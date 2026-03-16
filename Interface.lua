local UI = {}

function UI.Init(Lib)
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

    TabMove:CreateSection("Téléportation (Waypoints Stealth)")

    TabMove:CreateButton({
        Name = "📍 Poser un Point de TP",
        Callback = function() Lib.SetTPPoint() end,
    })

    TabMove:CreateButton({
        Name = "🌀 Se téléporter au Point (Indétectable)",
        Callback = function() Lib.GoToTPPoint() end,
    })

    -- [[ 🕵️ ONGLET MURDER MYSTERY 2 ]] --
    local TabMM2 = Window:CreateTab("🕵️ Murder Mystery 2")
    TabMM2:CreateSection("Avantages de Rôle")

    TabMM2:CreateToggle({
        Name = "Role ESP (Vision à travers murs)",
        CurrentValue = false,
        Callback = function(v) 
            if Lib and Lib.ToggleRoleESP then
                Lib.ToggleRoleESP(v)
            else
                warn("⚠️ Lib.ToggleRoleESP n'est pas prêt !")
            end
        end,
    })

    TabMM2:CreateToggle({
        Name = "Silent Aim (Shoot/Throw Bot)",
        CurrentValue = false,
        Callback = function(v) 
            -- Sécurité anti-nil pour éviter le Callback Error
            if Lib and Lib.ToggleSilentAim then
                Lib.ToggleSilentAim(v) 
            else
                warn("⚠️ Lib.ToggleSilentAim n'est pas encore chargé !")
            end
        end,
    })

    TabMM2:CreateSection("Utilitaires")

    TabMM2:CreateButton({
        Name = "🔫 Auto-Grab Gun (TP au pistolet)",
        Callback = function() 
            -- On appelle la fonction de la Lib au lieu de faire le code ici
            if Lib and Lib.AutoGrabGun then
                Lib.AutoGrabGun()
            else
                -- Secours si la Lib bug
                Rayfield:Notify({Title = "Erreur", Content = "Fonction non chargée", Duration = 2})
            end
        end,
    })

    -- [[ ⚔️ ONGLET BLADE BALL ]] --
    local TabBlade = Window:CreateTab("⚔️ Blade Ball")
    TabBlade:CreateSection("Combat & Sniper")

    TabBlade:CreateKeybind({
        Name = "Touche d'Interception (Parry)",
        CurrentKeybind = "F",
        HoldToInteract = false,
        Flag = "ParryKeybind",
        Callback = function(Keybind)
            -- Sécurité : On vérifie que Keybind n'est pas vide
            if Keybind and Keybind ~= "" then
                -- On protège l'appel pour éviter le crash si la touche est spéciale
                pcall(function()
                    Lib.ParryKey = Enum.KeyCode[Keybind]
                    print("⌨️ Nouvelle touche Parry : " .. Keybind)
                end)
            end
        end,
    })

    TabBlade:CreateToggle({
        Name = "Auto-Spam Duel (Proximité)",
        CurrentValue = false,
        Callback = function(v) Lib.ToggleAutoSpam(v) end,
    })

    TabBlade:CreateParagraph({
        Title = "🚀 Info Technique", 
        Content = "Le Remote Sniper force le serveur à parer la balle, peu importe la distance, si elle est dirigée vers toi."
    })

    TabBlade:CreateSection("Debug")

    TabBlade:CreateButton({
        Name = "🔍 Vérifier la Balle (Console)",
        Callback = function()
            local ball = workspace:FindFirstChild("Ball") or workspace:FindFirstChild("Balls")
            if ball then print("✅ Balle détectée !") else print("❌ Balle introuvable.") end
        end,
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
    TabFun:CreateSection("Manipulateur de Corps")

    TabFun:CreateButton({
        Name = "Devenir GÉANT (x3)",
        Callback = function() Lib.ChangeSize(3) end,
    })

    TabFun:CreateButton({
        Name = "Devenir MINUSCULE (x0.3)",
        Callback = function() Lib.ChangeSize(0.3) end,
    })

    TabFun:CreateSlider({
        Name = "Taille Précise",
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
        Name = "🛡️ Supprimer Zones Kill/VIP",
        Callback = function() Lib.BypassTouch() end,
    })

    TabUnlock:CreateButton({
        Name = "🎁 Tenter Give Items (Remotes)",
        Callback = function() Lib.GetRemoteTools() end,
    })

    TabUnlock:CreateButton({
        Name = "🚀 Lancer Infinite Yield",
        Callback = function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end,
    })

    -- [[ 🛡️ LOGIQUE DE PERSISTANCE & ANTI-RESET ]] --
    local LP = game:GetService("Players").LocalPlayer
    
    LP.CharacterAdded:Connect(function(Character)
        local Humanoid = Character:WaitForChild("Humanoid", 5)
        if Humanoid then
            task.wait(1)
            Lib.SetSpeed(Lib.WalkSpeed)
        end
    end)

    task.spawn(function()
        while task.wait(2) do
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                local hum = LP.Character.Humanoid
                if hum.WalkSpeed ~= Lib.WalkSpeed then hum.WalkSpeed = Lib.WalkSpeed end
            end
        end
    end)

    return Window
end

return UI