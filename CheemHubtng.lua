--====================================================
-- CHEEM HUB | KEY SYSTEM (NO HWID)
--====================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ✅ Key hợp lệ
local VALID_KEYS = {
    ["489cc25454f545bd9bfc61e80e0fb6ed"] = true,
    ["d511f1013ed24f9a8355b1e4fc0ca0ed"] = true,
    ["9c91bde175a34a7ebf20021b2872157a"] = true
}

-- ⛔ Key bị ban
local BLACKLIST_KEYS = {
    ["0a8d49fc2bc44237b5debf5cf1e03700"] = true,
}

-- ❌ Không có key
if not getgenv().Key then
    LocalPlayer:Kick("❌ No key provided")
    return
end

-- ⛔ Blacklist
if BLACKLIST_KEYS[getgenv().Key] then
    LocalPlayer:Kick("⛔Error:Key is blacklist user is not whilist")
    return
end

-- ❌ Key sai
if not VALID_KEYS[getgenv().Key] then
    LocalPlayer:Kick("❌ Invalid key")
    return
end

-- ✅ Key đúng → tiếp tục load hub
warn("[CHEEM HUB] ✅ Key accepted")

--====================================================
-- CHEEM HUB | SMART CORE (SINGLE FILE)
--====================================================

repeat task.wait() until game:IsLoaded()

-- SERVICES
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

--====================================================
-- CHEEM CORE
--====================================================
local CheemCore = {}

function CheemCore.HasQuestGui()
    local gui = LocalPlayer.PlayerGui:FindFirstChild("Main")
    if not gui then return false end
    return gui:FindFirstChild("Quest") ~= nil
end

--================ WEAPON CORE =================

function CheemCore.GetPlayerWeapons()

    local list = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character

    if backpack then
        for _,tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local name = tool.ToolTip or tool.Name
                  list[name] = tool
            end
        end
    end

    if char then
        for _,tool in pairs(char:GetChildren()) do
            if tool:IsA("Tool") then
               local name = tool.ToolTip or tool.Name
                list[name] = tool
            end
        end
    end

    return list
end


function CheemCore.GetCurrentWeaponType()

    local char = LocalPlayer.Character
    if not char then return end

    for _,tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            return GetWeaponType(tool.Name)
        end
    end
end


function CheemCore.ResolveWeaponType()

    local weapons = CheemCore.GetPlayerWeapons()

    if weapons[WeaponRuntime.SelectedType] then
        return WeaponRuntime.SelectedType
    end

    for _,typeName in ipairs(WeaponRuntime.Priority) do
        if weapons[typeName] then
            return typeName
        end
    end
end


function CheemCore.UpdateEquipState(now)

    if now - WeaponRuntime.LastEquip < WeaponRuntime.EquipDelay then return end

    local targetType = CheemCore.ResolveWeaponType()
    if not targetType then return end

    local current = CheemCore.GetCurrentWeaponType()
    if current == targetType then return end

    local weapons = CheemCore.GetPlayerWeapons()
    local tool = weapons[targetType]

    if tool then
        WeaponRuntime.LastEquip = now
        tool.Parent = LocalPlayer.Character
    end
end

--====================================================
-- STATE
--====================================================
local STATE = {
    IDLE = "IDLE",
    FARM = "FARM",
}
local CurrentState = STATE.IDLE

--====================================================
-- FLAGS
--====================================================
local Flags = {
    Enabled   = false,
    AutoQuest = true,
    Debug     = false,
}

--====================================================
-- FARM CONFIG
--====================================================
local FarmConfig = {
    MobName        = "Bandit",
    AttackDistance= 10,
    AttackDelay   = 0.15,
}

--====================================================
-- QUEST DATA (SEA 1)
--====================================================
local QuestData = {

    ["Start Island"] = {
        IslandPos = CFrame.new(1060, 16, 1547),
        Quests = {
            {Min=1,  Max=9,  Quest="BanditQuest1", Level=1, Mob="Bandit"},
            {Min=10, Max=14, Quest="BanditQuest1", Level=2, Mob="Monkey"},
        }
    },

    ["Jungle"] = {
        IslandPos = CFrame.new(-1600, 36, 150),
        Quests = {
            {Min=15, Max=29, Quest="JungleQuest", Level=1, Mob="Gorilla"},
            {Min=30, Max=39, Quest="JungleQuest", Level=2, Mob="Gorilla King"},
        }
    },

    ["Pirate Village"] = {
        IslandPos = CFrame.new(-1100, 13, 3800),
        Quests = {
            {Min=40, Max=59, Quest="BuggyQuest1", Level=1, Mob="Pirate"},
            {Min=60, Max=74, Quest="BuggyQuest1", Level=2, Mob="Brute"},
        }
    },

    ["Desert"] = {
        IslandPos = CFrame.new(930, 7, 4480),
        Quests = {
            {Min=75, Max=89, Quest="DesertQuest", Level=1, Mob="Desert Bandit"},
            {Min=90, Max=99, Quest="DesertQuest", Level=2, Mob="Desert Officer"},
        }
    },

    ["Frozen Village"] = {
        IslandPos = CFrame.new(1380, 87, -1290),
        Quests = {
            {Min=100, Max=119, Quest="SnowQuest", Level=1, Mob="Snow Bandit"},
            {Min=120, Max=149, Quest="SnowQuest", Level=2, Mob="Snowman"},
        }
    },

    ["Marine Captain"] = {
        IslandPos = CFrame.new(-5030, 29, 4325),
        Quests = {
            {Min=150, Max=174, Quest="MarineQuest2", Level=1, Mob="Chief Petty Officer"},
            {Min=175, Max=189, Quest="MarineQuest2", Level=2, Mob="Sky Bandit"},
        }
    },

    ["Sky Island"] = {
        IslandPos = CFrame.new(-4850, 717, -2620),
        Quests = {
            {Min=190, Max=209, Quest="SkyQuest", Level=1, Mob="Dark Master"},
        }
    },

    ["Prison"] = {
        IslandPos = CFrame.new(4850, 5, 735),
        Quests = {
            {Min=210, Max=249, Quest="PrisonQuest", Level=1, Mob="Prisoner"},
        }
    },

    ["Colosseum"] = {
        IslandPos = CFrame.new(-1500, 7, -3000),
        Quests = {
            {Min=250, Max=299, Quest="ColosseumQuest", Level=1, Mob="Toga Warrior"},
        }
    },

    ["Magma Village"] = {
        IslandPos = CFrame.new(-5250, 8, 8500),
        Quests = {
            {Min=300, Max=324, Quest="MagmaQuest", Level=1, Mob="Military Soldier"},
            {Min=325, Max=374, Quest="MagmaQuest", Level=2, Mob="Military Spy"},
        }
    },

    ["Fishman Island"] = {
        IslandPos = CFrame.new(61000, 18, 1560),
        Quests = {
            {Min=375, Max=399, Quest="FishmanQuest", Level=1, Mob="Fishman Warrior"},
            {Min=400, Max=449, Quest="FishmanQuest", Level=2, Mob="Fishman Commando"},
        }
    },

    ["Skypiea"] = {
        IslandPos = CFrame.new(-4720, 845, -1950),
        Quests = {
            {Min=450, Max=474, Quest="SkyExp1Quest", Level=1, Mob="God's Guard"},
            {Min=475, Max=524, Quest="SkyExp1Quest", Level=2, Mob="Shanda"},
        }
    },

    ["Fountain City"] = {
        IslandPos = CFrame.new(5250, 39, 4050),
        Quests = {
            {Min=525, Max=700, Quest="FountainQuest", Level=1, Mob="Galley Pirate"},
        }
    },
}

function CheemCore.GetQuestByLevel(lv)
    for _, island in pairs(QuestData) do
        for _, q in ipairs(island.Quests) do
            if lv >= q.Min and lv <= q.Max then
                return {
                    QuestName = q.Quest,
                    QuestLevel = q.Level,
                    MobName = q.Mob,
                    IslandPos = island.IslandPos
                }
            end
        end
    end
end

--====================================================
-- CHARACTER
--====================================================
local Character, HRP
local function setupCharacter(char)
    Character = char
    HRP = char:WaitForChild("HumanoidRootPart")
end
if LocalPlayer.Character then setupCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(setupCharacter)

--====================================================
-- RUNTIME (SINGLE SOURCE OF TRUTH)
--====================================================
local Runtime = {
    CurrentQuest = nil,
    HasQuest     = false,
    Target       = nil,
    LastAttack   = 0,
    LastQuest    = 0,
    LastScan     = 0,
}

--====================================================
-- WEAPON RUNTIME
--====================================================
--====================================================
-- WEAPON RUNTIME
--====================================================
local WeaponRuntime = {
    SelectedType = "Sword",
    Priority = {"Sword","Blox Fruit","Gun"},
    LastEquip = 0,
    EquipDelay = 0.6,
    PriorityMode = true
}
--====================================================
-- WEAPON HELPER
--====================================================
local function GetWeaponType(toolName)

    toolName = toolName:lower()

if toolName:find("fruit") then
    return "Blox Fruit"
end

    if toolName:find("gun") or toolName:find("rifle") then
        return "Gun"
    end

    return "Sword"
end

function CheemCore.ScanInventory()

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end

    local weapons = {
    ["Sword"] = {},
    ["Blox Fruit"] = {},
    ["Gun"] = {}
}

    for _,tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local t = GetWeaponType(tool.Name)
            table.insert(weapons[t], tool.Name)
        end
    end

    if Character then
        for _,tool in ipairs(Character:GetChildren()) do
            if tool:IsA("Tool") then
                local t = GetWeaponType(tool.Name)
                table.insert(weapons[t], tool.Name)
            end
        end
    end

    return weapons
end

function CheemCore.ResolvePriorityWeapon()

    local inv = CheemCore.ScanInventory()
    if not inv then return end

    if #inv["Sword"] > 0 then return inv["Sword"][1] end
    if #inv["Blox Fruit"] > 0 then return inv["Blox Fruit"][1] end
    if #inv["Gun"] > 0 then return inv["Gun"][1] 
    end
end

function CheemCore.RefreshWeapon()

    local selected

    if WeaponRuntime.PriorityMode then
        selected = CheemCore.ResolvePriorityWeapon()
    else
        selected = WeaponRuntime.SelectedManual
    end

    if not selected then return end

    WeaponRuntime.CurrentWeapon = selected
end

-- Quest update (slow tick)
function CheemCore.UpdateQuest(now)
    if now - Runtime.LastQuest < 1 then return end
    Runtime.LastQuest = now

    local data = LocalPlayer:FindFirstChild("Data")
    if not data or not data:FindFirstChild("Level") then return end
    local lv = data.Level.Value
    local newQuest = CheemCore.GetQuestByLevel(lv)
    if not newQuest then return end

    -- 🚀 ĐỦ LEVEL → QUEST MỚI
if not Runtime.CurrentQuest
or Runtime.CurrentQuest.QuestName ~= newQuest.QuestName
or Runtime.CurrentQuest.QuestLevel ~= newQuest.QuestLevel then

    Runtime.CurrentQuest = newQuest
    FarmConfig.MobName = newQuest.MobName

    Runtime.Target   = nil
    Runtime.HasQuest = false

    if Flags.Debug then
        warn("[CHEEM] New Quest:", newQuest.MobName)
       end
    end
end

-- UpdateQuestState
function CheemCore.UpdateQuestState()
    if CheemCore.HasQuestGui() then
        Runtime.HasQuest = true
    else
        Runtime.HasQuest = false
    end
end

-- Auto take quest (safe)
function CheemCore.TakeQuest()
    if not Flags.AutoQuest then return end

    -- 🧠 đã có quest trong UI thì thôi
    if CheemCore.HasQuestGui() then
        Runtime.HasQuest = true
        return
    end
   --Quest monitior
   
    if Runtime.HasQuest then return end

    local q = Runtime.CurrentQuest
    if not q then return end

    local CommF = ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    if CommF then
        CommF:InvokeServer("StartQuest", q.QuestName, q.QuestLevel)
        Runtime.HasQuest = true
    end
end

-- Find closest mob
function CheemCore.GetMob()
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies or not HRP then return end

    local closest, dist = nil, math.huge
    for _,mob in ipairs(enemies:GetChildren()) do
        if mob.Name == FarmConfig.MobName
        and mob:FindFirstChild("Humanoid")
        and mob:FindFirstChild("HumanoidRootPart")
        and mob.Humanoid.Health > 0 then
            local d = (HRP.Position - mob.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                closest = mob
            end
        end
    end
    return closest
end

-- Ensure island (non-block)
function CheemCore.EnsureIsland(dt)
    local q = Runtime.CurrentQuest
    if not q or not HRP then return true end

    local dist = (HRP.Position - q.IslandPos.Position).Magnitude
    if dist > 300 then
        -- move mượt (không tween, không wait)
        HRP.CFrame = HRP.CFrame:Lerp(
    q.IslandPos,
    math.clamp(dt * 1.2, 0, 0.15)
)
        return false
    end

    return true
end

-- Main farm tick (NO yield, NO wait)
function CheemCore.FarmTick(dt)
    if not HRP then return end
    local now = os.clock()

    -- Island check
    if not CheemCore.EnsureIsland(dt) then
        Runtime.Target = nil
        return
    end

    -- Scan target (cooldown)
    if not Runtime.Target
    or Runtime.Target.Humanoid.Health <= 0 then
        if now - Runtime.LastScan > 0.4 then
            Runtime.Target = CheemCore.GetMob()
            Runtime.LastScan = now
        end
        return
    end

    local mob = Runtime.Target
    local hrp = mob.HumanoidRootPart

    -- Hold position
    local attackCF = hrp.CFrame * CFrame.new(0,0,FarmConfig.AttackDistance)
    HRP.CFrame = HRP.CFrame:Lerp(attackCF, 0.35)

    -- Attack tick
    if now - Runtime.LastAttack >= FarmConfig.AttackDelay then
        mouse1click()
        Runtime.LastAttack = now
    end
end

--====================================================
-- CHEEM UI LIBRARY
--====================================================

local CheemUI = {}

local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Gui = Instance.new("ScreenGui")
Gui.Name = "CheemHub"
Gui.ResetOnSpawn = false
Gui.Parent = PlayerGui

--====================================
-- UI SHOW/HIDE ICON TOGGLE
--====================================

local UIS = game:GetService("UserInputService")

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "CheemHubToggle"
ToggleGui.ResetOnSpawn = false
ToggleGui.Parent = PlayerGui

local iconFrame = Instance.new("Frame")
iconFrame.Parent = ToggleGui
iconFrame.Size = UDim2.fromOffset(56,56)
iconFrame.Position = UDim2.fromScale(0.02,0.45)
iconFrame.BackgroundColor3 = Color3.fromRGB(60,50,180)
iconFrame.BorderSizePixel = 0
iconFrame.Active = true
Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0,16)

-- IMAGE ICON
local icon = Instance.new("ImageLabel")
icon.Parent = iconFrame
icon.Size = UDim2.fromScale(0.7,0.7)
icon.Position = UDim2.fromScale(0.15,0.15)
icon.BackgroundTransparency = 1

-- icon menu
icon.Image = "rbxassetid://3926305904"
icon.ImageRectOffset = Vector2.new(964, 324)
icon.ImageRectSize = Vector2.new(36, 36)

--====================================
-- TOGGLE LOGIC
--====================================

local uiOn = true

local function setUI(state)
    uiOn = state
    Gui.Enabled = state

    iconFrame.BackgroundColor3 =
        state and Color3.fromRGB(60,50,180)
        or Color3.fromRGB(35,35,35)
end

iconFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        setUI(not uiOn)
    end
end)

--====================================
-- DRAG ICON
--====================================

local dragging = false
local dragStart, startPos

iconFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = iconFrame.Position
    end
end)

iconFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        iconFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

local Main = Instance.new("Frame", Gui)
Main.Size = UDim2.fromScale(0.6, 0.6)
Main.Position = UDim2.fromScale(0.2, 0.2)
Main.BackgroundColor3 = Color3.fromRGB(18,18,18)
Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,12)

-- TAB (TRÁI)
local TabsFrame = Instance.new("Frame", Main)
TabsFrame.Size = UDim2.fromScale(0.25, 1)
TabsFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
TabsFrame.BorderSizePixel = 0
Instance.new("UICorner", TabsFrame).CornerRadius = UDim.new(0,12)

local TabsLayout = Instance.new("UIListLayout", TabsFrame)
TabsLayout.Padding = UDim.new(0,6)
TabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TabsPadding = Instance.new("UIPadding", TabsFrame)
TabsPadding.PaddingTop = UDim.new(0,10)

-- CONTENT (PHẢI)
local PagesFrame = Instance.new("Frame", Main)
PagesFrame.Position = UDim2.fromScale(0.25,0)
PagesFrame.Size = UDim2.fromScale(0.75,1)
PagesFrame.BackgroundColor3 = Color3.fromRGB(15,15,15)
PagesFrame.BorderSizePixel = 0
Instance.new("UICorner", PagesFrame).CornerRadius = UDim.new(0,12)

local Tabs = {}
local Pages = {}
local CurrentTab

function CheemUI:CreateTab(name)
    -- BUTTON
    local btn = Instance.new("TextButton", TabsFrame)
    btn.Size = UDim2.fromScale(0.9,0.08)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn)

    -- PAGE
    local page = Instance.new("Frame", PagesFrame)
    page.Size = UDim2.fromScale(1,1)
    page.Visible = false
    page.BackgroundTransparency = 1

    Tabs[name] = btn
    Pages[name] = page

    btn.MouseButton1Click:Connect(function()
        if CurrentTab then
            Tabs[CurrentTab].BackgroundColor3 = Color3.fromRGB(40,40,40)
            Pages[CurrentTab].Visible = false
        end
        CurrentTab = name
        btn.BackgroundColor3 = Color3.fromRGB(90,70,200)
        page.Visible = true
    end)

    if not CurrentTab then
        CurrentTab = name
        btn.BackgroundColor3 = Color3.fromRGB(90,70,200)
        page.Visible = true
    end

    return page
end

function CheemUI:CreateToggle(parent, text, default, iconId, callback)

    local holder = Instance.new("Frame", parent)
    holder.Size = UDim2.fromScale(0.9,0.1)
    holder.BackgroundTransparency = 1

    -- TEXT
    local label = Instance.new("TextLabel", holder)
    label.Size = UDim2.fromScale(0.6,1)
    label.Text = text
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(230,230,230)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    -- TOGGLE BOX (VUÔNG BO GÓC)
    local box = Instance.new("Frame", holder)
    box.Size = UDim2.fromScale(0.25,0.8)
    box.Position = UDim2.fromScale(0.7,0.1)
    box.BackgroundColor3 = default and Color3.fromRGB(230,180,40) or Color3.fromRGB(25,25,25)
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,10)

    -- VIỀN
    local stroke = Instance.new("UIStroke", box)
    stroke.Thickness = 2
    stroke.Color = default and Color3.fromRGB(255,210,60) or Color3.fromRGB(60,60,60)

    -- ICON
    local icon = Instance.new("ImageLabel", box)
    icon.Size = UDim2.fromScale(0.7,0.7)
    icon.Position = UDim2.fromScale(0.15,0.15)
    icon.BackgroundTransparency = 1
    icon.Image = iconId or ""
    icon.ImageColor3 = default and Color3.fromRGB(20,20,20) or Color3.fromRGB(180,180,180)

    -- CLICK
    local btn = Instance.new("TextButton", box)
    btn.Size = UDim2.fromScale(1,1)
    btn.Text = ""
    btn.BackgroundTransparency = 1

    btn.MouseButton1Click:Connect(function()
        default = not default
        callback(default)

        -- tween màu nền
        game:GetService("TweenService"):Create(
            box,
            TweenInfo.new(0.18),
            {
                BackgroundColor3 = default
                    and Color3.fromRGB(230,180,40)
                    or Color3.fromRGB(25,25,25)
            }
        ):Play()

        -- đổi viền
        stroke.Color = default
            and Color3.fromRGB(255,210,60)
            or Color3.fromRGB(60,60,60)

        -- đổi màu icon
        icon.ImageColor3 = default
            and Color3.fromRGB(20,20,20)
            or Color3.fromRGB(180,180,180)
    end)
end

local SettingTab = CheemUI:CreateTab("Setting farm")
local FarmTab = CheemUI:CreateTab("Farm")

local farmLayout = Instance.new("UIListLayout", FarmTab)
farmLayout.Padding = UDim.new(0,10)
farmLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local farmPad = Instance.new("UIPadding", FarmTab)
farmPad.PaddingTop = UDim.new(0,12)

CheemUI:CreateToggle(
    FarmTab,
    "Auto Farm",
    false,
    "rbxassetid://6031091004",
    function(v)
        Flags.Enabled = v
        CurrentState = v and STATE.FARM or STATE.IDLE
    end
)

--========================================
--WEAPON TYPES
--========================================
local WeaponTypes = {
    "Sword",
    "Blox Fruit",
    "Gun"
}

--================ DROPDOWN =================
local function CreateDropdown(parent, title, getList, callback)
    local box = Instance.new("Frame", parent)
    box.Size = UDim2.fromScale(0.9, 0.1)
    box.BackgroundColor3 = Color3.fromRGB(35,35,35)
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,10)

    local label = Instance.new("TextLabel", box)
    label.Size = UDim2.fromScale(1,1)
    label.Text = title .. ": None"
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundTransparency = 1

    local open = false
    local listFrame = Instance.new("Frame", parent)
    listFrame.Visible = false
    listFrame.Size = UDim2.new(0.9,0,0,0)
    listFrame.Position = UDim2.fromScale(0,0.11)
    listFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    Instance.new("UICorner", listFrame)

    local layout = Instance.new("UIListLayout", listFrame)
    layout.Padding = UDim.new(0,4)

    local function refresh()
        for _,c in ipairs(listFrame:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end

        for _,name in ipairs(getList()) do
            local btn = Instance.new("TextButton", listFrame)
            btn.Size = UDim2.new(1,0,0,30)
            btn.Text = name
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 13
            btn.TextColor3 = Color3.new(1,1,1)
            btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
            Instance.new("UICorner", btn)

            btn.MouseButton1Click:Connect(function()
                label.Text = title .. ": " .. name
                callback(name)
                listFrame.Visible = false
                open = false
            end)
        end
    end

    box.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            open = not open
            if open then
                refresh()
                listFrame.Visible = true
            else
                listFrame.Visible = false
            end
        end
    end)
end

CreateDropdown(FarmTab,"Select Weapon Type",
function()
    return WeaponTypes
end,
function(value)
    WeaponRuntime.SelectedType = value
end)

--====================================================
-- MAIN LOOP
--====================================================
RunService.Heartbeat:Connect(function(dt)

    if not Flags.Enabled then return end
    if CurrentState ~= STATE.FARM then return end

    local now = os.clock()

    CheemCore.UpdateQuest(now)
    CheemCore.UpdateEquipState(now)
    CheemCore.TakeQuest()
    CheemCore.FarmTick(dt)
end)