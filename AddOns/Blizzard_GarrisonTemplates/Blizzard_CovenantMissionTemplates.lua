function AddAutoCombatSpellToTooltip(tooltip, autoCombatSpell)
	local str;
	if (autoCombatSpell.icon) then
		str = CreateTextureMarkup(autoCombatSpell.icon, 64, 64, 16, 16, 0, 1, 0, 1, 0, 0);
	else
		str = "";
	end
	str = str .. " " .. autoCombatSpell.name;
	GameTooltip_AddColoredLine(tooltip, str, WHITE_FONT_COLOR);
	GameTooltip_AddBlankLineToTooltip(tooltip);
	if autoCombatSpell.cooldown > 0 then
		GameTooltip_AddColoredLine(tooltip, COVENANT_MISSIONS_COOLDOWN:format(autoCombatSpell.cooldown), WHITE_FONT_COLOR);
	end

	local wrap = true;
	GameTooltip_AddNormalLine(tooltip, autoCombatSpell.description, wrap);
end

---------------------------------------------------------------------------------
-- Covenant Mission Page Enemy Frame
---------------------------------------------------------------------------------
CovenantMissionPageEnemyMixin = { }

function CovenantMissionPageEnemyMixin:OnEnter()
	if (#self.autoCombatSpells > 0) then
		GameTooltip:SetOwner(self, "ANCHOR_NONE");
		GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 0);
		GameTooltip_SetTitle(GameTooltip, self.Name:GetText());
		
		for i = 1, #self.autoCombatSpells do
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			AddAutoCombatSpellToTooltip(GameTooltip, self.autoCombatSpells[i])
		end
		GameTooltip:Show();
	end
end

function CovenantMissionPageEnemyMixin:OnLeave()
	GameTooltip_Hide();
end

---------------------------------------------------------------------------------
-- Autospell Ability Tooltip Handlers
---------------------------------------------------------------------------------

function CovenantMissionAutoSpellAbilityTemplate_OnEnter(self)
	if ( not self.info ) then
		return; 
	end

	GameTooltip:SetOwner(self, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", 0, 0);
	AddAutoCombatSpellToTooltip(GameTooltip, self.info);
	GameTooltip:Show();
end

function CovenantMissionAutoSpellAbilityTemplate_OnLeave()
	GameTooltip_Hide();
end

---------------------------------------------------------------------------------
-- Covenant Follower Tab Heal Button Handlers
---------------------------------------------------------------------------------

function CovenantMissionHealFollowerButton_OnClick(buttonFrame)
	local mainFrame = buttonFrame:GetParent();
	C_Garrison.RushHealFollower(mainFrame.followerID);
end

function CovenantMissionHealFollowerButton_OnEnter(buttonFrame)
	GameTooltip:SetOwner(buttonFrame, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPLEFT", buttonFrame, "BOTTOMRIGHT", 0, 0);
	GameTooltip_AddNormalLine(GameTooltip, buttonFrame.tooltip, wrap);
	GameTooltip:Show();
end

---------------------------------------------------------------------------------
-- Covenant Follower Tab Mixin
---------------------------------------------------------------------------------

CovenantFollowerTabMixin = {};

function CovenantFollowerTabMixin:OnLoad()
	self.abilitiesPool = CreateFramePool("FRAME", self.AbilitiesFrame, "CovenantMissionAutoSpellAbilityTemplate");
	self.statsPool = CreateFramePool("FRAME", self.StatsFrame, "CovenantStatLineTemplate");
end

function CovenantFollowerTabMixin:OnUpdate()
	local SECONDS_BETWEEN_UPDATE = 5;
	local currentTime = GetTime();
	if (self.lastUpdate and (currentTime - self.lastUpdate) > SECONDS_BETWEEN_UPDATE) then 
		self.followerInfo.autoCombatantStats = C_Garrison.GetFollowerAutoCombatStats(self.followerID);
		self:UpdateCombatantStats(self.followerInfo);
		self:UpdateHealCost();

		self.lastUpdate = GetTime();
	end
end

function CovenantFollowerTabMixin:UpdateValidSpellHighlightOnAbilityFrame()
end

function CovenantFollowerTabMixin:UpdateHealCost()	
	local followerStats = self.followerInfo.autoCombatantStats;
	self.HealFollowerButton.tooltip = nil;

	if not followerStats then
		self.HealFollowerButton:SetEnabled(false);
		return;
	end

	local buttonCost = ((followerStats.maxHealth - followerStats.currentHealth) / followerStats.maxHealth) * Constants.GarrisonConstsExposed.GARRISON_AUTO_COMBATANT_FULL_HEAL_COST;
	self.CostFrame.Cost:SetText(math.ceil(buttonCost));
	
	if (buttonCost == 0) then
		self.HealFollowerButton:SetEnabled(false);
		self.HealFollowerButton.tooltip = COVENANT_MISSIONS_HEAL_ERROR_FULL_HEALTH;
	else 
		local _, secondaryCurrency = C_Garrison.GetCurrencyTypes(GarrisonFollowerOptions[self.followerInfo.followerTypeID].garrisonType);
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(secondaryCurrency);
		if (buttonCost > currencyInfo.quantity) then 
			self.HealFollowerButton:SetEnabled(false);
			self.HealFollowerButton.tooltip = COVENANT_MISSIONS_HEAL_ERROR_RESOURCES;
		else
			self.HealFollowerButton:SetEnabled(true);
		end
	end
end

function CovenantFollowerTabMixin:SetupNewStatText(anchorFrame, leftText, rightText, additionalOffset)
	additionalOffset = additionalOffset or 0;

	local newFrame = self.statsPool:Acquire();
	newFrame.LeftString:SetText(leftText);
	newFrame.RightString:SetText(rightText);
	newFrame.layoutIndex = anchorFrame.layoutIndex + 1;
	newFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT", 0, -4 + additionalOffset);
	newFrame:Show();
	return newFrame;
end

function CovenantFollowerTabMixin:UpdateCombatantStats(followerInfo)
	self.statsPool:ReleaseAll();

	local anchorFrame = self.StatsFrame.StatsLabel;
	local autoCombatantStats = followerInfo.autoCombatantStats;
	
	if autoCombatantStats then
		--Level
		local newAnchorFrame = self:SetupNewStatText(anchorFrame, COVENANT_MISSIONS_LEVEL, followerInfo.level);
		
		--Health
		local healthColor = (autoCombatantStats.currentHealth == autoCombatantStats.maxHealth) and WHITE_FONT_COLOR or RED_FONT_COLOR;
		newAnchorFrame = self:SetupNewStatText(newAnchorFrame, COVENANT_MISSIONS_HEALTH, healthColor:WrapTextInColorCode(autoCombatantStats.currentHealth) .. "/" .. autoCombatantStats.maxHealth, -4);
		
		--Attack
		newAnchorFrame = self:SetupNewStatText(newAnchorFrame, COVENANT_MISSIONS_ATTACK, autoCombatantStats.attack);

		--Experience, hide if max level.
		if followerInfo.levelXP ~= 0 then
			newAnchorFrame = self:SetupNewStatText(newAnchorFrame, COVENANT_MISSIONS_XP_TO_LEVEL, followerInfo.levelXP);
		end

		self.StatsFrame.StatsLabel:Show();
		self.StatsFrame:Layout();
	else
		self.StatsFrame.StatsLabel:Hide();
	end
end

function CovenantFollowerTabMixin:UpdateAbilities(autoSpellInfo)
	local ABILITY_ICON_SIZE = 60; --The base frame we're reusing here as a pool is too small.
	local anchorFrame;

	self.AbilitiesLabel:Hide();
	self.abilitiesPool:ReleaseAll();

	for i, autoSpell in ipairs(autoSpellInfo) do
		local abilityFrame = self.abilitiesPool:Acquire();
		abilityFrame:SetSize(ABILITY_ICON_SIZE, ABILITY_ICON_SIZE); 
		abilityFrame.Icon:SetSize(ABILITY_ICON_SIZE, ABILITY_ICON_SIZE);
		abilityFrame.info = autoSpell;
		abilityFrame.info.showCounters = false;
		abilityFrame.Icon:SetTexture(autoSpell.icon);
		abilityFrame.layoutIndex = i;
		abilityFrame.Border:Hide();
		abilityFrame:Show();

		anchorFrame = abilityFrame;
	end

	if anchorFrame then
		self.AbilitiesLabel:Show();
		self.AbilitiesLabel:SetPoint("TOPLEFT", self.StatsFrame, "BOTTOMLEFT", 0, -18);
	end
		
	self.AbilitiesFrame:Layout();
end

function CovenantFollowerTabMixin:ShowFollower(followerID, followerList)

	local followerInfo = C_Garrison.GetFollowerInfo(followerID);
	local autoSpellAbilities = C_Garrison.GetFollowerAutoCombatSpells(followerID);
	local autoCombatantStats = C_Garrison.GetFollowerAutoCombatStats(followerID);
	local missionFrame = self:GetParent();

	self.followerID = followerID;
	self.ModelCluster.followerID = followerID;

	self:ShowFollowerModel(followerInfo);
	if (not followerInfo) then
		followerInfo = { };
		followerInfo.followerTypeID = missionFrame:GetFollowerList().followerType;
		followerInfo.quality = 1;
		followerInfo.abilities = { };
		followerInfo.unlockableAbilities = { };
		followerInfo.equipment = { };
		followerInfo.unlockableEquipment = { };
		followerInfo.combatAllySpellIDs = { };
	end

	if not autoSpellAbilities then
		autoSpellAbilities = {};
	end

	followerInfo.autoCombatantStats = autoCombatantStats;
	followerInfo.autoSpellAbilities = autoSpellAbilities;
	self.followerInfo = followerInfo;

	self.Name:SetText(followerInfo.name);
	self.ClassSpec:SetText(followerInfo.className);

	--Add in stats: hp, power, level, experience.
	self:UpdateCombatantStats(followerInfo);

	--Add in ability icons
	self:UpdateAbilities(autoSpellAbilities);

	--Set cost of the heal, enable/disable the button accordingly. 
	self:UpdateHealCost();

	self.lastUpdate = GetTime();
end

---------------------------------------------------------------------------------
--- Covenant Mission List Mixin												  ---
---------------------------------------------------------------------------------

function CovenantMissionList_Sort(missionsList)
	local comparison = function(mission1, mission2)

		--Filter inProgress to the bottom unless they can be completed
		if mission1.canBeCompleted ~= mission2.canBeCompleted then
			return mission1.canBeCompleted;
		end

		if mission1.inProgress ~= mission2.inProgress then
			return not mission1.inProgress;
		end

		if ( mission1.level ~= mission2.level ) then
			return mission1.level > mission2.level;
		end

		if ( mission1.durationSeconds ~= mission2.durationSeconds ) then
			return mission1.durationSeconds < mission2.durationSeconds;
		end

		if ( mission1.isRare ~= mission2.isRare ) then
			return mission1.isRare;
		end

		return strcmputf8i(mission1.name, mission2.name) < 0;
	end

	table.sort(missionsList, comparison);
end

CovenantMissionListMixin = { }

function CovenantMissionListMixin:OnLoad()
	self.newMissionIDs = {};
	self.combinedMissions = {};
	self.listScroll:SetScript("OnMouseWheel", function(self, ...) HybridScrollFrame_OnMouseWheel(self, ...); GarrisonMissionList_UpdateMouseOverTooltip(self); end);
end

function CovenantMissionListMixin:OnUpdate()
	local timeNow = GetTime();
	for i = 1, #self.combinedMissions do
		if ( not self.combinedMissions[i].inProgress and self.combinedMissions[i].offerEndTime and self.combinedMissions[i].offerEndTime <= timeNow ) then
			self:UpdateMissions();
			break;
		end
	end

	self:Update();
end

function CovenantMissionListMixin:UpdateMissions()

	local inProgressMissions = {};
	local completedMissions = {};
	C_Garrison.GetInProgressMissions(inProgressMissions, self:GetMissionFrame().followerTypeID);
	completedMissions = C_Garrison.GetCompleteMissions(self:GetMissionFrame().followerTypeID);

	C_Garrison.GetAvailableMissions(self.combinedMissions, self:GetMissionFrame().followerTypeID);
	for i = 1, #inProgressMissions do
		for j = 1, #completedMissions  do
			if completedMissions[j].missionID == inProgressMissions[i].missionID then
				inProgressMissions[i].canBeCompleted = true;
			end
		end
		
		table.insert(self.combinedMissions, inProgressMissions[i]);
	end

	CovenantMissionList_Sort(self.combinedMissions);

	self:Update();
end

function CovenantMissionListMixin:Update()
	local missions = self.combinedMissions;
	local followerTypeID = self:GetMissionFrame().followerTypeID;
	local numMissions = missions and #missions or 0;
	local scrollFrame = self.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	if (numMissions == 0) then
		self.EmptyListString:Show();
	else
		self.EmptyListString:Hide();
	end

	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		if ( index <= numMissions) then
			local mission = missions[index];
			button.id = index;
			button.info = mission;
			button.Title:SetWidth(0);
			button.Title:SetText(mission.name);
			button.Level:SetText(mission.level);
			if ( mission.durationSeconds >= GARRISON_LONG_MISSION_TIME ) then
				local duration = format(GARRISON_LONG_MISSION_TIME_FORMAT, mission.duration);
				button.Summary:SetFormattedText(PARENS_TEMPLATE, duration);
			else
				button.Summary:SetFormattedText(PARENS_TEMPLATE, mission.duration);
			end
			if ( mission.locTextureKit ) then
				button.LocBG:Show();
				button.LocBG:SetAtlas(mission.locTextureKit.."-List");
			else
				button.LocBG:Hide();
			end
			if (mission.isRare) then
				button.RareOverlay:Show();
				button.RareText:Show();
				button.IconBG:SetVertexColor(0, 0.012, 0.291, 0.4)
			else
				button.RareOverlay:Hide();
				button.RareText:Hide();
				button.IconBG:SetVertexColor(0, 0, 0, 0.4)
			end
			local showingItemLevel = false;
			if ( GarrisonFollowerOptions[followerTypeID].showILevelOnMission and mission.isMaxLevel and mission.iLevel > 0 ) then
				button.ItemLevel:SetFormattedText(NUMBER_IN_PARENTHESES, mission.iLevel);
				button.ItemLevel:Show();
				showingItemLevel = true;
			else
				button.ItemLevel:Hide();
			end
			if ( showingItemLevel and mission.isRare ) then
				button.Level:SetPoint("CENTER", button, "TOPLEFT", 35, -22);
			else
				button.Level:SetPoint("CENTER", button, "TOPLEFT", 35, -36);
			end

			button:Enable();
			button.Overlay:Hide();

			if (mission.canBeCompleted) then
				button.Summary:SetText(YELLOW_FONT_COLOR_CODE..COMPLETE..FONT_COLOR_CODE_CLOSE);
			elseif (mission.inProgress) then
				button.Overlay:Show();
				button.Summary:SetText(mission.timeLeft.." "..RED_FONT_COLOR_CODE..GARRISON_MISSION_IN_PROGRESS..FONT_COLOR_CODE_CLOSE);
			end

			if ( button.Title:GetWidth() + button.Summary:GetWidth() + 8 < 655 - #mission.rewards * 65 ) then
				button.Title:SetPoint("LEFT", 165, 0);
				button.Summary:ClearAllPoints();
				button.Summary:SetPoint("BOTTOMLEFT", button.Title, "BOTTOMRIGHT", 8, 0);
			else
				button.Title:SetPoint("LEFT", 165, 10);
				button.Title:SetWidth(655 - #mission.rewards * 65);
				button.Summary:ClearAllPoints();
				button.Summary:SetPoint("TOPLEFT", button.Title, "BOTTOMLEFT", 0, -4);
			end

			button.MissionType:SetAtlas(mission.typeAtlas);
			button.MissionType:SetSize(75, 75);
			button.MissionType:SetPoint("TOPLEFT", 68, -2);

			GarrisonMissionButton_SetRewards(button, mission.rewards, #mission.rewards);
			button:Show();
		else
			button:Hide();
			button.info = nil;
		end
	end

	local totalHeight = numMissions * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
end

---------------------------------------------------------------------------------
--- Covenant Mission List Button Handlers									  ---
---------------------------------------------------------------------------------

function CovenantMissionButton_OnClick(self)
	local missionFrame = self:GetParent():GetParent():GetParent():GetParent():GetParent();
	if (self.info.canBeCompleted) then
		missionFrame:InitiateMissionCompletion(self.info);
	else
		missionFrame:OnClickMission(self.info);
	end
end

function CovenantMissionButton_OnEnter(self)

end

