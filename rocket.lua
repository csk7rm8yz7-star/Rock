local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

local GuiParent = LP:WaitForChild("PlayerGui")
pcall(function()
    if CoreGui then
        local t = Instance.new("ScreenGui"); t.Parent = CoreGui; t:Destroy(); GuiParent = CoreGui
    end
end)

getgenv().Aim = true; getgenv().Smooth = 0.25; getgenv().FOV = 200
getgenv().AimMaxDist = 300; getgenv().Prediction = 0.12; getgenv().AutoFire = false
getgenv().Wall = true; getgenv().Team = true; getgenv().AimTarget = "Head"

getgenv().Silent = false; getgenv().SilentFOV = 300
getgenv().SilentTarget = "Head"; getgenv().SilentPriority = "Crosshair"

getgenv().ESP = true; getgenv().Box = true; getgenv().Chams = true
getgenv().HP = true; getgenv().Name = true; getgenv().Dist = true
getgenv().Tool = true; getgenv().Tracer = true; getgenv().MaxD = 600

local marks = {}
local tGui, eGui

local function isVis(tPart, tChar)
    if not tPart then return false end
    local ignore = {LP.Character, tChar}
    for _ = 1, 4 do
        local p = RaycastParams.new()
        p.FilterType = Enum.RaycastFilterType.Exclude
        p.FilterDescendantsInstances = ignore
        p.IgnoreWater = true
        local res = workspace:Raycast(Cam.CFrame.Position, tPart.Position - Cam.CFrame.Position, p)
        if not res then return true end
        if res.Instance.Transparency > 0.1 or res.Instance.CanCollide == false then
            table.insert(ignore, res.Instance)
        else
            return false
        end
    end
    return false
end

local function isTeam(p)
    local s, r = pcall(function() return LP.Team and p.Team and LP.Team == p.Team end)
    return s and r
end

local function removeESP(p)
    if marks[p] then
        for _, v in pairs(marks[p]) do if typeof(v) == "Instance" then v:Destroy() end end
        marks[p] = nil
    end
end

task.spawn(function()
    pcall(function()
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if getgenv().Silent and (method == "Raycast" or method == "FindPartOnRay") then
                local args = {...}
                if typeof(args[1]) == "Ray" then
                    local best, bestVal = nil, math.huge
                    local c = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local char = p.Character
                            local tPart = (getgenv().SilentTarget == "Head" and char:FindFirstChild("Head")) or char.HumanoidRootPart
                            if tPart then
                                local tm = getgenv().Team and isTeam(p)
                                if not tm then
                                    local sp, on = Cam:WorldToViewportPoint(tPart.Position)
                                    if on then
                                        local d = (Vector2.new(sp.X, sp.Y) - c).Magnitude
                                        if d <= getgenv().SilentFOV then 
                                            local val = d
                                            if getgenv().SilentPriority == "HP" then
                                                local hum = char:FindFirstChild("Humanoid")
                                                val = hum and hum.Health or math.huge
                                            end
                                            if val < bestVal then bestVal = val; best = tPart end
                                        end
                                    end
                                end
                            end
                        end
                    end
                    if best then
                        args[1] = Ray.new(Cam.CFrame.Position, (best.Position - Cam.CFrame.Position).Unit * 1000)
                        return old(self, unpack(args))
                    end
                end
            end
            return old(self, ...)
        end)
    end)
end)

pcall(function()
    for _, v in ipairs({"TacticalMenuUI", "TacticalTracerUI", "TacticalEspOverlay"}) do
        local o = GuiParent:FindFirstChild(v); if o then o:Destroy() end
    end

    tGui = Instance.new("ScreenGui"); tGui.IgnoreGuiInset = true; tGui.DisplayOrder = 1; tGui.Parent = GuiParent
    eGui = Instance.new("ScreenGui"); eGui.IgnoreGuiInset = true; eGui.DisplayOrder = 2; eGui.Parent = GuiParent
    local sGui = Instance.new("ScreenGui"); sGui.Name = "TacticalMenuUI"; sGui.IgnoreGuiInset = true; sGui.DisplayOrder = 10; sGui.Parent = GuiParent

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(50, 50); btn.Position = UDim2.new(0, 15, 0.12, 0)
    btn.BackgroundColor3 = Color3.fromRGB(240, 240, 240); btn.TextColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextSize = 22; btn.Font = Enum.Font.GothamBold; btn.Text = "⚙️"; btn.Active = true; btn.Parent = sGui
    local c1 = Instance.new("UICorner"); c1.CornerRadius = UDim.new(0, 8); c1.Parent = btn

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(400, 360); frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frame.Visible = false; frame.Parent = sGui
    local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0, 6); c2.Parent = frame
    local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(200, 200, 200); st.Parent = frame

    local hdr = Instance.new("Frame")
    hdr.Size = UDim2.new(1, 0, 0, 36); hdr.BackgroundColor3 = Color3.fromRGB(245, 245, 245); hdr.Parent = frame
    local hc = Instance.new("UICorner"); hc.CornerRadius = UDim.new(0, 6); hc.Parent = hdr

    local hLbl = Instance.new("TextLabel")
    hLbl.Size = UDim2.new(1, -60, 1, 0); hLbl.Position = UDim2.new(0, 12, 0, 0)
    hLbl.BackgroundTransparency = 1; hLbl.Text = "🔥 ROCKET | ADVANCED"
    hLbl.TextColor3 = Color3.fromRGB(30, 30, 30); hLbl.TextSize = 13; hLbl.Font = Enum.Font.GothamBold
    hLbl.TextXAlignment = Enum.TextXAlignment.Left; hLbl.Parent = hdr

    local cl = Instance.new("TextButton")
    cl.Size = UDim2.fromOffset(24, 24); cl.Position = UDim2.new(1, -32, 0, 6)
    cl.BackgroundColor3 = Color3.fromRGB(240, 240, 240); cl.TextColor3 = Color3.fromRGB(100, 100, 100)
    cl.TextSize = 14; cl.Text = "✕"; cl.Parent = hdr
    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 4); cc.Parent = cl

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, 30); bar.Position = UDim2.new(0, 12, 0, 46)
    bar.BackgroundColor3 = Color3.fromRGB(250, 250, 250); bar.Parent = frame
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 4); tc.Parent = bar
    local ts = Instance.new("UIStroke"); ts.Color = Color3.fromRGB(220, 220, 220); ts.Parent = bar
    local tl = Instance.new("UIListLayout"); tl.FillDirection = Enum.FillDirection.Horizontal; tl.Parent = bar

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -24, 1, -90); content.Position = UDim2.new(0, 12, 0, 84)
    content.BackgroundTransparency = 1; content.Parent = frame

    local pages = {}
    local function newPage(n)
        local p = Instance.new("ScrollingFrame")
        p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.BorderSizePixel = 0
        p.ScrollBarThickness = 2; p.AutomaticCanvasSize = Enum.AutomaticSize.Y
        p.Visible = false; p.Parent = content
        local lay = Instance.new("UIListLayout"); lay.Padding = UDim.new(0, 8); lay.Parent = p
        pages[n] = p; return p
    end
    local pAim = newPage("AIM"); local pSilent = newPage("SILENT"); local pEsp = newPage("ESP")

    local tBtns = {}
    local function switchTab(n)
        for name, p in pairs(pages) do p.Visible = (name == n) end
        for name, b in pairs(tBtns) do
            b.BackgroundColor3 = (name == n) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(250, 250, 250)
            b.TextColor3 = (name == n) and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(100, 100, 100)
        end
    end

    local function newTab(n, o)
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(120, 30); b.BackgroundColor3 = Color3.fromRGB(250, 250, 250)
        b.TextColor3 = Color3.fromRGB(100, 100, 100); b.TextSize = 11
        b.Font = Enum.Font.GothamMedium; b.Text = "0" .. o .. " | " .. n; b.LayoutOrder = o; b.Parent = bar
        b.MouseButton1Click:Connect(function() switchTab(n) end)
        tBtns[n] = b
    end
    newTab("AIM", 1); newTab("SILENT", 2); newTab("ESP", 3)

    local function newCheck(p, n, def, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 24); b.BackgroundTransparency = 1; b.Parent = p
        local bx = Instance.new("Frame")
        bx.Size = UDim2.fromOffset(16, 16); bx.Position = UDim2.new(0, 0, 0.5, 0); bx.AnchorPoint = Vector2.new(0, 0.5)
        bx.BackgroundColor3 = def and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(250, 250, 250); bx.Parent = b
        local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(0, 3); bc.Parent = bx
        local bs = Instance.new("UIStroke"); bs.Color = def and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(180, 180, 180); bs.Parent = bx
        local cm = Instance.new("TextLabel")
        cm.Size = UDim2.fromScale(1, 1); cm.BackgroundTransparency = 1; cm.TextColor3 = Color3.fromRGB(255, 255, 255)
        cm.TextSize = 12; cm.Font = Enum.Font.GothamBold; cm.Text = def and "✓" or ""; cm.Parent = bx
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -24, 1, 0); lbl.Position = UDim2.new(0, 24, 0, 0); lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.fromRGB(80, 80, 80); lbl.TextSize = 12; lbl.Text = n
        lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = b
        b.MouseButton1Click:Connect(function()
            local nv = cb()
            bx.BackgroundColor3 = nv and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(250, 250, 250)
            bs.Color = nv and Color3.fromRGB(255, 140, 0) or Color3.fromRGB(180, 180, 180)
            cm.Text = nv and "✓" or ""
        end)
    end

    local function newSlider(p, n, min, max, def, cb)
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, 0, 0, 36); f.BackgroundTransparency = 1; f.Parent = p
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 16); l.BackgroundTransparency = 1; l.TextColor3 = Color3.fromRGB(80, 80, 80)
        l.TextSize = 12; l.Text = n .. ": " .. tostring(def); l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, 0, 0, 6); bar.Position = UDim2.new(0, 0, 0, 20)
        bar.BackgroundColor3 = Color3.fromRGB(220, 220, 220); bar.Parent = f
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(255, 140, 0); fill.Parent = bar
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromScale(1, 1); b.BackgroundTransparency = 1; b.Text = ""; b.Parent = bar
        local drag = false
        b.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
        UIS.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local pr = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pr)
                fill.Size = UDim2.new(pr, 0, 1, 0); l.Text = n .. ": " .. val; cb(val)
            end
        end)
    end

    newCheck(pAim, "Aimbot", getgenv().Aim, function() getgenv().Aim = not getgenv().Aim; return getgenv().Aim end)
    newCheck(pAim, "Auto-Fire", getgenv().AutoFire, function() getgenv().AutoFire = not getgenv().AutoFire; return getgenv().AutoFire end)
    newCheck(pAim, "WallCheck", getgenv().Wall, function() getgenv().Wall = not getgenv().Wall; return getgenv().Wall end)
    newCheck(pAim, "TeamCheck", getgenv().Team, function() getgenv().Team = not getgenv().Team; return getgenv().Team end)
    newSlider(pAim, "Smooth", 5, 100, math.floor(getgenv().Smooth * 100), function(v) getgenv().Smooth = v / 100 end)
    newSlider(pAim, "FOV", 50, 500, getgenv().FOV, function(v) getgenv().FOV = v end)
    newSlider(pAim, "Max Dist", 50, 600, getgenv().AimMaxDist, function(v) getgenv().AimMaxDist = v end)

    newCheck(pSilent, "Silent Aim", getgenv().Silent, function() getgenv().Silent = not getgenv().Silent; return getgenv().Silent end)
    newSlider(pSilent, "Silent FOV", 50, 500, getgenv().SilentFOV, function(v) getgenv().SilentFOV = v end)

    newCheck(pEsp, "ESP", getgenv().ESP, function() getgenv().ESP = not getgenv().ESP; return getgenv().ESP end)
    newCheck(pEsp, "Box", getgenv().Box, function() getgenv().Box = not getgenv().Box; return getgenv().Box end)
    newCheck(pEsp, "HP Bar", getgenv().HP, function() getgenv().HP = not getgenv().HP; return getgenv().HP end)
    newCheck(pEsp, "Tracers", getgenv().Tracer, function() getgenv().Tracer = not getgenv().Tracer; return getgenv().Tracer end)

    local dragGear, dStartGear, sPosGear
    local dragPanel, dStartPanel, sPosPanel
    btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragGear = true; dStartGear = Vector2.new(i.Position.X, i.Position.Y); sPosGear = Vector2.new(btn.AbsolutePosition.X, btn.AbsolutePosition.Y) end end)
    btn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragGear = false end end)
    hdr.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragPanel = true; dStartPanel = Vector2.new(i.Position.X, i.Position.Y); sPosPanel = Vector2.new(frame.AbsolutePosition.X, frame.AbsolutePosition.Y) end end)
    hdr.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragPanel = false end end)
    UIS.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local pos = Vector2.new(i.Position.X, i.Position.Y)
            if dragGear then btn.Position = UDim2.new(0, sPosGear.X + (pos - dStartGear).X, 0, sPosGear.Y + (pos - dStartGear).Y) end
            if dragPanel then frame.Position = UDim2.new(0, sPosPanel.X + (pos - dStartPanel).X, 0, sPosPanel.Y + (pos - dStartPanel).Y) end
        end
    end)
    btn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
        if frame.Visible then
            local ga = btn.AbsolutePosition
            frame.Position = UDim2.new(0, math.max(10, math.min(ga.X + btn.AbsoluteSize.X + 10, sGui.AbsoluteSize.X - 430)), 0, math.max(10, ga.Y))
        end
    end)
    cl.MouseButton1Click:Connect(function() frame.Visible = false end)
    switchTab("AIM")
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        if not LP or not Cam or not tGui or not eGui then return end
        local cp = Cam.CFrame.Position
        local vp = Cam.ViewportSize
        local sc = Vector2.new(vp.X / 2, vp.Y / 2)
        local cTarget = nil
        local sDist = getgenv().FOV
        local onScreen = false

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local c = p.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                local h = c and c:FindFirstChild("Humanoid")
                if c and r and h and h.Health > 0 then
                    local d = (cp - r.Position).Magnitude
                    local tm = isTeam(p)
                    local tPass = not (getgenv().Team and tm)
                    local vis = true
                    if getgenv().Wall then vis = isVis(r, c) end

                    if d <= getgenv().MaxD then
                        if not marks[p] then
                            local col = tm and Color3.fromRGB(60, 160, 255) or Color3.fromRGB(255, 60, 60)
                            local hl = Instance.new("Highlight"); hl.FillTransparency = 0.5; hl.FillColor = col; hl.OutlineColor = col; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = c
                            
                            local gui = Instance.new("BillboardGui"); gui.Size = UDim2.fromOffset(120, 60); gui.StudsOffset = Vector3.new(0, 3, 0); gui.AlwaysOnTop = true; gui.Adornee = r; gui.Parent = r
                            local holder = Instance.new("Frame"); holder.Size = UDim2.fromScale(1, 1); holder.BackgroundTransparency = 1; holder.Parent = gui
                            local layout = Instance.new("UIListLayout"); layout.FillDirection = Enum.FillDirection.Vertical; layout.HorizontalAlignment = Enum.HorizontalAlignment.Center; layout.VerticalAlignment = Enum.VerticalAlignment.Bottom; layout.Parent = holder
                            
                            local n = Instance.new("TextLabel"); n.Size = UDim2.new(1, 0, 0, 14); n.BackgroundTransparency = 1; n.TextColor3 = col; n.TextSize = 12; n.Font = Enum.Font.GothamBold; n.TextStrokeTransparency = 0.5; n.Parent = holder
                            local hbBg = Instance.new("Frame"); hbBg.Size = UDim2.new(0.8, 0, 0, 5); hbBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40); hbBg.BorderSizePixel = 0; hbBg.Parent = holder
                            local hbFill = Instance.new("Frame"); hbFill.Size = UDim2.new(1, 0, 1, 0); hbFill.BackgroundColor3 = Color3.fromRGB(80, 220, 100); hbFill.BorderSizePixel = 0; hbFill.Parent = hbBg

                            local tr = Instance.new("Frame"); tr.BackgroundColor3 = Color3.fromRGB(255, 140, 0); tr.BorderSizePixel = 0; tr.AnchorPoint = Vector2.new(0.5, 0.5); tr.Visible = false; tr.Parent = tGui
                            local bx = Instance.new("Frame"); bx.BackgroundTransparency = 1; bx.Visible = false; bx.Parent = eGui
                            local bxs = Instance.new("UIStroke"); bxs.Color = Color3.fromRGB(255, 60, 60); bxs.Thickness = 1.5; bxs.Parent = bx

                            marks[p] = {hl = hl, tag = gui, n = n, hb = hbBg, hf = hbFill, tr = tr, bx = bx}
                        end

                        local col = tm and Color3.fromRGB(60, 160, 255) or Color3.fromRGB(255, 60, 60)
                        local show = getgenv().ESP and vis
                        local m = marks[p]

                        if m and m.tag then
                            m.hl.Enabled = getgenv().Chams and show
                            m.hl.FillColor = col
                            m.hl.OutlineColor = col
                            m.tag.Enabled = show
                            m.n.Visible = getgenv().Name; m.n.Text = p.Name; m.n.TextColor3 = col
                            m.hb.Visible = getgenv().HP
                            local hp = math.clamp(h.Health, 0, h.MaxHealth)
                            local ratio = h.MaxHealth > 0 and (hp / h.MaxHealth) or 0
                            m.hf.Size = UDim2.new(ratio, 0, 1, 0)
                        end

                        if m and m.bx then
                            local showB = getgenv().Box and show
                            m.bx.Visible = showB
                            if showB then
                                local hd = c:FindFirstChild("Head")
                                local ll = c:FindFirstChild("Left Leg") or c:FindFirstChild("LeftLeg")
                                local rl = c:FindFirstChild("Right Leg") or c:FindFirstChild("RightLeg")
                                if hd and ll and rl then
                                    local tp, tos = Cam:WorldToViewportPoint(hd.Position + Vector3.new(0, 0.5, 0))
                                    local bp, bos = Cam:WorldToViewportPoint((ll.Position + rl.Position) / 2 - Vector3.new(0, 0.5, 0))
                                    if tos and bos then
                                        local hgt = math.abs(tp.Y - bp.Y)
                                        local wid = hgt * 0.6
                                        local cx = (tp.X + bp.X) / 2
                                        local cy = (tp.Y + bp.Y) / 2
                                        m.bx.Position = UDim2.fromOffset(cx - wid / 2, cy - hgt / 2)
                                        m.bx.Size = UDim2.fromOffset(wid, hgt)
                                        local s = m.bx:FindFirstChildOfClass("UIStroke")
                                        if s then s.Color = col end
                                    else
                                        m.bx.Visible = false
                                    end
                                else
                                    m.bx.Visible = false
                                end
                            end
                        end

                        if m and m.tr then
                            local showT = getgenv().Tracer and vis and show
                            if showT then
                                local hd = c:FindFirstChild("Head")
                                local wt = hd and hd.Position or r.Position
                                local sp, os = Cam:WorldToViewportPoint(wt)
                                if os then
                                    local dl = Vector2.new(sp.X, sp.Y) - Vector2.new(vp.X / 2, vp.Y)
                                    m.tr.Position = UDim2.fromOffset(vp.X / 2, vp.Y)
                                    m.tr.Size = UDim2.fromOffset(dl.Magnitude, 1.5)
                                    m.tr.Rotation = math.deg(math.atan2(dl.Y, dl.X))
                                    m.tr.BackgroundColor3 = col
                                    m.tr.Visible = true
                                else
                                    m.tr.Visible = false
                                end
                            else
                                m.tr.Visible = false
                            end
                        end

                        if getgenv().Aim and tPass and d <= getgenv().AimMaxDist and vis then
                            local tP = (getgenv().AimTarget == "Head" and c:FindFirstChild("Head")) or r
                            if tP then
                                local pVis = true
                                if getgenv().Wall and tP ~= r then pVis = isVis(tP, c) end
                                if pVis then
                                    local pos, ons = Cam:WorldToViewportPoint(tP.Position)
                                    if ons then
                                        local d2c = (Vector2.new(pos.X, pos.Y) - sc).Magnitude
                                        if d2c < sDist then
                                            sDist = d2c
                                            local vel = r.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
                                            cTarget = tP.Position + (vel * getgenv().Prediction)
                                            onScreen = true
                                        end
                                    end
                                end
                            end
                        end
                    else
                        removeESP(p)
                    end
                else
                    removeESP(p)
                end
            end
        end

        if getgenv().Aim and cTarget then
            Cam.CFrame = Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position, cTarget), getgenv().Smooth)
        end
        
        if getgenv().AutoFire and onScreen then
            pcall(function()
                local vm = game:GetService("VirtualUser")
                vm:CaptureController()
                vm:ClickButton1(Vector2.new(vp.X/2, vp.Y/2))
            end)
        end
    end)
end)

print(">>> ROCKET | FULLY COMPLETED <<<")
