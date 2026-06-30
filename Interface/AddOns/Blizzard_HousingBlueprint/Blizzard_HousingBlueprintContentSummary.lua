HousingBlueprintContentSummaryMixin = {};

local ContentWhileShownEvents = {
	"HOUSING_NUM_DECOR_PLACED_CHANGED",
	"HOUSING_STORAGE_UPDATED",
	"HOUSING_STORAGE_ENTRY_UPDATED",
	"HOUSING_LAYOUT_ROOM_RECEIVED",
	"HOUSING_LAYOUT_ROOM_REMOVED",
	"HOUSE_LEVEL_CHANGED",
	"HOUSING_BLUEPRINT_CONTENTS_RECEIVED",
	"HOUSING_BLUEPRINT_CONTENTS_FAILURE"
};

function HousingBlueprintContentSummaryMixin:OnLoad()
	self.CountListContainer.ContentsListButton:SetScript("OnClick", function()
		if self.blueprintContentInfo then
			PlaySound(SOUNDKIT.HOUSING_BLUEPRINTS_BUTTONS);
			HousingBlueprintContentListFrame:ShowBlueprintContents(self.blueprintContentInfo, self.isReadonly);
		end
	end);
	self.Background:SetAlpha(self.backgroundAlpha);
end

function HousingBlueprintContentSummaryMixin:OnEvent(event, ...)
	if event == "HOUSING_NUM_DECOR_PLACED_CHANGED"
		or event == "HOUSING_STORAGE_UPDATED"
		or event == "HOUSING_LAYOUT_ROOM_RECEIVED" 
		or event == "HOUSING_LAYOUT_ROOM_REMOVED"
		or event == "HOUSE_LEVEL_CHANGED" then
		if not self.isReadonly then
			self:UpdateBlueprintContentsData();
		end
	elseif event == "HOUSING_STORAGE_ENTRY_UPDATED" then
		local entryVariantID = ...;
		if not self.isReadonly and self:DoesBlueprintContainCatalogEntry(entryVariantID) then
			self:UpdateBlueprintContentsData();
		end
	elseif event == "HOUSING_BLUEPRINT_CONTENTS_FAILURE" then
		local sharecode, result = ...;
		self:OnContentRequestFailure(result);
	elseif event == "HOUSING_BLUEPRINT_CONTENTS_RECEIVED" then
		local contentInfo = ...;
		if contentInfo and self.blueprintCode == contentInfo.shareCode then
			self:OnBlueprintContentsReceived(contentInfo);
		end
	end
end

function HousingBlueprintContentSummaryMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ContentWhileShownEvents);

	if self.blueprintCode then
		self:UpdateBlueprintContentsData();
	else
		-- Update to ensure we're at least using our minimum width & height
		self:MarkDirty();
	end
end

function HousingBlueprintContentSummaryMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ContentWhileShownEvents);
end

function HousingBlueprintContentSummaryMixin:SetContentUpdatedCallback(contentUpdatedCallback)
	self.contentUpdatedCallback = contentUpdatedCallback;
end

function HousingBlueprintContentSummaryMixin:SetShareCode(shareCode, isReadonly)
	self.blueprintCode = shareCode;
	self.blueprintType = C_HousingBlueprint.GetBlueprintTypeForCode(self.blueprintCode);

	if isReadonly ~= nil then
		self.isReadonly = isReadonly;
	else
		self.isReadonly = not C_HousingBlueprint.CanImportTypeFromCurrentLocation(self.blueprintType);
	end

	if self:IsShown() then
		self:UpdateBlueprintContentsData();
	end
end

function HousingBlueprintContentSummaryMixin:ClearData()
	self.blueprintCode = nil;
	self.blueprintType = nil;
	self.isReadonly = nil;
	self.isWaitingForContent = nil;
	self.showLoadingState = nil;
	self.blueprintContentInfo = nil;
	self.budgetInfo = nil;

	self.CountListContainer.ContentsCountText:SetText("");
end

function HousingBlueprintContentSummaryMixin:GetWaitingState()
	return self.isWaitingForContent, self.showLoadingState;
end

function HousingBlueprintContentSummaryMixin:IsShowingBlueprint(shareCode)
	return self.blueprintContentInfo and self.blueprintContentInfo.shareCode == shareCode;
end

function HousingBlueprintContentSummaryMixin:IsShowingBlueprintForTarget(shareCode, houseGUID)
	if not self.blueprintContentInfo then
		return false;
	end

	return self.blueprintContentInfo.shareCode == shareCode and self.blueprintContentInfo.targetHouseGUID == houseGUID;
end

function HousingBlueprintContentSummaryMixin:GetBlueprintValues()
	return self.blueprintCode, self.blueprintType;
end

function HousingBlueprintContentSummaryMixin:HasUnmetRequirements()
	return self.blueprintContentInfo ~= nil and FlagsUtil.IsAnythingSet(self.blueprintContentInfo.unmetRequirementFlags);
end

function HousingBlueprintContentSummaryMixin:IsReadonly()
	return self.isReadonly;
end

function HousingBlueprintContentSummaryMixin:IsContentImportable()
	if not self.blueprintContentInfo then
		return false;
	end

	if self.isReadonly then
		return false;
	end

	if not FlagsUtil.IsAnythingSet(self.blueprintContentInfo.blockingRequirementFlags) then
		return true;
	end

	local disabledTooltip = nil;
	-- If insufficient budget, convey that in the most precise way
	if FlagsUtil.IsSet(self.blueprintContentInfo.blockingRequirementFlags, Enum.HousingBlueprintUnmetRequirementFlags.InsufficientBudget) then
		if self.budgetInfo.insufficientRoom and (self.budgetInfo.insufficientInterior or self.budgetInfo.insufficientExterior) then
			disabledTooltip = ERR_HOUSING_BLUEPRINT_REQUIREMENT_BUDGETS;
		elseif self.budgetInfo.insufficientRoom then
			disabledTooltip = ERR_HOUSING_BLUEPRINT_REQUIREMENT_BUDGET_ROOM;
		else
			disabledTooltip = ERR_HOUSING_BLUEPRINT_REQUIREMENT_BUDGET_DECOR;
		end
	else
		-- Otherwise, choose the first other blocking requirement flag we have a tooltip for
		for flagName, flagValue in pairs(Enum.HousingBlueprintUnmetRequirementFlags) do
			if FlagsUtil.IsSet(self.blueprintContentInfo.blockingRequirementFlags, flagValue) and HousingBlueprintUnmetRequirementStrings[flagValue] then
				disabledTooltip = HousingBlueprintUnmetRequirementStrings[flagValue];
				break;
			end
		end
	end

	return false, disabledTooltip;
end

function HousingBlueprintContentSummaryMixin:UpdateBlueprintContentsData()
	if self.isWaitingForContent then
		return;
	end

	-- Avoid showing loading state if we're requesting an update on blueprint contents we're already displaying
	local showLoadingState = not self.blueprintContentInfo or self.blueprintContentInfo.shareCode ~= self.blueprintCode;
	self:UpdateWaitingState(--[[isWaitingForContent]] true, showLoadingState);
	
	C_HousingBlueprint.RequestBlueprintContents(self.blueprintCode);
end

function HousingBlueprintContentSummaryMixin:OnContentRequestFailure()
	self:UpdateWaitingState(--[[isWaitingForContent]] false, --[[showLoadingState]] false);
	if self.contentUpdatedCallback then
		self.contentUpdatedCallback();
	end
	local errorText = HousingResultToErrorText[result] or ERR_HOUSING_RESULT_BLUEPRINT_GENERIC_IMPORT_ERROR;
	UIErrorsFrame:AddExternalErrorMessage(HOUSING_BLUEPRINT_IMPORT_ERROR_FMT:format(errorText));
end

function HousingBlueprintContentSummaryMixin:OnBlueprintContentsReceived(contentInfo)
	self:UpdateWaitingState(--[[isWaitingForContent]] false, --[[showLoadingState]] false);
	self.blueprintContentInfo = contentInfo;

	local availableInteriorBudget, availableExteriorBudget, availableRoomBudget = nil, nil, nil;
	if not self.isReadonly then
		availableInteriorBudget, availableExteriorBudget = C_HousingDecor.GetBothMaxPlacementBudgets();
		availableRoomBudget = C_HousingLayout.GetRoomPlacementBudget();
		-- Rooms are the only blueprint type that add to the existing spent budgets rather than replace them, so need to display "available" rather than "max"
		if availableInteriorBudget and self.blueprintType == Enum.HousingBlueprintType.Room then
			local spentInteriorDecorBudget, _ = C_HousingDecor.GetBothSpentPlacementBudgets();
			local spentRoomBudget = C_HousingLayout.GetSpentPlacementBudget();
			availableInteriorBudget = availableInteriorBudget - spentInteriorDecorBudget;
			availableRoomBudget = availableRoomBudget - spentRoomBudget;
		end
	end

	self.budgetInfo = {
		insufficientInterior = availableInteriorBudget and self.blueprintContentInfo.interiorDecorBudgetCost > availableInteriorBudget,
		insufficientExterior = availableExteriorBudget and self.blueprintContentInfo.exteriorDecorBudgetCost > availableExteriorBudget,
		insufficientRoom = availableRoomBudget and self.blueprintContentInfo.roomBudgetCost > availableRoomBudget,
	};

	self:UpdateBudget(self.BudgetsContainer.IndoorDecorBudget, self.blueprintContentInfo.interiorDecorBudgetCost, availableInteriorBudget, self.budgetInfo.insufficientInterior);
	self:UpdateBudget(self.BudgetsContainer.OutdoorDecorBudget, self.blueprintContentInfo.exteriorDecorBudgetCost, availableExteriorBudget, self.budgetInfo.insufficientExterior);
	self:UpdateBudget(self.BudgetsContainer.RoomBudget, self.blueprintContentInfo.roomBudgetCost, availableRoomBudget, self.budgetInfo.insufficientRoom);

	local numItems = 0;
	local numMissing = 0;
	for _, contentGroup in ipairs(self.blueprintContentInfo.contentGroups) do
		for _, entry in ipairs(contentGroup.entries) do
			numItems = numItems + entry.total;
			if entry.invalid then
				numMissing = numMissing + entry.total;
			else
				numMissing = numMissing + entry.numMissing;
			end
		end
	end
	if self.isReadonly then
		self.CountListContainer.ContentsCountText:SetText(HOUSING_BLUEPRINT_IMPORT_VALIDATION_CONTENTS_COUNT_FMT:format(numItems));
	else
		local numAvailable = numItems - numMissing;
		self.CountListContainer.ContentsCountText:SetText(HOUSING_BLUEPRINT_IMPORT_VALIDATION_CONTENTS_COUNT_COMPARE_FMT:format(numAvailable, numItems));
	end

	self:MarkDirty();

	if self.contentUpdatedCallback then
		self.contentUpdatedCallback();
	end

	-- If we got new content data for the blueprint the List frame is also showing, make sure it gets updated too
	if HousingBlueprintContentListFrame:IsShown() and HousingBlueprintContentListFrame:IsShowingBlueprintForTarget(self.blueprintContentInfo.shareCode, self.blueprintContentInfo.targetHouseGUID)  then
		HousingBlueprintContentListFrame:ShowBlueprintContents(self.blueprintContentInfo, self.isReadonly);
	end
end

function HousingBlueprintContentSummaryMixin:UpdateBudget(budgetFrame, budgetCost, budgetAvailable, isInsufficient)
	if budgetCost > 0 then
		if not budgetAvailable then
			budgetFrame.Text:SetText(HOUSING_BLUEPRINT_IMPORT_VALIDATION_BUDGET_FMT:format(budgetCost));
		else
			budgetFrame.Text:SetText(HOUSING_BLUEPRINT_IMPORT_VALIDATION_BUDGET_COMPARE_FMT:format(budgetCost, budgetAvailable));
		end
		local textColor = isInsufficient and RED_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
		budgetFrame.Text:SetTextColor(textColor:GetRGB());
		budgetFrame:Show();
	else
		budgetFrame:Hide();
	end
end

function HousingBlueprintContentSummaryMixin:DoesBlueprintContainCatalogEntry(entryVariantID)
	if not self.blueprintContentInfo then
		return false;
	end

	local targetContentType = nil;
	if entryVariantID.entryType == Enum.HousingCatalogEntryType.Decor then
		targetContentType = Enum.HousingBlueprintContentType.Decor;
	elseif entryVariantID.entryType == Enum.HousingCatalogEntryType.Room then
		targetContentType = Enum.HousingBlueprintContentType.Room;
	else
		return false;
	end

	for _, contentGroup in ipairs(self.blueprintContentInfo.contentGroups) do
		if contentGroup.contentType == targetContentType then
			for _, entry in ipairs(contentGroup.entries) do
				if entry.recordID == entryVariantID.recordID then
					return true;
				end
			end
		end
	end

	return false;
end

function HousingBlueprintContentSummaryMixin:UpdateWaitingState(isWaitingForContent, showLoadingState)
	self.isWaitingForContent = isWaitingForContent;
	self.showLoadingState = showLoadingState;
	self.LoadingSpinner:SetShown(self.showLoadingState);
	self.BudgetsContainer:SetShown(not self.showLoadingState);
	self.CountListContainer:SetShown(not self.showLoadingState);
end

HousingBlueprintBudgetMixin = {};

function HousingBlueprintBudgetMixin:OnLoad()
	self.Icon:SetAtlas(self.icon);
end

function HousingBlueprintBudgetMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM");
	GameTooltip_AddHighlightLine(GameTooltip, self.tooltipText);
	GameTooltip:Show();
end

function HousingBlueprintBudgetMixin:OnLeave()
	GameTooltip:Hide();
end
