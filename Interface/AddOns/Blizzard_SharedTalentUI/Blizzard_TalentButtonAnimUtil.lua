
TalentButtonAnimUtil = {};

TalentButtonAnimUtil.TalentButtonAnimState = {
	None = 0,
	Increased = 1,
	Infinite = 2,
};

function TalentButtonAnimUtil.TalentButtonAnimationReset(pool, anim, isNew)
	if isNew then
		return;
	end
	
	anim:ResetAnim();
end
