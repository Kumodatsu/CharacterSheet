--- Locale and translation functionality.
-- @module CS.Core.Locale
local _, CS = ...
local M = {}

local iformat = CS.Core.Util.iformat

local default_locale = "enUS"

local translations = {}

--- Gets the tag of the currently active locale.
-- @treturn string
-- The tag of the currently active locale.
function M.get_locale()
  return GetLocale()
end

--- Gets the translation table for the specified locale.
-- If the locale is unspecified or if the given locale is not supported or does
-- not exist, falls back to the default locale.
-- @tparam ?string locale
-- The tag for the desired locale, for example "enUS".
-- @treturn table
-- The translation table.
function M.get_translation_table(locale)
  locale = locale or default_locale
  local translation_table = translations[locale] or translations[default_locale]
  if not translation_table then
    error "There is no translation table."
  end
  return translation_table
end

--- Adds a translation table for the given locale.
-- @tparam string locale
-- The locale for which this translation table applies.
-- @tparam table translation_table
-- A table whose keys are valid translation keys and whose values are the
-- translations. If the translations require arguments, they must be formatted
-- such that they can be used by @{CS.Core.Util.iformat|iformat}.
function M.add_translation_table(locale, translation_table)
  if translations[locale] then
    error(string.format(
      "More than one translation table has been added for the locale '%s'.",
      locale
    ))
  end
  translations[locale] = translation_table
end

--- Gets the translation associated with a translation key for a locale.
-- @tparam string locale
-- The locale for which to fetch the translation.
-- @tparam string translation_key
-- The translation key for which to fetch the translation.
-- @param ...
-- Any arguments to be formatted into the translation string.
-- @treturn string
-- The formatted translation.
function M.translate_for_locale(locale, translation_key, ...)
  if not translations[locale] then
    error(string.format(
      "Locale '%s' is not supported or does not exist.",
      locale
    ))
  end
  local translation = translations[locale][translation_key]
  if not translation then
    error(string.format(
      "Translation key '%s' is missing for locale '%s'.",
      translation_key,
      locale
    ))
  end
  return iformat(translation, ...)
end

--- Gets the translation associated with a translation key for the currently
--- active locale.
-- @tparam string translation_key
-- The translation key for which to fetch the translation.
-- @param ...
-- Any arguments to be formatted into the translation string.
-- @treturn string
-- The formatted translation.
function M.translate(translation_key, ...)
  return M.translate_for_locale(M.get_locale(), translation_key, ...)
end

CS.Core.Locale = M
