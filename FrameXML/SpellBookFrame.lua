MAX_SPELLS = 1024;
MAX_SKILLLINE_TABS = 8;
SPELLS_PER_PAGE = 12;
MAX_SPELL_PAGES = ceil(MAX_SPELLS / SPELLS_PER_PAGE);

BOOKTYPE_SPELL = "spell";
BOOKTYPE_PROFESSION = "professions";
BOOKTYPE_PET = "pet";
BOOKTYPE_CORE_ABILITIES = "core";

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
											title = "Core Abilities",
											updateFunc =  function() SpellBook_UpdateCoreAbilitiesTab(); end
										};										
SPELLBOOK_PAGENUMBERS = {};

SpellBookFrames = {	"SpellBookSpellIconsFrame", "SpellBookProfessionFrame",  "SpellBookSideTabsFrame", "SpellBookPageNavigationFrame", "SpellBookCoreAbilitiesFrame"};

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
	HelpPlate_Hide();
	if ( not HasPetSpells() and bookType == BOOKTYPE_PET ) then
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
	if ( tutorial and not GetCVarBitfield( "closedInfoFrames", tutorial ) ) then
		if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
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
	end
	return tutorial, helpPlate;
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
	SetPortraitToTexture(SpellBookFramePortrait, "Interface\\Spellbook\\Spellbook-Icon");
	
	ButtonFrameTemplate_HideButtonBar(SpellBookFrame);
	ButtonFrameTemplate_HideAttic(SpellBookFrame);
	SpellBookFrameInsetBg:Hide();
end

function SpellBookFrame_OnEvent(self, event, ...)
	if ( event == "SPELLS_CHANGED" ) then
		if ( SpellBookFrame:IsVisible() ) then
			if ( GetNumSpellTabs() < SpellBookFrame.selectedSkillLine ) then
				SpellBookFrame.selectedSkillLine = 1;
			end
			SpellBookFrame_Update();
		end
	elseif ( event == "LEARNED_SPELL_IN_TAB" ) then
		local spellID, tabNum = ...;
		local flashFrame = _G["SpellBookSkillLineTab"..tabNum.."Flash"];
		if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
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
		-- default to first tab if the selected one is gone - happens if you leave a guild with perks 
		if ( GetNumSpellTabs() < SpellBookFrame.selectedSkillLine ) then
			SpellBookFrame.selectedSkillLine = 1;
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
	SpellBookFrameTabButton2.binding = "TOGGLEPROFESSIONBOOK";
	
	local tabIndex = 3;
	-- check to see if we have a pet
	local hasPetSpells, petToken = HasPetSpells();
	SpellBookFrame.petTitle = nil;
	if ( hasPetSpells ) then
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
	
	-- core abilities is always shown
	local nextTab = _G["SpellBookFrameTabButton"..tabIndex];
	nextTab:Show();
	nextTab.bookType = BOOKTYPE_CORE_ABILITIES;
	nextTab.binding = "TOGGLECOREABILITIESBOOK";
	nextTab:SetText(SpellBookInfo[BOOKTYPE_CORE_ABILITIES].title);
	
	
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

	SpellBookPage1:SetDesaturated(_G["SpellBookSkillLineTab"..SpellBookFrame.selectedSkillLine].isOffSpec);
	SpellBookPage2:SetDesaturated(_G["SpellBookSkillLineTab"..SpellBookFrame.selectedSkillLine].isOffSpec);
end

function SpellBookFrame_UpdateSpells ()
	for i = 1, SPELLS_PER_PAGE do
		_G["SpellButton" .. i]:Show();
		SpellButton_UpdateButton(_G["SpellButton" .. i]);
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
		if ( not self.isOffSpec ) then
			ToggleSpellAutocast(slot, SpellBookFrame.bookType);
		end
	else
		local _, id = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
		if (slotType == "FLYOUT") then
			SpellFlyout:Toggle(id, self, "RIGHT", 1, false, self.isOffSpec);
			SpellFlyout:SetBorderColor(181/256, 162/256, 90/256);
		else
			if ( not self.isOffSpec ) then
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
		if ( MacroFrame and MacroFrame:IsShown() ) then
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
		CooldownFrame_SetTimer(cooldown, start, duration, enable);
	end
end

function SpellButton_UpdateButton(self)
	if SpellBookFrame.bookType == BOOKTYPE_PROFESSION then
		UpdateProfessionButton(self);
		return;
	end

	if ( not SpellBookFrame.selectedSkillLine ) then
		SpellBookFrame.selectedSkillLine = 1;
	end
	local temp, texture, offset, numSlots, isGuild, isOffSpec = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
	SpellBookFrame.selectedSkillLineNumSlots = numSlots;
	SpellBookFrame.selectedSkillLineOffset = offset;
	self.isOffSpec = isOffSpec;
	
	if (not self.SpellName.shadowX) then
		self.SpellName.shadowX, self.SpellName.shadowY = self.SpellName:GetShadowOffset();
	end

	local slot, slotType = SpellBook_GetSpellBookSlot(self);
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
	
	local specName, className = IsSpellClassOrSpec(slot, SpellBookFrame.bookType);
	if ( subSpellName == "" ) then
		if ( specName ) then
			subSpellName = specName;
--		elseif ( className ) then
--			subSpellName = className;
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
			local slotType = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
			return slot, slotType;
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
shineGet = {}
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
			local name, texture, _, _, isGuild, isOffSpec = GetSpellTabInfo(i);
			skillLineTab:SetNormalTexture(texture);
			skillLineTab.tooltip = name;
			skillLineTab:Show();
			skillLineTab.isOffSpec = isOffSpec;
			skillLineTab:GetNormalTexture():SetDesaturated(isOffSpec);

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

WARRIOR_ARMS_CORE_ABILITY_1="Use to close the distance to your target."
WARRIOR_ARMS_CORE_ABILITY_2="Use when available so your target takes more damage."
WARRIOR_ARMS_CORE_ABILITY_3="Use when available. Primary Rage generator."
WARRIOR_ARMS_CORE_ABILITY_4="Use when available."
WARRIOR_ARMS_CORE_ABILITY_5="Use whenever you have 60 Rage."
WARRIOR_ARMS_CORE_ABILITY_6="Use when your target is below 20% health."

-- Hardcoded spell id's for spec display
SPEC_CORE_ABILITY_DISPLAY = {}
SPEC_CORE_ABILITY_DISPLAY[71] = { 100,WARRIOR_ARMS_CORE_ABILITY_1, 86346,WARRIOR_ARMS_CORE_ABILITY_2, 12294,WARRIOR_ARMS_CORE_ABILITY_3, 7384,WARRIOR_ARMS_CORE_ABILITY_4, 1464,WARRIOR_ARMS_CORE_ABILITY_5, 5308,WARRIOR_ARMS_CORE_ABILITY_6 }; --Arms
SPEC_CORE_ABILITY_DISPLAY[72] = { 23881,10, 23588,10, 100130,10, 85288,10 }; --Fury
SPEC_CORE_ABILITY_DISPLAY[73] = { 23922,10, 20243,10, 6572,10, 2565,10 }; --Protection
function SpellBook_UpdateCoreAbilitiesTab()
	SpellBookFrame_UpdatePages();
	
--	local id, name, description, icon, background = GetSpecializationInfo(shownSpec, nil, self.isPet);
	
	local abilityList = SPEC_CORE_ABILITY_DISPLAY[71];
	local index = 1;
	for i=1,#abilityList,2 do
		local name, subname = GetSpellInfo(abilityList[i]);
		local _, icon = GetSpellTexture(abilityList[i]);
		SpellBookCoreAbilitiesFrame.Abilities[index].Name:SetText(name);
		SpellBookCoreAbilitiesFrame.Abilities[index].iconTexture:SetTexture(icon);
		SpellBookCoreAbilitiesFrame.Abilities[index].InfoText:SetText(abilityList[i+1]);
		SpellBookCoreAbilitiesFrame.Abilities[index]:Show();
		index = index + 1;
	end
	for i=index,#SpellBookCoreAbilitiesFrame.Abilities,1 do
		SpellBookCoreAbilitiesFrame.Abilities[index]:Hide();
	end
end

SpellBookFrame_HelpPlate = {
	FramePos = { x = 5,	y = -22 },
	FrameSize = { width = 580, height = 500	},
	[1] = { ButtonPos = { x = 250,	y = -50}, HighLightBox = { x = 65, y = -25, width = 460, height = 462 }, ToolTipDir = "DOWN",	ToolTipText = "Drag spells to your action bar from here.  Your active spells are sorted before passive spells." },
	[2] = { ButtonPos = { x = 515,	y = -30 }, HighLightBox = { x = 530, y = 0, width = 64, height = 110 }, ToolTipDir = "LEFT",		ToolTipText = "These tabs display your current spells." },
	[3] = { ButtonPos = { x = 515,	y = -150}, HighLightBox = { x = 530, y = -120, width = 64, height = 205 }, ToolTipDir = "LEFT",	MinLevel = 10, ToolTipText = "These tabs display all the spells you would get if you choose a different specialization.\n\nSome spells will be available in multiple specializations." },
}

ProfessionsFrame_HelpPlate = {
	FramePos = { x = 5,	y = -22 },
	FrameSize = { width = 545, height = 500	},
	[1] = { ButtonPos = { x = 150,	y = -110 }, HighLightBox = { x = 60, y = -35, width = 460, height = 200 }, ToolTipDir = "UP",		ToolTipText = "You can find trainers for professions in a major city.\n\nA gathering profession is recommended for new players" },
	[2] = { ButtonPos = { x = 150,	y = -325}, HighLightBox = { x = 60, y = -235, width = 460, height = 240 }, ToolTipDir = "UP",	ToolTipText = "You can find trainers for professions in a major city.\n\nFirst Aid is recommended for new players." },
}

CoreAbilitiesFrame_HelpPlate = {
	FramePos = { x = 5,	y = -22 },
	FrameSize = { width = 580, height = 500	},
	[1] = { ButtonPos = { x = 450,	y = -50}, HighLightBox = { x = 65, y = -35, width = 460, height = 452 }, ToolTipDir = "RIGHT",	ToolTipText = "This page gives you information on your most important abilities.\n\nYou should definitely have these abilities on your action bar." },
}

function SpellBook_ToggleTutorial()
	local tutorial, helpPlate = SpellBookFrame_GetTutorialEnum();
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
		HelpPlate_Show( helpPlate, SpellBookFrame, SpellBookFrame.MainHelpButton );
		SetCVarBitfield( "closedInfoFrames", tutorial, true );
	else
		HelpPlate_Hide();
	end
end
