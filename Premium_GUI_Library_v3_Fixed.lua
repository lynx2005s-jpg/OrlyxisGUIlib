-- ═══════════════════════════════════════════════════════════════════════════════
--  PREMIUM GUI LIBRARY FOR ROBLOX (Delta / Flux / Synapse Ready)
--  Version: 3.0 - FIXED & ENHANCED
--  Features: Key System, Status Label, 10 Themes, 17+ Components, Icon Toggle
--  Inspired by Rayfield & Fluent
-- ═══════════════════════════════════════════════════════════════════════════════

local Library = {}

-- ═══ SERVICES ═══
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- ═══ UTILITIES ═══
local Utils = {}

function Utils:Create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

function Utils:Tween(inst, props, duration, style, dir, callback)
    style = style or Enum.EasingStyle.Quart
    dir = dir or Enum.EasingDirection.Out
    duration = duration or 0.35
    local ti = TweenInfo.new(duration, style, dir)
    local tw = TweenService:Create(inst, ti, props)
    if callback then tw.Completed:Connect(callback) end
    tw:Play()
    return tw
end

function Utils:Spring(inst, props, duration)
    return self:Tween(inst, props, duration or 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

function Utils:Ripple(btn, mx, my, color)
    local ripple = self:Create("Frame", {
        Name = "Ripple", AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = color or Color3.fromRGB(255,255,255),
        BackgroundTransparency = 0.85,
        Position = UDim2.new(0, mx - btn.AbsolutePosition.X, 0, my - btn.AbsolutePosition.Y),
        Size = UDim2.new(0, 0, 0, 0), BorderSizePixel = 0,
        ZIndex = btn.ZIndex + 2, Parent = btn,
    })
    self:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ripple})
    local max = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) * 2.8
    self:Tween(ripple, {Size = UDim2.new(0, max, 0, max), BackgroundTransparency = 1}, 0.7, nil, nil, function()
        ripple:Destroy()
    end)
end

function Utils:MakeDraggable(frame, handle)
    handle = handle or frame
    local drag, dragInput, startPos, startFrame

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            startPos = input.Position
            startFrame = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and drag then
            local delta = input.Position - startPos
            frame.Position = UDim2.new(startFrame.X.Scale, startFrame.X.Offset + delta.X, startFrame.Y.Scale, startFrame.Y.Offset + delta.Y)
        end
    end)
end

function Utils:Round(num, dec)
    dec = dec or 0
    return math.floor(num * 10^dec + 0.5) / 10^dec
end

-- ═══ THEME SYSTEM (10 Presets + Custom) ═══
local Theme = {}

Theme.Presets = {
    Default = {
        Name = "Default",
        Primary = Color3.fromRGB(124, 37, 255),
        Secondary = Color3.fromRGB(88, 28, 200),
        Background = Color3.fromRGB(20, 20, 23),
        Foreground = Color3.fromRGB(28, 28, 32),
        Surface = Color3.fromRGB(35, 35, 40),
        Elevated = Color3.fromRGB(45, 45, 52),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 170, 180),
        TextMuted = Color3.fromRGB(120, 120, 130),
        Success = Color3.fromRGB(0, 230, 118),
        Warning = Color3.fromRGB(255, 171, 0),
        Error = Color3.fromRGB(255, 82, 82),
        Info = Color3.fromRGB(41, 182, 246),
        Border = Color3.fromRGB(55, 55, 65),
        BorderHover = Color3.fromRGB(80, 80, 95),
        Glass = Color3.fromRGB(20, 20, 23),
        GlassAlpha = 0.15,
        CornerRadius = 10,
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
        FontSemibold = Enum.Font.GothamSemibold,
    },
    Ocean = {
        Name = "Ocean",
        Primary = Color3.fromRGB(0, 176, 255),
        Secondary = Color3.fromRGB(0, 120, 215),
        Background = Color3.fromRGB(12, 18, 28),
        Foreground = Color3.fromRGB(18, 26, 40),
        Surface = Color3.fromRGB(24, 34, 52),
        Elevated = Color3.fromRGB(32, 44, 66),
        TextPrimary = Color3.fromRGB(240, 248, 255),
        TextSecondary = Color3.fromRGB(150, 180, 210),
        TextMuted = Color3.fromRGB(100, 130, 170),
        Success = Color3.fromRGB(0, 255, 170),
        Warning = Color3.fromRGB(255, 200, 60),
        Error = Color3.fromRGB(255, 90, 90),
        Info = Color3.fromRGB(80, 200, 255),
        Border = Color3.fromRGB(35, 50, 75),
        BorderHover = Color3.fromRGB(55, 80, 120),
        Glass = Color3.fromRGB(12, 18, 28),
        GlassAlpha = 0.12,
        CornerRadius = 12,
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
        FontSemibold = Enum.Font.GothamSemibold,
    },
    Midnight = {
        Name = "Midnight",
        Primary = Color3.fromRGB(255, 50, 100),
        Secondary = Color3.fromRGB(200, 30, 70),
        Background = Color3.fromRGB(10, 10, 14),
        Foreground = Color3.fromRGB(16, 16, 22),
        Surface = Color3.fromRGB(24, 24, 32),
        Elevated = Color3.fromRGB(32, 32, 44),
        TextPrimary = Color3.fromRGB(245, 245, 250),
        TextSecondary = Color3.fromRGB(160, 160, 175),
        TextMuted = Color3.fromRGB(110, 110, 125),
        Success = Color3.fromRGB(50, 255, 130),
        Warning = Color3.fromRGB(255, 180, 50),
        Error = Color3.fromRGB(255, 70, 70),
        Info = Color3.fromRGB(255, 100, 150),
        Border = Color3.fromRGB(40, 40, 55),
        BorderHover = Color3.fromRGB(70, 70, 90),
        Glass = Color3.fromRGB(10, 10, 14),
        GlassAlpha = 0.2,
        CornerRadius = 8,
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
        FontSemibold = Enum.Font.GothamSemibold,
    },
    Forest = {
        Name = "Forest",
        Primary = Color3.fromRGB(0, 200, 83),
        Secondary = Color3.fromRGB(0, 150, 60),
        Background = Color3.fromRGB(14, 20, 14),
        Foreground = Color3.fromRGB(20, 28, 20),
        Surface = Color3.fromRGB(28, 38, 28),
        Elevated = Color3.fromRGB(36, 48, 36),
        TextPrimary = Color3.fromRGB(240, 255, 240),
        TextSecondary = Color3.fromRGB(160, 190, 160),
        TextMuted = Color3.fromRGB(110, 140, 110),
        Success = Color3.fromRGB(100, 255, 100),
        Warning = Color3.fromRGB(255, 220, 80),
        Error = Color3.fromRGB(255, 100, 100),
        Info = Color3.fromRGB(100, 255, 150),
        Border = Color3.fromRGB(40, 55, 40),
        BorderHover = Color3.fromRGB(60, 85, 60),
        Glass = Color3.fromRGB(14, 20, 14),
        GlassAlpha = 0.15,
        CornerRadius = 10,
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
        FontSemibold = Enum.Font.GothamSemibold,
    },
    Sunset = {
        Name = "Sunset",
        Primary = Color3.fromRGB(255, 112, 67),
        Secondary = Color3.fromRGB(230, 80, 40),
        Background = Color3.fromRGB(22, 16, 14),
        Foreground = Color3.fromRGB(32, 24, 20),
        Surface = Color3.fromRGB(44, 34, 28),
        Elevated = Color3.fromRGB(56, 44, 36),
        TextPrimary = Color3.fromRGB(255, 245, 230),
        TextSecondary = Color3.fromRGB(200, 180, 160),
        TextMuted = Color3.fromRGB(150, 130, 110),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 90, 90),
        Info = Color3.fromRGB(255, 160, 100),
        Border = Color3.fromRGB(60, 48, 40),
        BorderHover = Color3.fromRGB(90, 72, 60),
        Glass = Color3.fromRGB(22, 16, 14),
        GlassAlpha = 0.15,
        CornerRadius = 10,
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
        FontSemibold = Enum.Font.GothamSemibold,
    },
    Cyber = {
        Name = "Cyber",
        Primary = Color3.fromRGB(0, 255, 255),
        Secondary = Color3.fromRGB(0, 200, 200),
        Background = Color3.fromRGB(8, 8, 12),
        Foreground = Color3.fromRGB(12, 12, 20),
        Surface = Color3.fromRGB(20, 20, 35),
        Elevated = Color3.fromRGB(28, 28, 48),
        TextPrimary = Color3.fromRGB(220, 255, 255),
        TextSecondary = Color3.fromRGB(140, 200, 200),
        TextMuted = Color3.fromRGB(90, 140, 140),
        Success = Color3.fromRGB(0, 255, 150),
        Warning = Color3.fromRGB(255, 255, 0),
        Error = Color3.fromRGB(255, 50, 100),
        Info = Color3.fromRGB(0, 230, 255),
        Border = Color3.fromRGB(30, 40, 60),
        BorderHover = Color3.fromRGB(50, 70, 100),
        Glass = Color3.fromRGB(8, 8, 12),
        GlassAlpha = 0.1,
        CornerRadius = 6,
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
        FontSemibold = Enum.Font.GothamSemibold,
    },
    Rose = {
        Name = "Rose",
        Primary = Color3.fromRGB(236, 64, 122),
        Secondary = Color3.fromRGB(200, 40, 90),
        Background = Color3.fromRGB(20, 14, 18),
        Foreground = Color3.fromRGB(28, 20, 24),
        Surface = Color3.fromRGB(40, 28, 36),
        Elevated = Color3.fromRGB(52, 36, 46),
        TextPrimary = Color3.fromRGB(255, 240, 245),
        TextSecondary = Color3.fromRGB(200, 170, 180),
        TextMuted = Color3.fromRGB(150, 120, 135),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 100),
        Error = Color3.fromRGB(255, 80, 80),
        Info = Color3.fromRGB(255, 130, 180),
        Border = Color3.fromRGB(55, 40, 48),
        BorderHover = Color3.fromRGB(80, 55, 70),
        Glass = Color3.fromRGB(20, 14, 18),
        GlassAlpha = 0.15,
        CornerRadius = 12,
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
        FontSemibold = Enum.Font.GothamSemibold,
    },
    Dark = {
        Name = "Dark",
        Primary = Color3.fromRGB(200, 200, 200),
        Secondary = Color3.fromRGB(150, 150, 150),
        Background = Color3.fromRGB(10, 10, 10),
        Foreground = Color3.fromRGB(18, 18, 18),
        Surface = Color3.fromRGB(28, 28, 28),
        Elevated = Color3.fromRGB(38, 38, 38),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(160, 160, 160),
        TextMuted = Color3.fromRGB(100, 100, 100),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 80, 80),
        Info = Color3.fromRGB(180, 180, 180),
        Border = Color3.fromRGB(40, 40, 40),
        BorderHover = Color3.fromRGB(70, 70, 70),
        Glass = Color3.fromRGB(10, 10, 10),
        GlassAlpha = 0.2,
        CornerRadius = 8,
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
        FontSemibold = Enum.Font.GothamSemibold,
    },
    Gold = {
        Name = "Gold",
        Primary = Color3.fromRGB(255, 193, 7),
        Secondary = Color3.fromRGB(220, 160, 0),
        Background = Color3.fromRGB(20, 18, 12),
        Foreground = Color3.fromRGB(30, 26, 18),
        Surface = Color3.fromRGB(48, 42, 28),
        Elevated = Color3.fromRGB(60, 54, 36),
        TextPrimary = Color3.fromRGB(255, 250, 230),
        TextSecondary = Color3.fromRGB(210, 190, 150),
        TextMuted = Color3.fromRGB(160, 140, 100),
        Success = Color3.fromRGB(100, 255, 150),
        Warning = Color3.fromRGB(255, 220, 100),
        Error = Color3.fromRGB(255, 90, 90),
        Info = Color3.fromRGB(255, 200, 80),
        Border = Color3.fromRGB(60, 52, 35),
        BorderHover = Color3.fromRGB(90, 78, 50),
        Glass = Color3.fromRGB(20, 18, 12),
        GlassAlpha = 0.15,
        CornerRadius = 10,
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
        FontSemibold = Enum.Font.GothamSemibold,
    },
    Lavender = {
        Name = "Lavender",
        Primary = Color3.fromRGB(180, 140, 255),
        Secondary = Color3.fromRGB(140, 100, 220),
        Background = Color3.fromRGB(18, 16, 24),
        Foreground = Color3.fromRGB(26, 24, 34),
        Surface = Color3.fromRGB(40, 36, 52),
        Elevated = Color3.fromRGB(50, 46, 66),
        TextPrimary = Color3.fromRGB(245, 240, 255),
        TextSecondary = Color3.fromRGB(190, 180, 220),
        TextMuted = Color3.fromRGB(140, 130, 170),
        Success = Color3.fromRGB(120, 255, 160),
        Warning = Color3.fromRGB(255, 210, 100),
        Error = Color3.fromRGB(255, 100, 100),
        Info = Color3.fromRGB(200, 170, 255),
        Border = Color3.fromRGB(50, 46, 65),
        BorderHover = Color3.fromRGB(75, 68, 95),
        Glass = Color3.fromRGB(18, 16, 24),
        GlassAlpha = 0.15,
        CornerRadius = 12,
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
        FontSemibold = Enum.Font.GothamSemibold,
    },
}

Theme.Current = nil

function Theme:Set(nameOrTable)
    if type(nameOrTable) == "string" and self.Presets[nameOrTable] then
        self.Current = self.Presets[nameOrTable]
    elseif type(nameOrTable) == "table" then
        self.Current = nameOrTable
    else
        self.Current = self.Presets.Default
    end
    return self.Current
end

function Theme:Get()
    if not self.Current then self.Current = self.Presets.Default end
    return self.Current
end

function Theme:RegisterCustom(name, colors)
    self.Presets[name] = colors
    return colors
end

function Theme:GetAllNames()
    local names = {}
    for name, _ in pairs(self.Presets) do
        table.insert(names, name)
    end
    return names
end

-- ═══ ANIMATION ENGINE ═══
local Anim = {}

function Anim:Tween(inst, props, dur, style, dir, cb)
    return Utils:Tween(inst, props, dur, style, dir, cb)
end

function Anim:FadeIn(inst, dur)
    inst.BackgroundTransparency = 1
    return self:Tween(inst, {BackgroundTransparency = 0}, dur or 0.3)
end

function Anim:FadeOut(inst, dur, cb)
    return self:Tween(inst, {BackgroundTransparency = 1}, dur or 0.3, nil, nil, cb)
end

function Anim:ScaleIn(inst, dur)
    inst.Size = UDim2.new(0, 0, 0, 0)
    return self:Tween(inst, {Size = UDim2.new(1, 0, 1, 0)}, dur or 0.4, Enum.EasingStyle.Back)
end

function Anim:Pop(inst, dur)
    return self:Tween(inst, {Size = UDim2.new(1, 4, 1, 4)}, (dur or 0.15) / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
        self:Tween(inst, {Size = UDim2.new(1, 0, 1, 0)}, (dur or 0.15) / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end)
end

function Anim:SlideY(inst, offset, dur)
    return self:Tween(inst, {Position = UDim2.new(inst.Position.X.Scale, inst.Position.X.Offset, inst.Position.Y.Scale, inst.Position.Y.Offset + offset)}, dur or 0.3)
end

function Anim:Number(startVal, endVal, dur, cb)
    local startTime = tick()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local prog = math.min(elapsed / (dur or 0.3), 1)
        local eased = 1 - math.pow(1 - prog, 3)
        cb(startVal + (endVal - startVal) * eased)
        if prog >= 1 then conn:Disconnect() end
    end)
    return conn
end

-- ═══ COMPONENTS (17+ Components) ═══
local Components = {}

function Components:Base(name, parent, h)
    local t = Theme:Get()
    local base = Utils:Create("Frame", {
        Name = name, BackgroundColor3 = t.Foreground, BorderSizePixel = 0,
        Size = UDim2.new(1, -16, 0, h or 40), Position = UDim2.new(0, 8, 0, 0), Parent = parent,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, t.CornerRadius - 2), Parent = base})
    return base
end

-- 1. Label
function Components:Label(c)
    local t = Theme:Get()
    local base = self:Base("Label", c.Parent, c.Height or 28)
    base.BackgroundTransparency = 1
    local lbl = Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "Label", Font = t.Font, TextSize = c.Size or 13,
        TextColor3 = c.Color or t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -12, 1, 0), Position = UDim2.new(0, 8, 0, 0),
        TextXAlignment = c.Align or Enum.TextXAlignment.Left, TextWrapped = true,
        Parent = base,
    })
    return {Instance = base, Set = function(_, txt) lbl.Text = txt end, Object = lbl}
end

-- 2. Paragraph
function Components:Paragraph(c)
    local t = Theme:Get()
    local base = self:Base("Paragraph", c.Parent, 60)
    base.AutomaticSize = Enum.AutomaticSize.Y
    local title = Utils:Create("TextLabel", {
        Name = "Title", Text = c.Title or "Title", Font = t.FontBold, TextSize = 13,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0, 8, 0, 6),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })
    local content = Utils:Create("TextLabel", {
        Name = "Content", Text = c.Content or "", Font = t.Font, TextSize = 12,
        TextColor3 = t.TextSecondary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, 20), Position = UDim2.new(0, 8, 0, 26),
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = base,
    })
    return {Instance = base, SetTitle = function(_, txt) title.Text = txt end, SetContent = function(_, txt) content.Text = txt end}
end

-- 3. Button
function Components:Button(c)
    local t = Theme:Get()
    local cb = c.Callback or function() end
    local base = self:Base("Button", c.Parent, 36)

    local stroke = Utils:Create("UIStroke", {Color = t.Border, Thickness = 1, Transparency = 0.6, Parent = base})
    local lbl = Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "Button", Font = t.FontBold, TextSize = 12,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), Parent = base,
    })
    local hover = Utils:Create("Frame", {
        Name = "Hover", BackgroundColor3 = t.Primary, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 2, Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, t.CornerRadius - 2), Parent = hover})

    local hovering = false
    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            hovering = true
            Anim:Tween(hover, {BackgroundTransparency = 0.92}, 0.2)
            Anim:Tween(base, {BackgroundColor3 = t.Surface}, 0.2)
            Anim:Tween(stroke, {Color = t.BorderHover}, 0.2)
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = UserInputService:GetMouseLocation()
            Utils:Ripple(base, pos.X, pos.Y, t.Primary)
            Anim:Tween(base, {BackgroundColor3 = t.Secondary}, 0.1, nil, nil, function()
                Anim:Tween(base, {BackgroundColor3 = hovering and t.Surface or t.Foreground}, 0.2)
            end)
            cb()
        end
    end)
    base.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            hovering = false
            Anim:Tween(hover, {BackgroundTransparency = 1}, 0.2)
            Anim:Tween(base, {BackgroundColor3 = t.Foreground}, 0.2)
            Anim:Tween(stroke, {Color = t.Border}, 0.2)
        end
    end)
    return {Instance = base, SetText = function(_, txt) lbl.Text = txt end}
end

-- 4. Toggle
function Components:Toggle(c)
    local t = Theme:Get()
    local cb = c.Callback or function() end
    local base = self:Base("Toggle", c.Parent, 40)

    Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "Toggle", Font = t.Font, TextSize = 13,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -70, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })

    local bg = Utils:Create("Frame", {
        Name = "Bg", BackgroundColor3 = t.Border, BorderSizePixel = 0,
        Size = UDim2.new(0, 44, 0, 24), Position = UDim2.new(1, -54, 0.5, -12), Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = bg})

    local knob = Utils:Create("Frame", {
        Name = "Knob", BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0,
        Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 3, 0.5, -9), Parent = bg,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})
    Utils:Create("UIStroke", {Color = Color3.fromRGB(200,200,200), Thickness = 0.5, Parent = knob})

    local state = c.Default or false
    local function update()
        if state then
            Anim:Tween(bg, {BackgroundColor3 = t.Primary}, 0.25)
            Anim:Tween(knob, {Position = UDim2.new(0, 23, 0.5, -9)}, 0.25, Enum.EasingStyle.Back)
        else
            Anim:Tween(bg, {BackgroundColor3 = t.Border}, 0.25)
            Anim:Tween(knob, {Position = UDim2.new(0, 3, 0.5, -9)}, 0.25, Enum.EasingStyle.Back)
        end
        cb(state)
    end
    if state then update() end

    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state; update()
        end
    end)
    return {Instance = base, Get = function() return state end, Set = function(_, v) state = v; update() end}
end

-- 5. Slider
function Components:Slider(c)
    local t = Theme:Get()
    local cb = c.Callback or function() end
    local min, max = c.Min or 0, c.Max or 100
    local inc = c.Increment or 1
    local base = self:Base("Slider", c.Parent, 52)

    Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "Slider", Font = t.Font, TextSize = 13,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 0, 20), Position = UDim2.new(0, 10, 0, 5),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })
    local valLbl = Utils:Create("TextLabel", {
        Name = "Value", Text = tostring(c.Default or min), Font = t.FontBold, TextSize = 12,
        TextColor3 = t.Primary, BackgroundTransparency = 1,
        Size = UDim2.new(0, 50, 0, 20), Position = UDim2.new(1, -60, 0, 5),
        TextXAlignment = Enum.TextXAlignment.Right, Parent = base,
    })

    local track = Utils:Create("Frame", {
        Name = "Track", BackgroundColor3 = t.Border, BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 34), Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})

    local fill = Utils:Create("Frame", {
        Name = "Fill", BackgroundColor3 = t.Primary, BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0), Parent = track,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})

    local knob = Utils:Create("Frame", {
        Name = "Knob", BackgroundColor3 = Color3.fromRGB(255,255,255), BorderSizePixel = 0,
        Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, -8, 0.5, -8), Parent = track,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})
    Utils:Create("UIStroke", {Color = t.Primary, Thickness = 2, Parent = knob})

    local dragging = false
    local val = c.Default or min

    local function update(input)
        local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local raw = min + (max - min) * rel
        val = math.floor(raw / inc + 0.5) * inc
        val = math.clamp(val, min, max)
        local s = (val - min) / (max - min)
        fill.Size = UDim2.new(s, 0, 1, 0)
        knob.Position = UDim2.new(s, -8, 0.5, -8)
        valLbl.Text = tostring(val)
        cb(val)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return {Instance = base, Get = function() return val end, Set = function(_, v)
        val = math.clamp(v, min, max)
        local s = (val - min) / (max - min)
        fill.Size = UDim2.new(s, 0, 1, 0)
        knob.Position = UDim2.new(s, -8, 0.5, -8)
        valLbl.Text = tostring(val); cb(val)
    end}
end

-- 6. Dropdown
function Components:Dropdown(c)
    local t = Theme:Get()
    local cb = c.Callback or function() end
    local opts = c.Options or {}
    local base = self:Base("Dropdown", c.Parent, 40)

    Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "Dropdown", Font = t.Font, TextSize = 13,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -130, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })
    local sel = Utils:Create("TextLabel", {
        Name = "Selected", Text = c.Default or "Select...", Font = t.FontMedium, TextSize = 12,
        TextColor3 = t.TextSecondary, BackgroundTransparency = 1,
        Size = UDim2.new(0, 90, 1, 0), Position = UDim2.new(1, -110, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right, Parent = base,
    })
    local arrow = Utils:Create("TextLabel", {
        Name = "Arrow", Text = "▼", Font = t.Font, TextSize = 10,
        TextColor3 = t.TextMuted, BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -22, 0, 0), Parent = base,
    })

    local drop = Utils:Create("Frame", {
        Name = "Dropdown", BackgroundColor3 = t.Surface, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 42),
        Visible = false, ZIndex = 10, ClipsDescendants = true, Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, t.CornerRadius - 2), Parent = drop})
    Utils:Create("UIStroke", {Color = t.Border, Thickness = 1, Parent = drop})
    Utils:Create("UIListLayout", {Padding = UDim.new(0, 2), Parent = drop})

    local open = false
    local cur = c.Default

    local function mkOpt(txt)
        local btn = Utils:Create("TextButton", {
            Name = txt, Text = txt, Font = t.Font, TextSize = 12,
            TextColor3 = t.TextSecondary, BackgroundColor3 = t.Surface,
            BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), ZIndex = 11, Parent = drop,
        })
        btn.MouseEnter:Connect(function()
            Anim:Tween(btn, {BackgroundColor3 = t.Primary, TextColor3 = Color3.fromRGB(255,255,255)}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Anim:Tween(btn, {BackgroundColor3 = t.Surface, TextColor3 = t.TextSecondary}, 0.15)
        end)
        btn.MouseButton1Click:Connect(function()
            cur = txt; sel.Text = txt; open = false
            Anim:Tween(drop, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            Anim:Tween(arrow, {Rotation = 0}, 0.2)
            cb(txt)
        end)
    end
    for _, o in ipairs(opts) do mkOpt(o) end

    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            open = not open
            if open then
                drop.Visible = true
                Anim:Tween(drop, {Size = UDim2.new(1, 0, 0, math.min(#opts * 32 + 4, 180))}, 0.25, Enum.EasingStyle.Quart)
                Anim:Tween(arrow, {Rotation = 180}, 0.25)
            else
                Anim:Tween(drop, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, nil, nil, function() drop.Visible = false end)
                Anim:Tween(arrow, {Rotation = 0}, 0.2)
            end
        end
    end)
    return {Instance = base, Get = function() return cur end, SetOptions = function(_, new)
        for _, ch in ipairs(drop:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
        opts = new; for _, o in ipairs(opts) do mkOpt(o) end
    end}
end

-- 7. MultiDropdown
function Components:MultiDropdown(c)
    local t = Theme:Get()
    local cb = c.Callback or function() end
    local opts = c.Options or {}
    local base = self:Base("MultiDropdown", c.Parent, 40)

    Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "Multi Select", Font = t.Font, TextSize = 13,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -130, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })
    local sel = Utils:Create("TextLabel", {
        Name = "Selected", Text = "None", Font = t.FontMedium, TextSize = 12,
        TextColor3 = t.TextSecondary, BackgroundTransparency = 1,
        Size = UDim2.new(0, 90, 1, 0), Position = UDim2.new(1, -110, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right, Parent = base,
    })
    local arrow = Utils:Create("TextLabel", {
        Name = "Arrow", Text = "▼", Font = t.Font, TextSize = 10,
        TextColor3 = t.TextMuted, BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -22, 0, 0), Parent = base,
    })

    local drop = Utils:Create("Frame", {
        Name = "Dropdown", BackgroundColor3 = t.Surface, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 42),
        Visible = false, ZIndex = 10, ClipsDescendants = true, Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, t.CornerRadius - 2), Parent = drop})
    Utils:Create("UIStroke", {Color = t.Border, Thickness = 1, Parent = drop})
    Utils:Create("UIListLayout", {Padding = UDim.new(0, 2), Parent = drop})

    local open = false
    local selected = {}

    local function updateText()
        local txt = ""
        for i, v in ipairs(selected) do
            txt = txt .. v .. (i < #selected and ", " or "")
        end
        sel.Text = #selected > 0 and txt or "None"
    end

    local function mkOpt(txt)
        local btn = Utils:Create("TextButton", {
            Name = txt, Text = "   " .. txt, Font = t.Font, TextSize = 12,
            TextColor3 = t.TextSecondary, BackgroundColor3 = t.Surface,
            BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 30), ZIndex = 11, Parent = drop,
        })
        local check = Utils:Create("Frame", {
            Name = "Check", BackgroundColor3 = t.Primary, BorderSizePixel = 0,
            Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 8, 0.5, -7),
            Visible = false, Parent = btn,
        })
        Utils:Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = check})

        btn.MouseEnter:Connect(function()
            Anim:Tween(btn, {BackgroundColor3 = t.Elevated}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Anim:Tween(btn, {BackgroundColor3 = t.Surface}, 0.15)
        end)
        btn.MouseButton1Click:Connect(function()
            local found = false
            for i, v in ipairs(selected) do
                if v == txt then table.remove(selected, i); found = true; break end
            end
            if not found then table.insert(selected, txt) end
            check.Visible = not found
            updateText(); cb(selected)
        end)
    end
    for _, o in ipairs(opts) do mkOpt(o) end

    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            open = not open
            if open then
                drop.Visible = true
                Anim:Tween(drop, {Size = UDim2.new(1, 0, 0, math.min(#opts * 32 + 4, 180))}, 0.25)
                Anim:Tween(arrow, {Rotation = 180}, 0.25)
            else
                Anim:Tween(drop, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, nil, nil, function() drop.Visible = false end)
                Anim:Tween(arrow, {Rotation = 0}, 0.2)
            end
        end
    end)
    return {Instance = base, Get = function() return selected end}
end

-- 8. Input
function Components:Input(c)
    local t = Theme:Get()
    local cb = c.Callback or function() end
    local base = self:Base("Input", c.Parent, 40)

    Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "Input", Font = t.Font, TextSize = 13,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -150, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })
    local box = Utils:Create("TextBox", {
        Name = "Box", Text = c.Default or "", PlaceholderText = c.Placeholder or "Type...",
        Font = t.Font, TextSize = 12, TextColor3 = t.TextPrimary,
        PlaceholderColor3 = t.TextMuted, BackgroundColor3 = t.Background,
        BorderSizePixel = 0, Size = UDim2.new(0, 130, 0, 26),
        Position = UDim2.new(1, -140, 0.5, -13), ClearTextOnFocus = false, Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, math.max(t.CornerRadius - 3, 4)), Parent = box})
    local stroke = Utils:Create("UIStroke", {Color = t.Border, Thickness = 1, Parent = box})

    box.Focused:Connect(function() Anim:Tween(stroke, {Color = t.Primary}, 0.2) end)
    box.FocusLost:Connect(function() Anim:Tween(stroke, {Color = t.Border}, 0.2); cb(box.Text) end)
    return {Instance = base, Get = function() return box.Text end, Set = function(_, txt) box.Text = txt; cb(txt) end}
end

-- 9. NumberInput
function Components:NumberInput(c)
    local t = Theme:Get()
    local cb = c.Callback or function() end
    local base = self:Base("NumberInput", c.Parent, 40)

    Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "Number", Font = t.Font, TextSize = 13,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -150, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })
    local box = Utils:Create("TextBox", {
        Name = "Box", Text = tostring(c.Default or 0), PlaceholderText = "0",
        Font = t.Font, TextSize = 12, TextColor3 = t.TextPrimary,
        PlaceholderColor3 = t.TextMuted, BackgroundColor3 = t.Background,
        BorderSizePixel = 0, Size = UDim2.new(0, 80, 0, 26),
        Position = UDim2.new(1, -90, 0.5, -13), ClearTextOnFocus = false, Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, math.max(t.CornerRadius - 3, 4)), Parent = box})
    local stroke = Utils:Create("UIStroke", {Color = t.Border, Thickness = 1, Parent = box})

    local function validate()
        local n = tonumber(box.Text)
        if n then
            if c.Min then n = math.max(n, c.Min) end
            if c.Max then n = math.min(n, c.Max) end
            box.Text = tostring(n)
            cb(n)
        else
            box.Text = tostring(c.Default or 0)
        end
    end

    box.Focused:Connect(function() Anim:Tween(stroke, {Color = t.Primary}, 0.2) end)
    box.FocusLost:Connect(function() Anim:Tween(stroke, {Color = t.Border}, 0.2); validate() end)
    return {Instance = base, Get = function() return tonumber(box.Text) or 0 end, Set = function(_, v) box.Text = tostring(v); cb(v) end}
end

-- 10. Keybind
function Components:Keybind(c)
    local t = Theme:Get()
    local cb = c.Callback or function() end
    local base = self:Base("Keybind", c.Parent, 40)

    Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "Keybind", Font = t.Font, TextSize = 13,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })
    local keyLbl = Utils:Create("TextLabel", {
        Name = "Key", Text = (c.Default or Enum.KeyCode.E).Name,
        Font = t.FontBold, TextSize = 11, TextColor3 = t.Primary,
        BackgroundColor3 = t.Background, BorderSizePixel = 0,
        Size = UDim2.new(0, 55, 0, 24), Position = UDim2.new(1, -65, 0.5, -12), Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = keyLbl})
    local stroke = Utils:Create("UIStroke", {Color = t.Border, Thickness = 1, Parent = keyLbl})

    local listening = false
    local curKey = c.Default or Enum.KeyCode.E

    local function listen()
        listening = true
        keyLbl.Text = "..."
        Anim:Tween(stroke, {Color = t.Primary}, 0.2)
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode ~= Enum.KeyCode.Escape then
                    curKey = input.KeyCode
                    keyLbl.Text = input.KeyCode.Name
                    cb(input.KeyCode)
                end
                listening = false
                Anim:Tween(stroke, {Color = t.Border}, 0.2)
                conn:Disconnect()
            end
        end)
    end

    keyLbl.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not listening then listen() end
    end)
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == curKey and not listening then cb(curKey) end
    end)
    return {Instance = base, Get = function() return curKey end, Set = function(_, k) curKey = k; keyLbl.Text = k.Name end}
end

-- 11. ColorPicker
function Components:ColorPicker(c)
    local t = Theme:Get()
    local cb = c.Callback or function() end
    local base = self:Base("ColorPicker", c.Parent, 40)

    Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "Color", Font = t.Font, TextSize = 13,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })
    local preview = Utils:Create("Frame", {
        Name = "Preview", BackgroundColor3 = c.Default or t.Primary, BorderSizePixel = 0,
        Size = UDim2.new(0, 32, 0, 22), Position = UDim2.new(1, -42, 0.5, -11), Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = preview})
    Utils:Create("UIStroke", {Color = t.Border, Thickness = 1, Parent = preview})

    local open = false
    local cur = c.Default or t.Primary

    local picker = Utils:Create("Frame", {
        Name = "Picker", BackgroundColor3 = t.Surface, BorderSizePixel = 0,
        Size = UDim2.new(0, 180, 0, 0), Position = UDim2.new(1, -190, 0, 42),
        Visible = false, ZIndex = 15, Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, t.CornerRadius - 2), Parent = picker})
    Utils:Create("UIStroke", {Color = t.Border, Thickness = 1, Parent = picker})
    Utils:Create("UIGridLayout", {CellSize = UDim2.new(0, 32, 0, 32), CellPadding = UDim2.new(0, 6, 0, 6), Parent = picker})
    Utils:Create("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), Parent = picker})

    local presets = {
        Color3.fromRGB(255,0,0), Color3.fromRGB(255,127,0), Color3.fromRGB(255,255,0),
        Color3.fromRGB(0,255,0), Color3.fromRGB(0,255,255), Color3.fromRGB(0,0,255),
        Color3.fromRGB(127,0,255), Color3.fromRGB(255,0,255), Color3.fromRGB(255,255,255),
        Color3.fromRGB(124,37,255), Color3.fromRGB(255,50,100), Color3.fromRGB(0,150,255),
        Color3.fromRGB(0,200,83), Color3.fromRGB(255,193,7), Color3.fromRGB(236,64,122),
    }
    for i, col in ipairs(presets) do
        local sw = Utils:Create("TextButton", {
            Name = "S"..i, BackgroundColor3 = col, BorderSizePixel = 0,
            Size = UDim2.new(0, 32, 0, 32), ZIndex = 16, Parent = picker,
        })
        Utils:Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = sw})
        sw.MouseButton1Click:Connect(function()
            cur = col; preview.BackgroundColor3 = col
            open = false
            Anim:Tween(picker, {Size = UDim2.new(0, 180, 0, 0)}, 0.2, nil, nil, function() picker.Visible = false end)
            cb(col)
        end)
    end

    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            open = not open
            if open then
                picker.Visible = true
                Anim:Tween(picker, {Size = UDim2.new(0, 180, 0, 130)}, 0.25)
            else
                Anim:Tween(picker, {Size = UDim2.new(0, 180, 0, 0)}, 0.2, nil, nil, function() picker.Visible = false end)
            end
        end
    end)
    return {Instance = base, Get = function() return cur end, Set = function(_, col) cur = col; preview.BackgroundColor3 = col; cb(col) end}
end

-- 12. ProgressBar
function Components:ProgressBar(c)
    local t = Theme:Get()
    local base = self:Base("ProgressBar", c.Parent, 36)
    base.BackgroundTransparency = 1

    Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "Progress", Font = t.Font, TextSize = 12,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 0, 16), Position = UDim2.new(0, 8, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })
    local pct = Utils:Create("TextLabel", {
        Name = "Percent", Text = "0%", Font = t.FontBold, TextSize = 11,
        TextColor3 = t.Primary, BackgroundTransparency = 1,
        Size = UDim2.new(0, 40, 0, 16), Position = UDim2.new(1, -44, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right, Parent = base,
    })
    local track = Utils:Create("Frame", {
        Name = "Track", BackgroundColor3 = t.Border, BorderSizePixel = 0,
        Size = UDim2.new(1, -16, 0, 6), Position = UDim2.new(0, 8, 0, 22), Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})
    local fill = Utils:Create("Frame", {
        Name = "Fill", BackgroundColor3 = t.Primary, BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0), Parent = track,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})

    local val = c.Value or 0
    local function set(v)
        val = math.clamp(v, 0, 100)
        fill.Size = UDim2.new(val / 100, 0, 1, 0)
        pct.Text = math.floor(val) .. "%"
    end
    set(val)
    return {Instance = base, Get = function() return val end, Set = function(_, v) set(v) end}
end

-- 13. SearchBar
function Components:SearchBar(c)
    local t = Theme:Get()
    local cb = c.Callback or function() end
    local base = self:Base("SearchBar", c.Parent, 36)
    base.BackgroundColor3 = t.Background

    local icon = Utils:Create("TextLabel", {
        Name = "Icon", Text = "🔍", Font = t.Font, TextSize = 12,
        TextColor3 = t.TextMuted, BackgroundTransparency = 1,
        Size = UDim2.new(0, 24, 1, 0), Position = UDim2.new(0, 8, 0, 0), Parent = base,
    })
    local box = Utils:Create("TextBox", {
        Name = "Box", Text = "", PlaceholderText = c.Placeholder or "Search...",
        Font = t.Font, TextSize = 12, TextColor3 = t.TextPrimary,
        PlaceholderColor3 = t.TextMuted, BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 32, 0, 0),
        Parent = base,
    })
    local stroke = Utils:Create("UIStroke", {Color = t.Border, Thickness = 1, Parent = base})

    box:GetPropertyChangedSignal("Text"):Connect(function() cb(box.Text) end)
    box.Focused:Connect(function() Anim:Tween(stroke, {Color = t.Primary}, 0.2) end)
    box.FocusLost:Connect(function() Anim:Tween(stroke, {Color = t.Border}, 0.2) end)
    return {Instance = base, Get = function() return box.Text end, Set = function(_, txt) box.Text = txt end}
end

-- 14. Collapsible (Accordion)
function Components:Collapsible(c)
    local t = Theme:Get()
    local base = self:Base("Collapsible", c.Parent, 36)
    base.AutomaticSize = Enum.AutomaticSize.Y

    local header = Utils:Create("TextButton", {
        Name = "Header", Text = "   " .. (c.Text or "Section"), Font = t.FontBold, TextSize = 13,
        TextColor3 = t.TextPrimary, BackgroundColor3 = t.Foreground, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36), TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, t.CornerRadius - 2), Parent = header})

    local arrow = Utils:Create("TextLabel", {
        Name = "Arrow", Text = "▶", Font = t.Font, TextSize = 11,
        TextColor3 = t.TextMuted, BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -26, 0.5, -10), Parent = header,
    })

    local content = Utils:Create("Frame", {
        Name = "Content", BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 36),
        ClipsDescendants = true, Parent = base,
    })
    local layout = Utils:Create("UIListLayout", {Padding = UDim.new(0, 6), Parent = content})
    Utils:Create("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = content})

    local open = false
    header.MouseButton1Click:Connect(function()
        open = not open
        if open then
            Anim:Tween(arrow, {Rotation = 90}, 0.2)
            Anim:Tween(content, {Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 12)}, 0.3)
        else
            Anim:Tween(arrow, {Rotation = 0}, 0.2)
            Anim:Tween(content, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        end
    end)

    return {
        Instance = base,
        CreateLabel = function(_, cfg) cfg = cfg or {}; cfg.Parent = content; return Components:Label(cfg) end,
        CreateButton = function(_, cfg) cfg = cfg or {}; cfg.Parent = content; return Components:Button(cfg) end,
        CreateToggle = function(_, cfg) cfg = cfg or {}; cfg.Parent = content; return Components:Toggle(cfg) end,
        CreateSlider = function(_, cfg) cfg = cfg or {}; cfg.Parent = content; return Components:Slider(cfg) end,
        CreateInput = function(_, cfg) cfg = cfg or {}; cfg.Parent = content; return Components:Input(cfg) end,
    }
end

-- 15. Divider
function Components:Divider(c)
    local t = Theme:Get()
    local base = Utils:Create("Frame", {
        Name = "Divider", BackgroundTransparency = 1,
        Size = UDim2.new(1, -16, 0, c.Text and 28 or 14), Position = UDim2.new(0, 8, 0, 0), Parent = c.Parent,
    })
    if c.Text then
        Utils:Create("Frame", {BackgroundColor3 = t.Border, BorderSizePixel = 0, Size = UDim2.new(0.5, -45, 0, 1), Position = UDim2.new(0, 0, 0.5, 0), Parent = base})
        Utils:Create("Frame", {BackgroundColor3 = t.Border, BorderSizePixel = 0, Size = UDim2.new(0.5, -45, 0, 1), Position = UDim2.new(0.5, 45, 0.5, 0), Parent = base})
        Utils:Create("TextLabel", {Text = c.Text, Font = t.FontMedium, TextSize = 11, TextColor3 = t.TextMuted, BackgroundTransparency = 1, Size = UDim2.new(0, 90, 1, 0), Position = UDim2.new(0.5, -45, 0, 0), Parent = base})
    else
        Utils:Create("Frame", {BackgroundColor3 = t.Border, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0.5, 0), Parent = base})
    end
    return {Instance = base}
end

-- 16. ImageButton
function Components:ImageButton(c)
    local t = Theme:Get()
    local cb = c.Callback or function() end
    local base = self:Base("ImageButton", c.Parent, 42)

    local img = Utils:Create("ImageButton", {
        Name = "Image", Image = c.Image or "", BackgroundTransparency = 1,
        Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(0, 8, 0.5, -14), Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = img})

    local lbl = Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "", Font = t.Font, TextSize = 13,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -48, 1, 0), Position = UDim2.new(0, 42, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })

    local hover = Utils:Create("Frame", {
        Name = "Hover", BackgroundColor3 = t.Primary, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 2, Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, t.CornerRadius - 2), Parent = hover})

    local hov = false
    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            hov = true; Anim:Tween(hover, {BackgroundTransparency = 0.92}, 0.2)
            Anim:Tween(base, {BackgroundColor3 = t.Surface}, 0.2)
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = UserInputService:GetMouseLocation()
            Utils:Ripple(base, pos.X, pos.Y, t.Primary)
            cb()
        end
    end)
    base.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            hov = false; Anim:Tween(hover, {BackgroundTransparency = 1}, 0.2)
            Anim:Tween(base, {BackgroundColor3 = t.Foreground}, 0.2)
        end
    end)
    return {Instance = base}
end

-- 17. StatBar (HP/Mana style)
function Components:StatBar(c)
    local t = Theme:Get()
    local base = self:Base("StatBar", c.Parent, 40)
    base.BackgroundTransparency = 1

    Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "Stat", Font = t.Font, TextSize = 12,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 0, 16), Position = UDim2.new(0, 8, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })
    local valLbl = Utils:Create("TextLabel", {
        Name = "Value", Text = (c.Value or 0) .. "/" .. (c.Max or 100), Font = t.FontBold, TextSize = 11,
        TextColor3 = t.TextSecondary, BackgroundTransparency = 1,
        Size = UDim2.new(0, 60, 0, 16), Position = UDim2.new(1, -64, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right, Parent = base,
    })
    local track = Utils:Create("Frame", {
        Name = "Track", BackgroundColor3 = t.Border, BorderSizePixel = 0,
        Size = UDim2.new(1, -16, 0, 8), Position = UDim2.new(0, 8, 0, 22), Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})
    local fill = Utils:Create("Frame", {
        Name = "Fill", BackgroundColor3 = c.Color or t.Primary, BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0), Parent = track,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})

    local val, max = c.Value or 0, c.Max or 100
    local function set(v, m)
        val = v or val; max = m or max
        local s = math.clamp(val / max, 0, 1)
        fill.Size = UDim2.new(s, 0, 1, 0)
        valLbl.Text = val .. "/" .. max
    end
    set(val, max)
    return {Instance = base, Get = function() return val, max end, Set = function(_, v, m) set(v, m) end}
end

-- 18. Bind (Rayfield-style bind with hold mode)
function Components:Bind(c)
    local t = Theme:Get()
    local cb = c.Callback or function() end
    local hold = c.Hold or false
    local base = self:Base("Bind", c.Parent, 40)

    Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "Bind", Font = t.Font, TextSize = 13,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -80, 1, 0), Position = UDim2.new(0, 10, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })
    local keyLbl = Utils:Create("TextLabel", {
        Name = "Key", Text = (c.Default and c.Default.Name) or "NONE",
        Font = t.FontBold, TextSize = 11, TextColor3 = t.Primary,
        BackgroundColor3 = t.Background, BorderSizePixel = 0,
        Size = UDim2.new(0, 55, 0, 24), Position = UDim2.new(1, -65, 0.5, -12), Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = keyLbl})
    local stroke = Utils:Create("UIStroke", {Color = t.Border, Thickness = 1, Parent = keyLbl})

    local listening = false
    local curKey = c.Default

    local function listen()
        listening = true
        keyLbl.Text = "..."
        Anim:Tween(stroke, {Color = t.Primary}, 0.2)
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode ~= Enum.KeyCode.Escape then
                    curKey = input.KeyCode
                    keyLbl.Text = input.KeyCode.Name
                    cb(input.KeyCode, false)
                end
                listening = false
                Anim:Tween(stroke, {Color = t.Border}, 0.2)
                conn:Disconnect()
            end
        end)
    end

    keyLbl.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not listening then listen() end
    end)

    if hold then
        UserInputService.InputBegan:Connect(function(input)
            if curKey and input.KeyCode == curKey and not listening then cb(curKey, true) end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if curKey and input.KeyCode == curKey and not listening then cb(curKey, false) end
        end)
    else
        UserInputService.InputBegan:Connect(function(input)
            if curKey and input.KeyCode == curKey and not listening then cb(curKey, false) end
        end)
    end

    return {Instance = base, Get = function() return curKey end, Set = function(_, k) curKey = k; keyLbl.Text = k and k.Name or "NONE" end}
end

-- 19. Chip (Tag/Badge)
function Components:Chip(c)
    local t = Theme:Get()
    local base = Utils:Create("Frame", {
        Name = "Chip", BackgroundColor3 = c.Color or t.Primary, BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 0, 24), AutomaticSize = Enum.AutomaticSize.X, Parent = c.Parent,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = base})
    Utils:Create("UIPadding", {PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = base})

    local lbl = Utils:Create("TextLabel", {
        Name = "Text", Text = c.Text or "Chip", Font = t.FontMedium, TextSize = 11,
        TextColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Parent = base,
    })
    return {Instance = base, Set = function(_, txt) lbl.Text = txt end}
end

-- ═══ NOTIFICATIONS ═══
local NotifSys = {}

function NotifSys:Init(parent)
    self.Container = Utils:Create("Frame", {
        Name = "Notifications", BackgroundTransparency = 1,
        Size = UDim2.new(0, 300, 1, -20), Position = UDim2.new(1, -320, 0, 10), Parent = parent,
    })
    Utils:Create("UIListLayout", {Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Top, Parent = self.Container})
end

function NotifSys:Notify(c)
    local t = Theme:Get()
    local title = c.Title or "Notification"
    local content = c.Content or ""
    local dur = c.Duration or 4
    local ntype = c.Type or "Info"
    local colors = {Info = t.Info, Success = t.Success, Warning = t.Warning, Error = t.Error}
    local icons = {Info = "ℹ", Success = "✓", Warning = "⚠", Error = "✕"}

    local notif = Utils:Create("Frame", {
        Name = "Notif", BackgroundColor3 = t.Surface, BorderSizePixel = 0,
        Size = UDim2.new(0, 280, 0, 0), ClipsDescendants = true, Parent = self.Container,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, t.CornerRadius), Parent = notif})
    Utils:Create("UIStroke", {Color = colors[ntype] or t.Primary, Thickness = 1.5, Parent = notif})

    local accent = Utils:Create("Frame", {
        Name = "Accent", BackgroundColor3 = colors[ntype] or t.Primary, BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0), Parent = notif,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = accent})

    Utils:Create("TextLabel", {
        Name = "Icon", Text = icons[ntype] or "ℹ", Font = t.FontBold, TextSize = 16,
        TextColor3 = colors[ntype] or t.Primary, BackgroundTransparency = 1,
        Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, 12, 0, 8), Parent = notif,
    })
    Utils:Create("TextLabel", {
        Name = "Title", Text = title, Font = t.FontBold, TextSize = 13,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -60, 0, 20), Position = UDim2.new(0, 40, 0, 8),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = notif,
    })
    local cont = Utils:Create("TextLabel", {
        Name = "Content", Text = content, Font = t.Font, TextSize = 12,
        TextColor3 = t.TextSecondary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 0, 20), Position = UDim2.new(0, 40, 0, 28),
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = notif,
    })
    local close = Utils:Create("TextButton", {
        Name = "Close", Text = "✕", Font = t.FontBold, TextSize = 12,
        TextColor3 = t.TextMuted, BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -24, 0, 6), Parent = notif,
    })

    local h = math.max(55, 32 + cont.TextBounds.Y)
    Anim:Tween(notif, {Size = UDim2.new(0, 280, 0, h)}, 0.35, Enum.EasingStyle.Back)

    local function dismiss()
        Anim:Tween(notif, {Size = UDim2.new(0, 280, 0, 0)}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In, function()
            notif:Destroy()
        end)
    end
    close.MouseButton1Click:Connect(dismiss)
    if dur > 0 then task.delay(dur, dismiss) end
    return notif
end

-- ═══ ICON TOGGLE SYSTEM ═══
local IconToggle = {}

function IconToggle:Create(parent, theme, onToggle)
    local t = theme or Theme:Get()

    local iconBtn = Utils:Create("ImageButton", {
        Name = "IconToggle", BackgroundColor3 = t.Primary, BorderSizePixel = 0,
        Size = UDim2.new(0, 44, 0, 44), Position = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://7733965380",
        ImageColor3 = Color3.fromRGB(255,255,255),
        ZIndex = 100,
        Parent = parent,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = iconBtn})
    Utils:Create("UIStroke", {Color = Color3.fromRGB(255,255,255), Thickness = 2, Transparency = 0.3, Parent = iconBtn})

    local shadow = Utils:Create("ImageLabel", {
        Name = "Shadow", BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805", ImageColor3 = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.4, ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        Size = UDim2.new(1, 16, 1, 16), Position = UDim2.new(0, -8, 0, -8),
        ZIndex = 99, Parent = iconBtn,
    })

    local pulse = Utils:Create("Frame", {
        Name = "Pulse", BackgroundColor3 = t.Primary, BackgroundTransparency = 0.7,
        Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 98, Parent = iconBtn,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = pulse})

    local pulsing = true
    local function doPulse()
        if not pulsing then return end
        Anim:Tween(pulse, {Size = UDim2.new(1.4, 0, 1.4, 0), Position = UDim2.new(-0.2, 0, -0.2, 0), BackgroundTransparency = 1}, 1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, function()
            pulse.Size = UDim2.new(1, 0, 1, 0)
            pulse.Position = UDim2.new(0, 0, 0, 0)
            pulse.BackgroundTransparency = 0.7
            task.delay(0.5, doPulse)
        end)
    end
    doPulse()

    Utils:MakeDraggable(iconBtn, iconBtn)

    iconBtn.MouseButton1Click:Connect(function()
        Utils:Ripple(iconBtn, iconBtn.AbsolutePosition.X + 22, iconBtn.AbsolutePosition.Y + 22, Color3.fromRGB(255,255,255))
        onToggle()
    end)

    iconBtn.MouseEnter:Connect(function()
        Anim:Tween(iconBtn, {Size = UDim2.new(0, 48, 0, 48)}, 0.2, Enum.EasingStyle.Back)
    end)
    iconBtn.MouseLeave:Connect(function()
        Anim:Tween(iconBtn, {Size = UDim2.new(0, 44, 0, 44)}, 0.2, Enum.EasingStyle.Back)
    end)

    return {
        Instance = iconBtn,
        SetImage = function(_, img) iconBtn.Image = img end,
        SetVisible = function(_, vis) iconBtn.Visible = vis end,
        Destroy = function() iconBtn:Destroy() end,
    }
end

-- ═══ KEY SYSTEM ═══
local KeySystem = {}

function KeySystem:Create(parent, config, onSuccess)
    local t = Theme:Get()
    local cfg = config or {}
    local title = cfg.Title or "Key System"
    local subtitle = cfg.Subtitle or "Enter your key to continue"
    local keys = cfg.Keys or {}
    local link = cfg.Link or ""
    local saveFile = cfg.SaveFile or false
    local fileName = cfg.FileName or "KeySystem_Save"

    local sg = parent

    local overlay = Utils:Create("Frame", {
        Name = "KeyOverlay", BackgroundColor3 = t.Background, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 1, 0), ZIndex = 200, Parent = sg,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = overlay})

    local container = Utils:Create("Frame", {
        Name = "KeyContainer", BackgroundTransparency = 1,
        Size = UDim2.new(0, 320, 0, 220), Position = UDim2.new(0.5, -160, 0.5, -110), Parent = overlay,
    })

    local icon = Utils:Create("TextLabel", {
        Name = "Icon", Text = "🔐", Font = t.FontBold, TextSize = 32,
        TextColor3 = t.Primary, BackgroundTransparency = 1,
        Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0.5, -25, 0, 0), Parent = container,
    })

    local titleLbl = Utils:Create("TextLabel", {
        Name = "Title", Text = title, Font = t.FontBold, TextSize = 18,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24), Position = UDim2.new(0, 0, 0, 55), Parent = container,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local subLbl = Utils:Create("TextLabel", {
        Name = "Subtitle", Text = subtitle, Font = t.Font, TextSize = 12,
        TextColor3 = t.TextSecondary, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 80), Parent = container,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local box = Utils:Create("TextBox", {
        Name = "KeyBox", Text = "", PlaceholderText = "Enter Key...",
        Font = t.Font, TextSize = 13, TextColor3 = t.TextPrimary,
        PlaceholderColor3 = t.TextMuted, BackgroundColor3 = t.Foreground,
        BorderSizePixel = 0, Size = UDim2.new(1, -40, 0, 36),
        Position = UDim2.new(0, 20, 0, 110), Parent = container,
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = box})
    local stroke = Utils:Create("UIStroke", {Color = t.Border, Thickness = 1, Parent = box})

    local submit = Utils:Create("TextButton", {
        Name = "Submit", Text = "Submit Key", Font = t.FontBold, TextSize = 13,
        TextColor3 = Color3.fromRGB(255,255,255), BackgroundColor3 = t.Primary, BorderSizePixel = 0,
        Size = UDim2.new(1, -40, 0, 36), Position = UDim2.new(0, 20, 0, 155), Parent = container,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = submit})

    local linkBtn
    if link ~= "" then
        linkBtn = Utils:Create("TextButton", {
            Name = "GetKey", Text = "Get Key", Font = t.Font, TextSize = 11,
            TextColor3 = t.Info, BackgroundTransparency = 1,
            Size = UDim2.new(0, 80, 0, 20), Position = UDim2.new(0.5, -40, 0, 195), Parent = container,
        })
        linkBtn.MouseButton1Click:Connect(function()
            if setclipboard then setclipboard(link) end
            NotifSys:Notify({Title = "Copied!", Content = "Key link copied to clipboard", Type = "Info", Duration = 3})
        end)
    end

    local statusLbl = Utils:Create("TextLabel", {
        Name = "Status", Text = "", Font = t.Font, TextSize = 11,
        TextColor3 = t.Error, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 90), Parent = container,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    box.Focused:Connect(function() Anim:Tween(stroke, {Color = t.Primary}, 0.2) end)
    box.FocusLost:Connect(function() Anim:Tween(stroke, {Color = t.Border}, 0.2) end)

    local function validate(key)
        for _, k in ipairs(keys) do
            if key == k then return true end
        end
        return false
    end

    local function trySubmit()
        local key = box.Text:gsub("%s+", "")
        if key == "" then
            statusLbl.Text = "Please enter a key"
            return
        end
        if validate(key) then
            statusLbl.TextColor3 = t.Success
            statusLbl.Text = "Key accepted!"
            if saveFile and writefile then
                pcall(function() writefile(fileName .. ".txt", key) end)
            end
            task.delay(0.5, function()
                Anim:Tween(overlay, {BackgroundTransparency = 1}, 0.3, nil, nil, function()
                    overlay:Destroy()
                end)
                onSuccess()
            end)
        else
            statusLbl.TextColor3 = t.Error
            statusLbl.Text = "Invalid key!"
            Anim:Tween(box, {Position = UDim2.new(0, 15, 0, 110)}, 0.05, nil, nil, function()
                Anim:Tween(box, {Position = UDim2.new(0, 25, 0, 110)}, 0.05, nil, nil, function()
                    Anim:Tween(box, {Position = UDim2.new(0, 20, 0, 110)}, 0.05)
                end)
            end)
        end
    end

    submit.MouseButton1Click:Connect(trySubmit)
    box.FocusLost:Connect(function(enter) if enter then trySubmit() end end)

    -- Auto-load saved key
    if saveFile and readfile and isfile then
        pcall(function()
            if isfile(fileName .. ".txt") then
                local saved = readfile(fileName .. ".txt"):gsub("%s+", "")
                if validate(saved) then
                    box.Text = saved
                    trySubmit()
                end
            end
        end)
    end

    return {
        Instance = overlay,
        Destroy = function() overlay:Destroy() end,
    }
end

-- ═══ MAIN WINDOW ═══
function Library:CreateWindow(c)
    c = c or {}
    local t = Theme:Set(c.Theme or "Default")

    local name = c.Name or "GUI Library"
    local keybind = c.Keybind or Enum.KeyCode.RightShift
    local useIcon = c.UseIconToggle ~= false
    local iconImage = c.IconImage or "rbxassetid://7733965380"

    -- Status Label Config
    local statusConfig = c.StatusLabel or {}
    local showStatus = statusConfig.Enabled ~= false
    local statusText = statusConfig.Text or "PREMIUM"
    local statusColor = statusConfig.Color or t.Primary
    local statusBg = statusConfig.Background or t.Surface

    -- Key System Config
    local keyConfig = c.KeySystem or {}
    local useKey = keyConfig.Enabled == true

    -- ScreenGui
    local sg = Utils:Create("ScreenGui", {
        Name = name .. "_GUI", ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ResetOnSpawn = false,
    })

    local function safeParent()
        if syn and syn.protect_gui then
            syn.protect_gui(sg); sg.Parent = CoreGui
        elseif gethui then
            sg.Parent = gethui()
        elseif CoreGui then
            sg.Parent = CoreGui
        else
            sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
    end
    safeParent()

    -- Main Frame (520x360)
    local mf = Utils:Create("Frame", {
        Name = "Main", BackgroundColor3 = t.Background, BorderSizePixel = 0,
        Size = UDim2.new(0, 520, 0, 360), Position = UDim2.new(0.5, -260, 0.5, -180),
        ClipsDescendants = true, Parent = sg, Visible = not useKey,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = mf})

    -- Shadow
    Utils:Create("ImageLabel", {
        Name = "Shadow", BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805", ImageColor3 = Color3.fromRGB(0,0,0),
        ImageTransparency = 0.55, ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        Size = UDim2.new(1, 36, 1, 36), Position = UDim2.new(0, -18, 0, -18),
        ZIndex = 0, Parent = mf,
    })

    -- Title Bar
    local tb = Utils:Create("Frame", {
        Name = "TitleBar", BackgroundColor3 = t.Foreground, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38), Parent = mf,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 14), Parent = tb})
    Utils:Create("Frame", {BackgroundColor3 = t.Foreground, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14), Parent = tb})

    -- Title
    local titleLbl = Utils:Create("TextLabel", {
        Name = "Title", Text = name, Font = t.FontBold, TextSize = 15,
        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -180, 1, 0), Position = UDim2.new(0, 14, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = tb,
    })

    -- Status Label (Premium/Free/etc)
    local statusChip
    if showStatus then
        statusChip = Utils:Create("Frame", {
            Name = "StatusChip", BackgroundColor3 = statusBg, BorderSizePixel = 0,
            Size = UDim2.new(0, 0, 0, 18), AutomaticSize = Enum.AutomaticSize.X,
            Position = UDim2.new(0, 14 + titleLbl.TextBounds.X + 8, 0.5, -9), Parent = tb,
        })
        Utils:Create("UICorner", {CornerRadius = UDim.new(0, 9), Parent = statusChip})
        Utils:Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = statusChip})
        Utils:Create("UIStroke", {Color = statusColor, Thickness = 1, Parent = statusChip})

        local statusLbl = Utils:Create("TextLabel", {
            Name = "StatusText", Text = statusText, Font = t.FontBold, TextSize = 10,
            TextColor3 = statusColor, BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, Parent = statusChip,
        })

        -- Update position when title changes
        titleLbl:GetPropertyChangedSignal("TextBounds"):Connect(function()
            statusChip.Position = UDim2.new(0, 14 + titleLbl.TextBounds.X + 8, 0.5, -9)
        end)
    end

    -- Window controls
    local closeBtn = Utils:Create("TextButton", {
        Name = "Close", Text = "", BackgroundColor3 = t.Error, BorderSizePixel = 0,
        Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -30, 0.5, -6), Parent = tb,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = closeBtn})

    local minBtn = Utils:Create("TextButton", {
        Name = "Minimize", Text = "", BackgroundColor3 = t.Warning, BorderSizePixel = 0,
        Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(1, -50, 0.5, -6), Parent = tb,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = minBtn})

    -- Sidebar
    local sb = Utils:Create("Frame", {
        Name = "Sidebar", BackgroundColor3 = t.Foreground, BorderSizePixel = 0,
        Size = UDim2.new(0, 140, 1, -38), Position = UDim2.new(0, 0, 0, 38), Parent = mf,
    })
    Utils:Create("UIListLayout", {Padding = UDim.new(0, 3), Parent = sb})
    Utils:Create("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = sb})

    -- Content
    local cf = Utils:Create("Frame", {
        Name = "Content", BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, -150, 1, -46), Position = UDim2.new(0, 145, 0, 42),
        ClipsDescendants = true, Parent = mf,
    })
    Utils:Create("UIListLayout", {Padding = UDim.new(0, 6), Parent = cf})
    Utils:Create("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8), Parent = cf})

    -- Draggable
    Utils:MakeDraggable(mf, tb)

    -- State
    local tabs = {}
    local curTab = nil
    local minimized = false
    local closed = false
    local originalSize = mf.Size
    local originalPos = mf.Position

    -- Icon Toggle
    local iconToggle
    if useIcon then
        iconToggle = IconToggle:Create(sg, t, function()
            if closed then
                closed = false
                mf.Visible = true
                mf.Size = UDim2.new(0, 0, 0, 0)
                mf.BackgroundTransparency = 1
                Anim:Spring(mf, {Size = originalSize, BackgroundTransparency = 0}, 0.5)
                iconToggle:SetVisible(false)
            elseif minimized then
                minimized = false
                Anim:Tween(mf, {Size = originalSize, Position = originalPos}, 0.35, Enum.EasingStyle.Back)
            else
                minimized = true
                Anim:Tween(mf, {Size = UDim2.new(0, 520, 0, 38)}, 0.3, Enum.EasingStyle.Quart)
            end
        end)
        iconToggle:SetVisible(false)
    end

    -- Minimize button
    minBtn.MouseButton1Click:Connect(function()
        if minimized then
            minimized = false
            Anim:Tween(mf, {Size = originalSize, Position = originalPos}, 0.35, Enum.EasingStyle.Back)
            if iconToggle then iconToggle:SetVisible(false) end
        else
            minimized = true
            Anim:Tween(mf, {Size = UDim2.new(0, 520, 0, 38)}, 0.3, Enum.EasingStyle.Quart)
            if iconToggle then
                task.delay(0.35, function()
                    if minimized then iconToggle:SetVisible(true) end
                end)
            end
        end
    end)

    -- Close button
    closeBtn.MouseButton1Click:Connect(function()
        closed = true
        Anim:Tween(mf, {Size = UDim2.new(0, 0, 0, 0)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
            mf.Visible = false
            if iconToggle then iconToggle:SetVisible(true) end
        end)
    end)

    -- Keybind
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == keybind then
            if closed then
                closed = false; mf.Visible = true
                mf.Size = UDim2.new(0, 0, 0, 0); mf.BackgroundTransparency = 1
                Anim:Spring(mf, {Size = originalSize, BackgroundTransparency = 0}, 0.5)
                if iconToggle then iconToggle:SetVisible(false) end
            elseif minimized then
                minimized = false
                Anim:Tween(mf, {Size = originalSize, Position = originalPos}, 0.35, Enum.EasingStyle.Back)
                if iconToggle then iconToggle:SetVisible(false) end
            else
                sg.Enabled = not sg.Enabled
            end
        end
    end)

    -- Notifications
    NotifSys:Init(sg)

    -- Key System
    if useKey then
        KeySystem:Create(sg, keyConfig, function()
            mf.Visible = true
            mf.Size = UDim2.new(0, 0, 0, 0)
            mf.BackgroundTransparency = 1
            Anim:Spring(mf, {Size = UDim2.new(0, 520, 0, 360), BackgroundTransparency = 0}, 0.55)
        end)
    end

    -- Window API
    local window = {
        ScreenGui = sg,
        MainFrame = mf,

        CreateTab = function(_, tc)
            tc = tc or {}
            local tname = tc.Name or "Tab"
            local ticon = tc.Icon or nil

            local btn = Utils:Create("TextButton", {
                Name = tname .. "_Tab", Text = "      " .. tname,
                Font = t.FontMedium, TextSize = 12, TextColor3 = t.TextSecondary,
                BackgroundColor3 = t.Background, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 32), Parent = sb,
            })
            Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})

            local ind = Utils:Create("Frame", {
                Name = "Ind", BackgroundColor3 = t.Primary, BorderSizePixel = 0,
                Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5), Parent = btn,
            })
            Utils:Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = ind})

            -- Tab icon
            if ticon then
                local iconImg = Utils:Create("ImageLabel", {
                    Name = "Icon", Image = ticon, BackgroundTransparency = 1,
                    Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 10, 0.5, -8), Parent = btn,
                })
            end

            local content = Utils:Create("ScrollingFrame", {
                Name = tname .. "_Content", BackgroundTransparency = 1, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 3,
                ScrollBarImageColor3 = t.Primary, Visible = false, Parent = cf,
            })
            Utils:Create("UIListLayout", {Padding = UDim.new(0, 6), Parent = content})
            Utils:Create("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8), Parent = content})

            local tab = {
                Name = tname, Button = btn, Content = content,

                CreateSection = function(_, sc)
                    sc = sc or {}
                    local sname = sc.Name or "Section"

                    local sf = Utils:Create("Frame", {
                        Name = sname, BackgroundColor3 = t.Foreground, BorderSizePixel = 0,
                        Size = UDim2.new(1, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = content,
                    })
                    Utils:Create("UICorner", {CornerRadius = UDim.new(0, t.CornerRadius - 2), Parent = sf})

                    Utils:Create("TextLabel", {
                        Name = "Title", Text = sname, Font = t.FontBold, TextSize = 13,
                        TextColor3 = t.TextPrimary, BackgroundTransparency = 1,
                        Size = UDim2.new(1, -16, 0, 26), Position = UDim2.new(0, 10, 0, 6),
                        TextXAlignment = Enum.TextXAlignment.Left, Parent = sf,
                    })

                    local scnt = Utils:Create("Frame", {
                        Name = "Content", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.new(0, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.Y, Parent = sf,
                    })
                    Utils:Create("UIListLayout", {Padding = UDim.new(0, 5), Parent = scnt})
                    Utils:Create("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4), PaddingBottom = UDim.new(0, 8), Parent = scnt})

                    scnt:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        sf.Size = UDim2.new(1, -8, 0, scnt.AbsoluteContentSize.Y + 38)
                    end)

                    return {
                        Instance = sf,
                        CreateLabel = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:Label(cfg) end,
                        CreateParagraph = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:Paragraph(cfg) end,
                        CreateButton = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:Button(cfg) end,
                        CreateToggle = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:Toggle(cfg) end,
                        CreateSlider = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:Slider(cfg) end,
                        CreateDropdown = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:Dropdown(cfg) end,
                        CreateMultiDropdown = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:MultiDropdown(cfg) end,
                        CreateInput = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:Input(cfg) end,
                        CreateNumberInput = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:NumberInput(cfg) end,
                        CreateKeybind = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:Keybind(cfg) end,
                        CreateBind = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:Bind(cfg) end,
                        CreateColorPicker = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:ColorPicker(cfg) end,
                        CreateProgressBar = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:ProgressBar(cfg) end,
                        CreateSearchBar = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:SearchBar(cfg) end,
                        CreateCollapsible = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:Collapsible(cfg) end,
                        CreateDivider = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:Divider(cfg) end,
                        CreateImageButton = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:ImageButton(cfg) end,
                        CreateStatBar = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:StatBar(cfg) end,
                        CreateChip = function(_, cfg) cfg = cfg or {}; cfg.Parent = scnt; return Components:Chip(cfg) end,
                    }
                end,
            }

            btn.MouseButton1Click:Connect(function()
                if curTab == tab then return end
                if curTab then
                    Anim:Tween(curTab.Button, {BackgroundColor3 = t.Background}, 0.2)
                    curTab.Button.TextColor3 = t.TextSecondary
                    curTab.Button.Ind.Size = UDim2.new(0, 3, 0, 0)
                    curTab.Content.Visible = false
                end
                curTab = tab
                Anim:Tween(btn, {BackgroundColor3 = t.Surface}, 0.2)
                btn.TextColor3 = t.TextPrimary
                Anim:Tween(ind, {Size = UDim2.new(0, 3, 0, 18)}, 0.3, Enum.EasingStyle.Back)
                content.Visible = true
            end)

            content:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                content.CanvasSize = UDim2.new(0, 0, 0, content.AbsoluteContentSize.Y + 16)
            end)

            table.insert(tabs, tab)
            if #tabs == 1 then btn.MouseButton1Click:Fire() end
            return tab
        end,

        Notify = function(_, nc) return NotifSys:Notify(nc) end,
        Destroy = function() sg:Destroy() end,
        SetTheme = function(_, name) Theme:Set(name) end,
        GetThemes = function() return Theme:GetAllNames() end,
        SetStatus = function(_, txt, col)
            if statusChip then
                local lbl = statusChip:FindFirstChild("StatusText")
                if lbl then lbl.Text = txt end
                if col then
                    statusChip:FindFirstChildOfClass("UIStroke").Color = col
                    lbl.TextColor3 = col
                end
            end
        end,
    }

    -- Entrance
    if not useKey then
        mf.Size = UDim2.new(0, 0, 0, 0)
        mf.BackgroundTransparency = 1
        Anim:Spring(mf, {Size = UDim2.new(0, 520, 0, 360), BackgroundTransparency = 0}, 0.55)
    end

    return window
end

return Library
