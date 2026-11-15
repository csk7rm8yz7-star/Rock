--==[ Rocket Ultimate: ImGui Edition ]==--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

local GuiParent = LP:WaitForChild("PlayerGui")

-- Настройки
getgenv().Aim = true; getgenv().Smooth = 0.25; getgenv().FOV = 200
getgenv().AimMaxDist = 300; getgenv().Prediction = 12
getgenv().Wall = true; getgenv().Team = true
getgenv().Silent = false; getgenv().SilentFOV = 300
getgenv().SilentTarget = "Head"; getgenv().SilentWall = true; getgenv().SilentHP = false
getgenv().ESP = true; getgenv().Box = true; getgenv().Chams = true
getgenv().HP = true; getgenv().Name = true; getgenv().Dist = true
getgenv().Tracer = true; getgenv().MaxD = 900
getgenv().ESP_WallCheck = false; getgenv().VehicleESP = true
getgenv().Hitbox = false; getgenv().HitboxSize = 3; getgenv().Fullbright = false

local marks = {}
local vMarks = {}
local tGui = Instance.new("ScreenGui"); tGui.IgnoreGuiInset = true; tGui.DisplayOrder = 1; tGui.Parent = GuiParent
local eGui = Instance.new("ScreenGui"); eGui.IgnoreGuiInset = true; eGui.DisplayOrder = 2; eGui.Parent = GuiParent

-- Утилиты
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

local function removeVESP(obj)
    if vMarks[obj] then
        for _, v in pairs(vMarks[obj]) do if typeof(v) == "Instance" then v:Destroy() end end
        vMarks[obj] = nil
    end
end

task.spawn(function()
    pcall(function()
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local m = getnamecallmethod()
            if getgenv().Silent and (m == "Raycast" or m == "FindPartOnRay") then
                local args = {...}
                if typeof(args[1]) == "Ray" then
                    local best, bv = nil, math.huge
                    local c = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local ch = p.Character
                            local tp = (getgenv().SilentTarget == "Head" and ch:FindFirstChild("Head")) or ch.HumanoidRootPart
                            local tm = getgenv().Team and isTeam(p)
                            local wallBlock = (getgenv().SilentWall and not isVis(tp, ch))
                            if not tm and not wallBlock then
                                local sp, on = Cam:WorldToViewportPoint(tp.Position)
                                if on then
                                    local d = (Vector2.new(sp.X, sp.Y) - c).Magnitude
                                    if d <= getgenv().SilentFOV then
                                        local val = d
                                        if getgenv().SilentHP then
                                            local hum = ch:FindFirstChild("Humanoid")
                                            val = hum and hum.Health or math.huge
                                        end
                                        if val < bv then bv = val; best = tp end
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

-- GUI Стиль ImGui
local sGui = Instance.new("ScreenGui"); sGui.Name = "TacticalMenuUI"; sGui.IgnoreGuiInset = true; sGui.DisplayOrder = 10; sGui.Parent = GuiParent
local btn = Instance.new("TextButton"); btn.Size = UDim2.fromOffset(50, 50); btn.Position = UDim2.new(0, 15, 0.12, 0); btn.BackgroundColor3 = Color3.fromRGB(30, 30, 35); btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.TextSize = 22; btn.Font = Enum.Font.GothamBold; btn.Text = "⚙️"; btn.Active = true; btn.Parent = sGui
local c1 = Instance.new("UICorner"); c1.CornerRadius = UDim.new(0, 8); c1.Parent = btn

local frame = Instance.new("Frame"); frame.Size = UDim2.fromOffset(550, 350); frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); frame.Visible = false; frame.Parent = sGui
local c2 = Instance.new("UICorner"); c2.CornerRadius = UDim.new(0, 6); c2.Parent = frame
local st = Instance.new("UIStroke"); st.Color = Color3.fromRGB(45, 45, 50); st.Thickness = 1.5; st.Parent = frame

-- Боковая панель (Вкладки)
local sidebar = Instance.new("Frame"); sidebar.Size = UDim2.new(0, 140, 1, 0); sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30); sidebar.Parent = frame
local sc1 = Instance.new("UICorner"); sc1.CornerRadius = UDim.new(0, 6); sc1.Parent = sidebar

local logo = Instance.new("TextLabel"); logo.Size = UDim2.new(1, 0, 0, 40); logo.BackgroundTransparency = 1; logo.Text = "ROCKET"; logo.TextColor3 = Color3.fromRGB(100, 150, 255); logo.Font = Enum.Font.GothamBold; logo.TextSize = 14; logo.Parent = sidebar

local content = Instance.new("Frame"); content.Size = UDim2.new(1, -140, 1, 0); content.Position = UDim2.new(0, 140, 0, 0); content.BackgroundTransparency = 1; content.Parent = frame

local pages = {}
local function newPage(n)
    local p = Instance.new("ScrollingFrame"); p.Size = UDim2.new(1, -20, 1, -20); p.Position = UDim2.new(0, 10, 0, 10); p.BackgroundTransparency = 1; p.BorderSizePixel = 0; p.ScrollBarThickness = 2; p.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255); p.AutomaticCanvasSize = Enum.AutomaticSize.Y; p.Visible = false; p.Parent = content
    local lay = Instance.new("UIListLayout"); lay.Padding = UDim.new(0, 12); lay.Parent = p
    pages[n] = p; return p
end

local pAim = newPage("AIM"); local pSilent = newPage("SILENT"); local pEsp = newPage("ESP"); local pMisc = newPage("MISC")
local tBtns = {}
local function switchTab(n)
    for name, p in pairs(pages) do p.Visible = (name == n) end
    for name, b in pairs(tBtns) do 
        b.BackgroundColor3 = (name == n) and Color3.fromRGB(40, 45, 60) or Color3.fromRGB(30, 30, 35)
        b.TextColor3 = (name == n) and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(150, 150, 150) 
    end
end

local function newTab(n, o)
    local b = Instance.new("TextButton"); b.Size = UDim2.new(1, -20, 0, 30); b.Position = UDim2.new(0, 10, 0, 40 + (o * 35)); b.BackgroundColor3 = Color3.fromRGB(30, 30, 35); b.TextColor3 = Color3.fromRGB(150, 150, 150); b.TextSize = 12; b.Font = Enum.Font.GothamBold; b.Text = n; b.TextXAlignment = Enum.TextXAlignment.Left; b.Parent = sidebar
    local tc = Instance.new("UICorner"); tc.CornerRadius = UDim.new(0, 4); tc.Parent = b
    local pad = Instance.new("UIPadding"); pad.PaddingLeft = UDim.new(0, 10); pad.Parent = b
    b.MouseButton1Click:Connect(function() switchTab(n) end); tBtns[n] = b
end
newTab("AIM", 1); newTab("SILENT", 2); newTab("ESP", 3); newTab("MISC", 4)

-- Функция Тумблера (переключателя)
local function newToggle(p, n, def, cb)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, 30); f.BackgroundTransparency = 1; f.Parent = p
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -60, 1, 0); l.BackgroundTransparency = 1; l.TextColor3 = Color3.fromRGB(200, 200, 200); l.TextSize = 12; l.Font = Enum.Font.Gotham; l.Text = n; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
    
    local bg = Instance.new("Frame"); bg.Size = UDim2.fromOffset(36, 18); bg.Position = UDim2.new(1, -36, 0.5, -9); bg.BackgroundColor3 = def and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(50, 50, 55); bg.Parent = f
    local bc = Instance.new("UICorner"); bc.CornerRadius = UDim.new(1, 0); bc.Parent = bg
    
    local knob = Instance.new("Frame"); knob.Size = UDim2.fromOffset(14, 14); knob.Position = def and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7); knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knob.Parent = bg
    local kc = Instance.new("UICorner"); kc.CornerRadius = UDim.new(1, 0); kc.Parent = knob
    
    local btn = Instance.new("TextButton"); btn.Size = UDim2.fromScale(1, 1); btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = f
    
    btn.MouseButton1Click:Connect(function()
        local val = cb()
        bg.BackgroundColor3 = val and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(50, 50, 55)
        knob.Position = val and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    end)
end

-- Функция Слайдера (с цифрой)
local function newSlider(p, n, min, max, def, cb)
    local f = Instance.new("Frame"); f.Size = UDim2.new(1, 0, 0, 40); f.BackgroundTransparency = 1; f.Parent = p
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, 0, 0, 16); l.BackgroundTransparency = 1; l.TextColor3 = Color3.fromRGB(200, 200, 200); l.TextSize = 12; l.Font = Enum.Font.Gotham; l.Text = n; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = f
    
    local box = Instance.new("Frame"); box.Size = UDim2.new(1, 0, 0, 20); box.Position = UDim2.new(0, 0, 0, 20); box.BackgroundColor3 = Color3.fromRGB(30, 30, 35); box.Parent = f
    local boxc = Instance.new("UICorner"); boxc.CornerRadius = UDim.new(0, 4); boxc.Parent = box
    
    local fill = Instance.new("Frame"); fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(100, 150, 255); fill.Parent = box
    local fillc = Instance.new("UICorner"); fillc.CornerRadius = UDim.new(0, 4); fillc.Parent = fill
    
    local txt = Instance.new("TextLabel"); txt.Size = UDim2.fromScale(1, 1); txt.BackgroundTransparency = 1; txt.TextColor3 = Color3.fromRGB(255, 255, 255); txt.TextSize = 12; txt.Font = Enum.Font.GothamBold; txt.Text = tostring(def); txt.ZIndex = 2; txt.Parent = box
    
    local btn = Instance.new("TextButton"); btn.Size = UDim2.fromScale(1, 1); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 3; btn.Parent = box
    local drag = false
    btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
    UIS.InputChanged:Connect(function(i) 
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then 
            local pr = math.clamp((i.Position.X - box.AbsolutePosition.X) / box.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pr)
            fill.Size = UDim2.new(pr, 0, 1, 0)
            txt.Text = tostring(val)
            cb(val) 
        end 
    end)
end

-- Наполнение страниц
newToggle(pAim, "Aimbot", getgenv().Aim, function() getgenv().Aim = not getgenv().Aim; return getgenv().Aim end)
newToggle(pAim, "WallCheck", getgenv().Wall, function() getgenv().Wall = not getgenv().Wall; return getgenv().Wall end)
newToggle(pAim, "TeamCheck", getgenv().Team, function() getgenv().Team = not getgenv().Team; return getgenv().Team end)
newSlider(pAim, "FOV", 50, 500, getgenv().FOV, function(v) getgenv().FOV = v end)
newSlider(pAim, "Smoothness", 5, 100, math.floor(getgenv().Smooth * 100), function(v) getgenv().Smooth = v / 100 end)
newSlider(pAim, "Prediction", 0, 50, getgenv().Prediction, function(v) getgenv().Prediction = v / 100 end)

newToggle(pSilent, "Silent Aim", getgenv().Silent, function() getgenv().Silent = not getgenv().Silent; return getgenv().Silent end)
newToggle(pSilent, "Visible Check", getgenv().SilentWall, function() getgenv().SilentWall = not getgenv().SilentWall; return getgenv().SilentWall end)
newToggle(pSilent, "Target Head", (getgenv().SilentTarget == "Head"), function() getgenv().SilentTarget = (getgenv().SilentTarget == "Head") and "Body" or "Head"; return getgenv().SilentTarget == "Head" end)
newSlider(pSilent, "Silent FOV", 50, 500, getgenv().SilentFOV, function(v) getgenv().SilentFOV = v end)

newToggle(pEsp, "ESP Enable", getgenv().ESP, function() getgenv().ESP = not getgenv().ESP; return getgenv().ESP end)
newToggle(pEsp, "Box", getgenv().Box, function() getgenv().Box = not getgenv().Box; return getgenv().Box end)
newToggle(pEsp, "Tracers", getgenv().Tracer, function() getgenv().Tracer = not getgenv().Tracer; return getgenv().Tracer end)
newToggle(pEsp, "Chams", getgenv().Chams, function() getgenv().Chams = not getgenv().Chams; return getgenv().Chams end)
newToggle(pEsp, "Vehicle ESP", getgenv().VehicleESP, function() getgenv().VehicleESP = not getgenv().VehicleESP; return getgenv().VehicleESP end)
newSlider(pEsp, "Max Dist", 100, 2000, getgenv().MaxD, function(v) getgenv().MaxD = v end)

newToggle(pMisc, "Hitbox Expander", getgenv().Hitbox, function() getgenv().Hitbox = not getgenv().Hitbox; return getgenv().Hitbox end)
newSlider(pMisc, "Hitbox Size", 1, 10, getgenv().HitboxSize, function(v) getgenv().HitboxSize = v end)
newToggle(pMisc, "Fullbright", getgenv().Fullbright, function()
    getgenv().Fullbright = not getgenv().Fullbright
    if getgenv().Fullbright then
        Lighting.Brightness = 3; Lighting.ClockTime = 14; Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200); Lighting.Ambient = Color3.fromRGB(200, 200, 200)
    else
        Lighting.Brightness = 1; Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128); Lighting.Ambient = Color3.fromRGB(70, 70, 70)
    end
    return getgenv().Fullbright
end)

-- Перетаскивание
local dg, ds, dp
btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = true; ds = Vector2.new(i.Position.X, i.Position.Y); dp = Vector2.new(btn.AbsolutePosition.X, btn.AbsolutePosition.Y) end end)
btn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = false end end)
UIS.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        if dg then btn.Position = UDim2.new(0, dp.X + (i.Position.X - ds.X), 0, dp.Y + (i.Position.Y - ds.Y)) end
    end
end)
btn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible; if frame.Visible then local ga = btn.AbsolutePosition; frame.Position = UDim2.new(0, math.max(10, math.min(ga.X + btn.AbsoluteSize.X + 10, sGui.AbsoluteSize.X - 560)), 0, math.max(10, ga.Y)) end end)
switchTab("AIM")

-- Логика (цикл)
RunService.RenderStepped:Connect(function()
    pcall(function()
        local cp = Cam.CFrame.Position; local vp = Cam.ViewportSize; local sc = Vector2.new(vp.X / 2, vp.Y / 2); local cTarget = nil; local sDist = getgenv().FOV
        
        if getgenv().VehicleESP then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and (string.find(obj.Name:lower(), "tigr") or string.find(obj.Name:lower(), "pickup") or string.find(obj.Name:lower(), "atv")) then
                    local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                    if primary then
                        local d = (cp - primary.Position).Magnitude
                        if d <= getgenv().MaxD then
                            if not vMarks[obj] then
                                local hl = Instance.new("Highlight"); hl.FillTransparency = 1; hl.OutlineColor = Color3.fromRGB(255, 255, 0); hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = obj
                                local gui = Instance.new("BillboardGui"); gui.Size = UDim2.fromOffset(100, 20); gui.StudsOffset = Vector3.new(0, 3, 0); gui.AlwaysOnTop = true; gui.Adornee = primary; gui.Parent = primary
                                local n = Instance.new("TextLabel"); n.Size = UDim2.new(1, 0, 1, 0); n.BackgroundTransparency = 1; n.TextColor3 = Color3.fromRGB(255, 255, 0); n.TextSize = 12; n.Font = Enum.Font.GothamBold; n.TextStrokeTransparency = 0.5; n.Parent = gui
                                vMarks[obj] = {hl = hl, tag = gui, n = n}
                            end
                            local m = vMarks[obj]; m.tag.Enabled = true; m.hl.Enabled = true; m.n.Text = obj.Name .. " [" .. math.floor(d) .. "m]"
                        else removeVESP(obj) end
                    end
                end
            end
        else for obj, _ in pairs(vMarks) do removeVESP(obj) end end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local c = p.Character; local r = c and c:FindFirstChild("HumanoidRootPart"); local h = c and c:FindFirstChild("Humanoid")
                if c and r and h and h.Health > 0 then
                    if getgenv().Hitbox then pcall(function() if not c:FindFirstChild("THB") then local hb = Instance.new("Part"); hb.Name = "THB"; hb.Shape = Enum.PartType.Ball; hb.Size = Vector3.new(1,1,1) * getgenv().HitboxSize; hb.Transparency = 1; hb.CanCollide = false; hb.Massless = true; local w = Instance.new("Weld"); w.Part0 = r; w.Part1 = hb; w.Parent = hb; hb.Parent = c else c.THB.Size = Vector3.new(1,1,1) * getgenv().HitboxSize end end) end
                    local d = (cp - r.Position).Magnitude; local tm = isTeam(p); local tPass = not (getgenv().Team and tm)
                    local visAim = true; if getgenv().Wall then visAim = isVis(r, c) end
                    local visEsp = true; if getgenv().ESP_WallCheck then visEsp = isVis(r, c) end

                    if d <= getgenv().MaxD then
                        if not marks[p] then
                            local col = tm and Color3.fromRGB(60, 160, 255) or Color3.fromRGB(255, 60, 60)
                            local hl = Instance.new("Highlight"); hl.FillTransparency = 0.5; hl.FillColor = col; hl.OutlineColor = col; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = c
                            local gui = Instance.new("BillboardGui"); gui.Size = UDim2.fromOffset(120, 60); gui.StudsOffset = Vector3.new(0, 3, 0); gui.AlwaysOnTop = true; gui.Adornee = r; gui.Parent = r
                            local holder = Instance.new("Frame"); holder.Size = UDim2.fromScale(1, 1); holder.BackgroundTransparency = 1; holder.Parent = gui
                            local n = Instance.new("TextLabel"); n.Size = UDim2.new(1, 0, 0, 14); n.BackgroundTransparency = 1; n.TextColor3 = col; n.TextSize = 12; n.Font = Enum.Font.GothamBold; n.TextStrokeTransparency = 0.5; n.Parent = holder
                            local hbBg = Instance.new("Frame"); hbBg.Size = UDim2.new(0.8, 0, 0, 5); hbBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40); hbBg.BorderSizePixel = 0; hbBg.Parent = holder
                            local hbFill = Instance.new("Frame"); hbFill.Size = UDim2.new(1, 0, 1, 0); hbFill.BackgroundColor3 = Color3.fromRGB(80, 220, 100); hbFill.BorderSizePixel = 0; hbFill.Parent = hbBg
                            local tr = Instance.new("Frame"); tr.BackgroundColor3 = Color3.fromRGB(255, 140, 0); tr.BorderSizePixel = 0; tr.AnchorPoint = Vector2.new(0.5, 0.5); tr.Visible = false; tr.Parent = tGui
                            local bx = Instance.new("Frame"); bx.BackgroundTransparency = 1; bx.Visible = false; bx.Parent = eGui
                            local bxs = Instance.new("UIStroke"); bxs.Color = Color3.fromRGB(255, 60, 60); bxs.Thickness = 1.5; bxs.Parent = bx
                            marks[p] = {hl = hl, tag = gui, n = n, hb = hbBg, hf = hbFill, tr = tr, bx = bx}
                        end
                        local col = tm and Color3.fromRGB(60, 160, 255) or Color3.fromRGB(255, 60, 60); local show = getgenv().ESP and visEsp; local m = marks[p]
                        if m and m.tag then m.hl.Enabled = getgenv().Chams and show; m.hl.FillColor = col; m.hl.OutlineColor = col; m.tag.Enabled = show; m.n.Visible = getgenv().Name; m.n.Text = p.Name; m.n.TextColor3 = col; m.hb.Visible = getgenv().HP; local hp = math.clamp(h.Health, 0, h.MaxHealth); local ratio = h.MaxHealth > 0 and (hp / h.MaxHealth) or 0; m.hf.Size = UDim2.new(ratio, 0, 1, 0) end
                        if m and m.bx then local showB = getgenv().Box and show; m.bx.Visible = showB; if showB then local hd = c:FindFirstChild("Head"); local ll = c:FindFirstChild("Left Leg") or c:FindFirstChild("LeftLeg"); local rl = c:FindFirstChild("Right Leg") or c:FindFirstChild("RightLeg"); if hd and ll and rl then local tp, tos = Cam:WorldToViewportPoint(hd.Position + Vector3.new(0, 0.5, 0)); local bp, bos = Cam:WorldToViewportPoint((ll.Position + rl.Position) / 2 - Vector3.new(0, 0.5, 0)); if tos and bos then local hgt = math.abs(tp.Y - bp.Y); local wid = hgt * 0.6; local cx = (tp.X + bp.X) / 2; local cy = (tp.Y + bp.Y) / 2; m.bx.Position = UDim2.fromOffset(cx - wid / 2, cy - hgt / 2); m.bx.Size = UDim2.fromOffset(wid, hgt); local s = m.bx:FindFirstChildOfClass("UIStroke"); if s then s.Color = col end else m.bx.Visible = false end else m.bx.Visible = false end end end
                        if m and m.tr then local showT = getgenv().Tracer and visEsp and show; if showT then local hd = c:FindFirstChild("Head"); local wt = hd and hd.Position or r.Position; local sp, os = Cam:WorldToViewportPoint(wt); if os then local dl = Vector2.new(sp.X, sp.Y) - Vector2.new(vp.X / 2, vp.Y); m.tr.Position = UDim2.fromOffset(vp.X / 2, vp.Y); m.tr.Size = UDim2.fromOffset(dl.Magnitude, 1.5); m.tr.Rotation = math.deg(math.atan2(dl.Y, dl.X)); m.tr.BackgroundColor3 = col; m.tr.Visible = true else m.tr.Visible = false end else m.tr.Visible = false end end
                        
                        if getgenv().Aim and tPass and d <= getgenv().AimMaxDist and visAim then local tP = c:FindFirstChild("Head") or r; if tP then local pVis = true; if getgenv().Wall and tP ~= r then pVis = isVis(tP, c) end; if pVis then local pos, ons = Cam:WorldToViewportPoint(tP.Position); if ons then local d2c = (Vector2.new(pos.X, pos.Y) - sc).Magnitude; if d2c < sDist then sDist = d2c; local vel = r.AssemblyLinearVelocity or Vector3.new(0, 0, 0); cTarget = tP.Position + (vel * getgenv().Prediction) end end end end end
                    else removeESP(p) end
                else removeESP(p) end
            end
        end

        if getgenv().Aim and cTarget then Cam.CFrame = Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position, cTarget), getgenv().Smooth) end
    end)
end)

print(">>> ROCKET | IMGUI STYLE LOADED <<<")
