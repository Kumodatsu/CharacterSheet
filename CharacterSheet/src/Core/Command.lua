local addon_name, CS = ...
CS.Command = {}

local M = CS.Command

local T = CS.Locale.GetLocaleTranslations()

SLASH_CHARACTER_SHEET1 = "/cs"
SLASH_CHARACTER_SHEET2 = "/charsheet"

M.Commands = {}

M.parse_cmd = function(input)
    local tokens = {}
    for token in input:gmatch "[%S]+" do
        table.insert(tokens, token)
    end
    if #tokens == 0 then
        return false
    end
    local cmd  = tokens[1]
    local args = { unpack(tokens, 2, #tokens) }
    return true, cmd, args
end

M.add_cmd = function(name, f, description, packed)
    if M.Commands[name] then
        return CS.print(T.ERROR_DUPLICATE_COMMAND(name))
    end
    if packed == nil then
        packed = false
    end
    M.Commands[name] = {
        Command     = f,
        Description = description,
        Packed      = packed
    }
end

M.execute_cmd = function(name, args)
    local entry = M.Commands[name]
    if entry ~= nil then
        if entry.Packed then
            entry.Command(args)
        else
            entry.Command(unpack(args))
        end
    else
        CS.print(T.MSG_UNKNOWN_COMMAND(name))
    end
end

SlashCmdList["CHARACTER_SHEET"] = function(input)
    local success, name, args = M.parse_cmd(input)
    if success then
        M.execute_cmd(name, args)
    else
        CS.print(T.ERROR_PARSE_COMMAND_FAILED(input))
    end
end

local list_help = function(name)
    if not name then
        CS.print(T.MSG_AVAILABLE_COMMANDS)
        for k, v in pairs(M.Commands) do
            CS.print("/cs %s", k)
        end
        CS.print(T.MSG_HELP_COMMAND)
        return
    end
    local entry = M.Commands[name]
    if not entry then
        return CS.print(T.MSG_UNKNOWN_COMMAND(name))
    end
    CS.print(entry.Description)
end

M.add_cmd("help", list_help, T.CMD_DESC_HELP)
