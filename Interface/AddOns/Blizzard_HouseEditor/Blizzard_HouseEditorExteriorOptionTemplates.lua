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
	self.selectedOptionID = nil;
	self.options = nil;
end

function HouseExteriorOptionDropdownMixin:HasAnyLockedChoices()
	for _, option in ipairs(self.options) do
		if option.isLocked then
			return true;
		end
	end
	return false;
end

function HouseExteriorOptionDropdownMixin:CanSelectChoice(choiceData)
	return not choiceData.isLocked;
end

function HouseExteriorOptionDropdownMixin:IsChoiceSelected(choiceData)
	-- Required override
	assert(false);
end

function HouseExteriorOptionDropdownMixin:OnSelectChoice(choiceData)
	-- Required override
	assert(false);
end

function HouseExteriorOptionDropdownMixin:ShowOptions(selectedOptionID, options)
	self.selectedOptionID = selectedOptionID;
	self.options = options;

	local hasAnyLockedChoices = self:HasAnyLockedChoices();
	local hasAnyFailedReqs = hasAnyLockedChoices; -- For now we don't display any ineligible choices, just locked

	local defaultLockedTooltip = self:GetDefaultLockedTooltip();

	self.Dropdown:SetEnabled(true);
	self.Dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag(self:GetDropdownTag());

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
			return self:IsChoiceSelected(choiceData);
		end

		local function CanSelect(choiceData)
			return self:CanSelectChoice(choiceData);
		end

		local function OnSelect(choiceData, menuInputData, menu)
			self:OnSelectChoice(choiceData);
		end

		local function FinalizeLayout(button, description, menu, columns, rows)
			-- Frames have size overrides if their containing menu has multiple columns.
			local hasMultipleColumns = columns > 1;
			button:FinalizeLayout(hasMultipleColumns, hasALockedChoice);
			self:MarkDirty();
		end

		for choiceIndex, choiceData in ipairs(options) do
			choiceData.ineligibleChoice = choiceData.isLocked;
			if choiceData.isLocked then
				if choiceData.lockReasonString and choiceData.lockReasonString ~= "" then
					choiceData.lockedText = choiceData.lockReasonString;
				else
					choiceData.lockedText = defaultLockedTooltip;
				end
			end

			local entryDescription = rootDescription:CreateTemplate("HouseExteriorOptionDropdownElementTemplate");
			entryDescription:AddInitializer(function(button, description, menu)
				local selected = IsSelected(choiceData);

				button:SetScript("OnClick", function(button, buttonName)
					if not selected then
						description:Pick(MenuInputContext.MouseButton, buttonName);
						if not choiceData.isNoneOption then
							PlaySound(SOUNDKIT.HOUSING_EXTERIOR_CUSTOMIZATION_DROPDOWN_SELECT_OPTION);
						end
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

----------------- Exterior Type Dropdown -----------------
-- Inherits HouseExteriorOptionDropdownTemplate
HouseExteriorTypeDropdownMixin = {};

function HouseExteriorTypeDropdownMixin:GetDropdownTag()
	return "HOUSE_EXTERIOR_TYPE_OPTIONS_MENU";
end

function HouseExteriorTypeDropdownMixin:GetDefaultLockedTooltip()
	return HOUSING_EXTERIOR_CUSTOMIZATION_LOCKED_TOOLTIP;
end

function HouseExteriorTypeDropdownMixin:IsChoiceSelected(choiceData)
	return choiceData.houseExteriorTypeID == self.selectedOptionID;
end

function HouseExteriorTypeDropdownMixin:OnSelectChoice(choiceData)
	C_HouseExterior.SetHouseExteriorType(choiceData.houseExteriorTypeID);
end

function HouseExteriorTypeDropdownMixin:ShowHouseExteriorTypeOptions(selectedExteriorTypeID, exteriorTypeOptions)
	self:ShowOptions(selectedExteriorTypeID, exteriorTypeOptions);
end

----------------- Exterior Size Dropdown -----------------
-- Inherits HouseExteriorOptionDropdownTemplate
HouseExteriorSizeDropdownMixin = {};

function HouseExteriorSizeDropdownMixin:GetDropdownTag()
	return "HOUSE_EXTERIOR_TYPE_OPTIONS_MENU";
end

function HouseExteriorSizeDropdownMixin:GetDefaultLockedTooltip()
	return HOUSING_EXTERIOR_CUSTOMIZATION_SIZE_LOCKED_TOOLTIP;
end

function HouseExteriorSizeDropdownMixin:IsChoiceSelected(choiceData)
	return choiceData.size == self.selectedOptionID;
end

function HouseExteriorSizeDropdownMixin:OnSelectChoice(choiceData)
	C_HouseExterior.SetHouseExteriorSize(choiceData.size);
end

function HouseExteriorSizeDropdownMixin:ShowHouseExteriorSizeOptions(selectedSize, exteriorSizeOptions)
	self:ShowOptions(selectedSize, exteriorSizeOptions);
end

----------------- Core Fixture Dropdown -----------------
-- Inherits HouseExteriorOptionDropdownTemplate
HouseExteriorCoreFixtureDropdownMixin = {};

function HouseExteriorCoreFixtureDropdownMixin:GetDropdownTag()
	return "HOUSE_EXTERIOR_CORE_FIXTURE_OPTIONS_MENU";
end

function HouseExteriorCoreFixtureDropdownMixin:GetDefaultLockedTooltip()
	return HOUSING_EXTERIOR_CUSTOMIZATION_LOCKED_TOOLTIP;
end

function HouseExteriorCoreFixtureDropdownMixin:IsChoiceSelected(choiceData)
	return choiceData.fixtureID == self.selectedOptionID;
end

function HouseExteriorCoreFixtureDropdownMixin:OnSelectChoice(choiceData)
	C_HouseExterior.SelectCoreFixtureOption(choiceData.fixtureID);
end

function HouseExteriorCoreFixtureDropdownMixin:ShowCoreFixtureInfo(selectedFixtureID, fixtureOptions, useColorNames)
	-- TODO: Remove all this once we have real color name data
	local houseTypeID = C_HouseExterior.GetCurrentHouseExteriorType();
	local typeSpecificNames = houseTypeID and HouseExteriorColorNames.TypeSpecific[houseTypeID] or nil;
	for choiceIndex, choiceData in ipairs(fixtureOptions) do
		if useColorNames then
			-- TODO: If/when we can redo the data setup for exterior color definitions, ideally color name is part of the choice struct, rather than the color ID
			local overrideColorName = typeSpecificNames and typeSpecificNames[choiceData.colorID];
			local colorName = overrideColorName or HouseExteriorColorNames.Default[choiceData.colorID];
			if colorName then
				choiceData.name = colorName;
			end
		end
	end

	self:ShowOptions(selectedFixtureID, fixtureOptions);
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
	local isSameHookpoint = self.fixturePointInfo and self.fixturePointInfo.ownerHash == fixturePointInfo.ownerHash;
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

	local scrollBehavior = isSameHookpoint and ScrollBoxConstants.RetainScrollPosition or ScrollBoxConstants.DiscardScrollPosition;
	self.ScrollBox:SetDataProvider(dataProvider, scrollBehavior);

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

-- TODO: Create some new data & stop using the ExteriorComponent "COLOR" field for player-facing color names altogether
-- It is not meant for the kind of granular color specificity we're looking for here
HouseExteriorColorNames = {
	Default = {
		[7] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_BLACK, --Black - "Charcoal"
		[8] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_BLUE, --Blue "Ocean"
		[9] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_BROWN, --Brown "nutmeg"
		[21] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_GREEN, --Green "Forest"
		[32] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_ORANGE, --Orange "Rust"
		[36] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_PURPLE, --Purple "Violet"
		[37] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_RED, --Red "Crimson"
		[44] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_YELLOW, --Yellow "Mustard"
	},
	TypeSpecific = {
		[55] = { -- Night Elf
			[34] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_PLUM, --Pink "Plum"
			[40] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_BLUE, --Teal "Ocean"
			[44] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_OCHRE, --Yellow "Ochre"
		},
		[56] = { -- Blood Elf
			[0] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_RED, --None "Crimson"
			[8] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_SAPPHIRE, --Blue "Sapphire"
			[21] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_EMERALD, --Green "Emerald"
			[40] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_BLUE, --Teal "Ocean"
			[42] = HOUSING_EXTERIOR_CUSTOMIZATION_COLOR_PLUM, --Violet "Plum"
		},
	},
};
