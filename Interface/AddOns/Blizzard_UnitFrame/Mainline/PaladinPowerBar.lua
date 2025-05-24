HOLY_POWER_SPELL_READY = 3; -- Num power required to cast majority of holy power spells

PaladinPowerBar = {};

PaladinPowerBar.VisualState = {
	Inactive = 1,		-- No runes filled
	Active = 2,			-- Some runes filled
	SpellReady = 3,		-- Enough runes filled for holy spells
}

function PaladinPowerBar:OnLoad()
	self:ResetAllVisuals();

	-- Stash this for use in visual state changes later
	self.playReadyLoopFunc = GenerateClosure(self.PlayReadyLoopCallback, self);

	ClassResourceBarMixin.OnLoad(self);
end

function PaladinPowerBar:UpdatePower()
	if self.delayedUpdate then
		return;
	end
	local unit = self:GetUnit();
	local numHolyPower = UnitPower( unit, Enum.PowerType.HolyPower );
	local maxHolyPower = UnitPowerMax( unit, Enum.PowerType.HolyPower );

	local isSpellReady = numHolyPower >= HOLY_POWER_SPELL_READY;

	for i=1,maxHolyPower do
		local holyRune = self["rune"..i];
		local runeState = PaladinPowerBar.VisualState.Inactive;
		if i <= numHolyPower then
			runeState = isSpellReady and PaladinPowerBar.VisualState.SpellReady or PaladinPowerBar.VisualState.Active;
		end

		holyRune:SetVisualState(runeState);
	end

	local holderState = PaladinPowerBar.VisualState.Inactive;
	if numHolyPower > 0 then
		holderState = isSpellReady and PaladinPowerBar.VisualState.SpellReady or PaladinPowerBar.VisualState.Active;
	end

	self:UpdateVisualState(holderState, numHolyPower);
end

function PaladinPowerBar:GetVisualState()
	return self.visualState;
end

function PaladinPowerBar:UpdateVisualState(visualState, numHolyPower)
	-- If neither state or power have changed, nothing to do, early out
	if visualState == self.visualState and numHolyPower == self.lastPower then
		return;
	end

	local oldState = self.visualState;
	local oldPower = self.lastPower or 0;

	self.visualState = visualState;
	self.lastPower = numHolyPower;

	-- If state changed, start with a clean state by stopping & hiding everything
	if self.visualState ~= oldState then
		self:ResetAllVisuals();
	end

	if self.visualState == PaladinPowerBar.VisualState.Inactive then
		-- No rune change pulses while in depleted state, only visual is entering the state
		if self.visualState ~= oldState then
			self.depleteAnim:Restart();
		end
	elseif self.visualState == PaladinPowerBar.VisualState.Active then
		-- Pulse decrease anim if dropped down from SpellReady, or if power reduced while in active state
		if oldState == PaladinPowerBar.VisualState.SpellReady or numHolyPower < oldPower then
			self.ActiveTexture:SetAlpha(1);
			self.depleteAnim:Restart();
		--- Otherwise pulse activate for power increase or entering from inactive
		else
			self.activateAnim:Restart();
		end
	elseif self.visualState == PaladinPowerBar.VisualState.SpellReady then
		-- All transitions to, or power changes while in SpellReady restart the ready state visuals, so start there
		self.ActiveTexture:SetAlpha(1);
		self.readyAnim:Stop();
		self.readyLoopAnim:Stop();

		-- Pulse anims based on rune changes while in state, always end with transitioning to ReadyLoop
		if numHolyPower < oldPower then
			self.depleteAnim:SetScript("OnFinished", self.playReadyLoopFunc);
			self.depleteAnim:Restart();
		else
			self.readyAnim:SetScript("OnFinished", self.playReadyLoopFunc);
			self.readyAnim:Restart();
		end
	end
end

function PaladinPowerBar:ResetAllVisuals()
	self.activateAnim:Stop();
	self.readyAnim:Stop();
	self.readyLoopAnim:Stop();
	self.depleteAnim:Stop();

	self.ActiveTexture:SetAlpha(0);
	self.ThinGlow:SetAlpha(0);
	self.Glow:SetAlpha(0);
end

function PaladinPowerBar:PlayReadyLoopCallback(animGroup)
	-- Remove callback from animGroup as we may not always want that anim to trigger loop
	animGroup:SetScript("OnFinished", nil);
	if self:GetVisualState() == PaladinPowerBar.VisualState.SpellReady then
		self.readyLoopAnim:Restart();
	end
end



PaladinPowerBarRune = {};

function PaladinPowerBarRune:OnLoad()
	-- Set up all atlases based on which rune this is
	local baseAtlasName = "uf-holypower-rune"..self.runeNumber;

	if self.useBackground then
		self.Background:SetAtlas(baseAtlasName, TextureKitConstants.UseAtlasSize);
		self.Background:Show();
	else
		self.Background:Hide();
	end

	self.ActiveTexture:SetAtlas(baseAtlasName.."-active", TextureKitConstants.UseAtlasSize);
	self.Glow:SetAtlas(baseAtlasName.."-glow", TextureKitConstants.UseAtlasSize);
	self.Blur:SetAtlas(baseAtlasName.."-blur", TextureKitConstants.UseAtlasSize);

	self.FX:SetAtlas(baseAtlasName.."-fx", TextureKitConstants.UseAtlasSize);
	self.FX:ClearAllPoints();
	self.FX:SetPoint("CENTER", 0, self.fxOffsetY);

	self.DepleteFlipbook:SetAtlas("UF-HolyPower-DepleteRune"..self.runeNumber);
	self.DepleteFlipbook:SetSize(self.depleteFlipbookWidth, self.depleteFlipbookHeight);
	self.DepleteFlipbook:ClearAllPoints();
	self.DepleteFlipbook:SetPoint("CENTER", 0, self.depleteFlipbookOffsetY);

	self.readyLoopAnim:SetScript("OnFinished", GenerateClosure(self.PlayReadyLoop, self));

	local skipTransitionAnimation = true;
	self:SetVisualState(PaladinPowerBar.VisualState.Inactive, skipTransitionAnimation);
end

function PaladinPowerBarRune:GetVisualState()
	return self.visualState;
end

function PaladinPowerBarRune:SetVisualState(visualState, skipTransitionAnimation)
	local oldState = self.visualState;

	self.visualState = visualState;

	-- If state changed, start with a clean state by stopping & hiding everything
	if self.visualState ~= oldState then
		self:ResetAllVisuals();
	end

	if self.visualState == PaladinPowerBar.VisualState.Inactive then
		-- Avoid stomping any ongoing Deplete animation if we get duplicate Inactive updates, unless intentionally skipping anims
		if oldState ~= PaladinPowerBar.VisualState.Inactive or skipTransitionAnimation then
			if skipTransitionAnimation then
				self.DepleteFlipbook:SetAlpha(0);
				self.depleteAnim:Stop();
			elseif not self.depleteAnim:IsPlaying() then
				self.DepleteFlipbook:SetAlpha(1);
				self.depleteAnim:Restart();
			end
		end
	elseif self.visualState == PaladinPowerBar.VisualState.Active then
		if oldState == PaladinPowerBar.VisualState.Inactive and not skipTransitionAnimation then
			self.activateAnim:Restart();
		else
			self.ActiveTexture:SetAlpha(1);
		end
	elseif self.visualState == PaladinPowerBar.VisualState.SpellReady then
		self.ActiveTexture:SetAlpha(1);

		if not skipTransitionAnimation then
			self.readyLoopAnim:Stop();
			self.readyAnim:Restart();
		else
			self.readyAnim:Stop();
			self.readyLoopAnim:Play();
		end
	end
end

function PaladinPowerBarRune:ResetAllVisuals()
	self.activateAnim:Stop();
	self.readyAnim:Stop();
	self.readyLoopAnim:Stop();
	self.depleteAnim:Stop();

	self.ActiveTexture:SetAlpha(0);
	self.Glow:SetAlpha(0);
	self.FX:SetAlpha(0);
	self.Blur:SetAlpha(0);
	self.DepleteFlipbook:SetAlpha(0);
end

function PaladinPowerBarRune:PlayReadyLoop()
	if self:GetVisualState() == PaladinPowerBar.VisualState.SpellReady then
		self.readyLoopAnim:Restart();
	end
end