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
Functions.ParryKey = Enum.KeyCode.F
Functions.SilentAim = false
Functions.AutoSpam = false
Functions.RoleESP = false

local LP = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local NoclipConnection = nil

-- [[ 🏃 MOUVEMENT ]] --
function Functions.SetSpeed(value)
    Functions.WalkSpeed = value
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = value
    end
end

-- CORRECTIF : Ajout de la fonction manquante pour le Main.lua
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
        local BV = Instance.new("BodyVelocity")
        BV.Name = "UniversalFly"
        BV.Parent = Root
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BV.Velocity = Vector3.new(0,0,0)

        task.spawn(function()
            while Functions.Flying and Root and Root.Parent do
                local Cam = workspace.CurrentCamera.CFrame
                local dir = Vector3.new(0,0,0)
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
            NoclipConnection = RunService.Stepped:Connect(function()
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
        local remotes = rStorage:FindFirstChild("Remotes")
        local parryRemote = (remotes and remotes:FindFirstChild("Parry")) 
                            or rStorage:FindFirstChild("ParryAttempt") 
                            or rStorage:FindFirstChild("Parry")
        if parryRemote then
            parryRemote:FireServer(ball.Position, ball.CFrame)
        end
    end
end

-- [[ 🕵️ MURDER MYSTERY 2 ]] --
function Functions.ToggleRoleESP(state)
    Functions.RoleESP = state
    if state then
        task.spawn(function()
            while Functions.RoleESP do
                for _, v in pairs(game.Players:GetPlayers()) do
                    if v ~= LP and v.Character then
                        local hl = v.Character:FindFirstChild("RoleHighlight") or Instance.new("Highlight", v.Character)
                        hl.Name = "RoleHighlight"
                        local inv = v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")
                        local gun = v.Backpack:FindFirstChild("Gun") or v.Character:FindFirstChild("Gun")
                        
                        if inv then hl.FillColor = Color3.fromRGB(255, 0, 0)
                        elseif gun then hl.FillColor = Color3.fromRGB(0, 0, 255)
                        else hl.FillColor = Color3.fromRGB(0, 255, 0) end
                        hl.FillTransparency = 0.5
                    end
                end
                task.wait(1)
            end
            for _, v in pairs(game.Players:GetPlayers()) do 
                if v.Character and v.Character:FindFirstChild("RoleHighlight") then 
                    v.Character.RoleHighlight:Destroy() 
                end 
            end
        end)
    end
end

function Functions.GetSilentTarget()
    local target, shortestDist = nil, math.huge
    local isMurderer = LP.Backpack:FindFirstChild("Knife") or (LP.Character and LP.Character:FindFirstChild("Knife"))
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if not isMurderer then
                if v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife") then 
                    return v.Character.HumanoidRootPart 
                end
            else
                local d = (v.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if d < shortestDist then 
                    shortestDist = d 
                    target = v.Character.HumanoidRootPart 
                end
            end
        end
    end
    return target
end

-- CORRECTIF : Initialisation du Hook une seule fois
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if Functions.SilentAim and method == "FireServer" and (self.Name == "Shoot" or self.Name == "Throw") then
        local target = Functions.GetSilentTarget()
        if target then 
            args[1] = target.Position 
            return oldNamecall(self, unpack(args)) 
        end
    end
    return oldNamecall(self, ...)
end)

-- [[ 🛡️ AUTO-SPAM ]] --
task.spawn(function()
    while true do
        if Functions.AutoSpam then
            Functions.RemoteParry()
        end
        task.wait(0.05)
    end
end)

-- [[ 🛡️ EVENTS ]] --
UIS.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Functions.ParryKey then 
        Functions.RemoteParry() 
    end
end)

UIS.JumpRequest:Connect(function()
    if Functions.InfJump and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

return Functions