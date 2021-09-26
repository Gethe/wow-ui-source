
-- Constants
local NUM_AVATAR_ICON_ROWS = 5;
local NUM_AVATAR_ICON_COLUMNS = 6;
local AVATAR_ICON_SIZE = 64;
local AVATAR_ICON_SPACING = 9;
local COMMUNITIES_AVATAR_PICKER_DIALOG_SCROLL_FRAME_EVENTS = {
	"AVATAR_LIST_UPDATED",
};

function CommunitiesAvatarPicker_OpenDialog(clubType, avatarId, onOkay, onCancel)
	CommunitiesAvatarPickerDialog:SetClubType(clubType);
	CommunitiesAvatarPickerDialog:SetAvatarId(avatarId);
	CommunitiesAvatarPickerDialog.OnOkay = onOkay;
	CommunitiesAvatarPickerDialog.OnCancel = onCancel;
	CommunitiesAvatarPickerDialog:Show();
end

function CommunitiesAvatarPicker_CloseDialog()
	CommunitiesAvatarPickerDialog:Hide();
end

function CommunitiesAvatarPicker_IsShown()
	return CommunitiesAvatarPickerDialog:IsShown();
end

CommunitiesAvatarPickerDialogMixin = {};

function CommunitiesAvatarPickerDialogMixin:OnShow()
	self:SetAttribute("shown", true);
end

function CommunitiesAvatarPickerDialogMixin:OnHide()
	self:SetAttribute("shown", false);
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

CommunitiesAvatarPickerDialogScrollFrameMixin = {};

function CommunitiesAvatarPickerDialogScrollFrameMixin:OnLoad()
	self.ScrollBar.scrollStep = AVATAR_ICON_SIZE * NUM_AVATAR_ICON_COLUMNS;
	self.ScrollBar:ClearAllPoints();
	self.ScrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", 9, -1);
	self.ScrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 9, 14);
	self.ScrollBarTop:ClearAllPoints();
	self.ScrollBarTop:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 20);
	self.ScrollBarBottom:ClearAllPoints();
	self.ScrollBarBottom:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 0, -4);
	
	self.avatarButtons = {};
	for i = 1, NUM_AVATAR_ICON_ROWS do
		self.avatarButtons[i] = {};
		for j = 1, NUM_AVATAR_ICON_COLUMNS do
			local avatarButton = CreateFrame("BUTTON", nil, self, "AvatarButtonTemplate");
			self.avatarButtons[i][j] = avatarButton;
			local offset = AVATAR_ICON_SIZE + AVATAR_ICON_SPACING;
			avatarButton:SetPoint("TOPLEFT", (j - 1) * offset, (i - 1) * -offset);
		end
	end
end

function CommunitiesAvatarPickerDialogScrollFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_AVATAR_PICKER_DIALOG_SCROLL_FRAME_EVENTS);
	FauxScrollFrame_SetOffset(self, 0);
	self.ScrollBar:SetValue(0);
	self.avatarIdList = C_Club.GetAvatarIdList(self:GetClubType());
	self:Refresh();
end

function CommunitiesAvatarPickerDialogScrollFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_AVATAR_PICKER_DIALOG_SCROLL_FRAME_EVENTS);
end

function CommunitiesAvatarPickerDialogScrollFrameMixin:OnEvent(event, ...)
	if event == "AVATAR_LIST_UPDATED" then
		local clubType = ...;
		if clubType == self:GetClubType() then
			self.avatarIdList = C_Club.GetAvatarIdList(clubType);
			self:Refresh();
		end
	end
end

function CommunitiesAvatarPickerDialogScrollFrameMixin:OnVerticalScroll(offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, AVATAR_ICON_SIZE, function() self:Refresh() end);
end

function CommunitiesAvatarPickerDialogScrollFrameMixin:GetAvatarId()
	return self:GetParent():GetAvatarId()
end

function CommunitiesAvatarPickerDialogScrollFrameMixin:GetClubType()
	return self:GetParent():GetClubType()
end

function CommunitiesAvatarPickerDialogScrollFrameMixin:Refresh()
	-- Force offset to be a proper multiple of 6 to avoid any shifting
	local offset = math.ceil(FauxScrollFrame_GetOffset(self) / NUM_AVATAR_ICON_COLUMNS) * NUM_AVATAR_ICON_COLUMNS;
	
	local numAvatars = self.avatarIdList and #self.avatarIdList or 0;
	local numShown = NUM_AVATAR_ICON_COLUMNS * NUM_AVATAR_ICON_ROWS;
	for i = 1, NUM_AVATAR_ICON_ROWS do
		for j = 1, NUM_AVATAR_ICON_COLUMNS do
			local avatarButton = self.avatarButtons[i][j];
			local avatarOffset = offset + j + (i - 1) * NUM_AVATAR_ICON_COLUMNS;
			if avatarOffset <= numAvatars then
				local avatarId = self.avatarIdList[avatarOffset];
				avatarButton.avatarId = avatarId;
				avatarButton.Selected:SetShown(self:GetAvatarId() == avatarButton.avatarId);
				C_Club.SetAvatarTexture(avatarButton.Icon, avatarId, self:GetClubType());
				avatarButton:Show();
			else
				avatarButton:Hide();
				numShown = numShown - 1;
			end
		end
	end
	
	local alwaysShowScrollbar = true;
	FauxScrollFrame_Update(self, numAvatars, numShown, AVATAR_ICON_SIZE, nil, nil, nil, nil, nil, nil, alwaysShowScrollbar);
end
