QUICK_JOIN_TOAST_QUEUE_MULTIPLIER = 1000;
QUICK_JOIN_TOAST_PLAYER_MULTIPLIER = 1;
QUICK_JOIN_TOAST_PLAYER_FRIEND_VALUE = 4;
QUICK_JOIN_TOAST_PLAYER_GUILD_VALUE = 1;
QUICK_JOIN_TOAST_DURATION = 7;
QUICK_JOIN_TOAST_DELAY_DURATION = 10;
--
QuickJoinToastMixin = {}

function QuickJoinToastMixin:OnLoad()
	self:RegisterEvent("SOCIAL_QUEUE_UPDATE");
	self.groups = {};
	self.groupsAwaitingDisplay = {};

	self:SetPoint("BOTTOM", DEFAULT_CHAT_FRAME.buttonFrame, "TOP", 0, 36);
	self.FriendCount:SetShadowOffset(1, 1);

	self:UpdateDisplayedFriendCount();

	--Flag everything as seen
	local groups = C_SocialQueue.GetAllGroups(true);
	for i=1, #groups do
		local group = CreateFromMixins(QuickJoinToastGroupMixin);
		group:Init(groups[i]);
		group:MarkAllAsDisplayed();
		self.groups[groups[i]] = group;
	end
end

function QuickJoinToastMixin:OnEvent(event, ...)
	if ( event == "SOCIAL_QUEUE_UPDATE" ) then
		local guid, numAddedItems = ...;

		local canJoin, numQueues = C_SocialQueue.GetGroupInfo(guid);

		if ( not numQueues or numQueues == 0 ) then
			self.groups[guid] = nil;
			self.groupsAwaitingDisplay[guid] = nil;
			return;
		end

		local group = self.groups[guid];
		if ( group ) then
			group:Update();
		else
			group = CreateFromMixins(QuickJoinToastGroupMixin);
			group:Init(guid);
			self.groups[guid] = group;
		end

		if ( group:GetPriority() > 0 ) then
			if ( not self.groupsAwaitingDisplay[guid] ) then
				self.groupsAwaitingDisplay[guid] = true;
				group:SetDelayed(true);
				C_Timer.After(QUICK_JOIN_TOAST_DELAY_DURATION, function()
					group:SetDelayed(false);
					if ( not self.displayedToast ) then
						self:CheckDisplayToast();
					end
				end);
			end
		else
			self.groupsAwaitingDisplay[guid] = nil;
		end

		if ( not self.displayedToast ) then
			self:CheckDisplayToast();
		end

		self.QueueCount:SetText(#C_SocialQueue.GetAllGroups(false));
	end
end

function QuickJoinToastMixin:UpdateDisplayedFriendCount()
	local _, numBNetOnline = BNGetNumFriends();
	local _, numWoWOnline = GetNumFriends();
	self.FriendCount:SetText(numBNetOnline + numWoWOnline);
end

function QuickJoinToastMixin:CheckDisplayToast(hideIfNeeded)
	local group = self:GetHighestPriorityGroup();
	if ( group and self:ShouldDisplayGroup(group) ) then
		self:ShowToast(group);
	elseif ( self.displayedToast and hideIfNeeded ) then
		self:HideToast();
	end
end

function QuickJoinToastMixin:GetHighestPriorityGroup()
	local highestGroup = nil;
	local highestPriority = 0;
	for guid, _ in pairs(self.groupsAwaitingDisplay) do
		local group = self.groups[guid];
		if ( group ) then
			if ( not group:IsDelayed() ) then
				local priority = group:GetPriority();
				if ( priority > highestPriority ) then
					highestGroup = group;
					highestPriority = priority;
				end
			end
		else
			GMError("Have a group guid, but not group?");
		end
	end

	return highestGroup;
end

function QuickJoinToastMixin:ShouldDisplayGroup(group)
	--TODO - Throttling
	return true;
end

function QuickJoinToastMixin:ShowToast(group)
	self.ToastActiveAnim:Stop();

	self.oldToast = self.displayedToast;
	self.displayedToast = group;
	if ( self.oldToast ) then
		self.Toast2.Text:SetText(self:GetCurrentText());
		self.ToastToToastAnim:Play();
	else
		self.Toast.Text:SetText(self:GetCurrentText());
		self.FriendToToastAnim:Play();
	end

	self:SetHitRectInsets(0, -self.Toast:GetWidth(), 0, 0);
end

function QuickJoinToastMixin:HideToast()
	self:SetHitRectInsets(0, 0, 0, 0);
	self.ToastActiveAnim:Stop();
	self.ToastToFriendAnim:Play();
end

function QuickJoinToastMixin:OnClick(button)
	if ( self.displayedToast ) then
		ToggleQuickJoinPanel();
	else
		ToggleFriendsFrame(1);
	end
end

function QuickJoinToastMixin:OnMouseDown()
	self.FriendsButton:SetAtlas("quickjoin-button-friendslist-down");
	self.QueueButton:SetAtlas("quickjoin-button-quickjoin-down");
end

function QuickJoinToastMixin:OnMouseUp()
	self.FriendsButton:SetAtlas("quickjoin-button-friendslist-up");
	self.QueueButton:SetAtlas("quickjoin-button-quickjoin-up");
end

function QuickJoinToastMixin:OnEnter()
	if ( self.displayedToast ) then
		local queues = C_SocialQueue.GetGroupQueues(self.displayedToast.guid);
		if ( queues ) then
			GameTooltip:SetOwner(self.Toast, "ANCHOR_RIGHT");
			SocialQueueUtil_SetTooltip(GameTooltip, SOCIAL_QUEUE_TOOLTIP_HEADER, queues);
			GameTooltip:Show();
		end
	else
		GameTooltip_AddNewbieTip(self, MicroButtonTooltipText(SOCIAL_BUTTON, "TOGGLESOCIAL"), 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_SOCIAL);
	end
end

function QuickJoinToastMixin:OnLeave()
	GameTooltip:Hide();
end

function QuickJoinToastMixin:GetCurrentText()
	local group = self.displayedToast;

	local members = C_SocialQueue.GetGroupMembers(group.guid);
	local playerName, color = SocialQueueUtil_GetNameAndColor(members[1]);

	if ( #members > 1 ) then
		playerName = string.format(QUICK_JOIN_TOAST_EXTRA_PLAYERS, playerName, #members - 1);
	end
	playerName = color..playerName..FONT_COLOR_CODE_CLOSE;

	local queues = group:GetNewQueues();
	local queueName = SocialQueueUtil_GetQueueName(queues[1]);
	if ( #queues > 1 ) then
		queueName = string.format(QUICK_JOIN_TOAST_EXTRA_QUEUES, queueName, #queues - 1);
	end

	if ( queues[1].type == "lfglist" ) then
		return string.format(QUICK_JOIN_TOAST_LFGLIST_MESSAGE, playerName, queueName);
	else
		return string.format(QUICK_JOIN_TOAST_MESSAGE, playerName, queueName);
	end
end

-------------------------------
-----Anim callbacks------------
-------------------------------
function QuickJoinToastMixin:ToastPulse()
	if ( GetTime() - self.displayedTime > QUICK_JOIN_TOAST_DURATION ) then
		self:CheckDisplayToast(true);
	else
		self.ToastActiveAnim:Play();
	end
end

function QuickJoinToastMixin:FriendToToastFinished()
	self.displayedTime = GetTime();
	self.ToastActiveAnim:Play();
	self.displayedToast:MarkAllAsDisplayed();
end

function QuickJoinToastMixin:ToastToToastFinished()
	self.displayedTime = GetTime();
	self.ToastActiveAnim:Play();
	self.Toast.Text:SetText(self:GetCurrentText());
	self.displayedToast:MarkAllAsDisplayed();
end

function QuickJoinToastMixin:ToastToFriendFinished()
	self.displayedToast = nil;
	self:CheckDisplayToast();
end
---------------------------
--QuickJoinToastGroup------
---------------------------
QuickJoinToastGroupMixin = {};

function QuickJoinToastGroupMixin:Init(guid)
	self.guid = guid;
	self.displayedQueues = {};
	self:Update();
end

function QuickJoinToastGroupMixin:SetDelayed(delayed)
	self.delayed = delayed;
end

function QuickJoinToastGroupMixin:IsDelayed()
	return self.delayed;
end

function QuickJoinToastGroupMixin:MarkAllAsDisplayed()
	local queues = C_SocialQueue.GetGroupQueues(self.guid);
	local newDisplayedQueues = {};
	if ( queues ) then
		for i=1, #queues do
			local queue = queues[i];
			newDisplayedQueues[queue.clientID] = true;
		end
	end
	self.displayedQueues = newDisplayedQueues;
	self:Update();
end

function QuickJoinToastGroupMixin:GetNewQueues()
	local newQueues = {};
	local queues = C_SocialQueue.GetGroupQueues(self.guid);

	for i=1, #queues do
		if ( not self.displayedQueues[queues[i].clientID] ) then
			queues[i].tableIndex = i;
			newQueues[#newQueues + 1] = queues[i];
		end
	end

	table.sort(newQueues, function(a, b)
		local priorityA = QuickJoinToast_GetPriorityFromQueue(a);
		local priorityB = QuickJoinToast_GetPriorityFromQueue(b);
		if ( priorityA == priorityB ) then
			return a.tableIndex < b.tableIndex;
		end
		return priorityA > priorityB;
	end);

	return newQueues;
end

--This function is just a global to make it easier for AddOns to hook/replace
function QuickJoinToast_GetPriority(group, queues, players)
	local maxQueuePriority = 0;
	for i=1, #queues do
		local queue = queues[i];
		if ( not group.displayedQueues[queue.clientID] ) then
			maxQueuePriority = math.max(maxQueuePriority, QuickJoinToast_GetPriorityFromQueue(queue));
		end
	end

	if ( maxQueuePriority > 0 ) then
		return maxQueuePriority * QUICK_JOIN_TOAST_QUEUE_MULTIPLIER + QuickJoinToast_GetPriorityFromPlayers(players)  * QUICK_JOIN_TOAST_PLAYER_MULTIPLIER;
	else
		return 0;
	end
end

--Should return a value in the range [0, 100)
function QuickJoinToast_GetPriorityFromQueue(queue)
	if ( not queue.eligible ) then
		return 0;
	end

	if ( queue.type == "lfglist" ) then
		local id, activityID, name, comment, voiceChat, iLvl, honorLevel, age, numBNetFriends, numCharFriends, numGuildMates, isDelisted = C_LFGList.GetSearchResultInfo(queue.lfgListID);
		local fullName, shortName, categoryID, groupID, iLevel, filters, minLevel, maxPlayers, displayType = C_LFGList.GetActivityInfo(activityID);
		--Filter by activity flags
		return 99;
	elseif ( queue.type == "lfg" ) then
		return 99;
	elseif ( queue.type == "pvp" ) then
		return 99;
	end
end

--Should return a value in the range [0, 100)
function QuickJoinToast_GetPriorityFromPlayers(players)
	local priority = 0;
	for i=1, #players do
		local player = players[i];
		if ( BNGetGameAccountInfoByGUID(player) or IsCharacterFriend(player) ) then
			priority = priority + QUICK_JOIN_TOAST_PLAYER_FRIEND_VALUE;
		end
		if ( IsGuildMember(player) ) then
			priority = priority + QUICK_JOIN_TOAST_PLAYER_GUILD_VALUE;
		end
	end
	return priority;
end

function QuickJoinToastGroupMixin:Update()
	local canJoin = C_SocialQueue.GetGroupInfo(self.guid);
	local queues = C_SocialQueue.GetGroupQueues(self.guid);
	local players = C_SocialQueue.GetGroupMembers(self.guid);

	if ( queues and players and canJoin ) then
		self.priority = QuickJoinToast_GetPriority(self, queues, players);
	else
		self.priority = 0;
	end

	--Clean out displayedQueues of queues that no longer exist
	local newDisplayedQueues = {};
	if ( queues and self.displayedQueues ) then
		for i=1, #queues do
			if ( self.displayedQueues[queues[i].clientID] ) then
				newDisplayedQueues[queues[i].clientID] = true;
			end
		end
	end

	self.displayedQueues = newDisplayedQueues;
end

function QuickJoinToastGroupMixin:GetPriority()
	return self.priority;
end
