local Functions = {}

-- [[ SERVICES ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ VARIABLES DE CONFIGURATION ]] --
Functions.Flying = false
Functions.AutoSteal = false
Functions.KillAura = false 
Functions.PermanentBarrier = false -- 🔒 Nouvel état pour ta base

Functions.FlySpeed = 50
Functions.DetectionRadius = 500
Functions.KillRange = 25 

-- [[ 🛡️ SYSTÈME ANTI-KICK & SÉCURITÉ ]] --

-- Empêche d'être kické après 20 minutes d'inactivité
function Functions.EnableAntiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
        print("🛡️ Anti-AFK : Signal envoyé pour maintenir la session.")
    end)
end

-- Stabilise le personnage et trompe les calculs de l'Anti-Cheat
function Functions.ResetPhysics()
    local Character = LocalPlayer.Character
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        local HRP = Character.HumanoidRootPart
        HRP.Velocity = Vector3.new(0, 0, 0)
        HRP.RotVelocity = Vector3.new(0, 0, 0)
    end
end

-- [[ 🔍 DÉTECTION : ITEMS & JOUEURS ]] --

function Functions.GetClosestBrainrot()
    local Character = LocalPlayer.Character
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
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local ClosestEnemy = nil
    local ShortestDistance = Functions.KillRange
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            local EnemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local EnemyHumanoid = player.Character.Humanoid
            
            if EnemyRoot and EnemyHumanoid.Health > 0 then
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

-- [[ 🌪️ LOGIQUE DE COMBAT : FLING ]] --

function Functions.Fling(Target)
    local Character = LocalPlayer.Character
    local Root = Character:FindFirstChild("HumanoidRootPart")
    local TRoot = Target:FindFirstChild("HumanoidRootPart")
    
    if Root and TRoot then
        local OldCFrame = Root.CFrame
        local Velocity = Instance.new("BodyAngularVelocity")
        Velocity.Name = "FlingForce"
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

-- [[ 🚀 LOGIQUE DE MOUVEMENT : FLY ]] --

function Functions.ToggleFly(v)
    Functions.Flying = v
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then return end
    local Root = Character.HumanoidRootPart
    
    if Functions.Flying then
        local Velocity = Instance.new("BodyVelocity", Root)
        Velocity.Name = "FlyVelocity"
        Velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        
        task.spawn(function()
            while Functions.Flying do
                local MoveDir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then MoveDir = MoveDir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then MoveDir = MoveDir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then MoveDir = MoveDir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then MoveDir = MoveDir + Camera.CFrame.RightVector end
                
                Velocity.Velocity = MoveDir * Functions.FlySpeed
                RunService.RenderStepped:Wait()
            end
            if Velocity then Velocity:Destroy() end
            Functions.ResetPhysics()
        end)
    end
end

-- [[ 🎒 LOGIQUE D'INVENTAIRE : GIVE ALL ]] --

function Functions.GiveAllItems()
    local Backpack = LocalPlayer:FindFirstChild("Backpack")
    local StoragePlaces = {game:GetService("ReplicatedStorage"), game:GetService("Lighting")}
    
    for _, storage in pairs(StoragePlaces) do
        for _, item in pairs(storage:GetDescendants()) do
            if item:IsA("Tool") then
                local clone = item:Clone()
                clone.Parent = Backpack
            end
        end
    end
end

-- [[ 🏠 LOGIQUE DE BASE : BARRIÈRE PERMANENTE ]] --

function Functions.LockMyBarrier()
    task.spawn(function()
        while Functions.PermanentBarrier do
            for _, base in pairs(workspace:FindFirstChild("Bases") and workspace.Bases:GetChildren() or {}) do 
                -- On vérifie si tu es le propriétaire de la base
                if base:FindFirstChild("Owner") and base.Owner.Value == LocalPlayer.Name then
                    -- On cherche le Remote de contrôle de la barrière
                    -- Note : Si ça ne marche pas, il faut ajuster le nom du Remote (souvent dans la porte ou le bouton)
                    local ToggleRemote = base:FindFirstChild("ToggleBarrier") or base:FindFirstChild("Remote") or game:GetService("ReplicatedStorage"):FindFirstChild("ToggleBarrier")
                    
                    if ToggleRemote and ToggleRemote:IsA("RemoteEvent") then
                        ToggleRemote:FireServer(true) -- Force la fermeture
                    end
                end
            end
            task.wait(1.5) -- Délai pour ne pas spammer le serveur inutilement
        end
    end)
end

return Functions