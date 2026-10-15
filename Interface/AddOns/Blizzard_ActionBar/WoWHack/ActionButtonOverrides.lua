

BINDING_NAME_MULTIACTIONBAR5BUTTON1 = BINDING_NAME_WOWHACKULTIMATE;

local function IsWoWHackUltimateAction(action)
	return action and C_ActionBar.GetSpellTypeRestrictionForAction(action) == Enum.ActionBarSpellTypeRestriction.WoWHackUltimateActions;
end

local function StopUltimateReadyAnimations(ultimateDecoration)
	ultimateDecoration.IntroFrame.Anim:Stop();
	ultimateDecoration.IntroFrame:Hide();
	ultimateDecoration.ReadyLoopFrame.Anim:Stop();
	ultimateDecoration.ReadyLoopFrame:Hide();
end

local function StopUltimateUseAnimation(ultimateDecoration)
	ultimateDecoration.UseBurstFrame.Anim:Stop();
	ultimateDecoration.UseBurstFrame:Hide();
end

local function ResetUltimateAnimationState(ultimateDecoration)
	StopUltimateReadyAnimations(ultimateDecoration);
	StopUltimateUseAnimation(ultimateDecoration);
	ultimateDecoration.isReady = nil;
end

local function PlayUltimateReadyLoop(ultimateDecoration)
	StopUltimateReadyAnimations(ultimateDecoration);
	ultimateDecoration.ReadyLoopFrame:Show();
	ultimateDecoration.ReadyLoopFrame.Anim:Play();
end

local function PlayUltimateReadyIntro(ultimateDecoration)
	StopUltimateReadyAnimations(ultimateDecoration);
	ultimateDecoration.IntroFrame:Show();
	ultimateDecoration.IntroFrame.Anim:Play();
end

local function PlayUltimateUseAnimation(self)
	local ultimateDecoration = self.ultimateDecoration;
	if not ultimateDecoration or ultimateDecoration.UseBurstFrame.Anim:IsPlaying() then
		return;
	end

	StopUltimateReadyAnimations(ultimateDecoration);
	StopUltimateUseAnimation(ultimateDecoration);
	ultimateDecoration.UseBurstFrame:Show();
	ultimateDecoration.UseBurstFrame.Anim:Play();
end

local function InitializeUltimateDecoration(self)
	local ultimateDecoration = CreateFrame("Frame", nil, self, "WoWHackUltimateButtonDecorationTemplate");
	self.ultimateDecoration = ultimateDecoration;
	self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player");
	ultimateDecoration.owner = self;
	ultimateDecoration:SetFrameLevel(self:GetFrameLevel());
	ultimateDecoration:SetFrameStrata("LOW");
	ultimateDecoration.IntroFrame:SetFrameLevel(ultimateDecoration:GetFrameLevel());
	ultimateDecoration.ReadyLoopFrame:SetFrameLevel(ultimateDecoration:GetFrameLevel());
	ultimateDecoration.UseBurstFrame:SetFrameLevel(ultimateDecoration:GetFrameLevel() + 1);

	ultimateDecoration.IntroFrame.Anim:SetScript("OnFinished", function()
		ultimateDecoration.IntroFrame:Hide();
		if ultimateDecoration.isReady then
			PlayUltimateReadyLoop(ultimateDecoration);
		end
	end);

	ultimateDecoration.UseBurstFrame.Anim:SetScript("OnFinished", function()
		ultimateDecoration.UseBurstFrame:Hide();
		ultimateDecoration.owner:UpdateUltimateReadyState();
	end);

	ultimateDecoration:SetScript("OnHide", function()
		StopUltimateReadyAnimations(ultimateDecoration);
		StopUltimateUseAnimation(ultimateDecoration);
	end);

	ultimateDecoration:SetScript("OnShow", function()
		ultimateDecoration.owner:UpdateUltimateReadyState();
	end);
end

local function GetUltimateDecoration(self)
	if not self.ultimateDecoration then
		InitializeUltimateDecoration(self);
	end

	return self.ultimateDecoration;
end

local function InitializeWoWHackUltimateActionBar()
	if not C_GameRules.IsWoWHack() then
		return;
	end

	if MultiBar5 then
		MultiBar5.systemNameString = BINDING_NAME_WOWHACKULTIMATE;
		MultiBar5.addSystemIndexToName = false;
	end

	for index = 1, 1 do
		local button = _G["MultiBar5Button" .. index];
		if button and button.UpdateButtonArt then
			button:UpdateButtonArt();
			button:UpdateUltimateReadyState();
		end
	end
end

EventUtil.RegisterOnceFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
	InitializeWoWHackUltimateActionBar();
end);

function BaseActionButtonMixin:UpdateUltimateReadyState(isUsable, notEnoughMana)
	local ultimateDecoration = self.ultimateDecoration;
	if not ultimateDecoration then
		return;
	end

	if not IsWoWHackUltimateAction(self.action) then
		ResetUltimateAnimationState(ultimateDecoration);
		return;
	end

	if isUsable == nil or notEnoughMana == nil then
		isUsable, notEnoughMana = C_ActionBar.IsUsableAction(self.action);
	end

	local cooldownInfo = C_ActionBar.GetActionCooldown(self.action);
	local chargeInfo = C_ActionBar.GetActionCharges(self.action);
	local lossOfControlInfo = C_ActionBar.GetActionLossOfControlCooldownInfo(self.action);
	local hasCharge = not chargeInfo or chargeInfo.maxCharges == 0 or chargeInfo.currentCharges > 0;
	local isReady = isUsable and not notEnoughMana and hasCharge and not cooldownInfo.isActive and not lossOfControlInfo.isActive;
	ultimateDecoration.isReady = isReady;
	if ultimateDecoration.UseBurstFrame.Anim:IsPlaying() or not ultimateDecoration:IsVisible()  then
		StopUltimateReadyAnimations(ultimateDecoration);
		return;
	end

	if isReady then
		if not ultimateDecoration.IntroFrame.Anim:IsPlaying() and not ultimateDecoration.ReadyLoopFrame.Anim:IsPlaying() then
			PlayUltimateReadyIntro(ultimateDecoration);
		end
	else
		StopUltimateReadyAnimations(ultimateDecoration);
	end
end

local ULTIMATE_FRAME_SCALE = 1.2;
local ULTIMATE_FRAME_RING_SCALE = 1.3;

local function SetupUltimateButtonArt(self, parent)
	local ultimateDecoration = GetUltimateDecoration(self);

	self.SlotArt:SetAtlas("talebound-hud-actionbar-icon-ultimate", true);
	self.SlotArt:SetDesaturated(false);
	self.SlotArt:ClearAllPoints();
	self.SlotArt:SetPoint("CENTER", parent);
	self.SlotArt:SetScale(0.7);
	self.SlotArt:Show();

	self.SlotBackground:SetAtlas("talebound-hud-actionbar-iconframe-ultimate-bg", true);
	self.SlotBackground:ClearAllPoints();
	self.SlotBackground:SetPoint("CENTER", parent);
	self.SlotBackground:SetScale(0.7);
	self.SlotBackground:Show();

	self.IconMask:SetAtlas("talebound-hud-actionbar-iconframe-ultimate-mask", true);
	self.IconMask:ClearAllPoints();
	self.IconMask:SetPoint("CENTER", self.SlotBackground, "CENTER", 0, 0);
	self.IconMask:SetScale(0.7);

	-- Adjust the icon to be a bit out of frame by a few pixels
	self.icon:SetPoint("TOPLEFT", self, "TOPLEFT", -4, 6);
	self.icon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, -4);
	self.icon:SetDrawLayer("ARTWORK", 1.0);

	self:SetNormalAtlas("talebound-hud-actionbar-iconframe-ultimate");
	self.NormalTexture:SetDrawLayer("OVERLAY");
	self.NormalTexture:ClearAllPoints();
	self.NormalTexture:SetPoint("CENTER", parent);
	self.NormalTexture:SetScale(ULTIMATE_FRAME_SCALE);

	self:SetPushedAtlas("talebound-hud-actionbar-iconframe-ultimate-ready");
	self.PushedTexture:SetDrawLayer("OVERLAY");
	self.PushedTexture:ClearAllPoints();
	self.PushedTexture:SetPoint("CENTER", parent);
	self.PushedTexture:SetScale(ULTIMATE_FRAME_SCALE);

	self.HighlightTexture:SetAtlas("talebound-hud-actionbar-iconframe-ultimate-ready");
	self.HighlightTexture:ClearAllPoints();
	self.HighlightTexture:SetPoint("CENTER", parent);
	self.HighlightTexture:SetScale(ULTIMATE_FRAME_RING_SCALE);

	self.CheckedTexture:SetAtlas("talebound-hud-actionbar-iconframe-ultimate");
	self.CheckedTexture:ClearAllPoints();
	self.CheckedTexture:SetPoint("CENTER", parent);
	self.CheckedTexture:SetScale(ULTIMATE_FRAME_RING_SCALE);

	self.SpellHighlightTexture:SetAtlas("talebound-hud-actionbar-iconframe-ultimate-ready");
	self.SpellHighlightTexture:ClearAllPoints();
	self.SpellHighlightTexture:SetPoint("CENTER", parent);
	self.SpellHighlightTexture:SetScale(ULTIMATE_FRAME_RING_SCALE);
	
	self.QuickKeybindHighlightTexture:SetAtlas("talebound-hud-actionbar-iconframe-ultimate-ready");
	self.QuickKeybindHighlightTexture:ClearAllPoints();
	self.QuickKeybindHighlightTexture:SetPoint("CENTER", parent);
	self.QuickKeybindHighlightTexture:SetScale(ULTIMATE_FRAME_RING_SCALE);

	self.NewActionTexture:SetAtlas("talebound-hud-actionbar-iconframe-ultimate-ready");
	self.NewActionTexture:ClearAllPoints();
	self.NewActionTexture:SetPoint("CENTER", parent);
	self.NewActionTexture:SetScale(ULTIMATE_FRAME_RING_SCALE);

	ultimateDecoration.TreeTexture:Show();

	ultimateDecoration.TreeTopBranchesFrame:Show();

	self:UpdateUltimateReadyState();
end

local function ResetUltimateButtonArt(self)
	if self.IconMask then
		self.IconMask:SetAtlas("UI-HUD-ActionBar-IconFrame-Mask", true);
		self.IconMask:ClearAllPoints();
		self.IconMask:SetPoint("CENTER", self.icon, "CENTER");
	end
	self.SlotBackground:SetAtlas("UI-HUD-ActionBar-IconFrame-Background", true);
	self.SlotBackground:ClearAllPoints();
	self.SlotBackground:SetAllPoints(self);

	self.NormalTexture:ClearAllPoints();
	self.NormalTexture:SetPoint("TOPLEFT");
	self.PushedTexture:ClearAllPoints();
	self.PushedTexture:SetPoint("TOPLEFT");
	local ultimateDecoration = self.ultimateDecoration;
	if ultimateDecoration then
		ultimateDecoration.TreeTexture:Hide();
		ultimateDecoration.TreeTopBranchesFrame:Hide();
		ResetUltimateAnimationState(ultimateDecoration);
	end
end

function BaseActionButtonMixin:UpdateButtonArt()
	if (not self.SlotArt or not self.SlotBackground) then
		return;
	end

	local parent = self:GetParent();
	local spellTypeRestrictions = self.action and C_ActionBar.GetSpellTypeRestrictionForAction(self.action);
	ResetUltimateButtonArt(self);
	if (self.action) then
		if spellTypeRestrictions == Enum.ActionBarSpellTypeRestriction.WoWHackUltimateActions then
			SetupUltimateButtonArt(self, parent);
			return;
		elseif (spellTypeRestrictions == Enum.ActionBarSpellTypeRestriction.WoWHackOffensiveActions) then
			self.SlotArt:SetAtlas("talebound-hud-actionbar-icon-attack", true);
			self.SlotArt:SetScale(0.6);
		elseif (spellTypeRestrictions == Enum.ActionBarSpellTypeRestriction.WoWHackDefensiveActions) then
			self.SlotArt:SetAtlas("talebound-hud-actionbar-icon-defense", true);
		end

		if (spellTypeRestrictions ~= Enum.ActionBarSpellTypeRestriction.None) then
			self.icon:SetDrawLayer("BORDER");
			self.SlotArt:ClearAllPoints();
			self.SlotArt:SetPoint("CENTER", parent, "CENTER");
			self.SlotArt:Show();
			
			self.SlotBackground:ClearAllPoints();
			self.SlotBackground:SetAtlas("talebound-hud-actionbar-iconframe-bg", true);
			self.SlotBackground:SetPoint("TOPLEFT", parent, "TOPLEFT", -2, 1);
			self.SlotBackground:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 2, -1);
			self.SlotBackground:Show();

			self.IconMask:SetAtlas("talebound-hud-actionbar-iconframe-mask", true);
			self.IconMask:SetSize(40, 40);

			self:SetNormalAtlas("talebound-hud-actionbar-iconframe");
			self.NormalTexture:SetDrawLayer("OVERLAY");
			self.NormalTexture:SetSize(49, 49);
			self.NormalTexture:ClearAllPoints();
			self.NormalTexture:SetPoint("CENTER", parent, "CENTER");

			self.PushedTexture:SetSize(49, 49);
			self.PushedTexture:ClearAllPoints();
			self.PushedTexture:SetPoint("CENTER", parent, "CENTER", 3, -3);

			self.NewActionTexture:SetPoint("TOPLEFT", parent, "TOPLEFT");
			self.NewActionTexture:SetSize(46, 46);

			self.SpellHighlightTexture:SetSize(46, 45);
			self.QuickKeybindHighlightTexture:SetSize(46, 45);

			return;
		end
	end

	self.SlotArt:SetAtlas("ui-hud-actionbar-iconframe-slot");
	self.SlotArt:SetDesaturated(false);
	self.SlotArt:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0);
	self.SlotArt:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0);

	if (self.bar and not self.bar.hideBarArt) then
		self.SlotArt:Show();
		self.SlotBackground:Hide();

		self:SetNormalAtlas("UI-HUD-ActionBar-IconFrame");
		self.NormalTexture:SetDrawLayer("OVERLAY");
		self.NormalTexture:SetSize(46, 46);

		self:SetPushedAtlas("UI-HUD-ActionBar-IconFrame-Down");
		self.PushedTexture:SetDrawLayer("OVERLAY");
		self.PushedTexture:SetSize(46, 46);
	else
		self.SlotArt:Hide();
		self.SlotBackground:Show();

		self:SetNormalAtlas("UI-HUD-ActionBar-IconFrame-AddRow");
		self.NormalTexture:SetDrawLayer("OVERLAY");
		self.NormalTexture:SetSize(51, 51);

		self:SetPushedAtlas("UI-HUD-ActionBar-IconFrame-AddRow-Down");
		self.PushedTexture:SetDrawLayer("OVERLAY");
		self.PushedTexture:SetSize(51, 51);
	end
end

local actionButtonUpdateAction = ActionBarActionButtonMixin.UpdateAction;
function ActionBarActionButtonMixin:UpdateAction(force)
	actionButtonUpdateAction(self, force);
	if IsWoWHackUltimateAction(self.action) or self.ultimateDecoration then
		self:UpdateButtonArt();
		self:UpdateUltimateReadyState();
	end
end

local actionButtonOnEvent = ActionBarActionButtonMixin.OnEvent;
function ActionBarActionButtonMixin:OnEvent(event, ...)
	actionButtonOnEvent(self, event, ...);
	if not IsWoWHackUltimateAction(self.action) then
		return;
	end

	if event == "UNIT_SPELLCAST_SUCCEEDED" then
		local _, _, spellID = ...;
		local actionType, actionSpellID = GetActionInfo(self.action);
		if actionType == "spell" and actionSpellID == spellID then
			PlayUltimateUseAnimation(self);
		end
	elseif event == "SPELL_UPDATE_CHARGES" then
		self:UpdateUltimateReadyState();
	end
end

local actionButtonUpdateUsable = ActionBarActionButtonMixin.UpdateUsable;
function ActionBarActionButtonMixin:UpdateUsable(action, isUsable, notEnoughMana, isLevelLinkLocked)
	actionButtonUpdateUsable(self, action, isUsable, notEnoughMana, isLevelLinkLocked);
	if self.UpdateUltimateReadyState then
		self:UpdateUltimateReadyState(isUsable, notEnoughMana);
	end
end

local actionButtonUpdateCooldown = ActionButton_UpdateCooldown;
local ACTION_BUTTON_COOLDOWN_ICON_ALPHA = 0.5;

function ActionButton_UpdateCooldown(self)
	actionButtonUpdateCooldown(self);
	if IsWoWHackUltimateAction(self.action) then
		self.cooldown:SetDrawSwipe(false);
		if self.lossOfControlCooldown then
			self.lossOfControlCooldown:SetDrawSwipe(false);
		end

		local isCooldownActive = self.cooldown:IsShown();
		if self.lossOfControlCooldown then
			isCooldownActive = isCooldownActive or self.lossOfControlCooldown:IsShown();
		end
		self.icon:SetAlpha(isCooldownActive and ACTION_BUTTON_COOLDOWN_ICON_ALPHA or 1.0);
	else
		-- Adjust the anchor for the cooldown frame to be a bit smaller for these new buttons
		self.chargeCooldown:SetPoint("TOPLEFT", self, "TOPLEFT", 4, -4);
		self.chargeCooldown:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -4, 4);
	end
	if self.UpdateUltimateReadyState then
		self:UpdateUltimateReadyState();
	end
end
