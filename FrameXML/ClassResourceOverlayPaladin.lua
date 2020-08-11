PaladinResourceOverlay = {};

function PaladinResourceOverlay:OnLoad()
	self.class = "PALADIN";
	--self.spec = SPEC_PALADIN_RETRIBUTION;
	self.powerToken = "HOLY_POWER";

	for i = 1, #self.Runes do
		self.Runes[i].on = false;
		self.Runes[i].OffTexture:SetAtlas("ClassOverlay-HolyPower" .. i .. "off", true);
		self.Runes[i].OnTexture:SetAtlas("ClassOverlay-HolyPower" .. i .. "on", true);
	end

	self.Background:SetAlpha(0.5);

	ClassResourceOverlay.OnLoad(self);
end

function PaladinResourceOverlay:OnEvent(event, arg1, arg2)
	local eventHandled = ClassResourceOverlay.OnEvent(self, event, arg1, arg2);
	if( not eventHandled and event == "PLAYER_LEVEL_UP" ) then
		local level = arg1;
		if level >= PALADINPOWERBAR_SHOW_LEVEL then
			self:UnregisterEvent("PLAYER_LEVEL_UP");
			self:GetParent():SetOverlay(self, true);
			self:UpdatePower();
		end
	end
end

function PaladinResourceOverlay:Setup()
	if (self:MatchesClass() and self:MatchesSpec() and UnitLevel("player") < PALADINPOWERBAR_SHOW_LEVEL) then
		self:RegisterEvent("PLAYER_LEVEL_UP");
		self:GetParent():SetOverlay(self, false);
	else
		ClassResourceOverlay.Setup(self);
	end
end

function PaladinResourceOverlay:ToggleHolyRune(self, on)
	if (self.on ~= on) then
		if (on) then
			self.TurnOn:Play();
		else
			self.TurnOff:Play();
		end
	end
end

function PaladinResourceOverlay:UpdatePower()
	if ( self.delayedUpdate ) then
		return;
	end

	local numHolyPower = UnitPower("player", Enum.PowerType.HolyPower);
	local maxHolyPower = UnitPowerMax("player", Enum.PowerType.HolyPower);

	-- If we had more than HOLY_POWER_FULL and then used HOLY_POWER_FULL amount of power, fade out
	-- the top 3 and then move the remaining power from the bottom up to the top
	if ( self.lastPower and self.lastPower > HOLY_POWER_FULL and numHolyPower == self.lastPower - HOLY_POWER_FULL ) then
		for i = 1, HOLY_POWER_FULL do
			self:ToggleHolyRune(self.Runes[i], false);
		end
		self.delayedUpdate = true;
		self.lastPower = nil;
		C_Timer.After(0.6, function()
			self.delayedUpdate = false;
			self:UpdatePower();
		end);
	else
		for i = 1, numHolyPower do
			self:ToggleHolyRune(self.Runes[i], true);
		end
		for i = numHolyPower + 1, maxHolyPower do
			self:ToggleHolyRune(self.Runes[i], false);
		end
		self.lastPower = numHolyPower;
	end
end
