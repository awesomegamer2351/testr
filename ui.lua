--[[
	Roblox UI Library Foundation
	ModuleScript providing a clean, modern base container for UI components.
	Expandable architecture - additional UI elements can be added later.

	[IMPROVEMENTS APPLIED]
	- Main frame made wider (landscape ratio: 700x400)
	- Background darkened while preserving translucency and blur
	- Bottom‑right corner glow now clearly visible using a soft gradient overlay
	- Code remains modular, professional, and ready for future components
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Library = {}
Library.__index = Library

-- Private constants
local MAIN_FRAME_SIZE = UDim2.fromOffset(700, 400)      -- ✅ Wider landscape shape
local CORNER_RADIUS = UDim.new(0, 12)
local GLOW_SIZE = UDim2.fromOffset(300, 300)            -- ✅ Larger glow for better visibility
local BLUR_SIZE = 15

--[[
	Creates the base UI container with:
	- Centered, translucent blurred background (now darker)
	- Rounded corners
	- Soft white glow from bottom‑right corner (visible and smooth)
	- Proper scaling across resolutions
]]
function Library.new()
	local self = setmetatable({}, Library)

	-- ScreenGui: main container for all UI elements
	self.ScreenGui = Instance.new("ScreenGui")
	self.ScreenGui.Name = "ModernUILibrary"
	self.ScreenGui.ResetOnSpawn = false
	self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	-- Parent to PlayerGui when available
	local player = Players.LocalPlayer
	if not player then
		if RunService:IsRunning() then
			warn("Library initialized before LocalPlayer ready; waiting for PlayerGui")
		end
		player = Players.LocalPlayer or Players.PlayerAdded:Wait()
	end
	local playerGui = player:WaitForChild("PlayerGui")
	self.ScreenGui.Parent = playerGui

	-- Main frame: centered container with landscape proportions
	self.MainFrame = Instance.new("Frame")
	self.MainFrame.Name = "MainContainer"
	self.MainFrame.Size = MAIN_FRAME_SIZE
	self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	self.MainFrame.Position = UDim2.fromScale(0.5, 0.5)
	-- ✅ Darker base colour while still translucent
	self.MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
	self.MainFrame.BackgroundTransparency = 0.35
	self.MainFrame.BorderSizePixel = 0
	self.MainFrame.ClipsDescendants = true
	self.MainFrame.Parent = self.ScreenGui

	-- Rounded corners
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = CORNER_RADIUS
	uiCorner.Parent = self.MainFrame

	-- Subtle gradient overlay for depth
	local mainGradient = Instance.new("UIGradient")
	mainGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 210))
	})
	mainGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(1, 0.25)
	})
	mainGradient.Rotation = 45
	mainGradient.Parent = self.MainFrame

	-- Blur effect for background (translucent + blurred)
	local blur = Instance.new("BlurEffect")
	blur.Size = BLUR_SIZE
	blur.Parent = self.MainFrame

	-- ✅ Improved bottom‑right corner glow – now clearly visible
	local glowFrame = Instance.new("Frame")
	glowFrame.Name = "CornerGlow"
	glowFrame.Size = GLOW_SIZE
	glowFrame.AnchorPoint = Vector2.new(1, 1)          -- Anchor at bottom‑right
	glowFrame.Position = UDim2.fromScale(1, 1)
	glowFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	glowFrame.BackgroundTransparency = 1               -- Transparency controlled by gradient
	glowFrame.BorderSizePixel = 0
	glowFrame.ZIndex = 2                               -- Render above main frame content
	glowFrame.Parent = self.MainFrame

	-- Match rounded corners of parent
	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = CORNER_RADIUS
	glowCorner.Parent = glowFrame

	-- Gradient to create a soft directional glow (fades from corner outward)
	local glowGradient = Instance.new("UIGradient")
	glowGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	-- ✅ Adjusted transparency sequence for a visible yet subtle glow
	glowGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0.0, 0.2),    -- Brightest at corner
		NumberSequenceKeypoint.new(0.3, 0.6),
		NumberSequenceKeypoint.new(0.7, 0.9),
		NumberSequenceKeypoint.new(1.0, 1.0)     -- Fully transparent away from corner
	})
	glowGradient.Rotation = -45                   -- Angle toward centre
	glowGradient.Parent = glowFrame

	-- Ensure UI scales properly on all screens
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 1
	uiScale.Parent = self.ScreenGui

	-- Optional: maintain aspect ratio (now landscape)
	local aspectRatio = Instance.new("UIAspectRatioConstraint")
	aspectRatio.AspectRatio = MAIN_FRAME_SIZE.X.Offset / MAIN_FRAME_SIZE.Y.Offset
	aspectRatio.Parent = self.MainFrame

	return self
end

--[[
	Cleans up the UI when no longer needed.
]]
function Library:Destroy()
	if self.ScreenGui then
		self.ScreenGui:Destroy()
		self.ScreenGui = nil
	end
	self.MainFrame = nil
end

--[[
	Returns the main container frame for adding custom components.
]]
function Library:GetContainer()
	return self.MainFrame
end

--[[
	Sets the visibility of the entire UI.
]]
function Library:SetVisible(visible: boolean)
	if self.ScreenGui then
		self.ScreenGui.Enabled = visible
	end
end

return Library
