local UI = {}

function UI.Init(Lib)
    -- 1. Chargement de Rayfield
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
            if Lib and Lib.SetSpeed then Lib.SetSpeed(v) end 
        end,
    })

    TabMove:CreateSlider({
        Name = "Puissance de saut",
        Range = {50, 500},
        Increment = 1,
        CurrentValue = 50,
        Callback = function(v) 
            if Lib and Lib.SetJump then Lib.SetJump(v) end 
        end,
    })

    TabMove:CreateToggle({
        Name = "Activer le Vol (Fly)",
        CurrentValue = false,
        Callback = function(v) 
            if Lib and Lib.ToggleFly then Lib.ToggleFly(v) end 
        end,
    })

    TabMove:CreateToggle({
        Name = "Noclip (Murs)",
        CurrentValue = false,
        Callback = function(v) 
            if Lib and Lib.ToggleNoclip then Lib.ToggleNoclip(v) end 
        end,
    })

    TabMove:CreateToggle({
        Name = "Saut Infini",
        CurrentValue = false,
        Callback = function(v) 
            if Lib then Lib.InfJump = v end
        end,
    })

    TabMove:CreateSection("Téléportation")

    TabMove:CreateButton({
        Name = "📍 Poser un Point de TP",
        Callback = function() 
            if Lib and Lib.SetTPPoint then Lib.SetTPPoint() end 
        end,
    })

    TabMove:CreateButton({
        Name = "🌀 Se téléporter au Point",
        Callback = function() 
            if Lib and Lib.GoToTPPoint then Lib.GoToTPPoint() end 
        end,
    })

    -- [[ 🕵️ ONGLET MURDER MYSTERY 2 ]] --
    local TabMM2 = Window:CreateTab("🕵️ MM2")
    TabMM2:CreateSection("Avantages")

    TabMM2:CreateToggle({
        Name = "Role ESP",
        CurrentValue = false,
        Callback = function(v) 
            if Lib and Lib.ToggleRoleESP then Lib.ToggleRoleESP(v) end
        end,
    })

    TabMM2:CreateToggle({
        Name = "Silent Aim",
        CurrentValue = false,
        Callback = function(v) 
            if Lib then Lib.SilentAim = v end
        end,
    })

    -- [[ ⚔️ BLADE BALL ]] --
    local TabBlade = Window:CreateTab("⚔️ Blade Ball")
    
    TabBlade:CreateSection("Contrôles de Parade")

    TabBlade:CreateKeybind({
        Name = "Touche Parry",
        CurrentKeybind = "F",
        HoldToInteract = false,
        Flag = "ParryKeybind",
        Callback = function(Keybind)
            if Lib then 
                Lib.ParryKey = Keybind 
            end
        end,
    })

    TabBlade:CreateToggle({
        Name = "Auto-Spam Duel",
        CurrentValue = false,
        Callback = function(v) 
            if Lib then Lib.AutoSpam = v end 
        end,
    })

    TabBlade:CreateSection("🔥 Module d'Accélération (Rage)")

    TabBlade:CreateToggle({
        Name = "Activer le Ball Boost",
        CurrentValue = false,
        Callback = function(v) 
            if Lib then Lib.BallBoost = v end 
        end,
    })

    TabBlade:CreateSlider({
        Name = "Puissance du Boost",
        Range = {1, 5},
        Increment = 0.1,
        CurrentValue = 1.5,
        Callback = function(v) 
            if Lib then Lib.BoostMultiplier = v end 
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

    Rayfield:Notify({
        Title = "SYSTÈME CHARGÉ",
        Content = "L'interface est prête !",
        Duration = 3,
        Image = 4483362458,
    })

    return Window
end

return UI