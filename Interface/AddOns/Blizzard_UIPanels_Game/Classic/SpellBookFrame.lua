MAX_SPELLS = 1024;
MAX_SKILLLINE_TABS = 8;
SPELLS_PER_PAGE = 12;
MAX_SPELL_PAGES = ceil(MAX_SPELLS / SPELLS_PER_PAGE);

BOOKTYPE_SPELL = "spell";
BOOKTYPE_PROFESSION = "professions";
BOOKTYPE_PET = "pet";
BOOKTYPE_CORE_ABILITIES = "core";
BOOKTYPE_WHAT_HAS_CHANGED = "changed"

SpellBookInfo = {};
SpellBookInfo[BOOKTYPE_SPELL] = {
	showFrames = {"SpellBookSpellIconsFrame", "SpellBookSideTabsFrame", "SpellBookPageNavigationFrame"},
											title = SPELLBOOK,
											updateFunc = function() SpellBook_UpdatePlayerTab(); end
};
SpellBookInfo[BOOKTYPE_PROFESSION] 	= { 	showFrames = {"SpellBookProfessionFrame"},
											title = TRADE_SKILLS,
											updateFunc = function() SpellBook_UpdateProfTab(); end,
											bgFileL="Interface\\Spellbook\\Professions-Book-Left",
											bgFileR="Interface\\Spellbook\\Professions-Book-Right",
											mousewheelNavigation = false,
};
SpellBookInfo[BOOKTYPE_PET] = {
	showFrames = {"SpellBookSpellIconsFrame", "SpellBookPageNavigationFrame"},
											title = PET,
											updateFunc =  function() SpellBook_UpdatePetTab(); end
};

SpellBookInfo[BOOKTYPE_CORE_ABILITIES]= { 	showFrames = {"SpellBookCoreAbilitiesFrame", "SpellBookPageNavigationFrame"}, 		
											title = CORE_ABILITIES,
											updateFunc =  function() SpellBook_UpdateCoreAbilitiesTab(); end
};

SpellBookInfo[BOOKTYPE_WHAT_HAS_CHANGED]= { showFrames = {"SpellBookWhatHasChanged"}, 		
											title = WHAT_HAS_CHANGED,
											updateFunc =  function() SpellBook_UpdateWhatHasChangedTab(); end
};	

SPELLBOOK_PAGENUMBERS = {};

PROFESSION_RANKS =  {};
PROFESSION_RANKS[1] = {75,  APPRENTICE};
PROFESSION_RANKS[2] = {150, JOURNEYMAN};
PROFESSION_RANKS[3] = {225, EXPERT};
PROFESSION_RANKS[4] = {300, ARTISAN};
PROFESSION_RANKS[5] = {375, MASTER};
PROFESSION_RANKS[6] = {450, GRAND_MASTER};
PROFESSION_RANKS[7] = {525, ILLUSTRIOUS};
PROFESSION_RANKS[8] = {600, ZEN_MASTER};

local ceil = ceil;
local strlen = strlen;
local tinsert = tinsert;
local tremove = tremove;

function ToggleSpellBook(bookType)
	if ( (not HasPetSpells() or not PetHasSpellbook()) and bookType == BOOKTYPE_PET ) then
		return;
	end
	
	local isShown = SpellBookFrame:IsShown();
	if ( isShown and (SpellBookFrame.bookType == bookType) ) then
		HideUIPanel(SpellBookFrame);
		return;
	elseif isShown then
		SpellBookFrame:PlayOpenSound()
		SpellBookFrame.bookType = bookType;	
		SpellBookFrame:Update();
	else	
		SpellBookFrame.bookType = bookType;	
		ShowUIPanel(SpellBookFrame);
	end
end

SpellBookFrameMixin = {};

function SpellBookFrameMixin:OnShow()
    if (SpellBookCoreAbilitiesFrame) then
		if ( not IsPlayerInitialSpec() ) then
			SpellBookCoreAbilitiesFrame.selectedSpec = C_SpecializationInfo.GetSpecialization() or 1;
		else
			SpellBookCoreAbilitiesFrame.selectedSpec = 1;
		end
    end
	self:Update();
	
	-- If there are tabs waiting to flash, then flash them... yeah..
	if ( self.flashTabs ) then
		UIFrameFlash(SpellBookTabFlashFrame, 0.5, 0.5, 30, nil);
	end

	-- Show multibar slots
	MultiActionBar_ShowAllGrids();
	UpdateMicroButtons();

	self:PlayOpenSound();
	MicroButtonPulseStop(SpellbookMicroButton);
end

function SpellBookFrameMixin:UpdateSpells()
	for i = 1, SPELLS_PER_PAGE do
		local currSpellButton = _G["SpellButton" .. i];
		currSpellButton:Show();
		currSpellButton:UpdateButton();
	end

	if (SpellBookPage1 and SpellBookPage2) then
		if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
			SpellBookPage1:SetDesaturated(_G["SpellBookSkillLineTab"..SpellBookFrame.selectedSkillLine].isOffSpec);
			SpellBookPage2:SetDesaturated(_G["SpellBookSkillLineTab"..SpellBookFrame.selectedSkillLine].isOffSpec);
		else
			SpellBookPage1:SetDesaturated(false);
			SpellBookPage2:SetDesaturated(false);
		end
	end
end

function SpellBookFrameMixin:PlayOpenSound()
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
	elseif ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		-- Need to change to pet book open sound
		PlaySound(SOUNDKIT.IG_ABILITY_OPEN);
	else
		PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
	end
end

function SpellBookFrameMixin:PlayCloseSound()
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound(SOUNDKIT.IG_SPELLBOOK_CLOSE);
	else
		-- Need to change to pet book close sound
		PlaySound(SOUNDKIT.IG_ABILITY_CLOSE);
	end
end

function SpellBookFrameMixin:OnHide()
	self:PlayCloseSound();

	-- Stop the flash frame from flashing if its still flashing.. flash flash flash
	UIFrameFlashStop(SpellBookTabFlashFrame);
	-- Hide all the flashing textures
	for i=1, MAX_SKILLLINE_TABS do
		_G["SpellBookSkillLineTab"..i.."Flash"]:Hide();
	end

	-- Hide multibar slots
	MultiActionBar_HideAllGrids();
	
	-- Do this last, it can cause taint.
	UpdateMicroButtons();
end

SpellButtonMixin = {};

function SpellButtonMixin:OnLoad() 
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function SpellButtonMixin:OnEvent(event, ...)
	if ( event == "SPELLS_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" ) then
		-- need to listen for UPDATE_SHAPESHIFT_FORM because attack icons change when the shapeshift form changes
		self:UpdateButton();
	elseif ( event == "SPELL_UPDATE_COOLDOWN" ) then
		self:UpdateCooldown();
		-- Update tooltip
		if ( GameTooltip:GetOwner() == self ) then
			self:OnEnter();
		end
	elseif ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
		self:UpdateSelection();
	elseif ( event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" ) then
		self:UpdateSelection();
	elseif ( event == "PET_BAR_UPDATE" ) then
		if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
			self:UpdateButton();
		end
	elseif ( event == "CURSOR_CHANGED" ) then
		if ( self.spellGrabbed ) then
			self:UpdateButton();
			self.spellGrabbed = false;
		end
	end
end

function SpellButtonMixin:OnShow()
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("CRAFT_SHOW");
	self:RegisterEvent("CRAFT_CLOSE");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
	self:RegisterEvent("TRADE_SKILL_SHOW");
	self:RegisterEvent("TRADE_SKILL_CLOSE");
	self:RegisterEvent("PET_BAR_UPDATE");
	self:RegisterEvent("CURSOR_CHANGED");
end

function SpellButtonMixin:OnHide()
	self:UnregisterEvent("SPELLS_CHANGED");
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	self:UnregisterEvent("CRAFT_SHOW");
	self:UnregisterEvent("CRAFT_CLOSE");
	self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED");
	self:UnregisterEvent("TRADE_SKILL_SHOW");
	self:UnregisterEvent("TRADE_SKILL_CLOSE");
	self:UnregisterEvent("PET_BAR_UPDATE");
	self:UnregisterEvent("CURSOR_CHANGED");
end
 
function SpellButtonMixin:OnEnter()
	local slot = SpellBook_GetSpellBookSlot(self);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( GameTooltip:SetSpellBookItem(slot, SpellBookFrame.bookType) ) then
		self.UpdateTooltip = self.OnEnter;
	else
		self.UpdateTooltip = nil;
	end

	GameTooltip:Show();
end

function SpellButtonMixin:OnLeave()
	GameTooltip:Hide();
end

function SpellButtonMixin:OnModifiedClick(button) 
	local slot = SpellBook_GetSpellBookSlot(self);
	if ( slot > MAX_SPELLS ) then
		return;
	end
	if ( IsModifiedClick("CHATLINK") ) then
		if ( MacroFrameText and MacroFrameText:HasFocus() ) then
			local spellName, subSpellName = GetSpellBookItemName(slot, SpellBookFrame.bookType);
			if ( spellName and not IsPassiveSpell(slot, SpellBookFrame.bookType) ) then
				if ( subSpellName and (strlen(subSpellName) > 0) ) then
					ChatEdit_InsertLink(spellName.."("..subSpellName..")");
				else
					ChatEdit_InsertLink(spellName);
				end
			end
			return;
		else
			local tradeSkillLink, tradeSkillSpellID = GetSpellTradeSkillLink(slot, SpellBookFrame.bookType);
			if ( tradeSkillSpellID ) then
				ChatEdit_InsertLink(tradeSkillLink);
			else
				ChatEdit_InsertLink(GetSpellLink(slot, SpellBookFrame.bookType));
			end
			return;
		end
	end
	if ( IsModifiedClick("PICKUPACTION") ) then
		PickupSpellBookItem(slot, SpellBookFrame.bookType);
		return;
	end
	if ( IsModifiedClick("SELFCAST") ) then
		CastSpell(slot, SpellBookFrame.bookType, true);
		self:UpdateSelection();
		return;
	end
end

function SpellButtonMixin:PreClick()
	self:SetChecked(false);
end

function SpellButtonMixin:UpdateDragSpell() 
	local slot, slotType = SpellBook_GetSpellBookSlot(self);
	if (not slot or slot > MAX_SPELLS or not _G[self:GetName().."IconTexture"]:IsShown() or (slotType == "FUTURESPELL")) then
		return;
	end
	self:SetChecked(false);
	PickupSpellBookItem(slot, SpellBookFrame.bookType);
end

function SpellButtonMixin:OnDragStart()
	if (self.isPassive) then 
		return;
	end

	self.spellGrabbed = true;
	self:UpdateDragSpell();
	if self.SpellHighlightTexture then
		self.SpellHighlightTexture:Hide();
	end
end

function SpellButtonMixin:OnDragStop()
	self.dragStopped = true;
end

function SpellButtonMixin:OnReceiveDrag()
	if (self.isPassive) then 
		return;
	end

	self:UpdateDragSpell();
end

function SpellButtonMixin:UpdateCooldown()
	local cooldown = self.cooldown;
	local slot, slotType = SpellBook_GetSpellBookSlot(self);
	if (slot) then
		local iconTexture = _G[self:GetName().."IconTexture"];
		local start, duration, enable, modRate = GetSpellCooldown(slot, SpellBookFrame.bookType);


		if (enable == 1) then
			iconTexture:SetVertexColor(1.0, 1.0, 1.0);
		else
			iconTexture:SetVertexColor(0.4, 0.4, 0.4);
		end

		if (cooldown and start and duration) then
			if (enable == 1) then
				cooldown:Hide();
			else
				cooldown:Show();
			end
			CooldownFrame_Set(cooldown, start, duration, enable, false, modRate);
		else
			cooldown:Hide();
		end
	end
end

function SpellBookPrevPageButton_OnClick()
	local pageNum = SpellBook_GetCurrentPage() - 1;
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
		SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = pageNum;
	else
		-- Need to change to pet book pageturn sound
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
		SPELLBOOK_PAGENUMBERS[SpellBookFrame.bookType] = pageNum;
	end
	SpellBookFrame:Update();
end

function SpellBookNextPageButton_OnClick()
	local pageNum = SpellBook_GetCurrentPage() + 1;
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
		SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = pageNum;
	else
		-- Need to change to pet book pageturn sound
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
		SPELLBOOK_PAGENUMBERS[SpellBookFrame.bookType] = pageNum;
	end
	SpellBookFrame:Update();
end

function SpellBookSkillLineTab_OnClick(self)
	local id = self:GetID();
	if ( SpellBookFrame.selectedSkillLine ~= id ) then
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
		SpellBookFrame.selectedSkillLine = id;
		SpellBookFrame:Update();
	else
		self:SetChecked(true);
	end
	
	-- Stop tab flashing
	if ( self ) then
		local tabFlash = _G[self:GetName().."Flash"];
		if ( tabFlash ) then
			tabFlash:Hide();
		end
	end
end

function SpellBookFrameTabButton_OnClick(self)
	self:Disable();
	if SpellBookFrame.currentTab then
		SpellBookFrame.currentTab:Enable();
	end
	SpellBookFrame.currentTab = self;
	ToggleSpellBook(self.bookType);
end

function SpellBook_GetButtonForID(id)
	-- Currently the spell book is mapped such that odd numbered buttons from 1 - 11 match id 1 - 6, while even numbered buttons from 2 - 12 match 7 - 12
	if (id > 6) then
		return _G["SpellButton"..((id - 6) * 2)];
	else
		return _G["SpellButton"..(((id - 1) * 2) + 1)];
	end
end

function SpellBookFrameMixin:OpenToPageForSlot(slot, reason)
	local alreadyOpen = SpellBookFrame:IsShown();
	SpellBookFrame.bookType = BOOKTYPE_SPELL;
	ShowUIPanel(SpellBookFrame);
	if (SpellBookFrame.selectedSkillLine ~= 2) then
		SpellBookFrame.selectedSkillLine = 2;
		self:Update();
	end

	if (alreadyOpen and reason == OPEN_REASON_PENDING_GLYPH) then
		local page = SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine];
		for i = 1, 12 do
			local glyphSlot = (i + ( SPELLS_PER_PAGE * (page - 1))) + SpellBookFrame.selectedSkillLineOffset;
			local slotType, spellID = GetSpellBookItemInfo(glyphSlot, SpellBookFrame.bookType);
			if (slotType == "SPELL") then
				if (IsSpellValidForPendingGlyph(spellID)) then
					self:Update();
					return;
				end
			end
		end
	end

	local slotType, spellID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
	local relativeSlot = slot - SpellBookFrame.selectedSkillLineOffset;
	local page = math.floor((relativeSlot - 1)/ SPELLS_PER_PAGE) + 1;
	SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = page;
	self:Update();
end

function SpellBookFrameMixin:ClearAbilityHighlights()
	for i = 1, SPELLS_PER_PAGE do
		local button = _G["SpellButton"..i];
		button.AbilityHighlightAnim:Stop();
		button.AbilityHighlight:Hide();
	end
end

function SpellBook_GetCurrentPage()
	local currentPage, maxPages;
	local numPetSpells = HasPetSpells() or 0;
	if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		currentPage = SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET];
		maxPages = ceil(numPetSpells/SPELLS_PER_PAGE);
	elseif ( SpellBookFrame.bookType == BOOKTYPE_SPELL) then
		currentPage = SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine];
		local _, _, _, numSlots = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
		maxPages = ceil(numSlots/SPELLS_PER_PAGE);
	elseif ( SpellBookFrame.bookType == BOOKTYPE_CORE_ABILITIES) then
		currentPage = 1;
		maxPages = 1;
	end
	return currentPage, maxPages;
end

local maxShines = 1;
local shineGet = {}
function SpellBook_GetAutoCastShine ()
	local shine = shineGet[1];
	
	if ( shine ) then
		tremove(shineGet, 1);
	else
		shine = CreateFrame("FRAME", "AutocastShine" .. maxShines, SpellBookFrame, "SpellBookShineTemplate");
		maxShines = maxShines + 1;
	end
	
	return shine;
end

function SpellBook_ReleaseAutoCastShine (shine)
	if ( not shine ) then
		return;
	end
	
	shine:Hide();
	AutoCastShine_AutoCastStop(shine);
	tinsert(shineGet, shine);
end

-------------------------------------------------------------------
--------------------- Update functions for tabs --------------------
-------------------------------------------------------------------
function SpellBookFrameMixin:UpdateSkillLineTabs()
	local numSkillLineTabs = GetNumSpellTabs();
	for i=1, MAX_SKILLLINE_TABS do
		local skillLineTab = _G["SpellBookSkillLineTab"..i];
		local prevTab = _G["SpellBookSkillLineTab"..i-1];
		if ( i <= numSkillLineTabs and SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
			local name, texture, _, _, isGuild, offSpecID, shouldHide, specID = GetSpellTabInfo(i);
			local isOffSpec = (offSpecID ~= 0);
			skillLineTab.isOffSpec = isOffSpec;
			
			if ( shouldHide ) then
				_G["SpellBookSkillLineTab"..i.."Flash"]:Hide();
				skillLineTab:Hide();
			else
				if(texture) then
					skillLineTab:SetNormalTexture(texture);
					skillLineTab:GetNormalTexture():SetDesaturated(isOffSpec);
				else
					skillLineTab:ClearNormalTexture();
				end
				skillLineTab.tooltip = name;
				skillLineTab:Show();

				if (prevTab) then
					if (isOffSpec and not prevTab.isOffSpec and OFFSPEC_TAB_OFFSET) then
						skillLineTab:SetPoint("TOPLEFT", prevTab, "BOTTOMLEFT", 0, -OFFSPEC_TAB_OFFSET);
					end
				end

				-- Set the selected tab
				if ( SpellBookFrame.selectedSkillLine == i ) then
					skillLineTab:SetChecked(true);
				else
					skillLineTab:SetChecked(false);
				end
			end
		else
			_G["SpellBookSkillLineTab"..i.."Flash"]:Hide();
			skillLineTab:Hide();
		end
	end
end

function SpellBook_UpdatePlayerTab()

	-- Setup skillline tabs
	local _, _, offset, numSlots = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
	SpellBookFrame.selectedSkillLineOffset = offset;
	SpellBookFrame.selectedSkillLineNumSlots = numSlots;
	
	SpellBookFrame:UpdatePages();

	SpellBookFrame:UpdateSkillLineTabs();

	SpellBookFrame:UpdateSpells();
end


function SpellBook_UpdatePetTab(showing)
	SpellBookFrame.numPetSpells = HasPetSpells() or 0;

	SpellBookFrame:UpdatePages();
	SpellBookFrame:UpdateSpells();
end

CoreAbilitySpellMixin = {}

function CoreAbilitySpellMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function CoreAbilitySpellMixin:OnClick()
	if (IsModifiedClick()) then
		ChatEdit_InsertLink(GetSpellLink(self.spellID));
	else
		ClearCursor()
	end
end

function CoreAbilitySpellMixin:OnDragStart()
	if (self.draggable) then
		PickupSpell(self.spellID);
	end
end

function CoreAbilitySpellMixin:OnReceiveDrag()
	if (self.draggable) then
		PickupSpell(self.spellID);
	end
end

function CoreAbilitySpellMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetSpellByID(self.spellID, false, false, true);
end

function CoreAbilitySpellMixin:OnLeave()
	GameTooltip:Hide();
end
