local Main = {}

function Main.Start(Lib)
    local LP = game:GetService("Players").LocalPlayer
    
    -- [[ 1. RÉACTIVATION SUR RESPOND ]] --
    -- Se déclenche dès que ton personnage réapparaît
    LP.CharacterAdded:Connect(function(Character)
        local Humanoid = Character:WaitForChild("Humanoid", 5)
        if Humanoid then
            task.wait(1) -- Petit délai pour bypass les resets serveurs
            Lib.SetSpeed(Lib.WalkSpeed)
            Lib.SetJump(Lib.JumpPower)
            print("🔄 Personnage réinitialisé : Pouvoirs ré-appliqués !")
        end
    end)

    -- [[ 2. BOUCLE DE SÉCURITÉ (ANTI-RESET) ]] --
    -- Vérifie toutes les 2 secondes que le jeu n'a pas remis ta vitesse par défaut
    task.spawn(function()
        while task.wait(2) do
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                local hum = LP.Character.Humanoid
                
                -- Si la vitesse actuelle est différente de celle choisie dans le menu
                if hum.WalkSpeed ~= Lib.WalkSpeed then
                    hum.WalkSpeed = Lib.WalkSpeed
                end
                
                -- Si le saut actuel est différent de celui choisi
                if hum.JumpPower ~= Lib.JumpPower then
                    hum.JumpPower = Lib.JumpPower
                end
            end
        end
    end)
    
    print("🛡️ Système de persistance activé avec succès !")
end

return Main