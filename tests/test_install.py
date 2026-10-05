"""Run installation in a temporary fixture with package/system commands stubbed.

The fixture substitutes TEST_HOME for HOME in scripts; the real home and shell
startup files are never modified. No network, sudo, or package installs occur.
"""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='dotfiles test ')
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.repo = self.root / 'repo'
        self.repo.mkdir()
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.home = self.root / 'home with spaces'
        self.home.mkdir()
        self.log = self.root / 'calls'
        self.env = dict(os.environ, TEST_HOME=str(self.home), TEST_LOG=str(self.log),
                        TEST_OS='Darwin', TEST_ARCH='arm64',
                        PATH=f'{self.bin}:/usr/bin:/bin', UPGRADE_TOOLS='false')
        for name in ['install', 'scripts/homebrew.sh', 'profiles/core/setup.sh']:
            target = self.repo / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text((ROOT / name).read_text().replace('$HOME', '$TEST_HOME'))
        for profile in ['core', 'macos', 'ubuntu', 'wsl']:
            folder = self.repo / 'profiles' / profile
            folder.mkdir(exist_ok=True)
            for name in ['dotbot.yaml', 'packages.brew', 'packages.apt']:
                source = ROOT / 'profiles' / profile / name
                if source.exists():
                    shutil.copyfile(source, folder / name)
            (folder / 'setup.sh').write_text('#!/bin/bash\necho "setup ' + profile + '" >> "$TEST_LOG"\n')
        self.stub('uname', 'case "$1" in -s) echo "$TEST_OS";; -m) echo "$TEST_ARCH";; esac')
        for name in ['git', 'python3', 'sudo', 'apt-get', 'nvim', 'uv', 'uvx', 'zsh']:
            self.stub(name, f'echo "{name} $*" >> "$TEST_LOG"')
        self.stub('curl', 'echo "unexpected curl" >> "$TEST_LOG"; exit 22')
        # Exercise installed-but-not-on-PATH discovery without using host brew.
        self.brew = self.root / 'brew-prefix' / 'bin' / 'brew'
        self.brew.parent.mkdir(parents=True)
        self.brew.write_text('''#!/bin/bash
printf 'brew %s\\n' "$*" >> "$TEST_LOG"
if [[ "$1" == shellenv ]]; then
    printf 'export HOMEBREW_PREFIX="test";\\n'
fi
''')
        self.brew.chmod(0o755)
        helper = self.repo / 'scripts/homebrew.sh'
        helper.write_text(helper.read_text().replace('/opt/homebrew/bin/brew', '"' + str(self.brew) + '"')
                          .replace('/usr/local/bin/brew', '"' + str(self.root / 'missing-brew') + '"'))

    def stub(self, name, body):
        file = self.bin / name
        file.write_text('#!/bin/bash\n' + body + '\n')
        file.chmod(0o755)

    def run_install(self, *args):
        return subprocess.run(['/bin/bash', str(self.repo / 'install'), *args],
                              cwd=self.root, env=self.env, text=True, capture_output=True)

    def calls(self):
        return self.log.read_text() if self.log.exists() else ''

    def test_macos_existing_brew_missing_path_and_repeat(self):
        for _ in range(2):
            result = self.run_install('macos')
            self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.calls()
        self.assertEqual(calls.count('brew shellenv bash'), 2)
        self.assertNotIn('unexpected curl', calls)
        self.assertNotIn('brew upgrade', calls)
        self.assertIn('submodule update --init --recursive', calls)
        self.assertIn('neovim uv pygments', calls)
        self.assertLess(calls.index('brew shellenv bash'), calls.index('brew update'))
        self.assertLess(calls.index('setup core'), calls.index('setup macos'))
        self.assertLess(calls.index('setup macos'), calls.index('dotbot/bin/dotbot'))
        self.assertIn('profiles/core/dotbot.yaml', calls)
        self.assertIn('profiles/macos/dotbot.yaml', calls)

    def test_fresh_homebrew_is_initialized_after_install(self):
        self.brew.unlink()
        self.env['TEST_BREW'] = str(self.brew)
        self.stub('curl', """echo 'download brew installer' >> "$TEST_LOG"
while [[ $# -gt 0 ]]; do
    if [[ "$1" == -o ]]; then output=$2; break; fi
    shift
done
cat > "$output" <<'INSTALLER'
#!/bin/bash
cat > "$TEST_BREW" <<'BREW'
#!/bin/bash
echo "brew $*" >> "$TEST_LOG"
if [[ "$1" == shellenv ]]; then echo 'export HOMEBREW_PREFIX=test'; fi
BREW
chmod +x "$TEST_BREW"
INSTALLER
""")
        result = self.run_install('macos')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertLess(self.calls().index('download brew installer'),
                        self.calls().index('brew shellenv bash'))

    def test_failed_homebrew_download_stops_installation(self):
        self.brew.unlink()
        result = self.run_install('macos')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('setup', self.calls())
        self.assertNotIn('dotbot/bin/dotbot', self.calls())

    def test_arguments_have_no_install_side_effects(self):
        for args in [(), ('bogus',), ('macos', '--bogus'), ('ubuntu',)]:
            self.assertNotEqual(self.run_install(*args).returncode, 0)
        self.assertEqual(self.calls(), '')

    def test_upgrade_is_explicit(self):
        result = self.run_install('macos', '--upgrade')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('brew upgrade', self.calls())

    def test_package_failure_stops_before_setup_and_links(self):
        self.brew.write_text('#!/bin/bash\n[[ "$1" != install ]]\n')
        self.assertNotEqual(self.run_install('macos').returncode, 0)
        self.assertNotIn('setup', self.calls())
        self.assertNotIn('dotbot/bin/dotbot', self.calls())

    def test_ubuntu_repository_before_wezterm(self):
        self.env['TEST_OS'] = 'Linux'
        prereq = self.repo / 'profiles/ubuntu/prerequisites.sh'
        shutil.copyfile(ROOT / 'profiles/ubuntu/prerequisites.sh', prereq)
        self.stub('curl', 'echo "download repo key" >> "$TEST_LOG"')
        result = self.run_install('ubuntu')
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.calls()
        self.assertLess(calls.index('download repo key'), calls.index('sudo apt-get install -y build-essential'))
        self.assertNotIn('apt-get upgrade', calls)
        self.assertLess(calls.index('setup ubuntu'), calls.index('dotbot/bin/dotbot'))

    def test_core_download_failure_preserves_existing_tools(self):
        self.env.update(TEST_OS='Linux', STOW_DIR=str(self.root / 'stow'),
                        BIN_DEST=str(self.root / 'tools'), UPGRADE_TOOLS='true')
        tools = Path(self.env['BIN_DEST'])
        tools.mkdir()
        original = tools / 'nvim'
        original.write_text('original executable')
        script = self.repo / 'real-core.sh'
        script.write_text((ROOT / 'profiles/core/setup.sh').read_text())
        result = subprocess.run(['/bin/bash', str(script)], env=self.env, capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(original.read_text(), 'original executable')
        self.assertFalse(Path(self.env['STOW_DIR']).exists())

    def test_linux_architectures_install_and_repeat_without_download(self):
        import io
        import tarfile
        archives = self.root / 'archives'
        archives.mkdir()
        for name, members in [('nvim', ['bin/nvim']), ('uv', ['uv', 'uvx'])]:
            with tarfile.open(archives / (name + '.tar.gz'), 'w:gz') as archive:
                for member in members:
                    body = b'#!/bin/sh\nexit 0\n'
                    info = tarfile.TarInfo('release/' + member)
                    info.mode = 0o755
                    info.size = len(body)
                    archive.addfile(info, io.BytesIO(body))
        self.env.update(TEST_OS='Linux', STOW_DIR=str(self.root / 'stow'),
                        BIN_DEST=str(self.root / 'tools'), TEST_ARCHIVES=str(archives),
                        UPGRADE_TOOLS='true')
        self.stub('curl', """echo "curl $*" >> "$TEST_LOG"
case "$2" in *neovim*) name=nvim ;; *) name=uv ;; esac
cp "$TEST_ARCHIVES/$name.tar.gz" "$4"
""")
        script = self.repo / 'real-core.sh'
        script.write_text((ROOT / 'profiles/core/setup.sh').read_text())
        for arch, nvim_arch, uv_arch in [('x86_64', 'x86_64', 'x86_64'), ('aarch64', 'arm64', 'aarch64')]:
            self.env['TEST_ARCH'] = arch
            result = subprocess.run(['/bin/bash', str(script)], env=self.env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('nvim-linux-' + nvim_arch + '.tar.gz', self.calls())
            self.assertIn('uv-' + uv_arch + '-unknown-linux-gnu.tar.gz', self.calls())
            for tool in ['nvim', 'uv', 'uvx']:
                self.assertTrue((Path(self.env['BIN_DEST']) / tool).is_file())
        calls = self.calls()
        self.env['UPGRADE_TOOLS'] = 'false'
        result = subprocess.run(['/bin/bash', str(script)], env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls().count('curl '), calls.count('curl '))

    def test_wsl_paths_spaces_backups_and_repeat(self):
        windows = self.root / 'Windows User Home'
        windows.mkdir()
        (windows / '.wezterm.lua').write_text('old configuration')
        (self.repo / 'wezterm.lua').write_text('new configuration')
        self.env.update(TEST_WINDOWS_HOME=str(windows), BASE_DIR=str(self.repo))
        self.stub('powershell.exe', 'printf "C:\\\\Users\\\\Name With Spaces\\r\\n"')
        self.stub('wslpath', 'echo "$TEST_WINDOWS_HOME"')
        script = self.repo / 'real-wsl.sh'
        script.write_text((ROOT / 'profiles/wsl/setup.sh').read_text().replace('$HOME', '$TEST_HOME'))
        for _ in range(2):
            result = subprocess.run(['/bin/bash', str(script)], env=self.env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.home / 'winhome').resolve(), windows.resolve())
        self.assertEqual((windows / '.wezterm.lua').read_text(), 'new configuration')
        backups = list(windows.glob('.wezterm.lua.backup.*'))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(), 'old configuration')

    def test_core_macos_does_not_download_or_change_shell(self):
        script = self.repo / 'real-core.sh'
        script.write_text((ROOT / 'profiles/core/setup.sh').read_text())
        self.stub('chsh', 'echo "unexpected chsh" >> "$TEST_LOG"; exit 1')
        result = subprocess.run(['/bin/bash', str(script)], env=self.env, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('unexpected', self.calls())


if __name__ == '__main__':
    unittest.main()
