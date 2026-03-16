-- [[ ⚡ LOADER SIMPLIFIÉ & ROBUSTE ⚡ ]] --
print("🚀 Initialisation forcée...")

local function GetCode(url)
    return game:HttpGet(url)
end

-- Téléchargement manuel
local libCode = GetCode("https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/FunctionsModule.lua")
local uiCode = GetCode("https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/Interface.lua")
local mainCode = GetCode("https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/Main.lua")

-- Exécution
local Lib = loadstring(libCode)()
print("✅ Logic OK")

local UI = loadstring(uiCode)()
print("✅ UI OK")

-- Lancement de l'interface
UI.Init(Lib)

-- Lancement du Main (sans blocage si erreur)
pcall(function()
    local Main = loadstring(mainCode)()
    Main.Start(Lib)
    print("✅ Main OK")
end)

print("🔥 HUB CHARGÉ !")