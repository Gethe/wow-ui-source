GossipFrameMixin = CreateFromMixins(GossipFrameSharedMixin);

function GossipFrameMixin:OnLoad()
	self:RegisterEvent("GOSSIP_SHOW");
	self:RegisterEvent("GOSSIP_CLOSED");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:UpdateScrollBox();

	-- shift inset framing over for scrollbar
	self.Inset:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -27, 24);
end

function GossipFrameMixin:OnEvent(event, ...)
	if ( event == "GOSSIP_SHOW" ) then
		self:HandleShow();
		self.FriendshipStatusBar:Update();
		self:Update();
	elseif ( event == "GOSSIP_CLOSED" ) then
		local interactionIsContinuing = ...;
		self:HandleHide(interactionIsContinuing);
	elseif ( event == "QUEST_LOG_UPDATE" and GossipFrame.hasActiveQuests ) then
		self:Update();
	end
end

GossipAvailableQuestButtonMixin = CreateFromMixins(GossipSharedAvailableQuestButtonMixin);
function GossipAvailableQuestButtonMixin:Setup(questInfo)
	if (questInfo.isLegendary) then
		self.Icon:SetTexture("Interface\\GossipFrame\\AvailableLegendaryQuestIcon");
	else
		self.Icon:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon");
	end
	GossipSharedAvailableQuestButtonMixin.Setup(self, questInfo);
end

GossipActiveQuestButtonMixin = CreateFromMixins(GossipSharedActiveQuestButtonMixin);
function GossipActiveQuestButtonMixin:Setup(questInfo)
	if (questInfo.isLegendary) then
		self.Icon:SetTexture("Interface\\GossipFrame\\ActiveLegendaryQuestIcon");
	else
		self.Icon:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon");
	end
	GossipSharedActiveQuestButtonMixin.Setup(self, questInfo);
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

function GossipFrameSharedMixin:SetGossipTitle(title)
	self.NameFrame.Name:SetText(title);
end

function GossipFrameMixin:SortOrder(leftInfo, rightInfo)
	return leftInfo.orderIndex < rightInfo.orderIndex;
end
