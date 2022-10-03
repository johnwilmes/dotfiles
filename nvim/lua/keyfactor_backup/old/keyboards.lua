local keyboards = {}

local function _get_mod(code, mod)
    if #code == 1 then
        return '<'..mod..'-'..code..'>'
    else
        -- code is of form <Foo>
        return '<'..mod..'-'..code:sub(2)
    end
end

local function shift(code)
    return _get_mod(unshift(code), 'S')
end

local function ctrl(code)
    return _get_mod(unshift(code), 'C')
end

local function alt(code)
    return _get_mod(unshift(code), 'A')
end

local function super(code)
    return _get_mod(unshift(code), 'D')
end

--[[ TODO: just map ,/\:' to <S-.-_;"> and it will all work with regularized <S-blah> mappings ]]

keyboards.jw = {}
keyboards.jw.map = {
    left='<Left>',
    right='<Right>',
    up='<Up>',
    down='<Down>',
    home='<Home>',
    ['end']='<End>',
    page_up='<PageUp>',
    page_down='<PageDown>',
    alternate='<F7>',
    exit='<F4>',
    open='<F1>',
    git='<F2>',

    linewise='<Space>',
    charwise='<F17>',
    capitalize='z',
    layer_operator='r',
    join='w',
    comment='f',
    surround='s',
    indent='c',
    delete='m',
    magic='<F19>'
    yank='l',
    layer_action='p',
    insert='t',
    put='d',
    command='v',
    repeat='g',
    undo='b',

    goto='.',
    ['select']='<F18>',
    list='q',
    seek='"',
    jumps='x',
    layer_motion='-',
    object='a',
    scroll='u',
    -- '_' unassigned
    word='e',
    code='o',
    search=';',
    bigram='i',
    char='y',
    mark='j',
    layer_leader='h',
    register='k',

    magic='<F19>',
}

return keyboards
