local addon_name, CS = ...
local M = CS.Saving

M.LoadData = function()
    local current_version = CS.Version.get_str()

    -- Account wide data
    do
        CS_DB = CS_DB or {}
        CS_DB.Version = CS_DB.Version or current_version
        local version  = CS.Version.from_str(CS_DB.Version)
        local versions = CS.Table.map(
            CS.Table.get_keys(M.LoadVersions),
            CS.Version.from_str
        )
        local load_version = CS.Table.nearest(versions, version)
        if load_version then
            M.LoadVersions[tostring(load_version)]()
        end
    end

    -- Character specific data
    do
        CS_Char_DB = CS_Char_DB or {}
        CS_Char_DB.Version = CS_Char_DB.Version or current_version
        local version  = CS.Version.from_str(CS_Char_DB.Version)
        local versions = CS.Table.map(
            CS.Table.get_keys(M.LoadCharVersions),
            CS.Version.from_str
        )
        local load_version = CS.Table.nearest(versions, version)
        if load_version then
            M.LoadCharVersions[tostring(load_version)]()
        end
    end
end
