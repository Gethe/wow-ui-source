-- Autocast shine stuff --

AUTOCAST_SHINE_R = .95;
AUTOCAST_SHINE_G = .95;
AUTOCAST_SHINE_B = .32;

AUTOCAST_SHINE_SPEEDS = { 2, 4, 6, 8 };
AUTOCAST_SHINE_TIMERS = { 0, 0, 0, 0 };

local AUTOCAST_SHINES = {};


function AutoCastShine_OnLoad(self)
	self.sparkles = {};

	local name = self:GetName();

	for i = 1, 16 do
		tinsert(self.sparkles, _G[name .. i]);
	end
end

function AutoCastShine_AutoCastStart(button, r, g, b)
	if ( AUTOCAST_SHINES[button] ) then
		return;
	end

	AUTOCAST_SHINES[button] = true;

	if ( not r ) then
		r, g, b = AUTOCAST_SHINE_R, AUTOCAST_SHINE_G, AUTOCAST_SHINE_B;
	end

	for _, sparkle in next, button.sparkles do
		sparkle:Show();
		sparkle:SetVertexColor(r, g, b);
	end
end

function AutoCastShine_AutoCastStop(button)
	AUTOCAST_SHINES[button] = nil;

	for _, sparkle in next, button.sparkles do
		sparkle:Hide();
	end
end

function AutoCastShine_OnUpdate(self, elapsed)
	for i in ipairs(AUTOCAST_SHINE_TIMERS) do
		AUTOCAST_SHINE_TIMERS[i] = AUTOCAST_SHINE_TIMERS[i] + elapsed;
		if ( AUTOCAST_SHINE_TIMERS[i] > AUTOCAST_SHINE_SPEEDS[i]*4 ) then
			AUTOCAST_SHINE_TIMERS[i] = 0;
		end
	end

	for button in pairs(AUTOCAST_SHINES) do
		local distance = button:GetWidth();

		-- This is local to this function to save a lookup. If you need to use it elsewhere, might wanna make it global and use a local reference.
		local AUTOCAST_SHINE_SPACING = 6;

		for i = 1, 4 do
			local timer = AUTOCAST_SHINE_TIMERS[i];
			local speed = AUTOCAST_SHINE_SPEEDS[i];

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
