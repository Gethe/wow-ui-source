-- Base choice entry for non-menu-system use
-- Inherits CustomizationElementTemplate
HouseExteriorOptionElementMixin = {};

--[[
Expected choiceData members
	Standard/required: id, name, choiceIndex
	Optional: isLocked, lockedText, isNew, ineligibleChoice, disabled, swatchColor1, swatchColor2, soundKit
]]--
function HouseExteriorOptionElementMixin:Init(choiceData, choiceIndex, selected, hasAFailedReq, hasALockedChoice)
	self.choiceData = choiceData;
	self.isSelected = selected;
	if self.overrideDetailsWidth then
		self.SelectionDetails:SetOverrideWidth(self.overrideDetailsWidth);
	end
	self.SelectionDetails:SetSkipLockedTextFormat(true);
	CustomizationElementMixin.Init(self, choiceData, choiceIndex, selected, hasAFailedReq, hasALockedChoice);
end

function HouseExteriorOptionElementMixin:GetChoiceData()
	return self.choiceData;
end

function HouseExteriorOptionElementMixin:IsSelected()
	return self.isSelected;
end

function HouseExteriorOptionElementMixin:GetAppropriateTooltip()
	return GameTooltip;
end

-- Base choice entry for dropdown menu use
-- Inherits CustomizationElementTemplate
HouseExteriorOptionDropdownElementMixin = {};

function HouseExteriorOptionDropdownElementMixin:Init(choiceData, choiceIndex, selected, hasAFailedReq, hasALockedChoice)
	if self.overrideDetailsWidth then
		self.SelectionDetails:SetOverrideWidth(self.overrideDetailsWidth);
	end
	self.SelectionDetails:SetSkipLockedTextFormat(true);
	CustomizationElementMixin.Init(self, choiceData, choiceIndex, selected, hasAFailedReq, hasALockedChoice);
end

function HouseExteriorOptionDropdownElementMixin:GetChoiceData()
	local description = self:GetElementDescription();
	return description:GetData();
end

function HouseExteriorOptionDropdownElementMixin:IsSelected()
	local description = self:GetElementDescription();
	return description:IsSelected(description:GetData());
end

function HouseExteriorOptionDropdownElementMixin:GetAppropriateTooltip()
	return GameTooltip;
end


-- Base dropdown containing multiple dropdown elements
HouseExteriorOptionDropdownMixin = {};

function HouseExteriorOptionDropdownMixin:OnLoad()
	self.Label:SetText(self.label);
end

function HouseExteriorOptionDropdownMixin:ClearAndHide()
	self.Dropdown:CloseMenu();
	self:Hide();
	self:MarkDirty();
end

-- TODO: Remove this whole mixin & template once we no longer need these static placeholder dropdowns for house type & size
HouseExteriorPlaceholderDropdownMixin = {};

function HouseExteriorPlaceholderDropdownMixin:OnLoad()
	HouseExteriorOptionDropdownMixin.OnLoad(self);
	self.Dropdown:SetMotionScriptsWhileDisabled(true);
	self.Dropdown:SetScript("OnEnter", function() self:OnEnter(); end);
	self.Dropdown:SetScript("OnLeave", function() self:OnLeave(); end);
end

function HouseExteriorPlaceholderDropdownMixin:ShowStaticPlaceholderInfo(value)
	self.Dropdown.Text:SetText(value);
	self.Dropdown:SetEnabled(false);
end

function HouseExteriorPlaceholderDropdownMixin:OnEnter()
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMRIGHT", self.Dropdown, "TOPLEFT", 0, 0);
	GameTooltip_AddNormalLine(tooltip, HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_COMING_SOON_TOOLTIP);
	tooltip:Show();
end

function HouseExteriorPlaceholderDropdownMixin:OnLeave()
	GameTooltip:Hide();
end

-- Dropdown specifically for Core Fixture options
-- Inherits HouseExteriorOptionDropdownTemplate
HouseExteriorCoreFixtureDropdownMixin = {};

function HouseExteriorCoreFixtureDropdownMixin:ClearAndHide()
	HouseExteriorOptionDropdownMixin.ClearAndHide(self);
	self.selectedFixtureID = nil;
	self.fixtureOptions = nil;
end

function HouseExteriorCoreFixtureDropdownMixin:HasAnyLockedChoices()
	for _, fixtureOption in ipairs(self.fixtureOptions) do
		if fixtureOption.isLocked then
			return true;
		end
	end
	return false;
end

function HouseExteriorCoreFixtureDropdownMixin:ShowCoreFixtureInfo(selectedFixtureID, fixtureOptions)
	self.selectedFixtureID = selectedFixtureID;
	self.fixtureOptions = fixtureOptions;

	local hasAnyLockedChoices = self:HasAnyLockedChoices();
	local hasAnyFailedReqs = hasAnyLockedChoices; -- Right now we have no ineligible choices that aren't also just locked

	self.Dropdown:SetEnabled(true);
	self.Dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("HOUSE_EXTERIOR_CORE_FIXTURE_OPTIONS_MENU");

		-- All of this is to be consistent with CustomizationDropdownWithSteppersAndLabelMixin and should ideally
		-- be rewritten/simplified to use the modern menu flow more correctly
		rootDescription:DisableCompositor();
		rootDescription:DisableReacquireFrames();
		local columns = MenuConstants.AutoCalculateColumns;
		local padding = 0;
		local compactionMargin = 100;
		rootDescription:SetGridMode(MenuConstants.VerticalGridDirection, columns, padding, compactionMargin);
		rootDescription:AddMenuAcquiredCallback(function(menu)
			menu:SetScale(self.Dropdown:GetEffectiveScale());
			PlaySound(SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_CLICK);
		end);

		local function IsSelected(choiceData)
			return choiceData.fixtureID == selectedFixtureID;
		end

		local function CanSelect(choiceData)
			return not choiceData.isLocked;
		end

		local function OnSelect(choiceData, menuInputData, menu)
			C_HouseExterior.SelectCoreFixtureOption(choiceData.fixtureID);
		end

		local function FinalizeLayout(button, description, menu, columns, rows)
			-- Frames have size overrides if their containing menu has multiple columns.
			local hasMultipleColumns = columns > 1;
			button:FinalizeLayout(hasMultipleColumns, hasALockedChoice);
			self:MarkDirty();
		end

		for choiceIndex, choiceData in ipairs(fixtureOptions) do
			choiceData.ineligibleChoice = choiceData.isLocked;
			if choiceData.isLocked then
				choiceData.lockedText = HOUSING_EXTERIOR_CUSTOMIZATION_LOCKED_TOOLTIP;
			end

			local entryDescription = rootDescription:CreateTemplate("HouseExteriorOptionDropdownElementTemplate");
			entryDescription:AddInitializer(function(button, description, menu)
				local selected = IsSelected(choiceData);

				button:SetScript("OnClick", function(button, buttonName)
					if not selected then
						description:Pick(MenuInputContext.MouseButton, buttonName);
						PlaySound(SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION);
					end
				end);
				
				button:Init(choiceData, choiceIndex, selected, hasAnyFailedReqs, hasAnyLockedChoices);

				--[[
				We will have 2 Layout() calls. One for the reference width, and another to account
				for the column count changing in FinalizeLayout below.
				]]--
				button:Layout();
			end);

			entryDescription:SetOnEnter(CustomizationDropdownElementMixin.OnEnter);
			entryDescription:SetOnLeave(CustomizationDropdownElementMixin.OnLeave);
			entryDescription:SetIsSelected(IsSelected);
			entryDescription:SetCanSelect(CanSelect);
			entryDescription:SetResponder(OnSelect);
			entryDescription:SetRadio(true);
			entryDescription:SetData(choiceData);
			entryDescription:SetFinalizeGridLayout(FinalizeLayout);
			MenuUtil.SetElementText(entryDescription, choiceData.name);
		end
	end);

	self:MarkDirty();
	self:Show();
end

-- List of non-core fixture options
HouseExteriorFixtureOptionListMixin = {};

function HouseExteriorFixtureOptionListMixin:OnLoad()
	self.RemoveButton:SetScript("OnClick", function ()
		if self.fixturePointInfo and self.fixturePointInfo.canSelectionBeRemoved then
			C_HouseExterior.RemoveFixtureFromSelectedPoint();
			C_HouseExterior.CancelActiveExteriorEditing();

			PlaySound(SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION_NONE);
		end
	end);

	self.optionElementPool = CreateFramePool("BUTTON", self, "HouseExteriorOptionElementTemplate");
end

function HouseExteriorFixtureOptionListMixin:GetFixturePointInfo()
	return self.fixturePointInfo;
end

function HouseExteriorFixtureOptionListMixin:HasAnyLockedChoices()
	for _, fixtureOption in ipairs(self.fixturePointInfo.fixtureOptions) do
		if fixtureOption.isLocked then
			return true;
		end
	end
	return false;
end

local FixtureTypeToSoundKit = {
	["Door"] = SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION_DOOR,
	["Roof Window"] = SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION_ROOF_WINDOW,
	["Window"] = SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION_WINDOW,
	["Tower"] = SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION_TOWER,
	["Chimney"] = SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION_CHIMNEY,
};

function HouseExteriorFixtureOptionListMixin:ShowFixturePointInfo(fixturePointInfo)
	self.fixturePointInfo = fixturePointInfo;

	-- Sort by type to group options of the same type together
	table.sort (self.fixturePointInfo.fixtureOptions, function (o1, o2)
		if o1.typeID ~= o2.typeID then
			return o1.typeID < o2.typeID;
		end
		return o1.name < o2.name;
	end);

	local hasAnyLockedChoices = self:HasAnyLockedChoices();
	local hasAnyFailedReqs = hasAnyLockedChoices; -- Right now we have no ineligible choices that aren't also just locked

	local isNothingSelected = not self.fixturePointInfo.selectedFixtureID;
	local isRemoveDisabled = not isNothingSelected and not self.fixturePointInfo.canSelectionBeRemoved;

	local removeButtonData = {
		name = HOUSING_EXTERIOR_CUSTOMIZATION_FIXTURE_NONE_OPTION, choiceIndex = 1,
		ineligibleChoice = isRemoveDisabled, isLocked = isRemoveDisabled,
		lockedText = isRemoveDisabled and HOUSING_EXTERIOR_CUSTOMIZATION_CANT_REMOVE or nil,
	};
	
	self.RemoveButton:Init(removeButtonData, 1, isNothingSelected, hasAnyFailedReqs, hasAnyLockedChoices);
	self.RemoveButton:Show();
	self.RemoveButton:Layout();

	for index, fixtureOption in ipairs(self.fixturePointInfo.fixtureOptions) do
		fixtureOption.ineligibleChoice = fixtureOption.isLocked;
		if fixtureOption.isLocked then
			fixtureOption.lockedText = HOUSING_EXTERIOR_CUSTOMIZATION_LOCKED_TOOLTIP;
		end

		local isSelected = fixtureOption.fixtureID == self.fixturePointInfo.selectedFixtureID;
		local elementButton = self.optionElementPool:Acquire();
		elementButton.layoutIndex = index + 1; -- Offset layout indices by 1 for the "None" remove button entry
		elementButton:SetScript("OnClick", function(button, buttonName)
			if not isSelected and not fixtureOption.isLocked then
				C_HouseExterior.SelectFixtureOption(fixtureOption.fixtureID);

				local soundKit = FixtureTypeToSoundKit[fixtureOption.typeName] or SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION;
				PlaySound(soundKit);
			end
		end);
		elementButton:Init(fixtureOption, index + 1, isSelected, hasAnyFailedReqs, hasAnyLockedChoices);
		elementButton:Show();
		elementButton:Layout();
	end

	local hasMultipleColumns = false;
	self.RemoveButton:FinalizeLayout(hasMultipleColumns, hasAnyLockedChoices)
	for elementButton in self.optionElementPool:EnumerateActive() do
		elementButton:FinalizeLayout(hasMultipleColumns, hasAnyLockedChoices);
	end

	self:Layout();
	self:Show();
end

function HouseExteriorFixtureOptionListMixin:ClearAndHide()
	self.fixturePointInfo = nil;
	self.optionElementPool:ReleaseAll();
	self:Hide();
end
