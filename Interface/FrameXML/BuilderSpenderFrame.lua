BuilderSpender = {};

function BuilderSpender:OnLoad()
	self.initialized = false;
end

function BuilderSpender:Initialize(textureInfo, unit, powerType)
	if (textureInfo.atlas) then
		self.BarTexture:SetAtlas(textureInfo.atlas, false);
	else
		self.BarTexture:SetVertexColor(textureInfo.r, textureInfo.g, textureInfo.b);
	end
	local height = self:GetHeight();
	self.BarTexture:SetHeight(height);
	self.LossGlowTexture:SetHeight(height);
	self.GainGlowTexture:SetHeight(height);
	self.unit = unit;
	self.powerType = powerType;
	self.maxValue = UnitPowerMax(unit, powerType);
	self.initialized = true;
end

function BuilderSpender_OnUpdateFeedbackGain(self)
	local timeEnd = 0.5;
	local timeElapsed = GetTime() - self.animGainStartTime;
	
	if ( timeElapsed > timeEnd ) then
		self:EndFeedbackGain();
	else
		local currValue = UnitPower(self.unit, self.powerType);
		-- If we have gained more power and are in the middle of this anim, match the
		-- right side of the glow bar to the right side of the power bar
		if ( currValue > self.newValue ) then
			self.newValue = currValue;
		end
		
		local timeElapsedPercent = timeElapsed / timeEnd;
		local currentValue = self.oldValue + (self.newValue - self.oldValue) * timeElapsedPercent;
		
		local maxValue = self.maxValue;
		if maxValue <= 0 then
			maxValue = 1;
		end
		
		local leftPosition = currentValue / maxValue * self:GetParent():GetWidth();
		local width = (self.newValue - currentValue) / maxValue * self:GetWidth();
		-- Setting a texture's width to 0 causes it to be full size, so when the width gets too small just hide it
		if (width < 0.5) then
			self.GainGlowTexture:Hide();
			self.updatingGain = false;
			return;
		end
		local texMinX = Clamp(currentValue / maxValue, 0, 1.0);
		local texMaxX = Clamp(self.newValue / maxValue, 0, 1.0);

		self.GainGlowTexture:ClearAllPoints();
		self.GainGlowTexture:SetPoint("TOPLEFT", leftPosition, 0);
		self.GainGlowTexture:SetHeight(self:GetHeight());
		self.GainGlowTexture:SetWidth(width);
		self.GainGlowTexture:SetTexCoord(texMinX, texMaxX, 0, 1);
		self.GainGlowTexture:Show();
	end
end

function BuilderSpender_OnUpdateFeedbackLoss(self)
	local timeGlowFade = 0.25;
	local timeBarFade = 0.4;
	local timeEnd = 0.6;
	local timeElapsed = GetTime() - self.animLossStartTime;
	
	if ( timeElapsed > timeEnd ) then
		self:EndFeedbackLoss();
	else
		local timeElapsedPercent = timeElapsed / timeEnd;
		local glowAlpha, barAlpha;
		
		if ( timeElapsed < timeGlowFade ) then
			glowAlpha = Lerp(0, 0.75, timeElapsed / timeGlowFade);
		else
			glowAlpha = Lerp(0.75, 0, (timeElapsed - timeGlowFade) / (timeEnd - timeGlowFade));
		end
		self.LossGlowTexture:SetAlpha(glowAlpha);
		
		if ( timeElapsed < timeBarFade ) then
			barAlpha = 1;
		else
			barAlpha = Lerp(1, 0, (timeElapsed - timeBarFade) / (timeEnd - timeBarFade));
		end
		self.BarTexture:SetAlpha(barAlpha);
	end
end

function BuilderSpender_OnUpdateFeedback(self)
	if ( self.updatingGain ) then
		BuilderSpender_OnUpdateFeedbackGain(self)
	end
	if ( self.updatingLoss ) then
		BuilderSpender_OnUpdateFeedbackLoss(self);
	end
	if ( not self.updatingGain and not self.updatingLoss ) then
		self:SetScript("OnUpdate", nil);
	end
end

function BuilderSpender:EndFeedbackGain()
	self.GainGlowTexture:Hide();
	self.updatingGain = false;
end

function BuilderSpender:EndFeedbackLoss()
	self.LossGlowTexture:Hide();
	self.BarTexture:Hide();
	self.updatingLoss = false;
end

function BuilderSpender:StartFeedbackAnim(oldValue, newValue)
	if (not self.initialized) then
		return;
	end
	
	local showBuilderFeedback = GetCVarBool("showBuilderFeedback");
	local showSpenderFeedback = GetCVarBool("showSpenderFeedback");
	if ( not showBuilderFeedback and not showSpenderFeedback ) then
		return;
	end
	
	oldValue = Clamp(oldValue, 0, self.maxValue);

	newValue = math.max(newValue, 0);

	if ( newValue > oldValue and showBuilderFeedback ) then -- Gaining power
		self.updatingGain = true;
		self:SetScript("OnUpdate", BuilderSpender_OnUpdateFeedback);
	
		self.oldValue = oldValue;
		self.newValue = newValue;
		self.animGainStartTime = GetTime();
	elseif ( newValue < oldValue and showSpenderFeedback ) then -- Losing power
		local glowTexture = self.LossGlowTexture;
		local barTexture = self.BarTexture;
		local maxValue = self.maxValue;
		local leftPosition = newValue / maxValue * self:GetWidth();
		local width = (oldValue - newValue) / maxValue * self:GetWidth();
		local texMinX = newValue / maxValue;
		local texMaxX = oldValue / maxValue;

		local height = self:GetHeight();
		
		glowTexture:ClearAllPoints();
		glowTexture:SetPoint("TOPLEFT", leftPosition, 0);
		glowTexture:SetHeight(height);
		glowTexture:SetWidth(width);
		glowTexture:SetTexCoord(texMinX, texMaxX, 0, 1);
		glowTexture:Show();
		glowTexture:SetAlpha(0);
		
		barTexture:ClearAllPoints();
		barTexture:SetPoint("TOPLEFT", leftPosition, 0);
		barTexture:SetHeight(height);
		barTexture:SetWidth(width);
		barTexture:SetTexCoord(texMinX, texMaxX, 0, 1);
		barTexture:Show();
		barTexture:SetAlpha(1);
		
		self.updatingLoss = true;
		self:SetScript("OnUpdate", BuilderSpender_OnUpdateFeedback);
		self.animLossStartTime = GetTime();
	end
end

function BuilderSpender:StopFeedbackAnim()
	if self.updatingGain then
		self:EndFeedbackGain();
	elseif self.updatingLoss then
		self:EndFeedbackLoss();
	end
end

--
-- Full Resource Pulse
--

FullResourcePulse = {};

function FullResourcePulse:Initialize(active)
	self.active = active;
	if ( active ) then
		self:RegisterEvent("PLAYER_REGEN_ENABLED");
		self:SetScript("OnEvent", FullResourcePulse_OnEvent);
	else
		self:UnregisterEvent("PLAYER_REGEN_ENABLED");
		self:SetScript("OnEvent", nil);
	end
end

function FullResourcePulse:SetMaxValue(maxValue)
	self.maxValue = maxValue;
end

function FullResourcePulse_OnEvent(self, event)
	-- Fade out anims if they are playing and player goes out of combat
	if ( event == "PLAYER_REGEN_ENABLED" ) then
		if ( self.SpikeFrame.SpikeAnim:IsPlaying() or self.PulseFrame.PulseAnim:IsPlaying() ) then
			self.FadeoutAnim:Play();
		end
	end
end

function FullResourcePulse:StartAnimIfFull(oldValue, newValue)
	-- If going to max and in combat, show alert/pulse animations
	if ( newValue == self.maxValue and UnitAffectingCombat("player") ) then
		if ( self.FadeoutAnim:IsPlaying() or not self.PulseFrame.PulseAnim:IsPlaying() ) then
			self.SpikeFrame.SpikeAnim:Play();
		end
		self.FadeoutAnim:Stop();
		self:SetAlpha(1);
		self.PulseFrame.PulseAnim:Play();
	-- If going from max to less than max and anims are playing, fade out anims
	elseif ( oldValue == self.maxValue and (self.PulseFrame.PulseAnim:IsPlaying() or self.SpikeFrame.SpikeAnim:IsPlaying()) ) then
		self.FadeoutAnim:Play();
	end
end

function FullResourcePulse:RemoveAnims()
	self:SetAlpha(0);
	self.PulseFrame.PulseAnim:Stop();
	self.SpikeFrame.SpikeAnim:Stop();
end