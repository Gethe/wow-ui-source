ClassNameplateBarRogueDruid = {};

function ClassNameplateBarRogueDruid:OnLoad()
	ClassResourceBarMixin.OnLoad(self);
end

function ClassNameplateBarRogueDruid:UpdateMaxPower()
	ClassResourceBarMixin.UpdateMaxPower(self);
end

function ClassNameplateBarRogueDruid:Setup()
	ClassResourceBarMixin.Setup(self);
end

function ClassNameplateBarRogueDruid:OnShow()
	self:UpdatePower();
end

function ClassNameplateBarRogueDruid:SetupDruid()
	local powerType, powerToken = UnitPowerType("player");
	local showBar = false;
	if (powerType == Enum.PowerType.Energy) then
		showBar = true;
	end
	if (showBar) then
		self:ShowNameplateBar();
		self:UpdatePower();
	else
		self:HideNameplateBar();
	end
	return showBar;
end

function ClassNameplateBarRogueDruid:SetupRogue()
	local showBar = ClassNameplateBar.Setup(self);
	if(showBar) then
		self:ShowNameplateBar();
	end
	return showBar;
end

function ClassNameplateBarRogueDruid:UpdatePower()
	if ( self.delayedUpdate or not self:IsShown() or (self.classResourceButtonTable and #self.classResourceButtonTable <= 0)) then
		return;
	end

	local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints);

	-- If we had more than self.maxUsablePoints and then used a finishing move, fade out
	-- the top row of points and then move the remaining points from the bottom up to the top
	if ( self.lastPower and self.lastPower > self.maxUsablePoints and comboPoints == self.lastPower - self.maxUsablePoints ) then
		for i = 1, self.maxUsablePoints do
			self:TurnOff(self.classResourceButtonTable[i], self.classResourceButtonTable[i].Point, 0);
		end
		self.delayedUpdate = true;
		self.lastPower = nil;
		C_Timer.After(0.25, function()
			self.delayedUpdate = false;
			self:UpdatePower();
		end);
	else
		for i = 1, comboPoints do
			if (not self.classResourceButtonTable[i].on) then
				self:TurnOn(self.classResourceButtonTable[i], self.classResourceButtonTable[i].Point, 1);
			end
		end
		for i = comboPoints + 1, #self.classResourceButtonTable do
			if (self.classResourceButtonTable[i] and self.classResourceButtonTable[i].on) then
				self:TurnOff(self.classResourceButtonTable[i], self.classResourceButtonTable[i].Point, 0);
			end
		end
		self.lastPower = comboPoints;
	end

	self:UpdateChargedPowerPoints();
end

function ClassNameplateBarRogueDruid:UpdateChargedPowerPoints()
	local chargedPowerPoints = GetUnitChargedPowerPoints("player");
	for i = 1, self.maxUsablePoints do
		local comboPointFrame = self.classResourceButtonTable[i];
		if(comboPointFrame) then 
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
end

ClassNameplateBarComboPointFrameMixin = { }; 
function ClassNameplateBarComboPointFrameMixin:Setup()
	self.on = false; 
end		