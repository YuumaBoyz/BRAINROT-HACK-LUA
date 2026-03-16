-- [[ ⚙️ UNIVERSAL FUNCTIONS MODULE v6.9 ]] --
local Functions = {}

-- [[ ⚙️ CONFIGURATION & VARIABLES ]] --
Functions.FlySpeed = 60
Functions.WalkSpeed = 16
Functions.JumpPower = 20
Functions.TPSpeed = 150
Functions.Flying = false
Functions.Noclip = false
Functions.InfJump = false
Functions.SavedPosition = nil
Functions.ParryKey = "F" 
Functions.SilentAim = false
Functions.AutoSpam = false
Functions.RoleESP = false
Functions.NoCooldown = false -- Nouvelle option

-- Options de Boost (Blade Ball)
Functions.BallBoost = false 
Functions.BoostMultiplier = 1.5 

local LP = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local NoclipConnection = nil

-- [[ 🛠️ HELPERS ]] --
local function GetHum()
    return LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
end

-- Fonction pour trouver la balle réelle (Partie physique)
local function GetBall()
    local ballFolder = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Balls") or workspace:FindFirstChild("CurrentBall")
    if ballFolder then
        if ballFolder:IsA("BasePart") then return ballFolder end
        local realBall = ballFolder:FindFirstChildOfClass("BasePart")
        return realBall
    end
    return nil
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

-- [[ ⚔️ SYSTÈME DE SCAN PRODIGIEUX (NO COOLDOWN) ]] --
function Functions.ToggleNoCooldown(state)
    Functions.NoCooldown = state
    
    if state then
        task.spawn(function()
            print("🔍 ***Lancement du scan profond des fichiers...***")
            
            -- On utilise getgc (Get Garbage Collector) pour fouiller la mémoire du jeu
            for _, v in pairs(getgc(true)) do
                if type(v) == "function" and islclosure(v) then
                    local name = debug.getinfo(v).name
                    local constants = debug.getconstants(v)
                    
                    -- On cherche des fonctions qui parlent de "Cooldown", "Ability", ou "Reset"
                    if name and (name:lower():find("cooldown") or name:lower():find("ability")) then
                        -- On remplace la fonction par une fonction vide qui retourne immédiatement
                        hookfunction(v, function() return end)
                    end
                    
                    -- Scan des constantes pour trouver les timers cachés
                    for _, const in pairs(constants) do
                        if const == "Cooldown" or const == "TickRate" then
                            -- On force les variables locales du script à 0
                            debug.setupvalue(v, "Cooldown", 0)
                            debug.setupvalue(v, "CD", 0)
                        end
                    end
                end
            end
            print("✅ ***Scan terminé : Cooldowns neutralisés !***")
        end)
    end
end

function Functions.ToggleCurveSpike(state)
    Functions.CurveSpike = state
    
    task.spawn(function()
        while Functions.CurveSpike do
            local ball = workspace:FindFirstChild("Ball") -- À vérifier selon le jeu
            if ball and ball.AssemblyLinearVelocity.Magnitude > 30 then
                -- On vérifie si c'est nous qui venons de frapper
                local dist = (ball.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if dist < 15 then
                    task.wait(0.1) -- Laisse la balle partir un peu pour l'effet visuel
                    
                    -- Détection du contreur le plus proche
                    for _, p in pairs(game.Players:GetPlayers()) do
                        if p ~= LP and p.Team ~= LP.Team and p.Character then
                            local opponentPos = p.Character.HumanoidRootPart.Position
                            local ballDir = ball.AssemblyLinearVelocity.Unit
                            local toOpponent = (opponentPos - ball.Position).Unit
                            
                            -- Si l'adversaire est sur le chemin (angle faible)
                            if ballDir:Dot(toOpponent) > 0.8 then 
                                -- On dévie la trajectoire sur le côté puis vers le bas
                                local sideSteer = Vector3.new(-ballDir.Z, 0, ballDir.X) -- Perpendiculaire
                                ball.AssemblyLinearVelocity = (ballDir + sideSteer * 0.5).Unit * ball.AssemblyLinearVelocity.Magnitude
                                
                                -- Force de chute pour toucher le sol vite
                                local force = Instance.new("BodyForce", ball)
                                force.Force = Vector3.new(0, -5000, 0)
                                game.Debris:AddItem(force, 0.5)
                                break
                            end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

function Functions.ToggleSlowMo(state)
    Functions.SlowMoActive = state
    
    RunService.RenderStepped:Connect(function()
        if not Functions.SlowMoActive then return end
        
        local ball = workspace:FindFirstChild("Ball")
        if ball and ball:IsA("BasePart") then
            local dist = (ball.Position - LP.Character.HumanoidRootPart.Position).Magnitude
            
            -- Si la balle est à moins de 20 mètres
            if dist < 20 then
                -- On ralentit localement le rendu de la position
                local shadowBall = ball:FindFirstChild("SlowMoVisual") or Instance.new("Part")
                if shadowBall.Name ~= "SlowMoVisual" then
                    shadowBall.Name = "SlowMoVisual"
                    shadowBall.Size = ball.Size
                    shadowBall.Shape = ball.Shape
                    shadowBall.Color = Color3.fromRGB(0, 255, 255)
                    shadowBall.Material = Enum.Material.Neon
                    shadowBall.Transparency = 0.6
                    shadowBall.CanCollide = false
                    shadowBall.Anchored = true
                    shadowBall.Parent = workspace
                end
                
                -- On crée une interpolation fluide et lente pour ton écran
                local targetPos = ball.Position
                shadowBall.CFrame = shadowBall.CFrame:Lerp(CFrame.new(targetPos), 0.15) -- 0.15 = ralentissement
                
                -- On rend la vraie balle invisible pour ne voir que la lente
                ball.LocalTransparencyModifier = 1
            else
                local shadow = workspace:FindFirstChild("SlowMoVisual")
                if shadow then shadow:Destroy() end
                ball.LocalTransparencyModifier = 0
            end
        end
    end)
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
                if NoclipConnection then NoclipConnection:Disconnect() end
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

-- [[ ⚔️ BLADE BALL ]] --

-- Fonction 1 : Parade classique
function Functions.RemoteParry()
    local ball = GetBall()
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Parry", true)
    if ball and remote and remote:IsA("RemoteEvent") then
        remote:FireServer(ball.Position, ball.CFrame)
    end
end

-- Fonction 2 : Boost de vitesse (Indépendant)
function Functions.ApplyBallBoost()
    if not Functions.BallBoost then return end
    local ball = GetBall()
    if ball then
        pcall(function()
            -- Injection de vélocité
            ball.AssemblyLinearVelocity = ball.AssemblyLinearVelocity * Functions.BoostMultiplier
        end)
    end
end

-- [[ 🕵️ MM2 ]] --
local success, err = pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if Functions.SilentAim and method == "FireServer" and (self.Name == "Shoot" or self.Name == "Throw") then
            return oldNamecall(self, ...)
        end
        return oldNamecall(self, ...)
    end)
end)

-- [[ 🛡️ BOUCLES & ÉVÉNEMENTS ]] --

-- Boucle Auto-Spam
task.spawn(function()
    while task.wait(0.05) do
        if Functions.AutoSpam then 
            Functions.RemoteParry() 
            if Functions.BallBoost then Functions.ApplyBallBoost() end
        end
    end
end)

-- Écoute des touches (Parry + Boost si activé)
UIS.InputBegan:Connect(function(i, p)
    if not p then
        local keyToDetect = Enum.KeyCode[Functions.ParryKey]
        if i.KeyCode == keyToDetect then 
            Functions.RemoteParry() 
            if Functions.BallBoost then 
                Functions.ApplyBallBoost() 
            end
        end
    end
end)

return Functions