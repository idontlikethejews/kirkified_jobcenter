Config = {}

Config.Debug = false -- enable debug prints in server and player console

Config.Language = 'en' -- en, pl

-- UI Style: 'minimal' | 'cards' | 'split'
Config.Style = 'minimal'

Config.UseTarget = true -- ox_target only

Config.TargetLocations = {
    {
        type = "ped",
        model = "a_m_y_business_01",
        coords = vector4(-109.4184, -610.0533, 36.2668, 254.1418)
    },
    -- {
    --     type = "sphere",
    --     coords = vector3(-265.0, -963.0, 31.0),
    --     radius = 1.5
    -- },
    -- {
    --     type = "model",
    --     model = "propname",
    --     coords = vector3(-254.0, -692.0, 33.0)
    -- }
}

Config.Jobs = {
    {
        job = "police",
        grade = 0,
        label = "Los Santos Police Department",
        description = "Protect and serve the citizens.",
        icon = "mdi:police-badge",
        image = "https://2img.net/i.imgur.com/BQoTEoz.png",
        requirements = {"Driver's License"}
    },
    {
        job = "ambulance",
        grade = 0,
        label = "Emergency Medical Services",
        description = "Save lives and provide critical medical assistance.",
        icon = "mdi:ambulance",
        image = "https://1000logos.net/wp-content/uploads/2020/09/Ems-Logo.png",
        requirements = {"Medical Training", "First Aid Certification"}
    }
}

-- Distance Check
Config.MaxDistance = 3.0

local function LoadLocale()
    local locale = LoadResourceFile(GetCurrentResourceName(), ('locales/%s.json'):format(
        Config.Language
    ))
    
    if not locale then
        print(("^1[Job Center]^0 Locale file 'locales/%s.json' not found. Using English as a fallback lang."):format(
            Config.Language
        ))
        locale = LoadResourceFile(GetCurrentResourceName(), 'locales/en.json')
    end
    
    if locale then
        Config.Locale = json.decode(locale)
        if Config.Debug then
            print(("^2[Job Center]^0 Loaded locale: %s"):format(
                Config.Language
            ))
        end
    else
        print(("^1[Job Center]^0 Failed to load any locale file. Please ensure 'locales/%s.json' exists."):format(
                Config.Language
            ))
        Config.Locale = {}
    end
end

LoadLocale()