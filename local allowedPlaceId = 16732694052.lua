-- 🔐 ป้องกันการถูกเตะจาก Anti-Cheat
local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "Kick" or tostring(self) == "Kick" then
        warn("⛔ มีความพยายาม Kick แต่ถูกบล็อกไว้")
        return nil
    end
    return old(self, ...)
end)

-- ✅ ตรวจสอบ PlaceId
local allowedPlaceId = 16732694052  
if game.PlaceId ~= allowedPlaceId then
    warn("⚠️ คุณไม่ได้อยู่ในแมพที่สคริปต์ถูกออกแบบมา อาจทำงานไม่สมบูรณ์")
end

-- ✅ โหลด UI Library อย่างปลอดภัย
local success, Library = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
end)

if not success then
    warn("ไม่สามารถโหลด UI Library ได้")
    return
end

local Window = Library.CreateLib("System Config", "DarkTheme")

-- 🧠 ตัวแปรสถานะ
local autoRunning = false
local autoThreads = {}

-- 🪝 TAB: AutoTool
local Tab = Window:NewTab("System Monitor")
local Section = Tab:NewSection("Fishing Automation")

Section:NewToggle("Start Auto", "เปิด/ปิดระบบอัตโนมัติ", function(state)
    autoRunning = state
    if state then
        print("✅ เริ่มระบบอัตโนมัติ")

        -- AutoLoop (Cast Rod)
        autoThreads.loop = task.spawn(function()
            while autoRunning do
                pcall(function()
                    local Players = game:GetService("Players")
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local LocalPlayer = Players.LocalPlayer
                    local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

                    local rodTool = LocalPlayer.Backpack:FindFirstChild("Poseidon Rod")
                    if rodTool then
                        LocalPlayer.Character.Humanoid:EquipTool(rodTool)
                    end

                    task.wait(math.random(5, 7) / 10)

                    local Rod = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if Rod and Rod:FindFirstChild("events") and Rod.events:FindFirstChild("cast") then
                        Rod.events.cast:FireServer(100, 1)
                        print("🎣 Cast เบ็ดแล้ว")
                    end
                end)
                task.wait(math.random(6, 9) / 10)
            end
        end)

        -- AutoShake
        autoThreads.shake = task.spawn(function()
            local vim = game:GetService("VirtualInputManager")
            local GUI = game.Players.LocalPlayer:WaitForChild("PlayerGui")

            while autoRunning do
                pcall(function()
                    local shakeui = GUI:FindFirstChild("shakeui")
                    if shakeui and shakeui.Enabled then
                        local safezone = shakeui:FindFirstChild("safezone")
                        if safezone then
                            local button = safezone:FindFirstChild("button")
                            if button and button:IsA("ImageButton") and button.Visible then
                                vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                                print("🌀 AutoShake: คลิกปุ่มแล้ว")
                            end
                        end
                    end
                end)
                task.wait(math.random(4, 7) / 100)
            end
        end)

        -- AutoReel
        autoThreads.reel = task.spawn(function()
            local GUI = game.Players.LocalPlayer:WaitForChild("PlayerGui")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local reelfinished = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("reelfinished")

            while autoRunning do
                pcall(function()
                    if not reelfinished then return end
                    for _, v in pairs(GUI:GetChildren()) do
                        if v:IsA("ScreenGui") and v.Name == "reel" and v:FindFirstChild("bar") then
                            reelfinished:FireServer(100, true)
                            print("✅ AutoReel: ดึงเบ็ด")
                        end
                    end
                end)
                task.wait(math.random(5, 8) / 10)
            end
        end)

    else
        print("⛔ ปิดระบบอัตโนมัติ")
        for _, thread in pairs(autoThreads) do
            if thread then task.cancel(thread) end
        end
        autoThreads = {}
    end
end)

-- ⚙️ UI Settings Tab
local Tab2 = Window:NewTab("Interface")
local Section2 = Tab2:NewSection("UI Options")

Section2:NewKeybind("Toggle UI", "แสดง/ซ่อนหน้าต่าง", Enum.KeyCode.F, function()
    Library:ToggleUI()
end)

Section2:NewColorPicker("UI Color", "เลือกสี UI", Color3.fromRGB(255, 255, 255), function(color)
    print("🎨 เปลี่ยนสี UI:", color)
end)
