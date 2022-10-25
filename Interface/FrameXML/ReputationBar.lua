ReputationStatusBarMixin = CreateFromMixins(StatusTrackingBarMixin);

function ReputationStatusBarMixin:GetPriority()
	return self.priority; 
end

function ReputationStatusBarMixin:UpdateCurrentText()
	if ( self.isCapped ) then
		self:SetBarText(self.name);
	else
		self:SetBarText(self.name:format(self.value, self.max)); 
	end
end

function ReputationStatusBarMixin:ShouldBeVisible()
	local name, reaction, minFaction, maxFaction, value, factionID = GetWatchedFactionInfo();
	return name ~= nil;
end

function ReputationStatusBarMixin:Update() 
	local name, reaction, minBar, maxBar, value, factionID = GetWatchedFactionInfo();
	local barTexture = FACTION_BAR_Textures[reaction];
	local isCapped;
	local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID);
	local friendshipID = reputationInfo.friendshipFactionID;
	if ( self.factionID ~= factionID ) then
		self.factionID = factionID;
		reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID);
		self.friendshipID = reputationInfo.friendshipFactionID
	end

	-- do something different for friendships
	local level;

	if ( C_Reputation.IsFactionParagon(factionID) ) then
		local currentValue, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID);
		minBar, maxBar  = 0, threshold;
		value = currentValue % threshold;
		if ( hasRewardPending ) then
			value = value + threshold;
		end
		if ( C_Reputation.IsMajorFaction(factionID) ) then
			barTexture = "UI-HUD-ExperienceBar-Fill-Reputation-Faction-Blue";
		end
	elseif ( C_Reputation.IsMajorFaction(factionID) ) then
		local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID);
		minBar, maxBar = 0, majorFactionData.renownLevelThreshold;
		barTexture = "UI-HUD-ExperienceBar-Fill-Reputation-Faction-Blue";
	elseif ( friendshipID > 0) then
		local repInfo = C_GossipInfo.GetFriendshipReputation(factionID);
		local repRankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID);
		level = repRankInfo.currentLevel;
		if ( repInfo.nextThreshold ) then
			minBar, maxBar, value = repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.standing;
		else
			-- max rank, make it look like a full bar
			minBar, maxBar, value = 0, 1, 1;
			isCapped = true;
		end
		local friendshipTextureIndex = 5; -- Friendships always use same texture
		barTexture = FACTION_BAR_Textures[friendshipTextureIndex];
	else
		level = reaction;
		if ( reaction == MAX_REPUTATION_REACTION ) then
			isCapped = true;
		end
	end

	-- Normalize values
	maxBar = maxBar - minBar;
	value = value - minBar;
	if ( isCapped and maxBar == 0 ) then
		maxBar = 1;
		value = 1;
	end
	minBar = 0;

	self:SetBarValues(value, minBar, maxBar, level);

	if ( isCapped ) then
		self:SetBarText(name);
	else
		name = name.." %d / %d";
		self:SetBarText(name:format(value, maxBar));
	end

	self.StatusBar:SetStatusBarTexture(barTexture);

	self.isCapped = isCapped;
	self.name = name;
	self.value = value;
	self.max = maxBar;
end

function ReputationStatusBarMixin:OnLoad()
	self:RegisterEvent("CVAR_UPDATE");
	self.priority = 1; 
end

function ReputationStatusBarMixin:OnEvent(event, ...)
	if( event == "CVAR_UPDATE") then
		local cvar = ...;
		if( cvar == "xpBarText" ) then
			self:UpdateTextVisibility();
		end
	end
end

function ReputationStatusBarMixin:OnEnter()
	self:ShowText();
	self:UpdateCurrentText();
	ReputationParagonWatchBar_OnEnter(self);
end

function ReputationStatusBarMixin:OnShow()
	self:UpdateTextVisibility();
end

function ReputationStatusBarMixin:OnLeave()
	self:HideText();
	ReputationParagonWatchBar_OnLeave(self);
end
