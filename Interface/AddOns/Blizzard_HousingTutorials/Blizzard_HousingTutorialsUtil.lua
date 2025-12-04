HousingTutorialUtil = {};

-- Doing this via string lookup to avoid dependency on load of the HouseFinder
function HousingTutorialUtil.GetFrameFromData(framePath)
	local frames = { strsplit(".", framePath) };

	if #frames == 0 then
		return nil;
	end

	local currFrame = _G[frames[1]];
	if not currFrame then
		return nil;
	end

	for i, frame in ipairs(frames) do
		if i ~= 1 then
			currFrame = currFrame[frame];

			if not currFrame then
				return nil;
			end
		end
	end

	return currFrame;
end

function HousingTutorialUtil.ResetAllDecorTutorials(includeQuestTutorials)
	if includeQuestTutorials then
		SetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingDecorPlace, false);
		SetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingDecorCleanup, false);
	end

	SetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingDecorClippingGrid, false);
	SetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingMarketTab, false);
	SetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingDecorCustomization, false);
	SetCVarBitfield(HOUSING_TUTORIAL_CVAR_BITFIELD, Enum.FrameTutorialAccount.HousingDecorLayout, false);
end

function HousingTutorialUtil.HousingQuestTutorialComplete()
	return (not C_CVar.GetCVarBool("housingTutorialsEnabled")) or
		(C_QuestLog.IsQuestFlaggedCompletedOnAccount(HousingTutorialQuestIDs.CleanupQuest) and
		C_QuestLog.IsQuestFlaggedCompletedOnAccount(HousingTutorialQuestIDs.DecorateQuest));
end

function HousingTutorialUtil.BoughtHouseQuestComplete()
	return (not C_CVar.GetCVarBool("housingTutorialsEnabled")) or
		C_QuestLog.IsQuestFlaggedCompletedOnAccount(HousingTutorialQuestIDs.BoughtHouseQuest);
end

function HousingTutorialUtil.IsModeValidForTutorial(mode)
	return mode ~= Enum.HouseEditorMode.ExpertDecor and
		mode ~= Enum.HouseEditorMode.Customize and
		mode ~= Enum.HouseEditorMode.Cleanup and
		mode ~= Enum.HouseEditorMode.Layout and
		mode ~= Enum.HouseEditorMode.ExteriorCustomization;
end
