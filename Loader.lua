-- [[ 🌐 UNIVERSAL HUB v6.8 - LOADER FINAL ]] --
print("🚀 ***Initialisation forcée...***")

local function GetCode(url)
    local s, res = pcall(function() return game:HttpGet(url) end)
    return s and res or nil
end

local baseUrl = "https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/"

-- 1. Téléchargement des modules
local libCode = GetCode(baseUrl .. "FunctionsModule.lua")
local uiCode = GetCode(baseUrl .. "Interface.lua")
local mainCode = GetCode(baseUrl .. "Main.lua")

if not libCode or not uiCode then
    warn("❌ ***Erreur critique : Impossible de télécharger les fichiers depuis GitHub !***")
    return
end

-- 2. Chargement sécurisé de la LIB
local Lib = loadstring(libCode)()
if type(Lib) ~= "table" then
    warn("❌ ***FunctionsModule n'a pas renvoyé une table valide !***")
    return
end
print("✅ ***Logic OK***")

-- 3. Chargement sécurisé de l'UI
local UI = loadstring(uiCode)()
if type(UI) ~= "table" or not UI.Init then
    warn("❌ ***Interface n'a pas renvoyé une table avec UI.Init !***")
    return
end
print("✅ ***UI OK***")

-- 4. Lancement de l'interface
task.spawn(function()
    local success, err = pcall(function()
        UI.Init(Lib)
    end)
    if success then
        print("🔥 ***HUB CHARGÉ AVEC SUCCÈS !***")
    else
        warn("❌ ***Erreur au lancement de l'UI :*** " .. tostring(err))
    end
end)

-- 5. Lancement du Main (Persistance)
if mainCode then
    task.spawn(function()
        local Main = loadstring(mainCode)()
        if Main and Main.Start then
            pcall(function() Main.Start(Lib) end)
            print("🛡️ ***Système Main activé***")
        end
    end)
end