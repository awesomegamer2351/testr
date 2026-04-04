--[[
    CHEETO UI LIBRARY V5 (DROPDOWN ENLARGED)
    - Config system (save/load/delete)
    - Toggle, Slider, Dropdown, Textbox, Button, ColorPicker
    - Description panel, draggable window, hide/show
    - User avatar + welcome text in top bar
    - DROPDOWN: auto-width, larger (32px height, 14px text), left-aligned text with padding
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer

local Library = {
    MainColor         = Color3.fromRGB(31, 33, 35),
    SidebarColor      = Color3.fromRGB(31, 33, 35),
    SeparatorColor    = Color3.fromRGB(40, 42, 44),
    SectionColor      = Color3.fromRGB(35, 38, 39),
    ToggleOffColor    = Color3.fromRGB(60, 62, 112),
    ToggleOnColor     = Color3.fromRGB(109, 111, 240),
    TextActiveColor   = Color3.fromRGB(255, 255, 255),
    TextInactiveColor = Color3.fromRGB(180, 182, 186),
    SliderOffColor    = Color3.fromRGB(55, 57, 61),
    TabSelectedBg     = Color3.fromRGB(40, 42, 44),
    Font              = Enum.Font.GothamMedium,
    _notificationParent = nil,
    _dropdownOpen     = false,
    _colorPickerOpen  = false,
    _draggingColorPicker = false,
    _configElements   = {},
    _configFolder     = "CheetoConfigs",
}

local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do obj[i] = v end
    return obj
end

function Library:Notify(title, description, duration)
    if not self._notificationParent then return end
    duration = duration or 3

    local notif = Create("Frame", {
        Parent = self._notificationParent,
        Size = UDim2.new(0, 280, 0, 60),
        Position = UDim2.new(1, -300, 1, -80),
        BackgroundColor3 = self.MainColor,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = notif})
    Create("Frame", {
        Parent = notif,
        Size = UDim2.new(0, 4, 1, 0),
        BackgroundColor3 = self.ToggleOnColor,
        BorderSizePixel = 0
    })
    Create("TextLabel", {
        Parent = notif,
        Text = title,
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        TextColor3 = self.TextActiveColor,
        Font = self.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    })
    Create("TextLabel", {
        Parent = notif,
        Text = description,
        Size = UDim2.new(1, -16, 0, 28),
        Position = UDim2.new(0, 12, 0, 28),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(200, 202, 206),
        Font = self.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrap = true
    })

    local tweenIn = TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0})
    tweenIn:Play()
    task.wait(duration)
    local tweenOut = TweenService:Create(notif, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
        Position = UDim2.new(1, 20, 1, -80),
        BackgroundTransparency = 1
    })
    tweenOut:Play()
    tweenOut.Completed:Connect(function() notif:Destroy() end)
end

-- ========== CONFIG SYSTEM ==========
function Library:SaveConfig(configName)
    if not configName or configName == "" then
        self:Notify("Config Error", "Please enter a config name", 3)
        return
    end
    
    local configData = {}
    for elementId, element in pairs(self._configElements) do
        if element.Type == "Toggle" then
            configData[elementId] = element.GetState()
        elseif element.Type == "Slider" then
            configData[elementId] = element.GetValue()
        elseif element.Type == "Dropdown" then
            configData[elementId] = element.GetSelected()
        elseif element.Type == "Textbox" then
            configData[elementId] = element.GetText()
        elseif element.Type == "ColorPicker" then
            local color = element.GetColor()
            configData[elementId] = {color.R, color.G, color.B}
        end
    end
    
    local success, err = pcall(function()
        local encoded = HttpService:JSONEncode(configData)
        writefile(self._configFolder .. "/" .. configName .. ".json", encoded)
    end)
    
    if success then
        self:Notify("Config Saved", "Successfully saved: " .. configName, 3)
    else
        self:Notify("Save Failed", "Could not save config", 3)
    end
end

function Library:LoadConfig(configName)
    if not configName or configName == "" then
        self:Notify("Config Error", "Please select a config", 3)
        return
    end
    
    local success, result = pcall(function()
        local filePath = self._configFolder .. "/" .. configName .. ".json"
        if not isfile(filePath) then
            return nil
        end
        local fileContent = readfile(filePath)
        return HttpService:JSONDecode(fileContent)
    end)
    
    if success and result then
        for elementId, value in pairs(result) do
            local element = self._configElements[elementId]
            if element then
                if element.Type == "Toggle" and element.SetState then
                    element.SetState(value)
                elseif element.Type == "Slider" and element.SetValue then
                    element.SetValue(value)
                elseif element.Type == "Dropdown" and element.SetSelected then
                    element.SetSelected(value)
                elseif element.Type == "Textbox" and element.SetText then
                    element.SetText(value)
                elseif element.Type == "ColorPicker" and element.SetColor then
                    if type(value) == "table" and value.R and value.G and value.B then
                        element.SetColor(Color3.new(value.R, value.G, value.B))
                    end
                end
            end
        end
        self:Notify("Config Loaded", "Successfully loaded: " .. configName, 3)
    else
        self:Notify("Load Failed", "Could not load config", 3)
    end
end

function Library:DeleteConfig(configName)
    if not configName or configName == "" then
        self:Notify("Config Error", "Please select a config", 3)
        return
    end
    
    local success, err = pcall(function()
        local filePath = self._configFolder .. "/" .. configName .. ".json"
        if isfile(filePath) then
            delfile(filePath)
        end
    end)
    
    if success then
        self:Notify("Config Deleted", "Successfully deleted: " .. configName, 3)
    else
        self:Notify("Delete Failed", "Could not delete config", 3)
    end
end

function Library:GetConfigList()
    local configs = {}
    local success, err = pcall(function()
        if not isfolder(self._configFolder) then
            makefolder(self._configFolder)
        end
        for _, file in ipairs(listfiles(self._configFolder)) do
            local fileName = file:match("([^/\\]+)%.json$")
            if fileName then
                table.insert(configs, fileName)
            end
        end
    end)
    return configs
end

-- ========== COLOR PICKER HELPER ==========
local function HSVToColor3(h, s, v)
    return Color3.fromHSV(h, s, v)
end

local function Color3ToHSV(color)
    return Color3.toHSV(color)
end

-- ========== WINDOW CREATION ==========
function Library:CreateWindow(title)
    pcall(function()
        if not isfolder(self._configFolder) then
            makefolder(self._configFolder)
        end
    end)

    local ScreenGui = Create("ScreenGui", {
        Name = "MolchunHub",
        Parent = CoreGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    Library._notificationParent = ScreenGui

    local vp = workspace.CurrentCamera.ViewportSize
    local frameW, frameH = 720, 420
    local startX = math.floor((vp.X - frameW) / 2)
    local startY = math.floor((vp.Y - frameH) / 2)

    local Main = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        Size = UDim2.new(0, frameW, 0, frameH),
        Position = UDim2.new(0, startX, 0, startY),
        BackgroundColor3 = self.MainColor,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })

    -- ==================== DESCRIPTION PANEL ====================
    local DESC_GAP = 10

    local DescPanel = Create("Frame", {
        Name = "DescPanel",
        Parent = ScreenGui,
        Size = UDim2.new(0, 0, 0, 36),
        Position = UDim2.new(0, startX + frameW + DESC_GAP, 0, startY),
        BackgroundColor3 = Library.SectionColor,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 30,
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DescPanel})

    local DescAccent = Create("Frame", {
        Parent = DescPanel,
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = Library.ToggleOnColor,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 31,
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = DescAccent})

    local DescLabel = Create("TextLabel", {
        Parent = DescPanel,
        Text = "",
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Library.TextActiveColor,
        TextTransparency = 1,
        Font = Library.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = false,
        ZIndex = 32,
    })

    local descShowing = false
    local descTweens  = {}

    local function cancelDescTweens()
        for _, t in ipairs(descTweens) do t:Cancel() end
        descTweens = {}
    end

    local function showDesc(text, rowFrame)
        if Library._dropdownOpen or Library._colorPickerOpen then return end
        DescLabel.Text = text
        local textBounds = DescLabel.TextBounds
        local pad = 28
        local newWidth = math.max(100, textBounds.X + pad)
        DescPanel.Size = UDim2.new(0, newWidth, 0, 36)

        local rp = rowFrame.AbsolutePosition
        local rs = rowFrame.AbsoluteSize
        local mp = Main.AbsolutePosition
        local ms = Main.AbsoluteSize

        local panelX = mp.X + ms.X + DESC_GAP
        local panelY = rp.Y + rs.Y / 2 - DescPanel.AbsoluteSize.Y / 2

        DescPanel.Position = UDim2.new(0, panelX, 0, panelY)

        cancelDescTweens()
        descShowing = true
        local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local t1 = TweenService:Create(DescPanel,  ti, {BackgroundTransparency = 0})
        local t2 = TweenService:Create(DescAccent, ti, {BackgroundTransparency = 0})
        local t3 = TweenService:Create(DescLabel,  ti, {TextTransparency = 0})
        t1:Play() t2:Play() t3:Play()
        descTweens = {t1, t2, t3}
    end

    local function hideDesc()
        if not descShowing then return end
        descShowing = false
        cancelDescTweens()
        local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local t1 = TweenService:Create(DescPanel,  ti, {BackgroundTransparency = 1})
        local t2 = TweenService:Create(DescAccent, ti, {BackgroundTransparency = 1})
        local t3 = TweenService:Create(DescLabel,  ti, {TextTransparency = 1})
        t1:Play() t2:Play() t3:Play()
        descTweens = {t1, t2, t3}
    end

    RunService.Heartbeat:Connect(function()
        if not Main or not Main.Parent then return end
        local mp = Main.AbsolutePosition
        local ms = Main.AbsoluteSize
        local cur = DescPanel.Position
        DescPanel.Position = UDim2.new(0, mp.X + ms.X + DESC_GAP, 0, cur.Y.Offset)
    end)

    local function AttachDescription(frame, descText)
        if not descText or descText == "" then return end
        frame.MouseEnter:Connect(function() showDesc(descText, frame) end)
        frame.MouseLeave:Connect(function() hideDesc() end)
    end

    -- ========== DRAG SYSTEM ==========
    local dragging   = false
    local dragOffset = Vector2.new()
    local targetX    = startX
    local targetY    = startY
    local SMOOTH     = 0.15

    local TopBar  = nil
    local Sidebar = nil

    local function inBounds(frame, px, py)
        if not frame then return false end
        local ap = frame.AbsolutePosition
        local as = frame.AbsoluteSize
        return px >= ap.X and px <= ap.X + as.X and py >= ap.Y and py <= ap.Y + as.Y
    end

    local function mouseOnSlider(px, py)
        for _, desc in ipairs(Main:GetDescendants()) do
            if desc:GetAttribute("CheetoSliderTrack") and inBounds(desc, px, py) then
                return true
            end
        end
        return false
    end

    Main.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local mx = input.Position.X
        local my = input.Position.Y
        if mouseOnSlider(mx, my) then return end
        if not inBounds(TopBar, mx, my) and not inBounds(Sidebar, mx, my) then return end
        dragging   = true
        dragOffset = Vector2.new(mx - Main.AbsolutePosition.X, my - Main.AbsolutePosition.Y)
        targetX    = Main.AbsolutePosition.X
        targetY    = Main.AbsolutePosition.Y
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local vp2  = workspace.CurrentCamera.ViewportSize
        local mPos = UserInputService:GetMouseLocation()
        targetX = math.clamp(mPos.X - dragOffset.X, 0, vp2.X - Main.AbsoluteSize.X)
        targetY = math.clamp(mPos.Y - dragOffset.Y, 0, vp2.Y - Main.AbsoluteSize.Y)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    RunService.Heartbeat:Connect(function(dt)
        local cx = Main.Position.X.Offset
        local cy = Main.Position.Y.Offset
        local t  = 1 - (1 - SMOOTH) ^ (dt * 60)
        Main.Position = UDim2.new(0, cx + (targetX - cx) * t, 0, cy + (targetY - cy) * t)
    end)

    -- ========== HIDE / SHOW ==========
    local isUIVisible = true
    local animatingUI = false
    local storedSize  = Main.Size
    local storedPos   = Main.Position

    local function hideUI(showNotification)
        if not isUIVisible or animatingUI then return end
        animatingUI = true
        storedSize  = Main.Size
        storedPos   = Main.Position
        local ap = Main.AbsolutePosition
        local as = Main.AbsoluteSize
        local cx = ap.X + as.X / 2
        local cy = ap.Y + as.Y / 2
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size     = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0, cx, 0, cy)
        }):Play()
        hideDesc()
        task.delay(0.2, function()
            Main.Visible      = false
            DescPanel.Visible = false
            isUIVisible       = false
            animatingUI       = false
            targetX = cx targetY = cy
            if showNotification then
                Library:Notify("UI Hidden", "Press Left CTRL to reopen")
            end
        end)
    end

    local function showUI()
        if isUIVisible or animatingUI then return end
        local cx = storedPos.X.Offset + storedSize.X.Offset / 2
        local cy = storedPos.Y.Offset + storedSize.Y.Offset / 2
        Main.Size         = UDim2.new(0, 0, 0, 0)
        Main.Position     = UDim2.new(0, cx, 0, cy)
        Main.Visible      = true
        DescPanel.Visible = true
        animatingUI       = true
        targetX = storedPos.X.Offset
        targetY = storedPos.Y.Offset
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size     = storedSize,
            Position = storedPos
        }):Play()
        task.delay(0.25, function()
            isUIVisible = true
            animatingUI = false
        end)
    end

    -- ========== SIDEBAR ==========
    Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = Main,
        Size = UDim2.new(0, 160, 1, 0),
        BackgroundColor3 = self.SidebarColor,
        BorderSizePixel = 0
    })
    Create("Frame", {
        Parent = Main,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(0, 160, 0, 0),
        BackgroundColor3 = self.SeparatorColor,
        BorderSizePixel = 0
    })
    Create("TextLabel", {
        Parent = Sidebar,
        Text = title,
        Size = UDim2.new(1, -10, 0, 50),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(220, 220, 220),
        Font = Enum.Font.GothamMedium,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        Position = UDim2.new(0, 0, 0, 55),
        Size = UDim2.new(1, 0, 1, -55),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0
    })
    Create("UIPadding", {Parent = TabContainer, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 15)})
    Create("UIListLayout", {Parent = TabContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})

    local Content = Create("Frame", {
        Name = "Content",
        Parent = Main,
        Position = UDim2.new(0, 161, 0, 0),
        Size = UDim2.new(1, -161, 1, 0),
        BackgroundTransparency = 1
    })

    -- ========== TOP BAR ==========
    TopBar = Create("Frame", {
        Parent = Content,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1
    })
    local PathLabel = Create("TextLabel", {
        Parent = TopBar,
        Text = title .. " >  ",
        Size = UDim2.new(0, 0, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = Library.TextActiveColor,
        Font = Library.Font,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        RichText = true,
        AutomaticSize = Enum.AutomaticSize.X
    })

    -- User container (right side, near collapse button)
    local UserContainer = Create("Frame", {
        Parent = TopBar,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -70, 0.5, 0)
    })

    local AvatarSize = 28
    local Avatar = Create("ImageLabel", {
        Parent = UserContainer,
        Size = UDim2.new(0, AvatarSize, 0, AvatarSize),
        Position = UDim2.new(0, 0, 0.5, -AvatarSize/2),
        BackgroundColor3 = Color3.fromRGB(45, 45, 45),
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    })
    Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Avatar})

    local WelcomeLabel = Create("TextLabel", {
        Parent = UserContainer,
        Size = UDim2.new(0, 0, 1, 0),
        Position = UDim2.new(0, AvatarSize + 6, 0, 0),
        BackgroundTransparency = 1,
        Text = "Welcome, ",
        TextColor3 = Library.TextActiveColor,
        Font = Library.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        AutomaticSize = Enum.AutomaticSize.X
    })
    local UsernameLabel = Create("TextLabel", {
        Parent = UserContainer,
        Size = UDim2.new(0, 0, 1, 0),
        Position = UDim2.new(0, AvatarSize + 6 + WelcomeLabel.TextBounds.X, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Library.TextInactiveColor,
        Font = Library.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        AutomaticSize = Enum.AutomaticSize.X
    })

    local function updateUserLayout()
        local username = LocalPlayer and (LocalPlayer.DisplayName or LocalPlayer.Name) or "User"
        UsernameLabel.Text = username
        local totalWidth = AvatarSize + 6 + WelcomeLabel.TextBounds.X + UsernameLabel.TextBounds.X
        UserContainer.Size = UDim2.new(0, totalWidth, 1, 0)
        UsernameLabel.Position = UDim2.new(0, AvatarSize + 6 + WelcomeLabel.TextBounds.X, 0, 0)
    end

    if LocalPlayer then
        local userId = LocalPlayer.UserId
        local thumbnail = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        Avatar.Image = thumbnail
        updateUserLayout()
    else
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        updateUserLayout()
        local userId = LocalPlayer.UserId
        local thumbnail = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        Avatar.Image = thumbnail
    end

    local CollapseBtn = Create("TextButton", {
        Parent = TopBar,
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, -42, 0.5, -16),
        BackgroundTransparency = 1,
        Text = ">|",
        TextColor3 = Library.TextInactiveColor,
        Font = Library.Font,
        TextSize = 18,
        AutoButtonColor = false
    })
    Create("Frame", {
        Parent = Content,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = Library.SeparatorColor,
        BorderSizePixel = 0
    })

    CollapseBtn.MouseButton1Click:Connect(function() hideUI(true) end)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.LeftControl then
            if isUIVisible then hideUI(false) else showUI() end
        end
    end)

    -- ========== TABS ==========
    local Window   = {Tabs = {}}
    local animating = false

    function Window:CreateTab(name)
        local TabBtn = Create("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Library.TabSelectedBg,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = name,
            TextColor3 = Library.TextActiveColor,
            Font = Library.Font,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false
        })
        Create("UIPadding", {Parent = TabBtn, PaddingLeft = UDim.new(0, 6)})

        local Page = Create("ScrollingFrame", {
            Parent = Content,
            Size = UDim2.new(1, 0, 1, -51),
            Position = UDim2.new(0, 0, 0, 51),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 0,
            ClipsDescendants = true
        })
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center})
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 15)})

        local defaultPos = UDim2.new(0, 0, 0, 51)
        local dropOffset = 20

        local function animatePageIn(page)
            page.Visible  = true
            page.Position = UDim2.new(0, 0, 0, 51 + dropOffset)
            TweenService:Create(page, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = defaultPos}):Play()
        end

        local function animatePageOut(page, callback)
            TweenService:Create(page, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0, 0, 0, 51 - dropOffset)}):Play()
            task.wait(0.2)
            page.Visible  = false
            page.Position = defaultPos
            if callback then callback() end
        end

        TabBtn.MouseButton1Click:Connect(function()
            if animating then return end
            local currentTab = nil
            for _, v in pairs(Window.Tabs) do
                if v.Page.Visible then currentTab = v break end
            end
            if currentTab and currentTab.Page == Page then return end
            animating = true
            for _, v in pairs(Window.Tabs) do
                v.Btn.BackgroundTransparency = 1
                v.Btn.TextColor3 = Library.TextActiveColor
            end
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Library.ToggleOnColor
            PathLabel.Text = "<font color='rgb(67,69,73)'>Molchun Hub >  </font><font color='rgb(255,255,255)'>" .. name .. "</font>"
            if currentTab then
                animatePageOut(currentTab.Page, function()
                    animatePageIn(Page)
                    animating = false
                end)
            else
                animatePageIn(Page)
                animating = false
            end
        end)

        local Tab = {Page = Page, Btn = TabBtn}
        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            Page.Visible  = true
            Page.Position = defaultPos
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Library.ToggleOnColor
            PathLabel.Text = "<font color='rgb(67,69,73)'>Molchun Hub >  </font><font color='rgb(255,255,255)'>" .. name .. "</font>"
        end

        -- ========== TOGGLE ==========
        function Tab:CreateToggle(text, callback, desc, configId)
            local TFrame = Create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, -30, 0, 44),
                BackgroundColor3 = Library.SectionColor,
                BorderSizePixel = 0
            })
            local LeftAccent = Create("Frame", {
                Parent = TFrame,
                Size = UDim2.new(0, 2, 1, 0),
                BackgroundColor3 = Library.ToggleOffColor,
                BorderSizePixel = 0
            })
            local Label = Create("TextLabel", {
                Parent = TFrame,
                Text = text,
                Size = UDim2.new(1, -250, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = Library.TextInactiveColor,
                Font = Library.Font,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            local BindLabel = Create("TextButton", {
                Parent = TFrame,
                Text = "Click to Bind",
                Size = UDim2.new(0, 110, 1, 0),
                Position = UDim2.new(1, -190, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = Library.TextInactiveColor,
                Font = Library.Font,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Right,
                AutoButtonColor = false
            })
            local ToggleBG = Create("Frame", {
                Parent = TFrame,
                Size = UDim2.new(0, 40, 0, 22),
                Position = UDim2.new(1, -60, 0.5, -11),
                BackgroundColor3 = Library.ToggleOffColor,
                BorderSizePixel = 0
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBG})
            local Ball = Create("Frame", {
                Parent = ToggleBG,
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(0, 2, 0.5, -9),
                BackgroundColor3 = Color3.fromRGB(220, 220, 220),
                BorderSizePixel = 0
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Ball})

            AttachDescription(TFrame, desc)

            local enabled   = false
            local boundKey  = nil
            local listening = false

            local function updateToggleUI()
                local pos     = enabled and UDim2.new(0, 20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
                local col     = enabled and Library.ToggleOnColor or Library.ToggleOffColor
                local textCol = enabled and Library.TextActiveColor or Library.TextInactiveColor
                TweenService:Create(Ball,       TweenInfo.new(0.2), {Position = pos}):Play()
                TweenService:Create(ToggleBG,   TweenInfo.new(0.2), {BackgroundColor3 = col}):Play()
                TweenService:Create(LeftAccent, TweenInfo.new(0.2), {BackgroundColor3 = col}):Play()
                TweenService:Create(Label,      TweenInfo.new(0.2), {TextColor3 = textCol}):Play()
                callback(enabled)
            end

            TFrame.InputBegan:Connect(function(io)
                if io.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mp = UserInputService:GetMouseLocation()
                    local ba = BindLabel.AbsolutePosition
                    local bs = BindLabel.AbsoluteSize
                    if mp.X >= ba.X and mp.X <= ba.X + bs.X and mp.Y >= ba.Y and mp.Y <= ba.Y + bs.Y then return end
                    enabled = not enabled
                    updateToggleUI()
                end
            end)

            BindLabel.MouseButton1Click:Connect(function()
                listening      = true
                BindLabel.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(io, gp)
                if gp then return end
                if listening and io.UserInputType == Enum.UserInputType.Keyboard then
                    boundKey       = io.KeyCode
                    BindLabel.Text = "Bind: " .. boundKey.Name
                    listening      = false
                elseif boundKey and io.UserInputType == Enum.UserInputType.Keyboard and io.KeyCode == boundKey then
                    enabled = not enabled
                    updateToggleUI()
                end
            end)

            local toggleObj = {
                GetState = function() return enabled end,
                SetState = function(state)
                    enabled = state
                    updateToggleUI()
                end,
                Type = "Toggle"
            }

            if configId then
                Library._configElements[configId] = toggleObj
            end

            return TFrame, toggleObj
        end

        -- ========== SLIDER ==========
        function Tab:CreateSlider(text, min, max, default, callback, desc, configId)
            local SFrame = Create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, -30, 0, 48),
                BackgroundColor3 = Library.SectionColor,
                BorderSizePixel = 0
            })
            Create("Frame", {
                Parent = SFrame,
                Size = UDim2.new(0, 2, 1, 0),
                BackgroundColor3 = Library.ToggleOnColor,
                BorderSizePixel = 0
            })
            Create("TextLabel", {
                Parent = SFrame,
                Text = text,
                Size = UDim2.new(1, -20, 0, 18),
                Position = UDim2.new(0, 15, 0, 4),
                BackgroundTransparency = 1,
                TextColor3 = Library.TextActiveColor,
                Font = Library.Font,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            local ValueLabel = Create("TextLabel", {
                Parent = SFrame,
                Text = tostring(default),
                Size = UDim2.new(0, 60, 0, 18),
                Position = UDim2.new(1, -75, 0, 4),
                BackgroundTransparency = 1,
                TextColor3 = Library.TextActiveColor,
                Font = Library.Font,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right
            })
            local SliderBg = Create("Frame", {
                Parent = SFrame,
                Size = UDim2.new(1, -30, 0, 4),
                Position = UDim2.new(0, 15, 0, 30),
                BackgroundColor3 = Library.SliderOffColor,
                BorderSizePixel = 0
            })
            SliderBg:SetAttribute("CheetoSliderTrack", true)
            local Fill = Create("Frame", {
                Parent = SliderBg,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Library.ToggleOnColor,
                BorderSizePixel = 0
            })
            Fill:SetAttribute("CheetoSliderTrack", true)

            AttachDescription(SFrame, desc)

            local currentValue   = default
            local draggingSlider = false

            local function setValue(value)
                value           = math.clamp(value, min, max)
                currentValue    = value
                Fill.Size       = UDim2.new((value - min) / (max - min), 0, 1, 0)
                ValueLabel.Text = string.format("%.1f", value)
                callback(value)
            end
            setValue(default)

            SliderBg.InputBegan:Connect(function(io)
                if io.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                    setValue(min + (max - min) * math.clamp((io.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1))
                end
            end)
            UserInputService.InputChanged:Connect(function(io)
                if draggingSlider and io.UserInputType == Enum.UserInputType.MouseMovement then
                    setValue(min + (max - min) * math.clamp((io.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1))
                end
            end)
            UserInputService.InputEnded:Connect(function(io)
                if io.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end
            end)

            local sliderObj = {
                GetValue = function() return currentValue end,
                SetValue = setValue,
                Type = "Slider"
            }

            if configId then
                Library._configElements[configId] = sliderObj
            end

            return sliderObj
        end

        -- ========== DROPDOWN (ENLARGED: 32px height, 14px text, auto-width) ==========
        function Tab:CreateDropdown(text, options, default, callback, desc, configId)
            local selectedOption = default or options[1]

            local DFrame = Create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, -30, 0, 44),
                BackgroundColor3 = Library.SectionColor,
                BorderSizePixel = 0
            })
            Create("Frame", {
                Parent = DFrame,
                Size = UDim2.new(0, 2, 1, 0),
                BackgroundColor3 = Library.ToggleOnColor,
                BorderSizePixel = 0,
                ZIndex = 2
            })
            Create("TextLabel", {
                Parent = DFrame,
                Text = text,
                Size = UDim2.new(1, -200, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = Library.TextActiveColor,
                Font = Library.Font,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })

            -- ENLARGED BUTTON: 32px height, bigger text
            local ButtonBg = Create("Frame", {
                Parent = DFrame,
                Size = UDim2.new(0, 100, 0, 32),   -- temporary width, will resize
                Position = UDim2.new(1, -105, 0.5, -16),
                BackgroundColor3 = Color3.fromRGB(28, 30, 32),
                BorderSizePixel = 0,
                ZIndex = 3
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = ButtonBg})

            -- TextLabel: left-aligned, 14px font, with padding
            local SelectLabel = Create("TextLabel", {
                Parent = ButtonBg,
                Text = selectedOption,
                Size = UDim2.new(1, -12, 1, 0),  -- 6px left + 6px right = 12px total horizontal padding
                Position = UDim2.new(0, 6, 0, 0), -- 6px left padding
                BackgroundTransparency = 1,
                TextColor3 = Color3.fromRGB(210, 212, 216),
                Font = Library.Font,
                TextSize = 14,   -- larger text
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = 4
            })

            local ClickZone = Create("TextButton", {
                Parent = ButtonBg,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 5,
                AutoButtonColor = false
            })

            AttachDescription(DFrame, desc)

            -- Resize function using larger text size (14)
            local function updateButtonWidth()
                local text = SelectLabel.Text
                local textWidth = TextService:GetTextSize(text, 14, Library.Font, Vector2.new(1000, 32)).X
                local horizontalPadding = 12  -- 6 left + 6 right
                local desiredWidth = math.max(50, textWidth + horizontalPadding)
                ButtonBg.Size = UDim2.new(0, desiredWidth, 0, 32)
                -- Keep right-aligned with 5px margin from DFrame's right edge
                ButtonBg.Position = UDim2.new(1, -(desiredWidth + 5), 0.5, -16)
            end

            updateButtonWidth()

            local expanded   = false
            local DropList   = nil
            local justOpened = false

            local function closeDropdown()
                if DropList then
                    local fadeOut = TweenService:Create(DropList, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
                    for _, child in ipairs(DropList:GetDescendants()) do
                        if child:IsA("TextLabel") or child:IsA("TextButton") then
                            TweenService:Create(child, TweenInfo.new(0.3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
                        end
                        if child:IsA("Frame") then
                            TweenService:Create(child, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                        end
                    end
                    fadeOut:Play()
                    local dl = DropList
                    fadeOut.Completed:Connect(function()
                        if dl and dl.Parent then dl:Destroy() end
                        Library._dropdownOpen = false
                    end)
                    DropList = nil
                end
                expanded = false
            end

            ClickZone.MouseButton1Click:Connect(function()
                if expanded then
                    closeDropdown()
                    return
                end
                Library._dropdownOpen = true
                hideDesc()
                expanded   = true
                justOpened = true
                task.defer(function() justOpened = false end)

                local optionH = 34   -- slightly taller options
                local listPad = 8
                local listH   = #options * optionH + listPad * 2

                local mainAP = Main.AbsolutePosition
                local mainAS = Main.AbsoluteSize
                local rowAP  = DFrame.AbsolutePosition
                local listX  = mainAP.X + mainAS.X + 6
                local listY  = rowAP.Y

                DropList = Create("Frame", {
                    Parent = ScreenGui,
                    Position = UDim2.new(0, listX, 0, listY),
                    Size = UDim2.new(0, 160, 0, listH),
                    BackgroundColor3 = Library.SectionColor,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 20,
                    ClipsDescendants = false
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = DropList})

                local ListAccent = Create("Frame", {
                    Parent = DropList,
                    Size = UDim2.new(0, 3, 1, 0),
                    BackgroundColor3 = Library.ToggleOnColor,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 21,
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = ListAccent})

                local ItemContainer = Create("Frame", {
                    Parent = DropList,
                    Position = UDim2.new(0, 3, 0, 0),
                    Size = UDim2.new(1, -3, 1, 0),
                    BackgroundTransparency = 1,
                    ZIndex = 21,
                    ClipsDescendants = true,
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = ItemContainer})
                Create("UIPadding", {
                    Parent = ItemContainer,
                    PaddingTop    = UDim.new(0, listPad),
                    PaddingBottom = UDim.new(0, listPad),
                    PaddingLeft   = UDim.new(0, 6),
                    PaddingRight  = UDim.new(0, 6)
                })
                Create("UIListLayout", {
                    Parent = ItemContainer,
                    Padding = UDim.new(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                TweenService:Create(DropList, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
                TweenService:Create(ListAccent, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()

                for _, opt in ipairs(options) do
                    local optBtn = Create("TextButton", {
                        Parent = ItemContainer,
                        Size = UDim2.new(1, 0, 0, optionH - 4),
                        Text = opt,
                        BackgroundColor3 = Library.SectionColor,
                        BackgroundTransparency = 1,
                        TextColor3 = Library.TextActiveColor,
                        TextTransparency = 1,
                        Font = Library.Font,
                        TextSize = 13,   -- keep options text comfortable
                        TextXAlignment = Enum.TextXAlignment.Left,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                        ZIndex = 22
                    })
                    Create("UIPadding", {Parent = optBtn, PaddingLeft = UDim.new(0, 8)})

                    TweenService:Create(optBtn, TweenInfo.new(0.3), {
                        BackgroundTransparency = 0,
                        TextTransparency = 0
                    }):Play()

                    optBtn.InputBegan:Connect(function(io)
                        if io.UserInputType == Enum.UserInputType.MouseButton1 then
                            selectedOption  = opt
                            SelectLabel.Text = opt
                            callback(opt)
                            updateButtonWidth()
                            closeDropdown()
                        end
                    end)
                    optBtn.MouseEnter:Connect(function()
                        TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = Library.TabSelectedBg}):Play()
                    end)
                    optBtn.MouseLeave:Connect(function()
                        TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3 = Library.SectionColor}):Play()
                    end)
                end
            end)

            UserInputService.InputBegan:Connect(function(io)
                if not expanded or justOpened then return end
                if io.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                local mp = UserInputService:GetMouseLocation()
                local function hitting(frame)
                    if not frame then return false end
                    local ap = frame.AbsolutePosition
                    local as = frame.AbsoluteSize
                    return mp.X >= ap.X and mp.X <= ap.X + as.X and mp.Y >= ap.Y and mp.Y <= ap.Y + as.Y
                end
                if not hitting(DFrame) and not hitting(DropList) then closeDropdown() end
            end)

            local dropdownObj = {
                GetSelected = function() return selectedOption end,
                SetSelected = function(opt)
                    if table.find(options, opt) then
                        selectedOption = opt
                        SelectLabel.Text = opt
                        callback(opt)
                        updateButtonWidth()
                    end
                end,
                Type = "Dropdown",
                Frame = DFrame
            }

            if configId then
                Library._configElements[configId] = dropdownObj
            end

            return dropdownObj
        end

        -- ========== TEXTBOX ==========
        function Tab:CreateTextbox(text, placeholder, defaultText, callback, desc, configId)
            local TBoxFrame = Create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, -30, 0, 50),
                BackgroundColor3 = Library.SectionColor,
                BorderSizePixel = 0
            })
            Create("Frame", {
                Parent = TBoxFrame,
                Size = UDim2.new(0, 2, 1, 0),
                BackgroundColor3 = Library.ToggleOnColor,
                BorderSizePixel = 0
            })
            Create("TextLabel", {
                Parent = TBoxFrame,
                Text = text,
                Size = UDim2.new(1, -230, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = Library.TextActiveColor,
                Font = Library.Font,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
            local InputBox = Create("TextBox", {
                Parent = TBoxFrame,
                Size = UDim2.new(0, 200, 0, 34),
                Position = UDim2.new(1, -215, 0.5, -17),
                BackgroundColor3 = Color3.fromRGB(25, 27, 29),
                TextColor3 = Library.TextActiveColor,
                Font = Library.Font,
                TextSize = 13,
                Text = defaultText or "",
                PlaceholderText = placeholder or "Enter text...",
                PlaceholderColor3 = Color3.fromRGB(100, 102, 106),
                ClearTextOnFocus = false,
                ZIndex = 3
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = InputBox})

            AttachDescription(TBoxFrame, desc)

            local currentText = defaultText or ""

            local function setText(newText)
                currentText = newText
                InputBox.Text = newText
                callback(newText)
            end

            InputBox.FocusLost:Connect(function(enterPressed)
                currentText = InputBox.Text
                callback(currentText)
            end)

            InputBox:GetPropertyChangedSignal("Text"):Connect(function()
                currentText = InputBox.Text
                callback(currentText)
            end)

            local textboxObj = {
                GetText = function() return currentText end,
                SetText = setText,
                Type = "Textbox"
            }

            if configId then
                Library._configElements[configId] = textboxObj
            end

            return TBoxFrame
        end

        -- ========== BUTTON ==========
        function Tab:CreateButton(text, callback, desc)
            local BFrame = Create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, -30, 0, 44),
                BackgroundColor3 = Library.SectionColor,
                BorderSizePixel = 0
            })
            Create("Frame", {
                Parent = BFrame,
                Size = UDim2.new(0, 2, 1, 0),
                BackgroundColor3 = Library.ToggleOnColor,
                BorderSizePixel = 0
            })
            
            local ButtonClick = Create("TextButton", {
                Parent = BFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Library.TextActiveColor,
                Font = Library.Font,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Center,
                AutoButtonColor = false,
                ZIndex = 2
            })

            AttachDescription(BFrame, desc)

            ButtonClick.MouseEnter:Connect(function()
                TweenService:Create(ButtonClick, TweenInfo.new(0.2), {TextColor3 = Library.ToggleOnColor}):Play()
            end)

            ButtonClick.MouseLeave:Connect(function()
                TweenService:Create(ButtonClick, TweenInfo.new(0.2), {TextColor3 = Library.TextActiveColor}):Play()
            end)

            ButtonClick.MouseButton1Click:Connect(function()
                callback()
            end)

            return BFrame
        end

        -- ========== COLOR PICKER (Discord-style, cursor dot, no close button) ==========
        function Tab:CreateColorPicker(text, defaultColor, callback, desc, configId)
            local currentColor = defaultColor or Color3.fromRGB(255, 255, 255)
            local h, s, v = Color3ToHSV(currentColor)

            local CFrame = Create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, -30, 0, 44),
                BackgroundColor3 = Library.SectionColor,
                BorderSizePixel = 0
            })
            Create("Frame", {
                Parent = CFrame,
                Size = UDim2.new(0, 2, 1, 0),
                BackgroundColor3 = Library.ToggleOnColor,
                BorderSizePixel = 0
            })
            Create("TextLabel", {
                Parent = CFrame,
                Text = text,
                Size = UDim2.new(1, -200, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = Library.TextActiveColor,
                Font = Library.Font,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            -- Color preview button (no arrow)
            local PreviewBtn = Create("TextButton", {
                Parent = CFrame,
                Size = UDim2.new(0, 34, 0, 34),
                Position = UDim2.new(1, -50, 0.5, -17),
                BackgroundColor3 = currentColor,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                ZIndex = 3
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = PreviewBtn})
            -- Thin border around preview
            Create("UIStroke", {
                Parent = PreviewBtn,
                Color = Color3.fromRGB(70, 72, 76),
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            })

            AttachDescription(CFrame, desc)

            local expanded   = false
            local PickerPop  = nil
            local justOpened = false

            -- Cursor dot references
            local CursorDot  = nil
            local HueThumb   = nil
            local SqFrame    = nil
            local SwatchFrame = nil

            local SQ = 185          -- square size
            local HUE_H = 16        -- hue strip height

            local function updatePreview()
                PreviewBtn.BackgroundColor3 = currentColor
            end

            local function refreshPickerUI()
                if not PickerPop then return end
                if SqFrame then
                    SqFrame.BackgroundColor3 = HSVToColor3(h, 1, 1)
                end
                if CursorDot then
                    CursorDot.Position = UDim2.new(s, -6, 1 - v, -6)
                end
                if HueThumb then
                    HueThumb.Position = UDim2.new(h, -3, 0, 0)
                end
                if SwatchFrame then
                    SwatchFrame.BackgroundColor3 = currentColor
                end
            end

            local function fireCallback()
                currentColor = HSVToColor3(h, s, v)
                updatePreview()
                callback(currentColor)
                refreshPickerUI()
            end

            local function closePicker()
                if not PickerPop then return end
                expanded = false
                Library._colorPickerOpen = false
                Library._draggingColorPicker = false

                local pop = PickerPop
                PickerPop = nil
                CursorDot = nil
                HueThumb  = nil
                SqFrame   = nil
                SwatchFrame = nil

                TweenService:Create(pop, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, pop.AbsoluteSize.X * 0.95, 0, pop.AbsoluteSize.Y * 0.95)
                }):Play()
                task.delay(0.22, function()
                    if pop and pop.Parent then pop:Destroy() end
                end)
            end

            local function openPicker()
                if expanded then
                    closePicker()
                    return
                end

                Library._colorPickerOpen = true
                hideDesc()
                expanded   = true
                justOpened = true
                task.defer(function() justOpened = false end)

                local mainAP = Main.AbsolutePosition
                local mainAS = Main.AbsoluteSize
                local rowAP  = CFrame.AbsolutePosition
                local popX   = mainAP.X + mainAS.X + 6
                local popY   = rowAP.Y - 10

                local POP_W = SQ + 24
                local POP_H = SQ + HUE_H + 58

                PickerPop = Create("Frame", {
                    Parent = ScreenGui,
                    Position = UDim2.new(0, popX, 0, popY),
                    Size = UDim2.new(0, POP_W, 0, POP_H),
                    BackgroundColor3 = Color3.fromRGB(30, 32, 35),
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    ZIndex = 50,
                    ClipsDescendants = false
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = PickerPop})
                local PopAccent = Create("Frame", {
                    Parent = PickerPop,
                    Size = UDim2.new(0, 3, 1, 0),
                    BackgroundColor3 = Library.ToggleOnColor,
                    BorderSizePixel = 0,
                    ZIndex = 51,
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = PopAccent})

                local Inner = Create("Frame", {
                    Parent = PickerPop,
                    Position = UDim2.new(0, 12, 0, 12),
                    Size = UDim2.new(1, -18, 1, -18),
                    BackgroundTransparency = 1,
                    ZIndex = 52
                })

                -- SATURATION/VALUE SQUARE
                SqFrame = Create("Frame", {
                    Parent = Inner,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0, SQ, 0, SQ),
                    BackgroundColor3 = HSVToColor3(h, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 53,
                    ClipsDescendants = true
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = SqFrame})

                -- White left-to-right gradient (saturation)
                local SatOverlay = Create("Frame", {
                    Parent = SqFrame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 54
                })
                Create("UIGradient", {
                    Parent = SatOverlay,
                    Rotation = 0,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    })
                })

                -- Black top-to-bottom gradient (value)
                local ValOverlay = Create("Frame", {
                    Parent = SqFrame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                    ZIndex = 55
                })
                Create("UIGradient", {
                    Parent = ValOverlay,
                    Rotation = 90,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    })
                })

                -- Cursor dot
                CursorDot = Create("Frame", {
                    Parent = SqFrame,
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(s, -6, 1 - v, -6),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 60,
                    ClipsDescendants = false
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = CursorDot})
                Create("UIStroke", {
                    Parent = CursorDot,
                    Color = Color3.fromRGB(50, 50, 50),
                    Thickness = 2,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })

                local SqHit = Create("TextButton", {
                    Parent = SqFrame,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 59,
                    AutoButtonColor = false
                })

                -- HUE STRIP
                local HueStrip = Create("Frame", {
                    Parent = Inner,
                    Position = UDim2.new(0, 0, 0, SQ + 10),
                    Size = UDim2.new(0, SQ, 0, HUE_H),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    ZIndex = 53
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = HueStrip})
                Create("UIGradient", {
                    Parent = HueStrip,
                    Rotation = 0,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.166, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.500, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.666, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0))
                    })
                })

                HueThumb = Create("Frame", {
                    Parent = HueStrip,
                    Size = UDim2.new(0, 6, 1, 0),
                    Position = UDim2.new(h, -3, 0, 0),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    ZIndex = 56
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = HueThumb})
                Create("UIStroke", {
                    Parent = HueThumb,
                    Color = Color3.fromRGB(50, 50, 50),
                    Thickness = 1.5,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })

                local HueHit = Create("TextButton", {
                    Parent = HueStrip,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 57,
                    AutoButtonColor = false
                })

                -- COLOR SWATCH
                SwatchFrame = Create("Frame", {
                    Parent = Inner,
                    Position = UDim2.new(0, 0, 0, SQ + HUE_H + 22),
                    Size = UDim2.new(0, SQ, 0, 20),
                    BackgroundColor3 = currentColor,
                    BorderSizePixel = 0,
                    ZIndex = 53
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = SwatchFrame})
                Create("UIStroke", {
                    Parent = SwatchFrame,
                    Color = Color3.fromRGB(60, 63, 67),
                    Thickness = 1,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                })

                -- DRAG LOGIC
                local draggingSV  = false
                local function applyMouseToSV(mousePos)
                    local ap = SqFrame.AbsolutePosition
                    local as = SqFrame.AbsoluteSize
                    s = math.clamp((mousePos.X - ap.X) / as.X, 0, 1)
                    v = 1 - math.clamp((mousePos.Y - ap.Y) / as.Y, 0, 1)
                    fireCallback()
                end

                SqHit.InputBegan:Connect(function(io)
                    if io.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV = true
                        Library._draggingColorPicker = true
                        applyMouseToSV(UserInputService:GetMouseLocation())
                    end
                end)

                local draggingHue = false
                local function applyMouseToHue(mousePos)
                    local ap = HueStrip.AbsolutePosition
                    local as = HueStrip.AbsoluteSize
                    h = math.clamp((mousePos.X - ap.X) / as.X, 0, 1)
                    fireCallback()
                end

                HueHit.InputBegan:Connect(function(io)
                    if io.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingHue = true
                        Library._draggingColorPicker = true
                        applyMouseToHue(UserInputService:GetMouseLocation())
                    end
                end)

                UserInputService.InputChanged:Connect(function(io)
                    if io.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                    local mp = UserInputService:GetMouseLocation()
                    if draggingSV  then applyMouseToSV(mp)  end
                    if draggingHue then applyMouseToHue(mp) end
                end)

                UserInputService.InputEnded:Connect(function(io)
                    if io.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSV  = false
                        draggingHue = false
                        Library._draggingColorPicker = false
                    end
                end)

                -- Animate in
                PickerPop.Size = UDim2.new(0, POP_W * 0.9, 0, POP_H * 0.9)
                PickerPop.BackgroundTransparency = 0.3
                TweenService:Create(PickerPop, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, POP_W, 0, POP_H),
                    BackgroundTransparency = 0
                }):Play()
            end

            PreviewBtn.MouseButton1Click:Connect(openPicker)

            -- Close picker when clicking outside (no close button)
            UserInputService.InputBegan:Connect(function(io)
                if not expanded or justOpened then return end
                if io.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                if Library._draggingColorPicker then return end

                local mp = UserInputService:GetMouseLocation()
                local function hitting(frame)
                    if not frame or not frame.Parent then return false end
                    local ap = frame.AbsolutePosition
                    local as = frame.AbsoluteSize
                    return mp.X >= ap.X and mp.X <= ap.X + as.X and mp.Y >= ap.Y and mp.Y <= ap.Y + as.Y
                end
                if not hitting(CFrame) and not hitting(PickerPop) then
                    closePicker()
                end
            end)

            local colorPickerObj = {
                GetColor = function() return currentColor end,
                SetColor = function(newColor)
                    currentColor = newColor
                    h, s, v = Color3ToHSV(currentColor)
                    updatePreview()
                    refreshPickerUI()
                    callback(currentColor)
                end,
                Type = "ColorPicker"
            }

            if configId then
                Library._configElements[configId] = colorPickerObj
            end

            return colorPickerObj
        end

        return Tab
    end

    return Window
end

return Library
