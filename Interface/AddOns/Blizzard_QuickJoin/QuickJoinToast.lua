QUICK_JOIN_CONFIG = nil;
--
QuickJoinToastMixin = {}

function QuickJoinToastMixin:OnLoad()
	QUICK_JOIN_CONFIG = C_SocialQueue.GetConfig();

	self:RegisterEvent("SOCIAL_QUEUE_UPDATE");
	self:RegisterEvent("SOCIAL_QUEUE_CONFIG_UPDATED");
	self:RegisterEvent("GROUP_JOINED");
	self:RegisterEvent("GROUP_LEFT");
	self:RegisterForClicks("AnyUp");
	self.groups = {};
	self.groupsAwaitingDisplay = {};
	self.queuedUpdates = {}; --Updates queued until we get config
	if ( QUICK_JOIN_CONFIG ) then
		self.throttle = CreateFromMixins(QuickJoinToastThrottleMixin);
		self.throttle:Init();
	end

	local alertSystem = ChatAlertFrame:AddAutoAnchoredSubSystem(self);
	ChatAlertFrame:SetSubSystemAnchorPriority(alertSystem, 0);

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
	
	if not C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.InGameFriendsList) then
		self:Hide();
	end
end

function QuickJoinToastMixin:OnShow()
	self:RegisterEvent("PVP_BRAWL_INFO_UPDATED");
	if RecruitAFriendFrame then
		RecruitAFriendFrame:UpdateRAFTutorialTips();
	end
end

function QuickJoinToastMixin:OnHide()
	self:UnregisterEvent("PVP_BRAWL_INFO_UPDATED");
	self:ClearCachedQueueData();
end

function QuickJoinToastMixin:OnEvent(event, ...)
	if ( event == "SOCIAL_QUEUE_UPDATE" ) then
		local guid, numAddedItems = ...;
		self:ProcessOrQueueUpdate(guid);
	elseif ( event == "SOCIAL_QUEUE_CONFIG_UPDATED" ) then
		QUICK_JOIN_CONFIG = C_SocialQueue.GetConfig();
		self.throttle = CreateFromMixins(QuickJoinToastThrottleMixin);
		self.throttle:Init();

		self:ProcessQueuedUpdates();
		self:CheckShowToast();
	elseif ( event == "GROUP_JOINED" ) then
		local index, guid = ...;
		self:ProcessOrQueueUpdate(guid);
	elseif ( event == "GROUP_LEFT" ) then
		local index, guid = ...;
		self:ProcessOrQueueUpdate(guid);
		self:CheckShowToast();
	elseif ( event == "PVP_BRAWL_INFO_UPDATED") then
		if (self.displayedToast and self:HasCachedQueueData()) then
			local updateQueues = false;
			local text = self:GetCurrentText(updateQueues);
			if (self.ToastToToastAnim:IsPlaying()) then
				self.pendingText = text;
				self.Toast2.Text:SetText(text);
			else
				self.Toast.Text:SetText(text);
			end
		end
	end
end

function QuickJoinToastMixin:ProcessOrQueueUpdate(guid)
	if ( QUICK_JOIN_CONFIG ) then
		self:ProcessUpdate(guid);
	else
		self:QueueUpdate(guid);
	end
end

function QuickJoinToastMixin:QueueUpdate(guid)
	self.queuedUpdates[#self.queuedUpdates + 1] = guid;
end

function QuickJoinToastMixin:ProcessQueuedUpdates()
	for i=1, #self.queuedUpdates do
		self:ProcessUpdate(self.queuedUpdates[i]);
	end
	self.queuedUpdates = {};
end

function QuickJoinToastMixin:ProcessUpdate(guid)
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

	if ( group:GetPriority() > 0 and not group:ShouldSuppressToast() ) then
		if ( not self.groupsAwaitingDisplay[guid] ) then
			self.groupsAwaitingDisplay[guid] = true;
			C_GuildInfo.GuildRoster();
			group:DelayUntil(GetTime() + QUICK_JOIN_CONFIG.DELAY_DURATION);
		end
	else
		self.groupsAwaitingDisplay[guid] = nil;
	end

	self:CheckShowToast();

	self.QueueCount:SetText(#C_SocialQueue.GetAllGroups(false));
end

function QuickJoinToastMixin:SetToastDirection(isOnRight)
	self.isOnRight = isOnRight;
	self:ModifyToastDirection(self.Toast, isOnRight);
	self:ModifyToastDirection(self.Toast2, isOnRight);
end

function QuickJoinToastMixin:ModifyToastDirection(toast, isOnRight)
	local thisDir = isOnRight and "RIGHT" or "LEFT";
	local otherDir = isOnRight and "LEFT" or "RIGHT";
	local invertNum = isOnRight and -1 or 1;

	toast:ClearAllPoints();
	if ( isOnRight ) then
		toast.Background:SetTexCoord(1, 0, 0, 1);
	else
		toast.Background:SetTexCoord(0, 1, 0, 1);
	end

	toast:SetPoint(thisDir, self, otherDir, -13 * invertNum, -1);
	--toast.Text:SetJustifyH(thisDir);
	toast.Text:SetPoint(thisDir, toast, thisDir, 15 * invertNum, 2);
end

function QuickJoinToastMixin:UpdateDisplayedFriendCount()
	local _, numBNetOnline = BNGetNumFriends();
	local numWoWOnline = C_FriendList.GetNumOnlineFriends() or 0;
	self.FriendCount:SetText(numBNetOnline + numWoWOnline);
end

function QuickJoinToastMixin:SetTimerFor(nextTime)
	if ( not nextTime ) then
		--Handle cancellation
		self.nextToastUpdateTime = nil;
		if ( self.updateTimer ) then
			self.updateTimer:Cancel();
			self.updateTimer = nil;
		end
	elseif ( not self.nextToastUpdateTime or nextTime <= self.nextToastUpdateTime ) then
		--This is a sooner time than we we were already waiting for, so set a timer for it.
		if ( self.updateTimer ) then
			self.updateTimer:Cancel();
		end
		self.nextToastUpdateTime = nextTime;
		local timeDiff = math.max(nextTime - GetTime(), 0.001);
		self.updateTimer = C_Timer.NewTimer(timeDiff, function()
			self.nextToastUpdateTime = nil;
			self:CheckShowToast();
		end);
	end
end

function QuickJoinToastMixin:CheckShowToast()
	if ( not self.displayedToast ) then
		self:CheckDisplayToast();
	end
end

function QuickJoinToastMixin:CheckDisplayToast(hideIfNeeded)
	local group, priority = self:GetHighestPriorityGroup();
	if ( group ) then
		local shouldDisplay = self:ShouldDisplayGroup(group);
		if ( shouldDisplay ) then
			self:ShowToast(group, priority);
			self:SetTimerFor(nil);
			return;
		end
	end

	if ( self.displayedToast and hideIfNeeded ) then
		self:HideToast();
	end

	self:SetTimerFor(self:GetNextToastTime());
end

function QuickJoinToastMixin:GetHighestPriorityGroup()
	local highestGroup = nil;
	local highestPriority = 0;
	local now = GetTime();
	for guid, _ in pairs(self.groupsAwaitingDisplay) do
		local group = self.groups[guid];
		if ( group ) then
			local delayUntil = group:GetDelayUntil();
			if ( not delayUntil or delayUntil <= now ) then
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

	return highestGroup, highestPriority;
end

function QuickJoinToastMixin:ShouldSuppressAllToasts()
	return IsInGroup() or QUICK_JOIN_CONFIG.TOASTS_DISABLED;
end

function QuickJoinToastMixin:GetNextToastTime()
	if ( self:ShouldSuppressAllToasts() ) then
		return nil;
	end

	local nextDisplayTime;
	local now = GetTime();
	for guid, _ in pairs(self.groupsAwaitingDisplay) do
		local group = self.groups[guid];
		if ( group ) then
			local t = math.max(self.throttle:GetTimeOfThreshold(group:GetPriority()), group:GetDelayUntil() or 0);
			if ( not nextDisplayTime or t < nextDisplayTime ) then
				nextDisplayTime = t;
			end
		else
			GMError("Have a group guid, but not group?");
		end
	end
	return nextDisplayTime;
end

function QuickJoinToastMixin:ShouldDisplayGroup(group)
	if ( self:ShouldSuppressAllToasts() ) then
		return false;
	end

	local priority = group:GetPriority();
	return priority >= self.throttle:GetThresholdAtTime(GetTime()) and priority >= QUICK_JOIN_CONFIG.THROTTLE_MIN_THRESHOLD;
end

function QuickJoinToastMixin:ShowToast(group, priority)
	self.throttle:OnToastShown();

	self.ToastActiveAnim:Stop();

	self.oldToast = self.displayedToast;
	self.displayedToast = group;

	local queues = C_SocialQueue.GetGroupQueues(self.displayedToast.guid);
	self.isLFGList = queues and queues[1] and queues[1].queueData.queueType == "lfglist";

	local updateQueues = true;
	if ( self.oldToast ) then
		local text = self:GetCurrentText(updateQueues);
		self.Toast2.Text:SetText(text);
		self.pendingText = text;
		self.ToastToToastAnim:Play();
	else
		self.Toast.Text:SetText(self:GetCurrentText(updateQueues));
		self.FriendToToastAnim:Play();
	end

	if ( self.isOnRight ) then
		self:SetHitRectInsets(-self.Toast:GetWidth(), 0, 0, 0);
	else
		self:SetHitRectInsets(0, -self.Toast:GetWidth(), 0, 0);
	end
	self:UpdateQueueIcon();
	PlaySound(SOUNDKIT.UI_71_SOCIAL_QUEUEING_TOAST);
	C_SocialQueue.SignalToastDisplayed(group.guid, priority);
end

function QuickJoinToastMixin:HideToast()
	self:SetHitRectInsets(0, 0, 0, 0);
	self.ToastActiveAnim:Stop();
	self.ToastToFriendAnim:Play();
end

function QuickJoinToastMixin:OnClick(button)
	if ( KeybindFrames_InQuickKeybindMode() ) then
		self:QuickKeybindButtonOnClick(button);
	elseif ( self.displayedToast ) then
		ToggleQuickJoinPanel();
		QuickJoinFrame:SelectGroup(self.displayedToast.guid);
		QuickJoinFrame:ScrollToGroup(self.displayedToast.guid);
	else
		ToggleFriendsFrame(FRIEND_TAB_FRIENDS);
	end
end

function QuickJoinToastMixin:OnMouseDown()
	self.FriendsButton:SetAtlas("quickjoin-button-friendslist-down");
	self:UpdateQueueIcon();
end

function QuickJoinToastMixin:OnMouseUp()
	self.FriendsButton:SetAtlas("quickjoin-button-friendslist-up");
	self:UpdateQueueIcon();
end

function QuickJoinToastMixin:UpdateQueueIcon()
	if ( not self.displayedToast ) then
		return;
	end

	if ( self:GetButtonState() == "PUSHED" ) then
		if ( self.isLFGList ) then
			self.QueueButton:SetAtlas("quickjoin-button-group-down");
			self.FlashingLayer:SetAtlas("quickjoin-button-group-down");
		else
			self.QueueButton:SetAtlas("quickjoin-button-quickjoin-down");
			self.FlashingLayer:SetAtlas("quickjoin-button-quickjoin-down");
		end
	else
		if ( self.isLFGList ) then
			self.QueueButton:SetAtlas("quickjoin-button-group-up");
			self.FlashingLayer:SetAtlas("quickjoin-button-group-up");
		else
			self.QueueButton:SetAtlas("quickjoin-button-quickjoin-up");
			self.FlashingLayer:SetAtlas("quickjoin-button-quickjoin-up");
		end
	end
end

function QuickJoinToastMixin:OnEnter()
	if ( not KeybindFrames_InQuickKeybindMode() ) then
		if ( self.displayedToast ) then
			local queues = C_SocialQueue.GetGroupQueues(self.displayedToast.guid);
			if ( queues ) then
				local knowsLeader = SocialQueueUtil_HasRelationshipWithLeader(self.displayedToast.guid);

				GameTooltip:SetOwner(self.Toast, self.isOnRight and "ANCHOR_LEFT" or "ANCHOR_RIGHT");
				SocialQueueUtil_SetTooltip(GameTooltip, SocialQueueUtil_GetHeaderName(self.displayedToast.guid), queues, true, knowsLeader);
				GameTooltip:AddLine(" ");
				GameTooltip:AddLine(SOCIAL_QUEUE_CLICK_TO_JOIN, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
				GameTooltip:Show();
			end
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			GameTooltip_SetTitle(GameTooltip, MicroButtonTooltipText(SOCIAL_BUTTON, "TOGGLESOCIAL"));
			GameTooltip:Show();
		end
	end
end

function QuickJoinToastMixin:OnLeave()
	GameTooltip:Hide();
end

local function GetExtraQueueCount(queues)
	local extraQueueCount = 0;

	if ( #queues > 1 ) then
		extraQueueCount = #queues - 1;
	elseif ( queues[1].queueData.lfgIDs and #queues[1].queueData.lfgIDs > 1 ) then
		extraQueueCount = #queues[1].queueData.lfgIDs - 1;
	end

	return extraQueueCount;
end

function QuickJoinToastMixin:HasCachedQueueData()
	return self.queues ~= nil;
end

function QuickJoinToastMixin:CachedQueueData()
	return self.queues;
end

function QuickJoinToastMixin:SetCachedQueueData(queues)
	self.queues = queues;
end

function QuickJoinToastMixin:ClearCachedQueueData()
	self:SetCachedQueueData(nil);
end

function QuickJoinToastMixin:GetCurrentText(updateQueues)
	local group = self.displayedToast;
	local queues;
	if (updateQueues) then
		queues = group:GetNewQueues();
		self:SetCachedQueueData(queues);
	else
		queues = self:CachedQueueData();
	end
	local queueName = SocialQueueUtil_GetQueueName(queues[1].queueData);
	local extraQueueCount = GetExtraQueueCount(queues);

	if ( extraQueueCount > 0 ) then
		queueName = string.format(QUICK_JOIN_TOAST_EXTRA_QUEUES, queueName, extraQueueCount);
	end

	if ( queues[1].queueData.queueType == "lfglist" ) then
		return string.format(QUICK_JOIN_TOAST_LFGLIST_MESSAGE, SocialQueueUtil_GetHeaderName(group.guid), queueName);
	else
		return string.format(QUICK_JOIN_TOAST_MESSAGE, SocialQueueUtil_GetHeaderName(group.guid), queueName);
	end
end

-------------------------------
-----Anim callbacks------------
-------------------------------
function QuickJoinToastMixin:ToastPulse()
	if ( GetTime() - self.displayedTime > QUICK_JOIN_CONFIG.TOAST_DURATION ) then
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
	self.Toast.Text:SetText(self.pendingText);
	self.Toast2.Text:SetText(nil); -- This is a workaround for a bug in the animation system.
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

function QuickJoinToastGroupMixin:DelayUntil(delayUntil)
	self.delayUntil = delayUntil;
end

function QuickJoinToastGroupMixin:GetDelayUntil()
	return self.delayUntil;
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
		return maxQueuePriority * QUICK_JOIN_CONFIG.QUEUE_MULTIPLIER + QuickJoinToast_GetPriorityFromPlayers(players)  * QUICK_JOIN_CONFIG.PLAYER_MULTIPLIER;
	else
		return 0;
	end
end

--Should return a value in the range [0, 100)
function QuickJoinToast_GetPriorityFromQueue(queue)
	if ( not queue.eligible ) then
		return 0;
	end

	local queueData = queue.queueData;

	local itemLevel = GetAverageItemLevel();
	if ( queueData.queueType == "lfglist" ) then
		local searchResultInfo = C_LFGList.GetSearchResultInfo(queueData.lfgListID);
		local activityInfo = C_LFGList.GetActivityInfoTable(searchResultInfo.activityID, nil, searchResultInfo.isWarMode);
		--Filter by activity flags
		if ( not activityInfo or not activityInfo.showQuickJoinToast ) then
			return 0;
		end

		local iLevel = activityInfo.ilvlSuggestion;
		if ( iLevel == 0 ) then
			return QUICK_JOIN_CONFIG.THROTTLE_LFGLIST_PRIORITY_DEFAULT;
		end
		if ( itemLevel >= iLevel ) then
			--We are above the item level suggestion. The further above we are, the less important this is.
			local ilvldiff = (itemLevel - iLevel) * QUICK_JOIN_CONFIG.THROTTLE_LFGLIST_ILVL_SCALING_ABOVE;
			return math.max(1, QUICK_JOIN_CONFIG.THROTTLE_LFGLIST_PRIORITY_ABOVE - ilvldiff);
		else
			--We are below the item level suggestion, but above the requirement set by the group. The further below the
			--suggestion we are, the less important this is.
			local ilvldiff = (iLevel - itemLevel) * QUICK_JOIN_CONFIG.THROTTLE_LFGLIST_ILVL_SCALING_BELOW;
			return math.max(1, QUICK_JOIN_CONFIG.THROTTLE_LFGLIST_PRIORITY_BELOW - ilvldiff);
		end
	elseif ( queueData.queueType == "lfg" ) then
		local lfgID = queueData.lfgIDs[1]; -- TODO: Determine whether or not to use multiple id's for priority scoring
		local name, typeID, subtypeID, minLevel, maxLevel, recLevel, minRecLevel, maxRecLevel, expansionLevel, groupID, textureFilename, difficulty, maxPlayers, description, isHoliday, repAmount, minPlayers, isTimewalker, mapName, minGear = GetLFGDungeonInfo(lfgID);
		if ( not name ) then
			--We hotfix deleted an LFG entry?
			return 0;
		end

		if ( isHoliday ) then
			--We won't recommend holiday dungeons ever
			return 0;
		end

		if ( typeID == TYPEID_RANDOM_DUNGEON ) then
			if ( GetRandomDungeonBestChoice() ~= lfgID ) then
				return 1;
			end

			if ( itemLevel > QUICK_JOIN_CONFIG.THROTTLE_DF_MAX_ITEM_LEVEL ) then
				--The point at which all random dungeons become pretty much irrelevant
				return 1;
			end

			return QUICK_JOIN_CONFIG.THROTTLE_DF_BEST_PRIORITY;
		elseif ( subtypeID == LFG_SUBTYPEID_RAID ) then
			--Go by ilvl
			if ( itemLevel < minGear ) then
				--Should never happen since we can't join it...
				return 0;
			end

			--The further above the item level requirement we are, the less important this is.
			local ilvldiff = (itemLevel - minGear) * QUICK_JOIN_CONFIG.THROTTLE_RF_ILVL_SCALING_ABOVE;
			return math.max(1, QUICK_JOIN_CONFIG.THROTTLE_RF_PRIORITY_ABOVE - ilvldiff);
		elseif ( subtypeID == LFG_SUBTYPEID_WORLDPVP ) then
			--If the player is below honor level 10, assume they aren't interested in PvP
			if ( UnitHonorLevel("player") < QUICK_JOIN_CONFIG.THROTTLE_PVP_HONOR_THRESHOLD) then
				return QUICK_JOIN_CONFIG.THROTTLE_PVP_PRIORITY_LOW;
			else
				return QUICK_JOIN_CONFIG.THROTTLE_PVP_PRIORITY_NORMAL;
			end
		else
			--Scenario, specific dungeons, etc.
			return 1;
		end
	elseif ( queueData.queueType == "pvp" ) then
		--If the player is below honor level 10, assume they aren't interested in PvP
		if ( UnitHonorLevel("player") < QUICK_JOIN_CONFIG.THROTTLE_PVP_HONOR_THRESHOLD) then
			return QUICK_JOIN_CONFIG.THROTTLE_PVP_PRIORITY_LOW;
		else
			return QUICK_JOIN_CONFIG.THROTTLE_PVP_PRIORITY_NORMAL;
		end
	end
end

--Should return a value in the range [0, 200)
function QuickJoinToast_GetPriorityFromPlayers(players)
	local priority = 0;
	for i=1, #players do
		local player = players[i].guid;
		if ( C_BattleNet.GetGameAccountInfoByGUID(player) or C_FriendList.IsFriend(player) ) then
			priority = priority + QUICK_JOIN_CONFIG.PLAYER_FRIEND_VALUE;
		end
		if ( IsGuildMember(player) ) then
			priority = priority + QUICK_JOIN_CONFIG.PLAYER_GUILD_VALUE;
		end
	end
	return priority;
end

function QuickJoinToastGroupMixin:Update()
	local canJoin = C_SocialQueue.GetGroupInfo(self.guid);
	local queues = C_SocialQueue.GetGroupQueues(self.guid);
	local players = C_SocialQueue.GetGroupMembers(self.guid);
	
	self.suppressToast = true;
	if players then
		for i, player in ipairs(players) do
			if not player.clubId then
				self.suppressToast = false;
				break;
			else
				local clubInfo = C_Club.GetClubInfo(player.clubId);
				if clubInfo and clubInfo.socialQueueingEnabled then
					self.suppressToast = false;
					break;
				end
			end
		end
	end

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

function QuickJoinToastGroupMixin:ShouldSuppressToast()
	return self.suppressToast;
end

function QuickJoinToastGroupMixin:GetPriority()
	return self.priority;
end

---------------------------
--QuickJoinToastThrottle---
---------------------------
QuickJoinToastThrottleMixin = {};

function QuickJoinToastThrottleMixin:Init()
	self.lastThreshold = QUICK_JOIN_CONFIG.THROTTLE_INITIAL_THRESHOLD;
	self.lastUpdateTime = GetTime();
end

function QuickJoinToastThrottleMixin:OnToastShown()
	self.lastThreshold = self:GetThresholdAtTime(GetTime()) + QUICK_JOIN_CONFIG.THROTTLE_PRIORITY_SPIKE;
	self.lastUpdateTime = GetTime();
end

function QuickJoinToastThrottleMixin:GetThresholdAtTime(t)
	local timePassed = t - self.lastUpdateTime;
	local amountDecayed = timePassed * QUICK_JOIN_CONFIG.THROTTLE_PRIORITY_SPIKE / QUICK_JOIN_CONFIG.THROTTLE_DECAY_TIME;
	return math.max(0, self.lastThreshold - amountDecayed);
end

function QuickJoinToastThrottleMixin:GetTimeOfThreshold(threshold)
	local decayNeeded = self.lastThreshold - threshold;
	local timeNeeded = decayNeeded * QUICK_JOIN_CONFIG.THROTTLE_DECAY_TIME / QUICK_JOIN_CONFIG.THROTTLE_PRIORITY_SPIKE;
	return self.lastUpdateTime + timeNeeded;
end
