ClassNameplateBarPaladin = {};

function ClassNameplateBarPaladin:OnLoad()
	self.class = "PALADIN";
	--self.spec = SPEC_PALADIN_RETRIBUTION;
	self.powerToken = "HOLY_POWER";

	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarPaladin:OnEvent(event, ...)
	local eventHandled = ClassNameplateBar.OnEvent(self, event, ...);
	if( not eventHandled and event == "PLAYER_LEVEL_UP" ) then
		local level = ...;
		if level >= PALADINPOWERBAR_SHOW_LEVEL then
			self:UnregisterEvent("PLAYER_LEVEL_UP");
			self:ShowNameplateBar();
			self:UpdatePower();
		end
	end
end

function ClassNameplateBarPaladin:Setup()
	local showBar = ClassNameplateBar.Setup(self);

	if (showBar and UnitLevel("player") < PALADINPOWERBAR_SHOW_LEVEL) then
		self:RegisterEvent("PLAYER_LEVEL_UP");
		self:HideNameplateBar();
	end
end

function ClassNameplateBarPaladin:ToggleHolyRune(self, enabled)
	if self.enabled ~= enabled then

		self.enabled = enabled;
		if self.enabled then
			self.TurnOff:Stop();
			self.TurnOn:Play();
		else
			self.TurnOn:Stop();
			self.TurnOff:Play();
		end
	end
end

function ClassNameplateBarPaladin:UpdatePower()
	local numHolyPower = UnitPower("player", Enum.PowerType.HolyPower);
	local maxHolyPower = UnitPowerMax("player", Enum.PowerType.HolyPower);

	for i = 1, numHolyPower do
		self:ToggleHolyRune(self.Runes[i], true);
	end
	for i = numHolyPower + 1, maxHolyPower do
		self:ToggleHolyRune(self.Runes[i], false);
	end
	self.lastPower = numHolyPower;
end
