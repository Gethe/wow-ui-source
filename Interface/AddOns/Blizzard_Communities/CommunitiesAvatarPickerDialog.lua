
-- Constants
local NUM_AVATAR_ICON_COLUMNS = 6;
local AVATAR_ICON_SPACING = 9;
local COMMUNITIES_AVATAR_PICKER_DIALOG_SCROLL_FRAME_EVENTS = {
	"AVATAR_LIST_UPDATED",
};

function CommunitiesAvatarPicker_OpenDialog(clubType, avatarId, onOkay, onCancel)
	CommunitiesAvatarPickerDialog:SetClubType(clubType);
	CommunitiesAvatarPickerDialog:SetAvatarId(avatarId);
	CommunitiesAvatarPickerDialog.Selector.OnOkay = onOkay;
	CommunitiesAvatarPickerDialog.Selector.OnCancel = onCancel;
	CommunitiesAvatarPickerDialog:Show();
end

function CommunitiesAvatarPicker_CloseDialog()
	CommunitiesAvatarPickerDialog:Hide();
end

function CommunitiesAvatarPicker_IsShown()
	return CommunitiesAvatarPickerDialog:IsShown();
end

CommunitiesAvatarPickerDialogMixin = {};

function CommunitiesAvatarPickerDialogMixin:OnLoad()
	local stride = 6;
	local view = CreateScrollBoxListGridView(stride);
	view:SetElementInitializer("AvatarButtonTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	view:SetPadding(AVATAR_ICON_SPACING, 0, 0, 0, AVATAR_ICON_SPACING, AVATAR_ICON_SPACING);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function CommunitiesAvatarPickerDialogMixin:SetupGamepad()
	GamepadBaseDialogMixin.SetupGamepad(self);

	SmartNavigation:SetSmartNavPanelInfoAddedCallback(self, function()
		SmartNavigation:SetScrollFrameForFrame(self, self.ScrollBox)
		local selectedButton = self:ScrollSelectionIntoView();
		if selectedButton then
			SmartNavigation:SetTargetButtonForFrame(self, selectedButton);
		end
	end);
end

function CommunitiesAvatarPickerDialogMixin:InitGamepad()
	GamepadBaseDialogMixin.InitGamepad(self);

	self.Selector.CancelButton:Hide();
	self.Selector.OkayButton:Hide();
	self.Selector.BottomRightCorner:SetAtlas("macropopup-bottomright-nobuttons", true);
end

function CommunitiesAvatarPickerDialogMixin:UninitGamepad()
	GamepadBaseDialogMixin.UninitGamepad(self);

	self.Selector.CancelButton:Show();
	self.Selector.OkayButton:Show();
	self.Selector.BottomRightCorner:SetAtlas("macropopup-bottomright", true);
end

function CommunitiesAvatarPickerDialogMixin:SmartNavigationCloseHandler()
	self.Selector.CancelButton:Click();
	return true;
end

function CommunitiesAvatarPickerDialogMixin:ScrollSelectionIntoView()
	local selectedIndex = table.indexof(self.avatarIdList, self.avatarId);
	if selectedIndex then
		self.ScrollBox:ScrollToElementDataIndex(selectedIndex);
		return self.ScrollBox:FindFrame(selectedIndex);
	end
end

function CommunitiesAvatarPickerDialogMixin:OnShow()
	self:SetAttribute("shown", true);

	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_AVATAR_PICKER_DIALOG_SCROLL_FRAME_EVENTS);

	self.ScrollBox:ScrollToBegin();
	self.avatarIdList = C_Club.GetAvatarIdList(self:GetClubType());
	self:Refresh();
end

function CommunitiesAvatarPickerDialogMixin:OnHide()
	self:SetAttribute("shown", false);

	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_AVATAR_PICKER_DIALOG_SCROLL_FRAME_EVENTS);
end

function CommunitiesAvatarPickerDialogMixin:OnEvent(event, ...)
	if event == "AVATAR_LIST_UPDATED" then
		local clubType = ...;
		if clubType == self:GetClubType() then
			self.avatarIdList = C_Club.GetAvatarIdList(clubType);
			self:Refresh();
		end
	end
end

function CommunitiesAvatarPickerDialogMixin:OnAttributeChanged(name, value)
	if name == "hide" then
		self:Hide();
	end
end

function CommunitiesAvatarPickerDialogMixin:SetAvatarId(avatarId)
	self.avatarId = avatarId;
end

function CommunitiesAvatarPickerDialogMixin:GetAvatarId()
	return self.avatarId;
end

function CommunitiesAvatarPickerDialogMixin:SetClubType(clubType)
	self.clubType = clubType;
end

function CommunitiesAvatarPickerDialogMixin:GetClubType()
	return self.clubType;
end

function CommunitiesAvatarPickerDialogMixin:Refresh()
	local dataProvider = CreateIndexRangeDataProvider(self.avatarIdList and #self.avatarIdList or 0);
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

CommunitiesAvatarButtonMixin = {};

function CommunitiesAvatarButtonMixin:Init(avatarIndex)
	local avatarId = CommunitiesAvatarPickerDialog.avatarIdList[avatarIndex];
	self.avatarId = avatarId;
	self.Selected:SetShown(CommunitiesAvatarPickerDialog:GetAvatarId() == self.avatarId);
	C_Club.SetAvatarTexture(self.Icon, avatarId, CommunitiesAvatarPickerDialog:GetClubType());
end

function CommunitiesAvatarButtonMixin:OnClick(buttonName, down)
	CommunitiesAvatarPickerDialog:SetAvatarId(self.avatarId);
	CommunitiesAvatarPickerDialog:Refresh();
end

function CommunitiesAvatarButtonMixin:OnSmartNavSelect()
	self:OnClick();
end

function CommunitiesAvatarButtonMixin:OnSmartNavClick()
	CommunitiesAvatarPickerDialog.Selector.OkayButton:Click();
end
