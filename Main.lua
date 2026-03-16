-- [[ BRAINROT HUB - MAIN EXECUTION ]] --
-- Fusion totale : Sécurité accrue, Modularité & Auto-Bypass
-- Auteur : Expert Scripting

-- 1. Attendre le chargement complet du jeu
if not game:IsLoaded() then game.Loaded:Wait() end

-- [[ CONFIGURATION DES SOURCES ]] --
local URL_FUNCTIONS = "https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/FunctionsModule.lua"
local URL_INTERFACE = "https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/Interface.lua"

-- [[ SERVICES & RÉFÉRENCES ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ 🛡️ CHARGEUR DE COMPOSANTS SÉCURISÉ ]] --
local function SafeLoad(name, url)
    local success, content = pcall(function() return game:HttpGet(url) end)
    
    if success and content then
        local func, err = loadstring(content)
        if func then
            -- On exécute le script et on récupère ce qu'il renvoie
            local result = func() 
            
            -- Vérification cruciale : Le script a-t-il renvoyé sa table (Functions ou UI) ?
            if result ~= nil then
                print("✅ [" .. name .. "] : Chargé avec succès.")
                return result
            else
                -- Si result est nil, c'est qu'il manque le "return" à la fin du fichier sur GitHub
                warn("⚠️ [" .. name .. "] : Le fichier est vide ou n'a rien retourné. Vérifie le 'return' à la fin du script sur GitHub !")
                return nil
            end
        else
            warn("❌ [" .. name .. "] : Erreur de syntaxe dans le code distant -> " .. tostring(err))
        end
    else
        warn("❌ [" .. name .. "] : Impossible de récupérer l'URL (Vérifie ton lien Raw GitHub).")
    end
    return nil
end

print("⚡ Initialisation du Brainrot Hub...")

-- [[ CHARGEMENT DES MODULES ]] --
local Lib = SafeLoad("Logic", URL_FUNCTIONS)
local UI = SafeLoad("UI", URL_INTERFACE)

-- Arrêt immédiat si un composant manque pour éviter les erreurs "nil"
if not Lib or not UI then
    return warn("⛔ ÉCHEC CRITIQUE : Impossible de lancer le Hub sans tous les composants.")
end

-- [[ 🛠️ ACTIVATION DES SYSTÈMES DE BASE ]] --
Lib.EnableAntiAFK() -- Protection contre la déconnexion
Lib.ResetPhysics()  -- Nettoyage initial

-- [[ 🖥️ INITIALISATION DE L'INTERFACE ]] --
local Window, FlyToggle, StealToggle, KillToggle = UI.Init(Lib) 

-- [[ 🌪️ BOUCLE ASYNCHRONE : FLING AURA (COMBAT) ]] --
task.spawn(function()
    while task.wait(0.1) do
        if Lib.KillAura then
            local Target = Lib.GetClosestPlayer()
            if Target then
                Lib.Fling(Target)   -- Propulsion physique
                Lib.ResetPhysics()  -- 🟢 BYPASS : Nettoie la vélocité
            end
        end
    end
end)

-- [[ 💰 BOUCLE ASYNCHRONE : AUTO-STEAL (FARM) ]] --
task.spawn(function()
    while task.wait(0.05) do
        if Lib.AutoSteal then
            local Target = Lib.GetClosestBrainrot()
            local Character = LocalPlayer.Character
            if Target and Character and Character:FindFirstChild("HumanoidRootPart") then
                local HRP = Character.HumanoidRootPart
                -- Téléportation flash
                HRP.CFrame = Target.CFrame * CFrame.new(0, 2, 0)
                Lib.ResetPhysics() -- 🟢 BYPASS
                task.wait(0.15)
            end
        end
    end
end)

-- [[ 🔒 BOUCLE ASYNCHRONE : BASE SECURITY ]] --
task.spawn(function()
    while task.wait(1.5) do
        if Lib.PermanentBarrier then
            Lib.LockMyBarrier() -- Force le verrouillage de la barrière
        end
    end
end)

print("🔥 BRAINROT HUB v3.1 : TOUT EST OPÉRATIONNEL !")
print("💡 Rappel : Utilise R-CTRL pour masquer l'interface.")