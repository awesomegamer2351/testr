local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    MainColor         = Color3.fromRGB(28, 28, 30),
    SidebarColor      = Color3.fromRGB(32, 32, 34),
    SeparatorColor    = Color3.fromRGB(45, 45, 48),
    SectionColor      = Color3.fromRGB(35, 35, 37),
    AccentColor       = Color3.fromRGB(107, 102, 237),
    TextActiveColor   = Color3.fromRGB(255, 255, 255),
    TextInactiveColor = Color3.fromRGB(120, 120, 125),
    DropdownColor     = Color3.fromRGB(31, 33, 37), -- rgba(31, 33, 37)
    Font              = Enum.Font.GothamMedium,
}

local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do obj[i] = v end
    return obj
end

function Library:CreateWindow(title)
    local ScreenGui = Create("ScreenGui", {Name = "CheetoHub", Parent = CoreGui, ResetOnSpawn = false})
    
    local Main = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 620, 0, 420),
        Position = UDim2.new(0.5, -310, 0.5, -210),
        BackgroundColor3 = self.MainColor,
        BorderSizePixel = 0,
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Main})

    local Sidebar = Create("Frame", {
        Parent = Main,
        Size = UDim2.new(0, 180, 1, 0),
        BackgroundColor3 = self.SidebarColor,
        BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Sidebar})

    -- Sidebar Title (Centered and Larger as requested)
    local TitleLabel = Create("TextLabel", {
        Parent = Sidebar,
        Text = title,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        Position = UDim2.new(0, 10, 0, 70),
        Size = UDim2.new(1, -20, 1, -80),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0
    })
    Create("UIListLayout", {Parent = TabContainer, Padding = UDim.new(0, 5)})

    local Content = Create("Frame", {
        Parent = Main,
        Position = UDim2.new(0, 180, 0, 0),
        Size = UDim2.new(1, -180, 1, 0),
        BackgroundTransparency = 1
    })

    -- Vertical Line between sidebar and content
    Create("Frame", {
        Parent = Main,
        Position = UDim2.new(0, 179, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = self.SeparatorColor,
        BorderSizePixel = 0
    })

    local TopBar = Create("Frame", {
        Parent = Content,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1
    })
    
    local PathLabel = Create("TextLabel", {
        Parent = TopBar,
        Text = title .. " > ",
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.TextInactiveColor,
        Font = self.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local CollapseBtn = Create("TextButton", {
        Parent = TopBar,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -45, 0.5, -15),
        BackgroundTransparency = 1,
        Text = ">|",
        TextColor3 = self.TextInactiveColor,
        Font = self.Font,
        TextSize = 18
    })

    local isCollapsed = false
    CollapseBtn.MouseButton1Click:Connect(function()
        isCollapsed = not isCollapsed
        PathLabel.Visible = not isCollapsed -- Deletes pathfinding text on hide
        local targetWidth = isCollapsed and 180 or 620
        TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, targetWidth, 0, 420)}):Play()
    end)

    local Window = {Tabs = {}}

    function Window:CreateTab(name)
        local TabBtn = Create("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Library.TextInactiveColor,
            Font = Library.Font,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local Page = Create("ScrollingFrame", {
            Parent = Content,
            Size = UDim2.new(1, 0, 1, -50),
            Position = UDim2.new(0, 0, 0, 50),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 8), HorizontalAlignment = Enum.HorizontalAlignment.Center})

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Window.Tabs) do
                v.Page.Visible = false
                v.Btn.TextColor3 = Library.TextInactiveColor
            end
            Page.Visible = true
            TabBtn.TextColor3 = Library.AccentColor -- Blueish text when active
            PathLabel.Text = title .. " > " .. name
        end)

        local Tab = {Page = Page, Btn = TabBtn}
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Page.Visible = true TabBtn.TextColor3 = Library.AccentColor end

        function Tab:CreateDropdown(text, options, callback)
            local DFrame = Create("Frame", {
                Parent = Page,
                Size = UDim2.new(0, 410, 0, 45),
                BackgroundColor3 = Library.SectionColor,
                BorderSizePixel = 0,
                ClipsDescendants = true
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DFrame})

            local Label = Create("TextLabel", {
                Parent = DFrame,
                Text = text,
                Size = UDim2.new(0, 200, 0, 45),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = Library.TextInactiveColor,
                Font = Library.Font,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local DropdownMain = Create("TextButton", {
                Parent = DFrame,
                Text = "Select...",
                Size = UDim2.new(0, 140, 0, 30),
                Position = UDim2.new(1, -155, 0, 7),
                BackgroundColor3 = Library.DropdownColor,
                TextColor3 = Library.TextActiveColor,
                Font = Library.Font,
                TextSize = 13,
                BorderSizePixel = 0
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DropdownMain})

            local OptionContainer = Create("Frame", {
                Parent = DFrame,
                Position = UDim2.new(0, 0, 0, 45),
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1
            })
            Create("UIListLayout", {Parent = OptionContainer})

            local open = false
            DropdownMain.MouseButton1Click:Connect(function()
                open = not open
                local targetSize = open and (45 + (#options * 30) + 5) or 45
                TweenService:Create(DFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 410, 0, targetSize)}):Play()
            end)

            for _, opt in pairs(options) do
                local OptBtn = Create("TextButton", {
                    Parent = OptionContainer,
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundTransparency = 1,
                    Text = opt,
                    TextColor3 = Library.TextInactiveColor,
                    Font = Library.Font,
                    TextSize = 13
                })
                OptBtn.MouseButton1Click:Connect(function()
                    DropdownMain.Text = opt
                    Label.TextColor3 = Library.TextActiveColor
                    callback(opt)
                    open = false
                    TweenService:Create(DFrame, TweenInfo.new(0.4), {Size = UDim2.new(0, 410, 0, 45)}):Play()
                end)
            end
        end

        return Tab
    end
    return Window
end

return Library
