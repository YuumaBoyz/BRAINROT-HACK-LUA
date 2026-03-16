local UI = {}

function UI.Init(Lib)
    -- Chargement de Rayfield avec sécurité
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    
    local Window = Rayfield:CreateWindow({
        Name = "🌐 UNIVERSAL HUB v6.8",
        LoadingTitle = "Initialisation du Multi-Tool...",
        LoadingSubtitle = "par YuumaBoyz",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "YuumaHubConfig",
            FileName = "UniversalConfig"
        }
    })

    -- [[ 🏃 ONGLET MOUVEMENT ]] --
    local TabMove = Window:CreateTab("🏃 Mouvement")
    TabMove:CreateSection("Vitesse & Capacités")

    TabMove:CreateSlider({
        Name = "Vitesse de marche",
        Range = {16, 500},
        Increment = 1,
        CurrentValue = 16,
        Callback = function(v) 
            if Lib.SetSpeed then Lib.SetSpeed(v) end 
        end,
    })

    TabMove:CreateToggle({
        Name = "Activer le Vol (Fly)",
        CurrentValue = false,
        Callback = function(v) 
            if Lib.ToggleFly then Lib.ToggleFly(v) end 
        end,
    })

    TabMove:CreateToggle({
        Name = "Noclip (Traverser les murs)",
        CurrentValue = false,
        Callback = function(v) 
            if Lib.ToggleNoclip then Lib.ToggleNoclip(v) end 
        end,
    })

    TabMove:CreateToggle({
        Name = "Saut Infini (Inf Jump)",
        CurrentValue = false,
        Callback = function(v) 
            Lib.InfJump = v
        end,
    })

    TabMove:CreateSection("Téléportation")

    TabMove:CreateButton({
        Name = "📍 Poser un Point de TP",
        Callback = function() 
            if Lib.SetTPPoint then Lib.SetTPPoint() end 
        end,
    })

    TabMove:CreateButton({
        Name = "🌀 Se téléporter au Point",
        Callback = function() 
            if Lib.GoToTPPoint then Lib.GoToTPPoint() end 
        end,
    })

    -- [[ 🕵️ ONGLET MURDER MYSTERY 2 ]] --
    local TabMM2 = Window:CreateTab("🕵️ MM2")
    TabMM2:CreateSection("Avantages")

    TabMM2:CreateToggle({
        Name = "Role ESP",
        CurrentValue = false,
        Callback = function(v) 
            if Lib.ToggleRoleESP then Lib.ToggleRoleESP(v) end
        end,
    })

    TabMM2:CreateToggle({
        Name = "Silent Aim",
        CurrentValue = false,
        Callback = function(v) 
            if Lib.ToggleSilentAim then Lib.ToggleSilentAim(v) end
        end,
    })

    TabMM2:CreateButton({
        Name = "🔫 Auto-Grab Gun",
        Callback = function() 
            if Lib.AutoGrabGun then Lib.AutoGrabGun() end
        end,
    })

    -- [[ ⚔️ ONGLET BLADE BALL ]] --
    local TabBlade = Window:CreateTab("⚔️ Blade Ball")
    TabBlade:CreateKeybind({
        Name = "Touche Parry",
        CurrentKeybind = "F",
        HoldToInteract = false,
        Flag = "ParryKeybind",
        Callback = function(Keybind)
            if Lib then Lib.ParryKey = Enum.KeyCode[Keybind] end
        end,
    })

    TabBlade:CreateToggle({
        Name = "Auto-Spam Duel",
        CurrentValue = false,
        Callback = function(v) 
            if Lib.ToggleAutoSpam then Lib.ToggleAutoSpam(v) end 
        end,
    })

    -- [[ 🎭 ONGLET FUN ]] --
    local TabFun = Window:CreateTab("🎭 Fun")
    TabFun:CreateSlider({
        Name = "Taille du personnage",
        Range = {0.1, 10},
        Increment = 0.1,
        CurrentValue = 1,
        Callback = function(Value) 
            if Lib.ChangeSize then Lib.ChangeSize(Value) end 
        end,
    })

    -- [[ 🔓 ONGLET UNLOCKS ]] --
    local TabUnlock = Window:CreateTab("🔓 Unlocks")
    TabUnlock:CreateButton({
        Name = "🚀 Lancer Infinite Yield",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end,
    })

    -- [[ 🛡️ LOGIQUE DE PERSISTANCE & SÉCURITÉ ]] --
    local LP = game:GetService("Players").LocalPlayer
    
    -- Anti-Reset de la vitesse lors du respawn
    LP.CharacterAdded:Connect(function(Character)
        task.wait(1)
        if Lib.SetSpeed then Lib.SetSpeed(Lib.WalkSpeed) end
    end)

    -- Boucle de vérification (évite les nil errors)
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                    local hum = LP.Character.Humanoid
                    if Lib.WalkSpeed and hum.WalkSpeed ~= Lib.WalkSpeed then 
                        hum.WalkSpeed = Lib.WalkSpeed 
                    end
                end
            end)
        end
    end)

    Rayfield:Notify({
        Title = "SYSTÈME CHARGÉ",
        Content = "L'interface est prête !",
        Duration = 3,
        Image = 4483362458,
    })

    return Window
end

return UI