-- MACCO Hub v2 - Interface Melhorada (Versão Corrigida)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Configurações
local COLORS = {
    BG_MAIN = Color3.fromRGB(8, 8, 8),
    BG_SIDEBAR = Color3.fromRGB(15, 15, 15),
    BG_CARD = Color3.fromRGB(20, 20, 20),
    ACCENT = Color3.fromRGB(255, 0, 0),
    TEXT_MAIN = Color3.fromRGB(255, 255, 255),
    TEXT_DIM = Color3.fromRGB(176, 176, 176),
    DIVIDER = Color3.fromRGB(40, 0, 0)
}

-- Estados
local headSize = 7
local espEnabled = false
local espMaxDist = 500
local espBoxes = false
local espTracers = false
local espHealthBar = true
local espSkeletons = false
local flyEnabled = false
local flySpeed = 50
local aimbotEnabled = false
local aimbotSmooth = 0
local fovSize = 200
local showFOV = false
local wallCheck = false
local aimbotTeamCheck = false
local aimPart = "Head"
local silentAimEnabled = false
local silentAimHitChance = 100
local silentAimPrediction = false
local silentAimPredictionAmount = 0.165
local espObjects = {}
local showGlow = true
local showDist = true
local showWeapon = true
local applyHead = true
local teamCheck = true
local isOpen = false
local currentTab = "Combat"
local isAimbotActive = false
local originalHeadSizes = {}
local flyConnections = {}

-- Verificar suporte a Drawing API
local DRAWING_SUPPORTED = pcall(function() return Drawing.new("Circle") end)

-- Limpar GUI antiga
if PlayerGui:FindFirstChild("MACCOHub") then
    PlayerGui.MACCOHub:Destroy()
end

-- Criar ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MACCOHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 750, 0, 450)
MainFrame.Position = UDim2.new(0.5, -375, 0.5, -225)
MainFrame.BackgroundColor3 = COLORS.BG_MAIN
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = COLORS.ACCENT
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 6)
MainCorner.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = COLORS.BG_SIDEBAR
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarTitle = Instance.new("TextLabel")
TopBarTitle.Size = UDim2.new(0, 200, 1, 0)
TopBarTitle.Position = UDim2.new(0, 15, 0, 0)
TopBarTitle.BackgroundTransparency = 1
TopBarTitle.Text = "MACCO HUB AR2"
TopBarTitle.TextColor3 = COLORS.TEXT_MAIN
TopBarTitle.TextSize = 16
TopBarTitle.Font = Enum.Font.GothamBold
TopBarTitle.TextXAlignment = Enum.TextXAlignment.Left
TopBarTitle.Parent = TopBar

-- Search Box (decorativo)
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0, 200, 0, 25)
SearchBox.Position = UDim2.new(0.5, -100, 0.5, -12.5)
SearchBox.BackgroundColor3 = COLORS.BG_MAIN
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "Search"
SearchBox.PlaceholderColor3 = COLORS.TEXT_DIM
SearchBox.Text = ""
SearchBox.TextColor3 = COLORS.TEXT_MAIN
SearchBox.TextSize = 12
SearchBox.Font = Enum.Font.Gotham
SearchBox.Parent = TopBar

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 4)
SearchCorner.Parent = SearchBox

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2.5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = COLORS.TEXT_MAIN
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 180, 1, -35)
Sidebar.Position = UDim2.new(0, 0, 0, 35)
Sidebar.BackgroundColor3 = COLORS.BG_SIDEBAR
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(1, 0, 0, 0)
SidebarLine.BackgroundColor3 = COLORS.DIVIDER
SidebarLine.BorderSizePixel = 0
SidebarLine.Parent = Sidebar

-- Content Area
local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -190, 1, -45)
Content.Position = UDim2.new(0, 185, 0, 40)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = COLORS.ACCENT
Content.BorderSizePixel = 0
Content.CanvasSize = UDim2.new(0, 0, 0, 1200)
Content.Parent = MainFrame

-- Tabs Storage
local tabs = {}
local tabButtons = {}

-- Helper: Create Tab Button
local function createTabButton(name, icon, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, 10 + (order * 45))
    btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextColor3 = COLORS.TEXT_DIM
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = Sidebar

    local activeLine = Instance.new("Frame")
    activeLine.Size = UDim2.new(0, 3, 1, 0)
    activeLine.BackgroundColor3 = COLORS.ACCENT
    activeLine.BorderSizePixel = 0
    activeLine.Visible = false
    activeLine.Parent = btn

    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.Parent = Content

    tabs[name] = tabContent
    tabButtons[name] = {btn = btn, line = activeLine}

    btn.MouseButton1Click:Connect(function()
        for n, t in pairs(tabs) do
            t.Visible = false
            if tabButtons[n] then
                tabButtons[n].btn.TextColor3 = COLORS.TEXT_DIM
                tabButtons[n].btn.BackgroundTransparency = 1
                tabButtons[n].line.Visible = false
            end
        end
        tabContent.Visible = true
        btn.TextColor3 = COLORS.TEXT_MAIN
        btn.BackgroundTransparency = 0.95
        activeLine.Visible = true
        currentTab = name
    end)

    return tabContent
end

-- Create Tabs
local combatTab = createTabButton("Combat", "[C]", 0)
local visualsTab = createTabButton("Visuals", "[V]", 1)
local vehicleTab = createTabButton("Vehicle", "[H]", 2)
local miscTab = createTabButton("Misc", "[M]", 3)

-- Activate first tab
tabs["Combat"].Visible = true
tabButtons["Combat"].btn.TextColor3 = COLORS.TEXT_MAIN
tabButtons["Combat"].btn.BackgroundTransparency = 0.95
tabButtons["Combat"].line.Visible = true

-- Helper: Create Card
local function createCard(parent, title, yPos)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0.95, 0, 0, 150)
    card.Position = UDim2.new(0.025, 0, 0, yPos)
    card.BackgroundColor3 = COLORS.BG_CARD
    card.BorderSizePixel = 0
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local cardTitle = Instance.new("TextLabel")
    cardTitle.Size = UDim2.new(1, -20, 0, 30)
    cardTitle.Position = UDim2.new(0, 10, 0, 5)
    cardTitle.BackgroundTransparency = 1
    cardTitle.Text = title
    cardTitle.TextColor3 = COLORS.TEXT_MAIN
    cardTitle.TextSize = 14
    cardTitle.Font = Enum.Font.GothamBold
    cardTitle.TextXAlignment = Enum.TextXAlignment.Left
    cardTitle.Parent = card

    return card
end

-- Helper: Create Toggle
local function createToggle(parent, labelText, yPos, defaultState, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 25)
    row.Position = UDim2.new(0, 10, 0, yPos)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = COLORS.TEXT_DIM
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -45, 0.5, -10)
    toggle.BackgroundColor3 = defaultState and COLORS.ACCENT or Color3.fromRGB(60, 60, 60)
    toggle.BorderSizePixel = 0
    toggle.Parent = row

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.Parent = toggle

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local state = defaultState
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Parent = toggle

    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = state and COLORS.ACCENT or Color3.fromRGB(60, 60, 60)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(state)
    end)
end

-- Helper: Create Slider
local function createSlider(parent, labelText, min, max, default, yPos, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, yPos)
    label.BackgroundTransparency = 1
    label.Text = labelText .. ": " .. default
    label.TextColor3 = COLORS.TEXT_DIM
    label.TextSize = 12
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -20, 0, 4)
    sliderBg.Position = UDim2.new(0, 10, 0, yPos + 22)
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = parent

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = COLORS.ACCENT
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg

    local sliding = false
    local currentValue = default
    
    local function update(input)
        local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        currentValue = val
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        label.Text = labelText .. ": " .. val
        callback(val)
    end

    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
end

-- ==================== COMBAT TAB ====================
local combatCard1 = createCard(combatTab, "Aimbot", 10)
createToggle(combatCard1, "Aimbot Enabled", 40, false, function(v) aimbotEnabled = v end)
createToggle(combatCard1, "Show FOV Circle", 70, false, function(v) 
    showFOV = v 
    if not v and fovCircle then fovCircle.Visible = false end
end)
createToggle(combatCard1, "Wall Check", 100, false, function(v) wallCheck = v end)

local combatCard2 = createCard(combatTab, "Aimbot Settings", 170)
createSlider(combatCard2, "FOV Size", 50, 500, 200, 40, function(v) 
    fovSize = v
    if fovCircle then fovCircle.Radius = v end
end)
createSlider(combatCard2, "Smoothness", 0, 3, 0, 75, function(v) 
    aimbotSmooth = v
end)
createToggle(combatCard2, "Team Check", 110, false, function(v) aimbotTeamCheck = v end)

local combatCard3 = createCard(combatTab, "Head Expanded", 330)
createSlider(combatCard3, "Expansion Size", 1, 30, 7, 40, function(v) headSize = v end)
createToggle(combatCard3, "Enable Head Expansion", 75, true, function(v) applyHead = v end)
createToggle(combatCard3, "Teamcheck", 105, true, function(v) teamCheck = v end)

local combatCard4 = createCard(combatTab, "Silent Aim", 490)
createToggle(combatCard4, "Silent Aim Enabled", 40, false, function(v) silentAimEnabled = v end)
createSlider(combatCard4, "Hit Chance %", 0, 100, 100, 70, function(v) silentAimHitChance = v end)
createToggle(combatCard4, "Prediction", 105, false, function(v) silentAimPrediction = v end)

-- ==================== VISUALS TAB ====================
local visualCard1 = createCard(visualsTab, "ESP", 10)
createToggle(visualCard1, "ESP Enabled", 40, false, function(v) espEnabled = v end)
createToggle(visualCard1, "Glow Effect", 70, true, function(v) showGlow = v end)
createToggle(visualCard1, "Show Distance", 100, true, function(v) showDist = v end)

local visualCard2 = createCard(visualsTab, "ESP Settings", 170)
createSlider(visualCard2, "Max Distance", 50, 5000, 500, 40, function(v) espMaxDist = v end)
createToggle(visualCard2, "Show Weapon", 75, true, function(v) showWeapon = v end)
createToggle(visualCard2, "Health Bar", 105, true, function(v) espHealthBar = v end)

local visualCard3 = createCard(visualsTab, "ESP Advanced", 330)
createToggle(visualCard3, "Boxes", 40, false, function(v) espBoxes = v end)
createToggle(visualCard3, "Tracers", 70, false, function(v) espTracers = v end)
createToggle(visualCard3, "Skeletons", 100, false, function(v) espSkeletons = v end)

-- ==================== VEHICLE TAB ====================
local vehicleCard1 = createCard(vehicleTab, "Vehicle Speed", 10)
createSlider(vehicleCard1, "Speed Boost", 1, 5, 1, 40, function(v) end)

-- ==================== MISC TAB ====================
local miscCard1 = createCard(miscTab, "Movement", 10)
createToggle(miscCard1, "Fly", 40, false, function(v)
    flyEnabled = v
    if not v then
        -- Limpar fly connections
        for _, conn in pairs(flyConnections) do
            if conn then conn:Disconnect() end
        end
        flyConnections = {}
        
        -- Restaurar movimento normal
        local char = Player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bg = hrp:FindFirstChild("FlyBodyGyro")
                local bv = hrp:FindFirstChild("FlyBodyVelocity")
                if bg then bg:Destroy() end
                if bv then bv:Destroy() end
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end)
createSlider(miscCard1, "Fly Speed", 10, 200, 50, 70, function(v) flySpeed = v end)

local miscCard2 = createCard(miscTab, "Script Control", 170)

-- Botão Desinjetar dentro do card
local uninjectBtn = Instance.new("TextButton")
uninjectBtn.Size = UDim2.new(1, -20, 0, 40)
uninjectBtn.Position = UDim2.new(0, 10, 0, 40)
uninjectBtn.BackgroundColor3 = COLORS.ACCENT
uninjectBtn.Text = "Desinjetar Script Completo"
uninjectBtn.TextColor3 = COLORS.TEXT_MAIN
uninjectBtn.Font = Enum.Font.GothamBold
uninjectBtn.TextSize = 13
uninjectBtn.BorderSizePixel = 0
uninjectBtn.Parent = miscCard2

local uninjectCorner = Instance.new("UICorner")
uninjectCorner.CornerRadius = UDim.new(0, 6)
uninjectCorner.Parent = uninjectBtn

local uninjectDesc = Instance.new("TextLabel")
uninjectDesc.Size = UDim2.new(1, -20, 0, 40)
uninjectDesc.Position = UDim2.new(0, 10, 0, 90)
uninjectDesc.BackgroundTransparency = 1
uninjectDesc.Text = "Remove completamente o script\ne restaura tudo ao normal"
uninjectDesc.TextColor3 = COLORS.TEXT_DIM
uninjectDesc.Font = Enum.Font.Gotham
uninjectDesc.TextSize = 11
uninjectDesc.TextWrapped = true
uninjectDesc.TextYAlignment = Enum.TextYAlignment.Top
uninjectDesc.Parent = miscCard2

local function cleanupScript()
    -- Limpar FOV Circle
    if fovCircle then fovCircle:Remove() end
    
    -- Restaurar cabeças
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player then
            local char = p.Character
            if char then
                local head = char:FindFirstChild("Head")
                if head and originalHeadSizes[p] then
                    pcall(function()
                        head.Size = originalHeadSizes[p].size or Vector3.new(2, 2, 1)
                        head.Transparency = originalHeadSizes[p].trans or 0
                        head.Color = originalHeadSizes[p].color or Color3.new(1, 1, 1)
                        head.Material = originalHeadSizes[p].material or Enum.Material.Plastic
                        head.CanCollide = true
                    end)
                end
            end
        end
    end
    
    -- Limpar ESP
    for _, obj in pairs(espObjects) do
        if obj then
            if obj.bb then pcall(function() obj.bb:Destroy() end) end
            if obj.highlight then pcall(function() obj.highlight:Destroy() end) end
            if obj.boxFrame then pcall(function() obj.boxFrame:Destroy() end) end
            if obj.tracerLine then pcall(function() obj.tracerLine:Remove() end) end
        end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        if char then
            local hl = char:FindFirstChild("ESPHighlight")
            if hl then hl:Destroy() end
        end
    end
    
    -- Desativar fly
    if flyEnabled then
        local char = Player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bg = hrp:FindFirstChild("FlyBodyGyro")
                local bv = hrp:FindFirstChild("FlyBodyVelocity")
                if bg then bg:Destroy() end
                if bv then bv:Destroy() end
            end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
    
    -- Limpar connections
    for _, conn in pairs(flyConnections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    
    ScreenGui:Destroy()
end

uninjectBtn.MouseButton1Click:Connect(cleanupScript)

-- Hint (apenas DEL para abrir/fechar)
local Hint = Instance.new("TextLabel")
Hint.Size = UDim2.new(0, 180, 0, 30)
Hint.Position = UDim2.new(0.5, -90, 0.95, 0)
Hint.BackgroundColor3 = COLORS.BG_CARD
Hint.BorderColor3 = COLORS.ACCENT
Hint.BorderSizePixel = 1
Hint.TextColor3 = COLORS.TEXT_MAIN
Hint.Text = "DEL - Abrir/Fechar"
Hint.Font = Enum.Font.GothamBold
Hint.TextSize = 12
Hint.Parent = ScreenGui

local hintCorner = Instance.new("UICorner")
hintCorner.CornerRadius = UDim.new(0, 6)
hintCorner.Parent = Hint

-- Toggle Menu
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local function toggleMenu()
    isOpen = not isOpen
    if isOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, tweenInfo, {Size = UDim2.new(0, 750, 0, 450)}):Play()
    else
        local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
        closeTween:Play()
        closeTween.Completed:Connect(function()
            if not isOpen then MainFrame.Visible = false end
        end)
    end
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        toggleMenu()
    end
end)

CloseBtn.MouseButton1Click:Connect(toggleMenu)

-- ==================== SISTEMA DE SEGURANÇA PARA METAMETHODS ====================
-- Verificar se está em ambiente compatível antes de usar hookmetamethod
local hookAvailable, hookFunction = pcall(function() return hookmetamethod end)
local isSecure = hookAvailable and hookFunction

-- Silent Aim Functions (apenas se hook disponível)
local silentAimHooksActive = false

local function getDirection(origin, position)
    if not origin or not position then return Vector3.new(0, 0, 0) end
    return (position - origin).Unit * 1000
end

local function isVisible(targetPos, targetChar)
    if not wallCheck then return true end
    local camera = workspace.CurrentCamera
    if not camera then return true end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {camera, Player.Character, targetChar}
    
    local rayResult = workspace:Raycast(camera.CFrame.Position, (targetPos - camera.CFrame.Position).Unit * 1000, raycastParams)
    return rayResult == nil
end

local function getSilentAimTarget()
    if not silentAimEnabled then return nil end
    
    local closestPlayer = nil
    local shortestDistance = fovSize
    local mousePos = UserInputService:GetMouseLocation()
    local camera = workspace.CurrentCamera
    if not camera then return nil end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local targetPart = player.Character:FindFirstChild(aimPart)
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            
            if targetPart and humanoid and humanoid.Health > 0 then
                if aimbotTeamCheck and player.Team == Player.Team then
                    goto continue
                end
                
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local screenPos2D = Vector2.new(screenPos.X, screenPos.Y)
                    local distFromMouse = (screenPos2D - mousePos).Magnitude
                    
                    if distFromMouse < shortestDistance then
                        if isVisible(targetPart.Position, player.Character) then
                            shortestDistance = distFromMouse
                            closestPlayer = targetPart
                        end
                    end
                end
            end
        end
        ::continue::
    end
    return closestPlayer
end

-- Silent Aim Hooks (com proteção)
if isSecure then
    local oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        if silentAimEnabled and self == workspace and not checkcaller() then
            local chance = math.random(1, 100) <= silentAimHitChance
            if not chance then return oldNamecall(self, ...) end
            
            local target = getSilentAimTarget()
            if not target then return oldNamecall(self, ...) end
            
            if method == "Raycast" then
                if #args >= 2 then
                    local origin = args[2]
                    local newArgs = {...}
                    newArgs[3] = getDirection(origin, target.Position)
                    return oldNamecall(unpack(newArgs))
                end
            elseif method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRayWithWhitelist" or method == "FindPartOnRay" then
                if #args >= 2 and typeof(args[2]) == "Ray" then
                    local ray = args[2]
                    local origin = ray.Origin
                    local newArgs = {...}
                    newArgs[2] = Ray.new(origin, getDirection(origin, target.Position))
                    return oldNamecall(unpack(newArgs))
                end
            end
        end
        
        return oldNamecall(self, ...)
    end))
    
    local oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, index)
        if self == Player:GetMouse() and not checkcaller() and silentAimEnabled then
            local target = getSilentAimTarget()
            if target then
                if index == "Hit" or index == "hit" then
                    if silentAimPrediction and target.Parent and target.Parent:FindFirstChild("HumanoidRootPart") then
                        local root = target.Parent:FindFirstChild("HumanoidRootPart")
                        local velocity = root and root.AssemblyLinearVelocity or Vector3.zero
                        return target.CFrame + (velocity * silentAimPredictionAmount)
                    else
                        return target.CFrame
                    end
                elseif index == "Target" or index == "target" then
                    return target
                end
            end
        end
        return oldIndex(self, index)
    end))
end

-- FOV Circle (apenas se suportado)
local fovCircle = nil
if DRAWING_SUPPORTED then
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 2
    fovCircle.NumSides = 50
    fovCircle.Radius = fovSize
    fovCircle.Filled = false
    fovCircle.Visible = false
    fovCircle.Color = Color3.fromRGB(255, 0, 0)
    fovCircle.Transparency = 1
end

-- ESP Logic melhorado
local function getToolName(player)
    local char = player.Character
    if not char then return nil end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name or nil
end

local function removeESP(player)
    if espObjects[player] then
        if espObjects[player].bb then pcall(function() espObjects[player].bb:Destroy() end) end
        if espObjects[player].highlight then pcall(function() espObjects[player].highlight:Destroy() end) end
        if espObjects[player].boxFrame then pcall(function() espObjects[player].boxFrame:Destroy() end) end
        if espObjects[player].tracerLine then pcall(function() espObjects[player].tracerLine:Remove() end) end
        espObjects[player] = nil
    end
end

local function updateESP(player, bb, highlight, hpLbl, distLbl, weaponLbl, healthBar, boxFrame, tracerLine)
    if not espEnabled or not bb or not bb.Parent then
        if bb then bb.Enabled = false end
        if highlight then highlight.Enabled = false end
        if healthBar then healthBar.Visible = false end
        if boxFrame then boxFrame.Visible = false end
        if tracerLine then tracerLine.Visible = false end
        return
    end
    
    local myChar = Player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not myRoot or not root then
        bb.Enabled = false
        if highlight then highlight.Enabled = false end
        if healthBar then healthBar.Visible = false end
        if boxFrame then boxFrame.Visible = false end
        if tracerLine then tracerLine.Visible = false end
        return
    end
    
    local dist = (root.Position - myRoot.Position).Magnitude
    if dist > espMaxDist then
        bb.Enabled = false
        if highlight then highlight.Enabled = false end
        if healthBar then healthBar.Visible = false end
        if boxFrame then boxFrame.Visible = false end
        if tracerLine then tracerLine.Visible = false end
        return
    end
    
    bb.Enabled = true
    if highlight then highlight.Enabled = showGlow end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        if hpLbl then
            hpLbl.Text = "HP: " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
        end
        
        -- Health Bar
        if healthBar and espHealthBar then
            healthBar.Visible = true
            local healthPercent = hum.Health / hum.MaxHealth
            healthBar.Size = UDim2.new(healthPercent,
