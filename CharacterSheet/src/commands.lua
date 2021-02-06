local _, CS = ...
local M = {}

local T = CS.Locale.GetLocaleTranslations()

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
    local args = CS.Table.get_range(tokens, 2, #tokens)
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
        CS.Print(T.MSG_UNKNOWN_COMMAND(name))
    end
end

M.add_cmd = function(name, f, description, packed)
    if CS.Table.has_key(M.cmds, name) then
        CS.Print(T.ERROR_DUPLICATE_COMMAND(name))
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
        CS.Print(T.ERROR_PARSE_COMMAND_FAILED(msg))
    end
end

local list_help = function(name)
    if name ~= nil then
        local entry = M.cmds[name]
        if entry ~= nil then
            CS.Print(entry.Description)
        else
            CS.Print(T.MSG_UNKNOWN_COMMAND(name))
        end
    else
        CS.Print("Available commands:")
        for k, v in pairs(M.cmds) do
            CS.Print("/cs %s", k)
        end
        CS.Print(T.MSG_HELP_COMMAND)
    end
end

M.add_cmd("help", list_help, [[
"/cs help" shows the list of commands.
"/cs help <command>" shows an explanation of the specified command.
]])

CS.Commands = M
