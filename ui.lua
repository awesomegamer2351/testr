--[[
	Roblox UI Library Foundation
	ModuleScript providing a clean, modern base container for UI components.
	Expandable architecture - additional UI elements can be added later.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Library = {}
Library.__index = Library

-- Private constants
local MAIN_FRAME_SIZE = UDim2.fromOffset(600, 400)
local CORNER_RADIUS = UDim.new(0, 12)
local GLOW_SIZE = UDim2.fromOffset(200, 200)
local BLUR_SIZE = 15

--[[
	Creates the base UI container with:
	- Centered, translucent blurred background
	- Rounded corners
	- Soft white glow from bottom corner
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

	-- Main frame: centered container
	self.MainFrame = Instance.new("Frame")
	self.MainFrame.Name = "MainContainer"
	self.MainFrame.Size = MAIN_FRAME_SIZE
	self.MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	self.MainFrame.Position = UDim2.fromScale(0.5, 0.5)
	self.MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) -- Dark base for translucency
	self.MainFrame.BackgroundTransparency = 0.4
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
		ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 230))
	})
	mainGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.1),
		NumberSequenceKeypoint.new(1, 0.3)
	})
	mainGradient.Rotation = 45
	mainGradient.Parent = self.MainFrame

	-- Blur effect for background (translucent + blurred)
	local blur = Instance.new("BlurEffect")
	blur.Size = BLUR_SIZE
	blur.Parent = self.MainFrame

	-- Soft white glow from bottom-right corner
	local glowFrame = Instance.new("Frame")
	glowFrame.Name = "CornerGlow"
	glowFrame.Size = GLOW_SIZE
	glowFrame.AnchorPoint = Vector2.new(1, 1)
	glowFrame.Position = UDim2.fromScale(1, 1)
	glowFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	glowFrame.BackgroundTransparency = 1 -- Start fully transparent, gradient handles visibility
	glowFrame.BorderSizePixel = 0
	glowFrame.Parent = self.MainFrame

	local glowCorner = Instance.new("UICorner")
	glowCorner.CornerRadius = CORNER_RADIUS
	glowCorner.Parent = glowFrame

	-- Gradient to create a directional glow (fades out from corner)
	local glowGradient = Instance.new("UIGradient")
	glowGradient.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	glowGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),  -- Corner is semi-transparent white
		NumberSequenceKeypoint.new(0.5, 0.8),
		NumberSequenceKeypoint.new(1, 1)      -- Fully transparent away from corner
	})
	glowGradient.Rotation = -45 -- Angle from bottom-right toward center
	glowGradient.Parent = glowFrame

	-- Ensure UI scales properly on all screens
	local uiScale = Instance.new("UIScale")
	uiScale.Scale = 1
	uiScale.Parent = self.ScreenGui

	-- Optional: maintain aspect ratio
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
