ClassNameplateBarDracthyr = { };

function ClassNameplateBarDracthyr:OnLoad()
	self.class = "DRACTHYR";
	self.powerToken = "ESSENCE";
	self.maxUsablePoints = 5;
	EssenceFrameMixin.OnLoad(self);
	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarDracthyr:OnEvent(event, ...)
	if (event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		self:Setup();
	elseif (event == "UNIT_MAXPOWER") then
		EssenceFrameMixin.UpdateMaxPower(self);
	elseif ( event == "UNIT_POWER_FREQUENT" ) then
		EssenceFrameMixin.UpdatePower(self);
	else
		ClassNameplateBar.OnEvent(self, event, ...);
	end
end

function ClassNameplateBarDracthyr:Setup()
	local showBar = ClassNameplateBar.Setup(self);
	self.unit = "player";
	local _, myclass = UnitClass(self.unit);
	if (not showBar) then
		if (myclass == "EVOKER") then
			self:SetupDracthyr();
		end
	end
end

function ClassNameplateBarDracthyr:SetupDracthyr()
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterUnitEvent("UNIT_POWER_POINT_CHARGE", "player");
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
	self:ShowNameplateBar();
	EssenceFrameMixin.UpdateMaxPower(self);
	EssenceFrameMixin.UpdatePower(self); 
end