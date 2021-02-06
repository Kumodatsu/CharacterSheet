local addon_name, CS = ...
local M = {}

M.DefaultLocale = "enUS"

M.Translations = {}

M.GetLocale = function()
    return GetLocale()
end

M.GetTranslations = function(locale)
    local translations = M.Translations[locale]
        or M.Translations[M.DefaultLocale]
    if not translations then
        return message "There is no translation table."
    end
    return translations
end

M.GetLocaleTranslations = function()
    return M.GetTranslations(M.GetLocale())
end

M.Translation = function(translations)
    for k, v in pairs(translations) do
        if v:find "%%%d+%$" then
            local str = v
            translations[k] = function(...)
                return CS.String.iformat(str, ...)
            end
        end
    end
    return translations
end

CS.Locale = M
