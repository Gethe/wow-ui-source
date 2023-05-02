WarlockPowerBar = {};

function WarlockPowerBar:OnLoad()
	self:RegisterEvent("PLAYER_REGEN_ENABLED");
	self:RegisterEvent("PLAYER_REGEN_DISABLED");

	ClassResourceBarMixin.OnLoad(self);
end

function WarlockPowerBar:OnEvent(event, ...)
	if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
        -- Regen being enabled/disabled is one of the few ways UI is notified that player's combat state has changed
		self:UpdatePower();
    end

	ClassResourceBarMixin.OnEvent(self, event, ...);
end

function WarlockPowerBar:UpdatePower()
	local unit = self:GetUnit();
	local shardPower = self:UnitPower(unit);

	-- Bug ID: 496542: Destruction is supposed to show partial soulshards, but Affliction and Demonology should only show full ones.
	if GetSpecialization() ~= SPEC_WARLOCK_DESTRUCTION then
		shardPower = math.floor(shardPower);
	end

	local isInCombat = UnitAffectingCombat(unit);

	local showIsFullPower = false;
	-- Only use "full power" visuals while in combat
	if isInCombat then
		-- Unlike UnitPower, UnitPowerMax doesn't need to be processed by UnitPowerDisplayMod (ie it returns 5, not 50)
		local maxPower = UnitPowerMax(unit, self.powerType);
		showIsFullPower = shardPower >= maxPower;
	end

	for shard in self.classResourceButtonPool:EnumerateActive() do
		shard:Update(shardPower, showIsFullPower);
	end
end

function WarlockPowerBar:UnitPower(unit)
	local shardPower = UnitPower(unit, self.powerType, true);
	local shardModifier = UnitPowerDisplayMod(self.powerType);
	return (shardModifier ~= 0) and (shardPower / shardModifier) or 0;
end



WarlockShardMixin = {};

WarlockShardMixin.IncrementSettings = {
	[1] = { fillAtlas = "UF-SoulShard-Inc1", glowAtlas = "UF-SoulShard-Inc1Glow", fillYOffset = -5.5, glowYOffset = -5.5 },
	[2] = { fillAtlas = "UF-SoulShard-Inc2", glowAtlas = "UF-SoulShard-Inc2Glow", fillYOffset = -6.5, glowYOffset = -6.5 },
	[3] = { fillAtlas = "UF-SoulShard-Inc3", glowAtlas = "UF-SoulShard-Inc3Glow", fillYOffset = -6.5, glowYOffset = -6.5 },
	[4] = { fillAtlas = "UF-SoulShard-Inc4", glowAtlas = "UF-SoulShard-Inc4Glow", fillYOffset = -5.5, glowYOffset = -5.5 },
	[5] = { fillAtlas = "UF-SoulShard-Inc5", glowAtlas = "UF-SoulShard-Inc5Glow", fillYOffset = -5.5, glowYOffset = -5.5 },
	[6] = { fillAtlas = "UF-SoulShard-Inc6", glowAtlas = "UF-SoulShard-Inc6Glow", fillYOffset = -5.5, glowYOffset = -5.5 },
	[7] = { fillAtlas = "UF-SoulShard-Inc7", glowAtlas = "UF-SoulShard-Inc7Glow", fillYOffset = -5, glowYOffset = -3 },
	[8] = { fillAtlas = "UF-SoulShard-Inc8", glowAtlas = "UF-SoulShard-Inc8Glow", fillYOffset = -4.5, glowYOffset = -3 },
	[9] = { fillAtlas = "UF-SoulShard-Inc9", glowAtlas = "UF-SoulShard-Inc9Glow", fillYOffset = -4.5, glowYOffset = -3 },
}

function WarlockShardMixin:Setup()
	self.fillAmount = nil;
	self:ResetVisuals();
	self:Show();
end

function WarlockShardMixin.OnRelease(framePool, self)
	self:ResetVisuals();
	FramePool_HideAndClearAnchors(framePool, self);
end

function WarlockShardMixin:Update(powerAmount, isBarFull)
	local fillAmount = Saturate(powerAmount - (self.layoutIndex - 1));

	-- Cut fillAmount to the tenths place to get rid of any & all floating point nonsense
	-- The epsilon prevents precision issues where, for example, a powerAmount of 4.1 would result in a fill amount of 0 (apparently math.floor((4.1-4)*10) == 0)
	fillAmount = math.floor((fillAmount + MathUtil.Epsilon) * 10) / 10;

	if self.fillAmount == fillAmount then
		self:UpdateFullPowerVisuals(isBarFull);
		return;
	end

	local oldFillAmount = self.fillAmount or 0;
	self.fillAmount = fillAmount;

	self:ResetVisuals();

	if fillAmount <= 0 then -- Empty
		if oldFillAmount >= 0.7 then
			self.FB_DepleteC:Show();
			self.depleteAnimC:Restart();
		elseif oldFillAmount >= 0.4 then
			self.FB_DepleteB:Show();
			self.depleteAnimB:Restart();
		elseif oldFillAmount >= 0.1 then
			self.FB_DepleteA:Show();
			self.depleteAnimA:Restart();
		end
	elseif fillAmount >= 1 then -- Full
		if not isBarFull then
			self.Shard_Soul:Show();
			if oldFillAmount == 0 then
				self.emptyToFullAnim:Restart();
			else
				self.fillDoneAnim:Restart();
			end
		end
	else -- Increments
		local incrementIndex = fillAmount * 10;
		local incrementSettings = WarlockShardMixin.IncrementSettings[incrementIndex];
		self.FillIncrement.Fill:SetAtlas(incrementSettings.fillAtlas, TextureKitConstants.UseAtlasSize);
		self.FillIncrement.Fill:ClearAllPoints();
		self.FillIncrement.Fill:SetPoint("CENTER", 0, incrementSettings.fillYOffset);

		self.FillIncrement.Glow:SetAtlas(incrementSettings.glowAtlas, TextureKitConstants.UseAtlasSize);
		self.FillIncrement.Glow:ClearAllPoints();
		self.FillIncrement.Glow:SetPoint("CENTER", 0, incrementSettings.glowYOffset);

		self.FillIncrement:Show();
		self.FillIncrement.FillAnim:Restart();
	end

	if isBarFull then
		self:UpdateFullPowerVisuals(isBarFull);
	end
end

function WarlockShardMixin:UpdateFullPowerVisuals(isBarFull)
	if isBarFull and not self.readyLoopAnim:IsPlaying() then
		self.emptyToFullAnim:Stop();
		self.fillDoneAnim:Stop();
		self.Shard_Soul:Hide();
		self.Shard_Icon:SetAlpha(1);
		self.readyLoopAnim:Restart();
	elseif not isBarFull and self.readyLoopAnim:IsPlaying() then
		self.readyLoopAnim:Stop();
	end
end

function WarlockShardMixin:ResetVisuals()
	self.emptyToFullAnim:Stop();
	self.fillDoneAnim:Stop();
	self.readyLoopAnim:Stop();

	self.depleteAnimA:Stop();
	self.depleteAnimB:Stop();
	self.depleteAnimC:Stop();

	self.FillIncrement.FillAnim:Stop();
	self.FillIncrement:Hide();
	self.Shard_Icon:SetAlpha(0);

	for _, fxTexture in ipairs(self.fxTextures) do
		fxTexture:SetAlpha(0);
	end
	for _, fxFlipbook in ipairs(self.fxFlipBooks) do
		fxFlipbook:Hide();
	end
end