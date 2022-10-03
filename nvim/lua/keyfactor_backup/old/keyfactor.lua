-- TODO figure out a way to override the thing shown by showcmd
-- TODO appropriately handle local mappings (e.g. buffer-local mappings, but possibly also
-- window/tabpage-local)

local module = {}

local utils = require('jw.utils')
local Trie = require('jw.trie')

local OPTIONS = {'remap', 'silent', 'expr'}
local MODES = {"c", "i", "n", "o", "s", "t", "x"}

local mappings = Trie:new()

for _, mode in ipairs(MODES) do
    mappings.insert(mode, {})
end


local function is_action(object)
    return type(object) == "string" or utils.is_callable(object)
end

local Action = {
    _next_id=1,
    _base_lhs = vim.api.nvim_replace_termcodes('<Plug>(Keyfactor)map', true, true, true),
}

function Action:new(raw, options, mode)
    object = {id=_next_id}
    setmetatable(object, self)
    self.__index = self
    self._next_id = self._next_id+1

    if type(raw) == 'string' then
        -- We map an internal "<Plug>" sequence to `raw`. Calling the Action performs a feedkeys
        -- for the "<Plug>" sequence. We could just directly feedkeys for `raw`, but then it would
        -- be harder to make e.g. <silent> work properly
        local keymap_opts = {
            noremap = not options.remap,
            silent = options.silent,
            expr = options.expr,
        }
        if raw:lower():sub(1, #'<plug>') == '<plug>' then
            keymap_opts.noremap = false
        end
        local lhs = self._base_lhs..tostring(object.id)
        vim.api.nvim_set_keymap(mode, lhs, raw, keymap_opts)

        object._callable = function()
            vim.api.nvim_feedkeys(lhs, 'mi', true)
        end

        object._cleanup = function()
            vim.api.nvim_del_keymap(mode, lhs)
        end
    elseif utils.is_callable(raw) then
        --TODO handle silent=true?
        object._callable = raw
    else
        error("Action constructor requires string or callable")
    end

    return object
end

function Action.__call(action)
    return action._callable()
end

function Action.__gc(action)
    if action._cleanup ~= nil then action._cleanup() end
end

--[[
External map table format:

keypress = "keypress"|keys={"key1", "key2", ...}
action = "action"|callable

map_table = {
    (keypress action?)
    {map_table}*
    [mode="modestr"]?
    [silent=...]?
    [remap=...]?
}
--]]

local function parse(map_table)
    local result = Trie:new()

    local function recurse(map_table, context)
        -- First, build the new context(s)
        local new_contexts = {}

        -- Overwrite the mode in the new context, if necessary
        if map_table.mode ~= nil then
            local mode_str = map_table.mode
            local mode = {}
            if type(mode_str) == 'string' then
                for i=1,#mode_str do
                    local m = mode_str:subs(i,i)
                    if vim.tbl_contains(MODES, m) then
                        table.insert(mode, m)
                    else
                        error("Unrecognized mode "..m.." for prefix "..context.prefix)
                    end
                end
                context.mode = mode
            else
                error("Mode is not a string for prefix "..context.prefix)
            end
        end

        -- Overwrite remaining options in new context, if necessary
        for _, option in ipairs(OPTIONS) do
            if map_table[option] ~= nil then
                context[option] = map_table[option]
            end
        end

        -- Get extension(s) of prefix
        local keys = map_table.keys
        local index = 1 -- keep track of whether we consumed an entry of map_table
        if not keys and type(map_table[1]) == 'string' then
            keys = {map_table[1]}
            index = 2
        end

        -- If there is nothing to do, quit with an error
        if #map_table < index then
            error("No mapping specified for prefix "..context.prefix)
        end

        -- Combine everything into new contexts
        if keys then
            for _, sequence in keys do
                local c = vim.deepcopy(context)
                c.prefix = c.prefix..sequence
                table.insert(new_contexts, c)
            end
        else
            table.insert(new_contexts, context)
        end

        -- Process the action, if there is any
        if keys then
            local action = nil
            if map_table.action ~= nil then
                action = map_table.action
            elseif is_action(map_table[index]) then
                action = map_table[index]
                index = index + 1
            end
            if action ~= nil then
                for _, c in ipairs(new_contexts) do
                    local keycodes = utils.string.split_keycodes(c.prefix)
                    local sequence = {}
                    for i, k in ipairs(keycodes) do
                        sequence[i] = vim.api.nvim_replace_termcodes(k, true, true, true)
                    end
                    for _, m in ipairs(c['mode']) do
                        local trie = result:get({m})
                        for i, k in ipairs(keycodes) do
                            trie = trie:get({sequence[i]})
                            if trie.value == nil then
                                trie.value = {keycode=k}
                            end
                        end
                        if trie.value.action ~= nil then
                            error("Multiple mappings specified for lhs "..context.prefix)
                        end
                        trie.value.action = Action:new(action, c, m)
                    end
                end
            end
        end

        -- Finally, proceed recursively
        for i = #index, #map_table do
            if type(map_table[i]) ~= 'table' then
                if is_action(map_table[index]) then
                    error("Wrong location to specify action for prefix"..context.prefix)
                else
                    error("Unrecognized map table entry for "..context.prefix)
                end
            else
                for _, context in pairs(new_contexts) do
                    recurse(map_table[i], context)
                end
            end
        end
    end

    recurse(map_table, vim.deepcopy(module.defaults))
    return result
end

local function get_listen_action(mode, key)
    return '<Cmd>lua package.loaded.keyfactor._listen("'.. mode..'",[['..key..']])<CR>'
end

function module._listen(mode, key)
    local key = vim.api.nvim_replace_termcodes(key, true, false, true)
    local trie = mappings:get({mode})
    local child
    local sequence = {}
    local history = {trie} -- all the trie nodes we visited
    local actions = {} -- index
    -- TODO make sure nothing we do here will clobber count/register, or else preserve them
    -- manually

    local function do_action()
        if #actions == 0 then
            return
        end
        local active = history[actions[#actions]]
        local remaining = table.concat(sequence, '', actions[#actions])
        vim.api.nvim_feedkeys(remaining, 'i', false)
        active.value.action()
    end

    while true do
        child = trie:get({key})
        if child then
            trie = child
            table.insert(sequence, key)
            table.insert(history, trie)
            if trie.value.action then
                table.insert(actions, #history)
            end

            if trie.n_children == 0 then
                -- We've reached a leaf, and must now perform an action
                if #actions > 0 then
                    do_action()
                else
                    error("Leaf does not have associated action!")
                end
                break
            end
        elseif _is_escape(key) then -- user cancelled sequence
            break
        elseif _is_backspace(key) then -- go back one step
            table.remove(sequence)
            if #sequence == 0 then
                break
            end
            table.remove(history)
            trie = history[#history]
            if #actions > 0 and actions[#actions] > #history then
                table.remove(actions)
            end
        else -- unrecognized key
            -- If there is an action to perform, do it
            if action_index > 0 then
                do_action()
                break
            else
            -- no action available
            -- TODO helpfully display possible completions
                print("Unrecognized key")
            end
        end

        key = vim.fn.getcharstr()
    end
end

function module.apply(map_table)
    local new_mappings = parse(map_table)

    -- Listen for additional key presses if necessary
    for mode, mode_mapping in pairs(new_mappings) do
        for _, trie in pairs(mode_mapping) do
            if trie.n_children > 0 then
                local rhs = get_listen_action(mode, trie.value.keypress)
                vim.api.nvim_set_keymap(mode, trie.value.keypress, rhs, {noremap=true})
            end
        end
    end

    mappings:extend(new_mappings)
end

function module.unmap(mode, key, recursive)
    --TODO
end

module.defaults = {
    mode='n',
    remap=false,
    silent=true,
    expr=false,
}

return module
