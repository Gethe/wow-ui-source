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
	self.ContentsListButton:SetScript("OnClick", function()
		if self.blueprintContentInfo then
			PlaySound(SOUNDKIT.HOUSING_BLUEPRINTS_BUTTONS);
			HousingBlueprintContentListFrame:ShowBlueprintContents(self.blueprintContentInfo, self:GetTargetGUID());
		end
	end);

	if self.backgroundAlpha then
		self.BudgetsContainer:SetBackgroundAlpha(self.backgroundAlpha);
	end

	self.defaultMinimumHeight = self.minimumHeight;
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
	self.BudgetsContainer:ClearData();
	self.blueprintCode = nil;
	self.blueprintType = nil;
	self.targetHouseGUID = nil;
	self.isWaitingForContent = nil;
	self.showLoadingState = nil;
	self.blueprintContentInfo = nil;
	self.lastErrorText = nil;
	self.fixedHeight = nil;
	self.minimumHeight = self.defaultMinimumHeight;

	self.CountText:SetText("");
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

function HousingBlueprintContentSummaryMixin:HasBlueprintContent()
	return self.blueprintContentInfo ~= nil;
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
		return false, self.lastErrorText;
	end

	if not self:HasTargetHouse() then
		return false;
	end

	if not HousingTutorialUtil.HousingDecorQuestTutorialComplete() then
		return false, ERR_NOT_IN_NPE;
	end

	if not C_HousingBlueprint.CanImportTypeFromCurrentLocation(self.blueprintType) then
		return false, ERR_HOUSING_RESULT_BLUEPRINT_TYPE_LOCATION_INVALID;
	end

	if not FlagsUtil.IsAnythingSet(self.blueprintContentInfo.blockingRequirementFlags) then
		return true;
	end

	local disabledTooltip = nil;
	-- If insufficient budget, convey that in the most precise way
	if FlagsUtil.IsSet(self.blueprintContentInfo.blockingRequirementFlags, Enum.HousingBlueprintUnmetRequirementFlags.InsufficientBudget) then
		local insufficientBudgetTypes = self.BudgetsContainer:GetInsufficientBudgetTypes();
		local numInsufficientTypes = CountTable(insufficientBudgetTypes);
		if numInsufficientTypes > 1 then
			disabledTooltip = ERR_HOUSING_BLUEPRINT_REQUIREMENT_BUDGETS;
		elseif insufficientBudgetTypes[Enum.HousingBudgetType.RoomPlacement] then
			disabledTooltip = ERR_HOUSING_BLUEPRINT_REQUIREMENT_BUDGET_ROOM;
		elseif insufficientBudgetTypes[Enum.HousingBudgetType.DecorPlacement] then
			disabledTooltip = ERR_HOUSING_BLUEPRINT_REQUIREMENT_BUDGET_DECOR;
		elseif insufficientBudgetTypes[Enum.HousingBudgetType.PetDecor] then
			disabledTooltip = ERR_HOUSING_BLUEPRINT_REQUIREMENT_BUDGET_PET_DECOR;
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
	-- For generic "DB error" results, we want to show "blueprint not found" as a more user-friendly player-facing message
	-- And as the most likely actual underlying issue leading to it
	if result == Enum.HousingResult.DbError then
		result = Enum.HousingResult.BlueprintNotFound;
	end

	local errorText = HousingResultToErrorText[result] or ERR_HOUSING_RESULT_BLUEPRINT_GENERIC_CONTENT_ERROR;
	self.lastErrorText = HOUSING_BLUEPRINT_CONTENT_ERROR_FMT:format(errorText);
	self:UpdateWaitingState(--[[isWaitingForContent]] false, --[[showLoadingState]] false);

	self:MarkDirty();

	if self.contentUpdatedCallback then
		self.contentUpdatedCallback();
	end
end

function HousingBlueprintContentSummaryMixin:OnBlueprintContentsReceived(contentInfo)
	local wasShowingLoadingState = self.showLoadingState;
	self:UpdateWaitingState(--[[isWaitingForContent]] false, --[[showLoadingState]] false);
	self.blueprintContentInfo = contentInfo;
	self.lastErrorText = nil;

	if wasShowingLoadingState and self.playLoadCompleteSound then
		PlaySound(SOUNDKIT.HOUSING_BLUEPRINTS_IMPORT_OPEN);
	end

	-- Update target houseGUID as what we got the data back with, because if we didn't specify a context at all, it'll be based on where the player is currently standing
	self.targetHouseGUID = self.blueprintContentInfo.targetHouseGUID;

	self.BudgetsContainer:SetInfo(self.blueprintContentInfo.budgetInfo, self.blueprintType);

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
		self.CountText:SetText(HOUSING_BLUEPRINT_IMPORT_VALIDATION_CONTENTS_COUNT_COMPARE_FMT:format(numAvailable, numItems));
	else
		self.CountText:SetText(HOUSING_BLUEPRINT_IMPORT_VALIDATION_CONTENTS_COUNT_FMT:format(numItems));
	end

	self:UpdateContentVisibility();

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

	self:UpdateContentVisibility();

	self.LoadingSpinner:SetShown(self.showLoadingState);
	if showLoadingState and (not self.loopSoundHandle) then
		local _, soundHandle = PlaySound(SOUNDKIT.HOUSING_BLUEPRINTS_IMPORT_LOOP);
		self.loopSoundHandle = soundHandle;
	elseif (not showLoadingState) and self.loopSoundHandle then
		StopSound(self.loopSoundHandle);
		self.loopSoundHandle = nil;
	end
end

function HousingBlueprintContentSummaryMixin:UpdateContentVisibility()
	local canShowContent = self:HasBlueprintContent() and not self.showLoadingState;

	self.BudgetsContainer:SetShown(canShowContent and self.BudgetsContainer:IsShowingAnyBudgets());
	self.ContentsListButton:SetShown(canShowContent);
	self.CountText:SetShown(canShowContent);

	if self.showLoadingState or canShowContent then
		-- If we're showing anything at all, maintain correct normal layout heights
		self.fixedHeight = nil;
		self.minimumHeight = self.defaultMinimumHeight;
	else
		-- If not showing anything at all, try not to take up empty space, without also invalidating our rect entirely
		-- Doing this as opposed to hiding this frame outright because we want to remain shown and plugged into any further data or state changes
		self.minimumHeight = nil;
		self.fixedHeight = 1;
	end
end
