local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local Library = {}
local AllGuis = {} -- Menyimpan semua ScreenGui yang dibuat Library

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

-- [ FITUR BARU: TRIPLE-CLICK TOGGLE GUI ] --
local TripleClickGui = nil
local function SetupTripleClickToggle()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	-- 1. Membuat GUI (Tema Hijau Alam dengan efek Glassmorphism)
	local myScreenGui = Instance.new("ScreenGui")
	myScreenGui.Name = "TigaKlikGui"
	myScreenGui.ResetOnSpawn = false
	myScreenGui.Parent = playerGui
	TripleClickGui = myScreenGui

	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 300, 0, 200)
	mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
	mainFrame.BackgroundColor3 = Color3.fromRGB(46, 125, 50) -- Nature Green
	mainFrame.BackgroundTransparency = 0.3 -- Efek semi-transparan
	mainFrame.Visible = false
	mainFrame.Parent = myScreenGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 16)
	uiCorner.Parent = mainFrame

	-- Efek Glassmorphism tambahan
	local glassStroke = Instance.new("UIStroke", mainFrame)
	glassStroke.Thickness = 2
	glassStroke.Color = Color3.fromRGB(129, 199, 132)
	glassStroke.Transparency = 0.3

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.Text = "UI Terbuka!"
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.BackgroundTransparency = 1
	textLabel.TextSize = 24
	textLabel.Parent = mainFrame

	-- 2. Variabel Logika Klik
	local clickCount = 0
	local lastClickTime = 0
	local TIME_TO_RESET = 1.0 -- Waktu sebelum klik kembali ke 0 (detik)
	local CENTER_ZONE_PERCENTAGE = 0.4 -- 40% area tengah layar

	-- 3. Loop Delta Time (Mengecek setiap frame)
	RunService.RenderStepped:Connect(function(deltaTime)
		if clickCount > 0 then
			if (os.clock() - lastClickTime) >= TIME_TO_RESET then
				clickCount = 0 -- Reset hitungan jadi 0 lagi
			end
		end
	end)

	-- 4. Deteksi Input Pemain
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end 

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local camera = workspace.CurrentCamera
			local viewportSize = camera.ViewportSize
			local inputPos = input.Position

			-- Hitung kotak area tengah
			local zoneWidth = viewportSize.X * CENTER_ZONE_PERCENTAGE
			local zoneHeight = viewportSize.Y * CENTER_ZONE_PERCENTAGE

			local minX = (viewportSize.X - zoneWidth) / 2
			local maxX = minX + zoneWidth
			local minY = (viewportSize.Y - zoneHeight) / 2
			local maxY = minY + zoneHeight

			-- Cek jika klik ada di area tengah
			if inputPos.X >= minX and inputPos.X <= maxX and inputPos.Y >= minY and inputPos.Y <= maxY then

				lastClickTime = os.clock() -- Perbarui waktu klik terakhir
				clickCount += 1 -- Tambah hitungan klik

				-- Jika mencapai 3 klik sebelum 1 detik habis
				if clickCount >= 3 then
					clickCount = 0 -- Reset hitungan

					-- Toggle visibility semua GUI Library (Invisible, bukan Destroy)
					local anyVisible = false
					for _, gui in ipairs(AllGuis) do
						if gui and gui.Parent then
							if gui.Enabled then
								anyVisible = true
								break
							end
						end
					end

					local newState = not anyVisible
					for _, gui in ipairs(AllGuis) do
						if gui and gui.Parent then
							gui.Enabled = newState
						end
					end

					-- Toggle indikator GUI juga
					mainFrame.Visible = newState

					-- Animasi toggle
					if newState then
						mainFrame.Size = UDim2.new(0, 280, 0, 180)
						TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
							Size = UDim2.new(0, 300, 0, 200)
						}):Play()
					end
				end
			end
		end
	end)
end

-- [ FUNGSI MEMBUAT WINDOW - KOTAK, BANYAK, TERPISAH ] --
function Library:CreateWindow(titleText)
	local Window = {}

	-- Parent aman
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

	-- Simpan ke daftar GUI Library
	table.insert(AllGuis, ScreenGui)

	-- Tab / Window Frame (KOTAK)
	local Tab = Instance.new("Frame", ScreenGui)
	Tab.Name = "Tab"
	Tab.BorderSizePixel = 0
	Tab.BackgroundColor3 = Theme.Background
	Tab.Size = UDim2.new(0, 180, 0, 34)
	Tab.Position = UDim2.new(0, 100 + (#Library * 50), 0, 50 + (#Library * 30))
	Tab.Active = true
	Tab.Visible = true
	MakeStroke(Tab, Theme.Stroke, 2)

	-- Title
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

	-- Minimize Indicator
	local MinInd = Instance.new("TextLabel", Tab)
	MinInd.Size = UDim2.new(0, 24, 0, 24)
	MinInd.Position = UDim2.new(1, -26, 0.5, -12)
	MinInd.BackgroundTransparency = 1
	MinInd.Text = "−"
	MinInd.TextColor3 = Theme.TextDim
	MinInd.FontFace = Theme.Font
	MinInd.TextSize = 20

	-- Menu / Content Frame (KOTAK)
	local Menu = Instance.new("Frame", Tab)
	Menu.Name = "Menu"
	Menu.BorderSizePixel = 0
	Menu.BackgroundColor3 = Theme.Background
	Menu.Size = UDim2.new(0, 180, 0, 264)
	Menu.Position = UDim2.new(0, 0, 0, 38)
	Menu.ClipsDescendants = true
	Menu.Visible = true
	MakeStroke(Menu, Theme.Stroke, 2)

	-- ScrollingFrame
	local Scroll = Instance.new("ScrollingFrame", Menu)
	Scroll.BorderSizePixel = 0
	Scroll.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Scroll.Size = UDim2.new(1, 0, 1, 0)
	Scroll.BackgroundTransparency = 1
	Scroll.ScrollBarThickness = 2
	Scroll.ScrollBarImageColor3 = Theme.Stroke
	Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)

	local UIList = Instance.new("UIListLayout", Scroll)
	UIList.SortOrder = Enum.SortOrder.LayoutOrder
	UIList.Padding = UDim.new(0, 6)
	UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

	local UIPad = Instance.new("UIPadding", Scroll)
	UIPad.PaddingTop = UDim.new(0, 6)
	UIPad.PaddingBottom = UDim.new(0, 6)

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
							TweenService:Create(Menu, tweenInfo, {Size = UDim2.new(0, 180, 0, 0)}):Play()
							MinInd.Text = "+"
						else
							TweenService:Create(Menu, tweenInfo, {Size = UDim2.new(0, 180, 0, 264)}):Play()
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

	-- [ FUNGSI BUTTON ] --
	function Window:CreateButton(text, callback)
		local Button = Instance.new("TextButton", Scroll)
		Button.Name = "Button_" .. text
		Button.Size = UDim2.new(1, -12, 0, 32)
		Button.BackgroundColor3 = Theme.Background
		Button.Text = text
		Button.TextColor3 = Theme.Text
		Button.FontFace = Theme.Font
		Button.TextSize = 18
		Button.AutoButtonColor = false
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

	-- [ FUNGSI TOGGLE ] --
	function Window:CreateToggle(text, defaultState, callback)
		local state = defaultState or false

		local ToggleBtn = Instance.new("TextButton", Scroll)
		ToggleBtn.Name = "Toggle_" .. text
		ToggleBtn.Size = UDim2.new(1, -12, 0, 32)
		ToggleBtn.BackgroundColor3 = Theme.Background
		ToggleBtn.Text = ""
		ToggleBtn.AutoButtonColor = false
		local TglStroke = MakeStroke(ToggleBtn, Theme.Stroke, 1.5)

		local Label = Instance.new("TextLabel", ToggleBtn)
		Label.Size = UDim2.new(1, -40, 1, 0)
		Label.Position = UDim2.new(0, 10, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = text
		Label.TextColor3 = Theme.Text
		Label.FontFace = Theme.Font
		Label.TextSize = 18
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextTruncate = Enum.TextTruncate.AtEnd

		-- Switch Background (kotak)
		local SwitchBg = Instance.new("Frame", ToggleBtn)
		SwitchBg.Size = UDim2.new(0, 36, 0, 18)
		SwitchBg.Position = UDim2.new(1, -44, 0.5, -9)
		SwitchBg.BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(50, 50, 60)
		SwitchBg.BorderSizePixel = 0

		-- Knob (kotak)
		local Knob = Instance.new("Frame", SwitchBg)
		Knob.Size = UDim2.new(0, 14, 0, 14)
		Knob.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
		Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Knob.BorderSizePixel = 0

		local function UpdateToggle()
			local targetPos = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
			local targetCol = state and Theme.Accent or Color3.fromRGB(50, 50, 60)
			TweenService:Create(SwitchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetCol}):Play()
			TweenService:Create(Knob, TweenInfo.new(0.2), {Position = targetPos}):Play()
			pcall(callback, state)
		end

		ToggleBtn.MouseButton1Click:Connect(function()
			state = not state
			UpdateToggle()
		end)

		pcall(callback, state)
	end

	-- [ FUNGSI SLIDER ] --
	function Window:CreateSlider(text, config, callback)
		config = config or {}
		local min = config.Min or 0
		local max = config.Max or 100
		local default = config.Default or min
		local increment = config.Increment or 1
		local suffix = config.Suffix or ""

		local SliderFrame = Instance.new("Frame", Scroll)
		SliderFrame.Name = "Slider_" .. text
		SliderFrame.Size = UDim2.new(1, -12, 0, 48)
		SliderFrame.BackgroundColor3 = Theme.Background
		SliderFrame.BorderSizePixel = 0
		MakeStroke(SliderFrame, Theme.Stroke, 1.5)

		local Label = Instance.new("TextLabel", SliderFrame)
		Label.Size = UDim2.new(1, -60, 0, 18)
		Label.Position = UDim2.new(0, 8, 0, 2)
		Label.BackgroundTransparency = 1
		Label.Text = text
		Label.TextColor3 = Theme.Text
		Label.FontFace = Theme.Font
		Label.TextSize = 16
		Label.TextXAlignment = Enum.TextXAlignment.Left

		local ValueLabel = Instance.new("TextLabel", SliderFrame)
		ValueLabel.Size = UDim2.new(0, 50, 0, 18)
		ValueLabel.Position = UDim2.new(1, -54, 0, 2)
		ValueLabel.BackgroundTransparency = 1
		ValueLabel.Text = tostring(default) .. suffix
		ValueLabel.TextColor3 = Theme.Accent
		ValueLabel.FontFace = Theme.Font
		ValueLabel.TextSize = 14
		ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

		-- Track (kotak)
		local Track = Instance.new("Frame", SliderFrame)
		Track.Size = UDim2.new(1, -16, 0, 5)
		Track.Position = UDim2.new(0, 8, 0, 28)
		Track.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
		Track.BorderSizePixel = 0

		local Fill = Instance.new("Frame", Track)
		Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
		Fill.BackgroundColor3 = Theme.Accent
		Fill.BorderSizePixel = 0

		local Knob = Instance.new("Frame", Track)
		Knob.Size = UDim2.new(0, 10, 0, 14)
		Knob.Position = UDim2.new((default - min) / (max - min), -5, 0.5, -7)
		Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Knob.BorderSizePixel = 0

		local function SetValue(val)
			val = math.clamp(val, min, max)
			val = math.floor((val - min) / increment + 0.5) * increment + min
			local pct = (val - min) / (max - min)
			TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(pct, 0, 1, 0)}):Play()
			TweenService:Create(Knob, TweenInfo.new(0.1), {Position = UDim2.new(pct, -5, 0.5, -7)}):Play()
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

	-- [ FUNGSI DROPDOWN - FIX ] --
	function Window:CreateDropdown(text, options, callback)
		options = options or {}
		local selected = options[1] or "Select..."
		local isOpen = false

		-- Frame utama dropdown
		local DDFrame = Instance.new("Frame", Scroll)
		DDFrame.Name = "Dropdown_" .. text
		DDFrame.Size = UDim2.new(1, -12, 0, 32)
		DDFrame.BackgroundColor3 = Theme.Background
		DDFrame.BorderSizePixel = 0
		DDFrame.ClipsDescendants = false
		MakeStroke(DDFrame, Theme.Stroke, 1.5)

		local Label = Instance.new("TextLabel", DDFrame)
		Label.Size = UDim2.new(1, -20, 0, 14)
		Label.Position = UDim2.new(0, 8, 0, 1)
		Label.BackgroundTransparency = 1
		Label.Text = text
		Label.TextColor3 = Theme.TextDim
		Label.FontFace = Theme.Font
		Label.TextSize = 11
		Label.TextXAlignment = Enum.TextXAlignment.Left

		local SelectedText = Instance.new("TextLabel", DDFrame)
		SelectedText.Size = UDim2.new(1, -32, 0, 18)
		SelectedText.Position = UDim2.new(0, 8, 0, 14)
		SelectedText.BackgroundTransparency = 1
		SelectedText.Text = selected
		SelectedText.TextColor3 = Theme.Text
		SelectedText.FontFace = Theme.Font
		SelectedText.TextSize = 16
		SelectedText.TextXAlignment = Enum.TextXAlignment.Left
		SelectedText.TextTruncate = Enum.TextTruncate.AtEnd

		local Arrow = Instance.new("TextLabel", DDFrame)
		Arrow.Size = UDim2.new(0, 18, 0, 18)
		Arrow.Position = UDim2.new(1, -22, 0, 8)
		Arrow.BackgroundTransparency = 1
		Arrow.Text = "▼"
		Arrow.TextColor3 = Theme.TextDim
		Arrow.FontFace = Theme.Font
		Arrow.TextSize = 12

		-- Options Container (di luar DDFrame agar tidak ter-clip, tapi masih di dalam Menu)
		local OptContainer = Instance.new("Frame", Menu)
		OptContainer.Name = "DDOptions_" .. text
		OptContainer.Size = UDim2.new(0, 180, 0, 0)
		OptContainer.Position = UDim2.new(0, 0, 0, DDFrame.AbsolutePosition.Y + 32)
		OptContainer.BackgroundColor3 = Theme.Background
		OptContainer.BorderSizePixel = 0
		OptContainer.Visible = false
		OptContainer.ZIndex = 10
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
				Btn.Size = UDim2.new(1, 0, 0, 26)
				Btn.BackgroundColor3 = Theme.Background
				Btn.Text = opt
				Btn.TextColor3 = Theme.Text
				Btn.FontFace = Theme.Font
				Btn.TextSize = 15
				Btn.AutoButtonColor = false
				Btn.BorderSizePixel = 0
				Btn.ZIndex = 11
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

		-- Update posisi OptContainer saat scroll
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
				local h = math.min(#options * 26, 130)
				OptContainer.Size = UDim2.new(0, 180, 0, h)
				OptContainer.Visible = true
				TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
			else
				OptContainer.Visible = false
				TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
			end
		end)
	end

	-- [ FUNGSI MULTISELECT ] --
	function Window:CreateMultiSelect(text, options, callback)
		options = options or {}
		local selected = {}
		local isOpen = false

		local MSFrame = Instance.new("Frame", Scroll)
		MSFrame.Name = "MultiSelect_" .. text
		MSFrame.Size = UDim2.new(1, -12, 0, 32)
		MSFrame.BackgroundColor3 = Theme.Background
		MSFrame.BorderSizePixel = 0
		MSFrame.ClipsDescendants = false
		MakeStroke(MSFrame, Theme.Stroke, 1.5)

		local Label = Instance.new("TextLabel", MSFrame)
		Label.Size = UDim2.new(1, -20, 0, 14)
		Label.Position = UDim2.new(0, 8, 0, 1)
		Label.BackgroundTransparency = 1
		Label.Text = text
		Label.TextColor3 = Theme.TextDim
		Label.FontFace = Theme.Font
		Label.TextSize = 11
		Label.TextXAlignment = Enum.TextXAlignment.Left

		local SelectedText = Instance.new("TextLabel", MSFrame)
		SelectedText.Size = UDim2.new(1, -32, 0, 18)
		SelectedText.Position = UDim2.new(0, 8, 0, 14)
		SelectedText.BackgroundTransparency = 1
		SelectedText.Text = "None"
		SelectedText.TextColor3 = Theme.Text
		SelectedText.FontFace = Theme.Font
		SelectedText.TextSize = 16
		SelectedText.TextXAlignment = Enum.TextXAlignment.Left
		SelectedText.TextTruncate = Enum.TextTruncate.AtEnd

		local Arrow = Instance.new("TextLabel", MSFrame)
		Arrow.Size = UDim2.new(0, 18, 0, 18)
		Arrow.Position = UDim2.new(1, -22, 0, 8)
		Arrow.BackgroundTransparency = 1
		Arrow.Text = "▼"
		Arrow.TextColor3 = Theme.TextDim
		Arrow.FontFace = Theme.Font
		Arrow.TextSize = 12

		-- Options Container (di luar MSFrame agar tidak ter-clip)
		local OptContainer = Instance.new("Frame", Menu)
		OptContainer.Name = "MSOptions_" .. text
		OptContainer.Size = UDim2.new(0, 180, 0, 0)
		OptContainer.Position = UDim2.new(0, 0, 0, 0)
		OptContainer.BackgroundColor3 = Theme.Background
		OptContainer.BorderSizePixel = 0
		OptContainer.Visible = false
		OptContainer.ZIndex = 10
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
				Row.Size = UDim2.new(1, 0, 0, 26)
				Row.BackgroundColor3 = Theme.Background
				Row.BorderSizePixel = 0
				Row.ZIndex = 11

				local isSel = table.find(selected, opt) ~= nil

				local CheckBox = Instance.new("Frame", Row)
				CheckBox.Size = UDim2.new(0, 14, 0, 14)
				CheckBox.Position = UDim2.new(0, 8, 0.5, -7)
				CheckBox.BackgroundColor3 = isSel and Theme.Accent or Theme.BackgroundLight
				CheckBox.BorderSizePixel = 0
				CheckBox.ZIndex = 12

				local CheckMark = Instance.new("TextLabel", CheckBox)
				CheckMark.Size = UDim2.new(1, 0, 1, 0)
				CheckMark.BackgroundTransparency = 1
				CheckMark.Text = "✓"
				CheckMark.TextColor3 = Color3.fromRGB(255,255,255)
				CheckMark.FontFace = Theme.Font
				CheckMark.TextSize = 11
				CheckMark.Visible = isSel
				CheckMark.ZIndex = 13

				local OptLabel = Instance.new("TextLabel", Row)
				OptLabel.Size = UDim2.new(1, -32, 1, 0)
				OptLabel.Position = UDim2.new(0, 28, 0, 0)
				OptLabel.BackgroundTransparency = 1
				OptLabel.Text = opt
				OptLabel.TextColor3 = Theme.Text
				OptLabel.FontFace = Theme.Font
				OptLabel.TextSize = 15
				OptLabel.TextXAlignment = Enum.TextXAlignment.Left
				OptLabel.ZIndex = 12

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

		-- Update posisi saat scroll
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
				local h = math.min(#options * 26, 130)
				OptContainer.Size = UDim2.new(0, 180, 0, h)
				OptContainer.Visible = true
				TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
			else
				OptContainer.Visible = false
				TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
			end
		end)
	end

	return Window
end

---------------------------------------------------------
-- [ SETUP TRIPLE-CLICK TOGGLE OTOMATIS ] --
---------------------------------------------------------
-- Panggil sekali saat library di-load untuk aktifkan fitur triple-click
SetupTripleClickToggle()
return Library
