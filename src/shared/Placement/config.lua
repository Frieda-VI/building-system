return {
	-- Placement
	KeyBind = Enum.KeyCode.P,
	PromptDiscard = function()
		print("discarding the placement")
		return true
	end,

	-- Placing
	CastDistance = 150,
	PlotTag = "Plot",
	Snapping = 4,

	Colour = { Succ = Color3.fromHex("#22c55e"), Err = Color3.fromHex("#ef4444") },
}
