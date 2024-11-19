-- Allow hidden buffers
vim.opt.hidden = true

-- Sensible tabs
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Don't confuse Esc and Alt
vim.opt.ttimeout = false

-- Wildmenu for command line completion
-- first <tab> expands to longest common prefix and lists all completions, subsequent cycles
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full"

-- New vertical split to the right
vim.opt.splitright = true

-- When to automatically break the line
vim.opt.textwidth = 99

-- Remember undo history
vim.opt.undofile = true 

-- TODO add 'stack' to jump options?

-- do we really need to comment all of these, just use :help if you forget what they are for
vim.g.tex_flavor = 'latex'

vim.opt.termguicolors = true

-- legacy vim
-- When entering a terminal window, automatically enter insert mode
vim.cmd [[ autocmd BufWinEnter,WinEnter term://* startinsert ]]

-- Override some ftplugins to make textwidth work
vim.cmd [[ filetype plugin indent on ]]
vim.cmd [[ autocmd FileType lua setlocal fo+=t]] 
