-- Blox Fruit Script for Delta Executor
-- GitHub: https://github.com/yourusername/bloxfruit-script

if _G.BloxFruitLoaded then return end
_G.BloxFruitLoaded = true

-- Load UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Delta Blox Fruit", "DarkTheme")

-- Configuration
local FarmSettings = {
    AutoFarm = false,
    AutoQuest = false,
    AutoBoss = false,
    AutoRaid = false
}

-- Auto Farm Function
local function StartAutoFarm()
    while FarmSettings.AutoFarm do
        task.wait(.1)
        pcall(function()
            -- Tìm mục tiêu gần nhất
            local target = nil
            local minDistance = math.huge
            
            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                    local dist = (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                    if dist < minDistance then
                        minDistance = dist
                        target = enemy
                    end
                end
            end
            
            if target then
                -- Di chuyển đến mục tiêu
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                
                -- Tấn công
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AttackButton")
                
                -- Sử dụng skill
                for _, key in pairs({"Z", "X", "C", "V"}) do
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, key, false, game)
                end
            end
        end)
    end
end

-- Auto Quest Function
local function StartAutoQuest()
    while FarmSettings.AutoQuest do
        task.wait(2)
        pcall(function()
            local Level = game.Players.LocalPlayer.Data.Level.Value
            
            if Level >= 1 and Level <= 10 then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "BanditQuest1", 1)
            elseif Level >= 15 and Level <= 30 then
                game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", "MarineQuest2", 2)
            -- Thêm các level khác...
            end
        end)
    end
end

-- Main Tab
local MainTab = Window:NewTab("Main")
local MainSection = MainTab:NewSection("Auto Farm")

MainSection:NewToggle("Auto Farm Level", "Tự động farm level", function(state)
    FarmSettings.AutoFarm = state
    if state then
        coroutine.wrap(StartAutoFarm)()
    end
end)

MainSection:NewToggle("Auto Quest", "Tự động nhận quest", function(state)
    FarmSettings.AutoQuest = state
    if state then
        coroutine.wrap(StartAutoQuest)()
    end
end)

-- Boss Tab
local BossTab = Window:NewTab("Boss")
local BossSection = BossTab:NewSection("Auto Boss")

BossSection:NewToggle("Auto Boss", "Tự động farm boss", function(state)
    FarmSettings.AutoBoss = state
    if state then
        coroutine.wrap(function()
            while FarmSettings.AutoBoss do
                task.wait(.2)
                -- Code farm boss
            end
        end)()
    end
end)

-- Teleport Tab
local TPTab = Window:NewTab("Teleport")
local TPSection = TPTab:NewSection("Địa điểm")

local Locations = {
    ["Jungle"] = CFrame.new(-1612.84, 36.85, 149.13),
    ["Marine Starter"] = CFrame.new(-2689.91, 6.35, 2046.64),
    ["Middle Town"] = CFrame.new(-655.97, 7.88, 1573.54)
}

for name, cf in pairs(Locations) do
    TPSection:NewButton("TP " .. name, "Dịch chuyển đến " .. name, function()
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = cf
    end)
end

-- Misc Tab
local MiscTab = Window:NewTab("Misc")
local MiscSection = MiscTab:NewSection("Tiện ích")

MiscSection:NewSlider("WalkSpeed", "Tốc độ di chuyển", 500, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)

MiscSection:NewSlider("JumpPower", "Sức nhảy", 350, 50, function(value)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
end)

-- Thông báo thành công
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Delta Blox Fruit",
    Text = "Script loaded from GitHub!",
    Duration = 5
})

return Window
