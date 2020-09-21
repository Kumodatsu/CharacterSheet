local addon_name, CS = ...
local M = {}

--[[
    Code for rolling dice, handling modifiers and showing the results in chat.
    Most of this code has been based on Skylar and Rennae's Dicemaster addon.
]]

-- Will be loaded from file on addon load
M.RaidRollsEnabled = false

M.RollRecords = {}

M.RollMatches = function(roll_data, lower, upper, name)
    return (
        roll_data.lower == lower and
        roll_data.upper == upper and
        (name == nil or roll_data.name == name)
    )
end

M.Roll = function(lower, upper, mod, stat)
    local roll_data = {
        name  = UnitName("player"),
        lower = tonumber(lower),
        upper = tonumber(upper),
        mod   = tonumber(mod) or 0,
        stat  = stat
    }
    table.insert(M.RollRecords, roll_data)
    RandomRoll(lower, upper)
end

local toggle_raid_rolls = function()
    M.RaidRollsEnabled = not M.RaidRollsEnabled
    if M.RaidRollsEnabled then
        CS.Output.Print("Raid roll messages are now ENABLED.")
    else
        CS.Output.Print("Raid roll messages are now DISABLED.")
    end
end

CS.Commands.add_cmd("raidrolls", toggle_raid_rolls, [[
Toggles raid roll messages on and off.
]])

-- This pattern is taken from Skylar and Rennae's Dicemaster addon
local roll_string_pattern = RANDOM_ROLL_RESULT
    :gsub("%%s", "(%%S+)")
    :gsub("%%d", "(%%d+)")
    :gsub("%(%(%%d%+%)%-%(%%d%+%)%)", "%%((%%d+)%%-(%%d+)%%)")

local on_system_message = function(message)
    local sender, roll, lower, upper = message:match(roll_string_pattern)
    roll  = tonumber(roll)
    lower = tonumber(lower)
    upper = tonumber(upper)
    local name = UnitName("player")

    if sender and sender == name then
        local mod  = 0
        local stat = nil
        for i = 1, #M.RollRecords do
            if M.RollMatches(M.RollRecords[i], lower, upper, name) then
                mod  = M.RollRecords[i].mod
                stat = M.RollRecords[i].stat
                table.remove(M.RollRecords, i)
                break
            end
        end

        local roll_str = ""
        if roll == lower then
            roll_str = " (NATURAL 1)"
        elseif roll == upper then
            local range = upper - (lower - 1)
            roll_str = string.format(" (NATURAL %d)", range)
        end
        if stat ~= nil then
            roll_str = string.format(" %s%s", stat, roll_str)
        end
        roll_str = string.format(
            "%d%s.",
            roll + mod,
            roll_str
        )
        if M.RaidRollsEnabled then
            if IsInRaid() then
                return SendChatMessage(roll_str, "RAID")
            elseif IsInGroup() then
                return SendChatMessage(roll_str, "PARTY")
            end
        end
        CS.Output.Print(roll_str)
    end
end

-- Frame to handle events
local frame_handle_rolls = CreateFrame("FRAME", "CS_HandleRolls")

frame_handle_rolls:RegisterEvent("CHAT_MSG_SYSTEM")

frame_handle_rolls.OnEvent = function(self, event, arg1)
    if event == "CHAT_MSG_SYSTEM" then
        on_system_message(arg1)
    end
end

frame_handle_rolls:SetScript("OnEvent", frame_handle_rolls.OnEvent)

CS.Roll = M
