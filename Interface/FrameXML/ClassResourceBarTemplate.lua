--[[ 
--------------------------- KeyValues --------------------------------
	tooltip1, tooltip2 [string] - Builds the mouseover tooltip1
	class [string] - The string name of the class
	spec [string] - Spec name of the class
	powerToken [string] = power token of the resource
	powerToken2 [string] = second power token of the resource
	maxUsablePoints [number] = the max points of the resource
	powerType [Enum.PowerType] = the power type of the class resource 
	spec [global] - the spec for the power bar to show
	resourceBarMixin [global] - override the default inherited mixin: ClassPowerBar
	resourcePointTemplate [string] - template for the horizontal layout frame to instantiate from
	resourcePointSetupFunc [global] - function on the resource point for any custom setup
	showTooltip [boolean] - show the tooltip on the mouseover
	showBarFunc [global] - custom function for whether or not the bar should show
	requiredShownLevel [number] - If the bar needs a certain level to show this will handle showing the bar on level up, etc
]]
ClassResourceBarMixin = {};

function ClassResourceBarMixin:OnLoad()
	self.classResourceButtonPool = CreateFramePool("FRAME", self, self.resourcePointTemplate);
	self.classResourceButtonTable = { };

	if(self.powerToken) then
		if(self.powerToken2) then
			self:SetPowerTokens(self.powerToken, self.powerToken2);
		else
			self:SetPowerTokens(self.powerToken);
		end
	end
	if(self.showTooltip) then
		self:SetTooltip(self.tooltip1, self.tooltip2);
	end
	self.maxUsablePoints = 5;
	self.resourceBarMixin.OnLoad(self);
end

function ClassResourceBarMixin:OnEvent(event, arg1, arg2)
	if(event == "PLAYER_LEVEL_UP") then 
		local unit = self.unit or self:GetParent().unit;
		unit = unit or "player";
		if(self.requiredShownLevel and UnitLevel(unit) >= self.requiredShownLevel) then
			self:UnregisterEvent("PLAYER_LEVEL_UP");
			self:HandleBarSetup();
		end
	elseif (event == "UNIT_DISPLAYPOWER" or event == "PLAYER_ENTERING_WORLD") then
		self:Setup();
	elseif (event == "UNIT_MAXPOWER") then
		self:UpdateMaxPower();
	elseif (event == "UNIT_POWER_POINT_CHARGE") then
		-- Not all classes have power point visuals but may receive this event due to specific spell auras
		if self.UpdateChargedPowerPoints then
			self:UpdateChargedPowerPoints();
		else
			self:UpdatePower();
		end
	else
		self.resourceBarMixin.OnEvent(self, event, arg1, arg2);
	end
end

function ClassResourceBarMixin:HandleBarSetup()
	local frameLevel = self:GetParent() and self:GetParent():GetFrameLevel() + 2 or self:GetFrameLevel(); 
	self:SetFrameLevel(frameLevel);
	self:Show();
	self:UpdateMaxPower();
	if(self.resourceBarMixin.UpdateMaxPower) then 
		self.resourceBarMixin.UpdateMaxPower(self);
	end
	self:UpdatePower();
end

function ClassResourceBarMixin:Setup()
	local showBar = false;
	self.xOffset = select(4, self:GetPoint());

	if UnitInVehicle("player") then
		self.xOffset = 43;
		showBar = PlayerVehicleHasComboPoints();
	else
		showBar = self.resourceBarMixin.Setup(self);
		if(self.showBarFunc) then
			showBar = self.showBarFunc(self);
		end
	end

	if showBar then
		self.unit = self.unit or self:GetParent():GetParent().unit;
		self.unit = self.unit or "player";
		self:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit);
		self:RegisterUnitEvent("UNIT_MAXPOWER", unit);
		self:RegisterUnitEvent("UNIT_POWER_POINT_CHARGE", unit);
		if (self.unit == "player" and self.requiredShownLevel and UnitLevel(self.unit) < self.requiredShownLevel) then
			self:RegisterEvent("PLAYER_LEVEL_UP");
		else
			self:HandleBarSetup();
		end
	else
		self:Hide();
		self:UnregisterEvent("UNIT_POWER_FREQUENT");
		self:UnregisterEvent("UNIT_MAXPOWER");
		self:UnregisterEvent("UNIT_POWER_POINT_CHARGE");
	end
end

function ClassResourceBarMixin:UpdateMaxPower()
	self.classResourceButtonPool:ReleaseAll();
	self.classResourceButtonTable = { };

	self.unit = self.unit or self:GetParent():GetParent().unit;
	self.unit = unit or "player";
	self.maxUsablePoints = UnitPowerMax(self.unit, self.powerType);
	for i = 1, self.maxUsablePoints do
		local resourcePoint = self.classResourceButtonPool:Acquire();
		self.classResourceButtonTable[i] = resourcePoint;
		if(self.resourcePointSetupFunc) then
			self.resourcePointSetupFunc(resourcePoint);
		end
		resourcePoint.layoutIndex = i;
		resourcePoint:Show();
	end

	self:Layout();
end

--To be overriden in inherited class
function ClassResourceBarMixin:UpdatePower()

end