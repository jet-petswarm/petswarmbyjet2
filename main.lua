-- [[ CONFIGURATION - แก้ไขตรงนี้ ]]
local allowedNames = {"Tippawan_811", "ชื่อของคุณ2"} -- ใส่ชื่อผู้เล่นที่อนุญาต
local targetPlaceId = 93712201161812
local fileName = "FarmSettings.json" -- ชื่อไฟล์ที่ใช้บันทึกค่า

-- [[ SERVICES ]]
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- [[ SECURITY CHECK ]]
local function isAllowed()
    for _, name in ipairs(allowedNames) do
        if player.Name == name then return true end
    end
    return false
end

if not isAllowed() then 
    warn("Access Denied: Player not in whitelist.")
    return 
end

if game.PlaceId ~= targetPlaceId then
    warn("Wrong Map! Current ID: " .. game.PlaceId)
    return
end

-- [[ DATA SAVING SYSTEM ]]
local farmActive = false
local function saveSettings()
    local data = {farming = farmActive}
    writefile(fileName, HttpService:JSONEncode(data))
end

local function loadSettings()
    if isfile(fileName) then
        local data = HttpService:JSONDecode(readfile(fileName))
        return data.farming
    end
    return false
end

-- [[ UI SETUP ]]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 150, 0, 110)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Active = true
MainFrame.Draggable = true -- ทำให้ลาก UI ได้

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Text = "Mini Farm UI"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 25)
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.new(1, 1, 0)
StatusLabel.BackgroundTransparency = 1

local ActionBtn = Instance.new("TextButton", MainFrame)
ActionBtn.Size = UDim2.new(0.8, 0, 0, 40)
ActionBtn.Position = UDim2.new(0.1, 0, 0, 55)
ActionBtn.Text = "START FARM"
ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ActionBtn.TextColor3 = Color3.new(1, 1, 1)

-- [[ FUNCTIONALITY ]]
local function teleport()
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart", 10)
    if rootPart then
        task.wait(0.5)
        rootPart.CFrame = CFrame.new(-18.0, 5.2, -161.8)
    end
end

-- ลูปการฟาร์ม
task.spawn(function()
    while true do
        if farmActive then
            StatusLabel.Text = "Status: FARMING..."
            StatusLabel.TextColor3 = Color3.new(0, 1, 0)
            
            -- โค้ด Remote ที่คุณให้มา
            local net = game:GetService("ReplicatedStorage"):WaitForChild("NetworkingContainer"):WaitForChild("DataRemote")
            net:FireServer({ {{"\226\129\130G", "707a396b-b43b-4622-9ad1-dd8620b72f00"}} })
            net:FireServer({ {{"\226\129\130("}} })
            net:FireServer({ {{"\226\129\130G", "c6887ad6-0381-4b16-a6ff-328d30250795"}} })
        else
            StatusLabel.Text = "Status: STOPPED"
            StatusLabel.TextColor3 = Color3.new(1, 0, 0)
        end
        task.wait(0.5)
    end
end)

-- ปุ่มกดสลับ สถานะ
ActionBtn.MouseButton1Click:Connect(function()
    farmActive = not farmActive
    if farmActive then
        ActionBtn.Text = "STOP FARM"
        ActionBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        teleport()
    else
        ActionBtn.Text = "START FARM"
        ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
    saveSettings() -- บันทึกค่าลงเครื่อง
end)

-- [[ INITIAL RUN (Auto-run if saved) ]]
farmActive = loadSettings()
if farmActive then
    ActionBtn.Text = "STOP FARM"
    ActionBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    task.spawn(teleport) -- วาร์ปทันทีถ้าเคยเปิดฟาร์มไว้
end
