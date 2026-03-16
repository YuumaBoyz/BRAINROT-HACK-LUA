local Functions = {}

-- [[ ⚙️ CONFIGURATION & VARIABLES ]] --
Functions.FlySpeed = 60
Functions.WalkSpeed = 16
Functions.JumpPower = 50
Functions.TPSpeed = 150
Functions.Flying = false
Functions.Noclip = false
Functions.InfJump = false
Functions.SavedPosition = nil
Functions.LookAtEnabled = false
Functions.ParryKey = Enum.KeyCode.F
Functions.SilentAim = false
Functions.AutoSpam = false

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
        Hum.UseJumpPower = true 
        Hum.JumpPower = value
    end
end

function Functions.ToggleFly(state)
    Functions.Flying = state
    local Char = LP.Character
    if not Char or not Char:FindFirstChild("HumanoidRootPart") then return end
    local Root = Char.HumanoidRootPart

    if Functions.Flying then
        if Root:FindFirstChild("UniversalFly") then Root.UniversalFly:Destroy() end
        local BV = Instance.new("BodyVelocity", Root)
        BV.Name = "UniversalFly"
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BV.Velocity = Vector3.new(0,0,0)

        task.spawn(function()
            while Functions.Flying and Root and Root.Parent do
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
                    if NoclipConnection then NoclipConnection:Disconnect() NoclipConnection = nil end
                end
            end)
        end
    end
end

-- [[ 📍 TÉLÉPORTATION ]] --
function Functions.SetTPPoint()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        Functions.SavedPosition = LP.Character.HumanoidRootPart.CFrame
        print("📍 Position enregistrée !")
    end
end

function Functions.GoToTPPoint()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and Functions.SavedPosition then
        local Root = LP.Character.HumanoidRootPart
        local dist = (Root.Position - Functions.SavedPosition.Position).Magnitude
        task.spawn(function()
            local tween = game:GetService("TweenService"):Create(Root, TweenInfo.new(dist / Functions.TPSpeed, Enum.EasingStyle.Linear), {CFrame = Functions.SavedPosition})
            local oldNoclip = Functions.Noclip
            Functions.ToggleNoclip(true)
            tween:Play()
            tween.Completed:Wait()
            Functions.ToggleNoclip(oldNoclip)
        end)
    end
end

-- [[ ⚔️ BLADE BALL ]] --
function Functions.RemoteParry()
    local ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Balls") or (workspace:FindFirstChild("CurrentBall") and workspace.CurrentBall:FindFirstChildOfClass("Part"))
    if ball then
        local rStorage = game:GetService("ReplicatedStorage")
        local parryRemote = rStorage:FindFirstChild("Remotes") and rStorage.Remotes:FindFirstChild("Parry") 
                            or rStorage:FindFirstChild("ParryAttempt") 
                            or rStorage:FindFirstChild("Parry")
                            or rStorage:FindFirstChild("GeneralAbility")
        if parryRemote then
            parryRemote:FireServer(ball.Position, ball.CFrame)
        end
    end
end

function Functions.ToggleAutoSpam(state)
    Functions.AutoSpam = state
    task.spawn(function()
        while Functions.AutoSpam do
            Functions.RemoteParry()
            task.wait(0.05)
        end
    end)
end

-- [[ 🕵️ MURDER MYSTERY 2 ]] --
function Functions.ToggleRoleESP(state)
    Functions.RoleESP = state
    task.spawn(function()
        while Functions.RoleESP do
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= LP and v.Character then
                    local hl = v.Character:FindFirstChild("RoleHighlight") or Instance.new("Highlight", v.Character)
                    hl.Name = "RoleHighlight"
                    local inv = v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")
                    local gun = v.Backpack:FindFirstChild("Gun") or v.Character:FindFirstChild("Gun")
                    
                    if inv then hl.FillColor = Color3.fromRGB(255, 0, 0) -- Murderer
                    elseif gun then hl.FillColor = Color3.fromRGB(0, 0, 255) -- Sheriff
                    else hl.FillColor = Color3.fromRGB(0, 255, 0) end -- Innocent
                    
                    hl.FillTransparency = 0.5
                end
            end
            task.wait(1)
        end
        for _, v in pairs(game.Players:GetPlayers()) do if v.Character and v.Character:FindFirstChild("RoleHighlight") then v.Character.RoleHighlight:Destroy() end end
    end)
end

function Functions.GetSilentTarget()
    local target, shortestDist = nil, math.huge
    local isMurderer = LP.Backpack:FindFirstChild("Knife") or (LP.Character and LP.Character:FindFirstChild("Knife"))
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if not isMurderer then
                -- Sheriff : Cible uniquement le Murderer
                if v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife") then return v.Character.HumanoidRootPart end
            else
                -- Murderer : Cible le plus proche
                local d = (v.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if d < shortestDist then shortestDist = d target = v.Character.HumanoidRootPart end
            end
        end
    end
    return target
end

function Functions.ToggleSilentAim(state)
    Functions.SilentAim = state
    if state then
        task.spawn(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local args = {...}
                if Functions.SilentAim and getnamecallmethod() == "FireServer" and (self.Name == "Shoot" or self.Name == "Throw") then
                    local target = Functions.GetSilentTarget()
                    if target then args[1] = target.Position return oldNamecall(self, unpack(args)) end
                end
                return oldNamecall(self, ...)
            end)
        end)
    end
end

function Functions.AutoGrabGun()
    local drop = workspace:FindFirstChild("GunDrop")
    if drop and LP.Character then
        local Root = LP.Character.HumanoidRootPart
        local wasNoclip = Functions.Noclip
        Functions.ToggleNoclip(true)
        local timeout = 0
        repeat
            Root.CFrame = drop.CFrame * CFrame.new(0, 1, 0)
            task.wait(0.1)
            timeout = timeout + 1
        until not workspace:FindFirstChild("GunDrop") or timeout > 20
        Functions.ToggleNoclip(wasNoclip)
    end
end

-- [[ 🎭 AUTRES & SYSTÈME ]] --
function Functions.ChangeSize(modifier)
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        for _, n in pairs({"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}) do
            local v = LP.Character.Humanoid:FindFirstChild(n) or Instance.new("NumberValue", LP.Character.Humanoid)
            v.Name = n v.Value = modifier
        end
    end
end

function Functions.EnableAntiAFK()
    local VU = game:GetService("VirtualUser")
    LP.Idled:Connect(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end)
end

-- [[ 🛡️ EVENTS ]] --
game:GetService("UserInputService").InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Functions.ParryKey then Functions.RemoteParry() end
end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if Functions.InfJump and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

return Functions