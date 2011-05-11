
--Global Strings
ENCOUNTER = "Encounter"
ENCOUNTER_BOSSED_HEADER = "Dungeon Encounters"
ENCOUNTER_BOSS_LOOT_HEADER = "Encounter Loot"
ENCOUNTER_DUNGEON_LOOT_HEADER = "Dungeon Loot"
ENCOUNTER_JOURNAL = "Encounter Journal"
ENCOUNTER_JOURNAL_SEARCH_RESULTS = 'Search Results for \"%s\"(%d)'
ENCOUNTER_JOURNAL_SHOW_SEARCH_RESULTS = 'Show All %d Results'
ENCOUNTER_JOURNAL_INSTANCE = 'Dungeon';
ENCOUNTER_JOURNAL_ENCOUNTER = 'Boss';
ENCOUNTER_JOURNAL_ENCOUNTER_ADD = 'Add';
ENCOUNTER_JOURNAL_ABILITY = 'Ability';
ENCOUNTER_JOURNAL_ITEM = 'Item';

--LOCALIZED CONSTANTS
EJ_MIN_CHARACTER_SEARCH = 3;


--FILE CONSTANTS
local HEADER_INDENT = 15;
local MAX_CREATURES_PER_ENCOUNTER = 6;

local SECTION_BUTTON_OFFSET = -6;
local SECTION_DESCRIPTION_OFFSET = -15;


local EJ_STYPE_ITEM = 0;
local EJ_STYPE_ENCOUNTER = 1;
local EJ_STYPE_CREATURE = 2;
local EJ_STYPE_SECTION = 3;
local EJ_STYPE_INSTANCE = 4;

local EJ_Tabs = {};
EJ_Tabs[1] = {frame="detailsScroll", button="bossTab"};
EJ_Tabs[2] = {frame="lootScroll", button="lootTab"};



function EncounterJournal_OnLoad(self)
	EncounterJournalTitleText:SetText(ENCOUNTER_JOURNAL);
	SetPortraitToTexture(EncounterJournalPortrait,"Interface\\EncounterJournal\\UI-EJ-PortraitIcon");
	self:RegisterEvent("EJ_LOOT_DATA_RECIEVED");
	
	self.encounter.freeHeaders = {};
	self.encounter.usedHeaders = {};
	
	self.encounter.infoFrame = self.encounter.info.detailsScroll.child;
	--self.encounter.scrollFrame.stepSize = 12;
	
	
	UIDropDownMenu_SetWidth(self.tierDropDown, 170);
	UIDropDownMenu_SetText(self.tierDropDown, "Pick A Dungeon");
	UIDropDownMenu_JustifyText(self.tierDropDown, "LEFT");
	UIDropDownMenu_Initialize(self.tierDropDown, EncounterJournal_TierDropDown_Init);
	
	
	self.encounter.info.bossTab:Click();
	
	self.encounter.info.lootScroll.update = EncounterJournal_LootUpdate;
	self.encounter.info.lootScroll.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.encounter.info.lootScroll, "EncounterItemTemplate", 0, 0);
	
	
	self.searchResults.scrollFrame.update = EncounterJournal_SearchUpdate;
	self.searchResults.scrollFrame.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.searchResults.scrollFrame, "EncounterSearchLGTemplate", 0, 0);
	
	EncounterJournal.isHeroic = false;
	EncounterJournal.is10Man = true;
	EJ_SetDifficulty(EncounterJournal.isHeroic, EncounterJournal.is10Man);
	
	EncounterJournal.searchBox.oldEditLost = EncounterJournal.searchBox:GetScript("OnEditFocusLost");
	EncounterJournal.searchBox:SetScript("OnEditFocusLost", function(self) self:oldEditLost(); EncounterJournal_HideSearchPreview(); end);
end


function EncounterJournal_OnShow(self)
	--PVPMicroButton_SetPushed();
	--UpdateMicroButtons();
	PlaySound("igCharacterInfoOpen");
	
	
	UIDropDownMenu_SetText(EncounterJournal.tierDropDown, "Pick a Dungeon");
	EncounterJournal_TierDropDown_Select( nil, 71, name)
end


function EncounterJournal_OnHide(self)
	--PVPMicroButton_SetNormal();
	--UpdateMicroButtons();
	PlaySound("igCharacterInfoClose");
end


function EncounterJournal_OnEvent(self, event, ...)
	if  event == "EJ_LOOT_DATA_RECIEVED" then
		EncounterJournal_LootUpdate();
		EncounterJournal_SearchUpdate();
	end
end


function EncounterJournal_DisplayInstance(self, instanceID)
	EncounterJournal.instanceID = instanceID;
	EncounterJournal.encounterID = nil;
	EJ_SelectInstance(instanceID);
	EncounterJournal_LootUpdate();
	EncounterJournal_ClearDetails()
	
	if EJ_InstanceIsRaid() then
		self.info.diff10man:Show();
		self.info.diff25man:Show();
	else
		self.info.diff10man:Hide();
		self.info.diff25man:Hide();
	end
	
	local name, description, bgImage = EJ_GetInstanceInfo();
	self.bgLeft:SetTexture(bgImage);
	self.instance.title:SetText(name);
	self.info.encounterTitle:SetText(name);
	self.instance.description:SetText(description);
	
	local bossIndex = 1;
	local name, description, bossID = EJ_GetEncounterInfoByIndex(bossIndex);
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
		
		bossButton:SetText(name);
		bossButton:Show();
		bossButton.encounterID = bossID;
		--Use the boss' first creature as the button icon
		local _, _, _, _, bossImage = EJ_GetCreatureInfo(1, bossID);
		bossImage = bossImage or "Interface\\EncounterJournal\\UI-EJ-BOSS-Default";
		bossButton.creature:SetTexture(bossImage);
		
		bossIndex = bossIndex + 1;
		name, description, bossID = EJ_GetEncounterInfoByIndex(bossIndex);
	end
	
	--handle typeHeader
	self.instance:Show();
end


function EncounterJournal_DisplayEncounter(self, encounterID)
	local name, description, _, rootSectionID = EJ_GetEncounterInfo(encounterID);
	EncounterJournal.encounterID = encounterID;
	EJ_SelectEncounter(encounterID);
	EncounterJournal_LootUpdate();
	EncounterJournal_ClearDetails();
	
	self.info.encounterTitle:SetText(name);
		
	self.infoFrame.description:SetText(description);
	self.infoFrame.description:SetWidth(self.infoFrame:GetWidth() -5);
	self.infoFrame.encounterID = encounterID;
	self.infoFrame.rootSectionID = rootSectionID;
	self.infoFrame.expanded = false;
	
	-- Setup Creatures
	local id, displayInfo, iconImage;
	for i=1,MAX_CREATURES_PER_ENCOUNTER do 
		id, name, description, displayInfo, iconImage = EJ_GetCreatureInfo(i);
		
		local button = self["creatureButton"..i];
		if id then
			iconImage = iconImage or "Interface\\EncounterJournal\\UI-EJ-BOSS-Default";
			button.creature:SetTexture(iconImage);
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
end


function EncounterJournal_DisplayCreature(self)
	if EncounterJournal.encounter.shownCreatureButton then
		EncounterJournal.encounter.shownCreatureButton:Enable();
	end
	
	if self.displayInfo then
		EncounterJournal.encounter.model.imageTitle:SetText(self.name);
		EncounterJournal.encounter.model:SetDisplayInfo(self.displayInfo);
		EncounterJournal.encounter.model:Show();
	end
	
	self:Disable();
	EncounterJournal.encounter.shownCreatureButton = self;
end


function EncounterJournal_ToggleHeaders(self)
	local infoHeader, lastHeader, parentID, _;
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
		if self.button then
			self.button.expandedIcon:SetText("+");
			
			self.description:Hide();
			self.descriptionBG:Hide();
			self.descriptionBGBottom:Hide();
		end
		
		for key,used in pairs(usedHeaders) do
			if used.parentID == self.myID then
				if used.expanded then
					EncounterJournal_ToggleHeaders(used)
				end
				used.anchorChild = nil;
				used:Hide();
				usedHeaders[key] = nil;
				freeHeaders[#freeHeaders+1] = used;
			end
		end
		
		if self.anchorChild then
			self.anchorChild:ClearAllPoints();
			self.anchorChild:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0 , SECTION_BUTTON_OFFSET);
		end
	else
		if self.button then
			self.button.expandedIcon:SetText("-");
			if strlen(self.description:GetText() or "") > 0 then
				self.description:Show();
				self.descriptionBG:Show();
				self.descriptionBGBottom:Show();
			else
				self.description:Hide();
				self.descriptionBG:Hide();
				self.descriptionBGBottom:Hide();
			end
		end
		
		
		lastHeader = nil;
		-- Get Section Info
		while nextSectionID do
			local title, description, headerType, abilityIcon, displayInfo, siblingID, _, fileredByDifficulty, flag1, flag2, flag3, flag4 = EJ_GetSectionInfo(nextSectionID);
		
			if not title then
				break;
			elseif not fileredByDifficulty then --ignore all sections that should not be shown with our current difficulty settings		
				if #freeHeaders == 0 then -- create a new header;
					infoHeader = CreateFrame("FRAME", "EncounterJournalInfoHeader"..(#freeHeaders+#usedHeaders), EncounterJournal.encounter.infoFrame, "EncounterInfoTemplate");
					--print("Creating: "..(#freeHeaders+#usedHeaders));
				else
					infoHeader = freeHeaders[#freeHeaders];
					freeHeaders[#freeHeaders] = nil;
				end
				usedHeaders[#usedHeaders+1] = infoHeader;
				
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
					SetPortraitTexture(infoHeader.button.portraitIcon, displayInfo);
					infoHeader.button.portraitIcon:Show();
					textLeftAnchor = infoHeader.button.portraitIcon;
					infoHeader.button.abilityIcon:Hide();
				else
					infoHeader.button.portraitIcon:Hide();
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
					EncounterJournal_SetFlagIcon(infoHeader.button.icon1, flag1);
					if flag2 then
						textRightAnchor = infoHeader.button.icon2;
						infoHeader.button.icon2:Show();
						EncounterJournal_SetFlagIcon(infoHeader.button.icon2, flag2);
						if flag3 then
							textRightAnchor = infoHeader.button.icon3;
							infoHeader.button.icon3:Show();
							EncounterJournal_SetFlagIcon(infoHeader.button.icon3, flag3);
							if flag4 then
								textRightAnchor = infoHeader.button.icon4;
								infoHeader.button.icon4:Show();
								EncounterJournal_SetFlagIcon(infoHeader.button.icon4, flag4);
							end
						end
					end
				end
				if textRightAnchor then
					infoHeader.button.title:SetPoint("RIGHT", textRightAnchor, "LEFT", -5, 0);
				else
					infoHeader.button.title:SetPoint("RIGHT", infoHeader.button, "RIGHT", -5, 0);
				end
				
				--SetupAnchors
				infoHeader.anchorChild = nil;
				if not lastHeader then
					if self.description:IsShown() then
						infoHeader:ClearAllPoints();
						infoHeader:SetPoint("TOP", self.description, "BOTTOM", 0 , SECTION_DESCRIPTION_OFFSET);
						infoHeader:SetPoint("RIGHT", self, "RIGHT", 0 , 0);
					else
						infoHeader:ClearAllPoints();
						infoHeader:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0 , SECTION_BUTTON_OFFSET);
					end
				else
					lastHeader.anchorChild = infoHeader;
					infoHeader:ClearAllPoints();
					infoHeader:SetPoint("TOPRIGHT", lastHeader, "BOTTOMRIGHT", 0 , SECTION_BUTTON_OFFSET);
				end
				
				infoHeader:SetWidth(hWidth);
				infoHeader:Show();
				lastHeader = infoHeader;
			end -- if not fileredByDifficulty
			nextSectionID = siblingID;
		end

		if self.anchorChild then
			if lastHeader then
				lastHeader.anchorChild = self.anchorChild;
				self.anchorChild:ClearAllPoints();
				self.anchorChild:SetPoint("TOPRIGHT", lastHeader, "BOTTOMRIGHT", 0 , SECTION_BUTTON_OFFSET);
			elseif self.description:IsShown() then
				self.anchorChild:ClearAllPoints();
				self.anchorChild:SetPoint("TOP", self.description, "BOTTOM", 0 , SECTION_DESCRIPTION_OFFSET);
				self.anchorChild:SetPoint("RIGHT", self, "RIGHT", 0 , 0);
			end
		end
		

		--Should be in the ccllapse
		--Hide remaining free Buttons
		for _,free in pairs(freeHeaders) do
			free:Hide();
		end
	end
	
	self:Show();
end


function EncounterJournal_ClearDetails()
	EncounterJournal.encounter.model:Hide();
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


function EncounterJournal_TierDropDown_Select(self, instanceID, name)
	EncounterJournal_DisplayInstance(EncounterJournal.encounter, instanceID);
	UIDropDownMenu_SetText(EncounterJournal.tierDropDown, name);
end


function EncounterJournal_TierDropDown_Init()
	local info = UIDropDownMenu_CreateInfo();
	--This temporarily list all bosses
	local index = 1;
	local instanceID, name, description = EJ_GetInstanceByIndex(index);
	
	while (instanceID) do
		info.text = name;
		info.tooltipTitle = name;
		info.tooltipText = description;
		info.arg1 = instanceID;
		info.arg2 = name;
		info.notCheckable = true;
		info.func = 	EncounterJournal_TierDropDown_Select;
		UIDropDownMenu_AddButton(info);
		
		index = index + 1;
		instanceID, name, description = EJ_GetInstanceByIndex(index);
	end
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
end


function EncounterJournal_LootUpdate()
	local scrollFrame = EncounterJournal.encounter.info.lootScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local items = scrollFrame.buttons;
	local item, index;
	
	local numLoot = EJ_GetNumLoot();
	
	for i = 1,#items do
		item = items[i];
		index = offset + i;
		if index <= numLoot then
			local name, icon, slot, armorType, itemID = EJ_GetLootInfoByIndex(index);
			item.name:SetText(name);
			item.icon:SetTexture(icon);
			item.slot:SetText(slot);
			item.armorType:SetText(armorType);
			item.itemID = itemID;
			item:Show();
			
			if item.showingTooltip then
				GameTooltip:SetItemByID(itemID);
			end
		else
			item:Hide();
		end
	end
	
	local totalHeight = numLoot * 51;
	HybridScrollFrame_Update(scrollFrame, totalHeight, 351);
end


function EncounterJournal_SetFlagIcon(texture, index)
	local iconSize = 32;
	local columns = 256/iconSize;
	local rows = 64/iconSize;

	l = mod(index, columns) / columns;
	r = l + (1/columns);
	t = floor(index/columns) / rows;
	b = t + (1/rows);
	texture:SetTexCoord(l,r,t,b);
end


function EncounterJournal_Refresh(self)
	EJ_SetDifficulty(EncounterJournal.isHeroic, EncounterJournal.is10Man);
	EncounterJournal_LootUpdate();
	
	if EncounterJournal.encounterID then
		EncounterJournal_DisplayEncounter(EncounterJournal.encounter, EncounterJournal.encounterID)
	elseif EncounterJournal.instanceID then
		EncounterJournal_DisplayInstance(EncounterJournal.encounter, EncounterJournal.instanceID);
	end
end


function EncounterJournal_GetSearchDisplay(index)
	local name, icon, path, typeText, displayInfo, itemID, _;
	local id, stype, instanceID, encounterID  = EJ_GetSearchResult(index);
	if stype == EJ_STYPE_INSTANCE then
		name, _, _, icon = EJ_GetInstanceInfo(id);
		typeText = ENCOUNTER_JOURNAL_INSTANCE;
	elseif stype == EJ_STYPE_ENCOUNTER then
		name = EJ_GetEncounterInfo(id);
		typeText = ENCOUNTER_JOURNAL_ENCOUNTER;
		path = EJ_GetInstanceInfo(instanceID);
		_, _, _, displayInfo = EJ_GetCreatureInfo(1, encounterID, instanceID);
	elseif stype == EJ_STYPE_SECTION then
		name, _, _, icon, displayInfo = EJ_GetSectionInfo(id)
		if displayInfo and displayInfo > 0 then
			typeText = ENCOUNTER_JOURNAL_ENCOUNTER_ADD;
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
			local cId, cName, _, cDisplayInfo = EJ_GetCreatureInfo(i, encounterID, instanceID);
			if cId == id then
				name = cName
				displayInfo = cDisplayInfo;
				break;
			end
		end
		typeText = ENCOUNTER_JOURNAL_ENCOUNTER
		path = EJ_GetInstanceInfo(instanceID).." | "..EJ_GetEncounterInfo(encounterID);
	end
	return name, icon, path, typeText, displayInfo, itemID, stype;
end


function EncounterJournal_SelectSearch(index)
	local _;
	local id, stype, instanceID, encounterID = EJ_GetSearchResult(index);
	if stype == EJ_STYPE_INSTANCE then
		instanceID = id;
	end
	
	if instanceID then
		EncounterJournal_DisplayInstance(EncounterJournal.encounter, instanceID);
	end
	
	if encounterID then
		EncounterJournal_DisplayEncounter(EncounterJournal.encounter, encounterID);
	end

	
	if stype == EJ_STYPE_ENCOUNTER then
	elseif stype == EJ_STYPE_SECTION then
		EncounterJournal.encounter.info.bossTab:Click();
	elseif stype == EJ_STYPE_ITEM then
		EncounterJournal.encounter.info.lootTab:Click();
	elseif stype == EJ_STYPE_CREATURE then
		for i=1,MAX_CREATURES_PER_ENCOUNTER do
			local button = EncounterJournal.encounter["creatureButton"..i];
			if button and button:IsShown() and button.id == id then
				EncounterJournal_DisplayCreature(button);
			end
		end
	end
	
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


function EncounterJournal_OnSearchTextChanged(self)
	local text = self:GetText();
	EncounterJournal_HideSearchPreview();
		
	if strlen(text) < EJ_MIN_CHARACTER_SEARCH or text == SEARCH then
		EJ_ClearSearch();
		EncounterJournal.searchResults:Hide();
		return;
	end
	EJ_SetSearch(text);
	
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


