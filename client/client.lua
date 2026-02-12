local ESX = exports['es_extended']:getSharedObject()

local isNuiOpen = false
local peds = {}

local function IsNearJobCenter()
    local playerCoords = GetEntityCoords(PlayerPedId())
    
    for _, location in ipairs(Config.TargetLocations) do
        local coordsCheck
        if location.type == "ped" or location.type == "model" then
            coordsCheck = vector3(location.coords.x, location.coords.y, location.coords.z)
        elseif location.type == "sphere" then
            coordsCheck = location.coords
        end
        
        if coordsCheck and #(playerCoords - coordsCheck) <= Config.MaxDistance then
            return true
        end
    end
    
    return false
end

local function OpenJobCenter()
    if isNuiOpen then return end
    
    lib.callback('job_center:getJobs', false, function(data)
        if not data then return end
        
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'open',
            data = data
        })
        isNuiOpen = true
    end)
end

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    isNuiOpen = false
    cb('ok')
end)

RegisterNUICallback('applyJob', function(data, cb)
    if not data or not data.jobindex then
        cb({
            success = false,
            message = Config.Locale.error
        })
        return
    end
    
    if not IsNearJobCenter() then
        lib.notify({
            title = 'Job Center',
            description = Config.Locale.tooFar,
            type = 'error'
        })
        cb({
            success = false,
            message = Config.Locale.tooFar
        })
        return
    end
    
    lib.callback('job_center:applyJob', false, function(result)
        if not result then
            local errorMsg = Config.Locale.error
            lib.notify({
                title = 'Job Center',
                description = errorMsg,
                type = 'error'
            })
            cb({
                success = false,
                message = errorMsg
            })
            return
        end
        
        if result.success then
            lib.notify({
                title = 'Job Center',
                description = result.message,
                type = 'success'
            })
            SetNuiFocus(false, false)
            isNuiOpen = false
        else
            lib.notify({
                title = 'Job Center',
                description = result.message,
                type = 'error'
            })
        end
        
        cb(result)
    end, data.jobindex)
end)

if Config.UseTarget then
    CreateThread(function()
        for i, location in ipairs(Config.TargetLocations) do
            if location.type == "ped" then
                local modelhash = GetHashKey(location.model)
                lib.requestModel(modelhash, 10000)
                
                local coords = location.coords
                local ped = CreatePed(4, modelhash, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
                
                if ped ~= 0 then
                    FreezeEntityPosition(ped, true)
                    SetEntityInvincible(ped, true)
                    SetBlockingOfNonTemporaryEvents(ped, true)
                    
                    peds[#peds + 1] = ped
                    
                    exports.ox_target:addLocalEntity(ped, {{
                        name = 'job_center_ped_' .. i,
                        icon = 'fas fa-briefcase',
                        label = Config.Locale.openMenu or 'Open Job Center',
                        onSelect = OpenJobCenter,
                        distance = 2.5
                    }})
                    
                    if Config.Debug then
                        print(("^2[Job Center]^0 Spawned ped at %.2f, %.2f, %.2f"):format(
                            coords.x,
                            coords.y,
                            coords.z
                        ))
                    end
                elseif Config.Debug then
                    print("^1[Job Center]^0 Failed to create ped")
                end
                
            elseif location.type == "sphere" then
                exports.ox_target:addSphereZone({
                    coords = location.coords,
                    radius = location.radius or 1.5,
                    options = {{
                        name = 'job_center_sphere_' .. i,
                        icon = 'fas fa-briefcase',
                        label = Config.Locale.openMenu or 'Open Job Center',
                        onSelect = OpenJobCenter
                    }}
                })
                
                if Config.Debug then
                    print("^2[Job Center]^0 Created sphere zone")
                end
                
            elseif location.type == "model" then
                exports.ox_target:addModel(location.model, {{
                    name = 'job_center_model_' .. i,
                    icon = 'fas fa-briefcase',
                    label = Config.Locale.openMenu or 'Open Job Center',
                    onSelect = OpenJobCenter,
                    distance = 2.5
                }})
                
                if Config.Debug then
                    print(("^2[Job Center]^0 Added target to model '%s'"):format(
                        location.model
                    ))
                end
            end
        end
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    
    for _, ped in ipairs(peds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    
    if isNuiOpen then
        SetNuiFocus(false, false)
    end
end)

if Config.Debug then
    RegisterCommand('jobcenter', function()
        OpenJobCenter()
    end, false)
end
