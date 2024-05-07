local FRIENDSHIP_BAR_COLORS = {
	[1] = PURE_RED_COLOR,
	[2] = FACTION_ORANGE_COLOR,
	[3] = FACTION_YELLOW_COLOR,
	[4] = FACTION_GREEN_COLOR,
};

NPCFriendshipStatusBarMixin = { };
function NPCFriendshipStatusBarMixin:GetColorIndex(currentRank, numRanks, numColors)
	if numRanks < numColors then
		if currentRank == 1 then
			return 1;
		elseif currentRank == numRanks then
			return numColors;
		else
			return 3;
		end
	end

	-- Each chunk of rank colors will either have smallColorChunkCount or largeColorChunkCount ranks in them
	local smallColorChunkCount = math.floor(numRanks/numColors);
	local largeColorChunkCount = math.ceil(numRanks/numColors);
	local numLargeColorChunks = numRanks % numColors;
	-- Any ranks <= highestMaxColorIndex will be part of a chunk of largeColorChunkCount colors
	-- Any ranks above this will be part of a chunk of smallColorChunkCount colors
	local highestMaxColorIndex = numLargeColorChunks * largeColorChunkCount;

	if currentRank <= highestMaxColorIndex then
		return math.ceil(currentRank / largeColorChunkCount);
	else
		-- This rank is in a small color chunk
		-- First remove highestMaxColorIndex to get back into a 1->x distribution
		local relativeIndex = currentRank - highestMaxColorIndex;
		-- Then distrubute ranks evenly within that group of colors
		local relativeColorIndex = math.ceil(relativeIndex / smallColorChunkCount);
		return numLargeColorChunks + relativeColorIndex;
	end
end

function NPCFriendshipStatusBarMixin:OnLoad()
	self:SetColorFill(1, 1, 1);
	self.Bar:SetDrawLayer("BORDER", -1);
end 

function NPCFriendshipStatusBarMixin:Update(factionID --[[ = nil ]])
	local reputationInfo = C_GossipInfo.GetFriendshipReputation(factionID or 0);
	if ( reputationInfo and reputationInfo.friendshipFactionID and  reputationInfo.friendshipFactionID > 0 ) then
		self.friendshipFactionID = reputationInfo.friendshipFactionID;
		-- if max rank, make it look like a full bar
		if ( not reputationInfo.nextThreshold ) then
			reputationInfo.reactionThreshold, reputationInfo.nextThreshold, reputationInfo.standing = 0, 1, 1;
		end
		if ( reputationInfo.texture ) then
			self.icon:SetTexture(reputationInfo.texture);
		else
			self.icon:SetTexture("Interface\\Common\\friendship-heart");
		end

		local numColors = 4;
		local colorIndex;
		if (not reputationInfo.overrideColor) then
			local rankInfo = C_GossipInfo.GetFriendshipReputationRanks(reputationInfo.friendshipFactionID);

			colorIndex = self:GetColorIndex(rankInfo.currentLevel, rankInfo.maxLevel, numColors);
			if (reversedColor) then
				colorIndex = (numColors + 1) - colorIndex;
			end
		else
			colorIndex = reputationInfo.overrideColor;
		end

		self:SetMinMaxValues(reputationInfo.reactionThreshold, reputationInfo.nextThreshold);
		self:SetValue(reputationInfo.standing);
		local barFillColor = FRIENDSHIP_BAR_COLORS[colorIndex];
		self:SetStatusBarColor(barFillColor:GetRGBA()); 
		self:Show();
	else
		self:Hide();
	end
end

function NPCFriendshipStatusBarMixin:OnEnter()
	ReputationBarMixin.ShowFriendshipReputationTooltip(self, self.friendshipFactionID, self, "ANCHOR_BOTTOMRIGHT");
end
