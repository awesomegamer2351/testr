local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    -- EXACT V5 PALETTE
    MainColor         = Color3.fromRGB(31, 33, 35),
    SidebarColor      = Color3.fromRGB(31, 33, 35),
    SeparatorColor    = Color3.fromRGB(40, 42, 44),
    SectionColor      = Color3.fromRGB(35, 38, 39),
    ToggleOffColor    = Color3.fromRGB(61, 62, 111),
    ToggleOnColor     = Color3.fromRGB(107, 102, 237), -- THE BLUE
    TextActiveColor   = Color3.fromRGB(220, 220, 220),
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
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = Main})

    -- BIGGER SIDEBAR (180px)
    local Sidebar = Create("Frame", {
        Parent = Main,
        Size = UDim2.new(0, 180, 1, 0),
        BackgroundColor3 = self.SidebarColor,
        BorderSizePixel = 0
    })
    
    -- CENTERED TITLE
    local TitleLabel = Create("TextLabel", {
        Parent = Sidebar,
        Text = "🔥 " .. title,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        Position = UDim2.new(0, 0, 0, 70),
        Size = UDim2.new(1, 0, 1, -70),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0
    })
    Create("UIListLayout", {Parent = TabContainer, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 5)})

    local Content = Create("Frame", {
        Parent = Main,
        Position = UDim2.new(0, 181, 0, 0),
        Size = UDim2.new(1, -181, 1, 0),
        BackgroundTransparency = 1
    })

    local PathLabel = Create("TextLabel", {
        Parent = Content,
        Size = UDim2.new(1, -50, 0, 50),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.TextInactiveColor,
        Font = self.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        RichText = true
    })

    -- Vertical Line
    Create("Frame", {
        Parent = Main,
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(0, 180, 0, 0),
        BackgroundColor3 = self.SeparatorColor,
        BorderSizePixel = 0
    })

    local Window = {Tabs = {}}

    function Window:CreateTab(name)
        local TabBtn = Create("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(0, 160, 0, 35),
            BackgroundColor3 = Library.TabSelectedBg,
            BackgroundTransparency = 1, -- Starts transparent
            Text = name,
            TextColor3 = Library.TextInactiveColor, -- Starts inactive gray
            Font = Library.Font,
            TextSize = 13
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = TabBtn})

        local Page = Create("ScrollingFrame", {
            Parent = Content,
            Size = UDim2.new(1, 0, 1, -51),
            Position = UDim2.new(0, 0, 0, 51),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 0
        })
        Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center})

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Window.Tabs) do
                v.Page.Visible = false
                v.Btn.BackgroundTransparency = 1
                v.Btn.TextColor3 = Library.TextInactiveColor -- Reset others to gray
            end
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0 -- Show background for active
            TabBtn.TextColor3 = Library.ToggleOnColor -- CHANGE TEXT TO BLUE
            PathLabel.Text = title .. " > <font color='#6b66ed'>" .. name .. "</font>"
        end)

        local Tab = {Page = Page, Btn = TabBtn}
        table.insert(Window.Tabs, Tab)
        
        -- Default selection
        if #Window.Tabs == 1 then 
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Library.ToggleOnColor
            PathLabel.Text = title .. " > <font color='#6b66ed'>" .. name .. "</font>"
        end

        function Tab:CreateToggle(text, callback)
            local TFrame = Create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, -30, 0, 38),
                BackgroundColor3 = Library.SectionColor,
                BorderSizePixel = 0
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = TFrame})

            -- BLUE ACCENT LINE (Left side)
            local LeftAccent = Create("Frame", {
                Parent = TFrame,
                Size = UDim2.new(0, 2, 1, 0),
                BackgroundColor3 = Library.ToggleOffColor,
                BorderSizePixel = 0
            })

            local Label = Create("TextLabel", {
                Parent = TFrame,
                Text = text,
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = Library.TextInactiveColor,
                Font = Library.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ToggleBG = Create("Frame", {
                Parent = TFrame,
                Size = UDim2.new(0, 34, 0, 18),
                Position = UDim2.new(1, -45, 0.5, -9),
                BackgroundColor3 = Library.ToggleOffColor,
                BorderSizePixel = 0
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBG})

            local Ball = Create("Frame", {
                Parent = ToggleBG,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, 2, 0.5, -7),
                BackgroundColor3 = Color3.fromRGB(220, 220, 220),
                BorderSizePixel = 0
            })
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Ball})

            local enabled = false
            TFrame.InputBegan:Connect(function(io)
                if io.UserInputType == Enum.UserInputType.MouseButton1 then
                    enabled = not enabled
                    local pos = enabled and UDim2.new(0, 18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                    local col = enabled and Library.ToggleOnColor or Library.ToggleOffColor
                    
                    TweenService:Create(Ball, TweenInfo.new(0.2), {Position = pos}):Play()
                    TweenService:Create(ToggleBG, TweenInfo.new(0.2), {BackgroundColor3 = col}):Play()
                    TweenService:Create(LeftAccent, TweenInfo.new(0.2), {BackgroundColor3 = col}):Play()
                    TweenService:Create(Label, TweenInfo.new(0.2), {TextColor3 = enabled and Library.TextActiveColor or Library.TextInactiveColor}):Play()
                    callback(enabled)
                end
            end)
        end

        function Tab:CreateDropdown(text, options, callback)
            local DFrame = Create("Frame", {
                Parent = Page,
                Size = UDim2.new(1, -30, 0, 38),
                BackgroundColor3 = Library.SectionColor,
                ClipsDescendants = true,
                BorderSizePixel = 0
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = DFrame})

            local DropdownBtn = Create("TextButton", {
                Parent = DFrame,
                Text = text .. " : Select...",
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundTransparency = 1,
                TextColor3 = Library.TextInactiveColor,
                Font = Library.Font,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            Create("UIPadding", {Parent = DropdownBtn, PaddingLeft = UDim.new(0, 15)})

            local OptionContainer = Create("Frame", {
                Parent = DFrame,
                Position = UDim2.new(0, 0, 0, 38),
                Size = UDim2.new(1, 0, 0, #options * 25),
                BackgroundTransparency = 1
            })
            Create("UIListLayout", {Parent = OptionContainer})

            local open = false
            DropdownBtn.MouseButton1Click:Connect(function()
                open = not open
                TweenService:Create(DFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -30, 0, open and (38 + #options * 25) or 38)}):Play()
            end)

            for _, opt in pairs(options) do
                local OptBtn = Create("TextButton", {
                    Parent = OptionContainer,
                    Size = UDim2.new(1, 0, 0, 25),
                    BackgroundTransparency = 1,
                    Text = opt,
                    TextColor3 = Library.TextInactiveColor,
                    Font = Library.Font,
                    TextSize = 12
                })
                OptBtn.MouseButton1Click:Connect(function()
                    DropdownBtn.Text = text .. " : " .. opt
                    callback(opt)
                    open = false
                    TweenService:Create(DFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -30, 0, 38)}):Play()
                end)
            end
        end

        return Tab
    end
    return Window
end

return Library
