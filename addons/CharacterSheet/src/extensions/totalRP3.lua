if not TRP3_API then return end

local addon_name, CS = ...
local M = {}

local Enum    = CS.Type.Enum
local switch  = CS.switch
local switchf = CS.switchf

local T = CS.Locale.GetLocaleTranslations()

M.StatUpdateState = Enum {
    None      = 1,
    Currently = 2,
    OOC       = 3
}

M.UpdateTRPWithStats = M.StatUpdateState.None

local stat_patterns = {
    "^HP: %-?%d+/%d+\nSTR: %d+ / DEX: %d+ / CON: %d+ / INT: %d+ / WIS: %d+ / CHA: %d+",
    "^HP: %-?%d+/%d+\nPet HP: %-?%d+/%d+\nSTR: %d+ / DEX: %d+ / CON: %d+ / INT: %d+ / WIS: %d+ / CHA: %d+",
    "^HP: %-?%d+/%d+\nPet HP: %-?%d+/%d+\n[_%w%-%.]+: %-?%d+/%-?%d+\nSTR: %d+ / DEX: %d+ / CON: %d+ / INT: %d+ / WIS: %d+ / CHA: %d+",
    "^HP: %-?%d+/%d+\n[_%w%-%.]+: %-?%d+/%-?%d+\nSTR: %d+ / DEX: %d+ / CON: %d+ / INT: %d+ / WIS: %d+ / CHA: %d+"
}

M.set_ooc = function(content)
    content         = content or ""
    local character = TRP3_API.profile.getData "player/character"
    local old_ooc   = character.CO
    character.CO    = content
    local changed   = old_ooc ~= character.CO
    if changed then
        local context = TRP3_API.navigation.page.getCurrentContext()
        if context and context.isPlayer then
            TRP3_RegisterMiscViewCurrentlyOOC.ScrollFrame.ScrollBox.EditBox
                :ApplyText(character.CO)
        end
        character.v = TRP3_API.utils.math.incrementNumber(character.v or 1, 2)
        TRP3_Addon:TriggerEvent(
            TRP3_Addon.Events.REGISTER_DATA_UPDATED,
            TRP3_API.globals.player_id,
            TRP3_API.profile.getPlayerCurrentProfileID(),
            "character"
        )
    end
end

M.get_ooc = function()
    local character = TRP3_API.profile.getData "player/character"
    return character.CO or ""
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
            TRP3_RegisterMiscViewCurrentlyIC.ScrollFrame.ScrollBox.EditBox
                :ApplyText(character.CU)
        end
        character.v = TRP3_API.utils.math.incrementNumber(character.v or 1, 2)
        TRP3_Addon:TriggerEvent(
            TRP3_Addon.Events.REGISTER_DATA_UPDATED,
            TRP3_API.globals.player_id,
            TRP3_API.profile.getPlayerCurrentProfileID(),
            "character"
        )
    end
end

M.get_cur = function()
    local character = TRP3_API.profile.getData "player/character"
    return character.CU or ""
end

M.set = function(content_type, content)
    switchf(content_type) {
        [M.StatUpdateState.Currently] = function() M.set_cur(content) end,
        [M.StatUpdateState.OOC]       = function() M.set_ooc(content) end
    }
end

M.get = function(content_type)
    return switchf(content_type) {
        [M.StatUpdateState.Currently] = M.get_cur,
        [M.StatUpdateState.OOC]       = M.get_ooc
    }
end

local format_stats_string = function(hp, max_hp, str, dex, con, int, wis, cha,
        pet_active, pet_hp, pet_max_hp, resource)
    local pet_str = pet_active and
        string.format("Pet HP: %d/%d\n", pet_hp, pet_max_hp) or ""
    local res_str = resource and
        string.format("%s: %d/%d\n", resource.Name, resource.Value, resource.Max) or ""
    return string.format(
        "HP: %d/%d\n%s%sSTR: %d / DEX: %d / CON: %d / INT: %d / WIS: %d / CHA: %d",
        hp, max_hp, pet_str, res_str, str, dex, con, int, wis, cha
    )
end

local content_without_stats = function(content)
    for _, pattern in ipairs(stat_patterns) do
        local s, e = content:find(pattern)
        if s then
            content = content:sub(e + 1)
            break
        end
    end
    local s, e = content:find "^\n+"
    if s then
        content = content:sub(e + 1)
    end
    return content
end

local replace_stats = function(content, stats)
    content = content_without_stats(content)
    return stats .. "\n\n" .. content
end

local clear_stats = function(content_type)
  local content = M.get(content_type)
  content = content_without_stats(content)
  M.set(content_type, content)
end

local clear_all_stats = function()
  for _, content_type in ipairs {
    M.StatUpdateState.Currently,
    M.StatUpdateState.OOC,
  } do
    clear_stats(content_type)
  end
end

local update_trp_stats = function()
  if M.UpdateTRPWithStats == M.StatUpdateState.None then
    return
  end

  local sheet = CS.Mechanics.Sheet
  local stats = sheet.Stats

  local content = M.get(M.UpdateTRPWithStats)
  local stats_str = format_stats_string(
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
      stats:get_pet_max_hp(),
      sheet.Resource
  )
  local new_content = replace_stats(content, stats_str)
  M.set(M.UpdateTRPWithStats, new_content)
end

CS.CharacterSheet.OnStatsChanged:add(update_trp_stats)
CS.CharacterSheet.OnHPChanged:add(update_trp_stats)
CS.CharacterSheet.OnPetChanged:add(update_trp_stats)
CS.CharacterSheet.OnPetToggled:add(update_trp_stats)
CS.CharacterSheet.OnResourceChanged:add(update_trp_stats)

local set_ooc_packed = function(packed_content)
    M.set_ooc(packed_content and table.concat(packed_content, " ") or "")
end

local set_cur_packed = function(packed_content)
    M.set_cur(packed_content and table.concat(packed_content, " ") or "")
end

local update_trp_stats_based_on_setting = function()
  switchf(M.UpdateTRPWithStats) {
    [M.StatUpdateState.None] = function()
      clear_all_stats()
    end,
    [M.StatUpdateState.Currently] = function()
      clear_stats(M.StatUpdateState.OOC)
      update_trp_stats()
    end,
    [M.StatUpdateState.OOC] = function()
      clear_stats(M.StatUpdateState.Currently)
      update_trp_stats()
    end,
  }
end

M.set_stat_update_state = function(state)
  M.UpdateTRPWithStats = state
  update_trp_stats_based_on_setting()

  CS.Print(
    switch(state) {
        [M.StatUpdateState.None] =
            T.MSG_TRP_STATS_NONE,
        [M.StatUpdateState.Currently] =
            T.MSG_TRP_STATS_CURRENTLY,
        [M.StatUpdateState.OOC] =
            T.MSG_TRP_STATS_OOC
    }
  )
end

local set_stat_update = function(value)
  value = value and value:lower() or ""
  local state = switch(value) {
      ["off"] = M.StatUpdateState.None,
      ["cur"] = M.StatUpdateState.Currently,
      ["ooc"] = M.StatUpdateState.OOC,
  }
  if not state then
    CS.Print(T.MSG_TRP_STATS_ARGS)
    return
  end
  M.set_stat_update_state(state)
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

CS.Commands.add_cmd("trpclearstats", clear_all_stats, [[
"/cs trpclearstats" removes your stats from your TRP info if they are there, leaving the rest of the contents intact.
]])

TRP3_API.module.registerModule({
    name        = C_AddOns.GetAddOnMetadata(addon_name, "Title"),
    description = C_AddOns.GetAddOnMetadata(addon_name, "Notes"),
    version     = tonumber(
      C_AddOns.GetAddOnMetadata(addon_name, "Version"):match("^%d+%.%d+")
    ),
    id          = "trp3_character_sheet",
    onStart     = function() end,
    onInit      = function() end,
    minVersion  = 3
});

CS.Extensions.totalRP3 = M
