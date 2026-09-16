BattleNetInviteFrameMixin = {};

function BattleNetInviteFrameMixin:OnLoad()
	self.exclusive = true;
	self.hideOnEscape = true;

	UserScaledElementMixin.OnLoad_UserScaledElement(self);

	self:RegisterEvent("CONFIRM_BATTLE_NET_FRIEND_INVITE_SHOW");

	EventRegistry:RegisterCallback("BattleNetInviteFrame.TitleFriendInviteByNameRequested", self.OnTitleFriendInviteByNameRequested, self);

	self.SendButton:SetScript("OnClick", function()
		if self.sendInviteCallback then
			self.sendInviteCallback();
		end

		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		StaticPopupSpecial_Hide(self);
	end);

	self.CancelButton:SetScript("OnClick", function()
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		StaticPopupSpecial_Hide(self);
	end);
end

function BattleNetInviteFrameMixin:OnEvent(event, ...)
	if event == "CONFIRM_BATTLE_NET_FRIEND_INVITE_SHOW" then
		local name, friendLevel = ...;
		-- BNCheckBattleTagInviteToUnit should have already set the target so SendVerifiedBattleNetFriendInvite takes no arguments
		self:ShowInviteConfirmation(name, friendLevel, C_BattleNet.SendVerifiedBattleNetFriendInvite);
	end
end

function BattleNetInviteFrameMixin:OnHide()
	self:Reset();
end

function BattleNetInviteFrameMixin:Reset()
	self.sendInviteCallback = nil;
end

function BattleNetInviteFrameMixin:OnTitleFriendInviteByNameRequested(targetCharacterName)
	local sendInviteCallback = GenerateClosure(C_BattleNet.SendTitleFriendInviteByName, targetCharacterName);
	self:ShowInviteConfirmation(targetCharacterName, Enum.BattleNetFriendLevel.Title, sendInviteCallback);
end

function BattleNetInviteFrameMixin:ShowInviteConfirmation(name, friendLevel, sendInviteCallback)
	self.InviteeName:SetText(name);
	self:SetTextForFriendLevel(friendLevel);

	if not self:IsShown() then
		StaticPopupSpecial_Show(self);
	end

	self.sendInviteCallback = sendInviteCallback;
end

function BattleNetInviteFrameMixin:SetTextForFriendLevel(friendLevel)
	local text = "";
	if friendLevel == Enum.BattleNetFriendLevel.BattleTag then
		text = BATTLE_TAG_REQUEST;
	elseif friendLevel == Enum.BattleNetFriendLevel.Title then
		text = TITLE_FRIEND_REQUEST;
	end

	self.InviteText:SetText(text);
end

function AddFriendFrame_Show()
	local name = nil;
	if not C_Glue.IsOnGlueScreen() then
		name = GetUnitName("target", true);
	end

	if ( name and UnitIsHumanPlayer("target") and UnitCanCooperate("player", "target") and C_FriendList.IsLegacyFriendSystemEnabled() and not C_FriendList.GetFriendInfo(name) ) then
		C_FriendList.AddFriend(name);
		PlaySound(SOUNDKIT.U_CHAT_SCROLL_BUTTON);
	else
		local _, battleTag, _, _, _, _, isRIDEnabled = BNGetInfo();
		if ( ( battleTag or isRIDEnabled ) and BNFeaturesEnabledAndConnected() ) then
			AddFriendEntryFrame_Init(true);
			AddFriendFrame.editFocus = AddFriendNameEditBox;
			if InGlue() then
				StaticPopup_Show("ADD_FRIEND");
			else
				StaticPopupSpecial_Show(AddFriendFrame);
				if ( GetCVarBool("addFriendInfoShown") ) then
					AddFriendFrame:ShowEntry();
				else
					AddFriendFrame:ShowInfo();
				end
			end
		else
			if C_FriendList.IsLegacyFriendSystemEnabled() then
				StaticPopup_Show("ADD_FRIEND");
			elseif not InGlue() then
				UIErrorsFrame:AddExternalErrorMessage(BATTLENET_UNAVAILABLE);
			end
		end
	end
end

AddFriendFrameMixin = {};

function AddFriendFrameMixin:OnLoad()
	self.exclusive = true;
	self.hideOnEscape = true;
end

function AddFriendFrameMixin:OnShow()
	local areTitleFriendsEnabled = C_BattleNet.AreTitleFriendsEnabled();
	AddFriendInfoFrame.InfoContainer.RightTextContainer.Description:SetText(areTitleFriendsEnabled and WOW_FRIEND_DESCRIPTION or CHARACTER_FRIEND_INFO);
end

function AddFriendFrameMixin:OnHide()
	self.editFocus = nil;
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function AddFriendFrameMixin:Resize()
	self:Layout();
end

function AddFriendFrameMixin:ShowInfo()
	AddFriendInfoFrame:Show();
	AddFriendEntryFrame:Hide();
	self:Resize();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function AddFriendFrameMixin:ShowEntry()
	AddFriendInfoFrame:Hide();
	if ( BNFeaturesEnabledAndConnected() ) then
		self.BNconnected = true;
		AddFriendEntryFrame.OptionsContainer.LeftTextContainer.Title:SetAlpha(1);
		AddFriendEntryFrame.OptionsContainer.LeftTextContainer.Description:SetTextColor(1, 1, 1);
		AddFriendEntryFrame.OptionsContainer.LeftTextContainer.IconHolder.SecondaryIcon:SetVertexColor(1, 1, 1);
		AddFriendEntryFrame.OptionsContainer.LeftTextContainer.IconHolder.FriendIcon:SetVertexColor(1, 1, 1);
		local _, battleTag, _, _, _, _, isRIDEnabled = BNGetInfo();
		if ( battleTag and isRIDEnabled ) then
			AddFriendEntryFrame.OptionsContainer.LeftTextContainer.Title:SetText(BATTLETAG_OR_REAL_ID_LABEL);
			AddFriendEntryFrame.OptionsContainer.LeftTextContainer.Description:SetText(REALID_BATTLETAG_FRIEND_LABEL);
			AddFriendNameEditBoxFill:SetText(ENTER_NAME_OR_BATTLETAG_OR_EMAIL);
		elseif ( isRIDEnabled ) then
			AddFriendEntryFrame.OptionsContainer.LeftTextContainer.Title:SetText(REAL_ID);
			AddFriendEntryFrame.OptionsContainer.LeftTextContainer.Description:SetText(REALID_FRIEND_LABEL);
			AddFriendNameEditBoxFill:SetText(ENTER_NAME_OR_EMAIL);
		elseif ( battleTag ) then
			AddFriendEntryFrame.OptionsContainer.LeftTextContainer.Title:SetText(BATTLETAG);
			AddFriendEntryFrame.OptionsContainer.LeftTextContainer.Description:SetText(BATTLETAG_FRIEND_LABEL);
			AddFriendNameEditBoxFill:SetText(ENTER_NAME_OR_BATTLETAG);
		end
	else
		self.BNconnected = nil;
		AddFriendEntryFrame.OptionsContainer.LeftTextContainer.Title:SetAlpha(0.35);
		AddFriendEntryFrame.OptionsContainer.LeftTextContainer.Description:SetText(BATTLENET_UNAVAILABLE);
		AddFriendEntryFrame.OptionsContainer.LeftTextContainer.Description:SetTextColor(1, 0, 0);
		AddFriendEntryFrame.OptionsContainer.LeftTextContainer.IconHolder.SecondaryIcon:SetVertexColor(.4, .4, .4);
		AddFriendEntryFrame.OptionsContainer.LeftTextContainer.IconHolder.FriendIcon:SetVertexColor(.4, .4, .4);
	end
	if ( self.editFocus ) then
		self.editFocus:SetFocus();
	end
	AddFriendEntryFrame:Show();
	self:Resize();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function AddFriendNameEditBox_OnTextChanged(self, userInput)
	if ( not AutoCompleteEditBox_OnTextChanged(self, userInput) ) then
		local text = self:GetText();
		if ( text ~= "" ) then
			AddFriendNameEditBoxFill:Hide();
			if ( AddFriendFrame.BNconnected ) then
				AddFriendEntryFrame_Init();
			end
			AddFriendEntryFrameAcceptButton:Enable();
		else
			AddFriendEntryFrame_Init();
			AddFriendNameEditBoxFill:Show();
			AddFriendEntryFrameAcceptButton:Disable();
		end
	end
end

function AddFriendEntryFrame_Init(clearText)
	AddFriendEntryFrameAcceptButton:SetText(SEND_REQUEST);
	AddFriendEntryFrame.OptionsContainer.RightTextContainer.Title:SetAlpha(1);
	AddFriendEntryFrame.OptionsContainer.RightTextContainer.Description:SetAlpha(1);
	AddFriendEntryFrame.OptionsContainer.RightTextContainer.IconHolder.SecondaryIcon:SetVertexColor(1, 1, 1);
	AddFriendEntryFrame.OptionsContainer.RightTextContainer.IconHolder.FriendIcon:SetVertexColor(1, 1, 1);
	if ( AddFriendFrame.BNconnected ) then
		AddFriendEntryFrame.OptionsContainer.OrLabel:SetVertexColor(1, 1, 1);
	else
		AddFriendEntryFrame.OptionsContainer.OrLabel:SetVertexColor(0.3, 0.3, 0.3);
	end
	if ( clearText ) then
		AddFriendNameEditBox:SetText("");
	end
end

function AddFriendFrame_Accept()
	local name = AddFriendNameEditBox:GetText();
	if ( AddFriendFrame_IsValidBattlenetName(name) and AddFriendFrame.BNconnected ) then
		BNSendFriendInvite(name, "");
	elseif C_BattleNet.AreTitleFriendsEnabled() then
		C_BattleNet.SendTitleFriendInviteByName(name);
	elseif C_FriendList.IsLegacyFriendSystemEnabled() then
		C_FriendList.AddFriend(name);
	else
		UIErrorsFrame:AddExternalErrorMessage(ERR_SYSTEM_DISABLED);
	end
	StaticPopupSpecial_Hide(AddFriendFrame);
end

function AddFriendFrame_IsValidBattlenetName(text)
	local _, battleTag, _, _, _, _, isRIDEnabled = BNGetInfo();
	if ( isRIDEnabled and string.find(text, "@") ) then
		return true;
	end
	if ( battleTag and string.find(text, "#") ) then
		return true;
	end
	return false;
end

function GlueAddFriendAccept(name)
	if ( IsValidBattlenetName(name) ) then
		BNSendFriendInvite(name, "");
	elseif C_BattleNet.AreTitleFriendsEnabled() then
		C_BattleNet.SendTitleFriendInviteByName(name);
	elseif C_FriendList.IsLegacyFriendSystemEnabled() then
		C_FriendList.AddFriend(name);
	end
end

function IsValidBattlenetName(text)
	local _, battleTag, _, _, _, _, isRIDEnabled = BNGetInfo();
	if ( isRIDEnabled and string.find(text, "@") ) then
		return true;
	end
	if ( battleTag and string.find(text, "#") ) then
		return true;
	end
	return false;
end

AddFriendIconHolderMixin = {};

function AddFriendIconHolderMixin:OnLoad()
	if self.secondaryIconAtlas then
		self.SecondaryIcon:SetAtlas(self.secondaryIconAtlas, TextureKitConstants.UseAtlasSize);
	end
end

AddFriendEntryFrameInfoButtonMixin = {};

function AddFriendEntryFrameInfoButtonMixin:OnLoad()
	UserScaledElementMixin.OnLoad_UserScaledElement(self);

	-- Unlike other buttons that use this button template, this one scales with font size
	-- Let's reanchor the assets so they scale properly
	self:InitResizableTextures();
end

function AddFriendEntryFrameInfoButtonMixin:InitResizableTextures()
	self.texture:ClearAllPoints();
	self.texture:SetPoint("TOPLEFT", self);
	self.texture:SetPoint("BOTTOMRIGHT", self);

	self.HighlightTexture:ClearAllPoints();
	self.HighlightTexture:SetPoint("TOPLEFT", self);
	self.HighlightTexture:SetPoint("BOTTOMRIGHT", self);
end

function AddFriendEntryFrameInfoButtonMixin:OnClick()
	if AddFriendNameEditBox:HasFocus() then
		AddFriendFrame.editFocus = AddFriendNameEditBox;
	else
		AddFriendFrame.editFocus = nil;
	end
	AddFriendFrame:ShowInfo();
end

AddFriendCloseButtonMixin = {};

function AddFriendCloseButtonMixin:OnClick()
	StaticPopupSpecial_Hide(AddFriendFrame);
end
