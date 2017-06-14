InsanityPowerBar = {};

function InsanityPowerBar:OnLoad()
	self.class = "PRIEST";
	self.spec = SPEC_PRIEST_SHADOW;
	self:SetPowerTokens("INSANITY");
	self.insane = false;
	self.fullTentacleWidth = select(2, GetAtlasInfo("Insanity-Tentacles"))

	ClassPowerBar.OnLoad(self);
end

function InsanityPowerBar:OnEvent(event, arg1, arg2)
	if (event == "UNIT_AURA") then
		local insane = IsInsane();
		if (insane and not self.insane) then
			-- Gained insanity
			self.InsanityOn.Anim:Play();
			self.DrippyPurpleMid.Anim:Play();
			self.DrippyPurpleLoop.Anim:Play();
			self.InsanitySpark.Anim:Play();
		elseif (not insane and self.insane) then
			-- Lost insanity
			self.InsanityOn.Fadeout:Play();
			self.DrippyPurpleMid.Fadeout:Play();
			self.DrippyPurpleLoop.Fadeout:Play();
			self.InsanitySpark.Fadeout:Play();
		end
		self.insane = insane;
	else
		ClassPowerBar.OnEvent(self, event, arg1, arg2);
	end
end

function InsanityPowerBar:Setup()
	local showBar = ClassPowerBar.Setup(self);
	if (showBar) then
		self:RegisterUnitEvent("UNIT_AURA", "player");
	end
end

function InsanityPowerBar:UpdatePower()
	if (self.insane) then
		local insanity = UnitPower("player", Enum.PowerType.Insanity);
		local tentacleWidth = 7 + insanity / 100 * PlayerFrameManaBar:GetWidth(); -- Tentacles start 7 pixels left of the insanity bar
		self.InsanityOn.Tentacles:SetWidth(tentacleWidth);
		self.InsanityOn.Tentacles:SetTexCoord(0, tentacleWidth / self.fullTentacleWidth, 0, 1);
	end
end
