local Functions = {}

-- [[ ⚙️ CONFIGURATION & VARIABLES ]] --
Functions.FlySpeed = 50
Functions.WalkSpeed = 16
Functions.JumpPower = 50
Functions.Flying = false
Functions.Noclip = false
Functions.InfJump = false
Functions.SavedPosition = nil
Functions.LookAtEnabled = false

local LP = game:GetService("Players").LocalPlayer
local NoclipConnection = nil

-- [[ 🏃 MOUVEMENT ]] --
function Functions.SetSpeed(value)
    Functions.WalkSpeed = value
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = value
    end
end

function Functions.SetJump(value)
    Functions.JumpPower = value
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        local Hum = LP.Character.Humanoid
        Hum.JumpPower = value
        Hum.UseJumpPower = true 
    end
end

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
    if Functions.Noclip then
        if not NoclipConnection then
            NoclipConnection = game:GetService("RunService").Stepped:Connect(function()
                if Functions.Noclip and LP.Character then
                    for _, part in pairs(LP.Character:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                else
                    if NoclipConnection then
                        NoclipConnection:Disconnect()
                        NoclipConnection = nil
                    end
                end
            end)
        end
    end
end

-- [[ 📍 TÉLÉPORTATION (WAYPOINTS) ]] --
function Functions.SetTPPoint()
    local Char = LP.Character
    if Char and Char:FindFirstChild("HumanoidRootPart") then
        Functions.SavedPosition = Char.HumanoidRootPart.CFrame
        print("📍 Position enregistrée !")
        -- Notification visuelle
        game:GetService("ReplicatedStorage").Rayfield.RayfieldNotify:Fire({
            Title = "Point de TP",
            Content = "Position actuelle sauvegardée !",
            Duration = 2,
            Image = 4483362458
        })
    end
end

function Functions.GoToTPPoint()
    local Char = LP.Character
    if Char and Char:FindFirstChild("HumanoidRootPart") then
        if Functions.SavedPosition then
            Char.HumanoidRootPart.CFrame = Functions.SavedPosition
            print("🚀 Téléportation effectuée !")
        else
            warn("❌ Aucun point enregistré !")
        end
    end
end

-- [[ 🎭 SOCIAL & VISUEL ]] --
function Functions.ToggleLookAt(state)
    Functions.LookAtEnabled = state
    task.spawn(function()
        while Functions.LookAtEnabled do
            local closest = nil
            local dist = math.huge
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d closest = p end
                end
            end
            if closest then
                LP.Character.HumanoidRootPart.CFrame = CFrame.lookAt(LP.Character.HumanoidRootPart.Position, Vector3.new(closest.Character.HumanoidRootPart.Position.X, LP.Character.HumanoidRootPart.Position.Y, closest.Character.HumanoidRootPart.Position.Z))
            end
            task.wait()
        end
    end)
end

function Functions.ChatSpy()
    print("💬 ChatSpy activé (Console F9)")
    local ChatEvents = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents", 5)
    if ChatEvents then
        ChatEvents.OnMessageDoneFiltering.OnClientEvent:Connect(function(messageData)
            print("[" .. tostring(messageData.FromSpeaker) .. "]: " .. tostring(messageData.Message))
        end)
    end
end

-- [[ 🔓 UNLOCKS & TAILLE ]] --
function Functions.BypassTouch()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") then
            local p = v.Parent.Name:lower()
            if p:find("vip") or p:find("kill") or p:find("dead") or p:find("death") then 
                v:Destroy() 
            end
        end
    end
    print("🛡️ Zones dangereuses/VIP bypassées !")
end

function Functions.GetRemoteTools()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:find("Give") or v.Name:find("Tool") or v.Name:find("Item")) then 
            v:FireServer() 
        end
    end
    print("🎁 Tentative de Give envoyée !")
end

function Functions.ChangeSize(modifier)
    local Hum = LP.Character and LP.Character:FindFirstChild("Humanoid")
    if Hum then
        local Scales = {"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}
        for _, n in pairs(Scales) do
            local v = Hum:FindFirstChild(n) or Instance.new("NumberValue", Hum)
            v.Name = n
            v.Value = modifier
        end
    end
end

-- [[ 🛡️ SYSTÈME & EVENTS ]] --
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Functions.InfJump and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

function Functions.EnableAntiAFK()
    local VU = game:GetService("VirtualUser")
    LP.Idled:Connect(function() 
        VU:CaptureController() 
        VU:ClickButton2(Vector2.new()) 
    end)
end

return Functions