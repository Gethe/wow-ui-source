CovenantRenownToastMixin = {};

function CovenantRenownToastMixin:OnLoad()
	self:RegisterEvent("COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED");
end

function CovenantRenownToastMixin:OnEvent(event, ...)
	if event == "COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED" then
		local newRenownLevel, oldRenownLevel = ...;
		if newRenownLevel > oldRenownLevel and newRenownLevel > 1 then
			self:ShowRenownLevelUpToast(C_Covenants.GetActiveCovenantID(), newRenownLevel);
		end
	end
end

function CovenantRenownToastMixin:OnHide()
	CovenantCelebrationBannerMixin.OnHide(self);

	TopBannerManager_BannerFinished();
end

function CovenantRenownToastMixin:AddSwirlEffects(covenantTextureKit) -- override
	local swirlEffects = CovenantChoiceToasts.GetSwirlEffectsByTextureKit(covenantTextureKit);
	for i, effect in ipairs(swirlEffects) do
		local effectDescription = { effectID = effect, soundEnabled = false, };
		self.IconSwirlModelScene:AddDynamicEffect(effectDescription, self);
	end
end

function CovenantRenownToastMixin:ShowRenownLevelUpToast(covenantID, renownLevel)
	local covenantData = C_Covenants.GetCovenantData(covenantID);
	if covenantData then
		if CovenantRenownFrame then
			HideUIPanel(CovenantRenownFrame);
		end
		TopBannerManager_Show(self, { 
			covenantID = covenantID,
			name = covenantData.name, 
			renownLevel = renownLevel,
			covenantColor = COVENANT_COLORS[covenantData.textureKit],
			textureKit = covenantData.textureKit,
		});
	end
end

function CovenantRenownToastMixin:SetupRewardVisuals(covenantID, renownLevel)
	local rewards = C_CovenantSanctumUI.GetRenownRewardsForLevel(covenantID, renownLevel);

	if #rewards > 0 then
		local primaryRewardInfo = rewards[1];
		local icon, name = RenownRewardUtil.GetUnformattedRenownRewardInfo(primaryRewardInfo, GenerateClosure(self.SetupRewardVisuals, self, covenantID, renownLevel))

		if icon then
			self.RewardIcon:SetTexture(icon);
			self.RewardIconMouseOver:Show();
			self.RewardIcon:Show();
			self.RewardIconRing:Show();
			self.RewardIcon:SetSize(52, 52);
		else
			self.RewardIconMouseOver:Hide();
			self.RewardIcon:Hide();
			self.RewardIcon:SetSize(1, 1);
			self.RewardIconRing:Hide();
		end

		local description = nil;
		for i, rewardInfo in ipairs(rewards) do
			if rewardInfo.toastDescription then
				if description then
					description = description .. "|n" .. rewardInfo.toastDescription;
				else
					description = rewardInfo.toastDescription;
				end
			end
		end

		self.RewardDescription:SetText(description);
	else
		self.RewardIconMouseOver:Hide();
		self.RewardIcon:Hide();
		self.RewardIcon:SetSize(1, 1);
		self.RewardIconRing:Hide();
		self.RewardDescription:SetText(nil);
	end
end

local SOUND_KIT_BY_TEXTURE_KIT = 
{
	Kyrian = { default = 172612, milestone = 172613, final = 172614, },
	Venthyr = { default = 172642, milestone = 172645, final = 172649, },
	NightFae = { default = 172643, milestone = 172646, final = 172650, },
	Necrolord = { default = 172644, milestone = 172648, final = 172651, },
};

function CovenantRenownToastMixin:PlayBanner(data)
	self.RenownLabel:SetFormattedText(COVENANT_RENOWN_LEVEL_TOAST, data.renownLevel);
	self.RenownLabel:SetTextColor(data.covenantColor:GetRGB());
	self:SetCovenantTextureKit(data.textureKit);

	local textureKitRegions = {
		[self.GlowLineTopBottom] = "CovenantChoice-Celebration-%sGlowLine",
	};

	SetupTextureKitOnFrames(data.textureKit, textureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);

	self.ToastBG:SetAlpha(0);
	self.GlowLineTop:SetAlpha(0);
	self.GlowLineTopAdditive:SetAlpha(0);
	self.Stars1:SetAlpha(0);
	self.Stars2:SetAlpha(0);
	self.IconSwirlModelScene:SetAlpha(0);
	self.Icon:SetAlpha(0);
	self.RenownLabel:SetAlpha(0);
	self.RewardIcon:SetAlpha(0);
	self.RewardIconRing:SetAlpha(0);
	self.RewardDescription:SetAlpha(0);

	self:SetupRewardVisuals(data.covenantID, data.renownLevel);

	local soundKitData = SOUND_KIT_BY_TEXTURE_KIT[data.textureKit]
	local levels = C_CovenantSanctumUI.GetRenownLevels(data.covenantID);
	local levelInfo = levels[data.renownLevel];
	local soundID = soundKitData.default;
	if data.renownLevel == #levels then
		soundID = soundKitData.final;
	elseif levelInfo.isMilestone then
		soundID = soundKitData.milestone;
	end
	PlaySound(soundID);

	self.bannerData = data;

	self:SetAlpha(1);
	self:Show();
	self.ShowAnim:Stop();
	self.ShowAnim:Play();
end

function CovenantRenownToastMixin:OnMouseEnter()
	GameTooltip:SetOwner(self.RewardIconMouseOver, "ANCHOR_NONE");
	GameTooltip:SetPoint("LEFT", self.RewardIconMouseOver, "RIGHT", 10, 0);
	self:RefreshTooltip();

	if self.ShowAnim.HoldAlpha:IsPlaying() then
		-- Holding already, just pause where we are
		self.ShowAnim.HoldAlpha:Pause();
	elseif self.ShowAnim.HoldAlpha:IsDone() then
		-- We're starting to fade out, reset alpha and hold
		self.ShowAnim.FadeAlpha:SetToAlpha(1);
		self.ShowAnim.FadeAlpha:Pause();
	else
		-- Still showing the fade-in, OnHoldAnimStarted will handle the transition
	end
end

function CovenantRenownToastMixin:OnMouseLeave()
	self.ShowAnim.FadeAlpha:SetToAlpha(0);
	self.ShowAnim:Stop();
	local isReversed = false;
	self.ShowAnim:Play(isReversed, 1.0);

	GameTooltip_Hide(self);
end

function CovenantRenownToastMixin:OnHoldAnimStarted()
	if GameTooltip:GetOwner() == self.RewardIconMouseOver then
		self.ShowAnim.HoldAlpha:Pause();
	end
end

function CovenantRenownToastMixin:RefreshTooltip()
	if GameTooltip:GetOwner() ~= self.RewardIconMouseOver then
		return;
	end

	local onItemUpdateCallback = GenerateClosure(self.RefreshTooltip, self);
	local rewards = C_CovenantSanctumUI.GetRenownRewardsForLevel(self.bannerData.covenantID, self.bannerData.renownLevel);
	local addRewards = true;
	if self.isCapstone then
		GameTooltip_SetTitle(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_TITLE);
		GameTooltip_AddNormalLine(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_DESC);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddHighlightLine(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_DESC2);
	else
		if #rewards == 1 then
			local icon, name, description = RenownRewardUtil.GetRenownRewardInfo(rewards[1], onItemUpdateCallback);
			GameTooltip_SetTitle(GameTooltip, name);
			GameTooltip_AddNormalLine(GameTooltip, description);
			addRewards = false;
		else
			GameTooltip_SetTitle(GameTooltip, RENOWN_REWARD_MILESTONE_TOOLTIP_TITLE:format(self.bannerData.renownLevel));
		end
	end
	if addRewards then
		for i, rewardInfo in ipairs(rewards) do
			local icon, name, description = RenownRewardUtil.GetRenownRewardInfo(rewardInfo, onItemUpdateCallback);
			if name then
				GameTooltip_AddNormalLine(GameTooltip, RENOWN_REWARD_TOOLTIP_REWARD_LINE:format(name));
			end
		end
	end
	GameTooltip:Show();
end

function CovenantRenownToastMixin:StopBanner()
	self.ShowAnim:Stop();
	self:Hide();
end

function CovenantRenownToastMixin:OnAnimFinished()
	self:Hide();
end
