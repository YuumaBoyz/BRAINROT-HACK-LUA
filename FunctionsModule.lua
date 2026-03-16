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

function Functions.SetSpeed(value)
    Functions.WalkSpeed = value
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = value
    end
end

function Functions.SetJump(value)
    Functions.JumpPower = value
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.JumpPower = value
        LP.Character.Humanoid.UseJumpPower = true 
    end
end

-- [[ 🚀 TRICHE AVANCÉE ]] --

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
            if BV then BV:Destroy() end
        end)
    end
end

function Functions.ToggleNoclip(state)
    Functions.Noclip = state
    local RunService = game:GetService("RunService")
    
    local function noclipLoop()
        if Functions.Noclip and LP.Character then
            for _, part in pairs(LP.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
    RunService.Stepped:Connect(noclipLoop)
end

-- INFINITE JUMP
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Functions.InfJump and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- [[ 🎭 MANIPULATION D'APPARENCE ]] --

function Functions.ChangeSize(modifier)
    local Char = LP.Character
    if Char and Char:FindFirstChild("Humanoid") then
        local Hum = Char.Humanoid
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
    end
end

-- [[ 🛡️ SYSTÈMES ]] --

function Functions.EnableAntiAFK()
    local VU = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.new())
    end)
end

return Functions