local BN_TOAST_TYPE_ONLINE = 1;
local BN_TOAST_TYPE_OFFLINE = 2;
local BN_TOAST_TYPE_BROADCAST = 3;
local BN_TOAST_TYPE_PENDING_INVITES = 4;
local BN_TOAST_TYPE_NEW_INVITE = 5;
local BN_TOAST_TYPE_CLUB_INVITATION = 6;

BNET_CLIENT_WOW = "WoW";
BNET_CLIENT_APP = "App";
BNET_CLIENT_HEROES = "Hero";
BNET_CLIENT_CLNT = "CLNT";

--Name can be a realID or plain battletag with no 4 digit number (e.g. Murky McGrill or LichKing).
function BNet_GetBNetIDAccount(name)
	return GetAutoCompletePresenceID(name);
end

--Name must be a character name from your friends list.
function BNet_GetBNetIDAccountFromCharacterName(name)
	local _, numBNetOnline = BNGetNumFriends();
	for i = 1, numBNetOnline do
		local opaqueID, displayName, battleTag, _, characterName = BNGetFriendInfo(i);
		if ( (characterName and strcmputf8i(name, characterName) == 0) ) then
			return opaqueID;
		end
	end
end

-- BNET toast

BNToastMixin = {}

function BNToastMixin:OnLoad()
	self.BNToastEvents = {
		showToastOnline = { "BN_FRIEND_ACCOUNT_ONLINE" },
		showToastOffline = { "BN_FRIEND_ACCOUNT_OFFLINE" },
		showToastClubInvitation = { "CLUB_INVITATION_ADDED_FOR_SELF" },
		showToastBroadcast = { "BN_CUSTOM_MESSAGE_CHANGED" },
		showToastFriendRequest = { "BN_FRIEND_INVITE_ADDED", "BN_FRIEND_INVITE_LIST_INITIALIZED" },
	};

	self.BNToasts = {};
	self.DoubleLine:SetSpacing(3);
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("BN_DISCONNECTED");
	self:RegisterEvent("BN_BLOCK_FAILED_TOO_MANY");

	local alertSystem = ChatAlertFrame:AddAutoAnchoredSubSystem(self);
	ChatAlertFrame:SetSubSystemAnchorPriority(alertSystem, 1);
end

function BNToastMixin:OnEvent(event, ...)
	if ( event == "BN_DISCONNECTED" ) then
		self:ClearToasts();
	elseif ( event == "BN_BLOCK_FAILED_TOO_MANY" ) then
		self:BlockFailed(...);
	elseif ( event == "BN_FRIEND_ACCOUNT_ONLINE" ) then
		self:AddToast(BN_TOAST_TYPE_ONLINE, ...);
	elseif ( event == "BN_FRIEND_ACCOUNT_OFFLINE" ) then
		self:AddToast(BN_TOAST_TYPE_OFFLINE, ...);
	elseif ( event == "BN_CUSTOM_MESSAGE_CHANGED" ) then
		self:OnCustomMessageChanged(...);
	elseif ( event == "BN_FRIEND_INVITE_ADDED" ) then
		self:AddToast(BN_TOAST_TYPE_NEW_INVITE);
	elseif ( event == "CLUB_INVITATION_ADDED_FOR_SELF" ) then
		self:AddToast(BN_TOAST_TYPE_CLUB_INVITATION, ...);
	elseif ( event == "BN_FRIEND_INVITE_LIST_INITIALIZED" ) then
		self:AddToast(BN_TOAST_TYPE_PENDING_INVITES, ...);
	elseif( event == "VARIABLES_LOADED" ) then
		self:OnVariablesLoaded();
	end
end

function BNToastMixin:OnHide()
	self:CheckShowToast();
end

function BNToastMixin:OnEnter()
	AlertFrame_PauseOutAnimation(self);

	if self.toastType == BN_TOAST_TYPE_BROADCAST and self.BottomLine:IsTruncated() then
		self.TooltipFrame.Text:SetText(self.BottomLine:GetText());
		self.TooltipFrame:Show();
	end
end

function BNToastMixin:OnLeave()
	AlertFrame_ResumeOutAnimation(self);
	self.TooltipFrame:Hide();
end

function BNToastMixin:OnClick()
	local toastType = self.toastType;
	local toastData = self.toastData;

	self:Hide(); -- will trigger next toast

	if toastType == BN_TOAST_TYPE_NEW_INVITE or toastType == BN_TOAST_TYPE_PENDING_INVITES then
		if not FriendsFrame:IsShown() then
			ToggleFriendsFrame(FRIEND_TAB_FRIENDS);
		end

		if GetCVarBool("friendInvitesCollapsed") then
			FriendsListFrame_ToggleInvites();
		end

		FriendsTabHeaderTab1:Click();
	elseif toastType == BN_TOAST_TYPE_ONLINE or toastType == BN_TOAST_TYPE_BROADCAST then
		local bnetIDAccount, accountName = BNGetFriendInfoByID(toastData);
		if accountName then --This player may have been removed from our friends list, so we may not have a name.
			ChatFrame_SendBNetTell(accountName);
		end
	elseif toastType == BN_TOAST_TYPE_CLUB_INVITATION then
		ShowUIPanel(CommunitiesFrame);
		CommunitiesFrame:SelectClub(toastData.club.clubId);
	end
end

function BNToastMixin:ClearToasts()
	table.wipe(self.BNToasts);
end

function BNToastMixin:BlockFailed(blockType)
	if ( blockType == "RID" ) then
		StaticPopup_Show("BN_BLOCK_FAILED_TOO_MANY_RID");
	elseif ( blockType == "CID" ) then
		StaticPopup_Show("BN_BLOCK_FAILED_TOO_MANY_CID");
	end
end

function BNToastMixin:OnCustomMessageChanged(toastData)
	if toastData then
		self:AddToast(BN_TOAST_TYPE_BROADCAST, toastData);
	end
end

function BNToastMixin:OnVariablesLoaded()
	self:SetToastDuration(GetCVar("toastDuration"));
	self:SetToastsEnabled(GetCVarBool("showToastWindow"));
end

function BNToastMixin:EnableToasts()
	for cvar, events in pairs(self.BNToastEvents) do
		if GetCVarBool(cvar) then
			for eventIndex, event in ipairs(events) do
				self:RegisterEvent(event);
			end
		end
	end
end

function BNToastMixin:DisableToasts()
	self:ClearToasts();
	self:Hide();

	for cvar, events in pairs(self.BNToastEvents) do
		for eventIndex, event in ipairs(events) do
			self:UnregisterEvent(event);
		end
	end
end

function BNToastMixin:UpdateToastEvent(cvar, value)
	if GetCVarBool("showToastWindow") then
		local events = self.BNToastEvents[cvar];
		if events and value == "1" then
			for eventIndex, event in pairs(events) do
				self:RegisterEvent(event);
			end
		else
			for eventIndex, event in pairs(events) do
				self:UnregisterEvent(event);
			end
		end
	end
end

function BNToastMixin:SetToastsEnabled(enabled)
	if enabled then
		self:EnableToasts();
	else
		self:DisableToasts();
	end
end

function BNToastMixin:SetToastDuration(duration)
	self.duration = duration;
end

function BNToastMixin:ShowToast()
	local toast = tremove(self.BNToasts, 1);
	local toastType, toastData = toast.toastType, toast.toastData;

	local topLine = self.TopLine;
	local middleLine = self.MiddleLine;
	local bottomLine = self.BottomLine;
	local doubleLine = self.DoubleLine;

	topLine:Hide();
	middleLine:Hide();
	bottomLine:Hide();
	doubleLine:Hide();

	if ( toastType == BN_TOAST_TYPE_NEW_INVITE ) then
		self.IconTexture:SetTexCoord(0.75, 1, 0, 0.5);
		doubleLine:Show();
		doubleLine:SetText(BN_TOAST_NEW_INVITE);
		doubleLine:SetMaxLines(0);
	elseif ( toastType == BN_TOAST_TYPE_PENDING_INVITES ) then
		self.IconTexture:SetTexCoord(0.75, 1, 0, 0.5);
		doubleLine:Show();
		doubleLine:SetFormattedText(BN_TOAST_PENDING_INVITES, toastData);
	elseif ( toastType == BN_TOAST_TYPE_ONLINE ) then
		local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount, client = BNGetFriendInfoByID(toastData);
		-- don't display a toast if we didn't get the data in time
		if ( not accountName ) then
			return;
		end

		if (battleTag) then
			characterName = BNet_GetValidatedCharacterName(characterName, battleTag, client) or "";
			characterName = BNet_GetClientEmbeddedAtlas(client, 14, 14, 0, -1)..characterName;
			middleLine:SetFormattedText(characterName);
			middleLine:SetTextColor(FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g, FRIENDS_BNET_NAME_COLOR.b);
			middleLine:Show();
		end

		self.IconTexture:SetTexCoord(0, 0.25, 0.5, 1);
		topLine:Show();
		topLine:SetText(FRIENDS_BNET_NAME_COLOR:WrapTextInColorCode(accountName));
		bottomLine:Show();
		bottomLine:SetText(FRIENDS_GRAY_COLOR:WrapTextInColorCode(BN_TOAST_ONLINE));
	elseif ( toastType == BN_TOAST_TYPE_OFFLINE ) then
		local bnetIDAccount, accountName = BNGetFriendInfoByID(toastData);
		-- don't display a toast if we didn't get the data in time
		if ( not accountName ) then
			return;
		end
		self.IconTexture:SetTexCoord(0, 0.25, 0.5, 1);
		topLine:Show();
		topLine:SetFormattedText(FRIENDS_BNET_NAME_COLOR:WrapTextInColorCode(accountName));
		bottomLine:Show();
		bottomLine:SetText(BN_TOAST_OFFLINE);
		bottomLine:SetTextColor(FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g, FRIENDS_GRAY_COLOR.b);
		doubleLine:Hide();
		middleLine:Hide();
	elseif ( toastType == BN_TOAST_TYPE_BROADCAST ) then
		local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount, client, isOnline, lastOnline, isAFK, isDND, messageText = BNGetFriendInfoByID(toastData);
		if ( not messageText or messageText == "" ) then
			return;
		end
		BNToastFrameIconTexture:SetTexCoord(0, 0.25, 0, 0.5);
		topLine:Show();
		topLine:SetText(accountName);
		topLine:SetTextColor(FRIENDS_BNET_NAME_COLOR.r, FRIENDS_BNET_NAME_COLOR.g, FRIENDS_BNET_NAME_COLOR.b);
		bottomLine:Show();
		bottomLine:SetText(messageText);
		bottomLine:SetTextColor(FRIENDS_GRAY_COLOR.r, FRIENDS_GRAY_COLOR.g, FRIENDS_GRAY_COLOR.b);
		doubleLine:Hide();
		middleLine:Hide();
	elseif ( toastType == BN_TOAST_TYPE_CLUB_INVITATION ) then
		self.IconTexture:SetTexCoord(0.5, 0.75, 0, 0.5);
		doubleLine:Show();
		local clubName = "";
		clubName = BATTLENET_FONT_COLOR:WrapTextInColorCode(toastData.club.name);
		doubleLine:SetText(BN_TOAST_NEW_CLUB_INVITATION:format(clubName));
		doubleLine:SetMaxLines(2);
	end

	if (middleLine:IsShown() and bottomLine:IsShown()) then
		bottomLine:SetPoint("TOPLEFT", middleLine, "BOTTOMLEFT", 0, -4);
		self:SetHeight(63);
	else
		bottomLine:SetPoint("TOPLEFT", topLine, "BOTTOMLEFT", 0, -4);
		self:SetHeight(50);
	end

	PlaySound(SOUNDKIT.UI_BNET_TOAST);
	self.toastType = toastType;
	self.toastData = toastData;
	AlertFrame_ShowNewAlert(self);
end

function BNToastMixin:CheckShowToast()
	if #self.BNToasts > 0 then
		self:ShowToast();
	end
end

function BNToastMixin:AddToast(toastType, toastData)
	self:RemoveToast(toastType, toastData);
	tinsert(self.BNToasts, { toastType = toastType, toastData = toastData });
	self:ShowToast();
end

function BNToastMixin:RemoveToast(toastType, toastData)
	for toastIndex, toast in ipairs(self.BNToasts) do
		if toast.toastType == toastType and toast.toastData == toastData then
			tremove(self.BNToasts, toastIndex);
			break;
		end
	end
end

--This is used to track time played for an alert in Korea

BNetTimeAlertMixin = {};

function BNetTimeAlertMixin:OnLoad()
	self:RegisterEvent("SESSION_TIME_ALERT");

	local alertSystem = ChatAlertFrame:AddAutoAnchoredSubSystem(self);
	ChatAlertFrame:SetSubSystemAnchorPriority(alertSystem, 2);
end

function BNetTimeAlertMixin:OnEvent(event, ...)
	if not self:IsShown() then
		self:Start(...);
	end
end

function BNetTimeAlertMixin:Start(time)
	self:SetExternallyManagedOutroAnimation(true); -- Initially this needs to display for a set amount of time, after which the alert system takes over and fades it out.
	AlertFrame_ShowNewAlert(self);
	self.timer = time / 1000;
end

function BNetTimeAlertMixin:OnUpdate(elapsed)
	if self.timer then
		self.timer = self.timer - elapsed;
		if self.timer < 0 then
			self:SetExternallyManagedOutroAnimation(false);
			AlertFrame_PlayOutroAnimation(self);
			self.timer = nil;
		end
	end

	-- As long as this frame is shown, continue to update
	self.Text:SetFormattedText(TIME_PLAYED_ALERT, SecondsToTime(GetSessionTime(), true, true));
	self:SetHeight(self.Text:GetStringHeight() + 20);
end

-- if we don't have a character name or it's for a game that doesn't have toons like Heroes, use the battletag
function BNet_GetValidatedCharacterName(characterName, battleTag, client)
	if ( not characterName or characterName == "" or client == BNET_CLIENT_HEROES ) then
		if ( battleTag and battleTag ~= "" ) then
			local symbol = string.find(battleTag, "#");
			if ( symbol ) then
				return string.sub(battleTag, 1, symbol - 1);
			else
				return battleTag;
			end
		else
			return nil;
		end
	end
	return characterName;
end

function BNet_GetValidatedCharacterNameWithClientEmbeddedTexture(characterName, battleTag, texture, fileWidth, fileHeight, texWidth, texHeight, texXOffset, texYOffset)
	return BNet_GetClientEmbeddedTexture(texture, fileWidth, fileHeight, texWidth, texHeight, texXOffset, texYOffset).." "..BNet_GetValidatedCharacterName(characterName, battleTag, client);
end
