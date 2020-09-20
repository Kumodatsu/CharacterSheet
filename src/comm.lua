local addon_name, CS = ...
local M = {}

-- Addon messages
CS_MessagePrefix = "CS"
local request_result =
    C_ChatInfo.RegisterAddonMessagePrefix(CS_MessagePrefix)
if not request_result then
    message "The CharacterSheet addon could not register a message prefix. The addon may not work properly."
end

CS.OnAddonMessageReceived:add(function(msg, channel, sender)
    CS.Output.Print("<CS RECEIVED> %s in %s: %s", sender, channel, msg)
end)

local send_addon_msg = function(channel, msg)
    local target = channel == "WHISPER" and UnitName("target") or nil
    C_ChatInfo.SendAddonMessage(CS_MessagePrefix, msg, channel, target)
    CS.Output.Print("<CS SENT> in %s: %s", channel, msg)
end

CS.Commands.add_cmd("comm", send_addon_msg, [[
"/cs comm <channel> <msg>" sends a CS addon message to the specified channel.
]])

CS.Comm = M
