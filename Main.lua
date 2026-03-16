-- [[ BRAINROT HUB - MAIN EXECUTION ]] --
-- Fusion totale : Sécurité, Modularité, Combat & Auto-Bypass
-- Auteur : Expert Scripting

-- 1. Attendre le chargement complet du jeu
if not game:IsLoaded() then game.Loaded:Wait() end

-- [[ CONFIGURATION DES SOURCES ]] --
local URL_FUNCTIONS = "https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/FunctionsModule.lua"
local URL_INTERFACE = "https://raw.githubusercontent.com/YuumaBoyz/BRAINROT-HACK-LUA/main/Interface.lua"

-- [[ SERVICES & RÉFÉRENCES ]] --
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ CHARGEUR DE COMPOSANTS ]] --
local function SafeLoad(name, url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success and result then
        print("✅ [" .. name .. "] : Chargé avec succès.")
        return result
    else
        warn("❌ [" .. name .. "] : Erreur de téléchargement -> " .. tostring(result))
        return nil
    end
end

print("⚡ Initialisation du Brainrot Hub...")

local Lib = SafeLoad("Logic", URL_FUNCTIONS)
local UI = SafeLoad("UI", URL_INTERFACE)

if not Lib or not UI then
    return warn("⛔ ÉCHEC CRITIQUE : Impossible de charger les composants distants.")
end

-- [[ 🛡️ ACTIVATION DES SYSTÈMES DE BASE ]] --
Lib.EnableAntiAFK() -- Protection contre la déconnexion immédiate
Lib.ResetPhysics()  -- Nettoyage initial de la physique

-- [[ 🖥️ INITIALISATION DE L'INTERFACE ]] --
-- On récupère les éléments de l'UI pour garder la compatibilité si besoin
local Window, FlyToggle, StealToggle, KillToggle = UI.Init(Lib) 

-- [[ 🌪️ BOUCLE ASYNCHRONE : FLING AURA (COMBAT) ]] --
task.spawn(function()
    while task.wait(0.1) do
        if Lib.KillAura then
            local Target = Lib.GetClosestPlayer()
            if Target then
                Lib.Fling(Target)   -- Exécution de la propulsion
                Lib.ResetPhysics()  -- 🟢 BYPASS : Empêche le kick après le choc
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
                Lib.ResetPhysics() -- 🟢 BYPASS : Stabilise le perso après le TP
                task.wait(0.15)
            end
        end
    end
end)

-- [[ 🔒 BOUCLE ASYNCHRONE : BASE SECURITY ]] --
task.spawn(function()
    while task.wait(1.5) do
        if Lib.PermanentBarrier then
            Lib.LockMyBarrier() -- Force la fermeture de ta barrière
        end
    end
end)

print("🔥 BRAINROT HUB v3 : TOUT EST OPÉRATIONNEL !")
print("💡 Rappel : Utilise R-CTRL pour masquer l'interface.")