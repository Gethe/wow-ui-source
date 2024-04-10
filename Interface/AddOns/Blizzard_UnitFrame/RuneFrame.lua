RuneFrameMixin = {};

function RuneFrameMixin:OnLoad()
	-- Disable rune frame if not a death knight.
	local _, class = UnitClass("player");

	if ( class ~= "DEATHKNIGHT" ) then
		self:Hide();
		return;
	end

	self:RegisterEvent("RUNE_POWER_UPDATE");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:SetScript("OnEvent", self.OnEvent);

	self.runeIndices = {};
	for i = 1, #self.Runes do
		tinsert(self.runeIndices, i);
	end

	self.spentAnimsActive = 0;

	if (self.tooltipTitle and self.tooltip) then
		self:SetScript("OnEnter", self.OnEnter);
		self:SetScript("OnLeave", self.OnLeave);
	else
		self:SetScript("OnEnter", nil);
		self:SetScript("OnLeave", nil);
	end

	self.runeSortCompare = GenerateClosure(self.RuneButtonComparison, self);

	self:Layout();
end

function RuneFrameMixin:OnEvent(event, ...)
	if ( event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_ENTERING_WORLD" ) then
		self:UpdateRunes(true);
	elseif ( event == "RUNE_POWER_UPDATE") then
		self:UpdateRunes(false);
	end
end

function RuneFrameMixin:UpdateRunes(isSpecChange)
	local specIndex = GetSpecialization();

	local numNewlyDepletedRunes = 0;
	for i = 1, #self.Runes do
		local runeButton = self.Runes[i];

		if (isSpecChange) then
			runeButton:UpdateSpec(specIndex);
		end

		runeButton:UpdateState();

		-- We want to play deplete visuals on the position where a rune was when it got depleted, not necessarily on the depleted rune itself (as it may move)
		-- So count of newly depleted runes
		if runeButton.isNewlyDepleted then
			numNewlyDepletedRunes = numNewlyDepletedRunes + 1;
		end
	end

	-- Now that all visual states are updated, update sort order based on those visual states
	table.sort(self.runeIndices, self.runeSortCompare);

	local anyLayoutUpdates = false;
	for newLayoutIndex, runeIndex in ipairs(self.runeIndices) do
		local runeButton = self.Runes[runeIndex];
		if runeButton:UpdateLayoutIndex(newLayoutIndex) then
			anyLayoutUpdates = true;
		end

		-- Showing deplete visuals on ready runes looks bad, so rather than showing at exact previous index of depleted runes, depleted visuals start at leftmost non-ready rune
		if numNewlyDepletedRunes > 0 and runeButton.visualState ~= RuneButtonMixin.VisualState.Ready then
			runeButton:PlayDepleteVisuals();
			numNewlyDepletedRunes = numNewlyDepletedRunes - 1;
		end
	end

	if anyLayoutUpdates then
		self:Layout();
	end
end

function RuneFrameMixin:RuneButtonComparison(runeAIndex, runeBIndex)
	local runeAButton = self.Runes[runeAIndex];
	local runeBButton = self.Runes[runeBIndex];

	return RuneButtonMixin.CompareRuneButtons(runeAButton, runeBButton);
end

function RuneFrameMixin:OnEnter()
	local tooltip = GameTooltip;
	tooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	GameTooltip_SetTitle(tooltip, self.tooltipTitle);
	GameTooltip_AddNormalLine(tooltip, self.tooltip);
	tooltip:Show();
end

function RuneFrameMixin:OnLeave()
	GameTooltip_Hide();
end


local DefaultArtType = "Default";
local ArtTypeBySpec = {
	[1] = "Blood",
	[2] = "Frost",
	[3] = "Unholy",
};

local RuneArtSet = {
	cooldownSwipe = "UF-DKRunes-%s-LevelBar",
	runeAtlases = {
		{ region = "FB_RuneDeplete", atlas = "UF-DKRunes-%sDeplete", useAtlasSize = TextureKitConstants.IgnoreAtlasSize },
		{ region = "Rune_Grad", atlas = "UF-DKRunes-%s-SkullGrad", useAtlasSize = TextureKitConstants.UseAtlasSize },
		{ region = "Rune_Lines", atlas = "UF-DKRunes-%s-SkullLines", useAtlasSize = TextureKitConstants.UseAtlasSize },
		{ region = "Rune_Active", atlas = "UF-DKRunes-%s-SkullActive", useAtlasSize = TextureKitConstants.UseAtlasSize },
		{ region = "Rune_Mid", atlas = "UF-DKRunes-%s-SkullMid", useAtlasSize = TextureKitConstants.UseAtlasSize },
		{ region = "Rune_Eyes", atlas = "UF-DKRunes-%s-Eyes", useAtlasSize = TextureKitConstants.UseAtlasSize },
		{ region = "Glow", atlas = "UF-DKRunes-%s-FilledGlwA", useAtlasSize = TextureKitConstants.UseAtlasSize },
		{ region = "Glow2", atlas = "UF-DKRunes-%s-FilledGlwB", useAtlasSize = TextureKitConstants.UseAtlasSize },
		{ region = "Smoke", atlas = "UF-DKRunes-%s-Smoke", useAtlasSize = TextureKitConstants.UseAtlasSize },
	}
};

RuneButtonMixin = {};

-- Note: These int values affect sorting in CompareRuneButtons
RuneButtonMixin.VisualState = {
	Empty = 1,				-- Empty, cooldown hasn't started
	OnCooldown = 2,			-- Cooldown has started
	CooldownEnding = 3,		-- Cooldown is ending, not over
	Ready = 4,				-- Full, cooldown over
};

function RuneButtonMixin:OnLoad()
	-- CooldownFrame's OnUpdate only fires while actively tracking a cooldown, so dynamically setting/unsetting it is unneeded
	self.Cooldown:SetScript("OnUpdate", GenerateClosure(self.OnCooldownUpdate, self));
end

function RuneButtonMixin:UpdateSpec(specIndex)
	local specArtType = (specIndex ~= nil) and ArtTypeBySpec[specIndex] or nil;
	if specArtType == nil then
		-- If player hasn't chosen a Specialization yet, use Default rune set
		specArtType = DefaultArtType;
	end

	local cdSwipeAtlas = C_Texture.GetAtlasInfo(RuneArtSet.cooldownSwipe:format(specArtType));
	self.Cooldown:SetSwipeTexture(cdSwipeAtlas.file or cdSwipeAtlas.filename);
	-- CooldownFrame primarily works with Texture files, extra info required to make it work with a Texture Atlas
	local lowTexCoords = { x = cdSwipeAtlas.leftTexCoord, y = cdSwipeAtlas.topTexCoord };
	local highTexCoords = { x = cdSwipeAtlas.rightTexCoord, y = cdSwipeAtlas.bottomTexCoord };
	self.Cooldown:SetTexCoordRange(lowTexCoords, highTexCoords);

	for _, artInfo in ipairs(RuneArtSet.runeAtlases) do
		local region = self[artInfo.region];
		if region then
			region:SetAtlas(artInfo.atlas:format(specArtType), artInfo.useAtlasSize);
		end

		local depleteRegion = self.DepleteVisuals[artInfo.region];
		if depleteRegion then
			depleteRegion:SetAtlas(artInfo.atlas:format(specArtType), artInfo.useAtlasSize);
		end
	end
end

function RuneButtonMixin:UpdateState()
	local previousState = self.visualState;

	self.isNewlyDepleted = false;

	local start, duration, runeReady = GetRuneCooldown(self.runeIndex);
	self.lastRuneState = { start = start, duration = duration, runeReady = runeReady }

	if not runeReady then
		if start then
			self:ShowAsOnCooldown(start, duration, previousState);
		elseif previousState ~= RuneButtonMixin.VisualState.Empty then
			-- On cooldown with no start means just show as empty
			self:ShowAsEmpty();
		end
	else
		self:ShowAsReady(previousState);
	end
end

function RuneButtonMixin:PlayDepleteVisuals()
	self.DepleteVisuals.DepleteAnim:Restart();
end

function RuneButtonMixin:UpdateLayoutIndex(layoutIndex)
	if self.layoutIndex == layoutIndex then
		return false;
	end

	-- Deplete visuals are meant to be played on a specific layout position, so if our layout position is changing, stop it
	if self.DepleteVisuals.DepleteAnim:IsPlaying() then
		self.DepleteVisuals.DepleteAnim:Stop();
	end

	self.layoutIndex = layoutIndex;
	return true;
end

function RuneButtonMixin:ShowAsReady(previousState)
	if self.EmptyAnim:IsPlaying() then
		self:SkipToFinalAnimState(self.EmptyAnim);
	end
	
	if self.CooldownFillAnim:IsPlaying() then
		self:SkipToFinalAnimState(self.CooldownFillAnim);
	end

	-- CooldownEnding starts playing just before cooldown ends, so if already playing, let it continue
	-- Otherwise, skip straight to end state as we skipped straight to being ready
	if not self.CooldownEndingAnim:IsPlaying() and previousState ~= RuneButtonMixin.VisualState.Ready then
		self:SkipToFinalAnimState(self.CooldownEndingAnim);
	end

	self.visualState = RuneButtonMixin.VisualState.Ready;
	self.cooldownEndingStartTime = nil;
	self.Cooldown:Clear();
end

function RuneButtonMixin:ShowAsEmpty()
	if self.CooldownFillAnim:IsPlaying() then
		self:SkipToFinalAnimState(self.CooldownFillAnim);
	end
	if self.CooldownEndingAnim:IsPlaying() then
		self:SkipToFinalAnimState(self.CooldownEndingAnim);
	end
	if not self.EmptyAnim:IsPlaying() then
		self:SkipToFinalAnimState(self.EmptyAnim);
	end
	self.Cooldown:Clear();
	self.cooldownEndingStartTime = nil;
	self.visualState = RuneButtonMixin.VisualState.Empty;
	self.isNewlyDepleted = true;
end

function RuneButtonMixin:ShowAsOnCooldown(start, duration, previousState)
	-- Many time values are miliseconds off due to floating point issues, so using semi-generous epsilon for comparisons
	local timeEpsilon = 0.01;

	-- Avoid thrashing cooldown if already in the right cooldown state
	local oldStart, oldDuration = self.Cooldown:GetCooldownTimes();
	local oldEnd = (oldStart + oldDuration)/1000; -- GetCooldownTimes returns millisesconds, while SetCooldown takes seconds
	local newEnd = start + duration;
	if ApproximatelyEqual(oldEnd, newEnd, timeEpsilon) and self.CooldownFillAnim:IsPlaying() then
		return;
	end

	local timeNow = GetTime();
	local timeNowFloored = math.floor(timeNow);

	-- CooldownEndingAnim starts just before cooldown ends, calculate when that will be
	self.cooldownEndingStartTime = (start + duration) - self.cooldownEndingOffsetSeconds;
	local isBeforeCooldownEndStartTime = timeNowFloored < math.floor(self.cooldownEndingStartTime);

	if (previousState == nil) or (isBeforeCooldownEndStartTime and self.CooldownEndingAnim:IsPlaying()) then
		self:SkipToFinalAnimState(self.CooldownEndingAnim);
	end

	if (previousState == nil) or (previousState == RuneButtonMixin.VisualState.Ready) or (previousState == RuneButtonMixin.VisualState.CooldownEnding and isBeforeCooldownEndStartTime) then
		self.EmptyAnim:Restart();
		self.visualState = RuneButtonMixin.VisualState.Empty;
		self.isNewlyDepleted = true;
	end

	self.Cooldown:SetCooldown(start, duration);

	-- Only play Fill anim if cooldown has started and cooldownEndingAnim hasn't
	if isBeforeCooldownEndStartTime and timeNowFloored >= math.floor(start) then
		-- Fill anim was designed for a cooldown of X seconds, compensate for actual cooldown length
		local speedMultiplier = self.cooldownFillAnimBasisSeconds / duration;
		-- Offset anim time to match current progress through cooldown
		local startOffset = timeNow - start;

		local shouldRestartFillAnim = true;
		if self.CooldownFillAnim:IsPlaying() then
			-- Anim Restart is expensive, check current anim state & avoid if already at correct anim state
			local currentMultiplier = self.CooldownFillAnim:GetAnimationSpeedMultiplier();
			local currentElapsed = self.CooldownFillAnim:GetElapsed();
			if ApproximatelyEqual(currentMultiplier, speedMultiplier, timeEpsilon) and ApproximatelyEqual(currentElapsed, startOffset, timeEpsilon) then
				shouldRestartFillAnim = false;
			end
		end

		if shouldRestartFillAnim then
			self.CooldownFillAnim:SetAnimationSpeedMultiplier(speedMultiplier);
			local reverse = false;
			self.CooldownFillAnim:Restart(reverse, startOffset);
		end

		self.visualState = RuneButtonMixin.VisualState.OnCooldown;
	end
end

function RuneButtonMixin:OnCooldownUpdate()
	if not self.cooldownEndingStartTime then
		return;
	end

	local timeNow = GetTime();
	-- CooldownEndingAnim starts just before cooldown ends, if reached that time then get started
	if timeNow >= self.cooldownEndingStartTime then
		local animStartOffset = timeNow - self.cooldownEndingStartTime;

		self.CooldownFillAnim:Stop();

		local reverse = false;
		self.CooldownEndingAnim:Restart(reverse, animStartOffset);
		self.cooldownEndingStartTime = nil;
		self.visualState = RuneButtonMixin.VisualState.CooldownEnding;
	end
end

function RuneButtonMixin:SkipToFinalAnimState(animation)
	if animation then
		-- Fastforward animation straight to its end visual state
		local reverse = false;
		animation:Restart(reverse, animation:GetDuration());
	end
end

function RuneButtonMixin.CompareRuneButtons(runeAButton, runeBButton)
	local runeAState = runeAButton.visualState;
	local runeBState = runeBButton.visualState;

	if runeAState == nil or runeBState == nil then
		if runeAState == nil and runeBState == nil then
			return runeAButton.runeIndex > runeBButton.runeIndex;
		end
		return runeAState ~= nil;
	end

	if runeAState ~= runeBState then
		return runeAState > runeBState;
	end

	if runeAState == RuneButtonMixin.VisualState.Ready then
		local runeAPlayingEnd = runeAButton.CooldownEndingAnim:IsPlaying();
		local runeBPlayingEnd = runeBButton.CooldownEndingAnim:IsPlaying();
		if runeAPlayingEnd ~= runeBPlayingEnd then
			return not runeAPlayingEnd;
		end
		local runeAEndProgress = runeAButton.CooldownEndingAnim:GetProgress();
		local runeBEndProgress = runeBButton.CooldownEndingAnim:GetProgress();
		if (runeAEndProgress ~= runeBEndProgress) then
			return runeAEndProgress > runeBEndProgress;
		end
	end

	local runeAStart = runeAButton.lastRuneState.start;
	local runeBStart = runeBButton.lastRuneState.start;

	if (runeAStart ~= runeBStart) then
		return runeAStart < runeBStart;
	end

	return runeAButton.runeIndex > runeBButton.runeIndex;
end