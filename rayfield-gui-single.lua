
-- ═══════════════════════════════════════════════════
-- GUI Library for Roblox (Delta Executor Ready)
-- Inspired by Rayfield
-- Single-File Version
-- ═══════════════════════════════════════════════════

local Library = {}

-- ═══ UTILS ═══
local Utils = {}

function Utils:Create(instanceType, properties)
    local instance = Instance.new(instanceType)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

function Utils:Tween(instance, properties, duration, easingStyle, easingDirection, callback)
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out

    local tweenInfo = TweenInfo.new(duration or 0.3, easingStyle, easingDirection)
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, properties)
    if callback then tween.Completed:Connect(callback) end
    tween:Play()
    return tween
end

function Utils:Ripple(button, mouseX, mouseY, color)
    local ripple = self:Create("Frame", {
        Name = "Ripple",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = color or Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.8,
        Position = UDim2.new(0, mouseX - button.AbsolutePosition.X, 0, mouseY - button.AbsolutePosition.Y),
        Size = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
        ZIndex = button.ZIndex + 1,
        Parent = button
    })

    self:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ripple})

    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2.5
    self:Tween(ripple, {Size = UDim2.new(0, maxSize, 0, maxSize), BackgroundTransparency = 1}, 0.6, nil, nil, function()
        ripple:Destroy()
    end)
end

function Utils:MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput, mousePos, framePos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- ═══ THEME ═══
local Theme = {}

Theme.Presets = {
    Default = {
        Primary = Color3.fromRGB(124, 37, 255),
        Secondary = Color3.fromRGB(88, 28, 200),
        Background = Color3.fromRGB(25, 25, 25),
        Foreground = Color3.fromRGB(30, 30, 30),
        Surface = Color3.fromRGB(35, 35, 35),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(180, 180, 180),
        Success = Color3.fromRGB(0, 255, 127),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(255, 82, 82),
        Border = Color3.fromRGB(50, 50, 50),
        CornerRadius = 8,
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
    },
    Ocean = {
        Primary = Color3.fromRGB(0, 150, 255),
        Secondary = Color3.fromRGB(0, 100, 200),
        Background = Color3.fromRGB(15, 20, 30),
        Foreground = Color3.fromRGB(20, 28, 40),
        Surface = Color3.fromRGB(25, 35, 50),
        TextPrimary = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(160, 180, 200),
        Success = Color3.fromRGB(0, 255, 150),
        Warning = Color3.fromRGB(255, 200, 50),
        Error = Color3.fromRGB(255, 80, 80),
        Border = Color3.fromRGB(40, 55, 75),
        CornerRadius = 10,
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
    },
    Midnight = {
        Primary = Color3.fromRGB(255, 50, 100),
        Secondary = Color3.fromRGB(200, 30, 70),
        Background = Color3.fromRGB(10, 10, 15),
        Foreground = Color3.fromRGB(18, 18, 25),
        Surface = Color3.fromRGB(25, 25, 35),
        TextPrimary = Color3.fromRGB(240, 240, 245),
        TextSecondary = Color3.fromRGB(140, 140, 160),
        Success = Color3.fromRGB(50, 255, 150),
        Warning = Color3.fromRGB(255, 180, 50),
        Error = Color3.fromRGB(255, 70, 70),
        Border = Color3.fromRGB(40, 40, 55),
        CornerRadius = 6,
        Font = Enum.Font.Gotham,
        FontBold = Enum.Font.GothamBold,
        FontMedium = Enum.Font.GothamMedium,
    },
}

Theme.Current = nil

function Theme:Set(themeName)
    if self.Presets[themeName] then
        self.Current = self.Presets[themeName]
    elseif type(themeName) == "table" then
        self.Current = themeName
    else
        self.Current = self.Presets.Default
    end
    return self.Current
end

function Theme:Get()
    if not self.Current then self.Current = self.Presets.Default end
    return self.Current
end

-- ═══ ANIMATION ═══
local Animation = {}

function Animation:Tween(instance, properties, duration, style, direction, callback)
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    duration = duration or 0.3

    local tweenInfo = TweenInfo.new(duration, style, direction)
    local tween = game:GetService("TweenService"):Create(instance, tweenInfo, properties)
    if callback then tween.Completed:Connect(callback) end
    tween:Play()
    return tween
end

-- ═══ COMPONENTS ═══
local Components = {}

function Components:CreateBase(name, parent, theme)
    theme = theme or Theme:Get()
    local base = Utils:Create("Frame", {
        Name = name,
        BackgroundColor3 = theme.Foreground,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 40),
        Position = UDim2.new(0, 10, 0, 0),
        Parent = parent,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, theme.CornerRadius), Parent = base})
    return base
end

function Components:Label(config)
    local theme = Theme:Get()
    local base = self:CreateBase("Label", config.Parent, theme)
    base.Size = UDim2.new(1, -20, 0, 30)
    base.BackgroundTransparency = 1

    local label = Utils:Create("TextLabel", {
        Name = "Text", Text = config.Text or "Label",
        Font = theme.Font, TextSize = 14, TextColor3 = config.Color or theme.TextPrimary,
        BackgroundTransparency = 1, Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })

    return {Instance = base, Set = function(self, newText) label.Text = newText end}
end

function Components:Button(config)
    local theme = Theme:Get()
    local callback = config.Callback or function() end
    local base = self:CreateBase("Button", config.Parent, theme)
    base.Size = UDim2.new(1, -20, 0, 36)

    Utils:Create("UIStroke", {Color = theme.Border, Thickness = 1, Transparency = 0.5, Parent = base})

    local label = Utils:Create("TextLabel", {
        Name = "Text", Text = config.Text or "Button",
        Font = theme.FontBold, TextSize = 13, TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = base,
    })

    local hover = Utils:Create("Frame", {
        Name = "Hover", BackgroundColor3 = theme.Primary, BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0, ZIndex = 2, Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, theme.CornerRadius), Parent = hover})

    local isHovering = false
    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            isHovering = true
            Animation:Tween(hover, {BackgroundTransparency = 0.9}, 0.2)
            Animation:Tween(base, {BackgroundColor3 = theme.Surface}, 0.2)
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
            local pos = game:GetService("UserInputService"):GetMouseLocation()
            Utils:Ripple(base, pos.X, pos.Y, theme.Primary)
            Animation:Tween(base, {BackgroundColor3 = theme.Secondary}, 0.1, nil, nil, function()
                Animation:Tween(base, {BackgroundColor3 = isHovering and theme.Surface or theme.Foreground}, 0.2)
            end)
            callback()
        end
    end)

    base.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            isHovering = false
            Animation:Tween(hover, {BackgroundTransparency = 1}, 0.2)
            Animation:Tween(base, {BackgroundColor3 = theme.Foreground}, 0.2)
        end
    end)

    return {Instance = base, SetText = function(self, newText) label.Text = newText end}
end

function Components:Toggle(config)
    local theme = Theme:Get()
    local callback = config.Callback or function() end
    local base = self:CreateBase("Toggle", config.Parent, theme)
    base.Size = UDim2.new(1, -20, 0, 40)

    Utils:Create("TextLabel", {
        Name = "Text", Text = config.Text or "Toggle",
        Font = theme.Font, TextSize = 14, TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1, Size = UDim2.new(1, -70, 1, 0),
        Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })

    local toggleBg = Utils:Create("Frame", {
        Name = "ToggleBg", BackgroundColor3 = theme.Border, BorderSizePixel = 0,
        Size = UDim2.new(0, 44, 0, 24), Position = UDim2.new(1, -54, 0.5, -12), Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = toggleBg})

    local knob = Utils:Create("Frame", {
        Name = "Knob", BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
        Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 3, 0.5, -9), Parent = toggleBg,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

    local state = config.Default or false

    local function updateToggle()
        if state then
            Animation:Tween(toggleBg, {BackgroundColor3 = theme.Primary}, 0.2)
            Animation:Tween(knob, {Position = UDim2.new(0, 23, 0.5, -9)}, 0.2)
        else
            Animation:Tween(toggleBg, {BackgroundColor3 = theme.Border}, 0.2)
            Animation:Tween(knob, {Position = UDim2.new(0, 3, 0.5, -9)}, 0.2)
        end
        callback(state)
    end

    if state then updateToggle() end

    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            updateToggle()
        end
    end)

    return {
        Instance = base,
        GetState = function() return state end,
        SetState = function(self, newState) state = newState; updateToggle() end,
    }
end

function Components:Slider(config)
    local theme = Theme:Get()
    local callback = config.Callback or function() end
    local min, max = config.Min or 0, config.Max or 100
    local increment = config.Increment or 1
    local base = self:CreateBase("Slider", config.Parent, theme)
    base.Size = UDim2.new(1, -20, 0, 50)

    Utils:Create("TextLabel", {
        Name = "Text", Text = config.Text or "Slider",
        Font = theme.Font, TextSize = 14, TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1, Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.new(0, 10, 0, 5), TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })

    local valueLabel = Utils:Create("TextLabel", {
        Name = "Value", Text = tostring(config.Default or min),
        Font = theme.FontBold, TextSize = 13, TextColor3 = theme.Primary,
        BackgroundTransparency = 1, Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -70, 0, 5), TextXAlignment = Enum.TextXAlignment.Right, Parent = base,
    })

    local track = Utils:Create("Frame", {
        Name = "Track", BackgroundColor3 = theme.Border, BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 0, 34), Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})

    local fill = Utils:Create("Frame", {
        Name = "Fill", BackgroundColor3 = theme.Primary, BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0), Parent = track,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})

    local knob = Utils:Create("Frame", {
        Name = "Knob", BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
        Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, -7, 0.5, -7), Parent = track,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

    local dragging = false
    local currentValue = config.Default or min

    local function updateValue(input)
        local pos = input.Position.X
        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local relative = math.clamp((pos - trackPos) / trackSize, 0, 1)
        local rawValue = min + (max - min) * relative
        currentValue = math.floor(rawValue / increment + 0.5) * increment
        currentValue = math.clamp(currentValue, min, max)

        local scale = (currentValue - min) / (max - min)
        fill.Size = UDim2.new(scale, 0, 1, 0)
        knob.Position = UDim2.new(scale, -7, 0.5, -7)
        valueLabel.Text = tostring(currentValue)
        callback(currentValue)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            updateValue(input)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input)
        end
    end)

    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return {
        Instance = base,
        GetValue = function() return currentValue end,
        SetValue = function(self, val)
            currentValue = math.clamp(val, min, max)
            local scale = (currentValue - min) / (max - min)
            fill.Size = UDim2.new(scale, 0, 1, 0)
            knob.Position = UDim2.new(scale, -7, 0.5, -7)
            valueLabel.Text = tostring(currentValue)
            callback(currentValue)
        end,
    }
end

function Components:Dropdown(config)
    local theme = Theme:Get()
    local callback = config.Callback or function() end
    local options = config.Options or {}
    local base = self:CreateBase("Dropdown", config.Parent, theme)
    base.Size = UDim2.new(1, -20, 0, 40)

    Utils:Create("TextLabel", {
        Name = "Text", Text = config.Text or "Dropdown",
        Font = theme.Font, TextSize = 14, TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1, Size = UDim2.new(1, -140, 1, 0),
        Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })

    local selected = Utils:Create("TextLabel", {
        Name = "Selected", Text = config.Default or "Select...",
        Font = theme.FontMedium, TextSize = 13, TextColor3 = theme.TextSecondary,
        BackgroundTransparency = 1, Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -120, 0, 0), TextXAlignment = Enum.TextXAlignment.Right, Parent = base,
    })

    local arrow = Utils:Create("TextLabel", {
        Name = "Arrow", Text = "▼", Font = theme.Font, TextSize = 10,
        TextColor3 = theme.TextSecondary, BackgroundTransparency = 1,
        Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -25, 0, 0), Parent = base,
    })

    local dropdownFrame = Utils:Create("Frame", {
        Name = "DropdownFrame", BackgroundColor3 = theme.Surface, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0), Position = UDim2.new(0, 0, 0, 42),
        Visible = false, ZIndex = 10, ClipsDescendants = true, Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, theme.CornerRadius), Parent = dropdownFrame})
    Utils:Create("UIStroke", {Color = theme.Border, Thickness = 1, Parent = dropdownFrame})
    Utils:Create("UIListLayout", {Padding = UDim.new(0, 2), Parent = dropdownFrame})

    local open = false
    local currentSelection = config.Default

    local function createOption(optionText)
        local btn = Utils:Create("TextButton", {
            Name = optionText, Text = optionText, Font = theme.Font, TextSize = 13,
            TextColor3 = theme.TextSecondary, BackgroundColor3 = theme.Surface,
            BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 32), ZIndex = 11, Parent = dropdownFrame,
        })
        btn.MouseEnter:Connect(function()
            Animation:Tween(btn, {BackgroundColor3 = theme.Primary, TextColor3 = Color3.fromRGB(255,255,255)}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            Animation:Tween(btn, {BackgroundColor3 = theme.Surface, TextColor3 = theme.TextSecondary}, 0.15)
        end)
        btn.MouseButton1Click:Connect(function()
            currentSelection = optionText
            selected.Text = optionText
            open = false
            Animation:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            arrow.Text = "▼"
            callback(optionText)
        end)
    end

    for _, opt in ipairs(options) do createOption(opt) end

    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            open = not open
            if open then
                dropdownFrame.Visible = true
                Animation:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, math.min(#options * 34 + 4, 200))}, 0.2)
                arrow.Text = "▲"
            else
                Animation:Tween(dropdownFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2, nil, nil, function()
                    dropdownFrame.Visible = false
                end)
                arrow.Text = "▼"
            end
        end
    end)

    return {
        Instance = base,
        GetSelected = function() return currentSelection end,
        SetOptions = function(self, newOptions)
            for _, child in ipairs(dropdownFrame:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            options = newOptions
            for _, opt in ipairs(options) do createOption(opt) end
        end,
    }
end

function Components:Input(config)
    local theme = Theme:Get()
    local callback = config.Callback or function() end
    local base = self:CreateBase("Input", config.Parent, theme)
    base.Size = UDim2.new(1, -20, 0, 40)

    Utils:Create("TextLabel", {
        Name = "Text", Text = config.Text or "Input",
        Font = theme.Font, TextSize = 14, TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1, Size = UDim2.new(1, -160, 1, 0),
        Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })

    local inputBox = Utils:Create("TextBox", {
        Name = "InputBox", Text = config.Default or "",
        PlaceholderText = config.Placeholder or "Type here...",
        Font = theme.Font, TextSize = 13, TextColor3 = theme.TextPrimary,
        PlaceholderColor3 = theme.TextSecondary, BackgroundColor3 = theme.Background,
        BorderSizePixel = 0, Size = UDim2.new(0, 140, 0, 28),
        Position = UDim2.new(1, -150, 0.5, -14), ClearTextOnFocus = false, Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, math.max(theme.CornerRadius - 2, 4)), Parent = inputBox})

    local stroke = Utils:Create("UIStroke", {Color = theme.Border, Thickness = 1, Parent = inputBox})

    inputBox.Focused:Connect(function() Animation:Tween(stroke, {Color = theme.Primary}, 0.2) end)
    inputBox.FocusLost:Connect(function() Animation:Tween(stroke, {Color = theme.Border}, 0.2); callback(inputBox.Text) end)

    return {
        Instance = base,
        GetText = function() return inputBox.Text end,
        SetText = function(self, text) inputBox.Text = text; callback(text) end,
    }
end

function Components:Keybind(config)
    local theme = Theme:Get()
    local callback = config.Callback or function() end
    local base = self:CreateBase("Keybind", config.Parent, theme)
    base.Size = UDim2.new(1, -20, 0, 40)

    Utils:Create("TextLabel", {
        Name = "Text", Text = config.Text or "Keybind",
        Font = theme.Font, TextSize = 14, TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1, Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })

    local keyLabel = Utils:Create("TextLabel", {
        Name = "Key", Text = (config.Default or Enum.KeyCode.E).Name,
        Font = theme.FontBold, TextSize = 12, TextColor3 = theme.Primary,
        BackgroundColor3 = theme.Background, BorderSizePixel = 0,
        Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(1, -70, 0.5, -13), Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = keyLabel})
    local stroke = Utils:Create("UIStroke", {Color = theme.Border, Thickness = 1, Parent = keyLabel})

    local listening = false
    local currentKey = config.Default or Enum.KeyCode.E

    local function listenForKey()
        listening = true
        keyLabel.Text = "..."
        Animation:Tween(stroke, {Color = theme.Primary}, 0.2)
        local connection
        connection = game:GetService("UserInputService").InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                if input.KeyCode ~= Enum.KeyCode.Escape then
                    currentKey = input.KeyCode
                    keyLabel.Text = input.KeyCode.Name
                    callback(input.KeyCode)
                end
                listening = false
                Animation:Tween(stroke, {Color = theme.Border}, 0.2)
                connection:Disconnect()
            end
        end)
    end

    keyLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not listening then
            listenForKey()
        end
    end)

    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.KeyCode == currentKey and not listening then callback(currentKey) end
    end)

    return {
        Instance = base,
        GetKey = function() return currentKey end,
        SetKey = function(self, keyCode) currentKey = keyCode; keyLabel.Text = keyCode.Name end,
    }
end

function Components:ColorPicker(config)
    local theme = Theme:Get()
    local callback = config.Callback or function() end
    local base = self:CreateBase("ColorPicker", config.Parent, theme)
    base.Size = UDim2.new(1, -20, 0, 40)

    Utils:Create("TextLabel", {
        Name = "Text", Text = config.Text or "Color",
        Font = theme.Font, TextSize = 14, TextColor3 = theme.TextPrimary,
        BackgroundTransparency = 1, Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 10, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, Parent = base,
    })

    local colorPreview = Utils:Create("Frame", {
        Name = "Preview", BackgroundColor3 = config.Default or Color3.fromRGB(124, 37, 255),
        BorderSizePixel = 0, Size = UDim2.new(0, 36, 0, 26),
        Position = UDim2.new(1, -46, 0.5, -13), Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = colorPreview})
    Utils:Create("UIStroke", {Color = theme.Border, Thickness = 1, Parent = colorPreview})

    local pickerOpen = false
    local currentColor = config.Default or Color3.fromRGB(124, 37, 255)

    local pickerFrame = Utils:Create("Frame", {
        Name = "PickerFrame", BackgroundColor3 = theme.Surface, BorderSizePixel = 0,
        Size = UDim2.new(0, 200, 0, 0), Position = UDim2.new(1, -210, 0, 42),
        Visible = false, ZIndex = 15, Parent = base,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, theme.CornerRadius), Parent = pickerFrame})
    Utils:Create("UIStroke", {Color = theme.Border, Thickness = 1, Parent = pickerFrame})
    Utils:Create("UIGridLayout", {CellSize = UDim2.new(0, 36, 0, 36), CellPadding = UDim2.new(0, 8, 0, 8), Parent = pickerFrame})

    local presets = {
        Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 127, 0), Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(127, 0, 255), Color3.fromRGB(255, 0, 255), Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(124, 37, 255), Color3.fromRGB(255, 50, 100), Color3.fromRGB(0, 150, 255),
    }

    for i, color in ipairs(presets) do
        local swatch = Utils:Create("TextButton", {
            Name = "Swatch" .. i, BackgroundColor3 = color, BorderSizePixel = 0,
            Size = UDim2.new(0, 36, 0, 36), ZIndex = 16, Parent = pickerFrame,
        })
        Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = swatch})
        swatch.MouseButton1Click:Connect(function()
            currentColor = color
            colorPreview.BackgroundColor3 = color
            pickerOpen = false
            Animation:Tween(pickerFrame, {Size = UDim2.new(0, 200, 0, 0)}, 0.2, nil, nil, function()
                pickerFrame.Visible = false
            end)
            callback(color)
        end)
    end

    base.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            pickerOpen = not pickerOpen
            if pickerOpen then
                pickerFrame.Visible = true
                Animation:Tween(pickerFrame, {Size = UDim2.new(0, 200, 0, 140)}, 0.2)
            else
                Animation:Tween(pickerFrame, {Size = UDim2.new(0, 200, 0, 0)}, 0.2, nil, nil, function()
                    pickerFrame.Visible = false
                end)
            end
        end
    end)

    return {
        Instance = base,
        GetColor = function() return currentColor end,
        SetColor = function(self, color) currentColor = color; colorPreview.BackgroundColor3 = color; callback(color) end,
    }
end

function Components:Divider(config)
    local theme = Theme:Get()
    local base = Utils:Create("Frame", {
        Name = "Divider", BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, config.Text and 30 or 16),
        Position = UDim2.new(0, 10, 0, 0), Parent = config.Parent,
    })

    if config.Text then
        Utils:Create("Frame", {BackgroundColor3 = theme.Border, BorderSizePixel = 0, Size = UDim2.new(0.5, -50, 0, 1), Position = UDim2.new(0, 0, 0.5, 0), Parent = base})
        Utils:Create("Frame", {BackgroundColor3 = theme.Border, BorderSizePixel = 0, Size = UDim2.new(0.5, -50, 0, 1), Position = UDim2.new(0.5, 50, 0.5, 0), Parent = base})
        Utils:Create("TextLabel", {Text = config.Text, Font = theme.FontMedium, TextSize = 12, TextColor3 = theme.TextSecondary, BackgroundTransparency = 1, Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(0.5, -50, 0, 0), Parent = base})
    else
        Utils:Create("Frame", {BackgroundColor3 = theme.Border, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 0.5, 0), Parent = base})
    end

    return {Instance = base}
end

-- ═══ NOTIFICATION SYSTEM ═══
local NotificationSystem = {}
NotificationSystem.Queue = {}
NotificationSystem.Active = {}

function NotificationSystem:Init(parent)
    self.Container = Utils:Create("Frame", {
        Name = "Notifications", BackgroundTransparency = 1,
        Size = UDim2.new(0, 320, 1, 0), Position = UDim2.new(1, -340, 0, 20), Parent = parent,
    })
    Utils:Create("UIListLayout", {Padding = UDim.new(0, 10), HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Top, Parent = self.Container})
end

function NotificationSystem:Notify(config)
    local theme = Theme:Get()
    local title = config.Title or "Notification"
    local content = config.Content or ""
    local duration = config.Duration or 5
    local notifType = config.Type or "Info"

    local colors = {Info = theme.Primary, Success = theme.Success, Warning = theme.Warning, Error = theme.Error}

    local notif = Utils:Create("Frame", {
        Name = "Notification", BackgroundColor3 = theme.Surface, BorderSizePixel = 0,
        Size = UDim2.new(0, 300, 0, 0), ClipsDescendants = true, Parent = self.Container,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, theme.CornerRadius), Parent = notif})
    Utils:Create("UIStroke", {Color = colors[notifType] or theme.Primary, Thickness = 2, Parent = notif})

    local iconText = notifType == "Success" and "✓" or notifType == "Warning" and "⚠" or notifType == "Error" and "✕" or "ℹ"
    Utils:Create("TextLabel", {Name = "Icon", Text = iconText, Font = theme.FontBold, TextSize = 18, TextColor3 = colors[notifType] or theme.Primary, BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, 10, 0, 10), Parent = notif})

    Utils:Create("TextLabel", {Name = "Title", Text = title, Font = theme.FontBold, TextSize = 14, TextColor3 = theme.TextPrimary, BackgroundTransparency = 1, Size = UDim2.new(1, -50, 0, 20), Position = UDim2.new(0, 45, 0, 10), TextXAlignment = Enum.TextXAlignment.Left, Parent = notif})

    local contentLabel = Utils:Create("TextLabel", {Name = "Content", Text = content, Font = theme.Font, TextSize = 12, TextColor3 = theme.TextSecondary, BackgroundTransparency = 1, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 35), TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, Parent = notif})

    local closeBtn = Utils:Create("TextButton", {Name = "Close", Text = "✕", Font = theme.FontBold, TextSize = 14, TextColor3 = theme.TextSecondary, BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -25, 0, 8), Parent = notif})

    local contentHeight = math.max(20, contentLabel.TextBounds.Y)
    local targetHeight = 50 + contentHeight

    Animation:Tween(notif, {Size = UDim2.new(0, 300, 0, targetHeight)}, 0.3, Enum.EasingStyle.Back)

    local function dismiss()
        Animation:Tween(notif, {Size = UDim2.new(0, 300, 0, 0)}, 0.2, nil, nil, function() notif:Destroy() end)
    end

    closeBtn.MouseButton1Click:Connect(dismiss)
    if duration > 0 then task.delay(duration, dismiss) end

    return notif
end

-- ═══ MAIN WINDOW ═══
function Library:CreateWindow(config)
    config = config or {}
    local theme = Theme:Set(config.Theme or "Default")

    local windowName = config.Name or "GUI Library"
    local keybind = config.Keybind or Enum.KeyCode.RightShift

    -- ScreenGui
    local screenGui = Utils:Create("ScreenGui", {
        Name = windowName .. "_GUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
    })

    -- Protect GUI for executors
    if syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = game:GetService("CoreGui")
    elseif gethui then
        screenGui.Parent = gethui()
    else
        screenGui.Parent = game:GetService("CoreGui")
    end

    -- Main Frame
    local mainFrame = Utils:Create("Frame", {
        Name = "MainWindow", BackgroundColor3 = theme.Background, BorderSizePixel = 0,
        Size = UDim2.new(0, 580, 0, 420), Position = UDim2.new(0.5, -290, 0.5, -210),
        ClipsDescendants = true, Parent = screenGui,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = mainFrame})

    -- Shadow
    Utils:Create("ImageLabel", {
        Name = "Shadow", BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805", ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5, ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        Size = UDim2.new(1, 40, 1, 40), Position = UDim2.new(0, -20, 0, -20),
        ZIndex = 0, Parent = mainFrame,
    })

    -- Title Bar
    local titleBar = Utils:Create("Frame", {
        Name = "TitleBar", BackgroundColor3 = theme.Foreground, BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42), Parent = mainFrame,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = titleBar})
    Utils:Create("Frame", {BackgroundColor3 = theme.Foreground, BorderSizePixel = 0, Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -12), Parent = titleBar})

    Utils:Create("TextLabel", {
        Name = "Title", Text = windowName, Font = theme.FontBold, TextSize = 16,
        TextColor3 = theme.TextPrimary, BackgroundTransparency = 1,
        Size = UDim2.new(1, -120, 1, 0), Position = UDim2.new(0, 15, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left, Parent = titleBar,
    })

    -- Close button
    local closeBtn = Utils:Create("TextButton", {
        Name = "Close", Text = "", BackgroundColor3 = theme.Error, BorderSizePixel = 0,
        Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -35, 0.5, -7), Parent = titleBar,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = closeBtn})

    -- Minimize button
    local minBtn = Utils:Create("TextButton", {
        Name = "Minimize", Text = "", BackgroundColor3 = theme.Warning, BorderSizePixel = 0,
        Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(1, -58, 0.5, -7), Parent = titleBar,
    })
    Utils:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = minBtn})

    -- Sidebar
    local sidebar = Utils:Create("Frame", {
        Name = "Sidebar", BackgroundColor3 = theme.Foreground, BorderSizePixel = 0,
        Size = UDim2.new(0, 160, 1, -42), Position = UDim2.new(0, 0, 0, 42), Parent = mainFrame,
    })
    Utils:Create("UIListLayout", {Padding = UDim.new(0, 4), Parent = sidebar})
    Utils:Create("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = sidebar})

    -- Content
    local contentFrame = Utils:Create("Frame", {
        Name = "Content", BackgroundTransparency = 1, BorderSizePixel = 0,
        Size = UDim2.new(1, -170, 1, -52), Position = UDim2.new(0, 165, 0, 47),
        ClipsDescendants = true, Parent = mainFrame,
    })
    Utils:Create("UIListLayout", {Padding = UDim.new(0, 8), Parent = contentFrame})
    Utils:Create("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10), Parent = contentFrame})

    local tabs = {}
    local currentTab = nil

    Utils:MakeDraggable(mainFrame, titleBar)

    -- Minimize
    local minimized = false
    local originalSize = mainFrame.Size
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            Animation:Tween(mainFrame, {Size = UDim2.new(0, 580, 0, 42)}, 0.3)
        else
            Animation:Tween(mainFrame, {Size = originalSize}, 0.3)
        end
    end)

    -- Close
    closeBtn.MouseButton1Click:Connect(function()
        Animation:Tween(mainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In, function()
            screenGui:Destroy()
        end)
    end)

    -- Keybind toggle
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.KeyCode == keybind then
            screenGui.Enabled = not screenGui.Enabled
        end
    end)

    -- Init notifications
    NotificationSystem:Init(screenGui)

    -- Window object
    local window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,

        CreateTab = function(self, tabConfig)
            tabConfig = tabConfig or {}
            local tabName = tabConfig.Name or "Tab"

            local tabBtn = Utils:Create("TextButton", {
                Name = tabName .. "_Tab", Text = "      " .. tabName,
                Font = theme.FontMedium, TextSize = 13, TextColor3 = theme.TextSecondary,
                BackgroundColor3 = theme.Background, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 34), Parent = sidebar,
            })
            Utils:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = tabBtn})

            local indicator = Utils:Create("Frame", {
                Name = "Indicator", BackgroundColor3 = theme.Primary, BorderSizePixel = 0,
                Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5), Parent = tabBtn,
            })
            Utils:Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = indicator})

            local tabContent = Utils:Create("ScrollingFrame", {
                Name = tabName .. "_Content", BackgroundTransparency = 1, BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 1, 0), ScrollBarThickness = 3,
                ScrollBarImageColor3 = theme.Primary, Visible = false, Parent = contentFrame,
            })
            Utils:Create("UIListLayout", {Padding = UDim.new(0, 8), Parent = tabContent})
            Utils:Create("UIPadding", {PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10), Parent = tabContent})

            local tab = {
                Name = tabName,
                Button = tabBtn,
                Content = tabContent,

                CreateSection = function(self, sectionConfig)
                    sectionConfig = sectionConfig or {}
                    local sectionName = sectionConfig.Name or "Section"

                    local sectionFrame = Utils:Create("Frame", {
                        Name = sectionName, BackgroundColor3 = theme.Foreground, BorderSizePixel = 0,
                        Size = UDim2.new(1, -10, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = tabContent,
                    })
                    Utils:Create("UICorner", {CornerRadius = UDim.new(0, theme.CornerRadius), Parent = sectionFrame})

                    Utils:Create("TextLabel", {
                        Name = "Title", Text = sectionName, Font = theme.FontBold, TextSize = 14,
                        TextColor3 = theme.TextPrimary, BackgroundTransparency = 1,
                        Size = UDim2.new(1, -20, 0, 28), Position = UDim2.new(0, 10, 0, 5),
                        TextXAlignment = Enum.TextXAlignment.Left, Parent = sectionFrame,
                    })

                    local sectionContent = Utils:Create("Frame", {
                        Name = "Content", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0),
                        Position = UDim2.new(0, 0, 0, 32), AutomaticSize = Enum.AutomaticSize.Y, Parent = sectionFrame,
                    })
                    Utils:Create("UIListLayout", {Padding = UDim.new(0, 6), Parent = sectionContent})
                    Utils:Create("UIPadding", {PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10), Parent = sectionContent})

                    sectionContent:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        sectionFrame.Size = UDim2.new(1, -10, 0, sectionContent.AbsoluteContentSize.Y + 42)
                    end)

                    local section = {
                        Instance = sectionFrame,
                        CreateLabel = function(self, c) c = c or {}; c.Parent = sectionContent; return Components:Label(c) end,
                        CreateParagraph = function(self, c) c = c or {}; c.Parent = sectionContent; return Components:Paragraph(c) end,
                        CreateButton = function(self, c) c = c or {}; c.Parent = sectionContent; return Components:Button(c) end,
                        CreateToggle = function(self, c) c = c or {}; c.Parent = sectionContent; return Components:Toggle(c) end,
                        CreateSlider = function(self, c) c = c or {}; c.Parent = sectionContent; return Components:Slider(c) end,
                        CreateDropdown = function(self, c) c = c or {}; c.Parent = sectionContent; return Components:Dropdown(c) end,
                        CreateInput = function(self, c) c = c or {}; c.Parent = sectionContent; return Components:Input(c) end,
                        CreateKeybind = function(self, c) c = c or {}; c.Parent = sectionContent; return Components:Keybind(c) end,
                        CreateColorPicker = function(self, c) c = c or {}; c.Parent = sectionContent; return Components:ColorPicker(c) end,
                        CreateDivider = function(self, c) c = c or {}; c.Parent = sectionContent; return Components:Divider(c) end,
                    }
                    return section
                end,
            }

            tabBtn.MouseButton1Click:Connect(function()
                if currentTab == tab then return end
                if currentTab then
                    Animation:Tween(currentTab.Button, {BackgroundColor3 = theme.Background}, 0.2)
                    currentTab.Button.TextColor3 = theme.TextSecondary
                    currentTab.Button.Indicator.Size = UDim2.new(0, 3, 0, 0)
                    currentTab.Content.Visible = false
                end
                currentTab = tab
                Animation:Tween(tabBtn, {BackgroundColor3 = theme.Surface}, 0.2)
                tabBtn.TextColor3 = theme.TextPrimary
                Animation:Tween(indicator, {Size = UDim2.new(0, 3, 0, 20)}, 0.3, Enum.EasingStyle.Back)
                tabContent.Visible = true
            end)

            tabContent:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                tabContent.CanvasSize = UDim2.new(0, 0, 0, tabContent.AbsoluteContentSize.Y + 20)
            end)

            table.insert(tabs, tab)
            if #tabs == 1 then tabBtn.MouseButton1Click:Fire() end
            return tab
        end,

        Notify = function(self, notifyConfig)
            return NotificationSystem:Notify(notifyConfig)
        end,

        Destroy = function(self) screenGui:Destroy() end,
    }

    -- Entrance animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundTransparency = 1
    Animation:Tween(mainFrame, {Size = UDim2.new(0, 580, 0, 420), BackgroundTransparency = 0}, 0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    return window
end

return Library
