
---------------------------------------------------------------------------------
--- Static Popups                                                             ---
---------------------------------------------------------------------------------

local warningIconText = "|T" .. STATICPOPUP_TEXTURE_ALERT .. ":15:15:0:-2|t";
StaticPopupDialogs["DANGEROUS_MISSIONS"] = {
	text = "",
	button1 = OKAY,
	button2 = CANCEL,
	OnShow = function(self)
		self.text:SetFormattedText(GARRISON_SHIPYARD_DANGEROUS_MISSION_WARNING, warningIconText, warningIconText);
	end,
	OnAccept = function(self)
		SetCVar("dangerousShipyardMissionWarningAlreadyShown", "1");
		self.data:OnClickStartMissionButtonConfirm();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

---------------------------------------------------------------------------------
--- Garrison Shipyard Mixin Functions                                         ---
---------------------------------------------------------------------------------

GARRISON_SHIP_OIL_CURRENCY = 1101;
GarrisonShipyardMission = {};

function GarrisonShipyardMission:OnLoadMainFrame()
	GarrisonMission.OnLoadMainFrame(self);

	self.BorderFrame.TitleText:SetText(GARRISON_SHIPYARD_TITLE);
	
	GarrisonFollowerList_OnLoad(self, self:GetFollowerType(), "GarrisonShipFollowerButtonTemplate", 12)

	self:UpdateCurrency();
	self.MissionComplete.pendingFogLift = {};
	
	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup == "Horde" ) then
		self.MissionTab.MissionPage.RewardsFrame.Chest:SetAtlas("GarrMission-HordeChest");
		self.MissionComplete.BonusRewards.ChestModel:SetDisplayInfo(54913);
		local dialogBorderFrame = self.MissionTab.MissionList.CompleteDialog.BorderFrame;
		dialogBorderFrame.Model:SetDisplayInfo(59175);
		dialogBorderFrame.Model:SetPosition(0.2, 1.15, -0.7);
	else
		local dialogBorderFrame = self.MissionTab.MissionList.CompleteDialog.BorderFrame;
		dialogBorderFrame.Model:SetDisplayInfo(58063);
		dialogBorderFrame.Model:SetPosition(0.2, .75, -0.7);
	end
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	--self:RegisterEvent("GARRISON_MISSION_STARTED");
	self:RegisterEvent("GARRISON_MISSION_FINISHED");
	--self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	--self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
end

function GarrisonShipyardMission:UpdateCurrency()
	local currencyName, amount, currencyTexture = GetCurrencyInfo(GARRISON_SHIP_OIL_CURRENCY);
	self.materialAmount = amount;
	amount = BreakUpLargeNumbers(amount)
	self.FollowerList.MaterialFrame.Materials:SetText(amount);
end

function GarrisonShipyardMission:SelectTab(id)
	GarrisonMission.SelectTab(self, id);
	if (id == 1) then
		self.BorderFrame.TitleText:SetText(GARRISON_SHIPYARD_TITLE);
	else
		self.BorderFrame.TitleText:SetText("");
	end
end

function GarrisonShipyardMission:OnClickMission(missionInfo)
	if (not GarrisonMission.OnClickMission(self, missionInfo)) then
		return;
	end
	
	--GarrisonShipyardMap_UpdateMissions();
	self.MissionTab.MissionList:Hide();
	self.MissionTab.MissionPage:Show();
	
	self:ShowMission(missionInfo);
	GarrisonFollowerList_UpdateFollowers(self.FollowerList);
end

function GarrisonShipyardMission:ShowMission(missionInfo)
	GarrisonMission.ShowMission(self, missionInfo);
	
	local frame = self.MissionTab.MissionPage;
	frame.Stage.Title:SetPoint("LEFT", frame.Stage.Header, "LEFT", 98, 0);
	frame.Stage.MissionEnvIcon:Hide();
	
	local typeAtlas = missionInfo.typePrefix .. "-Mission";
	frame.MissionType:SetAtlas(typeAtlas, true);
	
	frame.CostFrame.CostIcon:SetAtlas("ShipMission_CurrencyIcon-Oil", false);
end

function GarrisonShipyardMission:SetPartySize(frame, size, numEnemies)
	GarrisonMission.SetPartySize(self, frame, size, numEnemies);
	
	if ( size == 1 ) then
		frame.Followers[1]:SetPoint("TOPLEFT", 200, -206);
	elseif ( size == 2 ) then
		frame.Followers[1]:SetPoint("TOPLEFT", 116, -206);
	else
		frame.Followers[1]:SetPoint("TOPLEFT", 31, -206);
	end
end

function GarrisonShipyardMission:SetEnemies(frame, enemies, numFollowers)
	local numVisibleEnemies = GarrisonMission.SetEnemies(self, frame, enemies, numFollowers, 0);

	if ( numVisibleEnemies == 1 ) then
		frame.Enemy1:SetPoint("TOPLEFT", 200, -83);
	elseif ( numVisibleEnemies == 2 ) then
		frame.Enemy1:SetPoint("TOPLEFT", 116, -83);
	else
		frame.Enemy1:SetPoint("TOPLEFT", 31, -83);
	end
end

function GarrisonShipyardMission:UpdateMissionData(frame)
	GarrisonMission.UpdateMissionData(self, frame);
	frame.Stage.MissionEnv:Hide();
	
	GarrisonShipyardMissionPage_UpdatePortraitPulse(frame);
end

function GarrisonShipyardMission:SetEnemyPortrait(portraitFrame, enemy, eliteFrame, numMechs)
	local atlas = enemy.texPrefix .. "-Portrait";
	portraitFrame.Portrait:SetAtlas(atlas, true);
end

function GarrisonShipyardMission:SetFollowerPortrait(followerFrame, followerInfo, forMissionPage, listPortrait)
	local atlas = followerInfo.texPrefix;
	if (listPortrait) then
		atlas = atlas .. "-List";
	else
		atlas = atlas .. "-Portrait";
	end
	followerFrame.Portrait:SetAtlas(atlas, true);
end

function GarrisonShipyardMission:GetFollowerType()
	return LE_FOLLOWER_TYPE_SHIPYARD_6_2;
end

function GarrisonShipyardMission:OnClickStartMissionButton()
	local missionID = self.MissionTab.MissionPage.missionInfo.missionID;
	local _, _, _, successChance = C_Garrison.GetPartyMissionInfo(missionID);
	if (successChance < 100 and not GetCVarBool("dangerousShipyardMissionWarningAlreadyShown")) then
		StaticPopup_Show("DANGEROUS_MISSIONS", nil, nil, self);
	else
		self:OnClickStartMissionButtonConfirm();
	end
end

function GarrisonShipyardMission:OnClickStartMissionButtonConfirm()
	if (not GarrisonMission.OnClickStartMissionButton(self)) then
		return;
	end
end

function GarrisonShipyardMission:UpdateFollowerData()
	local followers = self.FollowerList.followers;
	local followersList = self.FollowerList.followersList;
	local numFollowers = #followersList;
	local scrollFrame = self.FollowerList.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;
	
	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		if ( index <= numFollowers) then
			local follower = followers[followersList[index]];
			button.isCollected = true;
			button.id = follower.followerID;
			button.info = follower;
			self:SetFollowerPortrait(button, follower, nil, true);
			button.BoatName:SetText(format(GARRISON_SHIPYARD_SHIP_NAME, follower.name));
			button.BoatType:SetText(follower.className);
			button.Status:SetText(follower.status);
			button.Selection:SetShown(button.id == self.selectedFollower);
			
			if (follower.quality == LE_ITEM_QUALITY_EPIC) then
				button.Quality:SetAtlas("ShipMission_BoatRarity-Epic", true);
			elseif (follower.quality == LE_ITEM_QUALITY_RARE) then
				button.Quality:SetAtlas("ShipMission_BoatRarity-Rare", true);
			else
				button.Quality:SetAtlas("ShipMission_BoatRarity-Uncommon", true);
			end
			
			if (follower.status) then
				button.BusyFrame:Show();
				button.BusyFrame.Texture:SetTexture(unpack(GARRISON_FOLLOWER_BUSY_COLOR));
			else
				button.BusyFrame:Hide();
			end
		
			local color = ITEM_QUALITY_COLORS[follower.quality];
			button.BoatName:SetTextColor(color.r, color.g, color.b);
			if (follower.xp == 0 or follower.levelXP == 0) then 
				button.XPBar:Hide();
			else
				button.XPBar:Show();
				button.XPBar:SetWidth((follower.xp/follower.levelXP) * 228);
			end

			GarrisonFollowerButton_UpdateCounters(self, button, follower, self.FollowerList.showCounters, self.lastUpdate);
		
			button:Show();
		else
			button:Hide();
		end
	end
	
	local totalHeight = numFollowers * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);

	self.lastUpdate = GetTime();
end

function GarrisonShipyardMission:AssignFollowerToMission(frame, info)
	if (not GarrisonMission.AssignFollowerToMission(self, frame, info)) then
		return;
	end
	
	self:SetFollowerPortrait(frame, info, nil, false);
	frame.Name:SetText(format(GARRISON_SHIPYARD_SHIP_NAME, info.name));
	frame.Name:Show();
end

function GarrisonShipyardMission:RemoveFollowerFromMission(frame, updateValues)
	GarrisonMission.RemoveFollowerFromMission(self, frame, updateValues);
	
	frame.Portrait:SetAtlas("ShipMission_FollowerBG", true);
	frame.Name:Hide();
end

function GarrisonShipyardFrame_ClearMouse()
	if ( GarrisonShipFollowerPlacer.info ) then
		GarrisonShipFollowerPlacer:Hide();
		GarrisonFollowerPlacerFrame:Hide();
		GarrisonShipFollowerPlacer.info = nil;
	end
end

function GarrisonShipyardMission:ClearMouse()
	GarrisonShipyardFrame_ClearMouse();
end

function GarrisonShipyardMission:UpdateMissions()
	GarrisonShipyardMap_UpdateMissions();
end

function GarrisonShipyardMission:CheckCompleteMissions(onShow)
	if (not GarrisonMission.CheckCompleteMissions(self, onShow)) then
		return;
	end
	
	-- preload one follower and one enemy model for the mission
	MissionCompletePreload_LoadMission(self, self.MissionComplete.completeMissions[1].missionID, true);
end

function GarrisonShipyardMission:MissionCompleteInitialize(missionList, index)
	if (not GarrisonMission.MissionCompleteInitialize(self, missionList, index)) then
		return;
	end
	
	local destroyAnim, destroySound, surviveAnim, surviveSound = C_Garrison.GetShipDeathAnimInfo();
	self.MissionComplete.destroyAnim = destroyAnim;
	self.MissionComplete.destroySound = destroySound;
	self.MissionComplete.surviveAnim = surviveAnim;
	self.MissionComplete.surviveSound = surviveSound;
end

function GarrisonShipyardMission:CloseMissionComplete()
	GarrisonMission.CloseMissionComplete(self);
	self:CheckPendingFogLift();
end

function GarrisonShipyardMission:CheckPendingFogLift()
	if (self.MissionTab.MissionList.CompleteDialog:IsShown() or self.MissionComplete:IsShown()) then
		return;
	end
	
	-- Check if we completed any missions that cause the fog to lift. If so, lift the fog
	for i=#self.MissionComplete.pendingFogLift, 1, -1 do
		local fogFrames = self.MissionTab.MissionList.FogFrames;
		for j=1, #fogFrames do
			if (self.MissionComplete.pendingFogLift[i] == fogFrames[j].offeredGarrMissionTextureID) then
				fogFrames[j].FogTexture:Hide();
				fogFrames[j].MapFogFadeOutAnim:Play();
				fogFrames[j].offeredGarrMissionTextureID = nil;
				
				table.remove(self.MissionComplete.pendingFogLift, i);
				break;
			end
		end
	end
end

function GarrisonShipyardMission:ResetMissionCompleteEncounter(encounter)
	encounter:Show();
	encounter.CheckFrame.SuccessAnim:Stop();
	encounter.CheckFrame.FailureAnim:Stop();
	encounter.CheckFrame.CrossLeft:SetAlpha(0);
	encounter.CheckFrame.CrossRight:SetAlpha(0);
	encounter.CheckFrame.CheckMark:SetAlpha(0);
	encounter.CheckFrame.CheckMarkGlow:SetAlpha(0);
	encounter.CheckFrame.CheckMarkLeft:SetAlpha(0);
	encounter.CheckFrame.CheckMarkRight:SetAlpha(0);
	encounter.CheckFrame.CheckSmoke:SetAlpha(0);
	encounter.Name:Hide();
end


---------------------------------------------------------------------------------
--- Garrison Shipyard Mission Complete Mixin Functions                        ---
---------------------------------------------------------------------------------

GarrisonShipyardMissionComplete = {};

-- Show all encounters and mechanics
function GarrisonShipyardMissionComplete:AnimLine(entry)
	self:SetEncounterModels(1);
	entry.duration = 0.5;

	local encountersFrame = self.Stage.EncountersFrame;
	local playCounteredSound = false;
	for i = 1, #encountersFrame.enemies do
		local mechanicsFrame = encountersFrame.Encounters[i].MechanicsFrame;
		local numMechs, countered = self:ShowEncounterMechanics(encountersFrame, mechanicsFrame, i);
		if (countered) then
			playCounteredSound = true;
		end
		mechanicsFrame:SetPoint("BOTTOM", encountersFrame.Encounters[i], (numMechs - 1) * -16, -5);
		encountersFrame.Encounters[i].CheckFrame:SetFrameLevel(mechanicsFrame:GetFrameLevel() + 1);
		encountersFrame.Encounters[i].Name:Show();
	end
	if ( playCounteredSound ) then
		PlaySound("UI_Garrison_Mission_Threat_Countered");
	end
end

function GarrisonShipyardMissionComplete:AnimPortrait(entry)
	local encountersFrame = self.Stage.EncountersFrame;
	for i = 1, #encountersFrame.enemies do
		local encounter = self.Stage.EncountersFrame.Encounters[i];
		if ( self.currentMission.succeeded ) then
			encounter.CheckFrame.SuccessAnim:Play();
		else
			if ( self.currentMission.failedEncounter == i ) then
				encounter.CheckFrame.FailureAnim:Play();
			else
				encounter.CheckFrame.SuccessAnim:Play();
			end
		end
	end
	if ( self.currentMission.succeeded ) then
		PlaySound("UI_Garrison_Mission_Complete_Mission_Success");
	else
		PlaySound("UI_Garrison_Mission_Complete_Encounter_Fail");
	end
	entry.duration = 0.5;
end

function GarrisonShipyardMissionComplete:AnimFollowersIn(entry)
	self.Stage.EncountersFrame.FadeOut:Play();
	
	local missionList = self.completeMissions;
	local mission = missionList[self.currentIndex];
	local numFollowers = #mission.followers;
	
	local followersFrame = self.Stage.FollowersFrame;
	followersFrame:Show();
	if (numFollowers == 1) then
		followersFrame.Follower2:Hide();
		followersFrame.Follower3:Hide();
		followersFrame.Follower1:SetPoint("LEFT", followersFrame, "TOPLEFT", 202, -206);
	elseif (numFollowers == 2) then
		followersFrame.Follower2:Show();
		followersFrame.Follower3:Hide();
		followersFrame.Follower1:SetPoint("LEFT", followersFrame, "TOPLEFT", 88, -206);
		followersFrame.Follower2:SetPoint("LEFT", followersFrame.Follower1, "RIGHT", 75, 0);
	else
		followersFrame.Follower2:Show();
		followersFrame.Follower3:Show();
		followersFrame.Follower1:SetPoint("LEFT", followersFrame, "TOPLEFT", 33, -206);
		followersFrame.Follower2:SetPoint("LEFT", followersFrame.Follower1, "RIGHT", 17, 0);
	end

	followersFrame.FadeIn:Stop();
	followersFrame.FadeIn:Play();
	
	-- preload next set
	local nextIndex = self.currentIndex + 1;
	local missionList = self.completeMissions;
	if ( missionList[nextIndex] ) then
		MissionCompletePreload_LoadMission(self:GetParent(), missionList[nextIndex].missionID);
	end
end

function GarrisonShipyardMissionComplete:AnimBoatDeath(entry)
	if (self.currentMission.succeeded) then
		entry.duration = 0;
		self:AnimXP(entry);
	elseif (self.boatDeathIndex <= #self.currentMission.followers) then
		local followerFrame = self.Stage.FollowersFrame.Followers[self.boatDeathIndex];
		if (not followerFrame.dead) then
			-- Play the water splash effect and the "survived" animation
			followerFrame.BoatDeathAnimations:SetCameraPosition(-2.2, -9.5, -0.5);
			followerFrame.BoatDeathAnimations:SetSpellVisualKit(self.surviveAnim);
			PlaySoundKitID(self.surviveSound);
			followerFrame.SurvivedAnim:Play();
			self:CheckAndShowFollowerXP(self.currentMission.followers[self.boatDeathIndex]);
		else
			-- Play the explosion effect and the "destroyed" animation
			followerFrame.BoatDeathAnimations:SetCameraPosition(0.7, -5.9, -1.3);
			followerFrame.BoatDeathAnimations:SetSpellVisualKit(self.destroyAnim);
			PlaySoundKitID(self.destroySound);
			followerFrame.DestroyedAnim:Play();
		end
		entry.duration = 1.5;
	end
end

function GarrisonShipyardMissionComplete:AnimCheckBoatDeath(entry)
	self.boatDeathIndex = self.boatDeathIndex + 1;
	-- If we have more boat deaths to show, set the animation index to play the next boat death
	if (not self.currentMission.succeeded and self.boatDeathIndex <= #self.currentMission.followers) then
		local boatDeathIndex = self:FindAnimIndexFor(self.AnimBoatDeath);
		if (boatDeathIndex) then
			self.animIndex = boatDeathIndex - 1;
		end
	end
end

-- if duration is nil it will be set in the onStart function
-- duration is irrelevant for the last entry
local SHIPYARD_ANIMATION_CONTROL = {
	[1] = { duration = nil,		onStartFunc = GarrisonShipyardMissionComplete.AnimLine },			-- line between encounters
	[2] = { duration = nil,		onStartFunc = GarrisonMissionComplete.AnimCheckModels },			-- check that models are loaded
	[3] = { duration = nil,		onStartFunc = GarrisonMissionComplete.AnimModels },					-- model fight
	[4] = { duration = nil,		onStartFunc = GarrisonMissionComplete.AnimPlayImpactSound },		-- impact sound when follower hits
	[5] = { duration = 0.45,	onStartFunc = GarrisonShipyardMissionComplete.AnimPortrait },		-- X over portrait
	[6] = { duration = 0.75,	onStartFunc = GarrisonMissionComplete.AnimRewards },				-- reward panel
	[7] = { duration = 0,		onStartFunc = GarrisonMissionComplete.AnimLockBurst },				-- explode the lock if mission successful	
	[8] = { duration = 0.5,		onStartFunc = GarrisonShipyardMissionComplete.AnimFollowersIn },	-- show all the mission followers
	[9] = { duration = nil,		onStartFunc = GarrisonShipyardMissionComplete.AnimBoatDeath },		-- boat death
	[10] = { duration = 0,		onStartFunc = GarrisonShipyardMissionComplete.AnimCheckBoatDeath },	-- check if there are more boat deaths to check
};

function GarrisonShipyardMissionComplete:SetAnimationControl()
	self.animationControl = SHIPYARD_ANIMATION_CONTROL;
end

function GarrisonShipyardMissionComplete:BeginAnims(animIndex, missionID)
	GarrisonMissionComplete.BeginAnims(self, animIndex);
	-- Find the encounterIndex that we want to use for the ship firing animation. If the mission failed,
	-- use the encounter that failed. Otherwise, use the first encounter that is an enemy ship. Encounters
	-- that are enemy ships do not have a portraitFileDataID field set.
	self.encounterIndex = 1;
	self.boatDeathIndex = 1;
	
	-- Reset animation states
	local followersFrame = self.Stage.FollowersFrame;
	for i=1, #followersFrame.Followers do
		local follower = followersFrame.Followers[i];
		follower.DestroyedText:SetPoint("CENTER", 0, 10);
		follower.Portrait:SetAlpha(1);
		follower.XP:SetAlpha(1);
		follower.SurvivedText:SetAlpha(0);
		follower.DestroyedText:SetAlpha(0);
		if (not follower.dead) then
			follower.DestroyedText:Hide();
			follower.SurvivedText:Show();
		else
			follower.SurvivedText:Hide();
			follower.DestroyedText:Show();
		end
	end
	
	if (self.currentMission.failedEncounter) then
		self.encounterIndex = self.currentMission.failedEncounter;
	else
		local encounters = self.Stage.EncountersFrame.Encounters;
		for i=1, #encounters do
			if (encounters[i].portraitFileDataID and encounters[i].portraitFileDataID ~= 0) then
				self.encounterIndex = i;
				break;
			end
		end
	end
end

function GarrisonShipyardMissionComplete:SetFollowerData(follower, name, classAtlas, portraitIconID)
	follower.Name:SetText(format(GARRISON_SHIPYARD_SHIP_NAME, name));
end

function GarrisonShipyardMissionComplete:SetFollowerLevel(followerFrame, level, quality, currXP, maxXP)
	if ( maxXP and maxXP > 0 ) then
		followerFrame.XP:SetMinMaxValues(0, maxXP);
		followerFrame.XP:SetValue(currXP);
		followerFrame.XP:Show();
	else
		followerFrame.XP:Hide();
	end
	followerFrame.XP.level = level;
	followerFrame.XP.quality = quality;
end

function GarrisonShipyardMissionComplete:DetermineFailedEncounter(missionID, succeeded, followerDeaths)
	if ( succeeded ) then
		self.currentMission.failedEncounter = nil;
		if (self.currentMission.offeredGarrMissionTextureID and self.currentMission.offeredGarrMissionTextureID ~= 0) then
			table.insert(self.pendingFogLift, self.currentMission.offeredGarrMissionTextureID);
		end
	else
		-- Pick the first encounter that is an enemy ship (ie not something like icy waters) to fail.
		-- Encounters that are enemy ships do not have a portraitFileDataID field set.
		self.currentMission.failedEncounter = 1;
		local encounters = self.Stage.EncountersFrame.Encounters;
		for i=1, #encounters do
			if (encounters[i].portraitFileDataID and encounters[i].portraitFileDataID ~= 0) then
				self.currentMission.failedEncounter = i;
				break;
			end
		end
	
		-- mark whether each follower survived or died
		local followersFrame = self.Stage.FollowersFrame;
		for i = 1, #followersFrame.Followers do
			local followerID = self.currentMission.followers[i];
			followersFrame.Followers[i].dead = true;
			for j = 1, #followerDeaths do
				if (followerID == followerDeaths[j].followerID) then
					followersFrame.Followers[i].dead = followerDeaths[j].death;
					break;
				end
			end
		end
	end
end

---------------------------------------------------------------------------------
--- Garrison Shipyard Frame                                                   ---
---------------------------------------------------------------------------------

function GarrisonShipyardFrame_OnEvent(self, event, ...)
	if (event == "CURRENCY_DISPLAY_UPDATE") then
		self:UpdateCurrency();
	elseif (event == "GARRISON_FOLLOWER_LIST_UPDATE" or event == "GARRISON_FOLLOWER_XP_CHANGED" or event == "GARRISON_FOLLOWER_REMOVED") then
		-- follower could have leveled at mission page, need to recheck counters
		if ( event == "GARRISON_FOLLOWER_XP_CHANGED" and self.MissionTab.MissionPage:IsShown() and self.MissionTab.MissionPage.missionInfo ) then
			self.followerCounters = C_Garrison.GetBuffedFollowersForMission(self.MissionTab.MissionPage.missionInfo.missionID);
			self.followerTraits = C_Garrison.GetFollowersTraitsForMission(self.MissionTab.MissionPage.missionInfo.missionID);	
		end
		GarrisonFollowerList_OnEvent(self, event, ...);
	elseif ( event == "GARRISON_FOLLOWER_UPGRADED" ) then
		GarrisonFollowerList_OnEvent(self, event, ...);
	elseif (event == "GARRISON_MISSION_FINISHED") then
		self:CheckCompleteMissions();
	-- TODO more events
	end
end

function GarrisonShipyardFrame_OnShow(self)
	--[[
	GarrisonThreatCountersFrame:SetParent(self.FollowerTab);
	GarrisonThreatCountersFrame:SetPoint("TOPRIGHT", -12, 30);
	]]--
	self:CheckCompleteMissions(true);
	PlaySound("UI_Garrison_CommandTable_Open");
end

function GarrisonShipyardFrame_OnHide(self)
	if ( self.MissionTab.MissionPage.missionInfo ) then
		self:CloseMission();
	end
	self:ClearMouse();
	self:HideCompleteMissions(true);
	--[[
		C_Garrison.CloseMissionNPC();
		HelpPlate_Hide();
		MissionCompletePreload_Cancel(self);
		StaticPopup_Hide("DEACTIVATE_FOLLOWER");
		StaticPopup_Hide("ACTIVATE_FOLLOWER");

		GarrisonMissionList_Update();
	]]--
	PlaySound("UI_Garrison_CommandTable_Close");
end

---------------------------------------------------------------------------------
--- Shipyard Map Mission List                                                 ---
---------------------------------------------------------------------------------

function GarrisonShipyardMap_OnLoad(self)
	self.missions = {};
	self.missionFrames = {};
	
	self:RegisterEvent("GARRISON_MISSION_LIST_UPDATE");
	self:RegisterEvent("GARRISON_RANDOM_MISSION_ADDED");
end

function GarrisonShipyardMap_OnEvent(self, event, ...)
	if (event == "GARRISON_MISSION_LIST_UPDATE" or event == "GARRISON_RANDOM_MISSION_ADDED") then
		GarrisonShipyardMap_UpdateMissions();
	end
end

function GarrisonShipyardMap_OnShow(self)
	self:GetParent():GetParent():CheckCompleteMissions(true);
	GarrisonShipyardMap_UpdateMissions();
	self:GetParent():GetParent().FollowerList:Hide();
	self:GetParent():GetParent():CheckPendingFogLift();
end

function GarrisonShipyardMap_OnHide(self)
	GarrisonShipFollowerPlacer:SetScript("OnUpdate", nil);
end

function GarrisonShipyardMap_OnUpdate(self)
	local timeNow = GetTime();
	for i = 1, #self.missions do
		if ( self.missions[i].offerEndTime and self.missions[i].offerEndTime <= timeNow ) then
			GarrisonShipyardMap_UpdateMissions();
			break;
		end
	end
end

function GarrisonShipyardMap_SetupFog(self, offeredGarrMissionTextureID)
	if (offeredGarrMissionTextureID and offeredGarrMissionTextureID ~= 0) then
		for i=1, #self.FogFrames do
			-- Skip if we are already showing this fog
			if (self.FogFrames[i].offeredGarrMissionTextureID == offeredGarrMissionTextureID and self.FogFrames[i]:IsShown()) then
				return;
			end
		end
		for i=1, #self.FogFrames do
			local fogFrame = self.FogFrames[i];
			if (not self.FogFrames[i]:IsShown()) then
				local textureKit, posX, posY = C_Garrison.GetMissionTexture(offeredGarrMissionTextureID);
				local atlasFog = textureKit .. "-Fog";
				local atlasHighlight = textureKit .. "-Highlight";
				
				fogFrame.offeredGarrMissionTextureID = offeredGarrMissionTextureID;
				fogFrame.FogTexture:SetAtlas(atlasFog, true);
				fogFrame.HighlightTexture:SetAtlas(atlasHighlight, true);
				fogFrame.HighlightAnimTexture:SetAtlas(atlasHighlight, true);
				fogFrame.FogAnimTexture:SetAtlas(atlasFog, true);
				fogFrame.HighlightGlowAnimTexture:SetAtlas(atlasHighlight, true);
				
				if (posX > 0 and posY > 0) then
					fogFrame.MapFogFadeOutAnim.ScaleAnim:SetOrigin("BOTTOMRIGHT", 0, 0);
				elseif (posX > 0 and posY == 0) then
					fogFrame.MapFogFadeOutAnim.ScaleAnim:SetOrigin("TOPRIGHT", 0, 0);
				elseif (posX == 0 and posY > 0) then
					fogFrame.MapFogFadeOutAnim.ScaleAnim:SetOrigin("BOTTOMLEFT", 0, 0);
				else
					fogFrame.MapFogFadeOutAnim.ScaleAnim:SetOrigin("TOPLEFT", 0, 0);
				end
				
				fogFrame:SetPoint("TOPLEFT", self.MapTexture, "TOPLEFT", posX, -posY);
				fogFrame:SetSize(fogFrame.FogTexture:GetSize());
				fogFrame:Show();
				break;
			end
		end
	end
end

function GarrisonShipyardMap_UpdateMissions()
	local self = GarrisonShipyardFrame.MissionTab.MissionList;

	local inProgressMissions = C_Garrison.GetInProgressMissions(LE_FOLLOWER_TYPE_SHIPYARD_6_2);
	C_Garrison.GetAvailableMissions(self.missions, LE_FOLLOWER_TYPE_SHIPYARD_6_2);
	for i = 1, #inProgressMissions do
		local mission = inProgressMissions[i];
		mission.inProgress = true;
		table.insert(self.missions, mission);
	end
	for i = 1, #self.missions do
		local mission = self.missions[i];
			
		-- Cache mission frames
		local frame = self.missionFrames[i];
		if (not frame) then
			frame = CreateFrame("BUTTON", "GarrisonShipyardMapMission" .. i, self, "GarrisonShipyardMapMissionTemplate");
			self.missionFrames[i] = frame;
		end
		
		-- If we have a siegebreaker mission that cannot be started, hide it
		if (mission.offeredGarrMissionTextureID ~= 0 and not mission.inProgress and not mission.canStart) then
			frame:Hide();
		else
			local mapWidth, mapHeight = GarrisonShipyardFrame.MissionTab.MissionList.MapTexture:GetSize();
			mission.mapPosX = mission.mapPosX * mapWidth;
			mission.mapPosY = mission.mapPosY * -mapHeight;
			frame:SetPoint("CENTER", self.MapTexture, "TOPLEFT", mission.mapPosX, mission.mapPosY);
			frame.info = mission;
			frame:SetHitRectInsets(10, 10, 10, 10);
			frame.RewardFrame:Hide();
			
			local mapAtlas = mission.typePrefix;
			
			GarrisonShipyardMap_SetupFog(self, mission.offeredGarrMissionTextureID);
				
			if (mission.inProgress) then
				local followerInfo = C_Garrison.GetFollowerInfo(mission.followers[1]);
				mapAtlas = mapAtlas .. "-MapBadge";
				local inProgressAtlas = followerInfo.texPrefix .. "-Map";
				frame.Icon:SetAtlas(inProgressAtlas, true); --Ships_Carrier-Map", true);
				frame.HighlightIcon:SetAtlas("Ships_Carrier-Map", true);
				frame.InProgressIcon:SetAtlas(mapAtlas, true);
				frame.InProgressIcon:Show();
				frame.GlowRing:Show();
				frame.InProgressBoatPulseAnim:Play();
				frame:SetSize(94, 94);
			else
				mapAtlas = mapAtlas .. "-Map";
				frame.Icon:SetAtlas(mapAtlas, true);
				frame.HighlightIcon:SetAtlas(mapAtlas, true);
				
				-- If mission type is combat with an item reward, show the item icon
				for id, reward in pairs(mission.rewards) do
					if (reward.itemID) then
						local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(reward.itemID);
						frame.RewardFrame.itemID = reward.itemID;
						frame.RewardFrame.Icon:SetTexture(itemTexture);
						frame.RewardFrame:Show();
						break;
					end
				end
				frame.InProgressIcon:Hide();
				frame.GlowRing:Hide();
				frame.InProgressBoatPulseAnim:Stop();
				frame:SetSize(64, 64);
			end
			
			frame:Show();
		end
	end

	-- Hide the rest of the frames that we have cached but are not used
	for j = #self.missions + 1, #self.missionFrames do
		self.missionFrames[j]:Hide();
	end
end

function GarrisonShipyardMap_ResetFogFrame(self)
	local fogFrame = self:GetParent();
	fogFrame.FogTexture:Show();
	fogFrame:Hide();
end

function GarrisonShipyardMapMission_OnClick(self, button)
	if (self.info.canStart) then
		local frame = self:GetParent():GetParent():GetParent();
		frame:OnClickMission(self.info);
	end
end

function GarrisonShipyardMapMission_OnEnter(self, button)
	if (self.info == nil) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
	GameTooltip:SetText(self.info.name);
	
	if (self.info.inProgress) then
		GameTooltip:AddLine(GARRISON_SHIPYARD_MSSION_INPROGRESS_TOOLTIP, 1, 1, 1, true);
		
		local missionInfo = C_Garrison.GetBasicMissionInfo(self.info.missionID);
		local timeLeft = missionInfo.timeLeft;
		GameTooltip:AddLine(format(GARRISON_SHIPYARD_MISSION_INPROGRESS_TIMELEFT, timeLeft), 1, 1, 1, true);
		
		local successChance = C_Garrison.GetMissionSuccessChance(self.info.missionID);
		if (successChance) then
			GameTooltip:AddLine(format(GARRISON_MISSION_PERCENT_CHANCE, successChance), 1, 1, 1, true);
		end
	else
		GameTooltip:AddLine(self.info.description, 1, 1, 1, true);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(string.format(GARRISON_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, self.info.numFollowers), 1, 1, 1);
		local timeString = NORMAL_FONT_COLOR_CODE .. TIME_LABEL .. FONT_COLOR_CODE_CLOSE .. " ";
		timeString = timeString .. HIGHLIGHT_FONT_COLOR_CODE .. self.info.duration .. FONT_COLOR_CODE_CLOSE;
		GameTooltip:AddLine(timeString);
		GarrisonMissionButton_AddThreatsToTooltip(self.info.missionID, GarrisonShipyardFrame:GetFollowerType());
		
		if (self.info.isRare) then
			GameTooltip:AddLine(GARRISON_MISSION_AVAILABILITY);
			GameTooltip:AddLine(self.info.offerTimeRemaining, 1, 1, 1);
		end
	end
	
	-- Add rewards
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(GARRISON_SHIPYARD_MISSION_REWARD);
	
	for id, reward in pairs(self.info.rewards) do
		if (reward.itemID) then
			local itemName, _, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(reward.itemID);
			local itemString = format("|T%s:25:25:0:0|t %s%s|r", itemTexture, ITEM_QUALITY_COLORS[itemRarity].hex, itemName);
			GameTooltip:AddLine(itemString);
		elseif (reward.followerXP) then
			GameTooltip:AddLine(format(GARRISON_REWARD_XP_FORMAT, BreakUpLargeNumbers(reward.followerXP)), 1, 1, 1);
		elseif (reward.currencyID ~= 0) then
			local _, _, currencyTexture = GetCurrencyInfo(reward.currencyID);
			GameTooltip:AddLine(reward.quantity .. " |T" .. currencyTexture .. ":0:0:0:0|t", 1, 1, 1);
		elseif (reward.currencyID == 0) then
			GameTooltip:AddLine(GetMoneyString(reward.quantity), 1, 1, 1);
		end
	end
	
	if not C_Garrison.IsOnGarrisonMap() then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(GARRISON_MISSION_TOOLTIP_RETURN_TO_START, nil, nil, nil, 1);
	end
	
	if (self.info.inProgress) then
		if (self.info.followers ~= nil) then
			GameTooltip:AddLine(" ");
			GameTooltip:AddLine(GARRISON_SHIPYARD_FOLLOWERS);
			for i=1, #(self.info.followers) do
				GameTooltip:AddLine(format(GARRISON_SHIPYARD_SHIP_NAME, C_Garrison.GetFollowerName(self.info.followers[i])), 1, 1, 1);
			end
		end
	end

	GameTooltip:Show();
end

function GarrisonShipyardMapMission_OnLeave(self, button)
	GameTooltip_Hide();
end


---------------------------------------------------------------------------------
--- Shipyard Map Mission Page                                                 ---
---------------------------------------------------------------------------------

function GarrisonShipyardMissionPage_OnLoad(self)
	self:RegisterEvent("GARRISON_FOLLOWER_LIST_UPDATE");
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED");
	self:RegisterForClicks("RightButtonUp");
	
	self.BuffsFrame:SetPoint("BOTTOM", 0, 178);
	self.BuffsFrame.BuffsTitle:SetText(GARRISON_SHIPYARD_MISSION_PARTY_BUFFS);
	self.RewardsFrame.MissionXP:SetPoint("BOTTOM", self.RewardsFrame, "TOP", 0, 4);
end

function GarrisonShipyardMissionPage_OnEvent(self, event, ...)
	local mainFrame = self:GetParent():GetParent();
	if ( event == "GARRISON_FOLLOWER_LIST_UPDATE" or event == "GARRISON_FOLLOWER_XP_CHANGED" ) then
		mainFrame:UpdateMissionParty(self.Followers);
		if ( self.missionInfo ) then
			local missionID = self.missionInfo.missionID;
			mainFrame.followerCounters = C_Garrison.GetBuffedFollowersForMission(missionID)
			mainFrame.followerTraits = C_Garrison.GetFollowersTraitsForMission(missionID);
			GarrisonFollowerList_UpdateFollowers(mainFrame.FollowerList);
			mainFrame:UpdateMissionData(self);
			return;
		end
	end
	mainFrame:UpdateStartButton(self);
end

function GarrisonShipyardMissionPage_OnShow(self)
	local mainFrame = self:GetParent():GetParent();
	mainFrame.FollowerList:Show();
	mainFrame:UpdateStartButton(self);
end

function GarrisonShipyardMissionPage_OnHide(self)
	self.lastUpdate = nil;
end

function GarrisonShipyardMissionPage_OnUpdate(self)
	if ( self.missionInfo.offerEndTime and self.missionInfo.offerEndTime <= GetTime() ) then
		-- mission expired	
		self:GetParent():GetParent():ClearMouse();
		self.CloseButton:Click();
	end
end

function GarrisonShipyardMissionPage_UpdatePortraitPulse(missionPage)
	-- only pulse the first available slot
	local pulsed = false;
	for i = 1, #missionPage.Followers do
		local followerFrame = missionPage.Followers[i];
		if ( followerFrame.info ) then
			followerFrame.PulseAnim:Stop();
			-- TODO if we need the code below, maybe put this into a common base function and remove from garrisonmissionui.lua
			--[[
			if ( C_Garrison.CanSpellTargetFollowerIDWithAddAbility(followerFrame.info.followerID) ) then
				followerFrame.PortraitFrame.SpellTargetHighlight:Show();
			else
				followerFrame.PortraitFrame.SpellTargetHighlight:Hide();
			end
			]]--
		else
			--followerFrame.PortraitFrame.SpellTargetHighlight:Hide();

			if ( pulsed ) then
				followerFrame.PulseAnim:Stop();
			else
				followerFrame.PulseAnim:Play();
				pulsed = true;
			end
		end
	end
end


---------------------------------------------------------------------------------
--- Ship Follower List                                                        ---
---------------------------------------------------------------------------------

function GarrisonShipFollowerListButton_OnClick(self, button)
	local followerFrame = self:GetParent():GetParent().followerFrame;
	PlaySound("UI_Garrison_CommandTable_SelectFollower");
	followerFrame.selectedFollower = self.id;

	GarrisonUpdateFollowerData(followerFrame);
	--if ( followerFrame.FollowerTab ) then
	--	GarrisonFollowerPage_ShowFollower(followerFrame.FollowerTab, self.id);
	--end
end

function GarrisonShipFollowerListButton_OnDragStart(self, button)
	local mainFrame = self:GetParent():GetParent():GetParent():GetParent();
	mainFrame:OnDragStartFollowerButton(GarrisonShipFollowerPlacer, self, 56);
end

function GarrisonShipFollowerListButton_OnDragStop(self, button)
	local mainFrame = self:GetParent():GetParent():GetParent():GetParent();
	mainFrame:OnDragStopFollowerButton(GarrisonShipFollowerPlacer);
end


---------------------------------------------------------------------------------
--- Ship Followers Mission Page                                               ---
---------------------------------------------------------------------------------

function GarrisonShipMissionPageFollowerFrame_OnDragStart(self)
	local mainFrame = self:GetParent():GetParent():GetParent();
	mainFrame:OnDragStartMissionFollower(GarrisonShipFollowerPlacer, self, 56);
end

function GarrisonShipMissionPageFollowerFrame_OnDragStop(self)
	local mainFrame = self:GetParent():GetParent():GetParent();
	mainFrame:OnDragStopMissionFollower(GarrisonShipFollowerPlacer);
end

function GarrisonShipMissionPageFollowerFrame_OnReceiveDrag(self)
	local mainFrame = self:GetParent():GetParent():GetParent();
	mainFrame:OnReceiveDragMissionFollower(GarrisonShipFollowerPlacer, self);
end

function GarrisonShipMissionPageFollowerFrame_OnMouseUp(self, button)
	local mainFrame = self:GetParent():GetParent():GetParent();
	mainFrame:OnMouseUpMissionFollower(self, button);
end

function GarrisonShipMissionPageFollowerFrame_OnEnter(self)
	if not self.info then 
		return;
	end

	local xp = C_Garrison.GetFollowerXP(self.info.followerID);
	local levelXp = C_Garrison.GetFollowerLevelXP(self.info.followerID);
		
	GarrisonShipFollowerTooltip:ClearAllPoints();
	GarrisonShipFollowerTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", -50, -30);	
	GarrisonFollowerTooltip_Show(self.info.garrFollowerID, 
		self.info.isCollected,
		C_Garrison.GetFollowerQuality(self.info.followerID),
		C_Garrison.GetFollowerLevel(self.info.followerID), 
		xp,
		levelXp,
		C_Garrison.GetFollowerItemLevelAverage(self.info.followerID), 
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 1),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 2),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 3),
		C_Garrison.GetFollowerAbilityAtIndex(self.info.followerID, 4),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 1),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 2),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 3),
		C_Garrison.GetFollowerTraitAtIndex(self.info.followerID, 4),
		true,
		C_Garrison.GetFollowerBiasForMission(self:GetParent().missionInfo.missionID, self.info.followerID) < 0.0,
		GarrisonShipFollowerTooltip,
		231
		);
end

function GarrisonShipMissionPageFollowerFrame_OnLeave(self)
	GarrisonShipFollowerTooltip:Hide();
end
