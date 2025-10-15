local ActorTag = "decor";

HousingModelPreviewMixin = {};

function HousingModelPreviewMixin:OnLoad()
	local forceSceneChange = true;
	self.ModelScene:TransitionToModelSceneID(Constants.HousingCatalogConsts.HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);
	self.ModelSceneControls:SetModelScene(self.ModelScene);
end

function HousingModelPreviewMixin:PreviewCatalogEntryInfo(catalogEntryInfo)
	self:ClearPreviewData();
	
	-- TODO: Fully implement Preview frame with decor info
	self.Name:SetText(catalogEntryInfo.name);

	if catalogEntryInfo.asset then
		local modelSceneID = catalogEntryInfo.uiModelSceneID or Constants.HousingCatalogConsts.HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT;
		local forceSceneChange = true;
		self.ModelScene:TransitionToModelSceneID(modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);

		local actor = self.ModelScene:GetActorByTag(ActorTag);
		if actor then
			actor:SetPreferModelCollisionBounds(true);
			actor:SetModelByFileID(catalogEntryInfo.asset);
		end

		self.ModelScene:Show();
		self.ModelSceneControls:Show();
		self.PreviewUnavailableText:Hide();
	else
		self.ModelScene:Hide();
		self.ModelSceneControls:Hide();
		self.PreviewUnavailableText:Show();
	end
end

function HousingModelPreviewMixin:ClearPreviewData()
	local actor = self.ModelScene:GetActorByTag(ActorTag);
	if actor then
		actor:ClearModel();
	end
end
