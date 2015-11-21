ClassNameplateBar = {};

function ClassNameplateBar:OnLoad()
	--[[ 
		Initialize these variables in the class-specific OnLoad mixin function. Also make sure to implement
		a UpdatePower() mixin function that handles UI changes for whenever the power display changes
	self.class = "PALADIN";
	self.spec = SPEC_PALADIN_RETRIBUTION;
	self.powerTokens = {"HOLY_POWER", "MANA"}
	]]--
	
	self:Setup();
end

function ClassNameplateBar:OnEvent(event, arg1, arg2)
	if ( event == "UNIT_POWER_FREQUENT" and arg1 == "player" ) then
		if (self.powerToken == arg2 ) then
			self:UpdatePower();
		end
	elseif ( event == "UNIT_MAXPOWER" and arg1 == "player" ) then
		self:UpdateMaxPower();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		self:UpdatePower();
	elseif (event == "PLAYER_TALENT_UPDATE" ) then
		self:Setup();
		self:UpdatePower();
	else
		return false;
	end
	return true;
end

function ClassNameplateBar:MatchesClass()
	local _, myclass = UnitClass("player");
	return myclass == self.class;
end

function ClassNameplateBar:MatchesSpec()
	if ( not self.spec ) then
		return true;
	end
	local myspec = GetSpecialization();
	return myspec == self.spec;
end
	
function ClassNameplateBar:Setup()
	local showBar = false;
	
	if ( self:MatchesClass() ) then
		if ( self:MatchesSpec() ) then
			self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
			self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
			self:RegisterEvent("PLAYER_ENTERING_WORLD");
			showBar = true;
		else
			self:UnregisterEvent("UNIT_POWER_FREQUENT");
			self:UnregisterEvent("UNIT_MAXPOWER");
			self:UnregisterEvent("PLAYER_ENTERING_WORLD");
		end
		
		self:RegisterEvent("PLAYER_TALENT_UPDATE");
	end
	self:ShowNameplateBar(showBar);
	if (showBar) then
		self:UpdateMaxPower();
	end
	return showBar;
end

function ClassNameplateBar:ShowNameplateBar(show)
	self:SetShown(show);
	if (show) then
		NamePlateDriverFrame:SetClassNameplateBar(self);
	end
end

function ClassNameplateBar:TurnOn(frame, texture, toAlpha)
	local alphaValue = texture:GetAlpha();
	frame.Fadein:Stop();
	frame.Fadeout:Stop();
	texture:SetAlpha(alphaValue);
	frame.on = true;
	if (alphaValue < toAlpha) then
		frame.Fadein.AlphaAnim:SetFromAlpha(alphaValue);
		frame.Fadein:Play();
	end
end

function ClassNameplateBar:TurnOff(frame, texture, toAlpha)
	local alphaValue = texture:GetAlpha();
	frame.Fadein:Stop();
	frame.Fadeout:Stop();
	texture:SetAlpha(alphaValue);
	frame.on = false;
	if (alphaValue > toAlpha) then
		frame.Fadeout.AlphaAnim:SetFromAlpha(alphaValue);
		frame.Fadeout:Play();
	end
end

function ClassNameplateBar:UpdateMaxPower()
end

function ClassNameplateBar:UpdatePower()
end


ClassNameplateManaBar = {};

function ClassNameplateManaBar:OnLoad()
	self.powerData = 
	{
		{class="DEATHKNIGHT", powerToken="RUNIC_POWER", powerType=SPELL_POWER_RUNIC_POWER},
		{class="DEMONHUNTER", powerToken="FURY", powerType=SPELL_POWER_FURY},
		{class="DRUID", powerToken="MANA", powerType=SPELL_POWER_MANA}, -- Druid needs some special case code to handle different forms
		{class="HUNTER", powerToken="FOCUS", powerType=SPELL_POWER_FOCUS},
		{class="MAGE", powerToken="MANA", powerType=SPELL_POWER_MANA},
		{class="MONK", spec=SPEC_MONK_MISTWEAVER, powerToken="MANA", powerType=SPELL_POWER_MANA},
		{class="MONK", powerToken="ENERGY", powerType=SPELL_POWER_ENERGY},
		{class="PALADIN", powerToken="MANA", powerType=SPELL_POWER_MANA},
		{class="PRIEST", spec=SPEC_PRIEST_SHADOW, powerToken="INSANITY", powerType=SPELL_POWER_INSANITY},
		{class="PRIEST", powerToken="MANA", powerType=SPELL_POWER_MANA},
		{class="ROGUE", powerToken="ENERGY", powerType=SPELL_POWER_ENERGY},
		{class="SHAMAN", spec=SPEC_SHAMAN_RESTORATION, powerToken="MANA", powerType=SPELL_POWER_MANA},
		{class="SHAMAN", powerToken="MAELSTROM", powerType=SPELL_POWER_MAELSTROM},
		{class="WARLOCK", powerToken="MANA", powerType=SPELL_POWER_MANA},
		{class="WARRIOR", powerToken="RAGE", powerType=SPELL_POWER_RAGE},
	};
	
	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateManaBar:Setup()
	local _, myclass = UnitClass("player");
	local myspec = GetSpecialization();
	for i = 1, #self.powerData do
		if (myclass == self.powerData[i].class) then
			self.class = myclass;
			local spec = self.powerData[i].spec;
			if (not spec or myspec == spec) then
				self.spec = myspec;
				self.powerToken = self.powerData[i].powerToken;
				self.powerType = self.powerData[i].powerType;
				break;
			end
		end
	end
	
	if (self.powerToken) then
		local info = PowerBarColor[self.powerToken];
		self:SetStatusBarColor(info.r, info.g, info.b);
	end
	return ClassNameplateBar.Setup(self);
end

function ClassNameplateManaBar:UpdateMaxPower()
	self:SetMinMaxValues(0, UnitPowerMax("player", self.powerType));
end

function ClassNameplateManaBar:UpdatePower()
	self:SetValue(UnitPower("player", self.powerType));
end

function ClassNameplateManaBar:ShowNameplateBar(show)
	self:SetShown(show);
	if (show) then
		NamePlateDriverFrame:SetClassNameplateManaBar(self);
	end
end
