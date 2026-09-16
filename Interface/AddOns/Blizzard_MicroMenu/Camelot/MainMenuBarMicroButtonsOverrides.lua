function CollectionsMicroButton_CanAlertBeShown()
	return false;
end;

-- Ranks in the legacy adventure tree lower the level at which the player can start spending talents.
function PlayerSpellsMicroButtonMixin:GetTalentUnlockLevel()
	local defaultUnlockLevel = Constants.LevelConstsExposed.MIN_TALENT_LEVEL;

	local configID = C_Traits.GetConfigIDByTreeID(Constants.LegacyConsts.LEGACY_TREE_ADVENTURE_ID);
	if not configID then
		return defaultUnlockLevel;
	end

	local nodeInfo = C_Traits.GetNodeInfo(configID, Constants.LegacyConsts.LEGACY_TREE_ADVENTURE_TALENTED_NODE_ID);
	if not nodeInfo then
		return defaultUnlockLevel;
	end

	local minUnlockLevel = 1;
	return math.max(minUnlockLevel, defaultUnlockLevel - nodeInfo.activeRank);
end


function CharacterMicroButtonMixin:ShouldShowTokenFrame()
	local hasCurrencies = C_CurrencyInfo.GetCurrencyListSize() > 0;
	local shouldShow = true;
	return shouldShow, hasCurrencies;
end

