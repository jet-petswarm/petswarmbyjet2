-- Jet Hub Ultimate Fishing & Auto-Hit (Paid Quality UI)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local VirtualUser = game:GetService("VirtualUser")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local FishingEvent = ReplicatedStorage
    :WaitForChild("Fishing")
    :WaitForChild("Remotes")
    :WaitForChild("FishingEvent")

--------------------------------------------------
-- ตัวแปรควบคุมระบบ
--------------------------------------------------
local autoFishing = false
local autoClicking = false
local castPosition = nil
local selectingCastPosition = false

local delayTime = 1.0
local luckHoldTime = 1.0
local hitDelay = 0.01

--------------------------------------------------
-- สร้าง UI ค่ายดัง (Premium Design)
--------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JetHubProUI"
screenGui.ResetOnSpawn = false
pcall(function()
    screenGui.Parent = CoreGui
end)
if not screenGui.Parent then
    screenGui.Parent = playerGui
end

-- Main Window Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.fromOffset(320, 440)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -220)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

-- UI Stroke (เส้นขอบเรืองแสงพรีเมียม)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 80)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- Top Bar Header
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 45)
topBar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
topBar.BorderSizePixel = 0
topBar.Parent = mainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = topBar

-- แก้ขอบล่าง TopBar ให้ตรง
local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 10)
topFix.Position = UDim2.new(0, 0, 1, -10)
topFix.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
topFix.BorderSizePixel = 0
topFix.Parent = topBar

-- Title Text
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -60, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "⚡  JET HUB  |  Fishing V2"
titleText.TextColor3 = Color3.fromRGB(240, 240, 255)
titleText.TextSize = 15
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = topBar

-- Minimize / Toggle UI Button (ปุ่มพับจอ)
local minButton = Instance.new("TextButton")
minButton.Size = UDim2.fromOffset(30, 30)
minButton.Position = UDim2.new(1, -38, 0.5, -15)
minButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
minButton.Text = "-"
minButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minButton.TextSize = 18
minButton.Font = Enum.Font.GothamBold
minButton.Parent = topBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minButton

-- Container สำหรับเก็บปุ่มทั้งหมด (ใช้ซ่อนตอนพับจอ)
local container = Instance.new("ScrollingFrame")
container.Size = UDim2.new(1, 0, 1, -45)
container.Position = UDim2.new(0, 0, 0, 45)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.CanvasSize = UDim2.new(0, 0, 0, 410)
container.ScrollBarThickness = 3
container.Parent = mainFrame

local uiList = Instance.new("UIListLayout")
uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 10)
uiList.Parent = container

-- เว้นขอบบนเล็กน้อย
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 12)
padding.Parent = container

--------------------------------------------------
-- สร้างฟังก์ชันสร้างปุ่มสไตล์พรีเมียม
--------------------------------------------------
local function createButton(name, text, color)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Size = UDim2.fromOffset(290, 42)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.Parent = container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = btn

    return btn
end

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.fromOffset(290, 24)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Ready to Setup"
statusLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = container

-- ปุ่มต่างๆ
local castButton = createButton("CastButton", "📍  SET CAST LOCATION", Color3.fromRGB(45, 85, 160))
local locationLabel = Instance.new("TextLabel")
locationLabel.Size = UDim2.fromOffset(290, 20)
locationLabel.BackgroundTransparency = 1
locationLabel.Text = "Cast Pos: Not Set"
locationLabel.TextColor3 = Color3.fromRGB(170, 170, 190)
locationLabel.TextSize = 11
locationLabel.Font = Enum.Font.Gotham
locationLabel.TextXAlignment = Enum.TextXAlignment.Left
locationLabel.Parent = container

local fishButton = createButton("FishButton", "Auto Fish: OFF", Color3.fromRGB(180, 45, 45))
local hitButton = createButton("HitButton", "Auto Hit: OFF", Color3.fromRGB(180, 45, 45))
local speedButton = createButton("SpeedButton", "Delay: 1.0s", Color3.fromRGB(45, 45, 55))
local holdButton = createButton("HoldButton", "Luck Hold: 1.0s", Color3.fromRGB(45, 45, 55))

--------------------------------------------------
-- อนิเมชั่นย่อ/ขยายหน้าต่าง (Minimize Logic)
--------------------------------------------------
local minimized = false
minButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    minButton.Text = minimized and "+" : "-"
    
    local targetSize = minimized and UDim2.fromOffset(320, 45) or UDim2.fromOffset(320, 440)
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = targetSize}):Play()
    container.Visible = not minimized
end)

--------------------------------------------------
-- ระบบตกปลา (Auto Fish Core)
--------------------------------------------------
local function fishOnce()
    if not autoFishing or not castPosition then return end

    FishingEvent:FireServer("Cast", { Position = castPosition })
    task.wait(0.1)
    if not autoFishing then return end

    local clickTime = os.clock()
    FishingEvent:FireServer("LuckHold", { ClickTime = clickTime })
    task.wait(luckHoldTime)
    if not autoFishing then return end

    FishingEvent:FireServer("LuckRelease", { ClickTime = os.clock() })
    task.wait(0.1)
    if not autoFishing then return end

    for index = 1, 17 do
        if not autoFishing then break end
        FishingEvent:FireServer("Hit", { Index = index })
        task.wait(hitDelay)
    end
end

--------------------------------------------------
-- ระบบ Auto Hit ตัวเก่ง (Fast & Stable)
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
            for _, connection in pairs(getconnections(targetButton.MouseButton1Click)) do connection:Fire() end
            for _, connection in pairs(getconnections(targetButton.MouseButton1Down)) do connection:Fire() end
            for _, connection in pairs(getconnections(targetButton.Activated)) do connection:Fire() end
        end
    end)
end

--------------------------------------------------
-- ระบบเซ็ตตำแหน่ง (Set Position)
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
        locationLabel.Text = string.format("Cast Pos: %.1f, %.1f, %.1f", castPosition.X, castPosition.Y, castPosition.Z)
        castButton.Text = "📍  CHANGE CAST LOCATION"
        castButton.BackgroundColor3 = Color3.fromRGB(45, 140, 85)
        selectingCastPosition = false
        statusLabel.Text = autoFishing and "Status: Fishing..." or "Status: Ready"
        statusLabel.TextColor3 = autoFishing and Color3.fromRGB(80, 255, 120) or Color3.fromRGB(255, 180, 50)
    end
end

castButton.MouseButton1Click:Connect(function()
    selectingCastPosition = true
    castButton.Text = "👉 TAP A SPOT IN THE WORLD"
    castButton.BackgroundColor3 = Color3.fromRGB(200, 140, 30)
    statusLabel.Text = "Status: Select a location..."
    statusLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
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
-- ปุ่มสลับสถานะเปิด-ปิด (Toggle Animations & States)
--------------------------------------------------

-- Auto Fish Toggle
fishButton.MouseButton1Click:Connect(function()
    if not castPosition then
        selectingCastPosition = true
        castButton.Text = "👉 TAP A SPOT IN THE WORLD"
        castButton.BackgroundColor3 = Color3.fromRGB(200, 140, 30)
        statusLabel.Text = "Status: Please set position first!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    autoFishing = not autoFishing
    if autoFishing then
        fishButton.Text = "Auto Fish: ON"
        TweenService:Create(fishButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 180, 80)}):Play()
        statusLabel.Text = "Status: Fishing..."
        statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
    else
        fishButton.Text = "Auto Fish: OFF"
        TweenService:Create(fishButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 45, 45)}):Play()
        statusLabel.Text = "Status: Paused"
        statusLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
    end
end)

-- Auto Hit Toggle
hitButton.MouseButton1Click:Connect(function()
    autoClicking = not autoClicking
    if autoClicking then
        hitButton.Text = "Auto Hit: ON"
        TweenService:Create(hitButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 180, 80)}):Play()
    else
        hitButton.Text = "Auto Hit: OFF"
        TweenService:Create(hitButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 45, 45)}):Play()
    end
end)

-- Delay Button
speedButton.MouseButton1Click:Connect(function()
    if delayTime == 1.0 then delayTime = 0.75
    elseif delayTime == 0.75 then delayTime = 0.5
    elseif delayTime == 0.5 then delayTime = 0.25
    else delayTime = 1.0 end
    speedButton.Text = "Delay: " .. delayTime .. "s"
end)

-- Luck Hold Button
holdButton.MouseButton1Click:Connect(function()
    if luckHoldTime == 1.0 then luckHoldTime = 0.75
    elseif luckHoldTime == 0.75 then luckHoldTime = 0.5
    elseif luckHoldTime == 0.5 then luckHoldTime = 0.25
    else luckHoldTime = 1.0 end
    holdButton.Text = "Luck Hold: " .. luckHoldTime .. "s"
end)

--------------------------------------------------
-- ลูปทำงานเบื้องหลัง (Background Loops)
--------------------------------------------------
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

task.spawn(function()
    while true do
        if autoClicking then
            clickTarget()
        end
        task.wait(0.05)
    end
end)

--------------------------------------------------
-- AUTO ANTI-KICK ทุกชนิด (ทำงานออโต้ทันที 100%)
--------------------------------------------------
task.spawn(function()
    -- 1. AFK Idle Protection
    task.spawn(function()
        while true do
            task.wait(45)
            pcall(function()
                VirtualUser:Button1Down(Vector2.new(0, 0))
                task.wait(0.1)
                VirtualUser:Button1Up(Vector2.new(0, 0))
            end)
        end
    end)

    -- 2. Window Focus Loss Protection
    pcall(function()
        player.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(0, 0))
            end)
        end)
    end)

    -- 3. Auto Reconnect Error Prompt Bypass
    pcall(function()
        CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
            if child.Name == "ErrorPrompt" then
                task.spawn(function()
                    while true do
                        task.wait(1)
                        pcall(function()
                            GuiService:EmulateFocus(child.ErrorPrompt.ButtonArea.Button1)
                        end)
                    end
                end)
            end
        end)
    end)
end)
