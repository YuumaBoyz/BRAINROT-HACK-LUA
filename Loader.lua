-- [[ 🌐 UNIVERSAL HUB v6.8 - HYBRID LOADER ]] --
print("🚀 ***Initialisation forcée...*** 🚀")

-- Fonction pour récupérer le code (Local ou Web)
local function GetModule(fileName, url)
    -- 1. Tentative de lecture locale (Prioritaire)
    local success, content = pcall(function() return readfile(fileName) end)
    
    if success and content then
        print("📂 ***Chargement local :*** " .. fileName)
    else
        -- 2. Secours sur GitHub si le fichier local manque
        print("🌐 ***Téléchargement depuis GitHub :*** " .. fileName)
        success, content = pcall(function() return game:HttpGet(url) end)
    end

    if success and content then
        local func, err = loadstring(content)
        if func then
            return func()
        else
            warn("❌ ***Erreur de syntaxe dans " .. fileName .. " :*** " .. tostring(err))
        end
    else
        warn("⚠️ ***Impossible de charger " .. fileName .. " (Vérifie ta connexion ou tes fichiers).***")
    end
    return nil
end

local function SafeLoad()
    local baseUrl = "https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/"

    -- 🛡️ Chargement sécurisé des modules
    local Lib = GetModule("functionsmodule.lua", baseUrl .. "FunctionsModule.lua")
    print("✅ ***Logic OK***")

    local UI = GetModule("interface.lua", baseUrl .. "Interface.lua")
    print("✅ ***UI OK***")

    local Main = GetModule("main.lua", baseUrl .. "Main.lua")

    -- 🚀 Lancement de l'interface
    if Lib and UI then
        local Success, Error = pcall(function()
            UI.Init(Lib)
        end)
        
        if Success then
            print("✅ ***Hub chargé avec succès !*** 🥳")
        else
            warn("❌ ***Erreur d'exécution de l'UI :*** " .. tostring(Error))
        end
    else
        warn("⚠️ ***Chargement avorté : Lib ou UI est Nil.***")
    end

    -- ⚙️ Lancement du Main (Optionnel/Silencieux)
    if Main and Lib then
        pcall(function()
            Main.Start(Lib)
            print("✅ ***Main OK***")
        end)
    end
end

SafeLoad()
print("🔥 ***HUB TOTALEMENT OPÉRATIONNEL !*** 🔥")