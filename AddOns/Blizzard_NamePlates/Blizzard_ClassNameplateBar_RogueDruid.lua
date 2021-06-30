ClassNameplateBarRogueDruid = {};

function ClassNameplateBarRogueDruid:OnLoad()
	self.class = "ROGUE";
	self.powerToken = "COMBO_POINTS";

	for i = 1, #self.ComboPoints do
		self.ComboPoints[i].on = false;
	end
	for i = 6, #self.ComboPoints do
		self.ComboPoints[i].Background:Hide();
	end
	self.comboPointSize = 13;
	self.bonusPointSize = 10;
	self.maxUsablePoints = 5;
	self.Combo7.Point:SetSize(self.bonusPointSize, self.bonusPointSize);
	self.Combo8.Point:SetSize(self.bonusPointSize, self.bonusPointSize);
	self.Combo9.Point:SetSize(self.bonusPointSize, self.bonusPointSize);
	self.Combo10.Point:SetSize(self.bonusPointSize, self.bonusPointSize);
	ClassNameplateBar.OnLoad(self);
end

function ClassNameplateBarRogueDruid:OnEvent(event, ...)
	if (event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD") then
		self:SetupDruid();
	elseif (event == "UNIT_POWER_POINT_CHARGE") then
		self:UpdateChargedPowerPoints();
	else
		ClassNameplateBar.OnEvent(self, event, ...);
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
	self:RegisterUnitEvent("UNIT_POWER_POINT_CHARGE", "player");
	local powerType, powerToken = UnitPowerType("player");
	local showBar = false;
	if (powerType == Enum.PowerType.Energy) then
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

function ClassNameplateBarRogueDruid:UpdateMaxPower()
	local maxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints);

	for i = 1, maxComboPoints do
		self.ComboPoints[i]:Show();
	end
	for i = maxComboPoints + 1, #self.ComboPoints do
		self.ComboPoints[i]:Hide();
	end

	self.maxUsablePoints = 5;
	self.Combo6.Background:Hide();
	if (maxComboPoints == 6) then
		self.maxUsablePoints = 6;
		self.Combo6:SetSize(self.comboPointSize, self.comboPointSize);
		self.Combo6.Point:SetSize(self.comboPointSize, self.comboPointSize);
		self.Combo6:ClearAllPoints();
		self.Combo6:SetPoint("LEFT", self.ComboPoints[5], "RIGHT", 4, 0);
		self:SetHeight(self.comboPointSize);
		self.Combo6.Background:Show();
	elseif (maxComboPoints >= 8) then
		self.Combo6:SetSize(self.bonusPointSize, self.bonusPointSize);
		self.Combo6.Point:SetSize(self.bonusPointSize, self.bonusPointSize);
		self.Combo6:ClearAllPoints();
		self.Combo6:SetPoint("BOTTOM", -14 - (7 * (maxComboPoints - 8)), -2);
		self:SetHeight(22);
	end
	self:SetWidth(self.Combo1:GetWidth() * self.maxUsablePoints + 4 * (self.maxUsablePoints - 1));

	if (self.Combo6.PointOff) then
		self.Combo6.PointOff:SetShown(maxComboPoints == 6);
	end
end

function ClassNameplateBarRogueDruid:UpdatePower()
	if ( self.delayedUpdate ) then
		return;
	end

	local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints);

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

	self:UpdateChargedPowerPoints();
end

function ComboPointPowerBar:UpdateChargedPowerPoints()
	local chargedPowerPoints = GetUnitChargedPowerPoints("player");
	for i = 1, self.maxUsablePoints do
		local comboPointFrame = self.ComboPoints[i];
		local isCharged = chargedPowerPoints and tContains(chargedPowerPoints, i);
		if comboPointFrame.isCharged ~= isCharged then
			comboPointFrame.isCharged = isCharged;
			if isCharged then
				comboPointFrame.Point:SetAtlas("ClassOverlay-ComboPoint-Kyrian");
				comboPointFrame.Background:SetAtlas("ClassOverlay-ComboPoint-Off-Kyrian");
				if comboPointFrame.on then
					comboPointFrame.on = false;
					comboPointFrame.Point:SetAlpha(0);
				end
				self:TurnOn(comboPointFrame, comboPointFrame.Point, 1);
			else
				comboPointFrame.Point:SetAtlas("ClassOverlay-ComboPoint");
				comboPointFrame.Background:SetAtlas("ClassOverlay-ComboPoint-Off");
			end
		end
	end
end