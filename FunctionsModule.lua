local Functions = {}

Functions.FlySpeed = 50
Functions.WalkSpeed = 16
Functions.JumpPower = 50
Functions.Flying = false
Functions.Noclip = false
Functions.InfJump = false
Functions.SavedPosition = nil

local LP = game:GetService("Players").LocalPlayer
local NoclipConnection = nil

function Functions.SetSpeed(value)
    Functions.WalkSpeed = value
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = value
    end
end

function Functions.SetJump(value)
    Functions.JumpPower = value
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.JumpPower = value
        LP.Character.Humanoid.UseJumpPower = true 
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
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
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

game:GetService("UserInputService").JumpRequest:Connect(function()
    if Functions.InfJump and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Supprimer les barrières de mort/kick (VIP Doors)
function Functions.BypassTouch()
    for _, v in pairs(workspace:GetDescendants()) do
        -- On cherche les objets qui déclenchent un script au toucher
        if v:IsA("TouchTransmitter") then
            local parent = v.Parent
            -- Si le nom contient VIP, Kill, Death ou Kick, on supprime le danger
            if parent.Name:find("VIP") or parent.Name:find("Kill") or parent.Name:find("Death") then
                v:Destroy() 
            end
        end
    end
    print("🛡️ TouchInterests dangereux supprimés !")
end

-- Tenter de récupérer tous les objets via RemoteEvents
function Functions.GetRemoteTools()
    for _, v in pairs(game:GetDescendants()) do
        -- On cherche les événements qui pourraient donner des items
        if v:IsA("RemoteEvent") and (v.Name:find("Give") or v.Name:find("Tool") or v.Name:find("Item")) then
            v:FireServer() -- On tente de déclencher l'événement
        end
    end
    print("🎁 Tentative de récupération d'items envoyée !")
end

function Functions.SetTPPoint()
    local Char = LP.Character
    if Char and Char:FindFirstChild("HumanoidRootPart") then
        Functions.SavedPosition = Char.HumanoidRootPart.CFrame
        print("📍 Position enregistrée avec succès !")
        -- Petit feedback visuel (optionnel)
        Rayfield:Notify({
            Title = "Point de TP",
            Content = "Position actuelle sauvegardée !",
            Duration = 2,
            Image = 4483362458,
        })
    end
end

-- Revenir au point enregistré
function Functions.GoToTPPoint()
    local Char = LP.Character
    if Char and Char:FindFirstChild("HumanoidRootPart") then
        if Functions.SavedPosition then
            Char.HumanoidRootPart.CFrame = Functions.SavedPosition
            print("🚀 Téléportation effectuée !")
        else
            warn("❌ Aucun point de TP enregistré !")
        end
    end
end

function Functions.ChangeSize(modifier)
    local Char = LP.Character
    local Hum = Char and Char:FindFirstChild("Humanoid")
    if not Hum then return end

    -- Liste des paramètres de taille R15
    local Scales = {
        "BodyHeightScale",
        "BodyWidthScale",
        "BodyDepthScale",
        "HeadScale"
    }

    for _, scaleName in pairs(Scales) do
        -- On cherche l'objet, s'il n'existe pas, on le crée !
        local scaleValue = Hum:FindFirstChild(scaleName)
        if not scaleValue then
            scaleValue = Instance.new("NumberValue")
            scaleValue.Name = scaleName
            scaleValue.Parent = Hum
        end
        scaleValue.Value = modifier
    end
end

function Functions.EnableAntiAFK()
    local VU = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        VU:CaptureController()
        VU:ClickButton2(Vector2.new())
    end)
end

return Functions