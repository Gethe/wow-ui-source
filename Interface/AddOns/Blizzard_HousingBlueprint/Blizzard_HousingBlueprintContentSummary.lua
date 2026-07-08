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
			HousingBlueprintContentListFrame:ShowBlueprintContents(self.blueprintContentInfo, self:GetTargetGUID());
		end
	end);
end

function HousingBlueprintContentSummaryMixin:OnEvent(event, ...)
	if event == "HOUSING_NUM_DECOR_PLACED_CHANGED"
		or event == "HOUSING_STORAGE_UPDATED"
		or event == "HOUSING_LAYOUT_ROOM_RECEIVED" 
		or event == "HOUSING_LAYOUT_ROOM_REMOVED"
		or event == "HOUSE_LEVEL_CHANGED" then
		if self:HasTargetHouse() then
			self:UpdateBlueprintContentsData();
		end
	elseif event == "HOUSING_STORAGE_ENTRY_UPDATED" then
		local entryVariantID = ...;
		if self:HasTargetHouse() and self:DoesBlueprintContainCatalogEntry(entryVariantID) then
			self:UpdateBlueprintContentsData();
		end
	elseif event == "HOUSING_BLUEPRINT_CONTENTS_FAILURE" then
		local sharecode, result = ...;
		self:OnContentRequestFailure(result);
	elseif event == "HOUSING_BLUEPRINT_CONTENTS_RECEIVED" then
		local contentInfo = ...;
		local currentTarget = self:GetTargetGUID();
		if contentInfo and self.blueprintCode == contentInfo.shareCode and (not currentTarget or currentTarget == contentInfo.targetHouseGUID) then
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

function HousingBlueprintContentSummaryMixin:SetShareCode(shareCode, targetHouseGUID)
	self:ClearData();
	self.blueprintCode = shareCode;
	self.blueprintType = C_HousingBlueprint.GetBlueprintTypeForCode(self.blueprintCode);

	self.targetHouseGUID = targetHouseGUID;

	if self:IsShown() then
		self:UpdateBlueprintContentsData();
	end
end

function HousingBlueprintContentSummaryMixin:ClearData()
	self.blueprintCode = nil;
	self.blueprintType = nil;
	self.targetHouseGUID = nil;
	self.isWaitingForContent = nil;
	self.showLoadingState = nil;
	self.blueprintContentInfo = nil;
	self.budgetInfo = nil;

	self.CountListContainer.ContentsCountText:SetText("");
end

function HousingBlueprintContentSummaryMixin:GetWaitingState()
	return self.isWaitingForContent, self.showLoadingState;
end

function HousingBlueprintContentSummaryMixin:GetTargetGUID()
	return self.targetHouseGUID;
end

function HousingBlueprintContentSummaryMixin:HasTargetHouse()
	return self:GetTargetGUID() ~= nil;
end

function HousingBlueprintContentSummaryMixin:IsShowingBlueprint(shareCode)
	return self.blueprintContentInfo and self.blueprintContentInfo.shareCode == shareCode;
end

function HousingBlueprintContentSummaryMixin:IsShowingBlueprintForTarget(shareCode, houseGUID)
	if not self.blueprintContentInfo then
		return false;
	end

	return self.blueprintContentInfo.shareCode == shareCode and self:GetTargetGUID() == houseGUID;
end

function HousingBlueprintContentSummaryMixin:GetBlueprintValues()
	return self.blueprintCode, self.blueprintType;
end

function HousingBlueprintContentSummaryMixin:HasUnmetRequirements()
	return self.blueprintContentInfo ~= nil and FlagsUtil.IsAnythingSet(self.blueprintContentInfo.unmetRequirementFlags);
end

function HousingBlueprintContentSummaryMixin:IsContentImportable()
	if not self.blueprintContentInfo then
		return false;
	end

	if not self:HasTargetHouse() then
		return false;
	end

	if not C_HousingBlueprint.CanImportTypeFromCurrentLocation(self.blueprintType) then
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

	local isFirstTimeUpdate = (not self.blueprintContentInfo) or (self.blueprintContentInfo.shareCode ~= self.blueprintCode);

	-- Avoid showing loading state if we're requesting an update on blueprint contents we're already displaying
	self:UpdateWaitingState(--[[isWaitingForContent]] true, --[[showLoadingState]] isFirstTimeUpdate);
	
	-- If we have a specific target, or we're updating existing shown content, stick with our current target, even  if that target is nil, so that it doesn't change across in-place data refreshes
	if self:HasTargetHouse() or not isFirstTimeUpdate then
		C_HousingBlueprint.RequestBlueprintContentsForContext(self.blueprintCode, self:GetTargetGUID());
	else
		C_HousingBlueprint.RequestBlueprintContents(self.blueprintCode);
	end
end

function HousingBlueprintContentSummaryMixin:OnContentRequestFailure(result)
	self:UpdateWaitingState(--[[isWaitingForContent]] false, --[[showLoadingState]] false);
	if self.contentUpdatedCallback then
		self.contentUpdatedCallback();
	end
	local errorText = HousingResultToErrorText[result] or ERR_HOUSING_RESULT_BLUEPRINT_GENERIC_CONTENT_ERROR;
	UIErrorsFrame:AddExternalErrorMessage(HOUSING_BLUEPRINT_CONTENT_ERROR_FMT:format(errorText));
end

function HousingBlueprintContentSummaryMixin:IsShowingAnyBudgets()
	for _, entry in ipairs(self.BudgetsContainer.BudgetEntries) do
		if entry:IsShown() then
			return true;
		end
	end
	return false;
end

function HousingBlueprintContentSummaryMixin:OnBlueprintContentsReceived(contentInfo)
	self:UpdateWaitingState(--[[isWaitingForContent]] false, --[[showLoadingState]] false);
	self.blueprintContentInfo = contentInfo;

	-- Update target houseGUID as what we got the data back with, because if we didn't specify a context at all, it'll be based on where the player is currently standing
	self.targetHouseGUID = self.blueprintContentInfo.targetHouseGUID;

	local availableInteriorBudget, availableExteriorBudget, availableRoomBudget = nil, nil, nil;
	if self.blueprintContentInfo.targetHouseBudgetInfo then
		availableInteriorBudget = self.blueprintContentInfo.targetHouseBudgetInfo.interiorDecorBudgetMax;
		availableExteriorBudget = self.blueprintContentInfo.targetHouseBudgetInfo.exteriorDecorBudgetMax;
		availableRoomBudget = self.blueprintContentInfo.targetHouseBudgetInfo.roomBudgetMax;

		-- Rooms are the only blueprint type that add to the existing spent budgets rather than replace them, so need to display "available" rather than "max"
		if self.blueprintType == Enum.HousingBlueprintType.Room then
			availableInteriorBudget = availableInteriorBudget - self.blueprintContentInfo.targetHouseBudgetInfo.interiorDecorBudgetCurrent;
			availableRoomBudget = availableRoomBudget - self.blueprintContentInfo.targetHouseBudgetInfo.roomBudgetCurrent;
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

	self.BudgetsContainer:SetShown(self:IsShowingAnyBudgets());

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
	if self:HasTargetHouse() then
		local numAvailable = numItems - numMissing;
		self.CountListContainer.ContentsCountText:SetText(HOUSING_BLUEPRINT_IMPORT_VALIDATION_CONTENTS_COUNT_COMPARE_FMT:format(numAvailable, numItems));
	else
		self.CountListContainer.ContentsCountText:SetText(HOUSING_BLUEPRINT_IMPORT_VALIDATION_CONTENTS_COUNT_FMT:format(numItems));
	end

	self:MarkDirty();

	if self.contentUpdatedCallback then
		self.contentUpdatedCallback();
	end

	-- If we got new content data for the blueprint the List frame is also showing, make sure it gets updated too
	local target = self:GetTargetGUID();
	if HousingBlueprintContentListFrame:IsShown() and HousingBlueprintContentListFrame:IsShowingBlueprintForTarget(self.blueprintContentInfo.shareCode, target)  then
		HousingBlueprintContentListFrame:ShowBlueprintContents(self.blueprintContentInfo, target);
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
	self.BudgetsContainer:SetShown((not self.showLoadingState) and self:IsShowingAnyBudgets());
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
