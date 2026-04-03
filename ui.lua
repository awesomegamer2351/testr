local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    MainColor         = Color3.fromRGB(31, 33, 35),
    SidebarColor      = Color3.fromRGB(31, 33, 35),
    SeparatorColor    = Color3.fromRGB(45, 45, 45),
    SectionColor      = Color3.fromRGB(35, 38, 39),
    AccentColor       = Color3.fromRGB(107, 102, 237), -- Blue line color
    ToggleOffColor    = Color3.fromRGB(61, 62, 111),
    TextInactiveColor = Color3.fromRGB(109, 111, 113),
    TabSelectedBg     = Color3.fromRGB(40, 42, 44),
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
        BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = Main})

    local Sidebar = Create("Frame", {
        Parent = Main,
        Size = UDim2.new(0, 180, 1, 0),
        BackgroundColor3 = self.SidebarColor,
        BorderSizePixel = 0,
        ZIndex = 5
    })
    
    local Content = Create("Frame", {
        Parent = Main,
        Position = UDim2.new(0, 181, 0, 0),
        Size = UDim2.new(1, -181, 1, 0),
        BackgroundTransparency = 1
    })

    -- TOP UI ELEMENTS
    local PathLabel = Create("TextLabel", {
        Parent = Content,
        Size = UDim2.new(1, -50, 0, 50),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.TextInactiveColor,
        Font = self.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = title .. " > "
    })

    local CollapseBtn = Create("TextButton", {
        Parent = Content,
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 10),
        BackgroundTransparency = 1,
        Text = ">|",
        TextColor3 = self.TextInactiveColor,
        Font = self.Font,
        TextSize = 16
    })

    -- TOP LINE
    Create("Frame", {
        Parent = Content,
        Size = UDim2.new(1, -30, 0, 1),
        Position = UDim2.new(0, 15, 0, 50),
        BackgroundColor3 = self.SeparatorColor,
        BorderSizePixel = 0
    })

    local Window = {Tabs = {}}

    function Window:CreateTab(name)
        local Page = Create("ScrollingFrame", {
            Parent = Content,
            Size = UDim2.new(1, 0, 1, -60),
            Position = UDim2.new(0, 0, 0, 60),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 0
        })
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 5), HorizontalAlignment = Enum.HorizontalAlignment.Center})
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 10)})

        local TabBtn = Create("TextButton", {
            Parent = Main:FindFirstChild("ScrollingFrame") or Create("ScrollingFrame", {Parent = Sidebar, Position = UDim2.new(0,0,0,70), Size = UDim2.new(1,0,1,-70), BackgroundTransparency = 1, ScrollBarThickness = 0}),
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Library.TextInactiveColor,
            Font = Library.Font,
            TextSize = 14
        })
        if TabBtn.Parent.ClassName ~= "ScrollingFrame" then Create("UIListLayout", {Parent = TabBtn.Parent}) end

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Window.Tabs) do v.Page.Visible = false end
            Page.Visible = true
            PathLabel.Text = title .. " > " .. name
        end)

        local Tab = {Page = Page}
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then Page.Visible = true PathLabel.Text = title .. " > " .. name end

        -- TOGGLE WITH BLUE LINE
        function Tab:CreateToggle(text, callback)
            local TFrame = Create("Frame", {Parent = Page, Size = UDim2.new(1, -30, 0, 40), BackgroundColor3 = Library.SectionColor, BorderSizePixel = 0})
            Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = TFrame})
            
            -- THE BLUE ACCENT LINE
            local BlueLine = Create("Frame", {Parent = TFrame, Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = Library.AccentColor, BorderSizePixel = 0})

            local Label = Create("TextLabel", {Parent = TFrame, Text = text, Size = UDim2.new(1, -100, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, TextColor3 = Library.TextInactiveColor, Font = Library.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local Switch = Create("Frame", {Parent = TFrame, Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -50, 0.5, -9), BackgroundColor3 = Library.ToggleOffColor, BorderSizePixel = 0})
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})
            
            local Ball = Create("Frame", {Parent = Switch, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0})
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Ball})

            local state = false
            TFrame.InputBegan:Connect(function(io)
                if io.UserInputType == Enum.UserInputType.MouseButton1 then
                    state = not state
                    TweenService:Create(Ball, TweenInfo.new(0.2), {Position = state and UDim2.new(0, 20, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
                    TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.AccentColor or Library.ToggleOffColor}):Play()
                    callback(state)
                end
            end)
        end

        -- REAL DROPDOWN TOGGLE
        function Tab:CreateDropdown(text, options, callback)
            local DFrame = Create("Frame", {Parent = Page, Size = UDim2.new(1, -30, 0, 40), BackgroundColor3 = Library.SectionColor, BorderSizePixel = 0, ZIndex = 2})
            Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = DFrame})
            
            -- THE BLUE ACCENT LINE
            Create("Frame", {Parent = DFrame, Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = Library.AccentColor, BorderSizePixel = 0})

            local Label = Create("TextLabel", {Parent = DFrame, Text = text, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, TextColor3 = Library.TextInactiveColor, Font = Library.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})

            local DropBtn = Create("TextButton", {Parent = DFrame, Size = UDim2.new(0, 120, 0, 26), Position = UDim2.new(1, -135, 0.5, -13), BackgroundColor3 = Color3.fromRGB(30, 30, 30), TextColor3 = Library.TextInactiveColor, Text = "Select...", Font = Library.Font, TextSize = 12})
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DropBtn})

            local DropList = Create("ScrollingFrame", {Parent = DFrame, Position = UDim2.new(1, -135, 1, 5), Size = UDim2.new(0, 120, 0, 0), BackgroundColor3 = Color3.fromRGB(30, 30, 30), Visible = false, ScrollBarThickness = 0, ZIndex = 10})
            Create("UIListLayout", {Parent = DropList})

            local open = false
            DropBtn.MouseButton1Click:Connect(function()
                open = not open
                DropList.Visible = open
                DropList.Size = open and UDim2.new(0, 120, 0, math.min(#options * 25, 100)) or UDim2.new(0, 120, 0, 0)
            end)

            for _, opt in pairs(options) do
                local OptBtn = Create("TextButton", {Parent = DropList, Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Text = opt, TextColor3 = Color3.fromRGB(200, 200, 200), Font = Library.Font, TextSize = 12, ZIndex = 11})
                OptBtn.MouseButton1Click:Connect(function()
                    DropBtn.Text = opt
                    open = false
                    DropList.Visible = false
                    callback(opt)
                end)
            end
        end

        return Tab
    end
    return Window
end

return Library
