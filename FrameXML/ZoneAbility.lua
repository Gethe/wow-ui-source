
local ZONE_SPELL_ABILITY_TEXTURES_BASE_FALLBACK = "Interface\\ExtraButton\\GarrZoneAbility-Armory";

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

local function HasZoneAbilitySpellOnBar(spellID)
	local slots = C_ActionBar.FindSpellActionButtons(spellID);
	if slots == nil then
		return false;
	end

	local currentBonusBarIndex = GetBonusBarIndex();
	for i = 1, #slots do
		local slot = slots[i];
		local isOnPrimaryActionBar = IsOnPrimaryActionBar(slot);
		local slotBonusBarIndex = C_ActionBar.GetBonusBarIndexForSlot(slot);

		-- This action is on one of the extra action bars that are always available, or on the primary action bar while it is not being replaced.
		if not slotBonusBarIndex and (not isOnPrimaryActionBar or (currentBonusBarIndex == 0)) then
			return true;
		end

		if slotBonusBarIndex == currentBonusBarIndex then
			return true;
		end
	end

	return false;
end

local function CheckShowZoneAbilityTutorial(zoneAbilityButton)
	local zoneAbilityInfo = zoneAbilityButton.zoneAbilityInfo;
	if HelpTip:IsShowingAny(ZoneAbilityFrame) or GetCVarBitfield("closedExtraAbiltyTutorials", zoneAbilityInfo.zoneAbilityID) or not zoneAbilityInfo.tutorialText then
		return;
	end

	local helpTipInfo = {
		text = zoneAbilityInfo.tutorialText,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedExtraAbiltyTutorials",
		onAcknowledgeCallback = function() ZoneAbilityFrame:CheckForTutorial() end,
		bitfieldFlag = zoneAbilityInfo.zoneAbilityID,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		offsetY = 20,
	};
	HelpTip:Show(ZoneAbilityFrame, helpTipInfo, zoneAbilityButton);
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

	self.SpellButtonContainer:SetTemplate("Button", "ZoneAbilityFrameSpellButtonTemplate");

	self:UpdateDisplayedZoneAbilities();
end

function ZoneAbilityFrameMixin:OnEvent(event, ...)
	self:MarkDirty();
end

function ZoneAbilityFrameMixin:MarkDirty()
	ZoneAbilityFrameUpdater:AddDirtyFrame(self);
end

local function SortByUIPriority(lhs, rhs)
	return lhs.uiPriority < rhs.uiPriority;
end

function ZoneAbilityFrameMixin:UpdateDisplayedZoneAbilities()
	local zoneAbilities = GetActiveZoneAbilities();
	table.sort(zoneAbilities, SortByUIPriority);

	local displayedZoneAbilities = {};
	local activeAbilityIsDisplayedOnBar = {};
	local displayedTextureKit = nil;
	for i, zoneAbilityInfo in ipairs(zoneAbilities) do
		local spellID = zoneAbilityInfo.spellID;
		local hasZoneAbilityOnBar = HasZoneAbilitySpellOnBar(spellID);
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
	if self.previousZoneAbilities and tCompare(self.previousZoneAbilities, displayedZoneAbilities) then
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
	GameTooltip:SetSpellByID(self:GetSpellID());
end

function ZoneAbilityFrameSpellButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function ZoneAbilityFrameSpellButtonMixin:OnClick()
	CastSpellByID(self:GetSpellID());
end

function ZoneAbilityFrameSpellButtonMixin:OnDragStart()
	PickupSpell(self:GetSpellID());
	SetCVarBitfield("closedExtraAbiltyTutorials", self.zoneAbilityInfo.zoneAbilityID, true);
	HideZoneAbilityTutorial();
end

function ZoneAbilityFrameSpellButtonMixin:Refresh()
	local spellID = self:GetSpellID();
	spellID = FindSpellOverrideByID(spellID) or spellID;

	local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID);
	local start, duration, enable = GetSpellCooldown(spellID);
	local usesCount = GetSpellCount(spellID);

	local spellCount = nil;
	if maxCharges and maxCharges > 1 then
		spellCount = charges;

		if charges < maxCharges then
			StartChargeCooldown(self, chargeStart, chargeDuration, enable);
		end
	elseif usesCount > 0 then
		spellCount = usesCount;
	end

	self.Count:SetText(spellCount and spellCount or "");

	if start then
		CooldownFrame_Set(self.Cooldown, start, duration, enable);
	end
end

function ZoneAbilityFrameSpellButtonMixin:CheckForTutorial()
	CheckShowZoneAbilityTutorial(self);
end

function ZoneAbilityFrameSpellButtonMixin:SetSpellID(spellID)
	self.spellID = spellID;

	local texture = select(3, GetSpellInfo(spellID));
	self.Icon:SetTexture(texture);

	self:Refresh();
end

function ZoneAbilityFrameSpellButtonMixin:GetSpellID()
	return self.spellID;
end

function ZoneAbilityFrameSpellButtonMixin:SetContent(zoneAbilityInfo)
	self.zoneAbilityInfo = zoneAbilityInfo;
	self:SetSpellID(zoneAbilityInfo.spellID);
	self:CheckForTutorial();
end