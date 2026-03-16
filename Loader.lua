-- [[ 🌐 UNIVERSAL HUB v6.9 - LOADER FINAL ]] --
-- Optimisé pour éviter les crashs CoreGui et les erreurs de chargement

-- 1. Sécurité : On attend que le moteur du jeu soit prêt
if not game:IsLoaded() then
    game.Loaded:Wait()
end

print("🚀 ***Initialisation forcée du système v6.9...***")

-- Fonction de téléchargement avec vérification de contenu
local function GetCode(url, name)
    local s, res = pcall(function() return game:HttpGet(url) end)
    if s and res and #res > 20 then -- On vérifie que le fichier n'est pas quasi vide
        return res
    end
    warn("⚠️ ***ERREUR SOURCE : Impossible de lire " .. name .. " (Vérifie l'URL Raw)***")
    return nil
end

local baseUrl = "https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/"

-- 2. Téléchargement des modules
local libCode = GetCode(baseUrl .. "FunctionsModule.lua", "FunctionsModule")
local uiCode = GetCode(baseUrl .. "Interface.lua", "Interface")
local mainCode = GetCode(baseUrl .. "Main.lua", "Main")

-- Arrêt immédiat si les fichiers essentiels manquent
if not libCode or not uiCode then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "❌ ERREUR GITHUB",
        Content = "Fichiers introuvables. Vérifie ta connexion ou tes liens.",
        Duration = 10
    })
    return
end

-- 3. Chargement de la LOGIQUE (FunctionsModule)
local LibSuccess, Lib = pcall(function()
    return loadstring(libCode)()
end)

if not LibSuccess or type(Lib) ~= "table" then
    warn("❌ ***ERREUR LOGIQUE : FunctionsModule.lua est invalide !***")
    return
end
print("✅ ***Logic Module Loaded***")

-- 4. Chargement de l'INTERFACE (Interface.lua)
local UISuccess, UI = pcall(function()
    return loadstring(uiCode)()
end)

if not UISuccess or type(UI) ~= "table" or not UI.Init then
    warn("❌ ***ERREUR UI : Interface.lua est invalide !***")
    return
end
print("✅ ***UI Module Loaded***")

-- 5. Lancement de l'Interface et de la Persistance
-- On utilise task.defer pour éviter d'interférer avec le chargement de Roblox
task.defer(function()
    print("🎨 ***Tentative d'affichage de l'interface...***")
    
    local success, err = pcall(function()
        UI.Init(Lib) -- Initialise l'interface avec la librairie
    end)
    
    if success then
        print("🔥 ***HUB CHARGÉ AVEC SUCCÈS !***")
        
        -- Lancement de la PERSISTANCE (Main.lua) après l'UI
        if mainCode then
            local MainSuccess, Main = pcall(function()
                return loadstring(mainCode)()
            end)
            
            if MainSuccess and type(Main) == "table" and Main.Start then
                pcall(function() Main.Start(Lib) end)
                print("🛡️ ***Système de Persistance (Main) activé***")
            end
        end
    else
        warn("❌ ***CRASH INTERFACE :*** " .. tostring(err))
    end
end)