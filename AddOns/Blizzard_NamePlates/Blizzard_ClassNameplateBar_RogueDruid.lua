ClassNameplateBarRogueDruid = {};

function ClassNameplateBarRogueDruid:OnLoad()
	self.class = "ROGUE";
	self.powerToken = "COMBO_POINTS";
	
	for i = 1, #self.ComboPoints do
		self.ComboPoints[i].on = false;
	end
	self.Combo7.Point:SetSize(8, 8);
	self.Combo8.Point:SetSize(8, 8);
	self.comboPointSize = 13;
	self.maxUsablePoints = 5;
	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarRogueDruid:OnEvent(event, arg1, arg2)
	if (event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD") then
		self:SetupDruid();
	else
		ClassNameplateBar.OnEvent(self, event, arg1, arg2);
	end
end

function ClassNameplateBarRogueDruid:Setup()
	local showBar = ClassNameplateBar.Setup(self);
	-- Also show for cat form druids
	if (not showBar) then
		local _, myclass = UnitClass("player");
		if (myclass == "DRUID") then
			self:SetupDruid();
		end
	end
end

function ClassNameplateBarRogueDruid:SetupDruid()
	self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	local powerType, powerToken = UnitPowerType("player");
	local showBar = false;
	if (powerType == SPELL_POWER_ENERGY) then
		showBar = true;
		self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
		self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
	else
		self:UnregisterEvent("UNIT_POWER_FREQUENT");
		self:UnregisterEvent("UNIT_MAXPOWER");
	end
	if (showBar) then
		self:ShowNameplateBar();
		self:UpdatePower();
	else
		self:HideNameplateBar();
	end
end
