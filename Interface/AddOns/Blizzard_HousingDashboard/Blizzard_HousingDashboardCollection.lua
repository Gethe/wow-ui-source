----------------- Collections Container -----------------
HousingDashboardCollectionFrameMixin = {};

function HousingDashboardCollectionFrameMixin:OnLoad()
	self.BlueprintCollection:SetBlueprintEntryClickedCallback(GenerateClosure(self.OnBlueprintEntryClicked, self));
end

function HousingDashboardCollectionFrameMixin:IsBlueprintSelected(shareCode)
	return self:IsShown() and self.BlueprintDetails:IsShowingBlueprint(shareCode);
end

function HousingDashboardCollectionFrameMixin:OnBlueprintEntryClicked(blueprintInfo)
	PlaySound(SOUNDKIT.HOUSING_BLUEPRINTS_BUTTONS);
	self.BlueprintDetails:ShowBlueprint(blueprintInfo);
end

----------------- Details preview frame -----------------
HousingDashboardBlueprintDetailsMixin = {};

local DetailsLifetimeEvents = {
	"HOUSING_BLUEPRINT_RENAME_SUCCESS",
	"HOUSING_BLUEPRINT_DELETE_SUCCESS",
};

function HousingDashboardBlueprintDetailsMixin:OnLoad()
	self:ClearData();

	self.GearDropdown:SetupMenu(function(_dropdown, rootDescription)
		local menuParams = {
			shouldShowImport = self.blueprintInfo and C_HousingBlueprint.GetImportAvailability() == Enum.HousingResult.Success and C_HousingBlueprint.CanImportTypeFromCurrentLocation(self.blueprintInfo.blueprintType),
			onDeleteConfirm = function() self:OnDeleteConfirmed(); end,
		};
		HousingBlueprintUtils.CreateBlueprintInfoContextMenu(rootDescription, self.blueprintInfo, menuParams);
	end);

	FrameUtil.RegisterFrameForEvents(self, DetailsLifetimeEvents);
	EventRegistry:RegisterCallback("HouseDropdown.HouseSelected", self.OnHouseSelected, self);
end

function HousingDashboardBlueprintDetailsMixin:OnDeleteConfirmed()
	if self.blueprintInfo and not self.blueprintInfo.isAutoSave then
		C_HousingBlueprint.DeleteBlueprint(self.blueprintInfo.blueprintID);
	end
end

function HousingDashboardBlueprintDetailsMixin:OnEvent(event, ...)
	if event == "HOUSING_BLUEPRINT_RENAME_SUCCESS" then
		local blueprintID, newName = ...;
		if self.blueprintInfo and self.blueprintInfo.blueprintID == blueprintID then
			self.NameText:SetText(newName);
		end
	elseif event == "HOUSING_BLUEPRINT_DELETE_SUCCESS" then
		local blueprintID = ...;
		if self.blueprintInfo and self.blueprintInfo.blueprintID == blueprintID then
			self:ClearData();
		end
	end
end

function HousingDashboardBlueprintDetailsMixin:OnShow()
	-- Since ContentSummary isn't inside of a layout frame with variable width, ensure it works with the width it has via anchors
	self.ContentSummary.fixedWidth = self.ContentSummary:GetWidth();
	self:SyncSummaryInfo();
end

function HousingDashboardBlueprintDetailsMixin:IsShowingBlueprint(shareCode)
	return self.blueprintInfo and self.blueprintInfo.shareCode == shareCode;
end

function HousingDashboardBlueprintDetailsMixin:ShowBlueprint(blueprintInfo)
	self.blueprintInfo = blueprintInfo;
	self.GearDropdown:Show();
	self.ContentSummary:Show();
	self.ContentSummary:SetShareCode(blueprintInfo.shareCode, self.targetHouseGUID);
	self.NameText:SetText(blueprintInfo.name);

	local creationDate = date("*t", blueprintInfo.creationTime);
	local dateStr = FormatShortDate(creationDate.day, creationDate.month, creationDate.year);
	local timeStr = GameTime_GetFormattedTime(creationDate.hour, creationDate.min, true);
	local dateTimeStr = dateStr.." "..timeStr;
	self.DateTimeText:SetText(HOUSING_BLUEPRINT_COLLECTION_TIMESTAMP_FMT:format(dateTimeStr));
end

function HousingDashboardBlueprintDetailsMixin:ClearData()
	self.blueprintInfo = nil;
	self.ContentSummary:ClearData();
	self.ContentSummary:Hide();
	self.NameText:SetText(nil);
	self.DateTimeText:SetText(nil);
	self.GearDropdown:Hide();
end

function HousingDashboardBlueprintDetailsMixin:OnHouseSelected(houseInfoID, houseInfo)
	self.targetHouseGUID = houseInfo.houseGUID;
	if self:IsVisible() then
		self:SyncSummaryInfo();
	end
end

function HousingDashboardBlueprintDetailsMixin:SyncSummaryInfo()
	if self.blueprintInfo and not self.ContentSummary:IsShowingBlueprintForTarget(self.blueprintInfo.shareCode, self.targetHouseGUID) then
		self.ContentSummary:SetShareCode(self.blueprintInfo.shareCode, self.targetHouseGUID);
	end
end
