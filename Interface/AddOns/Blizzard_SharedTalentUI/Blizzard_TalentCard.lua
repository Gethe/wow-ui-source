
-- Talent cards are expanded displays attached to talent buttons for use in alternate displays
-- like TalentFrameList to surface info like name/rank/description/etc.

TalentCardMixin = {};

function TalentCardMixin:Attach(talentButton)
	self.talentButton = talentButton;
	self:UpdateAnchors();
	self:Update();
end

function TalentCardMixin:OnRelease()
	self.talentButton = nil;
end

function TalentCardMixin:UpdateAnchors()
	self:SetPoint("LEFT", self.talentButton, "RIGHT", 6, 0);
end

function TalentCardMixin:Update()
	-- Override in your derived Mixin.
end

TalentDescriptionCardMixin = {};

function TalentDescriptionCardMixin:Update()
	-- Overrides TalentCardMixin.

	local definitionInfo = self.talentButton:GetDefinitionInfo();
	self.Description:SetText(definitionInfo and TalentUtil.GetTalentDescriptionFromInfo(definitionInfo) or "");
end

TalentNameCardMixin = {};

function TalentNameCardMixin:Update()
	-- Overrides TalentCardMixin.

	local definitionInfo = self.talentButton:GetDefinitionInfo();
	self.Name:SetText(definitionInfo and TalentUtil.GetTalentNameFromInfo(definitionInfo) or "");
end
