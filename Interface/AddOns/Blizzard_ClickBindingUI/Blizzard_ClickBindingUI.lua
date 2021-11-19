local ButtonStrings = {
	LeftButton = LEFT_BUTTON_STRING,
	Button1 = LEFT_BUTTON_STRING,
	RightButton = RIGHT_BUTTON_STRING,
	Button2 = RIGHT_BUTTON_STRING,
	MiddleButton = MIDDLE_BUTTON_STRING,
	Button3 = MIDDLE_BUTTON_STRING,
	Button4 = BUTTON_4_STRING,
	Button5 = BUTTON_5_STRING,
	Button6 = BUTTON_6_STRING,
	Button7 = BUTTON_7_STRING,
	Button8 = BUTTON_8_STRING,
	Button9 = BUTTON_9_STRING,
	Button10 = BUTTON_10_STRING,
	Button11 = BUTTON_11_STRING,
	Button12 = BUTTON_12_STRING,
	Button13 = BUTTON_13_STRING,
	Button14 = BUTTON_14_STRING,
	Button15 = BUTTON_15_STRING,
	Button16 = BUTTON_16_STRING,
	Button17 = BUTTON_17_STRING,
	Button18 = BUTTON_18_STRING,
	Button19 = BUTTON_19_STRING,
	Button20 = BUTTON_20_STRING,
	Button21 = BUTTON_21_STRING,
	Button22 = BUTTON_22_STRING,
	Button23 = BUTTON_23_STRING,
	Button24 = BUTTON_24_STRING,
	Button25 = BUTTON_25_STRING,
	Button26 = BUTTON_26_STRING,
	Button27 = BUTTON_27_STRING,
	Button28 = BUTTON_28_STRING,
	Button29 = BUTTON_29_STRING,
	Button30 = BUTTON_30_STRING,
	Button31 = BUTTON_31_STRING,
}

local ElementDataTypes = {
	DefaultsHeader = 1,
	InteractionBinding = 2,
	CustomsHeader = 3,
	CustomsBinding = 4,
	NewSlot = 5,
};

local EmptySlotIconAtlas = "clickcast-icon-add";
local InteractTargetUnitIcon = 132212;
local InteractOpenUnitMenuIcon = 134331;

StaticPopupDialogs["CONFIRM_LOSE_UNSAVED_CLICK_BINDINGS"] = {
	text = CLICK_CAST_UNSAVED,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function() HideUIPanel(ClickBindingFrame) end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
};

StaticPopupDialogs["CONFIRM_RESET_CLICK_BINDINGS"] = {
	text = CLICK_CAST_RESET,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function() ClickBindingFrame:ResetToDefaultProfile() end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
};

local function ElementSortComparator(e1, e2)
	if e1.elementType ~= e2.elementType then
		return e1.elementType < e2.elementType;
	end

	if e1.elementType == ElementDataTypes.InteractionBinding then
		return e1.bindingInfo.actionID < e2.bindingInfo.actionID;
	end

	-- Must be two custom bindings
	if e1.unbound and e2.unbound then
		if e1.bindingInfo.type ~= e2.bindingInfo.type then
			return e1.bindingInfo.type < e2.bindingInfo.type;
		end
		return e1.bindingInfo.actionID < e2.bindingInfo.actionID;
	elseif e1.unbound then
		return false;
	elseif e2.unbound then
		return true;
	end

	if e1.bindingInfo.button ~= e2.bindingInfo.button then
		return e1.bindingInfo.button < e2.bindingInfo.button;
	end

	return e1.bindingInfo.modifiers < e2.bindingInfo.modifiers;
end

local function DataProviderFromProfile(profile)
	local dataProvider = CreateDataProvider();

	local function AddNewElement(elementType, bindingInfo, unbound)
		dataProvider:Insert({elementType = elementType, bindingInfo = bindingInfo, unbound = unbound});
	end

	-- Add headers
	AddNewElement(ElementDataTypes.DefaultsHeader)
	AddNewElement(ElementDataTypes.CustomsHeader);

	-- Add custom bindings, keeping track of if custom interaction bindings are set
	local targetFound, menuFound;
	for _, bindingInfo in ipairs(profile) do
		if bindingInfo.type == Enum.ClickBindingType.Interaction then
			if bindingInfo.actionID == Enum.ClickBindingInteraction.Target then
				targetFound = true;
			elseif bindingInfo.actionID == Enum.ClickBindingInteraction.OpenContextMenu then
				menuFound = true;
			end
		end

		local elementType = (bindingInfo.type == Enum.ClickBindingType.Interaction) and ElementDataTypes.InteractionBinding or ElementDataTypes.CustomsBinding;
		AddNewElement(elementType, bindingInfo);
	end

	-- Add default interaction bindings
	if not targetFound then
		local targetBindingInfo = {
			type = Enum.ClickBindingType.Interaction,
			actionID = Enum.ClickBindingInteraction.Target,
		};
		AddNewElement(ElementDataTypes.InteractionBinding, targetBindingInfo, true);
	end
	if not menuFound then
		local menuBindingInfo = {
			type = Enum.ClickBindingType.Interaction,
			actionID = Enum.ClickBindingInteraction.OpenContextMenu,
		};
		AddNewElement(ElementDataTypes.InteractionBinding, menuBindingInfo, true);
	end

	-- Add a default empty binding
	AddNewElement(ElementDataTypes.NewSlot, nil, true);

	local skipSort = false;
	dataProvider:SetSortComparator(ElementSortComparator, skipSort);

	return dataProvider;
end

local function ProfileFromDataProvider(provider)
	local profile = {};

	for _, element in provider:Enumerate() do
		if element.bindingInfo and not element.unbound then
			table.insert(profile, element.bindingInfo);
		end
	end

	return profile;
end

local function NameAndIconFromElementData(elementData)
	-- Interaction bindings, custom bindings, and (in-progress) empty slots can all have binding info
	if elementData.bindingInfo then
		local bindingInfo = elementData.bindingInfo;
		local type = bindingInfo.type;
		local actionID = bindingInfo.actionID;

		local actionName, actionIcon, _;
		if type == Enum.ClickBindingType.Spell then
			local overrideID = FindSpellOverrideByID(actionID);
			actionName, _, actionIcon = GetSpellInfo(overrideID);
		elseif type == Enum.ClickBindingType.Macro then
			local macroName;
			macroName, actionIcon = GetMacroInfo(actionID);
			actionName = string.format(CLICK_BINDING_MACRO_TITLE, macroName);
		elseif type == Enum.ClickBindingType.Interaction then
			if actionID == Enum.ClickBindingInteraction.Target then
				actionName = string.format(CLICK_BINDING_INTERACTION_TITLE, CLICK_BINDING_TARGET_UNIT);
				actionIcon = InteractTargetUnitIcon;
			elseif actionID == Enum.ClickBindingInteraction.OpenContextMenu then
				actionName = string.format(CLICK_BINDING_INTERACTION_TITLE, CLICK_BINDING_OPEN_MENU);
				actionIcon = InteractOpenUnitMenuIcon;
			end
		end
		return actionName, actionIcon;
	elseif elementData.elementType == ElementDataTypes.DefaultsHeader then
		return CLICK_BINDINGS_DEFAULTS_HEADER;
	elseif elementData.elementType == ElementDataTypes.CustomsHeader then
		return CLICK_BINDINGS_CUSTOMS_HEADER;
	elseif elementData.elementType == ElementDataTypes.NewSlot then
		return EMPTY, EmptySlotIconAtlas;
	end
end

local function ColoredNameAndIconFromElementData(elementData)
	local name, icon = NameAndIconFromElementData(elementData);

	local isDisabled;
	if elementData.elementType == ElementDataTypes.NewSlot then
		isDisabled = (elementData.bindingInfo == nil);
	else
		isDisabled = elementData.unbound;
	end

	if isDisabled then
		name = DISABLED_FONT_COLOR:WrapTextInColorCode(name);
	end

	return name, icon;
end

local function BindingTextFromElementData(elementData)
	if elementData.elementType == ElementDataTypes.NewSlot then
		local bindingText = elementData.bindingInfo and CLICK_BINDINGS_SET_BINDING_PROMPT or CLICK_BINDINGS_NEW_EMPTY_PROMPT;
		return GREEN_FONT_COLOR:WrapTextInColorCode(bindingText);
	end

	local bindingInfo = elementData.bindingInfo;
	if not bindingInfo or not bindingInfo.button then
		return RED_FONT_COLOR:WrapTextInColorCode(CLICK_BINDINGS_UNBOUND_TEXT);
	end

	local buttonString = ButtonStrings[bindingInfo.button];
	local modifierText = C_ClickBindings.GetStringFromModifiers(bindingInfo.modifiers);
	if modifierText ~= "" then
		return CLICK_BINDINGS_BINDING_TEXT_FORMAT:format(modifierText, buttonString);
	else
		return buttonString;
	end
end


ClickBindingLineMixin = {};

function ClickBindingLineMixin:Init(elementData)
	self:RegisterForClicks("AnyUp");

	local bindingText = BindingTextFromElementData(elementData);
	self.BindingText:SetText(bindingText);

	local elementName, elementIcon = ColoredNameAndIconFromElementData(elementData);
	self.Name:SetText(elementName);
	if type(elementIcon) == "string" then
		self.Icon:SetAtlas(elementIcon);
	else
		self.Icon:SetTexture(elementIcon);
	end

	self.elementType = elementData.elementType;

	self.NewOutline:SetShown(self.elementType == ElementDataTypes.NewSlot and elementData.bindingInfo ~= nil);

	self.EmptySlotIconHighlight:SetShown(self.elementType == ElementDataTypes.NewSlot and elementData.bindingInfo == nil);

	local isUnboundAction = elementData.unbound and elementData.elementType ~= ElementDataTypes.NewSlot;
	self.Icon:SetDesaturated(isUnboundAction);
end

function ClickBindingLineMixin:OnEnter()
	local showDelete = (self.elementType ~= ElementDataTypes.InteractionBinding);
	if showDelete then
		self.DeleteButton:Show();
	end
end

function ClickBindingLineMixin:OnLeave()
	if GetMouseFocus() == self.DeleteButton then
		return;
	end

	self.DeleteButton:Hide();
end


ClickBindingHeaderMixin = {};

function ClickBindingHeaderMixin:Init(elementData)
	local elementName = ColoredNameAndIconFromElementData(elementData);
	self.Name:SetText(elementName);
end


ClickBindingFramePortraitMixin = {};

function ClickBindingFramePortraitMixin:SetSelectedState(isSelected)
	self.Frame:SetDesaturated(not isSelected);
	self.UnselectedFrame:SetShown(not isSelected);
end

function ClickBindingFramePortraitMixin:OnLoad()
	self:SetSelectedState(false);
	self.Portrait:SetTexture(self.PortraitTexture);
end

function ClickBindingFramePortraitMixin:GetFrame()
	return _G[self.FrameName];
end

function ClickBindingFramePortraitMixin:GetTooltipText()
	if self.FrameName == "SpellBookFrame" then
		return MicroButtonTooltipText(SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK");
	elseif self.FrameName == "MacroFrame" then
		return MACROS;
	end
end

function ClickBindingFramePortraitMixin:OnEnter()
	local tooltipText = self:GetTooltipText();
	if tooltipText then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, tooltipText);
		GameTooltip:Show();
	end
end

function ClickBindingFramePortraitMixin:OnLeave()
	GameTooltip:Hide();
end


UIPanelWindows["ClickBindingFrame"] = { area = "left", pushable = 2, whileDead = 1, width = 450, height = 600 };

ClickBindingFrameMixin = {};

function ClickBindingFrameMixin:InitializeButtons()
	self.SaveButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local profile = ProfileFromDataProvider(self.dataProvider);
		C_ClickBindings.SetProfileByInfo(profile);
		HideUIPanel(self);
	end);

	self.AddBindingButton:SetScript("OnClick", function()
		if self:HasNewSlot() then
			return;
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		self.dataProvider:Insert({elementType = ElementDataTypes.NewSlot, unbound = true});
		self:SetHasNewSlot(true);
		self:ClearUnboundText();
	end);

	self.ResetButton:SetScript("OnClick", function()
		StaticPopup_Show("CONFIRM_RESET_CLICK_BINDINGS");
	end);
	
	self.TutorialButton:SetScript("OnClick", function()
		local showTutorial = not self.TutorialFrame:IsShown();
		self.TutorialFrame:SetShown(showTutorial);
	end);

	self.CloseButton:SetScript("OnClick", function()
		if self.pendingChanges then
			StaticPopup_Show("CONFIRM_LOSE_UNSAVED_CLICK_BINDINGS");
		else
			HideUIPanel(self);
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		end
	end);

	for _, portrait in ipairs(self.FramePortraits) do
		portrait:SetScript("OnClick", function()
			local frame = portrait:GetFrame();
			if self:GetFocusedFrame() == frame then
				self:ClearFocusedFrame();
			else
				self:SetFocusedFrame(frame);
			end
		end);
	end
end

local function AddFromCursorInfo(addFunc)
	local addedNew = false;
	local cursorType, cursorInfo1, cursorInfo2 = GetCursorInfo();
	if cursorType == "spell" then
		local _, _, spellID = GetSpellBookItemName(cursorInfo1, cursorInfo2);
		if C_ClickBindings.CanSpellBeClickBound(spellID) then
			addFunc(Enum.ClickBindingType.Spell, spellID);
			addedNew = true;
		end
	elseif cursorType == "macro" then
		addFunc(Enum.ClickBindingType.Macro, cursorInfo1);
		addedNew = true;
	end
	ClearCursor();
	if addedNew then
		EventRegistry:TriggerEvent("ClickBindingFrame.UpdateFrames");
		ClickBindingFrame:CleanDataProvider();
		ClickBindingFrame.dataProvider:Sort();
		ClickBindingFrame:ClearUnboundText();
		ClickBindingFrame.pendingChanges = true;
	end
	return addedNew;
end

function ClickBindingFrameMixin:InitializeScrollBox()
	local padding = 7;
	-- Extra bottom padding to leave space to drag in an action
	local bottomPadding = 53;
	local spacing = 4;
	local view = CreateScrollBoxListLinearView(padding, bottomPadding, padding, padding, spacing);

	view:SetElementExtentCalculator(function(dataIndex, elementData)
		local buttonHeight = 46;
		local headerHeight = 20;
		local type = elementData.elementType;
		return (type == ElementDataTypes.DefaultsHeader or type == ElementDataTypes.CustomsHeader) and headerHeight or buttonHeight;
	end);

	view:SetElementFactory(function(factory, elementData)
		local type = elementData.elementType;
		if type == ElementDataTypes.DefaultsHeader or type == ElementDataTypes.CustomsHeader then
			local button = factory("Button", "ClickBindingHeaderTemplate");
			button:Init(elementData);
		else
			local button = factory("Button", "ClickBindingLineTemplate");
			button:Init(elementData);

			button:SetScript("OnClick", function(button, buttonName)
				local addedNew;
				if elementData.elementType ~= ElementDataTypes.InteractionBinding then
					addedNew = AddFromCursorInfo(function(type, actionID)
						if not elementData.bindingInfo then
							elementData.bindingInfo = {};
						end
						elementData.bindingInfo.type = type;
						elementData.bindingInfo.actionID = actionID;
						button:Init(elementData);
					end);
				end

				if addedNew or not elementData.bindingInfo then
					return;
				end

				local modifiers = C_ClickBindings.MakeModifiers();
				if elementData.bindingInfo.button == buttonName and elementData.bindingInfo.modifiers == modifiers then
					return;
				end

				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
				elementData.bindingInfo.button = buttonName;
				elementData.bindingInfo.modifiers = modifiers;
				elementData.unbound = false;
				if elementData.elementType == ElementDataTypes.NewSlot then
					elementData.elementType = ElementDataTypes.CustomsBinding;
					self:SetHasNewSlot(false);
				end
				button:Init(elementData);
				self:ClearUnboundText();
				self.ScrollBox:ForEachFrame(function(otherButton)
					local otherData = otherButton:GetElementData();
					if (otherData ~= elementData) and otherData.bindingInfo and (otherData.bindingInfo.button == buttonName) and (otherData.bindingInfo.modifiers == modifiers) then
						otherData.bindingInfo.button = nil;
						otherData.bindingInfo.modifiers = nil;
						otherData.unbound = true;
						otherButton:Init(otherData);
						self:SetUnboundText(otherData);
					end
				end);
				self:CleanDataProvider();
				self.dataProvider:Sort();
				self.pendingChanges = true;
			end);

			button.DeleteButton:SetScript("OnClick", function()
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
				self.dataProvider:Remove(elementData);
				if type == ElementDataTypes.NewSlot then
					self:SetHasNewSlot(false);
				else
					self.pendingChanges = true;
				end
				self:ClearUnboundText();
			end);
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.ScrollBox:RegisterForClicks("AnyUp");
	self.ScrollBox:SetScript("OnClick", function()
		AddFromCursorInfo(GenerateClosure(self.AddNewAction, self));
	end);
end

function ClickBindingFrameMixin:CleanDataProvider()
	-- Clear any duplicate unbound actions
	local toRemove = {};
	local seenActions = {};
	self.dataProvider:ForEach(function(elementData)
		if (elementData.elementType ~= ElementDataTypes.CustomsBinding) or (not elementData.unbound) then
			return;
		end

		local type = elementData.bindingInfo.type;
		local actionID = elementData.bindingInfo.actionID;
		if not seenActions[type] then
			seenActions[type] = {};
		end
		if seenActions[type][actionID] then
			table.insert(toRemove, elementData);
		end
		seenActions[type][actionID] = true;
	end);

	self.dataProvider:Remove(unpack(toRemove));
end

function ClickBindingFrameMixin:GetLastElement()
	return self.dataProvider:Find(self.dataProvider:GetSize());
end

function ClickBindingFrameMixin:SetHasNewSlot(hasNewSlot)
	local canAddNew = not hasNewSlot;
	self.AddBindingButton:SetEnabled(canAddNew);
	EventRegistry:TriggerEvent("ClickBindingFrame.UpdateFrames");
end

function ClickBindingFrameMixin:HasNewSlot()
	local lastElem = self:GetLastElement();
	return lastElem.elementType == ElementDataTypes.NewSlot;
end

function ClickBindingFrameMixin:HasEmptySlot()
	local lastElem = self:GetLastElement();
	return (lastElem.elementType == ElementDataTypes.NewSlot) and not lastElem.bindingInfo;
end

local ClickBindingFrameEvents = {
	"PLAYER_SPECIALIZATION_CHANGED",
	"SPELLS_CHANGED",
	"CLICKBINDINGS_SET_HIGHLIGHTS_SHOWN",
};

function ClickBindingFrameMixin:OnLoad()
	for _, event in ipairs(ClickBindingFrameEvents) do
		self:RegisterEvent(event);
	end

	MacroFrame_LoadUI();

	self:SetPortraitAtlasRaw("clickcast-icon-mouse");
	self:SetTitle(CLICK_CAST_BINDINGS);

	self:InitializeButtons();
	self:InitializeScrollBox();
end

function ClickBindingFrameMixin:OnShow()
	local showTutorial = not C_ClickBindings.GetTutorialShown();
	self.TutorialFrame:SetShown(showTutorial);
	-- Refresh() triggers ClickBindingFrame.UpdateFrames event through SetHasNewSlot()
	self:Refresh();
	self:SetFocusedFrame(SpellBookFrame);
end

function ClickBindingFrameMixin:OnHide()
	self:ClearFocusedFrame();
	StaticPopup_Hide("CONFIRM_LOSE_UNSAVED_CLICK_BINDINGS");
	StaticPopup_Hide("CONFIRM_RESET_CLICK_BINDINGS");
end

function ClickBindingFrameMixin:OnEvent(event, ...)
	if event == "PLAYER_SPECIALIZATION_CHANGED" and self:IsShown() then
		local unit = (...);
		if (unit == "player") and (GetSpecialization() ~= self.currentSpec) then
			self:Refresh();
		end
	elseif event == "SPELLS_CHANGED" and self:IsShown() then
		-- Remove any spells that are no longer known
		local toRemove = {};

		self.dataProvider:ForEach(function(element)
			if element.bindingInfo and (element.bindingInfo.type == Enum.ClickBindingType.Spell) and not IsSpellKnown(element.bindingInfo.actionID) then
				table.insert(toRemove, element)
			end
		end);

		self.dataProvider:Remove(unpack(toRemove));
	elseif event == "CLICKBINDINGS_SET_HIGHLIGHTS_SHOWN" then
		local showHighlights = ...;
		self:SetIconHighlightsShown(showHighlights);
	end
end

function ClickBindingFrameMixin:Refresh()
	local startingProfile = C_ClickBindings.GetProfileInfo();
	self.dataProvider = DataProviderFromProfile(startingProfile);
	self.ScrollBox:SetDataProvider(self.dataProvider, ScrollBoxConstants.DiscardScrollPosition)
	self:SetHasNewSlot(true);
	self:ClearUnboundText();
	self.currentSpec = GetSpecialization();
	self.pendingChanges = false;
end

function ClickBindingFrameMixin:SetFocusedFrame(frame)
	if (frame == self:GetFocusedFrame()) or not (frame == SpellBookFrame or frame == MacroFrame) then
		return;
	end

	HideUIPanel(self:GetFocusedFrame());
	self.focusedFrame = frame;

	if not frame:IsShown() then
		ShowUIPanel(frame);
	end

	for _, portrait in ipairs(self.FramePortraits) do
		portrait:SetSelectedState(portrait:GetFrame() == frame)
	end
end

function ClickBindingFrameMixin:ClearFocusedFrame()
	local focusedFrame = self:GetFocusedFrame();
	if focusedFrame and focusedFrame:IsShown() then
		HideUIPanel(focusedFrame);
	end
	self.focusedFrame = nil;

	for _, portrait in ipairs(self.FramePortraits) do
		portrait:SetSelectedState(false);
	end
end

function ClickBindingFrameMixin:GetFocusedFrame()
	return self.focusedFrame;
end

function ClickBindingFrameMixin:FillNewSlot(actionType, actionID)
	if not self:HasNewSlot() then
		return;
	end

	local lastElem = self:GetLastElement();
	local newBindingInfo = {
		type = actionType,
		actionID = actionID,
	};
	lastElem.bindingInfo = newBindingInfo;
	local lastLine = self.ScrollBox:FindFrame(lastElem);
	lastLine:Init(lastElem);
	EventRegistry:TriggerEvent("ClickBindingFrame.UpdateFrames");
	self:ClearUnboundText();
	self.pendingChanges = true;
end

function ClickBindingFrameMixin:AddNewAction(actionType, actionID)
	if not EnumUtil.IsValid(Enum.ClickBindingType, actionType) then
		return;
	end

	PlaySound(SOUNDKIT.IG_ABILITY_ICON_DROP);

	if self:HasNewSlot() then
		self:FillNewSlot(actionType, actionID);
	else
		local newBindingInfo = {
			type = actionType,
			actionID = actionID,
		};
		self.dataProvider:Insert({elementType = ElementDataTypes.CustomsBinding, bindingInfo = newBindingInfo, unbound = true});
	end

	self:CleanDataProvider();
	self.dataProvider:Sort();
	self:ClearUnboundText();
	self.pendingChanges = true;
end

function ClickBindingFrameMixin:SetUnboundText(elementData)
	local unboundName = NameAndIconFromElementData(elementData);
	local outputText = string.format(CLICK_BINDING_UNBOUND_OUTPUT, unboundName);
	self.UnboundText:SetText(outputText);
end

function ClickBindingFrameMixin:ClearUnboundText()
	self.UnboundText:SetText("");
end

function ClickBindingFrameMixin:SetIconHighlightsShown(show)
	self.ScrollBox:ForEachFrame(function(frame)
		local type = frame:GetElementData().elementType;
		if (type == ElementDataTypes.CustomsBinding) or (type == ElementDataTypes.NewSlot) then
			frame.IconHighlight:SetShown(show);
		end
	end);
end

function ClickBindingFrameMixin:ResetToDefaultProfile()
	C_ClickBindings.ResetCurrentProfile();
	local freshProfile = C_ClickBindings.GetProfileInfo();
	local freshProvider = DataProviderFromProfile(freshProfile);
	for _, element in self.dataProvider:Enumerate() do
		if element.elementType == ElementDataTypes.CustomsBinding then
			local newBindingInfo = {
				type = element.bindingInfo.type,
				actionID = element.bindingInfo.actionID,
			};
			freshProvider:Insert({elementType = ElementDataTypes.CustomsBinding, bindingInfo = newBindingInfo, unbound = true});
		end
	end
	self.dataProvider = freshProvider;
	self:CleanDataProvider();
	self.ScrollBox:SetDataProvider(self.dataProvider, ScrollBoxConstants.RetainScrollPosition)
	self:SetHasNewSlot(true);
	self:ClearUnboundText();
	self.pendingChanges = false;
end


ClickBindingTutorialMixin = {};

function ClickBindingTutorialMixin:OnLoad()
	ButtonFrameTemplate_HidePortrait(self);
	ButtonFrameTemplate_HideAttic(self);
	ButtonFrameTemplate_HideButtonBar(self);
	self.TitleText:SetText(CLICK_CAST_ABOUT_HEADER);
end

function ClickBindingTutorialMixin:OnHide()
	C_ClickBindings.SetTutorialShown();
end


function ClickBindingFrame_Toggle()
	local show = not ClickBindingFrame:IsShown();
	SetUIPanelShown(ClickBindingFrame, show);
end