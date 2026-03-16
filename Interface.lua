local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local UI = {}

function UI.Init(Lib)
    -- Création de la fenêtre principale
    local Window = Fluent:CreateWindow({
        Title = "BRAINROT HUB ✨",
        SubTitle = "by Expert Scripter",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true, -- Effet de flou derrière le menu
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightControl -- Touche pour cacher le menu
    })

    -- Création des Onglets
    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "home" }),
        Combat = Window:AddTab({ Title = "Combat", Icon = "sword" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    -- [[ ONGLET PRINCIPAL : COLLECTE & VOL ]] --
    
    -- Toggle pour le FLY
    local FlyToggle = Tabs.Main:AddToggle("FlyToggle", {Title = "Enable Fly", Default = false })
    FlyToggle:OnChanged(function()
        Lib.Flying = FlyToggle.Value
        Lib.ToggleFly(Lib.Flying)
    end)

    -- Slider pour la vitesse de vol
    local FlySlider = Tabs.Main:AddSlider("FlySpeed", {
        Title = "Fly Speed",
        Description = "Ajuste la vitesse de vol",
        Default = 50,
        Min = 10,
        Max = 300,
        Rounding = 1,
        Callback = function(Value)
            Lib.FlySpeed = Value
        end
    })

    -- Toggle pour l'AUTO-STEAL
    local StealToggle = Tabs.Main:AddToggle("StealToggle", {Title = "Auto-Steal Brainrots", Default = false })
    StealToggle:OnChanged(function()
        Lib.AutoSteal = StealToggle.Value
        -- La boucle est gérée dans le Main.lua
    end)

    -- [[ ONGLET COMBAT : KILL AURA ]] --

    local KillToggle = Tabs.Combat:AddToggle("KillToggle", {Title = "Kill Aura", Default = false })
    KillToggle:OnChanged(function()
        Lib.KillAura = KillToggle.Value
    end)

    local KillRadius = Tabs.Combat:AddSlider("KillRadius", {
        Title = "Kill Range",
        Description = "Distance de frappe",
        Default = 20,
        Min = 5,
        Max = 100,
        Rounding = 1,
        Callback = function(Value)
            Lib.KillRange = Value
        end
    })

    -- Notification de lancement
    Fluent:Notify({
        Title = "Brainrot Hub",
        Content = "Interface Fluent chargée avec succès !",
        Duration = 5
    })

    return Window, FlyToggle, StealToggle, KillToggle
end

return UI