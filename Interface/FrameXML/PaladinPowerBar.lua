HOLY_POWER_FULL = 3;
PALADINPOWERBAR_SHOW_LEVEL = 1;

PaladinPowerBar = {};

function PaladinPowerBar:OnLoad()
	self:SetTooltip(HOLY_POWER, HOLY_POWER_TOOLTIP);
	self:SetPowerTokens("HOLY_POWER");
	self.class = "PALADIN";
	--self.spec = SPEC_PALADIN_RETRIBUTION;

	self.glow:SetAlpha(0);
	self.rune1:SetAlpha(0);
	self.rune2:SetAlpha(0);
	self.rune3:SetAlpha(0);
	self.rune4:SetAlpha(0);
	self.rune5:SetAlpha(0);

	ClassPowerBar.OnLoad(self);
end

function PaladinPowerBar:OnEvent(event, ...)
	local handled = ClassPowerBar.OnEvent(self, event, ...);
	if handled then
		return true;
	elseif event == "PLAYER_LEVEL_UP" then
		local level = ...;
		if level >= PALADINPOWERBAR_SHOW_LEVEL then
			self:UnregisterEvent("PLAYER_LEVEL_UP");
			self.showAnim:Play();
			self:UpdatePower();
		end
	else
		return false;
	end

	return true;
end

function PaladinPowerBar:Setup()
	local showBar = ClassPowerBar.Setup(self);

	if (showBar) then
		if UnitLevel("player") < PALADINPOWERBAR_SHOW_LEVEL then
			self:RegisterEvent("PLAYER_LEVEL_UP");
			self:SetAlpha(0);
		end

		self.maxHolyPower = UnitPowerMax("player", Enum.PowerType.HolyPower);
		if ( self.maxHolyPower > HOLY_POWER_FULL ) then
			self.bankBG:SetAlpha(1);
		end
	end
end

function PaladinPowerBar:ToggleHolyRune(self, visible)
	if visible then
		self.activate:Stop();
		self.deactivate:Play();
	else
		self.deactivate:Stop();
		self.activate:Play();
	end
end

function PaladinPowerBar:UpdatePower()
	if ( self.delayedUpdate ) then
		return;
	end

	local numHolyPower = UnitPower( self:GetParent().unit, Enum.PowerType.HolyPower );
	local maxHolyPower = UnitPowerMax( self:GetParent().unit, Enum.PowerType.HolyPower );

	for i=1,maxHolyPower do
		local holyRune = self["rune"..i];
		local isShown = not holyRune.deactivate:IsPlaying() and (holyRune:GetAlpha()> 0 or holyRune.activate:IsPlaying());
		local shouldShow = i <= numHolyPower;
		if isShown ~= shouldShow then
			self:ToggleHolyRune(holyRune, isShown);
		end
	end

	-- flash the bar if it's full (3 holy power)
	if numHolyPower >= HOLY_POWER_FULL then
		self.glow.pulse.stopPulse = false;
		self.glow.pulse:Play();
	else
		self.glow.pulse.stopPulse = true;
	end

	-- check whether to show bank slots
	if ( maxHolyPower ~= self.maxHolyPower ) then
		if ( maxHolyPower > HOLY_POWER_FULL ) then
			self.showBankAnim:Play();
		else
			-- there is no way to lose the bank slots once you have them, but just in case
			self.showBankAnim:Stop();
			self.bankBG:SetAlpha(0);
		end
		self.maxHolyPower = maxHolyPower;
	end

	self.lastPower = numHolyPower;
end
