if not TRP3_API then return end

local addon_name, CS = ...
local M = {}

local Enum   = CS.Type.Enum
local switch = CS.switch

M.StatUpdateState = Enum {
    None      = 1,
    Currently = 2,
    OOC       = 3
}

M.UpdateTRPWithStats = M.StatUpdateState.None

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

local format_stats_string = function(hp, max_hp, str, dex, con, int, wis, cha,
        pet_active, pet_hp, pet_max_hp)
    local pet_str = pet_active and
        string.format("Pet HP: %d/%d\n", pet_hp, pet_max_hp) or ""
    return string.format(
        "HP: %d/%d\n%sSTR: %d / DEX: %d / CON: %d / INT: %d / WIS: %d / CHA: %d",
        hp, max_hp, pet_str, str, dex, con, int, wis, cha
    )
end

local update_trp_stats = function()
    local f = M.StatUpdateState.match(M.UpdateTRPWithStats) {
        [M.StatUpdateState.Currently] = M.set_cur,
        [M.StatUpdateState.OOC]       = M.set_ooc
    }
    if not f then return end
    local sheet = CS.Mechanics.Sheet
    local stats = sheet.Stats
    f(format_stats_string(
        sheet.HP,
        stats:get_max_hp(),
        stats.STR,
        stats.DEX,
        stats.CON,
        stats.INT,
        stats.WIS,
        stats.CHA,
        sheet.PetActive,
        sheet.PetHP,
        stats:get_pet_max_hp()
    ))
end

CS.CharacterSheet.OnStatsChanged:add(update_trp_stats)
CS.CharacterSheet.OnHPChanged:add(update_trp_stats)
CS.CharacterSheet.OnPetChanged:add(update_trp_stats)

local set_ooc_packed = function(packed_content)
    M.set_ooc(packed_content and table.concat(packed_content, " ") or "")
end

local set_cur_packed = function(packed_content)
    M.set_cur(packed_content and table.concat(packed_content, " ") or "")
end

local set_stat_update = function(value)
    value = value and value:lower() or ""
    local state = switch(value) {
        ["off"] = M.StatUpdateState.None,
        ["cur"] = M.StatUpdateState.Currently,
        ["ooc"] = M.StatUpdateState.OOC,
    }
    if not state then
        return CS.Output.Print "The argument must be one of: off, cur, ooc"
    end
    M.UpdateTRPWithStats = state
    CS.Output.Print(
        switch(state) {
            [M.StatUpdateState.None] =
                "Your TRP information now will not be overwritten by your stats.",
            [M.StatUpdateState.Currently] =
                "Your TRP Currently information now will be overwritten by your stats.",
            [M.StatUpdateState.OOC] =
                "Your TRP OOC information now will be overwritten by your stats."
        }
    )
end

CS.Commands.add_cmd("trpooc", set_ooc_packed, [[
"/cs trpooc" clears your TRP OOC information.
"/cs trpooc <content>" sets your TRP OOC information to the given content.
]], true)

CS.Commands.add_cmd("trpcur", set_cur_packed, [[
"/cs trpcur" clears your TRP Currently information.
"/cs trpcur <content>" sets your TRP Currently information to the given content.
]], true)

CS.Commands.add_cmd("trpstats", set_stat_update, [[
"/cs trpstats cur" will make your stats overwrite your TRP Currently whenever they're updated.
"/cs trpstats ooc" will make your stats overwrite your TRP OOC whenever they're updated.
"/cs trpstats off" will make your stats not overwrite any of your TRP information.
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
