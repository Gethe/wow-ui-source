NPCFriendshipStatusBarMixin = { };

function NPCFriendshipStatusBarMixin:OnLoad()
	self:SetColorFill(1, 1, 1);
	self.Bar:SetDrawLayer("BORDER", -1);
	self:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0.03, 0.36, 0.28), CreateColor(0.04, 0.53, 0.41));
	self:SetStatusBarColor(1, 0, 0);
end 

function NPCFriendshipStatusBarMixin:Update(factionID)
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

		self:SetMinMaxValues(reputationInfo.reactionThreshold, reputationInfo.nextThreshold);
		self:SetValue(reputationInfo.standing);
		self:Show();
	else
		self:Hide();
	end
end

function NPCFriendshipStatusBarMixin:OnEnter()
	local canClickForOptions = false;
	ShowFriendshipReputationTooltip(0, self, "ANCHOR_BOTTOMRIGHT");
end
