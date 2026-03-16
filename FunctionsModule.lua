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
local TweenService = game:GetService("TweenService")
local NoclipConnection = nil

-- Fonction utilitaire pour vérifier si le personnage est valide
local function GetChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function GetHum()
    local char = LP.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- [[ 🏃 MOUVEMENT ]] --
function Functions.SetSpeed(value)
    Functions.WalkSpeed = value
    local hum = GetHum()
    if hum then hum.WalkSpeed = value end
end

function Functions.SetJump(value)
    Functions.JumpPower = value
    local hum = GetHum()
    if hum then
        hum.UseJumpPower = true 
        hum.JumpPower = value
    end
end

function Functions.ToggleFly(state)
    Functions.Flying = state
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local root = char.HumanoidRootPart

    if Functions.Flying then
        -- Nettoyage si un ancien Fly existe
        if root:FindFirstChild("UniversalFly") then root.UniversalFly:Destroy() end
        
        local BV = Instance.new("BodyVelocity")
        BV.Name = "UniversalFly"
        BV.Parent = root
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        BV.Velocity = Vector3.new(0,0,0)

        task.spawn(function()
            while Functions.Flying and root and root.Parent do
                local cam = workspace.CurrentCamera.CFrame
                local dir = Vector3.new(0,0,0)
                if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
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
                        if part:IsA("BasePart") and part.CanCollide then 
                            part.CanCollide = false 
                        end
                    end
                elseif NoclipConnection then 
                    NoclipConnection:Disconnect() 
                    NoclipConnection = nil 
                end
            end)
        end
    end
end

-- [[ 📍 TÉLÉPORTATION ]] --
function Functions.SetTPPoint()
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        Functions.SavedPosition = char.HumanoidRootPart.CFrame
        print("📍 ***Position enregistrée !***")
    end
end

function Functions.GoToTPPoint()
    local char = LP.Character
    if char and char:FindFirstChild("HumanoidRootPart") and Functions.SavedPosition then
        local root = char.HumanoidRootPart
        local dist = (root.Position - Functions.SavedPosition.Position).Magnitude
        
        task.spawn(function()
            local tween = TweenService:Create(root, TweenInfo.new(dist / Functions.TPSpeed, Enum.EasingStyle.Linear), {CFrame = Functions.SavedPosition})
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
        if parryRemote and parryRemote:IsA("RemoteEvent") then
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
            -- Nettoyage
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
    local char = LP.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local isMurderer = LP.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if not isMurderer then
                if v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife") then 
                    return v.Character.HumanoidRootPart 
                end
            else
                local d = (v.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
                if d < shortestDist then 
                    shortestDist = d 
                    target = v.Character.HumanoidRootPart 
                end
            end
        end
    end
    return target
end

-- Hook de Namecall (Sécurisé contre les exécutions multiples)
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

-- [[ 🛡️ BOUCLES GLOBALES ]] --
task.spawn(function()
    while true do
        if Functions.AutoSpam then
            Functions.RemoteParry()
        end
        task.wait(0.05)
    end
end)

-- [[ 🛡️ ÉVÉNEMENTS ]] --
UIS.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == Functions.ParryKey then 
        Functions.RemoteParry() 
    end
end)

UIS.JumpRequest:Connect(function()
    if Functions.InfJump then
        local hum = GetHum()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

return Functions