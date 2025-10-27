---@class CtEntry
---@field pref string
---@field acc table<integer, string>
---@field add fun(this: CtEntry, s: string)

---@param this CtEntry
---@param s string
local function ctAdd(this, s)
    this.acc[#this.acc + 1] = s
end

---@param this CtEntry
---@return string
local function make(this)
    local s = table.concat(this.acc, ', ')

    if s:len() == 0 then
        return ''
    else
        return this.pref .. ' ' .. s
    end
end

---@param pref string
---@return CtEntry
local function newCtEntry(pref)
    return {
        pref = pref,
        acc = {},
        add = ctAdd,
        make = make
    }
end

---@type table<'add'|'solve'|'clean'|'fix', CtEntry>
local ct = {
    add = newCtEntry('Added'),
    solve = newCtEntry('Solved'),
    clean = newCtEntry('Cleaned'),
    fix = newCtEntry('Fixed')
}

local key = nil

for i = 1, select('#', ...) do
    ---@type string
    local s = select(i, ...)

    if s == '-h' or s == '--help' then
        print('commit.lua [-h --help] [-a --add <...>] [-s --sol <...>] [-c --clean <...>] [-f --fix <...>]')
        os.exit(0)
    elseif s == '-a' or s == '--add' then
        key = 'add'
    elseif s == '-s' or s == '--sol' then
        key = 'solve'
    elseif s == '-c' or s == '--clean' then
        key = 'clean'
    elseif s == '-f' or s == '--fix' then
        key = 'fix'
    elseif key then
        --local _, _, name = s:find("([%w_-]+%.pg)$")
        ct[key].add(ct[key], s)
    end
end

local made = {
    make(ct.add),
    make(ct.solve),
    make(ct.clean),
    make(ct.fix)
}

--[[
print('added: `' .. added .. '`')
print('solved: `' .. solved .. '`')
print('cleaned: `' .. cleaned .. '`')
print('fixed: `' .. fixed .. '`')
]]


local fname = 'com.txt'

local f, err = io.open(fname, 'w')
if err then
    print(err)
    os.exit(1)
elseif not f then
    print("Unable to open '" .. fname .. "'")
    os.exit(1)
end

f:write('Changes:\n')

for i = 1, #made do
    local s = made[i]

    if s:len() > 0 then
        f:write(' ')
        f:write(s)
        f:write('\n')
    end
end

f:close()

local c = string.format('git commit -aF %s', fname)

local success, _, code = os.execute(c)
if not success or code ~= 0 then
    os.remove(fname)
    os.exit(1)
end

os.remove(fname)
