ClassNameplateBarWindwalkerMonk = {};

function ClassNameplateBarWindwalkerMonk:OnLoad()
	self.class = "MONK";
	self.spec = SPEC_MONK_WINDWALKER;
	self.powerToken = "CHI";

	for i = 1, #self.Chi do
		self.Chi[i].on = false;
	end
	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarWindwalkerMonk:UpdateMaxPower()
	local maxOrbs = UnitPowerMax("player", Enum.PowerType.Chi);
	self.Chi6:SetShown(maxOrbs == 6);
	self:SetWidth(self.Chi1:GetWidth() * maxOrbs);
end

function ClassNameplateBarWindwalkerMonk:UpdatePower()
	local chi = UnitPower("player", Enum.PowerType.Chi);
	for i = 1, min(chi, #self.Chi) do
		if (not self.Chi[i].on) then
			self:TurnOn(self.Chi[i], self.Chi[i].Orb, 1);
		end
	end
	for i = chi + 1, #self.Chi do
		if (self.Chi[i].on) then
			self:TurnOff(self.Chi[i], self.Chi[i].Orb, 0);
		end
	end
end


--------------------------------------------------------------------------------
--
-- ClassNameplateBarBrewmasterMonk
--
--------------------------------------------------------------------------------

ClassNameplateBarBrewmasterMonk = {};

function ClassNameplateBarBrewmasterMonk:OnLoad()
	self.class = "MONK";
	self.spec = SPEC_MONK_BREWMASTER;
	self.powerToken = "STAGGER";
	self.overrideTargetMode = false;
	self.paddingOverride = 0;
	self.currValue = 0;
	self.Border:SetVertexColor(0, 0, 0, 1);
	self.Border:SetBorderSizes(nil, nil, 0, 0);
	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarBrewmasterMonk:UpdateMaxPower()
	local maxhealth = UnitHealthMax("player");
	self:SetMinMaxValues(0, maxhealth);
end

function ClassNameplateBarBrewmasterMonk:OnUpdate()
	self:UpdatePower();
end

function ClassNameplateBarBrewmasterMonk:UpdatePower()
	local currstagger = UnitStagger("player");
	if (not currstagger) then
		return;
	end
	self:SetValue(currstagger);
	self.value = currstagger;
	self:UpdateMaxPower();

	local _, maxstagger = self:GetMinMaxValues();
	local percent = currstagger/maxstagger;
	local info = PowerBarColor[BREWMASTER_POWER_BAR_NAME];

	if (percent > STAGGER_YELLOW_TRANSITION and percent < STAGGER_RED_TRANSITION) then
		info = info[STAGGER_YELLOW_INDEX];
	elseif (percent > STAGGER_RED_TRANSITION) then
		info = info[STAGGER_RED_INDEX];
	else
		info = info[STAGGER_GREEN_INDEX];
	end
	self:SetStatusBarColor(info.r, info.g, info.b);
end

function ClassNameplateBarBrewmasterMonk:OnOptionsUpdated()
	self:OnSizeChanged();
end

function ClassNameplateBarBrewmasterMonk:OnSizeChanged() -- override
	PixelUtil.SetHeight(self, DefaultCompactNamePlatePlayerFrameSetUpOptions.healthBarHeight);
	self.Border:UpdateSizes();
end