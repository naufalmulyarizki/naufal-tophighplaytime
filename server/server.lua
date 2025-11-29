local uPlyTime = {}
local Config = require 'shared.config'

lib.callback.register('naufal-tophighplaytime:server:getplaytime', function(source)
    local pt = MySQL.query.await('SELECT * FROM users_playtime')
    return pt[1] and pt or false
end)

local function Register(pData)
    uPlyTime[pData.source] = {
        time = os.time(),
        playerName = pData.name,
        identifier = GetPlayerIdentifierByType(pData.source, Config.identifier),
        steamname = GetPlayerName(pData.source)
    }
end

local function unLoaded(source)
    local pCache = uPlyTime[source]

    local identifier = pCache?.identifier or false
    local steam_name = pCache?.steamname or 'Unknown'
    local game_name = pCache?.playerName or 'Unknown'
    local time = pCache?.time or false

    if not time or not identifier then
        return
    end

    local total_time = os.time() - time

    local sqlUpdateFormat = [[
        UPDATE users_playtime SET 
            steam_name = ?,
            game_name = ?,
            total_time = total_time + ?
        WHERE steam = ?
    ]]

    local sqlInsertFormat = [[
        INSERT INTO users_playtime
            (steam, steam_name, game_name, total_time)
        VALUES
            (?, ?, ?, ?)
    ]]

    local updated = MySQL.update.await(sqlUpdateFormat, {steam_name, game_name, total_time, identifier})

    if updated < 1 then
        lib.print.info('Register a new playing time table for citizenid: ' .. steam_name)
        MySQL.insert.await(sqlInsertFormat, {identifier, steam_name, game_name, total_time})
    else
        lib.print.info('Updated total play time for citizenid:: ' .. steam_name)
    end
end

AddEventHandler('playerDropped', function (reason)
    unLoaded(source)
end)

AddEventHandler('RSGCore:Server:OnPlayerUnload', function(source)
    unLoaded(source)
end)

RegisterNetEvent('RSGCore:Server:PlayerLoaded', function(player)
    print(player.PlayerData.source)
    Register({
        source = player.PlayerData.source,
        name = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname,
        identifier = player.PlayerData.citizenid
    })
end)
