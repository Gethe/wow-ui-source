HousingBlueprintContentEntryMixin = {};

function HousingBlueprintContentEntryMixin:Init(node, isReadonly)
	local entryData = node:GetData();
	self.entryData = entryData;
	self.isReadonly = isReadonly;

	if entryData.total == 1 then
		self.CountText:SetText("");
	else
		if isReadonly then
			self.CountText:SetText(HOUSING_BLUEPRINT_CONTENT_ENTRY_COUNT_FMT:format(entryData.total));
		else
			local numAvailable = 0;
			if not entryData.invalid then
				numAvailable = entryData.total - entryData.numMissing;
			end
			self.CountText:SetText(HOUSING_BLUEPRINT_CONTENT_ENTRY_COUNT_COMPARE_FMT:format(numAvailable, entryData.total));
		end
	end
	self.NameText:SetText(entryData.name);

	local isAvailable = isReadonly or (not entryData.invalid and entryData.numMissing == 0);
	local textColor = isAvailable and HIGHLIGHT_FONT_COLOR or DISABLED_FONT_COLOR;
	self.NameText:SetTextColor(textColor:GetRGBA());
	self.CountText:SetTextColor(textColor:GetRGBA());

	if self.entryData.contentType == Enum.HousingBlueprintContentType.Room or self.entryData.contentType == Enum.HousingBlueprintContentType.Decor then
		local catalogEntryType = self.entryData.contentType == Enum.HousingBlueprintContentType.Room and Enum.HousingCatalogEntryType.Room or Enum.HousingCatalogEntryType.Decor;
		self.catalogInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(catalogEntryType, self.entryData.recordID);
		if self.catalogInfo then
			self.catalogInfo.entryID = { recordID = self.catalogInfo.recordID, entryType = self.catalogInfo.entryType };
			self.catalogInfo.variants = C_HousingCatalog.GetAllVariantInfosForEntry(self.catalogInfo.entryID);
		end
	end
end

function HousingBlueprintContentEntryMixin.Reset(framePool, self)
	self.entryData = nil;
	self.catalogInfo = nil;
	self.isReadonly = nil;
	self.HighlightBackground:Hide();
	Pool_HideAndClearAnchors(framePool, self);
end

function HousingBlueprintContentEntryMixin:OnClick()
	if not self.entryData then
		return;
	end

	if IsModifiedClick("CHATLINK") and ChatFrameUtil.GetActiveWindow() then
		if self.entryData.contentType == Enum.HousingBlueprintContentType.Decor then
			local decorLink = C_HousingDecor.GetDecorHyperlink(self.entryData.recordID);
			ChatFrameUtil.InsertLink(decorLink);
		elseif self.entryData.contentType == Enum.HousingBlueprintContentType.Dye then
			local itemLink = select(2, C_Item.GetItemInfo(self.entryData.recordID));
			ChatFrameUtil.InsertLink(itemLink);
		end
	elseif IsModifiedClick("DRESSUP") then
		if self.entryData.contentType == Enum.HousingBlueprintContentType.Decor then
			HousingFramesUtil.PreviewHousingDecorID(self.entryData.recordID);
		end
	elseif ContentTrackingUtil.IsTrackingModifierDown() then
		if self.entryData.contentType == Enum.HousingBlueprintContentType.Decor then
			Blizzard_HousingCatalogUtil.TrackHousingDecorID(self.entryData.recordID);
			-- Update tooltip after tracking click since that changes the text
			if GameTooltip:GetOwner() == self then
				self:OnEnter();
			end
		end
	end
end

function HousingBlueprintContentEntryMixin:OnEnter()
	if not self.entryData then
		return;
	end
	self.HighlightBackground:Show();

	local tooltip = GameTooltip;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:AddTypeSpecificTooltipTitle(tooltip);

	local hasTooltip = self:TryAddTypeSpecificTooltipLines(tooltip);

	if hasTooltip then
		GameTooltip:Show();
	else
		GameTooltip:Hide();
	end
end

function HousingBlueprintContentEntryMixin:OnLeave()
	if not self.entryData then
		return;
	end
	self.HighlightBackground:Hide();

	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end

function HousingBlueprintContentEntryMixin:AddTypeSpecificTooltipTitle(tooltip)
	local wrap = false;
	if self.entryData.contentType == Enum.HousingBlueprintContentType.Room and self.catalogInfo then
		local placementCost = HOUSING_ROOM_PLACEMENT_COST_FORMAT:format(self.catalogInfo.placementCost);
		local itemQualityColor = ColorManager.GetColorDataForItemQuality(self.catalogInfo.quality or Enum.ItemQuality.Common).color;
		GameTooltip_AddColoredDoubleLine(tooltip, self.entryData.name, placementCost, itemQualityColor, HIGHLIGHT_FONT_COLOR, wrap);
	elseif self.entryData.contentType == Enum.HousingBlueprintContentType.Decor and self.catalogInfo then
		local placementCost = HOUSING_DECOR_PLACEMENT_COST_FORMAT:format(self.catalogInfo.placementCost);
		local itemQualityColor = ColorManager.GetColorDataForItemQuality(self.catalogInfo.quality or Enum.ItemQuality.Common).color;
		GameTooltip_AddColoredDoubleLine(tooltip, self.entryData.name, placementCost, itemQualityColor, HIGHLIGHT_FONT_COLOR, wrap);
	else
		GameTooltip_SetTitle(tooltip, self.entryData.name, nil, wrap);
	end
end

function HousingBlueprintContentEntryMixin:TryAddTypeSpecificTooltipLines(tooltip)
	if self.entryData.contentType == Enum.HousingBlueprintContentType.HouseType then
		if self.entryData.tooltip then
			if self.entryData.invalid or self.entryData.numMissing > 0 then
				GameTooltip_AddErrorLine(tooltip, self.entryData.tooltip);
			else
				GameTooltip_AddNormalLine(tooltip, self.entryData.tooltip);
			end
			return true;
		end
	elseif self.entryData.contentType == Enum.HousingBlueprintContentType.Room then
		if self.catalogInfo and self.catalogInfo.isPrefab then
			GameTooltip_AddHighlightLine(tooltip, HOUSING_LAYOUT_PREFAB_ROOM_TOOLTIP);
		end
		if self.entryData.numMissing > 0 then
			GameTooltip_AddErrorLine(tooltip, ERR_HOUSING_BLUEPRINT_REQUIREMENT_ROOM_UNCOLLECTED);
		end
		-- Even without content, we want to at least show room's name and cost as tooltip title
		return true;
	elseif self.entryData.contentType == Enum.HousingBlueprintContentType.Decor then
		if not self.catalogInfo then
			GameTooltip_AddDisabledLine(tooltip, ERR_HOUSING_BLUEPRINT_CONTENT_ENTRY_INVALID);
			return true;
		end

		local totalPlaced = self.catalogInfo.totalNumPlaced;
		local totalUnplaced = self.catalogInfo.totalNumStored + self.catalogInfo.remainingRedeemable;
		local totalOwned = totalUnplaced + totalPlaced;
		local totalDyed = 0;
		for _, variantInfo in ipairs(self.catalogInfo.variants) do
			if variantInfo.entryVariantID.variantIdentifier ~= 0 then
				totalDyed = totalDyed + variantInfo.numStored;
			end
		end
		-- Num owned/stored/placed
		local ownedString = nil;
		if totalOwned == 0 or (totalPlaced == 0 and totalDyed == 0) then
			ownedString = HOUSING_BLUEPRINT_CONTENT_DECOR_OWNED_FMT:format(totalOwned);
		elseif totalPlaced > 0 and totalDyed > 0 then
			ownedString = HOUSING_BLUEPRINT_CONTENT_DECOR_OWNED_PLACED_DYED_FMT:format(totalOwned, totalPlaced, totalDyed);
		elseif totalPlaced > 0 then
			ownedString = HOUSING_BLUEPRINT_CONTENT_DECOR_OWNED_PLACED_FMT:format(totalOwned, totalPlaced);
		else
			ownedString = HOUSING_BLUEPRINT_CONTENT_DECOR_OWNED_DYED_FMT:format(totalOwned, totalDyed);
		end
		GameTooltip_AddNormalLine(tooltip, ownedString);

		-- Excluded dye notice
		if totalDyed > 0 and self.entryData.numMissing > 0 then
			GameTooltip_AddErrorLine(tooltip, HOUSING_BLUEPRINT_CONTENT_DECOR_DYED_NOTICE);
		end

		-- Preview instruction
		GameTooltip_AddInstructionLine(tooltip, HOUSING_DECOR_PREVIEW_TOOLTIP, GREEN_FONT_COLOR);

		-- Content tracking instruction
		Blizzard_HousingCatalogUtil.AddDecorEntryTooltipTrackingText(tooltip, self.entryData.recordID);

		return true;
	elseif self.entryData.contentType == Enum.HousingBlueprintContentType.Dye then
		GameTooltip:SetItemByID(self.entryData.recordID);
		return true;
	elseif self.entryData.contentType == Enum.HousingBlueprintContentType.Fixture then
		if self.entryData.numMissing > 0 then
			GameTooltip_AddErrorLine(tooltip, HOUSING_EXTERIOR_CUSTOMIZATION_LOCKED_TOOLTIP);
			return true;
		end
	elseif self.entryData.contentType == Enum.HousingBlueprintContentType.Other then
		if self.entryData.tooltip then
			if self.entryData.invalid or self.entryData.numMissing > 0 then
				GameTooltip_AddErrorLine(tooltip, self.entryData.tooltip);
			else
				GameTooltip_AddNormalLine(tooltip, self.entryData.tooltip);
			end
			return true;
		end
	end

	return false;
end

function HousingBlueprintContentEntryMixin:GetDebugName()
	if self.entryData then
		return self.entryData.name;
	end
	return "Unused Entry";
end

