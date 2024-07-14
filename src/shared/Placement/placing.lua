local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local placing = {}
placing.__index = placing

local config = require(script.Parent.config)

local structures = ReplicatedStorage:WaitForChild("Structures")

local camera = workspace.CurrentCamera
local ignoreParams = RaycastParams.new()
ignoreParams.FilterType = Enum.RaycastFilterType.Exclude

local function getHit(params)
	local mousePos = UserInputService:GetMouseLocation()
	local screenRay = camera:ViewportPointToRay(mousePos.X, mousePos.Y)

	ignoreParams.FilterDescendantsInstances =
		{ Players.LocalPlayer.Character, if params then table.unpack(params) else nil }

	local worldRay = workspace:Raycast(screenRay.Origin, screenRay.Direction * config.CastDistance, ignoreParams)
	return if worldRay and worldRay.Position
		then worldRay.Position
		else screenRay.Origin + screenRay.Direction * worldRay.CastDistance,
		worldRay
end

local StructureList = {}

local function snapY(vect)
	return Vector3.new(math.round((vect.X / config.Snapping)), 0, math.round((vect.Z / config.Snapping)))
			* config.Snapping
		+ Vector3.yAxis * vect.Y
end

local function makeWall(origin)
	local wall = structures.Wall:Clone()

	wall.Position = origin + Vector3.yAxis * wall.Size.Y / 2
	wall.Parent = workspace.Temp

	return wall
end

function placing:position()
	local wall = self.Part

	local mousePos, plot = getHit(self.Ignore)
	mousePos = snapY(mousePos)

	local toVect = mousePos - self.Origin

	local distance = toVect.Magnitude
	wall.Size = Vector3.new(1, 6, distance) --+ config.Snapping / 4)
	wall.CFrame = CFrame.lookAt(self.Origin + toVect / 2, mousePos) + Vector3.yAxis * 3

	self.isPlaceable = if distance >= config.Snapping and placing.CanPlace(plot) then true else false
	wall.Color = if self.isPlaceable then config.Colour.Succ else config.Colour.Err
end

function placing:place()
	self.isPlaceable = false

	local tempWall = self.Part
	self.Part = nil
	self.Origin = snapY(select(1, getHit()))

	table.remove(self.Ignore, table.find(self.Ignore, tempWall))

	tempWall.Color = Color3.fromHex("#a3a3a3")
	tempWall.CanTouch = true
	tempWall.Transparency = 0

	self.Part = makeWall(self.Origin)

	table.insert(self.Parts, self.Part)
	table.insert(self.Ignore, self.Part)
end

function StructureList:Wall()
	self.Part = makeWall(self.Origin)
	table.insert(self.Parts, self.Part)
	table.insert(self.Ignore, self.Part)

	local renderStepped = RunService.RenderStepped:Connect(function(_deltaTime)
		if not self.Part then
			return
		end

		self:position()
	end)

	local mouseClick = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if not gameProcessedEvent and input.UserInputType == Enum.UserInputType.MouseButton1 and self.isPlaceable then
			self:place()
		end
	end)

	table.insert(self.Connections, renderStepped)
	table.insert(self.Connections, mouseClick)
end

function placing.new(structure)
	local self = setmetatable({}, placing)

	self.Parts = {}
	self.Ignore = {}
	self.Connections = {}

	self.isPlaceable = false

	self.Origin = snapY(select(1, getHit()))

	StructureList[structure](self)

	return self
end

function placing.CanPlace(plot)
	plot = plot or select(2, getHit())
	return plot and plot.Instance and CollectionService:HasTag(plot.Instance, config.PlotTag)
end

function placing:Destroy()
	for _, connection in self.Connections do
		if connection then
			connection:Disconnect()
		end
	end

	for _, part in self.Ignore do
		part:Destroy()
	end

	for index in self do
		self[index] = nil
	end
end

return placing
