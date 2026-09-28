-- =====================================================================
-- JET HUB: ALLIANCE TOWER DEFENDERS V2 (FISH + FULL MACRO AUTO PLAY)
-- =====================================================================
print("==========================================")
print("[JET HUB] เริ่มต้นรันสคริปต์รวม (Fish + Macro Automation)...")

local success, initError = pcall(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local VirtualUser = game:GetService("VirtualUser")
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local TeleportService = game:GetService("TeleportService")

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- ล้าง UI เก่า
    pcall(function()
        if CoreGui:FindFirstChild("JetHubAllianceV2") then CoreGui.JetHubAllianceV2:Destroy() end
        if playerGui:FindFirstChild("JetHubAllianceV2") then playerGui.JetHubAllianceV2:Destroy() end
    end)

    -- ตรวจสอบ Remote ตกปลา
    local FishingEvent = nil
    pcall(function()
        FishingEvent = ReplicatedStorage:WaitForChild("Fishing", 2):WaitForChild("Remotes", 2):WaitForChild("FishingEvent", 2)
    end)

    -- ตัวแปรสถานะหลัก
    local autoFishing = false
    local castPosition = nil
    local lockedCharacterCFrame = nil 
    local selectingCastPosition = false
    local luckHoldTime = 0.3

    local autoMacroEnabled = false -- สถานะเปิด/ปิดระบบมาโครฟาร์ม

    -- สร้าง ScreenGui หลัก
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "JetHubAllianceV2"
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

    -- หน้าต่างหลัก (Main Frame) ขยายความสูงเพิ่มรองรับปุ่ม Macro
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.fromOffset(280, 440)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -220)
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
    titleText.Text = "JET HUB - TD V2"
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
    container.CanvasSize = UDim2.new(0, 0, 0, 410)
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

    -- กล่อง Status รวม
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
    antiKickStatus.Text = "Macro Farm: OFF"
    antiKickStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    antiKickStatus.TextSize = 11
    antiKickStatus.Font = Enum.Font.GothamMedium
    antiKickStatus.TextXAlignment = Enum.TextXAlignment.Left
    antiKickStatus.Parent = statusBox

    -- ปุ่มฟังก์ชันตกปลาเดิม
    local castButton = createButton("CastButton", "SET CAST LOCATION", Color3.fromRGB(45, 85, 160))
    
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

    -- ปุ่มเปิด/ปิด ระบบ Macro Farm อัตโนมัติ
    local macroButton = createButton("MacroButton", "Macro Farm: OFF", Color3.fromRGB(180, 45, 45))

    -- ปุ่มลอยเปิด-ปิด UI
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
        local targetSize = minimized and UDim2.fromOffset(280, 40) or UDim2.fromOffset(280, 440)
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = targetSize}):Play()
        container.Visible = not minimized
    end)

    -- ฟังก์ชันดึงตำแหน่ง RootPart
    local function getRootPart()
        local character = player.Character
        if not character then return nil end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.SeatPart then
            local seat = humanoid.SeatPart
            local model = seat:FindFirstAncestorOfClass("Model")
            if model and model.PrimaryPart then
                return model.PrimaryPart, model
            else
                return seat, seat
            end
        end
        
        return character:FindFirstChild("HumanoidRootPart"), character
    end

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
                
                local rootPart, model = getRootPart()
                if rootPart then
                    lockedCharacterCFrame = rootPart.CFrame
                end

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
            local rootPart = getRootPart()
            if rootPart then
                lockedCharacterCFrame = rootPart.CFrame
            end

            fishButton.Text = "Auto Fish: ON"
            TweenService:Create(fishButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 180, 80)}):Play()
            
            locationStatusButton.BackgroundColor3 = Color3.fromRGB(30, 110, 60)
            locationStatusButton.TextColor3 = Color3.fromRGB(120, 255, 150)
            locationStatusButton.Text = "Locked Pos & Boat Active"

            statusLabel.Text = "Auto Fish: Working (Active)"
            statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
        else
            fishButton.Text = "Auto Fish: OFF"
            TweenService:Create(fishButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 45, 45)}):Play()
            
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

    -- ปุ่มกดเปิด/ปิดระบบ Macro Farm
    macroButton.MouseButton1Click:Connect(function()
        autoMacroEnabled = not autoMacroEnabled
        if autoMacroEnabled then
            macroButton.Text = "Macro Farm: ON"
            TweenService:Create(macroButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 180, 80)}):Play()
            antiKickStatus.Text = "Macro Farm: Active"
            antiKickStatus.TextColor3 = Color3.fromRGB(80, 255, 120)
        else
            macroButton.Text = "Macro Farm: OFF"
            TweenService:Create(macroButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 45, 45)}):Play()
            antiKickStatus.Text = "Macro Farm: OFF"
            antiKickStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end)

    -- ระบบล็อคตำแหน่งตกปลา / เรือ
    RunService.Heartbeat:Connect(function()
        if autoFishing and lockedCharacterCFrame then
            pcall(function()
                local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if humanoid and humanoid.SeatPart then
                    local seat = humanoid.SeatPart
                    local model = seat:FindFirstAncestorOfClass("Model")
                    if model and model.PrimaryPart then
                        model:SetPrimaryPartCFrame(lockedCharacterCFrame)
                    else
                        seat.CFrame = lockedCharacterCFrame
                    end
                else
                    local rootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        rootPart.CFrame = lockedCharacterCFrame
                        rootPart.Velocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        end
    end)

    -- ลูปตกปลา
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

    -- ลูป Anti-Kick
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

    -- =====================================================================
    -- 🤖 ระบบ MACRO AUTOMATION (Lobby Matchmaking & In-Game Placement)
    -- =====================================================================
    
    -- ฟังก์ชันช่วยจำลองการคลิกปุ่มผ่าน UI Path
    local function clickGuiObject(uiObject)
        if not uiObject then return false end
        if uiObject:IsA("TextButton") or uiObject:IsA("ImageButton") then
            if getconnections then
                for _, conn in pairs(getconnections(uiObject.MouseButton1Click)) do conn:Fire() end
                for _, conn in pairs(getconnections(uiObject.Activated)) do conn:Fire() end
            end
            -- เผื่อเกมใช้ระบบ Input หรือ MouseClick ทั่วไป
            pcall(function()
                firesignal(uiObject.MouseButton1Click)
            end)
            return true
        end
        return false
    end

    -- 1. ระบบจัดการหน้าล็อบบี้ (Matchmaking & Map Navigation)
    task.spawn(function()
        while true do
            task.wait(1)
            if autoMacroEnabled then
                pcall(function()
                    local currentPlaceId = game.PlaceId
                    -- ถ้าอยู่ในแมพหลักล็อบบี้ (99703116573266)
                    if currentPlaceId == 99703116573266 then
                        print("[Macro] อยู่ในแมพหลัก - รอ 1 นาทีตามเงื่อนไข...")
                        task.wait(60) -- รอ 1 นาที
                        if not autoMacroEnabled then return end

                        -- กดปุ่ม: Play (Path: _MainUI.DownSide.Select.Play.Use)
                        local p1 = playerGui:FindFirstChild("_MainUI")
                        if p1 then
                            local useBtn = p1:FindFirstChild("DownSide") and p1.DownSide:FindFirstChild("Select") and p1.DownSide.Select:FindFirstChild("Play") and p1.DownSide.Select.Play:FindFirstChild("Use")
                            if useBtn then clickGuiObject(useBtn) end
                        end
                        task.wait(3)

                        -- กดปุ่ม: Classic (Path: MatchmakingUI.Frame.Selector.Classic.Move.Use)
                        local m1 = playerGui:FindFirstChild("MatchmakingUI")
                        if m1 then
                            local useBtn = m1:FindFirstChild("Frame") and m1.Frame:FindFirstChild("Selector") and m1.Frame.Selector:FindFirstChild("Classic") and m1.Frame.Selector.Classic:FindFirstChild("Move") and m1.Frame.Selector.Classic.Move:FindFirstChild("Use")
                            if useBtn then clickGuiObject(useBtn) end
                        end
                        task.wait(3)

                        -- กดปุ่มเลือกแมพ Camera Lab
                        local m2 = playerGui:FindFirstChild("MatchmakingUI")
                        if m2 then
                            local mapUse = m2:FindFirstChild("MatchMaking") and m2.MatchMaking:FindFirstChild("CurrentFrame") and m2.MatchMaking.CurrentFrame:FindFirstChild("Found") and m2.MatchMaking.CurrentFrame.Found:FindFirstChild("MapsList") and m2.MatchMaking.CurrentFrame.Found.MapsList:FindFirstChild("Camera Lab") and m2.MatchMaking.CurrentFrame.Found.MapsList["Camera Lab"]:FindFirstChild("Move") and m2.MatchMaking.CurrentFrame.Found.MapsList["Camera Lab"].Move:FindFirstChild("Use")
                            if mapUse then clickGuiObject(mapUse) end
                        end
                        task.wait(3)

                        -- กดย้ำๆ ที่ปุ่ม Found.Move.Use จนกว่าจะย้ายแมพ
                        while game.PlaceId == 99703116573266 and autoMacroEnabled do
                            pcall(function()
                                local m3 = playerGui:FindFirstChild("MatchmakingUI")
                                if m3 then
                                    local foundUse = m3:FindFirstChild("MatchMaking") and m3.MatchMaking:FindFirstChild("CurrentFrame") and m3.MatchMaking.CurrentFrame:FindFirstChild("Found") and m3.MatchMaking.CurrentFrame.Found:FindFirstChild("DownSide") and m3.MatchMaking.CurrentFrame.Found.DownSide:FindFirstChild("Selector") and m3.MatchMaking.CurrentFrame.Found.DownSide.Selector:FindFirstChild("Found") and m3.MatchMaking.CurrentFrame.Found.DownSide.Selector.Found:FindFirstChild("Move") and m3.MatchMaking.CurrentFrame.Found.DownSide.Selector.Found.Move:FindFirstChild("Use")
                                    if foundUse then clickGuiObject(foundUse) end
                                end
                            end)
                            task.wait(1)
                        end
                    end

                    -- ถ้าอยู่ในหน้าจบเกม (GameEndUI Replay)
                    local endUI = playerGui:FindFirstChild("GameEndUI")
                    if endUI then
                        local replayUse = endUI:FindFirstChild("NewFrame") and endUI.NewFrame:FindFirstChild("Selector") and endUI.NewFrame.Selector:FindFirstChild("Replay") and endUI.NewFrame.Selector.Replay:FindFirstChild("Use")
                        if replayUse then
                            print("[Macro] ตรวจพบหน้าจบเกม - กำลังกดรีเพลย์รัวๆ...")
                            while playerGui:FindFirstChild("GameEndUI") and autoMacroEnabled do
                                clickGuiObject(replayUse)
                                task.wait(0.5)
                            end
                        end
                    end
                end)
            end
        end
    end)

    -- 2. ระบบ Macro วางยูนิตและอัปเกรดอัตโนมัติ (ทำงานเมื่อเข้าสู่ด่านเล่นจริง)
    task.spawn(function()
        -- ตรวจสอบว่าไม่ได้อยู่ในแมพหลัก (แสดงว่าอยู่ในเกมเล่นจริง)
        while true do
            task.wait(1)
            if autoMacroEnabled and game.PlaceId ~= 99703116573266 then
                -- รอให้โหลด Remotes ให้พร้อม
                local remoteFuncs = ReplicatedStorage:WaitForChild("RemoteFunctions", 5)
                if remoteFuncs then
                    local PlaceTower = remoteFuncs:WaitForChild("PlaceTower", 5)
                    local UpgradeTower = remoteFuncs:WaitForChild("UpgradeTower", 5)

                    -- ระบบ Auto Speed 1.5x
                    task.spawn(function()
                        local speedRemote = ReplicatedStorage:FindFirstChild("RemoteEvents") 
                            and ReplicatedStorage.RemoteEvents:FindFirstChild("SetGameSpeed")
                        while autoMacroEnabled and game.PlaceId ~= 99703116573266 do
                            if speedRemote then
                                pcall(function() speedRemote:FireServer(1.5) end)
                            end
                            task.wait(1.5)
                        end
                    end)

                    -- ลำดับคิวมาโครที่คุณต้องการ
                    local macroQueue = {
                        -- 🟢 Plunger Camera Man 4 ตัวแรก
                        { action = "Place", name = "Plunger Camera Man", reqCash = 250, cframe = CFrame.new(-25.3438377, -4.66457939, -0.644769669, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
                        { action = "Place", name = "Plunger Camera Man", reqCash = 250, cframe = CFrame.new(-23.2532196, -4.66457939, 0.197704315, -0.0905106068, 0, -0.995895445, 0, 1, 0, 0.995895445, 0, -0.0905106068) },
                        { action = "Place", name = "Plunger Camera Man", reqCash = 250, cframe = CFrame.new(-25.036665, -4.66457939, 1.02075291, 1, 0, 0, 0, 1, 0, 0, 0, 1) },
                        { action = "Place", name = "Plunger Camera Man", reqCash = 250, cframe = CFrame.new(-23.1003609, -4.66457939, -2.01315594, 1, 0, 0, 0, 1, 0, 0, 0, 1) },

                        -- 🔵 อัปเกรด Plunger ตัวที่ 1-4 ให้ตัน
                        { action = "Upgrade", towerIndex = 1, reqCash = 450 },
                        { action = "Upgrade", towerIndex = 1, reqCash = 650 },
                        { action = "Upgrade", towerIndex = 1, reqCash = 900 },
                        
                        { action = "Upgrade", towerIndex = 2, reqCash = 450 },
                        { action = "Upgrade", towerIndex = 2, reqCash = 650 },
                        { action = "Upgrade", towerIndex = 2, reqCash = 900 },
                        
                        { action = "Upgrade", towerIndex = 3, reqCash = 450 },
                        { action = "Upgrade", towerIndex = 3, reqCash = 650 },
                        { action = "Upgrade", towerIndex = 3, reqCash = 900 },
                        
                        { action = "Upgrade", towerIndex = 4, reqCash = 450 },
                        { action = "Upgrade", towerIndex = 4, reqCash = 650 },
                        { action = "Upgrade", towerIndex = 4, reqCash = 900 },

                        -- 🟣 วาง Titan TV Man ทีละตัว แล้วอัปเกรดให้ตันทันที
                        { action = "Place", name = "Titan TV Man", reqCash = 2000, cframe = CFrame.new(-23.0490818, -2.43174171, -7.89207458, -0.330505848, 0, 0.943803906, 0, 1, 0, -0.943803906, 0, -0.330505848) },
                        { action = "Upgrade", towerIndex = 5, reqCash = 1400 },
                        { action = "Upgrade", towerIndex = 5, reqCash = 1900 },
                        { action = "Upgrade", towerIndex = 5, reqCash = 2500 },

                        { action = "Place", name = "Titan TV Man", reqCash = 2000, cframe = CFrame.new(-22.9510784, -2.43174171, -8.84347725, 0.767417371, 0, 0.641147852, 0, 1, 0, -0.641147852, 0, 0.767417371) },
                        { action = "Upgrade", towerIndex = 6, reqCash = 1400 },
                        { action = "Upgrade", towerIndex = 6, reqCash = 1900 },
                        { action = "Upgrade", towerIndex = 6, reqCash = 2500 },

                        { action = "Place", name = "Titan TV Man", reqCash = 2000, cframe = CFrame.new(-22.9731979, -2.43174171, -9.24433517, 0.974968731, 0, 0.222342134, 0, 1, 0, -0.222342134, 0, 0.974968731) },
                        { action = "Upgrade", towerIndex = 7, reqCash = 1400 },
                        { action = "Upgrade", towerIndex = 7, reqCash = 1900 },
                        { action = "Upgrade", towerIndex = 7, reqCash = 2500 },

                        { action = "Place", name = "Titan TV Man", reqCash = 2000, cframe = CFrame.new(-22.5559883, -2.43174171, -8.53898335, 0.994986653, 0, 0.100007981, 0, 1, 0, -0.100007981, 0, 0.994986653) },
                        { action = "Upgrade", towerIndex = 8, reqCash = 1400 },
                        { action = "Upgrade", towerIndex = 8, reqCash = 1900 },
                        { action = "Upgrade", towerIndex = 8, reqCash = 2500 },

                        { action = "Place", name = "Titan TV Man", reqCash = 2000, cframe = CFrame.new(-23.0528221, -2.43174171, -8.40134811, 0.993119001, 0, 0.117109641, 0, 1, 0, -0.117109641, 0, 0.993119001) },
                        { action = "Upgrade", towerIndex = 9, reqCash = 1400 },
                        { action = "Upgrade", towerIndex = 9, reqCash = 1900 },
                        { action = "Upgrade", towerIndex = 9, reqCash = 2500 },

                        { action = "Place", name = "Titan TV Man", reqCash = 2000, cframe = CFrame.new(-22.0240097, -2.43174171, -8.32596302, 0.98583287, 0, 0.167730689, 0, 1, 0, -0.167730689, 0, 0.98583287) },
                        { action = "Upgrade", towerIndex = 10, reqCash = 1400 },
                        { action = "Upgrade", towerIndex = 10, reqCash = 1900 },
                        { action = "Upgrade", towerIndex = 10, reqCash = 2500 },
                    }

                    local function getCash()
                        local leaderstats = player:FindFirstChild("leaderstats")
                        if leaderstats and leaderstats:FindFirstChild("Cash") then
                            return leaderstats.Cash.Value
                        end
                        return 0
                    end

                    local function waitForCash(requiredAmount)
                        while autoMacroEnabled and getCash() < requiredAmount do
                            task.wait(0.2)
                        end
                    end

                    print("🚀 [Macro] เริ่มต้นรันคิววางยูนิตในด่าน...")
                    local placedTowersList = {}

                    for stepIndex, step in ipairs(macroQueue) do
                        if not autoMacroEnabled or game.PlaceId == 99703116573266 then break end
                        
                        waitForCash(step.reqCash)
                        if not autoMacroEnabled then break end

                        if step.action == "Place" then
                            pcall(function()
                                PlaceTower:InvokeServer(step.name, step.cframe)
                            end)
                            task.wait(0.4)
                            local towers = Workspace:FindFirstChild("Towers") and Workspace.Towers:GetChildren() or {}
                            if #towers > 0 then
                                table.insert(placedTowersList, towers[#towers])
                            end
                        elseif step.action == "Upgrade" then
                            local targetIndex = step.towerIndex
                            local targetTower = placedTowersList[targetIndex]
                            if targetTower and targetTower.Parent then
                                pcall(function()
                                    UpgradeTower:InvokeServer(targetTower)
                                end)
                            end
                        end
                        task.wait(0.3)
                    end
                    print("🎉 [Macro] จบคิวการวางยูนิตในตานี้แล้ว!")
                    break -- ทำงานจบตานี้แล้วรอจนกว่าจะรีจอยหรือเล่นใหม่
                end
            end
        end
    end)

    print("[JET HUB V2] โหลดสำเร็จ: เมนูหลักรวมระบบตกปลาและ Macro Automation เรียบร้อย!")
    print("==========================================")
end)

if not success then
    warn("[JET HUB Error]: " .. tostring(initError))
end
