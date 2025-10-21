
local SPELLFLYOUT_DEFAULT_SPACING = 4;
local SPELLFLYOUT_INITIAL_SPACING = 7;
local SPELLFLYOUT_FINAL_SPACING = 4;

SpellFlyoutMixin = {};
SpellFlyoutButtonMixin = {};

function SpellFlyoutButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	_G[self:GetName() .. "Count"]:SetPoint("BOTTOMRIGHT", 0, 0);
	_G[self:GetName() .. "Icon"]:SetTexCoord(0.0625, 0.9375, 0.0625, 0.9375);
end

function SpellFlyoutButtonMixin:OnClick(button)
	if not self.spellID then
		return;
	end

	if ( IsModifiedClick("CHATLINK") ) then
		if ( MacroFrameText and MacroFrameText:HasFocus() ) then
			if ( self.spellName ) then
				ChatEdit_InsertLink(self.spellName);
			end
		else
			local spellLink, tradeSkillLink = GetSpellLink(self.spellID);
			if ( tradeSkillLink ) then
				ChatEdit_InsertLink(tradeSkillLink);
			elseif ( spellLink ) then
				ChatEdit_InsertLink(spellLink);
			end
		end
		self:UpdateState();
	else
		if (CastSpellByID(self.spellID)) then
			self:GetParent():Hide();
		end
	end
end

function SpellFlyoutButtonMixin:OnEnter()
	self:SetTooltip();
end

function SpellFlyoutButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function SpellFlyoutButtonMixin:OnDragStart()
	if (not self:GetParent().isActionBar or not GetCVarBool("lockActionBars") or IsModifiedClick("PICKUPACTION")) then
		if (self.spellID) then
			PickupSpell(self.spellID);
		end
	end
end

function SpellFlyoutButtonMixin:SetTooltip()
	if ( GetCVar("UberTooltips") == "1" ) then
		if (SpellFlyout.isActionBar) then
			GameTooltip_SetDefaultAnchor(GameTooltip, self);
		else
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 4, 4);
		end
		if ( GameTooltip:SetSpellByID(self.spellID) ) then
			self.UpdateTooltip = function() self:SetTooltip(); end;
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
		local spellName = GetSpellInfo(self.spellID);
		GameTooltip:SetText(spellName, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		self.UpdateTooltip = nil;
	end
end

function SpellFlyoutButtonMixin:UpdateCooldown()
	ActionButton_UpdateCooldown(self);
end

function SpellFlyoutButtonMixin:UpdateState()
	self:SetChecked(C_Spell.IsCurrentSpell(self.spellID));
end

function SpellFlyoutButtonMixin:UpdateUsable()
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

function SpellFlyoutButtonMixin:UpdateCount()
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

function SpellFlyoutMixin:OnLoad()
	self.eventsRegistered = false;
end

function SpellFlyoutMixin:OnEvent(event, ...)
	if (event == "SPELL_UPDATE_COOLDOWN") then
		local i = 1;
		local button = _G["SpellFlyoutButton"..i];
		while (button and button:IsShown()) do
			button:UpdateCooldown();
			i = i+1;
			button = _G["SpellFlyoutButton"..i];
		end
	elseif (event == "CURRENT_SPELL_CAST_CHANGED") then
		local i = 1;
		local button = _G["SpellFlyoutButton"..i];
		while (button and button:IsShown()) do
			button:UpdateState();
			i = i+1;
			button = _G["SpellFlyoutButton"..i];
		end
	elseif (event == "SPELL_UPDATE_USABLE") then
		local i = 1;
		local button = _G["SpellFlyoutButton"..i];
		while (button and button:IsShown()) do
			button:UpdateUsable();
			i = i+1;
			button = _G["SpellFlyoutButton"..i];
		end
	elseif (event == "BAG_UPDATE") then
		local i = 1;
		local button = _G["SpellFlyoutButton"..i];
		while (button and button:IsShown()) do
			button:UpdateCount();
			button:UpdateUsable();
			i = i+1;
			button = _G["SpellFlyoutButton"..i];
		end
	elseif (event == "SPELL_FLYOUT_UPDATE") then
		local i = 1;
		local button = _G["SpellFlyoutButton"..i];
		while (button and button:IsShown()) do
			button:UpdateCooldown();
			button:UpdateState();
			button:UpdateUsable();
			button:UpdateCount();
			i = i+1;
			button = _G["SpellFlyoutButton"..i];
		end
	elseif (event == "PET_STABLE_UPDATE" or event == "PET_STABLE_SHOW") then
		self:Hide();
	elseif (event == "ACTIONBAR_PAGE_CHANGED") then
		self:Hide();
	end
end

function SpellFlyoutMixin:Toggle(flyoutID, parent, direction, distance, isActionBar)

	if (self:IsShown() and self:GetParent() == parent) then
		self:Hide();
		return;
	end
	
	-- Save previous parent to update at the end
	local oldParent = self:GetParent();
	local oldIsActionBar = self.isActionBar;

	local _, _, numSlots, isKnown = GetFlyoutInfo(flyoutID);
	local actionBar = parent:GetParent();
	self:SetParent(parent);
	self.isActionBar = isActionBar;
	
	-- Make sure this flyout is known
	if (not isKnown or numSlots == 0) then
		self:Hide();
		return;
	end
	
	if (not direction) then
		direction = "UP";
	end
	
	-- Update all spell buttons for this flyout
	local prevButton = nil;
	local numButtons = 0;
	for i=1, numSlots do
		local spellID, overrideSpellID, isKnownSlot, spellName = GetFlyoutSlotInfo(flyoutID, i);
		local visible = true;
		
		-- Ignore Call Pet spells if there isn't a pet in that slot
		local petIndex, petName = GetCallPetSpellInfo(spellID);
		if (isActionBar and petIndex and (not petName or petName == "")) then
			visible = false;
		end
		
		if (isKnownSlot and visible) then
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
			
			_G[button:GetName().."Icon"]:SetTexture(GetSpellTexture(spellID));
			button.spellID = spellID;
			button:UpdateCooldown();
			button:UpdateState();
			button:UpdateUsable();
			button:UpdateCount();
			
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
	
	self.BgEnd:ClearAllPoints();
	if (direction == "UP") then
		self:SetPoint("BOTTOM", parent, "TOP", 0, 0);
		self.BgEnd:SetPoint("TOP");
		SetClampedTextureRotation(self.BgEnd, 0);
		self.HorizBg:Hide();
		self.VertBg:Show();
		self.VertBg:ClearAllPoints();
		self.VertBg:SetPoint("TOP", self.BgEnd, "BOTTOM");
		self.VertBg:SetPoint("BOTTOM", 0, distance);
	elseif (direction == "DOWN") then
		self:SetPoint("TOP", parent, "BOTTOM", 0, 0);
		self.BgEnd:SetPoint("BOTTOM");
		SetClampedTextureRotation(self.BgEnd, 180);
		self.HorizBg:Hide();
		self.VertBg:Show();
		self.VertBg:ClearAllPoints();
		self.VertBg:SetPoint("BOTTOM", self.BgEnd, "TOP");
		self.VertBg:SetPoint("TOP", 0, -distance);
	elseif (direction == "LEFT") then
		self:SetPoint("RIGHT", parent, "LEFT", 0, 0);
		self.BgEnd:SetPoint("LEFT");
		SetClampedTextureRotation(self.BgEnd, 270);
		self.VertBg:Hide();
		self.HorizBg:Show();
		self.HorizBg:ClearAllPoints();
		self.HorizBg:SetPoint("LEFT", self.BgEnd, "RIGHT");
		self.HorizBg:SetPoint("RIGHT", -distance, 0);
	elseif (direction == "RIGHT") then
		self:SetPoint("LEFT", parent, "RIGHT", 0, 0);
		self.BgEnd:SetPoint("RIGHT");
		SetClampedTextureRotation(self.BgEnd, 90);
		self.VertBg:Hide();
		self.HorizBg:Show();
		self.HorizBg:ClearAllPoints();
		self.HorizBg:SetPoint("RIGHT", self.BgEnd, "LEFT");
		self.HorizBg:SetPoint("LEFT", distance, 0);
	end
	
	if (direction == "UP" or direction == "DOWN") then
		self:SetWidth(prevButton:GetWidth());
		self:SetHeight((prevButton:GetHeight()+SPELLFLYOUT_DEFAULT_SPACING) * numButtons - SPELLFLYOUT_DEFAULT_SPACING + SPELLFLYOUT_INITIAL_SPACING + SPELLFLYOUT_FINAL_SPACING);
	else
		self:SetHeight(prevButton:GetHeight());
		self:SetWidth((prevButton:GetWidth()+SPELLFLYOUT_DEFAULT_SPACING) * numButtons - SPELLFLYOUT_DEFAULT_SPACING + SPELLFLYOUT_INITIAL_SPACING + SPELLFLYOUT_FINAL_SPACING);
	end
	
	self:SetBorderColor(0.7, 0.7, 0.7);
	
	self:Show();

	if (oldParent and oldIsActionBar) then
		ActionButton_UpdateFlyout(oldParent);
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
		self.eventsRegistered = true;
	end
	if (self.isActionBar) then
		ActionButton_UpdateFlyout(self:GetParent());
	end
end

function SpellFlyoutMixin:OnHide()
	if (self.eventsRegistered == true) then
		self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
		self:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED");
		self:UnregisterEvent("SPELL_UPDATE_USABLE");
		self:UnregisterEvent("BAG_UPDATE");
		self:UnregisterEvent("ACTIONBAR_PAGE_CHANGED");
		self:UnregisterEvent("PET_STABLE_UPDATE");
		self:UnregisterEvent("PET_STABLE_SHOW");
		self:UnregisterEvent("SPELL_FLYOUT_UPDATE");
		self.eventsRegistered = false;
	end
	if (self:IsShown()) then
		self:Hide();
	end
	if (self.isActionBar) then
		ActionButton_UpdateFlyout(self:GetParent());
	end
end

function SpellFlyoutMixin:SetBorderColor(r, g, b)
	self.HorizBg:SetVertexColor(r, g, b);
	self.VertBg:SetVertexColor(r, g, b);
	self.BgEnd:SetVertexColor(r, g, b);
end
