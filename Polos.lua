-- ═══════════════════════════════════════════════════════════
--  NEXUSUI - Modern Roblox GUI Library
--  Desain: Glassmorphism + Neumorphism
--  Tidak mirip Rayfield — desain original
-- ═══════════════════════════════════════════════════════════

local NexusUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════
--  THEME CONFIGURATION
-- ═══════════════════════════════════════════════════════════

NexusUI.Theme = {
    Background = Color3.fromRGB(15, 15, 25),
    GlassBackground = Color3.fromRGB(25, 25, 40),
    GlassTransparency = 0.15,
    BlurIntensity = 20,
    
    AccentPrimary = Color3.fromRGB(138, 43, 226),    -- Purple
    AccentSecondary = Color3.fromRGB(0, 255, 255),     -- Cyan
    AccentGradient = Color3.fromRGB(180, 90, 255),
    
    TextPrimary = Color3.fromRGB(245, 245, 255),
    TextSecondary = Color3.fromRGB(160, 160, 180),
    TextMuted = Color3.fromRGB(100, 100, 120),
    
    Success = Color3.fromRGB(80, 220, 120),
    Warning = Color3.fromRGB(255, 180, 60),
    Error = Color3.fromRGB(255, 80, 80),
    Info = Color3.fromRGB(80, 160, 255),
    
    ElementBackground = Color3.fromRGB(35, 35, 55),
    ElementHover = Color3.fromRGB(45, 45, 70),
    ElementStroke = Color3.fromRGB(60, 60, 90),
    ElementGlow = Color3.fromRGB(138, 43, 226),
    
    ToggleOn = Color3.fromRGB(138, 43, 226),
    ToggleOff = Color3.fromRGB(60, 60, 80),
    SliderFill = Color3.fromRGB(138, 43, 226),
    SliderBackground = Color3.fromRGB(40, 40, 60),
    
    SidebarWidth = 200,
    WindowMinSize = Vector2.new(600, 400),
    CornerRadius = 12,
    AnimationSpeed = 0.4
}

-- ═══════════════════════════════════════════════════════════
--  UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local function Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

local function Tween(instance, properties, duration, easingStyle, easingDirection)
    local tween = TweenService:Create(
        instance,
        TweenInfo.new(
            duration or NexusUI.Theme.AnimationSpeed,
            easingStyle or Enum.EasingStyle.Quart,
            easingDirection or Enum.EasingDirection.Out
        ),
        properties
    )
    tween:Play()
    return tween
end

local function AddCorner(instance, radius)
    local corner = Create("UICorner", {
        CornerRadius = UDim.new(0, radius or NexusUI.Theme.CornerRadius),
        Parent = instance
    })
    return corner
end

local function AddStroke(instance, color, thickness, transparency)
    local stroke = Create("UIStroke", {
        Color = color or NexusUI.Theme.ElementStroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0.5,
        Parent = instance
    })
    return stroke
end

local function AddShadow(instance, offset, blur, transparency)
    local shadow = Create("ImageLabel", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, offset or 5),
        Size = UDim2.new(1, blur or 30, 1, blur or 30),
        ZIndex = instance.ZIndex - 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = transparency or 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 50, 50),
        Parent = instance
    })
    return shadow
end

local function AddGlow(instance, color)
    local glow = Create("ImageLabel", {
        Name = "Glow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 20, 1, 20),
        ZIndex = instance.ZIndex - 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = color or NexusUI.Theme.AccentPrimary,
        ImageTransparency = 0.9,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 50, 50),
        Parent = instance
    })
    return glow
end

-- ═══════════════════════════════════════════════════════════
--  DRAG FUNCTIONALITY
-- ═══════════════════════════════════════════════════════════

local function MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil
    
    local function Update(input)
        local delta = input.Position - dragStart
        local newPosition = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        Tween(frame, {Position = newPosition}, 0.1, Enum.EasingStyle.Linear)
    end
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            Update(input)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
--  BLUR EFFECT
-- ═══════════════════════════════════════════════════════════

local function AddBlur(parent, intensity)
    local blur = Create("ImageLabel", {
        Name = "Blur",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Image = "rbxassetid://6071575925",
        ImageColor3 = Color3.fromRGB(20, 20, 35),
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(256, 256, 256, 256),
        SliceScale = 1,
        Parent = parent
    })
    return blur
end

-- ═══════════════════════════════════════════════════════════
--  NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════

NexusUI.Notifications = {}
local NotificationQueue = {}
local ActiveNotifications = 0
local MaxNotifications = 5

function NexusUI:Notify(settings)
    settings = settings or {}
    local title = settings.Title or "Notification"
    local content = settings.Content or ""
    local duration = settings.Duration or 4
    local type = settings.Type or "Info" -- Info, Success, Warning, Error
    local icon = settings.Icon or "🔔"
    
    if ActiveNotifications >= MaxNotifications then
        table.insert(NotificationQueue, settings)
        return
    end
    
    ActiveNotifications = ActiveNotifications + 1
    
    local color = NexusUI.Theme.Info
    if type == "Success" then color = NexusUI.Theme.Success
    elseif type == "Warning" then color = NexusUI.Theme.Warning
    elseif type == "Error" then color = NexusUI.Theme.Error end
    
    -- Create notification container if not exists
    local notifGui = PlayerGui:FindFirstChild("NexusNotifications")
    if not notifGui then
        notifGui = Create("ScreenGui", {
            Name = "NexusNotifications",
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            Parent = PlayerGui
        })
    end
    
    local notifFrame = Create("Frame", {
        Name = "Notification",
        BackgroundColor3 = NexusUI.Theme.GlassBackground,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 20, 1, -20 - (ActiveNotifications - 1) * 90),
        Size = UDim2.new(0, 300, 0, 80),
        AnchorPoint = Vector2.new(1, 1),
        Parent = notifGui
    })
    
    AddCorner(notifFrame, 12)
    AddStroke(notifFrame, color, 2, 0.3)
    AddShadow(notifFrame, 4, 20, 0.7)
    
    -- Accent bar
    local accentBar = Create("Frame", {
        Name = "AccentBar",
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 4, 1, 0),
        Parent = notifFrame
    })
    AddCorner(accentBar, 2)
    
    -- Icon
    local iconLabel = Create("TextLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(0, 30, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = icon,
        TextColor3 = color,
        TextSize = 24,
        Parent = notifFrame
    })
    
    -- Title
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 10),
        Size = UDim2.new(1, -60, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = NexusUI.Theme.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notifFrame
    })
    
    -- Content
    local contentLabel = Create("TextLabel", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 32),
        Size = UDim2.new(1, -60, 0, 40),
        Font = Enum.Font.Gotham,
        Text = content,
        TextColor3 = NexusUI.Theme.TextSecondary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = notifFrame
    })
    
    -- Progress bar
    local progressBar = Create("Frame", {
        Name = "ProgressBar",
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -3),
        Size = UDim2.new(1, 0, 0, 3),
        Parent = notifFrame
    })
    AddCorner(progressBar, 1.5)
    
    -- Animate in
    notifFrame.Position = UDim2.new(1, 20, 1, -20 - (ActiveNotifications - 1) * 90)
    Tween(notifFrame, {Position = UDim2.new(1, -20, 1, -20 - (ActiveNotifications - 1) * 90)}, 0.5, Enum.EasingStyle.Back)
    
    -- Progress animation
    Tween(progressBar, {Size = UDim2.new(0, 0, 0, 3)}, duration, Enum.EasingStyle.Linear)
    
    -- Close button
    local closeBtn = Create("TextButton", {
        Name = "Close",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 5),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "×",
        TextColor3 = NexusUI.Theme.TextMuted,
        TextSize = 18,
        Parent = notifFrame
    })
    
    local function CloseNotification()
        Tween(notifFrame, {Position = UDim2.new(1, 350, notifFrame.Position.Y.Scale, notifFrame.Position.Y.Offset)}, 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.wait(0.4)
        notifFrame:Destroy()
        ActiveNotifications = ActiveNotifications - 1
        
        -- Process queue
        if #NotificationQueue > 0 then
            local nextNotif = table.remove(NotificationQueue, 1)
            task.wait(0.1)
            NexusUI:Notify(nextNotif)
        end
    end
    
    closeBtn.MouseButton1Click:Connect(CloseNotification)
    
    task.delay(duration, CloseNotification)
end

-- ═══════════════════════════════════════════════════════════
--  CREATE WINDOW
-- ═══════════════════════════════════════════════════════════

function NexusUI:CreateWindow(settings)
    settings = settings or {}
    local windowName = settings.Name or "NexusUI"
    local subtitle = settings.Subtitle or "by Nexus"
    local icon = settings.Icon or "⚡"
    local keySystem = settings.KeySystem or false
    local keySettings = settings.KeySettings or {}
    
    -- Main ScreenGui
    local screenGui = Create("ScreenGui", {
        Name = "NexusUI_" .. windowName,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        Parent = PlayerGui
    })
    
    -- Main Window Frame
    local mainWindow = Create("Frame", {
        Name = "MainWindow",
        BackgroundColor3 = NexusUI.Theme.Background,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -400, 0.5, -250),
        Size = UDim2.new(0, 800, 0, 500),
        ClipsDescendants = true,
        Parent = screenGui
    })
    
    AddCorner(mainWindow, 16)
    AddShadow(mainWindow, 8, 40, 0.5)
    
    -- Blur background
    AddBlur(mainWindow, 20)
    
    -- Top Bar (Draggable)
    local topBar = Create("Frame", {
        Name = "TopBar",
        BackgroundColor3 = NexusUI.Theme.GlassBackground,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = mainWindow
    })
    
    -- Gradient overlay for top bar
    local topGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, NexusUI.Theme.AccentPrimary),
            ColorSequenceKeypoint.new(1, NexusUI.Theme.Background)
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.9),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Rotation = 90,
        Parent = topBar
    })
    
    -- Window Icon
    local windowIcon = Create("TextLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(0, 30, 0, 30),
        Font = Enum.Font.GothamBold,
        Text = icon,
        TextColor3 = NexusUI.Theme.AccentSecondary,
        TextSize = 22,
        Parent = topBar
    })
    
    -- Window Title
    local titleLabel = Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 8),
        Size = UDim2.new(0, 200, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = windowName,
        TextColor3 = NexusUI.Theme.TextPrimary,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar
    })
    
    -- Subtitle
    local subtitleLabel = Create("TextLabel", {
        Name = "Subtitle",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 50, 0, 28),
        Size = UDim2.new(0, 200, 0, 15),
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = NexusUI.Theme.TextMuted,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topBar
    })
    
    -- Control Buttons
    local controlsFrame = Create("Frame", {
        Name = "Controls",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -100, 0, 10),
        Size = UDim2.new(0, 90, 0, 30),
        Parent = topBar
    })
    
    local function CreateControlButton(name, color, position, callback)
        local btn = Create("TextButton", {
            Name = name,
            BackgroundColor3 = NexusUI.Theme.ElementBackground,
            BorderSizePixel = 0,
            Position = position,
            Size = UDim2.new(0, 26, 0, 26),
            Font = Enum.Font.GothamBold,
            Text = name == "Minimize" and "−" or name == "Maximize" and "□" or "×",
            TextColor3 = color,
            TextSize = 14,
            AutoButtonColor = false,
            Parent = controlsFrame
        })
        AddCorner(btn, 6)
        
        btn.MouseEnter:Connect(function()
            Tween(btn, {BackgroundColor3 = NexusUI.Theme.ElementHover}, 0.2)
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, {BackgroundColor3 = NexusUI.Theme.ElementBackground}, 0.2)
        end)
        
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    -- Close button
    CreateControlButton("Close", NexusUI.Theme.Error, UDim2.new(1, -26, 0, 0), function()
        Tween(mainWindow, {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(mainWindow.Position.X.Scale, mainWindow.Position.X.Offset + 400, mainWindow.Position.Y.Scale, mainWindow.Position.Y.Offset + 250)}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.5)
        screenGui:Destroy()
    end)
    
    -- Minimize button
    local minimized = false
    CreateControlButton("Minimize", NexusUI.Theme.TextSecondary, UDim2.new(1, -58, 0, 0), function()
        minimized = not minimized
        if minimized then
            Tween(mainWindow, {Size = UDim2.new(0, 800, 0, 50)}, 0.4, Enum.EasingStyle.Quart)
        else
            Tween(mainWindow, {Size = UDim2.new(0, 800, 0, 500)}, 0.4, Enum.EasingStyle.Quart)
        end
    end)
    
    MakeDraggable(mainWindow, topBar)
    
    -- Sidebar
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = NexusUI.Theme.GlassBackground,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(0, 200, 1, -50),
        Parent = mainWindow
    })
    
    -- Sidebar gradient
    local sidebarGradient = Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, NexusUI.Theme.AccentPrimary),
            ColorSequenceKeypoint.new(0.5, NexusUI.Theme.GlassBackground),
            ColorSequenceKeypoint.new(1, NexusUI.Theme.GlassBackground)
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.95),
            NumberSequenceKeypoint.new(0.5, 1),
            NumberSequenceKeypoint.new(1, 1)
        }),
        Rotation = 0,
        Parent = sidebar
    })
    
    -- Sidebar layout
    local sidebarLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        Parent = sidebar
    })
    
    local sidebarPadding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = sidebar
    })
    
    -- Search Box
    local searchBox = Create("Frame", {
        Name = "SearchBox",
        BackgroundColor3 = NexusUI.Theme.ElementBackground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 35),
        Parent = sidebar
    })
    AddCorner(searchBox, 8)
    AddStroke(searchBox, NexusUI.Theme.ElementStroke, 1, 0.6)
    
    local searchIcon = Create("TextLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 25, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "🔍",
        TextColor3 = NexusUI.Theme.TextMuted,
        TextSize = 14,
        Parent = searchBox
    })
    
    local searchInput = Create("TextBox", {
        Name = "Input",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 35, 0, 0),
        Size = UDim2.new(1, -45, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "",
        PlaceholderText = "Search...",
        PlaceholderColor3 = NexusUI.Theme.TextMuted,
        TextColor3 = NexusUI.Theme.TextPrimary,
        TextSize = 13,
        ClearTextOnFocus = false,
        Parent = searchBox
    })
    
    -- Content Area
    local contentArea = Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 200, 0, 50),
        Size = UDim2.new(1, -200, 1, -50),
        Parent = mainWindow
    })
    
    local contentPadding = Create("UIPadding", {
        PaddingTop = UDim.new(0, 20),
        PaddingLeft = UDim.new(0, 20),
        PaddingRight = UDim.new(0, 20),
        PaddingBottom = UDim.new(0, 20),
        Parent = contentArea
    })
    
    -- Pages container
    local pagesFolder = Create("Folder", {
        Name = "Pages",
        Parent = contentArea
    })
    
    -- Window Object
    local Window = {}
    Window.ScreenGui = screenGui
    Window.MainWindow = mainWindow
    Window.Sidebar = sidebar
    Window.ContentArea = contentArea
    Window.Pages = pagesFolder
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    -- ═══════════════════════════════════════════════════════════
    --  CREATE TAB
    -- ═══════════════════════════════════════════════════════════
    
    function Window:CreateTab(tabSettings)
        tabSettings = tabSettings or {}
        local tabName = tabSettings.Name or "Tab"
        local tabIcon = tabSettings.Icon or "📄"
        local tabColor = tabSettings.Color or NexusUI.Theme.AccentPrimary
        
        -- Sidebar Button
        local tabButton = Create("TextButton", {
            Name = tabName .. "Button",
            BackgroundColor3 = NexusUI.Theme.ElementBackground,
            BorderSizePixel = 0,
            Size = UDim2.new(1, -20, 0, 40),
            Font = Enum.Font.GothamBold,
            Text = "",
            AutoButtonColor = false,
            Parent = sidebar
        })
        AddCorner(tabButton, 10)
        
        -- Button icon
        local btnIcon = Create("TextLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 0),
            Size = UDim2.new(0, 30, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = tabIcon,
            TextColor3 = tabColor,
            TextSize = 18,
            Parent = tabButton
        })
        
        -- Button text
        local btnText = Create("TextLabel", {
            Name = "Text",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 45, 0, 0),
            Size = UDim2.new(1, -55, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = tabName,
            TextColor3 = NexusUI.Theme.TextSecondary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = tabButton
        })
        
        -- Active indicator
        local indicator = Create("Frame", {
            Name = "Indicator",
            BackgroundColor3 = tabColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.5, -10),
            Size = UDim2.new(0, 4, 0, 20),
            Parent = tabButton
        })
        AddCorner(indicator, 2)
        
        -- Page
        local page = Create("ScrollingFrame", {
            Name = tabName .. "Page",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = NexusUI.Theme.AccentPrimary,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = pagesFolder
        })
        
        local pageLayout = Create("UIListLayout", {
            Padding = UDim.new(0, 12),
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Parent = page
        })
        
        local pagePadding = Create("UIPadding", {
            PaddingTop = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 20),
            Parent = page
        })
        
        -- Tab Object
        local Tab = {}
        Tab.Name = tabName
        Tab.Button = tabButton
        Tab.Page = page
        Tab.Elements = {}
        
        -- Tab selection logic
        local function SelectTab()
            if Window.CurrentTab == Tab then return end
            
            -- Deselect current
            if Window.CurrentTab then
                Tween(Window.CurrentTab.Button, {BackgroundColor3 = NexusUI.Theme.ElementBackground}, 0.3)
                Tween(Window.CurrentTab.Button.Indicator, {Size = UDim2.new(0, 4, 0, 0)}, 0.3)
                Tween(Window.CurrentTab.Button.Text, {TextColor3 = NexusUI.Theme.TextSecondary}, 0.3)
                Window.CurrentTab.Page.Visible = false
            end
            
            -- Select new
            Window.CurrentTab = Tab
            Tween(tabButton, {BackgroundColor3 = NexusUI.Theme.ElementHover}, 0.3)
            Tween(indicator, {Size = UDim2.new(0, 4, 0, 20)}, 0.3, Enum.EasingStyle.Back)
            Tween(btnText, {TextColor3 = NexusUI.Theme.TextPrimary}, 0.3)
            page.Visible = true
            
            -- Animate page content
            for _, child in ipairs(page:GetChildren()) do
                if child:IsA("Frame") or child:IsA("TextButton") then
                    child.Position = UDim2.new(0, 20, child.Position.Y.Scale, child.Position.Y.Offset)
                    Tween(child, {Position = UDim2.new(0, 0, child.Position.Y.Scale, child.Position.Y.Offset)}, 0.4, Enum.EasingStyle.Quart)
                end
            end
        end
        
        tabButton.MouseButton1Click:Connect(SelectTab)
        
        tabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(tabButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 75)}, 0.2)
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(tabButton, {BackgroundColor3 = NexusUI.Theme.ElementBackground}, 0.2)
            end
        end)
        
        -- Auto-select first tab
        if #Window.Tabs == 0 then
            task.delay(0.1, SelectTab)
        end
        
        table.insert(Window.Tabs, Tab)
        
-- ═══════════════════════════════════════════════════════════
        --  ELEMENT CREATION FUNCTIONS
        -- ═══════════════════════════════════════════════════════════
        
        function Tab:CreateSection(sectionName)
            local section = Create("Frame", {
                Name = sectionName or "Section",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                Parent = page
            })
            
            local sectionLabel = Create("TextLabel", {
                Name = "Label",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = sectionName or "Section",
                TextColor3 = NexusUI.Theme.TextMuted,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = section
            })
            
            -- Divider line
            local divider = Create("Frame", {
                Name = "Divider",
                BackgroundColor3 = NexusUI.Theme.ElementStroke,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -1),
                Size = UDim2.new(1, 0, 0, 1),
                Parent = section
            })
            
            return section
        end
        
        function Tab:CreateButton(buttonSettings)
            buttonSettings = buttonSettings or {}
            local btnName = buttonSettings.Name or "Button"
            local btnDescription = buttonSettings.Description or ""
            local btnCallback = buttonSettings.Callback or function() end
            
            local buttonFrame = Create("TextButton", {
                Name = btnName,
                BackgroundColor3 = NexusUI.Theme.ElementBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 50),
                Font = Enum.Font.GothamBold,
                Text = "",
                AutoButtonColor = false,
                Parent = page
            })
            AddCorner(buttonFrame, 10)
            AddStroke(buttonFrame, NexusUI.Theme.ElementStroke, 1, 0.5)
            
            local titleLabel = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 8),
                Size = UDim2.new(1, -30, 0, 18),
                Font = Enum.Font.GothamBold,
                Text = btnName,
                TextColor3 = NexusUI.Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = buttonFrame
            })
            
            if btnDescription ~= "" then
                local descLabel = Create("TextLabel", {
                    Name = "Description",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 26),
                    Size = UDim2.new(1, -30, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = btnDescription,
                    TextColor3 = NexusUI.Theme.TextMuted,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = buttonFrame
                })
            end
            
            -- Arrow indicator
            local arrow = Create("TextLabel", {
                Name = "Arrow",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -30, 0, 0),
                Size = UDim2.new(0, 30, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "→",
                TextColor3 = NexusUI.Theme.AccentSecondary,
                TextSize = 16,
                Parent = buttonFrame
            })
            
            buttonFrame.MouseEnter:Connect(function()
                Tween(buttonFrame, {BackgroundColor3 = NexusUI.Theme.ElementHover}, 0.2)
                Tween(arrow, {Position = UDim2.new(1, -25, 0, 0)}, 0.2, Enum.EasingStyle.Back)
            end)
            
            buttonFrame.MouseLeave:Connect(function()
                Tween(buttonFrame, {BackgroundColor3 = NexusUI.Theme.ElementBackground}, 0.2)
                Tween(arrow, {Position = UDim2.new(1, -30, 0, 0)}, 0.2)
            end)
            
            buttonFrame.MouseButton1Click:Connect(function()
                -- Click ripple effect
                local ripple = Create("Frame", {
                    BackgroundColor3 = NexusUI.Theme.AccentPrimary,
                    BackgroundTransparency = 0.5,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Parent = buttonFrame
                })
                AddCorner(ripple, 50)
                
                Tween(ripple, {Size = UDim2.new(1, 40, 1, 40), BackgroundTransparency = 1}, 0.5)
                task.delay(0.5, function() ripple:Destroy() end)
                
                btnCallback()
            end)
            
            return buttonFrame
        end
        
        function Tab:CreateToggle(toggleSettings)
            toggleSettings = toggleSettings or {}
            local toggleName = toggleSettings.Name or "Toggle"
            local toggleDescription = toggleSettings.Description or ""
            local currentValue = toggleSettings.CurrentValue or false
            local toggleCallback = toggleSettings.Callback or function() end
            
            local toggleFrame = Create("Frame", {
                Name = toggleName,
                BackgroundColor3 = NexusUI.Theme.ElementBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 50),
                Parent = page
            })
            AddCorner(toggleFrame, 10)
            AddStroke(toggleFrame, NexusUI.Theme.ElementStroke, 1, 0.5)
            
            local titleLabel = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 8),
                Size = UDim2.new(1, -80, 0, 18),
                Font = Enum.Font.GothamBold,
                Text = toggleName,
                TextColor3 = NexusUI.Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toggleFrame
            })
            
            if toggleDescription ~= "" then
                local descLabel = Create("TextLabel", {
                    Name = "Description",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 15, 0, 26),
                    Size = UDim2.new(1, -80, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = toggleDescription,
                    TextColor3 = NexusUI.Theme.TextMuted,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = toggleFrame
                })
            end
            
            -- Toggle Switch
            local switchBg = Create("Frame", {
                Name = "SwitchBg",
                BackgroundColor3 = currentValue and NexusUI.Theme.ToggleOn or NexusUI.Theme.ToggleOff,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -55, 0.5, -12),
                Size = UDim2.new(0, 44, 0, 24),
                Parent = toggleFrame
            })
            AddCorner(switchBg, 12)
            
            local switchKnob = Create("Frame", {
                Name = "Knob",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = currentValue and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                Size = UDim2.new(0, 18, 0, 18),
                Parent = switchBg
            })
            AddCorner(switchKnob, 9)
            
            -- Glow effect when on
            local switchGlow = Create("ImageLabel", {
                Name = "Glow",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                Size = UDim2.new(1, 20, 1, 20),
                AnchorPoint = Vector2.new(0.5, 0.5),
                ZIndex = 0,
                Image = "rbxassetid://6014261993",
                ImageColor3 = NexusUI.Theme.AccentPrimary,
                ImageTransparency = currentValue and 0.8 or 1,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(49, 49, 50, 50),
                Parent = switchBg
            })
            
            local toggleButton = Create("TextButton", {
                Name = "ClickArea",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                Parent = toggleFrame
            })
            
            local function UpdateToggle()
                currentValue = not currentValue
                if currentValue then
                    Tween(switchBg, {BackgroundColor3 = NexusUI.Theme.ToggleOn}, 0.3)
                    Tween(switchKnob, {Position = UDim2.new(1, -22, 0.5, -9)}, 0.3, Enum.EasingStyle.Back)
                    Tween(switchGlow, {ImageTransparency = 0.8}, 0.3)
                else
                    Tween(switchBg, {BackgroundColor3 = NexusUI.Theme.ToggleOff}, 0.3)
                    Tween(switchKnob, {Position = UDim2.new(0, 2, 0.5, -9)}, 0.3, Enum.EasingStyle.Back)
                    Tween(switchGlow, {ImageTransparency = 1}, 0.3)
                end
                toggleCallback(currentValue)
            end
            
            toggleButton.MouseButton1Click:Connect(UpdateToggle)
            
            -- Return object with Set method
            local ToggleObj = {}
            function ToggleObj:Set(value)
                if value ~= currentValue then
                    UpdateToggle()
                end
            end
            function ToggleObj:Get() return currentValue end
            
            return ToggleObj
        end
        
        function Tab:CreateSlider(sliderSettings)
            sliderSettings = sliderSettings or {}
            local sliderName = sliderSettings.Name or "Slider"
            local range = sliderSettings.Range or {0, 100}
            local increment = sliderSettings.Increment or 1
            local suffix = sliderSettings.Suffix or ""
            local currentValue = sliderSettings.CurrentValue or range[1]
            local sliderCallback = sliderSettings.Callback or function() end
            
            local sliderFrame = Create("Frame", {
                Name = sliderName,
                BackgroundColor3 = NexusUI.Theme.ElementBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 70),
                Parent = page
            })
            AddCorner(sliderFrame, 10)
            AddStroke(sliderFrame, NexusUI.Theme.ElementStroke, 1, 0.5)
            
            local titleLabel = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 8),
                Size = UDim2.new(0.5, 0, 0, 18),
                Font = Enum.Font.GothamBold,
                Text = sliderName,
                TextColor3 = NexusUI.Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sliderFrame
            })
            
            local valueLabel = Create("TextLabel", {
                Name = "Value",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -70, 0, 8),
                Size = UDim2.new(0, 60, 0, 18),
                Font = Enum.Font.GothamBold,
                Text = tostring(currentValue) .. suffix,
                TextColor3 = NexusUI.Theme.AccentSecondary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = sliderFrame
            })
            
            -- Slider track
            local track = Create("Frame", {
                Name = "Track",
                BackgroundColor3 = NexusUI.Theme.SliderBackground,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 15, 0, 40),
                Size = UDim2.new(1, -30, 0, 8),
                Parent = sliderFrame
            })
            AddCorner(track, 4)
            
            -- Slider fill
            local fillPercent = (currentValue - range[1]) / (range[2] - range[1])
            local fill = Create("Frame", {
                Name = "Fill",
                BackgroundColor3 = NexusUI.Theme.SliderFill,
                BorderSizePixel = 0,
                Size = UDim2.new(fillPercent, 0, 1, 0),
                Parent = track
            })
            AddCorner(fill, 4)
            
            -- Gradient on fill
            local fillGradient = Create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, NexusUI.Theme.AccentPrimary),
                    ColorSequenceKeypoint.new(1, NexusUI.Theme.AccentSecondary)
                }),
                Parent = fill
            })
            
            -- Slider knob
            local knob = Create("Frame", {
                Name = "Knob",
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(fillPercent, -8, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Parent = track
            })
            AddCorner(knob, 8)
            
            -- Knob glow
            local knobGlow = Create("ImageLabel", {
                Name = "Glow",
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(1, 10, 1, 10),
                ZIndex = 0,
                Image = "rbxassetid://6014261993",
                ImageColor3 = NexusUI.Theme.AccentPrimary,
                ImageTransparency = 0.7,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(49, 49, 50, 50),
                Parent = knob
            })
            
            -- Interaction
            local dragging = false
            
            local function UpdateSlider(input)
                local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local value = range[1] + (range[2] - range[1]) * pos
                value = math.floor(value / increment + 0.5) * increment
                value = math.clamp(value, range[1], range[2])
                
                currentValue = value
                valueLabel.Text = tostring(value) .. suffix
                
                local newPercent = (value - range[1]) / (range[2] - range[1])
                Tween(fill, {Size = UDim2.new(newPercent, 0, 1, 0)}, 0.1, Enum.EasingStyle.Linear)
                Tween(knob, {Position = UDim2.new(newPercent, -8, 0.5, -8)}, 0.1, Enum.EasingStyle.Linear)
                
                sliderCallback(value)
            end
            
            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                   input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                   input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            -- Hover effects
            track.MouseEnter:Connect(function()
                Tween(knob, {Size = UDim2.new(0, 20, 0, 20)}, 0.2)
                Tween(knob, {Position = UDim2.new(knob.Position.X.Scale, -10, 0.5, -10)}, 0.2)
            end)
            
            track.MouseLeave:Connect(function()
                if not dragging then
                    Tween(knob, {Size = UDim2.new(0, 16, 0, 16)}, 0.2)
                    Tween(knob, {Position = UDim2.new(knob.Position.X.Scale, -8, 0.5, -8)}, 0.2)
                end
            end)
            
            local SliderObj = {}
            function SliderObj:Set(value)
                value = math.clamp(value, range[1], range[2])
                currentValue = value
                valueLabel.Text = tostring(value) .. suffix
                local newPercent = (value - range[1]) / (range[2] - range[1])
                Tween(fill, {Size = UDim2.new(newPercent, 0, 1, 0)}, 0.3)
                Tween(knob, {Position = UDim2.new(newPercent, -8, 0.5, -8)}, 0.3)
                sliderCallback(value)
            end
            function SliderObj:Get() return currentValue end
            
            return SliderObj
        end
        
        function Tab:CreateInput(inputSettings)
            inputSettings = inputSettings or {}
            local inputName = inputSettings.Name or "Input"
            local placeholder = inputSettings.PlaceholderText or "Enter text..."
            local currentText = inputSettings.CurrentValue or ""
            local removeText = inputSettings.RemoveTextAfterFocusLost or false
            local inputCallback = inputSettings.Callback or function() end
            
            local inputFrame = Create("Frame", {
                Name = inputName,
                BackgroundColor3 = NexusUI.Theme.ElementBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 60),
                Parent = page
            })
            AddCorner(inputFrame, 10)
            AddStroke(inputFrame, NexusUI.Theme.ElementStroke, 1, 0.5)
            
            local titleLabel = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 8),
                Size = UDim2.new(1, -30, 0, 18),
                Font = Enum.Font.GothamBold,
                Text = inputName,
                TextColor3 = NexusUI.Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = inputFrame
            })
            
            local textBox = Create("TextBox", {
                Name = "Input",
                BackgroundColor3 = NexusUI.Theme.Background,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 15, 0, 32),
                Size = UDim2.new(1, -30, 0, 26),
                Font = Enum.Font.Gotham,
                Text = currentText,
                PlaceholderText = placeholder,
                PlaceholderColor3 = NexusUI.Theme.TextMuted,
                TextColor3 = NexusUI.Theme.TextPrimary,
                TextSize = 13,
                ClearTextOnFocus = false,
                Parent = inputFrame
            })
            AddCorner(textBox, 6)
            AddStroke(textBox, NexusUI.Theme.ElementStroke, 1, 0.6)
            
            textBox.Focused:Connect(function()
                Tween(textBox, {BackgroundColor3 = NexusUI.Theme.ElementHover}, 0.2)
                Tween(textBox.UIStroke, {Color = NexusUI.Theme.AccentPrimary}, 0.2)
            end)
            
            textBox.FocusLost:Connect(function(enterPressed)
                Tween(textBox, {BackgroundColor3 = NexusUI.Theme.Background}, 0.2)
                Tween(textBox.UIStroke, {Color = NexusUI.Theme.ElementStroke}, 0.2)
                inputCallback(textBox.Text)
                if removeText then
                    textBox.Text = ""
                end
            end)
            
            local InputObj = {}
            function InputObj:Set(text)
                textBox.Text = text
                inputCallback(text)
            end
            function InputObj:Get() return textBox.Text end
            
            return InputObj
        end
        
        function Tab:CreateDropdown(dropdownSettings)
            dropdownSettings = dropdownSettings or {}
            local dropdownName = dropdownSettings.Name or "Dropdown"
            local options = dropdownSettings.Options or {}
            local currentOption = dropdownSettings.CurrentOption or (options[1] or "")
            local dropdownCallback = dropdownSettings.Callback or function() end
            
            local dropdownFrame = Create("Frame", {
                Name = dropdownName,
                BackgroundColor3 = NexusUI.Theme.ElementBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 50),
                ClipsDescendants = true,
                Parent = page
            })
            AddCorner(dropdownFrame, 10)
            AddStroke(dropdownFrame, NexusUI.Theme.ElementStroke, 1, 0.5)
            
            local titleLabel = Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 8),
                Size = UDim2.new(0.6, 0, 0, 18),
                Font = Enum.Font.GothamBold,
                Text = dropdownName,
                TextColor3 = NexusUI.Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdownFrame
            })
            
            local selectedLabel = Create("TextLabel", {
                Name = "Selected",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 28),
                Size = UDim2.new(0.6, 0, 0, 16),
                Font = Enum.Font.Gotham,
                Text = currentOption,
                TextColor3 = NexusUI.Theme.AccentSecondary,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdownFrame
            })
            
            local arrow = Create("TextLabel", {
                Name = "Arrow",
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -35, 0, 0),
                Size = UDim2.new(0, 30, 0, 50),
                Font = Enum.Font.GothamBold,
                Text = "▼",
                TextColor3 = NexusUI.Theme.TextMuted,
                TextSize = 12,
                Parent = dropdownFrame
            })
            
            -- Options container
            local optionsFrame = Create("Frame", {
                Name = "Options",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 55),
                Size = UDim2.new(1, -20, 0, 0),
                Parent = dropdownFrame
            })
            
            local optionsLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 4),
                Parent = optionsFrame
            })
            
            local optionButtons = {}
            local expanded = false
            
            local function ToggleDropdown()
                expanded = not expanded
                if expanded then
                    Tween(arrow, {Rotation = 180}, 0.3)
                    Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 55 + math.min(#options * 36, 200))}, 0.3, Enum.EasingStyle.Quart)
                else
                    Tween(arrow, {Rotation = 0}, 0.3)
                    Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.3, Enum.EasingStyle.Quart)
                end
            end
            
            -- Create option buttons
            for i, option in ipairs(options) do
                local optionBtn = Create("TextButton", {
                    Name = option,
                    BackgroundColor3 = NexusUI.Theme.Background,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Font = Enum.Font.Gotham,
                    Text = option,
                    TextColor3 = NexusUI.Theme.TextSecondary,
                    TextSize = 13,
                    AutoButtonColor = false,
                    Parent = optionsFrame
                })
                AddCorner(optionBtn, 6)
                
                optionBtn.MouseEnter:Connect(function()
                    Tween(optionBtn, {BackgroundColor3 = NexusUI.Theme.ElementHover}, 0.2)
                    Tween(optionBtn, {TextColor3 = NexusUI.Theme.TextPrimary}, 0.2)
                end)
                
                optionBtn.MouseLeave:Connect(function()
                    Tween(optionBtn, {BackgroundColor3 = NexusUI.Theme.Background}, 0.2)
                    Tween(optionBtn, {TextColor3 = NexusUI.Theme.TextSecondary}, 0.2)
                end)
                
                optionBtn.MouseButton1Click:Connect(function()
                    currentOption = option
                    selectedLabel.Text = option
                    dropdownCallback(option)
                    ToggleDropdown()
                end)
                
                table.insert(optionButtons, optionBtn)
            end
            
            local clickArea = Create("TextButton", {
                Name = "ClickArea",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 50),
                Text = "",
                Parent = dropdownFrame
            })
            clickArea.MouseButton1Click:Connect(ToggleDropdown)
            
            local DropdownObj = {}
            function DropdownObj:Set(option)
                if table.find(options, option) then
                    currentOption = option
                    selectedLabel.Text = option
                    dropdownCallback(option)
                end
            end
            function DropdownObj:Get() return currentOption end
            function DropdownObj:Refresh(newOptions)
                options = newOptions
                for _, btn in ipairs(optionButtons) do btn:Destroy() end
                optionButtons = {}
                -- Recreate options...
                for i, option in ipairs(options) do
                    -- (simplified - in production would recreate)
                end
            end
            
            return DropdownObj
        end
        
        function Tab:CreateLabel(labelSettings)
            labelSettings = labelSettings or {}
            local labelText = labelSettings.Text or "Label"
            local labelColor = labelSettings.Color or NexusUI.Theme.TextPrimary
            
            local labelFrame = Create("Frame", {
                Name = "Label",
                BackgroundColor3 = NexusUI.Theme.ElementBackground,
                BackgroundTransparency = 0.5,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40),
                Parent = page
            })
            AddCorner(labelFrame, 10)
            
            local label = Create("TextLabel", {
                Name = "Text",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                Font = Enum.Font.GothamBold,
                Text = labelText,
                TextColor3 = labelColor,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                Parent = labelFrame
            })
            
            local LabelObj = {}
            function LabelObj:Set(text)
                label.Text = text
            end
            
            return LabelObj
        end
        
        return Tab
    end
    
    -- Intro animation
    mainWindow.Size = UDim2.new(0, 0, 0, 0)
    mainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainWindow.Visible = true
    
    Tween(mainWindow, {Size = UDim2.new(0, 800, 0, 500)}, 0.6, Enum.EasingStyle.Back)
    Tween(mainWindow, {Position = UDim2.new(0.5, -400, 0.5, -250)}, 0.6, Enum.EasingStyle.Back)
    
    return Window
end

-- ═══════════════════════════════════════════════════════════
--  RETURN LIBRARY
-- ═══════════════════════════════════════════════════════════

return NexusUI