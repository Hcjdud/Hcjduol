--[[
    SWILL Delta TP System - Powerful TP with Noclip & Console Commands
    Commands: /tp <name> | /tome <name> | /forward <distance>
]]

local player = game.Players.LocalPlayer
if not player then
    game.Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = game.Players.LocalPlayer
end

local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Noclip function for passing through walls
local noclipEnabled = false
local function setNoclip(state)
    noclipEnabled = state
    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not state
            end
        end
    end
end

-- Enable noclip temporarily
local function temporaryNoclip(duration)
    setNoclip(true)
    task.wait(duration)
    setNoclip(false)
end

-- УЛЬТРА МОЩНЫЙ ТЕЛЕПОРТ (обходит любую защиту)
local function teleport(position)
    if not humanoidRootPart or not humanoidRootPart.Parent then return end
    
    -- Отключаем коллизию на время телепорта
    setNoclip(true)
    
    for i = 1, 5 do
        pcall(function()
            humanoidRootPart.CFrame = CFrame.new(position)
            task.wait(0.02)
            humanoidRootPart.Velocity = Vector3.new(0,0,0)
            humanoidRootPart:SetNetworkOwner(player)
            task.wait(0.02)
            
            -- Принудительная синхронизация
            if humanoidRootPart and (humanoidRootPart.Position - position).Magnitude > 5 then
                humanoidRootPart.CFrame = CFrame.new(position)
            end
            
            -- Обновление всех частей персонажа
            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") and part ~= humanoidRootPart then
                    part.CFrame = CFrame.new(position + Vector3.new(0, 1, 0))
                end
            end
        end)
        task.wait(0.03)
    end
    
    task.wait(0.1)
    setNoclip(false)
end

-- Телепорт к игроку + noclip
local function teleportToPlayer(targetPlayer)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return false, "Игрок не имеет персонажа"
    end
    
    local targetPos = targetPlayer.Character.HumanoidRootPart.Position
    teleport(targetPos)
    return true, "Телепорт к " .. targetPlayer.Name
end

-- Телепорт ко мне (to me) - телепортирует игрока немного вперёд от меня
local function teleportToMe(targetPlayer)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return false, "Игрок не имеет персонажа"
    end
    
    if not humanoidRootPart then
        return false, "У вас нет персонажа"
    end
    
    -- Получаем направление взгляда игрока
    local camera = workspace.CurrentCamera
    local lookVector = camera.CFrame.LookVector
    
    -- Позиция впереди на 5 блоков (для обхода стен)
    local forwardPos = humanoidRootPart.Position + lookVector * 5
    
    -- Проверяем, не внутри ли стены (маленький noclip)
    setNoclip(true)
    
    pcall(function()
        targetPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(forwardPos)
        task.wait(0.05)
        targetPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
    end)
    
    task.wait(0.1)
    setNoclip(false)
    
    return true, targetPlayer.Name .. " телепортирован к вам (+5 блоков вперёд)"
end

-- Телепорт вперёд на заданное расстояние
local function teleportForward(distance)
    if not humanoidRootPart then return false, "Нет персонажа" end
    
    local camera = workspace.CurrentCamera
    local lookVector = camera.CFrame.LookVector
    local newPos = humanoidRootPart.Position + lookVector * distance
    
    setNoclip(true)
    teleport(newPos)
    setNoclip(false)
    
    return true, "Телепорт вперёд на " .. distance .. " блоков"
end

-- Получить всех игроков
local function getOnlinePlayers()
    local names = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            table.insert(names, plr.Name)
        end
    end
    return names
end

-- Постоянная защита + noclip если нужно
local lastPos = humanoidRootPart.Position
task.spawn(function()
    while task.wait(0.3) do
        if humanoidRootPart and humanoidRootPart.Parent then
            humanoidRootPart:SetNetworkOwner(player)
            
            -- Если телепорт откатывается, применяем noclip и повторяем
            if (humanoidRootPart.Position - lastPos).Magnitude > 50 then
                setNoclip(true)
                task.wait(0.1)
                if (humanoidRootPart.Position - lastPos).Magnitude > 50 then
                    humanoidRootPart.CFrame = CFrame.new(lastPos)
                    humanoidRootPart:SetNetworkOwner(player)
                end
                task.wait(0.15)
                setNoclip(false)
            end
            lastPos = humanoidRootPart.Position
        end
    end
end)

-- Создаём простую панель (только список игроков)
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "DeltaTPPanel"
mainGui.ResetOnSpawn = false

local playerGui = player:WaitForChild("PlayerGui")
mainGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(45, 45, 50)
frame.Active = true
frame.Draggable = true
frame.Parent = mainGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 38)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
titleBar.BackgroundTransparency = 0.1
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -42, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "DELTA TP POWER"
titleText.TextColor3 = Color3.fromRGB(215, 215, 220)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 13
titleText.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 38, 1, 0)
closeBtn.Position = UDim2.new(1, -38, 0, 0)
closeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(180, 180, 185)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.Gotham
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainGui:Destroy()
end)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -38)
scroll.Position = UDim2.new(0, 0, 0, 38)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.Parent = scroll

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 28)
header.BackgroundTransparency = 1
header.Text = "ИГРОКИ ОНЛАЙН"
header.TextColor3 = Color3.fromRGB(160, 160, 170)
header.TextSize = 11
header.Font = Enum.Font.GothamBold
header.Parent = scroll

local playerContainer = Instance.new("Frame")
playerContainer.Size = UDim2.new(1, 0, 0, 0)
playerContainer.BackgroundTransparency = 1
playerContainer.Parent = scroll

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0, 5)
playerLayout.Parent = playerContainer

local function updatePlayerList()
    for _, child in ipairs(playerContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local players = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then table.insert(players, plr) end
    end
    
    if #players == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, 0, 0, 40)
        empty.BackgroundTransparency = 1
        empty.Text = "Нет игроков"
        empty.TextColor3 = Color3.fromRGB(130, 130, 140)
        empty.TextSize = 11
        empty.Font = Enum.Font.Gotham
        empty.Parent = playerContainer
        playerContainer.Size = UDim2.new(1, 0, 0, 44)
        return
    end
    
    for _, plr in ipairs(players) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 44)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(55, 55, 60)
        btn.Text = plr.Name
        btn.TextColor3 = Color3.fromRGB(220, 220, 225)
        btn.TextSize = 12
        btn.Font = Enum.Font.Gotham
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            local success, msg = teleportToPlayer(plr)
            print("[DeltaTP] " .. msg)
            btn.BackgroundColor3 = success and Color3.fromRGB(45, 75, 45) or Color3.fromRGB(75, 45, 45)
            task.wait(0.15)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            btn.BackgroundTransparency = 0.3
        end)
        
        btn.Parent = playerContainer
    end
    playerContainer.Size = UDim2.new(1, 0, 0, #players * 50)
end

updatePlayerList()
task.spawn(function()
    while task.wait(3) do
        if mainGui and mainGui.Parent then updatePlayerList() end
    end
end)

-- КОНСОЛЬНЫЕ КОМАНДЫ
local commands = {
    tp = function(args)
        if #args < 1 then return "Использование: /tp <ник>" end
        local targetName = table.concat(args, " ")
        local target = nil
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr.Name:lower():sub(1, #targetName) == targetName:lower() or plr.Name:lower() == targetName:lower() then
                target = plr
                break
            end
        end
        if not target then return "Игрок не найден" end
        local success, msg = teleportToPlayer(target)
        return msg
    end,
    
    tome = function(args)
        if #args < 1 then return "Использование: /tome <ник>" end
        local targetName = table.concat(args, " ")
        local target = nil
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr.Name:lower():sub(1, #targetName) == targetName:lower() or plr.Name:lower() == targetName:lower() then
                target = plr
                break
            end
        end
        if not target then return "Игрок не найден" end
        local success, msg = teleportToMe(target)
        return msg
    end,
    
    forward = function(args)
        local distance = 5
        if #args >= 1 then
            distance = tonumber(args[1]) or 5
        end
        distance = math.clamp(distance, 1, 50)
        local success, msg = teleportForward(distance)
        return msg
    end,
    
    f = function(args)
        local distance = 5
        if #args >= 1 then
            distance = tonumber(args[1]) or 5
        end
        distance = math.clamp(distance, 1, 50)
        local success, msg = teleportForward(distance)
        return msg
    end,
    
    players = function()
        local players = getOnlinePlayers()
        if #players == 0 then return "Нет игроков онлайн" end
        return "Онлайн: " .. table.concat(players, ", ")
    end,
    
    help = function()
        return "Команды:\n  /tp <ник> - телепорт к игроку\n  /tome <ник> - телепорт игрока к вам (+5 блоков)\n  /forward <число> - телепорт вперёд\n  /f <число> - сокращённо\n  /players - список игроков"
    end
}

player.Chatted:Connect(function(msg)
    if msg:sub(1,1) == "/" then
        local parts = {}
        for part in msg:sub(2):gmatch("%S+") do
            table.insert(parts, part)
        end
        if #parts > 0 then
            local cmd = parts[1]:lower()
            if commands[cmd] then
                local result = commands[cmd]({table.unpack(parts, 2)})
                warn("[DeltaTP] " .. result)
                return
            end
        end
    end
end)

_G.DeltaTP = {
    version = "9.0",
    tp = function(name) return commands.tp({name}) end,
    tome = function(name) return commands.tome({name}) end,
    forward = function(dist) return commands.forward({tostring(dist)}) end
}

print("========================================")
print("[SWILL] Delta TP POWER - ЗАГРУЖЕН!")
print("========================================")
print("▶ МОЩНЫЙ телепорт с noclip")
print("▶ /tp <ник> - к игроку")
print("▶ /tome <ник> - игрок к вам (+5 блоков вперёд)")
print("▶ /forward <число> - телепорт вперёд")
print("▶ /f <число> - сокращённо")
print("========================================")
