--[[
    SWILL Delta TP System - Professional Russian Edition
    Simple player list | Console TP command only
]]

local player = game.Players.LocalPlayer
if not player then
    game.Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = game.Players.LocalPlayer
end

local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

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

local function getOnlinePlayers()
    local names = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            table.insert(names, plr.Name)
        end
    end
    return names
end

local function teleportToPlayer(targetPlayer)
    if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return false, "Игрок не имеет персонажа"
    end
    teleport(targetPlayer.Character.HumanoidRootPart.Position)
    return true, "Телепорт к " .. targetPlayer.Name
end

-- Create main GUI
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "DeltaTPPanel"
mainGui.ResetOnSpawn = false

local playerGui = player:WaitForChild("PlayerGui")
mainGui.Parent = playerGui

-- Panel Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 450)
frame.Position = UDim2.new(0.5, -160, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
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
titleText.Text = "DELTA TELEPORT"
titleText.TextColor3 = Color3.fromRGB(215, 215, 220)
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 14
titleText.Parent = titleBar

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
refreshBtn.Text = "ОБНОВИТЬ"
refreshBtn.TextColor3 = Color3.fromRGB(210, 210, 215)
refreshBtn.TextSize = 11
refreshBtn.Font = Enum.Font.Gotham
refreshBtn.Parent = scroll

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 5)
refreshCorner.Parent = refreshBtn

-- Player Container
local playerContainer = Instance.new("Frame")
playerContainer.Size = UDim2.new(1, 0, 0, 0)
playerContainer.BackgroundTransparency = 1
playerContainer.Parent = scroll

local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0, 6)
playerLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerLayout.Parent = playerContainer

local function updatePlayerList()
    for _, child in ipairs(playerContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local players = {}
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player then
            table.insert(players, plr)
        end
    end
    
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
    
    for _, plr in ipairs(players) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 48)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        btn.BackgroundTransparency = 0.3
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(55, 55, 60)
        btn.Text = plr.Name
        btn.TextColor3 = Color3.fromRGB(220, 220, 225)
        btn.TextSize = 13
        btn.Font = Enum.Font.Gotham
        btn.TextXAlignment = Enum.TextXAlignment.Center
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        local targetPlayer = plr
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
    
    playerContainer.Size = UDim2.new(1, 0, 0, #players * 54)
end

refreshBtn.MouseButton1Click:Connect(function()
    updatePlayerList()
    refreshBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    task.wait(0.1)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
end)

-- Initial player list update
updatePlayerList()

-- Auto update every 3 seconds
task.spawn(function()
    while task.wait(3) do
        if mainGui and mainGui.Parent then
            updatePlayerList()
        end
    end
end)

-- Console command (only TP)
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
    help = function()
        return "Команда: /tp <ник>"
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
    version = "8.0",
    tp = function(name) return commands.tp({name}) end
}

print("========================================")
print("[SWILL] Delta TP - ЗАГРУЖЕН!")
print("========================================")
print("▶ Список игроков")
print("▶ Нажмите на игрока для телепорта")
print("▶ Команда: /tp <ник>")
print("========================================")
