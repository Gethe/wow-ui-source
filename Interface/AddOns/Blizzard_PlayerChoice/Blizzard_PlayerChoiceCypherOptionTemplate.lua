PlayerChoiceCypherOptionTemplateMixin = {};

local animationInfos =
{
	Pixels1 = 
	{
		baseDuration = 13,
		durationDiff = 4,
		XOfs = 0,
		YOfs = 250,
	},
	Pixels2 = 
	{
		baseDuration = 8,
		durationDiff = 3,
		XOfs = 0,
		YOfs = 250,
	},
	ArtworkPixels = 
	{
		baseDuration = 8,
		durationDiff = 0,
		XOfs = 0,
		YOfs = 250,
	},
	Wisps = 
	{
		baseDuration = 13,
		durationDiff = 4,
		XOfs = 0,
		YOfs = 500,
	},
	Wisps2 = 
	{
		baseDuration = 20,
		durationDiff = 4,
		XOfs = 0,
		YOfs = 500,
	},
};

function PlayerChoiceCypherOptionTemplateMixin:CypherChoiceOnLoad()
	local function GetRandomDelay()
		-- Random delay between 0s and 1s
		return math.random();
	end

	-- Set up animations with variable durations and delays so that not all options' animations are in-sync
	for asset, info in pairs(animationInfos) do
		local newGroup = self:CreateAnimationGroup();
		newGroup:SetLooping("REPEAT");
		table.insert(self.PassiveAnimations, newGroup);

		local newAnim = newGroup:CreateAnimation("Translation");
		newAnim:SetTarget(self[asset]);
		local duration = math.random(info.baseDuration - info.durationDiff, info.baseDuration + info.durationDiff);
		newAnim:SetDuration(duration);
		local delay = GetRandomDelay();
		newAnim:SetStartDelay(delay);
		newAnim:SetOffset(info.XOfs, info.YOfs);
	end
end