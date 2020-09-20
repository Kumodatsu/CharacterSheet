if not TRP3_API then return end

local addon_name, cs = ...
local M = {}

-- Will be loaded from file on addon load
M.UpdateTRPWithStats = false

-- Set the player's OOC information to the given content string.
-- The body of this function has been obtained by reverse engineering
-- Tammya's TRP3 Currently Frame addon.
local set_trp_ooc = function(content)
    local character = TRP3_API.profile.getData("player/character")
    local changed   = false
    content = content or ""
    if character.CO ~= content then
        character.CO = content
        changed      = true
    end
    if changed then
        local context = TRP3_API.navigation.page.getCurrentContext()
        if context and context.isPlayer then
            TRP3_RegisterMiscViewCurrentlyOOCScrollText:SetText(
                character.CO
            )
        end
        character.v = TRP3_API.utils.math.incrementNumber(character.v or 1, 2)
        TRP3_API.events.fireEvent( 
            TRP3_API.events.REGISTER_DATA_UPDATED,
            TRP3_API.globals.player_id, 
            TRP3_API.profile.getPlayerCurrentProfileID(), 
            "character"
        )
    end
end

local format_stats_string = function(hp, max_hp, str, dex, con, int, wis, cha)
    return "HP: "  .. hp .. "/" .. max_hp ..
        "\nSTR: "  .. str .. " / DEX: " .. dex .. " / CON: " .. con ..
        " / INT: " .. int .. " / WIS: " .. wis .. " / CHA: " .. cha
end

local update_trp_stats = function()
    if not M.UpdateTRPWithStats then
        return
    end
    local stats = cs.Charsheet.Stats
    set_trp_ooc(format_stats_string(
        cs.Charsheet.CurrentHP,
        stats:get_max_hp(),
        stats.STR,
        stats.DEX,
        stats.CON,
        stats.INT,
        stats.WIS,
        stats.CHA
    ))
end

cs.Charsheet.OnStatsChanged:add(update_trp_stats)
cs.Charsheet.OnCurrentHPChanged:add(update_trp_stats)

TRP3_API.module.registerModule({
    name        = GetAddOnMetadata(addon_name, "Title"),
    description = GetAddOnMetadata(addon_name, "Notes"),
    version     = tonumber(
        GetAddOnMetadata(addon_name, "Version"):match("^%d+%.%d+")
    ),
    id          = "trp3_character_sheet",
    onStart     = function() end,
    onInit      = function() end,
    minVersion  = 3
});

local toggle_stat_update = function()
    M.UpdateTRPWithStats = not M.UpdateTRPWithStats
    if M.UpdateTRPWithStats then
        cs.Output.Print(
            "TRP OOC information now WILL be overwritten by your stats."
        )
    else
        cs.Output.Print(
            "TRP OOC information now WILL NOT be overwritten by your stats."
        )
    end
end

cs.Commands.add_cmd("trp", toggle_stat_update, [[
"/cs trp" toggles whether your stats are allowed to overwrite your TRP's OOC information.
]])

cs.Extensions.totalRP3 = M
