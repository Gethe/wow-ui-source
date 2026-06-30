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
	FrameUtil.RegisterFrameForEvents(self, DetailsLifetimeEvents);
	self:ClearData();
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

function HousingDashboardBlueprintDetailsMixin:IsShowingBlueprint(shareCode)
	return self.blueprintInfo and self.blueprintInfo.shareCode == shareCode;
end

function HousingDashboardBlueprintDetailsMixin:ShowBlueprint(blueprintInfo)
	self.blueprintInfo = blueprintInfo;
	self.ContentSummary:Show();
	self.ContentSummary:SetShareCode(blueprintInfo.shareCode);
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
end
