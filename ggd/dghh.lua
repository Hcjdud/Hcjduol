--[[
    SWILL Delta TP System - Мобильная версия
    Большие кнопки, серо-чёрная тема, русский язык
]]

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local function teleport(position)
    local success, err = pcall(function()
        humanoidRootPart.CFrame = CFrame.new(position)
        wait(0.05)
        humanoidRootPart.Velocity = Vector3.new(0,0,0)
        humanoidRootPart:SetNetworkOwner(player)
        game:GetService("RunService").Heartbeat:Wait()
        humanoidRootPart.CFrame = CFrame.new(position)
    end)
    if not success then
        humanoidRootPart.CFrame = CFrame.new(position)
        wait()
        humanoidRootPart.CFrame = CFrame.new(position)
    end
end

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

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaTPPanel"
screenGui.Parent = player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 520)
frame.Position = UDim2.new(0.5, -190, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = frame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 45)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -50, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "Delta Teleport System"
titleText.TextColor3 = Color3.fromRGB(230, 230, 230)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 16
titleText.Parent = titleBar

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 44, 1, 0)
closeButton.Position = UDim2.new(1, -44, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
closeButton.BackgroundTransparency = 0.5
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeButton

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -45)
scrollFrame.Position = UDim2.new(0, 0, 0, 45)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 5
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(55, 55, 55)
scrollFrame.Parent = frame

local scrollList = Instance.new("UIListLayout")
scrollList.Padding = UDim.new(0, 10)
scrollList.SortOrder = Enum.SortOrder.LayoutOrder
scrollList.Parent = scrollFrame

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
padding.Parent = scrollFrame

local function createSection(title)
    local sectionLabel = Instance.new("TextLabel")
    sectionLabel.Size = UDim2.new(1, 0, 0, 28)
    sectionLabel.BackgroundTransparency = 1
    sectionLabel.Text = title
    sectionLabel.TextColor3 = Color3.fromRGB(170, 170, 170)
    sectionLabel.TextSize = 13
    sectionLabel.Font = Enum.Font.GothamBold
    sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel.Parent = scrollFrame
    return sectionLabel
end

local function createButton(text, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 60)
    btn.BackgroundColor3 = color or Color3.fromRGB(33, 33, 33)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(52, 52, 52)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(230, 230, 230)
    btn.TextSize = 15
    btn.Font = Enum.Font.Gotham
    btn.Parent = scrollFrame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    return btn
end

local function createInputBox(placeholder)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, 0, 0, 55)
    box.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    box.BorderSizePixel = 1
    box.BorderColor3 = Color3.fromRGB(48, 48, 48)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.TextColor3 = Color3.fromRGB(230, 230, 230)
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.Parent = scrollFrame
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 8)
    boxCorner.Parent = box
    return box
end

createSection("> ТЕЛЕПОРТ К ИГРОКУ")

local playerInput = createInputBox("Введите ник игрока")
playerInput.Text = ""

local tpPlayerBtn = createButton("ТЕЛЕПОРТ К ИГРОКУ", Color3.fromRGB(45, 45, 60))
tpPlayerBtn.TextColor3 = Color3.fromRGB(255, 200, 200)
tpPlayerBtn.TextSize = 16

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

local playersListBtn = createButton("ПОКАЗАТЬ ОНЛАЙН ИГРОКОВ", Color3.fromRGB(33, 33, 33))
playersListBtn.MouseButton1Click:Connect(function()
    local players = getOnlinePlayers()
    local msg = "Онлайн (" .. #players .. "): " .. table.concat(players, ", ")
    print("[DeltaTP] " .. msg)
    playersListBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    wait(0.15)
    playersListBtn.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
end)

createSection("> ТЕЛЕПОРТ ПО КООРДИНАТАМ")

local coordInput = createInputBox("Введите координаты (X, Y, Z)  пример: 0, 5, 0")
coordInput.Text = ""

local tpCoordBtn = createButton("ТЕЛЕПОРТ ПО КООРДИНАТАМ", Color3.fromRGB(45, 60, 45))
tpCoordBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
tpCoordBtn.TextSize = 16

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

local getPosBtn = createButton("ПОКАЗАТЬ ТЕКУЩУЮ ПОЗИЦИЮ", Color3.fromRGB(33, 33, 33))
getPosBtn.MouseButton1Click:Connect(function()
    local pos = humanoidRootPart.Position
    print(string.format("[DeltaTP] Позиция - X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z))
    getPosBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    wait(0.15)
    getPosBtn.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
end)

local helpBtn = createButton("КОМАНДЫ КОНСОЛИ", Color3.fromRGB(33, 33, 33))
helpBtn.MouseButton1Click:Connect(function()
    print("[DeltaTP] Консольные команды (вводить в чат с /):")
    print("  /to <ник>   - телепорт к игроку")
    print("  /tp X Y Z   - телепорт по координатам")
    print("  /players    - список игроков онлайн")
    print("  /pos        - текущая позиция")
    print("  /panel      - показать панель")
    print("  /close      - скрыть панель")
    helpBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    wait(0.15)
    helpBtn.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
end)

game:GetService("RunService").Stepped:Connect(function()
    if humanoidRootPart and humanoidRootPart.Parent then
        humanoidRootPart:SetNetworkOwner(player)
    end
end)

local consoleCommands = {
    to = function(args)
        if #args < 1 then
            return "Использование: /to <ник_игрока>"
        end
        local targetName = table.concat(args, " ")
        return teleportToPlayer(targetName)
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
    players = function()
        local online = getOnlinePlayers()
        return "Онлайн (" .. #online .. "): " .. table.concat(online, ", ")
    end,
    pos = function()
        local pos = humanoidRootPart.Position
        return string.format("X: %.1f, Y: %.1f, Z: %.1f", pos.X, pos.Y, pos.Z)
    end,
    help = function()
        return "Команды: /to <ник>, /tp X Y Z, /players, /pos, /panel, /close"
    end,
    panel = function()
        if screenGui.Parent == nil then
            screenGui.Parent = player:WaitForChild("PlayerGui")
            return "Панель показана"
        end
        return "Панель уже видна"
    end,
    close = function()
        screenGui:Destroy()
        return "Панель скрыта"
    end
}

game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
    if msg:sub(1,1) == "/" then
        local cmdLine = msg:sub(2)
        local parts = {}
        for part in cmdLine:gmatch("%S+") do
            table.insert(parts, part)
        end
        if #parts > 0 then
            local cmd = parts[1]:lower()
            local args = {table.unpack(parts, 2)}
            if consoleCommands[cmd] then
                local result = consoleCommands[cmd](args)
                warn("[DeltaTP] " .. result)
                return
            end
        end
    end
end)

_G.DeltaTP = {
    teleport = teleport,
    toPlayer = teleportToPlayer,
    getPlayers = getOnlinePlayers,
    showPanel = function() screenGui.Parent = player:WaitForChild("PlayerGui") end,
    hidePanel = function() screenGui:Destroy() end
}

print("[SWILL] Delta TP System - Мобильная версия загружена")
print("Большие кнопки для удобства на телефоне")
print("Консоль: /to <ник>, /tp X Y Z, /players, /pos, /panel, /close")
