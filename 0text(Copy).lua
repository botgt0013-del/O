-- BAGIAN 1 / 3
task.wait(6.5)
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")
local VIM = game:GetService("VirtualInputManager")
local RS = game:GetService("RunService")

if PG:FindFirstChild("UltimateUI") then PG.UltimateUI:Destroy() end
if PG:FindFirstChild("AreaKillUI") then PG.AreaKillUI:Destroy() end
if PG:FindFirstChild("LootTrackerUI") then PG.LootTrackerUI:Destroy() end

-- ==========================================
-- UI AUTO DUNGEON
-- ==========================================
local SG = Instance.new("ScreenGui", PG)
SG.Name = "UltimateUI"
SG.ResetOnSpawn = false

local MF = Instance.new("Frame", SG)
MF.Size = UDim2.new(0, 200, 0, 80)
MF.Position = UDim2.new(0, 10, 0, 120)
MF.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MF.BorderSizePixel = 2
MF.BorderColor3 = Color3.fromRGB(100, 100, 100)
MF.Active = true
MF.Draggable = true

local B = Instance.new("TextButton", MF)
B.Size = UDim2.new(1, -20, 0, 30)
B.Position = UDim2.new(0, 10, 0, 10)
B.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
B.TextColor3 = Color3.fromRGB(255, 255, 255)
B.Text = "Auto Full: ON"
B.Font = Enum.Font.SourceSansBold
B.TextSize = 14
Instance.new("UICorner", B).CornerRadius = UDim.new(0, 4)

local L = Instance.new("TextLabel", MF)
L.Size = UDim2.new(1, -20, 0, 30)
L.Position = UDim2.new(0, 10, 0, 45)
L.BackgroundTransparency = 1
L.TextColor3 = Color3.fromRGB(200, 200, 200)
L.Text = "Idle"
L.Font = Enum.Font.Code
L.TextSize = 11
L.TextWrapped = true

-- ==========================================
-- UI AUTO KILL
-- ==========================================
local SG2 = Instance.new("ScreenGui", PG)
SG2.Name = "AreaKillUI"
SG2.ResetOnSpawn = false

local MF2 = Instance.new("Frame", SG2)
MF2.Size = UDim2.new(0, 200, 0, 100)
MF2.Position = UDim2.new(0, 10, 0, 210)
MF2.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MF2.BorderSizePixel = 2
MF2.BorderColor3 = Color3.fromRGB(100, 100, 100)
MF2.Active = true
MF2.Draggable = true

local B2 = Instance.new("TextButton", MF2)
B2.Size = UDim2.new(1, -20, 0, 30)
B2.Position = UDim2.new(0, 10, 0, 10)
B2.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
B2.TextColor3 = Color3.fromRGB(255, 255, 255)
B2.Text = "Auto Necro: OFF"
B2.Font = Enum.Font.SourceSansBold
B2.TextSize = 14
Instance.new("UICorner", B2).CornerRadius = UDim.new(0, 4)

local L2 = Instance.new("TextLabel", MF2)
L2.Size = UDim2.new(1, -20, 0, 30)
L2.Position = UDim2.new(0, 10, 0, 45)
L2.BackgroundTransparency = 1
L2.TextColor3 = Color3.fromRGB(200, 200, 200)
L2.Text = "Idle"
L2.Font = Enum.Font.Code
L2.TextSize = 11
L2.TextWrapped = true

-- ==========================================
-- UI LOOT TRACKER
-- ==========================================
local SG3 = Instance.new("ScreenGui", PG)
SG3.Name = "LootTrackerUI"
SG3.ResetOnSpawn = false

local MF3 = Instance.new("Frame", SG3)
MF3.Size = UDim2.new(0, 200, 0, 120)
MF3.Position = UDim2.new(0, 220, 0, 120) 
MF3.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MF3.BorderSizePixel = 2
MF3.BorderColor3 = Color3.fromRGB(100, 100, 100)
MF3.Active = true
MF3.Draggable = true

local Title2 = Instance.new("TextLabel", MF3)
Title2.Size = UDim2.new(1, 0, 0, 25)
Title2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title2.TextColor3 = Color3.fromRGB(255, 255, 255)
Title2.Text = "Loot Tracker"
Title2.Font = Enum.Font.SourceSansBold
Title2.TextSize = 14
Title2.Parent = MF3

local ItemText = Instance.new("TextLabel", MF3)
ItemText.Size = UDim2.new(1, -20, 1, -35)
ItemText.Position = UDim2.new(0, 10, 0, 30)
ItemText.BackgroundTransparency = 1
ItemText.TextColor3 = Color3.fromRGB(200, 200, 200)
ItemText.Text = "Scanning..."
ItemText.Font = Enum.Font.Code
ItemText.TextSize = 12
ItemText.TextXAlignment = Enum.TextXAlignment.Left
ItemText.TextYAlignment = Enum.TextYAlignment.Top
ItemText.TextWrapped = true
ItemText.Parent = MF3

local TRACKED_ITEMS = {
    ["Blue Candy"] = true,
    ["Red Candy"] = true,
    ["HauntedArrow"] = true,
}

-- ==========================================
-- SHARED VARIABLES & FUNCTIONS
-- ==========================================
local S = { On = true, Summoned = false, HasSummoned = false }
local AlignPos, SpinConnection, NoClipConnection = nil, nil, nil
local ShapesDone = false
local FinishProcessed = false
local PortalUseCount = 0
local PortalBlacklisted = false

local SecondPassRunning = false
local SecondPassDone    = false
local ShapeRepairRunning = false

local CurrentTarget = nil
local TargetAttackedTime = 0

local function log(msg)
    local text = "[Auto] " .. tostring(msg)
    print(text)
    if rconsoleprint then rconsoleprint(text .. "\n") end
    if L then L.Text = msg end
end

local function Click(Btn, offsetX, offsetY)
    if not Btn or not Btn.Visible then return end
    pcall(function()
        local P, Sz = Btn.AbsolutePosition, Btn.AbsoluteSize
        local ox = offsetX or 0
        local oy = offsetY or 0
        local clickX = P.X + (Sz.X / 2) + ox
        local clickY = P.Y + (Sz.Y / 2) + oy
        VIM:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
    end)
end

local function Clear()
    if AlignPos then AlignPos:Destroy() AlignPos = nil end
    if SpinConnection then SpinConnection:Disconnect() SpinConnection = nil end
    if NoClipConnection then NoClipConnection:Disconnect() NoClipConnection = nil end
end

local function ClearRig()
    if AlignPos then AlignPos:Destroy() AlignPos = nil end
    if SpinConnection then SpinConnection:Disconnect() SpinConnection = nil end
    if NoClipConnection then NoClipConnection:Disconnect() NoClipConnection = nil end
end

local function ShapeSlotsEmpty()
    local R = workspace:FindFirstChild("Reaper's Graveyard")
    local SL = R and R:FindFirstChild("PuzzleSlots")
    if not SL then return true end
    for i = 1, 5 do
        local Slot = SL:FindFirstChild(tostring(i))
        if not Slot then return false end
        if #Slot:GetChildren() > 0 then return false end
    end
    return true
end

local function ShapeSlotsExist()
    local R = workspace:FindFirstChild("Reaper's Graveyard")
    local SL = R and R:FindFirstChild("PuzzleSlots")
    return SL ~= nil
end

local function IsShapeFinal()
    local R = workspace:FindFirstChild("Reaper's Graveyard")
    if not R then return false end
    for _, part in ipairs(R:GetChildren()) do
        if part:IsA("BasePart") then
            if part:FindFirstChildOfClass("ProximityPrompt") then
                return false
            end
        end
    end
    return true
end
-- BAGIAN 2 / 3
local function AutoSummonLoop()
    while S.On do
        if not S.HasSummoned then
            local clickRegion = nil
            local ok, region = pcall(function() 
                return PG.TopBar.Standard.Holders.Left.Summon.IconButton.Menu.IconSpot.ClickRegion 
            end)
            if ok and region then
                clickRegion = region
            else
                for _, v in ipairs(PG:GetDescendants()) do
                    if v.Name == "ClickRegion" and v:IsA("TextButton") then
                        local isSummon = false
                        local p = v.Parent
                        for i = 1, 5 do
                            if p and p.Name:lower():find("summon") then isSummon = true; break end
                            if p then p = p.Parent else break end
                        end
                        if isSummon then clickRegion = v; break end
                    end
                end
            end
            if clickRegion then 
                log("Auto Summon: Menekan tombol...")
                pcall(function() clickRegion:Activate() end)
                pcall(function() clickRegion.MouseButton1Click:Fire() end)
                pcall(function()
                    local conns = getconnections(clickRegion.MouseButton1Click)
                    if conns and #conns > 0 then for _, c in ipairs(conns) do c:Fire() end end
                end)
                task.wait(2) 
                S.HasSummoned = true 
                S.Summoned = true
            end
        end
        task.wait(1) 
    end
end

local function SolveShape()
    log("Shape: Memulai SolveShape...")
    local R = workspace:FindFirstChild("Reaper's Graveyard")
    local SL = R and R:FindFirstChild("PuzzleSlots")
    if not SL then 
        log("Shape Error: PuzzleSlots tidak ditemukan.")
        return false 
    end
    local Seq = {}
    for i = 1, 5 do
        local Slot = SL:FindFirstChild(tostring(i))
        local Shape = Slot and Slot:GetChildren()[1]
        if Shape then 
            table.insert(Seq, Shape.Name) 
            log("Shape Seq "..i..": "..Shape.Name)
        end
    end
    if #Seq == 0 then 
        log("Shape Error: Sequence kosong.")
        return false 
    end
    for i, Name in ipairs(Seq) do
        if not S.On then return false end
        local Part = R:FindFirstChild(Name)
        if not Part then
            log("Shape: " .. Name .. " sudah tidak ada. Skip.")
            continue 
        end
        if Part:IsA("BasePart") then
            log("Shape: Teleport ke "..Name)
            local MyHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if MyHRP then
                MyHRP.CFrame = Part.CFrame + Vector3.new(0, 3, 0)
                task.wait(0.3)
                local P = Part:FindFirstChildOfClass("ProximityPrompt")
                if P then
                    log("Shape: Trigger Prompt "..Name)
                    pcall(function() fireproximityprompt(P) end)
                    task.wait(0.3) 
                else
                    log("Shape Error: ProximityPrompt tidak ada di "..Name)
                    return false 
                end
            end
        end
    end
    log("Shape: Attempt selesai. Verifikasi via slot occupancy.")
    return true
end

local function RunSecondPass()
    if SecondPassRunning or SecondPassDone then return end
    SecondPassRunning = true
    log("Shape: Second pass queued (0.3s)...")
    task.wait(0.3)
    if not S.On then
        SecondPassRunning = false
        return
    end
    log("Shape: Second pass starting (background)...")
    local ok = SolveShape()
    if ok and IsShapeFinal() then
        log("Shape: Second pass confirmed.")
        SecondPassDone = true
    else
        log("Shape: Second pass failed. Retrying in 0.3s...")
        task.wait(0.3)
        local ok2 = SolveShape()
        if ok2 and IsShapeFinal() then
            log("Shape: Second pass retry confirmed.")
            SecondPassDone = true
        else
            log("Shape: Second pass retry failed. Leaving ShapesDone true.")
        end
    end
    SecondPassRunning = false
end

local function StartSpin(targetHRP, Name)
    Clear()
    local myChar = LP.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local hum = myChar:FindFirstChild("Humanoid")
    if hum then
        hum.Died:Connect(function()
            log("Died. Stopping...")
            Clear()
            S.Summoned = false
            S.HasSummoned = false
        end)
    end

    myHRP.Anchored = false
    local att = Instance.new("Attachment")
    att.Parent = myHRP

    AlignPos = Instance.new("AlignPosition")
    AlignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
    AlignPos.Attachment0 = att
    AlignPos.MaxForce = 100000
    AlignPos.Responsiveness = 50
    AlignPos.ApplyAtCenterOfMass = true
    AlignPos.Parent = myHRP

    NoClipConnection = RS.Stepped:Connect(function()
        if myChar then
            for _, v in pairs(myChar:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end)

    local angle = 0
    local radius = 15
    local spinSpeed = 0.25

    SpinConnection = RS.Heartbeat:Connect(function()
        if not S.On or not targetHRP.Parent or not myHRP.Parent then return end
        angle = angle + spinSpeed
        if angle >= math.pi * 2 then angle = 0 end
        local offsetX = math.cos(angle) * radius
        local offsetZ = math.sin(angle) * radius
        AlignPos.Position = targetHRP.Position + Vector3.new(offsetX, 0, offsetZ)
        myHRP.CFrame = CFrame.lookAt(myHRP.Position, targetHRP.Position)
    end)
    
    log("Spinning: " .. Name)
end

local function StartKill(targetHRP, Name)
    if S.Summoned then
        if not AlignPos or not AlignPos.Parent then
            StartSpin(targetHRP, Name)
        end
        
        while S.On do
            if not ShapesDone or not IsShapeFinal() then
                if ShapeSlotsExist() then
                    log("Shape belum clear! Menghentikan pukulan.")
                    ShapesDone = false
                else
                    log("Shape belum selesai! Menghentikan pukulan.")
                end
                Clear()
                break 
            end

            if not AlignPos or not AlignPos.Parent then
                log("AlignPos hancur. Langsung reposisi...")
                StartSpin(targetHRP, Name) 
            end

            if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") or LP.Character.Humanoid.Health <= 0 then
                log("Player died while attacking.")
                Clear()
                return
            end

            if not targetHRP or not targetHRP.Parent then break end
            
            if Name == "Necromancer" and (tick() - TargetAttackedTime > 15) then
                log("Timeout Necromancer. Cek Shape...")
                Clear()
                if not ShapesDone then
                    log("Memaksa ulang Shape karena timeout!")
                    ShapesDone = false
                    break 
                else
                    break 
                end
            end

            local ok, punchBtn = pcall(function() return PG.BaseGui.Overlay.MobileMenu.Abilities.Punch end)
            if ok and punchBtn then
                Click(punchBtn, -50, 0)
            end
            task.wait(0.1)
        end
    end
end

-- WATCHDOG SHAPE (0.3s)
task.spawn(function()
    while true do
        task.wait(0.3)
        if S.On then
            local R = workspace:FindFirstChild("Reaper's Graveyard")
            if R then
                if IsShapeFinal() then
                    if not ShapesDone then
                        ShapesDone = true
                        log("Watchdog: Tidak ada ProximityPrompt shape. Shape Done.")
                    end
                else
                    local empty = ShapeSlotsEmpty()
                    if empty and not ShapesDone then
                        ShapesDone = true
                        log("Watchdog: Slot kosong. Shape Done (verified).")
                    elseif (not empty) and ShapesDone then
                        ShapesDone = false
                        log("Watchdog: Prompt shape tersisa. ShapesDone dibatalkan.")
                    end
                    if ShapesDone and not SecondPassDone and not SecondPassRunning and not empty then
                        log("Watchdog: second pass not yet done, re-queueing.")
                        task.spawn(RunSecondPass)
                    end
                end
            end
        end
    end
end)

-- WATCHDOG SHAPE REPAIR (0.5s) - non-blocking
task.spawn(function()
    while true do
        task.wait(0.5)
        if S.On and ShapesDone and not ShapeRepairRunning then
            local R = workspace:FindFirstChild("Reaper's Graveyard")
            if R and not IsShapeFinal() then
                ShapeRepairRunning = true
                log("WatchdogRepair: Prompt shape tersisa pasca-done. Repair pass...")
                local ok = pcall(SolveShape)
                if ok and IsShapeFinal() then
                    log("WatchdogRepair: Repair confirmed. Combat undisturbed.")
                else
                    log("WatchdogRepair: Repair inconclusive. Akan ulang pada tick berikut.")
                end
                ShapeRepairRunning = false
            end
        end
    end
end)

-- WATCHDOG TARGET (1s)
task.spawn(function()
    while true do
        task.wait(1) 
        if S.On then
            if CurrentTarget and CurrentTarget.Parent then
                local hum = CurrentTarget:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    if tick() - TargetAttackedTime > 3 then
                        log("Watchdog: Target stuck. Reset posisi instan.")
                        Clear() 
                        TargetAttackedTime = tick() 
                    end
                end
            end
        end
    end
end)
-- BAGIAN 3 / 3 — tempel SETELAH BAGIAN 2.
local function MainLoop()
    S.Summoned, S.HasSummoned = false, false
    ShapesDone = false
    SecondPassRunning = false
    SecondPassDone = false
    ShapeRepairRunning = false
    FinishProcessed = false
    PortalUseCount = 0
    PortalBlacklisted = false
    
    while S.On do
        local R = workspace:FindFirstChild("Reaper's Graveyard")
        local SL = R and R:FindFirstChild("PuzzleSlots")
        
        local Necro = workspace:FindFirstChild("Necromancer")
        local Haunted = workspace:FindFirstChild("Haunted Reaper")
        local Walter = workspace:FindFirstChild("Walter Wraith")
        
        if (Haunted or Walter) and not ShapesDone and IsShapeFinal() then
            ShapesDone = true
            log("Boss Phase Detected. Shape final. Skipping Shape.")
        end

        if not ShapesDone then
            if not SL then
                ShapesDone = true
                log("Shape Done (PuzzleSlots hilang total).")
                task.wait(0.3)
            elseif not ShapeSlotsEmpty() then
                Clear()
                log("Shape: Mencoba menyelesaikan Shape...")
                local success = SolveShape()
                if success and ShapeSlotsEmpty() then
                    ShapesDone = true
                    log("Shape Done (first pass). Combat may begin.")
                    if not SecondPassRunning and not SecondPassDone then
                        task.spawn(RunSecondPass)
                    end
                    task.wait(1)
                else
                    log("Shape belum selesai. Retry 0.5 detik...")
                    task.wait(0.5) 
                end
            else
                ShapesDone = true
                log("Shape Done (semua slot kosong)")
                if not SecondPassRunning and not SecondPassDone then
                    task.spawn(RunSecondPass)
                end
            end
        end

        local Overlay = PG.BaseGui and PG.BaseGui:FindFirstChild("Overlay")
        local FinishFrame = Overlay and Overlay:FindFirstChild("DomainFinishFrame")
        local ClaimBtn = nil
        for _, v in ipairs(PG:GetDescendants()) do
            if v:IsA("TextButton") and (v.Text:lower():find("claim reward") or v.Name:lower():find("claim")) and v.Visible then
                ClaimBtn = v
                break
            end
        end

        if FinishFrame and FinishFrame.Visible and not FinishProcessed then
            FinishProcessed = true
            log("Dungeon Finished!")
            
            local LeaveBtn = FinishFrame:FindFirstChild("LeaveDomainButton")
            if LeaveBtn and LeaveBtn.Visible then
                log("Clicking Leave Domain...")
                Click(LeaveBtn)
                task.wait(2)
            end
            
            local ReplayBtn = FinishFrame:FindFirstChild("ReplayDomainButton")
            if ReplayBtn and ReplayBtn.Visible then
                log("Clicking Replay...")
                Click(ReplayBtn)
            end
        elseif ClaimBtn then
            log("Clicking Claim Reward...")
            Click(ClaimBtn)
            task.wait(2)
        else
            local IsNecroAlive = Necro and Necro:FindFirstChild("Humanoid") and Necro.Humanoid.Health > 0
            local IsHauntedAlive = Haunted and Haunted:FindFirstChild("Humanoid") and Haunted.Humanoid.Health > 0
            local IsWalterAlive = Walter and Walter:FindFirstChild("Humanoid") and Walter.Humanoid.Health > 0

            if IsWalterAlive or IsHauntedAlive or IsNecroAlive then
                if (not ShapesDone or not IsShapeFinal()) then
                    log("Blocking attack. Menunggu Shape...")
                    ShapesDone = false
                    Clear()
                    task.wait(0.5)
                else
                    local Target = nil
                    if IsWalterAlive then Target = Walter
                    elseif IsHauntedAlive then Target = Haunted
                    elseif IsNecroAlive then Target = Necro end

                    if CurrentTarget ~= Target then
                        Clear()
                        CurrentTarget = Target
                        TargetAttackedTime = tick() 
                    end

                    StartKill(Target:FindFirstChild("HumanoidRootPart"), Target.Name)
                end
            else
                Clear()
                CurrentTarget = nil
                local Portal = R and R:FindFirstChild("Portal")
                if Portal and not PortalBlacklisted then
                    if PortalUseCount < 4 then
                        log("Entering Portal ("..(PortalUseCount+1).."/4)...")
                        local MyHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if MyHRP then
                            if Portal:IsA("BasePart") then MyHRP.CFrame = Portal.CFrame + Vector3.new(0, 3, 0)
                            elseif Portal:IsA("Model") and Portal.PrimaryPart then MyHRP.CFrame = Portal.PrimaryPart.CFrame + Vector3.new(0, 3, 0) end
                            task.wait(0.5)
                            local Attach = Portal:FindFirstChild("Attachment")
                            local Prompt = Attach and Attach:FindFirstChildOfClass("ProximityPrompt")
                            if Prompt then pcall(function() fireproximityprompt(Prompt) end) PortalUseCount = PortalUseCount + 1 task.wait(2) end
                        end
                    else
                        PortalBlacklisted = true
                        log("Portal maxed. Waiting...")
                        task.wait(1)
                    end
                else
                    log("Waiting for next phase...")
                    if not R then
                        ShapesDone = false
                        SecondPassRunning = false
                        SecondPassDone = false
                        ShapeRepairRunning = false
                        S.Summoned, S.HasSummoned = false, false
                        FinishProcessed = false
                        PortalUseCount = 0
                        PortalBlacklisted = false
                    end
                    task.wait(0.5)
                end
            end
        end
        task.wait(0.1)
    end
    Clear()
    log("Idle")
end

-- ==========================================
-- LOGIKA AUTO NECRO
-- ==========================================
local S_Necro = { On = false }
local ENEMY_NAMES = {"Necromancer"} 
local POINT_1 = Vector3.new(300.51, 10.20, 198.57)
local POINT_2 = Vector3.new(-734.51, 10.19, 180.96)
local MAX_DISTANCE = 550 

local CurrentNecroTarget = nil
local SearchStartTime = tick()
local CurrentPoint = 1

local function logNecro(msg)
    local text = "[NecroKill] " .. tostring(msg)
    print(text)
    if rconsoleprint then rconsoleprint(text .. "\n") end
    if L2 then L2.Text = msg end
end

local function StartAttack(Target)
    ClearRig()
    CurrentNecroTarget = Target
    local MyHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local TargetHRP = Target and Target:FindFirstChild("HumanoidRootPart")
    if not MyHRP or not TargetHRP then return end

    local summonBtn = nil
    local okTop, topBtn = pcall(function() return PG.TopBar.Standard.Holders.Left.Summon.IconButton.Menu.IconSpot.ClickRegion end)
    if okTop and topBtn then summonBtn = topBtn end
    
    if summonBtn then 
        logNecro("Summoning Stand...")
        pcall(function() summonBtn:Activate() end)
        Click(summonBtn) 
        task.wait(2) 
    end

    AlignPos = Instance.new("AlignPosition", MyHRP)
    AlignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
    AlignPos.Attachment0 = MyHRP:FindFirstChild("RootAttachment") or Instance.new("Attachment", MyHRP)
    AlignPos.MaxForce = 100000
    AlignPos.Responsiveness = 50

    NoClipConnection = RS.Stepped:Connect(function()
        if LP.Character then
            for _, v in pairs(LP.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
            end
        end
    end)

    local angle = 0
    local radius = 15
    local spinSpeed = 0.25

    SpinConnection = RS.Heartbeat:Connect(function()
        if not S_Necro.On or not CurrentNecroTarget or not CurrentNecroTarget.Parent then return end
        local h = CurrentNecroTarget:FindFirstChild("Humanoid")
        if not h or h.Health <= 0 then return end
        angle = angle + spinSpeed
        if angle >= math.pi * 2 then angle = 0 end
        local offsetX = math.cos(angle) * radius
        local offsetZ = math.sin(angle) * radius
        AlignPos.Position = TargetHRP.Position + Vector3.new(offsetX, 0, offsetZ)
        MyHRP.CFrame = CFrame.lookAt(MyHRP.Position, TargetHRP.Position)
    end)

    task.spawn(function()
        while S_Necro.On do
            if not CurrentNecroTarget or not CurrentNecroTarget.Parent then break end
            local h = CurrentNecroTarget:FindFirstChild("Humanoid")
            if not h or h.Health <= 0 then break end
            local ok, punchBtn = pcall(function() return PG.BaseGui.Overlay.MobileMenu.Abilities.Punch end)
            if ok and punchBtn then Click(punchBtn) end
            task.wait(0.1)
        end
        ClearRig()
    end)
    
    logNecro("Attacking: " .. Target.Name)
end

local function MainLoopNecro()
    SearchStartTime = tick()
    
    while S_Necro.On do
        local MyHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not MyHRP then 
            ClearRig()
            task.wait(1) 
            continue 
        end

        if CurrentNecroTarget and CurrentNecroTarget.Parent then
            local h = CurrentNecroTarget:FindFirstChild("Humanoid")
            if h and h.Health > 0 then
                task.wait(0.5)
                continue
            end
        end

        local ActiveCenter = (CurrentPoint == 1) and POINT_1 or POINT_2

        local ClosestTarget = nil
        local ShortestDist = MAX_DISTANCE

        for _, obj in ipairs(workspace:GetDescendants()) do
            local isEnemy = false
            for _, name in ipairs(ENEMY_NAMES) do
                if obj.Name == name then
                    isEnemy = true
                    break
                end
            end

            if isEnemy then
                local h = obj:FindFirstChild("Humanoid")
                local hrp = obj:FindFirstChild("HumanoidRootPart")
                
                if h and hrp and h.Health > 0 then
                    local enemyDistToCenter = (hrp.Position - ActiveCenter).Magnitude
                    if enemyDistToCenter <= MAX_DISTANCE then
                        local dist = (hrp.Position - MyHRP.Position).Magnitude
                        if dist < ShortestDist then
                            ShortestDist = dist
                            ClosestTarget = obj
                        end
                    end
                end
            end
        end

        if ClosestTarget then
            SearchStartTime = tick() 
            StartAttack(ClosestTarget)
        else
            logNecro("Searching Necromancer...")
            ClearRig()
            
            if tick() - SearchStartTime > 2 then
                if CurrentPoint == 1 then
                    CurrentPoint = 2
                    logNecro("Teleporting to Point 2...")
                else
                    CurrentPoint = 1
                    logNecro("Teleporting to Point 1...")
                end
                MyHRP.CFrame = CFrame.new((CurrentPoint == 1) and POINT_1 or POINT_2)
                SearchStartTime = tick()
                task.wait(1)
            end
        end
        task.wait(0.5)
    end
    ClearRig()
end

-- ==========================================
-- LOOP LOOT TRACKER
-- ==========================================
task.spawn(function()
    while true do
        task.wait(1) 
        local itemsFound = {}
        local addedItems = {}
        
        local baseGui = PG:FindFirstChild("BaseGui")
        local overlay = baseGui and baseGui:FindFirstChild("Overlay")
        
        if overlay then
            local invFrame = overlay:FindFirstChild("InventoryFrame")
            local itemFrame = invFrame and invFrame:FindFirstChild("ItemFrame")
            local itemList = itemFrame and itemFrame:FindFirstChild("ItemList")
            
            if not itemList then
                local mainMenu = overlay:FindFirstChild("MainMenu")
                local container = mainMenu and mainMenu:FindFirstChild("Container")
                local inv = container and container:FindFirstChild("Inv")
                itemList = inv and inv:FindFirstChild("ItemList")
            end

            if itemList then
                for _, item in ipairs(itemList:GetChildren()) do
                    if TRACKED_ITEMS[item.Name] then
                        local qty = ""
                        local textLabel = item:FindFirstChild("TextLabel")
                        if textLabel and textLabel:IsA("TextLabel") and textLabel.Text ~= "" then
                            qty = " " .. textLabel.Text
                        end
                        local displayName = "- " .. item.Name .. qty
                        if not addedItems[displayName] then
                            table.insert(itemsFound, displayName)
                            addedItems[displayName] = true
                        end
                    end
                end
            end
        end
        
        if #itemsFound > 0 then
            ItemText.Text = table.concat(itemsFound, "\n")
        else
            ItemText.Text = "No items."
        end
    end
end)

-- ==========================================
-- EVENT BINDINGS
-- ==========================================
B.MouseButton1Click:Connect(function()
    S.On = not S.On
    B.Text = S.On and "Auto Full: ON" or "Auto Full: OFF"
    B.BackgroundColor3 = S.On and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(150, 50, 50)
    if S.On then 
        task.spawn(MainLoop)
        task.spawn(AutoSummonLoop)
    else 
        Clear() 
    end
end)

B2.MouseButton1Click:Connect(function()
    S_Necro.On = not S_Necro.On
    B2.Text = S_Necro.On and "Auto Necro: ON" or "Auto Necro: OFF"
    B2.BackgroundColor3 = S_Necro.On and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(150, 50, 50)
    if S_Necro.On then 
        task.spawn(MainLoopNecro) 
    else 
        ClearRig() 
    end
end)

LP.CharacterAdded:Connect(function(char)
    Clear() 
    ClearRig()
    S.Summoned, S.HasSummoned = false, false
    S_Necro.On = false
    B2.Text = "Auto Necro: OFF"
    B2.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    log("Respawned. Resetting states...")
    task.wait(3)
    if S.On then 
        task.spawn(MainLoop)
        task.spawn(AutoSummonLoop)
    end
end)

task.spawn(MainLoop)
task.spawn(AutoSummonLoop)