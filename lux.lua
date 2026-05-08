repeat task.wait() until game:IsLoaded()

-- // SERVICES \\ --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- // CONFIGURATION \\ --
local Config = {
    HubName = "UtopiaHub",
    ScriptURL = "https://raw.githubusercontent.com/Luixs1123/Luix/main/lux.lua", -- ✅ SEU LINK
    DiscordInvite = "GMeJJAYqKQ",
    AccentColor = Color3.fromRGB(114, 137, 218),
    BackgroundColor = Color3.fromRGB(20, 20, 20)
}

-- // UI HELPERS \\ --
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function Create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

-- // UI \\ --
local ScreenGui = Create("ScreenGui", {
    Name = "UtopiaLoader",
    Parent = CoreGui,
    ResetOnSpawn = false
})

local Blur = Create("BlurEffect", {
    Parent = game:GetService("Lighting"),
    Size = 0
})

local MainFrame = Create("Frame", {
    Parent = ScreenGui,
    BackgroundColor3 = Config.BackgroundColor,
    Position = UDim2.new(0.5, -200, 0.5, -125),
    Size = UDim2.new(0, 400, 0, 250)
})

Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = MainFrame})

local Title = Create("TextLabel", {
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 20, 0, 20),
    Size = UDim2.new(1, -40, 0, 30),
    Font = Enum.Font.GothamBold,
    Text = Config.HubName,
    TextColor3 = Color3.fromRGB(255,255,255),
    TextSize = 22,
    TextXAlignment = Enum.TextXAlignment.Left
})

local StatusLabel = Create("TextLabel", {
    Parent = MainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 20, 0, 120),
    Size = UDim2.new(1, -40, 0, 20),
    Font = Enum.Font.Gotham,
    Text = "Ready to load script",
    TextColor3 = Color3.fromRGB(150,150,150),
    TextSize = 14
})

-- BOTÃO LOAD
local LoadBtn = Create("TextButton", {
    Parent = MainFrame,
    BackgroundColor3 = Config.AccentColor,
    Position = UDim2.new(0.5, -150, 1, -60),
    Size = UDim2.new(0, 300, 0, 40),
    Font = Enum.Font.GothamBold,
    Text = "LOAD SCRIPT",
    TextColor3 = Color3.fromRGB(20,20,20),
    TextSize = 14
})

Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = LoadBtn})

LoadBtn.MouseButton1Click:Connect(function()
    StatusLabel.Text = "Loading..."
    StatusLabel.TextColor3 = Color3.fromRGB(200,200,200)

    local success, err = pcall(function()
        loadstring(game:HttpGet(Config.ScriptURL, true))()
    end)

    if success then
        StatusLabel.Text = "Loaded!"
        StatusLabel.TextColor3 = Color3.fromRGB(100,255,100)
    else
        StatusLabel.Text = "Erro ao carregar"
        warn(err)
    end
end)

-- BOTÃO DISCORD
local DiscordBtn = Create("TextButton", {
    Parent = MainFrame,
    BackgroundColor3 = Color3.fromRGB(88,101,242),
    Position = UDim2.new(1, -110, 0, 10),
    Size = UDim2.new(0, 80, 0, 25),
    Font = Enum.Font.GothamBold,
    Text = "Discord",
    TextColor3 = Color3.fromRGB(255,255,255),
    TextSize = 12
})

Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DiscordBtn})

DiscordBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/" .. Config.DiscordInvite)
end)

MakeDraggable(MainFrame)

-- ANIMAÇÃO
TweenService:Create(Blur, TweenInfo.new(0.8), {Size = 20}):Play()
