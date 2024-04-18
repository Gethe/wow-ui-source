StaticModelInfo = {};

function StaticModelInfo.CreateModelSceneEntry(modelSceneID, effectFileID1, effectFileID2)
	return {
		modelSceneID = modelSceneID,
		effectFileID1 = effectFileID1,
		effectFileID2 = effectFileID2,
	};
end

local function SetUpEffect(modelScene, tag, effectFileID, stopAnim)
	if not effectFileID then
		return nil;
	end
	local effectActor = modelScene:GetActorByTag(tag);
	if effectActor then
		effectActor:SetModelByFileID(effectFileID);
		if stopAnim then
			effectActor:SetAnimation(0, 0, 0, 0);
		end	
	end
	return effectActor;
end

function StaticModelInfo.SetupModelScene(modelScene, modelSceneInfo, forceUpdate, stopAnim)
	modelScene:SetFromModelSceneID(modelSceneInfo.modelSceneID, forceUpdate);
	return
		SetUpEffect(modelScene, "effect", modelSceneInfo.effectFileID1, stopAnim),
		SetUpEffect(modelScene, "effect2", modelSceneInfo.effectFileID2, stopAnim);
end