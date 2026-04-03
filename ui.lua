-- [[ CHEETO UI LIBRARY V5 - FULL ENGINE REWRITE ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Library = {
    GUI = nil,
    CurrentTab = nil,
    Pointers = {},
    
    Palette = {
        Main            = Color3.fromRGB(28, 28, 30),
        Sidebar         = Color3.fromRGB(31, 33, 35),
        Section         = Color3.fromRGB(35, 38, 39),
        Separator       = Color3.fromRGB(45, 45, 45),
        Accent          = Color3.fromRGB(107, 102, 237), 
        ToggleOff       = Color3.fromRGB(61, 62, 111),
        TextActive      = Color3.fromRGB(220, 220, 220),
        TextInactive    = Color3.fromRGB(109, 111, 113),
        TabHighlight    = Color3.fromRGB(40, 42, 44),
        DropdownBG      = Color3.fromRGB(30, 30, 32),
    },
    Font = Enum.Font.GothamMedium,
    Bold = Enum.Font.GothamBold
}

local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do obj[i] = v end
    return obj
end

function Library:Notify(text, duration)
    spawn(function()
        local NotificationFrame = Create("Frame", {
            Parent = self.GUI,
            Size = UDim2.new(0, 250, 0, 45),
            Position = UDim2.new(1, 10, 1, -60),
            BackgroundColor3 = self.Palette.Sidebar,
            BorderSizePixel = 0,
            ZIndex = 100
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = NotificationFrame})
        Create("Frame", {Parent = NotificationFrame, Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = self.Palette.Accent, BorderSizePixel = 0})
        
        local Label = Create("TextLabel", {
            Parent = NotificationFrame,
            Text = text,
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            TextColor3 = self.Palette.TextActive,
            Font = self.Font,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            RichText = true
        })
        
        TweenService:Create(NotificationFrame, TweenInfo.new(0.4), {Position = UDim2.new(1, -260, 1, -60)}):Play()
        task.wait(duration or 3)
        local out = TweenService:Create(NotificationFrame, TweenInfo.new(0.4), {Position = UDim2.new(1, 10, 1, -60)})
        out:Play()
        out.Completed:Wait()
        NotificationFrame:Destroy()
    end)
end

function Library:CreateWindow(title)
    local ScreenGui = Create("ScreenGui", {Name = "CheetoV5", Parent = CoreGui, ResetOnSpawn = false})
    self.GUI = ScreenGui

    local Main = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.new(0, 620, 0, 420),
        Position = UDim2.new(0.5, -310, 0.5, -210),
        BackgroundColor3 = self.Palette.Main,
        BorderSizePixel = 0,
        Active = true
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = Main})
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    local Sidebar = Create("Frame", {
        Parent = Main,
        Size = UDim2.new(0, 180, 1, 0),
        BackgroundColor3 = self.Palette.Sidebar,
        BorderSizePixel = 0
    })

    local TitleLabel = Create("TextLabel", {
        Parent = Sidebar,
        Text = title,
        Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = self.Bold,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Center
    })

    local TabList = Create("ScrollingFrame", {
        Parent = Sidebar,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -60),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0,0,0,0)
    })
    local layout = Create("UIListLayout", {Parent = TabList, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 2)})
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabList.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y)
    end)

    local Content = Create("Frame", {
        Parent = Main,
        Position = UDim2.new(0, 181, 0, 0),
        Size = UDim2.new(1, -181, 1, 0),
        BackgroundTransparency = 1
    })

    local PathLabel = Create("TextLabel", {
        Parent = Content,
        Size = UDim2.new(1, -50, 0, 50),
        Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1,
        TextColor3 = self.Palette.TextInactive,
        Font = self.Font,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = title .. " > "
    })

    Create("Frame", {
        Parent = Content,
        Size = UDim2.new(1, -40, 0, 1),
        Position = UDim2.new(0, 20, 0, 50),
        BackgroundColor3 = self.Palette.Separator,
        BorderSizePixel = 0
    })

    local Window = {Tabs = {}}

    function Window:CreateTab(name)
        local Page = Create("ScrollingFrame", {
            Parent = Content,
            Size = UDim2.new(1, 0, 1, -55),
            Position = UDim2.new(0, 0, 0, 55),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 0
        })
        local pLayout = Create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Center})
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 10)})

        local TabBtn = Create("TextButton", {
            Parent = TabList,
            Size = UDim2.new(1, -15, 0, 36),
            BackgroundColor3 = Library.Palette.TabHighlight,
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Library.Palette.TextInactive,
            Font = Library.Font,
            TextSize = 14
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = TabBtn})

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Window.Tabs) do
                v.Page.Visible = false
                v.Btn.BackgroundTransparency = 1
                v.Btn.TextColor3 = Library.Palette.TextInactive
            end
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Library.Palette.Accent
            PathLabel.Text = title .. " > " .. name
        end)

        local Tab = {Page = Page, Btn = TabBtn}
        table.insert(Window.Tabs, Tab)
        if #Window.Tabs == 1 then
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Library.Palette.Accent
            PathLabel.Text = title .. " > " .. name
        end

        function Tab:CreateToggle(text, callback)
            local TFrame = Create("Frame", {Parent = Page, Size = UDim2.new(1, -35, 0, 42), BackgroundColor3 = Library.Palette.Section, BorderSizePixel = 0})
            Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = TFrame})
            
            local BlueLine = Create("Frame", {Parent = TFrame, Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = Library.Palette.ToggleOff, BorderSizePixel = 0})

            local Label = Create("TextLabel", {
                Parent = TFrame, Text = text, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Library.Palette.TextActive, Font = Library.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
            })

            local ToggleBG = Create("Frame", {Parent = TFrame, Size = UDim2.new(0, 34, 0, 18), Position = UDim2.new(1, -45, 0.5, -9), BackgroundColor3 = Library.Palette.ToggleOff, BorderSizePixel = 0})
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBG})
            local Ball = Create("Frame", {Parent = ToggleBG, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0})
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Ball})

            local state = false
            TFrame.InputBegan:Connect(function(io)
                if io.UserInputType == Enum.UserInputType.MouseButton1 then
                    state = not state
                    TweenService:Create(Ball, TweenInfo.new(0.2), {Position = state and UDim2.new(0, 18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
                    TweenService:Create(ToggleBG, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.Palette.Accent or Library.Palette.ToggleOff}):Play()
                    TweenService:Create(BlueLine, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.Palette.Accent or Library.Palette.ToggleOff}):Play()
                    callback(state)
                end
            end)
        end

        function Tab:CreateDropdown(text, options, callback)
            local DFrame = Create("Frame", {Parent = Page, Size = UDim2.new(1, -35, 0, 42), BackgroundColor3 = Library.Palette.Section, BorderSizePixel = 0})
            Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = DFrame})
            
            Create("Frame", {Parent = DFrame, Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = Library.Palette.Accent, BorderSizePixel = 0})

            local Label = Create("TextLabel", {
                Parent = DFrame, Text = text, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1, TextColor3 = Library.Palette.TextActive, Font = Library.Font, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left
            })

            local DropBtn = Create("TextButton", {
                Parent = DFrame, Size = UDim2.new(0, 120, 0, 26), Position = UDim2.new(1, -135, 0.5, -13),
                BackgroundColor3 = Color3.fromRGB(30, 30, 32), TextColor3 = Library.Palette.TextInactive, Text = "Select...", Font = Library.Font, TextSize = 12
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DropBtn})

            -- External Dropdown List
            local DropList = Create("Frame", {
                Parent = ScreenGui, Size = UDim2.new(0, 120, 0, 0), BackgroundColor3 = Library.Palette.DropdownBG,
                BorderSizePixel = 0, Visible = false, ClipsDescendants = true, ZIndex = 50
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DropList})
            local dLayout = Create("UIListLayout", {Parent = DropList})

            DropBtn.MouseButton1Click:Connect(function()
                DropList.Visible = not DropList.Visible
                DropList.Position = UDim2.new(0, DropBtn.AbsolutePosition.X, 0, DropBtn.AbsolutePosition.Y + 30)
                DropList.Size = UDim2.new(0, 120, 0, DropList.Visible and #options * 25 or 0)
            end)

            for _, opt in pairs(options) do
                local OptBtn = Create("TextButton", {
                    Parent = DropList, Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1,
                    Text = opt, TextColor3 = Library.Palette.TextInactive, Font = Library.Font, TextSize = 12
                })
                OptBtn.MouseEnter:Connect(function() OptBtn.TextColor3 = Color3.fromRGB(255,255,255) end)
                OptBtn.MouseLeave:Connect(function() OptBtn.TextColor3 = Library.Palette.TextInactive end)
                OptBtn.MouseButton1Click:Connect(function()
                    DropBtn.Text = opt
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
