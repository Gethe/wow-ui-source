BuilderSpender = {};

function BuilderSpender:OnLoad()
	self.initialized = false;
end

function BuilderSpender:Initialize(textureInfo, unit, powerType)
	local _, height;
	if (textureInfo.atlas) then
		self.BarTexture:SetAtlas(textureInfo.atlas, false);
		_, _, height = GetAtlasInfo(textureInfo.atlas);
	else
		self.BarTexture:SetVertexColor(textureInfo.r, textureInfo.g, textureInfo.b);
		height = self.BarTexture:GetHeight();
	end
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
		self.GainGlowTexture:Hide();
		self.updatingGain = false;
	else
		local currValue = UnitPower(self.unit, self.powerType);
		-- If we have gained more power and are in the middle of this anim, match the
		-- right side of the glow bar to the right side of the power bar
		if ( currValue > self.newValue ) then
			self.newValue = currValue;
		end
		
		local timeElapsedPercent = timeElapsed / timeEnd;
		local currentValue = self.oldValue + (self.newValue - self.oldValue) * timeElapsedPercent;
		local leftPosition = currentValue / self.maxValue * self:GetParent():GetWidth();
		local width = (self.newValue - currentValue) / self.maxValue * self:GetWidth();
		-- Setting a texture's width to 0 causes it to be full size, so when the width gets too small just hide it
		if (width < 0.5) then
			self.GainGlowTexture:Hide();
			self.updatingGain = false;
			return;
		end
		local texMinX = currentValue / self.maxValue;
		local texMaxX = self.newValue / self.maxValue;
		
		self.GainGlowTexture:ClearAllPoints();
		self.GainGlowTexture:SetPoint("TOPLEFT", leftPosition, 0);
		self.GainGlowTexture:SetWidth(width);
		self.GainGlowTexture:SetTexCoord(texMinX, texMaxX, 0, 1);
	end
end

function BuilderSpender_OnUpdateFeedbackLoss(self)
	local timeGlowFade = 0.25;
	local timeBarFade = 0.4;
	local timeEnd = 0.6;
	local timeElapsed = GetTime() - self.animLossStartTime;
	
	if ( timeElapsed > timeEnd ) then
		self.LossGlowTexture:Hide();
		self.BarTexture:Hide();
		self.updatingLoss = false;
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

function BuilderSpender:StartFeedbackAnim(oldValue, newValue)
	if (not self.initialized) then
		return;
	end
	
	local showBuilderFeedback = GetCVarBool("showBuilderFeedback");
	local showSpenderFeedback = GetCVarBool("showSpenderFeedback");
	if ( not showBuilderFeedback and not showSpenderFeedback ) then
		return;
	end
	
	if ( newValue > oldValue and showBuilderFeedback ) then -- Gaining power
		self.GainGlowTexture:Show();
		self.GainGlowTexture:SetAlpha(0.75);
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
		
		glowTexture:ClearAllPoints();
		glowTexture:SetPoint("TOPLEFT", leftPosition, 0);
		glowTexture:SetWidth(width);
		glowTexture:SetTexCoord(texMinX, texMaxX, 0, 1);
		glowTexture:Show();
		glowTexture:SetAlpha(0);
		
		barTexture:ClearAllPoints();
		barTexture:SetPoint("TOPLEFT", leftPosition, 0);
		barTexture:SetWidth(width);
		barTexture:SetTexCoord(texMinX, texMaxX, 0, 1);
		barTexture:Show();
		barTexture:SetAlpha(1);
		
		self.updatingLoss = true;
		self:SetScript("OnUpdate", BuilderSpender_OnUpdateFeedback);
		self.animLossStartTime = GetTime();
	end
end
