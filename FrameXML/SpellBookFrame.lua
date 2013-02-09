MAX_SPELLS = 1024;
MAX_SKILLLINE_TABS = 8;
SPELLS_PER_PAGE = 12;
MAX_SPELL_PAGES = ceil(MAX_SPELLS / SPELLS_PER_PAGE);

BOOKTYPE_SPELL = "spell";
BOOKTYPE_PROFESSION = "professions";
BOOKTYPE_PET = "pet";
BOOKTYPE_CORE_ABILITIES = "core";
BOOKTYPE_WHAT_HAS_CHANGED = "changed"

local MaxSpellBookTypes = 5;
local SpellBookInfo = {};
SpellBookInfo[BOOKTYPE_SPELL] 		= { 	showFrames = {"SpellBookSpellIconsFrame", "SpellBookSideTabsFrame", "SpellBookPageNavigationFrame"}, 		
											title = SPELLBOOK,
											updateFunc = function() SpellBook_UpdatePlayerTab(); end
										};									
SpellBookInfo[BOOKTYPE_PROFESSION] 	= { 	showFrames = {"SpellBookProfessionFrame"}, 	
											title = TRADE_SKILLS,					
											updateFunc = function() SpellBook_UpdateProfTab(); end,
											bgFileL="Interface\\Spellbook\\Professions-Book-Left",
											bgFileR="Interface\\Spellbook\\Professions-Book-Right"
										};
SpellBookInfo[BOOKTYPE_PET] 		= { 	showFrames = {"SpellBookSpellIconsFrame", "SpellBookPageNavigationFrame"}, 		
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

SpellBookFrames = {	"SpellBookSpellIconsFrame", "SpellBookProfessionFrame",  "SpellBookSideTabsFrame", "SpellBookPageNavigationFrame", "SpellBookCoreAbilitiesFrame", "SpellBookWhatHasChanged"};

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
	HelpPlate_Hide();
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

	local tutorial, helpPlate = SpellBookFrame_GetTutorialEnum()
	if ( tutorial and not GetCVarBitfield("closedInfoFrames", tutorial) and GetCVarBool("showTutorials") ) then
		if ( helpPlate and not HelpPlate_IsShowing(helpPlate) and SpellBookFrame:IsShown()) then
			HelpPlate_Show( helpPlate, SpellBookFrame, SpellBookFrame.MainHelpButton );
			SetCVarBitfield( "closedInfoFrames", tutorial, true );
		end
	end
end

function SpellBookFrame_GetTutorialEnum()
	local helpPlate;
	local tutorial;
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		helpPlate = SpellBookFrame_HelpPlate;
		tutorial = LE_FRAME_TUTORIAL_SPELLBOOK;
	elseif ( SpellBookFrame.bookType == BOOKTYPE_PROFESSION ) then
		helpPlate = ProfessionsFrame_HelpPlate;
		tutorial = LE_FRAME_TUTORIAL_PROFESSIONS;
	elseif ( SpellBookFrame.bookType == BOOKTYPE_CORE_ABILITIES ) then
		helpPlate = CoreAbilitiesFrame_HelpPlate;
		tutorial = LE_FRAME_TUTORIAL_CORE_ABILITITES;
	elseif ( SpellBookFrame.bookType == BOOKTYPE_WHAT_HAS_CHANGED ) then
		helpPlate = WhatHasChangedFrame_HelpPlate;
		tutorial = LE_FRAME_TUTORIAL_WHAT_HAS_CHANGED;
	end
	return tutorial, helpPlate;
end

function SpellBookFrame_OnLoad(self)
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("LEARNED_SPELL_IN_TAB");	
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("PLAYER_GUILD_UPDATE");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");

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
	
	-- Set to the class tab by default
	SpellBookFrame.selectedSkillLine = 2;

	-- Initialize tab flashing
	SpellBookFrame.flashTabs = nil;
	
	-- Initialize portrait texture
	SetPortraitToTexture(SpellBookFramePortrait, "Interface\\Spellbook\\Spellbook-Icon");
	
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
			SpellBookFrame.selectedSkillLine = 2;
			SpellBookFrame_Update();
		else
			SpellBookFrame_UpdateSkillLineTabs();
		end
	elseif ( event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		local unit = ...;
		if ( unit == "player" ) then
			SpellBookFrame.selectedSkillLine = 2; -- number of skilllines will change!
			SpellBookFrame_Update();
		end
	end
end

function SpellBookFrame_OnShow(self)
	SpellBookCoreAbilitiesFrame.selectedSpec = GetSpecialization() or 1;
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
	SpellBookFrameTabButton2.binding = "TOGGLEPROFESSIONBOOK";
	
	local tabIndex = 3;
	-- check to see if we have a pet
	local hasPetSpells, petToken = HasPetSpells();
	SpellBookFrame.petTitle = nil;
	if ( hasPetSpells and PetHasSpellbook() ) then
		SpellBookFrame.petTitle = _G["PET_TYPE_"..petToken];
		local nextTab = _G["SpellBookFrameTabButton"..tabIndex];
		nextTab:Show();
		nextTab.bookType = BOOKTYPE_PET;		
		nextTab.binding = "TOGGLEPETBOOK";
		nextTab:SetText(SpellBookInfo[BOOKTYPE_PET].title);
		tabIndex = tabIndex+1;
	elseif (SpellBookFrame.bookType == BOOKTYPE_PET) then
		SpellBookFrame.bookType = _G["SpellBookFrameTabButton"..tabIndex-1].bookType;
	end
	
	local level = UnitLevel("player");
	
	if ( level >= 20 ) then
		local nextTab = _G["SpellBookFrameTabButton"..tabIndex];
		nextTab:Show();
		nextTab.bookType = BOOKTYPE_CORE_ABILITIES;
		nextTab.binding = "TOGGLECOREABILITIESBOOK";
		nextTab:SetText(SpellBookInfo[BOOKTYPE_CORE_ABILITIES].title);
		tabIndex = tabIndex+1;
	end
	
	if ( level >= 40 ) then
		local nextTab = _G["SpellBookFrameTabButton"..tabIndex];
		nextTab:Show();
		nextTab.bookType = BOOKTYPE_WHAT_HAS_CHANGED;
		nextTab.binding = "TOGGLEWHATHASCHANGEDBOOK";
		nextTab:SetText(SpellBookInfo[BOOKTYPE_WHAT_HAS_CHANGED].title);
	end
	
	-- Make sure the correct tab is selected
	for i=1,MaxSpellBookTypes do
		local tab = _G["SpellBookFrameTabButton"..i];
		PanelTemplates_TabResize(tab, 0, nil, 40);
		if ( tab.bookType == SpellBookFrame.bookType ) then
			PanelTemplates_SelectTab(tab);
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
	
	SpellBookFrameTitleText:SetText(SpellBookInfo[SpellBookFrame.bookType].title);
	
	local tabUpdate = SpellBookInfo[SpellBookFrame.bookType].updateFunc;
	if(tabUpdate) then
		tabUpdate()
	end
end

function SpellBookFrame_UpdateSpells ()
	for i = 1, SPELLS_PER_PAGE do
		_G["SpellButton" .. i]:Show();
		SpellButton_UpdateButton(_G["SpellButton" .. i]);
	end

	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		SpellBookPage1:SetDesaturated(_G["SpellBookSkillLineTab"..SpellBookFrame.selectedSkillLine].isOffSpec);
		SpellBookPage2:SetDesaturated(_G["SpellBookSkillLineTab"..SpellBookFrame.selectedSkillLine].isOffSpec);
	else
		SpellBookPage1:SetDesaturated(0);
		SpellBookPage2:SetDesaturated(0);
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
		PlaySound("igSpellBookOpen");
	elseif ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		-- Need to change to pet book open sound
		PlaySound("igAbilityOpen");
	else
		PlaySound("igSpellBookOpen");
	end
end

function SpellBookFrame_PlayCloseSound()
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound("igSpellBookClose");
	else
		-- Need to change to pet book close sound
		PlaySound("igAbilityClose");
	end
end

function SpellBookFrame_OnHide(self)
	HelpPlate_Hide();
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

function SpellButton_OnLoad(self) 
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function SpellButton_OnEvent(self, event, ...)
	if ( event == "SPELLS_CHANGED" or event == "UPDATE_SHAPESHIFT_FORM" ) then
		-- need to listen for UPDATE_SHAPESHIFT_FORM because attack icons change when the shapeshift form changes
		SpellButton_UpdateButton(self);
	elseif ( event == "SPELL_UPDATE_COOLDOWN" ) then
		SpellButton_UpdateCooldown(self);
		-- Update tooltip
		if ( GameTooltip:GetOwner() == self ) then
			SpellButton_OnEnter(self);
		end
	elseif ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
		SpellButton_UpdateSelection(self);
	elseif ( event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" or event == "ARCHAEOLOGY_CLOSED" ) then
		SpellButton_UpdateSelection(self);
	elseif ( event == "PET_BAR_UPDATE" ) then
		if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
			SpellButton_UpdateButton(self);
		end
	end
end

function SpellButton_OnShow(self)
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
	self:RegisterEvent("TRADE_SKILL_SHOW");
	self:RegisterEvent("TRADE_SKILL_CLOSE");
	self:RegisterEvent("ARCHAEOLOGY_CLOSED");
	self:RegisterEvent("PET_BAR_UPDATE");

	--SpellButton_UpdateButton(self);
end

function SpellButton_OnHide(self)
	self:UnregisterEvent("SPELLS_CHANGED");
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED");
	self:UnregisterEvent("TRADE_SKILL_SHOW");
	self:UnregisterEvent("TRADE_SKILL_CLOSE");
	self:UnregisterEvent("ARCHAEOLOGY_CLOSED");
	self:UnregisterEvent("PET_BAR_UPDATE");
end
 
function SpellButton_OnEnter(self)
	local slot = SpellBook_GetSpellBookSlot(self);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( GameTooltip:SetSpellBookItem(slot, SpellBookFrame.bookType) ) then
		self.UpdateTooltip = SpellButton_OnEnter;
	else
		self.UpdateTooltip = nil;
	end
end

function SpellButton_OnClick(self, button)
	local slot, slotType = SpellBook_GetSpellBookSlot(self);
	if ( slot > MAX_SPELLS or slotType == "FUTURESPELL") then
		return;
	end
	if ( button ~= "LeftButton" and SpellBookFrame.bookType == BOOKTYPE_PET ) then
		if ( self.offSpecID == 0 ) then
			ToggleSpellAutocast(slot, SpellBookFrame.bookType);
		end
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
		SpellButton_UpdateSelection(self);
	end
end

function SpellButton_OnModifiedClick(self, button) 
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
			local spellLink, tradeSkillLink = GetSpellLink(slot, SpellBookFrame.bookType);
			if ( tradeSkillLink ) then
				ChatEdit_InsertLink(tradeSkillLink);
			elseif ( spellLink ) then
				ChatEdit_InsertLink(spellLink);
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
		SpellButton_UpdateSelection(self);
		return;
	end
end

function SpellButton_OnDrag(self) 
	local slot, slotType = SpellBook_GetSpellBookSlot(self);
	if (not slot or slot > MAX_SPELLS or not _G[self:GetName().."IconTexture"]:IsShown() or (slotType == "FUTURESPELL")) then
		return;
	end
	self:SetChecked(0);
	PickupSpellBookItem(slot, SpellBookFrame.bookType);
end

function SpellButton_UpdateSelection(self)
	local slot = SpellBook_GetSpellBookSlot(self);
	if ( slot and IsSelectedSpellBookItem(slot, SpellBookFrame.bookType) ) then
		self:SetChecked("true");
	else
		self:SetChecked("false");
	end
end

function SpellButton_UpdateCooldown(self)
	local cooldown = _G[self:GetName().."Cooldown"];
	local slot, slotType = SpellBook_GetSpellBookSlot(self);
	if (slot) then
		local start, duration, enable = GetSpellCooldown(slot, SpellBookFrame.bookType);
		if (cooldown and start and duration) then
			CooldownFrame_SetTimer(cooldown, start, duration, enable);
		end
	end
end

function SpellButton_UpdateButton(self)
	if SpellBookFrame.bookType == BOOKTYPE_PROFESSION then
		UpdateProfessionButton(self);
		return;
	end

	if ( not SpellBookFrame.selectedSkillLine ) then
		SpellBookFrame.selectedSkillLine = 2;
	end
	local temp, texture, offset, numSlots, isGuild, offSpecID = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
	SpellBookFrame.selectedSkillLineNumSlots = numSlots;
	SpellBookFrame.selectedSkillLineOffset = offset;
	local isOffSpec = (offSpecID ~= 0) and (SpellBookFrame.bookType == BOOKTYPE_SPELL);
	self.offSpecID = offSpecID;
	
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

	-- Hide flyout if it's currently open
	if (SpellFlyout:IsShown() and SpellFlyout:GetParent() == self)  then
		SpellFlyout:Hide();
	end

	local highlightTexture = _G[name.."Highlight"];
	local texture;
	if ( slot ) then
		texture = GetSpellBookItemTexture(slot, SpellBookFrame.bookType);
	end

	-- If no spell, hide everything and return
	if ( not texture or (strlen(texture) == 0) ) then
		iconTexture:Hide();
		spellString:Hide();
		subSpellString:Hide();
		cooldown:Hide();
		autoCastableTexture:Hide();
		SpellBook_ReleaseAutoCastShine(self.shine);
		self.shine = nil;
		highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		self:SetChecked(0);
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
		self.TextBackground:SetDesaturated(isOffSpec);
		self.TextBackground2:SetDesaturated(isOffSpec);
		self.EmptySlot:SetDesaturated(isOffSpec);
		return;
	else
		self:Enable();
	end

	SpellButton_UpdateCooldown(self);

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

	local spellName, subSpellName = GetSpellBookItemName(slot, SpellBookFrame.bookType);
	local isPassive = IsPassiveSpell(slot, SpellBookFrame.bookType);
	self.isPassive = isPassive;

	if (slotType == "FLYOUT") then
		SetClampedTextureRotation(self.FlyoutArrow, 90);
		self.FlyoutArrow:Show();
	else
		self.FlyoutArrow:Hide();
	end
	
	local specs =  {GetSpecsForSpell(slot, SpellBookFrame.bookType)};
	local specName = table.concat(specs, PLAYER_LIST_DELIMITER);
	if ( subSpellName == "" ) then
		if ( specName and specName ~= "" ) then
			if ( isPassive ) then
				subSpellName = specName .. ", " .. SPELL_PASSIVE_SECOND
			else
				subSpellName = specName;
			end
		elseif ( IsTalentSpell(slot, SpellBookFrame.bookType) ) then
			if ( isPassive ) then
				subSpellName = TALENT_PASSIVE
			else
				subSpellName = TALENT
			end
		elseif ( isPassive ) then
			subSpellName = SPELL_PASSIVE;
		end
	end			

	-- If there is no spell sub-name, move the bottom row of text up
	if ( subSpellName == "" ) then
		self.SpellSubName:SetHeight(6);
	else
		self.SpellSubName:SetHeight(0);
	end

	iconTexture:SetTexture(texture);
	spellString:SetText(spellName);
	subSpellString:SetText(subSpellName);
	iconTexture:Show();
	spellString:Show();
	subSpellString:Show();
	
	if (not (slotType == "FUTURESPELL")) then
		slotFrame:Show();
		self.UnlearnedFrame:Hide();
		self.TrainFrame:Hide();
		self.IconTextureBg:Hide();
		iconTexture:SetAlpha(1);
		iconTexture:SetDesaturated(0);
		self.RequiredLevelString:Hide();
		self.SeeTrainerString:Hide();
		self.TrainTextBackground:Hide();
		self.TrainBook:Hide();
		self.SpellName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		self.SpellName:SetShadowOffset(self.SpellName.shadowX, self.SpellName.shadowY);
		self.SpellName:SetPoint("LEFT", self, "RIGHT", 8, 4);
		self.SpellSubName:SetTextColor(0, 0, 0);
		if ( slotType == "SPELL" and isOffSpec ) then
			local level = GetSpellLevelLearned(slotID);
			if ( level and level > UnitLevel("player") ) then
				self.RequiredLevelString:Show();
				self.RequiredLevelString:SetFormattedText(SPELLBOOK_AVAILABLE_AT, level);
				self.RequiredLevelString:SetTextColor(0.25, 0.12, 0);
			end
		end
	else
		local level = GetSpellAvailableLevel(slot, SpellBookFrame.bookType);
		slotFrame:Hide();
		self.IconTextureBg:Show();
		iconTexture:SetAlpha(0.5);
		iconTexture:SetDesaturated(1);
		if (level and level > UnitLevel("player")) then
			self.SeeTrainerString:Hide();
			self.RequiredLevelString:Show();
			self.RequiredLevelString:SetFormattedText(SPELLBOOK_AVAILABLE_AT, level);
			self.RequiredLevelString:SetTextColor(0.25, 0.12, 0);
			self.UnlearnedFrame:Show();
			self.TrainFrame:Hide();
			self.TrainTextBackground:Hide();
			self.TrainBook:Hide();
			self.SpellName:SetTextColor(0.25, 0.12, 0);
			self.SpellSubName:SetTextColor(0.25, 0.12, 0);
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
			self.SpellSubName:SetTextColor(0, 0, 0);
		end
	end

	if ( isPassive ) then
		highlightTexture:SetTexture("Interface\\Buttons\\UI-PassiveHighlight");
		slotFrame:Hide();
		self.UnlearnedFrame:Hide();
	else
		highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
	end

	-- set all the desaturated offspec pages
	slotFrame:SetDesaturated(isOffSpec);
	self.TextBackground:SetDesaturated(isOffSpec);
	self.TextBackground2:SetDesaturated(isOffSpec);
	self.EmptySlot:SetDesaturated(isOffSpec);
	self.FlyoutArrow:SetDesaturated(isOffSpec);
	if (isOffSpec) then
		iconTexture:SetDesaturated(isOffSpec);
		self.SpellName:SetTextColor(0.75, 0.75, 0.75);
		self.RequiredLevelString:SetTextColor(0.1, 0.1, 0.1);
		autoCastableTexture:Hide();
		SpellBook_ReleaseAutoCastShine(self.shine);
		self.shine = nil;
		self:SetChecked("false");
	else
		SpellButton_UpdateSelection(self);
	end
end

function SpellBookPrevPageButton_OnClick()
	local pageNum = SpellBook_GetCurrentPage() - 1;
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound("igAbiliityPageTurn");
		SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = pageNum;
	else
		-- Need to change to pet book pageturn sound
		PlaySound("igAbiliityPageTurn");
		SPELLBOOK_PAGENUMBERS[SpellBookFrame.bookType] = pageNum;
	end
	SpellBookFrame_Update();
end

function SpellBookNextPageButton_OnClick()
	local pageNum = SpellBook_GetCurrentPage() + 1;
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		PlaySound("igAbiliityPageTurn");
		SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] = pageNum;
	else
		-- Need to change to pet book pageturn sound
		PlaySound("igAbiliityPageTurn");
		SPELLBOOK_PAGENUMBERS[SpellBookFrame.bookType] = pageNum;
	end
	SpellBookFrame_Update();
end

function SpellBookSkillLineTab_OnClick(self)
	local id = self:GetID();
	if ( SpellBookFrame.selectedSkillLine ~= id ) then
		PlaySound("igAbiliityPageTurn");
		SpellBookFrame.selectedSkillLine = id;
		SpellBookFrame_Update();
	else
		self:SetChecked(1);
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
		return id + (SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] - 1));
	else
		local relativeSlot = id + ( SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine] - 1));
		if ( SpellBookFrame.selectedSkillLineNumSlots and relativeSlot <= SpellBookFrame.selectedSkillLineNumSlots) then
			local slot = SpellBookFrame.selectedSkillLineOffset + relativeSlot;
			local slotType, slotID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
			return slot, slotType, slotID;
		else
			return nil, nil;
		end
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
		local name, texture, offset, numSlots = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
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
function SpellBookFrame_UpdateSkillLineTabs()
	local numSkillLineTabs = GetNumSpellTabs();
	for i=1, MAX_SKILLLINE_TABS do
		local skillLineTab = _G["SpellBookSkillLineTab"..i];
		local prevTab = _G["SpellBookSkillLineTab"..i-1];
		if ( i <= numSkillLineTabs and SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
			local name, texture, _, _, isGuild, offSpecID = GetSpellTabInfo(i);
			local isOffSpec = (offSpecID ~= 0);
			skillLineTab:SetNormalTexture(texture);
			skillLineTab.tooltip = name;
			skillLineTab:Show();
			skillLineTab.isOffSpec = isOffSpec;
			if(texture) then
				skillLineTab:GetNormalTexture():SetDesaturated(isOffSpec);
			end

			-- Guild tab gets additional space
			if (prevTab) then
				if (isGuild) then
					skillLineTab:SetPoint("TOPLEFT", prevTab, "BOTTOMLEFT", 0, -46);
				elseif (isOffSpec and not prevTab.isOffSpec) then
					skillLineTab:SetPoint("TOPLEFT", prevTab, "BOTTOMLEFT", 0, -40);
				else
					skillLineTab:SetPoint("TOPLEFT", prevTab, "BOTTOMLEFT", 0, -17);
				end
			end
			
			-- Guild tab must show the Guild Banner
			if (isGuild) then
				skillLineTab:SetNormalTexture("Interface\\SpellBook\\GuildSpellbooktabBG");
				skillLineTab.TabardEmblem:Show();
				skillLineTab.TabardIconFrame:Show();
				SetLargeGuildTabardTextures("player", skillLineTab.TabardEmblem, skillLineTab:GetNormalTexture(), skillLineTab.TabardIconFrame);
			else
				skillLineTab.TabardEmblem:Hide();
				skillLineTab.TabardIconFrame:Hide();
			end

			-- Set the selected tab
			if ( SpellBookFrame.selectedSkillLine == i ) then
				skillLineTab:SetChecked(1);
				--SpellBookSpellGroupText:SetText(name);
			else
				skillLineTab:SetChecked(nil);
			end
		else
			_G["SpellBookSkillLineTab"..i.."Flash"]:Hide();
			skillLineTab:Hide();
		end
	end
end

function SpellBook_UpdatePlayerTab()

	-- Setup skillline tabs
	local name, texture, offset, numSlots = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
	SpellBookFrame.selectedSkillLineOffset = offset;
	SpellBookFrame.selectedSkillLineNumSlots = numSlots;
	
	SpellBookFrame_UpdatePages();

	SpellBookFrame_UpdateSkillLineTabs();

	SpellBookFrame_UpdateSpells();
end


function SpellBook_UpdatePetTab(showing)
	SpellBookFrame_UpdatePages();
	SpellBookFrame_UpdateSpells();
end

function UpdateProfessionButton(self)
	local spellIndex = self:GetID() + self:GetParent().spellOffset;
	local texture = GetSpellBookItemTexture(spellIndex, SpellBookFrame.bookType);
	local spellName, subSpellName = GetSpellBookItemName(spellIndex, SpellBookFrame.bookType);
	local isPassive = IsPassiveSpell(spellIndex, SpellBookFrame.bookType);
	if ( isPassive ) then
		self.highlightTexture:SetTexture("Interface\\Buttons\\UI-PassiveHighlight");
		self.spellString:SetTextColor(PASSIVE_SPELL_FONT_COLOR.r, PASSIVE_SPELL_FONT_COLOR.g, PASSIVE_SPELL_FONT_COLOR.b);
	else
		self.highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		self.spellString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	
	self.iconTexture:SetTexture(texture);
	local start, duration, enable = GetSpellCooldown(spellIndex, SpellBookFrame.bookType);
	CooldownFrame_SetTimer(self.cooldown, start, duration, enable);
	if ( enable == 1 ) then
		self.iconTexture:SetVertexColor(1.0, 1.0, 1.0);
	else
		self.iconTexture:SetVertexColor(0.4, 0.4, 0.4);
	end

	if ( self:GetParent().specializationIndex >= 0 and self:GetID() == self:GetParent().specializationOffset) then
		self.unlearn:Show();
	else
		self.unlearn:Hide();
	end
	
	self.spellString:SetText(spellName);
	self.subSpellString:SetText(subSpellName);	
	self.iconTexture:SetTexture(texture);
	
	SpellButton_UpdateSelection(self);
end

function FormatProfession(frame, index)
	if index then
		frame.missingHeader:Hide();
		frame.missingText:Hide();
		
		local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier, specializationIndex, specializationOffset = GetProfessionInfo(index);
		frame.skillName = name;
		frame.spellOffset = spelloffset;
		frame.skillLine = skillLine;
		frame.specializationIndex = specializationIndex;
		frame.specializationOffset = specializationOffset;
		
		frame.statusBar:SetMinMaxValues(1,maxRank);
		frame.statusBar:SetValue(rank);
		
		local prof_title = "";
		for i=1,#PROFESSION_RANKS do
		    local value,title = PROFESSION_RANKS[i][1], PROFESSION_RANKS[i][2]; 
			if maxRank < value then break end
			prof_title = title;
		end
		frame.rank:SetText(prof_title);
		
		frame.statusBar:Show();
		if rank == maxRank then
			frame.statusBar.capRight:Show();
		else
			frame.statusBar.capRight:Hide();
		end
		-- trial cap
		if IsTrialAccount() then
			local _, _, profCap = GetRestrictedAccountData();
			if rank >= profCap then
				frame.statusBar.capped:Show();
				frame.statusBar.rankText:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
				frame.statusBar.tooltip = RED_FONT_COLOR_CODE..TRIAL_CAPPED;
			else
				frame.statusBar.capped:Hide();
				frame.statusBar.rankText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				frame.statusBar.tooltip = nil;
			end
		end
		
		if frame.icon and texture then
			SetPortraitToTexture(frame.icon, texture);	
			frame.unlearn:Show();
		end
		
		frame.professionName:SetText(name);
		
		if ( rankModifier > 0 ) then
			frame.statusBar.rankText:SetFormattedText(TRADESKILL_RANK_WITH_MODIFIER, rank, rankModifier, maxRank);
		else
			frame.statusBar.rankText:SetFormattedText(TRADESKILL_RANK, rank, maxRank);
		end

		
		if numSpells <= 0 then		
			frame.button1:Hide();
			frame.button2:Hide();
		elseif numSpells == 1 then		
			frame.button2:Hide();
			frame.button1:Show();
			UpdateProfessionButton(frame.button1);		
		else -- if numSpells >= 2 then	
			frame.button1:Show();
			frame.button2:Show();
			UpdateProfessionButton(frame.button1);			
			UpdateProfessionButton(frame.button2);
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
			frame.unlearn:Hide();			
			frame.specialization:SetText("");
		end			
		frame.button1:Hide();
		frame.button2:Hide();
		frame.statusBar:Hide();
		frame.rank:SetText("");
		frame.professionName:SetText("");		
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
end


-- *************************************************************************************

-- String prefixes for text
SPEC_CORE_ABILITY_TEXT = {}
SPEC_CORE_ABILITY_TEXT[250] = "DK_BLOOD";
SPEC_CORE_ABILITY_TEXT[251] = "DK_FROST";
SPEC_CORE_ABILITY_TEXT[252] = "DK_UNHOLY";

SPEC_CORE_ABILITY_TEXT[102] = "DRUID_BALANCE";
SPEC_CORE_ABILITY_TEXT[103] = "DRUID_FERAL";
SPEC_CORE_ABILITY_TEXT[104] = "DRUID_GUARDIAN";
SPEC_CORE_ABILITY_TEXT[105] = "DRUID_RESTO";

SPEC_CORE_ABILITY_TEXT[253] = "HUNTER_BM";
SPEC_CORE_ABILITY_TEXT[254] = "HUNTER_MM";
SPEC_CORE_ABILITY_TEXT[255] = "HUNTER_SV";

SPEC_CORE_ABILITY_TEXT[62] = "MAGE_ARCANE";
SPEC_CORE_ABILITY_TEXT[63] = "MAGE_FIRE";
SPEC_CORE_ABILITY_TEXT[64] = "MAGE_FROST";

SPEC_CORE_ABILITY_TEXT[268] = "MONK_BREW";
SPEC_CORE_ABILITY_TEXT[270] = "MONK_MIST";
SPEC_CORE_ABILITY_TEXT[269] = "MONK_WIND";

SPEC_CORE_ABILITY_TEXT[65] = "PALADIN_HOLY";
SPEC_CORE_ABILITY_TEXT[66] = "PALADIN_PROT";
SPEC_CORE_ABILITY_TEXT[70] = "PALADIN_RET";

SPEC_CORE_ABILITY_TEXT[256] = "PRIEST_DISC";
SPEC_CORE_ABILITY_TEXT[257] = "PRIEST_HOLY";
SPEC_CORE_ABILITY_TEXT[258] = "PRIEST_SHADOW";

SPEC_CORE_ABILITY_TEXT[259] = "ROGUE_ASS";
SPEC_CORE_ABILITY_TEXT[260] = "ROGUE_COMBAT";
SPEC_CORE_ABILITY_TEXT[261] = "ROGUE_SUB";

SPEC_CORE_ABILITY_TEXT[262] = "SHAMAN_ELE";
SPEC_CORE_ABILITY_TEXT[263] = "SHAMAN_ENHANCE";
SPEC_CORE_ABILITY_TEXT[264] = "SHAMAN_RESTO";

SPEC_CORE_ABILITY_TEXT[265] = "WARLOCK_AFFLICTION";
SPEC_CORE_ABILITY_TEXT[266] = "WARLOCK_DEMO";
SPEC_CORE_ABILITY_TEXT[267] = "WARLOCK_DESTRO";

SPEC_CORE_ABILITY_TEXT[71] = "WARRIOR_ARMS";
SPEC_CORE_ABILITY_TEXT[72] = "WARRIOR_FURY";
SPEC_CORE_ABILITY_TEXT[73] = "WARRIOR_PROT";

-- Hardcoded spell id's for spec display
SPEC_CORE_ABILITY_DISPLAY = {}
SPEC_CORE_ABILITY_DISPLAY[250] = {	45462,	45477,	55050,	49998,	56815,			}; --Blood
SPEC_CORE_ABILITY_DISPLAY[251] = {	45462,	49184,	49020,	49143,					}; --Frost
SPEC_CORE_ABILITY_DISPLAY[252] = {	45462,	45477,	55090,	85948,	63560,	47541,	}; --Unholy

SPEC_CORE_ABILITY_DISPLAY[102] = {	79577,	8921,	93402,	5176,	2912,	78674,	}; --Balance
SPEC_CORE_ABILITY_DISPLAY[103] = {	5221,	33917 ,	1822,	52610,	1079,	22568,	}; --Feral
SPEC_CORE_ABILITY_DISPLAY[104] = {	33745,	77758,	33917,	62606,	22842,			}; --Guardian
SPEC_CORE_ABILITY_DISPLAY[105] = {	774,	8936,	50464,	5185,	33763,	18562,	}; --Restoration

SPEC_CORE_ABILITY_DISPLAY[253] = {	1978,	34026,	3044,	77767,	53351,			}; --Beast Mastery
SPEC_CORE_ABILITY_DISPLAY[254] = {	1978,	19434,	53209,	3044,	56641,	53351,	}; --Marskmanship
SPEC_CORE_ABILITY_DISPLAY[255] = {	1978,	3674,	53301,	3044,	77767,	53351,	}; --Survival

SPEC_CORE_ABILITY_DISPLAY[62] = {	114664,	30451,	5143,	44425,	}; --Arcane
SPEC_CORE_ABILITY_DISPLAY[63] = {	133,	11129,	108853,	11366,	}; --Fire
SPEC_CORE_ABILITY_DISPLAY[64] = {	116,	44614,	84714,	30455,	}; --Frost

SPEC_CORE_ABILITY_DISPLAY[268] = {	100780,	115295,	100784,	115180,	115181, }; --Brewmaster
SPEC_CORE_ABILITY_DISPLAY[270] = {	116694,	115151,	116670,	115175,	115460, }; --Mistweaver
SPEC_CORE_ABILITY_DISPLAY[269] = {	100780,	100787,	100784,	107428,	115072,	113656,	}; --Windwalker

SPEC_CORE_ABILITY_DISPLAY[65] = {	20473,	19750,	635,	82326,	85673,	53563,	}; --Holy
SPEC_CORE_ABILITY_DISPLAY[66] = {	31935,	20271,	35395,	26573,	119072,	53600,	}; --Protection
SPEC_CORE_ABILITY_DISPLAY[70] = {	20271,	35395,	879,	84963,	85256,	24275,	}; --Retribution

SPEC_CORE_ABILITY_DISPLAY[256] = {	33076,	47540,	2061,	2050,	2060,	17		}; --Discipline
SPEC_CORE_ABILITY_DISPLAY[257] = {	33076,	139,	2061,	2050,	2060,	126172	}; --Holy
SPEC_CORE_ABILITY_DISPLAY[258] = {	589,	34914,	8092,	15407,	2944,	32379,	}; --Shadow

SPEC_CORE_ABILITY_DISPLAY[259] = {	1329,	1943,	5171,	32645,	111240,	}; --Assassination
SPEC_CORE_ABILITY_DISPLAY[260] = {	1752,	84617,	5171,	2098,			}; --Combat
SPEC_CORE_ABILITY_DISPLAY[261] = {	53,		16511,	1943,	5171,	2098,	}; --Subtlety

SPEC_CORE_ABILITY_DISPLAY[262] = {	8050,	324,	8042,	51505,	403,	}; --Elemental
SPEC_CORE_ABILITY_DISPLAY[263] = {	8050,	17364,	60103,	403,			}; --Enhancement
SPEC_CORE_ABILITY_DISPLAY[264] = {	974,	61295,	8004,	331,	77472,	}; --Restoration

SPEC_CORE_ABILITY_DISPLAY[265] = {	172,	980,	30108,	103103,	1120,	48181,	}; --Affliction
SPEC_CORE_ABILITY_DISPLAY[266] = {	104315,	172,	105174,	686,	6353,	103958,	}; --Demonology
SPEC_CORE_ABILITY_DISPLAY[267] = {	108647,	348,	17962,	29722,	116858,	17877,	}; --Destruction

SPEC_CORE_ABILITY_DISPLAY[71] = {	100,	86346,	12294,	7384,	1464,	5308,	}; --Arms
SPEC_CORE_ABILITY_DISPLAY[72] = {	100,	23881,	85288,	100130,	5308,			}; --Fury	
SPEC_CORE_ABILITY_DISPLAY[73] = {	100,	23922,	6572,	20243,	2565,			}; --Protection

function SpellBook_GetCoreAbilityButton(index)
	local button = SpellBookCoreAbilitiesFrame.Abilities[index];
	if ( not button ) then
		SpellBookCoreAbilitiesFrame.Abilities[index] = CreateFrame("BUTTON", nil, SpellBookCoreAbilitiesFrame, "CoreAbilitySpellTemplate");
		button = SpellBookCoreAbilitiesFrame.Abilities[index];
		button:SetPoint("TOP", SpellBookCoreAbilitiesFrame.Abilities[index-1], "BOTTOM", 0, -29);
	end
	return button;
end

function SpellBook_GetCoreAbilitySpecTab(index)
	local tab = SpellBookCoreAbilitiesFrame.SpecTabs[index];
	if ( not tab ) then
		SpellBookCoreAbilitiesFrame.SpecTabs[index] = CreateFrame("CHECKBUTTON", nil, SpellBookCoreAbilitiesFrame, "CoreAbilitiesSkillLineTabTemplate");
		tab = SpellBookCoreAbilitiesFrame.SpecTabs[index]
		tab:SetPoint("TOPLEFT", SpellBookCoreAbilitiesFrame.SpecTabs[index-1], "BOTTOMLEFT", 0, -17);
	end
	return tab;
end

function SpellBookCoreAbilitiesTab_OnClick(self)
	PlaySound("igAbiliityPageTurn");
	SpellBookCoreAbilitiesFrame.selectedSpec = self:GetID();
	SpellBook_UpdateCoreAbilitiesTab();
end

function SpellBookCoreAbilities_UpdateTabs()
	local numSpecs = GetNumSpecializations();
	local currentSpec = GetSpecialization();
	local index = 1;
	local tab;
	if ( currentSpec ) then
		tab = SpellBook_GetCoreAbilitySpecTab(index);
		local id, name, description, icon = GetSpecializationInfo(currentSpec);
		tab:SetID(currentSpec);
		tab:SetNormalTexture(icon);
		tab:SetChecked(SpellBookCoreAbilitiesFrame.selectedSpec == tab:GetID());
		tab.tooltip = name;
		tab:Show();
		index = index + 1;
	end
	
	tab = SpellBook_GetCoreAbilitySpecTab(2);
	if ( currentSpec ) then
		tab:SetPoint("TOPLEFT", SpellBookCoreAbilitiesFrame.SpecTabs[1], "BOTTOMLEFT", 0, -40);
	else
		tab:SetPoint("TOPLEFT", SpellBookCoreAbilitiesFrame.SpecTabs[1], "BOTTOMLEFT", 0, -17);
	end
	
	for i=1, numSpecs do
		if ( not currentSpec or currentSpec ~= i ) then
			tab = SpellBook_GetCoreAbilitySpecTab(index);
			local id, name, description, icon = GetSpecializationInfo(i);
			tab:SetID(i);
			tab:SetNormalTexture(icon);
			tab:SetChecked(SpellBookCoreAbilitiesFrame.selectedSpec == tab:GetID());
			tab:GetNormalTexture():SetDesaturated(currentSpec and not (currentSpec == i));
			tab.tooltip = name;
			tab:Show();
			index = index + 1;
		end
	end
	for i = numSpecs + 1, #SpellBookCoreAbilitiesFrame.SpecTabs do
		SpellBook_GetCoreAbilitySpecTab(i):Hide();
	end
end

function SpellBook_UpdateCoreAbilitiesTab()
	SpellBookFrame_UpdatePages();
	SpellBookCoreAbilities_UpdateTabs();
	
	local currentSpec = GetSpecialization();
	local desaturate = currentSpec and (currentSpec ~= SpellBookCoreAbilitiesFrame.selectedSpec);
	local specID, displayName = GetSpecializationInfo(SpellBookCoreAbilitiesFrame.selectedSpec);
	local draggable = false;
	if ( GetSpecialization() == SpellBookCoreAbilitiesFrame.selectedSpec ) then
		draggable = true;
	end
	
	SpellBookCoreAbilitiesFrame.SpecName:SetText(displayName);
	
	local abilityList = SPEC_CORE_ABILITY_DISPLAY[specID];
	if ( abilityList ) then
		for i=1, #abilityList do
			local name, subname = GetSpellInfo(abilityList[i]);
			local _, icon = GetSpellTexture(abilityList[i]);
			local button = SpellBook_GetCoreAbilityButton(i);
			local level = GetSpellLevelLearned(abilityList[i]);
			local showLevel = (level and level > UnitLevel("player"));
			local isPassive = IsPassiveSpell(abilityList[i]);
			
			button.spellID = abilityList[i];
			button.Name:SetText(name);
			button.InfoText:SetText(_G[SPEC_CORE_ABILITY_TEXT[specID].."_CORE_ABILITY_"..i]);

			button.iconTexture:SetTexture(icon);
			button.iconTexture:SetDesaturated(showLevel or desaturate);
			
			button.ActiveTexture:SetShown(not showLevel and not isPassive);
			button.ActiveTexture:SetDesaturated(desaturate);
			button.FutureTexture:SetShown(showLevel);
			button.FutureTexture:SetDesaturated(desaturate);
			button.EmptySlot:SetDesaturated(desaturate);
			button.draggable = draggable and not isPassive and not showLevel;
			
			if ( showLevel ) then
				button.RequiredLevel:SetFormattedText(SPELLBOOK_AVAILABLE_AT, level);
			else
				button.RequiredLevel:SetText("");
			end
	
			if ( showLevel or isPassive ) then
				button.highlightTexture:SetTexture("Interface\\Buttons\\UI-PassiveHighlight");
			else
				button.highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
			end
	
			button:Show();
		end
	end
	for i = #abilityList + 1, #SpellBookCoreAbilitiesFrame.Abilities do
		SpellBook_GetCoreAbilityButton(i):Hide();
	end

	SpellBookPage1:SetDesaturated(desaturate);
	SpellBookPage2:SetDesaturated(desaturate);
end


-- *************************************************************************************
WHAT_HAS_CHANGED_TITLE = {}
WHAT_HAS_CHANGED_TITLE["HUNTER"]	= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_HUNTER_2,		WHC_TITLE_HUNTER_3,		WHC_TITLE_HUNTER_4	};
WHAT_HAS_CHANGED_TITLE["WARLOCK"]	= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_WARLOCK_2,	WHC_TITLE_WARLOCK_3,	WHC_TITLE_WARLOCK_4	};
WHAT_HAS_CHANGED_TITLE["PRIEST"]	= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_PRIEST_2,		WHC_TITLE_PRIEST_3,		WHC_TITLE_PRIEST_4	};
WHAT_HAS_CHANGED_TITLE["PALADIN"]	= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_PALADIN_2,	WHC_TITLE_PALADIN_3		};
WHAT_HAS_CHANGED_TITLE["MAGE"]		= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_MAGE_2,		WHC_TITLE_MAGE_3,		WHC_TITLE_MAGE_4	};
WHAT_HAS_CHANGED_TITLE["ROGUE"]		= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_ROGUE_2,		WHC_TITLE_ROGUE_3,		};
WHAT_HAS_CHANGED_TITLE["DRUID"]		= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_DRUID_2,		WHC_TITLE_DRUID_3,		WHC_TITLE_DRUID_4	};
WHAT_HAS_CHANGED_TITLE["SHAMAN"]	= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_SHAMAN_2,		};
WHAT_HAS_CHANGED_TITLE["WARRIOR"]	= { WHC_TITLE_WARRIOR_1,	WHC_TITLE_WARRIOR_2,	WHC_TITLE_WARRIOR_3,	WHC_TITLE_WARRIOR_4	};
WHAT_HAS_CHANGED_TITLE["MONK"]		= { WHC_TITLE_MONK_1,		WHC_TITLE_MONK_2,		WHC_TITLE_MONK_3		};
WHAT_HAS_CHANGED_TITLE["DEATHKNIGHT"] = { WHC_TITLE_WARRIOR_1,	WHC_TITLE_DK_2,			WHC_TITLE_DK_3			};


WHAT_HAS_CHANGED_DISPLAY = {}
WHAT_HAS_CHANGED_DISPLAY["HUNTER"]	= { WHC_WARRIOR_1,	WHC_HUNTER_2,	WHC_HUNTER_3,	WHC_HUNTER_4	};
WHAT_HAS_CHANGED_DISPLAY["WARLOCK"]	= { WHC_WARRIOR_1,	WHC_WARLOCK_2,	WHC_WARLOCK_3,	WHC_WARLOCK_4	};
WHAT_HAS_CHANGED_DISPLAY["PRIEST"]	= { WHC_WARRIOR_1,	WHC_PRIEST_2,	WHC_PRIEST_3,	WHC_PRIEST_4	};
WHAT_HAS_CHANGED_DISPLAY["PALADIN"]	= { WHC_WARRIOR_1,	WHC_PALADIN_2,	WHC_PALADIN_3,	};
WHAT_HAS_CHANGED_DISPLAY["MAGE"]	= { WHC_WARRIOR_1,	WHC_MAGE_2,		WHC_MAGE_3,		WHC_MAGE_4 };
WHAT_HAS_CHANGED_DISPLAY["ROGUE"]	= { WHC_WARRIOR_1,	WHC_ROGUE_2,	WHC_ROGUE_3,	};
WHAT_HAS_CHANGED_DISPLAY["DRUID"]	= { WHC_WARRIOR_1,	WHC_DRUID_2,	WHC_DRUID_3,	WHC_DRUID_4		};
WHAT_HAS_CHANGED_DISPLAY["SHAMAN"]	= { WHC_WARRIOR_1,	WHC_SHAMAN_2,	};
WHAT_HAS_CHANGED_DISPLAY["WARRIOR"]	= { WHC_WARRIOR_1,	WHC_WARRIOR_2,	WHC_WARRIOR_3,	WHC_WARRIOR_4 };
WHAT_HAS_CHANGED_DISPLAY["MONK"]	= { WHC_MONK_1,		WHC_MONK_2,		WHC_MONK_3		};
WHAT_HAS_CHANGED_DISPLAY["DEATHKNIGHT"] = { WHC_WARRIOR_1,	WHC_DK_2,	WHC_DK_3		};

function SpellBook_GetWhatChangedItem(index)
	local frame = SpellBookWhatHasChanged.ChangedItems[index];
	if ( not frame ) then
		SpellBookWhatHasChanged.ChangedItems[index] = CreateFrame("SimpleHTML", nil, SpellBookWhatHasChanged, "WhatHasChangedEntryTemplate");
		frame = SpellBookWhatHasChanged.ChangedItems[index];
		frame:SetPoint("TOP", SpellBookWhatHasChanged.ChangedItems[index-1], "BOTTOM", 0, -80);
	end
	return frame;
end

function SpellBook_UpdateWhatHasChangedTab()
	local displayName, class = UnitClass("player");
	local changedList = WHAT_HAS_CHANGED_DISPLAY[class];
	local changedTitle = WHAT_HAS_CHANGED_TITLE[class];

	SpellBookWhatHasChanged.ClassName:SetText(displayName);

	if ( changedList ) then
		for i=1, #changedList do
			local frame = SpellBook_GetWhatChangedItem(i);
			frame.Number:SetText(i);
			frame.Title:SetText(changedTitle[i]);
			frame:SetText(changedList[i], true);
		end
	end
	for i = #changedList + 1, #SpellBookWhatHasChanged.ChangedItems do
		SpellBook_GetWhatChangedItem(i):Hide();
	end
	SpellBookPage1:SetDesaturated(false);
	SpellBookPage2:SetDesaturated(false);
end


-- *************************************************************************************

SpellBookFrame_HelpPlate = {
	FramePos = { x = 5,	y = -22 },
	FrameSize = { width = 580, height = 500	},
	[1] = { ButtonPos = { x = 250,	y = -50},	HighLightBox = { x = 65, y = -25, width = 460, height = 462 },	ToolTipDir = "DOWN",	ToolTipText = SPELLBOOK_HELP_1 },
	[2] = { ButtonPos = { x = 520,	y = -30 },	HighLightBox = { x = 540, y = -5, width = 46, height = 100 },	ToolTipDir = "LEFT",	ToolTipText = SPELLBOOK_HELP_2 },
	[3] = { ButtonPos = { x = 520,	y = -150},	HighLightBox = { x = 540, y = -125, width = 46, height = 200 },	ToolTipDir = "LEFT",	ToolTipText = SPELLBOOK_HELP_3, MinLevel = 10 },
}

ProfessionsFrame_HelpPlate = {
	FramePos = { x = 5,	y = -22 },
	FrameSize = { width = 545, height = 500	},
	[1] = { ButtonPos = { x = 150,	y = -110 }, HighLightBox = { x = 60, y = -35, width = 460, height = 195 }, ToolTipDir = "UP",	ToolTipText = PROFESSIONS_HELP_1 },
	[2] = { ButtonPos = { x = 150,	y = -325}, HighLightBox = { x = 60, y = -235, width = 460, height = 240 }, ToolTipDir = "UP",	ToolTipText = PROFESSIONS_HELP_2 },
}

CoreAbilitiesFrame_HelpPlate = {
	FramePos = { x = 5,	y = -22 },
	FrameSize = { width = 580, height = 500	},
	[1] = { ButtonPos = { x = 430,	y = -30}, HighLightBox = { x = 65, y = -15, width = 460, height = 472 }, ToolTipDir = "RIGHT",	ToolTipText = CORE_ABILITIES_HELP_1 },
}

WhatHasChangedFrame_HelpPlate = {
	FramePos = { x = 5,	y = -22 },
	FrameSize = { width = 580, height = 500	},
	[1] = { ButtonPos = { x = 430,	y = -30}, HighLightBox = { x = 65, y = -15, width = 460, height = 472 }, ToolTipDir = "DOWN",	ToolTipText = WHAT_HAS_CHANGED_HELP_1 },
}

function SpellBook_ToggleTutorial()
	local tutorial, helpPlate = SpellBookFrame_GetTutorialEnum();
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) and SpellBookFrame:IsShown()) then
		HelpPlate_Show( helpPlate, SpellBookFrame, SpellBookFrame.MainHelpButton, true );
		SetCVarBitfield( "closedInfoFrames", tutorial, true );
	else
		HelpPlate_Hide(true);
	end
end
