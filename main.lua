-- =====================================================================
-- JET HUB V3.1 - Alliance Tower Defenders
-- UI ใหม่ + Macro บันทึกจริง (Hook เสถียร) + Auto Fish + Auto Replay
-- =====================================================================
print("==========================================")
print("[JET HUB V3.1] กำลังโหลด...")

local success, initError = pcall(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local VirtualUser = game:GetService("VirtualUser")
    local CoreGui = game:GetService("CoreGui")
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local HttpService = game:GetService("HttpService")

    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- ล้าง UI เก่า
    pcall(function()
        if CoreGui:FindFirstChild("JetHubV3") then CoreGui.JetHubV3:Destroy() end
        if playerGui:FindFirstChild("JetHubV3") then playerGui.JetHubV3:Destroy() end
    end)

    -- ===================== ระบบเซฟ / โหลด =====================
    local settingsFile = "JetHub_V3_Settings.json"
    local macrosFile = "JetHub_V3_Macros.json"

    local function saveSettings(data)
        pcall(function()
            if writefile then
                writefile(settingsFile, HttpService:JSONEncode(data))
            end
        end)
    end

    local function loadSettings()
        local ok, result = pcall(function()
            if readfile and isfile and isfile(settingsFile) then
                return HttpService:JSONDecode(readfile(settingsFile))
            end
        end)
        return (ok and result) or {
            AutoMacro = false,
            AutoReplay = true,
            SelectedMacro = nil,
            LuckHold = 0.3,
            GameSpeed = 1.5
        }
    end

    local function saveMacros(macros)
        pcall(function()
            if writefile then
                writefile(macrosFile, HttpService:JSONEncode(macros))
            end
        end)
    end

    local function loadMacros()
        local ok, result = pcall(function()
            if readfile and isfile and isfile(macrosFile) then
                return HttpService:JSONDecode(readfile(macrosFile))
            end
        end)
        return (ok and result) or {}
    end

    local settings = loadSettings()
    local macros = loadMacros()

    -- ===================== ตัวแปรสถานะ =====================
    local autoFishing = false
    local castPosition = nil
    local lockedCFrame = nil
    local selectingCast = false
    local luckHoldTime = settings.LuckHold or 0.3
    local autoMacroEnabled = settings.AutoMacro or false
    local autoReplayEnabled = settings.AutoReplay \~= false
    local currentSpeed = settings.GameSpeed or 1.5
    local isRecording = false
    local currentRecordingSteps = {}
    local selectedMacroName = settings.SelectedMacro
    local placedDuringRecord = {}

    local FishingEvent = nil
    pcall(function()
        FishingEvent = ReplicatedStorage:WaitForChild("Fishing", 3):WaitForChild("Remotes", 2):WaitForChild("FishingEvent", 2)
    end)

    -- ===================== สร้าง UI =====================
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "JetHubV3"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999999
    pcall(function() if protectgui then protectgui(screenGui) end end)
    local okParent = pcall(function() screenGui.Parent = CoreGui end)
    if not okParent then screenGui.Parent = playerGui end

    -- ปุ่มลอย
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.fromOffset(48, 48)
    toggleBtn.Position = UDim2.new(0, 12, 0.35, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 90, 180)
    toggleBtn.Text = "JET"
    toggleBtn.TextColor3 = Color3.new(1,1,1)
    toggleBtn.TextSize = 13
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Active = true
    toggleBtn.Draggable = true
    toggleBtn.Parent = screenGui
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

    -- หน้าต่างหลัก
    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(300, 470)
    main.Position = UDim2.new(0.5, -150, 0.5, -235)
    main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = screenGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(70, 70, 100)
    stroke.Thickness = 1.5

    -- หัวข้อ
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 42)
    top.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    top.BorderSizePixel = 0
    top.Parent = main
    Instance.new("UICorner", top).CornerRadius = UDim.new(0, 14)
    local topFix = Instance.new("Frame", top)
    topFix.Size = UDim2.new(1, 0, 0, 10)
    topFix.Position = UDim2.new(0, 0, 1, -10)
    topFix.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    topFix.BorderSizePixel = 0

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.new(0, 14, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "JET HUB V3.1"
    title.TextColor3 = Color3.fromRGB(240, 240, 255)
    title.TextSize = 15
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = top

    local minBtn = Instance.new("TextButton")
    minBtn.Size = UDim2.fromOffset(28, 28)
    minBtn.Position = UDim2.new(1, -36, 0.5, -14)
    minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.new(1,1,1)
    minBtn.TextSize = 18
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Parent = top
    Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 7)

    -- แท็บ
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, -16, 0, 32)
    tabBar.Position = UDim2.new(0, 8, 0, 48)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = main

    local tabLayout = Instance.new("UIListLayout", tabBar)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pages = {}
    local currentTab = "Main"

    local function createTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(68, 30)
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 48)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(180, 180, 200)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.Parent = tabBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local page = Instance.new("ScrollingFrame")
        page.Name = name
        page.Size = UDim2.new(1, -16, 1, -100)
        page.Position = UDim2.new(0, 8, 0, 88)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 3
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.Visible = false
        page.Parent = main

        local list = Instance.new("UIListLayout", page)
        list.Padding = UDim.new(0, 7)
        list.HorizontalAlignment = Enum.HorizontalAlignment.Center
        list.SortOrder = Enum.SortOrder.LayoutOrder

        local pad = Instance.new("UIPadding", page)
        pad.PaddingTop = UDim.new(0, 4)
        pad.PaddingBottom = UDim.new(0, 10)

        pages[name] = {btn = btn, page = page}

        btn.MouseButton1Click:Connect(function()
            for n, p in pairs(pages) do
                p.page.Visible = (n == name)
                p.btn.BackgroundColor3 = (n == name) and Color3.fromRGB(50, 100, 180) or Color3.fromRGB(35, 35, 48)
                p.btn.TextColor3 = (n == name) and Color3.new(1,1,1) or Color3.fromRGB(180, 180, 200)
            end
            currentTab = name
        end)
        return page
    end

    local mainPage = createTab("Main")
    local fishPage = createTab("Fish")
    local macroPage = createTab("Macro")
    local playPage = createTab("Play")

    pages["Main"].page.Visible = true
    pages["Main"].btn.BackgroundColor3 = Color3.fromRGB(50, 100, 180)
    pages["Main"].btn.TextColor3 = Color3.new(1,1,1)

    -- สถานะด้านล่าง
    local statusBar = Instance.new("Frame")
    statusBar.Size = UDim2.new(1, -16, 0, 36)
    statusBar.Position = UDim2.new(0, 8, 1, -44)
    statusBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    statusBar.BorderSizePixel = 0
    statusBar.Parent = main
    Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 8)

    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(1, -12, 1, 0)
    statusText.Position = UDim2.new(0, 8, 0, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "พร้อมใช้งาน"
    statusText.TextColor3 = Color3.fromRGB(160, 255, 160)
    statusText.TextSize = 12
    statusText.Font = Enum.Font.GothamMedium
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Parent = statusBar

    local function setStatus(txt, color)
        statusText.Text = txt
        statusText.TextColor3 = color or Color3.fromRGB(200, 200, 220)
    end

    local function makeBtn(parent, text, color, height)
        height = height or 34
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(268, height)
        b.BackgroundColor3 = color
        b.Text = text
        b.TextColor3 = Color3.new(1,1,1)
        b.TextSize = 13
        b.Font = Enum.Font.GothamBold
        b.Parent = parent
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        return b
    end

    local function makeLabel(parent, text)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.fromOffset(268, 22)
        l.BackgroundTransparency = 1
        l.Text = text
        l.TextColor3 = Color3.fromRGB(160, 160, 180)
        l.TextSize = 12
        l.Font = Enum.Font.GothamMedium
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = parent
        return l
    end

    -- ===================== แท็บ MAIN =====================
    makeLabel(mainPage, "สถานะระบบ")
    local macroStatusLbl = makeLabel(mainPage, autoMacroEnabled and "Macro: เปิดอยู่" or "Macro: ปิด")
    macroStatusLbl.TextColor3 = autoMacroEnabled and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,100,100)

    local replayStatusLbl = makeLabel(mainPage, autoReplayEnabled and "Auto Replay: เปิด" or "Auto Replay: ปิด")
    replayStatusLbl.TextColor3 = autoReplayEnabled and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,100,100)

    makeLabel(mainPage, "")
    local toggleMacroMain = makeBtn(mainPage, autoMacroEnabled and "ปิด Macro ทั้งหมด" or "เปิด Macro ทั้งหมด", autoMacroEnabled and Color3.fromRGB(45,160,70) or Color3.fromRGB(160,50,50))
    local toggleReplayMain = makeBtn(mainPage, autoReplayEnabled and "ปิด Auto Replay" or "เปิด Auto Replay", autoReplayEnabled and Color3.fromRGB(45,160,70) or Color3.fromRGB(160,50,50))

    -- ===================== แท็บ FISH =====================
    makeLabel(fishPage, "ระบบตกปลา")
    local castBtn = makeBtn(fishPage, "ตั้งจุดโยนเบ็ด", Color3.fromRGB(40, 90, 170))
    local locLbl = makeBtn(fishPage, "ยังไม่ได้ตั้งจุด", Color3.fromRGB(45, 45, 60), 28)
    locLbl.TextSize = 11
    local fishBtn = makeBtn(fishPage, "Auto Fish: ปิด", Color3.fromRGB(160, 45, 45))
    local holdBtn = makeBtn(fishPage, "Luck Hold: " .. luckHoldTime .. "s", Color3.fromRGB(50, 50, 65))

    -- ===================== แท็บ MACRO =====================
    makeLabel(macroPage, "สร้างมาโครใหม่")
    local nameBox = Instance.new("TextBox")
    nameBox.Size = UDim2.fromOffset(268, 32)
    nameBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    nameBox.Text = ""
    nameBox.PlaceholderText = "ชื่อมาโคร..."
    nameBox.TextColor3 = Color3.new(1,1,1)
    nameBox.PlaceholderColor3 = Color3.fromRGB(120,120,140)
    nameBox.TextSize = 13
    nameBox.Font = Enum.Font.Gotham
    nameBox.ClearTextOnFocus = false
    nameBox.Parent = macroPage
    Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 7)

    local createMacroBtn = makeBtn(macroPage, "สร้างมาโคร", Color3.fromRGB(40, 130, 80))

    makeLabel(macroPage, "มาโครที่มีอยู่")
    local macroListFrame = Instance.new("Frame")
    macroListFrame.Size = UDim2.fromOffset(268, 110)
    macroListFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
    macroListFrame.BorderSizePixel = 0
    macroListFrame.Parent = macroPage
    Instance.new("UICorner", macroListFrame).CornerRadius = UDim.new(0, 8)

    local macroScroll = Instance.new("ScrollingFrame")
    macroScroll.Size = UDim2.new(1, -8, 1, -8)
    macroScroll.Position = UDim2.new(0, 4, 0, 4)
    macroScroll.BackgroundTransparency = 1
    macroScroll.BorderSizePixel = 0
    macroScroll.ScrollBarThickness = 3
    macroScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    macroScroll.Parent = macroListFrame

    local macroListLayout = Instance.new("UIListLayout", macroScroll)
    macroListLayout.Padding = UDim.new(0, 4)
    macroListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local selectedLbl = makeLabel(macroPage, selectedMacroName and ("เลือกอยู่: " .. selectedMacroName) or "ยังไม่ได้เลือกมาโคร")
    selectedLbl.TextColor3 = Color3.fromRGB(100, 200, 255)

    local recordBtn = makeBtn(macroPage, "อัดมาโคร", Color3.fromRGB(180, 90, 30))
    local playMacroBtn = makeBtn(macroPage, "เล่นมาโครที่เลือก", Color3.fromRGB(40, 120, 180))
    local deleteMacroBtn = makeBtn(macroPage, "ลบมาโครที่เลือก", Color3.fromRGB(150, 40, 40))

    -- ===================== แท็บ PLAY =====================
    makeLabel(playPage, "ระบบเล่นอัตโนมัติ")
    local autoReplayBtn = makeBtn(playPage, autoReplayEnabled and "Auto Replay: เปิด" or "Auto Replay: ปิด", autoReplayEnabled and Color3.fromRGB(45,160,70) or Color3.fromRGB(160,50,50))
    makeLabel(playPage, "ความเร็วเกม")
    local speedBtn = makeBtn(playPage, "ความเร็ว: " .. currentSpeed .. "x", Color3.fromRGB(60, 60, 90))

    -- ===================== ฟังก์ชันช่วย =====================
    local function refreshMacroList()
        for _, child in ipairs(macroScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local y = 0
        for name, _ in pairs(macros) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -4, 0, 26)
            b.BackgroundColor3 = (name == selectedMacroName) and Color3.fromRGB(40, 100, 60) or Color3.fromRGB(40, 40, 55)
            b.Text = name
            b.TextColor3 = Color3.new(1,1,1)
            b.TextSize = 12
            b.Font = Enum.Font.GothamMedium
            b.Parent = macroScroll
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)

            b.MouseButton1Click:Connect(function()
                selectedMacroName = name
                settings.SelectedMacro = name
                saveSettings(settings)
                selectedLbl.Text = "เลือกอยู่: " .. name
                selectedLbl.TextColor3 = Color3.fromRGB(100, 200, 255)
                refreshMacroList()
                setStatus("เลือกมาโคร: " .. name, Color3.fromRGB(100, 200, 255))
            end)
            y = y + 30
        end
        macroScroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)
    end
    refreshMacroList()

    local function getCash()
        local ls = player:FindFirstChild("leaderstats")
        if ls and ls:FindFirstChild("Cash") then
            return ls.Cash.Value
        end
        return 0
    end

    local function getRoot()
        local char = player.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart then
            local seat = hum.SeatPart
            local model = seat:FindFirstAncestorOfClass("Model")
            if model and model.PrimaryPart then
                return model.PrimaryPart, model
            end
            return seat, seat
        end
        return char:FindFirstChild("HumanoidRootPart"), char
    end

    -- ===================== ระบบ FISH =====================
    local function clickTargetUI()
        pcall(function()
            local lobby = playerGui:FindFirstChild("_LobbyUI")
            if not lobby then return end
            local folder = lobby:FindFirstChild("UPDATE: 10 UI Folder")
            if not folder then return end
            local fishContent = folder:FindFirstChild("Fish Content")
            if not fishContent then return end
            local fishing = fishContent:FindFirstChild("Fishing")
            if not fishing then return end
            local target = fishing:FindFirstChild("TargetFrame")
            if not target then return end
            local clickObj = target:FindFirstChild("Click")
            if not clickObj then return end
            local hit = clickObj:FindFirstChild("HitArea")
            if hit and getconnections then
                for _, c in pairs(getconnections(hit.MouseButton1Click)) do c:Fire() end
                for _, c in pairs(getconnections(hit.MouseButton1Down)) do c:Fire() end
                for _, c in pairs(getconnections(hit.Activated)) do c:Fire() end
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

        pcall(function() FishingEvent:FireServer("Cast", {Position = castPosition}) end)
        task.wait(0.02)
        if not autoFishing then return end
        pcall(function() FishingEvent:FireServer("LuckHold", {ClickTime = os.clock()}) end)
        task.wait(luckHoldTime)
        if not autoFishing then return end
        pcall(function() FishingEvent:FireServer("LuckRelease", {ClickTime = os.clock()}) end)
        task.wait(0.02)
        if not autoFishing then return end
        pcall(function()
            for i = 1, 17 do
                if not autoFishing then break end
                FishingEvent:FireServer("Hit", {Index = i})
                clickTargetUI()
            end
        end)
    end

    local function updateCast(pos)
        local cam = workspace.CurrentCamera
        if not cam then return end
        pcall(function()
            local ray = cam:ViewportPointToRay(pos.X, pos.Y)
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {player.Character, screenGui}
            local res = workspace:Raycast(ray.Origin, ray.Direction * 2000, params)
            if res then
                castPosition = res.Position
                local root = getRoot()
                if root then lockedCFrame = root.CFrame end
                locLbl.Text = string.format("X:%.0f Y:%.0f Z:%.0f", castPosition.X, castPosition.Y, castPosition.Z)
                locLbl.BackgroundColor3 = Color3.fromRGB(30, 70, 100)
                castBtn.Text = "เปลี่ยนจุดโยน"
                castBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
                selectingCast = false
                setStatus("ตั้งจุดโยนแล้ว", Color3.fromRGB(100, 220, 140))
            end
        end)
    end

    -- ===================== ระบบ MACRO (Hook เสถียร) =====================
    local PlaceTower, UpgradeTower
    local oldPlaceInvoke, oldUpgradeInvoke
    local placeHooked, upgradeHooked = false, false

    local function setupRemotes()
        pcall(function()
            local rf = ReplicatedStorage:FindFirstChild("RemoteFunctions")
            if rf then
                PlaceTower = rf:FindFirstChild("PlaceTower")
                UpgradeTower = rf:FindFirstChild("UpgradeTower")
            end
        end)
    end
    setupRemotes()

    local function startRecording()
        if not selectedMacroName then
            setStatus("กรุณาเลือกมาโครก่อนอัด!", Color3.fromRGB(255, 100, 100))
            return
        end
        if isRecording then return end

        setupRemotes()
        if not PlaceTower or not UpgradeTower then
            setStatus("หา Remote ไม่เจอ (รอเข้าด่านก่อน)", Color3.fromRGB(255, 150, 50))
            return
        end

        isRecording = true
        currentRecordingSteps = {}
        placedDuringRecord = {}
        recordBtn.Text = "กำลังอัด... กดอีกครั้งเพื่อหยุด"
        recordBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        setStatus("กำลังอัดมาโคร: " .. selectedMacroName, Color3.fromRGB(255, 180, 50))

        local function placeHook(self, name, cframe, ...)
            if isRecording then
                task.defer(function()
                    local cash = getCash()
                    table.insert(currentRecordingSteps, {
                        action = "Place",
                        name = tostring(name),
                        cframe = {cframe:GetComponents()},
                        reqCash = cash
                    })
                    task.wait(0.18)
                    local towers = Workspace:FindFirstChild("Towers")
                    if towers then
                        local children = towers:GetChildren()
                        if #children > #placedDuringRecord then
                            table.insert(placedDuringRecord, children[#children])
                            setStatus("บันทึก Place: " .. tostring(name) .. " สำเร็จ", Color3.fromRGB(100, 220, 140))
                        else
                            setStatus("Place: " .. tostring(name) .. " (อาจวางไม่ติด)", Color3.fromRGB(255, 180, 50))
                        end
                    end
                end)
            end
            if oldPlaceInvoke then
                return oldPlaceInvoke(self, name, cframe, ...)
            end
        end

        local function upgradeHook(self, tower, ...)
            if isRecording then
                task.defer(function()
                    local cash = getCash()
                    local idx = table.find(placedDuringRecord, tower) or (#placedDuringRecord + 1)
                    table.insert(currentRecordingSteps, {
                        action = "Upgrade",
                        towerIndex = idx,
                        reqCash = cash
                    })
                    setStatus("บันทึก Upgrade #" .. idx, Color3.fromRGB(100, 220, 140))
                end)
            end
            if oldUpgradeInvoke then
                return oldUpgradeInvoke(self, tower, ...)
            end
        end

        -- พยายามใช้ hookfunction ก่อน
        local successHook = false
        if hookfunction then
            local ok1 = pcall(function()
                oldPlaceInvoke = hookfunction(PlaceTower.InvokeServer, newcclosure(placeHook))
                placeHooked = true
            end)
            local ok2 = pcall(function()
                oldUpgradeInvoke = hookfunction(UpgradeTower.InvokeServer, newcclosure(upgradeHook))
                upgradeHooked = true
            end)
            successHook = ok1 and ok2
        end

        -- Fallback
        if not successHook then
            pcall(function()
                oldPlaceInvoke = PlaceTower.InvokeServer
                PlaceTower.InvokeServer = newcclosure(placeHook)
                placeHooked = true
            end)
            pcall(function()
                oldUpgradeInvoke = UpgradeTower.InvokeServer
                UpgradeTower.InvokeServer = newcclosure(upgradeHook)
                upgradeHooked = true
            end)
        end
    end

    local function stopRecording()
        if not isRecording then return end
        isRecording = false

        pcall(function()
            if placeHooked and PlaceTower and oldPlaceInvoke then
                PlaceTower.InvokeServer = oldPlaceInvoke
            end
        end)
        pcall(function()
            if upgradeHooked and UpgradeTower and oldUpgradeInvoke then
                UpgradeTower.InvokeServer = oldUpgradeInvoke
            end
        end)

        placeHooked = false
        upgradeHooked = false

        if #currentRecordingSteps > 0 and selectedMacroName then
            macros[selectedMacroName] = { steps = currentRecordingSteps }
            saveMacros(macros)
            setStatus("เซฟมาโคร \"" .. selectedMacroName .. "\" สำเร็จ (" .. #currentRecordingSteps .. " ขั้น)", Color3.fromRGB(80, 255, 120))
        else
            setStatus("ไม่มีข้อมูลที่อัดไว้", Color3.fromRGB(255, 150, 50))
        end

        recordBtn.Text = "อัดมาโคร"
        recordBtn.BackgroundColor3 = Color3.fromRGB(180, 90, 30)
        currentRecordingSteps = {}
        placedDuringRecord = {}
    end

    local function playMacro(name)
        if not name or not macros[name] then
            setStatus("ไม่พบมาโครที่เลือก", Color3.fromRGB(255, 100, 100))
            return
        end
        setupRemotes()
        if not PlaceTower or not UpgradeTower then
            setStatus("หา Remote ไม่เจอ", Color3.fromRGB(255, 100, 100))
            return
        end

        local steps = macros[name].steps
        setStatus("เริ่มเล่นมาโคร: " .. name, Color3.fromRGB(100, 200, 255))

        task.spawn(function()
            local placed = {}
            for i, step in ipairs(steps) do
                if game.PlaceId == 99703116573266 then break end

                while getCash() < (step.reqCash or 0) do
                    if game.PlaceId == 99703116573266 then return end
                    task.wait(0.12)
                end

                if step.action == "Place" then
                    local cf = CFrame.new(unpack(step.cframe))
                    local successPlace = false
                    for retry = 1, 3 do
                        pcall(function()
                            PlaceTower:InvokeServer(step.name, cf)
                        end)
                        task.wait(0.25)
                        local towers = Workspace:FindFirstChild("Towers")
                        if towers then
                            local ch = towers:GetChildren()
                            if #ch > #placed then
                                table.insert(placed, ch[#ch])
                                successPlace = true
                                break
                            end
                        end
                        task.wait(0.15)
                    end
                    if not successPlace then
                        setStatus("วาง " .. step.name .. " ไม่สำเร็จ (ข้าม)", Color3.fromRGB(255, 150, 50))
                    end
                elseif step.action == "Upgrade" then
                    local t = placed[step.towerIndex]
                    if t and t.Parent then
                        pcall(function()
                            UpgradeTower:InvokeServer(t)
                        end)
                    end
                end
                task.wait(0.22)
            end
            setStatus("เล่นมาโคร \"" .. name .. "\" เสร็จแล้ว", Color3.fromRGB(80, 255, 120))
        end)
    end

    -- ===================== ระบบ Auto Replay + Matchmaking =====================
    local function clickGui(obj)
        if not obj then return false end
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            if getconnections then
                for _, c in pairs(getconnections(obj.MouseButton1Click)) do c:Fire() end
                for _, c in pairs(getconnections(obj.Activated)) do c:Fire() end
            end
            pcall(function() firesignal(obj.MouseButton1Click) end)
            return true
        end
        return false
    end

    -- ===================== Event ปุ่ม =====================
    local uiVisible = true
    toggleBtn.MouseButton1Click:Connect(function()
        uiVisible = not uiVisible
        main.Visible = uiVisible
    end)

    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        minBtn.Text = minimized and "+" or "−"
        local target = minimized and UDim2.fromOffset(300, 42) or UDim2.fromOffset(300, 470)
        TweenService:Create(main, TweenInfo.new(0.25), {Size = target}):Play()
        for _, p in pairs(pages) do p.page.Visible = not minimized and (p.page.Name == currentTab) end
        tabBar.Visible = not minimized
        statusBar.Visible = not minimized
    end)

    -- Main
    toggleMacroMain.MouseButton1Click:Connect(function()
        autoMacroEnabled = not autoMacroEnabled
        settings.AutoMacro = autoMacroEnabled
        saveSettings(settings)
        toggleMacroMain.Text = autoMacroEnabled and "ปิด Macro ทั้งหมด" or "เปิด Macro ทั้งหมด"
        toggleMacroMain.BackgroundColor3 = autoMacroEnabled and Color3.fromRGB(45,160,70) or Color3.fromRGB(160,50,50)
        macroStatusLbl.Text = autoMacroEnabled and "Macro: เปิดอยู่" or "Macro: ปิด"
        macroStatusLbl.TextColor3 = autoMacroEnabled and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,100,100)
        setStatus(autoMacroEnabled and "เปิด Macro แล้ว" or "ปิด Macro แล้ว")
    end)

    toggleReplayMain.MouseButton1Click:Connect(function()
        autoReplayEnabled = not autoReplayEnabled
        settings.AutoReplay = autoReplayEnabled
        saveSettings(settings)
        toggleReplayMain.Text = autoReplayEnabled and "ปิด Auto Replay" or "เปิด Auto Replay"
        toggleReplayMain.BackgroundColor3 = autoReplayEnabled and Color3.fromRGB(45,160,70) or Color3.fromRGB(160,50,50)
        replayStatusLbl.Text = autoReplayEnabled and "Auto Replay: เปิด" or "Auto Replay: ปิด"
        replayStatusLbl.TextColor3 = autoReplayEnabled and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,100,100)
        autoReplayBtn.Text = autoReplayEnabled and "Auto Replay: เปิด" or "Auto Replay: ปิด"
        autoReplayBtn.BackgroundColor3 = autoReplayEnabled and Color3.fromRGB(45,160,70) or Color3.fromRGB(160,50,50)
    end)

    -- Fish
    castBtn.MouseButton1Click:Connect(function()
        selectingCast = true
        castBtn.Text = "แตะจุดในโลก"
        castBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 30)
        setStatus("เลือกจุดโยนเบ็ด...", Color3.fromRGB(255, 220, 100))
    end)

    UserInputService.TouchTap:Connect(function(touches, processed)
        if selectingCast and not processed and touches[1] then
            updateCast(touches[1])
        end
    end)
    UserInputService.InputBegan:Connect(function(input, processed)
        if selectingCast and not processed and input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateCast(input.Position)
        end
    end)

    fishBtn.MouseButton1Click:Connect(function()
        if not castPosition then
            selectingCast = true
            castBtn.Text = "แตะจุดในโลก"
            castBtn.BackgroundColor3 = Color3.fromRGB(200, 140, 30)
            setStatus("ต้องตั้งจุดโยนก่อน!", Color3.fromRGB(255, 100, 100))
            return
        end
        autoFishing = not autoFishing
        if autoFishing then
            local root = getRoot()
            if root then lockedCFrame = root.CFrame end
            fishBtn.Text = "Auto Fish: เปิด"
            fishBtn.BackgroundColor3 = Color3.fromRGB(45, 160, 70)
            setStatus("Auto Fish ทำงาน", Color3.fromRGB(80, 255, 120))
        else
            fishBtn.Text = "Auto Fish: ปิด"
            fishBtn.BackgroundColor3 = Color3.fromRGB(160, 45, 45)
            setStatus("หยุด Auto Fish", Color3.fromRGB(255, 100, 100))
        end
    end)
        
    holdBtn.MouseButton1Click:Connect(function()
        if luckHoldTime == 0.3 then luckHoldTime = 0.2
        elseif luckHoldTime == 0.2 then luckHoldTime = 0.1
        else luckHoldTime = 0.3 end
        settings.LuckHold = luckHoldTime
        saveSettings(settings)
        holdBtn.Text = "Luck Hold: " .. luckHoldTime .. "s"
    end)

    -- Macro
    createMacroBtn.MouseButton1Click:Connect(function()
        local name = nameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
        if name == "" then
            setStatus("ใส่ชื่อมาโครก่อน", Color3.fromRGB(255, 100, 100))
            return
        end
        if macros[name] then
            setStatus("มีชื่อนี้แล้ว", Color3.fromRGB(255, 150, 50))
            return
        end
        macros[name] = { steps = {} }
        saveMacros(macros)
        selectedMacroName = name
        settings.SelectedMacro = name
        saveSettings(settings)
        nameBox.Text = ""
        selectedLbl.Text = "เลือกอยู่: " .. name
        refreshMacroList()
        setStatus("สร้างมาโคร \"" .. name .. "\" สำเร็จ", Color3.fromRGB(80, 255, 120))
    end)

    recordBtn.MouseButton1Click:Connect(function()
        if isRecording then
            stopRecording()
        else
            startRecording()
        end
    end)

    playMacroBtn.MouseButton1Click:Connect(function()
        if selectedMacroName then
            playMacro(selectedMacroName)
        else
            setStatus("เลือกมาโครก่อน", Color3.fromRGB(255, 100, 100))
        end
    end)

    deleteMacroBtn.MouseButton1Click:Connect(function()
        if not selectedMacroName then return end
        macros[selectedMacroName] = nil
        saveMacros(macros)
        setStatus("ลบมาโคร \"" .. selectedMacroName .. "\" แล้ว", Color3.fromRGB(255, 150, 50))
        selectedMacroName = nil
        settings.SelectedMacro = nil
        saveSettings(settings)
        selectedLbl.Text = "ยังไม่ได้เลือกมาโคร"
        refreshMacroList()
    end)

    -- Play
    autoReplayBtn.MouseButton1Click:Connect(function()
        autoReplayEnabled = not autoReplayEnabled
        settings.AutoReplay = autoReplayEnabled
        saveSettings(settings)
        autoReplayBtn.Text = autoReplayEnabled and "Auto Replay: เปิด" or "Auto Replay: ปิด"
        autoReplayBtn.BackgroundColor3 = autoReplayEnabled and Color3.fromRGB(45,160,70) or Color3.fromRGB(160,50,50)
        toggleReplayMain.Text = autoReplayEnabled and "ปิด Auto Replay" or "เปิด Auto Replay"
        toggleReplayMain.BackgroundColor3 = autoReplayEnabled and Color3.fromRGB(45,160,70) or Color3.fromRGB(160,50,50)
        replayStatusLbl.Text = autoReplayEnabled and "Auto Replay: เปิด" or "Auto Replay: ปิด"
        replayStatusLbl.TextColor3 = autoReplayEnabled and Color3.fromRGB(80,255,120) or Color3.fromRGB(255,100,100)
    end)

    speedBtn.MouseButton1Click:Connect(function()
        if currentSpeed == 1.5 then currentSpeed = 2
        elseif currentSpeed == 2 then currentSpeed = 1
        else currentSpeed = 1.5 end
        settings.GameSpeed = currentSpeed
        saveSettings(settings)
        speedBtn.Text = "ความเร็ว: " .. currentSpeed .. "x"
        pcall(function()
            local ev = ReplicatedStorage:FindFirstChild("RemoteEvents")
            if ev and ev:FindFirstChild("SetGameSpeed") then
                ev.SetGameSpeed:FireServer(currentSpeed)
            end
        end)
    end)

    -- ===================== ลูปทำงาน =====================
    RunService.Heartbeat:Connect(function()
        if autoFishing and lockedCFrame then
            pcall(function()
                local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                if hum and hum.SeatPart then
                    local seat = hum.SeatPart
                    local model = seat:FindFirstAncestorOfClass("Model")
                    if model and model.PrimaryPart then
                        model:SetPrimaryPartCFrame(lockedCFrame)
                    else
                        seat.CFrame = lockedCFrame
                    end
                else
                    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.CFrame = lockedCFrame
                        root.AssemblyLinearVelocity = Vector3.zero
                    end
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            if autoFishing then
                fishOnce()
                task.wait(0.05)
            else
                task.wait(0.15)
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(40)
            pcall(function()
                VirtualUser:Button1Down(Vector2.new(0, 0))
                task.wait(0.1)
                VirtualUser:Button1Up(Vector2.new(0, 0))
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(1.2)
            if not autoMacroEnabled and not autoReplayEnabled then continue end

            pcall(function()
                if game.PlaceId == 99703116573266 and autoMacroEnabled then
                    local p1 = playerGui:FindFirstChild("_MainUI")
                    if p1 then
                        local use = p1:FindFirstChild("DownSide") and p1.DownSide:FindFirstChild("Select") and p1.DownSide.Select:FindFirstChild("Play") and p1.DownSide.Select.Play:FindFirstChild("Use")
                        if use then clickGui(use) end
                    end
                    task.wait(2)

                    local m1 = playerGui:FindFirstChild("MatchmakingUI")
                    if m1 then
                        local use = m1:FindFirstChild("Frame") and m1.Frame:FindFirstChild("Selector") and m1.Frame.Selector:FindFirstChild("Classic") and m1.Frame.Selector.Classic:FindFirstChild("Move") and m1.Frame.Selector.Classic.Move:FindFirstChild("Use")
                        if use then clickGui(use) end
                    end
                    task.wait(2)

                    local m2 = playerGui:FindFirstChild("MatchmakingUI")
                    if m2 then
                        local mapUse = m2:FindFirstChild("MatchMaking") and m2.MatchMaking:FindFirstChild("CurrentFrame") and m2.MatchMaking.CurrentFrame:FindFirstChild("Found") and m2.MatchMaking.CurrentFrame.Found:FindFirstChild("MapsList") and m2.MatchMaking.CurrentFrame.Found.MapsList:FindFirstChild("Camera Lab") and m2.MatchMaking.CurrentFrame.Found.MapsList["Camera Lab"]:FindFirstChild("Move") and m2.MatchMaking.CurrentFrame.Found.MapsList["Camera Lab"].Move:FindFirstChild("Use")
                        if mapUse then clickGui(mapUse) end
                    end
                    task.wait(2)

                    while game.PlaceId == 99703116573266 and autoMacroEnabled do
                        local m3 = playerGui:FindFirstChild("MatchmakingUI")
                        if m3 then
                            local found = m3:FindFirstChild("MatchMaking") and m3.MatchMaking:FindFirstChild("CurrentFrame") and m3.MatchMaking.CurrentFrame:FindFirstChild("Found") and m3.MatchMaking.CurrentFrame.Found:FindFirstChild("DownSide") and m3.MatchMaking.CurrentFrame.Found.DownSide:FindFirstChild("Selector") and m3.MatchMaking.CurrentFrame.Found.DownSide.Selector:FindFirstChild("Found") and m3.MatchMaking.CurrentFrame.Found.DownSide.Selector.Found:FindFirstChild("Move") and m3.MatchMaking.CurrentFrame.Found.DownSide.Selector.Found.Move:FindFirstChild("Use")
                            if found then clickGui(found) end
                        end
                        task.wait(1)
                    end
                end

                if autoReplayEnabled then
                    local endUI = playerGui:FindFirstChild("GameEndUI")
                    if endUI then
                        local replay = endUI:FindFirstChild("NewFrame") and endUI.NewFrame:FindFirstChild("Selector") and endUI.NewFrame.Selector:FindFirstChild("Replay") and endUI.NewFrame.Selector.Replay:FindFirstChild("Use")
                        if replay then
                            while playerGui:FindFirstChild("GameEndUI") and autoReplayEnabled do
                                clickGui(replay)
                                task.wait(0.4)
                            end
                        end
                    end
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(2)
            if game.PlaceId \~= 99703116573266 then
                pcall(function()
                    local ev = ReplicatedStorage:FindFirstChild("RemoteEvents")
                    if ev and ev:FindFirstChild("SetGameSpeed") then
                        ev.SetGameSpeed:FireServer(currentSpeed)
                    end
                end)
            end
        end
    end)

    print("[JET HUB V3.1] โหลดสำเร็จ!")
    print("==========================================")
    setStatus("JET HUB V3.1 พร้อมใช้งาน", Color3.fromRGB(80, 255, 120))
end)

if not success then
    warn("[JET HUB Error]: " .. tostring(initError))
end
