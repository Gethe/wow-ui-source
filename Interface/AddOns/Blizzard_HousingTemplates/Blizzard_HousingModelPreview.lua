local ModelSceneID = 691;
local ActorTag = "decor";

HousingModelPreviewMixin = {};

function HousingModelPreviewMixin:OnLoad()
	local forceSceneChange = true;
	self.ModelScene:TransitionToModelSceneID(ModelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN, forceSceneChange);
end

function HousingModelPreviewMixin:PreviewCatalogEntryInfo(catalogEntryInfo)
	self:ClearPreviewData();
	
	-- TODO: Fully implement Preview frame with decor info
	self.Name:SetText(catalogEntryInfo.name);

	if catalogEntryInfo.asset then
		local actor = self.ModelScene:GetActorByTag(ActorTag);
		if actor then
			actor:SetModelByFileID(catalogEntryInfo.asset);
		end
	end
end

function HousingModelPreviewMixin:ClearPreviewData()
	local actor = self.ModelScene:GetActorByTag(ActorTag);
	if actor then
		actor:ClearModel();
	end
end
