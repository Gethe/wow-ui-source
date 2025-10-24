local ActorTag = "decor";

HousingModelPreviewMixin = {};

function HousingModelPreviewMixin:OnLoad()
	local forceSceneChange = true;
	self.ModelScene:TransitionToModelSceneID(Constants.HousingCatalogConsts.HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);
	self.ModelSceneControls:SetModelScene(self.ModelScene);
	self.TextContainer.fixedWidth = self.TextContainer:GetWidth();

	self.NameContainer.Name:SetScript("OnEnter", function()
		-- If name text is truncated, show the full name on hovering it
		if self.NameContainer.Name:IsTruncated() then
			GameTooltip:SetOwner(self.NameContainer.Name, "ANCHOR_CURSOR", 0, 0);
			local wrap = false;
			GameTooltip_SetTitle(GameTooltip, self.catalogEntryInfo.name, nil, wrap);
			GameTooltip:Show();
		end
	end);
	self.NameContainer.Name:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);

	self.NameContainer.PlacementCost:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.NameContainer.PlacementCost, "ANCHOR_RIGHT", 0, 0);
		GameTooltip_AddHighlightLine(GameTooltip, HOUSING_DECOR_PLACEMENT_COST_TOOLTIP);
		GameTooltip:Show();
	end);
	self.NameContainer.PlacementCost:SetScript("OnLeave", function()
		GameTooltip:Hide();
	end);

	self.TextContainer.NumOwned:SetScript("OnEnter", function()
		if self.catalogEntryInfo then
			local ownedText = HOUSING_DECOR_OWNED_ICON_TOOLTIP:format(self.catalogEntryInfo.numPlaced, self.catalogEntryInfo.numStored);
			GameTooltip:SetOwner(self.TextContainer.NumOwned, "ANCHOR_RIGHT", 0, 0);
			GameTooltip_AddHighlightLine(GameTooltip, ownedText);
			GameTooltip:Show();
		end
		
	end);
	self.TextContainer.NumOwned:SetScript("OnLeave", function()
		GameTooltip:Hide();
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

	local bonusText = catalogEntryInfo.firstAcquisitionBonus > 0 and HOUSING_DECOR_FIRST_ACQUISITION_FORMAT:format(catalogEntryInfo.firstAcquisitionBonus) or nil;
	self:SetTextOrHide(self.TextContainer.CollectionBonus, bonusText);

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

function HousingModelPreviewMixin:SetTextOrHide(fontString, text)
	if text and text ~= "" then
		fontString:SetText(text);
		fontString:Show();
	else
		fontString:Hide();
	end
end
