
local ZoneAbilityFrameAtlasFallback = "revendreth-zone-ability";

-- Include sound information based on texture kit for now.
local TextureKitToSoundEffects = {
	["bastion-zone-ability"] = { shownSoundEffect = SOUNDKIT.UI_9_0_COVENANT_ABILITY_ABILITY_BUTTON_APPEARS, placedSoundEffect = SOUNDKIT.UI_9_0_COVENANT_ABILITY_ABILITY_BUTTON_PLACED_BASTION, };
	["revendreth-zone-ability"] = { shownSoundEffect = SOUNDKIT.UI_9_0_COVENANT_ABILITY_ABILITY_BUTTON_APPEARS, placedSoundEffect = SOUNDKIT.UI_9_0_COVENANT_ABILITY_ABILITY_BUTTON_PLACED_REVENDRETH, };
	["ardenweald-zone-ability"] = { shownSoundEffect = SOUNDKIT.UI_9_0_COVENANT_ABILITY_ABILITY_BUTTON_APPEARS, placedSoundEffect = SOUNDKIT.UI_9_0_COVENANT_ABILITY_ABILITY_BUTTON_PLACED_ARDENWEALD, };
	["maldraxxus-zone-ability"] = { shownSoundEffect = SOUNDKIT.UI_9_0_COVENANT_ABILITY_ABILITY_BUTTON_APPEARS, placedSoundEffect = SOUNDKIT.UI_9_0_COVENANT_ABILITY_ABILITY_BUTTON_PLACED_MALDRAXXUS, };
};

local function GetActiveZoneAbilities()
	local zoneAbilities = C_ZoneAbility.GetActiveAbilities();
	for i, zoneAbility in ipairs(zoneAbilities) do
		local soundEffectData = TextureKitToSoundEffects[zoneAbility.textureKit]
		if soundEffectData then
			zoneAbility = Mixin(zoneAbility, soundEffectData);
		end
	end

	return zoneAbilities;
end

local function DoZoneAbilitiesIncludeSpellID(zoneAbilities, spellID)
	for i, zoneAbility in ipairs(zoneAbilities) do
		if zoneAbility.spellID == spellID then
			return true;
		end
	end

	return false;
end

local function HideZoneAbilityTutorial()
	HelpTip:HideAll(ZoneAbilityFrame);
end


ZoneAbilityFrameUpdater = {};

function ZoneAbilityFrameUpdater:AddDirtyFrame(dirtyFrame)
	if not self.dirtyFrames then
		self.dirtyFrames = {};
	end

	self.dirtyFrames[dirtyFrame] = true;

	if not self.isDirty then
		self.isDirty = true;
		C_Timer.After(0, function() self:Clean() end);
	end
end

function ZoneAbilityFrameUpdater:Clean()
	for frame in pairs(self.dirtyFrames) do
		frame:UpdateDisplayedZoneAbilities();
	end

	self.dirtyFrames = {};
	self.isDirty = false;
end

ZoneAbilityFrameMixin = {};

function ZoneAbilityFrameMixin:OnLoad()
	-- Always registered.
	self:RegisterUnitEvent("UNIT_AURA", "player");
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");

	EventRegistry:RegisterCallback("ActionBarShownSettingUpdated", self.MarkDirty, self);

	self.variablesLoaded = false;
	-- Will be unregistered once received.
	self:RegisterEvent("VARIABLES_LOADED");

	self.SpellButtonContainer:SetTemplate("Button", "ZoneAbilityFrameSpellButtonTemplate");

	self:UpdateDisplayedZoneAbilities();
end

function ZoneAbilityFrameMixin:OnEvent(event, ...)
	if event == "VARIABLES_LOADED" then
		self:SetVariablesLoaded();
	end

	self:MarkDirty();
end

function ZoneAbilityFrameMixin:SetVariablesLoaded()
	self:UnregisterEvent("VARIABLES_LOADED");
	self.variablesLoaded = true;
	self:CheckForTutorial();
end

function ZoneAbilityFrameMixin:MarkDirty()
	ZoneAbilityFrameUpdater:AddDirtyFrame(self);
end

local function SortByUIPriority(lhs, rhs)
	return lhs.uiPriority < rhs.uiPriority;
end

function ZoneAbilityFrameMixin:UpdateDisplayedZoneAbilities()
	-- Leaving this as a surgical fix for timerunning for now.
	local hideZoneAbilities = PlayerGetTimerunningSeasonID() and HasVehicleActionBar();

	local zoneAbilities = hideZoneAbilities and {} or GetActiveZoneAbilities();
	table.sort(zoneAbilities, SortByUIPriority);

	local displayedZoneAbilities = {};
	local activeAbilityIsDisplayedOnBar = {};
	local displayedTextureKit = nil;
	for i, zoneAbilityInfo in ipairs(zoneAbilities) do
		local spellID = zoneAbilityInfo.spellID;
		local excludeNonPlayerBars = true;
		local excludeSpecialPlayerBars = true;
		local hasZoneAbilityOnBar = ActionButtonUtil.IsSpellOnAnyActiveActionBar(spellID, excludeNonPlayerBars, excludeSpecialPlayerBars);
		activeAbilityIsDisplayedOnBar[spellID] = hasZoneAbilityOnBar;
		if not hasZoneAbilityOnBar then
			if #displayedZoneAbilities == 0 then
				table.insert(displayedZoneAbilities, zoneAbilityInfo);

				-- If there's no textureKit, only allow one to be displayed.
				if not zoneAbilityInfo.textureKit then
					break;
				end

				displayedTextureKit = zoneAbilityInfo.textureKit;
			elseif displayedTextureKit and zoneAbilityInfo.textureKit == displayedTextureKit then
				table.insert(displayedZoneAbilities, zoneAbilityInfo);
			end
		end
	end

	if self.previousZoneAbilities then
		for i, previousZoneAbility in ipairs(self.previousZoneAbilities) do
			if previousZoneAbility.placedSoundEffect then
				local spellID = previousZoneAbility.spellID;
				if activeAbilityIsDisplayedOnBar[spellID] and not DoZoneAbilitiesIncludeSpellID(displayedZoneAbilities, spellID) then
					PlaySound(previousZoneAbility.placedSoundEffect);
				end
			end
		end
	end

	for i, displayZoneAbility in ipairs(displayedZoneAbilities) do
		if displayZoneAbility.shownSoundEffect then
			local spellID = displayZoneAbility.spellID;
			if not self.previousZoneAbilities or not DoZoneAbilitiesIncludeSpellID(self.previousZoneAbilities, spellID) then
				PlaySound(displayZoneAbility.shownSoundEffect);
			end
		end
	end

	-- don't update if nothing's changed, could screw up OnClick
	local depth = 3;
	if self.previousZoneAbilities and tCompare(self.previousZoneAbilities, displayedZoneAbilities, depth) then
		return;
	end

	HideZoneAbilityTutorial();

	self.previousZoneAbilities = displayedZoneAbilities;

	local numDisplayedAbilites = #displayedZoneAbilities;
	if numDisplayedAbilites == 0 then
		ExtraAbilityContainer:RemoveFrame(self, ZoneAbilityFramePriority);
		return;
	end

	ExtraAbilityContainer:AddFrame(self, ZoneAbilityFramePriority);

	self.SpellButtonContainer:SetContents(displayedZoneAbilities);

	local useAtlasSize = true;
	if displayedTextureKit then
		if numDisplayedAbilites > 1 then
			-- Append "-2", "-3", etc to the texture name to accomodate multiple actions at once.
			local fullAtlasName = displayedTextureKit.."-"..numDisplayedAbilites;
			if C_Texture.GetAtlasInfo(fullAtlasName) then
				self.Style:SetAtlas(fullAtlasName, useAtlasSize);
				return;
			end
		end

		if C_Texture.GetAtlasInfo(displayedTextureKit) then
			self.Style:SetAtlas(displayedTextureKit, useAtlasSize);
		else
			self.Style:SetTexture(displayedTextureKit);
		end
	else
		self.Style:SetAtlas(ZoneAbilityFrameAtlasFallback, useAtlasSize);
	end
end

function ZoneAbilityFrameMixin:CheckForTutorial()
	for spellButton in self.SpellButtonContainer:EnumerateActive() do
		spellButton:CheckForTutorial();
	end
end

function ZoneAbilityFrameMixin:CanShowTutorial(zoneAbilityInfo)
	return self.variablesLoaded
		and not HelpTip:IsShowingAny(self)
		and not GetCVarBitfield("closedExtraAbiltyTutorials", zoneAbilityInfo.zoneAbilityID)
		and zoneAbilityInfo.tutorialText;
end

function ZoneAbilityFrameMixin:CheckShowZoneAbilityTutorial(zoneAbilityButton)
	local zoneAbilityInfo = zoneAbilityButton.zoneAbilityInfo;
	if not self:CanShowTutorial(zoneAbilityInfo) then
		return;
	end

	local helpTipInfo = {
		text = zoneAbilityInfo.tutorialText,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedExtraAbiltyTutorials",
		onAcknowledgeCallback = function() self:CheckForTutorial() end,
		bitfieldFlag = zoneAbilityInfo.zoneAbilityID,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		offsetY = 20,
	};
	HelpTip:Show(self, helpTipInfo, zoneAbilityButton);
end

ZoneAbilityFrameSpellButtonMixin = CreateFromMixins(ContentFrameMixin);

local ZoneAbilityFrameSpellButtonEvents = {
	"SPELL_UPDATE_COOLDOWN",
	"SPELL_UPDATE_USABLE",
	"SPELL_UPDATE_CHARGES",
};

function ZoneAbilityFrameSpellButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
end

function ZoneAbilityFrameSpellButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ZoneAbilityFrameSpellButtonEvents);
end

function ZoneAbilityFrameSpellButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ZoneAbilityFrameSpellButtonEvents);
end

function ZoneAbilityFrameSpellButtonMixin:OnEvent(event, ...)
	self:Refresh();
end

function ZoneAbilityFrameSpellButtonMixin:OnEnter()
	GameTooltip:SetOwner(self);
	GameTooltip:SetSpellByID(self:GetOverrideSpellID());
end

function ZoneAbilityFrameSpellButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function ZoneAbilityFrameSpellButtonMixin:OnClick()
	local unitToken, tryToggleSpell = nil, true;
	CastSpellByID(self:GetSpellID(), unitToken, tryToggleSpell);
end

function ZoneAbilityFrameSpellButtonMixin:OnDragStart()
	C_Spell.PickupSpell(self:GetSpellID());
	SetCVarBitfield("closedExtraAbiltyTutorials", self.zoneAbilityInfo.zoneAbilityID, true);
	HideZoneAbilityTutorial();
end

function ZoneAbilityFrameSpellButtonMixin:Refresh()
	local spellID = self:GetOverrideSpellID();

	local chargeInfo = C_Spell.GetSpellCharges(spellID);
	local cooldownInfo = C_Spell.GetSpellCooldown(spellID);
	local usesCount = C_Spell.GetSpellCastCount(spellID);

	local icon = C_ZoneAbility.GetZoneAbilityIcon(spellID);
	self.Icon:SetTexture(icon);

	local spellCount = nil;
	if chargeInfo then
		spellCount = chargeInfo.currentCharges;
		if chargeInfo.currentCharges < chargeInfo.maxCharges then
			StartChargeCooldown(self, chargeInfo.cooldownStartTime, chargeInfo.cooldownDuration, chargeInfo.chargeModRate);
		end
	elseif usesCount > 0 then
		spellCount = usesCount;
	end

	self.Count:SetText(spellCount and spellCount or "");

	if cooldownInfo then
		CooldownFrame_Set(self.Cooldown, cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.isEnabled);
	end
end

function ZoneAbilityFrameSpellButtonMixin:CheckForTutorial()
	self:GetParent():GetParent():CheckShowZoneAbilityTutorial(self);
end

function ZoneAbilityFrameSpellButtonMixin:SetSpellID(spellID)
	self.spellID = spellID;

	self:Refresh();
end

function ZoneAbilityFrameSpellButtonMixin:GetSpellID()
	return self.spellID;
end

function ZoneAbilityFrameSpellButtonMixin:GetOverrideSpellID()
	local spellID = self:GetSpellID();
	return FindSpellOverrideByID(spellID) or spellID;
end

function ZoneAbilityFrameSpellButtonMixin:SetContent(zoneAbilityInfo)
	self.zoneAbilityInfo = zoneAbilityInfo;
	self:SetSpellID(zoneAbilityInfo.spellID);
	self:CheckForTutorial();
end