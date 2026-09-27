-- ==================================================
-- JET HUB: ALLIANCE TOWER DEFENDERS V1 (AUTO LOCK POS)
-- ==================================================
print("==========================================")
print("[JET HUB] เริ่มต้นรันสคริปต์ (พร้อมระบบล็อคตำแหน่งและดึงกลับออโต้)...")

local success, initError = pcall(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local VirtualUser = game:GetService("VirtualUser")
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- ล้าง UI เก่า
    pcall(function()
        if CoreGui:FindFirstChild("JetHubAllianceV1") then CoreGui.JetHubAllianceV1:Destroy() end
        if playerGui:FindFirstChild("JetHubAllianceV1") then playerGui.JetHubAllianceV1:Destroy() end
    end)

    -- ตรวจสอบ Remote ตกปลา
    local FishingEvent = nil
    pcall(function()
        FishingEvent = ReplicatedStorage:WaitForChild("Fishing", 2):WaitForChild("Remotes", 2):WaitForChild("FishingEvent", 2)
    end)

    local autoFishing = false
    local castPosition = nil
    local lockedCharacterCFrame = nil -- ตัวแปรเก็บตำแหน่งล็อคตัวละคร/เรือ
    local selectingCastPosition = false
    local luckHoldTime = 0.3

    -- สร้าง ScreenGui หลัก
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "JetHubAllianceV1"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999999
    
    pcall(function()
        if protectgui then protectgui(screenGui) end
    end)
    
    local parentSuccess = pcall(function()
        screenGui.Parent = CoreGui
    end)
    if not parentSuccess then
        screenGui.Parent = playerGui
    end

    -- หน้าต่างหลัก (ขยายขนาดความสูงเพิ่มนิดหน่อยเพื่อให้พอดีกับปุ่มสถานะพิกัดใหม่)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromOffset(280, 380)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -190)
    mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(80, 80, 110)
    mainStroke.Thickness = 1.5
    mainStroke.Parent = mainFrame

    -- แถบบาร์ด้านบน
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 12)
    topCorner.Parent = topBar

    local topFix = Instance.new("Frame")
    topFix.Size = UDim2.new(1, 0, 0, 8)
    topFix.Position = UDim2.new(0, 0, 1, -8)
    topFix.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    topFix.BorderSizePixel = 0
    topFix.Parent = topBar

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -70, 1, 0)
    titleText.Position = UDim2.new(0, 12, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "JET HUB - TD v1"
    titleText.TextColor3 = Color3.fromRGB(240, 240, 255)
    titleText.TextSize = 14
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = topBar

    local minButton = Instance.new("TextButton")
    minButton.Size = UDim2.fromOffset(26, 26)
    minButton.Position = UDim2.new(1, -34, 0.5, -13)
    minButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    minButton.Text = "-"
    minButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minButton.TextSize = 16
    minButton.Font = Enum.Font.GothamBold
    minButton.Parent = topBar

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minButton

    local container = Instance.new("ScrollingFrame")
    container.Size = UDim2.new(1, 0, 1, -40)
    container.Position = UDim2.new(0, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.CanvasSize = UDim2.new(0, 0, 0, 340)
    container.ScrollBarThickness = 2
    container.Parent = mainFrame

    local uiList = Instance.new("UIListLayout")
    uiList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Padding = UDim.new(0, 8)
    uiList.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.Parent = container

    local function createButton(name, text, color)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.fromOffset(256, 36)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamBold
        btn.Parent = container

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        return btn
    end

    -- กล่อง Status แสดงสถานะ Auto Fish และ Anti-Kick
    local statusBox = Instance.new("Frame")
    statusBox.Size = UDim2.fromOffset(256, 60)
    statusBox.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    statusBox.BorderSizePixel = 0
    statusBox.Parent = container

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 8)
    statusCorner.Parent = statusBox

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -16, 0, 20)
    statusLabel.Position = UDim2.new(0, 8, 0, 6)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "Auto Fish: OFF (Paused)"
    statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusLabel.TextSize = 11
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusBox

    local antiKickStatus = Instance.new("TextLabel")
    antiKickStatus.Size = UDim2.new(1, -16, 0, 20)
    antiKickStatus.Position = UDim2.new(0, 8, 0, 28)
    antiKickStatus.BackgroundTransparency = 1
    antiKickStatus.Text = "Anti-Kick AFK: Active (Protected)"
    antiKickStatus.TextColor3 = Color3.fromRGB(80, 255, 120)
    antiKickStatus.TextSize = 11
    antiKickStatus.Font = Enum.Font.GothamMedium
    antiKickStatus.TextXAlignment = Enum.TextXAlignment.Left
    antiKickStatus.Parent = statusBox

    local castButton = createButton("CastButton", "SET CAST LOCATION", Color3.fromRGB(45, 85, 160))
    
    -- ปุ่มบอกสถานะพิกัด (กดแล้วโชว์พิกัด + เปลี่ยนสีตามสถานะ: ฟ้า=เห็นตำแหน่ง, เขียว=กำลังเปิดออโต้ล็อค)
    local locationStatusButton = Instance.new("TextButton")
    locationStatusButton.Name = "LocationStatusButton"
    locationStatusButton.Size = UDim2.fromOffset(256, 30)
    locationStatusButton.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    locationStatusButton.Text = "Location Status: Not Set"
    locationStatusButton.TextColor3 = Color3.fromRGB(170, 170, 190)
    locationStatusButton.TextSize = 11
    locationStatusButton.Font = Enum.Font.GothamMedium
    locationStatusButton.Parent = container

    local locCorner = Instance.new("UICorner")
    locCorner.CornerRadius = UDim.new(0, 8)
    locCorner.Parent = locationStatusButton

    local fishButton = createButton("FishButton", "Auto Fish: OFF", Color3.fromRGB(180, 45, 45))
    local holdButton = createButton("HoldButton", "Luck Hold: 0.3s", Color3.fromRGB(45, 45, 55))

    -- ปุ่มลอยเปิด-ปิด UI สคริปต์
    local toggleGuiButton = Instance.new("TextButton")
    toggleGuiButton.Name = "ToggleGuiButton"
    toggleGuiButton.Size = UDim2.fromOffset(45, 45)
    toggleGuiButton.Position = UDim2.new(0, 15, 0.4, 0)
    toggleGuiButton.BackgroundColor3 = Color3.fromRGB(45, 85, 160)
    toggleGuiButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleGuiButton.Text = "JET"
    toggleGuiButton.TextSize = 12
    toggleGuiButton.Font = Enum.Font.GothamBold
    toggleGuiButton.Active = true
    toggleGuiButton.Draggable = true
    toggleGuiButton.Parent = screenGui

    local toggleGuiCorner = Instance.new("UICorner")
    toggleGuiCorner.CornerRadius = UDim.new(1, 0)
    toggleGuiCorner.Parent = toggleGuiButton

    local uiVisible = true
    toggleGuiButton.MouseButton1Click:Connect(function()
        uiVisible = not uiVisible
        mainFrame.Visible = uiVisible
    end)

    local minimized = false
    minButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        minButton.Text = minimized and "+" or "-"
        local targetSize = minimized and UDim2.fromOffset(280, 40) or UDim2.fromOffset(280, 380)
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        container.Visible = not minimized
    end)

    -- ฟังก์ชันดึงตำแหน่ง RootPart (รองรับทั้งตัวละครธรรมดา และตัวละครที่ขับเรือ/นั่งยานพาหนะ)
    local function getRootPart()
        local character = player.Character
        if not character then return nil end
        
        -- ถ้ากำลังนั่งขับเรือ (Seat / VehicleSeat) ให้พยายามดึงพาร์ทรวมของเรือ
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.SeatPart then
            local seat = humanoid.SeatPart
            if seat.ведении then end
            -- หา Model หลักของเรือ
            local model = seat:FindFirstAncestorOfClass("Model")
            if model and model.PrimaryPart then
                return model.PrimaryPart, model
            else
                return seat, seat
            end
        end
        
        return character:FindFirstChild("HumanoidRootPart"), character
    end

    -- ฟังก์ชันกด Hit UI ทันที
    local function clickTargetUI()
        pcall(function()
            local lobbyUI = playerGui:FindFirstChild("_LobbyUI")
            if not lobbyUI then return end
            local updateFolder = lobbyUI:FindFirstChild("UPDATE: 10 UI Folder")
            if not updateFolder then return end
            local fishContent = updateFolder:FindFirstChild("Fish Content")
            if not fishContent then return end
            local fishing = fishContent:FindFirstChild("Fishing")
            if not fishing then return end
            local targetFrame = fishing:FindFirstChild("TargetFrame")
            if not targetFrame then return end
            local clickObj = targetFrame:FindFirstChild("Click")
            if not clickObj then return end
            local targetButton = clickObj:FindFirstChild("HitArea")
            
            if targetButton and getconnections then
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

    -- ฟังก์ชันตกปลาแบบ Instant Hit
    local function fishOnce()
        if not autoFishing or not castPosition then return end
        
        if not FishingEvent then
            pcall(function()
                FishingEvent = ReplicatedStorage:WaitForChild("Fishing", 1):WaitForChild("Remotes", 1):WaitForChild("FishingEvent", 1)
            end)
        end
        if not FishingEvent then return end
        
        pcall(function() FishingEvent:FireServer("Cast", { Position = castPosition }) end)
        task.wait(0.02)
        if not autoFishing then return end
        
        pcall(function() FishingEvent:FireServer("LuckHold", { ClickTime = os.clock() }) end)
        task.wait(luckHoldTime)
        if not autoFishing then return end
        
        pcall(function() FishingEvent:FireServer("LuckRelease", { ClickTime = os.clock() }) end)
        task.wait(0.02)
        if not autoFishing then return end
        
        pcall(function()
            for index = 1, 17 do
                if not autoFishing then break end
                FishingEvent:FireServer("Hit", { Index = index })
                clickTargetUI()
            end
        end)
    end

    local function updateCastLocation(screenPosition)
        local camera = workspace.CurrentCamera
        if not camera then return end
        pcall(function()
            local ray = camera:ViewportPointToRay(screenPosition.X, screenPosition.Y)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {player.Character, screenGui}
            local result = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
            if result then
                castPosition = result.Position
                
                -- บันทึกตำแหน่งตัวละคร/เรือปัจจุบันเก็บไว้เป็นจุดล็อค
                local rootPart, model = getRootPart()
                if rootPart then
                    lockedCharacterCFrame = rootPart.CFrame
                end

                -- อัปเดตปุ่มสถานะ Location ให้เป็นสีฟ้า (เห็นตำแหน่งแล้ว)
                locationStatusButton.Text = string.format("Pos: X:%.0f Y:%.0f Z:%.0f", castPosition.X, castPosition.Y, castPosition.Z)
                locationStatusButton.TextColor3 = Color3.fromRGB(100, 210, 255)
                locationStatusButton.BackgroundColor3 = Color3.fromRGB(35, 70, 110)

                castButton.Text = "CHANGE CAST LOCATION"
                castButton.BackgroundColor3 = Color3.fromRGB(45, 140, 85)
                selectingCastPosition = false
                statusLabel.Text = "Auto Fish: Ready (Paused)"
                statusLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
            end
        end)
    end

    castButton.MouseButton1Click:Connect(function()
        selectingCastPosition = true
        castButton.Text = "TAP A SPOT IN THE WORLD"
        castButton.BackgroundColor3 = Color3.fromRGB(200, 140, 30)
        statusLabel.Text = "Status: Select a location..."
        statusLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
    end)

    -- ปุ่มคลิกที่แถบสถานะพิกัดเพื่อดูพิกัดชัดๆ อีกรอบได้
    locationStatusButton.MouseButton1Click:Connect(function()
        if castPosition then
            locationStatusButton.Text = string.format("Pos: X:%.1f, Y:%.1f, Z:%.1f", castPosition.X, castPosition.Y, castPosition.Z)
        else
            locationStatusButton.Text = "Location Status: Not Set Yet!"
        end
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

    fishButton.MouseButton1Click:Connect(function()
        if not castPosition then
            selectingCastPosition = true
            castButton.Text = "TAP A SPOT IN THE WORLD"
            castButton.BackgroundColor3 = Color3.fromRGB(200, 140, 30)
            statusLabel.Text = "Error: Please set position first!"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            return
        end
        
        autoFishing = not autoFishing
        if autoFishing then
            -- อัปเดตตำแหน่งล็อคล่าสุดก่อนกดเริ่ม
            local rootPart = getRootPart()
            if rootPart then
                lockedCharacterCFrame = rootPart.CFrame
            end

            fishButton.Text = "Auto Fish: ON"
            TweenService:Create(fishButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 180, 80)}):Play()
            
            -- เปลี่ยนสถานะพิกัดเป็น "สีเขียว" เมื่อเปิดทำงาน
            locationStatusButton.BackgroundColor3 = Color3.fromRGB(30, 110, 60)
            locationStatusButton.TextColor3 = Color3.fromRGB(120, 255, 150)
            locationStatusButton.Text = "Locked Pos & Boat Active"

            statusLabel.Text = "Auto Fish: Working (Active)"
            statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
        else
            fishButton.Text = "Auto Fish: OFF"
            TweenService:Create(fishButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 45, 45)}):Play()
            
            -- เปลี่ยนสถานะพิกัดกลับเป็นสีฟ้าเมื่อปิด
            locationStatusButton.BackgroundColor3 = Color3.fromRGB(35, 70, 110)
            locationStatusButton.TextColor3 = Color3.fromRGB(100, 210, 255)
            if castPosition then
                locationStatusButton.Text = string.format("Pos: X:%.0f Y:%.0f Z:%.0f", castPosition.X, castPosition.Y, castPosition.Z)
            end

            statusLabel.Text = "Auto Fish: OFF (Paused)"
            statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)

    holdButton.MouseButton1Click:Connect(function()
        if luckHoldTime == 0.3 then luckHoldTime = 0.2
        elseif luckHoldTime == 0.2 then luckHoldTime = 0.1
        else luckHoldTime = 0.3 end
        holdButton.Text = "Luck Hold: " .. luckHoldTime .. "s"
    end)

    -- ระบบเช็คและดึงตัวละครหรือเรือกลับมาที่เดิมตลอดเวลาเมื่อเปิด Auto Fish
    RunService.Heartbeat:Connect(function()
        if autoFishing and lockedCharacterCFrame then
            pcall(function()
                local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.SeatPart then
                    -- ถ้านั่งเรืออยู่ ให้ดึงตัวเรือทั้งโมเดลกลับมาที่เดิม
                    local seat = humanoid.SeatPart
                    local model = seat:FindFirstAncestorOfClass("Model")
                    if model and model.PrimaryPart then
                        model:SetPrimaryPartCFrame(lockedCharacterCFrame)
                    else
                        seat.CFrame = lockedCharacterCFrame
                    end
                else
                    -- ถ้าไม่ได้ขับเรือ ให้ดึงตัวละครหลักกลับมาที่เดิม
                    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        rootPart.CFrame = lockedCharacterCFrame
                        rootPart.Velocity = Vector3.new(0, 0, 0) -- ล้างแรงเหวี่ยงป้องกันการกระเด็น
                    end
                end
            end)
        end
    end)

    -- รันลูปตกปลาแบบต่อเนื่อง
    task.spawn(function()
        while true do
            if autoFishing then
                fishOnce()
                task.wait(0.05)
            else
                task.wait(0.1)
            end
        end
    end)

    -- ระบบ Anti-Kick / AFK
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

    print("[JET HUB] โหลดสำเร็จ: พร้อมระบบล็อคตำแหน่งและดึงเรือออโต้!")
    print("==========================================")
end)

if not success then
    warn("[JET HUB Error]: " .. tostring(initError))
end
