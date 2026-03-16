-- [[ 🌐 UNIVERSAL LOADER & PERSISTENCE v6.9 ]] --

-- 1. Attente du chargement complet du jeu pour éviter les erreurs "SettingsHub"
if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Main = {}
local LP = game:GetService("Players").LocalPlayer

-- [[ 🛡️ FONCTION DE CHARGEMENT SÉCURISÉ ]] --
local function SafeLoad(url, name)
    local success, result = pcall(function()
        -- On récupère le code brut depuis GitHub
        local code = game:HttpGet(url)
        if code == "" or not code then return nil end
        return loadstring(code)()
    end)
    
    if success and result then
        print("✅ " .. name .. " chargé avec succès.")
        return result
    else
        -- Message d'erreur clair si le fichier est corrompu ou l'URL mauvaise
        warn("❌ ***ERREUR LOGIQUE : " .. name .. ".lua est corrompu ou vide !***")
        return nil
    end
end

-- [[ 🔄 LOGIQUE DE PERSISTENCE (Main.Start) ]] --
function Main.Start(Lib)
    if not Lib then 
        warn("❌ ***Main.lua : Impossible de démarrer, la Librairie est manquante !***")
        return 
    end

    -- Réactivation après Respawn
    LP.CharacterAdded:Connect(function(Character)
        local hum = Character:WaitForChild("Humanoid", 10)
        local root = Character:WaitForChild("HumanoidRootPart", 10)
        
        if hum and root then
            task.wait(1.5) -- Délai crucial pour bypass les scripts de reset du jeu
            
            pcall(function()
                -- Ré-application des pouvoirs
                if Lib.SetSpeed then Lib.SetSpeed(Lib.WalkSpeed) end
                if Lib.SetJump then Lib.SetJump(Lib.JumpPower) end
                
                if Lib.Flying and Lib.ToggleFly then 
                    Lib.ToggleFly(true) 
                end
                
                if Lib.Noclip and Lib.ToggleNoclip then
                    Lib.ToggleNoclip(true)
                end
            end)
            print("🔄 ***Personnage détecté : Pouvoirs ré-appliqués !***")
        end
    end)

    -- Boucle Anti-Cheat Bypass (Maintien des valeurs)
    task.spawn(function()
        while true do
            task.wait(2)
            pcall(function()
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if hum and hum.Health > 0 then
                    -- Force les valeurs si le jeu essaie de les remettre à 16 ou 50
                    if Lib.WalkSpeed and hum.WalkSpeed ~= Lib.WalkSpeed then
                        hum.WalkSpeed = Lib.WalkSpeed
                    end
                    if Lib.JumpPower and hum.JumpPower ~= Lib.JumpPower then
                        hum.JumpPower = Lib.JumpPower
                    end
                end
            end)
        end
    end)
    
    print("🛡️ ***Système de persistance (Main) activé***")
end

-- [[ 🚀 EXÉCUTION DU SYSTÈME ]] --

-- REMPLACE CES LIENS PAR TES PROPRES LIENS RAW GITHUB
local FunctionsURL = "https://raw.githubusercontent.com/TON_PROFIL/TON_REPO/main/FunctionsModule.lua"
local InterfaceURL = "https://raw.githubusercontent.com/TON_PROFIL/TON_REPO/main/Interface.lua"

local Lib = SafeLoad(FunctionsURL, "FunctionsModule")
local UI = SafeLoad(InterfaceURL, "Interface")

if Lib and UI then
    -- Initialisation de l'Interface
    UI.Init(Lib)
    -- Démarrage de la persistance
    Main.Start(Lib)
    
    print("🔥 ***HUB CHARGÉ AVEC SUCCÈS !***")
else
    -- Notification d'erreur visuelle si le chargement échoue
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "⚠️ ERREUR CRITIQUE",
        Content = "FunctionsModule.lua ou Interface.lua est introuvable sur GitHub.",
        Duration = 10
    })
end

return Main