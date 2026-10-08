local COMBOFRAME_FADE_IN = 0.3;
local MAX_COMBO_POINTS = 5;

local POINT_LAYOUT_DATA = {
	radius = 66,
	startAngleDegrees = -10,
	alternateStartAngleDegrees = 2,
	angleStepDegrees = 21,
	pointScale = 0.6,
};

ComboFrameMixin = {};

function ComboFrameMixin:OnLoad()
	self:ClearAllPoints();
	self:SetParent(TargetFrame);
	self:SetFrameStrata("MEDIUM");
	self:SetFrameLevel(500);
	self:SetPoint("CENTER", TargetFrame:GetPortrait(), "CENTER", 0, 2);

	self.layout = CopyTable(POINT_LAYOUT_DATA);
	self:InitializeComboPointPool();
	self:UpdateMax();
	self:Update();

	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
	self:RegisterUnitEvent("UNIT_POWER_UPDATE", "player");
	self:RegisterUnitEvent("UNIT_POWER_POINT_CHARGE", "player");
	self:RegisterUnitEvent("UNIT_MAXPOWER", "player");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function ComboFrameMixin:InitializeComboPointPool()
	self.ComboPoints = {};

	local scale = self.layout.pointScale;
	for pointIndex = 1, MAX_COMBO_POINTS do
		local comboPoint = CreateFrame("FRAME", nil, self, "RogueComboPointTemplate");
		assert(comboPoint.Setup and comboPoint.SetActive and comboPoint.SetActiveNoAnimation,
			"Combo point template must implement Setup, SetActive, and SetActiveNoAnimation");
		comboPoint.layoutIndex = pointIndex;
		comboPoint:Setup();
		comboPoint:SetScale(scale);
		comboPoint:Hide();
		self.ComboPoints[pointIndex] = comboPoint;
	end
end

function ComboFrameMixin:OnEvent(event, ...)
	if event == "PLAYER_TARGET_CHANGED" then
		local suppressTransitions = true;
		self:Update(suppressTransitions);
	elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_POWER_UPDATE" or event == "UNIT_POWER_POINT_CHARGE" then
		self:Update();
	elseif event == "UNIT_MAXPOWER" then
		self:UpdateMax();
		self:Update();
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UpdateMax();
		self:Update();
	end
end

function ComboFrameMixin:UpdateMax()
	local maxComboPoints = UnitPowerMax("player", Enum.PowerType.ComboPoints);
	self.maxComboPoints = math.min(maxComboPoints, MAX_COMBO_POINTS);

	self:LayoutPointsCircle();
end

function ComboFrameMixin:LayoutPointsCircle()
	local radius = self.layout.radius;
	local startAngleDegrees = self:GetEffectiveStartAngleDegrees();
	local angleStepDegrees = self.layout.angleStepDegrees;

	for pointIndex, comboPoint in ipairs(self.ComboPoints) do
		comboPoint:ClearAllPoints();

		if pointIndex <= self.maxComboPoints then
			local angleDegrees = startAngleDegrees + ((pointIndex - 1) * angleStepDegrees);
			local angleRadians = math.rad(angleDegrees);
			local xOffset = math.cos(angleRadians) * radius;
			local yOffset = math.sin(angleRadians) * radius;
			comboPoint:SetPoint("CENTER", self, "CENTER", xOffset, yOffset);
		end
	end
end

function ComboFrameMixin:GetEffectiveStartAngleDegrees()
	if TargetFrame:IsPvPBackgroundShown() then
		return self.layout.alternateStartAngleDegrees;
	end

	return self.layout.startAngleDegrees;
end

function ComboFrameMixin:Update(suppressTransitions)
	self:LayoutPointsCircle(self.maxComboPoints);

	local comboPoints = math.min(GetComboPoints("player", "target"), self.maxComboPoints);
	local firstActivePointIndex = self.maxComboPoints - comboPoints + 1;
	local shouldSuppressTransitions = suppressTransitions;
	local hasComboPoints = comboPoints > 0;

	for pointIndex, comboPoint in ipairs(self.ComboPoints) do
		if pointIndex <= self.maxComboPoints then
			comboPoint:Show();
			local isActive = pointIndex >= firstActivePointIndex;
			if shouldSuppressTransitions then
				comboPoint:SetActiveNoAnimation(isActive);
			else
				comboPoint:SetActive(isActive);
			end
		else
			comboPoint:Hide();
		end
	end

	if hasComboPoints then
		if not self:IsShown() then
			if shouldSuppressTransitions then
				self:SetAlpha(1);
				self:Show();
			else
				self:Show();
				UIFrameFadeIn(self, COMBOFRAME_FADE_IN);
			end
		end
	else
		self:Hide();
	end
end
