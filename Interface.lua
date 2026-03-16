local UI = {}

function UI.Init(Lib)
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "🌐 UNIVERSAL HUB v1",
        LoadingTitle = "Initialisation...",
        LoadingSubtitle = "par YuumaBoyz",
    })

    -- Onglet Mouvement
    local TabMove = Window:CreateTab("🏃 Mouvement")
    
    TabMove:CreateSlider({
        Name = "Vitesse (Speed)",
        Range = {16, 300},
        Increment = 1,
        CurrentValue = 16,
        Callback = function(Value) Lib.SetSpeed(Value) end,
    })

    TabMove:CreateToggle({
        Name = "Activer le Vol (Fly)",
        CurrentValue = false,
        Callback = function(Value) Lib.ToggleFly(Value) end,
    })

    -- Onglet Visuels
    local TabVisual = Window:CreateTab("👁️ Visuels")
    
    TabVisual:CreateButton({
        Name = "Full Bright (Voir dans le noir)",
        Callback = function()
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").GlobalShadows = false
        end,
    })

    return Window
end

return UI