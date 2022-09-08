
TalentFrameGateMixin = {};

function TalentFrameGateMixin:Init(talentFrame, anchorButton, condInfo)
	self.talentFrame = talentFrame;
	self.anchorButton = anchorButton;
	self.condInfo = condInfo;

	local spentAmountRequired = condInfo.spentAmountRequired;
	self.GateText:SetShown(spentAmountRequired ~= nil);
	if spentAmountRequired then
		self.GateText:SetText(spentAmountRequired);
	end
end

function TalentFrameGateMixin:OnEnter()
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_LEFT", 4, -4);

	local condInfo = self:GetTalentFrame():GetAndCacheCondInfo(self.condInfo.condID);
	GameTooltip_AddErrorLine(tooltip, TALENT_FRAME_GATE_TOOLTIP_FORMAT:format(condInfo.spentAmountRequired));
	tooltip:Show();
end

function TalentFrameGateMixin:OnLeave()
	GameTooltip_Hide();
end

function TalentFrameGateMixin:GetAnchorButton()
	return self.anchorButton;
end

function TalentFrameGateMixin:GetTalentFrame()
	return self.talentFrame;
end
