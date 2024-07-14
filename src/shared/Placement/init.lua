local UserInputService = game:GetService("UserInputService")

local placement = {}

local config = require(script.config)
local placing = require(script.placing)

placement.isPlacing = false

function placement.Place() end

function placement.initPlacement()
	if not placing.CanPlace() then
		return
	end

	placement.isPlacing = true
	placement.placeObj = placing.new("Wall")
end

function placement.exitPlacement()
	placement.isPlacing = false
	if placement.placeObj then
		placement.placeObj:Destroy()
	end
	placement.placeObj = nil
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	if gameProcessedEvent or input.KeyCode ~= config.KeyBind then
		return
	end

	if placement.isPlacing and config.PromptDiscard() then
		placement.exitPlacement()
		return
	end

	placement.initPlacement()
end)

return placement
