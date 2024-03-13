LowHealthFrameMixin = {};

LOW_HEALTH_FRAME_STATE_DISABLED = 0;
LOW_HEALTH_FRAME_STATE_FULLSCREEN = 1;
LOW_HEALTH_FRAME_STATE_LOW_HEALTH = 2;

function LowHealthFrameMixin:OnLoad()
	self.inCombat = false;

	self.lowHealthPercentStart = .35;

	self.fullscreenMaxAlpha = .75;
	self.fullscreenMinAlpha = .2;

	self.lowHealthMaxAlpha = 1.0;
	self.lowHealthMinAlpha = .15;
	self.lowHealthReducedMaxAlpha = 0.5;
	self.lowHealthReducedMinAlpha = .15;
	
	self:EvaluateVisibleState();
	
	self:RegisterEvent("PLAYER_REGEN_DISABLED");
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("CVAR_UPDATE");
end

function LowHealthFrameMixin:OnEvent(event, ...)
	local arg1 = ...;
	if event == "PLAYER_REGEN_DISABLED" then
		self:SetInCombat(true);
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:SetInCombat(false);
	elseif event == "UNIT_MAXHEALTH" or event == "UNIT_HEALTH" then
		self:EvaluateVisibleState();
	elseif event == "PLAYER_ENTERING_WORLD" then
		self.playerEntered = true;
	elseif event == "VARIABLES_LOADED" then
		self:UnregisterEvent("VARIABLES_LOADED");
		self.varsLoaded = true;
		if not GetCVarBool("doNotFlashLowHealthWarning") then
			self:ListenForHealthEvents();
		end
	elseif event == "CVAR_UPDATE" then
		if arg1 == "doNotFlashLowHealthWarning" then
			if not GetCVarBool("doNotFlashLowHealthWarning") then
				self:ListenForHealthEvents();
			else
				self:StopListeningForHealthEvents();
			end
			self:EvaluateVisibleState();
		end
	end
	
	if event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" then
		if self.playerEntered and self.varsLoaded then
			self:EvaluateVisibleState();
		end
	end
end

function LowHealthFrameMixin:ListenForHealthEvents()
	self:RegisterUnitEvent("UNIT_MAXHEALTH", "player");
	self:RegisterUnitEvent("UNIT_HEALTH", "player");
end

function LowHealthFrameMixin:StopListeningForHealthEvents()
	self:UnregisterEvent("UNIT_MAXHEALTH");
	self:UnregisterEvent("UNIT_HEALTH");

end

function LowHealthFrameMixin:DetermineFlashState()
	if UnitIsGhost("player") or UnitIsDead("player") then
		return LOW_HEALTH_FRAME_STATE_DISABLED;
	end

	if ( CinematicFrame and CinematicFrame:IsShown() ) then
		return LOW_HEALTH_FRAME_STATE_DISABLED;
	end

	if ( MovieFrame and MovieFrame:IsShown() ) then
		return LOW_HEALTH_FRAME_STATE_DISABLED;
	end

	-- flash if we're in combat and can't see the world
	if self.inCombat then
		if GetCVarBool("screenEdgeFlash") and GetUIPanel("fullscreen") then
			return LOW_HEALTH_FRAME_STATE_FULLSCREEN;
		end
	end

	-- flash if our health is low
	if self:IsAtLowHealth() then
		if not GetCVarBool("doNotFlashLowHealthWarning") and not GetUIPanel("fullscreen") then
			return LOW_HEALTH_FRAME_STATE_LOW_HEALTH;
		end
	end

	return LOW_HEALTH_FRAME_STATE_DISABLED;
end

function LowHealthFrameMixin:GetHealthPercent()
	local maxHealth = UnitHealthMax("player");
	if maxHealth <= 0.0 then
		return 1.0;
	end
	return UnitHealth("player") / maxHealth;
end

function LowHealthFrameMixin:IsAtLowHealth()
	return self:GetHealthPercent() <= self.lowHealthPercentStart;
end

function LowHealthFrameMixin:EvaluateVisibleState()
	local healthState = self:DetermineFlashState();
	if healthState == LOW_HEALTH_FRAME_STATE_DISABLED then
		self.pulseAnim:Stop();
		self:Hide();
	elseif healthState == LOW_HEALTH_FRAME_STATE_FULLSCREEN or healthState == LOW_HEALTH_FRAME_STATE_LOW_HEALTH then
		-- update min and max alpha
		local newMinAlpha = self.fullscreenMinAlpha;
		local newMaxAlpha = self.fullscreenMaxAlpha;
		if healthState == LOW_HEALTH_FRAME_STATE_LOW_HEALTH then
			newMinAlpha = self.lowHealthMinAlpha;
			newMaxAlpha = self.lowHealthMaxAlpha;
		end
		
		if (not self:IsShown()) then
			local alphaAnim = self.pulseAnim.AlphaAnim;
			alphaAnim:SetFromAlpha(newMinAlpha);
			alphaAnim:SetToAlpha(newMaxAlpha);
		end
		
		-- check if the pulse animation is playing
		if not self.pulseAnim:IsPlaying() then
			self:Show();
			self.pulseAnim:Play();
			self.fadeStart = GetTime() + 2;
			self.fadeEnd = GetTime() + 3;
			self:SetScript("OnUpdate", LowHealth_OnUpdate);
		end
	else
		error("Unknown Low Health Frame State");
	end
end

function LowHealth_OnUpdate(self)
	local healthState = self:DetermineFlashState();
	if healthState == LOW_HEALTH_FRAME_STATE_DISABLED then
		self.pulseAnim:Stop();
		self:Hide();
		self:SetScript("OnUpdate", nil);
		return;
	end
	
	local now = GetTime();
	if (now > self.fadeEnd) then
		self:SetScript("OnUpdate", nil);
	elseif (now > self.fadeStart) then
		local alphaAnim = self.pulseAnim.AlphaAnim;
		local lerpAmount = (now - self.fadeStart) / (self.fadeEnd - self.fadeStart);
		alphaAnim:SetFromAlpha(Lerp(self.lowHealthMinAlpha, self.lowHealthReducedMinAlpha, lerpAmount));
		alphaAnim:SetToAlpha(Lerp(self.lowHealthMaxAlpha, self.lowHealthReducedMaxAlpha, lerpAmount));
	end
end

function LowHealthFrameMixin:SetInCombat(inCombat)
	if self.inCombat ~= inCombat then
		self.inCombat = inCombat;
		if ( self.inCombat ) then
			FlashClientIcon();
		end
		self:EvaluateVisibleState();
	end
end
