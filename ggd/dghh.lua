--[[
    SWILL Delta TP System - Professional Russian Edition
    Auto-join (ВХ) with toggle | Transparent player list | Console commands
]]

local player = game.Players.LocalPlayer
if not player then
    game.Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = game.Players.LocalPlayer
end

local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Auto-Join (ВХ) variables
local autoJoinEnabled = false
local autoJoinTarget = nil

-- Anti-TP protection
local function teleport(position)
    if not humanoidRootPart or not humanoidRootPart.Parent then return end
    for i = 1, 3 do
        pcall(function()
            humanoidRootPart.CFrame = CFrame.new(position)
            task.wait(0.05)
            humanoidRootPart.Velocity = Vector3.new(0,0,0)
            humanoidRootPart:SetNetworkOwner(player)
            task.wait()
            if humanoidRootPart and (humanoidRootPart.Position - position).Magnitude > 10 then
                humanoidRootPart.CFrame = CFrame.new(position)
            end
        end)
        task.wait(0.05)
    end
end

-- Rollback protection
local lastPos = humanoidRootPart.Position
task.spawn(function()
    while task.wait(0.5) do
        if humanoidRootPart and humanoidRootPart.Parent then
            humanoidRootPart:SetNetworkOwner(player)
            if (humanoidRootPart.Position - lastPos).Magnitude > 100 then
                task.wait(0.2)
                if humanoidRootPart and (humanoidRootPart.Position - lastPos).Magnitude > 100 then
                    humanoidRootPart:SetNetworkOwner(player)
                end
            end
            lastPos = humanoidRootPart.Position
        end
    end
end)

-- Get player info with distance and HP
local function getPlayerInfo(targetPlayer)
    if not humanoidRootPart or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return 999, 0, 100
    end
    local distance = math.floor((humanoidRootPart.Position - targetPlayer.Character.HumanoidRootPart.Position).Magnitude)
    local humanoid = targetPlayer.Character:FindFirstChild("Humanoid")
    local hp = humanoid and math.floor(humanoid.Health) or 0
    local maxHp = humanoid and humanoid.MaxHealth or 100
    return distance, hp, maxHp
end

local function getOnlinePlayersWithInfo()
    local data = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local distance, hp, maxHp = getPlayerInfo(plr)
            table.insert(data, {
                name = plr.Name,
                distance = distance,
                hp = hp,
                maxHp = maxHp,
                player = plr
            })
        end
    end
    table.sort(data, function(a, b) return a.distance < b.distance end)
    return data
end

local function teleportToPlayer(targetPlayer)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return false, "Игрок не имеет персонажа"
    end
    teleport(targetPlayer.Character.HumanoidRootPart.Position)
    return true, "Телепорт к " .. targetPlayer.Name
end

-- Auto-Join logic
task.spawn(function()
    while task.wait(0.5) do
        if autoJoinEnabled then
            local players = getOnlinePlayersWithInfo()
            if #players > 0 then
                local target = players[1].player
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    teleport(target.Character.HumanoidRootPart.Position)
                end
            end
        end
    end
end)

-- Create main GUI (transparent player list)
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "DeltaTPPanel"
mainGui.ResetOnSpawn = false

local playerGui = player:WaitForChild("PlayerGui")
mainGui.Parent = playerGui

-- Panel Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 380, 0, 520)
frame.Position = UDim2.new(0.5, -190, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 1
frame.BorderColor3 = Color3.fromRGB(45, 45, 50)
frame.Active = true
frame.Draggable = true
frame.Visible = true
frame.Parent = mainGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 10)
frameCorner.Parent = frame

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 33)
titleBar.BackgroundTransparency = 0.1
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -48, 1, 0)
titleText.Position = UDim2.new(0, 12, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "DELTA TELEPORT SYSTEM"
titleText.TextColor3 = Color3.fromRGB(215, 215, 220)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 13
titleText.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 40, 1, 0)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
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

-- Scroll Frame
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -40)
scroll.Position = UDim2.new(0, 0, 0, 40)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(55, 55, 60)
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local padding = Instance.new("UIPadding")
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
padding.Parent = scroll

-- Header
local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundTransparency = 1
header.Text = "▸ ИГРОКИ ОНЛАЙН ◂"
header.TextColor3 = Color3.fromRGB(160, 160, 170)
header.TextSize = 12
header.Font = Enum.Font.GothamBold
header.TextXAlignment = Enum.TextXAlignment.Center
header.Parent = scroll

-- Refresh Button
local refreshBtn = Instance.new("TextButton")
refreshBtn.Size = UDim2.new(1, 0, 0, 38)
refreshBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
refreshBtn.BorderSizePixel = 1
refreshBtn.BorderColor3 = Color3.fromRGB(48, 48, 53)
refreshBtn.Text = "ОБНОВИТЬ СПИСОК"
refreshBtn.TextColor3 = Color3.fromRGB(210, 210, 215)
refreshBtn.TextSize = 11
refreshBtn.Font = Enum.Font.Gotham
refreshBtn.Parent = scroll

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 5)
refreshCorner.Parent = refreshBtn

-- Player Container (transparent buttons)
local playerContainer = Instance.new("Frame")
playerContainer.Size = UDim2.new(1, 0, 0, 0)
playerContainer.BackgroundTransparency = 1
playerContainer.Parent = scroll

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0, 6)
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Parent = playerContainer

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 28)
statusLabel.Position = UDim2.new(0, 0, 1, -30)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Нажмите на игрока для телепорта"
statusLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
statusLabel.TextSize = 10
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = frame

-- ВХ Toggle Button (on the panel)
local vhToggleBtn = Instance.new("TextButton")
vhToggleBtn.Size = UDim2.new(0.48, 0, 0, 36)
vhToggleBtn.Position = UDim2.new(0.01, 0, 1, -42)
vhToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
vhToggleBtn.BorderSizePixel = 1
vhToggleBtn.BorderColor3 = Color3.fromRGB(60, 60, 70)
vhToggleBtn.Text = "ВХ: ВЫКЛ"
vhToggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
vhToggleBtn.TextSize = 12
vhToggleBtn.Font = Enum.Font.GothamBold
vhToggleBtn.Parent = frame

local vhCorner = Instance.new("UICorner")
vhCorner.CornerRadius = UDim.new(0, 6)
vhCorner.Parent = vhToggleBtn

-- Update ВХ button appearance
local function updateVHToggle()
    if autoJoinEnabled then
        vhToggleBtn.Text = "ВХ: ВКЛ"
        vhToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 90, 50)
    else
        vhToggleBtn.Text = "ВХ: ВЫКЛ"
        vhToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    end
end

vhToggleBtn.MouseButton1Click:Connect(function()
    autoJoinEnabled = not autoJoinEnabled
    updateVHToggle()
    print("[DeltaTP] ВХ " .. (autoJoinEnabled and "ВКЛЮЧЕН" or "ВЫКЛЮЧЕН"))
end)

local function updatePlayerList()
    for _, child in ipairs(playerContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local players = getOnlinePlayersWithInfo()
    
    if #players == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, 0, 0, 50)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Text = "Нет игроков онлайн"
        emptyLabel.TextColor3 = Color3.fromRGB(130, 130, 140)
        emptyLabel.TextSize = 12
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.Parent = playerContainer
        playerContainer.Size = UDim2.new(1, 0, 0, 54)
        return
    end
    
    for _, data in ipairs(players) do
        -- Transparent button
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 52)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(55, 55, 60)
        
        local hpPercent = (data.hp / data.maxHp) * 100
        local hpColor = hpPercent > 60 and Color3.fromRGB(50, 150, 50) or (hpPercent > 30 and Color3.fromRGB(200, 150, 50) or Color3.fromRGB(200, 50, 50))
        
        local text = string.format("%s     📍 %dм     ❤️ %d/%d", data.name, data.distance, data.hp, data.maxHp)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(220, 220, 225)
        btn.TextSize = 12
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.TextTruncate = Enum.TextTruncate.AtEnd
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        -- HP Bar
        local hpBar = Instance.new("Frame")
        hpBar.Size = UDim2.new(hpPercent / 100, 0, 0, 3)
        hpBar.Position = UDim2.new(0, 0, 1, -3)
        hpBar.BackgroundColor3 = hpColor
        hpBar.BorderSizePixel = 0
        hpBar.Parent = btn
        
        local targetPlayer = data.player
        btn.MouseButton1Click:Connect(function()
            local success, msg = teleportToPlayer(targetPlayer)
            print("[DeltaTP] " .. msg)
            if success then
                btn.BackgroundColor3 = Color3.fromRGB(45, 75, 45)
                task.wait(0.15)
            else
                btn.BackgroundColor3 = Color3.fromRGB(75, 45, 45)
                task.wait(0.25)
            end
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            btn.BackgroundTransparency = 0.3
        end)
        
        btn.Parent = playerContainer
    end
    
    playerContainer.Size = UDim2.new(1, 0, 0, #players * 58)
end

refreshBtn.MouseButton1Click:Connect(function()
    updatePlayerList()
    refreshBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    task.wait(0.1)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
end)

-- Initial player list update
updatePlayerList()
updateVHToggle()

-- Auto update every 3 seconds
task.spawn(function()
    while task.wait(3) do
        if mainGui and mainGui.Parent then
            updatePlayerList()
        end
    end
end)

-- Console commands (only TP and toggle)
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
    vh_on = function()
        autoJoinEnabled = true
        updateVHToggle()
        return "ВХ включен"
    end,
    vh_off = function()
        autoJoinEnabled = false
        updateVHToggle()
        return "ВХ выключен"
    end,
    vh = function()
        autoJoinEnabled = not autoJoinEnabled
        updateVHToggle()
        return "ВХ " .. (autoJoinEnabled and "включен" or "выключен")
    end,
    help = function()
        return "Команды: /tp <ник>, /vh, /vh_on, /vh_off"
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
    version = "6.0",
    tp = function(name) return commands.tp({name}) end,
    vh_on = function() commands.vh_on() end,
    vh_off = function() commands.vh_off() end,
    vh_toggle = function() commands.vh() end
}

print("========================================")
print("[SWILL] Delta TP - ВХ ВЕРСИЯ ЗАГРУЖЕНА!")
print("========================================")
print("▶ Панель с прозрачными кнопками")
print("▶ Кнопка ВХ на панели (ВКЛ/ВЫКЛ)")
print("▶ Команды: /tp ник, /vh, /vh_on, /vh_off")
print("========================================")
