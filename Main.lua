-- [[ BRAINROT HUB - MAIN EXECUTION ]] --
-- Fusion totale : Sécurité, Modularité et Combat (Fling)
-- Auteur : Expert Scripting

-- 1. Attendre le chargement complet du jeu
repeat task.wait() until game:IsLoaded()

-- [[ CONFIGURATION DES SOURCES ]] --
-- ⚠️ Remplace par tes liens "Raw" (GitHub ou Pastebin)
local URL_FUNCTIONS = "https://pastebin.com/raw/TON_LIEN_FONCTIONS"
local URL_INTERFACE = "https://pastebin.com/raw/TON_LIEN_INTERFACE"

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
        warn("❌ [" .. name .. "] : Erreur -> " .. tostring(result))
        return nil
    end
end

print("⚡ Initialisation du Brainrot Hub...")

local Lib = SafeLoad("Logic", URL_FUNCTIONS)
local UI = SafeLoad("UI", URL_INTERFACE)

if not Lib or not UI then
    return warn("⛔ Échec critique : Impossible de charger les composants.")
end

-- [[ INITIALISATION DE L'INTERFACE ]] --
-- Si tu utilises Fluent, appelle UI.Init(Lib), sinon UI.CreateMain()
local Window, FlyBtn, StealBtn, KillBtn = UI.Init(Lib) 

-- [[ CONNEXION : LOGIQUE DE VOL (FLY) ]] --
if FlyBtn then
    FlyBtn.MouseButton1Click:Connect(function()
        Lib.Flying = not Lib.Flying
        FlyBtn.Text = Lib.Flying and "FLY : ON" or "FLY : OFF"
        FlyBtn.BackgroundColor3 = Lib.Flying and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        Lib.ToggleFly(Lib.Flying)
    end)
end

-- [[ CONNEXION : LOGIQUE DE COMBAT (FLING AURA) ]] --
if KillBtn then
    KillBtn.MouseButton1Click:Connect(function()
        Lib.KillAura = not Lib.KillAura
        KillBtn.Text = Lib.KillAura and "FLING AURA : ON" or "FLING AURA : OFF"
        KillBtn.BackgroundColor3 = Lib.KillAura and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(150, 0, 0)
    end)
end

-- [[ BOUCLE ASYNCHRONE : FLING AURA ]] --
task.spawn(function()
    while task.wait(0.1) do
        if Lib.KillAura then
            local Target = Lib.GetClosestPlayer()
            if Target then
                Lib.Fling(Target) -- Exécution de la propulsion physique
            end
        end
    end
end)

-- [[ BOUCLE ASYNCHRONE : AUTO-STEAL ]] --
task.spawn(function()
    while task.wait(0.05) do
        if Lib.AutoSteal then
            local Target = Lib.GetClosestBrainrot()
            local Character = LocalPlayer.Character
            if Target and Character and Character:FindFirstChild("HumanoidRootPart") then
                local HRP = Character.HumanoidRootPart
                -- Téléportation flash pour collecter
                HRP.CFrame = Target.CFrame * CFrame.new(0, 2, 0)
                task.wait(0.15)
            end
        end
    end
end)

print("🔥 TOUT EST OPÉRATIONNEL ! Amuse-toi bien sur Steal a Brainrot.")