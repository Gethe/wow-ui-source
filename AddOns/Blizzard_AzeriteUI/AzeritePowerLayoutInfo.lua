local BASE_ROTATION_OFFSET = math.pi / 2;

local DEFAULT_FOUR_POWERS = {
	0.94579392,
	-0.94579392,
	2.54329379,
	-2.54329379,
};

local DEFAULT_THREE_POWERS = {
	1.07617,
	-1.07617,
	math.pi,
};

local DEFAULT_TWO_POWERS = {
	math.pi / 2,
	-math.pi / 2,
};

local LAYOUT_TIER_INFO = {
	-- Outer most to inner most ring
	{ 
		radius = 251,
		startRadians = 
		{
			default = math.pi / 4,

			[2] = DEFAULT_TWO_POWERS,
			[3] = {
				0.94579392,
				-0.94579392,
				math.pi,
			};
			[4] = DEFAULT_FOUR_POWERS,
			[5] = {
				0.94579392,
				-0.94579392,
				2.22843639,
				-2.22843639,
				math.pi,
			},
		},
	},
	{ 
		radius = 178, 
		startRadians = 
		{
			default = math.pi / 2.5,

			[2] = DEFAULT_TWO_POWERS,
			[3] = DEFAULT_THREE_POWERS,
			[4] = DEFAULT_FOUR_POWERS,
			[5] = {
				0.94579392,
				-0.94579392,
				2.47557501,
				-2.47557501,
				math.pi,
			}
		},
	},
	{ 
		radius = 105, 
		startRadians = 
		{
			default = math.pi / 2,

			[2] = DEFAULT_TWO_POWERS,
		},
	},
	{ 
		radius = -2, 
		startRadians = 
		{
			default = 0.0,
		},
	},
}

local function GetLayoutInfo(tierIndex)
	local layoutInfo = LAYOUT_TIER_INFO[tierIndex];
	if not layoutInfo then
		error(("Unknown tier index: %s"):format(tostring(tierIndex)), 2);
	end

	return layoutInfo;
end

AzeriteLayoutInfo = {};

function AzeriteLayoutInfo.CalculatePowerOffset(powerIndex, numPowers, tierIndex)
	local layoutInfo = GetLayoutInfo(tierIndex);

	local overrideRads = layoutInfo.startRadians[numPowers] and layoutInfo.startRadians[numPowers][powerIndex];
	local startRadians = layoutInfo.startRadians.default;
	local angleRads = overrideRads or Lerp(startRadians, 2 * math.pi - startRadians, PercentageBetween(powerIndex, 1, numPowers));
	return CreateVector2D(math.cos(BASE_ROTATION_OFFSET + angleRads) * layoutInfo.radius, math.sin(BASE_ROTATION_OFFSET + angleRads) * layoutInfo.radius), angleRads;
end

function AzeriteLayoutInfo.CalculatePlugOffset(tierIndex)
	local layoutInfo = GetLayoutInfo(tierIndex);
	return CreateVector2D(0.0, layoutInfo.radius);
end