local SUPER_DISTRICT_INFO_NONE = {
	superDistrictID = 0,
	displayName = PCT_FLOW_DESTINATION_SUPER_DISTRICT_DROPDOWN_NONE,
};

SuperDistrictSelectorMixin = {};

function SuperDistrictSelectorMixin:OnLoad()
	self.SuperDistrictLabel:SetText(self.labelText);
	self.SuperDistrictDropdown:SetWidth(228);

	self.anySuperDistrictSelectedCallback = function()
		CharSelectServicesFlowFrame:ClearErrorMessage();
		self:CallOnSelectedCallback();
	end;
end

function SuperDistrictSelectorMixin:Initialize(results, wasFromRewind)
	if wasFromRewind then
		return;
	end

	local superDistrictInfos = {};
	if self.isDropdownOptional then
		table.insert(superDistrictInfos, SUPER_DISTRICT_INFO_NONE);
	end
	tAppendAll(superDistrictInfos, self.dropdownFunction());
	self:SetSelectedSuperDistrictInfo(superDistrictInfos[1]);

	local function IsSelected(superDistrictInfo)
		return self.selectedSuperDistrictInfo.superDistrictID == superDistrictInfo.superDistrictID;
	end

	local function SetSelected(superDistrictInfo)
		self:SetSelectedSuperDistrictInfo(superDistrictInfo);
		self.anySuperDistrictSelectedCallback();
	end
	
	self.SuperDistrictDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_CHARACTER_SELECT_SERVICE_SUPER_DISTRICT");

		for _, superDistrictInfo in ipairs(superDistrictInfos) do
			rootDescription:CreateRadio(superDistrictInfo.displayName, IsSelected, SetSelected, superDistrictInfo);
		end
	end);

	self.anySuperDistrictSelectedCallback();
end

function SuperDistrictSelectorMixin:SetOnSelectedCallback(callback)
	self.onSelectedCallback = callback;
end

function SuperDistrictSelectorMixin:CallOnSelectedCallback()
	if self.onSelectedCallback then
		self.onSelectedCallback();
	end
end

function SuperDistrictSelectorMixin:SetSelectedSuperDistrictInfo(superDistrictInfo)
	self.selectedSuperDistrictInfo = superDistrictInfo;
end

function SuperDistrictSelectorMixin:GetSelectedSuperDistrictInfo()
	return self.selectedSuperDistrictInfo;
end

function SuperDistrictSelectorMixin:GetResult()
	return self:GetSelectedSuperDistrictInfo();
end
