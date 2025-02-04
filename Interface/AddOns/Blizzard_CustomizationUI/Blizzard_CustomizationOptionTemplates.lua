----------------- Option Frame Base -----------------

CustomizationOptionFrameBaseMixin = CreateFromMixins(CustomizationContentFrameMixin);

function CustomizationOptionFrameBaseMixin:SetupOption(optionData)
	-- Required Override
	assert(false);
end

function CustomizationOptionFrameBaseMixin:SetOptionData(optionData)
	self.optionData = optionData;
end

function CustomizationOptionFrameBaseMixin:GetOptionData()
	return self.optionData;
end

function CustomizationOptionFrameBaseMixin:RefreshOption()
	self:SetupOption(self:GetOptionData());
end

function CustomizationOptionFrameBaseMixin:GetCurrentChoiceIndex()
	return self:GetOptionData().currentChoiceIndex;
end

function CustomizationOptionFrameBaseMixin:HasChoice()
	return self:GetCurrentChoice() ~= nil;
end

function CustomizationOptionFrameBaseMixin:GetChoice(index)
	if index then
		return self:GetOptionData().choices[index];
	end
end

function CustomizationOptionFrameBaseMixin:GetCurrentChoice()
	return self:GetChoice(self:GetCurrentChoiceIndex());
end

function CustomizationOptionFrameBaseMixin:HasSound()
	return self:GetOptionData().isSound;
end

function CustomizationOptionFrameBaseMixin:GetSoundKit(entryOverride)
	if self:HasSound() then
		if entryOverride then
			return entryOverride.choiceData.soundKit;
		end

		local choice = self:GetCurrentChoice();
		if choice then
			return choice.soundKit;
		end
	end
end

function CustomizationOptionFrameBaseMixin:SetupAudio(audioInterface)
	assert(self:HasSound());
	self:ShutdownAudio();

	audioInterface:SetParent(self);
	audioInterface:SetPoint("RIGHT", self.Label, "LEFT", -40, 0);
	audioInterface:Show();
	audioInterface:SetupAudio(self:GetSoundKit());
	self.audioInterface = audioInterface;
end

function CustomizationOptionFrameBaseMixin:ShutdownAudio()
	local interface = self.audioInterface;
	self.audioInterface = nil;

	if interface then
		interface:StopAudio();
	end
end

function CustomizationOptionFrameBaseMixin:GetAudioInterface()
	return self.audioInterface;
end

function CustomizationOptionFrameBaseMixin:GetDebugName()
	if not self.optionData then
		return nil;
	end
	local index = self.optionData.orderIndex or 0;
	local name = self.optionData.name or "UNNAMED";
	return string.format("[%02d] %s", index, name);
end

----------------- Option Slider -----------------

CustomizationOptionSliderMixin = CreateFromMixins(CustomizationOptionFrameBaseMixin, SliderWithButtonsAndLabelMixin, CustomizationFrameWithTooltipMixin);

function CustomizationOptionSliderMixin:OnLoad()
	CustomizationFrameWithTooltipMixin.OnLoad(self);
end

function CustomizationOptionSliderMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMLEFT", self.Slider.Thumb, "TOPRIGHT", self.tooltipXOffset, self.tooltipYOffset);
end

function CustomizationOptionSliderMixin:SetupOption(optionData)
	self:SetOptionData(optionData);
	self.currentChoice = nil;

	local minValue = 1;
	local maxValue = #optionData.choices;
	local valueStep = 1;
	self:SetupSlider(minValue, maxValue, optionData.currentChoiceIndex, valueStep, optionData.name);
end

function CustomizationOptionSliderMixin:OnSliderValueChanged(value, userInput)
	SliderWithButtonsAndLabelMixin.OnSliderValueChanged(self, value);

	local newChoice = Round(value);
	local newChoiceData = self.optionData.choices[newChoice];

	local needToUpdateModel = false;
	if userInput and self.currentChoice ~= newChoice then
		needToUpdateModel = true;
	end

	self.currentChoice = newChoice;

	local currentChoiceTooltip = (newChoiceData.name ~= "") and CHARACTER_CUSTOMIZATION_CHOICE_TOOLTIP:format(newChoice, newChoiceData.name) or newChoice;

	self:ClearTooltipLines();
	self:AddTooltipLine(currentChoiceTooltip);

	if CustomizationUtil.ShouldShowDebugTooltipInfo() then
		self:AddBlankTooltipLine();
		self:AddTooltipLine("Option ID: "..self.optionData.id, HIGHLIGHT_FONT_COLOR);
		self:AddTooltipLine("Choice ID: "..newChoiceData.id, HIGHLIGHT_FONT_COLOR);
	end

	local mouseFoci = GetMouseFoci();
	for _, mouseFocus in ipairs(mouseFoci) do
	if DoesAncestryInclude(self, mouseFocus) and (mouseFocus:GetObjectType() ~= "Button") then
		self:OnEnter();
			break;
		end
	end

	if needToUpdateModel then
		self:GetCustomizationFrame():SetCustomizationChoice(self.optionData.id, newChoiceData.id);
	end
end

----------------- Option Check Button -----------------

CustomizationOptionCheckButtonMixin = CreateFromMixins(CustomizationOptionFrameBaseMixin, CustomizationFrameWithTooltipMixin);

function CustomizationOptionCheckButtonMixin:CustomizationOptionCheckButton_OnLoad()
	self.Button:SetScript("OnClick", GenerateClosure(self.OnCheckButtonClick, self));
	self.Button:SetScript("OnEnter", GenerateClosure(self.OnEnter, self));
	self.Button:SetScript("OnLeave", GenerateClosure(self.OnLeave, self));
end

function CustomizationOptionCheckButtonMixin:SetupOption(optionData)
	self:SetOptionData(optionData);
	self.checked = (optionData.currentChoiceIndex == 2);

	self.New:SetShown(optionData.hasNewChoices);

	if CustomizationUtil.ShouldShowDebugTooltipInfo() then
		self:ClearTooltipLines();
		self:AddTooltipLine("Option ID: "..self.optionData.id, HIGHLIGHT_FONT_COLOR);
		self:AddTooltipLine("Choice ID: "..self.optionData.choices[optionData.currentChoiceIndex].id, HIGHLIGHT_FONT_COLOR);
	end

	self.Label:SetText(optionData.name);
	self.Button:SetChecked(self.checked);
end

function CustomizationOptionCheckButtonMixin:OnCheckButtonClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self.checked = not self.checked;

	local newChoiceIndex = self.checked and 2 or 1;
	local newChoiceData = self.optionData.choices[newChoiceIndex];

	local customizationFrame = self:GetCustomizationFrame();

	if self.New:IsShown() then
		customizationFrame:MarkCustomizationOptionAsSeen(self.optionData.id);
	end

	customizationFrame:SetCustomizationChoice(self.optionData.id, newChoiceData.id);
end

----------------- Dropdown with Steppers + Label -----------------

-- Expects to inherit DropdownWithSteppersAndLabelTemplate

CustomizationDropdownWithSteppersAndLabelMixin = CreateFromMixins(CustomizationOptionFrameBaseMixin, CustomizationFrameWithTooltipMixin);

function CustomizationDropdownWithSteppersAndLabelMixin:OnLoad()
	CustomizationFrameWithTooltipMixin.OnLoad(self);
	DropdownWithSteppersAndLabelMixin.OnLoad(self);

	self.Dropdown:SetMenuAnchor(AnchorUtil.CreateAnchor("TOPRIGHT", self.Dropdown, "BOTTOMRIGHT"));
	self.Dropdown:EnableMouseWheel(true);

	EventRegistry:RegisterCallback("Customization.SetMissingOptionWarningEnabled", self.SetMissingOptionWarningEnabled, self);
end

function CustomizationDropdownWithSteppersAndLabelMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMRIGHT", self.Dropdown, "TOPLEFT", self.tooltipXOffset, self.tooltipYOffset);
end

do
	local function GetChoiceConstraints(optionData)
		local hasAFailedReq = false;
		local hasALockedChoice = false;
		for choiceIndex, choiceData in ipairs(optionData.choices) do
			if choiceData.ineligibleChoice then
				hasAFailedReq = true;
			end
			if choiceData.isLocked then
				hasALockedChoice = true;
			end
		end
		return hasAFailedReq, hasALockedChoice;
	end
		
	local function CanSelect(choiceData)
		return (not choiceData.disabled) and (not choiceData.isLocked);
	end
	
	function CustomizationDropdownWithSteppersAndLabelMixin:SetupOption(optionData)
		self:SetOptionData(optionData);
	
		self:SetText(optionData.name);
	
		self.New:SetShown(optionData.hasNewChoices);
	
		self:ClearTooltipLines();
	
		local currentTooltip = self.Dropdown.SelectionDetails:GetTooltipText();
		if currentTooltip then
			self:AddTooltipLine(currentTooltip, HIGHLIGHT_FONT_COLOR);
		end

		local currentChoice = optionData.choices[optionData.currentChoiceIndex];
		if CustomizationUtil.ShouldShowDebugTooltipInfo() then
			if currentTooltip then
				self:AddBlankTooltipLine();
			end
			self:AddTooltipLine("Option ID: "..optionData.id, HIGHLIGHT_FONT_COLOR);
			if currentChoice then
				self:AddTooltipLine("Choice ID: "..currentChoice.id, HIGHLIGHT_FONT_COLOR);
			end
		end

		local rootDescription = MenuUtil.CreateRootMenuDescription(MenuStyle2Mixin);
	
		--[[
		The compositor is disabled here for multiple reasons:
		1) We're not concerned with these frames becoming tainted as there shouldn't be any
		functionality we need to protect in customization.
		2) The compositor isn't being leveraged anyways: the contents of these frames are
		in the CustomizationDropdownElementTemplate template.
		3) Performance concerns. Customization regenerates all options without consideration of
		the options actually changing, and since compositor isn't used here, it adds to the cumulatively
		large overhead of rebuilding all of the menu descriptions.
		]]--
		rootDescription:DisableCompositor();
	
		-- Again for performance reasons.
		rootDescription:DisableReacquireFrames();
	
		local columns = MenuConstants.AutoCalculateColumns;
		local padding = 0;
		local compactionMargin = 100;
		rootDescription:SetGridMode(MenuConstants.VerticalGridDirection, columns, padding, compactionMargin);

		rootDescription:AddMenuAcquiredCallback(function(menu)
			menu:SetScale(self.Dropdown:GetEffectiveScale());
		end);
	
		local hasAFailedReq, hasALockedChoice = GetChoiceConstraints(optionData);
		local customizationFrame = self:GetCustomizationFrame();
	
		--[[
		These functions cannot be defined as file locals because optionData, hasAFailedReq and hasALockedChoice
		and 'self' all require capture.
		]]

		local function IsSelected(choiceData)
			return optionData.currentChoiceIndex == choiceData.choiceIndex;
		end
	
		local function OnSelect(choiceData, menuInputData, menu)
			RunNextFrame(function() 
				customizationFrame.previewIsDirty = false;
				if choiceData.isNew then
					-- Choice may not have been previewed if player selected it via steppers
					customizationFrame:MarkCustomizationChoiceAsSeen(choiceData.id);
				end
				customizationFrame:SetCustomizationChoice(optionData.id, choiceData.id);
			end);
	
			-- If the selection was done via mouse-wheel, reinitialize and keep the menu open.
			if menuInputData.context == MenuInputContext.MouseWheel then
				return MenuResponse.Refresh;
			end
		end
		
		local function OnEnter(button)
			local description = button:GetElementDescription();
			local choiceData = description:GetData();
			customizationFrame:PreviewChoice(optionData, choiceData);

			local showDebugTooltipInfo = CustomizationUtil.ShouldShowDebugTooltipInfo();
	
			local tooltipText, tooltipLockedText = button.SelectionDetails:GetTooltipText();
			if tooltipText or showDebugTooltipInfo then
				local tooltip = self:GetAppropriateTooltip();

				tooltip:SetOwner(self, "ANCHOR_NONE");
					tooltip:SetPoint("BOTTOMRIGHT", button, "TOPLEFT", 0, 0);

				if tooltipText then
					GameTooltip_AddHighlightLine(tooltip, tooltipText);
				end

				if tooltipLockedText then
					GameTooltip_AddNormalLine(tooltip, tooltipLockedText);
				end

				if showDebugTooltipInfo then
					if tooltipText then
						GameTooltip_AddBlankLineToTooltip(tooltip, tooltipText);
					end

					GameTooltip_AddHighlightLine(tooltip, "Choice ID: "..choiceData.id);
				end

				tooltip:Show();
			end

			if self:HasSound() and not IsSelected(choiceData) then
				self:GetAudioInterface():PlayAudio(self:GetSoundKit(choiceData));
			end
	
			local selected = IsSelected(choiceData);
			if not selected then
				button.HighlightBGTex:SetAlpha(0.15);
				button.SelectionDetails.SelectionNumber:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
				button.SelectionDetails.SelectionName:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
			end
		end

		local function OnLeave(button)
			customizationFrame.previewIsDirty = true;

			local tooltip = self:GetAppropriateTooltip();
			tooltip:Hide();
				
			if self:GetAudioInterface() then
				self:GetAudioInterface():StopAudio();
			end
			
			local description = button:GetElementDescription();
			local choiceData = description:GetData();
			local selected = IsSelected(choiceData);
			if not selected then
				button.HighlightBGTex:SetAlpha(0);
				button.SelectionDetails:UpdateFontColors(choiceData, selected, hasAFailedReq);
			end
		end
	
		local function FinalizeLayout(button, description, menu, columns, rows)
			-- Frames have size overrides if their containing menu has multiple columns.
			local hasMultipleColumns = columns > 1;
			button.SelectionDetails:AdjustWidth(hasMultipleColumns, hasALockedChoice);
			button:Layout();
		end

		for choiceIndex, choiceData in ipairs(optionData.choices) do
			choiceData.choiceIndex = choiceIndex;

			local optionDescription = rootDescription:CreateTemplate("CustomizationDropdownElementTemplate");
			optionDescription:AddInitializer(function(button, description, menu)
				button.HighlightBGTex:SetAlpha(0);
	
				button:SetScript("OnClick", function(button, buttonName)
					description:Pick(MenuInputContext.MouseButton, buttonName);
				end);
				
				local selected = IsSelected(choiceData);
				
				button.SelectionDetails:Init(choiceData, choiceIndex, selected, hasAFailedReq, hasALockedChoice);

				--[[
				We will have 2 Layout() calls. One for the reference width, and another to account
				for the column count changing in FinalizeLayout below.
				]]--
				button:Layout();
			end);

			optionDescription:SetOnEnter(OnEnter);
			optionDescription:SetOnLeave(OnLeave);
			optionDescription:SetIsSelected(IsSelected);
			optionDescription:SetCanSelect(CanSelect);
			optionDescription:SetResponder(OnSelect);
			optionDescription:SetRadio(true);
			optionDescription:SetData(choiceData);
			optionDescription:SetFinalizeGridLayout(FinalizeLayout);
		end
		
		-- Setup the dropdown button.
		do
			--[[
			Dropdown shares the same details frame as the elements, but expects 'selected' and
			'hasAFailedReq' to be always be false.
			]]--

			local selected = false;
			local failedReq = false;
			local clampNameSize = true;
			self.Dropdown.SelectionDetails:Init(currentChoice, optionData.currentChoiceIndex, selected, failedReq, clampNameSize);
			self.Dropdown.SelectionDetails:Layout();
		end
		
		-- TODO Should be converted to a generator function.
		self.Dropdown:RegisterMenu(rootDescription);
	end
end

function CustomizationDropdownWithSteppersAndLabelMixin:GetOrCreateWarningTexture(enabled)
	if not self.Dropdown.WarningTexture then
		self.Dropdown.WarningTexture = self.Dropdown:CreateTexture(nil, nil, "CustomizationMissingOptionWarningTemplate");
		self.Dropdown.WarningTexture:ClearAllPoints();
		self.Dropdown.WarningTexture:SetPoint("BOTTOM", self.Dropdown, "TOP", 0, -23);
	end

	return self:GetWarningTexture();
end

function CustomizationDropdownWithSteppersAndLabelMixin:GetWarningTexture()
	return self.Dropdown.WarningTexture;
end

function CustomizationDropdownWithSteppersAndLabelMixin:SetMissingOptionWarningEnabled(externallyEnabled)
	local showWarning = externallyEnabled and not self:HasChoice();
	if showWarning then
		self:GetOrCreateWarningTexture():Show();
		self:GetWarningTexture().PulseAnim:Play();
	elseif self:GetWarningTexture() then
		self:GetWarningTexture():Hide();
	end
end


----------------- Dropdown Element Details -----------------

local CUSTOMIZATION_LOCK_WIDTH = 24;

CustomizationDropdownElementDetailsMixin = {};

function CustomizationDropdownElementDetailsMixin:GetTooltipText()
	local name;
	if self.lockedText or (self.SelectionName:IsShown() and self.SelectionName:IsTruncated()) then
		name = self.name;
	end

	if not self.lockedText then
		return name;
	end

	return name, BARBERSHOP_CUSTOMIZATION_SOURCE_FORMAT:format(self.lockedText);
end

function CustomizationDropdownElementDetailsMixin:AdjustWidth(multipleColumns, hasALockedChoice)
	local width = 116;
	if multipleColumns then
	if self.ColorSwatch1:IsShown() or self.ColorSwatch2:IsShown() then
			width = self.SelectionNumber:GetWidth() + self.ColorSwatch2:GetWidth() + 18;
	elseif self.SelectionName:IsShown() then
			width = 108;
	else
			width = 42;
		end
	end

	if hasALockedChoice then
		width = width + CUSTOMIZATION_LOCK_WIDTH;
	end

	self:SetWidth(Round(width));
end

local function GetNormalSelectionTextFontColor(choiceData, isSelected)
	if isSelected then
		return NORMAL_FONT_COLOR;
	else
		return DISABLED_FONT_COLOR;
	end
end

local function GetFailedReqSelectionTextFontColor(choiceData, isSelected)
	if isSelected then
		return NORMAL_FONT_COLOR;
	elseif choiceData.ineligibleChoice then
		return CUSTOMIZATION_CHOICE_INELIGIBLE_COLOR;
	else
		return CUSTOMIZATION_CHOICE_ELIGIBLE_COLOR;
	end
end

function CustomizationDropdownElementDetailsMixin:GetFontColors(choiceData, isSelected, hasAFailedReq)
	if self.selectable then
		local fontColorFunction = hasAFailedReq and GetFailedReqSelectionTextFontColor or GetNormalSelectionTextFontColor;
		local fontColor = fontColorFunction(choiceData, isSelected);
		local showAsNew = (choiceData.isNew and self.selectable);
		if showAsNew then
			return fontColor, HIGHLIGHT_FONT_COLOR;
		else
			return fontColor, fontColor;
		end
	else
		return NORMAL_FONT_COLOR, NORMAL_FONT_COLOR;
	end
end

function CustomizationDropdownElementDetailsMixin:UpdateFontColors(choiceData, isSelected, hasAFailedReq)
	local nameColor, numberColor = self:GetFontColors(choiceData, isSelected, hasAFailedReq);
	self.SelectionName:SetTextColor(nameColor:GetRGB());
	self.SelectionNumber:SetTextColor(numberColor:GetRGB());
end

-- The FRIZQT font has a problemm with rendering 1 (or numbers starting with 1), which causes it to be off center
-- So, we have to detect that and manually bump it back into the center
local function startsWithOne(index)
	local indexString = tostring(index);
	return indexString:sub(1, 1) == "1";
end

function CustomizationDropdownElementDetailsMixin:SetShowAsNew(showAsNew)
	if showAsNew then
		self.SelectionNumber:SetShadowColor(NEW_FEATURE_SHADOW_COLOR:GetRGBA());

		local halfStringWidth = self.SelectionNumber:GetStringWidth() / 2;
		local extraOffset = startsWithOne(self.index) and 1 or 0;
		self.NewGlow:SetPoint("CENTER", self.SelectionNumber, "LEFT", halfStringWidth + extraOffset, -2);
		self.SelectionNumberBG:Show();
		self.NewGlow:Show();
	else
		self.SelectionNumber:SetShadowColor(BLACK_FONT_COLOR:GetRGBA());
		self.SelectionNumberBG:Hide();
		self.NewGlow:Hide();
	end
end

function CustomizationDropdownElementDetailsMixin:UpdateText(choiceData, isSelected, hasAFailedReq, hideNumber, hasColors)
	self:UpdateFontColors(choiceData, isSelected, hasAFailedReq);

	self.SelectionNumber:SetText(self.index);
	self.SelectionNumberBG:SetText(self.index);

	if hasColors then
		self.SelectionName:Hide();
		self.SelectionNumber:SetWidth(25);
		self.SelectionNumberBG:SetWidth(25);
	elseif choiceData.name ~= "" then
		self.SelectionName:Show();
		self.SelectionName:SetWidth(0);
		self.SelectionName:SetText(choiceData.name);

		-- Truncates selected customization text
		local margins = 2;
		local selectionNumberWidth = 25;
		local maxWidth = self:GetParent():GetWidth() - margins - (not hideNumber and selectionNumberWidth or 0);
		if self.SelectionName:GetWidth() > maxWidth then
			self.SelectionName:SetWidth(maxWidth);
		end

		self.SelectionNumber:SetWidth(selectionNumberWidth);
		self.SelectionNumberBG:SetWidth(selectionNumberWidth);
	else
		self.SelectionName:Hide();
		self.SelectionNumber:SetWidth(0);
		self.SelectionNumberBG:SetWidth(0);
	end

	self.SelectionNumber:SetShown(not hideNumber);

	local showAsNew = (self.selectable and not hideNumber and choiceData.isNew);
	self:SetShowAsNew(showAsNew);
end

function CustomizationDropdownElementDetailsMixin:Init(choiceData, index, isSelected, hasAFailedReq, hasALockedChoice, clampNameSize)
	if not index then
		self.SelectionName:SetText(CHARACTER_CUSTOMIZE_POPOUT_UNSELECTED_OPTION);
		self.SelectionName:Show();
		self.SelectionName:SetWidth(0);
		self.SelectionName:SetPoint("LEFT", self, "LEFT", 0, 0);
		self.SelectionNumber:Hide();
		self.SelectionNumberBG:Hide();
		self.ColorSwatch1:Hide();
		self.ColorSwatch1Glow:Hide();
		self.ColorSwatch2:Hide();
		self.ColorSwatch2Glow:Hide();
		self:SetShowAsNew(false);
		return;
	end

	self.name = choiceData.name;
	self.index = index;
	self.lockedText = choiceData.isLocked and choiceData.lockedText;

	local color1 = choiceData.swatchColor1 or choiceData.swatchColor2;
	local color2 = choiceData.swatchColor1 and choiceData.swatchColor2;
	if color1 then
		if color2 then
			self.ColorSwatch2:Show();
			self.ColorSwatch2Glow:Show();
			self.ColorSwatch2:SetVertexColor(color2:GetRGB());
			self.ColorSwatch1:SetAtlas("charactercreate-customize-palette-half");
		else
			self.ColorSwatch2:Hide();
			self.ColorSwatch2Glow:Hide();
			self.ColorSwatch1:SetAtlas("charactercreate-customize-palette");
		end

		self.ColorSwatch1:Show();
		self.ColorSwatch1Glow:Show();
		self.ColorSwatch1:SetVertexColor(color1:GetRGB());
	elseif choiceData.name ~= "" then
		self.ColorSwatch1:Hide();
		self.ColorSwatch1Glow:Hide();
		self.ColorSwatch2:Hide();
		self.ColorSwatch2Glow:Hide();
	else
		self.ColorSwatch1:Hide();
		self.ColorSwatch1Glow:Hide();
		self.ColorSwatch2:Hide();
		self.ColorSwatch2Glow:Hide();
	end

	self.ColorSelected:SetShown(self.selectable and color1 and isSelected);

	local hideNumber = (not self.selectable and (color1 or (choiceData.name ~= "")));
	if hideNumber then
		self.SelectionName:SetPoint("LEFT", self, "LEFT", 0, 0);
		self.ColorSwatch1:SetPoint("LEFT", self, "LEFT", 0, 0);
		self.ColorSwatch2:SetPoint("LEFT", self, "LEFT", 18, -2);
	else
		self.SelectionName:SetPoint("LEFT", self.SelectionNumber, "RIGHT", 0, 0);
		self.ColorSwatch1:SetPoint("LEFT", self.SelectionNumber, "RIGHT", 0, 0);
		self.ColorSwatch2:SetPoint("LEFT", self.SelectionNumber, "RIGHT", 18, -2);
	end

	self.LockIcon:SetShown(choiceData.isLocked);
	if self.selectable then
		if choiceData.isLocked then
			self.SelectionName:SetPoint("RIGHT", -CUSTOMIZATION_LOCK_WIDTH, 0);		
		else
			self.SelectionName:SetPoint("RIGHT", 0, 0);
		end
	end

	self:UpdateText(choiceData, isSelected, hasAFailedReq, hideNumber, color1);

	if clampNameSize then
		local maxNameWidth = 126;
		if self.SelectionName:GetWidth() > maxNameWidth then
			self.SelectionName:SetWidth(maxNameWidth);
		end
	end
end


----------------- Dropdown Button -----------------

CustomizationDropdownMixin = {};

do
	local xy = 1;
	function CustomizationDropdownMixin:OnMouseDown()
		if WowStyle1FilterDropdownMixin.OnMouseDown(self) then
			self.SelectionDetails:AdjustPointsOffset(xy, -xy);
		end
	end

	function CustomizationDropdownMixin:OnMouseUp()
		if WowStyle1FilterDropdownMixin.OnMouseUp(self) then
			self.SelectionDetails:AdjustPointsOffset(-xy, xy);
		end
	end
end

function CustomizationDropdownMixin:OnDisable()
	WowStyle1FilterDropdownMixin.OnDisable(self);

	self.SelectionDetails:ClearPointsOffset();
end


----------------- Dropdown Button -----------------

CustomizationDropdownElementMixin = {};

function CustomizationDropdownElementMixin:OnLoad()
	self.SelectionDetails.SelectionName:SetPoint("RIGHT");
end