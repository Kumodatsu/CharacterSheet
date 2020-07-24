local addon_name, cs = ...
local M = {}

-- Will be loaded from file on addon load
M.RaidRollsEnabled = false

local toggle_raid_rolls = function()
    M.RaidRollsEnabled = not M.RaidRollsEnabled
    if M.RaidRollsEnabled then
        print("Raid roll messages are now ENABLED.")
    else
        print("Raid roll messages are now DISABLED.")
    end
end

cs.Commands.add_cmd("raidrolls", toggle_raid_rolls, [[
Toggles raid roll messages on and off.
]])

local roll_string_pattern = RANDOM_ROLL_RESULT
    :gsub("%%s", "(%%S+)")
    :gsub("%%d", "(%%d+)")
    :gsub("%(%(%%d%+%)%-%(%%d%+%)%)", "%%((%%d+)%%-(%%d+)%%)")

local on_system_message = function(message)
    if not M.RaidRollsEnabled or not IsInGroup() then return end

    local sender, roll, lower, upper = message:match(roll_string_pattern)
    if sender and sender == UnitName("player") then
        --[[
        local output = string.format(
            "%s rolls %d (%d-%d).",
            sender, roll, lower, upper
        )
        ]]
        local output = string.format(
            "%d.",
            roll
        )
        print(output)
        SendChatMessage(output, "RAID")
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

cs.Roll = M
