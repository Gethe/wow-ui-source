PaperDollFrameUtil = {};
PaperDollFrameUtil.Constants = {
	BaseMissChancePhysical = {
		[0] = 5.0;
		[1] = 5.5;
		[2] = 6.0;
		[3] = 8.0;
	};

	BaseMissChanceSpell = {
		[0] = 4.0;
		[1] = 5.0;
		[2] = 6.0;
		[3] = 17.0;
	};

	BaseEnemyDodgeChance = {
		[0] = 5.0;
		[1] = 5.5;
		[2] = 6.0;
		[3] = 6.5;
	};

	BaseEnemyParryChance = {
		[0] = 5.0;
		[1] = 5.5;
		[2] = 6.0;
		[3] = 14.0;
	};
};

function PaperDollFrameUtil.CanShowSpellPenetration()
	return true;
end

function PaperDollFrameUtil.CanShowPVPPower()
	return false;
end

function PaperDollFrameUtil.CanShowResistance()
	return true;
end