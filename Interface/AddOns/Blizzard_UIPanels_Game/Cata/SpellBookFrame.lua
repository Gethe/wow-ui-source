MAX_SPELLS = 1024;
MAX_SKILLLINE_TABS = 8;
SPELLS_PER_PAGE = 12;
MAX_SPELL_PAGES = ceil(MAX_SPELLS / SPELLS_PER_PAGE);

BOOKTYPE_SPELL = "spell";
BOOKTYPE_PROFESSION = "professions";
BOOKTYPE_PET = "pet";

local MaxSpellBookTypes = 3;
local SpellBookInfo = {};
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

SPELLBOOK_PAGENUMBERS = {};

SpellBookFrames = {	"SpellBookSpellIconsFrame", "SpellBookProfessionFrame", "SpellBookSideTabsFrame", "SpellBookPageNavigationFrame" };

PROFESSION_RANKS =  {};
PROFESSION_RANKS[1] = {75,  APPRENTICE};
PROFESSION_RANKS[2] = {150, JOURNEYMAN};
PROFESSION_RANKS[3] = {225, EXPERT};
PROFESSION_RANKS[4] = {300, ARTISAN};
PROFESSION_RANKS[5] = {375, MASTER};
PROFESSION_RANKS[6] = {450, GRAND_MASTER};
PROFESSION_RANKS[7] = {525, ILLUSTRIOUS};

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
		SpellBookFrame_PlayOpenSound()
		SpellBookFrame.bookType = bookType;	
		SpellBookFrame_Update();
	else	
		SpellBookFrame.bookType = bookType;	
		ShowUIPanel(SpellBookFrame);
	end
end

function SpellBookFrame_OnLoad(self)
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("LEARNED_SPELL_IN_TAB");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");

	SpellBookFrame.bookType = BOOKTYPE_SPELL;
	-- Init page nums
	SPELLBOOK_PAGENUMBERS[1] = 1;
	SPELLBOOK_PAGENUMBERS[2] = 1;
	SPELLBOOK_PAGENUMBERS[3] = 1;
	SPELLBOOK_PAGENUMBERS[4] = 1;
	SPELLBOOK_PAGENUMBERS[5] = 1;
	SPELLBOOK_PAGENUMBERS[6] = 1;
	SPELLBOOK_PAGENUMBERS[7] = 1;
	SPELLBOOK_PAGENUMBERS[8] = 1;
	SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] = 1;
	
	-- Set to the first tab by default
	SpellBookFrame.selectedSkillLine = 1;

	-- Initialize tab flashing
	SpellBookFrame.flashTabs = nil;

	-- Initialize portrait texture
	SetPortraitToTexture(self.portrait, "Interface\\Spellbook\\Spellbook-Icon");

	ButtonFrameTemplate_HideButtonBar(SpellBookFrame);
	ButtonFrameTemplate_HideAttic(SpellBookFrame);
	SpellBookFrameInsetBg:Hide();
end

function SpellBookFrame_OnEvent(self, event, ...)
	if ( event == "SPELLS_CHANGED" ) then
		if ( SpellBookFrame:IsVisible() ) then
			if ( GetNumSpellTabs() < SpellBookFrame.selectedSkillLine ) then
				SpellBookFrame.selectedSkillLine = 2;
			end
			SpellBookFrame_Update();
		end
	elseif ( event == "LEARNED_SPELL_IN_TAB" ) then
		SpellBookFrame_Update();
		local spellID, tabNum, isGuildSpell = ...;
		local flashFrame = _G["SpellBookSkillLineTab"..tabNum.."Flash"];
		if ( SpellBookFrame.bookType == BOOKTYPE_PET or isGuildSpell) then
			return;
		elseif ( tabNum <= GetNumSpellTabs() ) then
			if ( flashFrame ) then
				flashFrame:Show();
				SpellBookFrame.flashTabs = 1;
			end
		end
	elseif (event == "SKILL_LINES_CHANGED") then
		SpellBook_UpdateProfTab();
	elseif (event == "PLAYER_GUILD_UPDATE") then
		-- default to class tab if the selected one is gone - happens if you leave a guild with perks
		if ( GetNumSpellTabs() < SpellBookFrame.selectedSkillLine ) then
			SpellBookFrame_Update();
		else
			SpellBookFrame_UpdateSkillLineTabs();
		end
	end
end

function SpellBookFrame_OnShow(self)
	SpellBookFrame_Update();
	
	-- If there are tabs waiting to flash, then flash them... yeah..
	if ( self.flashTabs ) then
		UIFrameFlash(SpellBookTabFlashFrame, 0.5, 0.5, 30, nil);
	end

	-- Show multibar slots
	MultiActionBar_ShowAllGrids();
	UpdateMicroButtons();

	SpellBookFrame_PlayOpenSound();
	MicroButtonPulseStop(SpellbookMicroButton);
end

function SpellBookFrame_Update()
	-- Hide all tabs
	SpellBookFrameTabButton3:Hide();
	SpellBookFrameTabButton4:Hide();
	SpellBookFrameTabButton5:Hide();

	-- Setup tabs
	-- player spells and professions are always shown
	SpellBookFrameTabButton1:Show();
	SpellBookFrameTabButton1.bookType = BOOKTYPE_SPELL;
	SpellBookFrameTabButton1.binding = "TOGGLESPELLBOOK";
	SpellBookFrameTabButton1:SetText(SpellBookInfo[BOOKTYPE_SPELL].title);
	SpellBookFrameTabButton2:Show();
	SpellBookFrameTabButton2.bookType = BOOKTYPE_PROFESSION;
	SpellBookFrameTabButton2:SetText(SpellBookInfo[BOOKTYPE_PROFESSION].title);
	SpellBookFrameTabButton2.binding = "TOGGLECHARACTER1"; --since default bindngs are shared by all of Classic I am using the old binding name instead of TOGGLEPROFESSIONBOOK

	local numTabs = 2;
	-- check to see if we have a pet
	local hasPetSpells, petToken = HasPetSpells();
	SpellBookFrame.petTitle = nil;
	if ( hasPetSpells and PetHasSpellbook() ) then
		SpellBookFrame.petTitle = _G["PET_TYPE_"..petToken];
		local nextTab = _G["SpellBookFrameTabButton"..3];
		nextTab:Show();
		nextTab.bookType = BOOKTYPE_PET;
		nextTab.binding = "TOGGLEPETBOOK";
		nextTab:SetText(SpellBookInfo[BOOKTYPE_PET].title);
		numTabs = numTabs + 1;
	elseif (SpellBookFrame.bookType == BOOKTYPE_PET) then
		SpellBookFrame.bookType = _G["SpellBookFrameTabButton"..2].bookType;
	end

	PanelTemplates_SetNumTabs(SpellBookFrame, numTabs);

	-- Make sure the correct tab is selected
	for i=1,MaxSpellBookTypes do
		local tab = _G["SpellBookFrameTabButton"..i];
		if ( tab.bookType == SpellBookFrame.bookType ) then
			SpellBookFrame.currentTab = tab;
		else
			PanelTemplates_DeselectTab(tab);
		end
	end
	
	-- setup display
	for i, frame in ipairs(SpellBookFrames) do
		local found = false;
		for j,frame2 in ipairs(SpellBookInfo[SpellBookFrame.bookType].showFrames) do
			if (frame == frame2) then
				_G[frame]:Show();
				found = true;
				break;
			end
		end
		if (found == false) then
			_G[frame]:Hide();
		end
	end
	

	if SpellBookInfo[SpellBookFrame.bookType].bgFileL then
		SpellBookPage1:SetTexture(SpellBookInfo[SpellBookFrame.bookType].bgFileL);
	else
		SpellBookPage1:SetTexture("Interface\\Spellbook\\Spellbook-Page-1");
	end
	if SpellBookInfo[SpellBookFrame.bookType].bgFileR then
		SpellBookPage2:SetTexture(SpellBookInfo[SpellBookFrame.bookType].bgFileR);
	else
		SpellBookPage2:SetTexture("Interface\\Spellbook\\Spellbook-Page-2");
	end

	SpellBookFrame:SetTitle(SpellBookInfo[SpellBookFrame.bookType].title);

	local tabUpdate = SpellBookInfo[SpellBookFrame.bookType].updateFunc;
	if(tabUpdate) then
		tabUpdate()
	end
end

function SpellBookFrame_UpdateSpells ()
	for i = 1, SPELLS_PER_PAGE do
		local currSpellButton = _G["SpellButton" .. i];
		currSpellButton:Show();
		currSpellButton:UpdateButton();
	end
end

function SpellBookFrame_UpdatePages()
	local currentPage, maxPages = SpellBook_GetCurrentPage();
	if ( maxPages == nil or maxPages == 0 ) then
		return;
	end
	if ( currentPage > maxPages ) then
		if (SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
			SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = maxPages;
		else
			SPELLBOOK_PAGENUMBERS[SpellBookFrame.bookType] = maxPages;
		end
		currentPage = maxPages;
		if ( currentPage == 1 ) then
			SpellBookPrevPageButton:Disable();
		else
			SpellBookPrevPageButton:Enable();
		end
		if ( currentPage == maxPages ) then
			SpellBookNextPageButton:Disable();
		else
			SpellBookNextPageButton:Enable();
		end
	end
	if ( currentPage == 1 ) then
		SpellBookPrevPageButton:Disable();
	else
		SpellBookPrevPageButton:Enable();
	end
	if ( currentPage == maxPages ) then
		SpellBookNextPageButton:Disable();
	else
		SpellBookNextPageButton:Enable();
	end
	SpellBookPageText:SetFormattedText(PAGE_NUMBER, currentPage);
end

function SpellBookFrame_PlayOpenSound()
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
	elseif ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		-- Need to change to pet book open sound
		PlaySound(SOUNDKIT.IG_ABILITY_OPEN);
	else
		PlaySound(SOUNDKIT.IG_SPELLBOOK_OPEN);
	end
end

function SpellBookFrame_PlayCloseSound()
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound(SOUNDKIT.IG_SPELLBOOK_CLOSE);
	else
		-- Need to change to pet book close sound
		PlaySound(SOUNDKIT.IG_ABILITY_CLOSE);
	end
end

function SpellBookFrame_OnHide(self)
	SpellBookFrame_PlayCloseSound();

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
	elseif ( event == "CRAFT_SHOW" or event == "CRAFT_CLOSE" or event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE") then
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

function SpellButtonMixin:OnClick(button)
	local slot, slotType = SpellBook_GetSpellBookSlot(self);
	if ( slot > MAX_SPELLS or slotType == "FUTURESPELL") then
		return;
	end

	if (self.isPassive) then 
		return;
	end

	if ( button ~= "LeftButton" and SpellBookFrame.bookType == BOOKTYPE_PET ) then
			ToggleSpellAutocast(slot, SpellBookFrame.bookType);
	else
		local _, id = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
		if (slotType == "FLYOUT") then
			SpellFlyout:Toggle(id, self, "RIGHT", 1, false, self.offSpecID, true);
			SpellFlyout:SetBorderColor(181/256, 162/256, 90/256);
		else
			if ( SpellBookFrame.bookType ~= BOOKTYPE_SPELLBOOK or self.offSpecID == 0 ) then
				CastSpell(slot, SpellBookFrame.bookType);
			end
		end
		self:UpdateSelection();
	end
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

function SpellButtonMixin:UpdateDragSpell() 
	local slot, slotType = SpellBook_GetSpellBookSlot(self);
	if (not slot or slot > MAX_SPELLS or not _G[self:GetName().."IconTexture"]:IsShown() or (slotType == "FUTURESPELL")) then
		return;
	end
	self:SetChecked(false);
	PickupSpellBookItem(slot, SpellBookFrame.bookType);
end

function SpellButtonMixin:OnDragStart()
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
	self:UpdateDragSpell();
end

function SpellButtonMixin:UpdateSelection()
	-- We only highlight professions that are open. We used to highlight active shapeshifts and pet
	-- stances but we removed the highlight on those to avoid conflicting with the not-on-your-action-bar highlights.
	if SpellBookFrame.bookType == BOOKTYPE_PROFESSION then
		local slot = SpellBook_GetSpellBookSlot(self);
		if ( slot and IsSelectedSpellBookItem(slot, SpellBookFrame.bookType) ) then
			self:SetChecked(true);
		else
			self:SetChecked(false);
		end
	end
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

function SpellButtonMixin:UpdateButton()
	if SpellBookFrame.bookType == BOOKTYPE_PROFESSION then
		UpdateProfessionButton(self);
		return;
	end

	if ( not SpellBookFrame.selectedSkillLine ) then
		SpellBookFrame.selectedSkillLine = 2;
	end
	local _, _, offset, numSlots, _, offSpecID, shouldHide, specID = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
	SpellBookFrame.selectedSkillLineNumSlots = numSlots;
	SpellBookFrame.selectedSkillLineOffset = offset;
	
	if (not self.SpellName.shadowX) then
		self.SpellName.shadowX, self.SpellName.shadowY = self.SpellName:GetShadowOffset();
	end

	local slot, slotType, slotID = SpellBook_GetSpellBookSlot(self);
	local name = self:GetName();
	local iconTexture = _G[name.."IconTexture"];
	local spellString = _G[name.."SpellName"];
	local subSpellString = _G[name.."SubSpellName"];
	local cooldown = _G[name.."Cooldown"];
	local autoCastableTexture = _G[name.."AutoCastable"];
	local slotFrame = _G[name.."SlotFrame"];
	local normalTexture = _G[name.."NormalTexture"];
	local highlightTexture = _G[name.."Highlight"];
	local texture;
	if ( slot ) then
		texture = GetSpellBookItemTexture(slot, SpellBookFrame.bookType);
	end

	-- Hide flyout if it's currently open
	if (SpellFlyout:IsShown() and SpellFlyout:GetParent() == self)  then
		SpellFlyout:Hide();
	end

	local hidden = GetClassicExpansionLevel() < LE_EXPANSION_WRATH_OF_THE_LICH_KING and slot and IsSpellHidden(slot, SpellBookFrame.bookType);

	-- If no spell, hide everything and return, or kiosk mode and future spell
	if ( not texture or (strlen(texture) == 0) or (slotType == "FUTURESPELL" and Kiosk.IsEnabled()) or hidden) then
		iconTexture:Hide();
		spellString:Hide();
		subSpellString:Hide();
		cooldown:Hide();
		autoCastableTexture:Hide();
		SpellBook_ReleaseAutoCastShine(self.shine);
		self.shine = nil;
		highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		self:SetChecked(false);
		slotFrame:Hide();
		self.IconTextureBg:Hide();
		self.SeeTrainerString:Hide();
		self.RequiredLevelString:Hide();
		self.UnlearnedFrame:Hide();
		self.TrainFrame:Hide();
		self.TrainTextBackground:Hide();
		self.TrainBook:Hide();
		self.FlyoutArrow:Hide();
		self:Disable();
		return;
	else
		self:Enable();
	end

	self:UpdateCooldown();

	local autoCastAllowed, autoCastEnabled = GetSpellAutocast(slot, SpellBookFrame.bookType);
	if ( autoCastAllowed ) then
		autoCastableTexture:Show();
	else
		autoCastableTexture:Hide();
	end
	if ( autoCastEnabled and not self.shine ) then
		self.shine = SpellBook_GetAutoCastShine();
		self.shine:Show();
		self.shine:SetParent(self);
		self.shine:SetPoint("CENTER", self, "CENTER");
		AutoCastShine_AutoCastStart(self.shine);
	elseif ( autoCastEnabled ) then
		self.shine:Show();
		self.shine:SetParent(self);
		self.shine:SetPoint("CENTER", self, "CENTER");
		AutoCastShine_AutoCastStart(self.shine);
	elseif ( not autoCastEnabled ) then
		SpellBook_ReleaseAutoCastShine(self.shine);
		self.shine = nil;
	end

	local spellName, _, spellID = GetSpellBookItemName(slot, SpellBookFrame.bookType);
	local isPassive = IsPassiveSpell(slot, SpellBookFrame.bookType);
	self.isPassive = isPassive;
	if ( isPassive ) then
		highlightTexture:SetTexture("Interface\\Buttons\\UI-PassiveHighlight");
		spellString:SetTextColor(PASSIVE_SPELL_FONT_COLOR.r, PASSIVE_SPELL_FONT_COLOR.g, PASSIVE_SPELL_FONT_COLOR.b);
	else
		highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		spellString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	iconTexture:SetTexture(texture);
	spellString:SetText(spellName);

	self.SpellSubName:SetHeight(6);
	subSpellString:SetText("");
	if spellID then
		local spell = Spell:CreateFromSpellID(spellID);
		spell:ContinueOnSpellLoad(function()
			local subSpellName = spell:GetSpellSubtext();
			if ( subSpellName == "" ) then
				if ( isPassive ) then
					subSpellName = SPELL_PASSIVE;
				end
			end

			subSpellString:SetText(subSpellName);
		end);
	end

	if ( subSpellName == "" ) then
		spellString:SetPoint("LEFT", self, "RIGHT", 5, 1);
	else
		spellString:SetPoint("LEFT", self, "RIGHT", 5, 3);
	end

	iconTexture:Show();
	spellString:Show();
	subSpellString:Show();

	if (not (slotType == "FUTURESPELL")) then
		slotFrame:Show();
		self.UnlearnedFrame:Hide();
		self.TrainFrame:Hide();
		self.IconTextureBg:Hide();
		iconTexture:SetAlpha(1);
		iconTexture:SetDesaturated(false);
		self.RequiredLevelString:Hide();
		self.SeeTrainerString:Hide();
		self.TrainTextBackground:Hide();
		self.TrainBook:Hide();
		self.SpellName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		self.SpellName:SetShadowOffset(self.SpellName.shadowX, self.SpellName.shadowY);
		self.SpellName:SetPoint("LEFT", self, "RIGHT", 8, 4);
		--self.SpellSubName:SetTextColor(0, 0, 0);
		local _, actionID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);

		if self.SpellHighlightTexture then
			self.SpellHighlightTexture:Hide();
			if ( (SpellBookFrame.selectedSkillLine > 1 and not isOffSpec) or SpellBookFrame.bookType == BOOKTYPE_PET ) then
				if ( slotType == "SPELL" ) then
					-- If the spell is passive we never show the highlight.  Otherwise, check if there are any action
					-- buttons with this spell.
					self.SpellHighlightTexture:SetShown(not isPassive and not C_ActionBar.IsOnBarOrSpecialBar(actionID));
				elseif ( slotType == "FLYOUT" ) then
					self.SpellHighlightTexture:SetShown(not C_ActionBar.HasFlyoutActionButtons(actionID));
				elseif ( slotType == "PETACTION" ) then
					if ( isPassive ) then
						self.SpellHighlightTexture:Hide();
					else
						local onBarSomewhere = C_ActionBar.HasPetActionButtons(actionID) or C_ActionBar.HasPetActionPetBarIndices(actionID);
						self.SpellHighlightTexture:SetShown(not onBarSomewhere);
					end
				end
			end
		end
	else
		local level = GetSpellAvailableLevel(slot, SpellBookFrame.bookType);
		slotFrame:Hide();
		if self.SpellHighlightTexture then
			self.SpellHighlightTexture:Hide();
		end

		self.IconTextureBg:Show();
		iconTexture:SetAlpha(0.5);
		iconTexture:SetDesaturated(true);
		if (level and level > UnitLevel("player")) then
			self.SeeTrainerString:Hide();
			self.RequiredLevelString:Show();
			self.RequiredLevelString:SetFormattedText(SPELLBOOK_AVAILABLE_AT, level);
			self.UnlearnedFrame:Show();
			self.TrainFrame:Hide();
			self.TrainTextBackground:Hide();
			self.TrainBook:Hide();
			self.SpellName:SetTextColor(0.25, 0.12, 0);
			self.SpellName:SetShadowOffset(0, 0);
			self.SpellName:SetPoint("LEFT", self, "RIGHT", 8, 6);
		else
			self.SeeTrainerString:Show();
			self.RequiredLevelString:Hide();
			self.TrainFrame:Show();
			self.UnlearnedFrame:Hide();
			self.TrainTextBackground:Show();
			self.TrainBook:Show();
			self.SpellName:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			self.SpellName:SetShadowOffset(self.SpellName.shadowX, self.SpellName.shadowY);
			self.SpellName:SetPoint("LEFT", self, "RIGHT", 24, 8);
		end
	end

	if (slotType == "FLYOUT") then
		SetClampedTextureRotation(self.FlyoutArrow, 90);
		self.FlyoutArrow:Show();
	else
		self.FlyoutArrow:Hide();
	end

	self:UpdateSelection();
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
	SpellBookFrame_Update();
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
	SpellBookFrame_Update();
end

function SpellBookSkillLineTab_OnClick(self)
	local id = self:GetID();
	if ( SpellBookFrame.selectedSkillLine ~= id ) then
		PlaySound(SOUNDKIT.IG_ABILITY_PAGE_TURN);
		SpellBookFrame.selectedSkillLine = id;
		SpellBookFrame_Update();
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

function SpellBook_GetSpellBookSlot(spellButton)
	local id = spellButton:GetID()
	if ( SpellBookFrame.bookType == BOOKTYPE_PROFESSION) then
		return id + spellButton:GetParent().spellOffset;
	elseif ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		local slot = id + (SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] - 1));
		if ( SpellBookFrame.numPetSpells and slot <= SpellBookFrame.numPetSpells) then
			local slotType, slotID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
			return slot, slotType, slotID;
		end
	else
		local relativeSlot = id + ( SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] - 1));
		if ( SpellBookFrame.selectedSkillLineNumSlots and relativeSlot <= SpellBookFrame.selectedSkillLineNumSlots) then
			local slot = SpellBookFrame.selectedSkillLineOffset + relativeSlot;
			local slotType, slotID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
			return slot, slotType, slotID;
		end
	end
	return nil, nil, nil;
end

function SpellBook_GetButtonForID(id)
	-- Currently the spell book is mapped such that odd numbered buttons from 1 - 11 match id 1 - 6, while even numbered buttons from 2 - 12 match 7 - 12
	if (id > 6) then
		return _G["SpellButton"..((id - 6) * 2)];
	else
		return _G["SpellButton"..(((id - 1) * 2) + 1)];
	end
end

function SpellBookFrame_OpenToPageForSlot(slot, reason)
	local alreadyOpen = SpellBookFrame:IsShown();
	SpellBookFrame.bookType = BOOKTYPE_SPELL;
	ShowUIPanel(SpellBookFrame);
	if (SpellBookFrame.selectedSkillLine ~= 2) then
		SpellBookFrame.selectedSkillLine = 2;
		SpellBookFrame_Update();
	end

	if (alreadyOpen and reason == OPEN_REASON_PENDING_GLYPH) then
		local page = SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine];
		for i = 1, 12 do
			local slot = (i + ( SPELLS_PER_PAGE * (page - 1))) + SpellBookFrame.selectedSkillLineOffset;
			local slotType, spellID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
			if (slotType == "SPELL") then
				if (IsSpellValidForPendingGlyph(spellID)) then
					SpellBookFrame_Update();
					return;
				end
			end
		end
	end

	local slotType, spellID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
	local relativeSlot = slot - SpellBookFrame.selectedSkillLineOffset;
	local page = math.floor((relativeSlot - 1)/ SPELLS_PER_PAGE) + 1;
	SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = page;
	SpellBookFrame_Update();
end

function SpellBookFrame_ClearAbilityHighlights()
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
function SpellBookFrame_UpdateSkillLineTabs()
	local numSkillLineTabs = GetNumSpellTabs();
	for i=1, MAX_SKILLLINE_TABS do
		local skillLineTab = _G["SpellBookSkillLineTab"..i];
		local prevTab = _G["SpellBookSkillLineTab"..i-1];
		if ( i <= numSkillLineTabs and SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
			local name, texture, _, _, isGuild, offSpecID, shouldHide, specID = GetSpellTabInfo(i);	
			if ( shouldHide ) then
				_G["SpellBookSkillLineTab"..i.."Flash"]:Hide();
				skillLineTab:Hide();
			else
				if(texture) then
					skillLineTab:SetNormalTexture(texture);
				else
					skillLineTab:ClearNormalTexture();
				end
				skillLineTab.tooltip = name;
				skillLineTab:Show();

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
	
	SpellBookFrame_UpdatePages();

	SpellBookFrame_UpdateSkillLineTabs();

	SpellBookFrame_UpdateSpells();
end


function SpellBook_UpdatePetTab(showing)
	SpellBookFrame.numPetSpells = HasPetSpells() or 0;

	SpellBookFrame_UpdatePages();
	SpellBookFrame_UpdateSpells();
end


ProfessionsUnlearnButtonMixin = {};

function ProfessionsUnlearnButtonMixin:OnEnter()
    self.Icon:SetAlpha(1.0);
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    GameTooltip:SetText(UNLEARN_SKILL_TOOLTIP);
end

function ProfessionsUnlearnButtonMixin:OnLeave()
    self.Icon:SetAlpha(0.75);
	GameTooltip_Hide();
end

function ProfessionsUnlearnButtonMixin:OnMouseDown()
    self.Icon:SetPoint("TOPLEFT", 1, -1);
end

function ProfessionsUnlearnButtonMixin:OnMouseUp()
    self.Icon:SetPoint("TOPLEFT", 0, 0);
end


function UpdateProfessionButton(self)
	local parent = self:GetParent();
	if not parent.professionInitialized then
		return;
	end

	local spellIndex = self:GetID() + parent.spellOffset;
	local texture = GetSpellBookItemTexture(spellIndex, SpellBookFrame.bookType);
	local spellName, _, spellID = GetSpellBookItemName(spellIndex, SpellBookFrame.bookType);
	local isPassive = IsPassiveSpell(spellIndex, SpellBookFrame.bookType);
	if ( isPassive ) then
		self.highlightTexture:SetTexture("Interface\\Buttons\\UI-PassiveHighlight");
		self.spellString:SetTextColor(PASSIVE_SPELL_FONT_COLOR.r, PASSIVE_SPELL_FONT_COLOR.g, PASSIVE_SPELL_FONT_COLOR.b);
	else
		self.highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		self.spellString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end

	self.IconTexture:SetTexture(texture);
	local start, duration, enable = GetSpellCooldown(spellIndex, SpellBookFrame.bookType);
	CooldownFrame_Set(self.cooldown, start, duration, enable);
	if ( enable == 1 ) then
		self.IconTexture:SetVertexColor(1.0, 1.0, 1.0);
	else
		self.IconTexture:SetVertexColor(0.4, 0.4, 0.4);
	end

	self.spellString:SetText(spellName);
	self.subSpellString:SetText("");
	if spellID then
		local spell = Spell:CreateFromSpellID(spellID);
		spell:ContinueOnSpellLoad(function()
			self.subSpellString:SetText(spell:GetSpellSubtext());
		end);
	end
	self.IconTexture:SetTexture(texture);

	self:UpdateSelection();
end

function FormatProfession(frame, index)
	if index then
		frame.missingHeader:Hide();
		frame.missingText:Hide();

		local name, texture, rank, maxRank, numSpells, spellOffset, skillLine, rankModifier, specializationIndex, specializationOffset, skillLineName = GetProfessionInfo(index);
		frame.professionInitialized = true;
		frame.skillName = name;
		frame.spellOffset = spellOffset;
		frame.skillLine = skillLine;
		frame.specializationIndex = specializationIndex;
		frame.specializationOffset = specializationOffset;

		frame.statusBar:SetMinMaxValues(1,maxRank);
		frame.statusBar:SetValue(rank);

		if frame.UnlearnButton ~= nil then
			frame.UnlearnButton:Show();
			frame.UnlearnButton:SetScript("OnClick", function() 
				StaticPopup_Show("UNLEARN_SKILL", name, nil, skillLine);
			end);
		end

		local prof_title = "";
		if (skillLineName) then
			prof_title = skillLineName;
		else
			for i=1,#PROFESSION_RANKS do
				local value,title = PROFESSION_RANKS[i][1], PROFESSION_RANKS[i][2];
				if maxRank < value then break end
				prof_title = title;
			end
		end
		frame.rank:SetText(prof_title);

		frame.statusBar:Show();
		if rank == maxRank then
			frame.statusBar.capRight:Show();
		else
			frame.statusBar.capRight:Hide();
		end

		frame.statusBar.capped:Hide();
		frame.statusBar.rankText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		frame.statusBar.tooltip = nil;

		-- trial cap
		if ( GameLimitedMode_IsActive() ) then
			local _, _, profCap = GetRestrictedAccountData();
			if rank >= profCap and profCap > 0 then
				frame.statusBar.capped:Show();
				frame.statusBar.rankText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				frame.statusBar.tooltip = RED_FONT_COLOR_CODE..CAP_REACHED_TRIAL..FONT_COLOR_CODE_CLOSE;
			end
		end

		if frame.icon and texture then
			SetPortraitToTexture(frame.icon, texture);
		end

		frame.professionName:SetText(name);

		if ( rankModifier > 0 ) then
			frame.statusBar.rankText:SetFormattedText(TRADESKILL_RANK_WITH_MODIFIER, rank, rankModifier, maxRank);
		else
			frame.statusBar.rankText:SetFormattedText(TRADESKILL_RANK, rank, maxRank);
		end

		local hasSpell = false;
		if numSpells <= 0 then
			frame.SpellButton1:Hide();
			frame.SpellButton2:Hide();
		elseif numSpells == 1 then
			hasSpell = true;
			frame.SpellButton2:Hide();
			frame.SpellButton1:Show();
			UpdateProfessionButton(frame.SpellButton1);
		else -- if numSpells >= 2 then
			hasSpell = true;
			frame.SpellButton1:Show();
			frame.SpellButton2:Show();
			UpdateProfessionButton(frame.SpellButton1);
			UpdateProfessionButton(frame.SpellButton2);
		end

		if hasSpell and SpellBookFrame.showProfessionSpellHighlights and C_ProfSpecs.ShouldShowPointsReminderForSkillLine(skillLine) then
			UIFrameFlash(frame.SpellButton1.Flash, 0.5, 0.5, -1);
		else
			UIFrameFlashStop(frame.SpellButton1.Flash);
		end

		if numSpells >  2 then
			local errorStr = "Found "..numSpells.." skills for "..name.." the max is 2:"
			for i=1,numSpells do
				errorStr = errorStr.." ("..GetSpellBookItemName(i + spelloffset, SpellBookFrame.bookType)..")";
			end
			assert(false, errorStr)
		end
	else
		frame.missingHeader:Show();
		frame.missingText:Show();

		if frame.icon then
			SetPortraitToTexture(frame.icon, "Interface\\Icons\\INV_Scroll_04");
			frame.specialization:SetText("");
		end
		frame.SpellButton1:Hide();
		frame.SpellButton2:Hide();
		frame.statusBar:Hide();
		frame.rank:SetText("");
		frame.professionName:SetText("");

		if frame.UnlearnButton ~= nil then
			frame.UnlearnButton:Hide();
		end
	end
end

function SpellBook_UpdateProfTab()
	local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();
	FormatProfession(PrimaryProfession1, prof1);
	FormatProfession(PrimaryProfession2, prof2);
	FormatProfession(SecondaryProfession1, arch);
	FormatProfession(SecondaryProfession2, fish);
	FormatProfession(SecondaryProfession3, cook);
	FormatProfession(SecondaryProfession4, firstAid);
	SpellBookPage1:SetDesaturated(false);
	SpellBookPage2:SetDesaturated(false);
end