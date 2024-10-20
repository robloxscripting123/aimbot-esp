-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Variables
local aimbotEnabled = false
local espEnabled = false
local espBoxes = {} -- Store ESP boxes

-- GUI Creation
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 100)
MainFrame.Position = UDim2.new(0, 50, 0, 50)
MainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.Visible = true

-- Aimbot Toggle Button
local AimbotButton = Instance.new("TextButton", MainFrame)
AimbotButton.Size = UDim2.new(1, 0, 0, 50)
AimbotButton.Position = UDim2.new(0, 0, 0, 0)
AimbotButton.Text = "Toggle Aimbot"
AimbotButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

-- ESP Toggle Button
local ESPButton = Instance.new("TextButton", MainFrame)
ESPButton.Size = UDim2.new(1, 0, 0, 50)
ESPButton.Position = UDim2.new(0, 0, 0, 50)
ESPButton.Text = "Toggle ESP"
ESPButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)

-- Function to get the closest player to the crosshair
local function getClosestPlayerToCrosshair()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPosition, onScreen = Camera:WorldToScreenPoint(head.Position)

            if onScreen then
                local mousePos = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - mousePos).magnitude
                
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Aimbot Logic
local function aimAtPlayer(player)
    if player and player.Character and player.Character:FindFirstChild("Head") then
        local head = player.Character.Head
        -- This line ensures the camera aims at the head
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
    end
end

-- ESP (Wallhack) Logic
local function createESPBox(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = player.Character.HumanoidRootPart
        local box = Instance.new("BoxHandleAdornment")
        
        -- Box properties
        box.Size = humanoidRootPart.Size + Vector3.new(2, 2, 2)  -- Slightly bigger than the character
        box.Adornee = humanoidRootPart -- Attach to the character's root part
        box.Color3 = Color3.fromRGB(255, 0, 0) -- Set the ESP box color (red in this case)
        box.Transparency = 0.5 -- Set transparency (0 is opaque, 1 is fully transparent)
        box.AlwaysOnTop = true -- Make sure the ESP box is always visible
        box.ZIndex = 0
        box.Parent = humanoidRootPart

        -- Store reference to remove later
        table.insert(espBoxes, box)
    end
end

local function removeESPBoxes()
    for _, box in pairs(espBoxes) do
        box:Destroy()
    end
    espBoxes = {}
end

-- Toggle Aimbot
AimbotButton.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    AimbotButton.Text = aimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)

-- Toggle ESP
ESPButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    ESPButton.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    if espEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESPBox(player)
            end
        end
    else
        removeESPBoxes()
    end
end)

-- Aimbot and ESP updates during the game loop
RunService.RenderStepped:Connect(function()
    -- Aimbot activation when enabled
    if aimbotEnabled then
        local closestPlayer = getClosestPlayerToCrosshair()
        if closestPlayer then
            aimAtPlayer(closestPlayer)
        end
    end
    
    -- Update ESP for new players joining the game
    if espEnabled then
        removeESPBoxes()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                createESPBox(player)
            end
        end
    end
end)
