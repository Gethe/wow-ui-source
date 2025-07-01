PaperDollFrameUtil = {};
PaperDollFrameUtil.Constants = {
	BaseMissChancePhysical = {
		[0] = 3.0;
		[1] = 4.5;
		[2] = 6.0;
		[3] = 7.5;
	};

	BaseMissChanceSpell = {
		[0] = 6.0;
		[1] = 9.0;
		[2] = 12.0;
		[3] = 15.0;
	};

	BaseEnemyDodgeChance = {
		[0] = 3.0;
		[1] = 4.5;
		[2] = 6.0;
		[3] = 7.5;
	};

	BaseEnemyParryChance = {
		[0] = 3.0;
		[1] = 4.5;
		[2] = 6.0;
		[3] = 7.5;
	};
};

function PaperDollFrameUtil.CanShowSpellPenetration()
	return false;
end

function PaperDollFrameUtil.CanShowPVPPower()
	return true;
end

function PaperDollFrameUtil.CanShowResistance()
	return false;
end