local FriendsFriendsViewType = EnumUtil.MakeEnum(
	"Potential",
	"Mutual",
	"All"
);

FriendsFriendsButtonMixin = {};

function FriendsFriendsButtonMixin:Init(elementData, friendsFrame)
	local friendID = elementData.friendID;
	local accountName = elementData.accountName;
	local isMutual = elementData.isMutual;
	local view = friendsFrame.view;

	if isMutual then
		self:Disable();
		if view ~= FriendsFriendsViewType.Mutual then
			self.Name:SetText(accountName .. " " .. HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(FRIENDS_FRIENDS_MUTUAL_TEXT));
		else
			self.Name:SetText(accountName);
		end
		self.Name:SetTextColor(GRAY_FONT_COLOR:GetRGB());
	elseif friendsFrame.requested[friendID] then
		self.Name:SetText(accountName .. " " .. HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(FRIENDS_FRIENDS_REQUESTED_TEXT));
		self:Disable();
		self.Name:SetTextColor(GRAY_FONT_COLOR:GetRGB());
	else
		self.Name:SetText(accountName);
		self:Enable();
		self.Name:SetTextColor(BATTLENET_FONT_COLOR:GetRGB());
	end
	self.friendID = friendID;

	local selected = friendsFrame.selection == friendID;
	self:SetSelected(selected);
end

function FriendsFriendsButtonMixin:SetSelected(selected)
	if selected then
		self:LockHighlight();
	else
		self:UnlockHighlight();
	end
end

FriendsFriendsFrameMixin = CreateFromMixins(SocialUIScrollableElementExtentPreviewerMixin);

function FriendsFriendsFrameMixin:OnLoad()
	self:RegisterEvent("BN_REQUEST_FOF_SUCCEEDED");
	self:RegisterEvent("BN_DISCONNECTED");
	self.requested = {};
	self.hideOnEscape = true;
	self.exclusive = true;

	UserScaledElementMixin.OnLoad_UserScaledElement(self);
	SocialUIScrollableElementExtentPreviewerMixin.OnLoad(self);

	self.SendRequestButton:SetScript("OnClick", function()
		self:SendRequest();
	end);

	self.CloseButton:SetScript("OnClick", function()
		self:Close();
	end);

	self:InitializeScrollBox();
	self:InitializeDropdown();
end

function FriendsFriendsFrameMixin:InitializeDropdown()
	self.FriendsDropdown.Text:SetFontObject(UserScaledFontGameHighlight);
end

function FriendsFriendsFrameMixin:RefreshVisualsForFontSize()
	local dropdown = self.FriendsDropdown;
	dropdown:UpdateWidth();

	local textXOffset = TextSizeManager:GetScaledValue(8);
	dropdown.Text:ClearAllPoints();
	dropdown.Text:SetPoint("LEFT", dropdown, textXOffset, 0);
	dropdown.Text:SetPoint("RIGHT", dropdown.Arrow, "LEFT", -textXOffset, 0);

	local arrowScale = TextSizeManager:GetWeightedScale(TextSizeManager:GetScale(), { useScaleWeight = true, scaleWeight = 0.4 });
	local arrowXOffset = TextSizeManager:GetScaledValue(-1);
	local arrowYOffset = TextSizeManager:GetScaledValue(-2);
	dropdown.Arrow:ClearAllPoints();
	dropdown.Arrow:SetPoint("TOPRIGHT", dropdown, arrowXOffset, arrowYOffset);
	dropdown.Arrow:SetScale(arrowScale);
end

function FriendsFriendsFrameMixin:InitializeScrollBox()
	self:RegisterScrollableTemplatesForExtentPreview({"FriendsFriendsButtonTemplate"});

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("FriendsFriendsButtonTemplate", function(button, elementData)
		button:SetScript("OnClick", function()
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
			self:SetSelection(button.friendID);
		end);
		button:Init(elementData, self);
	end);

	view:SetElementExtentCalculator(function(_dataIndex, _elementData)
		return self:GetTemplateExtent("FriendsFriendsButtonTemplate");
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.ScrollBox:SetFrameLevel(self.ScrollFrameBorder:GetFrameLevel() + 1);
end

function FriendsFriendsFrameMixin:OnEvent(event)
	if event == "BN_REQUEST_FOF_SUCCEEDED" then
		if self:IsShown() then
			self.view = FriendsFriendsViewType.All;
			self.FriendsDropdown:Enable();
			self.FriendsDropdown:GenerateMenu();

			-- need to stop the flashing because it's flashing with showWhenDone set to true
			if UIFrameIsFlashing(self.WaitFrame) then
				UIFrameFlashStop(self.WaitFrame);
			end
			self.WaitFrame:Hide();
			self:Update();
		end
	elseif event == "BN_DISCONNECTED" then
		self:Close();
	end
end

function FriendsFriendsFrameMixin:OnShow()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);

	EventRegistry:RegisterCallback("TextSizeManager.OnTextScaleUpdated", self.OnFriendsFriendsTextScaleUpdated, self);
	self:ClearTemplateExtentCache();
	self:RefreshVisualsForFontSize();

	local function IsSelected(value)
		return value == self.view;
	end

	local function SetSelected(value)
		self.view = value;
		self:SetSelection(nil);
		self:Update();
	end

	local function CreateViewRadio(rootDescription, text, viewType)
		local radio = rootDescription:CreateRadio(text, IsSelected, SetSelected, viewType);
		radio:AddInitializer(SocialUIUtil.InitializeUserScaledDropdownButton);
		return radio;
	end

	self.FriendsDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_FRIENDS_FRIENDS");

		CreateViewRadio(rootDescription, FRIENDS_FRIENDS_CHOICE_EVERYONE, FriendsFriendsViewType.All);
		CreateViewRadio(rootDescription, FRIENDS_FRIENDS_CHOICE_POTENTIAL, FriendsFriendsViewType.Potential);
		CreateViewRadio(rootDescription, FRIENDS_FRIENDS_CHOICE_MUTUAL, FriendsFriendsViewType.Mutual);
	end);
end

function FriendsFriendsFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	EventRegistry:UnregisterCallback("TextSizeManager.OnTextScaleUpdated", self);
end

function FriendsFriendsFrameMixin:OnFriendsFriendsTextScaleUpdated()
	self:RefreshVisualsForFontSize();
	self:ClearTemplateExtentCache();
	self:Update();
end

function FriendsFriendsFrameMixin:SendRequest()
	if self.selection then
		PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
		self.requested[self.selection] = true;
		BNSendFriendInviteByID(self.selection);
		self:Reset();
		self:Update();
	end
end

function FriendsFriendsFrameMixin:Reset()
	self.SendRequestButton:Disable();
	self.selection = nil;
end

function FriendsFriendsFrameMixin:SetSelection(friendID)
	local oldSelection = self.selection;
	self.selection = friendID;

	local function UpdateButtonSelection(targetFriendID, selected)
		if targetFriendID then
			local button = self.ScrollBox:FindFrameByPredicate(function(frame, elementData)
				return elementData.friendID == targetFriendID;
			end);
			if button then
				button:SetSelected(selected);
			end
		end
	end

	UpdateButtonSelection(oldSelection, false);
	UpdateButtonSelection(friendID, true);

	if friendID then
		self.SendRequestButton:Enable();
	else
		self.SendRequestButton:Disable();
	end
end

function FriendsFriendsFrameMixin:Update()
	if self.WaitFrame:IsShown() then
		return;
	end

	local showMutual, showPotential;
	local view = self.view;
	local bnetIDAccount = self.bnetIDAccount;
	local numFriendsFriends = 0;
	local numMutual, numPotential = BNGetNumFOF(bnetIDAccount);
	if view == FriendsFriendsViewType.Potential or view == FriendsFriendsViewType.All then
		showPotential = true;
		numFriendsFriends = numFriendsFriends + numPotential;
	end
	if view == FriendsFriendsViewType.Mutual or view == FriendsFriendsViewType.All then
		showMutual = true;
		numFriendsFriends = numFriendsFriends + numMutual;
	end

	local dataProvider = CreateDataProvider();
	for index = 1, numFriendsFriends do
		local friendID, accountName, isMutual = BNGetFOFInfo(showMutual, showPotential, index);
		dataProvider:Insert({
			index=index,
			friendID=friendID,
			accountName=accountName,
			isMutual=isMutual
		});
	end

	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function FriendsFriendsFrameMixin:Close()
	if not C_Glue.IsOnGlueScreen() then
		StaticPopupSpecial_Hide(self);
	end
end

function FriendsFriendsFrameMixin:Open(bnetIDAccount)
	local accountInfo = C_BattleNet.GetAccountInfoByID(bnetIDAccount);
	if not accountInfo then
		return;
	end

	self.Title:SetFormattedText(FRIENDS_FRIENDS_HEADER, FRIENDS_BNET_NAME_COLOR_CODE .. accountInfo.accountName .. FONT_COLOR_CODE_CLOSE);
	self.bnetIDAccount = accountInfo.bnetAccountID;
	self.FriendsDropdown:Disable();
	self:Reset();
	self.WaitFrame:Show();
	StaticPopupSpecial_Show(self);
	BNRequestFOFInfo(accountInfo.bnetAccountID);
end

function FriendsFriendsFrame_Show(bnetIDAccount)
	FriendsFriendsFrame:Open(bnetIDAccount);
end

FriendsFriendsWaitFrameMixin = {};

function FriendsFriendsWaitFrameMixin:OnShow()
	if UIFrameIsFlashing(self) then
		UIFrameFlashStop(self);
	end

	local fadeInTime = 1;
	local fadeOutTime = 0.5;
	local flashDuration = 60;
	local showWhenDone = true;
	local flashInHoldTime = 1;
	UIFrameFlash(self, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime);
end
