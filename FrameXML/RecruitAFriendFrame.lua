local FriendAddedExplanation;
local FriendAddedNotice;
function RecruitAFriend_OnLoad(self)
	self.exclusive = true;
	self.hideOnEscape = true;
	self:RegisterEvent("RECRUIT_A_FRIEND_INVITER_FRIEND_ADDED");
	self:RegisterEvent("RECRUIT_A_FRIEND_INVITATION_FAILED");
	--self:RegisterEvent("VARIABLES_LOADED");
end

function RecruitAFriend_OnEvent(self, event, ...)
	if ( event == "RECRUIT_A_FRIEND_INVITER_FRIEND_ADDED" ) then
		local otherName = ...;
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(format(RAF_INVITER_FRIEND_ADDED, otherName), info.r, info.g, info.b);
	elseif ( event == "RECRUIT_A_FRIEND_INVITATION_FAILED" ) then
		--[[local errorType = ...;
		if ( errorType == "ACCOUNT_LIMIT" ) then
			RecruitAFriendSentFrame.Description:SetText(RED_FONT_COLOR_CODE..ERR_RECRUIT_A_FRIEND_ACCOUNT_LIMIT..FONT_COLOR_CODE_CLOSE);
		else
			RecruitAFriendSentFrame.Description:SetText(RED_FONT_COLOR_CODE..ERR_RECRUIT_A_FRIEND_FAILED..FONT_COLOR_CODE_CLOSE);
		end]]
	elseif ( event == "VARIABLES_LOADED" ) then
		--[[
		local active = C_RecruitAFriend.GetRecruitInfo();
		if ( active ) then
			if ( not GetCVarBool("displayedRAFFriendInfo") ) then
				SetCVar("displayedRAFFriendInfo", "1");
				if ( not FriendAddedNotice ) then
					FriendAddedNotice = CreateFrame("FRAME", nil, QuickJoinToastButton, "RecruitInfoDialogTemplate");
					FriendAddedNotice:SetPoint("LEFT", QuickJoinToastButton, "RIGHT", 15, 0);
				end
				if ( not FriendAddedExplanation ) then
					FriendAddedExplanation = CreateFrame("FRAME", nil, FriendsFrameFriendsScrollFrame, "RecruitInfoDialogTemplate");
					FriendAddedExplanation:SetPoint("LEFT", FriendsFrameFriendsScrollFrame, "RIGHT", 35, 60);
				end
				RecruitAFriend_ShowInfoDialog(FriendAddedExplanation, RAF_INVITEE_FRIEND_ADDED_EXPLANATION, true);
				RecruitAFriend_ShowInfoDialog(FriendAddedNotice, RAF_INVITEE_FRIEND_ADDED_NOTICE, false);
			end
		else
			--Reset it to the default so that we don't use extra server storage indefinitely
			SetCVar("displayedRAFFriendInfo", GetCVarDefault("displayedRAFFriendInfo"));
		end
		]]
	end
end

function RecruitAFriend_OnFriendsListShown()
	if ( FriendAddedNotice ) then
		FriendAddedNotice:Hide();
	end
end

function RecruitAFriend_OnShow(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

	local factionGroup, factionName = UnitFactionGroup("player");
	self.CharacterInfo.Text:SetFormattedText(RAF_REALM_INFO, factionName, SelectedRealmName());

	RecruitAFriendNameEditBox:SetText("");
	RecruitAFriendNoteEditBox:SetText("");
	RecruitAFriendNameEditBox:SetFocus();
end

function RecruitAFriend_OnEmailTextChanged(self, userInput)
	local text = self:GetText();
	local enableSendButton;
	if ( text ~= "" ) then
		self.Fill:Hide();
		enableSendButton = string.find(text, "@");
	else
		self.Fill:Show();
	end
	RecruitAFriendFrame.SendButton:SetEnabled(enableSendButton);
end

function RecruitAFriend_OnNoteChanged(self, userInput)
	local text = self:GetText();
	self.Fill:SetShown(text == "");
end

function RecruitAFriend_Send()
	C_RecruitAFriend.SendRecruit(RecruitAFriendNameEditBox:GetText(), RecruitAFriendNoteEditBox:GetText(), "Thrall");
	StaticPopupSpecial_Replace(RecruitAFriendSentFrame, RecruitAFriendFrame);

	--RecruitAFriendSentFrame.Description:SetText(RAF_INVITATION_SENT);
	StaticPopupSpecial_Show(RecruitAFriendSentFrame);
end

function RecruitAFriend_ShowInfoDialog(dialog, text, showOKButton)
	dialog.Text:SetText(text);
	dialog.OkayButton:SetShown(showOKButton);
	dialog:Show();
end

--Currently only supports "left" and "right"
function RecruitAFriend_SetInfoDialogDirection(dialog, direction)
	local orientation, offset, point, relativePoint;
	if ( direction == "left" ) then
		orientation = 90;
		offset = 3;
		point = "RIGHT";
		relativePoint = "LEFT";
	elseif ( direction == "right" ) then
		orientation = 270;
		offset = -3;
		point = "LEFT";
		relativePoint = "RIGHT";
	end
	SetClampedTextureRotation(dialog.ArrowShadow, orientation);
	SetClampedTextureRotation(dialog.Arrow, orientation);
	SetClampedTextureRotation(dialog.ArrowGlow, orientation);
	dialog.ArrowShadow:ClearAllPoints()
	dialog.Arrow:ClearAllPoints()
	dialog.ArrowGlow:ClearAllPoints()
	dialog.ArrowShadow:SetPoint(point, dialog, relativePoint, offset, 0);
	dialog.Arrow:SetPoint(point, dialog, relativePoint, offset, 0);
	dialog.ArrowGlow:SetPoint(point, dialog, relativePoint, offset, 0);
end
