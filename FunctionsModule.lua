-- [[ ⚙️ UNIVERSAL FUNCTIONS MODULE v6.8 ]] --
local Functions = {}

-- Variables de configuration
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

-- Helpers sécurisés
local function GetHum()
    return LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
end

-- [[ 🏃 FONCTIONS DE MOUVEMENT ]] --
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
        if root:FindFirstChild("UniversalFly") then root.UniversalFly:Destroy() end
        local BV = Instance.new("BodyVelocity", root)
        BV.Name = "UniversalFly"
        BV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
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
    if state and not NoclipConnection then
        NoclipConnection = RunService.Stepped:Connect(function()
            if not Functions.Noclip then 
                NoclipConnection:Disconnect()
                NoclipConnection = nil
                return 
            end
            if LP.Character then
                for _, p in pairs(LP.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end
end

-- [[ 📍 TELEPORTATION ]] --
function Functions.SetTPPoint()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        Functions.SavedPosition = LP.Character.HumanoidRootPart.CFrame
    end
end

function Functions.GoToTPPoint()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and Functions.SavedPosition then
        local root = LP.Character.HumanoidRootPart
        local dist = (root.Position - Functions.SavedPosition.Position).Magnitude
        TweenService:Create(root, TweenInfo.new(dist/Functions.TPSpeed), {CFrame = Functions.SavedPosition}):Play()
    end
end

-- [[ ⚔️ BLADE BALL & MM2 ]] --
function Functions.RemoteParry()
    local ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Balls") or workspace:FindFirstChild("CurrentBall")
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Parry", true)
    if ball and remote and remote:IsA("RemoteEvent") then
        remote:FireServer(ball.Position, ball.CFrame)
    end
end

-- Hook de Silent Aim (MM2) avec protection contre les crashs
local success, err = pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if Functions.SilentAim and method == "FireServer" and (self.Name == "Shoot" or self.Name == "Throw") then
            -- Logique simplifiée pour éviter le lag
            return oldNamecall(self, ...)
        end
        return oldNamecall(self, ...)
    end)
end)

-- [[ 🛡️ BOUCLE AUTOMATIQUE ]] --
task.spawn(function()
    while task.wait(0.05) do
        if Functions.AutoSpam then Functions.RemoteParry() end
    end
end)

-- Events
UIS.InputBegan:Connect(function(i, p)
    if not p then 
        -- On transforme ParryKey en Enum seulement au moment du clic
        local targetKey = (type(Functions.ParryKey) == "string") and Enum.KeyCode[Functions.ParryKey] or Functions.ParryKey
        
        if i.KeyCode == targetKey then 
            Functions.RemoteParry() 
        end
    end
end)

return Functions