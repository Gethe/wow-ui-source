
local SPELLFLYOUT_DEFAULT_SPACING = 4;
local SPELLFLYOUT_INITIAL_SPACING = 9;
local SPELLFLYOUT_FINAL_SPACING = 9;

SpellFlyoutOpenReason = EnumUtil.MakeEnum("GlyphPending", "GlyphActivated");

SpellFlyoutPopupButtonMixin = {};

function SpellFlyoutPopupButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	_G[self:GetName().."Count"]:SetPoint("BOTTOMRIGHT", 0, 0);
	self.maxDisplayCount = 99;
end

function SpellFlyoutPopupButtonMixin:OnClick()
	EventRegistry:TriggerEvent("SpellFlyoutPopupButtonMixin.OnClick", self);

	if ( IsModifiedClick("CHATLINK") ) then
		if ( MacroFrameText and MacroFrameText:HasFocus() ) then
			if ( self.spellName ) then
				ChatFrameUtil.InsertLink(self.spellName);
			end
		else
			local tradeSkillLink = C_Spell.GetSpellTradeSkillLink(self.spellID);
			if ( tradeSkillLink ) then
				ChatFrameUtil.InsertLink(tradeSkillLink);
			else
				local spellLink = C_Spell.GetSpellLink(self.spellID);
				ChatFrameUtil.InsertLink(spellLink);
			end
		end
		self:UpdateState();
	else
		if ( HasPendingGlyphCast() ) then
			if ( HasAttachedGlyph(self.spellID) ) then
				if ( IsPendingGlyphRemoval() ) then
					StaticPopup_Show("CONFIRM_GLYPH_REMOVAL", nil, nil, {name = GetCurrentGlyphNameForSpell(self.spellID), id = self.spellID});
				else
					StaticPopup_Show("CONFIRM_GLYPH_PLACEMENT", nil, nil, {name = GetPendingGlyphName(), currentName = GetCurrentGlyphNameForSpell(self.spellID), id = self.spellID});
				end
			else
				AttachGlyphToSpell(self.spellID);
			end
			return;
		end
		local spellID = C_Spell.GetSpellIDForSpellIdentifier(self.spellID);
		if ( self.offSpec ) then
			return;
		elseif ( spellID ) then
			CastSpellByID(spellID);
			self:ClosePopup();
		elseif ( self.spellName ) then
			CastSpellByName(self.spellName);
			self:ClosePopup();
		end
	end
end

function SpellFlyoutPopupButtonMixin:OnDragStart()
	if (not self.isActionBar or not Settings.GetValue("lockActionBars") or IsModifiedClick("PICKUPACTION")) then
		if (self.spellID) then
			C_Spell.PickupSpell(self.spellID);
		end
	end
end

function SpellFlyoutPopupButtonMixin:SetTooltip()
	if ( GetCVar("UberTooltips") == "1" or self.showFullTooltip ) then
		if (self.isActionBar) then
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 4, 4);
		end
		if ( GameTooltip:SetSpellByID(self.spellID) ) then
			self.UpdateTooltip = self.SetTooltip;
		else
			self.UpdateTooltip = nil;
		end
	else
		local parent = self:GetParent():GetParent():GetParent();
		if ( parent == MultiBarBottomRight or parent == MultiBarRight or parent == MultiBarLeft ) then
			GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		end
		local spellName = C_Spell.GetSpellName(self.spellID);
		GameTooltip:SetText(spellName, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		self.UpdateTooltip = nil;
	end
end

function SpellFlyoutPopupButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function SpellFlyoutPopupButtonMixin:UpdateCooldown()
	ActionButton_UpdateCooldown(self);
end

function SpellFlyoutPopupButtonMixin:UpdateState()
	if ( C_Spell.IsCurrentSpell(self.spellID) ) then
		self:SetChecked(true);
	else
		self:SetChecked(false);
	end
end

function SpellFlyoutPopupButtonMixin:UpdateUsable()
	local isUsable, notEnoughMana = C_Spell.IsSpellUsable(self.spellID);
	local name = self:GetName();
	local icon = _G[name.."Icon"];
	if ( isUsable or not self.isActionBar) then
		icon:SetVertexColor(1.0, 1.0, 1.0);
	elseif ( notEnoughMana ) then
		icon:SetVertexColor(0.5, 0.5, 1.0);
	else
		icon:SetVertexColor(0.4, 0.4, 0.4);
	end
end

function SpellFlyoutPopupButtonMixin:UpdateGlyphState(reason)
	self.GlyphIcon:SetShown(HasAttachedGlyph(self.spellID));
	if (HasPendingGlyphCast() and IsSpellValidForPendingGlyph(self.spellID)) then
		self.AbilityHighlight:Show();
		self.AbilityHighlightAnim:Play();
		if (reason == SpellFlyoutOpenReason.GlyphActivated) then
			if (IsPendingGlyphRemoval()) then
				self.GlyphIcon:Hide();
			else
				self.AbilityHighlightAnim:Stop();
				self.AbilityHighlight:Hide();
				self.GlyphIcon:Show();
				self.GlyphActivate:Show();
				self.GlyphTranslation:Show();
				self.GlyphActivateAnim:Play();
				SpellFlyout.glyphActivating = true;
			end
		end
	else
		self.AbilityHighlightAnim:Stop();
		self.AbilityHighlight:Hide();
	end
end

function SpellFlyoutPopupButtonMixin:UpdateCount()
	local text = _G[self:GetName().."Count"];
	text:SetText(C_Spell.GetSpellDisplayCount(self.spellID, self.maxDisplayCount));
end

SpellFlyoutMixin = {};

function SpellFlyoutMixin:OnLoad()
	self.eventsRegistered = false;
end

function SpellFlyoutMixin:OnEvent(event, ...)
	if (event == "SPELL_UPDATE_COOLDOWN") then
		local i = 1;
		local button = _G["SpellFlyoutPopupButton"..i];
		while (button and button:IsShown()) do
			button:UpdateCooldown();
			i = i+1;
			button = _G["SpellFlyoutPopupButton"..i];
		end
	elseif (event == "CURRENT_SPELL_CAST_CHANGED") then
		local i = 1;
		local button = _G["SpellFlyoutPopupButton"..i];
		while (button and button:IsShown()) do
			button:UpdateState();
			i = i+1;
			button = _G["SpellFlyoutPopupButton"..i];
		end
	elseif (event == "SPELL_UPDATE_USABLE") then
		local i = 1;
		local button = _G["SpellFlyoutPopupButton"..i];
		while (button and button:IsShown()) do
			button:UpdateUsable();
			i = i+1;
			button = _G["SpellFlyoutPopupButton"..i];
		end
	elseif (event == "BAG_UPDATE") then
		local i = 1;
		local button = _G["SpellFlyoutPopupButton"..i];
		while (button and button:IsShown()) do
			button:UpdateCount();
			button:UpdateUsable();
			i = i+1;
			button = _G["SpellFlyoutPopupButton"..i];
		end
	elseif (event == "SPELL_FLYOUT_UPDATE") then
		local i = 1;
		local button = _G["SpellFlyoutPopupButton"..i];
		while (button and button:IsShown()) do
			button:UpdateCooldown();
			button:UpdateState();
			button:UpdateUsable();
			button:UpdateCount();
			button:UpdateGlyphState();
			i = i+1;
			button = _G["SpellFlyoutPopupButton"..i];
		end
	elseif (event == "PET_STABLE_UPDATE" or event == "PET_STABLE_SHOW") then
		self:Close();
	elseif (event == "ACTIONBAR_PAGE_CHANGED") then
		self:Close();
	end
end

function SpellFlyoutMixin:Toggle(flyoutButton, flyoutID, isActionBar, specID, showFullTooltip, reason)
	if (self:IsShown() and self.glyphActivating) then
		return;
	end

	if self:IsShown() then
		local sameButton = self:IsAttachedToButton(flyoutButton);

		self:Close();

		if sameButton then
			return;
		end
	end

	local offSpec = specID and (specID ~= 0);

	local _, _, numSlots, isKnown = GetFlyoutInfo(flyoutID);
	self.isActionBar = isActionBar;

	-- Make sure this flyout is known or we are showing an offSpec flyout
	if ((not isKnown and not offSpec) or numSlots == 0) then
		return;
	end

	local direction = flyoutButton:GetPopupDirection();

	-- Update all spell buttons for this flyout
	local prevButton = nil;
	local numButtons = 0;
	for i=1, numSlots do
		local spellID, overrideSpellID, isKnownSlot, spellName, slotSpecID = GetFlyoutSlotInfo(flyoutID, i);
		local visible = true;

		-- Ignore Call Pet spells if there isn't a pet in that slot
		local petIndex, petName = GetCallPetSpellInfo(spellID);
		if (isActionBar and petIndex and (not petName or petName == "")) then
			visible = false;
		end

		if ( ((not offSpec or slotSpecID == 0) and visible and isKnownSlot) or (offSpec and slotSpecID == specID) ) then
			local button = _G["SpellFlyoutPopupButton"..numButtons+1];
			if (not button) then
				button = CreateFrame("CHECKBUTTON", "SpellFlyoutPopupButton"..numButtons+1, SpellFlyout, "SpellFlyoutPopupButtonTemplate");
			end

			button:ClearAllPoints();
			if (direction == "UP") then
				if (prevButton) then
					button:SetPoint("BOTTOM", prevButton, "TOP", 0, SPELLFLYOUT_DEFAULT_SPACING);
				else
					button:SetPoint("BOTTOM", 0, SPELLFLYOUT_INITIAL_SPACING);
				end
			elseif (direction == "DOWN") then
				if (prevButton) then
					button:SetPoint("TOP", prevButton, "BOTTOM", 0, -SPELLFLYOUT_DEFAULT_SPACING);
				else
					button:SetPoint("TOP", 0, -SPELLFLYOUT_INITIAL_SPACING);
				end
			elseif (direction == "LEFT") then
				if (prevButton) then
					button:SetPoint("RIGHT", prevButton, "LEFT", -SPELLFLYOUT_DEFAULT_SPACING, 0);
				else
					button:SetPoint("RIGHT", -SPELLFLYOUT_INITIAL_SPACING, 0);
				end
			elseif (direction == "RIGHT") then
				if (prevButton) then
					button:SetPoint("LEFT", prevButton, "RIGHT", SPELLFLYOUT_DEFAULT_SPACING, 0);
				else
					button:SetPoint("LEFT", SPELLFLYOUT_INITIAL_SPACING, 0);
				end
			end

			button:Show();
			button.showFullTooltip = showFullTooltip;
			button.isActionBar = isActionBar;

			_G[button:GetName().."Icon"]:SetTexture(C_Spell.GetSpellTexture(overrideSpellID));
			_G[button:GetName().."Icon"]:SetDesaturated(offSpec);
			button.offSpec = offSpec;
			button.spellID = spellID;
			button.spellName = spellName;
			if ( offSpec ) then
				button:Disable();
			else
				button:Enable();
			end
			button:UpdateCooldown();
			button:UpdateState();
			button:UpdateUsable();
			button:UpdateCount();
			button:UpdateGlyphState(reason);

			prevButton = button;
			numButtons = numButtons+1;
		end
	end

	-- Hide unused buttons
	local unusedButtonIndex = numButtons+1;
	while (_G["SpellFlyoutPopupButton"..unusedButtonIndex]) do
		_G["SpellFlyoutPopupButton"..unusedButtonIndex]:Hide();
		unusedButtonIndex = unusedButtonIndex+1;
	end

	if (numButtons == 0) then
		return;
	end

	self:SetFrameStrata("DIALOG");
	self:SetWidthPadding(8);
	self:SetHeightPadding(8);
	self:Layout();
	self:SetBorderColor(0.7, 0.7, 0.7);

	flyoutButton:TogglePopup();
end

function SpellFlyoutMixin:CloseIfWorldMapMaximized()
	if (WorldMapFrame:IsMaximized()) then
		self:Close();
	end
end

function SpellFlyoutMixin:OnShow()
	if (self.eventsRegistered == false) then
		self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
		self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
		self:RegisterEvent("SPELL_UPDATE_USABLE");
		self:RegisterEvent("BAG_UPDATE");
		self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
		self:RegisterEvent("PET_STABLE_UPDATE");
		self:RegisterEvent("PET_STABLE_SHOW");
		self:RegisterEvent("SPELL_FLYOUT_UPDATE");
		EventRegistry:RegisterCallback("WorldMapMaximized", self.Close, self);
		EventRegistry:RegisterCallback("WorldMapOnShow", self.CloseIfWorldMapMaximized, self);
		self.eventsRegistered = true;
	end
end

function SpellFlyoutMixin:OnHide()
	FlyoutPopupMixin.OnHide(self);

	if (self.eventsRegistered == true) then
		self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
		self:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED");
		self:UnregisterEvent("SPELL_UPDATE_USABLE");
		self:UnregisterEvent("BAG_UPDATE");
		self:UnregisterEvent("ACTIONBAR_PAGE_CHANGED");
		self:UnregisterEvent("PET_STABLE_UPDATE");
		self:UnregisterEvent("PET_STABLE_SHOW");
		self:UnregisterEvent("SPELL_FLYOUT_UPDATE");
		EventRegistry:UnregisterCallback("WorldMapMaximized", self.Close);
		EventRegistry:UnregisterCallback("WorldMapOnShow", self.CloseIfWorldMapMaximized);
		self.eventsRegistered = false;
	end

	self.glyphActivating = false;
end

function SpellFlyoutMixin:GetFlyoutButtonForSpell(spellID)
	if (not self:IsShown()) then
		return nil;
	end

	local i = 1;
	local button = _G["SpellFlyoutPopupButton"..i];
	while (button and button:IsShown()) do
		if (button.spellID == spellID) then
			return button;
		end
		i = i+1;
		button = _G["SpellFlyoutPopupButton"..i];
	end
	return nil;
end
