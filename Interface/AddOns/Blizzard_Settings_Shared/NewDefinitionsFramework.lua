NewSettings = {};
NewSettingsSeen = {};
NewSettingsPredicates = {};

local version = GetBuildInfo();

local function CheckInvokeSettingPredicate(predicate)
	if predicate then
		return predicate();
	end

	return true;
end

function IsNewSettingInCurrentVersion(variable)
	local currentNewSettings = NewSettings[version];
	if currentNewSettings then
		for _, var in ipairs(currentNewSettings) do
			if variable == var then
				local newSettingPredicate = NewSettingsPredicates[var];
				if CheckInvokeSettingPredicate(newSettingPredicate) then
					return true;
				end
				break;
			end
		end
	end

	return false;
end

function IsUnseenNewSettingInCurrentVersion(variable)
	local currentNewSettings = NewSettings[version];
	if currentNewSettings then
		for _, var in ipairs(currentNewSettings) do
			if variable == var then
				-- First check that it's a new setting in the current version
				local newSettingPredicate = NewSettingsPredicates[var];
				if CheckInvokeSettingPredicate(newSettingPredicate) then
					-- And if so, return whether or not it's been seen
					return not NewSettingsSeen[variable];
				end
			end
		end
	end

	-- This setting couldn't be found or wasn't new in the current version, nil return indicates that.
	return nil;
end

function CurrentVersionHasNewUnseenSettings()
	local currentNewSettings = NewSettings[version];
	if not currentNewSettings then
		return false;
	end

	for _, newSetting in ipairs(currentNewSettings) do
		local newSettingPredicate = NewSettingsPredicates[newSetting];
		if not NewSettingsSeen[newSetting] and CheckInvokeSettingPredicate(newSettingPredicate) then
			return true;
		end
	end

	return false;
end

function MarkNewSettingAsSeen(setting)
	local currentNewSettings = NewSettings[version];
	if not currentNewSettings then
		return;
	end

	for _, newSetting in ipairs(currentNewSettings) do
		if setting == newSetting then
			-- A setting cannot be marked as seen if it has a predicate that returns false.
			local newSettingPredicate = NewSettingsPredicates[newSetting];
			if CheckInvokeSettingPredicate(newSettingPredicate) then
				NewSettingsSeen[setting] = true;
				EventRegistry:TriggerEvent("NewSettingSeen", setting);
			end
			return;
		end
	end
end

NewDefinitionsCheckerMixin = {};

function NewDefinitionsCheckerMixin:NDCM_OnShow()
	EventRegistry:RegisterCallback("NewSettingSeen", function()
		self:CheckNewTagID();
	end, self);

	self:CheckNewTagID();
end

function NewDefinitionsCheckerMixin:NDCM_OnHide()
	EventRegistry:UnregisterCallback("NewSettingSeen", self);
end

function NewDefinitionsCheckerMixin:CheckNewTagID()
	local newOptionFrame = self:GetNewOptionDisplay();
	if newOptionFrame then
		local newTagID = self:GetNewTagID()
		if newTagID and IsUnseenNewSettingInCurrentVersion(newTagID) then
			self:SetNewOptionAnchor();
			newOptionFrame:Show();
		else
			newOptionFrame:Hide();
		end
	end
end

function NewDefinitionsCheckerMixin:HideNewOptionDisplay()
	local newOptionFrame = self:GetNewOptionDisplay();
	if newOptionFrame then
		newOptionFrame:Hide();
	end
end

function NewDefinitionsCheckerMixin:GetNewOptionDisplay()
	-- Override as needed
	return self.NewOptionsFrame;
end

function NewDefinitionsCheckerMixin:GetNewTagID()
	return self.newTagID;
end

function NewDefinitionsCheckerMixin:SetNewTagID(newTagID)
	if self.newTagID ~= newTagID then
		self.newTagID = newTagID;
		self:CheckNewTagID();
	end
end

function NewDefinitionsCheckerMixin:MarkSeen()
	local newTagID = self:GetNewTagID();
	if newTagID then
		MarkNewSettingAsSeen(newTagID);
	end
end

function NewDefinitionsCheckerMixin:SetNewOptionAnchor()
	-- Override as needed
	local newOptionFrame = self:GetNewOptionDisplay();
	if newOptionFrame then
		newOptionFrame:ClearAllPoints();
		newOptionFrame:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0);
	end
end

NewDefinitionsCheckerButtonMixin = CreateFromMixins(NewDefinitionsCheckerMixin);

function NewDefinitionsCheckerButtonMixin:SetNewOptionAnchor()
	local newOptionFrame = self:GetNewOptionDisplay();
	if newOptionFrame then
		newOptionFrame:SetPoint("BOTTOMRIGHT", self:GetFontString(), "LEFT", 16, -10);
	end
end
