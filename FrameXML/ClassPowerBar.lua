ClassPowerBar = {};

function ClassPowerBar:OnLoad()
	--[[ 
		Initialize these variables in the class-specific OnLoad mixin function. Also make sure to implement
		a UpdatePower() mixin function that handles UI changes for whenever the power display changes
	self.tooltipTitle = HOLY_POWER;
	self.tooltip = HOLY_POWER_TOOLTIP;
	self.class = "PALADIN";
	self.spec = SPEC_PALADIN_RETRIBUTION;
	self.powerTokens = {"HOLY_POWER"};
	]]--
	
	self:Setup();
end

function ClassPowerBar:OnEvent(event, arg1, arg2)
	if ( event == "UNIT_POWER_FREQUENT" and arg1 == self:GetParent().unit ) then
		for i = 1, #self.powerTokens do
			if (self.powerTokens[i] == arg2) then
				self:UpdatePower();
				break;
			end
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
	if (self.tooltipTitle and self.tooltipText) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
		GameTooltip:SetText(self.tooltipTitle, 1, 1, 1);
		GameTooltip:AddLine(self.tooltip, nil, nil, nil, true);
		GameTooltip:Show();
	end
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
	PlayerFrame.classPowerBar = self;
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
