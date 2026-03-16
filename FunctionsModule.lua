local Functions = {}

-- [[ 📊 VARIABLES D'ÉTAT ]] --
Functions.FlySpeed = 50
Functions.WalkSpeed = 16
Functions.JumpPower = 50
Functions.Flying = false
Functions.Noclip = false
Functions.InfJump = false

local LP = game:GetService("Players").LocalPlayer

-- [[ 🏃 MOUVEMENT DE BASE ]] --

-- Change la vitesse de marche
function Functions.SetSpeed(value)
    Functions.WalkSpeed = value
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = value
    end
end

-- Change la puissance de saut
function Functions.SetJump(value)
    Functions.JumpPower = value
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.JumpPower = value
        LP.Character.Humanoid.UseJumpPower = true -- Force l'utilisation du JumpPower
    end
end

-- [[ 🚀 TRICHE AVANCÉE ]] --

-- Vol (Fly) Universel
function Functions.ToggleFly(state)
    Functions.Flying = state
    local Char = LP.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root = Char.HumanoidRootPart

    if Functions.Flying then
        local BV = Instance.new("BodyVelocity", Root)
        BV.Name = "UniversalFly"
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BV.Velocity = Vector3.new(0,0,0)

        task.spawn(function()
            while Functions.Flying do
                local Cam = workspace.CurrentCamera.CFrame
                local dir = Vector3.new(0,0,0)
                local UIS = game:GetService("UserInputService")
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Cam.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Cam.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Cam.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Cam.RightVector end
                BV.Velocity = dir * Functions.FlySpeed
                task.wait()
            end
            BV:Destroy()
        end)
    end
end

-- NOCLIP (Traverser les murs)
function Functions.ToggleNoclip(state)
    Functions.Noclip = state
    -- Utilise le service de rendu pour désactiver les collisions à chaque frame
    game:GetService("RunService").Stepped:Connect(function()
        if Functions.Noclip and LP.Character then
            for _, part in pairs(LP.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- INFINITE JUMP (Sauter dans les airs)
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Functions.InfJump and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

- [[ 🎭 MANIPULATION D'APPARENCE ]] --

function Functions.ChangeSize(modifier)
    local Char = LP.Character
    if Char and Char:FindFirstChild("Humanoid") then
        local Hum = Char.Humanoid
        
        -- Liste des objets de scale pour les avatars R15
        local Scales = {
            "BodyHeightScale",
            "BodyWidthScale",
            "BodyDepthScale",
            "HeadScale"
        }
        
        for _, scaleName in pairs(Scales) do
            local scaleValue = Hum:FindFirstChild(scaleName)
            if scaleValue then
                scaleValue.Value = modifier
            end
        end
        
        -- Note : Pour les jeux R6, la taille est plus difficile à changer 
        -- localement sans mourir, mais cela fonctionne sur 90% des jeux récents.
    end
end

-- [[ 🛡️ SYSTÈMES SYSTÈME ]] --

-- Anti-AFK (Pour ne pas être déconnecté après 20 min)
function Functions.EnableAntiAFK()
    local VU = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.new())
    end)
end

return Functions