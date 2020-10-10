if not TRP3_API then return end

local addon_name, CS = ...
local M = {}

M.set_ooc = function(content)
    content         = content or ""
    local character = TRP3_API.profile.getData "player/character"
    local old_ooc   = character.CO
    character.CO    = content
    local changed   = old_ooc ~= character.CO
    if changed then
        local context = TRP3_API.navigation.page.getCurrentContext()
        if context and context.isPlayer then
            TRP3_RegisterMiscViewCurrentlyOOCScrollText:SetText(character.CO)
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

M.set_cur = function(content)
    content         = content or ""
    local character = TRP3_API.profile.getData "player/character"
    local old_cur   = character.CU
    character.CU    = content
    local changed   = old_cur ~= character.CU
    if changed then
        local context = TRP3_API.navigation.page.getCurrentContext()
        if context and context.isPlayer then
            TRP3_RegisterMiscViewCurrentlyICScrollText:SetText(character.CU)
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
    return string.format(
        "HP: %d/%d\nSTR: %d / DEX: %d / CON: %d / INT: %d / WIS: %d / CHA: %d",
        hp, max_hp, str, dex, con, int, wis, cha
    )
end

local update_trp_stats = function()
    if not M.UpdateTRPWithStats then
        return
    end
    local stats = CS.Charsheet.Stats
    M.set_ooc(format_stats_string(
        CS.Charsheet.CurrentHP,
        stats:get_max_hp(),
        stats.STR,
        stats.DEX,
        stats.CON,
        stats.INT,
        stats.WIS,
        stats.CHA
    ))
end

CS.Charsheet.OnStatsChanged:add(update_trp_stats)
CS.Charsheet.OnHPChanged:add(update_trp_stats)

local set_ooc_packed = function(packed_content)
    M.set_ooc(packed_content and table.concat(packed_content, " ") or "")
end

local set_cur_packed = function(packed_content)
    M.set_cur(packed_content and table.concat(packed_content, " ") or "")
end

local toggle_stat_update = function()
    M.UpdateTRPWithStats = not M.UpdateTRPWithStats
    if M.UpdateTRPWithStats then
        CS.Output.Print(
            "TRP OOC information now WILL be overwritten by your stats."
        )
    else
        CS.Output.Print(
            "TRP OOC information now WILL NOT be overwritten by your stats."
        )
    end
end

CS.Commands.add_cmd("trpooc", set_ooc_packed, [[
"/cs trpooc" clears your TRP OOC information.
"/cs trpooc <content>" sets your TRP OOC information to the given content.
]], true)

CS.Commands.add_cmd("trpcur", set_cur_packed, [[
"/cs trpcur" clears your TRP Currently information.
"/cs trpcur <content>" sets your TRP Currently information to the given content.
]], true)

CS.Commands.add_cmd("trpstats", toggle_stat_update, [[
"/cs trpstats" toggles whether your stats are allowed to overwrite your TRP's OOC information.
]])

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

CS.Extensions.totalRP3 = M
