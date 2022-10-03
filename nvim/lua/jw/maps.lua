-- local commands = require("jw.commands")
local telescope = require("telescope.builtin")

local encode = require("jw.modifier_remap").encode
local unshifted = [[abcdefghijklmnopqrstuvwxyz,."_/!<%*$&]]
local shifted = [[ABCDEFGHIJKLMNOPQRSTUVWXYZ;:'?-~>#+^|]]

local function k(key, modifiers)
    modifiers = modifiers or {}
    if modifiers.S and #key == 1 then
        local index , _ = unshifted:find(key)
        if index then
            key = shifted:sub(index,index)
            modifiers.S = nil
        end
    end

    local encoded = encode(key, modifiers)
    if encoded then return encoded end
    if vim.tbl_isempty(modifiers) then return key end

    if #key == 1 then
        key = ("<%s>"):format(key)
    end
    for mod, _ in pairs(modifiers) do
        key = ("<%s-%s"):format(mod, key:sub(2))
    end
    return key
end

vim.keymap.set({'c', 'i', 't'}, k('<Space>', {S=true}), '<Space>')
vim.keymap.set({'c', 'i', 't'}, k('<Enter>', {S=true}), '<Enter>')
vim.keymap.set({'c','i','t','n','o','s','x'}, k('[', {C=true}), '<Esc>')
vim.keymap.set({'i','t','n','o','s','x'}, k(';', {C=true}), '<C-\\><C-n>:')

vim.keymap.set({'c','i','t','n','o','s','x'}, k('h', {A=true}), '<C-\\><C-n><C-w>h')
vim.keymap.set({'c','i','t','n','o','s','x'}, k('j', {A=true}), '<C-\\><C-n><C-w>j')
vim.keymap.set({'c','i','t','n','o','s','x'}, k('k', {A=true}), '<C-\\><C-n><C-w>k')
vim.keymap.set({'c','i','t','n','o','s','x'}, k('l', {A=true}), '<C-\\><C-n><C-w>l')

vim.keymap.set('n', '<Space>ll', '<Cmd>Luadev<CR>')
vim.keymap.set({'n','v'}, '<Space>lv', '<Plug>(Luadev-Run)')
