----------------- Embedded Model Preview Mixin -----------------
local ActorTag = "decor";

HousingModelPreviewMixin = {};

function HousingModelPreviewMixin:OnLoad()
	local forceSceneChange = true;
	self.ModelScene:TransitionToModelSceneID(Constants.HousingCatalogConsts.HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);
	self.ModelSceneControls:SetModelScene(self.ModelScene);
	self.TextContainer.fixedWidth = self.TextContainer:GetWidth();

	self:SetupTextTooltip(self.NameContainer.Name, 
		function(tooltip) 
			local wrap = false; 
			GameTooltip_SetTitle(tooltip, self.catalogEntryInfo.name, nil, wrap); 
		end,
		function() return self.NameContainer.Name:IsTruncated(); end,
		"ANCHOR_CURSOR");

	self:SetupTextTooltip(self.NameContainer.PlacementCost, 
		function(tooltip) 
			GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_PLACEMENT_COST_TOOLTIP);
		end);

	self:SetupTextTooltip(self.TextContainer.CollectionBonus, 
		function(tooltip) 
			GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_FIRST_ACQUISITION_FORMAT:format(self.catalogEntryInfo.firstAcquisitionBonus));
		end);

	self:SetupTextTooltip(self.TextContainer.NumOwned, 
		function(tooltip) 
			GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_OWNED_ICON_TOOLTIP:format(self.catalogEntryInfo.numPlaced, self.catalogEntryInfo.numStored));
		end);
end

function HousingModelPreviewMixin:PreviewCatalogEntryInfo(catalogEntryInfo)
	self:ClearPreviewData();

	self.catalogEntryInfo = catalogEntryInfo;

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
	
	self.NameContainer.Name:SetText(catalogEntryInfo.name);
	self.NameContainer.PlacementCost:SetText(HOUSING_DECOR_PLACEMENT_COST_FORMAT:format(catalogEntryInfo.placementCost));
	self.NameContainer:MarkDirty();

	self:SetTextOrHide(self.TextContainer.SourceInfo, catalogEntryInfo.sourceText);

	self.TextContainer.CollectionBonus:SetShown(catalogEntryInfo.firstAcquisitionBonus > 0);

	local totalOwned = catalogEntryInfo.numPlaced + catalogEntryInfo.numStored;
	local totalOwnedText = totalOwned > 0 and HOUSING_DECOR_OWNED_ICON_FMT:format(totalOwned) or nil;
	self:SetTextOrHide(self.TextContainer.NumOwned, totalOwnedText);

	self.TextContainer:Layout();
end

function HousingModelPreviewMixin:ClearPreviewData()
	self.catalogEntryInfo = nil;

	local actor = self.ModelScene:GetActorByTag(ActorTag);
	if actor then
		actor:ClearModel();
	end
end

function HousingModelPreviewMixin:HasValidData()
	return self.catalogEntryInfo ~= nil;
end

function HousingModelPreviewMixin:SetupTextTooltip(fontString, textSetFunc, shouldShowFunc, overrideAnchor)
	fontString:SetScript("OnEnter", function()
		-- If have data, and conditional check is nil or passing
		if self:HasValidData() and ((not shouldShowFunc) or (shouldShowFunc())) then
			GameTooltip:SetOwner(fontString, overrideAnchor or "ANCHOR_RIGHT", 0, 0);
			textSetFunc(GameTooltip);
			GameTooltip:Show();
		end
	end);
	fontString:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);
end

function HousingModelPreviewMixin:SetTextOrHide(fontString, text)
	if text and text ~= "" then
		fontString:SetText(text);
		fontString:Show();
	else
		fontString:Hide();
	end
end

----------------- Standalone Container Mixin -----------------

HousingModelPreviewFrameMixin = {};

function HousingModelPreviewFrameMixin:OnLoad()
	self:SetParent(GetAppropriateTopLevelParent());
	ButtonFrameTemplate_HidePortrait(self);
	ButtonFrameTemplate_HideAttic(self);
	self:SetTitle(PREVIEW);
end

function HousingModelPreviewFrameMixin:ShowCatalogEntryInfo(catalogEntryInfo)
	self.ModelPreview:PreviewCatalogEntryInfo(catalogEntryInfo);
	if not self:IsShown() then
		ShowUIPanel(self);
	end
end

function HousingModelPreviewFrameMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function HousingModelPreviewFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end