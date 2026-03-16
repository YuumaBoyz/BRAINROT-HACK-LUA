-- [[ BRAINROT HUB LOADER v1 ]] --
-- Ce script sert de pont entre tes modules distants et le jeu.

local function LoadModule(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("✅ Module chargé avec succès depuis : " .. url)
        return result
    else
        warn("❌ Erreur lors du chargement du module : " .. tostring(result))
        return nil
    end
end

-- [[ CONFIGURATION DES LIENS ]] --
-- REMPLACE LES LIENS CI-DESSOUS PAR TES LIENS RÉELS (GitHub Raw ou Pastebin)
local URL_FUNCTIONS = "https://pastebin.com/raw/TON_LIEN_FONCTIONS"
local URL_INTERFACE = "https://pastebin.com/raw/TON_LIEN_INTERFACE"

-- [[ CHARGEMENT DES COMPOSANTS ]] --
print("⚡ Initialisation du Brainrot Hub...")

local Lib = LoadModule(URL_FUNCTIONS)
local UI = LoadModule(URL_INTERFACE)

if Lib and UI then
    -- Initialisation de l'interface
    local GUI, FlyBtn, StealBtn = UI.CreateMain()
    
    -- Connexion de la logique du FLY
    FlyBtn.MouseButton1Click:Connect(function()
        Lib.Flying = not Lib.Flying
        FlyBtn.Text = Lib.Flying and "FLY : ON" or "FLY : OFF"
        FlyBtn.BackgroundColor3 = Lib.Flying and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        Lib.ToggleFly(Lib.Flying)
    end)
    
    -- Connexion de la logique d'AUTO-STEAL
    StealBtn.MouseButton1Click:Connect(function()
        Lib.AutoSteal = not Lib.AutoSteal
        StealBtn.Text = Lib.AutoSteal and "AUTO-STEAL : ON" or "AUTO-STEAL : OFF"
        StealBtn.BackgroundColor3 = Lib.AutoSteal and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(100, 50, 150)
        
        task.spawn(function()
            while Lib.AutoSteal do
                local Target = Lib.GetClosestBrainrot()
                if Target and game.Players.LocalPlayer.Character then
                    local Root = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if Root then
                        Root.CFrame = Target.CFrame * CFrame.new(0, 2, 0)
                    end
                    task.wait(0.15)
                end
                task.wait(0.05)
            end
        end)
    end)

    print("🔥 Brainrot Hub est prêt ! Amuse-toi bien.")
else
    print("⛔ Échec critique du chargement. Vérifie tes liens URL.")
end