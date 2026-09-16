
local MULTISELL_ALPHA_STEP = 0.05;

MultisellProgressFrameMixin = {};

local function MultisellProgressFrame_OnUpdate(self)
	local alpha = self:GetAlpha() - MULTISELL_ALPHA_STEP;
	if alpha > 0 then
		self:SetAlpha(alpha);
	else
		self:SetScript("OnUpdate", nil);
	end
end

function MultisellProgressFrameMixin:Start(itemTexture, total)
	self:SetAlpha(1);
	self:SetScript("OnUpdate", nil);
	self.ProgressBar:SetMinMaxValues(0, total);
	self.ProgressBar:SetValue(0.01);
	self.ProgressBar.Text:SetFormattedText(AUCTION_CREATING, 0, total);
	self.ProgressBar.Icon:SetTexture(itemTexture);
end

function MultisellProgressFrameMixin:Refresh(currentCount, totalCount)
	self.ProgressBar:SetValue(currentCount);
	self.ProgressBar.Text:SetFormattedText(AUCTION_CREATING, currentCount, totalCount);
	if currentCount == totalCount then
		self:SetScript("OnUpdate", MultisellProgressFrame_OnUpdate);
	end
end
