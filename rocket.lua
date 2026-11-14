local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

local GuiParent = LP:WaitForChild("PlayerGui")

getgenv().Aim = true
getgenv().Smooth = 0.25
getgenv().FOV = 200
getgenv().Silent = false
getgenv().SilentFOV = 300
getgenv().Wall = true
getgenv().Team = true

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
                            local tPart = char:FindFirstChild("Head") or char.HumanoidRootPart
                            local sp, on = Cam:WorldToViewportPoint(tPart.Position)
                            if on then
                                local d = (Vector2.new(sp.X, sp.Y) - c).Magnitude
                                if d <= getgenv().SilentFOV and d < bestVal then
                                    bestVal = d; best = tPart
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

local sGui = Instance.new("ScreenGui")
sGui.Name = "RocketUI"
sGui.Parent = GuiParent

local btn = Instance.new("TextButton")
btn.Size = UDim2.fromOffset(50, 50)
btn.Position = UDim2.new(0, 15, 0.12, 0)
btn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
btn.Text = "MENU"
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.Font = Enum.Font.GothamBold
btn.Parent = sGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(200, 150)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Position = UDim2.new(0, 70, 0.12, 0)
frame.Visible = false
frame.Parent = sGui

local function addBtn(txt, y, func)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -20, 0, 30)
    b.Position = UDim2.new(0, 10, 0, y)
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Parent = frame
    b.MouseButton1Click:Connect(func)
end

addBtn("Aimbot: ON", 10, function() getgenv().Aim = not getgenv().Aim end)
addBtn("Silent Aim: OFF", 50, function() getgenv().Silent = not getgenv().Silent end)
addBtn("WallCheck: ON", 90, function() getgenv().Wall = not getgenv().Wall end)

btn.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

RunService.RenderStepped:Connect(function()
    pcall(function()
        local closest, dist = nil, getgenv().FOV
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local head = p.Character:FindFirstChild("Head") or p.Character.HumanoidRootPart
                local pos, on = Cam:WorldToViewportPoint(head.Position)
                if on then
                    local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)).Magnitude
                    if d < dist then
                        dist = d
                        closest = head.Position
                    end
                end
            end
        end
        if getgenv().Aim and closest then
            Cam.CFrame = Cam.CFrame:Lerp(CFrame.new(Cam.CFrame.Position, closest), getgenv().Smooth)
        end
    end)
end)

print(">>> ROCKET LOADED <<<")
