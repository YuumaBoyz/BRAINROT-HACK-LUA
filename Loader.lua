-- [[ BRAINROT HUB : SUPREME LOADER ]] --

local function LoadModule(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success and result then
        print("✅ Chargé : " .. url)
        return result
    else
        warn("❌ Erreur sur : " .. url .. " -> " .. tostring(result))
        return nil
    end
end

-- [[ CONFIGURATION DES LIENS GITHUB ]] --
local BASE_URL = "https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/"
local URL_FUNCTIONS = BASE_URL .. "FunctionsModule.lua"
local URL_INTERFACE = BASE_URL .. "Interface.lua"
local URL_MAIN      = BASE_URL .. "Main.lua"

-- [[ CHARGEMENT SEQUENTIEL ]] --
print("⚡ Initialisation du Brainrot Hub...")

local Lib  = LoadModule(URL_FUNCTIONS)
local UI   = LoadModule(URL_INTERFACE)
local Main = LoadModule(URL_MAIN)

if Lib and UI and Main then
    -- 1. On lance les protections de base
    Lib.EnableAntiAFK()
    
    -- 2. On initialise l'interface
    UI.Init(Lib) 
    
    -- 3. On lance les boucles infinies (Auto-Steal, Kill Aura, etc.)
    Main.Start(Lib)
    
    print("🔥 BRAINROT HUB : TOUS LES SYSTÈMES SONT OPÉRATIONNELS !")
else
    warn("⛔ Échec critique : Un ou plusieurs fichiers sont manquants sur GitHub.")
end