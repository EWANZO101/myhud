local display = false

-- /gps command
RegisterCommand("gps", function()
    display = not display
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "toggleGPS",
        display = display
    })
end)

-- Update location + waypoint distance
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500) -- update twice per second
        if display then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))

            -- Default HUD text
            local hudText = "Street: " .. street

            -- Check if waypoint exists
            if IsWaypointActive() then
                local blip = GetFirstBlipInfoId(8) -- 8 = waypoint blip
                if DoesBlipExist(blip) then
                    local wpCoords = GetBlipInfoIdCoord(blip)
                    local dist = #(coords - vector3(wpCoords.x, wpCoords.y, wpCoords.z))
                    hudText = hudText .. " | Waypoint: " .. string.format("%.1f m", dist)
                end
            end

            -- Send data to NUI
            SendNUIMessage({
                type = "updateLocation",
                text = hudText
            })
        end
    end
end)
