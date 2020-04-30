function AddAutoCombatSpellToTooltip(tooltip, autoCombatSpell)
	local str;
	if (autoCombatSpell.icon) then
		str = CreateTextureMarkup(autoCombatSpell.icon, 64, 64, 16, 16, 0, 1, 0, 1, 0, 0);
	else
		str = "";
	end
	str = str .. " " .. autoCombatSpell.name;
	GameTooltip_AddColoredLine(tooltip, str, WHITE_FONT_COLOR);

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
		local primaryCurrency = C_Garrison.GetCurrencyTypes(GarrisonFollowerOptions[self.followerInfo.followerTypeID].garrisonType);
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(primaryCurrency);
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