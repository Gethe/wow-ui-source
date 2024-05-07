MAX_SPELLS = 1024;
MAX_SKILLLINE_TABS = 8;
SPELLS_PER_PAGE = 12;
MAX_SPELL_PAGES = ceil(MAX_SPELLS / SPELLS_PER_PAGE);

BOOKTYPE_SPELL = "spell";
BOOKTYPE_PROFESSION = "professions";
BOOKTYPE_PET = "pet";

local MaxSpellBookTypes = 5;
local SpellBookInfo = {};
SpellBookInfo[BOOKTYPE_SPELL] 		= { 	showFrames = {"SpellBookSpellIconsFrame", "SpellBookSideTabsFrame", "SpellBookPageNavigationFrame"},
											title = SPELLBOOK,
											updateFunc = function() SpellBook_UpdatePlayerTab(); end,
											mousewheelNavigation = true,
										};
SpellBookInfo[BOOKTYPE_PROFESSION] 	= { 	showFrames = {"SpellBookProfessionFrame"},
											title = TRADE_SKILLS,
											updateFunc = function() SpellBook_UpdateProfTab(); end,
											bgFileL="Interface\\Spellbook\\Professions-Book-Left",
											bgFileR="Interface\\Spellbook\\Professions-Book-Right",
											mousewheelNavigation = false,
										};
SpellBookInfo[BOOKTYPE_PET] 		= { 	showFrames = {"SpellBookSpellIconsFrame", "SpellBookPageNavigationFrame"},
											title = PET,
											updateFunc =  function() SpellBook_UpdatePetTab(); end,
											mousewheelNavigation = true,
										};

SPELLBOOK_PAGENUMBERS = {};

SpellBookFrames = {	"SpellBookSpellIconsFrame", "SpellBookProfessionFrame",  "SpellBookSideTabsFrame", "SpellBookPageNavigationFrame" };

PROFESSION_RANKS =  {};
PROFESSION_RANKS[1] = {75,  APPRENTICE};
PROFESSION_RANKS[2] = {150, JOURNEYMAN};
PROFESSION_RANKS[3] = {225, EXPERT};
PROFESSION_RANKS[4] = {300, ARTISAN};
PROFESSION_RANKS[5] = {375, MASTER};
PROFESSION_RANKS[6] = {450, GRAND_MASTER};
PROFESSION_RANKS[7] = {525, ILLUSTRIOUS};
PROFESSION_RANKS[8] = {600, ZEN_MASTER};
PROFESSION_RANKS[9] = {700, DRAENOR_MASTER};
PROFESSION_RANKS[10] = {800, LEGION_MASTER};
PROFESSION_RANKS[11] = {950, BATTLE_FOR_AZEROTH_MASTER};


OPEN_REASON_PENDING_GLYPH = "pendingglyph";
OPEN_REASON_ACTIVATED_GLYPH = "activatedglyph";

local SKILL_LINE_CLASS = 2;
local SKILL_LINE_SPEC = 3;

local ceil = ceil;
local strlen = strlen;
local tinsert = tinsert;
local tremove = tremove;

function ToggleSpellBook(bookType)
	if not C_GameModeManager.IsFeatureEnabled(Enum.GameModeFeatureSetting.SpellbookPanel) then
		return;
	end

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

	EventRegistry:TriggerEvent("SpellBookFrame.ChangeBookType");
end

function SpellBookFrame_UpdateHelpPlate()
	if ( IsPlayerInitialSpec() ) then
		SpellBookFrame_HelpPlate[2].HighLightBox.height = 100;
		SpellBookFrame_HelpPlate[3].HighLightBox.height = GetNumSpecializations() * 50;
		SpellBookFrame_HelpPlate[3].HighLightBox.y = -125;
	else
		SpellBookFrame_HelpPlate[2].HighLightBox.height = 150;
		SpellBookFrame_HelpPlate[3].HighLightBox.height = (GetNumSpecializations() - 1) * 50;
		SpellBookFrame_HelpPlate[3].HighLightBox.y = -175;
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
	end
	return tutorial, helpPlate;
end

function SpellBookFrame_OnLoad(self)
	self:RegisterEvent("LEARNED_SPELL_IN_TAB");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
	self:RegisterEvent("USE_GLYPH");
	self:RegisterEvent("CANCEL_GLYPH_CAST");
	self:RegisterEvent("ACTIVATE_GLYPH");
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");

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
	SpellBookFrame.selectedSkillLine = SKILL_LINE_CLASS;

	-- Initialize tab flashing
	SpellBookFrame.flashTabs = nil;

	-- Initialize portrait texture
	self:SetPortraitToAsset("Interface\\Spellbook\\Spellbook-Icon");

	ButtonFrameTemplate_HideButtonBar(SpellBookFrame);
	ButtonFrameTemplate_HideAttic(SpellBookFrame);

	EventRegistry:RegisterCallback("ClickBindingFrame.UpdateFrames", SpellBookFrame_UpdateSpells, self);
end

function SpellBookFrame_OnEvent(self, event, ...)
	if ( event == "SPELLS_CHANGED" ) then
		SpellBookFrame_Update();
	elseif ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
		if (self.castingGlyphSlot and not IsCastingGlyph()) then
			SpellBookFrame.castingGlyphSlot = nil;
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
	elseif (event == "SKILL_LINES_CHANGED" or event == "TRIAL_STATUS_UPDATE") then
		SpellBook_UpdateProfTab();
	elseif (event == "PLAYER_GUILD_UPDATE") then
		-- default to class tab if the selected one is gone - happens if you leave a guild with perks
		if ( GetNumSpellTabs() < SpellBookFrame.selectedSkillLine ) then
			SpellBookFrame_Update();
		else
			SpellBookFrame_UpdateSkillLineTabs();
		end
	elseif ( event == "PLAYER_SPECIALIZATION_CHANGED" ) then
		SpellBookFrame_Update();
	elseif ( event == "USE_GLYPH" ) then
		local spellID = ...;
		SpellBookFrame_OpenToPageForGlyph(spellID, OPEN_REASON_PENDING_GLYPH);
	elseif ( event == "CANCEL_GLYPH_CAST" ) then
		SpellBookFrame_ClearAbilityHighlights();
		SpellFlyout:Hide();
	elseif ( event == "ACTIVATE_GLYPH" ) then
		local spellID = ...;
		SpellBookFrame_OpenToPageForGlyph(spellID, OPEN_REASON_ACTIVATED_GLYPH);
	end
end

function SpellBookFrame_OnShow(self)
	SpellBookFrame_Update();
	EventRegistry:TriggerEvent("SpellBookFrame.Show");

	-- If there are tabs waiting to flash, then flash them... yeah..
	if ( self.flashTabs ) then
		UIFrameFlash(SpellBookTabFlashFrame, 0.5, 0.5, 30, nil);
	end

	-- Show multibar slots
	MultiActionBar_ShowAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_SPELLCOLLECTION);
	UpdateMicroButtons();

	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterUnitEvent("PLAYER_GUILD_UPDATE", "player");
	self:RegisterUnitEvent("PLAYER_SPECIALIZATION_CHANGED", "player");

	if InClickBindingMode() then
		ClickBindingFrame:SetFocusedFrame(self);
	end

	SpellBookFrame_PlayOpenSound();
	MicroButtonPulseStop(SpellbookMicroButton);
	MainMenuMicroButton_HideAlert(SpellbookMicroButton);
	if ( SpellbookMicroButton.suggestedTabButton ) then
		SpellBookFrame.showProfessionSpellHighlights = true;
		if SpellbookMicroButton.suggestedTabButton.bookType ~= SpellBookFrame.bookType then
			SpellBookFrameTabButton_OnClick(SpellbookMicroButton.suggestedTabButton);
		end
		SpellbookMicroButton.suggestedTabButton = nil;
	else
		SpellBookFrame.showProfessionSpellHighlights = false;
	end
end

function SpellBookFrame_Update()
	-- Reset if selected skillline button is gone
	if ( GetNumSpellTabs() < SpellBookFrame.selectedSkillLine ) then
		SpellBookFrame.selectedSkillLine = SKILL_LINE_CLASS;
	end

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

	SpellBookFrame:SetTitle(SpellBookInfo[SpellBookFrame.bookType].title);

	local tabUpdate = SpellBookInfo[SpellBookFrame.bookType].updateFunc;
	if(tabUpdate) then
		tabUpdate()
	end

	-- if boosted, find the first locked spell and display a tip next to it
	HelpTip:Hide(SpellBookFrame, BOOSTED_CHAR_LOCKED_SPELL_TIP);
	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL and IsCharacterNewlyBoosted() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_BOOSTED_SPELL_BOOK) ) then
		local spellSlot;
		for i = 1, SPELLS_PER_PAGE do
			local spellBtn = _G["SpellButton" .. i];
			local slotType = select(2,SpellBook_GetSpellBookSlot(spellBtn));
			if (slotType == "FUTURESPELL") then
				if ( not spellSlot or spellBtn:GetID() < spellSlot:GetID() ) then
					spellSlot = spellBtn;
				end
			end
		end

		if ( spellSlot ) then
			local helpTipInfo = {
				text = BOOSTED_CHAR_LOCKED_SPELL_TIP,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_BOOSTED_SPELL_BOOK,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				offsetX = -6,
			};
			HelpTip:Show(SpellBookFrame, helpTipInfo, spellSlot);
		end
	end
end

function SpellBookFrame_UpdateSpells ()
	for i = 1, SPELLS_PER_PAGE do
		local currSpellButton = _G["SpellButton" .. i];
		currSpellButton:Show();
		currSpellButton:UpdateButton();
	end

	if ( SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		SpellBookPage1:SetDesaturated(_G["SpellBookSkillLineTab"..SpellBookFrame.selectedSkillLine].isOffSpec);
		SpellBookPage2:SetDesaturated(_G["SpellBookSkillLineTab"..SpellBookFrame.selectedSkillLine].isOffSpec);
	else
		SpellBookPage1:SetDesaturated(false);
		SpellBookPage2:SetDesaturated(false);
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

-- ------------------------------------------------------------------------------------------------------------
-- returns the spell button, if it can find it, for the spellID passed in
local buttonOrder = {1,3,5,7,9,11,2,4,6,8,10,12};
function SpellBookFrame_OpenToSpell(spellID, toggleFlyout, reason)
	SpellBookFrame.bookType = BOOKTYPE_SPELL;
	ShowUIPanel(SpellBookFrame);
	local numTabs = GetNumSpellTabs();

	local slot = FindFlyoutSlotBySpellID(spellID);
	if (slot <= 0) then
		slot = FindSpellBookSlotBySpellID(spellID);
	end
	if slot then
		for tabIndex = 1, numTabs do
			local _, _, offset, numSlots = GetSpellTabInfo(tabIndex);

			if slot <= offset + numSlots then
				-- get to the correct tab and page
				local spellIndex = slot - offset;
				local page = 1;
				if spellIndex > SPELLS_PER_PAGE then
					page = math.ceil(spellIndex / SPELLS_PER_PAGE);
					spellIndex = spellIndex - ((page - 1) * SPELLS_PER_PAGE);
				end
				SPELLBOOK_PAGENUMBERS[tabIndex] = page;
				SpellBookFrame.selectedSkillLine = tabIndex;
				SpellBookFrame_Update();

				--now we need to find the spell button, which COULD be a flyout button
				local slotType, actionID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
				if ( slotType == "FLYOUT" ) then
					-- find the ACTUAL flyout button
					local buttonIndex = buttonOrder[spellIndex];
					local flyoutButton = _G["SpellButton" .. buttonIndex];

					--find the spellbutton INSIDE the flyout
					local numButtons = 1;
					local _, _, numSlots = GetFlyoutInfo(actionID);
					for i = 1, numSlots do
						local flyoutSpellID, overrideSpellID, isKnown, spellName, slotSpecID = GetFlyoutSlotInfo(actionID, i);
						if spellID == flyoutSpellID then -- we found it
							--open the flyout
							if toggleFlyout then
								SpellFlyout:Toggle(actionID, flyoutButton, "RIGHT", 1, false, flyoutButton.offSpecID, true, reason);
							end
							local returnButton = _G["SpellFlyoutButton"..i];
							return returnButton, flyoutButton;
						end
						local button = _G["SpellFlyoutButton"..i];
						if (button and button:IsShown()) then
							numButtons = numButtons + 1;
						end
					end
				else
					-- this is just a regular spell button
					local buttonIndex = buttonOrder[spellIndex];
					local returnButton = _G["SpellButton" .. buttonIndex];
					return returnButton;
				end
			end
		end
	end
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


local SpellBookStaticPopups =
{
	"UNLEARN_SKILL",
};
local function SpellBookFrame_HideStaticPopups()
	for _, popup in ipairs(SpellBookStaticPopups) do
		StaticPopup_Hide(popup);
	end
end

function SpellBookFrame_OnHide(self)
	SpellBookFrame_HideStaticPopups();
	HelpPlate_Hide();
	SpellBookFrame_PlayCloseSound();
	EventRegistry:TriggerEvent("SpellBookFrame.Hide");

	-- Stop the flash frame from flashing if its still flashing.. flash flash flash
	UIFrameFlashStop(SpellBookTabFlashFrame);
	-- Hide all the flashing textures
	for i=1, MAX_SKILLLINE_TABS do
		_G["SpellBookSkillLineTab"..i.."Flash"]:Hide();
	end

	-- Hide multibar slots
	MultiActionBar_HideAllGrids(ACTION_BUTTON_SHOW_GRID_REASON_SPELLCOLLECTION);

	-- Do this last, it can cause taint.
	UpdateMicroButtons();

	self:UnregisterEvent("SPELLS_CHANGED");	
	self:UnregisterEvent("PLAYER_GUILD_UPDATE");
	self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED");

	if InClickBindingMode() then
		ClickBindingFrame:ClearFocusedFrame();
	end
end

--Returns whether the spec has spells that aren't on the player's bar, if it does returns the spell id of the first undragged spell
function SpellBookFrame_SpecHasUnDraggedSpells()
	--Always only checks the new player's currently selected spec
	local tabIndex = 3;
	local _, _, offset, numSlots = GetSpellTabInfo(tabIndex);

	for i = 1, numSlots do
		local slot = i + offset;
		local slotType, spellID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);

		if not C_ActionBar.IsOnBarOrSpecialBar(spellID) and slotType ~="FUTURESPELL" and not IsPassiveSpell(slot, SpellBookFrame.bookType) then
			return true, spellID;
		end
	end

	return false;
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
	elseif ( event == "TRADE_SKILL_SHOW" or event == "TRADE_SKILL_CLOSE" or event == "ARCHAEOLOGY_CLOSED" ) then
		self:UpdateSelection();
	elseif ( event == "PET_BAR_UPDATE" ) then
		if ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
			self:UpdateButton();
		end
	elseif ( event == "CURSOR_CHANGED" ) then
		if ( self.spellGrabbed ) then
			self:UpdateButton();
			if ( self.dragStopped ) then
				self.spellGrabbed = false;
				self.dragStopped = false;
			end
		end
	elseif ( event == "ACTIONBAR_SLOT_CHANGED" ) then
		local slot, slotType, slotID = SpellBook_GetSpellBookSlot(self);
		if ( not slot ) then
			return;
		end

		local _, actionID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
		local onActionBar = false;

		if ( slotType == "SPELL" ) then
			if (FindFlyoutSlotBySpellID(actionID) > 0) then
				-- We're part of a flyout
				SpellBookFrame_UpdateSpells();
			else
				onActionBar = C_ActionBar.IsOnBarOrSpecialBar(actionID);
			end
		elseif ( slotType == "FLYOUT" ) then
			onActionBar = C_ActionBar.HasFlyoutActionButtons(actionID);
		elseif ( slotType == "PETACTION" ) then
			onActionBar = C_ActionBar.HasPetActionButtons(actionID) or C_ActionBar.HasPetActionPetBarIndices(actionID);
		end

		if ( self.SpellHighlightTexture and self.SpellHighlightTexture:IsShown() == onActionBar ) then
			self:UpdateButton();
		end
	end
end

function SpellButtonMixin:OnShow()
	self:RegisterEvent("SPELLS_CHANGED");
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN");
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
	self:RegisterEvent("TRADE_SKILL_SHOW");
	self:RegisterEvent("TRADE_SKILL_CLOSE");
	self:RegisterEvent("ARCHAEOLOGY_CLOSED");
	self:RegisterEvent("PET_BAR_UPDATE");
	self:RegisterEvent("CURSOR_CHANGED");
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED");
end

function SpellButtonMixin:OnHide()
	self:UnregisterEvent("SPELLS_CHANGED");
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN");
	self:UnregisterEvent("UPDATE_SHAPESHIFT_FORM");
	self:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED");
	self:UnregisterEvent("TRADE_SKILL_SHOW");
	self:UnregisterEvent("TRADE_SKILL_CLOSE");
	self:UnregisterEvent("ARCHAEOLOGY_CLOSED");
	self:UnregisterEvent("PET_BAR_UPDATE");
	self:UnregisterEvent("CURSOR_CHANGED");
	self:UnregisterEvent("ACTIONBAR_SLOT_CHANGED");
end

function SpellButtonMixin:OnEnter()
	local slot = SpellBook_GetSpellBookSlot(self);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if ( InClickBindingMode() and not self.canClickBind ) then
		GameTooltip:AddLine(CLICK_BINDING_NOT_AVAILABLE, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		GameTooltip:Show();
		return;
	end

	if ( GameTooltip:SetSpellBookItem(slot, SpellBookFrame.bookType) ) then
		self.UpdateTooltip = self.OnEnter;
	else
		self.UpdateTooltip = nil;
	end

	ClearOnBarHighlightMarks();
	PetActionBar:ClearPetActionHighlightMarks();
	local slotType, actionID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
	if ( slotType == "SPELL" ) then
		UpdateOnBarHighlightMarksBySpell(actionID);
	elseif ( slotType == "FLYOUT" ) then
		UpdateOnBarHighlightMarksByFlyout(actionID);
	elseif ( slotType == "PETACTION" ) then
		UpdateOnBarHighlightMarksByPetAction(actionID);
		PetActionBar:UpdatePetActionHighlightMarks(actionID);
		PetActionBar:Update();
	end

	if ( self.SpellHighlightTexture and self.SpellHighlightTexture:IsShown() ) then
		GameTooltip:AddLine(SPELLBOOK_SPELL_NOT_ON_ACTION_BAR, LIGHTBLUE_FONT_COLOR.r, LIGHTBLUE_FONT_COLOR.g, LIGHTBLUE_FONT_COLOR.b);
	end

	-- Update action bar highlights
	ActionBarController_UpdateAllSpellHighlights();
	GameTooltip:Show();
end

function SpellButtonMixin:OnLeave()
	ClearOnBarHighlightMarks();
	PetActionBar:ClearPetActionHighlightMarks();

	-- Update action bar highlights
	ActionBarController_UpdateAllSpellHighlights();
	PetActionBar:Update();
	GameTooltip:Hide();
end

function SpellButtonMixin:OnClick(button)
	if ( IsModifiedClick() ) then
		self:OnModifiedClick(button);
		return;
	end

	local slot, slotType = SpellBook_GetSpellBookSlot(self);
	if ( slot > MAX_SPELLS or slotType == "FUTURESPELL") then
		return;
	end

	if InClickBindingMode() then
		if ClickBindingFrame:HasNewSlot() and self.canClickBind then
			if SpellBookFrame.bookType == BOOKTYPE_SPELL then
				local _, spellID = GetSpellBookItemInfo(slot, BOOKTYPE_SPELL);
				ClickBindingFrame:AddNewAction(Enum.ClickBindingType.Spell, spellID);
			elseif SpellBookFrame.bookType == BOOKTYPE_PET then
				local _, actionID = GetSpellBookItemInfo(slot, BOOKTYPE_PET);
				local spellID = C_PetInfo.GetSpellForPetAction(actionID);
				if spellID then
					ClickBindingFrame:AddNewAction(Enum.ClickBindingType.PetAction, spellID);
				end
			end
		end
		return;
	end

	if ( HasPendingGlyphCast() and SpellBookFrame.bookType == BOOKTYPE_SPELL ) then
		local slotType, spellID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
		if (slotType == "SPELL") then
			if ( HasAttachedGlyph(spellID) ) then
				if ( IsPendingGlyphRemoval() ) then
					StaticPopup_Show("CONFIRM_GLYPH_REMOVAL", nil, nil, {name = GetCurrentGlyphNameForSpell(spellID), id = spellID});
				else
					StaticPopup_Show("CONFIRM_GLYPH_PLACEMENT", nil, nil, {name = GetPendingGlyphName(), currentName = GetCurrentGlyphNameForSpell(spellID), id = spellID});
				end
			else
				AttachGlyphToSpell(spellID);
			end
		elseif (slotType == "FLYOUT") then
			SpellFlyout:Toggle(spellID, self, "RIGHT", 1, false, self.offSpecID, true);
			SpellFlyout:SetBorderColor(181/256, 162/256, 90/256);
			SpellFlyout:SetBorderSize(42);
		end
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
			SpellFlyout:SetBorderSize(42);
		else
			if ( SpellBookFrame.bookType ~= BOOKTYPE_SPELLBOOK or self.offSpecID == 0 ) then
				CastSpell(slot, SpellBookFrame.bookType);
			end
		end
		self:UpdateSelection();
	end
end

function SpellButtonMixin:OnModifiedClick(button)
	EventRegistry:TriggerEvent("SpellMixinButton.OnModifiedClick", self, button);

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
				local spellLink = GetSpellLink(slot, SpellBookFrame.bookType);
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
		self:UpdateSelection();
		return;
	end
end

function SpellButtonMixin:UpdateDragSpell()
	local slot, slotType = SpellBook_GetSpellBookSlot(self);
	if (not slot or slot > MAX_SPELLS or not self.IconTexture:IsShown() or (slotType == "FUTURESPELL")) then
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
		local start, duration, enable, modRate = GetSpellCooldown(slot, SpellBookFrame.bookType);
		if (cooldown and start and duration) then
			if (enable) then
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
		SpellBookFrame.selectedSkillLine = SKILL_LINE_CLASS;
	end
	local _, _, offset, numSlots, _, offSpecID, shouldHide, specID = GetSpellTabInfo(SpellBookFrame.selectedSkillLine);
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
	local levelLinkLockTexture = _G[name.."LevelLinkLockTexture"];
	local levelLinkLockBg = _G[name.."LevelLinkLockBg"];
	local spellString = _G[name.."SpellName"];
	local subSpellString = _G[name.."SubSpellName"];
	local cooldown = _G[name.."Cooldown"];
	local autoCastableTexture = _G[name.."AutoCastable"];
	local slotFrame = _G[name.."SlotFrame"];

	-- Hide flyout if it's currently open
	if (SpellFlyout:IsShown() and SpellFlyout:GetParent() == self and not HasPendingGlyphCast() and not SpellFlyout.glyphActivating)  then
		SpellFlyout:Hide();
	end

	local highlightTexture = _G[name.."Highlight"];
	local texture;
	if ( slot ) then
		texture = GetSpellBookItemTexture(slot, SpellBookFrame.bookType);
	end

	-- If no spell, hide everything and return, or kiosk mode and future spell
	if ( not texture or (strlen(texture) == 0) or (slotType == "FUTURESPELL" and Kiosk.IsEnabled())) then
		iconTexture:Hide();
		levelLinkLockTexture:Hide();
		levelLinkLockBg:Hide();
		spellString:Hide();
		subSpellString:Hide();
		cooldown:Hide();
		autoCastableTexture:Hide();
		SpellBook_ReleaseAutoCastShine(self.shine);
		self.shine = nil;
		self.canClickBind = false;
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
		self.AbilityHighlightAnim:Stop();
		self.AbilityHighlight:Hide();
		self.GlyphIcon:Hide();
		self:Disable();
		self.TextBackground:SetDesaturated(isOffSpec);
		self.TextBackground2:SetDesaturated(isOffSpec);
		self.EmptySlot:SetDesaturated(isOffSpec);
		self.ClickBindingIconCover:Hide();
		self.ClickBindingHighlight:Hide();
		if self.SpellHighlightTexture then
			self.SpellHighlightTexture:Hide();
		end
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

	-- TODO:: Re-enable this behavior when we can distinguish between passives that show
	-- a cooldown like Cauterize and Cheat Death, and ones that don't.
	-- self.PassiveSpellOverlay:SetShown(self.isPassive);

	if (slotType == "FLYOUT") then
		SetClampedTextureRotation(self.FlyoutArrow, 90);
		self.FlyoutArrow:Show();
	else
		self.FlyoutArrow:Hide();
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

			-- If there is no spell sub-name, move the bottom row of text up
			if ( subSpellName ~= "" ) then
				self.SpellSubName:SetHeight(0);
				subSpellString:SetText(subSpellName);
			end
		end);
	end

	iconTexture:Show();
	spellString:Show();
	subSpellString:Show();

	local iconTextureAlpha;
	local iconTextureDesaturated;
	local isDisabled = spellID and C_SpellBook.IsSpellDisabled(spellID);
	if (not (slotType == "FUTURESPELL") and not isDisabled) then
		slotFrame:Show();
		self.UnlearnedFrame:Hide();
		self.TrainFrame:Hide();
		self.IconTextureBg:Hide();
		iconTextureAlpha = 1;
		iconTextureDesaturated = false;
		self.RequiredLevelString:Hide();
		self.SeeTrainerString:Hide();
		self.TrainTextBackground:Hide();
		self.TrainBook:Hide();
		self.SpellName:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		self.SpellName:SetShadowOffset(self.SpellName.shadowX, self.SpellName.shadowY);
		self.SpellName:SetPoint("LEFT", self, "RIGHT", 8, 4);
		self.SpellSubName:SetTextColor(0, 0, 0);
		local _, actionID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
		if ( slotType == "SPELL" and not isOffSpec ) then
			if (IsSpellValidForPendingGlyph(actionID)) then
				self.AbilityHighlight:Show();
				self.AbilityHighlightAnim:Play();
			else
				self.AbilityHighlightAnim:Stop();
				self.AbilityHighlight:Hide();
			end
			if (HasAttachedGlyph(actionID) or SpellBookFrame.castingGlyphSlot == slot) then
				self.GlyphIcon:Show();
			else
				self.GlyphIcon:Hide();
			end
		else
			self.AbilityHighlightAnim:Stop();
			self.AbilityHighlight:Hide();
			self.GlyphIcon:Hide();
		end

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

		if ( slotType == "SPELL" and isOffSpec ) then
			local level = GetSpellLevelLearned(slotID);
			if ( level and level > 0 and level > UnitLevel("player") ) then
				self.RequiredLevelString:Show();
				self.RequiredLevelString:SetFormattedText(SPELLBOOK_AVAILABLE_AT, level);
				self.RequiredLevelString:SetTextColor(0.25, 0.12, 0);
			end
		end
	else
		local level = GetSpellAvailableLevel(slot, SpellBookFrame.bookType);
		slotFrame:Hide();
		self.AbilityHighlightAnim:Stop();
		self.AbilityHighlight:Hide();
		if self.SpellHighlightTexture then
			self.SpellHighlightTexture:Hide();
		end
		self.GlyphIcon:Hide();
		self.IconTextureBg:Show();
		iconTextureAlpha = .5;
		iconTextureDesaturated = true;
		if (IsCharacterNewlyBoosted()) then
			self.SeeTrainerString:Hide();
			self.UnlearnedFrame:Show();
			self.TrainFrame:Hide();
			self.TrainTextBackground:Hide();
			self.TrainBook:Hide();
			self.RequiredLevelString:Show();
			self.RequiredLevelString:SetText(BOOSTED_CHAR_SPELL_TEMPLOCK);
			self.RequiredLevelString:SetTextColor(0.25, 0.12, 0);
			self.SpellName:SetTextColor(0.25, 0.12, 0);
			self.SpellSubName:SetTextColor(0.25, 0.12, 0);
			self.SpellName:SetShadowOffset(0, 0);
			self.SpellName:SetPoint("LEFT", self, "RIGHT", 8, 6);
		elseif (level and level > UnitLevel("player") or isDisabled) then
			self.SeeTrainerString:Hide();

			local displayedLevel = isDisabled and GetSpellLevelLearned(slot, SpellBookFrame.bookType) or level;
			if displayedLevel > 0 then
				self.RequiredLevelString:SetFormattedText(SPELLBOOK_AVAILABLE_AT, displayedLevel);
				self.RequiredLevelString:SetTextColor(0.25, 0.12, 0);
				self.RequiredLevelString:Show();
			end

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

	local isLevelLinkLocked = spellID and C_LevelLink.IsSpellLocked(spellID) or false;
	levelLinkLockTexture:SetShown(isLevelLinkLocked);
	levelLinkLockBg:SetShown(isLevelLinkLocked);
	if isLevelLinkLocked then
		iconTexture:SetAlpha(1.0);
		iconTexture:SetDesaturated(true);
	else
		iconTexture:SetAlpha(iconTextureAlpha);
		iconTexture:SetDesaturated(iconTextureDesaturated);
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
		self:SetChecked(false);
	else
		self:UpdateSelection();
	end

	self.ClickBindingIconCover:Hide();
	self.ClickBindingHighlight:Hide();
	self.SpellName:SetShadowColor(0, 0, 0, 1);
	self.canClickBind = false;
	if (InClickBindingMode()) then
		self.SpellHighlightTexture:Hide();
		local spellBindable = spellID and C_ClickBindings.CanSpellBeClickBound(spellID) or false;
		local canBind = spellBindable and (not isOffSpec) and (not isDisabled);
		if (canBind) then
			self.canClickBind = true;
			if (ClickBindingFrame:HasEmptySlot()) then
				self.ClickBindingHighlight:Show();
			end
		else
			iconTexture:SetDesaturation(0.5);
			self.ClickBindingIconCover:Show();
			self.SpellName:SetTextColor(0.25, 0.12, 0);
			self.SpellSubName:SetTextColor(0.25, 0.12, 0);
			self.SpellName:SetShadowColor(0, 0, 0, 0);
		end
	end

	if GameTooltip:GetOwner() == self then
		self:OnEnter();
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

function SpellBookFrame_OnMouseWheel(self, value, scrollBar)
	--do nothing if not on an appropriate book type
	if not SpellBookInfo[SpellBookFrame.bookType].mousewheelNavigation then
		return;
	end

	local currentPage, maxPages = SpellBook_GetCurrentPage();

	if(value > 0) then
		if(currentPage > 1) then
			SpellBookPrevPageButton_OnClick()
		end
	else
		if(currentPage < maxPages) then
			SpellBookNextPageButton_OnClick()
		end
	end
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

	SpellBookFrame_HideStaticPopups();
end

function SpellBook_GetSpellBookSlot(spellButton)
	local id = spellButton:GetID()
	if ( SpellBookFrame.bookType == BOOKTYPE_PROFESSION) then
		return id + spellButton:GetParent().spellOffset;
	elseif ( SpellBookFrame.bookType == BOOKTYPE_PET ) then
		local slot = id + (SPELLS_PER_PAGE * (SPELLBOOK_PAGENUMBERS[BOOKTYPE_PET] - 1));
		local slotType, slotID = GetSpellBookItemInfo(slot, SpellBookFrame.bookType);
		return slot, slotType, slotID;
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

function SpellBook_GetButtonForID(id)
	-- Currently the spell book is mapped such that odd numbered buttons from 1 - 11 match id 1 - 6, while even numbered buttons from 2 - 12 match 7 - 12
	if (id > 6) then
		return _G["SpellButton"..((id - 6) * 2)];
	else
		return _G["SpellButton"..(((id - 1) * 2) + 1)];
	end
end

function SpellBookFrame_OpenToPageForGlyph(spellID, reason)
	SpellBookFrame.bookType = BOOKTYPE_SPELL;
	local toggleFlyout = true;
	local button, flyoutButton = SpellBookFrame_OpenToSpell(spellID, toggleFlyout, reason);

	if flyoutButton then
		SpellFlyout:SetBorderColor(181/256, 162/256, 90/256);
	elseif button then
		if (reason == OPEN_REASON_PENDING_GLYPH) then
			button.AbilityHighlight:Show();
			button.AbilityHighlightAnim:Play();
		elseif (reason == OPEN_REASON_ACTIVATED_GLYPH) then
			button.AbilityHighlightAnim:Stop();
			button.AbilityHighlight:Hide();
			button.GlyphActivate:Show();
			button.GlyphIcon:Show();
			button.GlyphTranslation:Show();
			button.GlyphActivateAnim:Play();
			SpellBookFrame.castingGlyphSlot = slot;
		end
	end
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
				local isOffSpec = (offSpecID ~= 0);
				skillLineTab.tooltip = name;
				skillLineTab:Show();
				skillLineTab.isOffSpec = isOffSpec;
				if(texture) then
					skillLineTab:SetNormalTexture(texture);
					skillLineTab:GetNormalTexture():SetDesaturated(isOffSpec);
				else
					skillLineTab:ClearNormalTexture();
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
					skillLineTab:SetChecked(true);
					--SpellBookSpellGroupText:SetText(name);
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
	local prof1, prof2, arch, fish, cook = GetProfessions();
	FormatProfession(PrimaryProfession1, prof1);
	FormatProfession(PrimaryProfession2, prof2);
	FormatProfession(SecondaryProfession1, cook);
	FormatProfession(SecondaryProfession2, fish);
	FormatProfession(SecondaryProfession3, arch);
	SpellBookPage1:SetDesaturated(false);
	SpellBookPage2:SetDesaturated(false);
end

-- *************************************************************************************

SpellBookFrame_HelpPlate = {
	FramePos = { x = 5,	y = -22 },
	FrameSize = { width = 580, height = 500	},
	[1] = { ButtonPos = { x = 250,	y = -50},	HighLightBox = { x = 65, y = -25, width = 460, height = 462 },	ToolTipDir = "DOWN",	ToolTipText = SPELLBOOK_HELP_1 },
	[2] = { ButtonPos = { x = 520,	y = -30 },	HighLightBox = { x = 540, y = -5, width = 46, height = 150 },	ToolTipDir = "LEFT",	ToolTipText = SPELLBOOK_HELP_2 },
	[3] = { ButtonPos = { x = 520,	y = -150},	HighLightBox = { x = 540, y = -175, width = 46, height = 100 },	ToolTipDir = "LEFT",	ToolTipText = SPELLBOOK_HELP_3, MinLevel = 10 },
}

ProfessionsFrame_HelpPlate = {
	FramePos = { x = 5,	y = -22 },
	FrameSize = { width = 545, height = 500	},
	[1] = { ButtonPos = { x = 150,	y = -110 }, HighLightBox = { x = 60, y = -35, width = 460, height = 195 }, ToolTipDir = "UP",	ToolTipText = PROFESSIONS_HELP_1 },
	[2] = { ButtonPos = { x = 150,	y = -325}, HighLightBox = { x = 60, y = -235, width = 460, height = 240 }, ToolTipDir = "UP",	ToolTipText = PROFESSIONS_HELP_2 },
}

function SpellBook_ToggleTutorial()
	SpellBookFrame_UpdateHelpPlate();
	local tutorial, helpPlate = SpellBookFrame_GetTutorialEnum();
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) and SpellBookFrame:IsShown()) then
		HelpPlate_Show( helpPlate, SpellBookFrame, SpellBookFrame.MainHelpButton );
		SetCVarBitfield( "closedInfoFrames", tutorial, true );
	else
		HelpPlate_Hide(true);
	end
end
