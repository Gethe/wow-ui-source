-- Autocast shine stuff --

AUTOCAST_SHINE_R = .95;
AUTOCAST_SHINE_G = .95;
AUTOCAST_SHINE_B = .32;

local AUTOCAST_SHINES = {};

AutoCastOverlayMixin = {};

function AutoCastOverlayMixin:OnLoad()
	for _, sparkle in ipairs(self.sparkles) do
		sparkle:SetVertexColor(AUTOCAST_SHINE_R, AUTOCAST_SHINE_G, AUTOCAST_SHINE_B);
	end
end

function AutoCastOverlayMixin:ShowAutoCastEnabled(isEnabled)
	if (isEnabled) then
		AutoCastOverlayManager:AddActiveShine(self);
	else
		AutoCastOverlayManager:RemoveActiveShine(self);
	end

	for _, sparkle in ipairs(self.sparkles) do
		sparkle:SetShown(isEnabled);
	end
end

AutoCastOverlayManagerMixin = {};

function AutoCastOverlayManagerMixin:OnLoad()
	self.autocastShineSpeeds = { 2, 4, 6, 8 };
	self.autocastShineTimers = { 0, 0, 0, 0 };

	self.activeShines = {};
end

function AutoCastOverlayManagerMixin:AddActiveShine(shine)
	tInsertUnique(self.activeShines, shine);
end

function AutoCastOverlayManagerMixin:RemoveActiveShine(shine)
	tDeleteItem(self.activeShines, shine);
end

function AutoCastOverlayManagerMixin:OnUpdate(elapsed)
	if (#self.activeShines == 0) then
		return;
	end

	for i in ipairs(self.autocastShineTimers) do
		self.autocastShineTimers[i] = self.autocastShineTimers[i] + elapsed;
		if ( self.autocastShineTimers[i] > self.autocastShineSpeeds[i]*4 ) then
			self.autocastShineTimers[i] = self.autocastShineTimers[i] - self.autocastShineSpeeds[i]*4;
		end
	end

	for _, button in ipairs(self.activeShines) do
		local distance = button:GetWidth();

		for i = 1, 4 do
			local timer = self.autocastShineTimers[i];
			local speed = self.autocastShineSpeeds[i];

			if ( timer <= speed ) then
				local basePosition = timer/speed*distance;
				button.sparkles[0+i]:SetPoint("CENTER", button, "TOPLEFT", basePosition, 0);
				button.sparkles[4+i]:SetPoint("CENTER", button, "BOTTOMRIGHT", -basePosition, 0);
				button.sparkles[8+i]:SetPoint("CENTER", button, "TOPRIGHT", 0, -basePosition);
				button.sparkles[12+i]:SetPoint("CENTER", button, "BOTTOMLEFT", 0, basePosition);
			elseif ( timer <= speed*2 ) then
				local basePosition = (timer-speed)/speed*distance;
				button.sparkles[0+i]:SetPoint("CENTER", button, "TOPRIGHT", 0, -basePosition);
				button.sparkles[4+i]:SetPoint("CENTER", button, "BOTTOMLEFT", 0, basePosition);
				button.sparkles[8+i]:SetPoint("CENTER", button, "BOTTOMRIGHT", -basePosition, 0);
				button.sparkles[12+i]:SetPoint("CENTER", button, "TOPLEFT", basePosition, 0);
			elseif ( timer <= speed*3 ) then
				local basePosition = (timer-speed*2)/speed*distance;
				button.sparkles[0+i]:SetPoint("CENTER", button, "BOTTOMRIGHT", -basePosition, 0);
				button.sparkles[4+i]:SetPoint("CENTER", button, "TOPLEFT", basePosition, 0);
				button.sparkles[8+i]:SetPoint("CENTER", button, "BOTTOMLEFT", 0, basePosition);
				button.sparkles[12+i]:SetPoint("CENTER", button, "TOPRIGHT", 0, -basePosition);
			else
				local basePosition = (timer-speed*3)/speed*distance;
				button.sparkles[0+i]:SetPoint("CENTER", button, "BOTTOMLEFT", 0, basePosition);
				button.sparkles[4+i]:SetPoint("CENTER", button, "TOPRIGHT", 0, -basePosition);
				button.sparkles[8+i]:SetPoint("CENTER", button, "TOPLEFT", basePosition, 0);
				button.sparkles[12+i]:SetPoint("CENTER", button, "BOTTOMRIGHT", -basePosition, 0);
			end
		end
	end
end
