
----------------- Embedded Model Preview Mixin -----------------
local ActorTag = "decor";

HousingModelPreviewMixin = {};

function HousingModelPreviewMixin:OnLoad()
	local forceSceneChange = true;
	self.ModelScene:TransitionToModelSceneID(Constants.HousingCatalogConsts.HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);
	self.ModelSceneControls:SetModelScene(self.ModelScene);

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
		end, nil, "ANCHOR_LEFT");

	self:SetupTextTooltip(self.TextContainer.NumOwned, 
		function(tooltip) 
			local isBaseVariant = not self.variantInfo or self.variantInfo.entryVariantID.variantIdentifier == 0;
			if isBaseVariant then
				local numStored = Blizzard_HousingCatalogUtil.GetEntryNumStored(self.catalogEntryInfo);
				GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_PLACED_TOOLTIP:format(self.catalogEntryInfo.totalNumPlaced));
				GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_STORAGE_TOOLTIP:format(numStored));
			else
				local totalOwned = Blizzard_HousingCatalogUtil.GetEntryTotalOwned(self.catalogEntryInfo);
				GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_VARIANT_DYED_COUNT_TOOLTIP:format(self.variantInfo.numStored));
				GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_VARIANT_TOTAL_OWNED_TOOLTIP:format(totalOwned));
			end
		end, nil, "ANCHOR_LEFT", GameNoHeaderTooltip);

	self.VariantLeftButton:SetScript("OnClick",
		function()
			self:CycleVariant(-1);
		end);

	self.VariantRightButton:SetScript("OnClick",
		function()
			self:CycleVariant(1);
		end);

	self:SetupTextTooltip(self.VariantLeftButton,
		function(tooltip)
			GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_VARIANT_CYCLE_TOOLTIP);
		end, nil, "ANCHOR_LEFT");

	self:SetupTextTooltip(self.VariantRightButton,
		function(tooltip)
			GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_VARIANT_CYCLE_TOOLTIP);
		end);

	self:SetupTextTooltip(self.TextContainer.DyeDisplay, function(tooltip)
		local dyeNames = self:GetCurrentDyeNames();
		if dyeNames then
			GameTooltip_AddHighlightLine(tooltip, HOUSING_DECOR_DYE_LIST:format(dyeNames));
		end
	end, nil, "ANCHOR_LEFT");
end

function HousingModelPreviewMixin:PreviewCatalogEntryInfo(catalogEntryInfo, variantInfo)
	self:ClearPreviewData();

	self.catalogEntryInfo = catalogEntryInfo;

	local entryID = { recordID = catalogEntryInfo.recordID, entryType = catalogEntryInfo.entryType };
	self.allVariantInfos = self:GetSortedVariantInfosWithBase(entryID);
	self.currentVariantIndex = self:FindVariantIndex(variantInfo) or 1;
	self.variantInfo = self.allVariantInfos[self.currentVariantIndex];

	self:ApplyCurrentVariant();
end

function HousingModelPreviewMixin:GetSortedVariantInfosWithBase(entryID)
	local variantInfos = C_HousingCatalog.GetAllVariantInfosForEntry(entryID);

	local hasBase = false;
	for i, info in ipairs(variantInfos) do
		if info.entryVariantID.variantIdentifier == 0 then
			hasBase = true;
			break;
		end
	end

	if not hasBase then
		table.insert(variantInfos, {
			entryVariantID = {
				recordID = entryID.recordID,
				entryType = entryID.entryType,
				variantIdentifier = 0,
			},
			numStored = 0,
			dyeSlots = {},
		});
	end

	-- Ensure a consistent ordering with the base variant first.
	table.sort(variantInfos, function(a, b)
		return a.entryVariantID.variantIdentifier < b.entryVariantID.variantIdentifier;
	end);

	return variantInfos;
end

function HousingModelPreviewMixin:FindVariantIndex(variantInfo)
	if not variantInfo then
		return nil;
	end

	for i, info in ipairs(self.allVariantInfos) do
		if info.entryVariantID.variantIdentifier == variantInfo.entryVariantID.variantIdentifier then
			return i;
		end
	end

	return nil;
end

function HousingModelPreviewMixin:CycleVariant(direction)
	if not self.allVariantInfos or #self.allVariantInfos <= 1 then
		return;
	end

	local newIndex = self.currentVariantIndex + direction;
	if newIndex < 1 or newIndex > #self.allVariantInfos then
		return;
	end

	self.currentVariantIndex = newIndex;
	self.variantInfo = self.allVariantInfos[self.currentVariantIndex];
	self:ApplyCurrentVariant();
end

function HousingModelPreviewMixin:UpdateVariantButtons()
	local numVariants = self.allVariantInfos and #self.allVariantInfos or 0;
	local showButtons = numVariants > 1;
	self.VariantLeftButton:SetShown(showButtons and self.currentVariantIndex > 1);
	self.VariantRightButton:SetShown(showButtons and self.currentVariantIndex < numVariants);
end

function HousingModelPreviewMixin:GetCurrentDyeNames()
	if not self.variantInfo then
		return nil;
	end

	local names = {};
	for i, dyeSlotEntry in ipairs(self.variantInfo.dyeSlots) do
		if dyeSlotEntry.dyeColorID then
			local dyeColorInfo = C_DyeColor.GetDyeColorInfo(dyeSlotEntry.dyeColorID);
			if dyeColorInfo and dyeColorInfo.name then
				table.insert(names, dyeColorInfo.name);
			end
		end
	end

	if #names > 0 then
		return table.concat(names, ", ");
	end

	return nil;
end

function HousingModelPreviewMixin:ApplyCurrentVariant()
	local catalogEntryInfo = self.catalogEntryInfo;

	if catalogEntryInfo.asset then
		local modelSceneID = catalogEntryInfo.uiModelSceneID or Constants.HousingCatalogConsts.HOUSING_CATALOG_DECOR_MODELSCENEID_DEFAULT;
		local forceSceneChange = not self.lastAppliedRecordID or (self.lastAppliedRecordID ~= catalogEntryInfo.recordID);
		self.lastAppliedRecordID = catalogEntryInfo.recordID;
		self.ModelScene:TransitionToModelSceneID(modelSceneID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_DISCARD, forceSceneChange);

		local actor = self.ModelScene:GetActorByTag(ActorTag);
		if actor then
			actor:SetPreferModelCollisionBounds(true);
			actor:SetModelByFileID(catalogEntryInfo.asset);

			local dyeColorsByChannel = {};
			local dyeSlots = self.variantInfo and self.variantInfo.dyeSlots or {};
			for i, dyeSlotEntry in ipairs(dyeSlots) do
				if dyeSlotEntry.dyeColorID then
					dyeColorsByChannel[dyeSlotEntry.channel] = dyeSlotEntry.dyeColorID;
				end
			end
			actor:SetGradientMaskWithDyes(dyeColorsByChannel[0], dyeColorsByChannel[1], dyeColorsByChannel[2]);
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

	local isBaseVariant = not self.variantInfo or self.variantInfo.entryVariantID.variantIdentifier == 0;

	self:SetTextOrHide(self.TextContainer.SourceInfo, isBaseVariant and catalogEntryInfo.sourceText or nil);
	self.TextContainer.CollectionBonus:SetShown(isBaseVariant and catalogEntryInfo.firstAcquisitionBonus > 0);

	local dyeSlots = self.variantInfo and self.variantInfo.dyeSlots or {};
	local showDyeDisplay = not isBaseVariant and #dyeSlots > 0;
	self.TextContainer.DyesLabel:SetShown(showDyeDisplay);
	if showDyeDisplay then
		self.TextContainer.DyeDisplay:UpdateDyeSlots(dyeSlots);
	else
		self.TextContainer.DyeDisplay:SetNumDyeIconsShown(0);
	end

	local displayCount = isBaseVariant and Blizzard_HousingCatalogUtil.GetEntryTotalOwned(catalogEntryInfo) or self.variantInfo.numStored;
	local displayCountText = displayCount > 0 and HOUSING_DECOR_OWNED_ICON_FMT:format(displayCount) or nil;
	self:SetTextOrHide(self.TextContainer.NumOwned, displayCountText);

	-- We have dynamic anchors so we need to fix the width before layout to allow children to properly expand.
	self.TextContainer:SetFixedWidth(self.TextContainer:GetWidth());
	self.TextContainer:Layout();

	self:UpdateVariantButtons();
end

function HousingModelPreviewMixin:ClearPreviewData()
	self.catalogEntryInfo = nil;
	self.variantInfo = nil;
	self.allVariantInfos = nil;
	self.currentVariantIndex = nil;
	self.lastAppliedRecordID = nil;

	self.VariantLeftButton:Hide();
	self.VariantRightButton:Hide();

	local actor = self.ModelScene:GetActorByTag(ActorTag);
	if actor then
		actor:ClearModel();
	end
end

function HousingModelPreviewMixin:HasValidData()
	return self.catalogEntryInfo ~= nil;
end

function HousingModelPreviewMixin:SetupTextTooltip(fontString, textSetFunc, shouldShowFunc, overrideAnchor, overrideTooltip)
	local tooltip = overrideTooltip or GameTooltip;
	fontString:SetScript("OnEnter", function()
		-- If have data, and conditional check is nil or passing
		if self:HasValidData() and ((not shouldShowFunc) or (shouldShowFunc())) then
			tooltip:SetOwner(fontString, overrideAnchor or "ANCHOR_RIGHT", 0, 0);
			textSetFunc(tooltip);
			tooltip:Show();
		end
	end);
	fontString:SetScript("OnLeave", function()
		tooltip:Hide();
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
	ButtonFrameTemplate_HidePortrait(self);
	ButtonFrameTemplate_HideAttic(self);
	self:SetTitle(PREVIEW);
end

function HousingModelPreviewFrameMixin:ShowCatalogEntryInfo(catalogEntryInfo, variantInfo)
	self.ModelPreview:PreviewCatalogEntryInfo(catalogEntryInfo, variantInfo);
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