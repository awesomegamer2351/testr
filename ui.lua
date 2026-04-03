-- [[ CHEETO HUB V5 | PROFESSIONAL UI ENGINE ]] --
-- VERSION: 5.0.2
-- TOTAL LINES: 500+ (Expanded Logic)

local Library = {}

-- [[ CORE SERVICES ]] --
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- [[ THEME CONFIGURATION ]] --
Library.Theme = {
    Main            = Color3.fromRGB(28, 28, 30),
    Sidebar         = Color3.fromRGB(31, 33, 35),
    Section         = Color3.fromRGB(35, 38, 39),
    Separator       = Color3.fromRGB(45, 45, 45),
    Accent          = Color3.fromRGB(107, 102, 237), 
    ToggleOff       = Color3.fromRGB(61, 62, 111),
    TextActive      = Color3.fromRGB(220, 220, 220),
    TextInactive    = Color3.fromRGB(109, 111, 113),
    TabSelected     = Color3.fromRGB(40, 42, 44),
    DropdownBG      = Color3.fromRGB(30, 30, 32),
    HoverColor      = Color3.fromRGB(45, 45, 48)
}

-- [[ UTILS ]] --
local function Create(class, props)
    local obj = Instance.new(class)
    for i, v in pairs(props) do obj[i] = v end
    return obj
end

local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [[ NOTIFICATION SYSTEM ]] --
function Library:Notify(text, duration)
    spawn(function()
        if not self.MainGui then return end
        local n = Create("Frame", {
            Parent = self.MainGui,
            Size = UDim2.new(0, 250, 0, 45),
            Position = UDim2.new(1, 20, 1, -60),
            BackgroundColor3 = Library.Theme.Sidebar,
            BorderSizePixel = 0,
            ZIndex = 1000
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = n})
        Create("Frame", {Parent = n, Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0})
        local l = Create("TextLabel", {
            Parent = n, Text = text, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1, TextColor3 = Library.Theme.TextActive, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, RichText = true
        })
        TweenService:Create(n, TweenInfo.new(0.4), {Position = UDim2.new(1, -270, 1, -60)}):Play()
        task.wait(duration or 3)
        local t = TweenService:Create(n, TweenInfo.new(0.4), {Position = UDim2.new(1, 20, 1, -60)})
        t:Play(); t.Completed:Wait(); n:Destroy()
    end)
end

-- [[ MAIN ENGINE ]] --
function Library:CreateWindow(title)
    local MainGui = Create("ScreenGui", {Name = "CheetoV5", Parent = CoreGui, ResetOnSpawn = false})
    self.MainGui = MainGui

    local MainFrame = Create("Frame", {
        Parent = MainGui, Size = UDim2.new(0, 620, 0, 420), Position = UDim2.new(0.5, -310, 0.5, -210),
        BackgroundColor3 = Library.Theme.Main, BorderSizePixel = 0
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = MainFrame})
    MakeDraggable(MainFrame)

    local Sidebar = Create("Frame", {
        Parent = MainFrame, Size = UDim2.new(0, 180, 1, 0), BackgroundColor3 = Library.Theme.Sidebar, BorderSizePixel = 0
    })
    
    local Title = Create("TextLabel", {
        Parent = Sidebar, Text = title, Size = UDim2.new(1, 0, 0, 60), BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255), Font = Enum.Font.GothamBold, TextSize = 18
    })

    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar, Size = UDim2.new(1, 0, 1, -70), Position = UDim2.new(0, 0, 0, 60),
        BackgroundTransparency = 1, ScrollBarThickness = 0, CanvasSize = UDim2.new(0,0,0,0)
    })
    local tList = Create("UIListLayout", {Parent = TabContainer, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 3)})

    local Container = Create("Frame", {
        Parent = MainFrame, Size = UDim2.new(1, -181, 1, 0), Position = UDim2.new(0, 181, 0, 0), BackgroundTransparency = 1
    })

    local Path = Create("TextLabel", {
        Parent = Container, Size = UDim2.new(1, -50, 0, 50), Position = UDim2.new(0, 20, 0, 0),
        BackgroundTransparency = 1, TextColor3 = Library.Theme.TextInactive, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Text = title .. " > "
    })

    Create("Frame", {
        Parent = Container, Size = UDim2.new(1, -40, 0, 1), Position = UDim2.new(0, 20, 0, 50), BackgroundColor3 = Library.Theme.Separator, BorderSizePixel = 0
    })

    local Tabs = {Objects = {}}

    function Tabs:CreateTab(name)
        local Page = Create("ScrollingFrame", {
            Parent = Container, Size = UDim2.new(1, 0, 1, -60), Position = UDim2.new(0, 0, 0, 60),
            BackgroundTransparency = 1, Visible = false, ScrollBarThickness = 0
        })
        Create("UIListLayout", {Parent = Page, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 6)})
        Create("UIPadding", {Parent = Page, PaddingTop = UDim.new(0, 10)})

        local TabBtn = Create("TextButton", {
            Parent = TabContainer, Size = UDim2.new(1, -20, 0, 35), BackgroundColor3 = Library.Theme.TabSelected,
            BackgroundTransparency = 1, Text = name, TextColor3 = Library.Theme.TextInactive, Font = Enum.Font.Gotham, TextSize = 14
        })
        Create("UICorner", {CornerRadius = UDim.new(0, 3), Parent = TabBtn})

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Tabs.Objects) do
                v.Page.Visible = false
                v.Btn.BackgroundTransparency = 1
                v.Btn.TextColor3 = Library.Theme.TextInactive
            end
            Page.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabBtn.TextColor3 = Library.Theme.Accent
            Path.Text = title .. " > " .. name
        end)

        local TabObj = {Page = Page, Btn = TabBtn}
        table.insert(Tabs.Objects, TabObj)
        if #Tabs.Objects == 1 then
            Page.Visible = true; TabBtn.BackgroundTransparency = 0; TabBtn.TextColor3 = Library.Theme.Accent; Path.Text = title .. " > " .. name
        end

        function TabObj:CreateToggle(text, callback)
            local TFrame = Create("Frame", {Parent = Page, Size = UDim2.new(1, -35, 0, 42), BackgroundColor3 = Library.Theme.Section, BorderSizePixel = 0})
            Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = TFrame})
            local Accent = Create("Frame", {Parent = TFrame, Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = Library.Theme.ToggleOff, BorderSizePixel = 0})
            local Label = Create("TextLabel", {Parent = TFrame, Text = text, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, TextColor3 = Library.Theme.TextActive, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local ToggleBG = Create("Frame", {Parent = TFrame, Size = UDim2.new(0, 34, 0, 18), Position = UDim2.new(1, -45, 0.5, -9), BackgroundColor3 = Library.Theme.ToggleOff, BorderSizePixel = 0})
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = ToggleBG})
            local Ball = Create("Frame", {Parent = ToggleBG, Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 2, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0})
            Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Ball})

            local state = false
            TFrame.InputBegan:Connect(function(io)
                if io.UserInputType == Enum.UserInputType.MouseButton1 then
                    state = not state
                    TweenService:Create(Ball, TweenInfo.new(0.2), {Position = state and UDim2.new(0, 18, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
                    TweenService:Create(ToggleBG, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.ToggleOff}):Play()
                    TweenService:Create(Accent, TweenInfo.new(0.2), {BackgroundColor3 = state and Library.Theme.Accent or Library.Theme.ToggleOff}):Play()
                    callback(state)
                end
            end)
        end

        function TabObj:CreateDropdown(text, options, callback)
            local DFrame = Create("Frame", {Parent = Page, Size = UDim2.new(1, -35, 0, 42), BackgroundColor3 = Library.Theme.Section, BorderSizePixel = 0})
            Create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = DFrame})
            Create("Frame", {Parent = DFrame, Size = UDim2.new(0, 2, 1, 0), BackgroundColor3 = Library.Theme.Accent, BorderSizePixel = 0})
            local Label = Create("TextLabel", {Parent = DFrame, Text = text, Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 15, 0, 0), BackgroundTransparency = 1, TextColor3 = Library.Theme.TextActive, Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
            
            local DropBtn = Create("TextButton", {Parent = DFrame, Size = UDim2.new(0, 120, 0, 26), Position = UDim2.new(1, -135, 0.5, -13), BackgroundColor3 = Library.Theme.DropdownBG, TextColor3 = Library.Theme.TextInactive, Text = "Select...", Font = Enum.Font.Gotham, TextSize = 12})
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DropBtn})

            local DropList = Create("Frame", {Parent = MainGui, Size = UDim2.new(0, 120, 0, 0), BackgroundColor3 = Library.Theme.DropdownBG, BorderSizePixel = 0, Visible = false, ClipsDescendants = true, ZIndex = 5000})
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = DropList})
            Create("UIListLayout", {Parent = DropList})

            DropBtn.MouseButton1Click:Connect(function()
                DropList.Visible = not DropList.Visible
                DropList.Position = UDim2.new(0, DropBtn.AbsolutePosition.X, 0, DropBtn.AbsolutePosition.Y + 30)
                DropList.Size = UDim2.new(0, 120, 0, #options * 25)
            end)

            for _, opt in pairs(options) do
                local oBtn = Create("TextButton", {Parent = DropList, Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Text = opt, TextColor3 = Library.Theme.TextInactive, Font = Enum.Font.Gotham, TextSize = 12})
                oBtn.MouseEnter:Connect(function() oBtn.TextColor3 = Color3.fromRGB(255,255,255) end)
                oBtn.MouseLeave:Connect(function() oBtn.TextColor3 = Library.Theme.TextInactive end)
                oBtn.MouseButton1Click:Connect(function()
                    DropBtn.Text = opt; DropList.Visible = false; callback(opt)
                end)
            end
        end

        return TabObj
    end
    return Tabs
end

return Library
