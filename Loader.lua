-- [[ BRAINROT HUB LOADER v3 ]] --
-- Fusion : Anti-AFK, Fling Aura, Auto-Steal & Reset Physics

local function LoadModule(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success and result then
        print("✅ Module chargé : " .. url)
        return result
    else
        warn("❌ Erreur de chargement : " .. tostring(result))
        return nil
    end
end

-- [[ CONFIGURATION DES LIENS ]] --
local URL_FUNCTIONS = "https://pastebin.com/raw/TON_LIEN_FONCTIONS"
local URL_INTERFACE = "https://pastebin.com/raw/TON_LIEN_INTERFACE"

-- [[ CHARGEMENT DES COMPOSANTS ]] --
print("⚡ Initialisation du Brainrot Hub...")

local Lib = LoadModule(URL_FUNCTIONS)
local UI = LoadModule(URL_INTERFACE)

if Lib and UI then
    -- [[ 🛡️ LANCEMENT DES PROTECTIONS ]] --
    Lib.EnableAntiAFK() -- Active l'Anti-AFK dès le démarrage

    -- Initialisation de l'interface (Adapter selon ta version Fluent ou Classique)
    local Window, FlyBtn, StealBtn, KillBtn = UI.Init(Lib) 
    
    -- [[ ✈️ LOGIQUE : FLY ]] --
    if FlyBtn then
        FlyBtn.MouseButton1Click:Connect(function()
            Lib.Flying = not Lib.Flying
            FlyBtn.Text = Lib.Flying and "FLY : ON" or "FLY : OFF"
            FlyBtn.BackgroundColor3 = Lib.Flying and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
            Lib.ToggleFly(Lib.Flying)
        end)
    end

    -- [[ ⚔️ LOGIQUE : FLING AURA (KILL) ]] --
    -- Bouton pour activer/désactiver le massacre
    if KillBtn then
        KillBtn.MouseButton1Click:Connect(function()
            Lib.KillAura = not Lib.KillAura
            KillBtn.Text = Lib.KillAura and "FLING AURA : ON" or "FLING AURA : OFF"
            KillBtn.BackgroundColor3 = Lib.KillAura and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(150, 0, 0)
        end)
    end

    task.spawn(function()
        while task.wait(0.1) do
            if Lib.KillAura then
                local Target = Lib.GetClosestPlayer()
                if Target then
                    Lib.Fling(Target) -- Éjecte le joueur
                    Lib.ResetPhysics() -- 🟢 Sécurité : Nettoie la vélocité après le choc
                end
            end
        end
    end)

    -- [[ 💰 LOGIQUE : AUTO-STEAL ]] --
    if StealBtn then
        StealBtn.MouseButton1Click:Connect(function()
            Lib.AutoSteal = not Lib.AutoSteal
            StealBtn.Text = Lib.AutoSteal and "AUTO-STEAL : ON" or "AUTO-STEAL : OFF"
            StealBtn.BackgroundColor3 = Lib.AutoSteal and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 50, 150)
        end)
    end

    task.spawn(function()
        while task.wait(0.05) do
            if Lib.AutoSteal then
                local Target = Lib.GetClosestBrainrot()
                local Character = game.Players.LocalPlayer.Character
                if Target and Character and Character:FindFirstChild("HumanoidRootPart") then
                    Character.HumanoidRootPart.CFrame = Target.CFrame * CFrame.new(0, 2, 0)
                    Lib.ResetPhysics() -- 🟢 Sécurité : Nettoie la vélocité après le TP
                    task.wait(0.15)
                end
            end
        end
    end)

    print("🔥 Brainrot Hub v3 est prêt ! Protection Anti-Kick active.")
else
    print("⛔ Échec critique. Vérifie tes liens URL.")
end