local SpellBookItemEvents = {
	"UPDATE_SHAPESHIFT_FORM",
	"SPELL_UPDATE_COOLDOWN",
	"PET_BAR_UPDATE",
	"ACTIONBAR_SLOT_CHANGED",
	"CURSOR_CHANGED",
}

local TRAINABLE_FX_ID = 176;

SpellBookItemMixin = {};

function SpellBookItemMixin:OnLoad()
	-- Moved to a container to center all of the text vertically.
	-- Aliasing them to preserve functionality and reduce the amount
	-- of things in the hierarchy to list on the Lua side
	self.Name = self.TextContainer.Name;
	self.SubName = self.TextContainer.SubName;
	self.RequiredLevel = self.TextContainer.RequiredLevel;

	self.Backplate:SetAlpha(self.defaultBackplateAlpha);
	self.Button.IconHighlight:SetAlpha(self.iconHighlightHoverAlpha);
end

function SpellBookItemMixin:Init(elementData)
	self.elementData = elementData;
	local forceUpdate = true;
	self:UpdateSpellData(forceUpdate);
end

function SpellBookItemMixin.Reset(framePool, self)
	Pool_HideAndClearAnchors(framePool, self);
	self:ClearSpellData();
	self.elementData = nil;
end

function SpellBookItemMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, SpellBookItemEvents);
	self:UpdateActionBarAnim();
	self:UpdateBorderAnim();
	self:UpdateTrainableFX();
end

function SpellBookItemMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SpellBookItemEvents);
	self:UpdateActionBarAnim();
	self:UpdateBorderAnim();
	self:UpdateTrainableFX();
end

function SpellBookItemMixin:OnEvent(event, ...)
	if not self:HasValidData() then
		return;
	end

	if event == "UPDATE_SHAPESHIFT_FORM" then
		-- Attack icons change when shapeshift form changes
		self:UpdateIcon();
	elseif event == "SPELL_UPDATE_COOLDOWN" then
		-- Update cooldown & tooltip, if active
		self:UpdateCooldown();
		if ( GameTooltip:GetOwner() == self ) then
			self:OnEnter();
		end
	elseif event == "PET_BAR_UPDATE" then
		-- Update pet autocast visuals if pet bar spell
		if self.spellBank == Enum.SpellBookSpellBank.Pet then
			self:UpdateAutoCast();
			self:UpdateActionBarStatus();
		end
	elseif event == "ACTIONBAR_SLOT_CHANGED" then
		self:UpdateActionBarStatus();
	elseif event == "CURSOR_CHANGED" then
		-- Spell was being dragged from spellbook, update action bar status since we may have hidden visual during drag
		if self.spellGrabbed then
			self.spellGrabbed = false;
			self:UpdateActionBarStatus();
		end
	end
end

function SpellBookItemMixin:UpdateSpellData(forceUpdate)
	if not self.elementData then
		self:ClearSpellData();
		return;
	end

	local spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(self.elementData.slotIndex, self.elementData.spellBank);
	if not spellBookItemInfo then
		self:ClearSpellData();
		return;
	end

	-- Avoid updating all data and visuals if it's not necessary
	if not forceUpdate and self.spellBookItemInfo and tCompare(spellBookItemInfo, self.spellBookItemInfo) then
		-- Do still update dynamic states that aren't core spell book item data and don't have bespoke update events
		if self.activeGlyphCast then
			self:UpdateGlyphState();
		end
		return;
	end

	self:ClearSpellData();

	self.spellBookItemInfo = spellBookItemInfo;
	self.isOffSpec = self.elementData.isOffSpec;
	self.slotIndex = self.elementData.slotIndex;
	self.spellBank = self.elementData.spellBank;

	self:UpdateVisuals();
end

function SpellBookItemMixin:ClearSpellData()
	if self.cancelSpellLoadCallback then
		self.cancelSpellLoadCallback();
	end

	self.spellBookItemInfo = nil;
	self.isOffSpec = nil;
	self.slotIndex = nil;
	self.spellBank = nil;
	self.isUnlearned = nil;
	self.spellGrabbed = nil;
	self.activeGlyphCast = nil;
	self.inClickBindMode = nil;
	self.canClickBind = nil;
	self.isTrainable = nil;
end

function SpellBookItemMixin:HasValidData()
	return self.elementData and self.spellBookItemInfo;
end

function SpellBookItemMixin:GetName()
	return self:HasValidData() and self.spellBookItemInfo.name;
end

function SpellBookItemMixin:GetTexture()
	return self:HasValidData() and self.Button.Icon:GetTexture();
end

function SpellBookItemMixin:IsFlyout()
	return self:HasValidData() and self.spellBookItemInfo.itemType == Enum.SpellBookItemType.Flyout;
end

function SpellBookItemMixin:GetItemType()
	return self:HasValidData() and self.spellBookItemInfo.itemType;
end

function SpellBookItemMixin:GetDragTarget()
	return self.Button;
end

function SpellBookItemMixin:ToggleFlyout(reason)
	if not self:IsFlyout() then
		return;
	end

	local offSpecID = self.isOffSpec and self.elementData.specID or nil;
	local distance, isActionBar, showFullTooltip = -2, false, true;
	SpellFlyout:Toggle(self.spellBookItemInfo.actionID, self.Button, "RIGHT", distance, isActionBar, offSpecID, showFullTooltip, reason);
	SpellFlyout:SetBorderSize(42);

	local rotation = SpellFlyout:IsShown() and 180 or 0;
	SetClampedTextureRotation(self.Button.FlyoutArrow, rotation);
end

local function TrimTextSpace(textFrame)
	if (not textFrame:GetText() or textFrame:GetText() == "") then
		textFrame:SetHeight(1);
		textFrame:Hide();
	else
		textFrame:SetHeight(min(textFrame:GetStringHeight(), textFrame:GetLineHeight() * textFrame:GetMaxLines()));
		textFrame:Show();
	end
end

function SpellBookItemMixin:UpdateTextContainer()
	-- The TrimTextSpace function call here is needed to work around
	-- a bug with FontStrings with a specified maxLine count
	TrimTextSpace(self.Name);
	TrimTextSpace(self.SubName);
	TrimTextSpace(self.RequiredLevel);

	self.TextContainer:Layout();
end

function SpellBookItemMixin:UpdateVisuals()
	self.Name:SetText(self.spellBookItemInfo.name);
	self.Button.Icon:SetTexture(self.spellBookItemInfo.iconID);

	if self.spellBookItemInfo.subName then
		self:UpdateSubName(self.spellBookItemInfo.subName);
	else
		self.SubName:SetText("");
		if self.spellBookItemInfo.spellID then
			local spell = Spell:CreateFromSpellID(spellID);
			self.cancelSpellLoadCallback = spell:ContinueWithCancelOnSpellLoad(function()
				local spellSubName = spell:GetSpellSubtext();
				self:UpdateSubName(spellSubName);
				self.cancelSpellLoadCallback = nil;

				self:UpdateTextContainer();
			end);
		end
	end

	if (self.spellBookItemInfo.itemType == Enum.SpellBookItemType.Flyout) then
		self.Button.FlyoutArrow:Show();
	else
		self.Button.FlyoutArrow:Hide();
	end

	self:UpdateArtSet();
	if self.artSet.iconMask then
		self.Button.IconMask:SetAtlas(self.artSet.iconMask, TextureKitConstants.IgnoreAtlasSize);
		self.Button.IconMask:Show();
	else
		self.Button.IconMask:Hide();
	end

	self.Button.IconHighlight:SetAtlas(self.artSet.iconHighlight, TextureKitConstants.IgnoreAtlasSize);

	self.isUnlearned = self.isOffSpec or self.spellBookItemInfo.itemType == Enum.SpellBookItemType.FutureSpell;

	self.Button.Icon:SetDesaturated(self.isUnlearned);
	self.Button.FlyoutArrow:SetDesaturated(self.isUnlearned);

	self.isTrainable = false;

	if self.isUnlearned then
		self.Name:SetAlpha(self.unlearnedTextAlpha);
		self.SubName:SetAlpha(self.unlearnedTextAlpha);
		self.RequiredLevel:SetAlpha(self.unlearnedTextAlpha);

		self.Button.Icon:SetVertexColor(SPELLBOOK_UNLEARNED_TINT_COLOR:GetRGB());
		self.Button.Icon:SetAlpha(self.unlearnedIconAlpha);

		local levelLearned = C_SpellBook.GetSpellBookItemLevelLearned(self.slotIndex, self.spellBank);

		local subtext = "";

		-- Spell is locked due to a character boost temporarily limiting spells
		if not self.isOffSpec and IsCharacterNewlyBoosted() then
			subtext = BOOSTED_CHAR_SPELL_TEMPLOCK;
		-- Spell level is too high
		elseif levelLearned and levelLearned > UnitLevel("player") then
			subtext = string.format(SPELLBOOK_AVAILABLE_AT, levelLearned)
		-- Spell available but needs to be learned at a trainer
		elseif not self.isOffSpec then
			self.isTrainable = true;
			subtext = SPELLBOOK_TRAINABLE;
			self.Button.TrainableBackplate:SetAtlas(self.artSet.trainableBackplate, TextureKitConstants.IgnoreAtlasSize);
		end

		self.RequiredLevel:SetShown(subtext ~= "");
		self.RequiredLevel:SetText(subtext);
	else
		self.Name:SetAlpha(1);
		self.SubName:SetAlpha(1);
		self.RequiredLevel:SetAlpha(1);

		self.Button.Icon:SetVertexColor(1, 1, 1);
		self.Button.Icon:SetAlpha(1);

		self.RequiredLevel:Hide();
		self.RequiredLevel:SetText("");
	end

	local borderAtlas = self.isUnlearned and self.artSet.inactiveBorder or self.artSet.activeBorder;
	local borderAnchors = self.isUnlearned and self.artSet.inactiveBorderAnchors or self.artSet.activeBorderAnchors;
	self.Button.Border:SetAtlas(borderAtlas, TextureKitConstants.IgnoreAtlasSize);
	self.Button.Border:ClearAllPoints();
	for _, anchor in ipairs(borderAnchors) do
		local point, relativeTo, relativePoint, x, y = anchor:Get();
		relativeTo = relativeTo or self.Button;
		self.Button.Border:SetPoint(point, relativeTo, relativePoint, x, y);
	end

	self.Button.BorderSheenMask:SetAtlas(self.artSet.borderSheenMask, TextureKitConstants.UseAtlasSize);
	self.Button.BorderSheenMask:ClearAllPoints();
	for _, anchor in ipairs(self.artSet.borderSheenMaskAnchors) do
		local point, relativeTo, relativePoint, x, y = anchor:Get();
		relativeTo = relativeTo or self.Button.Border;
		self.Button.BorderSheenMask:SetPoint(point, relativeTo, relativePoint, x, y);
	end

	local isLevelLinkLocked = self.spellBookItemInfo.spellID and C_LevelLink.IsSpellLocked(self.spellBookItemInfo.spellID) or false;
	self.Button.LevelLinkLock:SetShown(isLevelLinkLocked);
	self.Button.LevelLinkIconCover:SetShown(isLevelLinkLocked);

	self.Button.TrainableShadow:SetShown(self.isTrainable);
	self.Button.TrainableBackplate:SetShown(self.isTrainable);

	self:UpdateTextContainer();
	self:UpdateActionBarStatus();
	self:UpdateCooldown();
	self:UpdateAutoCast();
	self:UpdateGlyphState();
	self:UpdateClickBindState();
	self:UpdateBorderAnim();
	self:UpdateTrainableFX();

	-- If already being hovered, make sure to reset any on-hover state that needs to change
	if self.Button:IsMouseMotionFocus() then
		self:OnIconLeave();
		self:OnIconEnter();
	end
end

function SpellBookItemMixin:UpdateSubName(subNameText)
	if subNameText == "" and self.spellBookItemInfo.isPassive then
		subNameText = SPELL_PASSIVE;
	end
	self.spellBookItemInfo.subName = subNameText;
	self.SubName:SetText(subNameText);
end

function SpellBookItemMixin:UpdateIcon()
	if not self:HasValidData() then
		return;
	end

	-- Icons may dynamically change (ex: on shapeshifting) so update to correct texture
	self.Button.Icon:SetTexture(C_SpellBook.GetSpellBookItemTexture(self.slotIndex, self.spellBank));
end

function SpellBookItemMixin:UpdateActionBarStatus()
	if not self:HasValidData() then
		return;
	end

	-- Avoid showing "missing from bar" visuals while in click bind mode, or spell is being dragged out of spellbook
	if not self.spellGrabbed and not self.inClickBindMode and self.elementData.showActionBarStatus then
		self.actionBarStatus = SpellSearchUtil.GetActionbarStatusForSpellBookItemInfo(self.spellBookItemInfo);
	else
		self.actionBarStatus = ActionButtonUtil.ActionBarActionStatus.NotMissing;
	end

	self:UpdateActionBarAnim();
end

function SpellBookItemMixin:UpdateActionBarAnim()
	local shouldPlayHighlight = self:HasValidData() and self.actionBarStatus == ActionButtonUtil.ActionBarActionStatus.MissingFromAllBars and self:IsShown();
	self:UpdateSynchronizedAnimState(self.Button.ActionBarHighlight.Anim, shouldPlayHighlight);
end

function SpellBookItemMixin:UpdateBorderAnim()
	local shouldPlaySheen = self:HasValidData() and not self.isUnlearned and self:IsShown();
	self:UpdateSynchronizedAnimState(self.Button.BorderSheen.Anim, shouldPlaySheen);
end

function SpellBookItemMixin:UpdateSynchronizedAnimState(animGroup, shouldBePlaying)
	local isPlaying = animGroup:IsPlaying();
	if shouldBePlaying and not isPlaying then
		-- Ensure all looping anims stay synced with other SpellBookItems
		animGroup:PlaySynced();
	elseif not shouldBePlaying and isPlaying then
		animGroup:Stop();
	end
end

function SpellBookItemMixin:UpdateTrainableFX()
	local shouldBePlaying = self.isTrainable and self:HasValidData() and self:IsShown();
	if shouldBePlaying and not self.trainableFXController then
		self.trainableFXController = self.Button.FxModelScene:AddEffect(TRAINABLE_FX_ID, self.Button, self.Button);
	elseif not shouldBePlaying and self.trainableFXController then
		self.trainableFXController:CancelEffect();
		self.trainableFXController = nil;
	end
end

function SpellBookItemMixin:UpdateCooldown()
	if not self:HasValidData() then
		return;
	end

	local cooldownInfo = C_SpellBook.GetSpellBookItemCooldown(self.slotIndex, self.spellBank);
	if cooldownInfo and cooldownInfo.isEnabled then
		self.Button.Cooldown:SetCooldown(cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.modRate);
	else
		self.Button.Cooldown:Clear();
	end
end

function SpellBookItemMixin:UpdateAutoCast()
	if not self:HasValidData() then
		return;
	end

	local autoCastAllowed, autoCastEnabled = false, false;

	if not self.isOffSpec then
		autoCastAllowed, autoCastEnabled = C_SpellBook.GetSpellBookItemAutoCast(self.slotIndex, self.spellBank);
	end

	self.Button.AutoCastOverlay:SetShown(autoCastAllowed);
	self.Button.AutoCastOverlay:ShowAutoCastEnabled(autoCastEnabled);
end

function SpellBookItemMixin:ShowGlyphActivation()
	if not self:HasValidData() then
		return;
	end

	-- Cache that a glyph is being applied/removed on this item
	-- So that we can show the right glyph state while the cast is still ongoing
	self.activeGlyphCast = { isRemoval = IsPendingGlyphRemoval() };

	local isActivationStart = true;
	self:UpdateGlyphState(isActivationStart);
end

function SpellBookItemMixin:UpdateGlyphState(isActivationStart)
	if not self:HasValidData() then
		return;
	end

	local hasGlyph = false;
	local isValidForPendingGlyph = false;

	-- On the frame that activeGlyphCast is set, IsCastingGlyph is not yet true,
	-- so important to also check if we only just now set activeGlyphCast before clearing it out as stale
	if self.activeGlyphCast and not (isActivationStart or IsCastingGlyph()) then
		self.activeGlyphCast = nil;
	end

	-- Glyph application/removal is actively being cast on this item, so predict glyph state based on cached info
	if self.activeGlyphCast then
		hasGlyph = not self.activeGlyphCast.isRemoval;
	-- Otherwise get current glyph state normally
	elseif self.spellBookItemInfo.itemType == Enum.SpellBookItemType.Spell and not self.isOffSpec then
		hasGlyph = HasAttachedGlyph(self.spellBookItemInfo.spellID);
		isValidForPendingGlyph = IsSpellValidForPendingGlyph(self.spellBookItemInfo.spellID);
	end

	self.Button.GlyphIcon:SetShown(hasGlyph);

	if isValidForPendingGlyph and not self.GlyphHighlightAnim:IsPlaying() then
		self.GlyphHighlightAnim:Restart();
	elseif not isValidForPendingGlyph and self.GlyphHighlightAnim:IsPlaying() then
		self.GlyphHighlightAnim:Stop();
	end

	if isActivationStart then
		self.Button.GlyphActivateHighlight:Show();
		self.Button.GlyphActiveIcon:Show();
		self.GlyphActivateAnim:Restart();
	else
		self.GlyphActivateAnim:Stop();
		self.Button.GlyphActivateHighlight:Hide();
		self.Button.GlyphActiveIcon:Hide();
	end
end

function SpellBookItemMixin:UpdateClickBindState()
	if not self:HasValidData() then
		return;
	end

	local wasInClickBindMode = self.inClickBindMode;
	self.inClickBindMode = InClickBindingMode();
	self.canClickBind = false;

	if self.inClickBindMode and self.spellBookItemInfo.spellID and not self.isUnlearned then
		self.canClickBind = C_ClickBindings.CanSpellBeClickBound(self.spellBookItemInfo.spellID);
	end

	self.Button.ClickBindingHighlight:SetShown(self.canClickBind and ClickBindingFrame:HasEmptySlot());
	self.Button.ClickBindingIconCover:SetShown(self.inClickBindMode and not self.canClickBind);

	-- Update saturation, except on unlearned items as they already have their own desaturated state
	if not self.isUnlearned then
		-- Desaturate if binding active and can't click bind, otherwise restore saturation
		local saturation = (self.inClickBindMode and not self.canClickBind) and 0.75 or 0;
		self.Button.Icon:SetDesaturation(saturation);
	end

	if self.inClickBindMode ~= wasInClickBindMode then
		-- Update action bar status as its highlight is disabled while in clickbind mode
		self:UpdateActionBarStatus();
	end
end

function SpellBookItemMixin:OnIconEnter()
	if not self:HasValidData() then
		return;
	end

	local tooltip = GameTooltip;
	tooltip:SetOwner(self.Button, "ANCHOR_RIGHT");

	if self.inClickBindMode and not self.canClickBind then
		GameTooltip_AddErrorLine(tooltip, CLICK_BINDING_NOT_AVAILABLE);
		tooltip:Show();
		return;
	end

	if not self.isUnlearned then
		self.Button.IconHighlight:Show();
		self.Backplate:SetAlpha(self.hoverBackplateAlpha);
	end

	tooltip:SetSpellBookItem(self.slotIndex, self.spellBank)

	local actionBarStatusToolTip = self.actionBarStatus and SpellSearchUtil.GetTooltipForActionBarStatus(self.actionBarStatus);
	if actionBarStatusToolTip then
		GameTooltip_AddColoredLine(tooltip, actionBarStatusToolTip, LIGHTBLUE_FONT_COLOR);
	end

	tooltip:Show();

	ClearOnBarHighlightMarks();

	local itemType = self.spellBookItemInfo.itemType;
	local actionID = self.spellBookItemInfo.actionID;

	if itemType == Enum.SpellBookItemType.Spell then
		UpdateOnBarHighlightMarksBySpell(actionID);
	elseif itemType == Enum.SpellBookItemType.Flyout then
		UpdateOnBarHighlightMarksByFlyout(actionID);
	elseif itemType == Enum.SpellBookItemType.PetAction then
		UpdateOnBarHighlightMarksByPetAction(actionID);
		PetActionBar:UpdatePetActionHighlightMarks(actionID);
		PetActionBar:Update();
	end

	ActionBarController_UpdateAllSpellHighlights();
end

function SpellBookItemMixin:OnIconLeave()
	if not self:HasValidData() then
		return;
	end

	self.Button.IconHighlight:Hide();
	self.Button.IconHighlight:SetAlpha(self.iconHighlightHoverAlpha);
	self.Backplate:SetAlpha(self.defaultBackplateAlpha);

	ClearOnBarHighlightMarks();
	PetActionBar:ClearPetActionHighlightMarks();

	-- Update action bar highlights
	ActionBarController_UpdateAllSpellHighlights();
	PetActionBar:Update();
	GameTooltip:Hide();
end

function SpellBookItemMixin:OnIconClick(button)
	if not self:HasValidData() then
		return;
	end

	local itemType = self.spellBookItemInfo.itemType;
	local spellID = self.spellBookItemInfo.spellID;
	local actionID = self.spellBookItemInfo.actionID;

	-- If in click bind mode, handle trying to set bind slot
	if self.inClickBindMode then
		if self.canClickBind and actionID and ClickBindingFrame:HasNewSlot() then
			if self.spellBank == Enum.SpellBookSpellBank.Player then
				ClickBindingFrame:AddNewAction(Enum.ClickBindingType.Spell, actionID);
			elseif self.spellBank == Enum.SpellBookSpellBank.Pet then
				ClickBindingFrame:AddNewAction(Enum.ClickBindingType.PetAction, actionID);
			end
		end
	-- If using a glyph or vanishing powder, handle trying to apply glyph
	elseif HasPendingGlyphCast() and self.spellBank == Enum.SpellBookSpellBank.Player then
		if itemType == Enum.SpellBookItemType.Spell and not self.isOffSpec then
			if HasAttachedGlyph(spellID) then
				if IsPendingGlyphRemoval() then
					StaticPopup_Show("CONFIRM_GLYPH_REMOVAL", nil, nil, {name = GetCurrentGlyphNameForSpell(spellID), id = spellID});
				else
					StaticPopup_Show("CONFIRM_GLYPH_PLACEMENT", nil, nil, {name = GetPendingGlyphName(), currentName = GetCurrentGlyphNameForSpell(spellID), id = spellID});
				end
			else
				AttachGlyphToSpell(spellID);
			end
		elseif itemType == Enum.SpellBookItemType.Flyout then
			self:ToggleFlyout(nil);
		end
	-- If pet spell, toggle spell autocast
	elseif button ~= "LeftButton" and self.spellBank == Enum.SpellBookSpellBank.Pet then
		C_SpellBook.ToggleSpellBookItemAutoCast(self.slotIndex, self.spellBank);
	-- If flyout, toggle flyout
	elseif itemType == Enum.SpellBookItemType.Flyout then
		self:ToggleFlyout(nil);
	-- If castable, cast spell
	elseif (itemType == Enum.SpellBookItemType.Spell and not self.isOffSpec) or
			itemType == Enum.SpellBookItemType.PetAction then
		C_SpellBook.CastSpellBookItem(self.slotIndex, self.spellBank);
	end
end

function SpellBookItemMixin:OnModifiedIconClick(button)
	if not self:HasValidData() then
		return;
	end

	EventRegistry:TriggerEvent("SpellBookItemMixin.OnModifiedClick", self, button);

	if IsModifiedClick("CHATLINK") then
		if MacroFrameText and MacroFrameText:HasFocus() then
			-- Macro frame is open, so chat link inserts spell name into macro text
			if not self.spellBookItemInfo.isPassive then
				local spellName = self.spellBookItemInfo.name;
				local subName = self.spellBookItemInfo.subName
				if subName and strlen(subName) > 0 then
					ChatEdit_InsertLink(spellName.."("..subName..")");
				else
					ChatEdit_InsertLink(spellName);
				end
			end
		else
			-- First try to get spell as a trade skill link
			local chatLink = C_SpellBook.GetSpellBookItemTradeSkillLink(self.slotIndex, self.spellBank);
			if not chatLink then
				-- If spell is not a trade skill, use regular spell link
				chatLink = C_SpellBook.GetSpellBookItemLink(self.slotIndex, self.spellBank);
			end
			ChatEdit_InsertLink(chatLink);
		end
	elseif IsModifiedClick("PICKUPACTION") then
		C_SpellBook.PickupSpellBookItem(self.slotIndex, self.spellBank);
	elseif IsModifiedClick("SELFCAST") then
		C_SpellBook.CastSpellBookItem(self.slotIndex, self.spellBank, true);
	end
end

function SpellBookItemMixin:OnIconDragStart()
	if not self:HasValidData() then
		return;
	end

	C_SpellBook.PickupSpellBookItem(self.slotIndex, self.spellBank);
	self.spellGrabbed = true;
	self:UpdateActionBarStatus();
end

function SpellBookItemMixin:OnIconMouseDown()
	if not self:HasValidData() then
		return;
	end

	if not self.isUnlearned then
		self.Button.IconHighlight:SetAlpha(self.iconHighlightPressAlpha);
	end
end

function SpellBookItemMixin:OnIconMouseUp()
	if not self:HasValidData() then
		return;
	end

	if not self.isUnlearned then
		self.Button.IconHighlight:SetAlpha(self.iconHighlightHoverAlpha);
	end
end

function SpellBookItemMixin:OnGlyphActivateAnimFinished()
	self:UpdateGlyphState();
end

SpellBookItemMixin.ArtSet = {
	Square = {
		iconMask = "spellbook-item-spellicon-mask",
		iconHighlight = "spellbook-item-iconframe-hover",
		activeBorder = "spellbook-item-iconframe",
		activeBorderAnchors = {
			CreateAnchor("TOPLEFT", nil, "TOPLEFT", -11, 1),
			CreateAnchor("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 1, -7),
		},
		inactiveBorder = "spellbook-item-iconframe-inactive",
		inactiveBorderAnchors = {
			CreateAnchor("TOPLEFT", nil, "TOPLEFT", -10, 1),
			CreateAnchor("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 2, -5),
		},
		borderSheenMask = "spellbook-item-iconframe-sheen-mask",
		borderSheenMaskAnchors = {
			CreateAnchor("TOPLEFT"),
			CreateAnchor("BOTTOMRIGHT"),
		},
		trainableBackplate = "spellbook-item-needtrainer-iconframe-backplate",
	},
	Circle = {
		iconMask = "talents-node-circle-mask",
		iconHighlight = "spellbook-item-iconframe-passive-hover",
		activeBorder = "talents-node-circle-gray",
		activeBorderAnchors = {
			CreateAnchor("TOPLEFT", nil, "TOPLEFT", 0, 0),
			CreateAnchor("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 0, 0),
		},
		inactiveBorder = "spellbook-item-iconframe-passive-inactive",
		inactiveBorderAnchors = {
			CreateAnchor("TOPLEFT", nil, "TOPLEFT", 0, 0),
			CreateAnchor("BOTTOMRIGHT", nil, "BOTTOMRIGHT", 0, 0),
		},
		borderSheenMask = "talents-node-circle-sheenmask",
		borderSheenMaskAnchors = {
			CreateAnchor("CENTER"),
		},
		trainableBackplate = "spellbook-item-needtrainer-passive-backplate",
	},
}

function SpellBookItemMixin:UpdateArtSet()
	if not self:HasValidData() then
		self.artSet = nil;
	elseif self.spellBookItemInfo.isPassive then
		self.artSet = SpellBookItemMixin.ArtSet.Circle;
	else
		self.artSet = SpellBookItemMixin.ArtSet.Square;
	end
end


SpellBookItemButtonMixin = {};

function SpellBookItemButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function SpellBookItemButtonMixin:OnClick(button)
	if IsModifiedClick() then
		self:GetParent():OnModifiedIconClick(button);
	else
		self:GetParent():OnIconClick(button);
	end
end

function SpellBookItemButtonMixin:OnEnter()
	self:GetParent():OnIconEnter();
end

function SpellBookItemButtonMixin:OnLeave()
	self:GetParent():OnIconLeave();
end

function SpellBookItemButtonMixin:OnDragStart()
	self:GetParent():OnIconDragStart();
end

function SpellBookItemButtonMixin:OnMouseDown()
	self:GetParent():OnIconMouseDown();
end

function SpellBookItemButtonMixin:OnMouseUp()
	self:GetParent():OnIconMouseUp();
end