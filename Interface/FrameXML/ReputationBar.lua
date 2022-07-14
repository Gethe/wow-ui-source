ReputationBarMixin = CreateFromMixins(StatusTrackingBarMixin);

function ReputationBarMixin:GetPriority()
	return self.priority; 
end

function ReputationBarMixin:UpdateCurrentText()
	if ( self.isCapped ) then
		self:SetBarText(self.name);
	else
		self:SetBarText(self.name:format(self.value, self.max)); 
	end
end

function ReputationBarMixin:ShouldBeVisible()
	local name, reaction, minFaction, maxFaction, value, factionID = GetWatchedFactionInfo();
	return name ~= nil;
end

function ReputationBarMixin:Update() 
	local name, reaction, minBar, maxBar, value, factionID = GetWatchedFactionInfo();
	local colorIndex = reaction;
	local isCapped;
	local friendshipID = GetFriendshipReputation(factionID);
	
	if ( self.factionID ~= factionID ) then
			self.factionID = factionID;
			self.friendshipID = GetFriendshipReputation(factionID);
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
	elseif ( friendshipID ) then
		local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID);
		level = GetFriendshipReputationRanks(factionID);
		if ( nextFriendThreshold ) then
			minBar, maxBar, value = friendThreshold, nextFriendThreshold, friendRep;
		else
			-- max rank, make it look like a full bar
			minBar, maxBar, value = 0, 1, 1;
			isCapped = true;
		end
		colorIndex = 5;		-- always color friendships green
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
	
	local color = FACTION_BAR_COLORS[colorIndex];
	
	self:SetBarColor(color.r, color.g, color.b, 1); 
	
	self.isCapped = isCapped; 
	self.name = name;
	self.value = value; 
	self.max = maxBar; 
end

function ReputationBarMixin:OnLoad()
	self:RegisterEvent("CVAR_UPDATE");
	self.priority = 1; 
end

function ReputationBarMixin:OnEvent(event, ...)
	if( event == "CVAR_UPDATE") then
		local cvar = ...;
		if( cvar == "XP_BAR_TEXT" ) then
			self:UpdateTextVisibility();
		end
	end
end

function ReputationBarMixin:OnEnter()
	self:ShowText();
	self:UpdateCurrentText();
	ReputationParagonWatchBar_OnEnter(self);
end

function ReputationBarMixin:OnShow()
	self:UpdateTextVisibility();
end

function ReputationBarMixin:OnLeave()
	self:HideText();
	ReputationParagonWatchBar_OnLeave(self);
end
