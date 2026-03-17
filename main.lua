local player = game.Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local TP = game:GetService("TeleportService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- [แก้ไขแล้ว] ชื่อไฟล์จะเปลี่ยนไปตาม ID ของผู้เล่นแต่ละคน ทำให้ฟาร์ม 2 จอแล้วเซฟไม่ทับกัน
local fileName = "Gemini_" .. player.UserId .. ".json"

------------------------------------------------
-- CONFIG & AUTO-RUN SYSTEM
------------------------------------------------
_G.Config = {
    Zone = "Zone1",
    SacPet = "Pet Name",
    Toggles = {},
    SelectedBosses = {}
}

local allToggles = {}

local function SaveConfig()
    local data = HttpService:JSONEncode(_G.Config)
    writefile(fileName, data)
end

------------------------------------------------
-- THEME & UI UI STRUCTURE
------------------------------------------------
local theme = {
    Background = Color3.fromRGB(15, 15, 15),
    SideBar = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(255, 150, 0),
    Text = Color3.fromRGB(255, 255, 255),
    Button = Color3.fromRGB(30, 30, 30)
}

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "GeminiHub_Ultimate"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 520, 0, 400)
main.Position = UDim2.new(0.5, -260, 0.5, -200)
main.BackgroundColor3 = theme.Background
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

-- Sidebar
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 130, 1, 0)
sidebar.BackgroundColor3 = theme.SideBar
Instance.new("UICorner", sidebar)

local container = Instance.new("Frame", main)
container.Size = UDim2.new(1, -140, 1, -20)
container.Position = UDim2.new(0, 135, 0, 10)
container.BackgroundTransparency = 1

local tabs = {}
local function createTab(name)
    local f = Instance.new("ScrollingFrame", container)
    f.Size = UDim2.new(1, 0, 1, 0)
    f.BackgroundTransparency = 1
    f.Visible = false
    f.ScrollBarThickness = 2
    f.CanvasSize = UDim2.new(0, 0, 0, 750)
    Instance.new("UIListLayout", f).Padding = UDim.new(0, 8)
    tabs[name] = f
    return f
end

local farmTab = createTab("Farm")
local hatchTab = createTab("Hatch")
local sacTab = createTab("Sacrifice")
local camTab = createTab("Camera")
local setTab = createTab("Setting")

local function showTab(name)
    for k, v in pairs(tabs) do v.Visible = (k == name) end
end
showTab("Farm")

local function sideBtn(name, order)
    local b = Instance.new("TextButton", sidebar)
    b.Size = UDim2.new(1, -10, 0, 40)
    b.Position = UDim2.new(0, 5, 0, (order * 45) + 15)
    b.Text = name
    b.BackgroundColor3 = theme.Button
    b.TextColor3 = theme.Text
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() showTab(name) end)
end
sideBtn("Farm", 0); sideBtn("Hatch", 1); sideBtn("Sacrifice", 2); sideBtn("Camera", 3); sideBtn("Setting", 4)

------------------------------------------------
-- UI TOOLS (TOGGLES)
------------------------------------------------
local function makeToggle(text, parent, configName, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.Text = text .. ": OFF"
    b.BackgroundColor3 = theme.Button
    b.TextColor3 = theme.Text
    b.Font = Enum.Font.Gotham
    Instance.new("UICorner", b)
    
    local function update(val)
        _G.Config.Toggles[configName] = val
        b.Text = text .. (val and ": ON" or ": OFF")
        b.BackgroundColor3 = val and theme.Accent or theme.Button
        if val then task.spawn(function() callback(true) end) end
    end
    
    b.MouseButton1Click:Connect(function() update(not _G.Config.Toggles[configName]) end)
    allToggles[configName] = update
    return update
end

------------------------------------------------
-- 1. FARM TAB (FOOD, EGG, BOSS)
------------------------------------------------
local zoneInput = Instance.new("TextBox", farmTab)
zoneInput.Size = UDim2.new(1, 0, 0, 35); zoneInput.PlaceholderText = "Zone Name..."; zoneInput.Text = _G.Config.Zone
zoneInput.BackgroundColor3 = theme.Button; zoneInput.TextColor3 = theme.Text; Instance.new("UICorner", zoneInput)
zoneInput.FocusLost:Connect(function() _G.Config.Zone = zoneInput.Text end)

makeToggle("Auto Farm Food", farmTab, "Food", function(v)
    while _G.Config.Toggles["Food"] do
        pcall(function()
            local zonePath = workspace.Zones[_G.Config.Zone].FoodSpawns
            local foods = zonePath:GetChildren()
            if #foods > 0 then
                local sharedTarget = foods[math.random(1, #foods)]
                local allPets = workspace[player.Name].Pets:GetChildren()
                if sharedTarget and #allPets > 0 then
                    for _, pet in ipairs(allPets) do
                        task.spawn(function()
                            for i = 1, 15 do
                                RS.Remotes.Functions.CollectionRF:InvokeServer("CollectFood", sharedTarget, pet)
                            end
                        end)
                    end
                    task.wait(0.3)
                end
            end
        end)
        RunService.Heartbeat:Wait()
    end
end)

makeToggle("Auto Farm Eggs (Combat)", farmTab, "Eggs", function(v)
    while _G.Config.Toggles["Eggs"] do
        pcall(function()
            for _,e in pairs(workspace.Zones[_G.Config.Zone].Enemies:GetChildren()) do
                for _,p in pairs(workspace[player.Name].Pets:GetChildren()) do
                    RS.Remotes.Functions.CombatRF:InvokeServer("AttackEnemy",e,p)
                end
            end
        end)
        task.wait()
    end
end)

local bossScroll = Instance.new("ScrollingFrame", farmTab)
bossScroll.Size = UDim2.new(1, 0, 0, 120); bossScroll.BackgroundColor3 = theme.Button; bossScroll.CanvasSize = UDim2.new(0,0,0,350)
Instance.new("UIListLayout", bossScroll)
local bossList = {"SummerEventZoneB1","ElementEventZoneB1","WinterEventZoneB1","Zone2B1","Zone6B1","Zone8B1","Zone10B1","Zone12B1","Zone12B2","Zone12B3"}

for _, name in pairs(bossList) do
    local b = Instance.new("TextButton", bossScroll)
    b.Size = UDim2.new(1,0,0,30); b.Text = name; b.BackgroundColor3 = Color3.fromRGB(45,0,0); b.TextColor3 = theme.Text
    b.MouseButton1Click:Connect(function()
        _G.Config.SelectedBosses[name] = not _G.Config.SelectedBosses[name]
        b.BackgroundColor3 = _G.Config.SelectedBosses[name] and Color3.fromRGB(0,45,0) or Color3.fromRGB(45,0,0)
    end)
end

makeToggle("Farm Selected Bosses", farmTab, "Boss", function(v)
    while _G.Config.Toggles["Boss"] do
        for z, enabled in pairs(_G.Config.SelectedBosses) do
            if enabled then pcall(function()
                for _,e in pairs(workspace.Zones[z].Enemies:GetChildren()) do
                    for _,p in pairs(workspace[player.Name].Pets:GetChildren()) do
                        RS.Remotes.Functions.CombatRF:InvokeServer("AttackEnemy",e,p)
                    end
                end
            end) end
        end
        task.wait()
    end
end)

------------------------------------------------
-- 2. HATCH TAB
------------------------------------------------
makeToggle("Fast Hatch (NO WAIT)", hatchTab, "Hatch", function(v)
    while _G.Config.Toggles["Hatch"] do
        RS.Remotes.Events.HatchEggEvent:FireServer()
        local hGui = player.PlayerGui:FindFirstChild("HatchGui") or player.PlayerGui:FindFirstChild("EggOpenGui")
        if hGui then hGui.Enabled = false end
        RunService.Heartbeat:Wait()
    end
end)

makeToggle("Fast Auto Feed (NO WAIT)", hatchTab, "Feed", function(v)
    while _G.Config.Toggles["Feed"] do
        pcall(function()
            for _, n in pairs(workspace.Nests:GetChildren()) do
                RS.Remotes.Events.FeedEggEvent:FireServer(n)
            end
        end)
        RunService.Heartbeat:Wait()
    end
end)

makeToggle("Delete Egg UI (Anti-Lag)", hatchTab, "DeleteEggUI", function(v)
    local targets = {["EggOpening"] = true, ["EggOpenGui"] = true, ["HatchGui"] = true}
    local function removeEggUI(obj)
        if _G.Config.Toggles["DeleteEggUI"] and targets[obj.Name] then
            pcall(function() obj:Destroy() end)
        end
    end
    for _, obj in pairs(player.PlayerGui:GetDescendants()) do removeEggUI(obj) end
    player.PlayerGui.DescendantAdded:Connect(removeEggUI)
end)

local line = Instance.new("Frame", hatchTab)
line.Size = UDim2.new(1, 0, 0, 2); line.BackgroundColor3 = theme.Accent; line.BorderSizePixel = 0

local sellInput = Instance.new("TextBox", hatchTab)
sellInput.Size = UDim2.new(1, 0, 0, 35); sellInput.PlaceholderText = "ชื่อสัตว์ที่จะขาย..."; sellInput.Text = _G.Config.AutoSellName or ""; sellInput.BackgroundColor3 = theme.Button; sellInput.TextColor3 = theme.Text; Instance.new("UICorner", sellInput)
sellInput.FocusLost:Connect(function() _G.Config.AutoSellName = sellInput.Text end)

makeToggle("Auto Sell (Turbo)", hatchTab, "AutoSell", function(v)
    local sellRemote = RS:WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("SellMonsterEvent")
    while _G.Config.Toggles["AutoSell"] do
        local targetName = _G.Config.AutoSellName
        if targetName and targetName ~= "" then
            for _, obj in pairs(player:GetDescendants()) do
                if string.find(obj.Name, targetName) then
                    task.spawn(function() pcall(function() sellRemote:FireServer(obj.Name) end) end)
                end
            end
        end
        task.wait(0.3)
    end
end)

------------------------------------------------
-- 3. SACRIFICE TAB
------------------------------------------------
local sacInput = Instance.new("TextBox", sacTab)
sacInput.Size = UDim2.new(1, 0, 0, 35); sacInput.Text = _G.Config.SacPet; sacInput.BackgroundColor3 = theme.Button; sacInput.TextColor3 = theme.Text
sacInput.FocusLost:Connect(function() _G.Config.SacPet = sacInput.Text end)

makeToggle("Auto Sacrifice", sacTab, "Sac", function(v)
    while _G.Config.Toggles["Sac"] do
        RS.Remotes.Functions.SacrificeFunction:InvokeServer("SacrificeWell", _G.Config.SacPet)
        task.wait(1)
    end
end)

------------------------------------------------
-- 4. CAMERA TAB
------------------------------------------------
local sPos, sCam
local function camBtn(text, parent, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,35); b.Text = text; b.BackgroundColor3 = theme.Button; b.TextColor3 = theme.Text; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(callback)
end

camBtn("Save My Position", camTab, function() sPos = player.Character.HumanoidRootPart.CFrame end)
camBtn("Warp to Saved Pos", camTab, function() if sPos then player.Character.HumanoidRootPart.CFrame = sPos end end)
camBtn("Save Camera View", camTab, function() sCam = workspace.CurrentCamera.CFrame end)

makeToggle("Lock Camera View", camTab, "CamLock", function(v)
    while _G.Config.Toggles["CamLock"] do
        if sCam then workspace.CurrentCamera.CFrame = sCam end
        task.wait()
    end
end)

------------------------------------------------
-- 5. SETTINGS
------------------------------------------------
local bSave = Instance.new("TextButton", setTab)
bSave.Size = UDim2.new(1,0,0,45); bSave.Text = "SAVE EVERYTHING (JSON)"; bSave.BackgroundColor3 = theme.Accent; bSave.TextColor3 = theme.Text
bSave.MouseButton1Click:Connect(function() SaveConfig(); print("Saved!") end)

makeToggle("Extreme FPS Boost", setTab, "FPS", function(v)
    if v then
        for _, o in pairs(game:GetDescendants()) do
            if o:IsA("BasePart") then o.Material = "Plastic"; o.Reflectance = 0
            elseif o:IsA("Decal") or o:IsA("Texture") then o:Destroy() end
        end
        Lighting.GlobalShadows = false
        settings().Rendering.QualityLevel = 1
    end
end)

makeToggle("Hide Game UI", setTab, "HideUI", function(v)
    for _, g in pairs(player.PlayerGui:GetChildren()) do
        if g:IsA("ScreenGui") and g.Name ~= gui.Name then g.Enabled = not v end
    end
end)

makeToggle("Auto Rejoin", setTab, "Rejoin", function(v)
    player.Idled:Connect(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end)
end)

game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
    if child.Name == "ErrorPrompt" and _G.Config.Toggles["Rejoin"] then TP:Teleport(game.PlaceId) end
end)

------------------------------------------------
-- AUTO LOAD EXECUTION
------------------------------------------------
task.spawn(function()
    if isfile(fileName) then
        local data = HttpService:JSONDecode(readfile(fileName))
        _G.Config = data
        zoneInput.Text = _G.Config.Zone
        sacInput.Text = _G.Config.SacPet
        task.wait(1)
        for n, s in pairs(_G.Config.Toggles) do if s and allToggles[n] then allToggles[n](true) end end
    end
end)

------------------------------------------------
-- DRAG & ICON
------------------------------------------------
local icon = Instance.new("ImageButton", gui)
icon.Size = UDim2.new(0, 50, 0, 50); icon.Position = UDim2.new(0, 10, 0.5, -25); icon.Image = "rbxassetid://10511856020"
icon.BackgroundColor3 = theme.SideBar; Instance.new("UICorner", icon).CornerRadius = UDim.new(1, 0)
icon.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

local d, ds, sp
main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true; ds = i.Position; sp = main.Position end end)
UIS.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
    local delta = i.Position - ds
    main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
