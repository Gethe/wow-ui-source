GossipFrameMixin = CreateFromMixins(GossipFrameSharedMixin);

function GossipFrameMixin:OnLoad()
	self:RegisterEvent("GOSSIP_SHOW");
	self:RegisterEvent("GOSSIP_CLOSED");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:UpdateScrollBox();

end

function GossipFrameMixin:OnEvent(event, ...)
	if ( event == "GOSSIP_SHOW" ) then
		self:HandleShow();
		NPCFriendshipStatusBar_Update(self);
		self:Update();
	elseif ( event == "GOSSIP_CLOSED" ) then
		local interactionIsContinuing = ...;
		self:HandleHide(interactionIsContinuing);
	elseif ( event == "QUEST_LOG_UPDATE" and GossipFrame.hasActiveQuests ) then
		self:Update();
	end
end

GossipAvailableQuestButtonMixin = CreateFromMixins(GossipSharedAvailableQuestButtonMixin);
function GossipAvailableQuestButtonMixin:Setup(...)
	self.Icon:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon");
	GossipSharedAvailableQuestButtonMixin.Setup(self, ...);
end

GossipActiveQuestButtonMixin = CreateFromMixins(GossipSharedActiveQuestButtonMixin);
function GossipActiveQuestButtonMixin:Setup(...)
	self.Icon:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon");
	GossipSharedActiveQuestButtonMixin.Setup(self, ...);
end

function GossipFrameActiveQuestsUpdate(...)
	self.Icon:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon");
	--This is probably broken from the GossipFrame refactor, but adding in my 3.4.0 fix to note to include the 
	--change when we tackle the issue
	if ( ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) and not select(i+3, ...) ) then
		self.Icon:SetTexture("Interface\\GossipFrame\\IncompleteQuestIcon");
	else
		self.Icon:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon");
	end
	GossipSharedActiveQuestButtonMixin.Setup(self, ...);
end

function NPCFriendshipStatusBar_Update(frame, factionID --[[ = nil ]])
	--[[local statusBar = NPCFriendshipStatusBar;
	local id, rep, maxRep, name, text, texture, reaction, threshold, nextThreshold = GetFriendshipReputation(factionID);
	statusBar.friendshipFactionID = id;
	if ( id and id > 0 ) then
		statusBar:SetParent(frame);
		-- if max rank, make it look like a full bar
		if ( not nextThreshold ) then
			threshold, nextThreshold, rep = 0, 1, 1;
		end
		if ( texture ) then
			statusBar.icon:SetTexture(texture);
		else
			statusBar.icon:SetTexture("Interface\\Common\\friendship-heart");
		end
		statusBar:SetMinMaxValues(threshold, nextThreshold);
		statusBar:SetValue(rep);
		statusBar:ClearAllPoints();
		statusBar:SetPoint("TOPLEFT", 73, -41);
		statusBar:Show();
	else
		statusBar:Hide();
	end]]
end

function NPCFriendshipStatusBar_OnEnter(self)
	ShowFriendshipReputationTooltip(self.friendshipFactionID, self, "ANCHOR_BOTTOMRIGHT");
end

function GossipFrameSharedMixin:SetGossipTitle(title)
	self.NameFrame.Name:SetText(title);
end

function GossipFrameMixin:SortOrder(leftInfo, rightInfo)
	return leftInfo.orderIndex < rightInfo.orderIndex;
end