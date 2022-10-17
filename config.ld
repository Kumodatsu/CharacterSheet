project     = "Character Sheet"
title       = "Character Sheet API Reference"
description = [[
  World of Warcraft addon for managing character sheets for roleplaying events
  and automating relevant calculations.
]]

dir  = "doc"
file = {
  "addons/CharacterSheet",
  exclude = {
    "addons/CharacterSheet/src/locales",
    "addons/CharacterSheet/src/init.lua",
  },
}

format               = "plain"
sort                 = true
backtick_references  = true
no_space_before_args = true

new_type("event", "Events", false, "Parameters")
