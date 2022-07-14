local CASTBAR_STAGE_INVALID = -1;
local CASTBAR_STAGE_DURATION_INVALID = -1;
CASTBAR_STAGE_WIDTH = 195;
CASTBAR_STAGE_MIN_OFFSET = CASTBAR_STAGE_WIDTH / -2;
CASTBAR_STAGE_MAX_OFFSET = CASTBAR_STAGE_WIDTH / 2;

CASTING_BAR_TYPES = {
	applyingcrafting = { 
		filling = "ui-castingbar-filling-applyingcrafting",
		full = "ui-castingbar-full-applyingcrafting",
		glow = "ui-castingbar-full-glow-applyingcrafting",
		sparkFx = "CraftingGlow",
		finishAnim = "CraftingFinish",
	},
	standard = { 
		filling = "ui-castingbar-filling-standard",
		full = "ui-castingbar-full-standard",
		glow = "ui-castingbar-full-glow-standard",
		sparkFx = "StandardGlow",
		finishAnim = "StandardFinish",
	},
	empowered = { 
		filling = "ui-castingbar-filling-empowered",
		full = "ui-castingbar-full-standard",
		glow = "ui-castingbar-full-glow-standard",
		finishAnim = "StandardFinish",
		-- For empowered, only play finish anim if at full power
		finishCondition = function (self) return self.CurrSpellStage == self.NumStages; end
	},
	channel = { 
		filling = "ui-castingbar-filling-channel",
		full = "ui-castingbar-full-channel",
		glow = "ui-castingbar-full-glow-channel",
		sparkFx = "ChannelShadow",
		finishAnim = "ChannelFinish",
	},
	uninterruptable = {
		filling = "ui-castingbar-uninterruptable",
		full = "ui-castingbar-uninterruptable",
		glow = "ui-castingbar-full-glow-standard",
	},
	interrupted = { 
		filling = "ui-castingbar-interrupted",
		full = "ui-castingbar-interrupted",
		glow = "ui-castingbar-full-glow-standard",
	},
};

CastingBarMixin = {};

function CastingBarMixin:OnLoad(unit, showTradeSkills, showShield)
	self:SetUnit(unit, showTradeSkills, showShield);

	self.showCastbar = true;

	local point, relativeTo, relativePoint, offsetX, offsetY = self.Spark:GetPoint(1);
	if ( point == "CENTER" ) then
		self.Spark.offsetY = offsetY;
	end
	
	self.StagePoints = {};
	self.StagePips = {};
end

-- Fades additional widgets along with the cast bar, in case these widgets are not parented or use ignoreParentAlpha
function CastingBarMixin:AddWidgetForFade(widget)
	if not self.additionalFadeWidgets then
		self.additionalFadeWidgets = {};
	end
	self.additionalFadeWidgets[widget] = true;
end

function CastingBarMixin:SetUnit(unit, showTradeSkills, showShield)
	if self.unit ~= unit then
		self.unit = unit;
		self.showTradeSkills = showTradeSkills;
		self.showShield = showShield;

		self.casting = nil;
		self.channeling = nil;
		self.reverseChanneling = nil;
		
		self:StopAnims();

		if unit then
			self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_START", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit);
			self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit);
			self:RegisterEvent("PLAYER_ENTERING_WORLD");

			self:OnEvent("PLAYER_ENTERING_WORLD")
		else
			self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED");
			self:UnregisterEvent("UNIT_SPELLCAST_DELAYED");
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START");
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
			self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
			self:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_START");
			self:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_UPDATE");
			self:UnregisterEvent("UNIT_SPELLCAST_EMPOWER_STOP");
			self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE");
			self:UnregisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE");
			self:UnregisterEvent("UNIT_SPELLCAST_START");
			self:UnregisterEvent("UNIT_SPELLCAST_STOP");
			self:UnregisterEvent("UNIT_SPELLCAST_FAILED");
			self:UnregisterEvent("PLAYER_ENTERING_WORLD");

			self:Hide();
		end
	end
end

function CastingBarMixin:OnShow()
	if ( self.unit ) then
		if ( self.casting ) then
			local _, _, _, startTime = UnitCastingInfo(self.unit);
			if ( startTime ) then
				self.value = (GetTime() - (startTime / 1000));
			end
		else
			local _, _, _, _, endTime = UnitChannelInfo(self.unit);
			if ( endTime ) then
				self.value = ((endTime / 1000) - GetTime());
			end
		end
	end
end

function CastingBarAnim_OnInterruptSparkAnimFinish(self)
	local castingBar = self:GetParent();
	castingBar:SetValue(castingBar.maxValue);
	castingBar:HideSpark();
end

function CastingBarMixin:GetEffectiveType(isChannel, notInterruptible, isTradeSkill, isEmpowered)
	if isTradeSkill then
		return "applyingcrafting";
	end
	if notInterruptible then
		return "uninterruptable";
	end
	if isChannel then
		return "channel";
	end
	if isEmpowered then
		return "empowered";
	end
	return "standard";
end

function CastingBarMixin:GetTypeInfo(barType)
	if not barType then
		barType = "standard";
	end
	return CASTING_BAR_TYPES[barType];
end

function CastingBarMixin:OnEvent(event, ...)
	local arg1 = ...;

	local unit = self.unit;
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local nameChannel = UnitChannelInfo(unit);
		local nameSpell = UnitCastingInfo(unit);
		if ( nameChannel ) then
			event = "UNIT_SPELLCAST_CHANNEL_START";
			arg1 = unit;
		elseif ( nameSpell ) then
			event = "UNIT_SPELLCAST_START";
			arg1 = unit;
		else
		    self:FinishSpell();
		end
	end

	if ( arg1 ~= unit ) then
		return;
	end

	if ( event == "UNIT_SPELLCAST_START" ) then
		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit);
		if ( not name or (not self.showTradeSkills and isTradeSkill)) then
			self:Hide();
			return;
		end

		self.barType = self:GetEffectiveType(false, notInterruptible, isTradeSkill, false);
		self:SetStatusBarTexture(self:GetTypeInfo(self.barType).filling);

		self:ClearStages();

		self:ShowSpark();

		self.value = (GetTime() - (startTime / 1000));
		self.maxValue = (endTime - startTime) / 1000;
		self:SetMinMaxValues(0, self.maxValue);
		self:SetValue(self.value);
		if ( self.Text ) then
			self.Text:SetText(text);
		end
		if ( self.Icon ) then
			self.Icon:SetTexture(texture);
			if ( self.iconWhenNoninterruptible ) then
				self.Icon:SetShown(not notInterruptible);
			end
		end
		self.casting = true;
		self.castID = castID;
		self.channeling = nil;
		self.reverseChanneling = nil;
		
		self:StopAnims();
		self:ApplyAlpha(1.0);

		if ( self.BorderShield ) then
			if ( self.showShield and notInterruptible ) then
				self.BorderShield:Show();
				if ( self.BarBorder ) then
					self.BarBorder:Hide();
				end
			else
				self.BorderShield:Hide();
				if ( self.BarBorder ) then
					self.BarBorder:Show();
				end
			end
		end
		if ( self.showCastbar ) then
			self:Show();
		end

	elseif ( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") then
		if ( not self:IsVisible() ) then
			self:Hide();
		end
		if ( (self.casting and event == "UNIT_SPELLCAST_STOP" and select(2, ...) == self.castID) or
		     ((self.channeling or self.reverseChanneling) and (event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP")) ) then
			
			-- Cast info not available once stopped, so update bar based on cached barType
			local barTypeInfo = self:GetTypeInfo(self.barType);
			self:SetStatusBarTexture(barTypeInfo.full);

			self:HideSpark();

			if ( self.Flash ) then
				self.Flash:SetAtlas(barTypeInfo.glow);
				self.Flash:SetAlpha(0.0);
				self.Flash:Show();
			end
			if not self.reverseChanneling and not self.channeling then
				self:SetValue(self.maxValue);
			end

			self:PlayFadeAnim();
			
			if (event ~= "UNIT_SPELLCAST_EMPOWER_STOP") then
				self:PlayFinishAnim();
			end

			if ( event == "UNIT_SPELLCAST_STOP" ) then
				self.casting = nil;
			else
				self.channeling = nil;
				if (self.reverseChanneling) then
					self.casting = nil;
				end
				self.reverseChanneling = nil;
			end
		end
	elseif ( event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" ) then
		if ( self:IsShown() and
		     (self.casting and select(2, ...) == self.castID) and (not self.FadeOutAnim or not self.FadeOutAnim:IsPlaying()) ) then

			self.barType = "interrupted"; -- failed and interrupted use same bar art
			self:SetStatusBarTexture(self:GetTypeInfo(self.barType).full);

			self:ShowSpark();

			if ( self.Text ) then
				if ( event == "UNIT_SPELLCAST_FAILED" ) then
					self.Text:SetText(FAILED);
				else
					self.Text:SetText(INTERRUPTED);
				end
			end
			
			self.casting = nil;
			self.channeling = nil;
			self.reverseChanneling = nil;

			self:PlayInterruptAnims();
		end
	elseif ( event == "UNIT_SPELLCAST_DELAYED" ) then
		if ( self:IsShown() ) then
			local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unit);
			if ( not name or (not self.showTradeSkills and isTradeSkill)) then
				-- if there is no name, there is no bar
				self:Hide();
				return;
			end
			self.value = (GetTime() - (startTime / 1000));
			self.maxValue = (endTime - startTime) / 1000;
			self:SetMinMaxValues(0, self.maxValue);
			if ( not self.casting ) then
				self.barType = self:GetEffectiveType(false, notInterruptible, isTradeSkill, false);
				self:SetStatusBarTexture(self:GetTypeInfo(self.barType).filling);
				self:ClearStages();
				self:ShowSpark();
				if ( self.Flash ) then
					self.Flash:SetAlpha(0.0);
					self.Flash:Hide();
				end
				self.casting = true;
				self.channeling = nil;
				self.reverseChanneling = nil;
				
				self:StopAnims();
			end
		end
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START" ) then
		local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible, spellID, _, numStages = UnitChannelInfo(unit);
		if ( not name or (not self.showTradeSkills and isTradeSkill)) then
			-- if there is no name, there is no bar
			self:Hide();
			return;
		end

		local isChargeSpell = numStages > 0;
		
		self.maxValue = (endTime - startTime) / 1000;

		self.barType = self:GetEffectiveType(not isChargeSpell, notInterruptible, isTradeSkill, isChargeSpell);
		self:SetStatusBarTexture(self:GetTypeInfo(self.barType).filling);

		self:ClearStages();
		
		if (isChargeSpell) then
			self:AddStages(numStages);

			self.value = (startTime / 1000) - GetTime();
			self:ShowSpark();
		else
			self.value = (endTime / 1000) - GetTime();
		end

		self:ShowSpark();

		self:SetMinMaxValues(0, self.maxValue);
		self:SetValue(self.value);
		if ( self.Text ) then
			self.Text:SetText(text);
		end
		if ( self.Icon ) then
			self.Icon:SetTexture(texture);
		end
		if (isChargeSpell) then
			self.reverseChanneling = true;
			self.casting = true;
			self.channeling = false;
		else
			self.reverseChanneling = nil;
			self.casting = nil;
			self.channeling = true;
		end
		
		self:StopAnims();
		self:ApplyAlpha(1.0);

		if ( self.BorderShield ) then
			if ( self.showShield and notInterruptible ) then
				self.BorderShield:Show();
				if ( self.BarBorder ) then
					self.BarBorder:Hide();
				end
			else
				self.BorderShield:Hide();
				if ( self.BarBorder ) then
					self.BarBorder:Show();
				end
			end
		end
		if ( self.showCastbar ) then
			self:Show();
		end
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_EMPOWER_UPDATE" ) then
		if ( self:IsShown() ) then
			local name, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit);
			if ( not name or (not self.showTradeSkills and isTradeSkill)) then
				-- if there is no name, there is no bar
				self:Hide();
				return;
			end
			self.value = ((endTime / 1000) - GetTime());
			self.maxValue = (endTime - startTime) / 1000;
			self:SetMinMaxValues(0, self.maxValue);
			self:SetValue(self.value);
		end
	elseif ( event == "UNIT_SPELLCAST_INTERRUPTIBLE" or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" ) then
		self:UpdateInterruptibleState(event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE");
	end
end

function CastingBarMixin:UpdateInterruptibleState(notInterruptible)
	if ( self.casting or self.channeling ) then
		local _, _, _, _, _, isTradeSkill = UnitCastingInfo(self.unit);
		self.barType = self:GetEffectiveType(false, notInterruptible, isTradeSkill, false);
		self:SetStatusBarTexture(self:GetTypeInfo(self.barType).filling);

		if ( self.BorderShield ) then
			if ( self.showShield and notInterruptible ) then
				self.BorderShield:Show();
				if ( self.BarBorder ) then
					self.BarBorder:Hide();
				end
			else
				self.BorderShield:Hide();
				if ( self.BarBorder ) then
					self.BarBorder:Show();
				end
			end
		end

		if ( self.Icon and self.iconWhenNoninterruptible ) then
			self.Icon:SetShown(not notInterruptible);
		end
	end
end

function CastingBarMixin:OnUpdate(elapsed)
	if ( self.casting or self.reverseChanneling) then
		self.value = self.value + elapsed;
		if(self.reverseChanneling and self.NumStages > 0) then
			self:UpdateStage();
		end
		if ( self.value >= self.maxValue ) then
			self:SetValue(self.maxValue);
			if (not self.reverseChanneling) then
				self:FinishSpell(self.Spark, self.Flash);
			else
				if self.FlashLoopingAnim and not self.FlashLoopingAnim:IsPlaying() then
					self.FlashLoopingAnim:Play();
					self.Flash:Show();
				end
			end
			self:HideSpark();
			return;
		end
		self:SetValue(self.value);
		if ( self.Flash ) then
			self.Flash:Hide();
		end
	elseif ( self.channeling ) then
		self.value = self.value - elapsed;
		if ( self.value <= 0 ) then
			self:FinishSpell();
			return;
		end
		self:SetValue(self.value);
		if ( self.Flash ) then
			self.Flash:Hide();
		end
	end

	if ( self.casting or self.reverseChanneling or self.channeling ) then
		if ( self.Spark ) then
			local sparkPosition = (self.value / self.maxValue) * self:GetWidth();
			self.Spark:SetPoint("CENTER", self, "LEFT", sparkPosition, self.Spark.offsetY or 0);
		end
	end
end

function CastingBarMixin:ApplyAlpha(alpha)
	self:SetAlpha(alpha);
	if self.additionalFadeWidgets then
		for widget in pairs(self.additionalFadeWidgets) do
			widget:SetAlpha(alpha);
		end
	end
end

function CastingBarMixin:FinishSpell()
	if self.maxValue and not self.reverseChanneling and not self.channeling then
		self:SetValue(self.maxValue);
	end
	local barTypeInfo = self:GetTypeInfo(self.barType);
	self:SetStatusBarTexture(barTypeInfo.full);

	self:HideSpark();

	if ( self.Flash ) then
		self.Flash:SetAtlas(barTypeInfo.glow);
		self.Flash:SetAlpha(0.0);
		self.Flash:Show();
	end
	
	self:PlayFadeAnim();
	
	if not self.reverseChanneling then
		self:PlayFinishAnim();
	end
	
	self.casting = nil;
	self.channeling = nil;
	self.reverseChanneling = nil;
end

function CastingBarMixin:ShowSpark()
	if ( self.Spark ) then
		self.Spark:Show();
	end

	local currentBarType = self.barType;

	if currentBarType == "interrupted" then
		self.Spark:SetAtlas("ui-castingbar-pip-2x_red");
	else
		self.Spark:SetAtlas("ui-castingbar-pip");
	end

	for barType, barTypeInfo in pairs(CASTING_BAR_TYPES) do
		local sparkFx = barTypeInfo.sparkFx and self[barTypeInfo.sparkFx];
		if sparkFx then
			sparkFx:SetShown(barType == currentBarType);
		end
	end
end

function CastingBarMixin:HideSpark()
	if ( self.Spark ) then
		self.Spark:Hide();
	end

	for barType, barTypeInfo in pairs(CASTING_BAR_TYPES) do
		local sparkFx = barTypeInfo.sparkFx and self[barTypeInfo.sparkFx];
		if sparkFx then
			sparkFx:Hide();
		end
	end
end

function CastingBarMixin:PlayInterruptAnims()
	if self.HoldFadeOutAnim then
		self.HoldFadeOutAnim:Play();
	end
	if self.InterruptShakeAnim and tonumber(GetCVar("ShakeStrengthUI")) > 0 then
		self.InterruptShakeAnim:Play();
	end
	if self.InterruptGlowAnim then
		self.InterruptGlowAnim:Play();
	end
	if self.InterruptSparkAnim then
		self.InterruptSparkAnim:Play();
	end
end

function CastingBarMixin:StopInterruptAnims()
	if self.HoldFadeOutAnim then
		self.HoldFadeOutAnim:Stop();
	end
	if self.InterruptShakeAnim then
		self.InterruptShakeAnim:Stop();
	end
	if self.InterruptGlowAnim then
		self.InterruptGlowAnim:Stop();
	end
	if self.InterruptSparkAnim then
		self.InterruptSparkAnim:Stop();
	end
end

function CastingBarMixin:PlayFadeAnim()
	if self.FlashLoopingAnim then
		self.FlashLoopingAnim:Stop();
	end

	if self.FlashAnim then
		self.FlashAnim:Play();
	end

	if self.FadeOutAnim and self:GetAlpha() > 0 and self:IsVisible() then
		if self.reverseChanneling and self.CurrSpellStage < self.NumStages then
			self.HoldFadeOutAnim:Play();
		else
			self.FadeOutAnim:Play();
		end
	end
end
	
function CastingBarMixin:PlayFinishAnim()
	local barTypeInfo = self:GetTypeInfo(self.barType);

	local playFinish = not barTypeInfo.finishCondition or barTypeInfo.finishCondition(self);
	if playFinish then
		local finishAnim = barTypeInfo.finishAnim and self[barTypeInfo.finishAnim];
		if finishAnim then
			finishAnim:Play();
		end
	end
end

function CastingBarMixin:StopFinishAnims()
	if self.FlashAnim then
		self.FlashAnim:Stop();
	end
	if self.FadeOutAnim then
		self.FadeOutAnim:Stop();
	end

	for _, barTypeInfo in pairs(CASTING_BAR_TYPES) do
		local finishAnim = barTypeInfo.finishAnim and self[barTypeInfo.finishAnim];
		if finishAnim then
			finishAnim:Stop();
		end
	end
end

function CastingBarMixin:StopAnims()
	self:StopInterruptAnims();
	self:StopFinishAnims();
end

function CastingBarMixin:UpdateIsShown()
	if ( self.casting and self.showCastbar ) then
		self:OnEvent("PLAYER_ENTERING_WORLD")
	else
		self:Hide();
	end
end

function CastingBarMixin:SetLook(look)
	if ( look == "CLASSIC" ) then
		self:SetWidth(209);
		self:SetHeight(11);
		-- border
		self.Border:ClearAllPoints();
		self.Border:SetAllPoints();
		-- bordershield
		self.BorderShield:ClearAllPoints();
		self.BorderShield:SetWidth(256);
		self.BorderShield:SetHeight(64);
		self.BorderShield:SetPoint("TOP", 0, 28);
		-- text
		self.Text:ClearAllPoints();
		self.Text:SetWidth(185);
		self.Text:SetHeight(16);
		self.Text:SetPoint("TOP", 0, -10);
		self.Text:SetFontObject("GameFontHighlightSmall");
		-- text border
		if self.TextBorder then
			self.TextBorder:Show();
		end
		-- icon
		self.Icon:Hide();
		-- bar spark
		self.Spark.offsetY = 0;
		-- bar flash
		self.Flash:ClearAllPoints();
		self.Flash:SetAllPoints();
		self.Flash:SetPoint("TOP", 0, 2);
	elseif ( look == "UNITFRAME" ) then
		self:SetWidth(150);
		self:SetHeight(10);
		-- border
		self.Border:ClearAllPoints();
		self.Border:SetAllPoints();
		-- bordershield
		self.BorderShield:ClearAllPoints();
		self.BorderShield:SetWidth(0);
		self.BorderShield:SetHeight(49);
		self.BorderShield:SetPoint("TOPLEFT", -28, 20);
		self.BorderShield:SetPoint("TOPRIGHT", 18, 20);
		-- text
		self.Text:ClearAllPoints();
		self.Text:SetWidth(0);
		self.Text:SetHeight(16);
		self.Text:SetPoint("TOPLEFT", 0, 3);
		self.Text:SetPoint("TOPRIGHT", 0, 3);
		self.Text:SetFontObject("SystemFont_Shadow_Small");
		-- text border
		if self.TextBorder then
			self.TextBorder:Hide();
		end
		-- icon
		self.Icon:Show();
		-- bar spark
		self.Spark.offsetY = 0;
		-- bar flash
		self.Flash:ClearAllPoints();
		self.Flash:SetAllPoints();
	end
end

function CastingBarMixin:AddStages(numStages)
	self.CurrSpellStage = CASTBAR_STAGE_INVALID;
	self.NumStages = numStages;
	self.SpellID = spellID;
	local sumDuration = 0;
	self.StagePoints = {};
	self.StagePips = {};
	local hasFX = self.StandardFinish ~= nil;
	local stageMaxValue = self.maxValue * 1000;
	for i = 1,self.NumStages,1 do
		local duration = GetEmpowerStageDuration(i-1);
		if(duration > CASTBAR_STAGE_DURATION_INVALID) then
			sumDuration = sumDuration + duration;
			local portion = sumDuration / stageMaxValue;
			local offset = (CASTBAR_STAGE_WIDTH * portion) + CASTBAR_STAGE_MIN_OFFSET;
			self.StagePoints[i] = sumDuration;
			if(offset > CASTBAR_STAGE_MIN_OFFSET and offset <= CASTBAR_STAGE_MAX_OFFSET) then
				local stagePipName = "StagePip" .. i;
				local stagePip = self[stagePipName];
				if not stagePip then
					stagePip = CreateFrame("FRAME", nil, self, hasFX and "CastingBarFrameStagePipFXTemplate" or "CastingBarFrameStagePipTemplate");
					self[stagePipName] = stagePip;
				end

				if stagePip then
					table.insert(self.StagePips, stagePip);
					stagePip:SetPoint("TOP", offset, 0.5);
					stagePip:SetPoint("BOTTOM", offset, 0);
					if i == self.NumStages then
						stagePip:SetPoint("RIGHT", 0, 0);
					end
					stagePip:Show();
					stagePip.BasePip:SetShown(i ~= self.NumStages);
					stagePip.BasePipGlow:Hide();
				end
			end
		end
	end

	if self.ChargeBackground then
		local showChargeBackground = self.NumStages > 0 and self.StagePip1;

		self.ChargeBackground:SetShown(showChargeBackground);

		if showChargeBackground then
			self.ChargeBackground:SetTexCoord(0, 1 / numStages, 0, 1);
			self.ChargeBackground:SetPoint("RIGHT", self.StagePip1, "CENTER", 0, 0);
		end
	end

	if self.ChargeFull then
		self.ChargeFull:SetShown(false);
	end
end

function CastingBarMixin:UpdateStage()
	local maxStage = 0;
	local stageValue = self.value*1000;
	for i = 1, self.NumStages do
		if self.StagePoints[i] then
			if stageValue > self.StagePoints[i] then
				maxStage = i;
			else
				break;
			end
		end
	end

	if (maxStage ~= self.CurrSpellStage and maxStage > CASTBAR_STAGE_INVALID and maxStage <= self.NumStages) then
		self.CurrSpellStage = maxStage;
		if maxStage < self.NumStages then
			local stagePip = self.StagePips[maxStage];
			if stagePip then
				stagePip.BasePipGlow:SetShown(maxStage < self.NumStages);

				for i = 1, maxStage do
					local stageAnimName = "Stage" .. i;
					local stageAnim = stagePip[stageAnimName];
					if stageAnim then
						stageAnim:Play();
					end
				end
			end
		end
		if maxStage == self.NumStages then
			self:PlayFinishAnim();
		end

		if self.ChargeGlow then
			self.ChargeGlow:SetShown(maxStage == self.NumStages);
		end

		if self.ChargeFull then
			self.ChargeFull:SetShown(maxStage > 0);

			local stagePip = self["StagePip" .. maxStage];

			if maxStage == self.NumStages then
				self.ChargeFull:SetPoint("RIGHT", self, "RIGHT", 0, 0);
			elseif stagePip then
				self.ChargeFull:SetPoint("RIGHT", stagePip, "CENTER", 0, 0);
			end

			self.ChargeFull:SetTexCoord(0, self.ChargeFull:GetWidth() / self:GetWidth(), 0, 1);
		end

		if self.ChargeBackground then
			local nextStagePip = self["StagePip" .. maxStage + 1];
			
			if (maxStage + 1) == self.NumStages then
				self.ChargeBackground:SetPoint("RIGHT", self, "RIGHT", 0, 0);
			elseif nextStagePip then
				self.ChargeBackground:SetPoint("RIGHT", nextStagePip, "CENTER", 0, 0);
			end

			self.ChargeBackground:SetTexCoord(0, self.ChargeBackground:GetWidth() / self:GetWidth(), 0, 1);
		end
	end
end

function CastingBarMixin:ClearStages()
	if self.ChargeBackground then
		self.ChargeBackground:SetShown(false);
	end

	if self.ChargeFull then
		self.ChargeFull:SetShown(false);
	end

	if self.ChargeGlow then
		self.ChargeGlow:SetShown(false);
	end

	for _, stagePip in pairs(self.StagePips) do
		local maxStage = self.NumStages;
		for i = 1, maxStage do
			local stageAnimName = "Stage" .. i;
			local stageAnim = stagePip[stageAnimName];
			if stageAnim then
				stageAnim:Stop();
			end
		end
		stagePip:Hide();
	end
	self.NumStages = 0;
	table.wipe(self.StagePoints);
end
