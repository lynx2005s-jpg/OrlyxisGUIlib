--[[
    ============================================
    Roblox UI Library - Executor Edition
    ============================================
    A modular, themeable, and animated UI library 
    designed for Roblox script executors.

    GitHub: (Your Repo Here)
    Version: 2.0

    Components:
    - Frame, Button, Label, Input, Toggle, Slider, Dropdown
    - ColorPicker, Notification, Window, TabSystem, SubTabSystem
    - KeySystem (Free/Premium/Custom tiers)
    - Console, ScriptHub, Keybind, CodeEditor, Section

    Usage:
        local UI = require(path.to.UILibrary)
        local screen = UI:CreateScreenGui("MyUI")
        -- See examples at bottom of file
--]]

local UILibrary = {}

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

-- ============================================
-- THEME SYSTEM
-- ============================================
UILibrary.Theme = {
    Colors = {
        Primary = Color3.fromRGB(88, 101, 242),
        Secondary = Color3.fromRGB(47, 49, 54),
        Background = Color3.fromRGB(32, 34, 37),
        Surface = Color3.fromRGB(54, 57, 63),
        Text = Color3.fromRGB(255, 255, 255),
        TextMuted = Color3.fromRGB(185, 187, 190),
        Success = Color3.fromRGB(59, 165, 93),
        Warning = Color3.fromRGB(250, 168, 26),
        Error = Color3.fromRGB(237, 66, 69),
        Border = Color3.fromRGB(32, 34, 37),
    },
    Frame = {
        BackgroundColor3 = Color3.fromRGB(54, 57, 63),
        BorderSizePixel = 0,
        CornerRadius = UDim.new(0, 8),
    },
    Button = {
        BackgroundColor3 = Color3.fromRGB(88, 101, 242),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        CornerRadius = UDim.new(0, 6),
    },
    Label = {
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
    },
    Input = {
        BackgroundColor3 = Color3.fromRGB(32, 34, 37),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.Gotham,
        TextSize = 14,
        BorderSizePixel = 0,
        PlaceholderColor3 = Color3.fromRGB(185, 187, 190),
        ClearTextOnFocus = false,
        CornerRadius = UDim.new(0, 6),
    },
    Toggle = {
        BackgroundColor3 = Color3.fromRGB(47, 49, 54),
        BorderSizePixel = 0,
        CornerRadius = UDim.new(1, 0),
    },
    Slider = {
        BackgroundColor3 = Color3.fromRGB(47, 49, 54),
        BorderSizePixel = 0,
        CornerRadius = UDim.new(0, 4),
        FillColor = Color3.fromRGB(88, 101, 242),
    },
    Dropdown = {
        BackgroundColor3 = Color3.fromRGB(54, 57, 63),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        CornerRadius = UDim.new(0, 6),
    },
}

function UILibrary:ApplyTheme(instance, elementType)
    local theme = self.Theme[elementType]
    if not theme then return end
    for prop, value in pairs(theme) do
        if instance[prop] ~= nil then
            instance[prop] = value
        end
    end
end

-- ============================================
-- TWEEN UTILITY
-- ============================================
UILibrary.Tween = {
    Easings = {
        Smooth = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Bounce = TweenInfo.new(0.5, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out),
        Elastic = TweenInfo.new(0.5, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
        Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        Linear = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
    }
}

function UILibrary.Tween:Play(instance, tweenInfo, properties, callback)
    local tween = TweenService:Create(instance, tweenInfo or self.Easings.Smooth, properties)
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

function UILibrary.Tween:HoverEffect(button, hoverColor, defaultColor)
    local default = defaultColor or button.BackgroundColor3
    button.MouseEnter:Connect(function()
        self:Play(button, self.Easings.Fast, {BackgroundColor3 = hoverColor})
    end)
    button.MouseLeave:Connect(function()
        self:Play(button, self.Easings.Fast, {BackgroundColor3 = default})
    end)
end

function UILibrary.Tween:ClickEffect(button)
    local originalSize = button.Size
    self:Play(button, self.Easings.Fast, {
        Size = UDim2.new(originalSize.X.Scale * 0.95, originalSize.X.Offset * 0.95,
                         originalSize.Y.Scale * 0.95, originalSize.Y.Offset * 0.95)
    }, function()
        self:Play(button, self.Easings.Bounce, {Size = originalSize})
    end)
end

-- ============================================
-- CORE FUNCTIONS
-- ============================================
UILibrary.ActiveGuis = {}

function UILibrary:CreateScreenGui(name, properties)
    properties = properties or {}
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    local existing = playerGui:FindFirstChild(name)
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = name or "UI_" .. tostring(tick())
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = properties.IgnoreInset or true

    for prop, value in pairs(properties) do
        if prop ~= "IgnoreInset" then
            screenGui[prop] = value
        end
    end

    screenGui.Parent = playerGui
    table.insert(self.ActiveGuis, screenGui)
    return screenGui
end

function UILibrary:Cleanup()
    for _, gui in ipairs(self.ActiveGuis) do
        if gui and gui.Parent then
            gui:Destroy()
        end
    end
    self.ActiveGuis = {}
end

-- ============================================
-- COMPONENTS
-- ============================================

-- FRAME
function UILibrary:CreateFrame(parent, properties)
    properties = properties or {}
    local frame = Instance.new("Frame")
    frame.Name = properties.Name or "Frame"
    frame.Size = properties.Size or UDim2.new(0, 200, 0, 100)
    frame.Position = properties.Position or UDim2.new(0, 0, 0, 0)

    for prop, value in pairs(self.Theme.Frame) do
        if prop ~= "CornerRadius" then frame[prop] = value end
    end
    for prop, value in pairs(properties) do
        if prop ~= "Name" and prop ~= "CornerRadius" and prop ~= "Shadow" and prop ~= "Padding" and prop ~= "Layout" then
            frame[prop] = value
        end
    end

    local cornerRadius = properties.CornerRadius or self.Theme.Frame.CornerRadius
    if cornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = cornerRadius
        corner.Parent = frame
    end

    if properties.Shadow then
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://5554236805"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.6
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(23, 23, 277, 277)
        shadow.Size = UDim2.new(1, 20, 1, 20)
        shadow.Position = UDim2.new(0, -10, 0, -10)
        shadow.ZIndex = frame.ZIndex - 1
        shadow.Parent = frame
    end

    if properties.Padding then
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, properties.Padding)
        padding.PaddingRight = UDim.new(0, properties.Padding)
        padding.PaddingTop = UDim.new(0, properties.Padding)
        padding.PaddingBottom = UDim.new(0, properties.Padding)
        padding.Parent = frame
    end

    if properties.Layout then
        local layout = Instance.new(properties.Layout)
        if properties.Padding then layout.Padding = UDim.new(0, properties.Padding) end
        layout.Parent = frame
    end

    frame.Parent = parent
    return frame
end

-- BUTTON
function UILibrary:CreateButton(parent, properties)
    properties = properties or {}
    local button = Instance.new("TextButton")
    button.Name = properties.Name or "Button"
    button.Size = properties.Size or UDim2.new(0, 120, 0, 36)
    button.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    button.Text = properties.Text or "Button"

    for prop, value in pairs(self.Theme.Button) do
        if prop ~= "CornerRadius" then button[prop] = value end
    end
    for prop, value in pairs(properties) do
        if prop ~= "Name" and prop ~= "CornerRadius" and prop ~= "Callback" and prop ~= "HoverColor" and prop ~= "Icon" then
            button[prop] = value
        end
    end

    local cornerRadius = properties.CornerRadius or self.Theme.Button.CornerRadius
    if cornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = cornerRadius
        corner.Parent = button
    end

    local hoverColor = properties.HoverColor or self.Theme.Colors.Primary:Lerp(Color3.new(1,1,1), 0.2)
    self.Tween:HoverEffect(button, hoverColor, button.BackgroundColor3)

    button.MouseButton1Click:Connect(function()
        self.Tween:ClickEffect(button)
        if properties.Callback then properties.Callback() end
    end)

    if properties.Icon then
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.BackgroundTransparency = 1
        icon.Image = properties.Icon
        icon.Size = UDim2.new(0, 20, 0, 20)
        icon.Position = UDim2.new(0, 8, 0.5, -10)
        icon.Parent = button
        button.TextXAlignment = Enum.TextXAlignment.Left
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 32)
        pad.Parent = button
    end

    button.Parent = parent
    return button
end

-- LABEL
function UILibrary:CreateLabel(parent, properties)
    properties = properties or {}
    local label = Instance.new("TextLabel")
    label.Name = properties.Name or "Label"
    label.Size = properties.Size or UDim2.new(0, 200, 0, 20)
    label.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    label.Text = properties.Text or "Label"

    for prop, value in pairs(self.Theme.Label) do
        label[prop] = value
    end
    for prop, value in pairs(properties) do
        if prop ~= "Name" then label[prop] = value end
    end

    label.Parent = parent
    return label
end

-- INPUT
function UILibrary:CreateInput(parent, properties)
    properties = properties or {}
    local container = Instance.new("Frame")
    container.Name = properties.Name or "Input"
    container.Size = properties.Size or UDim2.new(0, 200, 0, 36)
    container.BackgroundTransparency = 1

    local bg = Instance.new("TextBox")
    bg.Name = "TextBox"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.PlaceholderText = properties.Placeholder or "Type here..."
    bg.Text = properties.DefaultText or ""

    for prop, value in pairs(self.Theme.Input) do
        if prop ~= "CornerRadius" then bg[prop] = value end
    end
    for prop, value in pairs(properties) do
        if prop ~= "Name" and prop ~= "CornerRadius" and prop ~= "Placeholder" and prop ~= "DefaultText" and prop ~= "Callback" and prop ~= "OnChanged" and prop ~= "FocusColor" then
            bg[prop] = value
        end
    end

    local cornerRadius = properties.CornerRadius or self.Theme.Input.CornerRadius
    if cornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = cornerRadius
        corner.Parent = bg
    end

    local defaultColor = bg.BackgroundColor3
    local focusColor = properties.FocusColor or self.Theme.Colors.Surface

    bg.Focused:Connect(function()
        self.Tween:Play(bg, self.Tween.Easings.Fast, {BackgroundColor3 = focusColor})
    end)

    bg.FocusLost:Connect(function(enterPressed)
        self.Tween:Play(bg, self.Tween.Easings.Fast, {BackgroundColor3 = defaultColor})
        if properties.Callback then
            properties.Callback(bg.Text, enterPressed)
        end
    end)

    if properties.OnChanged then
        bg:GetPropertyChangedSignal("Text"):Connect(function()
            properties.OnChanged(bg.Text)
        end)
    end

    bg.Parent = container
    container.Parent = parent
    return container, bg
end

-- TOGGLE
function UILibrary:CreateToggle(parent, properties)
    properties = properties or {}
    local container = Instance.new("Frame")
    container.Name = properties.Name or "Toggle"
    container.Size = properties.Size or UDim2.new(0, 44, 0, 24)
    container.BackgroundTransparency = 1

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 1, 0)
    track.BackgroundColor3 = properties.OffColor or self.Theme.Colors.Secondary

    local corner = Instance.new("UICorner")
    corner.CornerRadius = self.Theme.Toggle.CornerRadius
    corner.Parent = track

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local isOn = properties.Default or false
    local onColor = properties.OnColor or self.Theme.Colors.Success
    local offColor = properties.OffColor or self.Theme.Colors.Secondary

    local function updateState()
        local targetColor = isOn and onColor or offColor
        local targetPos = isOn and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        self.Tween:Play(track, self.Tween.Easings.Smooth, {BackgroundColor3 = targetColor})
        self.Tween:Play(knob, self.Tween.Easings.Elastic, {Position = targetPos})
        if properties.Callback then properties.Callback(isOn) end
    end

    if isOn then
        track.BackgroundColor3 = onColor
        knob.Position = UDim2.new(1, -21, 0.5, -9)
    end

    local clickArea = Instance.new("TextButton")
    clickArea.Name = "ClickArea"
    clickArea.Size = UDim2.new(1, 0, 1, 0)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.MouseButton1Click:Connect(function()
        isOn = not isOn
        updateState()
    end)

    if properties.Label then
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Text = properties.Label
        label.Font = self.Theme.Label.Font
        label.TextSize = self.Theme.Label.TextSize
        label.TextColor3 = self.Theme.Label.TextColor3
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(0, 100, 1, 0)
        label.Position = UDim2.new(1, 8, 0, 0)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = container
        container.Size = UDim2.new(0, 150, 0, 24)
    end

    knob.Parent = track
    track.Parent = container
    clickArea.Parent = container
    container.Parent = parent

    local api = {}
    function api:GetValue() return isOn end
    function api:SetValue(value)
        isOn = value
        updateState()
    end
    return api, container
end

-- SLIDER
function UILibrary:CreateSlider(parent, properties)
    properties = properties or {}
    local min = properties.Min or 0
    local max = properties.Max or 100
    local default = math.clamp(properties.Default or min, min, max)
    local step = properties.Step or 1

    local container = Instance.new("Frame")
    container.Name = properties.Name or "Slider"
    container.Size = properties.Size or UDim2.new(0, 200, 0, 40)
    container.BackgroundTransparency = 1

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, 0, 0, 6)
    track.Position = UDim2.new(0, 0, 0.5, -3)
    track.BackgroundColor3 = self.Theme.Slider.BackgroundColor3
    track.BorderSizePixel = 0

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = self.Theme.Slider.CornerRadius
    trackCorner.Parent = track

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = self.Theme.Slider.FillColor
    fill.BorderSizePixel = 0

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = self.Theme.Slider.CornerRadius
    fillCorner.Parent = fill

    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Text = tostring(default)
    valueLabel.Font = self.Theme.Label.Font
    valueLabel.TextSize = 12
    valueLabel.TextColor3 = self.Theme.Colors.TextMuted
    valueLabel.BackgroundTransparency = 1
    valueLabel.Size = UDim2.new(0, 40, 0, 20)
    valueLabel.Position = UDim2.new(1, -40, 0, -20)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right

    if properties.Title then
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Text = properties.Title
        title.Font = self.Theme.Label.Font
        title.TextSize = self.Theme.Label.TextSize
        title.TextColor3 = self.Theme.Label.TextColor3
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -50, 0, 20)
        title.Position = UDim2.new(0, 0, 0, -20)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = container
    end

    local isDragging = false
    local currentValue = default

    local function updateValue(input)
        local trackAbs = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local mouseX = input.Position.X
        local percent = math.clamp((mouseX - trackAbs) / trackSize, 0, 1)
        local rawValue = min + (percent * (max - min))
        if step > 0 then
            currentValue = math.floor((rawValue / step) + 0.5) * step
        else
            currentValue = rawValue
        end
        currentValue = math.clamp(currentValue, min, max)
        percent = (currentValue - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -8, 0.5, -8)
        valueLabel.Text = string.format(properties.Format or "%.0f", currentValue)
        if properties.Callback then properties.Callback(currentValue) end
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            self.Tween:Play(knob, self.Tween.Easings.Fast, {Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(knob.Position.X.Scale, -10, 0.5, -10)})
        end
    end)

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateValue(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and isDragging then
            isDragging = false
            self.Tween:Play(knob, self.Tween.Easings.Fast, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(knob.Position.X.Scale, -8, 0.5, -8)})
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input)
        end
    end)

    fill.Parent = track
    track.Parent = container
    knob.Parent = track
    valueLabel.Parent = container
    container.Parent = parent

    local api = {}
    function api:GetValue() return currentValue end
    function api:SetValue(value)
        currentValue = math.clamp(value, min, max)
        local percent = (currentValue - min) / (max - min)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        knob.Position = UDim2.new(percent, -8, 0.5, -8)
        valueLabel.Text = string.format(properties.Format or "%.0f", currentValue)
    end
    return api, container
end

-- DROPDOWN
function UILibrary:CreateDropdown(parent, properties)
    properties = properties or {}
    local options = properties.Options or {}
    local selected = properties.Default or (options[1] or "")

    local container = Instance.new("Frame")
    container.Name = properties.Name or "Dropdown"
    container.Size = properties.Size or UDim2.new(0, 200, 0, 36)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true

    local button = Instance.new("TextButton")
    button.Name = "Button"
    button.Size = UDim2.new(1, 0, 0, 36)
    button.Text = selected
    button.TextXAlignment = Enum.TextXAlignment.Left

    for prop, value in pairs(self.Theme.Dropdown) do
        if prop ~= "CornerRadius" then button[prop] = value end
    end

    local corner = Instance.new("UICorner")
    corner.CornerRadius = self.Theme.Dropdown.CornerRadius
    corner.Parent = button

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.Parent = button

    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://7072706663"
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -28, 0.5, -8)
    arrow.Parent = button

    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "Options"
    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
    optionsFrame.Position = UDim2.new(0, 0, 0, 40)
    optionsFrame.BackgroundColor3 = self.Theme.Colors.Surface
    optionsFrame.BorderSizePixel = 0
    optionsFrame.Visible = false
    optionsFrame.ClipsDescendants = true

    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 6)
    optionsCorner.Parent = optionsFrame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.Parent = optionsFrame

    local isOpen = false

    local function createOption(text)
        local option = Instance.new("TextButton")
        option.Name = text
        option.Size = UDim2.new(1, 0, 0, 32)
        option.Text = text
        option.TextXAlignment = Enum.TextXAlignment.Left
        option.BackgroundColor3 = self.Theme.Colors.Surface
        option.TextColor3 = self.Theme.Colors.Text
        option.Font = self.Theme.Label.Font
        option.TextSize = 14
        option.AutoButtonColor = false

        local optPadding = Instance.new("UIPadding")
        optPadding.PaddingLeft = UDim.new(0, 12)
        optPadding.Parent = option

        option.MouseEnter:Connect(function()
            self.Tween:Play(option, self.Tween.Easings.Fast, {BackgroundColor3 = self.Theme.Colors.Secondary})
        end)
        option.MouseLeave:Connect(function()
            self.Tween:Play(option, self.Tween.Easings.Fast, {BackgroundColor3 = self.Theme.Colors.Surface})
        end)
        option.MouseButton1Click:Connect(function()
            selected = text
            button.Text = text
            isOpen = false
            optionsFrame.Visible = false
            self.Tween:Play(arrow, self.Tween.Easings.Smooth, {Rotation = 0})
            if properties.Callback then properties.Callback(text) end
        end)
        option.Parent = optionsFrame
    end

    for _, opt in ipairs(options) do
        createOption(opt)
    end

    button.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        optionsFrame.Visible = isOpen
        if isOpen then
            local totalHeight = #options * 34
            optionsFrame.Size = UDim2.new(1, 0, 0, totalHeight)
            self.Tween:Play(arrow, self.Tween.Easings.Smooth, {Rotation = 180})
        else
            self.Tween:Play(arrow, self.Tween.Easings.Smooth, {Rotation = 0})
        end
    end)

    button.Parent = container
    optionsFrame.Parent = container
    container.Parent = parent

    local api = {}
    function api:GetValue() return selected end
    function api:SetValue(value)
        selected = value
        button.Text = value
    end
    function api:AddOption(text)
        table.insert(options, text)
        createOption(text)
    end
    return api, container
end

-- COLOR PICKER
function UILibrary:CreateColorPicker(parent, properties)
    properties = properties or {}
    local currentColor = properties.Default or Color3.fromRGB(88, 101, 242)
    local hue, sat, val = currentColor:ToHSV()

    local container = Instance.new("Frame")
    container.Name = properties.Name or "ColorPicker"
    container.Size = properties.Size or UDim2.new(0, 280, 0, 220)
    container.BackgroundColor3 = self.Theme.Colors.Background
    container.BorderSizePixel = 0
    container.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container

    if properties.Title then
        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Text = properties.Title
        title.Font = self.Theme.Label.Font
        title.TextSize = 14
        title.TextColor3 = self.Theme.Colors.Text
        title.BackgroundTransparency = 1
        title.Size = UDim2.new(1, -20, 0, 28)
        title.Position = UDim2.new(0, 10, 0, 4)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = container
    end

    local svFrame = Instance.new("Frame")
    svFrame.Name = "SVFrame"
    svFrame.Size = UDim2.new(0, 180, 0, 140)
    svFrame.Position = UDim2.new(0, 10, 0, 36)
    svFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
    svFrame.BorderSizePixel = 0

    local svCorner = Instance.new("UICorner")
    svCorner.CornerRadius = UDim.new(0, 6)
    svCorner.Parent = svFrame

    local whiteGrad = Instance.new("UIGradient")
    whiteGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
    }
    whiteGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    }
    whiteGrad.Parent = svFrame

    local blackOverlay = Instance.new("Frame")
    blackOverlay.Name = "BlackOverlay"
    blackOverlay.Size = UDim2.new(1, 0, 1, 0)
    blackOverlay.BackgroundTransparency = 1

    local blackGrad = Instance.new("UIGradient")
    blackGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))
    }
    blackGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    }
    blackGrad.Rotation = -90
    blackGrad.Parent = blackOverlay
    blackOverlay.Parent = svFrame

    local svKnob = Instance.new("Frame")
    svKnob.Name = "SVKnob"
    svKnob.Size = UDim2.new(0, 12, 0, 12)
    svKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    svKnob.BorderSizePixel = 2
    svKnob.BorderColor3 = Color3.new(0.3, 0.3, 0.3)

    local svKnobCorner = Instance.new("UICorner")
    svKnobCorner.CornerRadius = UDim.new(1, 0)
    svKnobCorner.Parent = svKnob

    local hueBar = Instance.new("Frame")
    hueBar.Name = "HueBar"
    hueBar.Size = UDim2.new(0, 20, 0, 140)
    hueBar.Position = UDim2.new(0, 200, 0, 36)
    hueBar.BorderSizePixel = 0

    local hueGrad = Instance.new("UIGradient")
    hueGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
        ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
        ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
        ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
        ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
    }
    hueGrad.Parent = hueBar

    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 6)
    hueCorner.Parent = hueBar

    local hueKnob = Instance.new("Frame")
    hueKnob.Name = "HueKnob"
    hueKnob.Size = UDim2.new(1, 4, 0, 6)
    hueKnob.Position = UDim2.new(0, -2, 0, -3)
    hueKnob.BackgroundColor3 = Color3.new(1, 1, 1)
    hueKnob.BorderSizePixel = 2
    hueKnob.BorderColor3 = Color3.new(0.3, 0.3, 0.3)

    local preview = Instance.new("Frame")
    preview.Name = "Preview"
    preview.Size = UDim2.new(0, 60, 0, 30)
    preview.Position = UDim2.new(0, 10, 0, 186)
    preview.BackgroundColor3 = currentColor
    preview.BorderSizePixel = 0

    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 6)
    previewCorner.Parent = preview

    local rgbInput = Instance.new("TextBox")
    rgbInput.Name = "RGBInput"
    rgbInput.Size = UDim2.new(0, 100, 0, 30)
    rgbInput.Position = UDim2.new(0, 80, 0, 186)
    rgbInput.BackgroundColor3 = self.Theme.Colors.Surface
    rgbInput.TextColor3 = self.Theme.Colors.Text
    rgbInput.Font = self.Theme.Label.Font
    rgbInput.TextSize = 12
    rgbInput.Text = string.format("%d, %d, %d", math.floor(currentColor.R*255), math.floor(currentColor.G*255), math.floor(currentColor.B*255))
    rgbInput.ClearTextOnFocus = false

    local rgbCorner = Instance.new("UICorner")
    rgbCorner.CornerRadius = UDim.new(0, 6)
    rgbCorner.Parent = rgbInput

    local hexInput = Instance.new("TextBox")
    hexInput.Name = "HexInput"
    hexInput.Size = UDim2.new(0, 80, 0, 30)
    hexInput.Position = UDim2.new(0, 190, 0, 186)
    hexInput.BackgroundColor3 = self.Theme.Colors.Surface
    hexInput.TextColor3 = self.Theme.Colors.Text
    hexInput.Font = self.Theme.Label.Font
    hexInput.TextSize = 12
    hexInput.Text = string.format("#%02X%02X%02X", math.floor(currentColor.R*255), math.floor(currentColor.G*255), math.floor(currentColor.B*255))
    hexInput.ClearTextOnFocus = false

    local hexCorner = Instance.new("UICorner")
    hexCorner.CornerRadius = UDim.new(0, 6)
    hexCorner.Parent = hexInput

    local function updateColor(newHue, newSat, newVal)
        hue, sat, val = newHue, newSat, newVal
        currentColor = Color3.fromHSV(hue, sat, val)
        svFrame.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        preview.BackgroundColor3 = currentColor
        rgbInput.Text = string.format("%d, %d, %d", math.floor(currentColor.R*255), math.floor(currentColor.G*255), math.floor(currentColor.B*255))
        hexInput.Text = string.format("#%02X%02X%02X", math.floor(currentColor.R*255), math.floor(currentColor.G*255), math.floor(currentColor.B*255))
        if properties.Callback then properties.Callback(currentColor) end
    end

    local function updateKnobs()
        svKnob.Position = UDim2.new(sat, -6, 1 - val, -6)
        hueKnob.Position = UDim2.new(-0.1, 0, 1 - hue, -3)
    end

    local svDragging = false
    svFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = true
            local relX = math.clamp((input.Position.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
            local relY = math.clamp((input.Position.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
            updateColor(hue, relX, 1 - relY)
            updateKnobs()
        end
    end)

    local hueDragging = false
    hueBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            local relY = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
            updateColor(1 - relY, sat, val)
            updateKnobs()
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if svDragging then
                local relX = math.clamp((input.Position.X - svFrame.AbsolutePosition.X) / svFrame.AbsoluteSize.X, 0, 1)
                local relY = math.clamp((input.Position.Y - svFrame.AbsolutePosition.Y) / svFrame.AbsoluteSize.Y, 0, 1)
                updateColor(hue, relX, 1 - relY)
                updateKnobs()
            elseif hueDragging then
                local relY = math.clamp((input.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
                updateColor(1 - relY, sat, val)
                updateKnobs()
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = false
            hueDragging = false
        end
    end)

    rgbInput.FocusLost:Connect(function()
        local r, g, b = rgbInput.Text:match("(%d+)%s*,%s*(%d+)%s*,%s*(%d+)")
        if r and g and b then
            local newColor = Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
            hue, sat, val = newColor:ToHSV()
            updateColor(hue, sat, val)
            updateKnobs()
        end
    end)

    hexInput.FocusLost:Connect(function()
        local hex = hexInput.Text:gsub("#", "")
        if #hex == 6 then
            local r = tonumber(hex:sub(1,2), 16)
            local g = tonumber(hex:sub(3,4), 16)
            local b = tonumber(hex:sub(5,6), 16)
            if r and g and b then
                local newColor = Color3.fromRGB(r, g, b)
                hue, sat, val = newColor:ToHSV()
                updateColor(hue, sat, val)
                updateKnobs()
            end
        end
    end)

    updateKnobs()
    svKnob.Parent = svFrame
    hueKnob.Parent = hueBar
    svFrame.Parent = container
    hueBar.Parent = container
    preview.Parent = container
    rgbInput.Parent = container
    hexInput.Parent = container
    container.Parent = parent

    local api = {}
    function api:GetColor() return currentColor end
    function api:SetColor(color)
        hue, sat, val = color:ToHSV()
        updateColor(hue, sat, val)
        updateKnobs()
    end
    return api, container
end

-- NOTIFICATION
UILibrary.Notification = {}
local activeNotifications = {}

function UILibrary.Notification:Create(parent, properties)
    properties = properties or {}
    local notifType = properties.Type or "Info"
    local duration = properties.Duration or 3
    local title = properties.Title or "Notification"
    local message = properties.Message or ""

    local typeColors = {
        Info = UILibrary.Theme.Colors.Primary,
        Success = UILibrary.Theme.Colors.Success,
        Warning = UILibrary.Theme.Colors.Warning,
        Error = UILibrary.Theme.Colors.Error
    }
    local typeIcons = {
        Info = "rbxassetid://3944670656",
        Success = "rbxassetid://3944670738",
        Warning = "rbxassetid://3944670815",
        Error = "rbxassetid://3944670892"
    }
    local accentColor = typeColors[notifType] or typeColors.Info
    local icon = typeIcons[notifType] or typeIcons.Info

    local container = Instance.new("Frame")
    container.Name = "Notification"
    container.Size = UDim2.new(0, 320, 0, 0)
    container.Position = UDim2.new(1, -340, 1, -20)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true

    local card = Instance.new("Frame")
    card.Name = "Card"
    card.Size = UDim2.new(1, 0, 0, 0)
    card.BackgroundColor3 = UILibrary.Theme.Colors.Surface
    card.BorderSizePixel = 0

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card

    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.BackgroundColor3 = accentColor
    accent.BorderSizePixel = 0

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 10)
    accentCorner.Parent = accent

    local iconImg = Instance.new("ImageLabel")
    iconImg.Name = "Icon"
    iconImg.BackgroundTransparency = 1
    iconImg.Image = icon
    iconImg.ImageColor3 = accentColor
    iconImg.Size = UDim2.new(0, 24, 0, 24)
    iconImg.Position = UDim2.new(0, 16, 0, 14)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.TextColor3 = UILibrary.Theme.Colors.Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -80, 0, 20)
    titleLabel.Position = UDim2.new(0, 52, 0, 10)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local msgLabel = Instance.new("TextLabel")
    msgLabel.Name = "Message"
    msgLabel.Text = message
    msgLabel.Font = UILibrary.Theme.Label.Font
    msgLabel.TextSize = 13
    msgLabel.TextColor3 = UILibrary.Theme.Colors.TextMuted
    msgLabel.BackgroundTransparency = 1
    msgLabel.Size = UDim2.new(1, -68, 0, 0)
    msgLabel.Position = UDim2.new(0, 52, 0, 32)
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextYAlignment = Enum.TextYAlignment.Top
    msgLabel.TextWrapped = true
    msgLabel.AutomaticSize = Enum.AutomaticSize.Y

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -32, 0, 10)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "×"
    closeBtn.TextColor3 = UILibrary.Theme.Colors.TextMuted
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 18

    local progressBar = Instance.new("Frame")
    progressBar.Name = "Progress"
    progressBar.Size = UDim2.new(1, 0, 0, 3)
    progressBar.Position = UDim2.new(0, 0, 1, -3)
    progressBar.BackgroundColor3 = accentColor
    progressBar.BorderSizePixel = 0

    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 2)
    progressCorner.Parent = progressBar

    local textSize = TextService:GetTextSize(message, 13, UILibrary.Theme.Label.Font, Vector2.new(240, 1000))
    local cardHeight = math.max(64, 42 + textSize.Y)

    for _, notif in ipairs(activeNotifications) do
        if notif and notif.Parent then
            local currentPos = notif.Position
            UILibrary.Tween:Play(notif, UILibrary.Tween.Easings.Smooth, {
                Position = UDim2.new(currentPos.X.Scale, currentPos.X.Offset, currentPos.Y.Scale, currentPos.Y.Offset - cardHeight - 12)
            })
        end
    end

    table.insert(activeNotifications, 1, container)

    accent.Parent = card
    iconImg.Parent = card
    titleLabel.Parent = card
    msgLabel.Parent = card
    closeBtn.Parent = card
    progressBar.Parent = card
    card.Parent = container
    container.Parent = parent

    container.Size = UDim2.new(0, 320, 0, cardHeight)
    card.Size = UDim2.new(1, 0, 0, cardHeight)
    container.Position = UDim2.new(1, 20, 1, -20 - cardHeight)

    UILibrary.Tween:Play(container, UILibrary.Tween.Easings.Bounce, {
        Position = UDim2.new(1, -340, 1, -20 - cardHeight)
    })

    UILibrary.Tween:Play(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 3)})

    local dismissConnection
    local function dismiss()
        if dismissConnection then dismissConnection:Disconnect() end
        for i, notif in ipairs(activeNotifications) do
            if notif == container then
                table.remove(activeNotifications, i)
                break
            end
        end
        UILibrary.Tween:Play(container, UILibrary.Tween.Easings.Fast, {
            Position = UDim2.new(1, 20, container.Position.Y.Scale, container.Position.Y.Offset)
        }, function()
            container:Destroy()
        end)
    end

    dismissConnection = task.delay(duration, dismiss)
    closeBtn.MouseButton1Click:Connect(dismiss)

    return container
end

function UILibrary.Notification:Info(parent, title, message, duration)
    return self:Create(parent, {Type = "Info", Title = title, Message = message, Duration = duration})
end
function UILibrary.Notification:Success(parent, title, message, duration)
    return self:Create(parent, {Type = "Success", Title = title, Message = message, Duration = duration})
end
function UILibrary.Notification:Warning(parent, title, message, duration)
    return self:Create(parent, {Type = "Warning", Title = title, Message = message, Duration = duration})
end
function UILibrary.Notification:Error(parent, title, message, duration)
    return self:Create(parent, {Type = "Error", Title = title, Message = message, Duration = duration})
end

-- WINDOW
function UILibrary:CreateWindow(parent, properties)
    properties = properties or {}
    local title = properties.Title or "Window"
    local size = properties.Size or UDim2.new(0, 500, 0, 350)
    local minSize = properties.MinSize or Vector2.new(300, 200)

    local window = Instance.new("Frame")
    window.Name = properties.Name or "Window"
    window.Size = size
    window.Position = properties.Position or UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    window.BackgroundColor3 = self.Theme.Colors.Background
    window.BorderSizePixel = 0

    local windowCorner = Instance.new("UICorner")
    windowCorner.CornerRadius = UDim.new(0, 12)
    windowCorner.Parent = window

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.ZIndex = 0
    shadow.Parent = window

    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = self.Theme.Colors.Surface
    titleBar.BorderSizePixel = 0

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar

    local titleFix = Instance.new("Frame")
    titleFix.Name = "Fix"
    titleFix.Size = UDim2.new(1, 0, 0, 12)
    titleFix.Position = UDim2.new(0, 0, 1, -12)
    titleFix.BackgroundColor3 = self.Theme.Colors.Surface
    titleFix.BorderSizePixel = 0
    titleFix.Parent = titleBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 15
    titleLabel.TextColor3 = self.Theme.Colors.Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, -120, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    local controls = Instance.new("Frame")
    controls.Name = "Controls"
    controls.Size = UDim2.new(0, 80, 1, 0)
    controls.Position = UDim2.new(1, -90, 0, 0)
    controls.BackgroundTransparency = 1

    local minBtn = Instance.new("TextButton")
    minBtn.Name = "Minimize"
    minBtn.Size = UDim2.new(0, 24, 0, 24)
    minBtn.Position = UDim2.new(0, 0, 0.5, -12)
    minBtn.BackgroundColor3 = self.Theme.Colors.Warning
    minBtn.Text = ""
    minBtn.AutoButtonColor = false

    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(1, 0)
    minCorner.Parent = minBtn

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(0, 32, 0.5, -12)
    closeBtn.BackgroundColor3 = self.Theme.Colors.Error
    closeBtn.Text = ""
    closeBtn.AutoButtonColor = false

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeBtn

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -60)
    content.Position = UDim2.new(0, 10, 0, 50)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true

    local resizeHandle = Instance.new("TextButton")
    resizeHandle.Name = "Resize"
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Text = ""
    resizeHandle.Parent = window

    local isDragging = false
    local dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = window.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    local isResizing = false
    local resizeStart, startSize

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isResizing = true
            resizeStart = input.Position
            startSize = window.Size
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isResizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newWidth = math.max(minSize.X, startSize.X.Offset + delta.X)
            local newHeight = math.max(minSize.Y, startSize.Y.Offset + delta.Y)
            window.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isResizing = false
        end
    end)

    local isMinimized = false
    local originalSize = size

    minBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            originalSize = window.Size
            self.Tween:Play(window, self.Tween.Easings.Smooth, {Size = UDim2.new(0, window.Size.X.Offset, 0, 40)})
            content.Visible = false
            resizeHandle.Visible = false
        else
            self.Tween:Play(window, self.Tween.Easings.Smooth, {Size = originalSize})
            content.Visible = true
            resizeHandle.Visible = true
        end
    end)

    closeBtn.MouseButton1Click:Connect(function()
        self.Tween:Play(window, self.Tween.Easings.Fast, {Size = UDim2.new(0, window.Size.X.Offset, 0, 0)}, function()
            window:Destroy()
        end)
    end)

    self.Tween:HoverEffect(minBtn, self.Theme.Colors.Warning:Lerp(Color3.new(1,1,1), 0.3), self.Theme.Colors.Warning)
    self.Tween:HoverEffect(closeBtn, self.Theme.Colors.Error:Lerp(Color3.new(1,1,1), 0.3), self.Theme.Colors.Error)

    minBtn.Parent = controls
    closeBtn.Parent = controls
    controls.Parent = titleBar
    titleBar.Parent = window
    content.Parent = window
    window.Parent = parent

    window.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            window.ZIndex = 10
            for _, child in ipairs(parent:GetChildren()) do
                if child:IsA("Frame") and child ~= window then
                    child.ZIndex = 1
                end
            end
        end
    end)

    local api = {}
    function api:GetContent() return content end
    function api:SetTitle(newTitle) titleLabel.Text = newTitle end
    function api:Close() window:Destroy() end
    return api, window
end

-- TAB SYSTEM
function UILibrary:CreateTabSystem(parent, properties)
    properties = properties or {}
    local tabs = {}
    local activeTab = nil

    local container = Instance.new("Frame")
    container.Name = properties.Name or "TabSystem"
    container.Size = properties.Size or UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1

    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, 0, 0, 38)
    tabBar.BackgroundColor3 = self.Theme.Colors.Surface
    tabBar.BorderSizePixel = 0

    local tabBarCorner = Instance.new("UICorner")
    tabBarCorner.CornerRadius = UDim.new(0, 8)
    tabBarCorner.Parent = tabBar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabBar

    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingLeft = UDim.new(0, 8)
    tabPadding.PaddingTop = UDim.new(0, 6)
    tabPadding.Parent = tabBar

    local contentContainer = Instance.new("Frame")
    contentContainer.Name = "Content"
    contentContainer.Size = UDim2.new(1, 0, 1, -46)
    contentContainer.Position = UDim2.new(0, 0, 0, 42)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ClipsDescendants = true

    tabBar.Parent = container
    contentContainer.Parent = container
    container.Parent = parent

    local function switchTab(tabId)
        if activeTab == tabId then return end
        if activeTab and tabs[activeTab] then
            local oldData = tabs[activeTab]
            self.Tween:Play(oldData.content, self.Tween.Easings.Fast, {Position = UDim2.new(0.05, 0, 0, 0)})
            oldData.content.Visible = false
            self.Tween:Play(oldData.button, self.Tween.Easings.Fast, {TextColor3 = self.Theme.Colors.TextMuted})
            oldData.button.BackgroundTransparency = 1
        end
        activeTab = tabId
        local newData = tabs[tabId]
        newData.content.Position = UDim2.new(0.05, 0, 0, 0)
        newData.content.Visible = true
        self.Tween:Play(newData.content, self.Tween.Easings.Smooth, {Position = UDim2.new(0, 0, 0, 0)})
        self.Tween:Play(newData.button, self.Tween.Easings.Fast, {TextColor3 = self.Theme.Colors.Text})
    end

    local api = {}
    function api:AddTab(tabProps)
        tabProps = tabProps or {}
        local tabName = tabProps.Name or "Tab"
        local tabId = tabProps.Id or tostring(#tabs + 1)

        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = tabName
        tabBtn.Size = UDim2.new(0, 0, 0, 32)
        tabBtn.AutomaticSize = Enum.AutomaticSize.X
        tabBtn.BackgroundColor3 = self.Theme.Colors.Primary
        tabBtn.BackgroundTransparency = 1
        tabBtn.Text = tabName
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 13
        tabBtn.TextColor3 = self.Theme.Colors.TextMuted
        tabBtn.AutoButtonColor = false

        local btnPadding = Instance.new("UIPadding")
        btnPadding.PaddingLeft = UDim.new(0, 14)
        btnPadding.PaddingRight = UDim.new(0, 14)
        btnPadding.Parent = tabBtn

        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Name = tabName .. "Content"
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = self.Theme.Colors.Primary
        tabContent.Visible = false
        tabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)

        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.Parent = tabContent

        local contentPadding = Instance.new("UIPadding")
        contentPadding.PaddingLeft = UDim.new(0, 8)
        contentPadding.PaddingRight = UDim.new(0, 8)
        contentPadding.PaddingTop = UDim.new(0, 8)
        contentPadding.PaddingBottom = UDim.new(0, 8)
        contentPadding.Parent = tabContent

        tabBtn.MouseEnter:Connect(function()
            if activeTab ~= tabId then
                self.Tween:Play(tabBtn, self.Tween.Easings.Fast, {TextColor3 = self.Theme.Colors.Text})
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab ~= tabId then
                self.Tween:Play(tabBtn, self.Tween.Easings.Fast, {TextColor3 = self.Theme.Colors.TextMuted})
            end
        end)
        tabBtn.MouseButton1Click:Connect(function()
            switchTab(tabId)
        end)

        tabBtn.Parent = tabBar
        tabContent.Parent = contentContainer
        tabs[tabId] = {button = tabBtn, content = tabContent, id = tabId}

        if not activeTab then
            switchTab(tabId)
        end

        return tabContent
    end

    function api:GetTab(tabId)
        return tabs[tabId] and tabs[tabId].content
    end
    function api:SetActive(tabId)
        switchTab(tabId)
    end
    return api, container
end

-- SUB TAB SYSTEM
function UILibrary:CreateSubTabSystem(parent, properties)
    properties = properties or {}
    local subTabs = {}
    local activeSub = nil

    local container = Instance.new("Frame")
    container.Name = properties.Name or "SubTabSystem"
    container.Size = properties.Size or UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1

    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "Buttons"
    buttonContainer.Size = UDim2.new(0, 140, 1, 0)
    buttonContainer.BackgroundTransparency = 1

    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.Padding = UDim.new(0, 4)
    buttonLayout.Parent = buttonContainer

    local buttonPadding = Instance.new("UIPadding")
    buttonPadding.PaddingTop = UDim.new(0, 8)
    buttonPadding.PaddingLeft = UDim.new(0, 8)
    buttonPadding.PaddingRight = UDim.new(0, 8)
    buttonPadding.Parent = buttonContainer

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -148, 1, 0)
    contentArea.Position = UDim2.new(0, 148, 0, 0)
    contentArea.BackgroundColor3 = self.Theme.Colors.Surface
    contentArea.BorderSizePixel = 0

    local contentCorner = Instance.new("UICorner")
    contentCorner.CornerRadius = UDim.new(0, 10)
    contentCorner.Parent = contentArea

    buttonContainer.Parent = container
    contentArea.Parent = container
    container.Parent = parent

    local function switchSub(subId)
        if activeSub == subId then return end
        if activeSub and subTabs[activeSub] then
            local old = subTabs[activeSub]
            self.Tween:Play(old.content, self.Tween.Easings.Fast, {Position = UDim2.new(0.03, 0, 0, 0)})
            old.content.Visible = false
            self.Tween:Play(old.button, self.Tween.Easings.Fast, {BackgroundTransparency = 1, TextColor3 = self.Theme.Colors.TextMuted})
        end
        activeSub = subId
        local new = subTabs[subId]
        new.content.Position = UDim2.new(0.03, 0, 0, 0)
        new.content.Visible = true
        self.Tween:Play(new.content, self.Tween.Easings.Smooth, {Position = UDim2.new(0, 0, 0, 0)})
        self.Tween:Play(new.button, self.Tween.Easings.Fast, {BackgroundTransparency = 0.9, TextColor3 = self.Theme.Colors.Text})
    end

    local api = {}
    function api:AddSubTab(subProps)
        subProps = subProps or {}
        local name = subProps.Name or "Sub"
        local icon = subProps.Icon
        local subId = subProps.Id or tostring(#subTabs + 1)

        local subBtn = Instance.new("TextButton")
        subBtn.Name = name
        subBtn.Size = UDim2.new(1, 0, 0, 36)
        subBtn.BackgroundColor3 = self.Theme.Colors.Primary
        subBtn.BackgroundTransparency = 1
        subBtn.Text = (icon and "  " or "") .. name
        subBtn.Font = Enum.Font.Gotham
        subBtn.TextSize = 13
        subBtn.TextColor3 = self.Theme.Colors.TextMuted
        subBtn.TextXAlignment = Enum.TextXAlignment.Left
        subBtn.AutoButtonColor = false

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = subBtn

        local btnPadding = Instance.new("UIPadding")
        btnPadding.PaddingLeft = UDim.new(0, icon and 28 or 12)
        btnPadding.Parent = subBtn

        if icon then
            local iconImg = Instance.new("ImageLabel")
            iconImg.BackgroundTransparency = 1
            iconImg.Image = icon
            iconImg.ImageColor3 = self.Theme.Colors.TextMuted
            iconImg.Size = UDim2.new(0, 18, 0, 18)
            iconImg.Position = UDim2.new(0, 8, 0.5, -9)
            iconImg.Parent = subBtn
        end

        local subContent = Instance.new("ScrollingFrame")
        subContent.Name = name .. "Content"
        subContent.Size = UDim2.new(1, -16, 1, -16)
        subContent.Position = UDim2.new(0, 8, 0, 8)
        subContent.BackgroundTransparency = 1
        subContent.BorderSizePixel = 0
        subContent.ScrollBarThickness = 3
        subContent.ScrollBarImageColor3 = self.Theme.Colors.Primary
        subContent.Visible = false
        subContent.AutomaticCanvasSize = Enum.AutomaticSize.Y

        local subLayout = Instance.new("UIListLayout")
        subLayout.Padding = UDim.new(0, 8)
        subLayout.Parent = subContent

        subBtn.MouseEnter:Connect(function()
            if activeSub ~= subId then
                self.Tween:Play(subBtn, self.Tween.Easings.Fast, {BackgroundTransparency = 0.95})
            end
        end)
        subBtn.MouseLeave:Connect(function()
            if activeSub ~= subId then
                self.Tween:Play(subBtn, self.Tween.Easings.Fast, {BackgroundTransparency = 1})
            end
        end)
        subBtn.MouseButton1Click:Connect(function()
            switchSub(subId)
        end)

        subBtn.Parent = buttonContainer
        subContent.Parent = contentArea
        subTabs[subId] = {button = subBtn, content = subContent, id = subId}

        if not activeSub then
            switchSub(subId)
        end

        return subContent
    end

    function api:GetSubTab(subId)
        return subTabs[subId] and subTabs[subId].content
    end
    return api, container
end

-- KEY SYSTEM (Free / Premium / Custom)
function UILibrary:CreateKeySystem(parent, properties)
    properties = properties or {}

    local tiers = {
        Free = {
            Key = properties.FreeKey or "FREE-2026-EXEC",
            KeyLink = properties.FreeKeyLink or "https://linkvertise.com/freekey",
            Color = Color3.fromRGB(52, 152, 219),
            Benefits = {"Basic Scripts", "Standard Support"},
            SaveFile = "FreeKey.json"
        },
        Premium = {
            Key = properties.PremiumKey or "PREM-2026-VIP",
            KeyLink = properties.PremiumKeyLink or "https://sellix.io/premiumkey",
            Color = Color3.fromRGB(155, 89, 182),
            Benefits = {"All Scripts", "Priority Support", "Exclusive Features", "No Ads"},
            SaveFile = "PremiumKey.json"
        },
        Custom = {
            Key = properties.CustomKey or "CUST-2026-SPEC",
            KeyLink = properties.CustomKeyLink or "https://discord.gg/customkey",
            Color = Color3.fromRGB(230, 126, 34),
            Benefits = {"Custom Scripts", "API Access", "Early Updates"},
            SaveFile = "CustomKey.json"
        }
    }

    local selectedTier = "Free"
    local onSuccess = properties.OnSuccess or function(tier) end
    local onFail = properties.OnFail or function(key, tier) end
    local saveKey = properties.SaveKey ~= false

    -- Check saved keys
    local savedTier = nil
    if saveKey then
        pcall(function()
            if readfile and isfile then
                for tierName, tierData in pairs(tiers) do
                    if isfile(tierData.SaveFile) then
                        local data = HttpService:JSONDecode(readfile(tierData.SaveFile))
                        if data.key == tierData.Key then
                            savedTier = tierName
                            break
                        end
                    end
                end
            end
        end)
    end

    if savedTier then
        onSuccess(savedTier, {})
        return {Verified = true, SkipUI = true, Tier = savedTier}
    end

    local container = Instance.new("Frame")
    container.Name = "KeySystem"
    container.Size = UDim2.new(0, 440, 0, 360)
    container.Position = UDim2.new(0.5, -220, 0.5, -180)
    container.BackgroundColor3 = self.Theme.Colors.Background
    container.BorderSizePixel = 0
    container.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = container

    local shadow = Instance.new("ImageLabel")
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://5554236805"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.6
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    shadow.Size = UDim2.new(1, 40, 1, 40)
    shadow.Position = UDim2.new(0, -20, 0, -20)
    shadow.ZIndex = 0
    shadow.Parent = container

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 60)
    header.BackgroundColor3 = self.Theme.Colors.Surface
    header.BorderSizePixel = 0

    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 16)
    headerFix.Position = UDim2.new(0, 0, 1, -16)
    headerFix.BackgroundColor3 = self.Theme.Colors.Surface
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local title = Instance.new("TextLabel")
    title.Text = "🔐 Key Verification"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = self.Theme.Colors.Text
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Parent = header

    local tierLabel = Instance.new("TextLabel")
    tierLabel.Text = "Select Tier:"
    tierLabel.Font = Enum.Font.GothamBold
    tierLabel.TextSize = 13
    tierLabel.TextColor3 = self.Theme.Colors.TextMuted
    tierLabel.BackgroundTransparency = 1
    tierLabel.Size = UDim2.new(0, 80, 0, 24)
    tierLabel.Position = UDim2.new(0, 20, 0, 72)
    tierLabel.TextXAlignment = Enum.TextXAlignment.Left
    tierLabel.Parent = container

    local tierContainer = Instance.new("Frame")
    tierContainer.Name = "TierButtons"
    tierContainer.Size = UDim2.new(1, -40, 0, 36)
    tierContainer.Position = UDim2.new(0, 20, 0, 98)
    tierContainer.BackgroundTransparency = 1

    local tierLayout = Instance.new("UIListLayout")
    tierLayout.FillDirection = Enum.FillDirection.Horizontal
    tierLayout.Padding = UDim.new(0, 8)
    tierLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tierLayout.Parent = tierContainer

    local benefitsPanel = Instance.new("Frame")
    benefitsPanel.Name = "Benefits"
    benefitsPanel.Size = UDim2.new(1, -40, 0, 80)
    benefitsPanel.Position = UDim2.new(0, 20, 0, 142)
    benefitsPanel.BackgroundColor3 = self.Theme.Colors.Surface
    benefitsPanel.BorderSizePixel = 0

    local benefitsCorner = Instance.new("UICorner")
    benefitsCorner.CornerRadius = UDim.new(0, 10)
    benefitsCorner.Parent = benefitsPanel

    local benefitsLayout = Instance.new("UIListLayout")
    benefitsLayout.Padding = UDim.new(0, 4)
    benefitsLayout.Parent = benefitsPanel

    local benefitsPadding = Instance.new("UIPadding")
    benefitsPadding.PaddingLeft = UDim.new(0, 12)
    benefitsPadding.PaddingTop = UDim.new(0, 8)
    benefitsPadding.Parent = benefitsPanel

    local tierButtons = {}

    local function updateBenefits(tierName)
        for _, child in ipairs(benefitsPanel:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        local tierData = tiers[tierName]
        for _, benefit in ipairs(tierData.Benefits) do
            local benefitLabel = Instance.new("TextLabel")
            benefitLabel.Text = "✓ " .. benefit
            benefitLabel.Font = Enum.Font.Gotham
            benefitLabel.TextSize = 12
            benefitLabel.TextColor3 = tierData.Color
            benefitLabel.BackgroundTransparency = 1
            benefitLabel.Size = UDim2.new(1, 0, 0, 18)
            benefitLabel.TextXAlignment = Enum.TextXAlignment.Left
            benefitLabel.Parent = benefitsPanel
        end
    end

    local function selectTier(tierName)
        selectedTier = tierName
        local tierData = tiers[tierName]
        for name, btn in pairs(tierButtons) do
            if name == tierName then
                self.Tween:Play(btn, self.Tween.Easings.Fast, {BackgroundColor3 = tierData.Color})
                btn.TextColor3 = Color3.new(1, 1, 1)
            else
                self.Tween:Play(btn, self.Tween.Easings.Fast, {BackgroundColor3 = self.Theme.Colors.Secondary})
                btn.TextColor3 = self.Theme.Colors.TextMuted
            end
        end
        updateBenefits(tierName)
    end

    for tierName, tierData in pairs(tiers) do
        local btn = Instance.new("TextButton")
        btn.Name = tierName
        btn.Size = UDim2.new(0, 120, 1, 0)
        btn.BackgroundColor3 = self.Theme.Colors.Secondary
        btn.Text = tierName
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.TextColor3 = self.Theme.Colors.TextMuted
        btn.AutoButtonColor = false

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(function()
            selectTier(tierName)
        end)

        btn.Parent = tierContainer
        tierButtons[tierName] = btn
    end

    local inputBg = Instance.new("Frame")
    inputBg.Name = "InputBg"
    inputBg.Size = UDim2.new(1, -40, 0, 44)
    inputBg.Position = UDim2.new(0, 20, 0, 230)
    inputBg.BackgroundColor3 = self.Theme.Colors.Surface
    inputBg.BorderSizePixel = 0

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 10)
    inputCorner.Parent = inputBg

    local keyInput = Instance.new("TextBox")
    keyInput.Name = "KeyInput"
    keyInput.Size = UDim2.new(1, -20, 1, 0)
    keyInput.Position = UDim2.new(0, 10, 0, 0)
    keyInput.BackgroundTransparency = 1
    keyInput.Text = ""
    keyInput.PlaceholderText = "Enter your key..."
    keyInput.PlaceholderColor3 = self.Theme.Colors.TextMuted
    keyInput.TextColor3 = self.Theme.Colors.Text
    keyInput.Font = self.Theme.Label.Font
    keyInput.TextSize = 14
    keyInput.TextXAlignment = Enum.TextXAlignment.Left
    keyInput.ClearTextOnFocus = false
    keyInput.Parent = inputBg

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Text = ""
    status.Font = Enum.Font.Gotham
    status.TextSize = 12
    status.TextColor3 = self.Theme.Colors.Error
    status.BackgroundTransparency = 1
    status.Size = UDim2.new(1, -40, 0, 20)
    status.Position = UDim2.new(0, 20, 0, 278)
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = container

    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, -40, 0, 40)
    btnContainer.Position = UDim2.new(0, 20, 0, 302)
    btnContainer.BackgroundTransparency = 1

    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = Enum.FillDirection.Horizontal
    btnLayout.Padding = UDim.new(0, 10)
    btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    btnLayout.Parent = btnContainer

    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0, 130, 1, 0)
    getKeyBtn.BackgroundColor3 = self.Theme.Colors.Secondary
    getKeyBtn.Text = "🔗 Get Key"
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.TextSize = 13
    getKeyBtn.TextColor3 = self.Theme.Colors.Text
    getKeyBtn.AutoButtonColor = false

    local getKeyCorner = Instance.new("UICorner")
    getKeyCorner.CornerRadius = UDim.new(0, 10)
    getKeyCorner.Parent = getKeyBtn

    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0, 130, 1, 0)
    submitBtn.BackgroundColor3 = self.Theme.Colors.Primary
    submitBtn.Text = "✓ Verify"
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.TextSize = 13
    submitBtn.TextColor3 = self.Theme.Colors.Text
    submitBtn.AutoButtonColor = false

    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 10)
    submitCorner.Parent = submitBtn

    local footer = Instance.new("TextLabel")
    footer.Text = "Key is saved locally per tier • Do not share your key"
    footer.Font = Enum.Font.Gotham
    footer.TextSize = 11
    footer.TextColor3 = self.Theme.Colors.TextMuted
    footer.BackgroundTransparency = 1
    footer.Size = UDim2.new(1, 0, 0, 20)
    footer.Position = UDim2.new(0, 0, 1, -24)
    footer.Parent = container

    local function verifyKey(key, tier)
        return key == tiers[tier].Key
    end

    local function submit()
        local key = keyInput.Text:gsub("^%s*(.-)%s*$", "%1")
        if #key == 0 then
            status.Text = "⚠ Please enter a key"
            return
        end
        local tierData = tiers[selectedTier]
        if verifyKey(key, selectedTier) then
            status.TextColor3 = self.Theme.Colors.Success
            status.Text = "✓ " .. selectedTier .. " key verified!"
            if saveKey then
                pcall(function()
                    if writefile then
                        local data = {key = key, tier = selectedTier, timestamp = os.time(), hwid = Players.LocalPlayer.UserId}
                        writefile(tierData.SaveFile, HttpService:JSONEncode(data))
                    end
                end)
            end
            self.Tween:Play(container, self.Tween.Easings.Smooth, {
                Size = UDim2.new(0, 440, 0, 0),
                Position = UDim2.new(0.5, -220, 0.5, 0)
            }, function()
                container:Destroy()
                onSuccess(selectedTier, {key = key, timestamp = os.time()})
            end)
        else
            status.TextColor3 = self.Theme.Colors.Error
            status.Text = "✗ Invalid " .. selectedTier .. " key"
            self.Tween:Play(inputBg, self.Tween.Easings.Fast, {BackgroundColor3 = Color3.fromRGB(80, 40, 40)}, function()
                self.Tween:Play(inputBg, self.Tween.Easings.Smooth, {BackgroundColor3 = self.Theme.Colors.Surface})
            end)
            onFail(key, selectedTier)
        end
    end

    getKeyBtn.MouseButton1Click:Connect(function()
        local link = tiers[selectedTier].KeyLink
        if setclipboard then
            setclipboard(link)
            status.TextColor3 = tiers[selectedTier].Color
            status.Text = "🔗 " .. selectedTier .. " link copied!"
        else
            status.TextColor3 = self.Theme.Colors.Warning
            status.Text = "Visit: " .. link
        end
    end)

    submitBtn.MouseButton1Click:Connect(submit)
    keyInput.FocusLost:Connect(function(enter) if enter then submit() end end)

    self.Tween:HoverEffect(getKeyBtn, self.Theme.Colors.Secondary:Lerp(Color3.new(1,1,1), 0.1), self.Theme.Colors.Secondary)
    self.Tween:HoverEffect(submitBtn, self.Theme.Colors.Primary:Lerp(Color3.new(1,1,1), 0.2), self.Theme.Colors.Primary)

    header.Parent = container
    tierLabel.Parent = container
    tierContainer.Parent = container
    benefitsPanel.Parent = container
    inputBg.Parent = container
    btnContainer.Parent = container
    getKeyBtn.Parent = btnContainer
    submitBtn.Parent = btnContainer
    container.Parent = parent

    selectTier("Free")
    container.Size = UDim2.new(0, 440, 0, 0)
    self.Tween:Play(container, self.Tween.Easings.Bounce, {Size = UDim2.new(0, 440, 0, 360)})

    return {
        Verified = false,
        SkipUI = false,
        Tier = nil,
        Destroy = function() container:Destroy() end
    }
end

-- ============================================
-- BONUS COMPONENTS
-- ============================================

-- CONSOLE / OUTPUT LOG
function UILibrary:CreateConsole(parent, properties)
    properties = properties or {}

    local container = Instance.new("Frame")
    container.Name = properties.Name or "Console"
    container.Size = properties.Size or UDim2.new(1, 0, 0, 200)
    container.BackgroundColor3 = self.Theme.Colors.Background
    container.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 28)
    header.BackgroundColor3 = self.Theme.Colors.Surface
    header.BorderSizePixel = 0

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header

    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 8)
    headerFix.Position = UDim2.new(0, 0, 1, -8)
    headerFix.BackgroundColor3 = self.Theme.Colors.Surface
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local title = Instance.new("TextLabel")
    title.Text = "Output"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextColor3 = self.Theme.Colors.Text
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(0, 80, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0, 50, 0, 20)
    clearBtn.Position = UDim2.new(1, -110, 0, 4)
    clearBtn.BackgroundColor3 = self.Theme.Colors.Secondary
    clearBtn.Text = "Clear"
    clearBtn.Font = Enum.Font.Gotham
    clearBtn.TextSize = 11
    clearBtn.TextColor3 = self.Theme.Colors.Text
    clearBtn.AutoButtonColor = false

    local clearCorner = Instance.new("UICorner")
    clearCorner.CornerRadius = UDim.new(0, 6)
    clearCorner.Parent = clearBtn

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 50, 0, 20)
    copyBtn.Position = UDim2.new(1, -56, 0, 4)
    copyBtn.BackgroundColor3 = self.Theme.Colors.Primary
    copyBtn.Text = "Copy"
    copyBtn.Font = Enum.Font.Gotham
    copyBtn.TextSize = 11
    copyBtn.TextColor3 = self.Theme.Colors.Text
    copyBtn.AutoButtonColor = false

    local copyCorner = Instance.new("UICorner")
    copyCorner.CornerRadius = UDim.new(0, 6)
    copyCorner.Parent = copyBtn

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Scroll"
    scroll.Size = UDim2.new(1, -16, 1, -40)
    scroll.Position = UDim2.new(0, 8, 0, 32)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = self.Theme.Colors.Primary
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

    local logLayout = Instance.new("UIListLayout")
    logLayout.Padding = UDim.new(0, 2)
    logLayout.Parent = scroll

    local logs = {}

    local function addLog(text, logType)
        logType = logType or "Info"
        local colors = {
            Info = self.Theme.Colors.Text,
            Success = self.Theme.Colors.Success,
            Warning = self.Theme.Colors.Warning,
            Error = self.Theme.Colors.Error
        }

        local label = Instance.new("TextLabel")
        label.Text = "[" .. os.date("%H:%M:%S") .. "] " .. text
        label.Font = Enum.Font.Code
        label.TextSize = 12
        label.TextColor3 = colors[logType] or colors.Info
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 0, 18)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextWrapped = true
        label.AutomaticSize = Enum.AutomaticSize.Y
        label.Parent = scroll

        table.insert(logs, label)
        scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
    end

    clearBtn.MouseButton1Click:Connect(function()
        for _, log in ipairs(logs) do
            log:Destroy()
        end
        logs = {}
    end)

    copyBtn.MouseButton1Click:Connect(function()
        local text = ""
        for _, log in ipairs(logs) do
            text = text .. log.Text .. "\n"
        end
        if setclipboard then
            setclipboard(text)
        end
    end)

    header.Parent = container
    clearBtn.Parent = header
    copyBtn.Parent = header
    scroll.Parent = container
    container.Parent = parent

    local api = {}
    function api:Log(text, logType) addLog(text, logType) end
    function api:Clear()
        for _, log in ipairs(logs) do log:Destroy() end
        logs = {}
    end
    return api, container
end

-- SCRIPT HUB
function UILibrary:CreateScriptHub(parent, properties)
    properties = properties or {}
    local scripts = properties.Scripts or {}

    local container = Instance.new("ScrollingFrame")
    container.Name = properties.Name or "ScriptHub"
    container.Size = properties.Size or UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ScrollBarThickness = 4
    container.ScrollBarImageColor3 = self.Theme.Colors.Primary
    container.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 8)
    padding.PaddingRight = UDim.new(0, 8)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = container

    for _, scriptData in ipairs(scripts) do
        local card = Instance.new("Frame")
        card.Name = scriptData.Name or "Script"
        card.Size = UDim2.new(1, 0, 0, 64)
        card.BackgroundColor3 = self.Theme.Colors.Surface
        card.BorderSizePixel = 0

        local cardCorner = Instance.new("UICorner")
        cardCorner.CornerRadius = UDim.new(0, 10)
        cardCorner.Parent = card

        local icon = Instance.new("ImageLabel")
        icon.BackgroundTransparency = 1
        icon.Image = scriptData.Icon or "rbxassetid://3926305904"
        icon.Size = UDim2.new(0, 40, 0, 40)
        icon.Position = UDim2.new(0, 12, 0.5, -20)
        icon.Parent = card

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Text = scriptData.Name or "Script"
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.TextColor3 = self.Theme.Colors.Text
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, -180, 0, 20)
        nameLabel.Position = UDim2.new(0, 64, 0, 8)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        local descLabel = Instance.new("TextLabel")
        descLabel.Text = scriptData.Description or "No description"
        descLabel.Font = Enum.Font.Gotham
        descLabel.TextSize = 12
        descLabel.TextColor3 = self.Theme.Colors.TextMuted
        descLabel.BackgroundTransparency = 1
        descLabel.Size = UDim2.new(1, -180, 0, 20)
        descLabel.Position = UDim2.new(0, 64, 0, 30)
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = card

        local execBtn = Instance.new("TextButton")
        execBtn.Size = UDim2.new(0, 80, 0, 32)
        execBtn.Position = UDim2.new(1, -96, 0.5, -16)
        execBtn.BackgroundColor3 = self.Theme.Colors.Primary
        execBtn.Text = "▶ Run"
        execBtn.Font = Enum.Font.GothamBold
        execBtn.TextSize = 12
        execBtn.TextColor3 = self.Theme.Colors.Text
        execBtn.AutoButtonColor = false

        local execCorner = Instance.new("UICorner")
        execCorner.CornerRadius = UDim.new(0, 8)
        execCorner.Parent = execBtn

        execBtn.MouseButton1Click:Connect(function()
            self.Tween:ClickEffect(execBtn)
            if scriptData.Callback then
                scriptData.Callback()
            end
        end)

        self.Tween:HoverEffect(execBtn, self.Theme.Colors.Primary:Lerp(Color3.new(1,1,1), 0.2), self.Theme.Colors.Primary)
        execBtn.Parent = card
        card.Parent = container
    end

    container.Parent = parent
    return container
end

-- KEYBIND SYSTEM
function UILibrary:CreateKeybind(parent, properties)
    properties = properties or {}
    local defaultKey = properties.Default or Enum.KeyCode.RightControl
    local currentKey = defaultKey
    local listening = false

    local container = Instance.new("Frame")
    container.Name = properties.Name or "Keybind"
    container.Size = properties.Size or UDim2.new(0, 200, 0, 36)
    container.BackgroundTransparency = 1

    local label = Instance.new("TextLabel")
    label.Text = properties.Label or "Toggle Key"
    label.Font = self.Theme.Label.Font
    label.TextSize = self.Theme.Label.TextSize
    label.TextColor3 = self.Theme.Label.TextColor3
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 80, 1, 0)
    keyBtn.Position = UDim2.new(1, -80, 0, 0)
    keyBtn.BackgroundColor3 = self.Theme.Colors.Surface
    keyBtn.Text = defaultKey.Name
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 12
    keyBtn.TextColor3 = self.Theme.Colors.Text
    keyBtn.AutoButtonColor = false

    local keyCorner = Instance.new("UICorner")
    keyCorner.CornerRadius = UDim.new(0, 6)
    keyCorner.Parent = keyBtn

    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        self.Tween:Play(keyBtn, self.Tween.Easings.Fast, {BackgroundColor3 = self.Theme.Colors.Primary})
    end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and not gameProcessed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                currentKey = input.KeyCode
                keyBtn.Text = currentKey.Name
                self.Tween:Play(keyBtn, self.Tween.Easings.Fast, {BackgroundColor3 = self.Theme.Colors.Surface})
                if properties.Callback then
                    properties.Callback(currentKey)
                end
            end
        elseif input.KeyCode == currentKey and not gameProcessed then
            if properties.Action then
                properties.Action()
            end
        end
    end)

    keyBtn.Parent = container
    container.Parent = parent

    local api = {}
    function api:GetKey() return currentKey end
    function api:SetKey(key)
        currentKey = key
        keyBtn.Text = key.Name
    end
    return api, container
end

-- CODE EDITOR (Multi-line with line numbers)
function UILibrary:CreateCodeEditor(parent, properties)
    properties = properties or {}

    local container = Instance.new("Frame")
    container.Name = properties.Name or "CodeEditor"
    container.Size = properties.Size or UDim2.new(1, 0, 0, 200)
    container.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    container.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = container

    local lineNumbers = Instance.new("TextLabel")
    lineNumbers.Name = "LineNumbers"
    lineNumbers.Size = UDim2.new(0, 36, 1, -8)
    lineNumbers.Position = UDim2.new(0, 4, 0, 4)
    lineNumbers.BackgroundTransparency = 1
    lineNumbers.Text = "1"
    lineNumbers.Font = Enum.Font.Code
    lineNumbers.TextSize = 13
    lineNumbers.TextColor3 = Color3.fromRGB(100, 100, 100)
    lineNumbers.TextXAlignment = Enum.TextXAlignment.Right
    lineNumbers.TextYAlignment = Enum.TextYAlignment.Top
    lineNumbers.Parent = container

    local editor = Instance.new("TextBox")
    editor.Name = "Editor"
    editor.Size = UDim2.new(1, -48, 1, -8)
    editor.Position = UDim2.new(0, 44, 0, 4)
    editor.BackgroundTransparency = 1
    editor.Text = properties.Default or ""
    editor.PlaceholderText = "-- Paste script here"
    editor.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
    editor.TextColor3 = Color3.fromRGB(220, 220, 220)
    editor.Font = Enum.Font.Code
    editor.TextSize = 13
    editor.TextXAlignment = Enum.TextXAlignment.Left
    editor.TextYAlignment = Enum.TextYAlignment.Top
    editor.ClearTextOnFocus = false
    editor.MultiLine = true
    editor.TextWrapped = true

    editor:GetPropertyChangedSignal("Text"):Connect(function()
        local lines = 1
        for _ in editor.Text:gmatch("\n") do
            lines = lines + 1
        end
        local nums = ""
        for i = 1, lines do
            nums = nums .. i .. "\n"
        end
        lineNumbers.Text = nums:sub(1, -2)
    end)

    editor.Parent = container
    container.Parent = parent

    local api = {}
    function api:GetText() return editor.Text end
    function api:SetText(text) editor.Text = text end
    function api:Clear() editor.Text = "" end
    return api, container
end

-- COLLAPSIBLE SECTION
function UILibrary:CreateSection(parent, properties)
    properties = properties or {}
    local isOpen = properties.DefaultOpen ~= false

    local container = Instance.new("Frame")
    container.Name = properties.Name or "Section"
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.AutomaticSize = Enum.AutomaticSize.Y

    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 36)
    header.BackgroundColor3 = self.Theme.Colors.Surface
    header.Text = ""
    header.AutoButtonColor = false

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
    headerCorner.Parent = header

    local title = Instance.new("TextLabel")
    title.Text = properties.Title or "Section"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextColor3 = self.Theme.Colors.Text
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.BackgroundTransparency = 1
    arrow.Image = "rbxassetid://7072706663"
    arrow.ImageColor3 = self.Theme.Colors.TextMuted
    arrow.Size = UDim2.new(0, 16, 0, 16)
    arrow.Position = UDim2.new(1, -28, 0.5, -8)
    arrow.Rotation = isOpen and 180 or 0
    arrow.Parent = header

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 40)
    content.BackgroundTransparency = 1
    content.Visible = isOpen
    content.AutomaticSize = Enum.AutomaticSize.Y

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.Parent = content

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingLeft = UDim.new(0, 8)
    contentPadding.PaddingRight = UDim.new(0, 8)
    contentPadding.PaddingTop = UDim.new(0, 4)
    contentPadding.PaddingBottom = UDim.new(0, 8)
    contentPadding.Parent = content

    header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        content.Visible = isOpen
        self.Tween:Play(arrow, self.Tween.Easings.Smooth, {Rotation = isOpen and 180 or 0})
    end)

    header.Parent = container
    content.Parent = container
    container.Parent = parent

    return content, container
end

-- ============================================
-- EXAMPLE USAGE (Comment out when using as module)
-- ============================================
--[[
local UI = require(game.ReplicatedStorage:WaitForChild("UILibrary"))

-- Key System
local keyResult = UI:CreateKeySystem(game.CoreGui, {
    FreeKey = "FREE-KEY-123",
    FreeKeyLink = "https://linkvertise.com/free",
    PremiumKey = "PREM-KEY-456",
    PremiumKeyLink = "https://sellix.io/premium",
    CustomKey = "CUST-KEY-789",
    CustomKeyLink = "https://discord.gg/custom",
    SaveKey = true,
    OnSuccess = function(tier, data)
        print("Verified as:", tier)
    end
})

if keyResult.Verified or keyResult.SkipUI then
    -- Create Window
    local winApi, window = UI:CreateWindow(game.CoreGui, {
        Title = "⚡ Executor Hub",
        Size = UDim2.new(0, 600, 0, 450)
    })

    local content = winApi:GetContent()

    -- Tab System
    local tabApi = UI:CreateTabSystem(content)
    local execTab = tabApi:AddTab({Name = "Executor", Id = "exec"})
    local settingsTab = tabApi:AddTab({Name = "Settings", Id = "settings"})

    -- Code Editor in Executor tab
    local editorApi = UI:CreateCodeEditor(execTab, {Default = "print('Hello World')"})

    -- Console
    local consoleApi = UI:CreateConsole(execTab)
    consoleApi:Log("Executor loaded successfully", "Success")

    -- Script Hub
    UI:CreateScriptHub(execTab, {
        Scripts = {
            {Name = "Infinite Yield", Description = "Admin commands", Callback = function() print("Running IY...") end},
            {Name = "Dex Explorer", Description = "Game explorer", Callback = function() print("Running Dex...") end}
        }
    })

    -- Settings
    UI:CreateToggle(settingsTab, {Label = "Auto Save", Callback = function(v) print(v) end})
    UI:CreateKeybind(settingsTab, {Label = "Toggle UI", Default = Enum.KeyCode.RightControl, Action = function() window.Visible = not window.Visible end})
    UI:CreateColorPicker(settingsTab, {Title = "Accent Color", Callback = function(c) print(c) end})
end
--]]

return UILibrary
