-- [[ 🌐 UNIVERSAL HUB : LOADER GÉNÉRAL 🌐 ]] --
-- Garde les mêmes liens GitHub mais avec une logique universelle.

-- 1. Attente du chargement
if not game:IsLoaded() then game.Loaded:Wait() end

-- [[ 🛡️ LE CHARGEUR BLINDÉ (DEBUG) ]] --
local function SafeLoad(name, url)
    print("⏳ Chargement de : " .. name .. "...")
    local success, content = pcall(function() return game:HttpGet(url) end)
    
    if success and content then
        local func, err = loadstring(content)
        if func then
            local ok, result = pcall(func)
            if ok and result ~= nil then
                print("✅ [" .. name .. "] chargé !")
                return result
            else
                warn("❌ Erreur d'exécution [" .. name .. "] : " .. tostring(result))
            end
        else
            warn("❌ Erreur de syntaxe [" .. name .. "] : " .. tostring(err))
        end
    else
        warn("❌ Impossible d'accéder au lien Raw pour : " .. name)
    end
    return nil
end

-- [[ 🔗 TES LIENS GITHUB (INCHANGÉS) ]] --
local URL_FUNCTIONS = "https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/FunctionsModule.lua"
local URL_INTERFACE = "https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/Interface.lua"
local URL_MAIN      = "https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/Main.lua"

-- [[ ⚡ LANCEMENT SÉQUENTIEL ]] --
print("⚡ Lancement de l'Universal Hub...")

local Lib  = SafeLoad("Logic", URL_FUNCTIONS)
local UI   = SafeLoad("UI", URL_INTERFACE)
local Main = SafeLoad("Main", URL_MAIN)

if Lib and UI and Main then
    -- Activation des fonctions de base (Universel)
    Lib.EnableAntiAFK()
    
    -- Initialisation de l'Interface Rayfield
    UI.Init(Lib) 
    
    -- Lancement des boucles de maintien (Speed, Jump, Fly)
    Main.Start(Lib)
    
    print("🔥 TOUT EST OPÉRATIONNEL ! AMUSE-TOI BIEN !")
else
    warn("⛔ ÉCHEC CRITIQUE : Vérifie tes fichiers sur GitHub.")
end