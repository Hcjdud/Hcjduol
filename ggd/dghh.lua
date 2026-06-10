--[[
    SWILL Delta TP System - Professional Edition
    Draggable toggle button, gray/black theme, compact console
]]

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Улучшенная защита от анти-тп
local function teleport(position)
    for i = 1, 3 do
        pcall(function()
            humanoidRootPart.CFrame = CFrame.new(position)
            wait(0.03)
            humanoidRootPart.Velocity = Vector3.new(0,0,0)
            humanoidRootPart:SetNetworkOwner(player)
            game:GetService("RunService").Heartbeat:Wait()
            if (humanoidRootPart.Position - position).Magnitude > 5 then
                humanoidRootPart.CFrame = CFrame.new(position)
                wait(0.03)
                humanoidRootPart.CFrame = CFrame.new(position)
            end
        end)
        wait(0.05)
    end
end

-- Защита от отката
local lastPosition = humanoidRootPart.Position
game:GetService("RunService").Heartbeat:Connect(function()
    if humanoidRootPart then
        local currentPos = humanoidRootPart.Position
        if (currentPos - lastPosition).Magnitude > 50 then
            wait(0.1)
            if (humanoidRootPart.Position - lastPosition).Magnitude > 50 then
                humanoidRootPart:SetNetworkOwner(player)
            end
        end
        lastPosition = humanoidRootPart.Position
    end
end)

local function teleportToPlayer(targetPlayerName)
    local targetPlayer = nil
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr.Name:lower() == targetPlayerName:lower() or string.sub(plr.Name:lower(), 1, #targetPlayerName) == targetPlayerName:lower() then
            targetPlayer = plr
            break
        end
    end
    
    if not targetPlayer then
        return "Player not found. Online: " .. table.concat(getOnlinePlayers(), ", ")
    end
    
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return "Target has no character"
    end
    
    teleport(targetPlayer.Character.HumanoidRootPart.Position)
    return "Teleported to " .. targetPlayer.Name
end

local function getOnlinePlayers()
    local names = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        table.insert(names, plr.Name)
    end
    return names
end

-- Перетаскиваемая кнопка-кружок
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "DeltaToggleButton"
toggleGui.Parent = player:WaitForChild("PlayerGui")
toggleGui.ResetOnSpawn = false

local toggleButton = Instance.new("ImageButton")
toggleButton.Size = UDim2.new(0, 48, 0, 48)
toggleButton.Position = UDim2.new(0.85, 0, 0.85, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
toggleButton.BackgroundTransparency = 0
toggleButton.BorderSizePixel = 1
toggleButton.BorderColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.Image = "rbxassetid://2669901589"
toggleButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
toggleButton.Parent = toggleGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleButton

-- Перетаскивание кнопки
local dragging = false
local dragStartPos
local dragStartMousePos

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStartPos = toggleButton.Position
        dragStartMousePos = input.Position
    end
end)

toggleButton.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStartMousePos
        local newX = dragStartPos.X.Scale + (delta.X / toggleGui.AbsoluteSize.X)
        local newY = dragStartPos.Y.Scale + (delta.Y / toggleGui.AbsoluteSize.Y)
        toggleButton.Position = UDim2.new(math.clamp(newX, 0, 0.9), 0, math.clamp(newY, 0, 0.85), 0)
    end
end)

toggleButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Основная панель (профессиональная серая тема)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaTPPanel"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.Enabled = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 400)
frame.Position = UDim2.new(0.5, -170, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
frame.BackgroundTransparency = 0
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(50, 50, 55)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local shadow = Instance.new("UICorner")
shadow.CornerRadius = UDim.new(0, 10)
shadow.Parent = frame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 36)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -42, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "DELTA TELEPORT"
titleText.TextColor3 = Color3.fromRGB(210, 210, 215)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 13
titleText.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 38, 1, 0)
closeButton.Position = UDim2.new(1, -38, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
closeButton.BackgroundTransparency = 0
closeButton.Text = "□"
closeButton.TextColor3 = Color3.fromRGB(190, 190, 195)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.Gotham
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
    toggleButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
end)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -36)
scrollFrame.Position = UDim2.new(0, 0, 0, 36)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(55, 55, 60)
scrollFrame.Parent = frame

local scrollList = Instance.new("UIListLayout")
scrollList.Padding = UDim.new(0, 8)
scrollList.SortOrder = Enum.SortOrder.LayoutOrder
scrollList.Parent = scrollFrame

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
padding.Parent = scrollFrame

local function createSection(title)
    local section = Instance.new("TextLabel")
    section.Size = UDim2.new(1, 0, 0, 24)
    section.BackgroundTransparency = 1
    section.Text = "▸ " .. title
    section.TextColor3 = Color3.fromRGB(155, 155, 165)
    section.TextSize = 11
    section.Font = Enum.Font.GothamBold
    section.TextXAlignment = Enum.TextXAlignment.Left
    section.Parent = scrollFrame
    return section
end

local function createButton(text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(48, 48, 53)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(205, 205, 210)
    btn.TextSize = 12
    btn.Font = Enum.Font.Gotham
    btn.Parent = scrollFrame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    return btn
end

local function createInputBox(placeholder)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 42)
    box.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
    box.BorderSizePixel = 1
    box.BorderColor3 = Color3.fromRGB(46, 46, 51)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(210, 210, 215)
    box.TextSize = 12
    box.Font = Enum.Font.Gotham
    box.Parent = scrollFrame
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = box
    return box
end

createSection("PLAYER TP")

local playerInput = createInputBox("Enter player name")
local tpPlayerBtn = createButton("TELEPORT TO PLAYER")
tpPlayerBtn.TextColor3 = Color3.fromRGB(200, 210, 230)

tpPlayerBtn.MouseButton1Click:Connect(function()
    local name = playerInput.Text
    if name == "" then
        tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(55, 40, 40)
        wait(0.2)
        tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
        return
    end
    local result = teleportToPlayer(name)
    print("[DeltaTP] " .. result)
    if result:match("not found") then
        tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(65, 40, 40)
        wait(0.3)
        tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    else
        tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(35, 55, 35)
        wait(0.2)
        tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    end
    playerInput.Text = ""
end)

local playersBtn = createButton("SHOW ONLINE PLAYERS")
playersBtn.MouseButton1Click:Connect(function()
    local players = getOnlinePlayers()
    print("[DeltaTP] Online (" .. #players .. "): " .. table.concat(players, ", "))
    playersBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    wait(0.1)
    playersBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
end)

createSection("COORDINATE TP")

local coordInput = createInputBox("X, Y, Z  (example: 0, 5, 0)")
local tpCoordBtn = createButton("TELEPORT TO COORDINATES")
tpCoordBtn.TextColor3 = Color3.fromRGB(200, 220, 200)

tpCoordBtn.MouseButton1Click:Connect(function()
    local coords = coordInput.Text
    local parts = {}
    for num in coords:gmatch("%-?%d+") do
        table.insert(parts, tonumber(num))
    end
    if #parts >= 3 then
        teleport(Vector3.new(parts[1], parts[2], parts[3]))
        tpCoordBtn.BackgroundColor3 = Color3.fromRGB(35, 60, 35)
        wait(0.2)
        tpCoordBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    else
        tpCoordBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
        wait(0.25)
        tpCoordBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
    end
    coordInput.Text = ""
end)

createSection("INFO")

local posBtn = createButton("CURRENT POSITION")
posBtn.MouseButton1Click:Connect(function()
    local pos = humanoidRootPart.Position
    print(string.format("[DeltaTP] X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z))
    posBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    wait(0.1)
    posBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
end)

local helpBtn = createButton("CONSOLE COMMANDS")
helpBtn.MouseButton1Click:Connect(function()
    print("[DeltaTP] Commands (in chat with /): /to <name>, /tp X Y Z, /players, /pos, /panel, /close")
    helpBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    wait(0.1)
    helpBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 37)
end)

-- Логика переключения панели
local panelVisible = false
toggleButton.MouseButton1Click:Connect(function()
    panelVisible = not panelVisible
    screenGui.Enabled = panelVisible
    toggleButton.ImageColor3 = panelVisible and Color3.fromRGB(140, 140, 150) or Color3.fromRGB(200, 200, 200)
end)

-- Консольные команды (компактные)
local cmds = {
    to = function(a) return #a < 1 and "Usage: /to <name>" or teleportToPlayer(table.concat(a, " ")) end,
    tp = function(a)
        if #a >= 3 then
            local x, y, z = tonumber(a[1]), tonumber(a[2]), tonumber(a[3])
            if x and y and z then teleport(Vector3.new(x, y, z)) return "TP -> " .. x .. ", " .. y .. ", " .. z end
        end
        return "Usage: /tp X Y Z"
    end,
    players = function() local o = getOnlinePlayers() return "Online (" .. #o .. "): " .. table.concat(o, ", ") end,
    pos = function() local p = humanoidRootPart.Position return string.format("X: %.1f Y: %.1f Z: %.1f", p.X, p.Y, p.Z) end,
    panel = function() screenGui.Enabled = true; panelVisible = true; toggleButton.ImageColor3 = Color3.fromRGB(140, 140, 150); return "Panel shown" end,
    close = function() screenGui.Enabled = false; panelVisible = false; toggleButton.ImageColor3 = Color3.fromRGB(200, 200, 200); return "Panel hidden" end,
    help = function() return "Commands: /to, /tp, /players, /pos, /panel, /close" end
}

game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
    if msg:sub(1,1) == "/" then
        local p = {}
        for part in msg:sub(2):gmatch("%S+") do table.insert(p, part) end
        if #p > 0 and cmds[p[1]:lower()] then
            warn("[DeltaTP] " .. cmds[p[1]:lower()]({table.unpack(p, 2)}))
            return
        end
    end
end)

_G.DeltaTP = { tp = teleport, to = teleportToPlayer, list = getOnlinePlayers }

print("[SWILL] Delta TP Professional Loaded")
print("Draggable gray circle button | Clean gray interface | Anti-TP protection")
