local CASTBAR_STAGE_INVALID = -1;
local CASTBAR_STAGE_DURATION_INVALID = -1;

CASTING_BAR_TYPES = {
	applyingcrafting = { 
		filling = "ui-castingbar-filling-applyingcrafting",
		full = "ui-castingbar-full-applyingcrafting",
		glow = "ui-castingbar-full-glow-applyingcrafting",
		sparkFx = "CraftingGlow",
		finishAnim = "CraftingFinish",
	},
	applyingtalents = { 
		filling = "ui-castingbar-filling-applyingcrafting",
		full = "ui-castingbar-full-applyingcrafting",
		glow = "ui-castingbar-full-glow-applyingcrafting",
		sparkFx = "CraftingGlow",
	},
	standard = { 
		filling = "ui-castingbar-filling-standard",
		full = "ui-castingbar-full-standard",
		glow = "ui-castingbar-full-glow-standard",
		sparkFx = "StandardGlow",
		finishAnim = "StandardFinish",
	},
	empowered = { 
		filling = "",
		full = "",
		glow = "",
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
	self.StagePoints = {};
	self.StagePips = {};
	self.StageTiers = {};

	self:SetUnit(unit, showTradeSkills, showShield);

	self.showCastbar = true;

	local point, relativeTo, relativePoint, offsetX, offsetY = self.Spark:GetPoint(1);
	if ( point == "CENTER" ) then
		self.Spark.offsetY = offsetY;
	end
end

function CastingBarMixin:UpdateShownState(desiredShow)
	if self.isInEditMode then
		-- If we are in edit mode then override and just show
		self:StopFinishAnims();
		self:ApplyAlpha(1.0);
		self:Show();
		return;
	end

	if desiredShow ~= nil then
		self:SetShown(desiredShow);
		return;
	end

	self:SetShown(self.casting and self.showCastbar);
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

			local desiredShowFalse = false;
			self:UpdateShownState(desiredShowFalse);
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

function CastingBarAnim_OnFadeOutFinish(self)
	local castingBar = self:GetParent();
	castingBar:Hide();
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
			local desiredShowFalse = false;
			self:UpdateShownState(desiredShowFalse);
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

		self:UpdateShownState(self.showCastbar);
	elseif ( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP") then
		if ( not self:IsVisible() ) then
			local desiredShowFalse = false;
			self:UpdateShownState(desiredShowFalse);
		end
		if ( (self.casting and event == "UNIT_SPELLCAST_STOP" and select(2, ...) == self.castID) or
		     ((self.channeling or self.reverseChanneling) and (event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP")) ) then
			
			-- Cast info not available once stopped, so update bar based on cached barType
			local barTypeInfo = self:GetTypeInfo(self.barType);
			self:SetStatusBarTexture(barTypeInfo.full);

			if not self.reverseChanneling then
				self:HideSpark();
			end

			if ( self.Flash ) then
				self.Flash:SetAtlas(barTypeInfo.glow);
				self.Flash:SetAlpha(0.0);
				self.Flash:Show();
			end
			if not self.reverseChanneling and not self.channeling then
				self:SetValue(self.maxValue);
			end

			self:PlayFadeAnim();
			self:PlayFinishAnim();

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
				local desiredShowFalse = false;
				self:UpdateShownState(desiredShowFalse);
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
			local desiredShowFalse = false;
			self:UpdateShownState(desiredShowFalse);
			return;
		end

		local isChargeSpell = numStages > 0;

		if isChargeSpell then
			endTime = endTime + GetUnitEmpowerHoldAtMaxTime(self.unit);
		end
		
		self.maxValue = (endTime - startTime) / 1000;

		self.barType = self:GetEffectiveType(not isChargeSpell, notInterruptible, isTradeSkill, isChargeSpell);

		if isChargeSpell then
			self:SetColorFill(0, 0, 0, 0);
		else
			self:SetStatusBarTexture(self:GetTypeInfo(self.barType).filling);
		end

		self:ClearStages();
		
		if (isChargeSpell) then
			self.value = GetTime() - (startTime / 1000);
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

		self:UpdateShownState(self.showCastbar);

		-- AddStages after Show so that the layout is valid
		if (isChargeSpell) then
			self:AddStages(numStages);
		end
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_UPDATE" or event == "UNIT_SPELLCAST_EMPOWER_UPDATE" ) then
		if ( self:IsShown() ) then
			local name, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(unit);
			if ( not name or (not self.showTradeSkills and isTradeSkill)) then
				-- if there is no name, there is no bar
				local desiredShowFalse = false;
				self:UpdateShownState(desiredShowFalse);
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
				self:FinishSpell();
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
	self:PlayFinishAnim();
	
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
		self.Spark:SetAtlas("ui-castingbar-pip-red");
		self.Spark.offsetY = 0;
	elseif currentBarType == "empowered" then
		self.Spark:SetAtlas("ui-castingbar-empower-cursor");
		self.Spark.offsetY = 4;
	else
		self.Spark:SetAtlas("ui-castingbar-pip");
		self.Spark.offsetY = 0;
	end

	for barType, barTypeInfo in pairs(CASTING_BAR_TYPES) do
		local sparkFx = barTypeInfo.sparkFx and self[barTypeInfo.sparkFx];
		if sparkFx then
			sparkFx:SetShown(self.playCastFX and barType == currentBarType);
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
	
	if not self.playCastFX then
		return;
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
		elseif not self.isInEditMode then
			self.FadeOutAnim:Play();
		end
	end
end

function CastingBarMixin:PlayFinishAnim()
	if not self.playCastFX then
		return;
	end

	local barTypeInfo = self:GetTypeInfo(self.barType);

	local playFinish = not barTypeInfo.finishCondition or barTypeInfo.finishCondition(self);
	if playFinish then
		local finishAnim = barTypeInfo.finishAnim and self[barTypeInfo.finishAnim];
		if finishAnim then
			finishAnim:Play();
		end
	end

	if self.barType == "empowered" then
		for i = 1, self.CurrSpellStage do
			local stageTier = self.StageTiers[i];
			if stageTier and stageTier.FinishAnim then
				stageTier.FlashAnim:Stop();
				stageTier.FinishAnim:Play();
			end
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
		local desiredShowFalse = false;
		self:UpdateShownState(desiredShowFalse);
	end
end

function CastingBarMixin:SetAndUpdateShowCastbar(showCastbar)
	self.showCastbar = showCastbar;
	self:UpdateIsShown();
end

function CastingBarMixin:SetLook(look)
	if ( look == "CLASSIC" ) then
		self.playCastFX = true;
		self:SetWidth(208);
		self:SetHeight(11);
		-- bordershield
		self.BorderShield:ClearAllPoints();
		self.BorderShield:SetWidth(256);
		self.BorderShield:SetHeight(64);
		self.BorderShield:SetPoint("TOP", 0, 28);
		-- text
		self.Text:Show();
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
		-- drop shadow
		if self.DropShadow then
			self.DropShadow:Hide();
		end
	elseif ( look == "UNITFRAME" ) then
		self.playCastFX = false;
		self:SetWidth(150);
		self:SetHeight(10);
		-- bordershield
		self.BorderShield:ClearAllPoints();
		self.BorderShield:SetWidth(0);
		self.BorderShield:SetHeight(49);
		self.BorderShield:SetPoint("TOPLEFT", -28, 20);
		self.BorderShield:SetPoint("TOPRIGHT", 18, 20);
		-- text
		self.Text:Show();
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
		-- drop shadow
		if self.DropShadow then
			self.DropShadow:Hide();
		end
	elseif ( look == "OVERLAY" ) then
		self.playCastFX = true;
		self:SetWidth(208);
		self:SetHeight(11);
		-- bordershield
		self.BorderShield:ClearAllPoints();
		self.BorderShield:SetWidth(256);
		self.BorderShield:SetHeight(64);
		self.BorderShield:SetPoint("TOP", 0, 28);
		-- text
		self.Text:Show();
		self.Text:ClearAllPoints();
		self.Text:SetWidth(300);
		self.Text:SetHeight(20);
		self.Text:SetPoint("TOP", 0, 30);
		self.Text:SetFontObject("GameFontNormalLarge");
		-- text border
		if self.TextBorder then
			self.TextBorder:Hide();
		end
		-- icon
		self.Icon:Hide();
		-- drop shadow
		if self.DropShadow then
			self.DropShadow:Show();
		end
	end
end

function CastingBarMixin:AddStages(numStages)
	self.CurrSpellStage = CASTBAR_STAGE_INVALID;
	self.NumStages = numStages + 1;
	self.SpellID = spellID;
	local sumDuration = 0;
	self.StagePoints = {};
	self.StagePips = {};
	self.StageTiers = {};
	local hasFX = self.StandardFinish ~= nil;
	local stageMaxValue = self.maxValue * 1000;

	local getStageDuration = function(stage)
		if stage == self.NumStages then	
			return GetUnitEmpowerHoldAtMaxTime(self.unit);
		else
			return GetUnitEmpowerStageDuration(self.unit, stage-1);
		end
	end;

	local castBarLeft = self:GetLeft();
	local castBarRight = self:GetRight();
	local castBarWidth = castBarRight - castBarLeft;

	for i = 1,self.NumStages-1,1 do
		local duration = getStageDuration(i);
		if(duration > CASTBAR_STAGE_DURATION_INVALID) then
			sumDuration = sumDuration + duration;
			local portion = sumDuration / stageMaxValue;
			local offset = castBarWidth * portion;
			self.StagePoints[i] = sumDuration;

			local stagePipName = "StagePip" .. i;
			local stagePip = self[stagePipName];
			if not stagePip then
				stagePip = CreateFrame("FRAME", nil, self, hasFX and "CastingBarFrameStagePipFXTemplate" or "CastingBarFrameStagePipTemplate");
				self[stagePipName] = stagePip;
			end

			if stagePip then
				table.insert(self.StagePips, stagePip);
				stagePip:ClearAllPoints();
				stagePip:SetPoint("TOP", self, "TOPLEFT", offset, -1);
				stagePip:SetPoint("BOTTOM", self, "BOTTOMLEFT", offset, 1);
				stagePip:Show();
				stagePip.BasePip:SetShown(i ~= self.NumStages);
			end
		end
	end

	for i = 1,self.NumStages-1,1 do
		local chargeTierName = "ChargeTier" .. i;
		local chargeTier = self[chargeTierName];
		if not chargeTier then
			chargeTier = CreateFrame("FRAME", nil, self, "CastingBarFrameStageTierTemplate");
			self[chargeTierName] = chargeTier;
		end

		if chargeTier then
			local leftStagePip = self.StagePips[i];
			local rightStagePip = self.StagePips[i+1];

			if leftStagePip then
				chargeTier:SetPoint("TOPLEFT", leftStagePip, "TOP", 0, 0);
			end
			if rightStagePip then
				chargeTier:SetPoint("BOTTOMRIGHT", rightStagePip, "BOTTOM", 0, 0);
			else
				chargeTier:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 1);
			end

			local chargeTierLeft = chargeTier:GetLeft();
			local chargeTierRight = chargeTier:GetRight();

			local left = (chargeTierLeft - castBarLeft) / castBarWidth;
			local right = 1.0 - ((castBarRight - chargeTierRight) / castBarWidth);

			chargeTier.FlashAnim:Stop();
			chargeTier.FinishAnim:Stop();

			chargeTier.Normal:SetAtlas(("ui-castingbar-tier%d-empower"):format(i));
			chargeTier.Disabled:SetAtlas(("ui-castingbar-disabled-tier%d-empower"):format(i));
			chargeTier.Glow:SetAtlas(("ui-castingbar-glow-tier%d-empower"):format(i));

			chargeTier.Normal:SetTexCoord(left, right, 0, 1);
			chargeTier.Disabled:SetTexCoord(left, right, 0, 1);
			chargeTier.Glow:SetTexCoord(left, right, 0, 1);

			chargeTier.Normal:SetShown(false);
			chargeTier.Disabled:SetShown(true);
			chargeTier.Glow:SetAlpha(0);

			chargeTier:Show();
			table.insert(self.StageTiers, chargeTier);
		end
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
			if stagePip and stagePip.StageAnim then
				stagePip.StageAnim:Play();
			end
		end

		if self.playCastFX then
			if maxStage == self.NumStages - 1 then
				if self.StageFinish then
					self.StageFinish:Play();
				end
			elseif maxStage > 0 then
				if self.StageFlash then
					self.StageFlash:Play();
				end
			end
		end
		
		local chargeTierName = "ChargeTier" .. self.CurrSpellStage;
		local chargeTier = self[chargeTierName];
		if chargeTier then
			chargeTier.Normal:SetShown(true);
			chargeTier.Disabled:SetShown(false);
			chargeTier.FlashAnim:Play();
		end
	end
end

function CastingBarMixin:ClearStages()

	if self.ChargeGlow then
		self.ChargeGlow:SetShown(false);
	end
	if self.ChargeFlash then
		self.ChargeFlash:SetAlpha(0);
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

	for _, stageTier in pairs(self.StageTiers) do
		stageTier:Hide();
	end

	self.NumStages = 0;
	table.wipe(self.StagePoints);
	table.wipe(self.StageTiers);
end



PlayerCastingBarMixin = {};

function PlayerCastingBarMixin:OnLoad()
	local showTradeSkills = true;
	local showShieldNo = false;
	CastingBarMixin.OnLoad(self, "player", showTradeSkills, showShieldNo);
	self.Icon:Hide();
end

function PlayerCastingBarMixin:OnShow()
	CastingBarMixin.OnShow(self);
	UIParentManagedFrameMixin.OnShow(self); 
end

function PlayerCastingBarMixin:IsAttachedToPlayerFrame()
	return self.attachedToPlayerFrame;
end



-- Alternate Player Casting Bar for use over frames whose content triggers contextual player casts
OverlayPlayerCastingBarMixin = {};

function OverlayPlayerCastingBarMixin:OnLoad()
	local showTradeSkills = true;
	local showShieldNo = false;
	CastingBarMixin.OnLoad(self, "player", showTradeSkills, showShieldNo);
	self.Icon:Hide();
	self.showCastbar = false;
end

--[[
--	Call to use this casting bar over the specified frame INSTEAD of showing the default PlayerCastingBar.
--	Will display any currently active Player cast, and any future Player casts until EndReplacingPlayerBar is called.
--
--	overrideInfo:
--		overrideBarType = [CASTING_BAR_TYPES] -- Use a specific bar type rather than have it determined by the type of spell being cast, defines textures used (Default: nil)
--		overrideLook 	= ["CLASSIC", "UNIT", "OVERLAY"] -- Use a specific bar look, defines component sizing and anchoring (Default: "OVERLAY")
--		overrideAnchor 	= [AnchorUtilAnchorInstance] -- Specify a point to anchor the cast bar to, should be created via CreateAnchor (Default: Center of parentFrame)
--		hideBarText		= [BOOLEAN] -- Disable showing text on the cast bar (Default: false)
--]]
function OverlayPlayerCastingBarMixin:StartReplacingPlayerBarAt(parentFrame, overrideInfo)
	-- Disable real Player Cast Bar
	PlayerCastingBarFrame:SetAndUpdateShowCastbar(false);

	overrideInfo = overrideInfo or {};
	self.overrideBarType = overrideInfo.overrideBarType;

	self:SetParent(parentFrame);
	self:SetFrameLevel(parentFrame:GetFrameLevel() + 10);
	self:ClearAllPoints();

	if overrideInfo.overrideAnchor then
		overrideInfo.overrideAnchor:SetPoint(self);
	else
		self:SetPoint("CENTER", parentFrame);
	end

	-- Run through override look adjusting sizing and shown components
	local overrideLook = overrideInfo.overrideLook or "OVERLAY";
	self:SetLook(overrideLook);

	-- Hide text components if needed, avoid using Show/SetShown and overriding SetLook having already hidden either
	if overrideInfo.hideBarText then
		self.Text:Hide();
		self.TextBorder:Hide();
	end

	-- SetAndUpdateShowCastbar will show self on next Player Cast OR now if a Player Cast is active
	self:SetAndUpdateShowCastbar(true);
end

--[[
--	Call to resume using only the default PlayerCastingBar.
--	PlayerCastingBar will immediately pick up displaying any already-active Player casts.
--]]
function OverlayPlayerCastingBarMixin:EndReplacingPlayerBar()
	-- Hide self
	self:SetAndUpdateShowCastbar(false);
	self:SetParent(UIParent);
	self.overrideBarType = nil;

	-- Re-enable real Player Cast Bar
	PlayerCastingBarFrame:SetAndUpdateShowCastbar(true);
end

-- Override template mixin for overriden bar type
function OverlayPlayerCastingBarMixin:GetEffectiveType(isChannel, notInterruptible, isTradeSkill, isEmpowered)
	return self.overrideBarType or CastingBarMixin.GetEffectiveType(self, isChannel, notInterruptible, isTradeSkill, isEmpowered);
end

function OverlayPlayerCastingBarMixin:OnShow()
	CastingBarMixin.OnShow(self);
	EventRegistry:TriggerEvent("OverlayPlayerCastBar.OnShow");
end

function OverlayPlayerCastingBarMixin:OnHide()
	CastingBarMixin.OnHide(self);
	EventRegistry:TriggerEvent("OverlayPlayerCastBar.OnHide");
end