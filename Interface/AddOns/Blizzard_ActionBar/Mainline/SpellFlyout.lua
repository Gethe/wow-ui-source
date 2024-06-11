
local SPELLFLYOUT_DEFAULT_SPACING = 4;
local SPELLFLYOUT_INITIAL_SPACING = 7;
local SPELLFLYOUT_FINAL_SPACING = 9;

SpellFlyoutOpenReason = EnumUtil.MakeEnum("GlyphPending", "GlyphActivated");

function SpellFlyoutButton_OnClick(self)

	if ( IsModifiedClick("CHATLINK") ) then
		if ( MacroFrameText and MacroFrameText:HasFocus() ) then
			if ( self.spellName ) then
				ChatEdit_InsertLink(self.spellName);
			end
		else
			local tradeSkillLink = C_Spell.GetSpellTradeSkillLink(self.spellID);
			if ( tradeSkillLink ) then
				ChatEdit_InsertLink(tradeSkillLink);
			else
				local spellLink = C_Spell.GetSpellLink(self.spellID);
				ChatEdit_InsertLink(spellLink);
			end
		end
		SpellFlyoutButton_UpdateState(self);
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
			self:GetParent():Hide();
		elseif ( self.spellName ) then
			CastSpellByName(self.spellName);
			self:GetParent():Hide();
		end
	end
end

function SpellFlyoutButton_OnDrag(self)
	if (not self:GetParent().isActionBar or not Settings.GetValue("lockActionBars") or IsModifiedClick("PICKUPACTION")) then
		if (self.spellID) then
			C_Spell.PickupSpell(self.spellID);
		end
	end
end

function SpellFlyoutButton_SetTooltip(self)
	if ( GetCVar("UberTooltips") == "1" or self.showFullTooltip ) then
		if (SpellFlyout.isActionBar) then
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 4, 4);
		end
		if ( GameTooltip:SetSpellByID(self.spellID) ) then
			self.UpdateTooltip = SpellFlyoutButton_SetTooltip;
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

function SpellFlyoutButton_UpdateCooldown(self)
	ActionButton_UpdateCooldown(self);
end

function SpellFlyoutButton_UpdateState(self)
	if ( C_Spell.IsCurrentSpell(self.spellID) ) then
		self:SetChecked(true);
	else
		self:SetChecked(false);
	end
end

function SpellFlyoutButton_UpdateUsable(self)
	local isUsable, notEnoughMana = C_Spell.IsSpellUsable(self.spellID);
	local name = self:GetName();
	local icon = _G[name.."Icon"];
	if ( isUsable or not self:GetParent().isActionBar) then
		icon:SetVertexColor(1.0, 1.0, 1.0);
	elseif ( notEnoughMana ) then
		icon:SetVertexColor(0.5, 0.5, 1.0);
	else
		icon:SetVertexColor(0.4, 0.4, 0.4);
	end
end

function SpellFlyoutButton_UpdateGlyphState(self, reason)
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

function SpellFlyoutButton_UpdateCount (self)
	local text = _G[self:GetName().."Count"];
	if ( IsConsumableSpell(self.spellID)) then
		local count = C_Spell.GetSpellCastCount(self.spellID);
		if ( count > (self.maxDisplayCount or 9999 ) ) then
			text:SetText("*");
		else
			text:SetText(count);
		end
	else
		text:SetText("");
	end
end

function SpellFlyout_OnLoad(self)
	self.Toggle = SpellFlyout_Toggle;
	self.SetBorderColor = SpellFlyout_SetBorderColor;
	self.SetBorderSize = SpellFlyout_SetBorderSize;
	self.GetFlyoutButtonForSpell = SpellFlyout_GetFlyoutButtonForSpell;
	self.eventsRegistered = false;
end

function SpellFlyout_OnEvent(self, event, ...)
	if (event == "SPELL_UPDATE_COOLDOWN") then
		local i = 1;
		local button = _G["SpellFlyoutButton"..i];
		while (button and button:IsShown()) do
			SpellFlyoutButton_UpdateCooldown(button);
			i = i+1;
			button = _G["SpellFlyoutButton"..i];
		end
	elseif (event == "CURRENT_SPELL_CAST_CHANGED") then
		local i = 1;
		local button = _G["SpellFlyoutButton"..i];
		while (button and button:IsShown()) do
			SpellFlyoutButton_UpdateState(button);
			i = i+1;
			button = _G["SpellFlyoutButton"..i];
		end
	elseif (event == "SPELL_UPDATE_USABLE") then
		local i = 1;
		local button = _G["SpellFlyoutButton"..i];
		while (button and button:IsShown()) do
			SpellFlyoutButton_UpdateUsable(button);
			i = i+1;
			button = _G["SpellFlyoutButton"..i];
		end
	elseif (event == "BAG_UPDATE") then
		local i = 1;
		local button = _G["SpellFlyoutButton"..i];
		while (button and button:IsShown()) do
			SpellFlyoutButton_UpdateCount(button);
			SpellFlyoutButton_UpdateUsable(button);
			i = i+1;
			button = _G["SpellFlyoutButton"..i];
		end
	elseif (event == "SPELL_FLYOUT_UPDATE") then
		local i = 1;
		local button = _G["SpellFlyoutButton"..i];
		while (button and button:IsShown()) do
			SpellFlyoutButton_UpdateCooldown(button);
			SpellFlyoutButton_UpdateState(button);
			SpellFlyoutButton_UpdateUsable(button);
			SpellFlyoutButton_UpdateCount(button);
			SpellFlyoutButton_UpdateGlyphState(button);
			i = i+1;
			button = _G["SpellFlyoutButton"..i];
		end
	elseif (event == "PET_STABLE_UPDATE" or event == "PET_STABLE_SHOW") then
		self:Hide();
	elseif (event == "ACTIONBAR_PAGE_CHANGED") then
		self:Hide();
	end
end

function SpellFlyout_Toggle(self, flyoutID, parent, direction, distance, isActionBar, specID, showFullTooltip, reason)
	if (self:IsShown() and self:GetParent() == parent) then
		self.glyphActivating = false;
		self:Hide();
		return;
	end

	if (self:IsShown() and self.glyphActivating) then
		return;
	end

	local offSpec = specID and (specID ~= 0);

	-- Save previous parent to update at the end
	local oldParent = self:GetParent();
	local oldIsActionBar = self.isActionBar;

	local _, _, numSlots, isKnown = GetFlyoutInfo(flyoutID);
	self:SetParent(parent);
	self.isActionBar = isActionBar;

	-- Make sure this flyout is known or we are showing an offSpec flyout
	if ((not isKnown and not offSpec) or numSlots == 0) then
		self:Hide();
		return;
	end

	if (not direction) then
		direction = "UP";
	end

	-- If you're on an action bar then base your direction on the action bar's orientation and position
	if (isActionBar) then
		direction = parent.bar:GetSpellFlyoutDirection();
	end

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
			local button = _G["SpellFlyoutButton"..numButtons+1];
			if (not button) then
				button = CreateFrame("CHECKBUTTON", "SpellFlyoutButton"..numButtons+1, SpellFlyout, "SpellFlyoutButtonTemplate");
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
			SpellFlyoutButton_UpdateCooldown(button);
			SpellFlyoutButton_UpdateState(button);
			SpellFlyoutButton_UpdateUsable(button);
			SpellFlyoutButton_UpdateCount(button);
			SpellFlyoutButton_UpdateGlyphState(button, reason);

			prevButton = button;
			numButtons = numButtons+1;
		end
	end

	-- Hide unused buttons
	local unusedButtonIndex = numButtons+1;
	while (_G["SpellFlyoutButton"..unusedButtonIndex]) do
		_G["SpellFlyoutButton"..unusedButtonIndex]:Hide();
		unusedButtonIndex = unusedButtonIndex+1;
	end

	if (numButtons == 0) then
		self:Hide();
		return;
	end

	-- Show the flyout
	self:SetFrameStrata("DIALOG");
	self:ClearAllPoints();

	if (not distance) then
		distance = 0;
	end

	self.Background.End:ClearAllPoints();
	self.Background.Start:ClearAllPoints();
	if (direction == "UP") then
		self:SetPoint("BOTTOM", parent, "TOP");
		self.Background.End:SetPoint("TOP", 0, SPELLFLYOUT_INITIAL_SPACING);
		SetClampedTextureRotation(self.Background.End, 0);
		SetClampedTextureRotation(self.Background.VerticalMiddle, 0);
		self.Background.Start:SetPoint("TOP", self.Background.VerticalMiddle, "BOTTOM");
		SetClampedTextureRotation(self.Background.Start, 0);
		self.Background.HorizontalMiddle:Hide();
		self.Background.VerticalMiddle:Show();
		self.Background.VerticalMiddle:ClearAllPoints();
		self.Background.VerticalMiddle:SetPoint("TOP", self.Background.End, "BOTTOM");
		self.Background.VerticalMiddle:SetPoint("BOTTOM", 0, distance);
	elseif (direction == "DOWN") then
		self:SetPoint("TOP", parent, "BOTTOM");
		self.Background.End:SetPoint("BOTTOM", 0, -SPELLFLYOUT_INITIAL_SPACING);
		SetClampedTextureRotation(self.Background.End, 180);
		SetClampedTextureRotation(self.Background.VerticalMiddle, 180);
		self.Background.Start:SetPoint("BOTTOM", self.Background.VerticalMiddle, "TOP");
		SetClampedTextureRotation(self.Background.Start, 180);
		self.Background.HorizontalMiddle:Hide();
		self.Background.VerticalMiddle:Show();
		self.Background.VerticalMiddle:ClearAllPoints();
		self.Background.VerticalMiddle:SetPoint("BOTTOM", self.Background.End, "TOP");
		self.Background.VerticalMiddle:SetPoint("TOP", 0, -distance);
	elseif (direction == "LEFT") then
		self:SetPoint("RIGHT", parent, "LEFT");
		self.Background.End:SetPoint("LEFT", -SPELLFLYOUT_INITIAL_SPACING, 0);
		SetClampedTextureRotation(self.Background.End, 270);
		SetClampedTextureRotation(self.Background.HorizontalMiddle, 180);
		self.Background.Start:SetPoint("LEFT", self.Background.HorizontalMiddle, "RIGHT");
		SetClampedTextureRotation(self.Background.Start, 270);
		self.Background.VerticalMiddle:Hide();
		self.Background.HorizontalMiddle:Show();
		self.Background.HorizontalMiddle:ClearAllPoints();
		self.Background.HorizontalMiddle:SetPoint("LEFT", self.Background.End, "RIGHT");
		self.Background.HorizontalMiddle:SetPoint("RIGHT", -distance, 0);
	elseif (direction == "RIGHT") then
		self:SetPoint("LEFT", parent, "RIGHT");
		self.Background.End:SetPoint("RIGHT", SPELLFLYOUT_INITIAL_SPACING, 0);
		SetClampedTextureRotation(self.Background.End, 90);
		SetClampedTextureRotation(self.Background.HorizontalMiddle, 0);
		self.Background.Start:SetPoint("RIGHT", self.Background.HorizontalMiddle, "LEFT");
		SetClampedTextureRotation(self.Background.Start, 90);
		self.Background.VerticalMiddle:Hide();
		self.Background.HorizontalMiddle:Show();
		self.Background.HorizontalMiddle:ClearAllPoints();
		self.Background.HorizontalMiddle:SetPoint("RIGHT", self.Background.End, "LEFT");
		self.Background.HorizontalMiddle:SetPoint("LEFT", distance, 0);
	end

	self:Layout();

	self.direction = direction;
	self:SetBorderColor(0.7, 0.7, 0.7);
	self:SetBorderSize(47);

	self:Show();

	if (oldParent and oldIsActionBar) then
		oldParent:UpdateFlyout();
	end
end

function SpellFlyout_HideIfWorldMapMaximized(self)
	if (WorldMapFrame:IsMaximized()) then
		self:Hide();
	end
end

function SpellFlyout_OnShow(self)
	if (self.eventsRegistered == false) then
		self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
		self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
		self:RegisterEvent("SPELL_UPDATE_USABLE");
		self:RegisterEvent("BAG_UPDATE");
		self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
		self:RegisterEvent("PET_STABLE_UPDATE");
		self:RegisterEvent("PET_STABLE_SHOW");
		self:RegisterEvent("SPELL_FLYOUT_UPDATE");
		EventRegistry:RegisterCallback("WorldMapMaximized", self.Hide, self);
		EventRegistry:RegisterCallback("WorldMapOnShow", SpellFlyout_HideIfWorldMapMaximized, self);
		self.eventsRegistered = true;
	end
	if (self.isActionBar) then
		self:GetParent():UpdateFlyout();
	end
end

function SpellFlyout_OnHide(self)
	if (self.eventsRegistered == true) then
		self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
		self:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED");
		self:UnregisterEvent("SPELL_UPDATE_USABLE");
		self:UnregisterEvent("BAG_UPDATE");
		self:UnregisterEvent("ACTIONBAR_PAGE_CHANGED");
		self:UnregisterEvent("PET_STABLE_UPDATE");
		self:UnregisterEvent("PET_STABLE_SHOW");
		self:UnregisterEvent("SPELL_FLYOUT_UPDATE");
		EventRegistry:UnregisterCallback("WorldMapMaximized", self.Hide);
		EventRegistry:UnregisterCallback("WorldMapOnShow", SpellFlyout_HideIfWorldMapMaximized);
		self.eventsRegistered = false;
	end
	if (self:IsShown()) then
		self:Hide();
	end
	if (self.isActionBar) then
		self:GetParent():UpdateFlyout();
	end
end

function SpellFlyout_SetBorderColor(self, r, g, b)
	self.Background.Start:SetVertexColor(r, g, b);
	self.Background.HorizontalMiddle:SetVertexColor(r, g, b);
	self.Background.VerticalMiddle:SetVertexColor(r, g, b);
	self.Background.End:SetVertexColor(r, g, b);
end

function SpellFlyout_SetBorderSize(self, size)
	if (not self.direction or self.direction == "UP" or self.direction == "DOWN") then
		self.Background.Start:SetWidth(size);
		self.Background.HorizontalMiddle:SetWidth(size);
		self.Background.VerticalMiddle:SetWidth(size);
		self.Background.End:SetWidth(size);
	else
		self.Background.Start:SetHeight(size);
		self.Background.HorizontalMiddle:SetHeight(size);
		self.Background.VerticalMiddle:SetHeight(size);
		self.Background.End:SetHeight(size);
	end
end

function SpellFlyout_GetFlyoutButtonForSpell(self, spellID)
	if (not self:IsShown()) then
		return nil;
	end

	local i = 1;
	local button = _G["SpellFlyoutButton"..i];
	while (button and button:IsShown()) do
		if (button.spellID == spellID) then
			return button;
		end
		i = i+1;
		button = _G["SpellFlyoutButton"..i];
	end
	return nil;
end