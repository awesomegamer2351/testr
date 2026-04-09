--[[
	Roblox UI Library Foundation
	ModuleScript providing a clean, modern base container for UI components.
	Expandable architecture - additional UI elements can be added later.

	[STRICT FIXES APPLIED]
	1. WIDER LANDSCAPE RATIO: 800x350 (over 2:1 width-to-height)
	2. DARKER BACKGROUND: RGB(20,20,25) with 0.3 transparency
	3. VISIBLE CORNER GLOW: Bottom‑right corner glow using a UIGradient‑powered frame
	   with a radial‑style transparency falloff and larger size.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Library = {}
Library.__index = Library

-- Private constants
-- ✅ WIDER: 800x350 instead of previous 700x400
local MAIN_FRAME_SIZE = UDim2.fromOffset(800, 350)
local CORNER_RADIUS = UDim.new(0, 12)
-- ✅ Larger glow for undeniable visibility
local GLOW_SIZE = UDim2.fromOffset(400, 400)
local BLUR_SIZE = 15

--[[
	Creates the base UI container with:
	- Centered, translucent blurred background (noticeably darker)
	- Rounded corners
	- Soft white glow from bottom‑right corner (clearly visible)
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

	-- Main frame: centered container with wide landscape proportions
	self.MainFrame = Instance.new("Frame")
	self.MainFrame.Name = "MainContainer"
	self.MainFrame.Size = MAIN_FRAME_SIZE
	self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	self.MainFrame.Position = UDim2.fromScale(0.5, 0.5)
	-- ✅ DARKER BACKGROUND: RGB(20,20,25) with 0.3 transparency
	self.MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	self.MainFrame.BackgroundTransparency = 0.3
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

	-- ✅ VISIBLE BOTTOM‑RIGHT CORNER GLOW
	-- Uses a large frame anchored at the corner with a UIGradient that simulates radial fade.
	local glowFrame = Instance.new("Frame")
	glowFrame.Name = "CornerGlow"
	glowFrame.Size = GLOW_SIZE
	glowFrame.AnchorPoint = Vector2.new(1, 1)          -- Anchor at bottom‑right
	glowFrame.Position = UDim2.fromScale(1, 1)
	glowFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	glowFrame.BackgroundTransparency = 1               -- Transparency handled by gradient
	glowFrame.BorderSizePixel = 0
	glowFrame.ZIndex = 2                               -- Render above background elements
	glowFrame.Parent = self.MainFrame

	-- Round the glow frame to match parent corners
	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = CORNER_RADIUS
	glowCorner.Parent = glowFrame

	-- ✅ UIGradient configured for a directional corner glow
	-- Transparency keypoints create a fade from bright (near corner) to transparent (away).
	-- Rotation set to -45° so the gradient aligns diagonally from the corner inward.
	local glowGradient = Instance.new("UIGradient")
	glowGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	glowGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0.0, 0.3),    -- Bright at the very corner
		NumberSequenceKeypoint.new(0.2, 0.6),    -- Quickly fade
		NumberSequenceKeypoint.new(0.5, 0.9),    -- Almost gone halfway across the glow frame
		NumberSequenceKeypoint.new(1.0, 1.0)     -- Fully transparent at far edges
	})
	glowGradient.Rotation = -45                   -- Align with bottom‑right to top‑left diagonal
	glowGradient.Parent = glowFrame

	-- Ensure UI scales properly on all screens
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 1
	uiScale.Parent = self.ScreenGui

	-- Maintain the wide aspect ratio
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
