COMBOFRAME_FADE_IN = 0.3;
COMBOFRAME_FADE_OUT = 0.5;
COMBOFRAME_HIGHLIGHT_FADE_IN = 0.4;
COMBOFRAME_SHINE_FADE_IN = 0.3;
COMBOFRAME_SHINE_FADE_OUT = 0.4;
COMBO_FRAME_LAST_NUM_POINTS = 0;

function ComboFrame_OnLoad(self)
	if (GetCVar("comboPointLocation") ~= "1") then
		self:Hide();
		return;
	end

	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("UNIT_POWER_FREQUENT");
	self:RegisterEvent("UNIT_MAXPOWER");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	-- init alpha
	self.ComboPoints[1].Highlight:SetAlpha(0);
	self.ComboPoints[1].Shine:SetAlpha(0);

	ComboFrame_UpdateMax(self);
end

function ComboFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		ComboFrame_Update(self);
	elseif ( event == "UNIT_POWER_FREQUENT" ) then
		local unit = ...;
		if ( unit == PlayerFrame.unit ) then
			ComboFrame_Update(self);
		end
	elseif ( event == "UNIT_MAXPOWER" or event == "PLAYER_ENTERING_WORLD" ) then
		ComboFrame_UpdateMax(self);
	end
end

function ComboFrame_UpdateMax(self)
	self.maxComboPoints = UnitPowerMax(PlayerFrame.unit, Enum.PowerType.ComboPoints);

	-- If we have 6 or 9 max combo points, we use the first combo point and we show 6 circles
	-- in a row. Otherwise we skip the first combo point and show 5 circles. The last 3 combo
	-- point circle (if you have the talent to allow this) are shown only if filled.
	if (self.maxComboPoints == 6 or self.maxComboPoints == 9) then
		self.startComboPointIndex = 1;
		self.extraComboPoints = 7;
	else
		self.startComboPointIndex = 2;
		self.extraComboPoints = 6;
	end

	-- First hide all combo points
	for i = 1, #self.ComboPoints do
		self.ComboPoints[i]:Hide();
	end
end

function ComboFrame_Update(self)

	if (not self.maxComboPoints) then
		-- This can happen if we are showing combo points on the player frame (which doesn't use ComboFrame) and we exit a vehicle.
		return;
	end

	local comboPoints = GetComboPoints(PlayerFrame.unit, "target");
	local comboPoint, comboPointHighlight, comboPointShine;

	if ( comboPoints > 0 ) then
		if ( not self:IsShown() ) then
			self:Show();
			UIFrameFadeIn(self, COMBOFRAME_FADE_IN);
		end

		local comboIndex = self.startComboPointIndex;
		for i=1, self.maxComboPoints do
			local fadeInfo = {};
			comboPoint = self.ComboPoints[comboIndex];
			comboPointHighlight = comboPoint.Highlight;
			comboPointShine = comboPoint.Shine;
			if ( i <= comboPoints ) then
				if ( i > COMBO_FRAME_LAST_NUM_POINTS ) then
					-- Fade in the highlight and set a function that triggers when it is done fading
					fadeInfo.mode = "IN";
					fadeInfo.timeToFade = COMBOFRAME_HIGHLIGHT_FADE_IN;
					fadeInfo.finishedFunc = ComboPointShineFadeIn;
					fadeInfo.finishedArg1 = comboPointShine;
					UIFrameFade(comboPointHighlight, fadeInfo);
				end
			else
				if ( CVarCallbackRegistry:GetCVarValueBool("colorblindMode") ) then
					comboPoint:Hide();
				end
				comboPointHighlight:SetAlpha(0);
				comboPointShine:SetAlpha(0);
			end
			if ( i >= self.extraComboPoints ) then
				-- Only show the last 3 combo points (from the talent) if you have the combo point
				comboPoint:SetShown( comboPoints >= i );
			else
				comboPoint:Show();
			end
			comboIndex = comboIndex + 1;
		end
	else
		self.ComboPoints[1].Highlight:SetAlpha(0);
		self.ComboPoints[1].Shine:SetAlpha(0);
		self:Hide();
	end
	COMBO_FRAME_LAST_NUM_POINTS = comboPoints;
end

function ComboPointShineFadeIn(frame)
	-- Fade in the shine and then fade it out with the ComboPointShineFadeOut function
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = COMBOFRAME_SHINE_FADE_IN;
	fadeInfo.finishedFunc = ComboPointShineFadeOut;
	fadeInfo.finishedArg1 = frame;
	UIFrameFade(frame, fadeInfo);
end

--hack since a frame can't have a reference to itself in it
function ComboPointShineFadeOut(frame)
	UIFrameFadeOut(frame, COMBOFRAME_SHINE_FADE_OUT);
end
