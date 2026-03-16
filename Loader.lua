-- [[ 🌐 UNIVERSAL HUB v6.8 - LOADER FINAL ]] --
print("🚀 ***Initialisation forcée du système...***")

-- Fonction de téléchargement ultra-rapide
local function GetCode(url)
    local s, res = pcall(function() return game:HttpGet(url) end)
    if s and res and #res > 0 then
        return res
    end
    return nil
end

local baseUrl = "https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/"

-- 1. Téléchargement des modules en parallèle
local libCode = GetCode(baseUrl .. "FunctionsModule.lua")
local uiCode = GetCode(baseUrl .. "Interface.lua")
local mainCode = GetCode(baseUrl .. "Main.lua")

-- Vérification immédiate de la source GitHub
if not libCode or not uiCode then
    warn("❌ ***ERREUR RÉSEAU : Impossible de récupérer les fichiers sur GitHub !***")
    return
end

-- 2. Chargement de la LOGIQUE (FunctionsModule)
local LibSuccess, Lib = pcall(function()
    return loadstring(libCode)()
end)

if not LibSuccess or type(Lib) ~= "table" then
    warn("❌ ***ERREUR LOGIQUE : FunctionsModule.lua est corrompu ou vide !***")
    return
end
print("✅ ***Logic Module Loaded***")

-- 3. Chargement de l'INTERFACE (Interface.lua)
local UISuccess, UI = pcall(function()
    return loadstring(uiCode)()
end)

if not UISuccess or type(UI) ~= "table" or not UI.Init then
    warn("❌ ***ERREUR UI : Interface.lua est invalide (Vérifie le 'return UI') !***")
    return
end
print("✅ ***UI Module Loaded***")

-- 4. Lancement sécurisé de l'Interface
-- On utilise task.defer pour s'assurer que l'environnement est stable avant d'ouvrir Rayfield
task.defer(function()
    print("🎨 ***Tentative d'affichage de l'interface...***")
    local success, err = pcall(function()
        UI.Init(Lib)
    end)
    
    if success then
        print("🔥 ***HUB CHARGÉ AVEC SUCCÈS !***")
    else
        warn("❌ ***CRASH INTERFACE :*** " .. tostring(err))
    end
end)

-- 5. Lancement de la PERSISTANCE (Main.lua)
if mainCode then
    task.spawn(function()
        local MainSuccess, Main = pcall(function()
            return loadstring(mainCode)()
        end)
        
        if MainSuccess and type(Main) == "table" and Main.Start then
            pcall(function() Main.Start(Lib) end)
            print("🛡️ ***Système de Persistance (Main) activé***")
        else
            warn("⚠️ ***Main.lua ignoré (non trouvé ou invalide)***")
        end
    end)
end