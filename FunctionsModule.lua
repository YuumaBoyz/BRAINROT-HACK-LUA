local Functions = {}

-- [[ ⚙️ CONFIGURATION & VARIABLES ]] --
Functions.FlySpeed = 60
Functions.WalkSpeed = 16
Functions.JumpPower = 50
Functions.TPSpeed = 150 -- Vitesse du TP (plus c'est bas, plus c'est discret)
Functions.Flying = false
Functions.Noclip = false
Functions.InfJump = false
Functions.SavedPosition = nil
Functions.LookAtEnabled = false
Functions.ParryKey = Enum.KeyCode.F -- Touche pour Blade Ball

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
        -- Nettoyage si un ancien Fly existe
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

-- [[ 📍 TÉLÉPORTATION ]] --
function Functions.SetTPPoint()
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        Functions.SavedPosition = LP.Character.HumanoidRootPart.CFrame
        print("📍 Position enregistrée !")
    end
end

function Functions.GoToTPPoint()
    local Char = LP.Character
    if Char and Char:FindFirstChild("HumanoidRootPart") and Functions.SavedPosition then
        local Root = Char.HumanoidRootPart
        local targetCFrame = Functions.SavedPosition
        
        -- On calcule la distance
        local distance = (Root.Position - targetCFrame.Position).Magnitude
        
        -- Si on est à plus de 500 studs, on fait un petit saut intermédiaire pour éviter les bugs
        task.spawn(function()
            print("🚀 Déplacement Stealth en cours...")
            local tweenService = game:GetService("TweenService")
            local info = TweenInfo.new(distance / Functions.TPSpeed, Enum.EasingStyle.Linear)
            local tween = tweenService:Create(Root, info, {CFrame = targetCFrame})
            
            -- On active le Noclip pendant le TP pour ne pas rester bloqué dans un mur
            local oldNoclip = Functions.Noclip
            Functions.ToggleNoclip(true)
            
            tween:Play()
            tween.Completed:Wait()
            
            Functions.ToggleNoclip(oldNoclip)
            print("✅ Arrivé à destination !")
        end)
    else
        warn("❌ Aucun point enregistré ou personnage introuvable !")
    end
end

-- [[ ⚔️ BLADE BALL : REMOTE SNIPER ]] --
function Functions.RemoteParry()
    local ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Balls")
    
    if ball then
        local rStorage = game:GetService("ReplicatedStorage")
        -- Recherche multi-remotes pour compatibilité
        local parryRemote = rStorage:FindFirstChild("Remotes") and rStorage.Remotes:FindFirstChild("Parry") 
                            or rStorage:FindFirstChild("ParryAttempt") 
                            or rStorage:FindFirstChild("Parry")

        if parryRemote then
            parryRemote:FireServer(ball.Position) 
            print("🎯 Remote Sniper : Balle interceptée !")
            
            -- Effet visuel
            local highlight = Instance.new("SelectionBox")
            highlight.Adornee = ball
            highlight.Color3 = Color3.fromRGB(0, 255, 0)
            highlight.Parent = ball
            task.delay(0.3, function() if highlight then highlight:Destroy() end end)
        else
            warn("❌ Remote de Parry introuvable !")
        end
    end
end

-- [[ 🎭 SOCIAL & VISUEL ]] --
function Functions.ToggleLookAt(state)
    Functions.LookAtEnabled = state
    task.spawn(function()
        while Functions.LookAtEnabled do
            local closest, dist = nil, math.huge
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local d = (LP.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < dist then dist = d closest = p end
                end
            end
            if closest and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                local pos = closest.Character.HumanoidRootPart.Position
                LP.Character.HumanoidRootPart.CFrame = CFrame.lookAt(LP.Character.HumanoidRootPart.Position, Vector3.new(pos.X, LP.Character.HumanoidRootPart.Position.Y, pos.Z))
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
    print("🎁 Tentative de Give effectuée !")
end

function Functions.ChangeSize(modifier)
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        local Hum = LP.Character.Humanoid
        local Scales = {"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale"}
        for _, n in pairs(Scales) do
            local v = Hum:FindFirstChild(n) or Instance.new("NumberValue", Hum)
            v.Name = n
            v.Value = modifier
        end
    end
end

-- [[ 👁️ MM2 : ROLE ESP ]] --
function Functions.ToggleRoleESP(state)
    Functions.RoleESP = state
    
    task.spawn(function()
        while Functions.RoleESP do
            for _, v in pairs(game.Players:GetPlayers()) do
                if v ~= LP and v.Character then
                    -- On cherche ou on crée le Highlight
                    local highlight = v.Character:FindFirstChild("RoleHighlight") or Instance.new("Highlight")
                    highlight.Name = "RoleHighlight"
                    highlight.Parent = v.Character
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                    
                    -- Détection du rôle par l'inventaire
                    local character = v.Character
                    local backpack = v.Backpack
                    
                    if backpack:FindFirstChild("Knife") or character:FindFirstChild("Knife") then
                        highlight.FillColor = Color3.fromRGB(255, 0, 0) -- 🔪 Meurtrier (Rouge)
                        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
                    elseif backpack:FindFirstChild("Gun") or character:FindFirstChild("Gun") then
                        highlight.FillColor = Color3.fromRGB(0, 0, 255) -- 🔫 Sheriff (Bleu)
                        highlight.OutlineColor = Color3.fromRGB(0, 0, 255)
                    else
                        highlight.FillColor = Color3.fromRGB(0, 255, 0) -- 🟢 Innocent (Vert)
                        highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
                    end
                end
            end
            task.wait(1) -- Rafraîchissement toutes les secondes
        end
        
        -- Nettoyage si on désactive
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("RoleHighlight") then
                v.Character.RoleHighlight:Destroy()
            end
        end
    end)
end

-- [[ 🎯 MM2 : SILENT AIM ]] --
function Functions.GetSilentTarget()
    local target = nil
    local shortestDist = math.huge
    local LP = game:GetService("Players").LocalPlayer
    
    -- Vérifie si on est Murderer
    local isMurderer = LP.Backpack:FindFirstChild("Knife") or (LP.Character and LP.Character:FindFirstChild("Knife"))
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if not isMurderer then
                -- Si on est Sheriff/Hero : Cible uniquement le Murderer
                if v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife") then
                    return v.Character.HumanoidRootPart
                end
            else
                -- Si on est Murderer : Cible le plus proche
                local dist = (v.Character.HumanoidRootPart.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    target = v.Character.HumanoidRootPart
                end
            end
        end
    end
    return target
end

-- Hook pour rediriger l'attaque
function Functions.ToggleSilentAim(state)
    -- Sécurité : Si state est nil, on s'arrête
    if state == nil then return end
    
    Functions.SilentAim = state
    print("🎯 Silent Aim : " .. (state and "ACTIVÉ" or "DÉSACTIVÉ"))
    
    if state then
        -- On utilise task.spawn pour ne pas bloquer le reste du chargement
        task.spawn(function()
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local args = {...}
                local method = getnamecallmethod()
                
                -- Vérification que le SilentAim est toujours actif
                if Functions.SilentAim and method == "FireServer" then
                    if self.Name == "Shoot" or self.Name == "Throw" then
                        local target = Functions.GetSilentTarget()
                        if target then
                            args[1] = target.Position
                            return oldNamecall(self, table.unpack(args))
                        end
                    end
                end
                return oldNamecall(self, ...)
            end)
        end)
    end
end

function Functions.AutoGrabGun()
    local drop = workspace:FindFirstChild("GunDrop")
    if drop and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local Root = LP.Character.HumanoidRootPart
        local oldPos = Root.CFrame
        
        print("🔫 Tentative de récupération du pistolet...")
        
        -- Désactive momentanément le Noclip pour être sûr de toucher l'objet
        local wasNoclip = Functions.Noclip
        Functions.ToggleNoclip(true)

        -- Boucle de récupération (on reste sur l'arme jusqu'à ce qu'elle disparaisse du sol)
        local timeout = 0
        repeat
            Root.CFrame = drop.CFrame * CFrame.new(0, 1, 0) -- On se TP légèrement au-dessus
            task.wait(0.1)
            timeout = timeout + 1
        until not workspace:FindFirstChild("GunDrop") or timeout > 10
        
        -- On revient à la position de départ (optionnel, enlève si tu veux rester là-bas)
        -- Root.CFrame = oldPos
        
        Functions.ToggleNoclip(wasNoclip)
        print("✅ Pistolet récupéré !")
    else
        -- Si l'UI a besoin d'une notification, elle sera gérée dans le UI.lua
        warn("❌ Le pistolet n'est pas au sol !")
    end
end

-- [[ 🛡️ SYSTÈME & EVENTS ]] --
function Functions.EnableAntiAFK()
    local VU = game:GetService("VirtualUser")
    LP.Idled:Connect(function() 
        VU:CaptureController() 
        VU:ClickButton2(Vector2.new()) 
    end)
    print("💤 Anti-AFK activé !")
end

-- Gestion des touches
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Functions.ParryKey then
        Functions.RemoteParry()
    end
end)

-- Saut Infini
game:GetService("UserInputService").JumpRequest:Connect(function()
    if Functions.InfJump and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

return Functions