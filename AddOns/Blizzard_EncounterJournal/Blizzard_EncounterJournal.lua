--LOCALIZED CONSTANTS
EJ_MIN_CHARACTER_SEARCH = 3;


--FILE CONSTANTS
local HEADER_INDENT = 15;
local MAX_CREATURES_PER_ENCOUNTER = 6;

local SECTION_BUTTON_OFFSET = 6;
local SECTION_DESCRIPTION_OFFSET = 27;


local EJ_STYPE_ITEM = 0;
local EJ_STYPE_ENCOUNTER = 1;
local EJ_STYPE_CREATURE = 2;
local EJ_STYPE_SECTION = 3;
local EJ_STYPE_INSTANCE = 4;


local EJ_NUM_INSTANCE_PER_ROW = 4;

local EJ_LORE_MAX_HEIGHT = 97;
local EJ_MAX_SECTION_MOVE = 320;


local EJ_Tabs = {};
EJ_Tabs[1] = {frame="detailsScroll", button="bossTab"};
EJ_Tabs[2] = {frame="lootScroll", button="lootTab"};


local EJ_section_openTable = {};


local EJ_LINK_INSTANCE 		= 0;
local EJ_LINK_ENCOUNTER		= 1;
local EJ_LINK_SECTION 		= 3;



local EJ_DIFF_5MAN 				= 1
local EJ_DIFF_5MAN_HEROIC 		= 2

local EJ_DIFF_10MAN		 		= 1
local EJ_DIFF_25MAN		 		= 2
local EJ_DIFF_10MAN_HEROIC 		= 3
local EJ_DIFF_25MAN_HEROIC 		= 4
local EJ_DIFF_LFRAID	 		= 5

local EJ_DIFF_DUNGEON_TBL =  
{
	[1] = { enumValue = EJ_DIFF_5MAN, size = 5, prefix = PLAYER_DIFFICULTY1, difficultyID = 1 },
	[2] = { enumValue = EJ_DIFF_5MAN_HEROIC, size = 5, prefix = PLAYER_DIFFICULTY2, difficultyID =  2 }
}

local EJ_DIFF_RAID_TBL =  
{
	[1] = { enumValue = EJ_DIFF_LFRAID, size = 25, prefix = PLAYER_DIFFICULTY3, difficultyID = 7 },
	[2] = { enumValue = EJ_DIFF_10MAN, size = 10, prefix = PLAYER_DIFFICULTY1, difficultyID = 3 },
	[3] = { enumValue = EJ_DIFF_10MAN_HEROIC, size = 10, prefix = PLAYER_DIFFICULTY2, difficultyID = 5 },
	[4] = { enumValue = EJ_DIFF_25MAN, size = 25, prefix = PLAYER_DIFFICULTY1, difficultyID = 4 },
	[5] = { enumValue = EJ_DIFF_25MAN_HEROIC, size = 25, prefix = PLAYER_DIFFICULTY2, difficultyID = 6 }
}

local EJ_TIER_DATA =
{
	[1] = { backgroundTexture = "Interface\\EncounterJournal\\UI-EJ-Classic", r = 1.0, g = 0.8, b = 0.0},
	[2] = { backgroundTexture = "Interface\\EncounterJournal\\UI-EJ-BurningCrusade", r = 0.6, g = 0.8, b = 0.0},
	[3] = { backgroundTexture = "Interface\\EncounterJournal\\UI-EJ-WrathoftheLichKing", r = 0.2, g = 0.8, b = 1.0},
	[4] = { backgroundTexture = "Interface\\EncounterJournal\\UI-EJ-Cataclysm", r = 1.0, g = 0.4, b = 0.0},
	[5] = { backgroundTexture = "Interface\\EncounterJournal\\UI-EJ-MistsofPandaria", r = 0.0, g = 0.6, b = 0.2},
}


local BOSS_LOOT_BUTTON_HEIGHT = 45;
local INSTANCE_LOOT_BUTTON_HEIGHT = 64;


function EncounterJournal_OnLoad(self)
	EncounterJournalTitleText:SetText(ENCOUNTER_JOURNAL);
	SetPortraitToTexture(EncounterJournalPortrait,"Interface\\EncounterJournal\\UI-EJ-PortraitIcon");
	self:RegisterEvent("EJ_LOOT_DATA_RECIEVED");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("EJ_DIFFICULTY_UPDATE");
	
	self.encounter.freeHeaders = {};
	self.encounter.usedHeaders = {};
	
	self.encounter.infoFrame = self.encounter.info.detailsScroll.child;
	self.encounter.info.detailsScroll.ScrollBar.scrollStep = 30;	
	
	self.encounter.info.bossTab:Click();
	
	self.encounter.info.lootScroll.update = EncounterJournal_LootUpdate;
	self.encounter.info.lootScroll.scrollBar.doNotHide = true;
	self.encounter.info.lootScroll.dynamic = EncounterJournal_LootCalcScroll;
	HybridScrollFrame_CreateButtons(self.encounter.info.lootScroll, "EncounterItemTemplate", 0, 0);
	
	
	self.searchResults.scrollFrame.update = EncounterJournal_SearchUpdate;
	self.searchResults.scrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.searchResults.scrollFrame, "EncounterSearchLGTemplate", 0, 0);
	
	EJ_SetDifficulty(EJ_DIFF_5MAN);
	
	EncounterJournal.searchBox.oldEditLost = EncounterJournal.searchBox:GetScript("OnEditFocusLost");
	EncounterJournal.searchBox:SetScript("OnEditFocusLost", function(self) self:oldEditLost(); EncounterJournal_HideSearchPreview(); end);
	EncounterJournal.searchBox.clearFunc = EncounterJournal_ClearSearch;
	
	
	local homeData = {
		name = HOME,
		OnClick = EncounterJournal_ListInstances,
		listFunc = EJNAV_ListInstance,
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
	if instanceID ~= 0 and (instanceID ~= EncounterJournal.lastInstance or difficultyID ~= EncounterJournal.difficultyID) then
		EncounterJournal_ListInstances();
		EncounterJournal_DisplayInstance(instanceID);
		EncounterJournal.lastInstance = instanceID;
		EncounterJournal.difficultyID = difficultyID;
		-- convert difficulty ID to old difficulty index
		local difficultyIndex;
		-- check dungeon table first
		for _, info in pairs(EJ_DIFF_DUNGEON_TBL) do
			if ( info.difficultyID == difficultyID ) then
				difficultyIndex = info.enumValue;
				break;
			end
		end
		-- check raid table
		if ( not difficultyIndex ) then
			for _, info in pairs(EJ_DIFF_RAID_TBL) do
				if ( info.difficultyID == difficultyID ) then
					difficultyIndex = info.enumValue;
					break;
				end
			end	
		end
		EJ_SetDifficulty(difficultyIndex or EJ_DIFF_5MAN);
	elseif ( EncounterJournal.queuedPortraitUpdate ) then
		-- fixes portraits when switching between fullscreen and windowed mode
		EncounterJournal_UpdatePortraits();
		EncounterJournal.queuedPortraitUpdate = false;
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
		local newDifficulty = ...;
		local diffList = EJ_DIFF_DUNGEON_TBL;
		if EJ_InstanceIsRaid() then
			diffList = EJ_DIFF_RAID_TBL;
		end
		
		for _, entry in pairs(diffList) do
			if entry.enumValue == newDifficulty then
				EncounterJournal.encounter.info.difficulty:SetFormattedText(ENCOUNTER_JOURNAL_DIFF_TEXT, entry.size, entry.prefix);
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


function EncounterJournal_UpdatePortraits()
	if ( EncounterJournal:IsShown() ) then
		local self = EncounterJournal.encounter;
		for i = 1, MAX_CREATURES_PER_ENCOUNTER do
			local button = self["creatureButton"..i];
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

local infinateLoopPolice = false; --design migh make a tier that has no instances at all sigh
function EncounterJournal_ListInstances()
	local tierName = EJ_GetTierInfo(EJ_GetCurrentTier());
	EncounterJournal.instanceSelect.tier:SetText(tierName);
	NavBar_Reset(EncounterJournal.navBar);
	EncounterJournal.encounter:Hide();
	EncounterJournal.instanceSelect:Show();
	local showRaid = EncounterJournal.instanceSelect.raidsTab:IsEnabled() == nil;
	

	local self = EncounterJournal.instanceSelect.scroll.child;
	local index = 1;
	local instanceID, name, description, _, buttonImage, _, _, link = EJ_GetInstanceByIndex(index, showRaid);
	local instanceButton;
	
	--No instances in this tab
	if not instanceID and not infinateLoopPolice then
		--disable this tab and select the other one.
		local nextTab = mod(EncounterJournal.instanceSelect.currTab, 2) + 1;
		EncounterJournal.instanceSelect.tabs[EncounterJournal.instanceSelect.currTab].grayBox:Show();
		EncounterJournal.instanceSelect.tabs[nextTab]:Click();
		infinateLoopPolice = true;
		EncounterJournal_ListInstances()
		return;
	end
	infinateLoopPolice = false;
	
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


function EncounterJournal_DisplayInstance(instanceID, noButton)
	local self = EncounterJournal.encounter;
	EncounterJournal.encounter.model:Hide();
	EncounterJournal.instanceSelect:Hide();
	EncounterJournal.encounter:Show();
	EncounterJournal.ceatureDisplayID = 0;

	EncounterJournal.instanceID = instanceID;
	EncounterJournal.encounterID = nil;
	EJ_SelectInstance(instanceID);
	EncounterJournal_LootUpdate();
	EncounterJournal_ClearDetails()
	
	local iname, description, bgImage, _, loreImage = EJ_GetInstanceInfo();
	self.instance.title:SetText(iname);
	self.instance.loreBG:SetTexture(loreImage);
	self.info.encounterTitle:SetText(iname);
	
	self.instance.loreScroll.child.lore:SetText(description);
	local loreHeight = self.instance.loreScroll.child.lore:GetHeight();
	self.instance.loreScroll.ScrollBar:SetValue(0);
	if loreHeight <= EJ_LORE_MAX_HEIGHT then
		self.instance.loreScroll.ScrollBar:Hide();
	else
		self.instance.loreScroll.ScrollBar:Show();
	end
	
	self.info.dungeonBG:SetTexture(bgImage);
	self.info.dungeonBG:Hide();
	
	local bossIndex = 1;
	local name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
	local bossButton;
	while bossID do
		bossButton = _G["EncounterJournalBossButton"..bossIndex];
		if not bossButton then -- create a new header;
			bossButton = CreateFrame("BUTTON", "EncounterJournalBossButton"..bossIndex, EncounterJournal.encounter.infoFrame, "EncounterBossButtonTemplate");
			if bossIndex > 1 then
				bossButton:SetPoint("TOPLEFT", _G["EncounterJournalBossButton"..(bossIndex-1)], "BOTTOMLEFT", 0, -15);
			else
				bossButton:SetPoint("TOPLEFT", EncounterJournal.encounter.infoFrame, "TOPLEFT", 0, -10);
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
		
		bossIndex = bossIndex + 1;
		name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex);
	end
	
	--handle typeHeader
	
	self.instance:Show();
	
	if not noButton then
		local buttonData = {
			name = iname,
			OnClick = EJNAV_RefreshInstance,
			listFunc = EJNAV_ListEncounter
		}
		NavBar_AddButton(EncounterJournal.navBar, buttonData);
	end
end


function EncounterJournal_DisplayEncounter(encounterID, noButton)
	local self = EncounterJournal.encounter;
	EncounterJournal.encounter.model:Show();
	
	local ename, description, _, rootSectionID = EJ_GetEncounterInfo(encounterID);
	EncounterJournal.encounterID = encounterID;
	EJ_SelectEncounter(encounterID);
	EncounterJournal_LootUpdate();
	EncounterJournal_ClearDetails();
	
	self.info.encounterTitle:SetText(ename);
		
	self.infoFrame.description:SetText(description);
	self.infoFrame.description:SetWidth(self.infoFrame:GetWidth() -5);
	self.infoFrame.encounterID = encounterID;
	self.infoFrame.rootSectionID = rootSectionID;
	self.infoFrame.expanded = false;
	
	self.info.dungeonBG:Show();
	
	-- Setup Creatures
	local id, name, displayInfo, iconImage;
	for i=1,MAX_CREATURES_PER_ENCOUNTER do 
		id, name, description, displayInfo, iconImage = EJ_GetCreatureInfo(i);
		
		local button = self["creatureButton"..i];
		if id then
			SetPortraitTexture(button.creature, displayInfo);
			button.name = name;
			button.id = id;
			button.description = description;
			button.displayInfo = displayInfo;
			button:Show();
		end
		
		if i == 1 then
			EncounterJournal_DisplayCreature(button);
		end
	end
	
	EncounterJournal_ToggleHeaders(self.infoFrame)
	self:Show();
	
	if not noButton then
		local buttonData = {
			name = ename,
			OnClick = EJNAV_RefreshEncounter,
		}
		NavBar_AddButton(EncounterJournal.navBar, buttonData);
	end
end


function EncounterJournal_DisplayCreature(self)
	if EncounterJournal.encounter.shownCreatureButton then
		EncounterJournal.encounter.shownCreatureButton:Enable();
	end
	
	if EncounterJournal.ceatureDisplayID == self.displayInfo then
		--Don't refresh the same model
	elseif self.displayInfo then
		EncounterJournal.encounter.model:SetDisplayInfo(self.displayInfo);
		EncounterJournal.ceatureDisplayID = self.displayInfo;
	end
		
	EncounterJournal.encounter.model.imageTitle:SetText(self.name);
	self:Disable();
	EncounterJournal.encounter.shownCreatureButton = self;
end


local toggleTempList = {};
local headerCount = 0;
function EncounterJournal_ToggleHeaders(self, doNotShift)
	local numAdded = 0
	local infoHeader, parentID, _;
	local hWidth = self:GetWidth();
	local nextSectionID;
	local topLevelSection = false;
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
	
	
	local freeHeaders = EncounterJournal.encounter.freeHeaders;
	local usedHeaders = EncounterJournal.encounter.usedHeaders;
	
	self.expanded = not self.expanded;
	local hideHeaders = not self.expanded;
	if hideHeaders then
		-- This can only happen for buttons
		self.button.expandedIcon:SetText("+");
		self.description:Hide();
		self.descriptionBG:Hide();
		self.descriptionBGBottom:Hide();
		
		EncounterJournal_ClearChildHeaders(self);
	else
		if strlen(self.description:GetText() or "") > 0 then
			self.description:Show();
			if self.button then
				self.descriptionBG:Show();
				self.descriptionBGBottom:Show();
				self.button.expandedIcon:SetText("-");
			end
		elseif self.button then
			self.description:Hide();
			self.descriptionBG:Hide();
			self.descriptionBGBottom:Hide();
			self.button.expandedIcon:SetText("-");
		end
	
		-- Get Section Info
		local listEnd  = #usedHeaders;
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
			usedHeaders[1]:SetPoint("TOPRIGHT", 0 , -8 - self.description:GetHeight() - SECTION_BUTTON_OFFSET);
		end
	end
	
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
	local usedHeaders = EncounterJournal.encounter.usedHeaders;
	for _, section in pairs(usedHeaders) do
		if section.myID == sectionID then
			section.cbCount = 0;
			section.flashAnim:Play();
			section:SetScript("OnUpdate", EncounterJournal_FocusSectionCallback);
			return;
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
	
	EncounterJournal.encounter.info.lootScroll.scrollBar:SetValue(0);
	EncounterJournal.encounter.info.detailsScroll.ScrollBar:SetValue(0);
	
	local freeHeaders = EncounterJournal.encounter.freeHeaders;
	local usedHeaders = EncounterJournal.encounter.usedHeaders;
	
	for key,used in pairs(usedHeaders) do
		used:Hide();
		usedHeaders[key] = nil;
		freeHeaders[#freeHeaders+1] = used;
	end
	
	for i=1,MAX_CREATURES_PER_ENCOUNTER do 
		EncounterJournal.encounter["creatureButton"..i]:Hide();
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


function EncounterJournal_TabClicked(self, button)
	local tabType = self:GetID();
	local info = EncounterJournal.encounter.info;
	info.tab = tabType;
	for key, data in pairs(EJ_Tabs) do 
		if key == tabType then
			info[data.frame]:Show();
			info[data.button]:Disable();
		else
			info[data.frame]:Hide();
			info[data.button]:Enable();
		end
	end
	PlaySound("igAbiliityPageTurn");
end


function EncounterJournal_LootCallback(itemID)
	local scrollFrame = EncounterJournal.encounter.info.lootScroll;
	
	for i,item in pairs(scrollFrame.buttons) do
		if item.itemID == itemID then
			local name, icon, slot, armorType, itemID, _, encounterID = EJ_GetLootInfoByIndex(item.index);
			item.name:SetText(name);
			item.icon:SetTexture(icon);
			item.slot:SetText(slot);
			item.boss:SetFormattedText(BOSS_INFO_STRING, EJ_GetEncounterInfo(encounterID));
			item.armorType:SetText(armorType);
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
				GameTooltip:SetItemByID(itemID);
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
			ShoppingTooltip3:Hide();
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


function EncounterJournal_SetFlagIcon(texture, index)
	local iconSize = 32;
	local columns = 256/iconSize;
	local rows = 64/iconSize;

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
	local id, stype, _, instanceID, encounterID  = EJ_GetSearchResult(index);
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
	return name, icon, path, typeText, displayInfo, itemID, stype;
end


function EncounterJournal_SelectSearch(index)
	local _;
	local id, stype, difficulty, instanceID, encounterID = EJ_GetSearchResult(index);
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
	
	EncounterJournal_OpenJournal(difficulty, instanceID, encounterID, sectionID, creatureID, itemID);
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
			local name, icon, path, typeText, displayInfo, itemID, stype = EncounterJournal_GetSearchDisplay(index);
			if stype == EJ_STYPE_INSTANCE then
				result.icon:SetTexCoord(0.16796875, 0.51171875, 0.03125, 0.71875);
			else
				result.icon:SetTexCoord(0, 1, 0, 1);
			end
			
			result.name:SetText(name);
			result.resultType:SetText(typeText);
			result.path:SetText(path);
			result.icon:SetTexture(icon);
			result.itemID = itemID;
			if displayInfo and displayInfo > 0 then
				SetPortraitTexture(result.icon, displayInfo);
			end
			result:SetID(index);
			result:Show();
			
			if result.showingTooltip then
				if itemID then
					GameTooltip:SetOwner(result, "ANCHOR_RIGHT");
					GameTooltip:SetItemByID(itemID);
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
	local text = self:GetText();
	EncounterJournal_HideSearchPreview();
		
	if strlen(text) < EJ_MIN_CHARACTER_SEARCH or text == SEARCH then
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
				local name, icon, path, typeText, displayInfo, itemID = EncounterJournal_GetSearchDisplay(index);
				button.name:SetText(name);
				button.icon:SetTexture(icon);
				button.itemID = itemID;
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


function EncounterJournal_OpenJournalLink(tag, jtype, id, difficulty)
	jtype = tonumber(jtype);
	id = tonumber(id);
	difficulty = tonumber(difficulty);
	local instanceID, encounterID, sectionID, tierIndex = EJ_HandleLinkPath(jtype, id);
	EncounterJournal_OpenJournal(difficulty, instanceID, encounterID, sectionID, nil, nil, tierIndex);
end


function EncounterJournal_OpenJournal(difficulty, instanceID, encounterID, sectionID, creatureID, itemID, tierIndex)
	ShowUIPanel(EncounterJournal);
	if instanceID then
		NavBar_Reset(EncounterJournal.navBar);
		EncounterJournal_DisplayInstance(instanceID);
		EJ_SetDifficulty(difficulty);
		if encounterID then
			if sectionID then
				EncounterJournal.encounter.info.bossTab:Click();
				local sectionPath = {EJ_GetSectionPath(sectionID)};
				for _, id in pairs(sectionPath) do
					EJ_section_openTable[id] = true;
				end
			end
			
			
			EncounterJournal_DisplayEncounter(encounterID);
			if sectionID then
				EncounterJournal_FocusSection(sectionID);
			elseif itemID then
				EncounterJournal.encounter.info.lootTab:Click();
			end
			
			
			if creatureID then
				for i=1,MAX_CREATURES_PER_ENCOUNTER do
					local button = EncounterJournal.encounter["creatureButton"..i];
					if button and button:IsShown() and button.id == creatureID then
						EncounterJournal_DisplayCreature(button);
					end
				end
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
	local diffList = EJ_DIFF_DUNGEON_TBL;
	if EJ_InstanceIsRaid() then
		diffList = EJ_DIFF_RAID_TBL;
	end
	
	local info = UIDropDownMenu_CreateInfo();
	for i=1,#diffList do
		local entry = diffList[i];
		if EJ_IsValidInstanceDifficulty(entry.difficultyID) then
			info.func = EncounterJournal_SelectDifficulty;
			info.text = string.format(ENCOUNTER_JOURNAL_DIFF_TEXT, entry.size, entry.prefix);
			info.arg1 = entry.enumValue;
			info.checked = currDifficulty == entry.enumValue;
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
		_, name = GetSpecializationInfoByID(specID)
	elseif (classID > 0) then
		name = GetClassInfoByID(classID);
	end
	
	if name then
		EncounterJournal.encounter.info.lootScroll.classClearFilter.text:SetText(string.format(EJ_CLASS_FILTER, name));
		EncounterJournal.encounter.info.lootScroll.classClearFilter:Show();
		EncounterJournal.encounter.info.lootScroll:SetHeight(360);
	else
		EncounterJournal.encounter.info.lootScroll.classClearFilter:Hide();
		EncounterJournal.encounter.info.lootScroll:SetHeight(384);
	end
end

local CLASS_DROPDOWN = 1;
function EncounterJournal_InitLootFilter(self, level)
	local filterClassID, filterSpecID = EJ_GetLootFilter();
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
			local specID, specName = GetSpecializationInfoForClassID(classID, i);
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
	local showRaid = EncounterJournal.instanceSelect.raidsTab:IsEnabled() == nil;
	local instanceID = EJ_GetInstanceByIndex(index, showRaid);
	EncounterJournal_DisplayInstance(instanceID);
end


function EJNAV_ListInstance(self, index)
	--local navBar = self:GetParent();
	local showRaid = EncounterJournal.instanceSelect.raidsTab:IsEnabled() == nil;
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
