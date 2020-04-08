
OptionalReagentButtonMixin = {};

function OptionalReagentButtonMixin:OnLoad()
	self.Name:SetFontObject("GameFontHighlightSmall");
	self.EffectText:SetMaxLines(2);
end

function OptionalReagentButtonMixin:ChangeMaxLinesForName(numMaxLines)
	self.Name:SetMaxLines(numMaxLines);
	self.Name:SetHeight(0);
end

function OptionalReagentButtonMixin:SetReagentText(name, bonusText)
	self.Name:SetText(name);
	self.EffectText:SetText(bonusText or "");
	
	local numEffectLines = self.EffectText:GetNumLines();
	
	self.Name:ClearAllPoints();

	if bonusText then
		self:ChangeMaxLinesForName(1);

		if numEffectLines > 1 then
			self.Name:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 6, -4);
		else
			self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 6, 6);
		end
	else
		self:ChangeMaxLinesForName(3);
		self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 6, 0);
	end
end
