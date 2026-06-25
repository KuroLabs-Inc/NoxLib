local NoxLib = {}
NoxLib.__index = NoxLib

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local Theme = {
	Background = Color3.fromRGB(15, 15, 18),
	Sidebar = Color3.fromRGB(20, 20, 24),
	Topbar = Color3.fromRGB(18, 18, 22),
	Element = Color3.fromRGB(28, 28, 34),
	ElementHover = Color3.fromRGB(38, 38, 46),
	Stroke = Color3.fromRGB(45, 45, 55),
	Accent = Color3.fromRGB(90, 140, 255),
	AccentDim = Color3.fromRGB(60, 95, 180),
	Text = Color3.fromRGB(235, 235, 240),
	SubText = Color3.fromRGB(150, 150, 160),
	Danger = Color3.fromRGB(235, 70, 70),
	Good = Color3.fromRGB(70, 200, 120),
}

local function tween(obj, time, props, style, dir)
	local info = TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, info, props)
	t:Play()
	return t
end

local function corner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = obj
	return c
end

local function stroke(obj, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Theme.Stroke
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = obj
	return s
end

local function pad(obj, all)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, all)
	p.PaddingBottom = UDim.new(0, all)
	p.PaddingLeft = UDim.new(0, all)
	p.PaddingRight = UDim.new(0, all)
	p.Parent = obj
	return p
end

local function makeImageId(value)
	if value == nil then
		return ""
	end
	if typeof(value) == "number" then
		return "rbxassetid://" .. tostring(value)
	end
	value = tostring(value)
	if value == "" then
		return ""
	end
	if string.find(value, "rbxassetid://") or string.find(value, "rbxasset://") or string.find(value, "http") then
		return value
	end
	if string.match(value, "^%d+$") then
		return "rbxassetid://" .. value
	end
	return value
end

local function draggable(frame, handle)
	handle = handle or frame
	local dragging = false
	local dragStart, startPos
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function NoxLib:CreateWindow(config)
	config = config or {}
	local windowTitle = config.Title or "Nox Library"
	local windowSubTitle = config.SubTitle or "Premium UI"
	local toggleImage = config.ToggleImage or config.Image or 0
	local toggleText = config.ToggleText or "Open"

	local self = setmetatable({}, NoxLib)
	self.Tabs = {}
	self.Connections = {}
	self.Threads = {}
	self.Destroyed = false

	local oldGui = nil
	pcall(function()
		oldGui = CoreGui:FindFirstChild("NoxLibScreenGui")
	end)
	if oldGui then
		oldGui:Destroy()
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "NoxLibScreenGui"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.IgnoreGuiInset = true
	local ok = pcall(function()
		ScreenGui.Parent = CoreGui
	end)
	if not ok then
		ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
	self.ScreenGui = ScreenGui

	local defaultSize = UDim2.new(0, 480, 0, 320)

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = defaultSize
	Main.Position = UDim2.new(0.5, -240, 0.5, -160)
	Main.BackgroundColor3 = Theme.Background
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui
	corner(Main, 12)
	stroke(Main, Theme.Stroke, 1.4)
	self.Main = Main

	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://6014261993"
	shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	shadow.ImageTransparency = 0.4
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow.Size = UDim2.new(1, 60, 1, 60)
	shadow.Position = UDim2.new(0, -30, 0, -30)
	shadow.ZIndex = 0
	shadow.Parent = Main

	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, 34)
	Topbar.BackgroundColor3 = Theme.Topbar
	Topbar.BorderSizePixel = 0
	Topbar.Parent = Main
	corner(Topbar, 12)

	local topbarFix = Instance.new("Frame")
	topbarFix.Size = UDim2.new(1, 0, 0, 14)
	topbarFix.Position = UDim2.new(0, 0, 1, -14)
	topbarFix.BackgroundColor3 = Theme.Topbar
	topbarFix.BorderSizePixel = 0
	topbarFix.Parent = Topbar

	draggable(Main, Topbar)

	-- ====================================================================
	-- TWEAK: SUSUNAN BARU TOPBAR (JUDUL KIRI, TOMBOL KANAN)
	-- ====================================================================
	
	-- Judul / Nama Script dipindah ke KIRI
	local titleHolder = Instance.new("Frame")
	titleHolder.BackgroundTransparency = 1
	titleHolder.Size = UDim2.new(1, -110, 1, 0)
	titleHolder.Position = UDim2.new(0, 14, 0, 0) -- Jarak aman dari pinggir kiri
	titleHolder.Parent = Topbar

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Size = UDim2.new(1, 0, 1, 0)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = windowTitle
	titleLabel.TextColor3 = Theme.Text
	titleLabel.TextSize = 13
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left -- Teks rata KIRI
	titleLabel.Parent = titleHolder

	local subLabel = Instance.new("TextLabel")
	subLabel.Visible = false
	subLabel.BackgroundTransparency = 1
	subLabel.Text = windowSubTitle
	subLabel.Parent = titleHolder

	-- Tombol Kontrol (-, +, X) dipindah ke KANAN
	local btnHolder = Instance.new("Frame")
	btnHolder.Name = "Buttons"
	btnHolder.BackgroundTransparency = 1
	btnHolder.Size = UDim2.new(0, 80, 1, 0)
	btnHolder.Position = UDim2.new(1, -94, 0, 0) -- Nempel ke pinggir kanan
	btnHolder.Parent = Topbar
	
	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right -- Item menyusun dari kanan
	btnLayout.Padding = UDim.new(0, 4)
	btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
	btnLayout.Parent = btnHolder

	local function symButton(symbol, color, order)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 24, 0, 24)
		b.BackgroundColor3 = Theme.Element
		b.BackgroundTransparency = 1
		b.Font = Enum.Font.GothamBold
		b.Text = symbol
		b.TextColor3 = color
		b.TextSize = 15
		b.AutoButtonColor = false
		b.BorderSizePixel = 0
		b.LayoutOrder = order
		b.Parent = btnHolder
		corner(b, 6)
		b.MouseEnter:Connect(function()
			tween(b, 0.12, { BackgroundTransparency = 0, TextColor3 = Theme.Text })
		end)
		b.MouseLeave:Connect(function()
			tween(b, 0.12, { BackgroundTransparency = 1, TextColor3 = color })
		end)
		return b
	end

	-- Diurutkan dari kiri ke kanan: Minimize (-), Maximize (+), lalu Close (X)
	local minimizeBtn = symButton("-", Theme.SubText, 1)
	local maximizeBtn = symButton("+", Theme.SubText, 2)
	local destroyBtn = symButton("\u{00D7}", Theme.Danger, 3)

	-- ====================================================================

	local Body = Instance.new("Frame")
	Body.Name = "Body"
	Body.BackgroundTransparency = 1
	Body.Size = UDim2.new(1, 0, 1, -34)
	Body.Position = UDim2.new(0, 0, 0, 34)
	Body.Parent = Main

	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.BackgroundColor3 = Theme.Background
	Content.BorderSizePixel = 0
	Content.Size = UDim2.new(1, -146, 1, -10)
	Content.Position = UDim2.new(0, 6, 0, 2)
	Content.Parent = Body

	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Size = UDim2.new(0, 132, 1, -10)
	Sidebar.Position = UDim2.new(1, -138, 0, 2)
	Sidebar.Parent = Body
	corner(Sidebar, 10)
	stroke(Sidebar, Theme.Stroke, 1)

	local sbTitle = Instance.new("TextLabel")
	sbTitle.BackgroundTransparency = 1
	sbTitle.Size = UDim2.new(1, -20, 0, 24)
	sbTitle.Position = UDim2.new(0, 12, 0, 8)
	sbTitle.Font = Enum.Font.GothamBold
	sbTitle.Text = "Tabs"
	sbTitle.TextColor3 = Theme.SubText
	sbTitle.TextSize = 12
	sbTitle.TextXAlignment = Enum.TextXAlignment.Left
	sbTitle.Parent = Sidebar

	local TabList = Instance.new("ScrollingFrame")
	TabList.Name = "TabList"
	TabList.BackgroundTransparency = 1
	TabList.BorderSizePixel = 0
	TabList.Size = UDim2.new(1, -12, 1, -44)
	TabList.Position = UDim2.new(0, 6, 0, 36)
	TabList.ScrollBarThickness = 3
	TabList.ScrollBarImageColor3 = Theme.Accent
	TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TabList.Parent = Sidebar
	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 6)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = TabList

	local Pages = Instance.new("Frame")
	Pages.Name = "Pages"
	Pages.BackgroundTransparency = 1
	Pages.Size = UDim2.new(1, 0, 1, 0)
	Pages.Parent = Content
	self.Pages = Pages
	self.TabList = TabList

	local OpenButton = Instance.new("TextButton")
	OpenButton.Name = "NoxOpenButton"
	OpenButton.Size = UDim2.new(0, 50, 0, 50)
	OpenButton.Position = UDim2.new(0, 20, 0, 80)
	OpenButton.BackgroundColor3 = Theme.Sidebar
	OpenButton.Text = ""
	OpenButton.AutoButtonColor = false
	OpenButton.BorderSizePixel = 0
	OpenButton.Visible = false
	OpenButton.Parent = ScreenGui
	corner(OpenButton, 12)
	stroke(OpenButton, Theme.Accent, 1.4)
	draggable(OpenButton, OpenButton)

	local openImg = Instance.new("ImageLabel")
	openImg.BackgroundColor3 = Theme.Element
	openImg.Size = UDim2.new(1, -8, 1, -8)
	openImg.Position = UDim2.new(0, 4, 0, 4)
	openImg.Image = makeImageId(toggleImage)
	openImg.ScaleType = Enum.ScaleType.Crop
	openImg.Parent = OpenButton
	corner(openImg, 9)

	OpenButton.MouseEnter:Connect(function()
		tween(OpenButton, 0.12, { Size = UDim2.new(0, 54, 0, 54) })
	end)
	OpenButton.MouseLeave:Connect(function()
		tween(OpenButton, 0.12, { Size = UDim2.new(0, 50, 0, 50) })
	end)
	self.OpenButton = OpenButton

	local resizeHandle = Instance.new("ImageButton")
	resizeHandle.Name = "ResizeHandle"
	resizeHandle.AnchorPoint = Vector2.new(1, 1)
	resizeHandle.Size = UDim2.new(0, 18, 0, 18)
	resizeHandle.Position = UDim2.new(1, -4, 1, -4)
	resizeHandle.BackgroundTransparency = 1
	resizeHandle.Image = "rbxassetid://6035047391"
	resizeHandle.ImageColor3 = Theme.SubText
	resizeHandle.ImageTransparency = 0.3
	resizeHandle.Rotation = 90
	resizeHandle.Visible = false
	resizeHandle.ZIndex = 5
	resizeHandle.Parent = Main

	local minSize = Vector2.new(380, 250)
	local maxSize = Vector2.new(760, 520)
	resizeHandle.Visible = true

	do
		local rdragging = false
		local rstart, rsize
		resizeHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				rdragging = true
				rstart = input.Position
				rsize = Main.AbsoluteSize
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						rdragging = false
					end
				end)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if rdragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - rstart
				local nx = math.clamp(rsize.X + delta.X, minSize.X, maxSize.X)
				local ny = math.clamp(rsize.Y + delta.Y, minSize.Y, maxSize.Y)
				Main.Size = UDim2.new(0, nx, 0, ny)
			end
		end)
	end

	local maximized = false
	local lastSize, lastPos
	maximizeBtn.MouseButton1Click:Connect(function()
		if not maximized then
			lastSize = Main.Size
			lastPos = Main.Position
			local currentHeight = Main.Size.Y.Offset
			tween(Main, 0.25, {
				Size = UDim2.new(0, maxSize.X, 0, currentHeight),
				Position = UDim2.new(0.5, -maxSize.X / 2, Main.Position.Y.Scale, Main.Position.Y.Offset),
			})
			maximized = true
		else
			tween(Main, 0.25, { Size = lastSize, Position = lastPos })
			maximized = false
		end
	end)

	local function showWindow()
		Main.Visible = true
		OpenButton.Visible = false
		Main.Size = UDim2.new(Main.Size.X.Scale, Main.Size.X.Offset, 0, 0)
		tween(Main, 0.25, { Size = defaultSize }, Enum.EasingStyle.Back)
	end

	local function hideWindow()
		tween(Main, 0.2, { Size = UDim2.new(Main.Size.X.Scale, Main.Size.X.Offset, 0, 0) }).Completed:Connect(function()
			Main.Visible = false
			OpenButton.Visible = true
		end)
	end

	minimizeBtn.MouseButton1Click:Connect(function()
		hideWindow()
	end)

	OpenButton.MouseButton1Click:Connect(function()
		showWindow()
	end)

	local Overlay = Instance.new("Frame")
	Overlay.Name = "Overlay"
	Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Overlay.BackgroundTransparency = 1
	Overlay.Size = UDim2.new(1, 0, 1, 0)
	Overlay.Visible = false
	Overlay.ZIndex = 20
	Overlay.Parent = Main

	local Dialog = Instance.new("Frame")
	Dialog.Name = "Dialog"
	Dialog.AnchorPoint = Vector2.new(0.5, 0.5)
	Dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
	Dialog.Size = UDim2.new(0, 320, 0, 150)
	Dialog.BackgroundColor3 = Theme.Sidebar
	Dialog.BorderSizePixel = 0
	Dialog.ZIndex = 21
	Dialog.Parent = Overlay
	corner(Dialog, 12)
	stroke(Dialog, Theme.Danger, 1.4)

	local dTitle = Instance.new("TextLabel")
	dTitle.BackgroundTransparency = 1
	dTitle.Size = UDim2.new(1, -24, 0, 30)
	dTitle.Position = UDim2.new(0, 12, 0, 14)
	dTitle.Font = Enum.Font.GothamBold
	dTitle.Text = "Warning"
	dTitle.TextColor3 = Theme.Danger
	dTitle.TextSize = 16
	dTitle.TextXAlignment = Enum.TextXAlignment.Left
	dTitle.ZIndex = 22
	dTitle.Parent = Dialog

	local dDesc = Instance.new("TextLabel")
	dDesc.BackgroundTransparency = 1
	dDesc.Size = UDim2.new(1, -24, 0, 40)
	dDesc.Position = UDim2.new(0, 12, 0, 44)
	dDesc.Font = Enum.Font.Gotham
	dDesc.Text = "Are you sure wanna Destroy The UI?"
	dDesc.TextColor3 = Theme.Text
	dDesc.TextSize = 13
	dDesc.TextWrapped = true
	dDesc.TextXAlignment = Enum.TextXAlignment.Left
	dDesc.TextYAlignment = Enum.TextYAlignment.Top
	dDesc.ZIndex = 22
	dDesc.Parent = Dialog

	local yesBtn = Instance.new("TextButton")
	yesBtn.Size = UDim2.new(0.5, -18, 0, 36)
	yesBtn.Position = UDim2.new(0, 12, 1, -48)
	yesBtn.BackgroundColor3 = Theme.Danger
	yesBtn.Font = Enum.Font.GothamBold
	yesBtn.Text = "Yes"
	yesBtn.TextColor3 = Theme.Text
	yesBtn.TextSize = 14
	yesBtn.AutoButtonColor = false
	yesBtn.BorderSizePixel = 0
	yesBtn.ZIndex = 22
	yesBtn.Parent = Dialog
	corner(yesBtn, 8)

	local noBtn = Instance.new("TextButton")
	noBtn.Size = UDim2.new(0.5, -18, 0, 36)
	noBtn.Position = UDim2.new(0.5, 6, 1, -48)
	noBtn.BackgroundColor3 = Theme.Element
	noBtn.Font = Enum.Font.GothamBold
	noBtn.Text = "No"
	noBtn.TextColor3 = Theme.Text
	noBtn.TextSize = 14
	noBtn.AutoButtonColor = false
	noBtn.BorderSizePixel = 0
	noBtn.ZIndex = 22
	noBtn.Parent = Dialog
	corner(noBtn, 8)

	local function openDialog()
		Overlay.Visible = true
		Dialog.Size = UDim2.new(0, 320, 0, 0)
		tween(Overlay, 0.18, { BackgroundTransparency = 0.45 })
		tween(Dialog, 0.22, { Size = UDim2.new(0, 320, 0, 150) }, Enum.EasingStyle.Back)
	end

	local function closeDialog()
		tween(Overlay, 0.18, { BackgroundTransparency = 1 })
		tween(Dialog, 0.18, { Size = UDim2.new(0, 320, 0, 0) }).Completed:Connect(function()
			Overlay.Visible = false
		end)
	end

	destroyBtn.MouseButton1Click:Connect(function()
		openDialog()
	end)

	noBtn.MouseButton1Click:Connect(function()
		closeDialog()
	end)

	yesBtn.MouseButton1Click:Connect(function()
		self:Destroy()
	end)

	hideWindow()
	OpenButton.Visible = true
	task.wait(0.05)
	showWindow()

	return self
end

function NoxLib:_makeSection(parent, title)
	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -10, 0, 24)
	label.Font = Enum.Font.GothamBold
	label.Text = title
	label.TextColor3 = Theme.SubText
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

function NoxLib:CreateTab(config)
	config = config or {}
	local name = config.Name or config.Title or "Tab"
	local icon = config.Icon

	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(1, -6, 0, 34)
	tabBtn.BackgroundColor3 = Theme.Element
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = ""
	tabBtn.AutoButtonColor = false
	tabBtn.BorderSizePixel = 0
	tabBtn.Parent = self.TabList
	corner(tabBtn, 8)

	local tabIcon
	if icon then
		tabIcon = Instance.new("ImageLabel")
		tabIcon.BackgroundTransparency = 1
		tabIcon.Size = UDim2.new(0, 18, 0, 18)
		tabIcon.Position = UDim2.new(0, 10, 0.5, -9)
		tabIcon.Image = makeImageId(icon)
		tabIcon.ImageColor3 = Theme.SubText
		tabIcon.Parent = tabBtn
	end

	local tabLabel = Instance.new("TextLabel")
	tabLabel.BackgroundTransparency = 1
	tabLabel.Size = UDim2.new(1, icon and -38 or -20, 1, 0)
	tabLabel.Position = UDim2.new(0, icon and 36 or 12, 0, 0)
	tabLabel.Font = Enum.Font.GothamMedium
	tabLabel.Text = name
	tabLabel.TextColor3 = Theme.SubText
	tabLabel.TextSize = 13
	tabLabel.TextXAlignment = Enum.TextXAlignment.Left
	tabLabel.Parent = tabBtn

	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.Size = UDim2.new(1, 0, 1, 0)
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = Theme.Accent
	page.CanvasSize = UDim2.new(0, 0, 0, 0)
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = self.Pages
	local pLayout = Instance.new("UIListLayout")
	pLayout.Padding = UDim.new(0, 8)
	pLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pLayout.Parent = page
	pad(page, 10)

	local tabData = { Button = tabBtn, Page = page, Label = tabLabel, Icon = tabIcon }
	table.insert(self.Tabs, tabData)

	local function select()
		for _, t in ipairs(self.Tabs) do
			t.Page.Visible = false
			tween(t.Button, 0.15, { BackgroundTransparency = 1 })
			tween(t.Label, 0.15, { TextColor3 = Theme.SubText })
			if t.Icon then
				tween(t.Icon, 0.15, { ImageColor3 = Theme.SubText })
			end
		end
		page.Visible = true
		tween(tabBtn, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = Theme.Element })
		tween(tabLabel, 0.15, { TextColor3 = Theme.Text })
		if tabIcon then
			tween(tabIcon, 0.15, { ImageColor3 = Theme.Accent })
		end
	end

	tabBtn.MouseButton1Click:Connect(select)
	tabBtn.MouseEnter:Connect(function()
		if not page.Visible then
			tween(tabBtn, 0.12, { BackgroundTransparency = 0.6 })
		end
	end)
	tabBtn.MouseLeave:Connect(function()
		if not page.Visible then
			tween(tabBtn, 0.12, { BackgroundTransparency = 1 })
		end
	end)

	if #self.Tabs == 1 then
		select()
	end

	local Components = {}

	local function baseElement(height)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, 0, 0, height or 44)
		f.BackgroundColor3 = Theme.Element
		f.BorderSizePixel = 0
		f.Parent = page
		corner(f, 8)
		stroke(f, Theme.Stroke, 1)
		return f
	end

	function Components:AddSection(text)
		return self and NoxLib:_makeSection(page, text or "Section")
	end

	function Components:AddButton(cfg)
		cfg = cfg or {}
		local f = baseElement(44)
		local b = Instance.new("TextButton")
		b.BackgroundTransparency = 1
		b.Size = UDim2.new(1, 0, 1, 0)
		b.Text = ""
		b.Parent = f

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, -50, 1, 0)
		lbl.Position = UDim2.new(0, 14, 0, 0)
		lbl.Font = Enum.Font.GothamMedium
		lbl.Text = cfg.Name or cfg.Title or "Button"
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = f

		local arrow = Instance.new("ImageLabel")
		arrow.BackgroundTransparency = 1
		arrow.Size = UDim2.new(0, 16, 0, 16)
		arrow.Position = UDim2.new(1, -28, 0.5, -8)
		arrow.Image = "rbxassetid://6034818372"
		arrow.ImageColor3 = Theme.SubText
		arrow.Parent = f

		b.MouseEnter:Connect(function()
			tween(f, 0.12, { BackgroundColor3 = Theme.ElementHover })
		end)
		b.MouseLeave:Connect(function()
			tween(f, 0.12, { BackgroundColor3 = Theme.Element })
		end)
		b.MouseButton1Click:Connect(function()
			tween(f, 0.08, { BackgroundColor3 = Theme.AccentDim }).Completed:Connect(function()
				tween(f, 0.15, { BackgroundColor3 = Theme.Element })
			end)
			if cfg.Callback then
				task.spawn(cfg.Callback)
			end
		end)
		return f
	end

	function Components:AddToggle(cfg)
		cfg = cfg or {}
		local state = cfg.Default or false
		local f = baseElement(44)

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, -70, 1, 0)
		lbl.Position = UDim2.new(0, 14, 0, 0)
		lbl.Font = Enum.Font.GothamMedium
		lbl.Text = cfg.Name or cfg.Title or "Toggle"
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = f

		local pill = Instance.new("Frame")
		pill.Size = UDim2.new(0, 42, 0, 22)
		pill.Position = UDim2.new(1, -54, 0.5, -11)
		pill.BackgroundColor3 = Theme.Stroke
		pill.BorderSizePixel = 0
		pill.Parent = f
		corner(pill, 11)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.new(0, 16, 0, 16)
		knob.Position = UDim2.new(0, 3, 0.5, -8)
		knob.BackgroundColor3 = Theme.Text
		knob.BorderSizePixel = 0
		knob.Parent = pill
		corner(knob, 8)

		local btn = Instance.new("TextButton")
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.Text = ""
		btn.Parent = f

		local function set(v, fire)
			state = v
			if state then
				tween(pill, 0.18, { BackgroundColor3 = Theme.Accent })
				tween(knob, 0.18, { Position = UDim2.new(1, -19, 0.5, -8) })
			else
				tween(pill, 0.18, { BackgroundColor3 = Theme.Stroke })
				tween(knob, 0.18, { Position = UDim2.new(0, 3, 0.5, -8) })
			end
			if fire and cfg.Callback then
				task.spawn(cfg.Callback, state)
			end
		end

		btn.MouseButton1Click:Connect(function()
			set(not state, true)
		end)
		set(state, false)

		return { Set = function(_, v) set(v, true) end, Get = function() return state end }
	end

	function Components:AddSlider(cfg)
		cfg = cfg or {}
		local min = cfg.Min or 0
		local max = cfg.Max or 100
		local value = cfg.Default or min
		local decimals = cfg.Decimals or 0
		local f = baseElement(56)

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, -70, 0, 22)
		lbl.Position = UDim2.new(0, 14, 0, 6)
		lbl.Font = Enum.Font.GothamMedium
		lbl.Text = cfg.Name or cfg.Title or "Slider"
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = f

		local valLbl = Instance.new("TextLabel")
		valLbl.BackgroundTransparency = 1
		valLbl.Size = UDim2.new(0, 60, 0, 22)
		valLbl.Position = UDim2.new(1, -68, 0, 6)
		valLbl.Font = Enum.Font.GothamBold
		valLbl.Text = tostring(value)
		valLbl.TextColor3 = Theme.Accent
		valLbl.TextSize = 13
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.Parent = f

		local track = Instance.new("Frame")
		track.Size = UDim2.new(1, -28, 0, 6)
		track.Position = UDim2.new(0, 14, 1, -16)
		track.BackgroundColor3 = Theme.Stroke
		track.BorderSizePixel = 0
		track.Parent = f
		corner(track, 3)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.BackgroundColor3 = Theme.Accent
		fill.BorderSizePixel = 0
		fill.Parent = track
		corner(fill, 3)

		local function round(n)
			local m = 10 ^ decimals
			return math.floor(n * m + 0.5) / m
		end

		local function set(v, fire)
			v = math.clamp(v, min, max)
			value = round(v)
			local ratio = (value - min) / (max - min)
			fill.Size = UDim2.new(ratio, 0, 1, 0)
			valLbl.Text = tostring(value)
			if fire and cfg.Callback then
				task.spawn(cfg.Callback, value)
			end
		end

		local dragging = false
		local function update(input)
			local rel = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
			set(min + (max - min) * rel, true)
		end

		track.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				update(input)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				update(input)
			end
		end)

		set(value, false)
		return { Set = function(_, v) set(v, true) end, Get = function() return value end }
	end

	function Components:AddDropdown(cfg)
		cfg = cfg or {}
		local options = cfg.Options or {}
		local multi = cfg.Multi or false
		local selected = multi and {} or (cfg.Default or nil)
		local open = false
		local f = baseElement(44)
		f.ClipsDescendants = true

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, -60, 0, 44)
		lbl.Position = UDim2.new(0, 14, 0, 0)
		lbl.Font = Enum.Font.GothamMedium
		lbl.Text = cfg.Name or cfg.Title or "Dropdown"
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = f

		local valLbl = Instance.new("TextLabel")
		valLbl.BackgroundTransparency = 1
		valLbl.Size = UDim2.new(0, 120, 0, 44)
		valLbl.Position = UDim2.new(1, -150, 0, 0)
		valLbl.Font = Enum.Font.Gotham
		valLbl.Text = multi and "None" or (selected or "Select")
		valLbl.TextColor3 = Theme.SubText
		valLbl.TextSize = 12
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.Parent = f

		local arrow = Instance.new("ImageLabel")
		arrow.BackgroundTransparency = 1
		arrow.Size = UDim2.new(0, 16, 0, 16)
		arrow.Position = UDim2.new(1, -26, 0, 14)
		arrow.Image = "rbxassetid://6034818372"
		arrow.ImageColor3 = Theme.SubText
		arrow.Rotation = 90
		arrow.Parent = f

		local listHolder = Instance.new("Frame")
		listHolder.BackgroundTransparency = 1
		listHolder.Size = UDim2.new(1, -16, 0, 0)
		listHolder.Position = UDim2.new(0, 8, 0, 48)
		listHolder.Parent = f
		local lLayout = Instance.new("UIListLayout")
		lLayout.Padding = UDim.new(0, 4)
		lLayout.SortOrder = Enum.SortOrder.LayoutOrder
		lLayout.Parent = listHolder

		local function refreshText()
			if multi then
				local t = {}
				for k, v in pairs(selected) do
					if v then
						table.insert(t, k)
					end
				end
				valLbl.Text = #t > 0 and table.concat(t, ", ") or "None"
			else
				valLbl.Text = selected or "Select"
			end
		end

		local function rebuild()
			for _, c in ipairs(listHolder:GetChildren()) do
				if c:IsA("TextButton") then
					c:Destroy()
				end
			end
			for _, opt in ipairs(options) do
				local ob = Instance.new("TextButton")
				ob.Size = UDim2.new(1, 0, 0, 30)
				ob.BackgroundColor3 = Theme.Sidebar
				ob.Font = Enum.Font.Gotham
				ob.Text = "  " .. tostring(opt)
				ob.TextColor3 = Theme.Text
				ob.TextSize = 12
				ob.TextXAlignment = Enum.TextXAlignment.Left
				ob.AutoButtonColor = false
				ob.BorderSizePixel = 0
				ob.Parent = listHolder
				corner(ob, 6)

				local function paint()
					local on = multi and selected[opt] or (selected == opt)
					ob.TextColor3 = on and Theme.Accent or Theme.Text
					ob.BackgroundColor3 = on and Theme.ElementHover or Theme.Sidebar
				end
				paint()

				ob.MouseButton1Click:Connect(function()
					if multi then
						selected[opt] = not selected[opt]
					else
						selected = opt
					end
					refreshText()
					for _, c in ipairs(listHolder:GetChildren()) do
						if c:IsA("TextButton") then
							local nm = string.gsub(c.Text, "^%s+", "")
							local s = multi and selected[nm] or (selected == nm)
							c.TextColor3 = s and Theme.Accent or Theme.Text
							c.BackgroundColor3 = s and Theme.ElementHover or Theme.Sidebar
						end
					end
					if cfg.Callback then
						task.spawn(cfg.Callback, selected)
					end
				end)
			end
		end
		rebuild()

		local btn = Instance.new("TextButton")
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.new(1, 0, 0, 44)
		btn.Text = ""
		btn.Parent = f

		btn.MouseButton1Click:Connect(function()
			open = not open
			local count = #options
			local target = open and (48 + count * 34 + 8) or 44
			tween(f, 0.2, { Size = UDim2.new(1, 0, 0, target) })
			tween(arrow, 0.2, { Rotation = open and -90 or 90 })
		end)

		return {
			Set = function(_, v) selected = v refreshText() rebuild() end,
			Get = function() return selected end,
			Refresh = function(_, newOpts) options = newOpts or options rebuild() end,
		}
	end

	function Components:AddTextbox(cfg)
		cfg = cfg or {}
		local f = baseElement(44)

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(0, 140, 1, 0)
		lbl.Position = UDim2.new(0, 14, 0, 0)
		lbl.Font = Enum.Font.GothamMedium
		lbl.Text = cfg.Name or cfg.Title or "Textbox"
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = f

		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0, 150, 0, 28)
		box.Position = UDim2.new(1, -164, 0.5, -14)
		box.BackgroundColor3 = Theme.Sidebar
		box.Font = Enum.Font.Gotham
		box.PlaceholderText = cfg.Placeholder or "Type here..."
		box.PlaceholderColor3 = Theme.SubText
		box.Text = cfg.Default or ""
		box.TextColor3 = Theme.Text
		box.TextSize = 12
		box.ClearTextOnFocus = false
		box.BorderSizePixel = 0
		box.Parent = f
		corner(box, 6)
		stroke(box, Theme.Stroke, 1)

		box.Focused:Connect(function()
			tween(box, 0.12, { BackgroundColor3 = Theme.ElementHover })
		end)
		box.FocusLost:Connect(function(enter)
			tween(box, 0.12, { BackgroundColor3 = Theme.Sidebar })
			if cfg.Callback then
				task.spawn(cfg.Callback, box.Text, enter)
			end
		end)

		return { Set = function(_, v) box.Text = v end, Get = function() return box.Text end }
	end

	function Components:AddKeybind(cfg)
		cfg = cfg or {}
		local current = cfg.Default or Enum.KeyCode.RightShift
		local binding = false
		local f = baseElement(44)

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, -120, 1, 0)
		lbl.Position = UDim2.new(0, 14, 0, 0)
		lbl.Font = Enum.Font.GothamMedium
		lbl.Text = cfg.Name or cfg.Title or "Keybind"
		lbl.TextColor3 = Theme.Text
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = f

		local keyBtn = Instance.new("TextButton")
		keyBtn.Size = UDim2.new(0, 90, 0, 28)
		keyBtn.Position = UDim2.new(1, -104, 0.5, -14)
		keyBtn.BackgroundColor3 = Theme.Sidebar
		keyBtn.Font = Enum.Font.GothamBold
		keyBtn.Text = current.Name
		keyBtn.TextColor3 = Theme.Accent
		keyBtn.TextSize = 12
		keyBtn.AutoButtonColor = false
		keyBtn.BorderSizePixel = 0
		keyBtn.Parent = f
		corner(keyBtn, 6)
		stroke(keyBtn, Theme.Stroke, 1)

		keyBtn.MouseButton1Click:Connect(function()
			binding = true
			keyBtn.Text = "..."
		end)

		local conn = UserInputService.InputBegan:Connect(function(input, gpe)
			if binding and input.UserInputType == Enum.UserInputType.Keyboard then
				current = input.KeyCode
				keyBtn.Text = current.Name
				binding = false
			elseif not binding and not gpe and input.KeyCode == current then
				if cfg.Callback then
					task.spawn(cfg.Callback)
				end
			end
		end)
		table.insert(self.Connections or {}, conn)

		return { Set = function(_, k) current = k keyBtn.Text = k.Name end, Get = function() return current end }
	end

	function Components:AddLabel(text)
		local f = baseElement(36)
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, -28, 1, 0)
		lbl.Position = UDim2.new(0, 14, 0, 0)
		lbl.Font = Enum.Font.Gotham
		lbl.Text = text or "Label"
		lbl.TextColor3 = Theme.SubText
		lbl.TextSize = 12
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextWrapped = true
		lbl.Parent = f
		return { Set = function(_, t) lbl.Text = t end }
	end

	return Components
end

function NoxLib:Notify(cfg)
	cfg = cfg or {}
	local holder = self.ScreenGui:FindFirstChild("NotifHolder")
	if not holder then
		holder = Instance.new("Frame")
		holder.Name = "NotifHolder"
		holder.BackgroundTransparency = 1
		holder.AnchorPoint = Vector2.new(1, 1)
		holder.Position = UDim2.new(1, -16, 1, -16)
		holder.Size = UDim2.new(0, 280, 1, -32)
		holder.Parent = self.ScreenGui
		local l = Instance.new("UIListLayout")
		l.VerticalAlignment = Enum.VerticalAlignment.Bottom
		l.HorizontalAlignment = Enum.HorizontalAlignment.Right
		l.Padding = UDim.new(0, 8)
		l.SortOrder = Enum.SortOrder.LayoutOrder
		l.Parent = holder
	end

	local n = Instance.new("Frame")
	n.Size = UDim2.new(1, 0, 0, 0)
	n.AutomaticSize = Enum.AutomaticSize.Y
	n.BackgroundColor3 = Theme.Sidebar
	n.BorderSizePixel = 0
	n.Parent = holder
	corner(n, 8)
	stroke(n, Theme.Accent, 1.2)
	pad(n, 10)

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 4)
	layout.Parent = n

	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.new(1, 0, 0, 18)
	t.Font = Enum.Font.GothamBold
	t.Text = cfg.Title or "Notification"
	t.TextColor3 = Theme.Text
	t.TextSize = 13
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.Parent = n

	local d = Instance.new("TextLabel")
	d.BackgroundTransparency = 1
	d.Size = UDim2.new(1, 0, 0, 0)
	d.AutomaticSize = Enum.AutomaticSize.Y
	d.Font = Enum.Font.Gotham
	d.Text = cfg.Content or cfg.Text or ""
	d.TextColor3 = Theme.SubText
	d.TextSize = 12
	d.TextWrapped = true
	d.TextXAlignment = Enum.TextXAlignment.Left
	d.Parent = n

	task.delay(cfg.Duration or 4, function()
		tween(n, 0.25, { BackgroundTransparency = 1 }).Completed:Connect(function()
			n:Destroy()
		end)
	end)
end

function NoxLib:Destroy()
	if self.Destroyed then
		return
	end
	self.Destroyed = true

	for _, conn in ipairs(self.Connections or {}) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	self.Connections = {}

	for _, th in ipairs(self.Threads or {}) do
		pcall(function()
			task.cancel(th)
		end)
	end
	self.Threads = {}

	if getgenv then
		local g = getgenv()
		if g.NoxLibFlags then
			for k in pairs(g.NoxLibFlags) do
				g.NoxLibFlags[k] = nil
			end
		end
	end

	if self.Main then
		tween(self.Main, 0.2, { Size = UDim2.new(0, self.Main.AbsoluteSize.X, 0, 0), BackgroundTransparency = 1 })
	end

	task.wait(0.22)

	if self.OpenButton then
		pcall(function()
			self.OpenButton:Destroy()
		end)
	end
	if self.ScreenGui then
		pcall(function()
			self.ScreenGui:Destroy()
		end)
	end

	self.Tabs = {}
	self.Main = nil
	self.ScreenGui = nil
end

return NoxLib
