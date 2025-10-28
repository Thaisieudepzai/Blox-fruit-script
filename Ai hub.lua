-- Auto Hop & Lưu Trữ Ác Quỷ - Storage System
if _G.DevilFruitStorage then return end
_G.DevilFruitStorage = true

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("🍎 Devil Fruit Storage", "DarkTheme")

-- Biến toàn cục
getgenv().AutoHop = false
getgenv().AutoCollect = false
getgenv().AutoStore = false
getgenv().Notify = true
getgenv().HopDelay = 30

-- Hệ thống lưu trữ
getgenv().FruitStorage = {
    CollectedFruits = {},
    TotalCollected = 0,
    LastFound = "",
    StorageFile = "DevilFruitData.json"
}

-- GUI Status Window (Có thể kéo)
local StatusGUI = Instance.new("ScreenGui")
local StatusFrame = Instance.new("Frame")
local StatusLabel = Instance.new("TextLabel")
local DragFrame = Instance.new("Frame")

-- Tạo GUI
StatusGUI.Name = "DevilFruitStorageStatus"
StatusGUI.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

StatusFrame.Name = "StatusFrame"
StatusFrame.Parent = StatusGUI
StatusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
StatusFrame.BorderSizePixel = 2
StatusFrame.BorderColor3 = Color3.fromRGB(0, 255, 0)
StatusFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
StatusFrame.Size = UDim2.new(0, 350, 0, 150)
StatusFrame.Active = true
StatusFrame.Draggable = true

-- Drag Frame
DragFrame.Name = "DragFrame"
DragFrame.Parent = StatusFrame
DragFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
DragFrame.BorderSizePixel = 0
DragFrame.Position = UDim2.new(0, 0, 0, 0)
DragFrame.Size = UDim2.new(1, 0, 0, 20)

StatusLabel.Name = "StatusLabel"
StatusLabel.Parent = StatusFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 10, 0, 25)
StatusLabel.Size = UDim2.new(1, -20, 1, -30)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "🍎 DEVIL FRUIT STORAGE\n🔴 OFFLINE\nTổng trái: 0"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.TextSize = 14
StatusLabel.TextWrapped = true
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Lưu dữ liệu
local function SaveStorage()
    pcall(function()
        local data = {
            CollectedFruits = getgenv().FruitStorage.CollectedFruits,
            TotalCollected = getgenv().FruitStorage.TotalCollected,
            LastFound = getgenv().FruitStorage.LastFound
        }
        writefile(getgenv().FruitStorage.StorageFile, game:GetService("HttpService"):JSONEncode(data))
    end)
end

-- Load dữ liệu
local function LoadStorage()
    pcall(function()
        if isfile(getgenv().FruitStorage.StorageFile) then
            local data = game:GetService("HttpService"):JSONDecode(readfile(getgenv().FruitStorage.StorageFile))
            getgenv().FruitStorage.CollectedFruits = data.CollectedFruits or {}
            getgenv().FruitStorage.TotalCollected = data.TotalCollected or 0
            getgenv().FruitStorage.LastFound = data.LastFound or ""
        end
    end)
end

-- Cập nhật trạng thái
local function UpdateStatus(message)
    StatusLabel.Text = "🍎 DEVIL FRUIT STORAGE\n"..message.."\nTổng trái: "..getgenv().FruitStorage.TotalCollected
    if getgenv().Notify then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🍎 Fruit Storage",
            Text = message:gsub("\n", " "),
            Duration = 5
        })
    end
end

-- Thêm trái vào kho
local function AddToStorage(fruitName)
    if not getgenv().FruitStorage.CollectedFruits[fruitName] then
        getgenv().FruitStorage.CollectedFruits[fruitName] = 0
    end
    getgenv().FruitStorage.CollectedFruits[fruitName] = getgenv().FruitStorage.CollectedFruits[fruitName] + 1
    getgenv().FruitStorage.TotalCollected = getgenv().FruitStorage.TotalCollected + 1
    getgenv().FruitStorage.LastFound = fruitName
    
    SaveStorage()
    
    return getgenv().FruitStorage.CollectedFruits[fruitName]
end

-- Tìm trái ác quỷ
local function FindDevilFruits()
    pcall(function()
        for _, item in pairs(workspace:GetChildren()) do
            if item:FindFirstChild("Handle") and (string.find(item.Name, "Fruit") or string.find(item.Name, "Demon")) then
                return item
            end
        end
    end)
    return nil
end

-- Lưu trữ trái ác quỷ
local function StoreDevilFruit(fruit)
    pcall(function()
        -- Mở inventory
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("GetFruits")
        
        -- Lưu thông tin trái
        local count = AddToStorage(fruit.Name)
        
        UpdateStatus("✅ ĐÃ LƯU TRỮ: "..fruit.Name.."\nSố lượng: "..count.."\nTổng: "..getgenv().FruitStorage.TotalCollected)
    end)
end

-- Auto Collect & Store
local function StartCollecting()
    while getgenv().AutoCollect do
        task.wait(2)
        local fruit = FindDevilFruits()
        if fruit then
            UpdateStatus("🎯 PHÁT HIỆN: "..fruit.Name.."\nĐang di chuyển...")
            
            -- Teleport đến trái ác quỷ
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = fruit.Handle.CFrame
            
            -- Chờ nhặt
            task.wait(3)
            
            -- Tự động lưu trữ
            if getgenv().AutoStore then
                StoreDevilFruit(fruit)
            else
                local count = AddToStorage(fruit.Name)
                UpdateStatus("✅ ĐÃ NHẶT: "..fruit.Name.."\nSố lượng: "..count)
            end
        else
            UpdateStatus("🔍 Đang tìm trái ác quỷ...\nServer: "..game.JobId:sub(1, 8))
        end
    end
end

-- Auto Hop
local function StartAutoHop()
    while getgenv().AutoHop do
        task.wait(getgenv().HopDelay)
        
        if getgenv().AutoCollect then
            local fruit = FindDevilFruits()
            if not fruit then
                UpdateStatus("🔄 Không tìm thấy trái\nĐang đổi server...")
                
                -- Hop server
                local TeleportService = game:GetService("TeleportService")
                local PlaceId = game.PlaceId
                local Servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Desc&limit=100"))
                
                for _, server in pairs(Servers.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(PlaceId, server.id)
                        task.wait(5)
                        break
                    end
                end
            else
                UpdateStatus("🎯 Đã tìm thấy: "..fruit.Name.."\nKhông cần đổi server")
            end
        end
    end
end

-- MAIN TAB
local MainTab = Window:NewTab("Chính")
local AutoSection = MainTab:NewSection("Tự Động")

AutoSection:NewToggle("Auto Hop Server", "Tự động đổi server", function(state)
    getgenv().AutoHop = state
    if state then
        UpdateStatus("🟢 AUTO HOP: BẬT\nĐang tìm server...")
        spawn(StartAutoHop)
    else
        UpdateStatus("🔴 AUTO HOP: TẮT")
    end
end)

AutoSection:NewToggle("Auto Collect Fruit", "Tự động nhặt trái", function(state)
    getgenv().AutoCollect = state
    if state then
        UpdateStatus("🟢 AUTO COLLECT: BẬT\nĐang quét...")
        spawn(StartCollecting)
    else
        UpdateStatus("🔴 AUTO COLLECT: TẮT")
    end
end)

AutoSection:NewToggle("Auto Lưu Trữ", "Tự động lưu vào kho", function(state)
    getgenv().AutoStore = state
    UpdateStatus("💾 AUTO STORE: "..(state and "BẬT" or "TẮT"))
end)

-- STORAGE TAB
local StorageTab = Window:NewTab("Kho Trữ")
local StorageSection = StorageTab:NewSection("Quản Lý Kho")

StorageSection:NewButton("Xem Kho Trữ", "Hiện tất cả trái đã lưu", function()
    local storageText = "📦 KHO TRỮ ÁC QUỶ:\n"
    local hasFruits = false
    
    for fruitName, count in pairs(getgenv().FruitStorage.CollectedFruits) do
        storageText = storageText.."• "..fruitName..": "..count.."\n"
        hasFruits = true
    end
    
    if not hasFruits then
        storageText = storageText.."❌ Chưa có trái nào"
    end
    
    storageText = storageText.."\nTỔNG: "..getgenv().FruitStorage.TotalCollected.." trái"
    
    UpdateStatus(storageText)
end)

StorageSection:NewButton("Xuất Dữ Liệu", "Copy data sang clipboard", function()
    setclipboard(game:GetService("HttpService"):JSONEncode(getgenv().FruitStorage.CollectedFruits))
    UpdateStatus("📋 Đã copy dữ liệu\nvào clipboard!")
end)

StorageSection:NewButton("Reset Kho", "Xóa toàn bộ dữ liệu", function()
    getgenv().FruitStorage.CollectedFruits = {}
    getgenv().FruitStorage.TotalCollected = 0
    getgenv().FruitStorage.LastFound = ""
    SaveStorage()
    UpdateStatus("🗑️ Đã reset kho trữ!\nTổng trái: 0")
end)

-- SETTINGS TAB
local SettingsTab = Window:NewTab("Cài Đặt")
local SettingsSection = SettingsTab:NewSection("Tùy Chỉnh")

SettingsSection:NewSlider("Thời gian chờ (giây)", "Thời gian chờ trước khi hop", 120, 10, function(value)
    getgenv().HopDelay = value
    UpdateStatus("⏰ Thời gian chờ: "..value.."s")
end)

SettingsSection:NewToggle("Thông báo", "Hiện thông báo", function(state)
    getgenv().Notify = state
    UpdateStatus("🔔 Thông báo: "..(state and "BẬT" or "TẮT"))
end)

-- Khởi động
LoadStorage()
UpdateStatus("🍎 DEVIL FRUIT STORAGE\nĐã khởi động thành công!\nKéo GUI để di chuyển\nTổng trái: "..getgenv().FruitStorage.TotalCollected)

-- Auto save mỗi 5 phút
spawn(function()
    while task.wait(300) do
        SaveStorage()
        UpdateStatus("💾 Đã auto save dữ liệu\nTổng trái: "..getgenv().FruitStorage.TotalCollected)
    end
end)
