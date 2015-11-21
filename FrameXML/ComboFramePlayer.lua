ComboPointPowerBar = {};

function ComboPointPowerBar:OnLoad()
	if (GetCVar("comboPointLocation") ~= "2") then
		self:Hide();
		return;
	end
	
	self.class = "ROGUE";
	self.powerTokens = {"COMBO_POINTS"};
	
	for i = 1, #self.ComboPoints do
		self.ComboPoints[i].on = false;
	end
	self.Combo7.Point:SetSize(8, 8);
	self.Combo8.Point:SetSize(8, 8);
	self.Combo7.PointOff:Hide();
	self.Combo8.PointOff:Hide();
	self.comboPointSize = 15;
	self.maxUsablePoints = 5;
	ClassPowerBar.OnLoad(self);
end

function ComboPointPowerBar:OnEvent(event, arg1, arg2)
	if (event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD" ) then
		self:SetupDruid();
	elseif (event == "UNIT_MAXPOWER") then
		self:UpdateMaxPower();
	else
		ClassPowerBar.OnEvent(self, event, arg1, arg2);
	end
end


function ComboPointPowerBar:Setup()
	local showBar = ClassPowerBar.Setup(self);
	if (showBar) then
		self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
		self:SetPoint("TOP", self:GetParent(), "BOTTOM", 50, 30);
		self:UpdateMaxPower();
	else
		self:SetupDruid();
	end
end

function ComboPointPowerBar:SetupDruid()
	local _, myclass = UnitClass("player");
	if (myclass ~= "DRUID") then
		return;
	end
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
		self:SetPoint("TOP", self:GetParent(), "BOTTOM", 50, 18);
		self:Show();
		self:UpdateMaxPower();
		self:UpdatePower();
	else
		self:Hide();
	end
end

function ComboPointPowerBar:UpdateMaxPower()
	local maxComboPoints = UnitPowerMax("player", SPELL_POWER_COMBO_POINTS);
	
	for i = 1, maxComboPoints do
		self.ComboPoints[i]:Show();
	end
	for i = maxComboPoints + 1, #self.ComboPoints do
		self.ComboPoints[i]:Hide();
	end
	
	self.maxUsablePoints = 5;
	if (maxComboPoints == 6) then
		self.maxUsablePoints = 6;
		self.Combo6:SetSize(self.comboPointSize, self.comboPointSize);
		self.Combo6.Point:SetSize(self.comboPointSize, self.comboPointSize);
		self.Combo6:ClearAllPoints();
		self.Combo6:SetPoint("LEFT", self.ComboPoints[5], "RIGHT", 4, 0);
		self:SetHeight(self.comboPointSize);
	elseif (maxComboPoints == 8) then
		self.Combo6:SetSize(8, 8);
		self.Combo6.Point:SetSize(8, 8);
		self.Combo6:ClearAllPoints();
		self.Combo6:SetPoint("BOTTOM", -12, 0);
		self:SetHeight(22);
	end
	self:SetWidth(self.Combo1:GetWidth() * self.maxUsablePoints + 4 * (self.maxUsablePoints - 1));
	
	if (self.Combo6.PointOff) then
		self.Combo6.PointOff:SetShown(maxComboPoints == 6);
	end
end

function ComboPointPowerBar:UpdatePower()
	if ( self.delayedUpdate ) then
		return;
	end
	
	local comboPoints = UnitPower("player", SPELL_POWER_COMBO_POINTS);
	
	-- If we had more than self.maxUsablePoints and then used a finishing move, fade out
	-- the top row of points and then move the remaining points from the bottom up to the top
	if ( self.lastPower and self.lastPower > self.maxUsablePoints and comboPoints == self.lastPower - self.maxUsablePoints ) then
		for i = 1, self.maxUsablePoints do
			self:TurnOff(self.ComboPoints[i], self.ComboPoints[i].Point, 0);
		end
		self.delayedUpdate = true;
		self.lastPower = nil;
		C_Timer.After(0.25, function()
			self.delayedUpdate = false;
			self:UpdatePower();
		end);
	else
		for i = 1, comboPoints do
			if (not self.ComboPoints[i].on) then
				self:TurnOn(self.ComboPoints[i], self.ComboPoints[i].Point, 1);
			end
		end
		for i = comboPoints + 1, #self.ComboPoints do
			if (self.ComboPoints[i].on) then
				self:TurnOff(self.ComboPoints[i], self.ComboPoints[i].Point, 0);
			end
		end
		self.lastPower = comboPoints;
	end
end
