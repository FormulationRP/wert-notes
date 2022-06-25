ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

QBCore.Functions.CreateCallback('wert-notes:get-my-notes', function(source, cb)
    local ply = ESX.GetPlayerFromId(source)
    if ply then
        local result = MySQL.query.await('SELECT * FROM notepad WHERE citizenid = ?', {ply.PlayerData.citizenid})
        if result and result[1] then
            cb(result)
        else
            cb(nil)
        end
    else
        cb(nil)
    end
end)

RegisterNetEvent("wert-notes:server:new-note", function(text)
    local src = source
    local ply = ESX.GetPlayerFromId(source)
    if ply and text then
        MySQL.Async.fetchAll("INSERT INTO notepad SET citizenid = @citizenid, text = @text", {
            ["@citizenid"] = ply.PlayerData.citizenid,
            ["@text"] = text,
        })
    end
end)

RegisterNetEvent("wert-notes:server:save-note", function(id, text)
    local src = source
    local ply = ESX.GetPlayerFromId(source)
    if ply and id and text then
        TriggerClientEvent("form_core:Notify", src, "success"  "Note updated!",10000
        MySQL.Async.execute('UPDATE notepad SET text = ? WHERE id = ?', {text, id})
    end
end)

RegisterNetEvent("wert-notes:server:delete-note", function(id)
    local src = source
    if id then
        TriggerClientEvent("form_core:Notify", src, "error" "Note deleted!",10000)
        MySQL.Async.execute('DELETE FROM notepad WHERE id = @id', {['@id'] = id})
    end
end)

RegisterNetEvent("wert-notes:server:share-note", function(id, text, playerId)
    local src = source
    local ply = ESX.GetPlayerFromId(src)
    local trgt = ESX.GetPlayerFromId(playerId)
    if ply and trgt and id and text then
        MySQL.Async.fetchAll("INSERT INTO notepad SET citizenid = @citizenid, text = @text", {
            ["@citizenid"] = trgt.PlayerData.citizenid,
            ["@text"] = text,
        })
        TriggerClientEvent("form_core:Notify", ply.PlayerData.source, "success", " You gave your #" .. id .. " numbered note to the nearby player!",10000)
        TriggerClientEvent("form_core:Notify", trgt.PlayerData.source, "success", "You got a note!", 10000)
    end
end)

QBCore.Functions.CreateUseableItem("stickynote", function(source, item)
    local src = source
    TriggerClientEvent("wert-notes:client:use-item", src)
end)