local addon_name, CS = ...
CS.Mechanics = CS.Mechanics or {}
CS.Mechanics.Roll = {}

local M = CS.Mechanics.Roll

local T = CS.Locale.GetLocaleTranslations()

--[[
    Code for rolling dice, handling modifiers and showing the results in chat.
    Most of this code has been based on Skylar and Rennae's Dicemaster addon.
]]

M.Settings = {
    raid_rolls_enabled = false,
    display_raw_rolls  = false
}

local roll_records = {}

M.RollType = {
    Raw  = 1,
    Stat = 2,
    Heal = 3,
    Pet  = 4
}

local roll_matches = function(roll_data, lower, upper, name)
    return (
        roll_data.lower == lower and
        roll_data.upper == upper and
        (name == nil or roll_data.name == name)
    )
end

M.Roll = function(roll_type, lower, upper, mod, stat, tf)
    local roll_data = {
        name      = UnitName "player",
        lower     = tonumber(lower),
        upper     = tonumber(upper),
        mod       = tonumber(mod) or 0,
        stat      = stat,
        tf        = tf,
        roll_type = roll_type or M.RollType.Raw
    }
    table.insert(roll_records, roll_data)
    RandomRoll(lower, upper)
end

local toggle_raid_rolls = function()
    M.Settings.raid_rolls_enabled = not M.Settings.raid_rolls_enabled
    if M.Settings.raid_rolls_enabled then
        CS.print(T.MSG_RAID_ROLL_ENABLED)
    else
        CS.print(T.MSG_RAID_ROLL_DISABLED)
    end
end

CS.Command.add_cmd("raidrolls", toggle_raid_rolls, T.CMD_DESC_RAID_ROLLS)

-- This pattern is taken from Skylar and Rennae's Dicemaster addon
-- TODO: This doesn't seem to work for non-enUS localizations.
local roll_string_pattern = RANDOM_ROLL_RESULT
    : gsub("%%s", "(%%S+)")
    : gsub("%%d", "(%%d+)")
    : gsub("%(%(%%d%+%)%-%(%%d%+%)%)", "%%((%%d+)%%-(%%d+)%%)")

local on_system_message = function(message)
    local sender, roll, lower, upper = message:match(roll_string_pattern)
    roll  = tonumber(roll)
    lower = tonumber(lower)
    upper = tonumber(upper)
    local name = UnitName "player"

    -- Check if the received system message is a roll message from the player
    if not sender or sender ~= name or not roll or not lower or not upper then
        return
    end

    local mod       = 0
    local stat      = nil
    local tf        = nil
    local roll_type = nil
    for i = 1, #roll_records do
        if roll_matches(roll_records[i], lower, upper, name) then
            mod       = roll_records[i].mod
            stat      = roll_records[i].stat
            tf        = roll_records[i].tf
            roll_type = roll_records[i].roll_type
            table.remove(roll_records, i)
            break
        end
    end

    if not M.Settings.display_raw_rolls and
            (not roll_type or roll_type == M.RollType.Raw) then
        return
    end

    local roll_str = ""
    if roll == lower then
        roll_str = string.format(" (%s 1)", T.NATURAL)
    elseif roll == upper then
        local range = upper - (lower - 1)
        roll_str = string.format(" (%s %d)", T.NATURAL, range)
    end
    if stat ~= nil and lower == 1 and upper == 20 and tf == nil then
        roll_str = string.format(" %s%s", stat, roll_str)
    end
    tf = tf or function(x) return x end
    roll_str = string.format(
        "%d%s.",
        tf(roll + mod),
        roll_str
    )
    if M.Settings.raid_rolls_enabled then
        if IsInRaid() then
            return SendChatMessage(roll_str, "RAID")
        elseif IsInGroup() then
            return SendChatMessage(roll_str, "PARTY")
        end
    end
    CS.print(roll_str)
end

CS.Events.OnSystemMessageReceived:add(on_system_message)
