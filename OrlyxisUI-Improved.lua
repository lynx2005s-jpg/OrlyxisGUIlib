local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local Library = {}
local AllGuis = {}
local NotificationGui = nil

-- [ TEMA UI - KOTAK ] --
local Theme = {
	Background = Color3.fromRGB(29, 29, 33),
	BackgroundLight = Color3.fromRGB(40, 40, 46),
	BackgroundHover = Color3.fromRGB(55, 55, 65),
	Stroke = Color3.fromRGB(110, 41, 218),
	StrokeDim = Color3.fromRGB(80, 40, 160),
	Text = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(180, 180, 190),
	Accent = Color3.fromRGB(130, 80, 230),
	Font = Font.new("rbxasset://fonts/families/Balthazar.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
}

local function MakeStroke(parent, color, thick)
	local s = Instance.new("UIStroke", parent)
	s.LineJoinMode = Enum.LineJoinMode.Miter
	s.Thickness = thick or 2
	s.Color = color or Theme.Stroke
	return s
end

local function MakeCorner(parent, radius)
	local c = Instance.new("UICorner", parent)
	c.CornerRadius = UDim.new(0, radius or 6)
	return c
end

-- [ FITUR: TRIPLE-CLICK TOGGLE GUI - FIXED: NO VISUAL INDICATOR ] --
local function SetupTripleClickToggle()
	local player = Players.LocalPlayer

	-- TIDAK ADA GUI YANG DIBUAT - Benar-benar invisible saat toggle
	local clickCount = 0
	local lastClickTime = 0
	local TIME_TO_RESET = 1.0
	local CENTER_ZONE_PERCENTAGE = 0.4

	RunService.RenderStepped:Connect(function()
		if clickCount > 0 then
			if (os.clock() - lastClickTime) >= TIME_TO_RESET then
				clickCount = 0
			end
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local camera = workspace.CurrentCamera
			if not camera then return end
			local viewportSize = camera.ViewportSize
			local inputPos = input.Position

			local zoneWidth = viewportSize.X * CENTER_ZONE_PERCENTAGE
			local zoneHeight = viewportSize.Y * CENTER_ZONE_PERCENTAGE

			local minX = (viewportSize.X - zoneWidth) / 2
			local maxX = minX + zoneWidth
			local minY = (viewportSize.Y - zoneHeight) / 2
			local maxY = minY + zoneHeight

			if inputPos.X >= minX and inputPos.X <= maxX and inputPos.Y >= minY and inputPos.Y <= maxY then
				lastClickTime = os.clock()
				clickCount += 1

				if clickCount >= 3 then
					clickCount = 0
					local anyVisible = false
					for _, gui in ipairs(AllGuis) do
						if gui and gui.Parent and gui.Enabled then
							anyVisible = true
							break
						end
					end

					local newState = not anyVisible
					for _, gui in ipairs(AllGuis) do
						if gui and gui.Parent then
							gui.Enabled = newState
						end
					end
				end
			end
		end
	end)
end

-- [ SISTEM NOTIFIKASI KEREN ] --
local function GetNotifyGui()
	if NotificationGui then return NotificationGui end
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local sg = Instance.new("ScreenGui")
	sg.Name = "OrlyxisNotify"
	sg.ResetOnSpawn = false
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.Parent = playerGui
	NotificationGui = sg

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.new(0, 340, 1, -20)
	container.Position = UDim2.new(1, -360, 0, 10)
	container.BackgroundTransparency = 1
	container.Parent = sg

	local list = Instance.new("UIListLayout", container)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 10)
	list.VerticalAlignment = Enum.VerticalAlignment.Top
	list.HorizontalAlignment = Enum.HorizontalAlignment.Right

	return NotificationGui
end

function Library:Notify(config)
	config = config or {}
	local title = config.Title or "Notification"
	local content = config.Content or ""
	local duration = config.Duration or 4
	local typeColor = config.Color or Theme.Accent

	local gui = GetNotifyGui()
	local container = gui:FindFirstChild("Container")

	local notifFrame = Instance.new("Frame")
	notifFrame.Size = UDim2.new(0, 320, 0, 0)
	notifFrame.BackgroundColor3 = Theme.Background
	notifFrame.BorderSizePixel = 0
	notifFrame.ClipsDescendants = true
	notifFrame.Parent = container
	MakeCorner(notifFrame, 14)
	MakeStroke(notifFrame, typeColor, 1.5)

	-- Glassmorphism background
	local glass = Instance.new("Frame", notifFrame)
	glass.Size = UDim2.new(1, 0, 1, 0)
	glass.BackgroundColor3 = Theme.Background
	glass.BackgroundTransparency = 0.15
	glass.BorderSizePixel = 0
	glass.ZIndex = 0
	MakeCorner(glass, 14)

	-- Glow behind
	local glow = Instance.new("Frame", notifFrame)
	glow.Size = UDim2.new(1, 30, 1, 30)
	glow.Position = UDim2.new(0, -15, 0, -15)
	glow.BackgroundTransparency = 1
	glow.ZIndex = -1
	local glowStroke = Instance.new("UIStroke", glow)
	glowStroke.Thickness = 20
	glowStroke.Color = typeColor
	glowStroke.Transparency = 0.92

	-- Accent bar left
	local accentBar = Instance.new("Frame", notifFrame)
	accentBar.Size = UDim2.new(0, 5, 1, -12)
	accentBar.Position = UDim2.new(0, 6, 0, 6)
	accentBar.BackgroundColor3 = typeColor
	accentBar.BorderSizePixel = 0
	accentBar.ZIndex = 2
	MakeCorner(accentBar, 3)

	-- Title
	local titleLabel = Instance.new("TextLabel", notifFrame)
	titleLabel.Size = UDim2.new(1, -30, 0, 22)
	titleLabel.Position = UDim2.new(0, 18, 0, 8)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = Theme.Text
	titleLabel.FontFace = Theme.Font
	titleLabel.TextSize = 18
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextScaled = true
	titleLabel.ZIndex = 2

	-- Content
	local contentLabel = Instance.new("TextLabel", notifFrame)
	contentLabel.Size = UDim2.new(1, -30, 0, 0)
	contentLabel.Position = UDim2.new(0, 18, 0, 32)
	contentLabel.BackgroundTransparency = 1
	contentLabel.Text = content
	contentLabel.TextColor3 = Theme.TextDim
	contentLabel.FontFace = Theme.Font
	contentLabel.TextSize = 14
	contentLabel.TextXAlignment = Enum.TextXAlignment.Left
	contentLabel.TextYAlignment = Enum.TextYAlignment.Top
	contentLabel.TextWrapped = true
	contentLabel.AutomaticSize = Enum.AutomaticSize.Y
	contentLabel.ZIndex = 2

	-- Calculate dynamic height
	local textBounds = TextService:GetTextSize(content, 14, Theme.Font, Vector2.new(290, 500))
	local targetHeight = math.max(75, 42 + textBounds.Y)

	-- Animate In (Slide + Scale)
	notifFrame.Size = UDim2.new(0, 320, 0, 0)
	TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 320, 0, targetHeight)
	}):Play()

	-- Progress bar
	local progress = Instance.new("Frame", notifFrame)
	progress.Size = UDim2.new(1, -12, 0, 3)
	progress.Position = UDim2.new(0, 6, 1, -6)
	progress.BackgroundColor3 = typeColor
	progress.BorderSizePixel = 0
	progress.ZIndex = 2
	MakeCorner(progress, 2)

	TweenService:Create(progress, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0, 0, 0, 3)
	}):Play()

	-- Auto Close
	task.delay(duration, function()
		local closeTween = TweenService:Create(notifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 320, 0, 0),
			BackgroundTransparency = 1
		})
		closeTween:Play()
		closeTween.Completed:Wait()
		notifFrame:Destroy()
	end)
end

-- [ FUNGSI MEMBUAT WINDOW ] --
function Library:CreateWindow(titleText)
	local Window = {}

	local parentGui
	if RunService:IsStudio() then
		parentGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	else
		local ok = pcall(function()
			parentGui = CoreGui
		end)
		if not ok or not parentGui then
			parentGui = Players.LocalPlayer:WaitForChild("PlayerGui")
		end
	end

	if parentGui:FindFirstChild(titleText .. "_GUI") then
		parentGui:FindFirstChild(titleText .. "_GUI"):Destroy()
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = titleText .. "_GUI"
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Parent = parentGui
	Window.ScreenGui = ScreenGui

	table.insert(AllGuis, ScreenGui)

	-- Tab / Window Frame
	local Tab = Instance.new("Frame", ScreenGui)
	Tab.Name = "Tab"
	Tab.BorderSizePixel = 0
	Tab.BackgroundColor3 = Theme.Background
	Tab.Size = UDim2.new(0, 200, 0, 36)
	Tab.Position = UDim2.new(0, 100 + (#Library * 50), 0, 50 + (#Library * 30))
	Tab.Active = true
	Tab.Visible = true
	MakeStroke(Tab, Theme.Stroke, 2)
	MakeCorner(Tab, 8)

	local Title = Instance.new("TextLabel", Tab)
	Title.BorderSizePixel = 0
	Title.TextSize = 22
	Title.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Title.FontFace = Theme.Font
	Title.TextColor3 = Theme.Text
	Title.BackgroundTransparency = 1
	Title.Size = UDim2.new(1, -30, 1, 0)
	Title.Position = UDim2.new(0, 10, 0, 0)
	Title.Text = titleText
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextScaled = true

	local MinInd = Instance.new("TextLabel", Tab)
	MinInd.Size = UDim2.new(0, 24, 0, 24)
	MinInd.Position = UDim2.new(1, -28, 0.5, -12)
	MinInd.BackgroundTransparency = 1
	MinInd.Text = "−"
	MinInd.TextColor3 = Theme.TextDim
	MinInd.FontFace = Theme.Font
	MinInd.TextSize = 20
	MinInd.TextScaled = true

	-- Menu / Content Frame
	local Menu = Instance.new("Frame", Tab)
	Menu.Name = "Menu"
	Menu.BorderSizePixel = 0
	Menu.BackgroundColor3 = Theme.Background
	Menu.Size = UDim2.new(0, 200, 0, 300)
	Menu.Position = UDim2.new(0, 0, 0, 40)
	Menu.ClipsDescendants = true
	Menu.Visible = true
	MakeStroke(Menu, Theme.Stroke, 2)
	MakeCorner(Menu, 8)

	local Scroll = Instance.new("ScrollingFrame", Menu)
	Scroll.BorderSizePixel = 0
	Scroll.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Scroll.Size = UDim2.new(1, 0, 1, 0)
	Scroll.BackgroundTransparency = 1
	Scroll.ScrollBarThickness = 3
	Scroll.ScrollBarImageColor3 = Theme.Stroke
	Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

	local UIList = Instance.new("UIListLayout", Scroll)
	UIList.SortOrder = Enum.SortOrder.LayoutOrder
	UIList.Padding = UDim.new(0, 8)
	UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local UIPad = Instance.new("UIPadding", Scroll)
	UIPad.PaddingTop = UDim.new(0, 8)
	UIPad.PaddingBottom = UDim.new(0, 8)
	UIPad.PaddingLeft = UDim.new(0, 6)
	UIPad.PaddingRight = UDim.new(0, 6)

	-- [ DRAGGABLE & MINIMIZE ] --
	local dragging, dragInput, dragStart, startPos
	local isMinimized = false
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

	Tab.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Tab.Position
			local clickStart = tick()
			local conn
			conn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					conn:Disconnect()
					if tick() - clickStart < 0.2 and (input.Position - dragStart).Magnitude < 5 then
						isMinimized = not isMinimized
						if isMinimized then
							TweenService:Create(Menu, tweenInfo, {Size = UDim2.new(0, 200, 0, 0)}):Play()
							MinInd.Text = "+"
						else
							TweenService:Create(Menu, tweenInfo, {Size = UDim2.new(0, 200, 0, 300)}):Play()
							MinInd.Text = "−"
						end
					end
				end
			end)
		end
	end)

	Tab.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			TweenService:Create(Tab, TweenInfo.new(0.08, Enum.EasingStyle.Linear), {
				Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			}):Play()
		end
	end)

	-- [ FUNGSI LABEL ] --
	function Window:CreateLabel(text)
		local Label = Instance.new("TextLabel", Scroll)
		Label.Name = "Label_" .. text
		Label.Size = UDim2.new(1, 0, 0, 24)
		Label.BackgroundTransparency = 1
		Label.Text = text
		Label.TextColor3 = Theme.Text
		Label.FontFace = Theme.Font
		Label.TextSize = 18
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextScaled = true
	end

	-- [ FUNGSI PARAGRAPH ] --
	function Window:CreateParagraph(title, content)
		local ParaFrame = Instance.new("Frame", Scroll)
		ParaFrame.Name = "Paragraph_" .. title
		ParaFrame.Size = UDim2.new(1, 0, 0, 0)
		ParaFrame.BackgroundColor3 = Theme.BackgroundLight
		ParaFrame.BorderSizePixel = 0
		ParaFrame.AutomaticSize = Enum.AutomaticSize.Y
		MakeCorner(ParaFrame, 8)
		MakeStroke(ParaFrame, Theme.StrokeDim, 1)

		local TitleLabel = Instance.new("TextLabel", ParaFrame)
		TitleLabel.Size = UDim2.new(1, -16, 0, 22)
		TitleLabel.Position = UDim2.new(0, 8, 0, 6)
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Text = title
		TitleLabel.TextColor3 = Theme.Accent
		TitleLabel.FontFace = Theme.Font
		TitleLabel.TextSize = 16
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.TextScaled = true

		local ContentLabel = Instance.new("TextLabel", ParaFrame)
		ContentLabel.Size = UDim2.new(1, -16, 0, 0)
		ContentLabel.Position = UDim2.new(0, 8, 0, 30)
		ContentLabel.BackgroundTransparency = 1
		ContentLabel.Text = content
		ContentLabel.TextColor3 = Theme.TextDim
		ContentLabel.FontFace = Theme.Font
		ContentLabel.TextSize = 14
		ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
		ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
		ContentLabel.TextWrapped = true
		ContentLabel.AutomaticSize = Enum.AutomaticSize.Y
		ContentLabel.TextScaled = true

		local pad = Instance.new("UIPadding", ParaFrame)
		pad.PaddingBottom = UDim.new(0, 10)
	end

	-- [ FUNGSI BUTTON - TEXT MENYESUAIKAN ] --
	function Window:CreateButton(text, callback)
		local Button = Instance.new("TextButton", Scroll)
		Button.Name = "Button_" .. text
		Button.Size = UDim2.new(1, 0, 0, 34)
		Button.BackgroundColor3 = Theme.Background
		Button.Text = text
		Button.TextColor3 = Theme.Text
		Button.FontFace = Theme.Font
		Button.TextSize = 18
		Button.AutoButtonColor = false
		Button.TextScaled = true
		MakeCorner(Button, 6)
		local BtnStroke = MakeStroke(Button, Theme.Stroke, 1.5)

		Button.MouseEnter:Connect(function()
			TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.BackgroundHover}):Play()
			TweenService:Create(BtnStroke, TweenInfo.new(0.1), {Color = Theme.Stroke}):Play()
		end)
		Button.MouseLeave:Connect(function()
			TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Background}):Play()
			TweenService:Create(BtnStroke, TweenInfo.new(0.1), {Color = Theme.StrokeDim}):Play()
		end)

		Button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Stroke}):Play()
			end
		end)
		Button.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Background}):Play()
			end
		end)

		Button.MouseButton1Click:Connect(function()
			pcall(callback)
		end)
	end

	-- [ FUNGSI TOGGLE - TEXT MENYESUAIKAN ] --
	function Window:CreateToggle(text, defaultState, callback)
		local state = defaultState or false

		local ToggleBtn = Instance.new("TextButton", Scroll)
		ToggleBtn.Name = "Toggle_" .. text
		ToggleBtn.Size = UDim2.new(1, 0, 0, 34)
		ToggleBtn.BackgroundColor3 = Theme.Background
		ToggleBtn.Text = ""
		ToggleBtn.AutoButtonColor = false
		MakeCorner(ToggleBtn, 6)
		local TglStroke = MakeStroke(ToggleBtn, Theme.Stroke, 1.5)

		local Label = Instance.new("TextLabel", ToggleBtn)
		Label.Size = UDim2.new(1, -50, 1, 0)
		Label.Position = UDim2.new(0, 10, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = text
		Label.TextColor3 = Theme.Text
		Label.FontFace = Theme.Font
		Label.TextSize = 18
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextScaled = true

		local SwitchBg = Instance.new("Frame", ToggleBtn)
		SwitchBg.Size = UDim2.new(0, 40, 0, 20)
		SwitchBg.Position = UDim2.new(1, -48, 0.5, -10)
		SwitchBg.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 60)
		SwitchBg.BorderSizePixel = 0
		MakeCorner(SwitchBg, 4)

		local Knob = Instance.new("Frame", SwitchBg)
		Knob.Size = UDim2.new(0, 16, 0, 16)
		Knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
		Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Knob.BorderSizePixel = 0
		MakeCorner(Knob, 4)

		local function UpdateToggle()
			local targetPos = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
			local targetCol = state and Theme.Accent or Color3.fromRGB(50, 50, 60)
			TweenService:Create(SwitchBg, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundColor3 = targetCol}):Play()
			TweenService:Create(Knob, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()
			pcall(callback, state)
		end

		ToggleBtn.MouseButton1Click:Connect(function()
			state = not state
			UpdateToggle()
		end)

		pcall(callback, state)
	end

	-- [ FUNGSI SLIDER - TEXT MENYESUAIKAN ] --
	function Window:CreateSlider(text, config, callback)
		config = config or {}
		local min = config.Min or 0
		local max = config.Max or 100
		local default = config.Default or min
		local increment = config.Increment or 1
		local suffix = config.Suffix or ""

		local SliderFrame = Instance.new("Frame", Scroll)
		SliderFrame.Name = "Slider_" .. text
		SliderFrame.Size = UDim2.new(1, 0, 0, 52)
		SliderFrame.BackgroundColor3 = Theme.Background
		SliderFrame.BorderSizePixel = 0
		MakeCorner(SliderFrame, 6)
		MakeStroke(SliderFrame, Theme.Stroke, 1.5)

		local Label = Instance.new("TextLabel", SliderFrame)
		Label.Size = UDim2.new(1, -70, 0, 20)
		Label.Position = UDim2.new(0, 8, 0, 2)
		Label.BackgroundTransparency = 1
		Label.Text = text
		Label.TextColor3 = Theme.Text
		Label.FontFace = Theme.Font
		Label.TextSize = 16
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextScaled = true

		local ValueLabel = Instance.new("TextLabel", SliderFrame)
		ValueLabel.Size = UDim2.new(0, 60, 0, 20)
		ValueLabel.Position = UDim2.new(1, -64, 0, 2)
		ValueLabel.BackgroundTransparency = 1
		ValueLabel.Text = tostring(default) .. suffix
		ValueLabel.TextColor3 = Theme.Accent
		ValueLabel.FontFace = Theme.Font
		ValueLabel.TextSize = 14
		ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
		ValueLabel.TextScaled = true

		local Track = Instance.new("Frame", SliderFrame)
		Track.Size = UDim2.new(1, -16, 0, 6)
		Track.Position = UDim2.new(0, 8, 0, 32)
		Track.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		Track.BorderSizePixel = 0
		MakeCorner(Track, 3)

		local Fill = Instance.new("Frame", Track)
		Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
		Fill.BackgroundColor3 = Theme.Accent
		Fill.BorderSizePixel = 0
		MakeCorner(Fill, 3)

		local Knob = Instance.new("Frame", Track)
		Knob.Size = UDim2.new(0, 14, 0, 18)
		Knob.Position = UDim2.new((default - min) / (max - min), -7, 0.5, -9)
		Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Knob.BorderSizePixel = 0
		MakeCorner(Knob, 4)
		MakeStroke(Knob, Theme.Stroke, 1)

		local function SetValue(val)
			val = math.clamp(val, min, max)
			val = math.floor((val - min) / increment + 0.5) * increment + min
			local pct = (val - min) / (max - min)
			TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
			TweenService:Create(Knob, TweenInfo.new(0.1), {Position = UDim2.new(pct, -7, 0.5, -9)}):Play()
			ValueLabel.Text = tostring(val) .. suffix
			pcall(callback, val)
		end

		local draggingSlider = false
		local function UpdateFromInput(input)
			local pos = input.Position.X
			local tStart = Track.AbsolutePosition.X
			local tSize = Track.AbsoluteSize.X
			local pct = math.clamp((pos - tStart) / tSize, 0, 1)
			SetValue(min + (max - min) * pct)
		end

		Track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingSlider = true
				UpdateFromInput(input)
			end
		end)
		Knob.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingSlider = true
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				UpdateFromInput(input)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingSlider = false
			end
		end)
	end

	-- [ FUNGSI DROPDOWN - FIX & TEXT MENYESUAIKAN ] --
	function Window:CreateDropdown(text, options, callback)
		options = options or {}
		local selected = options[1] or "Select..."
		local isOpen = false

		local DDFrame = Instance.new("Frame", Scroll)
		DDFrame.Name = "Dropdown_" .. text
		DDFrame.Size = UDim2.new(1, 0, 0, 34)
		DDFrame.BackgroundColor3 = Theme.Background
		DDFrame.BorderSizePixel = 0
		DDFrame.ClipsDescendants = false
		MakeCorner(DDFrame, 6)
		MakeStroke(DDFrame, Theme.Stroke, 1.5)

		local Label = Instance.new("TextLabel", DDFrame)
		Label.Size = UDim2.new(1, -20, 0, 14)
		Label.Position = UDim2.new(0, 8, 0, 2)
		Label.BackgroundTransparency = 1
		Label.Text = text
		Label.TextColor3 = Theme.TextDim
		Label.FontFace = Theme.Font
		Label.TextSize = 11
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextScaled = true

		local SelectedText = Instance.new("TextLabel", DDFrame)
		SelectedText.Size = UDim2.new(1, -32, 0, 18)
		SelectedText.Position = UDim2.new(0, 8, 0, 14)
		SelectedText.BackgroundTransparency = 1
		SelectedText.Text = selected
		SelectedText.TextColor3 = Theme.Text
		SelectedText.FontFace = Theme.Font
		SelectedText.TextSize = 16
		SelectedText.TextXAlignment = Enum.TextXAlignment.Left
		SelectedText.TextScaled = true

		local Arrow = Instance.new("TextLabel", DDFrame)
		Arrow.Size = UDim2.new(0, 18, 0, 18)
		Arrow.Position = UDim2.new(1, -22, 0, 8)
		Arrow.BackgroundTransparency = 1
		Arrow.Text = "▼"
		Arrow.TextColor3 = Theme.TextDim
		Arrow.FontFace = Theme.Font
		Arrow.TextSize = 12
		Arrow.TextScaled = true

		local OptContainer = Instance.new("Frame", Menu)
		OptContainer.Name = "DDOptions_" .. text
		OptContainer.Size = UDim2.new(0, 200, 0, 0)
		OptContainer.Position = UDim2.new(0, 0, 0, 0)
		OptContainer.BackgroundColor3 = Theme.Background
		OptContainer.BorderSizePixel = 0
		OptContainer.Visible = false
		OptContainer.ZIndex = 10
		MakeCorner(OptContainer, 6)
		MakeStroke(OptContainer, Theme.Stroke, 1.5)

		local OptList = Instance.new("UIListLayout", OptContainer)
		OptList.SortOrder = Enum.SortOrder.LayoutOrder
		OptList.Padding = UDim.new(0, 0)

		local function BuildOptions()
			for _, c in ipairs(OptContainer:GetChildren()) do
				if c:IsA("TextButton") then c:Destroy() end
			end
			for _, opt in ipairs(options) do
				local Btn = Instance.new("TextButton", OptContainer)
				Btn.Size = UDim2.new(1, 0, 0, 28)
				Btn.BackgroundColor3 = Theme.Background
				Btn.Text = opt
				Btn.TextColor3 = Theme.Text
				Btn.FontFace = Theme.Font
				Btn.TextSize = 15
				Btn.AutoButtonColor = false
				Btn.BorderSizePixel = 0
				Btn.ZIndex = 11
				Btn.TextScaled = true
				Btn.MouseEnter:Connect(function()
					TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.BackgroundHover}):Play()
				end)
				Btn.MouseLeave:Connect(function()
					TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Background}):Play()
				end)
				Btn.MouseButton1Click:Connect(function()
					selected = opt
					SelectedText.Text = selected
					isOpen = false
					OptContainer.Visible = false
					TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
					pcall(callback, selected)
				end)
			end
		end
		BuildOptions()

		Scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			if isOpen then
				local absY = DDFrame.AbsolutePosition.Y - Menu.AbsolutePosition.Y + DDFrame.AbsoluteSize.Y
				OptContainer.Position = UDim2.new(0, 0, 0, absY)
			end
		end)

		local ClickArea = Instance.new("TextButton", DDFrame)
		ClickArea.BackgroundTransparency = 1
		ClickArea.Size = UDim2.new(1, 0, 1, 0)
		ClickArea.Text = ""
		ClickArea.ZIndex = 2
		ClickArea.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			if isOpen then
				local absY = DDFrame.AbsolutePosition.Y - Menu.AbsolutePosition.Y + DDFrame.AbsoluteSize.Y
				OptContainer.Position = UDim2.new(0, 0, 0, absY)
				local h = math.min(#options * 28, 150)
				OptContainer.Size = UDim2.new(0, 200, 0, h)
				OptContainer.Visible = true
				TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
			else
				OptContainer.Visible = false
				TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
			end
		end)
	end

	-- [ FUNGSI MULTISELECT - TEXT MENYESUAIKAN ] --
	function Window:CreateMultiSelect(text, options, callback)
		options = options or {}
		local selected = {}
		local isOpen = false

		local MSFrame = Instance.new("Frame", Scroll)
		MSFrame.Name = "MultiSelect_" .. text
		MSFrame.Size = UDim2.new(1, 0, 0, 34)
		MSFrame.BackgroundColor3 = Theme.Background
		MSFrame.BorderSizePixel = 0
		MSFrame.ClipsDescendants = false
		MakeCorner(MSFrame, 6)
		MakeStroke(MSFrame, Theme.Stroke, 1.5)

		local Label = Instance.new("TextLabel", MSFrame)
		Label.Size = UDim2.new(1, -20, 0, 14)
		Label.Position = UDim2.new(0, 8, 0, 2)
		Label.BackgroundTransparency = 1
		Label.Text = text
		Label.TextColor3 = Theme.TextDim
		Label.FontFace = Theme.Font
		Label.TextSize = 11
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextScaled = true

		local SelectedText = Instance.new("TextLabel", MSFrame)
		SelectedText.Size = UDim2.new(1, -32, 0, 18)
		SelectedText.Position = UDim2.new(0, 8, 0, 14)
		SelectedText.BackgroundTransparency = 1
		SelectedText.Text = "None"
		SelectedText.TextColor3 = Theme.Text
		SelectedText.FontFace = Theme.Font
		SelectedText.TextSize = 16
		SelectedText.TextXAlignment = Enum.TextXAlignment.Left
		SelectedText.TextScaled = true

		local Arrow = Instance.new("TextLabel", MSFrame)
		Arrow.Size = UDim2.new(0, 18, 0, 18)
		Arrow.Position = UDim2.new(1, -22, 0, 8)
		Arrow.BackgroundTransparency = 1
		Arrow.Text = "▼"
		Arrow.TextColor3 = Theme.TextDim
		Arrow.FontFace = Theme.Font
		Arrow.TextSize = 12
		Arrow.TextScaled = true

		local OptContainer = Instance.new("Frame", Menu)
		OptContainer.Name = "MSOptions_" .. text
		OptContainer.Size = UDim2.new(0, 200, 0, 0)
		OptContainer.Position = UDim2.new(0, 0, 0, 0)
		OptContainer.BackgroundColor3 = Theme.Background
		OptContainer.BorderSizePixel = 0
		OptContainer.Visible = false
		OptContainer.ZIndex = 10
		MakeCorner(OptContainer, 6)
		MakeStroke(OptContainer, Theme.Stroke, 1.5)

		local OptList = Instance.new("UIListLayout", OptContainer)
		OptList.SortOrder = Enum.SortOrder.LayoutOrder
		OptList.Padding = UDim.new(0, 0)

		local function UpdateDisplay()
			if #selected == 0 then
				SelectedText.Text = "None"
			elseif #selected == 1 then
				SelectedText.Text = selected[1]
			else
				SelectedText.Text = #selected .. " selected"
			end
		end

		local function BuildOptions()
			for _, c in ipairs(OptContainer:GetChildren()) do
				if c:IsA("Frame") then c:Destroy() end
			end
			for _, opt in ipairs(options) do
				local Row = Instance.new("Frame", OptContainer)
				Row.Size = UDim2.new(1, 0, 0, 28)
				Row.BackgroundColor3 = Theme.Background
				Row.BorderSizePixel = 0
				Row.ZIndex = 11

				local isSel = table.find(selected, opt) ~= nil

				local CheckBox = Instance.new("Frame", Row)
				CheckBox.Size = UDim2.new(0, 16, 0, 16)
				CheckBox.Position = UDim2.new(0, 8, 0.5, -8)
				CheckBox.BackgroundColor3 = isSel and Theme.Accent or Theme.BackgroundLight
				CheckBox.BorderSizePixel = 0
				CheckBox.ZIndex = 12
				MakeCorner(CheckBox, 4)

				local CheckMark = Instance.new("TextLabel", CheckBox)
				CheckMark.Size = UDim2.new(1, 0, 1, 0)
				CheckMark.BackgroundTransparency = 1
				CheckMark.Text = "✓"
				CheckMark.TextColor3 = Color3.fromRGB(255,255,255)
				CheckMark.FontFace = Theme.Font
				CheckMark.TextSize = 12
				CheckMark.Visible = isSel
				CheckMark.ZIndex = 13
				CheckMark.TextScaled = true

				local OptLabel = Instance.new("TextLabel", Row)
				OptLabel.Size = UDim2.new(1, -36, 1, 0)
				OptLabel.Position = UDim2.new(0, 30, 0, 0)
				OptLabel.BackgroundTransparency = 1
				OptLabel.Text = opt
				OptLabel.TextColor3 = Theme.Text
				OptLabel.FontFace = Theme.Font
				OptLabel.TextSize = 15
				OptLabel.TextXAlignment = Enum.TextXAlignment.Left
				OptLabel.ZIndex = 12
				OptLabel.TextScaled = true

				local Btn = Instance.new("TextButton", Row)
				Btn.BackgroundTransparency = 1
				Btn.Size = UDim2.new(1, 0, 1, 0)
				Btn.Text = ""
				Btn.ZIndex = 14
				Btn.MouseEnter:Connect(function()
					TweenService:Create(Row, TweenInfo.new(0.1), {BackgroundColor3 = Theme.BackgroundHover}):Play()
				end)
				Btn.MouseLeave:Connect(function()
					TweenService:Create(Row, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Background}):Play()
				end)
				Btn.MouseButton1Click:Connect(function()
					local idx = table.find(selected, opt)
					if idx then
						table.remove(selected, idx)
						TweenService:Create(CheckBox, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BackgroundLight}):Play()
						CheckMark.Visible = false
					else
						table.insert(selected, opt)
						TweenService:Create(CheckBox, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent}):Play()
						CheckMark.Visible = true
					end
					UpdateDisplay()
					pcall(callback, selected)
				end)
			end
		end
		BuildOptions()

		Scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			if isOpen then
				local absY = MSFrame.AbsolutePosition.Y - Menu.AbsolutePosition.Y + MSFrame.AbsoluteSize.Y
				OptContainer.Position = UDim2.new(0, 0, 0, absY)
			end
		end)

		local ClickArea = Instance.new("TextButton", MSFrame)
		ClickArea.BackgroundTransparency = 1
		ClickArea.Size = UDim2.new(1, 0, 1, 0)
		ClickArea.Text = ""
		ClickArea.ZIndex = 2
		ClickArea.MouseButton1Click:Connect(function()
			isOpen = not isOpen
			if isOpen then
				local absY = MSFrame.AbsolutePosition.Y - Menu.AbsolutePosition.Y + MSFrame.AbsoluteSize.Y
				OptContainer.Position = UDim2.new(0, 0, 0, absY)
				local h = math.min(#options * 28, 150)
				OptContainer.Size = UDim2.new(0, 200, 0, h)
				OptContainer.Visible = true
				TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
			else
				OptContainer.Visible = false
				TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
			end
		end)
	end

	-- [ FUNGSI INPUT ] --
	function Window:CreateInput(text, placeholder, callback)
		local InputFrame = Instance.new("Frame", Scroll)
		InputFrame.Name = "Input_" .. text
		InputFrame.Size = UDim2.new(1, 0, 0, 60)
		InputFrame.BackgroundColor3 = Theme.Background
		InputFrame.BorderSizePixel = 0
		MakeCorner(InputFrame, 6)
		MakeStroke(InputFrame, Theme.Stroke, 1.5)

		local Label = Instance.new("TextLabel", InputFrame)
		Label.Size = UDim2.new(1, -16, 0, 18)
		Label.Position = UDim2.new(0, 8, 0, 4)
		Label.BackgroundTransparency = 1
		Label.Text = text
		Label.TextColor3 = Theme.TextDim
		Label.FontFace = Theme.Font
		Label.TextSize = 12
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextScaled = true

		local Box = Instance.new("TextBox", InputFrame)
		Box.Size = UDim2.new(1, -16, 0, 28)
		Box.Position = UDim2.new(0, 8, 0, 26)
		Box.BackgroundColor3 = Theme.BackgroundLight
		Box.Text = ""
		Box.PlaceholderText = placeholder or "Type here..."
		Box.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
		Box.TextColor3 = Theme.Text
		Box.FontFace = Theme.Font
		Box.TextSize = 15
		Box.ClearTextOnFocus = false
		MakeCorner(Box, 4)
		Box.TextScaled = true

		local BoxStroke = MakeStroke(Box, Theme.StrokeDim, 1)

		Box.Focused:Connect(function()
			TweenService:Create(BoxStroke, TweenInfo.new(0.2), {Color = Theme.Accent}):Play()
			TweenService:Create(Box, TweenInfo.new(0.2), {BackgroundColor3 = Theme.BackgroundHover}):Play()
		end)
		Box.FocusLost:Connect(function(enterPressed)
			TweenService:Create(BoxStroke, TweenInfo.new(0.2), {Color = Theme.StrokeDim}):Play()
			TweenService:Create(Box, TweenInfo.new(0.2), {BackgroundColor3 = Theme.BackgroundLight}):Play()
			pcall(callback, Box.Text, enterPressed)
		end)
	end

	-- [ FUNGSI COLOR PICKER - SUPER KECE ] --
	function Window:CreateColorPicker(text, defaultColor, callback)
		defaultColor = defaultColor or Color3.fromRGB(255, 0, 0)
		local h, s, v = defaultColor:ToHSV()

		local CPFrame = Instance.new("Frame", Scroll)
		CPFrame.Name = "ColorPicker_" .. text
		CPFrame.Size = UDim2.new(1, 0, 0, 200)
		CPFrame.BackgroundColor3 = Theme.Background
		CPFrame.BorderSizePixel = 0
		MakeCorner(CPFrame, 12)
		MakeStroke(CPFrame, Theme.Stroke, 1.5)

		-- Glow Effect
		local Glow = Instance.new("Frame", CPFrame)
		Glow.Name = "Glow"
		Glow.Size = UDim2.new(1, 40, 1, 40)
		Glow.Position = UDim2.new(0, -20, 0, -20)
		Glow.BackgroundTransparency = 1
		Glow.ZIndex = 0
		local GlowStroke = Instance.new("UIStroke", Glow)
		GlowStroke.Thickness = 25
		GlowStroke.Color = Theme.Accent
		GlowStroke.Transparency = 0.9

		-- Title
		local Title = Instance.new("TextLabel", CPFrame)
		Title.Size = UDim2.new(1, -70, 0, 22)
		Title.Position = UDim2.new(0, 10, 0, 6)
		Title.BackgroundTransparency = 1
		Title.Text = text
		Title.TextColor3 = Theme.Text
		Title.FontFace = Theme.Font
		Title.TextSize = 16
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.TextScaled = true
		Title.ZIndex = 2

		-- Preview
		local Preview = Instance.new("Frame", CPFrame)
		Preview.Size = UDim2.new(0, 56, 0, 56)
		Preview.Position = UDim2.new(1, -64, 0, 6)
		Preview.BackgroundColor3 = defaultColor
		Preview.BorderSizePixel = 0
		Preview.ZIndex = 2
		MakeCorner(Preview, 10)
		local PrevStroke = MakeStroke(Preview, Color3.fromRGB(255,255,255), 2)
		PrevStroke.Transparency = 0.3

		-- SV Box (Saturation & Value)
		local SVBox = Instance.new("Frame", CPFrame)
		SVBox.Size = UDim2.new(0, 130, 0, 110)
		SVBox.Position = UDim2.new(0, 8, 0, 32)
		SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		SVBox.BorderSizePixel = 0
		SVBox.ZIndex = 2
		MakeCorner(SVBox, 8)
		MakeStroke(SVBox, Color3.fromRGB(255,255,255), 1)

		local WhiteOverlay = Instance.new("Frame", SVBox)
		WhiteOverlay.Size = UDim2.new(1, 0, 1, 0)
		WhiteOverlay.BackgroundColor3 = Color3.new(1, 1, 1)
		WhiteOverlay.BorderSizePixel = 0
		local WhiteGrad = Instance.new("UIGradient", WhiteOverlay)
		WhiteGrad.Transparency = NumberSequence.new(0, 1)
		WhiteGrad.Rotation = 0

		local BlackOverlay = Instance.new("Frame", SVBox)
		BlackOverlay.Size = UDim2.new(1, 0, 1, 0)
		BlackOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
		BlackOverlay.BorderSizePixel = 0
		local BlackGrad = Instance.new("UIGradient", BlackOverlay)
		BlackGrad.Transparency = NumberSequence.new(1, 0)
		BlackGrad.Rotation = 90

		-- SV Knob
		local SVKnob = Instance.new("Frame", SVBox)
		SVKnob.Size = UDim2.new(0, 12, 0, 12)
		SVKnob.BackgroundColor3 = Color3.new(1, 1, 1)
		SVKnob.BorderSizePixel = 0
		SVKnob.Position = UDim2.new(s, -6, 1-v, -6)
		SVKnob.ZIndex = 5
		MakeCorner(SVKnob, 6)
		MakeStroke(SVKnob, Color3.new(0,0,0), 1)

		-- Hue Slider
		local HueFrame = Instance.new("Frame", CPFrame)
		HueFrame.Size = UDim2.new(0, 18, 0, 110)
		HueFrame.Position = UDim2.new(0, 146, 0, 32)
		HueFrame.BorderSizePixel = 0
		HueFrame.ZIndex = 2
		MakeCorner(HueFrame, 6)
		MakeStroke(HueFrame, Color3.fromRGB(255,255,255), 1)

		local HueGradient = Instance.new("UIGradient", HueFrame)
		HueGradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0))
		}
		HueGradient.Rotation = 90

		local HueKnob = Instance.new("Frame", HueFrame)
		HueKnob.Size = UDim2.new(1, 6, 0, 8)
		HueKnob.Position = UDim2.new(0, -3, 1-h, -4)
		HueKnob.BackgroundColor3 = Color3.new(1, 1, 1)
		HueKnob.BorderSizePixel = 0
		HueKnob.ZIndex = 5
		MakeCorner(HueKnob, 3)
		MakeStroke(HueKnob, Color3.new(0,0,0), 1)

		-- Hex Input
		local HexBox = Instance.new("TextBox", CPFrame)
		HexBox.Size = UDim2.new(0, 90, 0, 24)
		HexBox.Position = UDim2.new(0, 8, 0, 148)
		HexBox.BackgroundColor3 = Theme.BackgroundLight
		HexBox.Text = string.format("#%02X%02X%02X", defaultColor.R*255, defaultColor.G*255, defaultColor.B*255)
		HexBox.TextColor3 = Theme.Text
		HexBox.FontFace = Theme.Font
		HexBox.TextSize = 13
		HexBox.ClearTextOnFocus = false
		MakeCorner(HexBox, 6)
		MakeStroke(HexBox, Theme.StrokeDim, 1)
		HexBox.ZIndex = 2
		HexBox.TextScaled = true
		HexBox.PlaceholderText = "HEX"
		HexBox.PlaceholderColor3 = Color3.fromRGB(100,100,110)

		-- RGB Inputs
		local RBox = Instance.new("TextBox", CPFrame)
		RBox.Size = UDim2.new(0, 46, 0, 24)
		RBox.Position = UDim2.new(0, 106, 0, 148)
		RBox.BackgroundColor3 = Theme.BackgroundLight
		RBox.Text = tostring(math.floor(defaultColor.R*255))
		RBox.TextColor3 = Color3.fromRGB(255,100,100)
		RBox.FontFace = Theme.Font
		RBox.TextSize = 13
		MakeCorner(RBox, 6)
		MakeStroke(RBox, Color3.fromRGB(150,50,50), 1)
		RBox.ZIndex = 2
		RBox.TextScaled = true
		RBox.PlaceholderText = "R"

		local GBox = Instance.new("TextBox", CPFrame)
		GBox.Size = UDim2.new(0, 46, 0, 24)
		GBox.Position = UDim2.new(0, 156, 0, 148)
		GBox.BackgroundColor3 = Theme.BackgroundLight
		GBox.Text = tostring(math.floor(defaultColor.G*255))
		GBox.TextColor3 = Color3.fromRGB(100,255,100)
		GBox.FontFace = Theme.Font
		GBox.TextSize = 13
		MakeCorner(GBox, 6)
		MakeStroke(GBox, Color3.fromRGB(50,150,50), 1)
		GBox.ZIndex = 2
		GBox.TextScaled = true
		GBox.PlaceholderText = "G"

		local BBox = Instance.new("TextBox", CPFrame)
		BBox.Size = UDim2.new(0, 46, 0, 24)
		BBox.Position = UDim2.new(0, 206, 0, 148)
		BBox.BackgroundColor3 = Theme.BackgroundLight
		BBox.Text = tostring(math.floor(defaultColor.B*255))
		BBox.TextColor3 = Color3.fromRGB(100,100,255)
		BBox.FontFace = Theme.Font
		BBox.TextSize = 13
		MakeCorner(BBox, 6)
		MakeStroke(BBox, Color3.fromRGB(50,50,150), 1)
		BBox.ZIndex = 2
		BBox.TextScaled = true
		BBox.PlaceholderText = "B"

		local function UpdateColor(newH, newS, newV, skipCallback)
			h, s, v = newH, newS, newV
			local color = Color3.fromHSV(h, s, v)
			SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			Preview.BackgroundColor3 = color

			HexBox.Text = string.format("#%02X%02X%02X", color.R*255, color.G*255, color.B*255)
			RBox.Text = tostring(math.floor(color.R*255))
			GBox.Text = tostring(math.floor(color.G*255))
			BBox.Text = tostring(math.floor(color.B*255))

			if not skipCallback then
				pcall(callback, color)
			end
		end

		-- SV Dragging
		local draggingSV = false
		local function UpdateSV(input)
			local pos = input.Position
			local absPos = SVBox.AbsolutePosition
			local absSize = SVBox.AbsoluteSize
			local relX = math.clamp((pos.X - absPos.X) / absSize.X, 0, 1)
			local relY = math.clamp((pos.Y - absPos.Y) / absSize.Y, 0, 1)
			local newS = relX
			local newV = 1 - relY
			SVKnob.Position = UDim2.new(newS, -6, 1-newV, -6)
			UpdateColor(h, newS, newV)
		end

		SVBox.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingSV = true
				UpdateSV(input)
			end
		end)
		SVKnob.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingSV = true
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if draggingSV and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				UpdateSV(input)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingSV = false
			end
		end)

		-- Hue Dragging
		local draggingHue = false
		local function UpdateHue(input)
			local pos = input.Position
			local absPos = HueFrame.AbsolutePosition
			local absSize = HueFrame.AbsoluteSize
			local relY = math.clamp((pos.Y - absPos.Y) / absSize.Y, 0, 1)
			local newH = 1 - relY
			HueKnob.Position = UDim2.new(0, -3, 1-newH, -4)
			UpdateColor(newH, s, v)
		end

		HueFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingHue = true
				UpdateHue(input)
			end
		end)
		HueKnob.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingHue = true
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				UpdateHue(input)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingHue = false
			end
		end)

		-- Hex input
		HexBox.FocusLost:Connect(function()
			local txt = HexBox.Text:gsub("#", "")
			if #txt >= 6 then
				local r = tonumber(txt:sub(1,2), 16) or 255
				local g = tonumber(txt:sub(3,4), 16) or 0
				local b = tonumber(txt:sub(5,6), 16) or 0
				local newColor = Color3.fromRGB(r, g, b)
				local newH, newS, newV = newColor:ToHSV()
				SVKnob.Position = UDim2.new(newS, -6, 1-newV, -6)
				HueKnob.Position = UDim2.new(0, -3, 1-newH, -4)
				UpdateColor(newH, newS, newV)
			end
		end)

		-- RGB inputs
		local function updateFromRGB()
			local r = math.clamp(tonumber(RBox.Text) or 0, 0, 255)
			local g = math.clamp(tonumber(GBox.Text) or 0, 0, 255)
			local b = math.clamp(tonumber(BBox.Text) or 0, 0, 255)
			local newColor = Color3.fromRGB(r, g, b)
			local newH, newS, newV = newColor:ToHSV()
			SVKnob.Position = UDim2.new(newS, -6, 1-newV, -6)
			HueKnob.Position = UDim2.new(0, -3, 1-newH, -4)
			UpdateColor(newH, newS, newV)
		end

		RBox.FocusLost:Connect(updateFromRGB)
		GBox.FocusLost:Connect(updateFromRGB)
		BBox.FocusLost:Connect(updateFromRGB)

		pcall(callback, defaultColor)
	end

	table.insert(Library, Window)
	return Window
end

---------------------------------------------------------
-- [ SETUP TRIPLE-CLICK TOGGLE OTOMATIS ] --
---------------------------------------------------------
SetupTripleClickToggle()
return Library
