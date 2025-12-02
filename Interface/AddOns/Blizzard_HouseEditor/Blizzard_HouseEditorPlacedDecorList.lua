HouseEditorPlacedDecorListButtonMixin = {};

function HouseEditorPlacedDecorListButtonMixin:SetListFrame(listFrame)
	self.listFrame = listFrame;
	self.listFrame:SetOnHideCallback(function()
		self:UpdateState();
	end)
end

function HouseEditorPlacedDecorListButtonMixin:GetIconForState(state)
	-- Overrides BaseHousingActionButtonMixin
	local iconName = self.iconDefault;
	local isAtlas = true;

	if state.isEnabled then
		if state.isPressed then
			iconName = self.iconPressed;
		elseif state.isActive then
			iconName = self.iconActive;
		end
	end

	return iconName, isAtlas;
end

function HouseEditorPlacedDecorListButtonMixin:IsActive()
	return self.listFrame and self.listFrame:IsShown();
end

function HouseEditorPlacedDecorListButtonMixin:CheckEnabled()
	return true;
end

function HouseEditorPlacedDecorListButtonMixin:EnterMode()
	if self.listFrame then
		self.listFrame:Show();
	end
end

function HouseEditorPlacedDecorListButtonMixin:LeaveMode()
	if self.listFrame then
		self.listFrame:Hide();
	end
end

local PlacedDecorListWhileVisibleEvents = {
	"HOUSING_DECOR_PLACE_SUCCESS",
	"HOUSING_DECOR_REMOVED",
	"HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED",
	"HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED",
	"HOUSING_CLEANUP_MODE_TARGET_SELECTED",
	"HOUSING_CLEANUP_MODE_HOVERED_TARGET_CHANGED",
	"HOUSING_CUSTOMIZE_MODE_SELECTED_TARGET_CHANGED",
	"HOUSING_CUSTOMIZE_MODE_HOVERED_TARGET_CHANGED",
	"HOUSING_EXPERT_MODE_SELECTED_TARGET_CHANGED",
	"HOUSING_EXPERT_MODE_HOVERED_TARGET_CHANGED",
};

local stateChangeEvents = {
	["HOUSING_BASIC_MODE_SELECTED_TARGET_CHANGED"] = true,
	["HOUSING_BASIC_MODE_HOVERED_TARGET_CHANGED"] = true,
	["HOUSING_CLEANUP_MODE_TARGET_SELECTED"] = true,
	["HOUSING_CLEANUP_MODE_HOVERED_TARGET_CHANGED"] = true,
	["HOUSING_CUSTOMIZE_MODE_SELECTED_TARGET_CHANGED"] = true,
	["HOUSING_CUSTOMIZE_MODE_HOVERED_TARGET_CHANGED"] = true,
	["HOUSING_EXPERT_MODE_SELECTED_TARGET_CHANGED"] = true,
	["HOUSING_EXPERT_MODE_HOVERED_TARGET_CHANGED"] = true,
};

HouseEditorPlacedDecorListMixin = {};

function HouseEditorPlacedDecorListMixin:OnLoad()
	ClickToDragMixin.OnLoad(self);

	self.CloseButton:SetScript("OnClick", function() 
		self:Hide();
	end);

	local view = CreateScrollBoxListLinearView(self.topPadding, self.bottomPadding, self.leftPadding, self.rightPadding, self.horizontalSpacing, self.verticalSpacing);

	local function Initializer(frame, elementData)
		frame:Init(elementData);
	end
	local function Resetter(frame, elementData)
		frame:Reset();
	end
	view:SetElementInitializer("HouseEditorPlacedDecorEntryTemplate", Initializer);
	view:SetElementResetter(Resetter);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function HouseEditorPlacedDecorListMixin:OnShow()
	PlaySound(SOUNDKIT.HOUSING_PLACED_DECOR_LIST_OPEN);
	FrameUtil.RegisterFrameForEvents(self, PlacedDecorListWhileVisibleEvents);
	self:UpdateData();
end

function HouseEditorPlacedDecorListMixin:OnHide()
	PlaySound(SOUNDKIT.HOUSING_PLACED_DECOR_LIST_CLOSE);
	FrameUtil.UnregisterFrameForEvents(self, PlacedDecorListWhileVisibleEvents);
	if self.onHideCallback then
		self.onHideCallback();
	end
end

function HouseEditorPlacedDecorListMixin:OnEvent(event, ...)
	if event == "HOUSING_DECOR_PLACE_SUCCESS" then
		local decorGUID, size, isNew = ...;
		if isNew then
			self:OnEntryAdded(decorGUID);
		end
	elseif event == "HOUSING_DECOR_REMOVED" then
		local decorGUID = ...;
		self:OnEntryRemoved(decorGUID);
	elseif stateChangeEvents[event] then
		self:UpdateStates();
	end
end

function HouseEditorPlacedDecorListMixin:SetOnHideCallback(onHideCallback)
	self.onHideCallback = onHideCallback;
end

local function SortDecorByName(elementA, elementB)
	return strcmputf8i(elementA.name, elementB.name) < 0;
end

function HouseEditorPlacedDecorListMixin:UpdateData()
	local allDecorEntries = C_HousingDecor.GetAllPlacedDecor();
	local dataProvider = CreateDataProvider(allDecorEntries);
	dataProvider:SetSortComparator(SortDecorByName);
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	self:UpdateStates();
end

function HouseEditorPlacedDecorListMixin:UpdateStates()
	local selectedDecorInfo = C_HousingDecor.GetSelectedDecorInfo();
	local hoveredDecorInfo = C_HousingDecor.GetHoveredDecorInfo();
	local selectedDecorGUID = selectedDecorInfo and selectedDecorInfo.decorGUID or nil;
	local hoveredDecorGUID = hoveredDecorInfo and hoveredDecorInfo.decorGUID or nil;

	for _, frame in self.ScrollBox:EnumerateFrames() do
		local isSelected = frame.decorGUID == selectedDecorGUID;
		local isHovered = frame.decorGUID == hoveredDecorGUID;
		frame:UpdateState(isSelected, isHovered);
	end
end

function HouseEditorPlacedDecorListMixin:ClearData()
	self.ScrollBox:RemoveDataProvider();
end

function HouseEditorPlacedDecorListMixin:OnEntryAdded(decorGUID)
	local dataProvider = self.ScrollBox:GetDataProvider();
	if not dataProvider then
		return;
	end

	local entryExists = dataProvider:ContainsByPredicate(function(elementData) return elementData.decorGUID == decorGUID; end);

	if not entryExists then
		local instanceInfo = C_HousingDecor.GetDecorInstanceInfoForGUID(decorGUID);
		dataProvider:Insert({decorGUID = decorGUID, name = instanceInfo.name});
	end
end

function HouseEditorPlacedDecorListMixin:OnEntryRemoved(decorGUID)
	local dataProvider = self.ScrollBox:GetDataProvider();
	if not dataProvider then
		return;
	end

	dataProvider:RemoveByPredicate(function(elementData) return elementData.decorGUID == decorGUID; end);
end

HouseEditorPlacedDecorEntryMixin = {};

function HouseEditorPlacedDecorEntryMixin:Init(elementData)
	self.elementData = elementData;
	self.decorGUID = elementData.decorGUID;
	self.isSelected = false;
	self.isHovered = false;

	self.instanceInfo = C_HousingDecor.GetDecorInstanceInfoForGUID(self.decorGUID);

	self.DecorNameText:SetText(elementData.name);
	self:UpdateVisuals();
end

function HouseEditorPlacedDecorEntryMixin:Reset()
	self.elementData = nil;
	self.decorGUID = nil;
	self.isSelected = false;
	self.isHovered = false;
	self.instanceInfo = nil;
end

function HouseEditorPlacedDecorEntryMixin:HasValidData()
	return self.elementData and self.decorGUID;
end

function HouseEditorPlacedDecorEntryMixin:UpdateState(isSelected, isHovered)
	if self.isSelected == isSelected and self.isHovered == isHovered then
		return;
	end

	self.isSelected = isSelected;
	self.isHovered = isHovered;
	self:UpdateVisuals();
end

function HouseEditorPlacedDecorEntryMixin:UpdateVisuals()
	local fontColor = VERY_LIGHT_GRAY_COLOR;
	local bgAlpha = 0;

	
	if self.isHovered then
		bgAlpha = 0.15;
		fontColor = HIGHLIGHT_FONT_COLOR;
	elseif self.isSelected then
		-- If we're both selected and hovered by the mouse, we won't come back as also being "the" hovered decor
		-- So for highlight background visiuals we need to manually double check if mouse is over the ui
		bgAlpha = self:IsMouseMotionFocus() and 0.15 or 0;
		fontColor = NORMAL_FONT_COLOR;
	else
		bgAlpha = 0;
		fontColor = VERY_LIGHT_GRAY_COLOR;
	end

	self.HighlightBGTex:SetAlpha(bgAlpha);
	self.DecorNameText:SetTextColor(fontColor:GetRGB());
end

function HouseEditorPlacedDecorEntryMixin:OnClick(button)
	if not self:HasValidData() then
		return;
	end
	
	if button == "RightButton" then
		self:ShowContextMenu();
	else
		C_HousingDecor.SetPlacedDecorEntrySelected(self.decorGUID, not self.isSelected);
	end

end

function HouseEditorPlacedDecorEntryMixin:OnEnter()
	if not self:HasValidData() then
		return;
	end

	PlaySound(SOUNDKIT.HOUSING_HOVER_PLACED_DECOR);

	if not self.isSelected then
		C_HousingDecor.SetPlacedDecorEntryHovered(self.decorGUID, true);
	else
		self:UpdateVisuals();
	end
end

function HouseEditorPlacedDecorEntryMixin:OnLeave()
	if not self:HasValidData() then
		return;
	end

	if not self.isSelected then
		C_HousingDecor.SetPlacedDecorEntryHovered(self.decorGUID, false);
	else
		self:UpdateVisuals();
	end
end

function HouseEditorPlacedDecorEntryMixin:ShowContextMenu()
	if not self.instanceInfo then
		return;
	end

	local showDisabledTooltip = function(tooltip, elementDescription)
		GameTooltip_SetTitle(tooltip, HOUSING_DECOR_CANNOT_REMOVE);
	end

	MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
		rootDescription:SetTag("MENU_HOUSING_PLACED_DECOR");

		local removeButtonDesc = rootDescription:CreateButton(HOUSING_DECOR_REMOVE_INSTRUCTION, function()
			-- One more check in case anything changed while the context menu is open
			if self.instanceInfo and self.instanceInfo.canBeRemoved then
				PlaySound(SOUNDKIT.HOUSING_DECOR_EDIT_OPTION_REMOVE_ITEM);
				C_HousingDecor.RemovePlacedDecorEntry(self.decorGUID);
			end
		end);
		removeButtonDesc:SetEnabled(self.instanceInfo.canBeRemoved);
		if not self.instanceInfo.canBeRemoved then
			removeButtonDesc:SetTooltip(showDisabledTooltip);
		end
	end);
end
