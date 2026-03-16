local Main = {}

function Main.Start(Lib)
    local LP = game:GetService("Players").LocalPlayer
    
    -- Boucle pour ré-appliquer les paramètres après une mort
    task.spawn(function()
        while task.wait(2) do
            if LP.Character and LP.Character:FindFirstChild("Humanoid") then
                local hum = LP.Character.Humanoid
                if hum.WalkSpeed ~= Lib.WalkSpeed then
                    hum.WalkSpeed = Lib.WalkSpeed
                end
            end
        end
    end)
end

return Main