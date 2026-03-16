local UI = {}

function UI.Init(Lib)
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "🌐 UNIVERSAL HUB v6.2",
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
        Callback = function(v) Lib.SetSpeed(v) end,
    })

    TabMove:CreateToggle({
        Name = "Activer le Vol (Fly)",
        CurrentValue = false,
        Callback = function(v) Lib.ToggleFly(v) end,
    })

    TabMove:CreateToggle({
        Name = "Noclip (Traverser les murs)",
        CurrentValue = false,
        Callback = function(v) Lib.ToggleNoclip(v) end,
    })

    TabMove:CreateToggle({
        Name = "Saut Infini (Inf Jump)",
        CurrentValue = false,
        Callback = function(v) Lib.InfJump = v end,
    })

    TabMove:CreateSection("Téléportation (Waypoints)")

    TabMove:CreateButton({
        Name = "📍 Poser un Point de TP",
        Callback = function() Lib.SetTPPoint() end,
    })

    TabMove:CreateButton({
        Name = "🌀 Se téléporter au Point",
        Callback = function() Lib.GoToTPPoint() end,
    })

    -- [[ 👁️ ONGLET VISUELS ]] --
    local TabVisual = Window:CreateTab("👁️ Visuels")
    
    TabVisual:CreateButton({
        Name = "Full Bright (Éclairage Max)",
        Callback = function()
            local Lighting = game:GetService("Lighting")
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 999999
            Lighting.GlobalShadows = false
        end,
    })

    -- [[ 🎭 ONGLET FUN & TAILLE ]] --
    local TabFun = Window:CreateTab("🎭 Fun & Taille")

    TabFun:CreateSection("Manipulateur de Taille")

    TabFun:CreateButton({
        Name = "Devenir GÉANT (x3)",
        Callback = function() Lib.ChangeSize(3) end,
    })

    TabFun:CreateButton({
        Name = "Taille Normale (x1)",
        Callback = function() Lib.ChangeSize(1) end,
    })

    TabFun:CreateButton({
        Name = "Devenir MINUSCULE (x0.3)",
        Callback = function() Lib.ChangeSize(0.3) end,
    })

    TabFun:CreateSlider({
        Name = "Taille Personnalisée",
        Range = {0.1, 10},
        Increment = 0.1,
        CurrentValue = 1,
        Callback = function(Value) Lib.ChangeSize(Value) end,
    })

    -- [[ 💞 ONGLET SOCIAL ]] --
    local TabSocial = Window:CreateTab("💞 Social")

    TabSocial:CreateToggle({
        Name = "Regard Auto (Look At Player)",
        CurrentValue = false,
        Callback = function(v) Lib.ToggleLookAt(v) end,
    })

    TabSocial:CreateButton({
        Name = "Activer Chat Spy (Console F9)",
        Callback = function() Lib.ChatSpy() end,
    })

    -- [[ 🔓 ONGLET UNLOCKS ]] --
    local TabUnlock = Window:CreateTab("🔓 Unlocks")

    TabUnlock:CreateSection("Bypass & Exploits")

    TabUnlock:CreateButton({
        Name = "Supprimer Kill/VIP Parts (Bypass)",
        Callback = function() Lib.BypassTouch() end,
    })

    TabUnlock:CreateButton({
        Name = "Tenter Give VIP Tools (Remotes)",
        Callback = function() Lib.GetRemoteTools() end,
    })

    TabUnlock:CreateButton({
        Name = "🚀 Lancer Infinite Yield",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end,
    })

    return Window
end

return UI