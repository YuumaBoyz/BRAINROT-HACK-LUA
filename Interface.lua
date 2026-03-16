local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local UI = {}

function UI.Init(Lib)
    -- Création de la fenêtre principale
    local Window = Fluent:CreateWindow({
        Title = "BRAINROT HUB ✨",
        SubTitle = "by Expert Scripter",
        TabWidth = 160,
        Size = UDim2.fromOffset(580, 460),
        Acrylic = true, 
        Theme = "Dark",
        MinimizeKey = Enum.KeyCode.RightControl 
    })

    -- Création des Onglets
    local Tabs = {
        Main = Window:AddTab({ Title = "Main", Icon = "home" }),
        Combat = Window:AddTab({ Title = "Combat", Icon = "sword" }),
        Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
    }

    -- [[ 🏠 ONGLET PRINCIPAL : COLLECTE & VOL ]] --
    
    Tabs.Main:AddParagraph({
        Title = "Mouvement & Collecte",
        Content = "Gère ton vol et le vol automatique des Brainrots."
    })

    -- Toggle pour le FLY
    local FlyToggle = Tabs.Main:AddToggle("FlyToggle", {Title = "Enable Fly", Default = false })
    FlyToggle:OnChanged(function()
        Lib.Flying = FlyToggle.Value
        Lib.ToggleFly(Lib.Flying)
    end)

    -- Slider pour la vitesse de vol
    Tabs.Main:AddSlider("FlySpeed", {
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
    end)

    Tabs.Main:AddDivider()

    -- BOUTON GIVE ALL ITEMS 🎁
    Tabs.Main:AddButton({
        Title = "Give All Items",
        Description = "Tente de récupérer tous les outils du stockage",
        Callback = function()
            Lib.GiveAllItems()
            Fluent:Notify({
                Title = "Inventaire",
                Content = "Tentative de récupération terminée !",
                Duration = 3
            })
        end
    })

    Tabs.Main:AddDivider()

    -- [[ 🔒 SÉCURITÉ DE LA BASE ]] --
    
    Tabs.Main:AddParagraph({
        Title = "Sécurité",
        Content = "Protège ta base des intrus de façon permanente."
    })

    local BarrierToggle = Tabs.Main:AddToggle("BarrierToggle", {
        Title = "Permanent Red Barrier 🔒", 
        Default = false 
    })

    BarrierToggle:OnChanged(function()
        Lib.PermanentBarrier = BarrierToggle.Value
        if Lib.PermanentBarrier then
            Lib.LockMyBarrier()
            Fluent:Notify({
                Title = "Base Security",
                Content = "Barrière verrouillée en mode permanent !",
                Duration = 3
            })
        end
    end)

    -- [[ ⚔️ ONGLET COMBAT : KILL AURA ]] --

    Tabs.Combat:AddParagraph({
        Title = "Combat System",
        Content = "Active la Fling Aura pour éjecter les joueurs."
    })

    local KillToggle = Tabs.Combat:AddToggle("KillToggle", {Title = "Fling Aura (Kill)", Default = false })
    KillToggle:OnChanged(function()
        Lib.KillAura = KillToggle.Value
    end)

    Tabs.Combat:AddSlider("KillRadius", {
        Title = "Kill Range",
        Description = "Distance de détection des cibles",
        Default = 25,
        Min = 5,
        Max = 100,
        Rounding = 1,
        Callback = function(Value)
            Lib.KillRange = Value
        end
    })

    -- [[ ⚙️ ONGLET PARAMÈTRES ]] --
    
    Tabs.Settings:AddButton({
        Title = "Destroy UI",
        Description = "Ferme proprement le menu",
        Callback = function()
            Window:Destroy()
        end
    })

    -- Notification de lancement
    Fluent:Notify({
        Title = "Brainrot Hub",
        Content = "Interface Fluent chargée avec succès ! (R-CTRL pour cacher)",
        Duration = 5
    })

    return Window, FlyToggle, StealToggle, KillToggle
end

return UI