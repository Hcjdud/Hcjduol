--[[
    SWILL Delta TP System - Optimized Mobile Version
    Toggle button, improved anti-teleport, compact design
]]

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Улучшенная защита от анти-тп
local function teleport(position)
    for i = 1, 3 do
        local success, err = pcall(function()
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

-- Защита от отката (если игра телепортирует обратно)
game:GetService("RunService").Stepped:Connect(function()
    if humanoidRootPart and humanoidRootPart.Parent then
        humanoidRootPart:SetNetworkOwner(player)
    end
end)

-- Дополнительная защита: отслеживание принудительных телепортов сервером
local lastPosition = humanoidRootPart.Position
local antiRollback = true
game:GetService("RunService").Heartbeat:Connect(function()
    if antiRollback and humanoidRootPart then
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
        return "Игрок не найден. Онлайн: " .. table.concat(getOnlinePlayers(), ", ")
    end
    
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return "У игрока нет персонажа"
    end
    
    local targetPos = targetPlayer.Character.HumanoidRootPart.Position
    teleport(targetPos)
    return "Телепорт к " .. targetPlayer.Name
end

local function getOnlinePlayers()
    local names = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        table.insert(names, plr.Name)
    end
    return names
end

-- Создание кнопки-кружка для открытия/закрытия панели
local toggleGui = Instance.new("ScreenGui")
toggleGui.Name = "DeltaToggleButton"
toggleGui.Parent = player:WaitForChild("PlayerGui")
toggleGui.ResetOnSpawn = false

local toggleButton = Instance.new("ImageButton")
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0.85, 0, 0.85, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.BackgroundTransparency = 0
toggleButton.BorderSizePixel = 0
toggleButton.Image = "rbxassetid://2669901589" -- Белый круг
toggleButton.Parent = toggleGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleButton

local shadow = Instance.new("UIShadow")
shadow.Parent = toggleButton

-- Основная панель (изначально скрыта)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaTPPanel"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false
screenGui.Enabled = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 420)
frame.Position = UDim2.new(0.5, -160, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(45, 45, 45)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -40, 1, 0)
titleText.Position = UDim2.new(0, 10, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Delta Teleport"
titleText.TextColor3 = Color3.fromRGB(230, 230, 230)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 35, 1, 0)
closeButton.Position = UDim2.new(1, -35, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
closeButton.BackgroundTransparency = 0
closeButton.Text = "□"
closeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -35)
scrollFrame.Position = UDim2.new(0, 0, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
scrollFrame.Parent = frame

local scrollList = Instance.new("UIListLayout")
scrollList.Padding = UDim.new(0, 6)
scrollList.SortOrder = Enum.SortOrder.LayoutOrder
scrollList.Parent = scrollFrame

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 8)
padding.PaddingRight = UDim.new(0, 8)
padding.PaddingTop = UDim.new(0, 8)
padding.PaddingBottom = UDim.new(0, 8)
padding.Parent = scrollFrame

local function createSection(title)
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Size = UDim2.new(1, 0, 0, 22)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = title
    sectionLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
    sectionLabel.TextSize = 11
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = scrollFrame
    return sectionLabel
end

local function createButton(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 45)
    btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 35)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(52, 52, 52)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.TextSize = 13
    btn.Font = Enum.Font.Gotham
    btn.Parent = scrollFrame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    return btn
end

local function createInputBox(placeholder)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 45)
    box.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    box.BorderSizePixel = 1
    box.BorderColor3 = Color3.fromRGB(50, 50, 50)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(230, 230, 230)
    box.TextSize = 13
    box.Font = Enum.Font.Gotham
    box.Parent = scrollFrame
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 6)
    boxCorner.Parent = box
    return box
end

createSection("> ТЕЛЕПОРТ К ИГРОКУ")

local playerInput = createInputBox("Введите ник игрока")
playerInput.Text = ""

local tpPlayerBtn = createButton("ТЕЛЕПОРТ К ИГРОКУ", Color3.fromRGB(45, 45, 60))
tpPlayerBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
tpPlayerBtn.TextSize = 14

tpPlayerBtn.MouseButton1Click:Connect(function()
    local targetName = playerInput.Text
    if targetName == "" then
        tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(75, 45, 45)
        wait(0.2)
        tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        return
    end
    local result = teleportToPlayer(targetName)
    print("[DeltaTP] " .. result)
    if result:match("не найден") then
        tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(85, 40, 40)
        wait(0.3)
        tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    else
        tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(40, 75, 40)
        wait(0.2)
        tpPlayerBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    end
    playerInput.Text = ""
end)

local playersListBtn = createButton("ПОКАЗАТЬ ОНЛАЙН ИГРОКОВ", Color3.fromRGB(35, 35, 35))
playersListBtn.MouseButton1Click:Connect(function()
    local players = getOnlinePlayers()
    local msg = "Онлайн (" .. #players .. "): " .. table.concat(players, ", ")
    print("[DeltaTP] " .. msg)
    playersListBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    wait(0.1)
    playersListBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
end)

createSection("> ТЕЛЕПОРТ ПО КООРДИНАТАМ")

local coordInput = createInputBox("X, Y, Z  пример: 0, 5, 0")
coordInput.Text = ""

local tpCoordBtn = createButton("ТЕЛЕПОРТ ПО КООРДИНАТАМ", Color3.fromRGB(45, 60, 45))
tpCoordBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
tpCoordBtn.TextSize = 14

tpCoordBtn.MouseButton1Click:Connect(function()
    local coords = coordInput.Text
    local parts = {}
    for num in coords:gmatch("%-?%d+") do
        table.insert(parts, tonumber(num))
    end
    if #parts >= 3 then
        teleport(Vector3.new(parts[1], parts[2], parts[3]))
        tpCoordBtn.BackgroundColor3 = Color3.fromRGB(40, 85, 40)
        wait(0.2)
        tpCoordBtn.BackgroundColor3 = Color3.fromRGB(45, 60, 45)
    else
        tpCoordBtn.BackgroundColor3 = Color3.fromRGB(75, 45, 45)
        wait(0.25)
        tpCoordBtn.BackgroundColor3 = Color3.fromRGB(45, 60, 45)
    end
    coordInput.Text = ""
end)

createSection("> ИНФОРМАЦИЯ")

local getPosBtn = createButton("ТЕКУЩАЯ ПОЗИЦИЯ", Color3.fromRGB(35, 35, 35))
getPosBtn.MouseButton1Click:Connect(function()
    local pos = humanoidRootPart.Position
    print(string.format("[DeltaTP] X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z))
    getPosBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    wait(0.1)
    getPosBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
end)

local helpBtn = createButton("КОМАНДЫ КОНСОЛИ", Color3.fromRGB(35, 35, 35))
helpBtn.MouseButton1Click:Connect(function()
    print("[DeltaTP] Команды (в чат с /): /to <ник>, /tp X Y Z, /players, /pos, /panel, /close")
    helpBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    wait(0.1)
    helpBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
end)

-- Логика кнопки-кружка
local panelVisible = false
toggleButton.MouseButton1Click:Connect(function()
    panelVisible = not panelVisible
    screenGui.Enabled = panelVisible
    if panelVisible then
        toggleButton.ImageColor3 = Color3.fromRGB(200, 200, 200)
    else
        toggleButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

local consoleCommands = {
    to = function(args)
        if #args < 1 then return "Использование: /to <ник>" end
        return teleportToPlayer(table.concat(args, " "))
    end,
    tp = function(args)
        if #args >= 3 then
            local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
            if x and y and z then
                teleport(Vector3.new(x, y, z))
                return "Телепорт на " .. x .. ", " .. y .. ", " .. z
            end
        end
        return "Использование: /tp X Y Z"
    end,
    players = function() local o = getOnlinePlayers() return "Онлайн (" .. #o .. "): " .. table.concat(o, ", ") end,
    pos = function() local p = humanoidRootPart.Position return string.format("X: %.1f, Y: %.1f, Z: %.1f", p.X, p.Y, p.Z) end,
    help = function() return "Команды: /to <ник>, /tp X Y Z, /players, /pos, /panel, /close" end,
    panel = function() screenGui.Enabled = true; panelVisible = true; return "Панель показана" end,
    close = function() screenGui.Enabled = false; panelVisible = false; return "Панель скрыта" end
}

game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
    if msg:sub(1,1) == "/" then
        local parts = {}
        for part in msg:sub(2):gmatch("%S+") do table.insert(parts, part) end
        if #parts > 0 and consoleCommands[parts[1]:lower()] then
            local result = consoleCommands[parts[1]:lower()]({table.unpack(parts, 2)})
            warn("[DeltaTP] " .. result)
            return
        end
    end
end)

_G.DeltaTP = { teleport = teleport, toPlayer = teleportToPlayer, getPlayers = getOnlinePlayers }

print("[SWILL] Delta TP v3 загружен")
print("Белая кнопка-кружок для открытия панели")
print("Улучшенная защита от анти-тп и отката")
