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
Functions.KillAura = false -- Utilisé pour le Fling

Functions.FlySpeed = 50
Functions.DetectionRadius = 500
Functions.KillRange = 25 -- Portée pour le Fling

-- [[ DÉTECTION : BRAINROT (ITEMS) ]] --
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

-- [[ DÉTECTION : JOUEURS (CIBLES) ]] --
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

-- [[ LOGIQUE : FLING (POUR KILL SANS TAPER) ]] --
function Functions.Fling(Target)
    local Character = LocalPlayer.Character
    local Root = Character:FindFirstChild("HumanoidRootPart")
    local TRoot = Target:FindFirstChild("HumanoidRootPart")
    
    if Root and TRoot then
        local OldCFrame = Root.CFrame
        
        -- Création de la force rotative massive
        local Velocity = Instance.new("BodyAngularVelocity")
        Velocity.Name = "FlingForce"
        Velocity.AngularVelocity = Vector3.new(0, 99999, 0)
        Velocity.MaxTorque = Vector3.new(0, math.huge, 0)
        Velocity.P = math.huge
        Velocity.Parent = Root
        
        -- Téléportation flash sur la cible pour l'éjecter
        Root.CFrame = TRoot.CFrame
        task.wait(0.1) -- Délai pour que la physique de Roblox traite le choc
        
        -- Nettoyage et retour à la position sécurisée
        Velocity:Destroy()
        Root.CFrame = OldCFrame
    end
end

-- [[ LOGIQUE : VOL (FLY) ]] --
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
        end)
    end
end

return Functions