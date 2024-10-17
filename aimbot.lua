-- Get services
local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local players = game:GetService("Players")

-- Create GUI
local screenGui = Instance.new("ScreenGui")
local toggleButton = Instance.new("TextButton")

-- Set up GUI properties
screenGui.Parent = player.PlayerGui
toggleButton.Size = UDim2.new(0, 200, 0, 50)
toggleButton.Position = UDim2.new(0.5, -100, 0, 20)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
toggleButton.Text = "Toggle Aimbot"
toggleButton.Parent = screenGui

local aimbotEnabled = false -- Aimbot toggle
local closestPlayer = nil -- Variable to store the closest player

-- Function to get the closest player to the local player
local function getClosestPlayer()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    local closestDistance = math.huge -- Start with a very large distance
    closestPlayer = nil -- Reset closest player

    -- Iterate through all players
    for _, otherPlayer in pairs(players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
            local otherHumanoidRootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherHumanoidRootPart then
                -- Calculate the distance between the local player and the other player
                local distance = (otherHumanoidRootPart.Position - humanoidRootPart.Position).magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = otherPlayer
                end
            end
        end
    end
end

-- Function to snap aim instantly to the closest player's head
local function aimAtClosestPlayer()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    -- If we found a valid closest player
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("Head") then
        local targetHead = closestPlayer.Character.Head
        local targetPosition = targetHead.Position
        local playerPosition = humanoidRootPart.Position

        -- Snap the player's HumanoidRootPart instantly towards the target's head
        humanoidRootPart.CFrame = CFrame.new(playerPosition, targetPosition)
    end
end

-- Function to toggle the aimbot on button click
toggleButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        toggleButton.Text = "Aimbot: ON"
    else
        toggleButton.Text = "Aimbot: OFF"
    end
end)

-- Continuously check for the closest player and aim if aimbot is enabled
runService.RenderStepped:Connect(function()
    getClosestPlayer() -- Update closest player every frame
    if aimbotEnabled then
        aimAtClosestPlayer() -- Aim if aimbot is active
    end
end)

-- ESP Functionality
local function createESP(player)
    local highlight = Instance.new("Highlight") -- Create a Highlight object
    highlight.Adornee = player.Character -- Attach it to the player's character
    highlight.FillColor = Color3.new(1, 0, 0) -- Set fill color to red
    highlight.OutlineColor = Color3.new(1, 1, 1) -- Set outline color to white
    highlight.FillTransparency = 0.5 -- Set transparency
    highlight.Parent = player.Character -- Parent to the character
end

-- Create ESP for all players in the game
for _, otherPlayer in pairs(players:GetPlayers()) do
    if otherPlayer ~= player and otherPlayer.Character then
        createESP(otherPlayer)
    end
end

-- Update ESP whenever players join or leave
players.PlayerAdded:Connect(function(newPlayer)
    newPlayer.CharacterAdded:Connect(function()
        createESP(newPlayer)
    end)
end)

players.PlayerRemoving:Connect(function(leavingPlayer)
    if leavingPlayer.Character then
        local highlight = leavingPlayer.Character:FindFirstChildOfClass("Highlight")
        if highlight then
            highlight:Destroy() -- Remove highlight on player leaving
        end
    end
end)
