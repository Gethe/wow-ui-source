StaticModelInfo = {};

function StaticModelInfo.CreateModelSceneEntry(modelSceneID, effectFileID)
	return {
		modelSceneID = modelSceneID,
		effectFileID = effectFileID,
	};
end

function StaticModelInfo.SetupModelScene(modelScene, modelSceneInfo, forceUpdate)
	modelScene:SetFromModelSceneID(modelSceneInfo.modelSceneID, forceUpdate);
	local effectActor = modelScene:GetActorByTag("effect");
	if effectActor then
		effectActor:SetModelByFileID(modelSceneInfo.effectFileID);
	end
	return effectActor;
end