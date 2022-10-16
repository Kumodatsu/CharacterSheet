--- Functionality for registering slash commands.
-- @module Core.Command
local _, CS = ...
local M = {}

local get_range = CS.Core.Util.get_range
local match     = CS.Core.Util.match
local display   = CS.Core.Util.display
local translate = CS.Core.Locale.translate

SLASH_CHARACTER_SHEET1 = "/cs"
SLASH_CHARACTER_SHEET2 = "/charsheet"

local commands = {}

--- Parses some input string as a slash command.
-- The input is expected to be the actual command name followed by the command
-- arguments separated by spaces, without the preceding '/cs' or '/charsheet'.
-- @tparam string input
-- The input string.
-- @treturn bool
-- true if parsing was successful, false otherwise.
-- @treturn ?string
-- The command name.
-- @treturn ?table
-- A table of the arguments passed to the command.
local parse = function(input)
  local tokens = match(input, "%S+")
  if #tokens == 0 then return false end
  local cmd  = tokens[1]
  local args = get_range(tokens, 2, #tokens)
  return true, cmd, args
end

--- Executes a command with the given arguments.
-- @tparam string cmd_name
-- The name of the command.
-- @tparam table args
-- A table containing the arguments to be passed to the command function.
local execute = function(cmd_name, args)
  local entry = commands[cmd_name]
  if not entry then
    display(translate("MSG_UNKNOWN_COMMAND", cmd_name))
    return
  end
  entry.command(unpack(args))
end

--- Registers a slash command that invokes a function.
-- The command will be run as '/cs cmd_name args', where args is a space
-- separated list of arguments to be passed to the registered function.
-- @tparam string cmd_name
-- The name of the command.
-- @tparam string description_key
-- The translation key associated with the description for the command.
-- @tparam function f
-- The function to be invoked when the command is run.
function M.register_cmd(cmd_name, description_key, f)
  if commands[cmd_name] then
    error(string.format(
      "The command '%s' has been registered multiple times.",
      cmd_name
    ))
  end
  commands[cmd_name] = {
    name            = name,
    description_key = description_key,
    command         = f,
  }
end

-- A function is registered with World of Warcraft to be called when a '/cs' or
-- '/charsheet' command is run, which then invokes functions registered with
-- register_cmd
SlashCmdList["CHARACTER_SHEET"] = function(input)
  local success, cmd_name, args = parse(input)
  if not success then
    display(translate("ERROR_PARSE_COMMAND_FAILED", input))
    return
  end
  execute(cmd_name, args)
end

-- '/cs help' displays a list of available commands or a description of a
-- specific command.
M.register_cmd("help", "CMD_DESC_HELP", function(cmd_name)
  if cmd_name then
    local entry = commands[cmd_name]
    if not entry then
      display(translate("MSG_UNKNOWN_COMMAND", cmd_name))
      return
    end
    display("/cs %1$s\n%2$s", cmd_name, translate(entry.description_key))
  else
    display(translate "AVAILABLE_COMMANDS")
    for k, v in pairs(commands) do
      display("/cs %1$s", k)
    end
    display(translate "MSG_HELP_COMMAND")
  end
end)

CS.Core.Command = M
