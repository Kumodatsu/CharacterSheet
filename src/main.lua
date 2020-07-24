local addon_name, cs = ...

-- Global addon getter
CS_GetAddon = function()
    return cs
end

-- Key bindings
BINDING_HEADER_CHARACTER_SHEET = "Character Sheet"
BINDING_NAME_INCREMENT_HP      = "Increment HP"
BINDING_NAME_DECREMENT_HP      = "Decrement HP"

-- Addon messages
CS_MessagePrefix = "CS"
local request_result =
    C_ChatInfo.RegisterAddonMessagePrefix(CS_MessagePrefix)
if not request_result then
    message("The CharacterSheet addon could not register a message prefix. The addon may not work properly.")
end
