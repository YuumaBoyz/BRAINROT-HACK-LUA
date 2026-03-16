local Functions = {}

Functions.Flying = false
Functions.AutoSteal = false
Functions.KillAura = false 
Functions.PermanentBarrier = false
Functions.FlySpeed = 50
Functions.KillRange = 25 
Functions.DetectionRadius = 500

function Functions.EnableAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    game:GetService("Players").LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

function Functions.ResetPhysics()
    local Character = game:GetService("Players").LocalPlayer.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        Character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
    end
end

function Functions.GetClosestBrainrot()
    local Character = game:GetService("Players").LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return nil end
    local ClosestItem, ShortestDistance = nil, Functions.DetectionRadius
    for _, item in pairs(workspace:GetDescendants()) do
        if item:IsA("BasePart") and (item.Name:find("Brainrot") or item:FindFirstChild("TouchInterest")) then
            local Distance = (Character.HumanoidRootPart.Position - item.Position).Magnitude
            if Distance < ShortestDistance then
                ShortestDistance = Distance
                ClosestItem = item
            end
        end
    end
    return ClosestItem
end

function Functions.GetClosestPlayer()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return nil end
    local ClosestEnemy, ShortestDistance = nil, Functions.KillRange
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local EnemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if EnemyRoot and player.Character.Humanoid.Health > 0 then
                local Distance = (Character.HumanoidRootPart.Position - EnemyRoot.Position).Magnitude
                if Distance < ShortestDistance then
                    ShortestDistance = Distance
                    ClosestEnemy = player.Character
                end
            end
        end
    end
    return ClosestEnemy
end

function Functions.Fling(Target)
    local Root = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local TRoot = Target:FindFirstChild("HumanoidRootPart")
    if Root and TRoot then
        local OldCFrame = Root.CFrame
        local Velocity = Instance.new("BodyAngularVelocity")
        Velocity.AngularVelocity = Vector3.new(0, 99999, 0)
        Velocity.MaxTorque = Vector3.new(0, math.huge, 0)
        Velocity.P = math.huge
        Velocity.Parent = Root
        Root.CFrame = TRoot.CFrame
        task.wait(0.1)
        Velocity:Destroy()
        Root.CFrame = OldCFrame
        Functions.ResetPhysics()
    end
end

function Functions.ToggleFly(v)
    Functions.Flying = v
    local Root = game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not Root then return end
    if Functions.Flying then
        local BV = Instance.new("BodyVelocity", Root)
        BV.Name = "FlyVelocity"
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        task.spawn(function()
            while Functions.Flying do
                local MoveDir = Vector3.new(0,0,0)
                local Cam = workspace.CurrentCamera.CFrame
                local UIS = game:GetService("UserInputService")
                if UIS:IsKeyDown(Enum.KeyCode.W) then MoveDir = MoveDir + Cam.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then MoveDir = MoveDir - Cam.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then MoveDir = MoveDir - Cam.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then MoveDir = MoveDir + Cam.RightVector end
                BV.Velocity = MoveDir * Functions.FlySpeed
                task.wait()
            end
            BV:Destroy()
            Functions.ResetPhysics()
        end)
    end
end

function Functions.GiveAllItems()
    local Storage = {game:GetService("ReplicatedStorage"), game:GetService("Lighting")}
    for _, s in pairs(Storage) do
        for _, item in pairs(s:GetDescendants()) do
            if item:IsA("Tool") then
                item:Clone().Parent = game:GetService("Players").LocalPlayer.Backpack
            end
        end
    end
end

function Functions.LockMyBarrier()
    local LP = game:GetService("Players").LocalPlayer
    for _, base in pairs(workspace:FindFirstChild("Bases") and workspace.Bases:GetChildren() or {}) do
        if base:FindFirstChild("Owner") and base.Owner.Value == LP.Name then
            local Remote = base:FindFirstChild("ToggleBarrier") or base:FindFirstChild("Remote")
            if Remote and Remote:IsA("RemoteEvent") then Remote:FireServer(true) end
        end
    end
end

return Functions