local function CreateModelSceneEntry(modelSceneID, effectFileID)
	return {
		modelSceneID = modelSceneID,
		effectFileID = effectFileID,
	};
end

AzeriteModelInfo = {};

AzeriteModelInfo.ModelSceneTypePowerClick = 1;
AzeriteModelInfo.ModelSceneTypePowerLockedIn = 2;
AzeriteModelInfo.ModelSceneTypeFinalPowerLockedIn = 3;
AzeriteModelInfo.ModelSceneTypePowerReadyForSelection = 4;

local MODEL_SCENE_INFO = {
	[AzeriteModelInfo.ModelSceneTypePowerClick] = CreateModelSceneEntry(219, 1983548), -- 8FX_AZERITE_GENERIC_NOVAHIGH_BASE
	[AzeriteModelInfo.ModelSceneTypePowerLockedIn] = CreateModelSceneEntry(221, 2101307), -- 8FX_AZERITE_ABSORBCURRENCY_LARGE_IMPACTBASE
	[AzeriteModelInfo.ModelSceneTypeFinalPowerLockedIn] = CreateModelSceneEntry(223, 2101307), -- 8FX_AZERITE_ABSORBCURRENCY_LARGE_IMPACTBASE
	[AzeriteModelInfo.ModelSceneTypePowerReadyForSelection] = CreateModelSceneEntry(222, 1983980), -- 8FX_AZERITE_EMPOWER_STATECHEST
};

function AzeriteModelInfo.SetupModelScene(modelScene, modelSceneType, forceUpdate)
	local modelSceneInfo = MODEL_SCENE_INFO[modelSceneType];
	if not modelSceneInfo then
		error(("Unknown model scene type: %s"):format(tostring(modelSceneType)), 2);
	end

	modelScene:SetFromModelSceneID(modelSceneInfo.modelSceneID, forceUpdate);
	local effectActor = modelScene:GetActorByTag("effect");
	if effectActor then
		effectActor:SetModelByFileID(modelSceneInfo.effectFileID);
	end
	return effectActor;
end