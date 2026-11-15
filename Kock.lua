newSlider(pAim, "Hit Chance", 0, 100, getgenv().HitChance, function(v) getgenv().HitChance = v end)

newCheck(pSilent, "Silent Aim", getgenv().Silent, function() getgenv().Silent = not getgenv().Silent; return getgenv().Silent end)
newCheck(pSilent, "Silent WallCheck", getgenv().SilentWall, function() getgenv().SilentWall = not getgenv().SilentWall; return getgenv().SilentWall end)
newCheck(pSilent, "Target: Head", (getgenv().SilentTarget == "Head"), function() getgenv().SilentTarget = (getgenv().SilentTarget == "Head") and "Body" or "Head"; return getgenv().SilentTarget == "Head" end)
newCheck(pSilent, "Priority: Low HP", getgenv().SilentHP, function() getgenv().SilentHP = not getgenv().SilentHP; return getgenv().SilentHP end)
newSlider(pSilent, "Silent FOV", 50, 500, getgenv().SilentFOV, function(v) getgenv().SilentFOV = v end)

newCheck(pEsp, "ESP", getgenv().ESP, function() getgenv().ESP = not getgenv().ESP; return getgenv().ESP end)
newCheck(pEsp, "ESP WallCheck", getgenv().ESP_WallCheck, function() getgenv().ESP_WallCheck = not getgenv().ESP_WallCheck; return getgenv().ESP_WallCheck end)
newCheck(pEsp, "Chams", getgenv().Chams, function() getgenv().Chams = not getgenv().Chams; return getgenv().Chams end)
newCheck(pEsp, "Box", getgenv().Box, function() getgenv().Box = not getgenv().Box; return getgenv().Box end)
newCheck(pEsp, "HP Bar", getgenv().HP, function() getgenv().HP = not getgenv().HP; return getgenv().HP end)
newCheck(pEsp, "Name", getgenv().Name, function() getgenv().Name = not getgenv().Name; return getgenv().Name end)
newCheck(pEsp, "Tracers", getgenv().Tracer, function() getgenv().Tracer = not getgenv().Tracer; return getgenv().Tracer end)
newCheck(pEsp, "Vehicle ESP", getgenv().VehicleESP, function() getgenv().VehicleESP = not getgenv().VehicleESP; return getgenv().VehicleESP end)
newSlider(pEsp, "Max Dist", 100, 2000, getgenv().MaxD, function(v) getgenv().MaxD = v end)

newCheck(pMisc, "Hitbox Expander", getgenv().Hitbox, function() getgenv().Hitbox = not getgenv().Hitbox; return getgenv().Hitbox end)
newSlider(pMisc, "Hitbox Size", 1, 10, getgenv().HitboxSize, function(v) getgenv().HitboxSize = v end)
newCheck(pMisc, "Fullbright", getgenv().Fullbright, function()
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

local dg, ds, dp; local dpn, dsn, spp
btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = true; ds = Vector2.new(i.Position.X, i.Position.Y); dp = Vector2.new(btn.AbsolutePosition.X, btn.AbsolutePosition.Y) end end)
btn.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dg = false end end)
hdr.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dpn = true; dsn = Vector2.new(i.Position.X, i.Position.Y); spp = Vector2.new(frame.AbsolutePosition.X, frame.AbsolutePosition.Y) end end)
hdr.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dpn = false end end)
UIS.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        local pos = Vector2.new(i.Position.X, i.Position.Y)
        if dg then btn.Position = UDim2.new(0, dp.X + (pos - ds).X, 0, dp.Y + (pos - ds).Y) end
        if dpn then frame.Position = UDim2.new(0, spp.X + (pos - dsn).X, 0, spp.Y + (pos - dsn).Y) end
    end
end)
btn.MouseButton1Click:Connect(function() frame.Visible = not frame.Visible; if frame.Visible then local ga = btn.AbsolutePosition; frame.Position = UDim2.new(0, math.max(10, math.min(ga.X + btn.AbsoluteSize.X + 10, sGui.AbsoluteSize.X - 430)), 0, math.max(10, ga.Y)) end end)
cl.MouseButton1Click:Connect(function() frame.Visible = false end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        local cp = Cam.CFrame.Position
        local vp = Cam.ViewportSize
        local sc = Vector2.new(vp.X / 2, vp.Y / 2)
        local cTarget = nil
        local sDist = getgenv().FOV

        if getgenv().VehicleESP then
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("Model") and (string.find(obj.Name:lower(), "tigr") or string.find(obj.Name:lower(), "pickup") or string.find(obj.Name:lower(), "atv") or string.find(obj.Name:lower(), "quad")) then
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
                            local m = vMarks[obj]
                            m.tag.Enabled = true; m.hl.Enabled = true
                            m.n.Text = obj.Name .. " [" .. math.floor(d) .. "m]"
                        else removeVESP(obj) end
                    end
                end
            end
        else
            for obj, _ in pairs(vMarks) do removeVESP(obj) end
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                local c = p.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                local h = c and c:FindFirstChild("Humanoid")
                if c and r and h and h.Health > 0 then
                    if getgenv().Hitbox then
                        pcall(function()
                            if not c:FindFirstChild("TacticalHitbox") then
                                local hb = Instance.new("Part"); hb.Name = "TacticalHitbox"; hb.Shape = Enum.PartType.Ball; hb.Size = Vector3.new(1,1,1) * getgenv().HitboxSize; hb.Transparency = 1; hb.CanCollide = false; hb.Massless = true
                                local w = Instance.new("Weld"); w.Part0 = r; w.Part1 = hb; w.Parent = hb; hb.Parent = c
                            else c.TacticalHitbox.Size = Vector3.new(1,1,1) * getgenv().HitboxSize end
                        end)
                    end

                    local d = (cp - r.Position).Magnitude
                    local tm = isTeam(p)
                    local tPass = not (getgenv().Team and tm)
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

                        local col = tm and Color3.fromRGB(60, 160, 255) or Color3.fromRGB(255, 60, 60)
                        local show = getgenv().ESP and visEsp
                        local m = marks[p]

                        if m and m.tag then
                            m.hl.Enabled = getgenv().Chams and show; m.hl.FillColor = col; m.hl.OutlineColor = col
                            m.tag.Enabled = show
                            m.n.Visible = getgenv().Name; m.n.Text = p.Name; m.n.TextColor3 = col
                            m.hb.Visible = getgenv().HP
                            local hp = math.clamp(h.Health, 0, h.MaxHealth); local ratio = h.MaxHealth > 0 and (hp / h.MaxHealth) or 0
                            m.hf.Size = UDim2.new(ratio, 0, 1, 0)
                        end

                        if m and m.bx then
                            local showB = getgenv().Box and show
                            m.bx.Visible = showB
                            if showB then
                                local hd = c:FindFirstChild("Head"); local ll = c:FindFirstChild("Left Leg") or c:FindFirstChild("LeftLeg"); local rl = c:FindFirstChild("Right Leg") or c:FindFirstChild("RightLeg")
                                if hd and ll and rl then
                                    local tp, tos = Cam:WorldToViewportPoint(hd.Position + Vector3.new(0, 0.5, 0))
                                    local bp, bos = Cam:WorldToViewportPoint((ll.Position + rl.Position) / 2 - Vector3.new(0, 0.5, 0))
                                    if tos and bos then
                                        local hgt = math.abs(tp.Y - bp.Y); local wid = hgt * 0.6
                                        local cx = (tp.X + bp.X) / 2; local cy = (tp.Y + bp.Y) / 2
                                        m.bx.Position = UDim2.fromOffset(cx - wid / 2, cy - hgt / 2); m.bx.Size = UDim2.fromOffset(wid, hgt)
                                        local s = m.bx:FindFirstChildOfClass("UIStroke"); if s then s.Color = col end
                                    else m.bx.Visible = false end
                                else m.bx.Visible = false end
                            end
                        end

                        if m and m.tr then
                            local showT = getgenv().Tracer and visEsp and show
                            if showT then
                                local hd = c:FindFirstChild("Head"); local wt = hd and hd.Position or r.Position
                                local sp, os = Cam:WorldToViewportPoint(wt)
                                if os then
                                    local dl = Vector2.new(sp.X, sp.Y) - Vector2.new(vp.X / 2, vp.Y)
                                    m.tr.Position = UDim2.fromOffset(vp.X / 2, vp.Y); m.tr.Size = UDim2.fromOffset(dl.Magnitude, 1.5)
                                    m.tr.Rotation = math.deg(math.atan2(dl.Y, dl.X)); m.tr.BackgroundColor3 = col; m.tr.Visible = true
                                else m.tr.Visible = false end
                            else m.tr.Visible = false end
                        end

                        if getgenv().Aim and tPass and d <= getgenv().AimMaxDist and visAim then
                            local tP = c:FindFirstChild("Head") or r
                            if tP then
                                local pVis = true
                                if getgenv().Wall and tP ~= r then pVis = isVis(tP, c) end
                                if pVis then
                                    local pos, ons = Cam:WorldToViewportPoint(tP.Position)
                                    if ons then
                                        local d2c = (Vector2.new(pos.X, pos.Y) - sc).Magnitude
                                        if d2c < sDist then
                                            sDist = d2c
                                            if math.random(1, 100) <= getgenv().HitChance then
                                                local vel = r.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
                                                cTarget = tP.Position + (vel * getgenv().Prediction)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    else removeESP(p) end
                else removeESP(p) end
            end
        end

        if getgenv().Aim and cTarget then Cam.CFrame = Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position, cTarget), getgenv().Smooth) end
    end)
end)
print(">>> ROCKET | HIT CHANCE LOADED <<<
