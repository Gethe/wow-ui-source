SocialQueueListMixin = {};
function SocialQueueListMixin:OnLoad()
	--[[self:RegisterEvent("SOCIAL_QUEUE_UPDATE");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED");
	self:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED");
	self:FillGaps();]]
end

function SocialQueueListMixin:OnEvent(event, ...)
	if ( event == "SOCIAL_QUEUE_UPDATE" ) then
		local guid = ...;
		local button = self:GetButtonForGUID(guid);
		if ( button ) then
			self:UpdateButton(button);
		end
		self:FillGaps();
	elseif ( event == "LFG_LIST_SEARCH_RESULT_UPDATED" ) then
		local entryID = ...;
		local button = self:GetButtonForLFGListID(entryID);
		if ( button ) then
			self:UpdateButton(button);
		end
	elseif ( event == "LFG_LIST_SEARCH_RESULTS_RECEIVED" ) then
		for _, button in pairs(self.Buttons) do
			if ( button:GetLFGListID() ) then
				self:UpdateButton(button);
			end
		end
	end
end

function SocialQueueListMixin:FillGaps()
	for _, button in ipairs(self.Buttons) do
		if ( not button:IsActive() and not button:IsFadingOut() ) then
			local guid, queueData = self:GetBestUnusedGUID();
			if ( guid and queueData ) then
				button:SetData(guid, queueData);
				button:FadeIn();
			end
		end
	end
	self:UpdateDisplayState();
end

function SocialQueueListMixin:CountNumActiveButtons()
	local count = 0;
	for _, button in ipairs(self.Buttons) do
		if ( button:IsActive() ) then
			count = count + 1;
		end
	end
	return count;
end

function SocialQueueListMixin:UpdateDisplayState()
	local numActiveButtons = self:CountNumActiveButtons();
	if ( numActiveButtons == 0 and self:IsShown() and not self.AnimOut:IsPlaying() ) then
		self.AnimOut:Play();
	elseif ( numActiveButtons > 0 and not self:IsShown() ) then
		self:Show();
		self.AnimIn:Play();
	end
end

function SocialQueueListMixin:UpdateButton(button)
	local guid = button:GetGUID();
	local queueData = C_SocialQueue.GetActiveQueues(guid);
	if ( not queueData ) then
		button:FadeOut(function() self:FillGaps() end);
		self:UpdateDisplayState();
		return;
	end

	button:Update(queueData);
end

function SocialQueueListMixin:GetBestUnusedGUID()
	local guidsWithQueues = C_SocialQueue.GetQueuedGUIDs();
	for _, guid in ipairs(guidsWithQueues) do
		--TODO - add some smarter logic.
		if ( not self:GetButtonForGUID(guid) ) then
			return guid, C_SocialQueue.GetActiveQueues(guid);
		end
	end
end

function SocialQueueListMixin:GetButtonForGUID(guid)
	for _, button in ipairs(self.Buttons) do
		if ( button:GetGUID() == guid ) then
			return button;
		end
	end
end

function SocialQueueListMixin:GetButtonForLFGListID(lfgListID)
	for _, button in ipairs(self.Buttons) do
		if ( button:GetLFGListID() == lfgListID ) then
			return button;
		end
	end
end

-----------------------------
SocialQueueListButtonMixin = {};
function SocialQueueListButtonMixin:OnEnter()
	self.Highlight:Show();
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	SocialQueueUtil_SetTooltip(GameTooltip, self.name, self.queueData);
	GameTooltip:Show();
end

function SocialQueueListButtonMixin:OnLeave()
	self.Highlight:Hide();
	GameTooltip:Hide();
end

function SocialQueueListButtonMixin:SetData(guid, queueData)
	self.guid = guid;
	self.active = true;
	self.name = SocialQueueUtil_GetColoredName(guid);
	self:Update(queueData);
end

function SocialQueueListButtonMixin:Update(queueData)
	--Cache off queue data so we can display tooltips once it starts to fade.
	self.queueData = queueData;

	assert(queueData[1]);
	if ( queueData[1].type == "lfglist" ) then
		self.Icon:SetAtlas("socialqueuing-toast-icon-group", true);
	else
		self.Icon:SetAtlas("socialqueuing-toast-icon-eye", true);
	end
	self.Label:SetText(self:GetTextForQueue(self.name, queueData));

	if ( GameTooltip:GetOwner() == self ) then
		self:OnEnter();
	end
end

function SocialQueueListButtonMixin:GetLFGListID()
	return self:GetGUID() and self.queueData[1] and self.queueData[1].type == "lfglist" and self.queueData[1].lfgListID;
end

function SocialQueueListButtonMixin:GetTextForQueue(name, queueData)
	if ( queueData[1].type == "lfg" or queueData[1].type == "pvp") then
		local queueName = SocialQueueUtil_GetQueueName(queueData[1]);
		return string.format(SOCIAL_QUEUE_QUEUED_LABEL, name or UNKNOWNOBJECT , queueName);
	elseif ( queueData[1].type == "lfglist" ) then
		local lfgListID = queueData[1].lfgListID;
		local id, activityID, groupName, comment, voiceChat, iLvl, honorLevel, age, numBNetFriends, numCharFriends, numGuildMates, isDelisted, leaderName, numMembers = C_LFGList.GetSearchResultInfo(lfgListID);
		local activityName, shortName, categoryID, groupID, minItemLevel, filters, minLevel, maxPlayers, displayType, _, useHonorLevel = C_LFGList.GetActivityInfo(activityID);
		return string.format(SOCIAL_QUEUE_JOINED_LABEL, name or UNKNOWNOBJECT, activityName, groupName);
	end
end

function SocialQueueListButtonMixin:GetGUID()
	return (self:IsActive() or self:IsFadingOut()) and self.guid;
end

function SocialQueueListButtonMixin:FadeIn()
	self.AnimIn:Play();
	self:Show();
end

function SocialQueueListButtonMixin:FadeOut(cb)
	self.fadeOutCB = cb;
	self.fadingOut = true;
	self.active = false;
	self.AnimOut:Play();
end

function SocialQueueListButtonMixin:GetList()
	return self:GetParent();
end

function SocialQueueListButtonMixin:IsFadingOut()
	return self.fadingOut;
end

function SocialQueueListButtonMixin:IsActive()
	return self.active;
end

function SocialQueueListButtonMixin:OnFadeOutFinished()
	self.fadingOut = false;
	self:Hide();
	if ( self.fadeOutCB ) then
		self.fadeOutCB();
	end
end

-----------------------------
--Utils
-----------------------------
function SocialQueueUtil_GetQueueName(queue)
	if ( queue.type == "lfg" ) then
		local lfgID = queue.lfgID;
		local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday, _, _, isTimeWalker = GetLFGDungeonInfo(lfgID);
		if ( subtypeID == LFG_SUBTYPEID_DUNGEON ) then
			return string.format(SOCIAL_QUEUE_FORMAT_DUNGEON, name);
		elseif ( subtypeID == LFG_SUBTYPEID_HEROIC ) then
			return string.format(SOCIAL_QUEUE_FORMAT_HEROIC_DUNGEON, name);
		elseif ( subtypeID == LFG_SUBTYPEID_RAID ) then
			return string.format(SOCIAL_QUEUE_FORMAT_RAID, name);
		elseif ( subtypeID == LFG_SUBTYPEID_FLEXRAID ) then
			return string.format(SOCIAL_QUEUE_FORMAT_RAID, name);
		elseif ( subtypeID == LFG_SUBTYPEID_WORLDPVP ) then
			return string.format(SOCIAL_QUEUE_FORMAT_WORLDPVP, name);
		end
	elseif ( queue.type == "pvp" ) then
		local battlefieldType = queue.battlefieldType;
		local mapName = queue.mapName;
		if ( battlefieldType == "BATTLEGROUND" ) then
			return string.format(SOCIAL_QUEUE_FORMAT_BATTLEGROUND, mapName);
		elseif ( battlefieldType == "ARENA" ) then
			return string.format(SOCIAL_QUEUE_FORMAT_ARENA, queue.teamSize);
		elseif ( battlefieldType == "ARENASKIRMISH" ) then
			return SOCIAL_QUEUE_FORMAT_ARENA_SKIRMISH;
		else
			return mapName;
		end
	elseif ( queue.type == "lfglist" ) then
		if ( queue.lfgListID ) then
			return ( select(3, C_LFGList.GetSearchResultInfo(queue.lfgListID)) )
		end

		local activityID = queue.activityID;
		if ( activityID ) then
			local activityName, shortName, categoryID, groupID, minItemLevel, filters, minLevel, maxPlayers, displayType, _, useHonorLevel = C_LFGList.GetActivityInfo(activityID);
			return activityName;
		end
	end
	return UNKNOWNOBJECT;
end

function SocialQueueUtil_SetTooltip(tooltip, playerDisplayName, data)
	assert(data[1]);


	--For now, you can't queue for both LFGList and LFG+PvP.
	if ( data[1].type == "lfglist" ) then
		if ( C_LFGList.GetSearchResultInfo(data[1].lfgListID) ) then
			LFGListUtil_SetSearchEntryTooltip(tooltip, data[1].lfgListID);
		else
			--We're fading out.
			tooltip:SetText(playerDisplayName, 1, 1, 1, true);
		end
	else
		tooltip:SetText(playerDisplayName, 1, 1, 1, true);
		tooltip:AddLine(SOCIAL_QUEUE_QUEUED_FOR, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		for i=1, #data do
			local queue = data[i];
			local queueName = SocialQueueUtil_GetQueueName(queue);
			tooltip:AddLine(queueName, nil, nil, nil, true);
		end

		tooltip:AddLine(" ");
		tooltip:AddLine(SOCIAL_QUEUE_CLICK_TO_JOIN, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
	end
end

--returns name, color
function SocialQueueUtil_GetNameAndColor(guid)
	local hasFocus, characterName, client, realmName, realmID, faction, race, class, _, zoneName, level, gameText, broadcast, broadcastTime, online, bnetIDGameAccount, bnetIDAccount = BNGetGameAccountInfoByGUID(guid);
	if ( characterName and bnetIDAccount ) then
		local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount, client, isOnline, lastOnline, isBnetAFK, isBnetDND, messageText, noteText, isRIDFriend, messageTime, canSoR = BNGetFriendInfoByID(bnetIDAccount);
		if ( accountName ) then
			return accountName or UNKNOWNOBJECT, FRIENDS_BNET_NAME_COLOR_CODE;
		end
	end

	if ( IsCharacterFriend(guid) ) then
		local name = select(6, GetPlayerInfoByGUID(guid));
		return name or UNKNOWNOBJECT, FRIENDS_WOW_NAME_COLOR_CODE;
	end

	if ( IsGuildMember(guid) ) then
		local name = select(6, GetPlayerInfoByGUID(guid));
		return name or UNKNOWNOBJECT, RGBTableToColorCode(ChatTypeInfo.GUILD);
	end

	local name = select(6, GetPlayerInfoByGUID(guid));
	return name or UNKNOWNOBJECT, FRIENDS_WOW_NAME_COLOR_CODE;
end
