function widget:GetInfo()
  return {
	name      = "Game Speed",
	desc      = "Overrides increasing/decreasing game speed behaviour",
	author    = "Beherith",
	date      = "2020",
	layer     = -math.huge,
	enabled   = true,
  }
end

-- The number of speed gradations should be minimized,
-- while maintaining suitable fine control around normal (1×) speed
local speedLevels = {
	0.1,
	0.5,
	0.8,
	1,
	1.5,
	2,
	5,
	10,
	20,
	100,
	1000
}

local function setGameSpeed(speed)
	Spring.SendCommands("setspeed " .. speed)
end

local function increaseSpeed()
	local currentSpeed = Spring.GetGameSpeed()

	if currentSpeed >= speedLevels[#speedLevels] then
		return
	end

	local i = 1
	while speedLevels[i] <= currentSpeed do
		i = i + 1
	end

	setGameSpeed(speedLevels[i])
end

local function decreaseSpeed()
	local currentSpeed = Spring.GetGameSpeed()

	if currentSpeed <= speedLevels[1] then
		return
	end

	local i = #speedLevels
	while speedLevels[i] >= currentSpeed do
		i = i - 1
	end

	setGameSpeed(speedLevels[i])
end

function widget:Initialize()
	widgetHandler:AddAction("increasespeed", increaseSpeed, nil, 'pR')
	widgetHandler:AddAction("decreasespeed", decreaseSpeed, nil, 'pR')
end
