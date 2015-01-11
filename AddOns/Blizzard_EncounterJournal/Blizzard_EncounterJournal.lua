--LOCALIZED CONSTANTS
EJ_MIN_CHARACTER_SEARCH = 3;


--FILE CONSTANTS
local HEADER_INDENT = 15;
local MAX_CREATURES_PER_ENCOUNTER = 9;

local SECTION_BUTTON_OFFSET = 6;
local SECTION_DESCRIPTION_OFFSET = 27;

local EJ_STYPE_ITEM = 0;
local EJ_STYPE_ENCOUNTER = 1;
local EJ_STYPE_CREATURE = 2;
local EJ_STYPE_SECTION = 3;
local EJ_STYPE_INSTANCE = 4;

local EJ_HTYPE_OVERVIEW = 3;

local EJ_NUM_INSTANCE_PER_ROW = 4;

local EJ_LORE_MAX_HEIGHT = 97;
local EJ_MAX_SECTION_MOVE = 320;

-- Priority list for *not my spec*
local overviewPriorities = {
	[1] = "DAMAGER",
	[2] = "HEALER",
	[3] = "TANK",
}

local flagsByRole = {
	["DAMAGER"] = 1,
	["HEALER"] = 2,
	["TANK"] = 0,
}

local rolesByFlag = {
	[0] = "TANK",
	[1] = "DAMAGER",
	[2] = "HEALER"
}

local EJ_Tabs = {};

EJ_Tabs[1] = {frame="overviewScroll", button="overviewTab"};
EJ_Tabs[2] = {frame="lootScroll", button="lootTab"};
EJ_Tabs[3] = {frame="detailsScroll", button="bossTab"};
EJ_Tabs[4] = {frame="model", button="modelTab"};


local EJ_section_openTable = {};


local EJ_LINK_INSTANCE 		= 0;
local EJ_LINK_ENCOUNTER		= 1;
local EJ_LINK_SECTION 		= 3;

local EJ_DIFFICULTIES =  
{
	{ size = "5", prefix = PLAYER_DIFFICULTY1, difficultyID = 1 },
	{ size = "5", prefix = PLAYER_DIFFICULTY2, difficultyID =  2 },
	{ size = "5", prefix = PLAYER_DIFFICULTY5, difficultyID = 8 },
	{ size = "25", prefix = PLAYER_DIFFICULTY3, difficultyID = 7 },
	{ size = "10", prefix = PLAYER_DIFFICULTY1, difficultyID = 3 },
	{ size = "10", prefix = PLAYER_DIFFICULTY2, difficultyID = 5 },
	{ size = "25", prefix = PLAYER_DIFFICULTY1, difficultyID = 4 },
	{ size = "25", prefix = PLAYER_DIFFICULTY2, difficultyID = 6 },
	{ prefix = PLAYER_DIFFICULTY3, difficultyID = 17 },
	{ prefix = PLAYER_DIFFICULTY1, difficultyID = 14 },
	{ prefix = PLAYER_DIFFICULTY2, difficultyID = 15 },
	{ prefix = PLAYER_DIFFICULTY6, difficultyID = 16 },
}

local EJ_TIER_DATA =
{
	[1] = { backgroundTexture = "Interface\\EncounterJournal\\UI-EJ-Classic", r = 1.0, g = 0.8, b = 0.0 },
	[2] = { backgroundTexture = "Interface\\EncounterJournal\\UI-EJ-BurningCrusade", r = 0.6, g = 0.8, b = 0.0 },
	[3] = { backgroundTexture = "Interface\\EncounterJournal\\UI-EJ-WrathoftheLichKing", r = 0.2, g = 0.8, b = 1.0 },
	[4] = { backgroundTexture = "Interface\\EncounterJournal\\UI-EJ-Cataclysm", r = 1.0, g = 0.4, b = 0.0 },
	[5] = { backgroundTexture = "Interface\\EncounterJournal\\UI-EJ-MistsofPandaria", r = 0.0, g = 0.6, b = 0.2 },
	[6] = { backgroundTexture = "Interface\\ENCOUNTERJOURNAL\\UI-EJ-WarlordsofDraenor", r = 0.82, g = 0.55, b = 0.1 },
}


local BOSS_LOOT_BUTTON_HEIGHT = 45;
local INSTANCE_LOOT_BUTTON_HEIGHT = 64;


function EncounterJournal_OnLoad(self)
	EncounterJournalTitleText:SetText(ENCOUNTER_JOURNAL);
	SetPortraitToTexture(EncounterJournalPortrait,"Interface\\EncounterJournal\\UI-EJ-PortraitIcon");
	self:RegisterEvent("EJ_LOOT_DATA_RECIEVED");
	self:RegisterEvent("EJ_DIFFICULTY_UPDATE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	
	self.encounter.freeHeaders = {};
	self.encounter.usedHeaders = {};
	
	self.encounter.overviewFrame = self.encounter.info.overviewScroll.child;
	self.encounter.overviewFrame.isOverview = true;
	self.encounter.overviewFrame.overviews = {};
	self.encounter.info.overviewScroll.ScrollBar.scrollStep = 30;

	self.encounter.infoFrame = self.encounter.info.detailsScroll.child;
	self.encounter.info.detailsScroll.ScrollBar.scrollStep = 30;	
	
	self.encounter.bossesFrame = self.encounter.info.bossesScroll.child;
	self.encounter.info.bossesScroll.ScrollBar.scrollStep = 30;	
	
	self.encounter.info.overviewTab:Click();
	
	self.encounter.info.lootScroll.update = EncounterJournal_LootUpdate;
	self.encounter.info.lootScroll.scrollBar.doNotHide = true;
	self.encounter.info.lootScroll.dynamic = EncounterJournal_LootCalcScroll;
	HybridScrollFrame_CreateButtons(self.encounter.info.lootScroll, "EncounterItemTemplate", 0, 0);
	
	
	self.searchResults.scrollFrame.update = EncounterJournal_SearchUpdate;
	self.searchResults.scrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.searchResults.scrollFrame, "EncounterSearchLGTemplate", 0, 0);

	EJ_SetDifficulty(EJ_DIFFICULTIES[1].difficultyID);	-- default to 5-man normal
	
	
	local homeData = {
		name = HOME,
		OnClick = EncounterJournal_ListInstances,
	}
	NavBar_Initialize(self.navBar, "NavButtonTemplate", homeData, self.navBar.home, self.navBar.overflow);
	
	EncounterJournal.instanceSelect.dungeonsTab:Disable();
	EncounterJournal.instanceSelect.dungeonsTab.selectedGlow:Show();
	EncounterJournal.instanceSelect.raidsTab:GetFontString():SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

	EncounterJournal.instanceSelect.tabs = {EncounterJournal.instanceSelect.dungeonsTab, EncounterJournal.instanceSelect.raidsTab};
	EncounterJournal.instanceSelect.currTab = 1;
	EncounterJournal_ListInstances();
	
	
	UIDropDownMenu_Initialize(self.encounter.info.lootScroll.lootFilter, EncounterJournal_InitLootFilter, "MENU");
end

function EncounterJournal_OnShow(self)
	UpdateMicroButtons();
	PlaySound("igCharacterInfoOpen");
	EncounterJournal_LootUpdate()
	
	--automatically navigate to the current dungeon if you are in one;
	local instanceID = EJ_GetCurrentInstance();
	local _, _, difficultyID = GetInstanceInfo();
	if instanceID ~= 0 and (instanceID ~= EncounterJournal.lastInstance or EJ_GetDifficulty() ~= difficultyID) then
		EncounterJournal_ListInstances();
		EncounterJournal_DisplayInstance(instanceID);
		EncounterJournal.lastInstance = instanceID;
		-- try to set difficulty to current instance difficulty
		if ( EJ_IsValidInstanceDifficulty(difficultyID) ) then
			EJ_SetDifficulty(difficultyID);
		end
	elseif ( EncounterJournal.queuedPortraitUpdate ) then
		-- fixes portraits when switching between fullscreen and windowed mode
		EncounterJournal_UpdatePortraits();
		EncounterJournal.queuedPortraitUpdate = false;
	elseif ( self.encounter.overviewFrame:IsShown() and EncounterJournal.overviewDefaultRole and not EncounterJournal.encounter.overviewFrame.linkSection ) then
		local spec, role;

		spec = GetSpecialization();
		if (spec) then
			role = GetSpecializationRole(spec);
		else
			role = "DAMAGER";
		end

		if ( EncounterJournal.overviewDefaultRole ~= role ) then
			EncounterJournal_ToggleHeaders(EncounterJournal.encounter.overviewFrame);
		end
	end

	local tierData = EJ_TIER_DATA[EJ_GetCurrentTier()];
	EncounterJournal.instanceSelect.bg:SetTexture(tierData.backgroundTexture);
	EncounterJournal.instanceSelect.raidsTab.selectedGlow:SetVertexColor(tierData.r, tierData.g, tierData.b);
	EncounterJournal.instanceSelect.dungeonsTab.selectedGlow:SetVertexColor(tierData.r, tierData.g, tierData.b);
end


function EncounterJournal_OnHide(self)
	UpdateMicroButtons();
	PlaySound("igCharacterInfoClose");
	if self.searchBox.clearButton then
		self.searchBox.clearButton:Click();
		EJ_ClearSearch();
	end
end


function EncounterJournal_OnEvent(self, event, ...)
	if  event == "EJ_LOOT_DATA_RECIEVED" then
		local itemID = ...
		if itemID then
			EncounterJournal_LootCallback(itemID);
			EncounterJournal_SearchUpdate();
		else
			EncounterJournal_LootUpdate();
		end
	elseif event == "EJ_DIFFICULTY_UPDATE" then
		--fix the difficulty buttons
		local newDifficultyID = ...;	
		for _, entry in pairs(EJ_DIFFICULTIES) do
			if entry.difficultyID == newDifficultyID then
				if (entry.size) then
					EncounterJournal.encounter.info.difficulty:SetFormattedText(ENCOUNTER_JOURNAL_DIFF_TEXT, entry.size, entry.prefix);
				else
					EncounterJournal.encounter.info.difficulty:SetText(entry.prefix);
				end
				EncounterJournal_Refresh();
				break;
			end
		end
	elseif event == "UNIT_PORTRAIT_UPDATE" then
		local unit = ...;
		if not unit then
			EncounterJournal_UpdatePortraits();
		end
	end
end

function EncounterJournal_GetCreatureButton(index)
	if index > MAX_CREATURES_PER_ENCOUNTER then
		return nil;
	end
	
	local self = EncounterJournal.encounter.info;
	local button = self.creatureButtons[index]
	if (not button) then
		button = CreateFrame("BUTTON", nil, self, "EncounterCreatureButtonTemplate");
		button:SetPoint("TOPLEFT", self.creatureButtons[index-1], "BOTTOMLEFT", 0, 8);
		self.creatureButtons[index] = button;
	end
	return button;
end

function EncounterJournal_UpdatePortraits()
	if ( EncounterJournal:IsShown() ) then
		local creatures = EncounterJournal.encounter.info.creatureButtons;
		for i = 1, #creatures do
			local button = creatures[i];
			if ( button and button:IsShown() ) then
				SetPortraitTexture(button.creature, button.displayInfo);
			else
				break;
			end
		end
		local usedHeaders = EncounterJournal.encounter.usedHeaders;
		for _, header in pairs(usedHeaders) do
			if ( header.button.portrait.displayInfo ) then
				SetPortraitTexture(header.button.portrait.icon, header.button.portrait.displayInfo);
			end
		end
	else
		EncounterJournal.queuedPortraitUpdate = true;
	end
end

local infiniteLoopPolice = false; --design migh make a tier that has no instances at all sigh
function EncounterJournal_ListInstances()
	local tierName = EJ_GetTierInfo(EJ_GetCurrentTier());
	EncounterJournal.instanceSelect.tier:SetText(tierName);
	NavBar_Reset(EncounterJournal.navBar);
	EncounterJournal.encounter:Hide();
	EncounterJournal.instanceSelect:Show();
	local showRaid = not EncounterJournal.instanceSelect.raidsTab:IsEnabled();
	

	local self = EncounterJournal.instanceSelect.scroll.child;
	local index = 1;
	local instanceID, name, description, _, buttonImage, _, _, link = EJ_GetInstanceByIndex(index, showRaid);
	local instanceButton;
	
	--No instances in this tab
	if not instanceID and not infiniteLoopPolice then
		--disable this tab and select the other one.
		local nextTab = mod(EncounterJournal.instanceSelect.currTab, 2) + 1;
		EncounterJournal.instanceSelect.tabs[EncounterJournal.instanceSelect.currTab].grayBox:Show();
		EncounterJournal.instanceSelect.tabs[nextTab]:Click();
		infiniteLoopPolice = true;
		EncounterJournal_ListInstances()
		return;
	end
	infiniteLoopPolice = false;

	while instanceID do
		instanceButton = self["instance"..index];
		if not instanceButton then -- create button
			instanceButton = CreateFrame("BUTTON", self:GetParent():GetName().."instance"..index, self, "EncounterInstanceButtonTemplate");
			if ( EncounterJournal.localizeInstanceButton ) then
				EncounterJournal.localizeInstanceButton(instanceButton);
			end
			self["instance"..index] = instanceButton;
			if mod(index-1, EJ_NUM_INSTANCE_PER_ROW) == 0 then
				instanceButton:SetPoint("TOP", self["instance"..(index-EJ_NUM_INSTANCE_PER_ROW)], "BOTTOM", 0, -15);
			else
				instanceButton:SetPoint("LEFT", self["instance"..(index-1)], "RIGHT", 15, 0);
			end
		end
	
		instanceButton.name:SetText(name);
		instanceButton.bgImage:SetTexture(buttonImage);
		instanceButton.instanceID = instanceID;
		instanceButton.tooltipTitle = name;
		instanceButton.tooltipText = description;
		instanceButton.link = link;
		instanceButton:Show();

		index = index + 1;
		instanceID, name, description, _, buttonImage, _, _, link = EJ_GetInstanceByIndex(index, showRaid);
	end

	--Hide old buttons needed.
	instanceButton = self["instance"..index];
	while instanceButton do
		instanceButton:Hide();
		index = index + 1;
		instanceButton = self["instance"..index];
	end
	
	
	--check if the other tab is empty
	local instanceText = EJ_GetInstanceByIndex(1, not showRaid);
	--No instances in the other tab
	if not instanceText then
		--disable the other tab.
		local nextTab = mod(EncounterJournal.instanceSelect.currTab, 2) + 1;
		EncounterJournal.instanceSelect.tabs[nextTab].grayBox:Show();
	end
end

function EncounterJournalInstanceButton_OnClick(self)
	NavBar_Reset(EncounterJournal.navBar);
	EncounterJournal_DisplayInstance(EncounterJournal.instanceID);
end

local function EncounterJournal_GetRootAfterOverviews(rootSectionID)
	local nextSectionID = rootSectionID;

	local headerType, siblingID, _;

	repeat
		_, _, headerType, _, _, siblingID = EJ_GetSectionInfo(nextSectionID);
		if (headerType == EJ_HTYPE_OVERVIEW) then
			nextSectionID = siblingID;
		end
	until headerType ~= EJ_HTYPE_OVERVIEW;

	return nextSectionID;
end

local function EncounterJournal_CheckForOverview(rootSectionID)
	return select(3,EJ_GetSectionInfo(rootSectionID)) == EJ_HTYPE_OVERVIEW;
end

local function EncounterJournal_SearchForOverview(instanceID)
	local bossIndex = 1;
	local _, _, bossID = EJ_GetEncounterInfoByIndex(bossIndex);
	while bossID do
		local _, _, _, rootSectionID = EJ_GetEncounterInfo(bossID);

		if (EncounterJournal_CheckForOverview(rootSectionID)) then
			return true;
		end

		bossIndex = bossIndex + 1;
		_, _, bossID = EJ_GetEncounterInfoByIndex(bossIndex);
	end

	return false;
end

function EncounterJournal_DisplayInstance(instanceID, noButton)
	local self = EncounterJournal.encounter;
	EncounterJournal.instanceSelect:Hide();
	EncounterJournal.encounter:Show();
	EncounterJournal.ceatureDisplayID = 0;
	
	EncounterJournal.instanceID = instanceID;
	EncounterJournal.encounterID = nil;
	EJ_SelectInstance(instanceID);
	EncounterJournal_LootUpdate();
	EncounterJournal_ClearDetails()
	
	local iname, description, bgImage, _, loreImage, buttonImage = EJ_GetInstanceInfo();
	self.instance.title:SetText(iname);
	self.instance.titleBG:SetWidth(self.instance.title:GetStringWidth() + 80);
	self.instance.loreBG:SetTexture(loreImage);
	self.info.instanceTitle:SetText(iname);
	
	self.instance.loreScroll.child.lore:SetText(description);
	local loreHeight = self.instance.loreScroll.child.lore:GetHeight();
	self.instance.loreScroll.ScrollBar:SetValue(0);
	if loreHeight <= EJ_LORE_MAX_HEIGHT then
		self.instance.loreScroll.ScrollBar:Hide();
	else
		self.instance.loreScroll.ScrollBar:Show();
	end
	
	self.info.instanceButton.instanceID = instanceID;
	self.info.instanceButton.icon:SetTexture(buttonImage);
	self.info.instanceButton.icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask");
	
	self.info.model.dungeonBG:SetTexture(bgImage);
	
	local bossIndex = 1;
	local name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
	local bossButton;

	while bossID do
		bossButton = _G["EncounterJournalBossButton"..bossIndex];
		if not bossButton then -- create a new header;
			bossButton = CreateFrame("BUTTON", "EncounterJournalBossButton"..bossIndex, EncounterJournal.encounter.bossesFrame, "EncounterBossButtonTemplate");
			if bossIndex > 1 then
				bossButton:SetPoint("TOPLEFT", _G["EncounterJournalBossButton"..(bossIndex-1)], "BOTTOMLEFT", 0, -15);
			else
				bossButton:SetPoint("TOPLEFT", EncounterJournal.encounter.bossesFrame, "TOPLEFT", 0, -10);
			end
		end
		
		bossButton.link = link;
		bossButton:SetText(name);
		bossButton:Show();
		bossButton.encounterID = bossID;
		--Use the boss' first creature as the button icon
		local _, _, _, _, bossImage = EJ_GetCreatureInfo(1, bossID);
		bossImage = bossImage or "Interface\\EncounterJournal\\UI-EJ-BOSS-Default";
		bossButton.creature:SetTexture(bossImage);
		bossButton:UnlockHighlight();
		
		bossIndex = bossIndex + 1;
		name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
	end

	--disable model tab and abilities tab, no boss selected
	EncounterJournal.encounter.info.modelTab:Disable();
	EncounterJournal.encounter.info.modelTab:GetDisabledTexture():SetDesaturated(true);
	EncounterJournal.encounter.info.modelTab.unselected:SetDesaturated(true);
	EncounterJournal.encounter.info.bossTab:Disable();
	EncounterJournal.encounter.info.bossTab:GetDisabledTexture():SetDesaturated(true);
	EncounterJournal.encounter.info.bossTab.unselected:SetDesaturated(true);

	if (EncounterJournal_SearchForOverview(instanceID)) then
		EJ_Tabs[1].frame = "overviewScroll";
		EJ_Tabs[3].frame = "detailsScroll"; -- flip them back
		self.info[EJ_Tabs[1].button].tooltip = OVERVIEW;
		self.info[EJ_Tabs[3].button]:Show();
		self.info[EJ_Tabs[4].button]:SetPoint("TOP", self.info[EJ_Tabs[3].button], "BOTTOM", 0, 2)
		self.info.overviewFound = true;
	else
		EJ_Tabs[1].frame = "detailsScroll";
		EJ_Tabs[3].frame = "overviewScroll"; -- flip these so detailsScroll won't get hidden, overview will never be shown here
		self.info[EJ_Tabs[1].button].tooltip = ABILITIES;
		self.info[EJ_Tabs[3].button]:Hide();
		self.info[EJ_Tabs[4].button]:SetPoint("TOP", self.info[EJ_Tabs[2].button], "BOTTOM", 0, 2)
		self.info.overviewFound = false;
	end

	self.instance:Show();
	self.info.overviewScroll:Hide();
	self.info.detailsScroll:Hide();
	self.info.lootScroll:Hide();
	self.info.rightShadow:Hide();
	
	if (self.info.tab < 3) then
		self.info[EJ_Tabs[self.info.tab].button]:Click()
	else
		self.info.overviewTab:Click();
	end
	
	if not noButton then
		local buttonData = {
			id = instanceID,
			name = iname,
			OnClick = EJNAV_RefreshInstance,
			listFunc = EJNAV_ListInstance,
		}
		NavBar_AddButton(EncounterJournal.navBar, buttonData);
	end
end


function EncounterJournal_DisplayEncounter(encounterID, noButton)
	local self = EncounterJournal.encounter;
	
	local ename, description, _, rootSectionID = EJ_GetEncounterInfo(encounterID);
	if (EncounterJournal.encounterID == encounterID) then
		--navbar is already set to the right button, don't add another
		noButton = true;
	elseif (EncounterJournal.encounterID) then
		--make sure the previous navbar button is the instance button
		NavBar_OpenTo(EncounterJournal.navBar, EncounterJournal.instanceID);
	end
	EncounterJournal.encounterID = encounterID;
	EJ_SelectEncounter(encounterID);
	EncounterJournal_LootUpdate();
	--need to clear details, but don't want to scroll to top of bosses list
	local bossListScrollValue = self.info.bossesScroll.ScrollBar:GetValue()
	EncounterJournal_ClearDetails();
	EncounterJournal.encounter.info.bossesScroll.ScrollBar:SetValue(bossListScrollValue)
	
	self.info.encounterTitle:SetText(ename);
	
	local overviewFound;
	if (EncounterJournal_CheckForOverview(rootSectionID)) then
		local _, overviewDescription = EJ_GetSectionInfo(rootSectionID);
		self.overviewFrame.loreDescription:SetHeight(0);
		self.overviewFrame.loreDescription:SetWidth(self.overviewFrame:GetWidth() - 5);
		self.overviewFrame.loreDescription:SetText(description);
		self.overviewFrame.overviewDescription:SetWidth(self.overviewFrame:GetWidth() - 5);
		self.overviewFrame.overviewDescription.Text:SetWidth(self.overviewFrame:GetWidth() - 5);
		EncounterJournal_SetBullets(self.overviewFrame.overviewDescription, overviewDescription, false);
		local bulletHeight = 0;
		if (self.overviewFrame.Bullets and #self.overviewFrame.Bullets > 0) then
			for i = 1, #self.overviewFrame.Bullets do
				bulletHeight = bulletHeight + self.overviewFrame.Bullets[i]:GetHeight();
			end
			local bullet = self.overviewFrame.Bullets[1];
			bullet:ClearAllPoints();
			bullet:SetPoint("TOPLEFT", self.overviewFrame.overviewDescription, "BOTTOMLEFT", 0, -9);
		end
		self.overviewFrame.descriptionHeight = self.overviewFrame.loreDescription:GetHeight() + self.overviewFrame.overviewDescription:GetHeight() + bulletHeight + 42;
		self.overviewFrame.rootOverviewSectionID = rootSectionID;
		rootSectionID = EncounterJournal_GetRootAfterOverviews(rootSectionID);
		overviewFound = true;
	end
	
	self.infoFrame.description:SetWidth(self.infoFrame:GetWidth() -5);
	self.infoFrame.description:SetText(description);
	self.infoFrame.descriptionHeight = self.infoFrame.description:GetHeight();
	
	self.infoFrame.encounterID = encounterID;
	self.infoFrame.rootSectionID = rootSectionID;
	self.infoFrame.expanded = false;
	
	local bossIndex = 1;
	local name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
	local bossButton;
	while bossID do
		bossButton = _G["EncounterJournalBossButton"..bossIndex];
		if not bossButton then -- create a new header;
			bossButton = CreateFrame("BUTTON", "EncounterJournalBossButton"..bossIndex, EncounterJournal.encounter.bossesFrame, "EncounterBossButtonTemplate");
			if bossIndex > 1 then
				bossButton:SetPoint("TOPLEFT", _G["EncounterJournalBossButton"..(bossIndex-1)], "BOTTOMLEFT", 0, -15);
			else
				bossButton:SetPoint("TOPLEFT", EncounterJournal.encounter.bossesFrame, "TOPLEFT", 0, -10);
			end
		end
		
		bossButton.link = link;
		bossButton:SetText(name);
		bossButton:Show();
		bossButton.encounterID = bossID;
		--Use the boss' first creature as the button icon
		local _, _, _, _, bossImage = EJ_GetCreatureInfo(1, bossID);
		bossImage = bossImage or "Interface\\EncounterJournal\\UI-EJ-BOSS-Default";
		bossButton.creature:SetTexture(bossImage);
		
		if (encounterID == bossID) then
			bossButton:LockHighlight();
		else
			bossButton:UnlockHighlight();
		end
		
		bossIndex = bossIndex + 1;
		name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
	end
	
	-- Setup Creatures
	local id, name, displayInfo, iconImage;
	for i=1,MAX_CREATURES_PER_ENCOUNTER do 
		id, name, description, displayInfo, iconImage = EJ_GetCreatureInfo(i);
		
		if id then
			local button = EncounterJournal_GetCreatureButton(i);
			SetPortraitTexture(button.creature, displayInfo);
			button.name = name;
			button.id = id;
			button.description = description;
			button.displayInfo = displayInfo;
		end
	end
	
	--enable model and abilities tab
	EncounterJournal.encounter.info.modelTab:Enable();
	EncounterJournal.encounter.info.modelTab:GetDisabledTexture():SetDesaturated(false);
	EncounterJournal.encounter.info.modelTab.unselected:SetDesaturated(false);
	EncounterJournal.encounter.info.bossTab:Enable();
	EncounterJournal.encounter.info.bossTab:GetDisabledTexture():SetDesaturated(false);
	EncounterJournal.encounter.info.bossTab.unselected:SetDesaturated(false);

	if (overviewFound) then
		EncounterJournal_ToggleHeaders(self.overviewFrame);
		self.overviewFrame:Show();
	else
		self.overviewFrame:Hide();
	end

	EncounterJournal_ToggleHeaders(self.infoFrame);
	
	self:Show();
	
	--make sure we stay on the tab we were on
	self.info[EJ_Tabs[self.info.tab].button]:Click()
	
	if not noButton then
		local buttonData = {
			id = encounterID,
			name = ename,
			OnClick = EJNAV_RefreshEncounter,
			listFunc = EJNAV_ListEncounter,
		}
		NavBar_AddButton(EncounterJournal.navBar, buttonData);
	end
end

function EncounterJournal_DisplayCreature(self)
	if EncounterJournal.encounter.info.shownCreatureButton then
		EncounterJournal.encounter.info.shownCreatureButton:Enable();
	end
	
	if EncounterJournal.ceatureDisplayID == self.displayInfo then
		--Don't refresh the same model
	elseif self.displayInfo then
		EncounterJournal.encounter.info.model:SetDisplayInfo(self.displayInfo);
		EncounterJournal.ceatureDisplayID = self.displayInfo;
	end
		
	EncounterJournal.encounter.info.model.imageTitle:SetText(self.name);
	if (IsGMClient()) then
		local displayID, name = EncounterJournal.encounter.info.model:GetModelInfo();
		EncounterJournal.encounter.info.model.modelName:SetText(name);
		EncounterJournal.encounter.info.model.modelDisplayId:SetText(displayID);
		EncounterJournal.encounter.info.model.modelName:Show();
		EncounterJournal.encounter.info.model.modelDisplayId:Show();
		EncounterJournal.encounter.info.model.modelNameLabel:Show();
		EncounterJournal.encounter.info.model.modelDisplayIdLabel:Show();
		if (EncounterJournal.encounter.info.model.modelName:IsTruncated()) then
			local pos = string.find(name, "\\[^\\]*$");
			name = name:sub(1, pos - 1) .. "\\\n" .. name:sub(pos + 1);
			EncounterJournal.encounter.info.model.modelName:SetText(name);
		end
	else
		EncounterJournal.encounter.info.model.modelName:Hide();
		EncounterJournal.encounter.info.model.modelDisplayId:Hide();
		EncounterJournal.encounter.info.model.modelNameLabel:Hide();
		EncounterJournal.encounter.info.model.modelDisplayIdLabel:Hide();
	end

	self:Disable();
	EncounterJournal.encounter.info.shownCreatureButton = self;
end

function EncounterJournal_ShowCreatures()
	local button;
	local creatures = EncounterJournal.encounter.info.creatureButtons;
	for i=1, #creatures do 
		button = creatures[i];
		if (button.displayInfo) then
			button:Show();
			if (i==1) then
				EncounterJournal_DisplayCreature(button)
			end
		end
	end
end

function EncounterJournal_HideCreatures()
	local button;
	local creatures = EncounterJournal.encounter.info.creatureButtons;
	for i=1, #creatures do 
		creatures[i]:Hide()
	end
end

local toggleTempList = {};
local headerCount = 0;

function EncounterJournal_UpdateButtonState(self)
	local oldtex = self.textures.expanded;
	if self:GetParent().expanded then
		self.tex = self.textures.expanded;
		oldtex = self.textures.collapsed;
		self.expandedIcon:SetTextColor(0.929, 0.788, 0.620);
		self.title:SetTextColor(0.929, 0.788, 0.620);
	else
		self.tex = self.textures.collapsed;
		self.expandedIcon:SetTextColor(0.827, 0.659, 0.463);
		self.title:SetTextColor(0.827, 0.659, 0.463);
	end
	
	oldtex.up[1]:Hide();
	oldtex.up[2]:Hide();
	oldtex.up[3]:Hide();
	oldtex.down[1]:Hide();
	oldtex.down[2]:Hide();
	oldtex.down[3]:Hide();
	
	
	self.tex.up[1]:Show();
	self.tex.up[2]:Show();
	self.tex.up[3]:Show();
	self.tex.down[1]:Hide();
	self.tex.down[2]:Hide();
	self.tex.down[3]:Hide();
end

function EncounterJournal_CleanBullets(self, start, keep)
	if (not self.Bullets) then return end
    start = start or 1;
	for i = start, #self.Bullets do
		self.Bullets[i]:Hide();
		if (not keep) then
			if (not self.BulletCache) then
				self.BulletCache = {};
			end
			self.Bullets[i]:ClearAllPoints();
			tinsert(self.BulletCache, self.Bullets[i]);
			self.Bullets[i] = nil;
		end
	end
end

function EncounterJournal_SetBullets(object, description, hideBullets)
	local parent = object:GetParent();
	
	if (not string.find(description, "\$bullet;")) then
		object.Text:SetText(description);
		object.textString = description;
		object:SetHeight(object.Text:GetContentHeight());
		EncounterJournal_CleanBullets(parent);
		return;
	end

	local desc = string.match(description, "(.-)\$bullet;");

	if (desc) then
		object.Text:SetText(desc);
		object.textString = desc;
		object:SetHeight(object.Text:GetContentHeight());
	end
	
	local bullets = {}
	for v in string.gmatch(description,"\$bullet;([^$]+)") do
		tinsert(bullets, v);
	end

	local k = 1;
	local skipped = 0;
	for j = 1,#bullets do
		local text = bullets[j];
		if (text and text ~= "") then
			local bullet;
			bullet = parent.Bullets and parent.Bullets[k];
			if (not bullet) then
				if (parent.BulletCache and #parent.BulletCache > 0) then
					-- We only need to check for BulletCache because the BulletCache is created when we clean the bullets, so the BulletCache existing also means the Bullets exist.
					parent.Bullets[k] = tremove(parent.BulletCache);
					bullet = parent.Bullets[k];
				else
					bullet = CreateFrame("Frame", nil, parent, "EncounterOverviewBulletTemplate");
				end
				bullet:SetWidth(parent:GetWidth() - 13);
				bullet.Text:SetWidth(bullet:GetWidth() - 26);
			end
			bullet:ClearAllPoints();
			if (k == 1) then
				if (parent.button) then
					bullet:SetPoint("TOPLEFT", parent.button, "BOTTOMLEFT", 13, -9 - object:GetHeight());
				else
					bullet:SetPoint("TOPLEFT", parent, "TOPLEFT", 13, -9 - object:GetHeight());
				end
			else
				bullet:SetPoint("TOP", parent.Bullets[k-1], "BOTTOM", 0, 0);
			end
			bullet.Text:SetText(text);
			if (bullet.Text:GetContentHeight() ~= 0) then
				bullet:SetHeight(bullet.Text:GetContentHeight());
			end

			if (hideBullets) then
				bullet:Hide();
			else
				bullet:Show();
			end
			k = k + 1;
		else
			skipped = skipped + 1;
		end
	end

	EncounterJournal_CleanBullets(parent, (#bullets - skipped) + 1);
end

function EncounterJournal_SetDescriptionWithBullets(infoHeader, description)
	EncounterJournal_SetBullets(infoHeader.overviewDescription, description, true);

	infoHeader.descriptionBG:ClearAllPoints();
	infoHeader.descriptionBG:SetPoint("TOPLEFT", infoHeader.button, "BOTTOMLEFT", 1, 0);
	if (infoHeader.Bullets and #infoHeader.Bullets > 0) then
		infoHeader.descriptionBG:SetPoint("BOTTOMRIGHT", infoHeader.Bullets[#infoHeader.Bullets], -1, -11);
	else
		infoHeader.descriptionBG:SetPoint("BOTTOMRIGHT", infoHeader.overviewDescription, 9, -11);
	end
	infoHeader.descriptionBG:Hide();
	infoHeader.descriptionBGBottom:Hide();
end

function EncounterJournal_SetUpOverview(self, role, index)
	local infoHeader;
	if not self.overviews[index] then -- create a new header;
		infoHeader = CreateFrame("FRAME", "EncounterJournalOverviewInfoHeader"..index, EncounterJournal.encounter.overviewFrame, "EncounterInfoTemplate");
		infoHeader.description:Hide();
		infoHeader.overviewDescription:Hide();
		infoHeader.descriptionBG:Hide();
		infoHeader.descriptionBGBottom:Hide();
		infoHeader.button.abilityIcon:Hide();
		infoHeader.button.portrait:Hide();
		infoHeader.button.portrait.name = nil;
		infoHeader.button.portrait.displayInfo = nil;
		infoHeader.button.icon2:Hide();
		infoHeader.button.icon3:Hide();
		infoHeader.button.icon4:Hide();
		infoHeader.overviewIndex = index;
		infoHeader.isOverview = true;

		local textLeftAnchor = infoHeader.button.expandedIcon;
		local textRightAnchor = infoHeader.button.icon1;
		infoHeader.button.title:SetPoint("LEFT", textLeftAnchor, "RIGHT", 5, 0);
		infoHeader.button.title:SetPoint("RIGHT", textRightAnchor, "LEFT", -5, 0);

		self.overviews[index] = infoHeader;
	else
		infoHeader = self.overviews[index];
	end

	infoHeader.button.expandedIcon:SetText("+");
	infoHeader.expanded = false;
	
	infoHeader:ClearAllPoints();
	if (index == 1) then
		infoHeader:SetPoint("TOPLEFT", 0, -15 - self.descriptionHeight - SECTION_BUTTON_OFFSET);
		infoHeader:SetPoint("TOPRIGHT", 0, -15 - self.descriptionHeight - SECTION_BUTTON_OFFSET);
	else
		infoHeader:SetPoint("TOPLEFT", self.overviews[index-1], "BOTTOMLEFT", 0, -9);
		infoHeader:SetPoint("TOPRIGHT", self.overviews[index-1], "BOTTOMRIGHT", 0, -9);
	end

	infoHeader.description:Hide();

	for i = 1, #infoHeader.Bullets do
		infoHeader.Bullets[i]:Hide();
	end

	wipe(infoHeader.Bullets);
	local title, description, siblingID, link, flag1;
	
	local _, _, _, _, _, _, nextSectionID =  EJ_GetSectionInfo(self.rootOverviewSectionID);

	while nextSectionID do
		title, description, _, _, _, siblingID, _, _, link, _, flag1 = EJ_GetSectionInfo(nextSectionID);
		if (role == rolesByFlag[flag1]) then
			break;
		end
		nextSectionID = siblingID;
	end

	if (not title) then
		infoHeader:Hide();
		return;
	end
	
	infoHeader.button.icon1:Show();
	EncounterJournal_SetFlagIcon(infoHeader.button.icon1.icon, flag1);

	infoHeader.button.title:SetText(title);
	infoHeader.button.link = link;
	infoHeader.sectionID = nextSectionID;
	
	infoHeader.overviewDescription:SetWidth(infoHeader:GetWidth() - 20);
	EncounterJournal_SetDescriptionWithBullets(infoHeader, description);
	infoHeader:Show();
end

function EncounterJournal_ToggleHeaders(self, doNotShift)
	local numAdded = 0
	local infoHeader, parentID, _;
	local hWidth = self:GetWidth();
	local nextSectionID;
	local topLevelSection = false;
	
	local isOverview = self.isOverview;
	
	local hideHeaders;
	if (not self.isOverview or (self.isOverview and self.overviewIndex)) then
		self.expanded = not self.expanded;
		hideHeaders = not self.expanded;
	end

	if hideHeaders then
		self.button.expandedIcon:SetText("+");
		self.description:Hide();
		if (self.overviewDescription) then
			self.overviewDescription:Hide();
		end
		self.descriptionBG:Hide();
		self.descriptionBGBottom:Hide();

		EncounterJournal_CleanBullets(self, nil, true);
			
		if (self.overviewIndex) then
			local overview = EncounterJournal.encounter.overviewFrame.overviews[self.overviewIndex + 1];

			if (overview) then
				overview:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -9);
			end
		else
			EncounterJournal_ClearChildHeaders(self);
		end
	else
		if (not isOverview) then
			if strlen(self.description:GetText() or "") > 0 then
				self.description:Show();
				if (self.overviewDescription) then
					self.overviewDescription:Hide();
				end
				if self.button then
					self.descriptionBG:Show();
					self.descriptionBGBottom:Show();
					self.button.expandedIcon:SetText("-");
				end
			elseif self.button then
				self.description:Hide();
				if (self.overviewDescription) then
					self.overviewDescription:Hide();
				end
				self.descriptionBG:Hide();
				self.descriptionBGBottom:Hide();
				self.button.expandedIcon:SetText("-");
			end
		else
			if (self.overviewIndex) then
				self.button.expandedIcon:SetText("-");
				for i = 1, #self.Bullets do
					self.Bullets[i]:Show();
				end
				self.description:Hide();
				self.overviewDescription:Show();
				self.descriptionBG:Show();
				self.descriptionBGBottom:Show();
				
				local overview = EncounterJournal.encounter.overviewFrame.overviews[self.overviewIndex + 1];

				if (overview) then
					if (self.Bullets and #self.Bullets > 0) then
						overview:SetPoint("TOPLEFT", self.Bullets[#self.Bullets], "BOTTOMLEFT", -13, -18);
					else
						local yoffset = -18 - self:GetHeight();
						overview:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, yoffset);
					end
				end
				EncounterJournal_UpdateButtonState(self.button);
			end
		end

		-- Get Section Info
		if (not isOverview) then
			local freeHeaders = EncounterJournal.encounter.freeHeaders;
			local usedHeaders = EncounterJournal.encounter.usedHeaders;

			local listEnd = #usedHeaders;
			
			if self.myID then  -- this is from a button click
				_, _, _, _, _, _, nextSectionID =  EJ_GetSectionInfo(self.myID)
				parentID = self.myID;
				self.description:SetWidth(self:GetWidth() -20);
				hWidth = hWidth - HEADER_INDENT;
			else
				--This sets the base encounter header
				parentID = self.encounterID;
				nextSectionID = self.rootSectionID;
				topLevelSection = true;
			end

			while nextSectionID do
				local title, description, headerType, abilityIcon, displayInfo, siblingID, _, fileredByDifficulty, link, startsOpen, flag1, flag2, flag3, flag4 = EJ_GetSectionInfo(nextSectionID);
				if not title then
					break;
				elseif not fileredByDifficulty then --ignore all sections that should not be shown with our current difficulty settings		
					if #freeHeaders == 0 then -- create a new header;
						headerCount = headerCount + 1; -- the is a file local
						infoHeader = CreateFrame("FRAME", "EncounterJournalInfoHeader"..headerCount, EncounterJournal.encounter.infoFrame, "EncounterInfoTemplate");
						infoHeader:Hide();
					else
						infoHeader = freeHeaders[#freeHeaders];
						freeHeaders[#freeHeaders] = nil;
					end
					
					numAdded = numAdded + 1;
					toggleTempList[#toggleTempList+1] = infoHeader;
					
					infoHeader.button.link = link;
					infoHeader.parentID = parentID;
					infoHeader.myID = nextSectionID;
					infoHeader.description:SetText(description);
					infoHeader.button.title:SetText(title);
					if topLevelSection then
						infoHeader.button.title:SetFontObject("GameFontNormalMed3");
					else
						infoHeader.button.title:SetFontObject("GameFontNormal");
					end
					
					--All headers start collapsed
					infoHeader.expanded = false
					infoHeader.description:Hide();
					infoHeader.descriptionBG:Hide();
					infoHeader.descriptionBGBottom:Hide();
					infoHeader.button.expandedIcon:SetText("+");

					for i = 1, #infoHeader.Bullets do
						infoHeader.Bullets[i]:Hide();
					end

					local textLeftAnchor = infoHeader.button.expandedIcon;
					--Show ability Icon
					if abilityIcon ~= "" then
						infoHeader.button.abilityIcon:SetTexture(abilityIcon);
						infoHeader.button.abilityIcon:Show();
						textLeftAnchor = infoHeader.button.abilityIcon;
					else
						infoHeader.button.abilityIcon:Hide();
					end
					
					--Show Creature Portrait
					if displayInfo ~= 0 then
						SetPortraitTexture(infoHeader.button.portrait.icon, displayInfo);
						infoHeader.button.portrait.name = title;
						infoHeader.button.portrait.displayInfo = displayInfo;
						infoHeader.button.portrait:Show();
						textLeftAnchor = infoHeader.button.portrait;
						infoHeader.button.abilityIcon:Hide();
					else
						infoHeader.button.portrait:Hide();
						infoHeader.button.portrait.name = nil;
						infoHeader.button.portrait.displayInfo = nil;
					end
					infoHeader.button.title:SetPoint("LEFT", textLeftAnchor, "RIGHT", 5, 0);
					
					
					--Set flag Icons
					local textRightAnchor = nil;
					infoHeader.button.icon1:Hide();
					infoHeader.button.icon2:Hide();
					infoHeader.button.icon3:Hide();
					infoHeader.button.icon4:Hide();
					if flag1 then
						textRightAnchor = infoHeader.button.icon1;
						infoHeader.button.icon1:Show();
						infoHeader.button.icon1.tooltipTitle = _G["ENCOUNTER_JOURNAL_SECTION_FLAG"..flag1];
						infoHeader.button.icon1.tooltipText = _G["ENCOUNTER_JOURNAL_SECTION_FLAG_DESCRIPTION"..flag1];
						EncounterJournal_SetFlagIcon(infoHeader.button.icon1.icon, flag1);
						if flag2 then
							textRightAnchor = infoHeader.button.icon2;
							infoHeader.button.icon2:Show();
							EncounterJournal_SetFlagIcon(infoHeader.button.icon2.icon, flag2);
							infoHeader.button.icon2.tooltipTitle = _G["ENCOUNTER_JOURNAL_SECTION_FLAG"..flag2];
							infoHeader.button.icon2.tooltipText = _G["ENCOUNTER_JOURNAL_SECTION_FLAG_DESCRIPTION"..flag2];
							if flag3 then
								textRightAnchor = infoHeader.button.icon3;
								infoHeader.button.icon3:Show();
								EncounterJournal_SetFlagIcon(infoHeader.button.icon3.icon, flag3);
								infoHeader.button.icon3.tooltipTitle = _G["ENCOUNTER_JOURNAL_SECTION_FLAG"..flag3];
								infoHeader.button.icon3.tooltipText = _G["ENCOUNTER_JOURNAL_SECTION_FLAG_DESCRIPTION"..flag3];
								if flag4 then
									textRightAnchor = infoHeader.button.icon4;
									infoHeader.button.icon4:Show();
									EncounterJournal_SetFlagIcon(infoHeader.button.icon4.icon, flag4);
									infoHeader.button.icon4.tooltipTitle = _G["ENCOUNTER_JOURNAL_SECTION_FLAG"..flag4];
									infoHeader.button.icon4.tooltipText = _G["ENCOUNTER_JOURNAL_SECTION_FLAG_DESCRIPTION"..flag4];
								end
							end
						end
					end
					if textRightAnchor then
						infoHeader.button.title:SetPoint("RIGHT", textRightAnchor, "LEFT", -5, 0);
					else
						infoHeader.button.title:SetPoint("RIGHT", infoHeader.button, "RIGHT", -5, 0);
					end
					
					infoHeader.index = nil;
					infoHeader:SetWidth(hWidth);
					
					
					-- If this section has not be seen and should start open
					if EJ_section_openTable[infoHeader.myID] == nil and startsOpen then
						EJ_section_openTable[infoHeader.myID] = true;
					end
					
					--toggleNested?
					if EJ_section_openTable[infoHeader.myID]  then
						infoHeader.expanded = false; -- setting false to expand it in EncounterJournal_ToggleHeaders
						numAdded = numAdded + EncounterJournal_ToggleHeaders(infoHeader, true);
					end
					
					infoHeader:Show();
				end -- if not fileredByDifficulty
				nextSectionID = siblingID;
			end

			if not doNotShift and numAdded > 0 then
				--fix the usedlist
				local startIndex = self.index or 0;
				for i=listEnd,startIndex+1,-1 do
					usedHeaders[i+numAdded] = usedHeaders[i];
					usedHeaders[i+numAdded].index = i + numAdded;
					usedHeaders[i] = nil
				end
				for i=1,numAdded do
					usedHeaders[startIndex + i] = toggleTempList[i];
					usedHeaders[startIndex + i].index = startIndex + i;
					toggleTempList[i] = nil;
				end
			end
			
			if topLevelSection and usedHeaders[1] then
				usedHeaders[1]:SetPoint("TOPRIGHT", 0 , -8 - EncounterJournal.encounter.infoFrame.descriptionHeight - SECTION_BUTTON_OFFSET);
			end
		elseif (not self.overviewIndex) then
			for i = 1, #self.overviews do
				self.overviews[i]:Hide();
			end

			EncounterJournal.overviewDefaultRole = nil;

			if (not self.rootOverviewSectionID) then 
				return;
			end

			local spec, role;

			spec = GetSpecialization();
			if (spec) then
				role = GetSpecializationRole(spec);
			else
				role = "DAMAGER";
			end

			EncounterJournal_SetUpOverview(self, role, 1);

			local k = 2;			
			for i = 1, 3 do
				local otherRole = overviewPriorities[i];
				if (otherRole ~= role) then
					EncounterJournal_SetUpOverview(self, otherRole, k);
					k = k + 1;
				end
			end

			if (self.linkSection) then
				for i = 1, 3 do
					local overview = self.overviews[i];
					if (overview.sectionID == self.linkSection) then
						overview.expanded = false;
						EncounterJournal_ToggleHeaders(overview);
						overview.cbCount = 0;
						overview.flashAnim:Play();
						overview:SetScript("OnUpdate", EncounterJournal_FocusSectionCallback);
					else
						overview.expanded = true;
						EncounterJournal_ToggleHeaders(overview);
						overview.flashAnim:Stop();
						overview:SetScript("OnUpdate", nil);
					end
				end
				self.linkSection = nil;
			else
				self.overviews[1].expanded = false;
				EncounterJournal.overviewDefaultRole = role;
				EncounterJournal_ToggleHeaders(self.overviews[1]);
			end
		end
	end

	if (not isOverview) then
		if self.myID then
			EJ_section_openTable[self.myID] = self.expanded;
		end
		
		if not doNotShift then
			EncounterJournal_ShiftHeaders(self.index or 1);
			
			--check to see if it is offscreen
			if self.index then
				local scrollValue = EncounterJournal.encounter.info.detailsScroll.ScrollBar:GetValue();
				local cutoff = EncounterJournal.encounter.info.detailsScroll:GetHeight() + scrollValue;
				
				local _, _, _, _, anchorY = self:GetPoint();
				anchorY = anchorY - self:GetHeight();
				if self.description:IsShown() then
					anchorY = anchorY - self.description:GetHeight() - SECTION_DESCRIPTION_OFFSET;
				end
				
				if cutoff < abs(anchorY) then
					self.frameCount = 0;
					self:SetScript("OnUpdate", EncounterJournal_MoveSectionUpdate);
				end
			end
		end
		return numAdded;
	else
		return 0;
	end
end


function EncounterJournal_ShiftHeaders(index)
	local usedHeaders = EncounterJournal.encounter.usedHeaders;
	if not usedHeaders[index] then
		return;
	end
	
	local _, _, _, _, anchorY = usedHeaders[index]:GetPoint();
	for i=index,#usedHeaders-1 do
		anchorY = anchorY - usedHeaders[i]:GetHeight();
		if usedHeaders[i].description:IsShown() then
			anchorY = anchorY - usedHeaders[i].description:GetHeight() - SECTION_DESCRIPTION_OFFSET;
		else
			anchorY = anchorY - SECTION_BUTTON_OFFSET;
		end
		
		usedHeaders[i+1]:SetPoint("TOPRIGHT", 0 , anchorY);
	end
end


function EncounterJournal_ResetHeaders()
	for key,_ in pairs(EJ_section_openTable) do
		EJ_section_openTable[key] = nil;
	end

	PlaySound("igMainMenuOptionCheckBoxOn");
	EncounterJournal_Refresh();
end


function EncounterJournal_FocusSection(sectionID)
	if (not EncounterJournal_CheckForOverview(sectionID)) then
		local usedHeaders = EncounterJournal.encounter.usedHeaders;
		for _, section in pairs(usedHeaders) do
			if section.myID == sectionID then
				section.cbCount = 0;
				section.flashAnim:Play();
				section:SetScript("OnUpdate", EncounterJournal_FocusSectionCallback);
			else
				section.flashAnim:Stop();
				section:SetScript("OnUpdate", nil);
			end
		end
	end
end


function EncounterJournal_FocusSectionCallback(self)
	if self.cbCount > 0 then
		local _, _, _, _, anchorY = self:GetPoint();
		anchorY = abs(anchorY);
		anchorY = anchorY - EncounterJournal.encounter.info.detailsScroll:GetHeight()/2;
		EncounterJournal.encounter.info.detailsScroll.ScrollBar:SetValue(anchorY);
		self:SetScript("OnUpdate", nil);
	end
	self.cbCount = self.cbCount + 1;
end


function EncounterJournal_MoveSectionUpdate(self)
	
	if self.frameCount > 0 then
		local _, _, _, _, anchorY = self:GetPoint();
		local height = min(EJ_MAX_SECTION_MOVE, self:GetHeight() + self.description:GetHeight() + SECTION_DESCRIPTION_OFFSET);
		local scrollValue = abs(anchorY) - (EncounterJournal.encounter.info.detailsScroll:GetHeight()-height);
		EncounterJournal.encounter.info.detailsScroll.ScrollBar:SetValue(scrollValue);
		self:SetScript("OnUpdate", nil);
	end
	self.frameCount = self.frameCount + 1;
end


function EncounterJournal_ClearChildHeaders(self, doNotShift)
	local usedHeaders = EncounterJournal.encounter.usedHeaders;
	local freeHeaders = EncounterJournal.encounter.freeHeaders;
	local numCleared = 0
	for key,header in pairs(usedHeaders) do
		if header.parentID == self.myID then
			if header.expanded then
				numCleared = numCleared + EncounterJournal_ClearChildHeaders(header, true)
			end
			header:Hide();
			usedHeaders[key] = nil;
			freeHeaders[#freeHeaders+1] = header;
			numCleared = numCleared + 1;
		end
	end
	
	if numCleared > 0 and not doNotShift then
		local placeIndex = self.index + 1;
		local shiftHeader = usedHeaders[placeIndex + numCleared];
		while shiftHeader do
			usedHeaders[placeIndex] = shiftHeader;
			usedHeaders[placeIndex].index = placeIndex;
			usedHeaders[placeIndex + numCleared] = nil;
			placeIndex = placeIndex + 1;
			shiftHeader = usedHeaders[placeIndex + numCleared];
		end
	end
	return numCleared
end


function EncounterJournal_ClearDetails()
	EncounterJournal.encounter.instance:Hide();
	EncounterJournal.encounter.infoFrame.description:SetText("");
	EncounterJournal.encounter.info.encounterTitle:SetText("");
	
	EncounterJournal.encounter.info.lootScroll.scrollBar:SetValue(0);
	EncounterJournal.encounter.info.detailsScroll.ScrollBar:SetValue(0);
	EncounterJournal.encounter.info.bossesScroll.ScrollBar:SetValue(0);
	
	local freeHeaders = EncounterJournal.encounter.freeHeaders;
	local usedHeaders = EncounterJournal.encounter.usedHeaders;
	
	for key,used in pairs(usedHeaders) do
		used:Hide();
		usedHeaders[key] = nil;
		freeHeaders[#freeHeaders+1] = used;
	end
	
	local creatures = EncounterJournal.encounter.info.creatureButtons;
	for i=1, #creatures do 
		creatures[i]:Hide();
		creatures[i].displayInfo = nil;
	end
	
	local bossIndex = 1
	local bossButton = _G["EncounterJournalBossButton"..bossIndex];
	while bossButton do
		bossButton:Hide();
		bossIndex = bossIndex + 1;
		bossButton = _G["EncounterJournalBossButton"..bossIndex];
	end
	
	EncounterJournal.searchResults:Hide();
	EncounterJournal_HideSearchPreview();
	EncounterJournal.searchBox:ClearFocus();
end

function EncounterJournal_OnHyperlinkEnter(self, link, text, hyperlinkButton)
	if ( link and string.find(link, "spell") ) then
		local _, _, spellID = string.find(link, "(%d+)");
		if ( spellID ) then
			GameTooltip:SetOwner(hyperlinkButton, "ANCHOR_RIGHT");
			GameTooltip:SetSpellByID(spellID, false, false, false, EJ_GetDifficulty());
		end
	end
end

function EncounterJournal_TabClicked(self, button)
	local tabType = self:GetID();
	local info = EncounterJournal.encounter.info;
	info.tab = tabType;
	for key, data in pairs(EJ_Tabs) do 
		if key == tabType then
			info[data.frame]:Show();
			info[data.button].selected:Show();
			info[data.button].unselected:Hide();
			info[data.button]:LockHighlight();
		else
			info[data.frame]:Hide();
			info[data.button].selected:Hide();
			info[data.button].unselected:Show();
			info[data.button]:UnlockHighlight();
		end
	end
	PlaySound("igAbiliityPageTurn");
end


function EncounterJournal_LootCallback(itemID)
	local scrollFrame = EncounterJournal.encounter.info.lootScroll;
	
	for i,item in pairs(scrollFrame.buttons) do
		if item.itemID == itemID then
			local name, icon, slot, armorType, itemID, link, encounterID = EJ_GetLootInfoByIndex(item.index);
			item.name:SetText(name);
			item.icon:SetTexture(icon);
			item.slot:SetText(slot);
			item.boss:SetFormattedText(BOSS_INFO_STRING, EJ_GetEncounterInfo(encounterID));
			item.armorType:SetText(armorType);
			item.link = link;
		end
	end
end


function EncounterJournal_LootUpdate()
	EncounterJournal_UpdateFilterString();
	local scrollFrame = EncounterJournal.encounter.info.lootScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local items = scrollFrame.buttons;
	local item, index;
	
	local numLoot = EJ_GetNumLoot();
	local buttonSize = BOSS_LOOT_BUTTON_HEIGHT;
	
	for i = 1,#items do
		item = items[i];
		index = offset + i;
		if index <= numLoot then
			if (EncounterJournal.encounterID) then
				item:SetHeight(BOSS_LOOT_BUTTON_HEIGHT);
				item.boss:Hide();
				item.bossTexture:Hide();
				item.bosslessTexture:Show();
			else
				buttonSize = INSTANCE_LOOT_BUTTON_HEIGHT;
				item:SetHeight(INSTANCE_LOOT_BUTTON_HEIGHT);
				item.boss:Show();
				item.bossTexture:Show();
				item.bosslessTexture:Hide();
			end
			local name, icon, slot, armorType, itemID, link, encounterID = EJ_GetLootInfoByIndex(index);
			item.name:SetText(name);
			item.icon:SetTexture(icon);
			item.slot:SetText(slot);
			item.armorType:SetText(armorType);
			item.boss:SetFormattedText(BOSS_INFO_STRING, EJ_GetEncounterInfo(encounterID));
			item.encounterID = encounterID;
			item.itemID = itemID;
			item.index = index;
			item.link = link;
			item:Show();
			
			if item.showingTooltip then
				EncounterJournal_SetTooltip(link);
			end
		else
			item:Hide();
		end
	end
	
	local totalHeight = numLoot * buttonSize;
	HybridScrollFrame_Update(scrollFrame, totalHeight, scrollFrame:GetHeight());
end

function EncounterJournal_LootCalcScroll(offset)
	local buttonHeight = BOSS_LOOT_BUTTON_HEIGHT;
	local numLoot = EJ_GetNumLoot();
	
	if (not EncounterJournal.encounterID) then
		buttonHeight = INSTANCE_LOOT_BUTTON_HEIGHT;
	end	
	
	local index = floor(offset/buttonHeight)
	return index, offset - (index*buttonHeight);
end


function EncounterJournal_Loot_OnUpdate(self)
	if GameTooltip:IsOwned(self) then
		if IsModifiedClick("COMPAREITEMS") or
				 (GetCVarBool("alwaysCompareItems") and not IsEquippedItem(self.itemID)) then
			GameTooltip_ShowCompareItem();
		else
			ShoppingTooltip1:Hide();
			ShoppingTooltip2:Hide();
		end

		if IsModifiedClick("DRESSUP") then
			ShowInspectCursor();
		else
			ResetCursor();
		end
	end
end


function EncounterJournal_Loot_OnClick(self)
	if (EncounterJournal.encounterID ~= self.encounterID) then
		PlaySound("igSpellBookOpen");
		EncounterJournal_DisplayEncounter(self.encounterID);
	end
end

function EncounterJournal_SetTooltip(link)
	local classID, specID = EJ_GetLootFilter();

	if (specID == 0) then
		local spec = GetSpecialization();
		if (spec and classID == select(3, UnitClass("player"))) then
			specID = GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player"));
		else
			specID = -1;
		end
	end

	GameTooltip:SetHyperlink(link, classID, specID);
end

function EncounterJournal_SetFlagIcon(texture, index)
	local iconSize = 32;
	local columns = 256/iconSize;
	local rows = 64/iconSize;

	-- Mythic flag should use heroic Icon
	if (index == 12) then
		index = 3;
	end

	local l = mod(index, columns) / columns;
	local r = l + (1/columns);
	local t = floor(index/columns) / rows;
	local b = t + (1/rows);
	texture:SetTexCoord(l,r,t,b);
end


function EncounterJournal_Refresh(self)
	EncounterJournal_LootUpdate();
	
	if EncounterJournal.encounterID then
		EncounterJournal_DisplayEncounter(EncounterJournal.encounterID, true)
	elseif EncounterJournal.instanceID then
		EncounterJournal_DisplayInstance(EncounterJournal.instanceID, true);
	end
end


function EncounterJournal_GetSearchDisplay(index)
	local name, icon, path, typeText, displayInfo, itemID, _;
	local id, stype, _, instanceID, encounterID, itemLink = EJ_GetSearchResult(index);
	if stype == EJ_STYPE_INSTANCE then
		name, _, _, icon = EJ_GetInstanceInfo(id);
		typeText = ENCOUNTER_JOURNAL_INSTANCE;
	elseif stype == EJ_STYPE_ENCOUNTER then
		name = EJ_GetEncounterInfo(id);
		typeText = ENCOUNTER_JOURNAL_ENCOUNTER;
		path = EJ_GetInstanceInfo(instanceID);
		icon = "Interface\\EncounterJournal\\UI-EJ-GenericSearchCreature"
		--_, _, _, displayInfo = EJ_GetCreatureInfo(1, encounterID);
	elseif stype == EJ_STYPE_SECTION then
		name, _, _, icon, displayInfo = EJ_GetSectionInfo(id)
		if displayInfo and displayInfo > 0 then
			typeText = ENCOUNTER_JOURNAL_ENCOUNTER_ADD;
			displayInfo = nil;
			icon = "Interface\\EncounterJournal\\UI-EJ-GenericSearchCreature"
		else
			typeText = ENCOUNTER_JOURNAL_ABILITY;
		end
		path = EJ_GetInstanceInfo(instanceID).." | "..EJ_GetEncounterInfo(encounterID);
	elseif stype == EJ_STYPE_ITEM then
		name, icon, _, _, itemID = EJ_GetLootInfo(id)
		typeText = ENCOUNTER_JOURNAL_ITEM;
		path = EJ_GetInstanceInfo(instanceID).." | "..EJ_GetEncounterInfo(encounterID);
	elseif stype == EJ_STYPE_CREATURE then
		for i=1,MAX_CREATURES_PER_ENCOUNTER do
			local cId, cName, _, cDisplayInfo = EJ_GetCreatureInfo(i, encounterID);
			if cId == id then
				name = cName
				--displayInfo = cDisplayInfo;
				break;
			end
		end
		icon = "Interface\\EncounterJournal\\UI-EJ-GenericSearchCreature"
		typeText = ENCOUNTER_JOURNAL_ENCOUNTER
		path = EJ_GetInstanceInfo(instanceID).." | "..EJ_GetEncounterInfo(encounterID);
	end
	return name, icon, path, typeText, displayInfo, itemID, stype, itemLink;
end


function EncounterJournal_SelectSearch(index)
	local _;
	local id, stype, difficultyID, instanceID, encounterID = EJ_GetSearchResult(index);
	local sectionID, creatureID, itemID;
	if stype == EJ_STYPE_INSTANCE then
		instanceID = id;
	elseif stype == EJ_STYPE_SECTION then
		sectionID = id;
	elseif stype == EJ_STYPE_ITEM then
		itemID = id;
	elseif stype == EJ_STYPE_CREATURE then
		creatureID = id;
	end
	
	EncounterJournal_OpenJournal(difficultyID, instanceID, encounterID, sectionID, creatureID, itemID);
	EncounterJournal.searchResults:Hide();
end


function EncounterJournal_SearchUpdate()
	local scrollFrame = EncounterJournal.searchResults.scrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local results = scrollFrame.buttons;
	local result, index;
	
	local numResults = EJ_GetNumSearchResults();
	
	for i = 1,#results do
		result = results[i];
		index = offset + i;
		if index <= numResults then
			local name, icon, path, typeText, displayInfo, itemID, stype, itemLink = EncounterJournal_GetSearchDisplay(index);
			if stype == EJ_STYPE_INSTANCE then
				result.icon:SetTexCoord(0.16796875, 0.51171875, 0.03125, 0.71875);
			else
				result.icon:SetTexCoord(0, 1, 0, 1);
			end
			
			result.name:SetText(name);
			result.resultType:SetText(typeText);
			result.path:SetText(path);
			result.icon:SetTexture(icon);
			result.link = itemLink;
			if displayInfo and displayInfo > 0 then
				SetPortraitTexture(result.icon, displayInfo);
			end
			result:SetID(index);
			result:Show();
			
			if result.showingTooltip then
				if itemLink then
					GameTooltip:SetOwner(result, "ANCHOR_RIGHT");
					GameTooltip:SetHyperlink(itemLink);
				else
					GameTooltip:Hide();
				end
			end
		else
			result:Hide();
		end
	end
	
	local totalHeight = numResults * 49;
	HybridScrollFrame_Update(scrollFrame, totalHeight, 370);
end


function EncounterJournal_ShowFullSearch()
	local numResults = EJ_GetNumSearchResults();
	if numResults == 0 then
		EncounterJournal.searchResults:Hide();
		return;
	end

	EncounterJournal.searchResults.TitleText:SetText(string.format(ENCOUNTER_JOURNAL_SEARCH_RESULTS, EncounterJournal.searchBox:GetText(), numResults));
	EncounterJournal.searchResults:Show();
	EncounterJournal_SearchUpdate();
	EncounterJournal.searchResults.scrollFrame.scrollBar:SetValue(0);
	EncounterJournal_HideSearchPreview();
end


function EncounterJournal_HideSearchPreview()
	EncounterJournal.searchBox.showAllResults:Hide();
	local index = 1;
	local unusedButton = EncounterJournal.searchBox["sbutton"..index];
	while unusedButton do
		unusedButton:Hide();
		index = index + 1;
		unusedButton = EncounterJournal.searchBox["sbutton"..index]
	end
end


function EncounterJournal_ClearSearch(editbox)
	EncounterJournal.searchResults:Hide();
	EncounterJournal_HideSearchPreview();
end


function EncounterJournal_OnSearchTextChanged(self)
	SearchBoxTemplate_OnTextChanged(self);

	local text = self:GetText();
	EncounterJournal_HideSearchPreview();
		
	if strlen(text) < EJ_MIN_CHARACTER_SEARCH then
		EJ_ClearSearch();
		EncounterJournal.searchResults:Hide();
		return;
	end
	EJ_SetSearch(text);
	
	if not self:HasFocus() then
		return;
	end
	
	if EncounterJournal.searchResults:IsShown() then
		EncounterJournal_ShowFullSearch();
	else
		local numResults = EJ_GetNumSearchResults();
		local index = 1;
		local button;
		while index <= numResults do
			button = EncounterJournal.searchBox["sbutton"..index];
			if button then
				local name, icon, path, typeText, displayInfo, itemID, stype, itemLink = EncounterJournal_GetSearchDisplay(index);
				button.name:SetText(name);
				button.icon:SetTexture(icon);
				button.link = itemLink;
				if displayInfo and displayInfo > 0 then
					SetPortraitTexture(button.icon, displayInfo);
				end
				button:SetID(index);
				button:Show();
			else
				button = EncounterJournal.searchBox.showAllResults;
				button.text:SetText(string.format(ENCOUNTER_JOURNAL_SHOW_SEARCH_RESULTS, numResults));
				EncounterJournal.searchBox.showAllResults:Show();
				break;
			end
			index = index + 1;
		end
		
		EncounterJournal.searchBox.sbutton1.boarderAnchor:SetPoint("BOTTOM", button, "BOTTOM", 0, -5);
	end
end

function EncounterJournal_OnSearchFocusLost(self)
	SearchBoxTemplate_OnEditFocusLost(self);
	EncounterJournal_HideSearchPreview();
end

function EncounterJournal_OpenJournalLink(tag, jtype, id, difficultyID)
	jtype = tonumber(jtype);
	id = tonumber(id);
	difficultyID = tonumber(difficultyID);
	local instanceID, encounterID, sectionID, tierIndex = EJ_HandleLinkPath(jtype, id);
	EncounterJournal_OpenJournal(difficultyID, instanceID, encounterID, sectionID, nil, nil, tierIndex);
end


function EncounterJournal_OpenJournal(difficultyID, instanceID, encounterID, sectionID, creatureID, itemID, tierIndex)
	ShowUIPanel(EncounterJournal);
	if instanceID then
		NavBar_Reset(EncounterJournal.navBar);
		EncounterJournal_DisplayInstance(instanceID);
		EJ_SetDifficulty(difficultyID);
		if encounterID then
			if sectionID then
				if (EncounterJournal_CheckForOverview(sectionID)) then
					EncounterJournal.encounter.overviewFrame.linkSection = sectionID;
					EncounterJournal.encounter.info.overviewTab:Click();
				else
					if (EncounterJournal_SearchForOverview(instanceID)) then
						EncounterJournal.encounter.info.bossTab:Click();
					else
						EncounterJournal.encounter.info.overviewTab:Click();
					end
					local sectionPath = {EJ_GetSectionPath(sectionID)};
					for _, id in pairs(sectionPath) do
						EJ_section_openTable[id] = true;
					end
				end
			end
			
			
			EncounterJournal_DisplayEncounter(encounterID);
			if sectionID then
				EncounterJournal_FocusSection(sectionID);
			elseif itemID then
				EncounterJournal.encounter.info.lootTab:Click();
			end
			
		end
	elseif tierIndex then
		EncounterJournal_TierDropDown_Select(EncounterJournal, tierIndex+1);
	else
		EncounterJournal_ListInstances()
	end
end


function EncounterJournal_SelectDifficulty(self, value)
	EJ_SetDifficulty(value);
end


function EncounterJournal_DifficultyInit(self, level)
	local currDifficulty = EJ_GetDifficulty();
	local info = UIDropDownMenu_CreateInfo();
	for i=1,#EJ_DIFFICULTIES do
		local entry = EJ_DIFFICULTIES[i];
		if EJ_IsValidInstanceDifficulty(entry.difficultyID) then
			info.func = EncounterJournal_SelectDifficulty;
			if (entry.size) then
				info.text = string.format(ENCOUNTER_JOURNAL_DIFF_TEXT, entry.size, entry.prefix);
			else
				info.text = entry.prefix;
			end
			info.arg1 = entry.difficultyID;
			info.checked = currDifficulty == entry.difficultyID;
			UIDropDownMenu_AddButton(info);
		end
	end
end

function EJRaidTab_OnClick(self)
	self:GetParent().currTab = 2;

	self:Disable();
	self:GetFontString():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	local tierData = EJ_TIER_DATA[EJ_GetCurrentTier()];
	self.selectedGlow:SetVertexColor(tierData.r, tierData.g, tierData.b);
	self.selectedGlow:Show();

	local dungeonsTab = self:GetParent().dungeonsTab;
	dungeonsTab:Enable();
	dungeonsTab:GetFontString():SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	dungeonsTab.selectedGlow:Hide();
	EncounterJournal_ListInstances();
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function EJDungeonTab_OnClick(self)
	self:GetParent().currTab = 1;
	
	self:Disable();
	self:GetFontString():SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
	local tierData = EJ_TIER_DATA[EJ_GetCurrentTier()];
	self.selectedGlow:SetVertexColor(tierData.r, tierData.g, tierData.b);
	self.selectedGlow:Show();

	local raidsTab = self:GetParent().raidsTab;
	raidsTab:Enable();
	raidsTab:GetFontString():SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	raidsTab.selectedGlow:Hide();
	EncounterJournal_ListInstances();
	PlaySound("igMainMenuOptionCheckBoxOn");
end

function EJTierDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, EJTierDropDown_Initialize, "MENU");
end


function EJTierDropDown_Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	local numTiers = EJ_GetNumTiers();
	local currTier = EJ_GetCurrentTier();
	for i=1,numTiers do
		info.text = EJ_GetTierInfo(i);
		info.func = EncounterJournal_TierDropDown_Select
		info.checked = i == currTier;
		info.arg1 = i;
		UIDropDownMenu_AddButton(info, level)
	end
end


function EncounterJournal_TierDropDown_Select(self, tier)
	EJ_SelectTier(tier);
	EncounterJournal.instanceSelect.tabs[1].grayBox:Hide();
	EncounterJournal.instanceSelect.tabs[2].grayBox:Hide();

	local tierData = EJ_TIER_DATA[tier];
	EncounterJournal.instanceSelect.bg:SetTexture(tierData.backgroundTexture);
	EncounterJournal.instanceSelect.raidsTab.selectedGlow:SetVertexColor(tierData.r, tierData.g, tierData.b);
	EncounterJournal.instanceSelect.dungeonsTab.selectedGlow:SetVertexColor(tierData.r, tierData.g, tierData.b);
	
	EncounterJournal_ListInstances();
end


function EncounterJournal_SetFilter(self, classID, specID)
	EJ_SetLootFilter(classID, specID);
	CloseDropDownMenus(1);
	EncounterJournal_LootUpdate();
end


function EncounterJournal_UpdateFilterString()
	local name, _;
	local classID, specID = EJ_GetLootFilter();

	if (specID > 0) then
		_, name = GetSpecializationInfoByID(specID, UnitSex("player"))
	elseif (classID > 0) then
		name = GetClassInfoByID(classID);
	end
	
	if name then
		EncounterJournal.encounter.info.lootScroll.classClearFilter.text:SetText(string.format(EJ_CLASS_FILTER, name));
		EncounterJournal.encounter.info.lootScroll.classClearFilter:Show();
		EncounterJournal.encounter.info.lootScroll:SetHeight(360);
	else
		EncounterJournal.encounter.info.lootScroll.classClearFilter:Hide();
		EncounterJournal.encounter.info.lootScroll:SetHeight(382);
	end
end

local CLASS_DROPDOWN = 1;
function EncounterJournal_InitLootFilter(self, level)
	local filterClassID, filterSpecID = EJ_GetLootFilter();
	local sex = UnitSex("player");
	local classDisplayName, classTag, classID;
	local info = UIDropDownMenu_CreateInfo();
	info.keepShownOnClick = nil;

	if (UIDROPDOWNMENU_MENU_VALUE == CLASS_DROPDOWN) then 
		info.text = ALL_CLASSES;
		info.checked = (filterClassID == 0);
		info.arg1 = 0;
		info.arg2 = 0;
		info.func = EncounterJournal_SetFilter;
		UIDropDownMenu_AddButton(info, level);

		local numClasses = GetNumClasses();
		for i = 1, numClasses do
			classDisplayName, classTag, classID = GetClassInfo(i);
			info.text = classDisplayName;
			info.checked = (filterClassID == classID);
			info.arg1 = classID;
			info.arg2 = 0;
			info.func = EncounterJournal_SetFilter;
			UIDropDownMenu_AddButton(info, level);
		end
	end

	if (level == 1) then 
		info.text = CLASS;
		info.func =  nil;
		info.notCheckable = true;
		info.hasArrow = true;
		info.value = CLASS_DROPDOWN;
		UIDropDownMenu_AddButton(info, level)
		
		if ( filterClassID > 0 ) then
			classDisplayName, classTag, classID = GetClassInfoByID(filterClassID);
		else
			classDisplayName, classTag, classID = UnitClass("player");
		end
		info.text = classDisplayName;
		info.notCheckable = true;
		info.arg1 = nil;
		info.arg2 = nil;
		info.func =  nil;
		info.hasArrow = false;
		UIDropDownMenu_AddButton(info, level);
		
		info.notCheckable = nil;
		local numSpecs = GetNumSpecializationsForClassID(classID);
		for i = 1, numSpecs do
			local specID, specName = GetSpecializationInfoForClassID(classID, i, sex);
			info.leftPadding = 10;
			info.text = specName;
			info.checked = (filterSpecID == specID);
			info.arg1 = classID;
			info.arg2 = specID;
			info.func = EncounterJournal_SetFilter;
			UIDropDownMenu_AddButton(info, level);
		end

		info.text = ALL_SPECS;
		info.leftPadding = 10;
		info.checked = (classID == filterClassID) and (filterSpecID == 0);
		info.arg1 = classID;
		info.arg2 = 0;
		info.func = EncounterJournal_SetFilter;
		UIDropDownMenu_AddButton(info, level);
	end
end




----------------------------------------
--------------Nav Bar Func--------------
----------------------------------------
function EJNAV_RefreshInstance()
	EncounterJournal_DisplayInstance(EncounterJournal.instanceID, true);
end

function EJNAV_SelectInstance(self, index, navBar)
	local showRaid = not EncounterJournal.instanceSelect.raidsTab:IsEnabled();
	local instanceID = EJ_GetInstanceByIndex(index, showRaid);
	
	--Clear any previous selection.
	NavBar_Reset(navBar);
	
	EncounterJournal_DisplayInstance(instanceID);
end


function EJNAV_ListInstance(self, index)
	--local navBar = self:GetParent();
	local showRaid = not EncounterJournal.instanceSelect.raidsTab:IsEnabled();
	local _, name = EJ_GetInstanceByIndex(index, showRaid);
	return name, EJNAV_SelectInstance;
end


function EJNAV_RefreshEncounter()
	EncounterJournal_DisplayInstance(EncounterJournal.encounterID);
end


function EJNAV_SelectEncounter(self, index, navBar)
	local _, _, bossID = EJ_GetEncounterInfoByIndex(index);
	EncounterJournal_DisplayEncounter(bossID);
end


function EJNAV_ListEncounter(self, index)
	--local navBar = self:GetParent();
	local name = EJ_GetEncounterInfoByIndex(index);
	return name, EJNAV_SelectEncounter;
end
