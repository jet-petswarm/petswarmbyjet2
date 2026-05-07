-- [[ CONFIGURATION ]]
local allowedNames = {"Tippawan_811", "ชื่อของคุณ2"} 
local targetPlaceId = 93712201161812
local fileName = "FarmSettings.json"
local targetCFrame = CFrame.new(-18.0, 5.2, -161.8) -- พิกัดเป้าหมาย

-- [[ SERVICES ]]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- [[ SECURITY CHECK ]]
local function isAllowed()
    for _, name in ipairs(allowedNames) do
        if player.Name == name then return true end
    end
    return false
end

if not isAllowed() then 
    warn("Access Denied!")
    return 
end

-- [[ DATA SYSTEM ]]
local farmActive = false
local function saveSettings()
    pcall(function()
        writefile(fileName, HttpService:JSONEncode({farming = farmActive}))
    end)
end

local function loadSettings()
    if isfile(fileName) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(fileName)) end)
        return success and data.farming or false
    end
    return false
end

-- [[ UI SETUP - แสดงทุกแมพ ]]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 160, 0, 120)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "JET FARMER"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 30)
StatusLabel.Text = "Status: Checking..."
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.BackgroundTransparency = 1

local ActionBtn = Instance.new("TextButton", MainFrame)
ActionBtn.Size = UDim2.new(0.9, 0, 0, 40)
ActionBtn.Position = UDim2.new(0.05, 0, 0, 60)
ActionBtn.Text = "START"
ActionBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ActionBtn.TextColor3 = Color3.new(1, 1, 1)

-- [[ LOGIC ]]
local function teleport()
    local character = player.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        rootPart.CFrame = targetCFrame
    end
end

-- ลูปเช็คตำแหน่ง (Check Position)
task.spawn(function()
    while task.wait(1) do
        if farmActive and game.PlaceId == targetPlaceId then
            local character = player.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- ถ้าอยู่ห่างจากเป้าหมายเกิน 5 Units ให้วาร์ปกลับ
                if (rootPart.Position - targetCFrame.Position).Magnitude > 5 then
                    teleport()
                end
            end
        end
    end
end)

-- ลูปฟาร์มแบบรัวๆ (Rapid Fire)
task.spawn(function()
    while true do
        if farmActive and game.PlaceId == targetPlaceId then
            StatusLabel.Text = "Status: RUNNING ⚡"
            StatusLabel.TextColor3 = Color3.new(0, 1, 0)
            
            local net = game:GetService("ReplicatedStorage"):WaitForChild("NetworkingContainer"):WaitForChild("DataRemote")
            -- ส่งข้อมูลรัวๆ
            net:FireServer({ {{"\226\129\130G", "707a396b-b43b-4622-9ad1-dd8620b72f00"}} })
            net:FireServer({ {{"\226\129\130("}} })
            net:FireServer({ {{"\226\129\130G", "c6887ad6-0381-4b16-a6ff-328d30250795"}} })
            
            task.wait(0.1) -- ปรับให้รัวขึ้น (0.1 วินาที)
        elseif game.PlaceId ~= targetPlaceId then
            StatusLabel.Text = "Status: WRONG MAP"
            StatusLabel.TextColor3 = Color3.new(1, 0.5, 0)
            farmActive = false
            task.wait(1)
        else
            StatusLabel.Text = "Status: STOPPED"
            StatusLabel.TextColor3 = Color3.new(1, 0, 0)
            task.wait(0.5)
        end
    end
end)

-- ปุ่มกด
ActionBtn.MouseButton1Click:Connect(function()
    if game.PlaceId ~= targetPlaceId then 
        warn("Cannot start: Not in Pet Swarm map.")
        return 
    end
    
    farmActive = not farmActive
    if farmActive then
        ActionBtn.Text = "STOP FARM"
        ActionBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        teleport()
    else
        ActionBtn.Text = "START FARM"
        ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
    saveSettings()
end)

-- [[ INIT ]]
farmActive = loadSettings()
if farmActive and game.PlaceId == targetPlaceId then
    ActionBtn.Text = "STOP FARM"
    ActionBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    task.spawn(teleport)
else
    ActionBtn.Text = "START FARM"
    ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
end
