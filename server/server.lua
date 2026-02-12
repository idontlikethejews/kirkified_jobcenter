local ESX = exports['es_extended']:getSharedObject()

local jobstab ={}
local applycd = {}
local getcd = {}

CreateThread(function()
    local params = {}
    for _, jobdata in ipairs(Config.Jobs) do
        params[#params + 1] = jobdata.job
        params[#params + 1] = jobdata.grade
    end

    local placeholders = {}
    for i = 1, #Config.Jobs do
        placeholders[#placeholders + 1] = '(job_name = ? and grade = ?)'
    end

    local query = 'select job_name, grade, salary from job_grades where ' .. table.concat(placeholders, ' or ')
    local results = MySQL.query.await(query, params) or {}

    local salarytab = {}
    for _, row in ipairs(results) do
        salarytab[row.job_name .. '_' .. row.grade] = row.salary
    end

    for index, jobdata in ipairs(Config.Jobs) do
        local key = jobdata.job .. '_' .. jobdata.grade
        local salary = salarytab[key] or 0

        jobstab[index] = {
            job = jobdata.job,
            grade = jobdata.grade,
            label = jobdata.label,
            description = jobdata.description,
            icon = jobdata.icon,
            image = jobdata.image,
            requirements = jobdata.requirements,
            salary = salary
        }

        if Config.Debug then
            if salary > 0 then
                print(('^2[Job Center]^0 %s (Grade %d), salary: $%d'):format(
                    jobdata.job,
                    jobdata.grade,
                    salary
                ))
            else
                print(('^1[Job Center]^0 %s (Grade %d) IS NOT FOUND IN THE DB'):format(
                    jobdata.job,
                    jobdata.grade
                ))
            end
        end
    end

    if Config.Debug then
        print(('^2[Job Center]^0 Loaded %d jobs successfully'):format(
            #jobstab
        ))
    end
end)

lib.callback.register('job_center:getJobs', function(source)
    local time = os.time()
    if getcd[source] and (time - getcd[source]) < 2 then
        return nil
    end
    getcd[source] = time

    return {
        jobs = jobstab,
        style = Config.Style,
        locale = Config.Locale
    }
end)

lib.callback.register('job_center:applyJob', function(source, jobindex)
    local time = os.time()
    if applycd[source] and (time - applycd[source]) < 5 then
        return {
            success = false, 
            message = Config.Locale.waitBeforeApplying
        }
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return {
            success = false, 
            message = Config.Locale.error
        }
    end

    if not jobindex or type(jobindex) ~= 'number' or jobindex < 1 or jobindex > #jobstab or jobindex % 1 ~= 0 then
        if Config.Debug then
            print(('^1[Job Center]^0 Player %d sent invalid index: %s'):format(
                source,
                tostring(jobindex)
            ))
        end
        return {
            success = false, 
            message = Config.Locale.error
        }
    end

    local jobdata = jobstab[jobindex]
    if not jobdata then
        return {
            success = false, 
            message = Config.Locale.notFound
        }
    end

    local playerped = GetPlayerPed(source)
    if playerped == 0 then
        return {
            success = false, 
            message = Config.Locale.error
        }
    end

    local playercoords = GetEntityCoords(playerped)
    local isnearby = false

    for _, location in ipairs(Config.TargetLocations) do
        local coordscheck
        if location.type == "ped" or location.type == "model" then
            coordscheck = vector3(location.coords.x, location.coords.y, location.coords.z)
        elseif location.type == "sphere" then
            coordscheck = location.coords
        end

        if coordscheck and #(playercoords - coordscheck) <= Config.MaxDistance then
            isnearby = true
            break
        end
    end

    if not isnearby then
        if Config.Debug then
            print(('^1[Job Center]^0 Player %d is too far from the job center'):format(
                source
            ))
        end
        return {
            success = false, 
            message = Config.Locale.tooFar
        }
    end

    if xPlayer.job.name == jobdata.job then
        if xPlayer.job.grade >= jobdata.grade then
            if Config.Debug then
                print(('^3[Job Center]^0 Player %d already has a job as a %s with grade %d (offered grade: %d)'):format(
                    source,
                    jobdata.job,
                    xPlayer.job.grade,
                    jobdata.grade
                ))
            end
            return {
                success = false, 
                message = Config.Locale.alreadyHigherGrade
            }
        end
        
        if Config.Debug then
            print(('^3[Job Center]^0 Player %d already employed as a %s'):format(
                source,
                jobdata.job
            ))
        end
        return {
            success = false, 
            message = Config.Locale.alreadyEmployed
        }
    end

    applycd[source] = time
    xPlayer.setJob(jobdata.job, jobdata.grade)

    if Config.Debug then
        print(('^2[Job Center]^0 Player %d (%s) got hired as a %s (Grade %d)'):format(
            source,
            xPlayer.getName(),
            jobdata.job,
            jobdata.grade
        ))
    end

    return {
        success = true,
        message = Config.Locale.success .. " " .. jobdata.label
    }
end)

AddEventHandler('playerDropped', function()
    local source = source
    applycd[source] = nil
    getcd[source] = nil
end)