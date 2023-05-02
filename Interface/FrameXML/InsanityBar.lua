InsanityPowerBar = {};

function InsanityPowerBar:OnLoad()
	self.class = "PRIEST";
	self.spec = SPEC_PRIEST_SHADOW;
	self:SetPowerTokens("INSANITY");
	self.insane = false;

	local info = C_Texture.GetAtlasInfo("Insanity-Tentacles");
	self.fullTentacleWidth = info and info.width or 1; -- Prevent divide by 0.

	ClassPowerBar.OnLoad(self);
end

function InsanityPowerBar:OnEvent(event, arg1, arg2)
	if (event == "UNIT_AURA") then
		local insane = IsInsane();

		if (insane and not self.insane) then
			-- Gained insanity	
			self:StopInsanityVisuals();

			self.InsanityOn.Anim:Play();
			self.DrippyPurpleMid.Anim:Play();
			self.DrippyPurpleLoop.Anim:Play();
			self.InsanitySpark.Anim:Play();
		elseif (not insane and self.insane) then
			-- Lost insanity
			self:StopInsanityVisuals();

			self.InsanityOn.Fadeout:Play();
			self.DrippyPurpleMid.Fadeout:Play();
			self.DrippyPurpleLoop.Fadeout:Play();
			self.InsanitySpark.Fadeout:Play();
		end
		self.insane = insane;
		self:UpdatePower();
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

function InsanityPowerBar:StopInsanityVisuals()
	self.InsanityOn.Anim:Stop();
	self.DrippyPurpleMid.Anim:Stop();
	self.DrippyPurpleLoop.Anim:Stop();
	self.InsanitySpark.Anim:Stop();

	self.InsanityOn.Fadeout:Stop();
	self.DrippyPurpleMid.Fadeout:Stop();
	self.DrippyPurpleLoop.Fadeout:Stop();
	self.InsanitySpark.Fadeout:Stop();			
end

function InsanityPowerBar:UpdatePower()
	if (self.insane) then
		local insanity = UnitPower("player", Enum.PowerType.Insanity);
		local maxInsanity = UnitPowerMax("player", Enum.PowerType.Insanity);
		local insanityPercent = maxInsanity > 0 and (insanity / maxInsanity) or 0;
		local powerBarWidth = PlayerFrame_GetManaBar():GetWidth();

		-- Tentacles start 7 pixels left of the power bar.
		-- Think this is to make the tentacles appear like they are wrapping around the bottom of the power bar and the right side of the portrait.
		local tentacleWidth = 7 + (insanityPercent * powerBarWidth);

		self.InsanityOn.Tentacles:SetWidth(tentacleWidth > 0 and tentacleWidth or 1);
		self.InsanityOn.Tentacles:SetTexCoord(0, tentacleWidth / self.fullTentacleWidth, 0, 1);

		-- Turn off spark drip when bar gets too short so drip doesn't look janky going onto the player portrait
		local showSparkDrip = tentacleWidth > 10;
		self.InsanitySpark.SparkDrip1:SetShown(showSparkDrip);
		self.InsanitySpark.SparkDrip2:SetShown(showSparkDrip);
	end
end
