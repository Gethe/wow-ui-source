
-- globals
MULTICASTACTIONBAR_SLIDETIME = 0.09;
MULTICASTACTIONBAR_YPOS = 0;
MULTICASTACTIONBAR_XPOS = 30;
NUM_MULTI_CAST_PAGES = 3;
NUM_MULTI_CAST_BUTTONS_PER_PAGE = 4;		-- NOTE: must match MAX_TOTEMS!!!

-- locals
local MULTI_CAST_FLYOUT_BUTTON_INITIAL_OFFSET = 4;
local MULTI_CAST_FLYOUT_BUTTON_OFFSET = 2;
local MULTI_CAST_FLYOUT_CLOSE_SEC = 3;

local SLOT_EMPTY_TCOORDS = {
	[EARTH_TOTEM_SLOT] = {
		left	= 66 / 128,
		right	= 96 / 128,
		top		= 3 / 256,
		bottom	= 33 / 256,
	},
	[FIRE_TOTEM_SLOT] = {
		left	= 67 / 128,
		right	= 97 / 128,
		top		= 100 / 256,
		bottom	= 130 / 256,
	},
	[WATER_TOTEM_SLOT] = {
		left	= 39 / 128,
		right	= 69 / 128,
		top		= 209 / 256,
		bottom	= 239 / 256,
	},
	[AIR_TOTEM_SLOT] = {
		left	= 66 / 128,
		right	= 96 / 128,
		top		= 36 / 256,
		bottom	= 66 / 256,
	},
};
local SLOT_OVERLAY_TCOORDS = {
	[EARTH_TOTEM_SLOT] = {
		left	= 1 / 128,
		right	= 35 / 128,
		top		= 172 / 256,
		bottom	= 206 / 256,
	},
	[FIRE_TOTEM_SLOT] = {
		left	= 36 / 128,
		right	= 70 / 128,
		top		= 172 / 256,
		bottom	= 206 / 256,
	},
	[WATER_TOTEM_SLOT] = {
		left	= 1 / 128,
		right	= 35 / 128,
		top		= 207 / 256,
		bottom	= 240 / 256,
	},
	[AIR_TOTEM_SLOT] = {
		left	= 36 / 128,
		right	= 70 / 128,
		top		= 137 / 256,
		bottom	= 171 / 256,
	},
};

local FLYOUT_UP_BUTTON_TCOORDS = {
	["summon"] = {
		left	= 99 / 128,
		right	= 127 / 128,
		top		= 84 / 256,
		bottom	= 102 / 256,
	},
	[EARTH_TOTEM_SLOT] = {
		left	= 99 / 128,
		right	= 127 / 128,
		top		= 160 / 256,
		bottom	= 178 / 256,
	},
	[FIRE_TOTEM_SLOT] = {
		left	= 99 / 128,
		right	= 127 / 128,
		top		= 122 / 256,
		bottom	= 140 / 256,
	},
	[WATER_TOTEM_SLOT] = {
		left	= 99 / 128,
		right	= 127 / 128,
		top		= 199 / 256,
		bottom	= 217 / 256,
	},
	[AIR_TOTEM_SLOT] = {
		left	= 99 / 128,
		right	= 127 / 128,
		top		= 237 / 256,
		bottom	= 255 / 256,
	},
};
local FLYOUT_DOWN_BUTTON_TCOORDS = {
	["summon"] = {
		left	= 99 / 128,
		right	= 127 / 128,
		top		= 65 / 256,
		bottom	= 83 / 256,
	},
	[EARTH_TOTEM_SLOT] = {
		left	= 99 / 128,
		right	= 127 / 128,
		top		= 141 / 256,
		bottom	= 159 / 256,
	},
	[FIRE_TOTEM_SLOT] = {
		left	= 99 / 128,
		right	= 127 / 128,
		top		= 103 / 256,
		bottom	= 121 / 256,
	},
	[WATER_TOTEM_SLOT] = {
		left	= 99 / 128,
		right	= 127 / 128,
		top		= 180 / 256,
		bottom	= 198 / 256,
	},
	[AIR_TOTEM_SLOT] = {
		left	= 99 / 128,
		right	= 127 / 128,
		top		= 218 / 256,
		bottom	= 236 / 256,
	},
};
local FLYOUT_TOP_TCOORDS = {
	["summon"] = {
		left	= 33 / 128,
		right	= 65 / 128,
		top		= 1 / 256,
		bottom	= 23 / 256,
	},
	[EARTH_TOTEM_SLOT] = {
		left	= 0 / 128,
		right	= 32 / 128,
		top		= 46 / 256,
		bottom	= 68 / 256,
	},
	[FIRE_TOTEM_SLOT] = {
		left	= 33 / 128,
		right	= 65 / 128,
		top		= 46 / 256,
		bottom	= 68 / 256,
	},
	[WATER_TOTEM_SLOT] = {
		left	= 0 / 128,
		right	= 32 / 128,
		top		= 1 / 256,
		bottom	= 23 / 256,
	},
	[AIR_TOTEM_SLOT] = {
		left	= 0 / 128,
		right	= 32 / 128,
		top		= 91 / 256,
		bottom	= 113 / 256,
	},
};
local FLYOUT_MIDDLE_TCOORDS = {
	["summon"] = {
		left	= 33 / 128,
		right	= 65 / 128,
		top		= 23 / 256,
		bottom	= 43 / 256,
	},
	[EARTH_TOTEM_SLOT] = {
		left	= 0 / 128,
		right	= 32 / 128,
		top		= 68 / 256,
		bottom	= 88 / 256,
	},
	[FIRE_TOTEM_SLOT] = {
		left	= 33 / 128,
		right	= 65 / 128,
		top		= 68 / 256,
		bottom	= 88 / 256,
	},
	[WATER_TOTEM_SLOT] = {
		left	= 0 / 128,
		right	= 32 / 128,
		top		= 23 / 256,
		bottom	= 43 / 256,
	},
	[AIR_TOTEM_SLOT] = {
		left	= 0 / 128,
		right	= 32 / 128,
		top		= 113 / 256,
		bottom	= 133 / 256,
	},
};

-- knownMultiCastSummonSpells
-- index: TOTEM_MULTI_CAST_SUMMON_SPELLS 
-- value: spellId if the spell is known, nil otherwise
local knownMultiCastSummonSpells = { };
-- knownMultiCastRecallSpells
-- index: TOTEM_MULTI_CAST_RECALL_SPELLS 
-- value: spellId if the spell is known, nil otherwise
local knownMultiCastRecallSpells = { };

local function _ComputeMultiCastSlot(id)
	return mod(id - 1, NUM_MULTI_CAST_BUTTONS_PER_PAGE) + 1;
end

--
-- MultiCastActionBar
--

function MultiCastActionBarFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR");

	self.currentPage = 1;
	MultiCastSummonSpellButton:SetID(self.currentPage);

	self.numActiveSlots = 0;
end

function MultiCastActionBarFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_MULTI_CAST_ACTIONBAR" ) then
		MultiCastActionBarFrame_Update(self);
		if ( HasMultiCastActionBar() ) then
			ShowMultiCastActionBar();
			LockMultiCastActionBar();
		else
			UnlockMultiCastActionBar();
			HideMultiCastActionBar();
		end
	end
end

function MultiCastActionBarFrame_OnUpdate(self, elapsed)
	local yPos;
	if ( self.slideTimer and (self.slideTimer < self.timeToSlide) ) then
		self.completed = false;
		if ( self.mode == "show" ) then
			yPos = (self.slideTimer/self.timeToSlide) * MULTICASTACTIONBAR_YPOS;
			self:SetPoint("BOTTOMLEFT", self:GetParent(), "TOPLEFT", MULTICASTACTIONBAR_XPOS, yPos);
			self.state = "showing";
			self:Show();
		elseif ( self.mode == "hide" ) then
			yPos = (1 - (self.slideTimer/self.timeToSlide)) * MULTICASTACTIONBAR_YPOS;
			self:SetPoint("BOTTOMLEFT", self:GetParent(), "TOPLEFT", MULTICASTACTIONBAR_XPOS, yPos);
			self.state = "hiding";
		end
		self.slideTimer = self.slideTimer + elapsed;
	else
		self.completed = true;
		if ( self.mode == "show" ) then
			self:SetPoint("BOTTOMLEFT", self:GetParent(), "TOPLEFT", MULTICASTACTIONBAR_XPOS, MULTICASTACTIONBAR_YPOS);
			self.state = "top";
			--Move the chat frame and edit box up a bit
		elseif ( self.mode == "hide" ) then
			self:SetPoint("BOTTOMLEFT", self:GetParent(), "TOPLEFT", MULTICASTACTIONBAR_XPOS, 0);
			self.state = "bottom";
			self:Hide();
			--Move the chat frame and edit box back down to original position
		end
		self.mode = "none";
	end
end

function ShowMultiCastActionBar(doNotSlide)
	if ( (not MainMenuBar.busy) and (not UnitHasVehicleUI("player")) ) then	--Don't change while we're animating out MainMenuBar for vehicle UI
		if ( (MultiCastActionBarFrame.mode ~= "show" and MultiCastActionBarFrame.state ~= "top") or (not UIParent:IsShown())) then
			MultiCastActionBarFrame:Show();
			if ( MultiCastActionBarFrame.completed ) then
				MultiCastActionBarFrame.slideTimer = 0;
			end
			MultiCastActionBarFrame.timeToSlide = MULTICASTACTIONBAR_SLIDETIME;
			MultiCastActionBarFrame.mode = "show";
		end
	end
end

function HideMultiCastActionBar()
	if ( (not MainMenuBar.busy) and (not UnitHasVehicleUI("player")) ) then	--Don't change while we're animating out MainMenuBar for vehicle UI
		if ( (MultiCastActionBarFrame:IsShown()) or (not UIParent:IsShown())) then
			if ( MultiCastActionBarFrame.completed ) then
				MultiCastActionBarFrame.slideTimer = 0;
			end
			MultiCastActionBarFrame.timeToSlide = MULTICASTACTIONBAR_SLIDETIME;
			MultiCastActionBarFrame.mode = "hide";
		end
	end
end

function LockMultiCastActionBar()
	MultiCastActionBarFrame.locked = true;
end

function UnlockMultiCastActionBar()
	MultiCastActionBarFrame.locked = false;
end

function MultiCastActionBarFrame_Update(self)
	local currentPage = self.currentPage;

	-- update the action buttons and slot buttons
	local slot;
	local actionButton, slotButton;
	local actionIndex;
	local slotIndex = 1;
	local inverseSlotIndex;
	local pageOffset;
	local actionId;
	for i = 1, NUM_MULTI_CAST_BUTTONS_PER_PAGE do
		slot = TOTEM_PRIORITIES[i];
		if ( GetTotemInfo(slot) and GetMultiCastTotemSpells(slot) ) then
			-- update the slot button
			slotButton = _G["MultiCastSlotButton"..slotIndex];
			MultiCastSlotButton_Update(slotButton, slot);
			-- update the action buttons using this totem slot on each page
			for j = 1, NUM_MULTI_CAST_PAGES do
				pageOffset = (j-1) * NUM_MULTI_CAST_BUTTONS_PER_PAGE;
				actionIndex = pageOffset + slotIndex;
				actionButton = _G["MultiCastActionButton"..actionIndex];
				actionButton.slotButton = slotButton;
				actionId = pageOffset + slot;
				MultiCastActionButton_Update(actionButton, actionId, actionIndex, slot);
				-- if this is the current page, store a reference to the action button on the slot button
				if ( j == currentPage ) then
					slotButton.actionButton = actionButton;
				end
			end
			slotIndex = slotIndex + 1;
		else
			inverseSlotIndex = NUM_MULTI_CAST_BUTTONS_PER_PAGE - i + slotIndex;
			-- hide the slot button
			slotButton = _G["MultiCastSlotButton"..inverseSlotIndex];
			MultiCastSlotButton_Update(slotButton, 0);
			-- hide the action buttons for this button index on each page
			for j = 1, NUM_MULTI_CAST_PAGES do
				pageOffset = (j-1) * NUM_MULTI_CAST_BUTTONS_PER_PAGE;
				actionIndex = pageOffset + inverseSlotIndex;
				actionButton = _G["MultiCastActionButton"..actionIndex];
				actionButton.slotButton = nil;
				actionId = pageOffset + slot;
				MultiCastActionButton_Update(actionButton, actionId, actionIndex, 0);
			end
			slotButton.actionButton = nil;
		end
	end

	self.numActiveSlots = slotIndex - 1;
	if ( self.numActiveSlots == 0 ) then
		self:Hide();
		return;
	end
	self:Show();

	-- update the multi cast spells
	MultiCastSummonSpellButton_Update(MultiCastSummonSpellButton);
	MultiCastRecallSpellButton_Update(MultiCastRecallSpellButton);
end

function HasMultiCastActionBar()
	return MultiCastActionBarFrame.numActiveSlots and MultiCastActionBarFrame.numActiveSlots > 0;
end

function HasMultiCastActionPage(page)
	return ( page >= 1 and page <= NUM_MULTI_CAST_PAGES and knownMultiCastSummonSpells[page] );
end

function ChangeMultiCastActionPage(page)
	local prevPage = MultiCastActionBarFrame.currentPage;
	if ( page ~= prevPage and HasMultiCastActionPage(page) ) then
		MultiCastActionBarFrame.currentPage = page;
		MultiCastSummonSpellButton:SetID(page);
		_G["MultiCastActionPage"..prevPage]:Hide();
		_G["MultiCastActionPage"..page]:Show();
		MultiCastActionBarFrame_Update(MultiCastActionBarFrame);
	end
end


--
-- MultiCastSlotButton
--


function MultiCastSlotButton_OnEvent(self, event, ...)
	if ( event == "MODIFIER_STATE_CHANGED" ) then
		if ( IsModifiedClick("SHOWMULTICASTFLYOUT") and self:IsMouseOver() ) then
			MultiCastSlotButton_OnEnter(self);
		end
	end
end

function MultiCastSlotButton_OnEnter(self)
	if ( MultiCastFlyoutFrame.parent ~= self ) then
		MultiCastFlyoutFrameOpenButton_Show(MultiCastFlyoutFrameOpenButton, "slot", self);
	end
--[[
	self:RegisterEvent("MODIFIER_STATE_CHANGED");
	if ( IsModifiedClick("SHOWMULTICASTFLYOUT") ) then
		local slot = self:GetID();
		MultiCastFlyoutFrame_ToggleFlyout(MultiCastFlyoutFrame, "slot", self);
	end
--]]
end

function MultiCastSlotButton_OnLeave(self)
	GameTooltip:Hide();
	MultiCastFlyoutFrameOpenButton_Hide(MultiCastFlyoutFrameOpenButton);
end

function MultiCastSlotButton_Update(self, slot)
	self:SetID(slot);
	if ( slot == 0 ) then
		self:Hide();
	else
		-- fixup textures
		local tcoords = SLOT_OVERLAY_TCOORDS[slot];
		self.overlay:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
		tcoords = SLOT_EMPTY_TCOORDS[slot];
		self.background:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);

		self:Show();
	end
end


--
-- MultiCastActionButton
--

function MultiCastActionButton_OnLoad(self)
	-- fixup textures
	local name = self:GetName();
	local normalTexture = _G[name.."NormalTexture"];
	normalTexture:SetWidth(50);
	normalTexture:SetHeight(50);

	-- setup action button stuff
	self.buttonType = "MULTICASTACTIONBUTTON";
	self.buttonIndex = self:GetID();
	ActionButton_OnLoad(self);
end

function MultiCastActionButton_OnEvent(self, event, ...)
	ActionButton_OnEvent(self, event, ...);
	if ( event == "MODIFIER_STATE_CHANGED" ) then
		if ( IsModifiedClick("SHOWMULTICASTFLYOUT") and self:IsMouseOver() ) then
			MultiCastActionButton_OnEnter(self);
		end
	end
end

function MultiCastActionButton_OnShow(self)
	if ( not self.slotButton ) then
		self:Hide();
	end
end

function MultiCastActionButton_OnEnter(self)
	MultiCastSlotButton_OnEnter(self.slotButton);
	ActionButton_SetTooltip(self);
end

function MultiCastActionButton_OnLeave(self)
	GameTooltip:Hide();
	MultiCastFlyoutFrameOpenButton_Hide(MultiCastFlyoutFrameOpenButton);
end

function MultiCastActionButton_OnPostClick(self, button, down)
	ActionButton_UpdateState(self, button, down);
	MultiCastFlyoutFrame_Hide(MultiCastFlyoutFrame, true);
end

function MultiCastActionButton_Update(self, id, index, slot)
	self:SetID(id);
	self.buttonIndex = index;
	if ( slot == 0 ) then
		self:Hide();
	else
		ActionButton_UpdateAction(self);
		ActionButton_Update(self);
		ActionButton_UpdateHotkeys(self, self.buttonType);

		-- fixup textures
		local tcoords;
		tcoords = SLOT_OVERLAY_TCOORDS[slot];
		self.overlay:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
		self:Show();
	end
end

function MultiCastActionButtonDown(id)
	local button = _G["MultiCastActionButton"..id];
	if ( button:GetButtonState() == "NORMAL" ) then
		button:SetButtonState("PUSHED");
	end
end

function MultiCastActionButtonUp(id)
	local button = _G["MultiCastActionButton"..id];
	if ( button:GetButtonState() == "PUSHED" ) then
		button:SetButtonState("NORMAL");
		SecureActionButton_OnClick(button, "LeftButton");
		ActionButton_UpdateState(button);
	end
	MultiCastFlyoutFrame_Hide(MultiCastFlyoutFrame, true);
end


--
-- MultiCastFlyoutButton
--

function MultiCastFlyoutButton_OnLoad(self)
	self:RegisterForClicks("AnyUp");

	local parent = self:GetParent();
	tinsert(parent.buttons, self);
end

function MultiCastFlyoutButton_OnClick(self)
	local parent = self:GetParent();

	if ( self.spellId ) then
		local type = parent.type;
		if ( type == "page" ) then
			ChangeMultiCastActionPage(self.page);
		elseif ( type == "slot" ) then
			SetMultiCastSpell(ActionButton_CalculateAction(parent.parent.actionButton), self.spellId);
		end
	end

	MultiCastFlyoutFrame_Hide(parent, true);
end

function MultiCastFlyoutButton_OnEnter(self)
	MultiCastFlyoutButton_SetTooltip(self);
end

function MultiCastFlyoutButton_OnLeave(self)
	GameTooltip:Hide();
end

function MultiCastFlyoutButton_SetTooltip(self)
	if ( self.spellId ) then
		if ( self.spellId == 0 ) then
			if ( GetCVarBool("UberTooltips") ) then
				GameTooltip_SetDefaultAnchor(GameTooltip, self);
			else
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			end
			GameTooltip:SetText(MULTI_CAST_TOOLTIP_NO_TOTEM, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			self.UpdateTooltip = nil;
		else
			if ( GetCVarBool("UberTooltips") ) then
				GameTooltip_SetDefaultAnchor(GameTooltip, self);
			else
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			end
			if ( GameTooltip:SetSpellByID(self.spellId, false, true) ) then
				self.UpdateTooltip = MultiCastFlyoutButton_SetTooltip;
			else
				self.UpdateTooltip = nil;
			end
		end
	end
end


--
-- MultiCastFlyoutFrame
--

function MultiCastFlyoutFrame_OnShow(self)
	MultiCastFlyoutFrameOpenButton_Hide(MultiCastFlyoutFrameOpenButton, true);
end

function MultiCastFlyoutFrame_OnHide(self)
	self.type = nil;
	self.parent = nil;
end

function MultiCastFlyoutFrame_OnEnter(self)
end

function MultiCastFlyoutFrame_OnLeave(self)
--[[
	if ( not self:IsMouseOver() ) then
		self.closeCountdownSec = MULTI_CAST_FLYOUT_CLOSE_SEC;
	end
--]]
end

function MultiCastFlyoutFrame_OnUpdate(self, elapsed)
--[[
	local closeCountdownSec = self.closeCountdownSec;
	if ( closeCountdownSec ) then
		closeCountdownSec = closeCountdownSec - elapsed;
		if ( closeCountdownSec <= 0 ) then
			self.closeCountdownSec = nil;
			self:Hide();
		else
			self.closeCountdownSec = closeCountdownSec;
		end
	end
--]]
end

function MultiCastFlyoutFrame_Hide(self, forceHide)
	if ( forceHide or not self:IsMouseOver() ) then
		if ( self.parent ) then
			if ( self.parent:IsMouseOver() ) then
				MultiCastFlyoutFrameOpenButton_Show(MultiCastFlyoutFrameOpenButton, self.type, self.parent);
			else
				self.parent:UnregisterEvent("MODIFIER_STATE_CHANGED");
			end
		end
		self:Hide();
	end
end

function MultiCastFlyoutFrame_ToggleFlyout(self, type, parent)
	if ( self:IsShown() and self.parent == parent ) then
		MultiCastFlyoutFrame_Hide(self, true);
	else
		local toptcoords;
		local midtcoords;
		local closetcoords;
		if ( type == "slot" ) then
			local actionId = parent:GetID();
			local slot = _ComputeMultiCastSlot(actionId);
			if ( MultiCastFlyoutFrame_LoadSlotSpells(self, slot, GetMultiCastTotemSpells(actionId)) ) then
				toptcoords = FLYOUT_TOP_TCOORDS[slot];
				midtcoords = FLYOUT_MIDDLE_TCOORDS[slot];
				closetcoords = FLYOUT_DOWN_BUTTON_TCOORDS[slot];
			end
		elseif ( type == "page" ) then
			if ( MultiCastFlyoutFrame_LoadPageSpells(self) ) then
				toptcoords = FLYOUT_TOP_TCOORDS["summon"];
				midtcoords = FLYOUT_MIDDLE_TCOORDS["summon"];
				closetcoords = FLYOUT_DOWN_BUTTON_TCOORDS["summon"];
			end
		end
		if ( toptcoords ) then
			self.type = type;
			self.parent = parent;
			self:SetPoint("BOTTOM", parent, "TOP", 0, 0);
			self:Show();

			self.top:SetTexCoord(toptcoords.left, toptcoords.right, toptcoords.top, toptcoords.bottom);
			self.middle:SetTexCoord(midtcoords.left, midtcoords.right, midtcoords.top, midtcoords.bottom);
			MultiCastFlyoutFrameCloseButton.normalTexture:SetTexCoord(closetcoords.left, closetcoords.right, closetcoords.top, closetcoords.bottom);
		end
	end
end

function MultiCastFlyoutFrame_LoadPageSpells(self)
	local numKnownSpells = 0;
	for i, spellId in next, TOTEM_MULTI_CAST_SUMMON_SPELLS do
		if ( knownMultiCastSummonSpells[i] ) then
			numKnownSpells = numKnownSpells + 1;
		end
	end
	if ( numKnownSpells == 0 ) then
		return false;
	end

	self.buttons = self.buttons or {};
	local buttons = self.buttons;
	local numButtons = #buttons;

	local name = self:GetName();
	local totalHeight = 0;
	local button;
	local spellId;
	local name, rank, icon;
	local buttonIndex = 1;
	for i, spellId in next, TOTEM_MULTI_CAST_SUMMON_SPELLS do
		if ( knownMultiCastSummonSpells[i] ) then
			-- create the button
			if ( buttonIndex <= numButtons ) then
				button = buttons[buttonIndex];
				if ( buttonIndex == 1 ) then
					totalHeight = totalHeight + MULTI_CAST_FLYOUT_BUTTON_INITIAL_OFFSET;
				else
					totalHeight = totalHeight + MULTI_CAST_FLYOUT_BUTTON_OFFSET;
				end
			else
				button = CreateFrame("Button", "MultiCastFlyoutButton"..buttonIndex, self, "MultiCastFlyoutButtonTemplate");
				if ( buttonIndex == 1 ) then
					-- this is the first button, anchor it to the frame
					button:SetPoint("BOTTOM", self, "BOTTOM", 0, MULTI_CAST_FLYOUT_BUTTON_INITIAL_OFFSET);
					totalHeight = totalHeight + MULTI_CAST_FLYOUT_BUTTON_INITIAL_OFFSET;
				else
					-- this is not the first button, anchor it to the previous button
					button:SetPoint("BOTTOM", buttons[buttonIndex - 1], "TOP", 0, MULTI_CAST_FLYOUT_BUTTON_OFFSET);
					totalHeight = totalHeight + MULTI_CAST_FLYOUT_BUTTON_OFFSET;
				end
			end
			totalHeight = totalHeight + button:GetHeight();

			-- setup the button
			button.page = i;
			spellId = TOTEM_MULTI_CAST_SUMMON_SPELLS[i];
			button.spellId = spellId;
			name, rank, icon = GetSpellInfo(spellId);
			button.icon:SetTexture(icon);
			button.icon:SetTexCoord(0.0, 1.0, 0.0, 1.0);

			button:Show();

			buttonIndex = buttonIndex + 1;
		end
	end
	-- hide unused buttons
	for i = buttonIndex, numButtons do
		buttons[i]:Hide();
	end

	self:SetHeight(totalHeight + 2 + MultiCastFlyoutFrameCloseButton:GetHeight());

	return true;
end

function MultiCastFlyoutFrame_LoadSlotSpells(self, slot, ...)
	local numSpells = select("#", ...);
	if ( numSpells == 0 ) then
		return false;
	end
	-- add one to numSpells to represent the "none" slot
	numSpells = numSpells + 1;

	self.buttons = self.buttons or {};
	local buttons = self.buttons;
	local numButtons = #buttons;

	local name = self:GetName();
	local totalHeight = 0;
	local button;
	local spellId;
	local name, rank, icon;
	local tcoords;
	local tcoordLeft, tcoordRight, tcoordTop, tcoordBottom;
	for i = 1, numSpells do
		-- create the button
		if ( i <= numButtons ) then
			button = buttons[i];
			if ( i == 1 ) then
				totalHeight = totalHeight + MULTI_CAST_FLYOUT_BUTTON_INITIAL_OFFSET;
			else
				totalHeight = totalHeight + MULTI_CAST_FLYOUT_BUTTON_OFFSET;
			end
		else
			button = CreateFrame("Button", "MultiCastFlyoutButton"..i, self, "MultiCastFlyoutButtonTemplate");
			button:ClearAllPoints();
			if ( i == 1 ) then
				-- this is the first button, anchor it to the frame
				button:SetPoint("BOTTOM", self, "BOTTOM", 0, MULTI_CAST_FLYOUT_BUTTON_INITIAL_OFFSET);
				totalHeight = totalHeight + MULTI_CAST_FLYOUT_BUTTON_INITIAL_OFFSET;
			else
				-- this is not the first button, anchor it to the previous button
				button:SetPoint("BOTTOM", buttons[i - 1], "TOP", 0, MULTI_CAST_FLYOUT_BUTTON_OFFSET);
				totalHeight = totalHeight + MULTI_CAST_FLYOUT_BUTTON_OFFSET;
			end
		end
		totalHeight = totalHeight + button:GetHeight();

		-- setup the button
		if ( i == 1 ) then
			-- the first button clears your slot
			spellId = 0;
			icon = "Interface\\Buttons\\UI-TotemBar";
			tcoords = SLOT_EMPTY_TCOORDS[slot];
			tcoordLeft, tcoordRight, tcoordTop, tcoordBottom = tcoords.left, tcoords.right, tcoords.top, tcoords.bottom;
		else
			spellId = select(i - 1, ...);
			name, rank, icon = GetSpellInfo(spellId);
			tcoordLeft, tcoordRight, tcoordTop, tcoordBottom = 0.0, 1.0, 0.0, 1.0;
		end
		button.spellId = spellId;
		button.icon:SetTexture(icon);
		button.icon:SetTexCoord(tcoordLeft, tcoordRight, tcoordTop, tcoordBottom);

		button:Show();
	end
	-- hide unused buttons
	for i = numSpells + 1, numButtons do
		buttons[i]:Hide();
	end

	self:SetHeight(totalHeight + 2 + MultiCastFlyoutFrameCloseButton:GetHeight());

	return true;
end


--
-- MultiCastFlyoutFrameCloseButton
--

function MultiCastFlyoutFrameCloseButton_OnClick(self)
	self:GetParent():Hide();
end


--
-- MultiCastFlyoutFrameOpenButton
--

function MultiCastFlyoutFrameOpenButton_OnClick(self)
	MultiCastFlyoutFrame_ToggleFlyout(MultiCastFlyoutFrame, self.type, self.parent);
end

function MultiCastFlyoutFrameOpenButton_OnLeave(self)
	self:Hide();
end

function MultiCastFlyoutFrameOpenButton_Show(self, type, parent)
	local tcoords;
	if ( type == "page" ) then
		tcoords = FLYOUT_UP_BUTTON_TCOORDS["summon"];
	elseif ( type == "slot" ) then
		local slot = _ComputeMultiCastSlot(parent:GetID());
		tcoords = FLYOUT_UP_BUTTON_TCOORDS[slot];
	end
	if ( tcoords ) then
		self.normalTexture:SetTexCoord(tcoords.left, tcoords.right, tcoords.top, tcoords.bottom);
		self.type = type;
		self.parent = parent;
		self:SetParent(parent);
		self:SetPoint("BOTTOM", parent, "TOP", 0, 0);
		self:Show();
	end
end

function MultiCastFlyoutFrameOpenButton_Hide(self, force)
	if ( force or (not self:IsMouseOver() and not self.parent:IsMouseOver()) ) then
		self.type = nil;
		self:Hide();
	end
end


--
-- MultiCastSpellButton
--

function MultiCastSpellButton_OnLoad(self)
	self:RegisterForClicks("AnyUp");

	local name = self:GetName();
	local normalTexture = _G[name.."NormalTexture"];
	normalTexture:SetWidth(50);
	normalTexture:SetHeight(50);
end

function MultiCastSpellButton_OnEvent(self, event, ...)
	if ( event == "UPDATE_BINDINGS" ) then
		ActionButton_UpdateHotkeys(self, self.buttonType);
	elseif ( event == "ACTIONBAR_UPDATE_COOLDOWN" ) then
		MultiCastSpellButton_UpdateCooldown(self);
	elseif ( event == "ACTIONBAR_UPDATE_STATE" ) then
		MultiCastSpellButton_UpdateState(self);
	end
end

function MultiCastSpellButton_OnEnter(self)
	MultiCastSpellButton_SetTooltip(self);
end

function MultiCastSpellButton_OnLeave(self)
	GameTooltip:Hide();
end

function MultiCastSpellButton_SetTooltip(self)
	if ( GetCVarBool("UberTooltips") ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end
	if ( GameTooltip:SetSpellByID(self.spellId, false, true) ) then
		self.UpdateTooltip = MultiCastSpellButton_SetTooltip;
	else
		self.UpdateTooltip = nil;
	end
end

function MultiCastSpellButton_UpdateCooldown(self)
	local cooldown = _G[self:GetName().."Cooldown"];
	local start, duration, enable = GetSpellCooldown(self.spellId);
	CooldownFrame_SetTimer(cooldown, start, duration, enable);
end

function MultiCastSpellButton_UpdateState(self)
	if ( IsCurrentSpell(self.spellId) ) then
		self:SetChecked(1);
	else
		self:SetChecked(nil);
	end
end


--
-- MultiCastSummonSpellButton
--

function MultiCastSummonSpellButton_OnLoad(self)
	self.buttonType = "MULTICASTSUMMONBUTTON";
	MultiCastSpellButton_OnLoad(self);
end

function MultiCastSummonSpellButton_OnEvent(self, event, ...)
	MultiCastSpellButton_OnEvent(self, event, ...);
--[[
	if ( event == "MODIFIER_STATE_CHANGED" ) then
		if ( IsModifiedClick("SHOWMULTICASTFLYOUT") and self:IsMouseOver() ) then
			MultiCastSummonSpellButton_OnEnter(self);
		end
	end
--]]
end

function MultiCastSummonSpellButton_OnClick(self)
	MultiCastSummonSpellButtonUp(self:GetID());
end

function MultiCastSummonSpellButton_OnEnter(self)
	MultiCastSpellButton_OnEnter(self);

	if ( MultiCastFlyoutFrame.parent ~= self ) then
		MultiCastFlyoutFrameOpenButton_Show(MultiCastFlyoutFrameOpenButton, "page", self);
	end
--[[
	self:RegisterEvent("MODIFIER_STATE_CHANGED");
	if ( IsModifiedClick("SHOWMULTICASTFLYOUT") ) then
		MultiCastFlyoutFrame_ToggleFlyout(MultiCastFlyoutFrame, "page", self);
	end
--]]
end

function MultiCastSummonSpellButton_OnLeave(self)
	MultiCastSpellButton_OnLeave(self);
	MultiCastFlyoutFrameOpenButton_Hide(MultiCastFlyoutFrameOpenButton);
end

function MultiCastSummonSpellButton_Update(self)
	-- first update which multi-cast spells we actually know
	for index, spellId in next, TOTEM_MULTI_CAST_SUMMON_SPELLS do
		knownMultiCastSummonSpells[index] = (IsSpellKnown(spellId) and spellId) or nil;
	end

	-- update the spell button
	local spellId = knownMultiCastSummonSpells[self:GetID()];
	self.spellId = spellId;
	if ( HasMultiCastActionBar() and spellId ) then
		local name, rank, icon, cost, isFunnel, powerType, castTime, minRage, maxRange = GetSpellInfo(spellId);
		local buttonName = self:GetName();
		_G[buttonName.."Icon"]:SetTexture(icon);

		if ( not self.eventsRegistered ) then
			self:RegisterEvent("UPDATE_BINDINGS");
			self:RegisterEvent("ACTIONBAR_UPDATE_STATE");
			self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			self.eventsRegistered = true;
		end
		ActionButton_UpdateHotkeys(self, self.buttonType);
		MultiCastSpellButton_UpdateCooldown(self);

		if ( GameTooltip:GetOwner() == self ) then
			MultiCastSpellButton_SetTooltip(self);
		end

		-- reanchor the first slot button take make room for this button
		local width = self:GetWidth();
		local xOffset = width + 8 + 3;
		local page;
		for i = 1, NUM_MULTI_CAST_PAGES do
			page = _G["MultiCastActionPage"..i];
			page:SetPoint("BOTTOMLEFT", page:GetParent(), "BOTTOMLEFT", xOffset, 3);
		end
		MultiCastSlotButton1:SetPoint("BOTTOMLEFT", self:GetParent(), "BOTTOMLEFT", xOffset, 3);

		self:Show();
	else
		if ( self.eventsRegistered ) then
			self:UnregisterEvent("UPDATE_BINDINGS");
			self:UnregisterEvent("ACTIONBAR_UPDATE_STATE");
			self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			self.eventsRegistered = false;
		end

		-- reanchor the first slot button take the place of this button
		local xOffset = 3;
		local page;
		for i = 1, NUM_MULTI_CAST_PAGES do
			page = _G["MultiCastActionPage"..i];
			page:SetPoint("BOTTOMLEFT", page:GetParent(), "BOTTOMLEFT", xOffset, 3);
		end
		MultiCastSlotButton1:SetPoint("BOTTOMLEFT", self:GetParent(), "BOTTOMLEFT", xOffset, 3);

		self:Hide();
	end
end

function MultiCastSummonSpellButtonUp(id)
	CastSpellByID(TOTEM_MULTI_CAST_SUMMON_SPELLS[id]);
end


--
-- MultiCastRecallSpellButton
--

function MultiCastRecallSpellButton_OnLoad(self)
	self.buttonType = "MULTICASTRECALLBUTTON";
	MultiCastSpellButton_OnLoad(self);
end

function MultiCastRecallSpellButton_OnClick(self)
	MultiCastRecallSpellButtonUp(self:GetID());
end

function MultiCastRecallSpellButton_Update(self)
	-- first update which multi-cast spells we actually know
	for index, spellId in next, TOTEM_MULTI_CAST_RECALL_SPELLS do
		knownMultiCastRecallSpells[index] = (IsSpellKnown(spellId) and spellId) or nil;
	end

	-- update the spell button
	local spellId = knownMultiCastRecallSpells[self:GetID()];
	self.spellId = spellId;
	if ( HasMultiCastActionBar() and spellId ) then
		local name, rank, icon, cost, isFunnel, powerType, castTime, minRage, maxRange = GetSpellInfo(spellId);
		local buttonName = self:GetName();
		_G[buttonName.."Icon"]:SetTexture(icon);

		if ( not self.eventsRegistered ) then
			self:RegisterEvent("UPDATE_BINDINGS");
			self:RegisterEvent("ACTIONBAR_UPDATE_STATE");
			self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			self.eventsRegistered = true;
		end
		ActionButton_UpdateHotkeys(self, self.buttonType);
		MultiCastSpellButton_UpdateCooldown(self);

		if ( GameTooltip:GetOwner() == self ) then
			MultiCastSpellButton_SetTooltip(self);
		end

		-- anchor to the last shown slot
		local activeSlots = MultiCastActionBarFrame.numActiveSlots;
		if ( activeSlots > 0 ) then
			self:SetPoint("LEFT", _G["MultiCastSlotButton"..activeSlots], "RIGHT", 8, 0);
		end

		self:Show();
	else
		if ( self.eventsRegistered ) then
			self:UnregisterEvent("UPDATE_BINDINGS");
			self:UnregisterEvent("ACTIONBAR_UPDATE_STATE");
			self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
			self.eventsRegistered = false;
		end

		self:Hide();
	end
end

function MultiCastRecallSpellButtonUp(id)
	CastSpellByID(TOTEM_MULTI_CAST_RECALL_SPELLS[id]);
end
