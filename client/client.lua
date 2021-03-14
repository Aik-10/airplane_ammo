ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do 
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0) 
    end
end)

Citizen.CreateThread(function()
    while true do 
        Wait(1)
        if ( IsPedArmed(PlayerPedId(), 7)) then
            local hash = GetSelectedPedWeapon(PlayerPedId())
            local Currentammo = GetPedAmmoByType(PlayerPedId(), GetPedAmmoTypeFromWeapon(PlayerPedId(), hash))
            local CurrentbugWeapon = false

            if ( Currentammo == 1 ) then
                for i = 1, #weapons do
                    if ( weapons[i] == hash ) then
                        CurrentbugWeapon = true
                        break
                    end
                end
            end

            if ( CurrentbugWeapon ) then
                DisablePlayerFiring(PlayerId(), true)
            else
                if ( IsPedShooting(PlayerPedId()) ) then
                    if ( Currentammo == 0 ) then
                        ClearPedTasks(GetPlayerPed(-1))
                    end
                end
            end           
        else
            Wait(200)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(3)
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            if ( IsPedArmed(PlayerPedId(), 7)) then
                DisableControlAction(0,80, true) -- INPUT_VEH_CIN_CAM
            end
        elseif ( IsPedRagdoll(PlayerPedId())) then
            DisableControlAction(0,24, false) -- INPUT_ATTACK
        else
            Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do 
        Wait(3)
        if ( IsPedArmed(PlayerPedId(), 7)) then
            local hash = GetSelectedPedWeapon(PlayerPedId())
            local max = GetMaxAmmoInClip(PlayerPedId(),hash)
            local Currentammo = GetPedAmmoByType(PlayerPedId(), GetPedAmmoTypeFromWeapon(PlayerPedId(), hash))

            local _,currentClip = GetAmmoInClip(PlayerPedId(), hash)
            if ( currentClip ~= Currentammo ) then
                SetAmmoInClip(PlayerPedId(), hash, 0)
                Wait(3)
                if ( Currentammo > max ) then
                    SetPedAmmoByType(PlayerPedId(), GetPedAmmoTypeFromWeapon(PlayerPedId(), hash), max)
                else
                    SetPedAmmoByType(PlayerPedId(), GetPedAmmoTypeFromWeapon(PlayerPedId(), hash), Currentammo)
                end
            end
        else
            Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do 
        Wait(1)
        if ( IsPedArmed(PlayerPedId(), 6)) then
            local hash = GetSelectedPedWeapon(PlayerPedId())
            local Currentammo = GetPedAmmoByType(PlayerPedId(), GetPedAmmoTypeFromWeapon(PlayerPedId(), hash))
            local ammoGiving = GetMaxAmmoInClip(PlayerPedId(), hash) - Currentammo
            local CanReload = true

            for i = 1, #DisabledWeaponsRelaoding do
                if ( DisabledWeaponsRelaoding[i] == hash ) then
                    CanReload = false
                    break
                end
            end

            if IsControlJustReleased(1, 45) and ammoGiving > 0 and CanReload and not IsPedRagdoll(PlayerPedId()) then
                ESX.TriggerServerCallback('lentokone:ammo:getClips', function(count)
                    if ( count >= 1 ) then
                        local time = 4000
                        for i,v in ipairs( reloadTimes ) do
                            if ( GetHashKey(v["name"]) == hash) then
                                time = v["reloading"]
                                break
                            end
                        end
                        
                        exports['progbar']:Progress({
                            name = "realoading",
                            duration = time,
                            label = 'Ladataan asetta',
                            useWhileDead = true,
                            canCancel = true,
                            controlDisables = {
                                disableMovement = false,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true,
                            },
                            animation = {
                                animDict = "anim@mp_corona_idles@male_d@idle_a",
                                anim = "idle_a",
                                flags = 49,
                            },
                        }, function(cancelled)
                            if not cancelled then
                                ESX.TriggerServerCallback('lentokone:ammo:RemoveClips', function(status)
                                    if ( status ) then
                                        SetAmmoInClip(PlayerPedId(), hash, 0)
                                        local max = GetMaxAmmoInClip(PlayerPedId(), hash)
                                        local weapon = ESX.GetWeaponFromHash(hash)
                                        TriggerServerEvent('esx:updateWeaponAmmo', weapon['name'], max)
                                        SetPedAmmoByType(PlayerPedId(), GetPedAmmoTypeFromWeapon(PlayerPedId(), hash), max)
                                    end
                                end)
                            end
                        end)
                    end
                end)
            end
        else 
            Wait(1000)
        end 
    end
end)