
--Global Strings
ENCOUNTER = "Encounter"
ENCOUNTER_BOSSED_HEADER = "Dungeon Encounters"
ENCOUNTER_BOSS_LOOT_HEADER = "Encounter Loot"
ENCOUNTER_DUNGEON_LOOT_HEADER = "Dungeon Loot"
ENCOUNTER_JOURNAL = "Encounter Journal"


--FILE CONSTANTS
local HEADER_INDENT = 15;
local MAX_CREATURES_PER_ENCOUNTER = 6;

local SECTION_BUTTON_OFFSET = -6;
local SECTION_DESCRIPTION_OFFSET = -15;


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
	
	
	UIDropDownMenu_SetWidth(self.tempDD, 170);
	UIDropDownMenu_SetText(self.tempDD, "Pick A Boss");
	UIDropDownMenu_JustifyText(self.tempDD, "LEFT");
	UIDropDownMenu_Initialize(self.tempDD, EncounterJournal_TempDD_Init);
	UIDropDownMenu_DisableDropDown(self.tempDD);
	
	self.encounter.info.bossTab:Click();
	
	self.encounter.info.lootScroll.update = EncounterJournal_LootUpdate;
	self.encounter.info.lootScroll.scrollBar.doNotHide = true;
	HybridScrollFrame_CreateButtons(self.encounter.info.lootScroll, "EncounterItemTemplate", 0, 0);
	
	EncounterJournal.isHeroic = false;
	EncounterJournal.is10Man = true;
	EJ_SetDifficulty(EncounterJournal.isHeroic, EncounterJournal.is10Man);
end


function EncounterJournal_OnShow(self)
	--PVPMicroButton_SetPushed();
	--UpdateMicroButtons();
	PlaySound("igCharacterInfoOpen");
	
	
	UIDropDownMenu_SetText(EncounterJournal.tierDropDown, "Pick a Dungeon");
	EncounterJournal_TierDropDown_Select( nil, 71, name)
	EncounterJournal_TempDD_Select( nil, 132, test)
end


function EncounterJournal_OnHide(self)
	--PVPMicroButton_SetNormal();
	--UpdateMicroButtons();
	PlaySound("igCharacterInfoClose");
end


function EncounterJournal_OnEvent(self, event, ...)
	if  event == "EJ_LOOT_DATA_RECIEVED" then
		EncounterJournal_LootUpdate();
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
	
	local name, description = EJ_GetInstanceInfo();
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
			button.description = description;
			button.displayInfo = displayInfo;
			button:Show();
		end
		
		if i == 1 then
			EncounterJournal_DisplayCreature(button)
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
		self.description:SetWidth(self:GetWidth() -10);
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
end


function EncounterJournal_TierDropDown_Select(self, instanceID, name)
	EncounterJournal_DisplayInstance(EncounterJournal.encounter, instanceID);
	UIDropDownMenu_EnableDropDown(EncounterJournal.tempDD);
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
			local name, icon, slot, armorType, itemID = EJ_GetLootInfo(index);
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
		
	-- update tooltip
	if ( scrollFrame.activeButton ) then
		GuildPerksButton_OnEnter(scrollFrame.activeButton);
	end
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


function EncounterJournal_Refresh(self, value)
	EJ_SetDifficulty(EncounterJournal.isHeroic, EncounterJournal.is10Man);
	EncounterJournal_LootUpdate();
	
	if EncounterJournal.encounterID then
		EncounterJournal_DisplayEncounter(EncounterJournal.encounter, EncounterJournal.encounterID)
	elseif EncounterJournal.instanceID then
		EncounterJournal_DisplayInstance(EncounterJournal.encounter, EncounterJournal.instanceID);
	end
end


function EncounterJournal_ShowFullSearch(self, value)

end


function EncounterJournal_OnSearchTextChanged(self, value)

end




------------------------------------------------------------
-----------------------API FUNCTIONS------------------------
-----------------------API FUNCTIONS------------------------
------------------------------------------------------------


function EncounterJournal_GetEncounterInfo(encounterID)
	local title = "Mr. Forgemaster Throngus"
	local displayId = 33429
	local bgImage = "Interface\\EncounterJournal\\UI-EJ-BACKGROUND-Default"
	local numHeaders = 4
	local description = "Forgemaster Throngus is a baddass."
	
	return title, description, displayId, bgImage, numHeaders;
end

function EncounterJournal_GetHeaderInfo(parentId, index)
	local numHeaders = 3 
	local description = "Forgemaster Throngus is a baddass."
	local abilityIcon = "Interface\\Icons\\UI-EJ-PortraitIcon"
	local myID = index + parentId*10
	local title = "ID: "..myID
	
	return myID, title, abilityIcon, description, numHeaders;
end

function EncounterJournal_GetHeaderInfoByID(myID)
	local title = "Ability "..myID
	local numHeaders = 3 
	local description = "This is Ability"..myID
	description = description..description..description..description..description..description..description..description
	local abilityIcon = "Interface\\Icons\\UI-EJ-PortraitIcon"
	return title, abilityIcon, description, numHeaders;
end



function EncounterJournal_TempDD_Select(self, encounterID, name)
	UIDropDownMenu_SetText(EncounterJournal.tempDD, name);
	EncounterJournal_DisplayEncounter(EncounterJournal.encounter, encounterID)
end



function EncounterJournal_TempDD_Init()
	local info = UIDropDownMenu_CreateInfo();
	--This temporarily list all bosses
	local index = 1;
	local name, description, bossID = EJ_GetEncounterInfoByIndex(index);
	
	while (bossID and index < 25) do
		info.text = name;
		info.tooltipTitle = name;
		info.tooltipText = description;
		info.arg1 = bossID;
		info.arg2 = name;
		info.notCheckable = true;
		info.func = 	EncounterJournal_TempDD_Select;
		UIDropDownMenu_AddButton(info);
		
		index = index + 1;
		name, description, bossID = EJ_GetEncounterInfoByIndex(index);
	end
end 



