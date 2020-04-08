ClassPowerBar = {};

function ClassPowerBar:OnLoad()
	-- Initialize these variables in the class-specific OnLoad mixin function. Also make sure to implement
	-- an UpdatePower() mixin function that handles UI changes for whenever the power display changes

	self:Setup();
end

function ClassPowerBar:GetUnit()
	return self:GetParent().unit;
end

function ClassPowerBar:SetTooltip(tooltipTitle, tooltip)
	self.tooltipTitle = tooltipTitle;
	self.tooltip = tooltip;

	if (self.tooltipTitle and self.tooltip) then
		self:SetScript("OnEnter", self.OnEnter);
		self:SetScript("OnLeave", self.OnLeave);
	else
		self:SetScript("OnEnter", nil);
		self:SetScript("OnLeave", nil);
	end
end

function ClassPowerBar:SetPowerTokens(...)
	local tokens = {}

	for i = 1, select("#", ...) do
		local tokenType = select(i, ...);
		tokens[tokenType] = true;
	end

	self.powerTokens = tokens;
end

function ClassPowerBar:UsesPowerToken(tokenType)
	return self.powerTokens and self.powerTokens[tokenType];
end

function ClassPowerBar:OnEvent(event, ...)
	if ( event == "UNIT_POWER_FREQUENT" ) then
		local unitToken, powerToken = ...;
		if ( unitToken ~= self:GetUnit() ) then
			return false; -- Preserve previous behavior by not handling this event here.
		end

		-- Preserve previous behavior by always handling this event, even if this doesn't call UpdatePower
		if ( self:UsesPowerToken(powerToken) ) then
			self:UpdatePower();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" or event == "UNIT_DISPLAYPOWER" ) then
		self:UpdatePower();
	elseif (event == "PLAYER_TALENT_UPDATE" ) then
		self:Setup();
		self:UpdatePower();
	else
		return false;
	end

	return true;
end

function ClassPowerBar:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	GameTooltip:SetText(self.tooltipTitle, 1, 1, 1);
	GameTooltip:AddLine(self.tooltip, nil, nil, nil, true);
	GameTooltip:Show();
end

function ClassPowerBar:OnLeave()
	GameTooltip:Hide();
end

function ClassPowerBar:Setup()
	local _, class = UnitClass("player");
	local spec = GetSpecialization();
	local showBar = false;

	if ( class == self.class ) then
		if ( not self.spec or spec == self.spec ) then
			PlayerFrame.classPowerBar = self;
			self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
			self:RegisterEvent("PLAYER_ENTERING_WORLD");
			self:RegisterEvent("UNIT_DISPLAYPOWER");
			showBar = true;
		else
			self:UnregisterEvent("UNIT_POWER_FREQUENT");
			self:UnregisterEvent("PLAYER_ENTERING_WORLD");
			self:UnregisterEvent("UNIT_DISPLAYPOWER");
		end

		self:RegisterEvent("PLAYER_TALENT_UPDATE");
	end

	self:SetShown(showBar);
	return showBar;
end

function ClassPowerBar:TurnOn(frame, texture, toAlpha)
	local alphaValue = texture:GetAlpha();
	frame.Fadein:Stop();
	frame.Fadeout:Stop();
	texture:SetAlpha(alphaValue);
	frame.on = true;
	if (alphaValue < toAlpha) then
		if (texture:IsVisible()) then
			frame.Fadein.AlphaAnim:SetFromAlpha(alphaValue);
			frame.Fadein:Play();
		else
			texture:SetAlpha(toAlpha);
		end
	end
end

function ClassPowerBar:TurnOff(frame, texture, toAlpha)
	local alphaValue = texture:GetAlpha();
	frame.Fadein:Stop();
	frame.Fadeout:Stop();
	texture:SetAlpha(alphaValue);
	frame.on = false;
	if (alphaValue > toAlpha) then
		if (texture:IsVisible()) then
			frame.Fadeout.AlphaAnim:SetFromAlpha(alphaValue);
			frame.Fadeout:Play();
		else
			texture:SetAlpha(toAlpha);
		end
	end
end