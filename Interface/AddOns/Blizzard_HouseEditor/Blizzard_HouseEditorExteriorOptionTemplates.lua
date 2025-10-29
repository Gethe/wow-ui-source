----------------- Base choice entry for dropdown use -----------------
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


----------------- Base Dropdown -----------------
HouseExteriorOptionDropdownMixin = {};

function HouseExteriorOptionDropdownMixin:OnLoad()
	self.Label:SetText(self.label);
end

function HouseExteriorOptionDropdownMixin:ClearAndHide()
	self.Dropdown:CloseMenu();
	self:Hide();
	self:MarkDirty();
end

----------------- Placeholder Dropdown -----------------
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

----------------- Core Fixture Dropdown -----------------
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

function HouseExteriorCoreFixtureDropdownMixin:ShowCoreFixtureInfo(selectedFixtureID, fixtureOptions, useColorNames)
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
			if useColorNames then
				-- TODO: If/when we can redo the data setup for exterior color definitions, ideally color name is part of the choice struct, rather than the color ID
				local colorName = HousingExteriorColorStrings[choiceData.colorID];
				if colorName then
					choiceData.name = colorName;
				end
			end

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

----------------- Base choice entry for non-dropdown use -----------------
-- Inherits CustomizationElementTemplate
HouseExteriorOptionElementMixin = {};

function HouseExteriorOptionElementMixin:ExteriorEntryOnLoad()
	self.SelectionDetails:ClearAllPoints();
	self.SelectionDetails:SetPoint("LEFT", 15, 0);
	self.SelectionDetails:SetPoint("RIGHT");
end

-- Expected values
--	choiceData: choiceIndex, isNoneOption, fixtureID, typeName, name, ineligibleChoice, isLocked, lockedText
--	listStateData: isSelected, hasAFailedReq, hasALockedChoice
function HouseExteriorOptionElementMixin:Init(choiceData, listStateData)
	self.choiceData = choiceData;
	self.listStateData = listStateData;
	self.isSelected = listStateData.isSelected;
	self.SelectionDetails:SetSkipLockedTextFormat(true);
	CustomizationElementMixin.Init(self, choiceData, choiceData.choiceIndex, listStateData.isSelected, listStateData.hasAFailedReq, listStateData.hasALockedChoice);

	self:Layout();
	self:FinalizeLayout(false, listStateData.hasALockedChoice);
end

function HouseExteriorOptionElementMixin:Reset()
	self.choiceData = nil;
	self.isSelected = false;
end

local FixtureTypeToSoundKit = {
	["Door"] = SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION_DOOR,
	["Roof Window"] = SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION_ROOF_WINDOW,
	["Window"] = SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION_WINDOW,
	["Tower"] = SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION_TOWER,
	["Chimney"] = SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION_CHIMNEY,
};

function HouseExteriorOptionElementMixin:OnClick()
	if self.choiceData and not self.isSelected and not self.choiceData.isLocked then
		if self.choiceData.isNoneOption then
			C_HouseExterior.RemoveFixtureFromSelectedPoint();
			PlaySound(SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION_NONE);
		else
			C_HouseExterior.SelectFixtureOption(self.choiceData.fixtureID);
			local soundKit = FixtureTypeToSoundKit[self.choiceData.typeName] or SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION;
			PlaySound(soundKit);
		end
	end
end

function HouseExteriorOptionElementMixin:GetChoiceData()
	return self.choiceData or {};
end

function HouseExteriorOptionElementMixin:IsSelected()
	return self.isSelected;
end

function HouseExteriorOptionElementMixin:GetAppropriateTooltip()
	return GameTooltip;
end

----------------- Non-dropdown Choice List Mixin -----------------
HouseExteriorFixtureOptionListMixin = {};

function HouseExteriorFixtureOptionListMixin:OnLoad()
	self.CloseButton:SetScript("OnClick", function() 
		C_HouseExterior.CancelActiveExteriorEditing();
	end);

	local view = CreateScrollBoxListLinearView(self.topPadding, self.bottomPadding, self.leftPadding, self.rightPadding, self.horizontalSpacing, self.verticalSpacing);
	local function Initializer(frame, elementData)
		frame:Init(elementData.choiceData, elementData.listStateData);
	end
	local function Resetter(frame, elementData)
		frame:Reset();
	end
	view:SetElementInitializer("HouseExteriorOptionElementTemplate", Initializer);
	view:SetElementResetter(Resetter);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function HouseExteriorFixtureOptionListMixin:OnHide()
	PlaySound(SOUNDKIT.HOUSING_PLACE_HOUSE_CANCEL);
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

function HouseExteriorFixtureOptionListMixin:ShowFixturePointInfo(fixturePointInfo)
	self.fixturePointInfo = fixturePointInfo;

	local isAnythingSelected = self.fixturePointInfo.selectedFixtureID ~= nil;

	local headerText = isAnythingSelected and HOUSING_EXTERIOR_CUSTOMIZATION_HOOKPOINT_OCCUPIED_TOOLTIP or HOUSING_EXTERIOR_CUSTOMIZATION_HOOKPOINT_EMPTY_TOOLTIP;
	self.HeaderText:SetText(headerText);

	-- Sort by type to group options of the same type together
	table.sort (self.fixturePointInfo.fixtureOptions, function (o1, o2)
		if o1.typeID ~= o2.typeID then
			return o1.typeID < o2.typeID;
		end
		return o1.name < o2.name;
	end);

	local hasAnyLockedChoices = self:HasAnyLockedChoices();
	local hasAnyFailedReqs = hasAnyLockedChoices; -- Right now we have no ineligible choices that aren't also just locked
	
	local optionElements = {};

	local isRemoveDisabled = isAnythingSelected and not self.fixturePointInfo.canSelectionBeRemoved;
	local removeButtonData = {
		choiceData = {
			name = HOUSING_EXTERIOR_CUSTOMIZATION_FIXTURE_NONE_OPTION,
			choiceIndex = 1,
			ineligibleChoice = isRemoveDisabled,
			isLocked = isRemoveDisabled,
			lockedText = isRemoveDisabled and HOUSING_EXTERIOR_CUSTOMIZATION_CANT_REMOVE or nil,
			isNoneOption = true,
		},
		listStateData = {
			isSelected = not isAnythingSelected,
			hasAnyFailedReqs = hasAnyFailedReqs,
			hasAnyLockedChoices = hasAnyLockedChoices,
		}
	};
	table.insert(optionElements, removeButtonData);

	for index, fixtureOption in ipairs(self.fixturePointInfo.fixtureOptions) do
		local elementData = {};
		elementData.choiceData = fixtureOption;
		elementData.choiceData.choiceIndex = index + 1;
		elementData.choiceData.ineligibleChoice = elementData.choiceData.isLocked;
		if elementData.choiceData.isLocked and elementData.choiceData.lockReasonString then
			elementData.choiceData.lockedText = elementData.choiceData.lockReasonString;
		end

		elementData.listStateData = {
			isSelected = elementData.choiceData.fixtureID == self.fixturePointInfo.selectedFixtureID,
			hasAnyFailedReqs = hasAnyFailedReqs,
			hasAnyLockedChoices = hasAnyLockedChoices,
		};

		table.insert(optionElements, elementData);
	end

	local dataProvider = CreateDataProvider(optionElements);

	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	self:Show();
end

function HouseExteriorFixtureOptionListMixin:ClearData()
	self.fixturePointInfo = nil;
	self.ScrollBox:RemoveDataProvider();
end

function HouseExteriorFixtureOptionListMixin:ClearAndHide()
	self:ClearData();
	self:Hide();
end
