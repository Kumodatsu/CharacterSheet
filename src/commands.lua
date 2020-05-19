local _, cs = ...
local M = {}

local print = print

SLASH_CHARACTER_SHEET1 = "/cs"
SLASH_CHARACTER_SHEET2 = "/charsheet"

M.cmds = { }

-- msg: str -> bool, str, table
M.parse_cmd = function(msg)
    local tokens = {}
    for token in msg:gmatch("%w+") do
        table.insert(tokens, token)
    end
    if #tokens == 0 then
        return false
    end
    local cmd  = tokens[1]
    local args = cs.Table.get_range(tokens, 2, #tokens)
    return true, cmd, args
end

-- cmd: str, args: table
M.execute_cmd = function(name, args)
    local entry = M.cmds[name]
    if entry ~= nil then
        if entry.Packed then
            entry.Cmd(args)
        else
            entry.Cmd(unpack(args))
        end
    else
        print("Unknown command: " .. name)
    end
end

M.add_cmd = function(name, f, description, packed)
    if cs.Table.has_key(name) then
        print("Duplicate command name: " .. name)
    else
        if packed == nil then
            packed = false
        end
        M.cmds[name] = {
            Cmd         = f,
            Description = description,
            Packed      = packed
        }
    end
end

SlashCmdList["CHARACTER_SHEET"] = function(msg)
    local success, name, args = M.parse_cmd(msg)
    if success then
        M.execute_cmd(name, args)
    else
        print("Failed to parse command: " .. msg)
    end
end

local list_help = function(name)
    if name ~= nil then
        local entry = M.cmds[name]
        if entry ~= nil then
            print(entry.Description)
        else
            print("Unknown command: " .. name)
        end
    else
        for k, v in pairs(M.cmds) do
            print(k .. ": " .. v.Description)
        end
    end
end

M.add_cmd("help", list_help, [[
"/cs help" shows the list of commands.
"/cs help command" shows an explanation of the specified command.
]])

cs.Commands = M
