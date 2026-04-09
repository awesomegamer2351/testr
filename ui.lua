--[[
	Custom Executor UI Library - Base Container Module
	Author: Expert Lua/Luau Developer
	Description: Foundation for a modern, expandable executor UI using Drawing API only.
	No Roblox Instances allowed.
	
	Features implemented in this step:
	- Centered, landscape-oriented panel
	- Dark semi-transparent background with simulated rounded corners
	- Soft white glow emanating from a single bottom corner
	- Resolution-adaptive positioning
	- Clean modular structure for future component additions
]]

local Library = {}
Library.__index = Library

-- ======================== Utility Functions ========================

-- Get the current screen dimensions (viewport size)
local function getScreenSize()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	else
		-- Fallback for environments without a camera (unlikely)
		return Vector2.new(1920, 1080)
	end
end

-- Generate vertices for a filled rounded rectangle polygon
-- @param center Vector2 - center position of the rectangle
-- @param size Vector2 - width and height of the rectangle
-- @param radius number - corner radius
-- @param segments number - number of segments per corner (higher = smoother)
-- @return table of Vector2 points in order (clockwise)
local function generateRoundedRectVertices(center, size, radius, segments)
	segments = segments or 8
	local halfW, halfH = size.X * 0.5, size.Y * 0.5
	local left, right = center.X - halfW, center.X + halfW
	local top, bottom = center.Y - halfH, center.Y + halfH
	
	-- Ensure radius doesn't exceed half of smallest dimension
	radius = math.min(radius, halfW, halfH)
	
	local vertices = {}
	
	-- Helper to add points along a quarter circle
	local function addCornerPoints(cx, cy, startAngle, endAngle)
		local step = (endAngle - startAngle) / segments
		for i = 0, segments do
			local angle = startAngle + i * step
			local x = cx + radius * math.cos(angle)
			local y = cy + radius * math.sin(angle)
			table.insert(vertices, Vector2.new(x, y))
		end
	end
	
	-- Top-left corner (from pi to 1.5pi) -> actually we'll do clockwise from top-left
	-- Order: top-left -> top-right -> bottom-right -> bottom-left -> back to top-left
	-- We'll generate points clockwise.
	
	-- Top edge (left to right, excluding corner arcs)
	table.insert(vertices, Vector2.new(left + radius, top))
	table.insert(vertices, Vector2.new(right - radius, top))
	
	-- Top-right corner
	addCornerPoints(right - radius, top + radius, -math.pi/2, 0) -- from -90° to 0°
	
	-- Right edge (top to bottom)
	table.insert(vertices, Vector2.new(right, bottom - radius))
	
	-- Bottom-right corner
	addCornerPoints(right - radius, bottom - radius, 0, math.pi/2) -- 0° to 90°
	
	-- Bottom edge (right to left)
	table.insert(vertices, Vector2.new(left + radius, bottom))
	
	-- Bottom-left corner
	addCornerPoints(left + radius, bottom - radius, math.pi/2, math.pi) -- 90° to 180°
	
	-- Left edge (bottom to top)
	table.insert(vertices, Vector2.new(left, top + radius))
	
	-- Top-left corner (back to start)
	addCornerPoints(left + radius, top + radius, math.pi, 3*math.pi/2) -- 180° to 270°
	
	return vertices
end

-- Create a soft glow effect from a specific corner using layered circles
-- @param cornerPosition Vector2 - world position of the corner (bottom-left or bottom-right)
-- @param baseColor Color3 - color of the glow (usually white)
-- @param intensity number - base transparency multiplier
-- @return table of Drawing objects for the glow layers
local function createCornerGlow(cornerPosition, baseColor, intensity)
	local layers = {}
	local layerCount = 8
	local maxRadius = 250
	local startRadius = 30
	
	for i = 0, layerCount - 1 do
		local progress = i / (layerCount - 1)
		local radius = startRadius + (maxRadius - startRadius) * progress
		local transparency = 0.7 + 0.3 * progress -- fade out as radius increases
		
		local circle = Drawing.new("Circle")
		circle.Visible = true
		circle.Position = cornerPosition
		circle.Radius = radius
		circle.Color = baseColor
		circle.Transparency = transparency * intensity
		circle.Filled = true
		circle.ZIndex = 1 -- behind main panel but visible
		
		table.insert(layers, circle)
	end
	
	return layers
end

-- ======================== Library Class ========================

function Library.new()
	local self = setmetatable({}, Library)
	
	-- Configuration
	self.ScreenSize = getScreenSize()
	
	-- Panel dimensions (landscape: wider than tall)
	self.Size = Vector2.new(600, 400)
	self.Position = Vector2.new(
		(self.ScreenSize.X - self.Size.X) / 2,
		(self.ScreenSize.Y - self.Size.Y) / 2
	)
	
	-- Styling
	self.BackgroundColor = Color3.fromRGB(20, 20, 25) -- dark grey/blueish
	self.BackgroundTransparency = 0.15 -- semi-transparent
	self.CornerRadius = 12
	
	-- Glow settings (from bottom-right corner)
	self.GlowCorner = "BottomRight" -- could be "BottomLeft" later
	self.GlowColor = Color3.fromRGB(255, 255, 255)
	self.GlowIntensity = 0.6
	
	-- Drawing objects storage (for cleanup/updates)
	self.Drawings = {}
	
	-- Create the UI elements
	self:_createBaseContainer()
	
	return self
end

-- Internal method to create all drawing objects for the base container
function Library:_createBaseContainer()
	-- Clear any existing drawings (useful if reinitializing)
	self:Destroy()
	
	local drawings = {}
	
	-- 1. Glow layers (bottom-right corner)
	local cornerPos
	if self.GlowCorner == "BottomRight" then
		cornerPos = Vector2.new(
			self.Position.X + self.Size.X,
			self.Position.Y + self.Size.Y
		)
	else -- default to bottom-left if specified otherwise
		cornerPos = Vector2.new(
			self.Position.X,
			self.Position.Y + self.Size.Y
		)
	end
	
	local glowLayers = createCornerGlow(cornerPos, self.GlowColor, self.GlowIntensity)
	for _, glow in ipairs(glowLayers) do
		table.insert(drawings, glow)
	end
	
	-- 2. Main panel (rounded rectangle using Polygon)
	local vertices = generateRoundedRectVertices(
		self.Position + self.Size * 0.5, -- center
		self.Size,
		self.CornerRadius,
		12 -- segments for smoothness
	)
	
	local panel = Drawing.new("Polygon")
	panel.Visible = true
	panel.Points = vertices
	panel.Color = self.BackgroundColor
	panel.Transparency = self.BackgroundTransparency
	panel.Filled = true
	panel.Thickness = 0 -- no outline for now
	panel.ZIndex = 2
	
	table.insert(drawings, panel)
	
	-- Optional: subtle border for definition (can be toggled later)
	local borderVertices = generateRoundedRectVertices(
		self.Position + self.Size * 0.5,
		self.Size,
		self.CornerRadius,
		12
	)
	local border = Drawing.new("Polygon")
	border.Visible = true
	border.Points = borderVertices
	border.Color = Color3.fromRGB(80, 80, 90)
	border.Transparency = 0.7
	border.Filled = false
	border.Thickness = 1.5
	border.ZIndex = 3
	
	table.insert(drawings, border)
	
	self.Drawings = drawings
end

-- Public method to update the container (e.g., on resolution change)
function Library:Update()
	local newScreenSize = getScreenSize()
	if self.ScreenSize ~= newScreenSize then
		self.ScreenSize = newScreenSize
		self.Position = Vector2.new(
			(self.ScreenSize.X - self.Size.X) / 2,
			(self.ScreenSize.Y - self.Size.Y) / 2
		)
		-- Recreate all drawings with new positions
		self:_createBaseContainer()
	end
end

-- Clean up all drawing objects
function Library:Destroy()
	if self.Drawings then
		for _, drawing in ipairs(self.Drawings) do
			pcall(function() drawing:Remove() end)
		end
		self.Drawings = {}
	end
end

-- Hide/Show the entire UI (useful for toggle key)
function Library:SetVisible(visible)
	for _, drawing in ipairs(self.Drawings) do
		drawing.Visible = visible
	end
end

-- ======================== Module Initialization ========================

-- Creates and returns a new UI library instance
-- @return Library instance
local function init()
	local lib = Library.new()
	
	-- Optional: listen for resolution changes (requires executor environment support)
	-- Could be implemented with a loop or event connection if available.
	
	return lib
end

-- Return the module table
return {
	init = init,
	-- Expose Library for potential extension
	Library = Library
}
