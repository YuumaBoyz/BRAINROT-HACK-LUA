-- [[ BRAINROT HUB : SUPREME LOADER ]] --
-- Fusion : Sécurité Debug + Structure Modulaire
-- Auteur : Expert Scripting

-- 1. Attendre le chargement complet du jeu
if not game:IsLoaded() then game.Loaded:Wait() end

-- [[ 🛡️ FONCTION DE CHARGEMENT SÉCURISÉE ]] --
local function SafeLoad(name, url)
    local success, content = pcall(function() return game:HttpGet(url) end)
    if not success then 
        warn("❌ Impossible de lire l'URL pour : " .. name) 
        return nil 
    end
    
    local func, err = loadstring(content)
    if not func then
        warn("⚠️ ERREUR DE SYNTAXE DANS [" .. name .. "] : \n" .. tostring(err))
        return nil
    end
    
    local ok, result = pcall(func)
    if ok and result ~= nil then
        print("✅ [" .. name .. "] chargé avec succès.")
        return result
    else
        warn("❌ Erreur fatale à l'exécution de [" .. name .. "] (Vérifie le 'return' à la fin du fichier)")
        return nil
    end
end

-- [[ 🔗 CONFIGURATION DES LIENS ]] --
local BASE_URL = "https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/"
local URL_FUNCTIONS = BASE_URL .. "FunctionsModule.lua"
local URL_INTERFACE = BASE_URL .. "Interface.lua"
local URL_MAIN      = BASE_URL .. "Main.lua"

-- [[ ⚡ CHARGEMENT SÉQUENTIEL ]] --
print("⚡ Initialisation du Brainrot Hub...")

local Lib  = SafeLoad("Logic", URL_FUNCTIONS)
local UI   = SafeLoad("UI", URL_INTERFACE)
local Main = SafeLoad("Main", URL_MAIN)

-- [[ 🚀 EXÉCUTION ]] --
if Lib and UI and Main then
    -- 1. On lance les protections de base
    Lib.EnableAntiAFK()
    
    -- 2. On initialise l'interface (Passage de Lib pour les boutons)
    UI.Init(Lib) 
    
    -- 3. On lance les boucles infinies (Auto-Steal, Kill Aura, etc.)
    Main.Start(Lib)
    
    print("🔥 BRAINROT HUB : TOUS LES SYSTÈMES SONT OPÉRATIONNELS !")
else
    warn("⛔ ÉCHEC CRITIQUE : Un ou plusieurs fichiers sont invalides sur GitHub.")
    warn("👉 Vérifie que chaque fichier finit bien par 'return Functions', 'return UI' ou 'return Main'.")
end