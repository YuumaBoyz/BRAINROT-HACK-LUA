local Main = {}

function Main.Start(Lib)
    local LP = game:GetService("Players").LocalPlayer
    
    -- [[ 🛡️ SÉCURITÉ : Vérification de la Librairie ]] --
    if not Lib then 
        warn("❌ ***Main.lua : Impossible de démarrer, la Librairie est manquante !***")
        return 
    end

    -- [[ 🔄 1. RÉACTIVATION SUR RESPAWN ]] --
    LP.CharacterAdded:Connect(function(Character)
        -- On attend que le moteur physique soit prêt pour le nouveau perso
        local hum = Character:WaitForChild("Humanoid", 10)
        local root = Character:WaitForChild("HumanoidRootPart", 10)
        
        if hum and root then
            task.wait(1.5) -- Délai crucial pour bypass les scripts de reset du jeu
            
            pcall(function()
                -- Ré-application de la Vitesse
                if Lib.SetSpeed then Lib.SetSpeed(Lib.WalkSpeed) end
                
                -- Ré-application du Saut
                if Lib.SetJump then Lib.SetJump(Lib.JumpPower) end
                
                -- Ré-application du Fly (si activé avant la mort)
                if Lib.Flying and Lib.ToggleFly then 
                    Lib.ToggleFly(true) 
                end
                
                -- Ré-application du Noclip (si activé avant la mort)
                if Lib.Noclip and Lib.ToggleNoclip then
                    Lib.ToggleNoclip(true)
                end
            end)
            
            print("🔄 ***Personnage détecté : Pouvoirs ré-appliqués !***")
        end
    end)

    -- [[ ⛓️ 2. BOUCLE DE MAINTIEN (ANTI-CHEAT BYPASS) ]] --
    -- Cette boucle force les valeurs même si le jeu essaie de les remettre à 16 ou 50
    task.spawn(function()
        while true do
            task.wait(2) -- Vérification toutes les 2 secondes
            
            pcall(function()
                local char = LP.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if hum and hum.Health > 0 then
                    -- Maintien de la Vitesse
                    if Lib.WalkSpeed and hum.WalkSpeed ~= Lib.WalkSpeed then
                        hum.WalkSpeed = Lib.WalkSpeed
                    end
                    
                    -- Maintien du Saut
                    if Lib.JumpPower and hum.JumpPower ~= Lib.JumpPower then
                        hum.JumpPower = Lib.JumpPower
                    end
                end
            end)
        end
    end)
    
    print("🛡️ ***Système de persistance activé avec succès !***")
end

return Main