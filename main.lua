-- Jet Hub: Auto Fishing & Auto Hit (Combined)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local FishingEvent = ReplicatedStorage
    :WaitForChild("Fishing")
    :WaitForChild("Remotes")
    :WaitForChild("FishingEvent")

--------------------------------------------------
-- ตัวแปรควบคุมระบบทั้งหมด
--------------------------------------------------
local autoFishing = false
local autoClicking = false

local castPosition = nil
local selectingCastPosition = false

local delayTime = 1.0
local luckHoldTime = 1.0
local hitDelay = 0.01

--------------------------------------------------
-- สร้าง UI (Jet Hub Style)
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JetHubFishingGui"
screenGui.ResetOnSpawn = false
pcall(function()
    screenGui.Parent = game:GetService("CoreGui")
end)
if not screenGui.Parent then
    screenGui.Parent = playerGui
end

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.fromOffset(280, 360)
frame.Position = UDim2.new(0.5, -140, 0.5, -180)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- หัวข้อ Jet Hub
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "⚡ JET HUB: Fishing"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 18
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- Status แสดงสถานะ
local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(10, 38)
status.Size = UDim2.new(1, -20, 0, 20)
status.BackgroundTransparency = 1
status.Text = "Status: IDLE"
status.TextColor3 = Color3.fromRGB(255, 200, 80)
status.TextSize = 13
status.Font = Enum.Font.Gotham
status.Parent = frame

-- ปุ่ม Set Cast Location
local castButton = Instance.new("TextButton")
castButton.Position = UDim2.fromOffset(15, 65)
castButton.Size = UDim2.new(1, -30, 0, 35)
castButton.Text = "SET CAST LOCATION"
castButton.TextSize = 14
castButton.Font = Enum.Font.GothamBold
castButton.TextColor3 = Color3.new(1, 1, 1)
castButton.BackgroundColor3 = Color3.fromRGB(55, 95, 170)
castButton.Parent = frame

local castCorner = Instance.new("UICorner")
castCorner.CornerRadius = UDim.new(0, 8)
castCorner.Parent = castButton

local locationLabel = Instance.new("TextLabel")
locationLabel.Position = UDim2.fromOffset(15, 103)
locationLabel.Size = UDim2.new(1, -30, 0, 20)
locationLabel.BackgroundTransparency = 1
locationLabel.Text = "Cast: Not Set"
locationLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
locationLabel.TextSize = 11
locationLabel.Font = Enum.Font.Gotham
locationLabel.TextTruncate = Enum.TextTruncate.AtEnd
locationLabel.Parent = frame

-- ปุ่มเปิด/ปิด Auto Fish
local startButton = Instance.new("TextButton")
startButton.Position = UDim2.fromOffset(15, 128)
startButton.Size = UDim2.new(1, -30, 0, 40)
startButton.Text = "Auto Fish: OFF"
startButton.TextSize = 15
startButton.Font = Enum.Font.GothamBold
startButton.TextColor3 = Color3.new(1, 1, 1)
startButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
startButton.Parent = frame

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 8)
startCorner.Parent = startButton

-- ปุ่มเปิด/ปิด Auto Hit (ออโต้คลิกอันเดิมที่คุณชอบ)
local hitToggleButton = Instance.new("TextButton")
hitToggleButton.Position = UDim2.fromOffset(15, 175)
hitToggleButton.Size = UDim2.new(1, -30, 0, 40)
hitToggleButton.Text = "Auto Hit: OFF"
hitToggleButton.TextSize = 15
hitToggleButton.Font = Enum.Font.GothamBold
hitToggleButton.TextColor3 = Color3.new(1, 1, 1)
hitToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
hitToggleButton.Parent = frame

local hitCorner = Instance.new("UICorner")
hitCorner.CornerRadius = UDim.new(0, 8)
hitCorner.Parent = hitToggleButton

-- ปุ่มปรับ Delay
local speedButton = Instance.new("TextButton")
speedButton.Position = UDim2.fromOffset(15, 225)
speedButton.Size = UDim2.new(1, -30, 0, 30)
speedButton.Text = "Delay: 1.0s"
speedButton.TextSize = 13
speedButton.Font = Enum.Font.Gotham
speedButton.TextColor3 = Color3.new(1, 1, 1)
speedButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
speedButton.Parent = frame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 6)
speedCorner.Parent = speedButton

-- ปุ่มปรับ Luck Hold
local holdButton = Instance.new("TextButton")
holdButton.Position = UDim2.fromOffset(15, 262)
holdButton.Size = UDim2.new(1, -30, 0, 25)
holdButton.Text = "Luck Hold: 1.0s"
holdButton.TextSize = 12
holdButton.Font = Enum.Font.Gotham
holdButton.TextColor3 = Color3.new(1, 1, 1)
holdButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
holdButton.Parent = frame

local holdCorner = Instance.new("UICorner")
holdCorner.CornerRadius = UDim.new(0, 6)
holdCorner.Parent = holdButton

--------------------------------------------------
-- ฟังก์ชันระบบตกปลา (Auto Fish)
--------------------------------------------------
local function fishOnce()
    if not autoFishing or not castPosition then return end

    -- CAST
    FishingEvent:FireServer("Cast", { Position = castPosition })
    task.wait(0.1)
    if not autoFishing then return end

    -- LUCK HOLD
    local clickTime = os.clock()
    FishingEvent:FireServer("LuckHold", { ClickTime = clickTime })
    task.wait(luckHoldTime)
    if not autoFishing then return end

    -- LUCK RELEASE
    FishingEvent:FireServer("LuckRelease", { ClickTime = os.clock() })
    task.wait(0.1)
    if not autoFishing then return end

    -- HIT 1 THROUGH 17
    for index = 1, 17 do
        if not autoFishing then break end
        FishingEvent:FireServer("Hit", { Index = index })
        task.wait(hitDelay)
    end
end

--------------------------------------------------
-- ฟังก์ชันระบบ Auto Hit (มินิเกมของคุณ)
--------------------------------------------------
local function clickTarget()
    pcall(function()
        local targetButton = player.PlayerGui
            :WaitForChild("_LobbyUI", 0.1)
            :WaitForChild("UPDATE: 10 UI Folder", 0.1)
            :WaitForChild("Fish Content", 0.1)
            :WaitForChild("Fishing", 0.1)
            :WaitForChild("TargetFrame", 0.1)
            :WaitForChild("Click", 0.1)
            :WaitForChild("HitArea", 0.1)
        
        if targetButton then
            for _, connection in pairs(getconnections(targetButton.MouseButton1Click)) do
                connection:Fire()
            end
            for _, connection in pairs(getconnections(targetButton.MouseButton1Down)) do
                connection:Fire()
            end
            for _, connection in pairs(getconnections(targetButton.Activated)) do
                connection:Fire()
            end
        end
    end)
end

--------------------------------------------------
-- จัดการการตั้งค่าตำแหน่งตกปลา (Set Position)
--------------------------------------------------
local function updateCastLocation(screenPosition)
    local camera = workspace.CurrentCamera
    if not camera then return end

    local ray = camera:ViewportPointToRay(screenPosition.X, screenPosition.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character, screenGui}

    local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
    if result then
        castPosition = result.Position
        locationLabel.Text = string.format("Cast: %.1f, %.1f, %.1f", castPosition.X, castPosition.Y, castPosition.Z)
        castButton.Text = "CHANGE CAST LOCATION"
        castButton.BackgroundColor3 = Color3.fromRGB(55, 145, 90)
        selectingCastPosition = false
        status.Text = autoFishing and "Status: FISHING" or "Status: IDLE"
        status.TextColor3 = autoFishing and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 200, 80)
    end
end

castButton.Activated:Connect(function()
    selectingCastPosition = true
    castButton.Text = "TAP A SPOT IN THE WORLD"
    castButton.BackgroundColor3 = Color3.fromRGB(190, 140, 45)
    status.Text = "Status: SELECTING LOCATION"
    status.TextColor3 = Color3.fromRGB(255, 220, 100)
end)

UserInputService.TouchTap:Connect(function(touchPositions, processedByUI)
    if selectingCastPosition and not processedByUI and touchPositions[1] then
        updateCastLocation(touchPositions[1])
    end
end)

UserInputService.InputBegan:Connect(function(input, processedByUI)
    if selectingCastPosition and not processedByUI and input.UserInputType == Enum.UserInputType.MouseButton1 then
        updateCastLocation(input.Position)
    end
end)

--------------------------------------------------
-- ปุ่มกดเปิด-ปิด ควบคุมฟังก์ชัน
--------------------------------------------------

-- 1. ปุ่ม Auto Fish
startButton.Activated:Connect(function()
    if not castPosition then
        selectingCastPosition = true
        castButton.Text = "TAP A SPOT IN THE WORLD"
        castButton.BackgroundColor3 = Color3.fromRGB(190, 140, 45)
        status.Text = "Status: SELECT A CAST LOCATION"
        status.TextColor3 = Color3.fromRGB(255, 220, 100)
        return
    end

    autoFishing = not autoFishing

    if autoFishing then
        startButton.Text = "Auto Fish: ON"
        startButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        status.Text = "Status: FISHING"
        status.TextColor3 = Color3.fromRGB(80, 255, 120)
    else
        startButton.Text = "Auto Fish: OFF"
        startButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        status.Text = "Status: IDLE"
        status.TextColor3 = Color3.fromRGB(255, 200, 80)
    end
end)

-- 2. ปุ่ม Auto Hit (ออโต้คลิก)
hitToggleButton.Activated:Connect(function()
    autoClicking = not autoClicking
    
    if autoClicking then
        hitToggleButton.Text = "Auto Hit: ON"
        hitToggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        hitToggleButton.Text = "Auto Hit: OFF"
        hitToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

--------------------------------------------------
-- ปุ่มปรับค่าหน่วงเวลา (Delay & Luck Hold)
--------------------------------------------------
speedButton.Activated:Connect(function()
    if delayTime == 1.0 then delayTime = 0.75
    elseif delayTime == 0.75 then delayTime = 0.5
    elseif delayTime == 0.5 then delayTime = 0.25
    else delayTime = 1.0 end
    speedButton.Text = "Delay: " .. delayTime .. "s"
end)

holdButton.Activated:Connect(function()
    if luckHoldTime == 1.0 then luckHoldTime = 0.75
    elseif luckHoldTime == 0.75 then luckHoldTime = 0.5
    elseif luckHoldTime == 0.5 then luckHoldTime = 0.25
    else luckHoldTime = 1.0 end
    holdButton.Text = "Luck Hold: " .. luckHoldTime .. "s"
end)

--------------------------------------------------
-- ลูปทำงานเบื้องหลัง (Background Loops)
--------------------------------------------------

-- ลูป Auto Fish
task.spawn(function()
    while true do
        if autoFishing then
            fishOnce()
            task.wait(delayTime)
        else
            task.wait(0.2)
        end
    end
end)

-- ลูป Auto Hit (ไวและเสถียรตามเดิม)
task.spawn(function()
    while true do
        if autoClicking then
            clickTarget()
        end
        task.wait(0.05)
    end
end)
