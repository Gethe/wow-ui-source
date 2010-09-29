MAX_SPELLS = 1024;
MAX_SKILLLINE_TABS = 8;
SPELLS_PER_PAGE = 12;
NUM_COMPANIONS_PER_PAGE = 12;
MAX_SPELL_PAGES = ceil(MAX_SPELLS / SPELLS_PER_PAGE);

BOOKTYPE_SPELL = "spell";
BOOKTYPE_PROFESSION = "professions";
BOOKTYPE_PET = "pet";
BOOKTYPE_MOUNT = "mount";
BOOKTYPE_COMPANION = "companions";

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
SpellBookInfo[BOOKTYPE_MOUNT] 		= { showFrames = {"SpellBookCompanionsFrame", "SpellBookPageNavigationFrame"},
											title = MOUNTS,
											updateFunc = function()
																	SpellBook_UpdateCompanionsFrame("MOUNT");
																	SpellBookCompanionsFrame_UpdateCompanionPreview();
																end,
										};
SpellBookInfo[BOOKTYPE_COMPANION] 	= { showFrames = {"SpellBookCompanionsFrame", "SpellBookPageNavigationFrame"},
											title = COMPANIONS,
											updateFunc = function()
																	SpellBook_UpdateCompanionsFrame("CRITTER");
																	SpellBookCompanionsFrame_UpdateCompanionPreview();
																end,
										};
										
SPELLBOOK_PAGENUMBERS = {};

SpellBookFrames = {	"SpellBookSpellIconsFrame", "SpellBookProfessionFrame", "SpellBookCompanionsFrame", "SpellBookSideTabsFrame", "SpellBookPageNavigationFrame"};

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
	SPELLBOOK_PAGENUMBERS[BOOKTYPE_MOUNT] = 1;
	SPELLBOOK_PAGENUMBERS[BOOKTYPE_COMPANION] = 1;
	
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
			SpellBookFrame_Update();
		end
	elseif ( event == "LEARNED_SPELL_IN_TAB" ) then
		local spellID, tabNum = ...;
		local flashFrame = _G["SpellBookSkillLineTab"..tabNum.."Flash"];
		if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
			return;
		else
			if ( flashFrame ) then
				flashFrame:Show();
				SpellBookFrame.flashTabs = 1;
			end
		end
	elseif (event == "SKILL_LINES_CHANGED") then
		SpellBook_UpdateProfTab();
	elseif (event == "PLAYER_GUILD_UPDATE") then
		SpellBookFrame_UpdateSkillLineTabs();
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
	
	-- add mounts	
	 if ( GetNumCompanions("MOUNT") > 0  ) then
		local nextTab = _G["SpellBookFrameTabButton"..tabIndex];
		nextTab:Show();
		nextTab.bookType = BOOKTYPE_MOUNT;
		nextTab.binding = "TOGGLEMOUNTBOOK";
		nextTab:SetText(SpellBookInfo[BOOKTYPE_MOUNT].title);
		tabIndex = tabIndex+1;
	elseif (SpellBookFrame.bookType == BOOKTYPE_MOUNT) then
		SpellBookFrame.bookType = _G["SpellBookFrameTabButton"..tabIndex-1].bookType;
	end	

	-- add companions	
	 if ( GetNumCompanions("CRITTER") > 0  ) then
		local nextTab = _G["SpellBookFrameTabButton"..tabIndex];
		nextTab:Show();
		nextTab.bookType = BOOKTYPE_COMPANION;
		nextTab.binding = "TOGGLECOMPANIONBOOK";
		nextTab:SetText(SpellBookInfo[BOOKTYPE_COMPANION].title);
		tabIndex = tabIndex+1;
	elseif (SpellBookFrame.bookType == BOOKTYPE_COMPANION) then
		SpellBookFrame.bookType = _G["SpellBookFrameTabButton"..tabIndex-1].bookType;
	end
	
	-- Make sure the correct tab is selected
	for i=1,MaxSpellBookTypes do
		local tab = _G["SpellBookFrameTabButton"..i];
		PanelTemplates_TabResize(tab, 0);
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
	if ( event == "SPELLS_CHANGED" or event == "SPELL_UPDATE_COOLDOWN" or event == "UPDATE_SHAPESHIFT_FORM" ) then
		-- need to listen for UPDATE_SHAPESHIFT_FORM because attack icons change when the shapeshift form changes
		SpellButton_UpdateButton(self);
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
		ToggleSpellAutocast(slot, SpellBookFrame.bookType);
	else
		local _, id = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
		if (slotType == "FLYOUT") then
			SpellFlyout:Toggle(id, self, "RIGHT", 1);
			SpellFlyout:SetBorderColor(181/256, 162/256, 90/256);
		else
			CastSpell(slot, SpellBookFrame.bookType);
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

function SpellButton_UpdateButton(self)
	if SpellBookFrame.bookType == BOOKTYPE_PROFESSION then
		UpdateProfessionButton(self);
		return;
	end


	if ( not SpellBookFrame.selectedSkillLine ) then
		SpellBookFrame.selectedSkillLine = 1;
	end
	local temp, texture, offset, numSlots = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
	SpellBookFrame.selectedSkillLineNumSlots = numSlots;
	SpellBookFrame.selectedSkillLineOffset = offset;
	
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

	if ( (SpellBookFrame.bookType ~= BOOKTYPE_PET) and not slot) then
		self:Disable();
		iconTexture:Hide();
		spellString:Hide();
		subSpellString:Hide();
		cooldown:Hide();
		autoCastableTexture:Hide();
		SpellBook_ReleaseAutoCastShine(self.shine)
		self.shine = nil;
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
		return;
	else
		self:Enable();
	end

	local texture = GetSpellBookItemTexture(slot, SpellBookFrame.bookType);
	local highlightTexture = _G[name.."Highlight"];
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

	local start, duration, enable = GetSpellCooldown(slot, SpellBookFrame.bookType);
	CooldownFrame_SetTimer(cooldown, start, duration, enable);

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
	if ( isPassive ) then
		highlightTexture:SetTexture("Interface\\Buttons\\UI-PassiveHighlight");
		spellString:SetTextColor(PASSIVE_SPELL_FONT_COLOR.r, PASSIVE_SPELL_FONT_COLOR.g, PASSIVE_SPELL_FONT_COLOR.b);
	else
		highlightTexture:SetTexture("Interface\\Buttons\\ButtonHilight-Square");
		spellString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	end
	iconTexture:SetTexture(texture);
	spellString:SetText(spellName);
	subSpellString:SetText(subSpellName);

	-- If there is no spell sub-name, move the bottom row of text up
	if ( subSpellName == "" ) then
		self.SpellSubName:SetHeight(6);
	else
		self.SpellSubName:SetHeight(18);
	end

	iconTexture:Show();
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
		
		-- For spells that are on cooldown.  This must be done here because otherwise "SetDesaturated(0)" above will override this on low-end video cards.
		if ( enable == 1 ) then
			iconTexture:SetVertexColor(1.0, 1.0, 1.0);
		else
			iconTexture:SetVertexColor(0.4, 0.4, 0.4);
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
	
	spellString:Show();
	subSpellString:Show();
	SpellButton_UpdateSelection(self);
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
	elseif ( SpellBookFrame.bookType == BOOKTYPE_MOUNT or SpellBookFrame.bookType == BOOKTYPE_COMPANION) then
		currentPage = SPELLBOOK_PAGENUMBERS[SpellBookFrame.bookType];
		maxPages = ceil(GetNumCompanions(SpellBookCompanionsFrame.mode)/NUM_COMPANIONS_PER_PAGE);
	elseif ( SpellBookFrame.bookType == BOOKTYPE_SPELL) then
		currentPage = SPELLBOOK_PAGENUMBERS[SpellBookFrame.selectedSkillLine];
		local name, texture, offset, numSlots = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
		maxPages = ceil(numSlots/SPELLS_PER_PAGE);
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

----------------------------------------------------------------------
--    Mounts/Companions
----------------------------------------------------------------------

function SpellBookCompanionsFrame_OnLoad(self)
	self:RegisterEvent("COMPANION_LEARNED");
	self:RegisterEvent("COMPANION_UNLEARNED");
	self:RegisterEvent("COMPANION_UPDATE");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
end

function SpellBookCompanionsFrame_OnEvent(self, event, ...)
	local arg1 = ...;
	if ( event == "COMPANION_LEARNED" ) then
		if ( not SpellBookFrame:IsVisible() ) then
			MicroButtonPulse(SpellbookMicroButton, 60);
		end
		-- FIXME
		--if ( not self:IsVisible() ) then
		--	SetButtonPulse(CharacterFrameTab2, 60, 1);
		--end
		if (SpellBookFrame:IsVisible() ) then
			SpellBookFrame_Update();
		end
	elseif ( event == "COMPANION_UNLEARNED" ) then
		local page;
		local numCompanions = GetNumCompanions(SpellBookCompanionsFrame.mode);
		if ( SpellBookCompanionsFrame.mode=="MOUNT" ) then
			page = SPELLBOOK_PAGENUMBERS[BOOKTYPE_MOUNT];
			if ( numCompanions > 0 ) then
				SpellBookCompanionsFrame.idMount = GetCompanionInfo("MOUNT", 1);
				SpellBookCompanionsFrame_UpdateCompanionPreview();
			else
				SpellBookCompanionsFrame.idMount = nil;
			end
		else
			page = SPELLBOOK_PAGENUMBERS[BOOKTYPE_COMPANION];
			if ( numCompanions > 0 ) then
				SpellBookCompanionsFrame.idCritter = GetCompanionInfo("CRITTER", 1);
				SpellBookCompanionsFrame_UpdateCompanionPreview();
			else
				SpellBookCompanionsFrame.idCritter = nil;
			end
		end
		if (SpellBookFrame:IsVisible()) then
			SpellBookFrame_Update();
		end
	elseif ( event == "COMPANION_UPDATE" ) then
		if ( not SpellBookCompanionsFrame.idMount ) then
			SpellBookCompanionsFrame.idMount = GetCompanionInfo("MOUNT", 1);
		end
		if ( not SpellBookCompanionsFrame.idCritter ) then
			SpellBookCompanionsFrame.idCritter = GetCompanionInfo("CRITTER", 1);
		end
		if (self:IsVisible()) then
			SpellBook_UpdateCompanionsFrame();
		end
	elseif ( event == "SPELL_UPDATE_COOLDOWN" ) then
		if ( self:IsVisible() ) then
			SpellBook_UpdateCompanionCooldowns();
		end
	elseif ( (event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE") and (arg1 == "player")) then
		SpellBook_UpdateCompanionsFrame();
	end
end

function SpellBookCompanionsFrame_FindCompanionIndex(creatureID, mode)
	if ( not mode ) then
		mode = SpellBookCompanionsFrame.mode;
	end
	if (not creatureID ) then
		creatureID = (SpellBookCompanionsFrame.mode=="MOUNT") and SpellBookCompanionsFrame.idMount or SpellBookCompanionsFrame.idCritter;
	end
	for i=1,GetNumCompanions(mode) do
		if ( GetCompanionInfo(mode, i) == creatureID ) then
			return i;
		end
	end
	return nil;
end

function SpellBookCompanionsFrame_UpdateCompanionPreview()
	local selected = SpellBookCompanionsFrame_FindCompanionIndex();
	
	if (selected) then
		local creatureID, creatureName = GetCompanionInfo(SpellBookCompanionsFrame.mode, selected);
		if (SpellBookCompanionModelFrame.creatureID ~= creatureID) then
			SpellBookCompanionModelFrame.creatureID = creatureID;
			SpellBookCompanionModelFrame:SetCreature(creatureID);
			SpellBookCompanionSelectedName:SetText(creatureName);
		end
	end
end

function SpellBook_UpdateCompanionsFrame(type)
	local button, iconTexture, id;
	local creatureID, creatureName, spellID, icon, active;
	local offset, selected;
	
	if (type) then
		SpellBookCompanionsFrame.mode = type;
	end
	
	if (not SpellBookCompanionsFrame.mode) then
		return;
	end
	
	SpellBookFrame_UpdatePages();
	
	local currentPage, maxPages = SpellBook_GetCurrentPage();
	if (currentPage) then
		currentPage = currentPage - 1;
	end
	
	offset = (currentPage or 0)*NUM_COMPANIONS_PER_PAGE;
	if ( SpellBookCompanionsFrame.mode == "CRITTER" ) then
		selected = SpellBookCompanionsFrame_FindCompanionIndex(SpellBookCompanionsFrame.idCritter);
	elseif ( SpellBookCompanionsFrame.mode == "MOUNT" ) then
		selected = SpellBookCompanionsFrame_FindCompanionIndex(SpellBookCompanionsFrame.idMount);
	end
	
	if (not selected) then
		selected = 1;
		creatureID = GetCompanionInfo(SpellBookCompanionsFrame.mode, selected);
		if ( SpellBookCompanionsFrame.mode == "CRITTER" ) then
			SpellBookCompanionsFrame.idCritter = creatureID;
		elseif ( SpellBookCompanionsFrame.mode == "MOUNT" ) then
			SpellBookCompanionsFrame.idMount = creatureID;
		end
	end

	for i = 1, NUM_COMPANIONS_PER_PAGE do
		button = _G["SpellBookCompanionButton"..i];
		id = i + (offset or 0);
		creatureID, creatureName, spellID, icon, active = GetCompanionInfo(SpellBookCompanionsFrame.mode, id);
		button.creatureID = creatureID;
		button.spellID = spellID;
		button.active = active;
		if ( creatureID ) then
			button.IconTexture:SetTexture(icon);
			button.IconTexture:Show();
			button.SpellName:SetText(creatureName);
			button.SpellName:Show();
			button:Enable();
		else
			button:Disable();
			button.IconTexture:Hide();
			button.SpellName:Hide();
		end
		if ( (id == selected) and creatureID ) then
			button:SetChecked(true);
		else
			button:SetChecked(false);
		end
		
		if ( active ) then
			button.ActiveTexture:Show();
		else
			button.ActiveTexture:Hide();
		end
		if (SpellBookCompanionsFrame.mode == "CRITTER") then
			button.Background:SetTexCoord(0.71093750, 0.79492188, 0.00390625, 0.17187500);
		else
			button.Background:SetTexCoord(0.62304688, 0.70703125, 0.00390625, 0.17187500);
		end
	end
	
	if ( selected ) then
		creatureID, creatureName, spellID, icon, active = GetCompanionInfo(SpellBookCompanionsFrame.mode, selected);
		if ( active and creatureID ) then
			SpellBookCompanionSummonButton:SetText(SpellBookCompanionsFrame.mode == "MOUNT" and BINDING_NAME_DISMOUNT or PET_DISMISS);
		else
			SpellBookCompanionSummonButton:SetText(SpellBookCompanionsFrame.mode == "MOUNT" and MOUNT or SUMMON);
		end
	end
	
	SpellBook_UpdateCompanionCooldowns();
end

function SpellBook_UpdateCompanionCooldowns()
	local currentPage, maxPages = SpellBook_GetCurrentPage();
	if (currentPage) then
		currentPage = currentPage - 1;
	end
	local offset = (currentPage or 0)*NUM_COMPANIONS_PER_PAGE;
	
	for i = 1, NUM_COMPANIONS_PER_PAGE do
		local button = _G["SpellBookCompanionButton"..i];
		local cooldown = _G[button:GetName().."Cooldown"];
		if ( button.creatureID ) then
			local start, duration, enable = GetCompanionCooldown(SpellBookCompanionsFrame.mode, offset + button:GetID());
			if ( start and duration and enable ) then
				CooldownFrame_SetTimer(cooldown, start, duration, enable);
			end
		else
			cooldown:Hide();
		end
	end
end

function SpellBookCompanionButton_OnLoad(self)
	self:RegisterForDrag("LeftButton");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
end

function SpellBookCompanionButton_OnEnter(self)
	if ( GetCVar("UberTooltips") == "1" ) then
		GameTooltip_SetDefaultAnchor(GameTooltip, self);
	else
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	end

	if ( GameTooltip:SetSpellByID(self.spellID) ) then
		self.UpdateTooltip = CompanionButton_OnEnter;
	else
		self.UpdateTooltip = nil;
	end
	
	GameTooltip:Show()
end

function SpellBookCompanionButton_OnClick(self, button)
	local selectedID;
	if ( SpellBookCompanionsFrame.mode == "CRITTER" ) then
		selectedID = SpellBookCompanionsFrame.idCritter;
	elseif ( SpellBookCompanionsFrame.mode == "MOUNT" ) then
		selectedID = SpellBookCompanionsFrame.idMount;
	end

	if ( button ~= "LeftButton" or ( selectedID == self.creatureID) ) then
		local currentPage, maxPages = SpellBook_GetCurrentPage();
		if (currentPage) then
			currentPage = currentPage - 1;
		end
		
		offset = (currentPage or 0)*NUM_COMPANIONS_PER_PAGE;
		local index = self:GetID() + offset;
		if ( self.active ) then
			DismissCompanion(SpellBookCompanionsFrame.mode);
		else
			CallCompanion(SpellBookCompanionsFrame.mode, index);
		end
	else
		if ( SpellBookCompanionsFrame.mode == "CRITTER" ) then
			SpellBookCompanionsFrame.idCritter = self.creatureID;
			SpellBookCompanionsFrame_UpdateCompanionPreview();
		elseif ( SpellBookCompanionsFrame.mode == "MOUNT" ) then
			SpellBookCompanionsFrame.idMount = self.creatureID;
			SpellBookCompanionsFrame_UpdateCompanionPreview();
		end
	end
	
	SpellBook_UpdateCompanionsFrame();
end

function SpellBookCompanionButton_OnModifiedClick(self)
	local id = self.spellID;
	if ( IsModifiedClick("CHATLINK") ) then
		if ( MacroFrame and MacroFrame:IsShown() ) then
			local spellName = GetSpellInfo(id);
			ChatEdit_InsertLink(spellName);
		else
			local spellLink = GetSpellLink(id)
			ChatEdit_InsertLink(spellLink);
		end
	elseif ( IsModifiedClick("PICKUPACTION") ) then
		SpellBookCompanionButton_OnDrag(self);
	end
end

function SpellBookCompanionButton_OnDrag(self)
	local currentPage, maxPages = SpellBook_GetCurrentPage();
	if (currentPage) then
		currentPage = currentPage - 1;
	end
	
	local offset = (currentPage or 0)*NUM_COMPANIONS_PER_PAGE;
	local dragged = self:GetID() + offset;
	PickupCompanion( SpellBookCompanionsFrame.mode, dragged );
end

function SpellBookCompanionSummonButton_OnClick()
	local selected = SpellBookCompanionsFrame_FindCompanionIndex();
	local creatureID, creatureName, spellID, icon, active = GetCompanionInfo(SpellBookCompanionsFrame.mode, selected);
	if ( active ) then
		DismissCompanion(SpellBookCompanionsFrame.mode);
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		CallCompanion(SpellBookCompanionsFrame.mode, selected);
		PlaySound("igMainMenuOptionCheckBoxOff");
	end
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
			local name, texture, _, _, isGuild = GetSpellTabInfo(i);
			skillLineTab:SetNormalTexture(texture);
			skillLineTab.tooltip = name;
			skillLineTab:Show();
			
			-- Guild tab gets additional space
			if (prevTab) then
				if (isGuild) then
					skillLineTab:SetPoint("TOPLEFT", prevTab, "BOTTOMLEFT", 0, -46);
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
	
	self.spellString:SetText(spellName);
	self.subSpellString:SetText(subSpellName);	
	self.iconTexture:SetTexture(texture);
	
	SpellButton_UpdateSelection(self);
end

function FormatProfession(frame, index)
	if index then
		frame.missingHeader:Hide();
		frame.missingText:Hide();
		
		local name, texture, rank, maxRank, numSpells, spelloffset, skillLine = GetProfessionInfo(index);
		frame.skillName = name;
		frame.spellOffset = spelloffset;
		frame.skillLine = skillLine;
		
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
		
		if frame.icon and texture then
			SetPortraitToTexture(frame.icon, texture);	
			frame.unlearn:Show();
		end
		
		frame.professionName:SetText(name);
		frame.statusBar.rankText:SetText(rank.."/"..maxRank);
		
					
		
		
		
		if numSpells == 1 then		
			frame.button2:Hide();
			frame.button1:Show();
			UpdateProfessionButton(frame.button1);		
		elseif numSpells == 2 then	
			frame.button1:Show();
			frame.button2:Show();
			UpdateProfessionButton(frame.button1);			
			UpdateProfessionButton(frame.button2);	
		else
			frame.button1:Hide();
			frame.button2:Hide();		
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
