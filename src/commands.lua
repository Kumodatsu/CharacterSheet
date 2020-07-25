local _, cs = ...
local M = {}

SLASH_CHARACTER_SHEET1 = "/cs"
SLASH_CHARACTER_SHEET2 = "/charsheet"

M.cmds = { }

-- msg: str -> bool, str, table
M.parse_cmd = function(msg)
    local tokens = {}
    for token in msg:gmatch("[_%w%-%.]+") do
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
        cs.Output.Print("Unknown command: %s", name)
    end
end

M.add_cmd = function(name, f, description, packed)
    if cs.Table.has_key(name) then
        cs.Output.Print("Duplicate command name: %s", name)
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
        cs.Output.Print("Failed to parse command: %s", msg)
    end
end

local list_help = function(name)
    if name ~= nil then
        local entry = M.cmds[name]
        if entry ~= nil then
            cs.Output.Print(entry.Description)
        else
            cs.Output.Print("Unknown command: %s", name)
        end
    else
        cs.Output.Print("Available commands:")
        for k, v in pairs(M.cmds) do
            cs.Output.Print("/cs %s", k)
        end
        cs.Output.Print("Use \"/cs help <command>\" to show an explanation of the specified command.")
    end
end

M.add_cmd("help", list_help, [[
"/cs help" shows the list of commands.
"/cs help <command>" shows an explanation of the specified command.
]])

cs.Commands = M
