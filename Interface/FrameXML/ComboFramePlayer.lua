ComboPointPowerBar = {};

function ComboPointPowerBar:OnLoad()
	if (GetCVar("comboPointLocation") ~= "2") then
		self:Hide();
		return;
	end

	ClassResourceBarMixin.OnLoad(self);
end		
function ComboPointPowerBar:SetupDruid()
	local showBar = false;
	local _, myclass = UnitClass("player");
	if myclass == "DRUID" then
		local powerType, powerToken = UnitPowerType("player");
		showBar = (powerType == Enum.PowerType.Energy);
	end
	return showBar;
end

function ComboPointPowerBar:UpdatePower()
	if ( self.delayedUpdate ) then
		return;
	end

	local unit = self:GetParent().unit;
	local comboPoints = UnitPower(unit, Enum.PowerType.ComboPoints);
	local maxComboPoints = UnitPowerMax(unit, Enum.PowerType.ComboPoints);

	if ( self.lastPower and self.lastPower > self.maxUsablePoints and comboPoints == self.lastPower - self.maxUsablePoints ) then
		for i = 1, self.maxUsablePoints do
			self.classResourceButtonTable[i]:AnimateOut();
		end
		self.delayedUpdate = true;
		self.lastPower = nil;
		C_Timer.After(0.45, function()
			self.delayedUpdate = false;
			self:UpdatePower();
		end);
	else
		for i = 1, min(comboPoints, self.maxUsablePoints) do
			if (not self.classResourceButtonTable[i].on) then
				self.classResourceButtonTable[i]:AnimateIn();
			end
		end
		for i = comboPoints + 1, self.maxUsablePoints do
			if (self.classResourceButtonTable[i] and self.classResourceButtonTable[i].on) then
				self.classResourceButtonTable[i]:AnimateOut();
			end
		end
		self.lastPower = comboPoints;
	end

	self:UpdateChargedPowerPoints();
end

function ComboPointPowerBar:UpdateChargedPowerPoints()
	local chargedPowerPoints = GetUnitChargedPowerPoints(self:GetParent().unit);
	for i = 1, self.maxUsablePoints do
		local comboPointFrame = self.classResourceButtonTable[i];
		if(comboPointFrame) then 
			local isCharged = chargedPowerPoints and tContains(chargedPowerPoints, i);
			if comboPointFrame.isCharged ~= isCharged then
				comboPointFrame.isCharged = isCharged;
				if isCharged then
					comboPointFrame.Point:SetAtlas("ComboPoints-ComboPoint-Kyrian");
					comboPointFrame.PointOff:SetAtlas("ComboPoints-PointBg-Kyrian");
					if comboPointFrame.on then
						comboPointFrame.on = false;
						comboPointFrame.AnimIn:Stop();
					end
					comboPointFrame:AnimateIn();
				else
					comboPointFrame.Point:SetAtlas("ComboPoints-ComboPoint");
					comboPointFrame.PointOff:SetAtlas("ComboPoints-PointBg");
				end
			end
		end
	end
end

ComboPointPlayerMixin = { }
function ComboPointPlayerMixin:AnimateIn()
	if (not self.on) then
		self.on = true;
		self.AnimIn:Play();

		if (self.PointAnim) then
			self.PointAnim:Play();
		end
	end
end

function ComboPointPlayerMixin:Setup()
	self.on = false; 
end 

function ComboPointPlayerMixin:AnimateOut()
	if (self.on) then
		self.on = false;

		if (self.PointAnim) then
			self.PointAnim:Play(true);
		end

		self.AnimIn:Stop();
		self.AnimOut:Play();
	end
end
