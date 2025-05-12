local allowedPlaceId = 16732694052  

if game.PlaceId == allowedPlaceId then
    
    print("กำลังเล่นแผนที่ที่อนุญาต")
else
    -- ถ้า PlaceId ไม่ตรง, เด้งผู้เล่นออกพร้อมข้อความ
    game.Players.LocalPlayer:Kick("มึงใช้สคริปให้ถูกแมพ!")  
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("GOD STONE", "DarkTheme")

-- [[ ตัวแปรสถานะ ]]
local autoRunning = false
local autoThreads = {}

-- [[ TAB: AutoFrame ]]
local Tab = Window:NewTab("AutoFrame")
local Section = Tab:NewSection("รวม AutoEquip, Cast, AutoShake และ AutoReel")

Section:NewToggle("Click", "เริ่ม/หยุดระบบอัตโนมัติ", function(state)
    autoRunning = state
    if state then
        print("✅ เริ่มระบบ AutoFishing")

        -- ▶️ ระบบ AutoLoop
        autoThreads.loop = task.spawn(function()
            while autoRunning do
                local Players = game:GetService("Players")
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local LocalPlayer = Players.LocalPlayer
                local Char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

                -- Equip Rod
                if LocalPlayer.Backpack:FindFirstChild("Poseidon Rod") then
                    LocalPlayer.Character.Humanoid:EquipTool(LocalPlayer.Backpack:FindFirstChild("Poseidon Rod"))
                end
                task.wait(0.5)

                -- Cast Rod
                local Rod = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                if Rod and Rod:FindFirstChild("events") and Rod.events:FindFirstChild("cast") then
                    Rod.events.cast:FireServer(100, 1)
                    print("🎣 Cast เรียบร้อย")
                end

                task.wait(0.1)
            end
        end)

        -- ▶️ ระบบ AutoShake
        autoThreads.shake = task.spawn(function()
            local GuiService = game:GetService("GuiService")
            local LocalPlayer = game:GetService("Players").LocalPlayer
            local GUI = LocalPlayer:WaitForChild("PlayerGui")
            local vim = game:GetService("VirtualInputManager")

            while autoRunning do
                local shakeui = GUI:FindFirstChild("shakeui")
                if shakeui and shakeui.Enabled then
                    local safezone = shakeui:FindFirstChild("safezone")
                    if safezone then
                        local button = safezone:FindFirstChild("button")
                        if button and button:IsA("ImageButton") and button.Visible then
                            GuiService.SelectedCoreObject = button
                            task.wait(0.1)
                            vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                            vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                            print("🌀 AutoShake: คลิกปุ่มแล้ว")
                        end
                    end
                end
                task.wait(0.05)
            end
        end)

        -- ▶️ ระบบ AutoReel
        autoThreads.reel = task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local LocalPlayer = game:GetService("Players").LocalPlayer
            local GUI = LocalPlayer:WaitForChild("PlayerGui")
            local reelfinished = ReplicatedStorage:FindFirstChild("events") and ReplicatedStorage.events:FindFirstChild("reelfinished")

            if not reelfinished or not reelfinished:IsA("RemoteEvent") then return end

            while autoRunning do
                for _, v in pairs(GUI:GetChildren()) do
                    if v:IsA("ScreenGui") and v.Name == "reel" and v:FindFirstChild("bar") then
                        reelfinished:FireServer(100, true)
                        print("✅ AutoReel: ดึงเบ็ดแล้ว")
                    end
                end
                task.wait(0.1)
            end
        end)

    else
        print("⛔ ปิดระบบ AutoFishing")
        for _, thread in pairs(autoThreads) do
            if thread then task.cancel(thread) end
        end
        autoThreads = {}
    end
end)

-- [[ TAB: ตั้งค่า ]]
local Tab2 = Window:NewTab("ตั้งค่า")
local Section2 = Tab2:NewSection("UI Settings")
Section2:NewKeybind("เปิด/ปิด UI", "กดเพื่อซ่อน/แสดง", Enum.KeyCode.F, function()
	Library:ToggleUI()
end)
Section2:NewColorPicker("ตั้งค่าสี", "เปลี่ยนสีเทส", Color3.fromRGB(255, 255, 255), function(color)
    print("🎨 Color Picker:", color)
end)
local Tab = Window:NewTab("TabName")
local Section = Tab:NewSection("Section Name")
Section:NewToggle("ToggleText", "ToggleInfo", function(state)
    if state then
        print("Toggle On")
    else
        print("Toggle Off")
    end
end)
