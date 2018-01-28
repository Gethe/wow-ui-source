RogueResourceOverlay = {};

function RogueResourceOverlay:OnLoad()
	self.class = "ROGUE";
	self.powerToken = "COMBO_POINTS";

	local toAlpha = 0.5;
	self.Fadein.AlphaAnim:SetToAlpha(toAlpha);
	for i = 1, #self.ComboPoints do
		self.ComboPoints[i].Fadein.AlphaAnim:SetToAlpha(toAlpha);
	end

	ClassResourceOverlay.OnLoad(self);
end

function RogueResourceOverlay:OnEvent(event, arg1, arg2)
	if (event == "PLAYER_REGEN_ENABLED") then
		local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints);
		if (comboPoints == 0) then
			-- Fade out background if no combo points and player went out of combat
			self:PlayFadeAnim(self, self.Background, false);
		end
	else
		ClassResourceOverlay.OnEvent(self, event, arg1, arg2);
	end
end

function RogueResourceOverlay:Setup()
	ClassResourceOverlay.Setup(self);
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
end

function RogueResourceOverlay:PlayFadeAnim(frame, texture, fadein)
	local alphaValue = texture:GetAlpha();
	frame.Fadein:Stop();
	frame.Fadeout:Stop();
	texture:SetAlpha(alphaValue);
	if (fadein and alphaValue < 1) then
		frame.Fadein.AlphaAnim:SetFromAlpha(alphaValue);
		frame.Fadein:Play();
	elseif (not fadein and alphaValue > 0) then
		frame.Fadeout.AlphaAnim:SetFromAlpha(alphaValue);
		frame.Fadeout:Play();
	end
end

function RogueResourceOverlay:UpdatePower()
	local comboPoints = UnitPower("player", Enum.PowerType.ComboPoints);
	for i = 1, min(comboPoints, #self.ComboPoints) do
		self:PlayFadeAnim(self.ComboPoints[i], self.ComboPoints[i].Point, true);
	end
	for i = comboPoints + 1, #self.ComboPoints do
		self:PlayFadeAnim(self.ComboPoints[i], self.ComboPoints[i].Point, false);
	end

	if (comboPoints > 0) then
		-- Fade in background when we gain any combo points
		self:PlayFadeAnim(self, self.Background, true);
	elseif (comboPoints == 0 and not UnitAffectingCombat("player")) then
		-- Fade out background if no combo points and not in combat
		self:PlayFadeAnim(self, self.Background, false);
	end
end
