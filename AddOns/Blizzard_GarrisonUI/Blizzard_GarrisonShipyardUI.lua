
---------------------------------------------------------------------------------
--- Garrison Follower Options				                                  ---
---------------------------------------------------------------------------------

-- These are follower options that depend on this AddOn being loaded, and so they can't be set in GarrisonBaseUtils.
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_6_2].missionFollowerSortFunc = GarrisonFollowerList_DefaultMissionSort;
GarrisonFollowerOptions[Enum.GarrisonFollowerType.FollowerType_6_2].missionFollowerInitSortFunc = GarrisonFollowerList_InitializeDefaultMissionSort;


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

StaticPopupDialogs["GARRISON_SHIP_RENAME"] = {
	text = GARRISON_SHIP_RENAME_LABEL,
	button1 = ACCEPT,
	button3 = GARRISON_SHIP_RENAME_DEFAULT_LABEL,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 24,
	OnAccept = function(self)
		local text = self.editBox:GetText();
		C_Garrison.RenameFollower(self.data, text);
	end,
	OnAlt = function(self)
		C_Garrison.RenameFollower(self.data, "");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		local text = parent.editBox:GetText();
		C_Garrison.RenameFollower(parent.data, text);
		parent:Hide();
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["GARRISON_SHIP_DECOMMISSION"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		C_Garrison.RemoveFollower(self.data.followerID, true);
		PlaySound(SOUNDKIT.UI_GARRISON_SHIPYARD_DECOMISSION_SHIP);
	end,
	OnShow = function(self)
		local quality = C_Garrison.GetFollowerQuality(self.data.followerID);
		local name = FOLLOWER_QUALITY_COLORS[quality].hex..C_Garrison.GetFollowerName(self.data.followerID)..FONT_COLOR_CODE_CLOSE;
		self.text:SetFormattedText(GARRISON_SHIP_DECOMMISSION_CONFIRMATION, name);
	end,
	showAlert = 1,
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
	self:UpdateCurrency();
	self.MissionComplete.pendingFogLift = {};

	local factionGroup = UnitFactionGroup("player");
	if ( factionGroup == "Horde" ) then
		self.MissionTab.MissionPage.RewardsFrame.Chest:SetAtlas("GarrMission-HordeChest");
		self.MissionComplete.BonusRewards.ChestModel:SetDisplayInfo(54913);
		local dialogBorderFrame = self.MissionTab.MissionList.CompleteDialog.BorderFrame;
		dialogBorderFrame.Model:SetDisplayInfo(44158);
		dialogBorderFrame.Model:SetPosition(0.2, 1.35, -0.5);
		GarrisonMissionStage_SetBack(dialogBorderFrame.Stage, "_GarrMissionLocation-FrostfireSea-Back");
		GarrisonMissionStage_SetMid(dialogBorderFrame.Stage, "_GarrMissionLocation-FrostfireSea-Mid");
		GarrisonMissionStage_SetFore(dialogBorderFrame.Stage, "_GarrMissionLocation-FrostfireSea-Fore");
	else
		local dialogBorderFrame = self.MissionTab.MissionList.CompleteDialog.BorderFrame;
		dialogBorderFrame.Model:SetDisplayInfo(53831);
		dialogBorderFrame.Model:SetPosition(0.2, .90, -0.7);
		GarrisonMissionStage_SetBack(dialogBorderFrame.Stage, "_GarrMissionLocation-ShadowmoonSea-Back");
		GarrisonMissionStage_SetMid(dialogBorderFrame.Stage, "_GarrMissionLocation-ShadowmoonSea-Mid");
		GarrisonMissionStage_SetFore(dialogBorderFrame.Stage, "_GarrMissionLocation-ShadowmoonSea-Fore");
	end
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("GARRISON_FOLLOWER_XP_CHANGED");
	self:RegisterEvent("GARRISON_MISSION_FINISHED");

	self.MissionComplete.Stage.ModelRight:SetFacingLeft(true);
end

function GarrisonShipyardMission:OnEventMainFrame(event, ...)
	if (event == "CURRENCY_DISPLAY_UPDATE") then
		self:UpdateCurrency();
		-- follower could have leveled at mission page, need to recheck counters
	elseif (event == "GARRISON_FOLLOWER_XP_CHANGED" and self.MissionTab.MissionPage:IsShown() and self.MissionTab.MissionPage.missionInfo ) then
		local followerTypeID = ...;
		if (followerTypeID == self.followerTypeID) then
			self:GetFollowerBuffsForMission(self.MissionTab.MissionPage.missionInfo.missionID);
		end
	elseif (event == "GARRISON_MISSION_FINISHED") then
		local followerTypeID = ...;
		if (followerTypeID == self.followerTypeID) then
			self:CheckCompleteMissions();
		end
	end
end

function GarrisonShipyardMission:OnShowMainFrame()
	GarrisonMission.OnShowMainFrame(self);
	if (self.FollowerList.followerType ~= self.followerTypeID) then
		self.FollowerList:Initialize(self.followerTypeID);
	end
	self.MissionTab.MissionList.followerTypeID = self.followerTypeID;
	self:CheckCompleteMissions(true);
	PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_OPEN);
	self:CheckFollowerCount();
end

function GarrisonShipyardMission:OnHideMainFrame()
	if ( self.MissionTab.MissionPage.missionInfo ) then
		self:CloseMission();
	end
	self:ClearMouse();
	self:HideCompleteMissions(true);
	C_Garrison.CloseMissionNPC();
	MissionCompletePreload_Cancel(self);
	StaticPopup_Hide("DANGEROUS_MISSIONS");
	StaticPopup_Hide("CONFIRM_FOLLOWER_EQUIPMENT");
	GarrisonBonusAreaTooltip:Hide();
	PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_CLOSE);
end

function GarrisonShipyardMission:UpdateCurrency()
	local amount = C_CurrencyInfo.GetCurrencyInfo(GARRISON_SHIP_OIL_CURRENCY).quantity;
	self.materialAmount = amount;
	amount = BreakUpLargeNumbers(amount)
	self.FollowerList.MaterialFrame.Materials:SetText(amount);
end

function GarrisonShipyardMission:SelectTab(id)
	GarrisonMission.SelectTab(self, id);
	if (id == 1) then
		self.BorderFrame.TitleText:SetText(GARRISON_SHIPYARD_TITLE);
	else
		self.BorderFrame.TitleText:SetText(GARRISON_SHIPYARD_FLEET_TITLE);
	end
	if ( UIDropDownMenu_GetCurrentDropDown() == GarrisonShipyardFollowerOptionDropDown ) then
		CloseDropDownMenus();
	end
end

function GarrisonShipyardMission:CheckFollowerCount()
	local numFollowers = C_Garrison.GetNumFollowers(Enum.GarrisonFollowerType.FollowerType_6_2);
	if (numFollowers > 0) then
		PanelTemplates_EnableTab(self, 2);
	else
		PanelTemplates_DisableTab(self, 2);
		self:SelectTab(1);
	end
end

function GarrisonShipyardMission:OnClickMission(missionInfo)
	if (not GarrisonMission.OnClickMission(self, missionInfo)) then
		return false;
	end

	self.MissionTab.MissionList:Hide();
	self.MissionTab.MissionPage:Show();

	self:ShowMission(missionInfo);
	self.FollowerList:UpdateFollowers();
	return true;
end

function GarrisonShipyardMission:ShowMission(missionInfo)
	GarrisonMission.ShowMission(self, missionInfo);

	local frame = self.MissionTab.MissionPage;
	frame.Stage.Title:SetPoint("LEFT", frame.Stage.Header, "LEFT", 98, 0);
	frame.Stage.MissionEnvIcon:Hide();

	local typeAtlas = missionInfo.typeTextureKit .. "-Mission";
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

function GarrisonShipyardMission:SortEnemies(enemies)
	local comparison = function(enemy1, enemy2)
		local enemy1PortraitID = enemy1.portraitFileDataID or 0;
		local enemy2PortraitID = enemy2.portraitFileDataID or 0;
		return enemy1PortraitID > enemy2PortraitID;
	end

	table.sort(enemies, comparison);
end

function GarrisonShipyardMission:SortMechanics(mechanics)
	local comparison = function(mechanic1, mechanic2)
		return mechanic1.factor > mechanic2.factor;
	end

	local keys = {}
	for key in pairs(mechanics) do
		table.insert(keys, key)
	end

	table.sort(keys, function(a, b)
		return comparison(mechanics[a], mechanics[b])
	end)

	return keys;
end

function GarrisonShipyardMission:SetEnemies(frame, enemies, numFollowers)
	self:SortEnemies(enemies);
	local numVisibleEnemies = GarrisonMission.SetEnemies(self, frame, enemies, numFollowers );

	for i=1, #enemies do
		local Frame = frame.Enemies[i];
		if ( not Frame ) then
			break;
		end
		local enemy = enemies[i];
		GarrisonShipyardMission:SetLowFactorMechanics(Frame, enemy);
	end

	if ( numVisibleEnemies == 1 ) then
		frame.Enemy1:SetPoint("TOPLEFT", 200, -83);
	elseif ( numVisibleEnemies == 2 ) then
		frame.Enemy1:SetPoint("TOPLEFT", 116, -83);
	else
		frame.Enemy1:SetPoint("TOPLEFT", 31, -83);
	end
	return numVisibleEnemies;
end

function GarrisonShipyardMission:UpdateMissionData(frame)
	GarrisonMission.UpdateMissionData(self, frame);
	frame.Stage.MissionInfo.MissionEnv:Hide();

	GarrisonShipyardMissionPage_UpdatePortraitPulse(frame);
end

function GarrisonShipyardMission:UpdateStartButton(missionPage)
	GarrisonMission.UpdateStartButton(self, missionPage);
end

function GarrisonShipyardMission:SetEnemyName(portraitFrame, name)
end

function GarrisonShipyardMission:SetLowFactorMechanics(frame, enemy)
	local numMechs = 0;
	local sortedKeys = self:SortMechanics(enemy.mechanics);
	for _, id in ipairs(sortedKeys) do
		local mechanic = enemy.mechanics[id];
		numMechs = numMechs + 1;
		local Mechanic = frame.Mechanics[numMechs];
		if ( mechanic.factor > GARRISON_HIGH_THREAT_VALUE ) then
			Mechanic.Border:SetAtlas("GarrMission_EncounterAbilityBorder");
		else
			Mechanic.Border:SetAtlas("GarrMission_WeakEncounterAbilityBorder-Lg");
		end
	end
end

function GarrisonShipyardMission:SetEnemyPortrait(portraitFrame, enemy, eliteFrame, numMechs)
	if (enemy.textureKit) then
		local atlas = enemy.textureKit .. "-Portrait";
		portraitFrame.Portrait:SetAtlas(atlas, true);
		portraitFrame.Portrait:Show();
		portraitFrame.PortraitIcon:Hide();
		portraitFrame.PortraitRing:Hide();
		portraitFrame.Name:SetPoint("BOTTOM", portraitFrame.Portrait, "TOP", 0, -50);
	elseif (enemy.portraitFileDataID) then
		portraitFrame.PortraitIcon:SetTexture(enemy.portraitFileDataID);
		portraitFrame.PortraitIcon:Show();
		portraitFrame.PortraitRing:Show();
		portraitFrame.Portrait:Hide();
		portraitFrame.Name:SetPoint("BOTTOM", portraitFrame.PortraitIcon, "TOP", 0, 5);
	end
end

function GarrisonShipyardMission:SetFollowerPortrait(followerFrame, followerInfo, forMissionPage, listPortrait)
	local atlas = followerInfo.textureKit;
	if (listPortrait) then
		atlas = atlas .. "-List";
	else
		atlas = atlas .. "-Portrait";
	end
	followerFrame.Portrait:SetAtlas(atlas, true);
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
	PlaySound(SOUNDKIT.UI_GARRISON_SHIPYARD_START_MISSION);
end

function GarrisonShipyardMission:AssignFollowerToMission(frame, info)
	if (not GarrisonMission.AssignFollowerToMission(self, frame, info)) then
		return;
	end

	if ( info.classSpec == 53 or info.classSpec == 58 ) then
		PlaySound(SOUNDKIT.UI_GARRISON_SHIPYARD_PLACE_LANDING_CRAFT);
	elseif ( info.classSpec == 54 or info.classSpec == 59 ) then
		PlaySound(SOUNDKIT.UI_GARRISON_SHIPYARD_PLACE_DREADNOUGHT);
	elseif ( info.classSpec == 55 or info.classSpec == 60 ) then
		PlaySound(SOUNDKIT.UI_GARRISON_SHIPYARD_PLACE_CARRIER);
	elseif ( info.classSpec == 56 or info.classSpec == 61 ) then
		PlaySound(SOUNDKIT.UI_GARRISON_SHIPYARD_PLACE_GALLEON);
	elseif ( info.classSpec == 57 or info.classSpec == 62 ) then
		PlaySound(SOUNDKIT.UI_GARRISON_SHIPYARD_PLACE_SUBMARINE);
	end
	self:SetFollowerPortrait(frame, info, false, false);
	local color = FOLLOWER_QUALITY_COLORS[info.quality];
	frame.Name:SetText(format(GARRISON_SHIPYARD_SHIP_NAME, info.name));
	frame.Name:SetTextColor(color.r, color.g, color.b);
	frame.Name:Show();
	frame.NameBG:Show();
	if (frame.Name:GetNumLines() > 1) then
		frame.NameBG:SetSize(132, 33);
	else
		frame.NameBG:SetSize(132, 21);
	end
end

function GarrisonShipyardMission:RemoveFollowerFromMission(frame, updateValues)
	GarrisonMission.RemoveFollowerFromMission(self, frame, updateValues);

	frame.Portrait:SetAtlas("ShipMission_FollowerBG", true);
	frame.Name:Hide();
	frame.NameBG:Hide();
end

function GarrisonShipyardMission:UpdateMissionParty(followers)
	GarrisonMission.UpdateMissionParty(self, followers, "GarrisonMissionAbilityCounterTemplate");
	for followerIndex = 1, #followers do
		local followerFrame = followers[followerIndex];
		if ( followerFrame.info ) then
			local counters = self.followerCounters and followerFrame.info and self.followerCounters[followerFrame.info.followerID] or nil;
			-- Move left counter so that all counters are centered
			if ( counters ) then
				if ( #counters > 1 ) then
					table.sort(counters, function(left, right)
						if ( not left.factor ) then error("?") end
						return left.factor > right.factor;
					end)
					local offset = (#counters - 1) * 8 + (#counters - 1) * followerFrame.Counters[1]:GetWidth() / 2;
					followerFrame.Counters[1]:SetPoint("BOTTOM", -offset, 0);
				end
				for i = 1, #counters do
					local Counter = followerFrame.Counters[i];
					Counter.followerTypeID = Enum.GarrisonFollowerType.FollowerType_6_2;
					if ( Counter.info.factor > GARRISON_HIGH_THREAT_VALUE ) then
						Counter.Border:SetAtlas("GarrMission_EncounterAbilityBorder");
					else
						Counter.Border:SetAtlas("GarrMission_WeakEncounterAbilityBorder");
					end
				end
			end
		end
	end
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
	MissionCompletePreload_LoadMission(self, self.MissionComplete.completeMissions[1].missionID,
		GarrisonFollowerOptions[self.followerTypeID].showSingleMissionCompleteFollower,
		GarrisonFollowerOptions[self.followerTypeID].showSingleMissionCompleteAnimation);
end

function GarrisonShipyardMission:MissionCompleteInitialize(missionList, index)
	if (not GarrisonMission.MissionCompleteInitialize(self, missionList, index)) then
		return false;
	end

	local destroyAnim, destroySound, surviveAnim, surviveSound, saveAnim, saveSound = C_Garrison.GetShipDeathAnimInfo();
	self.MissionComplete.destroyAnim = destroyAnim;
	self.MissionComplete.destroySound = destroySound;
	self.MissionComplete.surviveAnim = surviveAnim;
	self.MissionComplete.surviveSound = surviveSound;
	self.MissionComplete.saveAnim = saveAnim;
	self.MissionComplete.saveSound = saveSound;

	-- In the future, it would be nice if a designer could setup this camera in data
	self.MissionComplete.boatDeathCamPos = {0.7, -7.7, -1.3};

	return true;
end

function GarrisonShipyardMission:CloseMissionComplete()
	GarrisonMission.CloseMissionComplete(self);
	self:CheckPendingFogLift();
	self:CheckPendingBonusAreaAdded();
	GarrisonShipyardMap_CheckTutorials();
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

function GarrisonShipyardMission:CheckPendingBonusAreaAdded()
	if (self.MissionTab.MissionList.CompleteDialog:IsShown() or self.MissionComplete:IsShown()) then
		return;
	end

	-- Check if we completed any missions that cause the fog to lift. If so, lift the fog
	local missionList = self.MissionTab.MissionList;
	for i=#missionList.pendingBonusArea, 1, -1 do
		for j=1, #missionList.bonusFrames do
			if (missionList.pendingBonusArea[i] == missionList.bonusFrames[j].bonusAbilityID) then
				missionList.bonusFrames[j].BonusAreaAddedAnim:Play();
				table.remove(missionList.pendingBonusArea, i);
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
	self:SetEncounterModels(self.encounterIndex);
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
		PlaySound(SOUNDKIT.UI_GARRISON_MISSION_THREAT_COUNTERED);
	end
end

function GarrisonShipyardMissionComplete:AnimModels(entry)
	local currentAnim = self.animInfo[self.encounterIndex];
	-- Always animate ships with the stead pan with adjusted start position and speed. These values
	-- were determined by using the GarrModelHelper mod.
	GarrisonMissionComplete.AnimModels(self, entry, LE_PAN_STEADY, LE_PAN_STEADY, 0.45, 0.02);
end

function GarrisonShipyardMissionComplete:AnimPortrait(entry)
	local encountersFrame = self.Stage.EncountersFrame;
	for i = 1, #encountersFrame.enemies do
		local encounter = self.Stage.EncountersFrame.Encounters[i];
		if (encounter.Portrait:IsShown()) then
			encounter.CheckFrame:SetPoint("CENTER", encounter.Portrait, "CENTER");
		else
			encounter.CheckFrame:SetPoint("CENTER", encounter.PortraitIcon, "CENTER");
		end
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
		PlaySound(SOUNDKIT.UI_GARRISON_MISSION_COMPLETE_MISSION_SUCCESS);
	else
		PlaySound(SOUNDKIT.UI_GARRISON_MISSION_COMPLETE_ENCOUNTER_FAIL);
	end
	entry.duration = 0.5;
end

function GarrisonShipyardMissionComplete:AnimFollowersIn(entry)
	if ( not self.skipAnimations ) then
		self.Stage.EncountersFrame.FadeOut:Play();
	end

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
	if ( self.skipAnimations ) then
		followersFrame:SetAlpha(1);
	else
		followersFrame.FadeIn:Play();
	end
	-- preload next set
	local nextIndex = self.currentIndex + 1;
	local missionList = self.completeMissions;
	if ( missionList[nextIndex] ) then
		MissionCompletePreload_LoadMission(self:GetParent(), missionList[nextIndex].missionID,
			GarrisonFollowerOptions[self:GetParent().followerTypeID].showSingleMissionCompleteFollower,
			GarrisonFollowerOptions[self:GetParent().followerTypeID].showSingleMissionCompleteAnimation);
	end

	if ( entry ) then
		if ( self.skipAnimations ) then
			entry.duration = 0;
		else
			entry.duration = 0.5;
		end
	end
end

function GarrisonShipyardMissionComplete:PlaySplashAnim(followerFrame)
	followerFrame.BoatDeathAnimations:SetCameraPosition(self.boatDeathCamPos[1], self.boatDeathCamPos[2], self.boatDeathCamPos[3]);
	followerFrame.BoatDeathAnimations:SetSpellVisualKit(self.surviveAnim);
	PlaySound(self.surviveSound);
end

function GarrisonShipyardMissionComplete:PlayExplosionAnim(followerFrame)
	followerFrame.BoatDeathAnimations:SetCameraPosition(self.boatDeathCamPos[1], self.boatDeathCamPos[2], self.boatDeathCamPos[3]);
	followerFrame.BoatDeathAnimations:SetSpellVisualKit(self.destroyAnim);
	PlaySound(self.destroySound);
end

function GarrisonShipyardMissionComplete:PlaySavedAnim(followerFrame)
	followerFrame.BoatDeathAnimations:SetCameraPosition(self.boatDeathCamPos[1], self.boatDeathCamPos[2], self.boatDeathCamPos[3]);
	followerFrame.BoatDeathAnimations:SetSpellVisualKit(self.saveAnim);
	PlaySound(self.saveSound);
end

function GarrisonShipyardMissionComplete:AnimBoatDeath(entry)
	if (self.currentMission.succeeded) then
		entry.duration = 0;
		self:AnimXP(entry);
	elseif (self.boatDeathIndex <= #self.currentMission.followers) then
		local followerFrame = self.Stage.FollowersFrame.Followers[self.boatDeathIndex];
		if (followerFrame.state == LE_FOLLOWER_MISSION_COMPLETE_STATE_ALIVE or followerFrame.state == LE_FOLLOWER_MISSION_COMPLETE_STATE_SAVED) then
			if (followerFrame.state == LE_FOLLOWER_MISSION_COMPLETE_STATE_ALIVE) then
				self:PlaySplashAnim(followerFrame);
			else
				self:PlaySavedAnim(followerFrame);
			end
			followerFrame.SurvivedAnim:Play();
			self:CheckAndShowFollowerXP(self.currentMission.followers[self.boatDeathIndex]);
		else
			self:PlayExplosionAnim(followerFrame);
			followerFrame.DestroyedAnim:Play();

			local shipName = followerFrame.Name:GetText();
			local destroyedMessage = format(GARRISON_FOLLOWER_SHIP_DESTROYED, shipName, followerFrame.shipType);
			DEFAULT_CHAT_FRAME:AddMessage(destroyedMessage, YELLOW_FONT_COLOR.r, YELLOW_FONT_COLOR.g, YELLOW_FONT_COLOR.b);
		end
		if (self.skipAnimations) then
			entry.duration = 0;
		else
			entry.duration = 1.5;
		end
	end
end

function GarrisonShipyardMissionComplete:ShowEncounterMechanics(encountersFrame, mechanicsFrame, encounterIndex)
	local numMechs, playCounteredSound = GarrisonMissionComplete.ShowEncounterMechanics(self, encountersFrame, mechanicsFrame, encounterIndex);

	GarrisonShipyardMission:SetLowFactorMechanics(mechanicsFrame, encountersFrame.enemies[encounterIndex]);

	return numMechs, playCounteredSound;
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

function GarrisonShipyardMissionComplete:AnimSkipWait(entry)
	if ( self.skipAnimations ) then
		entry.duration = 1.75;
	else
		entry.duration = 0;
	end
end

-- if duration is nil it will be set in the onStart function
-- duration is irrelevant for the last entry
local SHIPYARD_ANIMATION_CONTROL = {
	[1] = { duration = nil,		onStartFunc = GarrisonShipyardMissionComplete.AnimLine },			-- line between encounters
	[2] = { duration = nil,		onStartFunc = GarrisonMissionComplete.AnimCheckModels },			-- check that models are loaded
	[3] = { duration = nil,		onStartFunc = GarrisonShipyardMissionComplete.AnimModels },					-- model fight
	[4] = { duration = nil,		onStartFunc = GarrisonMissionComplete.AnimPlayImpactSound },		-- impact sound when follower hits
	[5] = { duration = 0.45,	onStartFunc = GarrisonShipyardMissionComplete.AnimPortrait },		-- X over portrait
	[6] = { duration = 0.75,	onStartFunc = GarrisonMissionComplete.AnimRewards },				-- reward panel
	[7] = { duration = 0,		onStartFunc = GarrisonMissionComplete.AnimLockBurst },				-- explode the lock if mission successful
	[8] = { duration = 0,		onStartFunc = GarrisonMissionComplete.AnimCleanUp },				-- clean up any model anims
	[9] = { duration = nil,		onStartFunc = GarrisonShipyardMissionComplete.AnimFollowersIn },	-- show all the mission followers
	[10] = { duration = nil,	onStartFunc = GarrisonShipyardMissionComplete.AnimBoatDeath },		-- boat death
	[11] = { duration = 0,		onStartFunc = GarrisonShipyardMissionComplete.AnimCheckBoatDeath },	-- check if there are more boat deaths to check
	[12] = { duration = nil,	onStartFunc = GarrisonShipyardMissionComplete.AnimSkipWait },		-- wait if we're in skip mode
	[13] = { duration = 0,		onStartFunc = GarrisonMissionComplete.AnimSkipNext },				-- click Next button if we're in skip mode
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
		follower.SurvivedAnim:Stop();
		follower.DestroyedAnim:Stop();
		follower.XPGain.FadeIn:Stop();
		follower.LevelUpFrame.Anim:Stop();
		if (follower.state == LE_FOLLOWER_MISSION_COMPLETE_STATE_ALIVE) then
			follower.DestroyedText:Hide();
			follower.SurvivedText:SetText(GARRISON_SHIPYARD_SHIP_SURVIVED);
			follower.SurvivedText:Show();
		elseif (follower.state == LE_FOLLOWER_MISSION_COMPLETE_STATE_SAVED) then
			follower.DestroyedText:Hide();
			follower.SurvivedText:SetText(GARRISON_SHIPYARD_SHIP_SAVED);
			follower.SurvivedText:Show();
		else
			follower.SurvivedText:Hide();
			follower.DestroyedText:Show();
		end
	end

	if (self.currentMission.failedEncounter) then
		self.encounterIndex = self.currentMission.failedEncounter;
	else
		self.encounterIndex = #self.Stage.EncountersFrame.enemies;
	end
end

function GarrisonShipyardMissionComplete:SetFollowerData(follower, name, className, classAtlas, portraitIconID, textureKit)
	follower.Name:SetText(format(GARRISON_SHIPYARD_SHIP_NAME, name));
	follower.shipType = className;
	if (follower.Name:GetNumLines() > 1) then
		follower.NameBG:SetSize(132, 33);
	else
		follower.NameBG:SetSize(132, 21);
	end

	if (textureKit) then
		local followerInfo = {textureKit=textureKit};
		self:GetParent():SetFollowerPortrait(follower, followerInfo, false, false);
	end
end

function GarrisonShipyardMissionComplete:SetFollowerLevel(followerFrame, followerInfo)
	if ( followerInfo.levelXP and followerInfo.levelXP > 0 ) then
		followerFrame.XP:SetMinMaxValues(0, followerInfo.levelXP);
		followerFrame.XP:SetValue(followerInfo.xp);
		followerFrame.XP:Show();
	else
		followerFrame.XP:Hide();
	end
	followerFrame.XP.level = followerInfo.level;
	followerFrame.XP.quality = followerInfo.quality;
	local color = FOLLOWER_QUALITY_COLORS[followerInfo.quality];
	followerFrame.Name:SetTextColor(color.r, color.g, color.b);
end

function GarrisonShipyardMissionComplete:DetermineFailedEncounter(missionID, succeeded, followerDeaths)
	if ( succeeded ) then
		self.currentMission.failedEncounter = nil;
		if (self.currentMission.offeredGarrMissionTextureID and self.currentMission.offeredGarrMissionTextureID ~= 0) then
			table.insert(self.pendingFogLift, self.currentMission.offeredGarrMissionTextureID);
		end
	else
		-- Pick the last encounter to fail, since the last one is guaranteed to be a ship
		self.currentMission.failedEncounter = #self.Stage.EncountersFrame.enemies;

		-- mark whether each follower survived or died
		local followersFrame = self.Stage.FollowersFrame;
		for i = 1, #followersFrame.Followers do
			local followerID = self.currentMission.followers[i];
			followersFrame.Followers[i].state = LE_FOLLOWER_MISSION_COMPLETE_STATE_ALIVE;
			for j = 1, #followerDeaths do
				if (followerID == followerDeaths[j].followerID) then
					followersFrame.Followers[i].state = followerDeaths[j].state;
					break;
				end
			end
		end
		self:GetParent():CheckFollowerCount();
	end
end

---------------------------------------------------------------------------------
--- Shipyard Map Mission List                                                 ---
---------------------------------------------------------------------------------

function GarrisonShipyardMap_OnLoad(self)
	self.missions = {};
	self.missionFrames = {};
	self.bonusFrames = {};
	self.pendingBonusArea = {};

	self:RegisterEvent("GARRISON_MISSION_LIST_UPDATE");
	self:RegisterEvent("GARRISON_RANDOM_MISSION_ADDED");
	self:RegisterEvent("GARRISON_MISSION_STARTED");
	self:RegisterEvent("GARRISON_MISSION_AREA_BONUS_ADDED");
end

function GarrisonShipyardMap_OnEvent(self, event, ...)
	if (event == "GARRISON_MISSION_LIST_UPDATE" or event == "GARRISON_RANDOM_MISSION_ADDED") then
		local followerTypeID = ...;
		if (followerTypeID == self.followerTypeID) then
			GarrisonShipyardMap_UpdateMissions();
			GarrisonShipyardMap_CheckTutorials();
		end
	elseif (event == "GARRISON_MISSION_AREA_BONUS_ADDED") then
		local bonusAbilityID = ...;
		GarrisonShipyardMap_UpdateMissions();
		GarrisonShipyardMap_CheckTutorials();
		table.insert(self.pendingBonusArea, bonusAbilityID);
	elseif (event == "GARRISON_MISSION_STARTED") then
		local followerTypeID, missionID = ...;
		if (followerTypeID == self.followerTypeID) then
			GarrisonShipyardMap_UpdateMissions();
			for i=1, #self.missionFrames do
				if (self.missionFrames[i].info.missionID == missionID) then
					self.missionFrames[i].ShipMissionStartAnim:Play();
					break;
				end
			end
		end
	end
end

function GarrisonShipyardMap_OnShow(self)
	self:GetParent():GetParent():CheckCompleteMissions(true);
	GarrisonShipyardMap_UpdateMissions();
	self:GetParent():GetParent().FollowerList:Hide();
	self:GetParent():GetParent():CheckPendingFogLift();
	self:GetParent():GetParent():CheckPendingBonusAreaAdded();
	GarrisonShipyardMap_CheckTutorials();
end

function GarrisonShipyardMap_OnHide(self)
	if ( GarrisonMissionTutorialFrame:GetParent() == self ) then
		GarrisonMissionTutorialFrame:Hide();
	end
	GarrisonShipFollowerPlacer:SetScript("OnUpdate", nil);
end

function GarrisonBonusEffectFrame_Set(frame, icon, name, description)
	frame.Icon:SetTexture(icon);
	frame.Name:SetText(name);
	frame.Description:SetText(description);
	frame:SetHeight(frame.Name:GetHeight() + frame.Description:GetHeight() + frame.yspacing);
end

function GarrisonBonusArea_Set(bonusArea, timeLeftStr, timeLeft, icon, name, description)
	bonusArea.TimeLeft:SetFormattedText(timeLeftStr, SecondsToTime(timeLeft));
	GarrisonBonusEffectFrame_Set(bonusArea.BonusEffectFrame, icon, name, description);
	bonusArea:SetHeight(bonusArea.Title:GetHeight() + bonusArea.TimeLeft:GetHeight() + bonusArea.BonusEffectFrame:GetHeight() + bonusArea.yspacing);
	bonusArea:Show();
end

function GarrisonShipyardMap_OnUpdate(self)
	local timeNow = GetTime();
	for i = 1, #self.missions do
		if ( self.missions[i].offerEndTime and self.missions[i].offerEndTime <= timeNow ) then
			GarrisonShipyardMap_UpdateMissions();
			break;
		elseif ( self.missions[i].inProgress ) then
			GarrisonShipyardMap_UpdateMissionTime(self.missionFrames[i]);
		end
	end

	-- Don't show tooltip if mousing over a mission
	if (GarrisonShipyardMapMissionTooltip:IsShown()) then
		GarrisonBonusAreaTooltip:Hide();
		return;
	end

	-- Check to see if mouse is in one or more bonus area circles
	local cursorX, cursorY = GetCursorPosition();
	cursorX = cursorX / UIParent:GetScale();
	cursorY = cursorY / UIParent:GetScale();

	local bonusAreaTooltipIndex = 1;
	local tooltipHeight = 0;
	GarrisonBonusAreaTooltip:ClearAllPoints();

	for i=1, #self.bonusFrames do
		local bonusFrame = self.bonusFrames[i];

		if (bonusFrame:IsShown()) then
			-- Remove bonus area if expired and refresh map
			if(bonusFrame.startTime + bonusFrame.duration < GetServerTime()) then
				bonusFrame:SetScript("OnUpdate", nil);
				bonusFrame:Hide();
				GarrisonBonusAreaTooltip:Hide();
				GarrisonShipyardMap_UpdateMissions();
				return;
			end

			local centerX = bonusFrame:GetLeft() + bonusFrame.radius;
			local centerY = bonusFrame:GetTop() - bonusFrame.radius;
			local xDiff = cursorX - centerX;
			local yDiff = cursorY - centerY;
			local distSquared = xDiff * xDiff + yDiff * yDiff;

			local tooltip = GarrisonBonusAreaTooltip;
			local bonusArea = tooltip.BonusAreas[bonusAreaTooltipIndex];
			if (distSquared < (bonusFrame.radius * bonusFrame.radius)) then
				if (not bonusArea) then
					bonusArea = CreateFrame("FRAME", "GarrisonBonusAreaTooltipFrame" .. bonusAreaTooltipIndex, tooltip, "GarrisonBonusAreaTooltipFrameTemplate");
					bonusArea:SetPoint("TOPLEFT", tooltip.BonusAreas[bonusAreaTooltipIndex - 1], "BOTTOMLEFT");
					tooltip.BonusAreas[bonusAreaTooltipIndex] = bonusArea;
				end
				tooltip:SetPoint("BOTTOMLEFT", bonusFrame, "TOP", 15, 0);

				local timeLeftSeconds = bonusFrame.startTime - GetServerTime() + bonusFrame.duration;
				GarrisonBonusArea_Set(bonusArea, GARRISON_BONUS_EFFECT_TIME_LEFT, timeLeftSeconds, bonusFrame.icon, bonusFrame.name, bonusFrame.description);
				tooltipHeight = tooltipHeight + bonusArea:GetHeight();
				bonusAreaTooltipIndex = bonusAreaTooltipIndex + 1;
			end
		end
	end
	for i=bonusAreaTooltipIndex, #GarrisonBonusAreaTooltip.BonusAreas do
		GarrisonBonusAreaTooltip.BonusAreas[i]:Hide();
	end
	if (tooltipHeight > 0) then
		GarrisonBonusAreaTooltip:SetHeight(tooltipHeight);
		GarrisonBonusAreaTooltip:Show();
	else
		GarrisonBonusAreaTooltip:Hide();
	end
end

local fogData =
{
	["NavalMap-Alliance"] =		{anchor="BOTTOMRIGHT",	leftOffset=48, rightOffset=0, topOffset=-36, bottomOffset=0},
	["NavalMap-Horde"] =		{anchor="TOPLEFT", 		leftOffset=0, rightOffset=-52, topOffset=0, bottomOffset=45},
	["NavalMap-IronHorde"] = 	{anchor="TOPRIGHT", 	leftOffset=70, rightOffset=0, topOffset=0, bottomOffset=42},
	["NavalMap-OpenWaters"] =	{anchor="BOTTOMLEFT", 	leftOffset=0, rightOffset=-82, topOffset=-70, bottomOffset=0},
};

function GarrisonShipyardMap_SetupFog(self, siegeBreakerFrame, offeredGarrMissionTextureID)
	if (offeredGarrMissionTextureID and offeredGarrMissionTextureID ~= 0) then
		siegeBreakerFrame:SetFrameLevel(self.FogFrames[1]:GetFrameLevel() + 1); -- Set siegebreaker mission above fog
		for i=1, #self.FogFrames do
			-- Skip if we are already showing this fog
			if (self.FogFrames[i].offeredGarrMissionTextureID == offeredGarrMissionTextureID and self.FogFrames[i]:IsShown()) then
				self.FogFrames[i].missionFrame = siegeBreakerFrame;
				return;
			end
		end
		for i=1, #self.FogFrames do
			local fogFrame = self.FogFrames[i];
			if (not self.FogFrames[i]:IsShown()) then
				local textureKit, posX, posY = C_Garrison.GetMissionTexture(offeredGarrMissionTextureID);
				local atlasFog = textureKit .. "-Fog";
				local atlasHighlight = textureKit .. "-Highlight";

				fogFrame.missionFrame = siegeBreakerFrame;
				fogFrame.offeredGarrMissionTextureID = offeredGarrMissionTextureID;
				fogFrame.FogTexture:SetAtlas(atlasFog, true);
				fogFrame.HighlightAnimTexture:SetAtlas(atlasHighlight, true);
				fogFrame.FogAnimTexture:SetAtlas(atlasFog, true);
				fogFrame.HighlightGlowAnimTexture:SetAtlas(atlasHighlight, true);

				local anchorPoint = fogData[textureKit].anchor;
				fogFrame.leftOffset = fogData[textureKit].leftOffset;
				fogFrame.rightOffset = fogData[textureKit].rightOffset;
				fogFrame.topOffset = fogData[textureKit].topOffset;
				fogFrame.bottomOffset = fogData[textureKit].bottomOffset;
				fogFrame.MapFogFadeOutAnim.ScaleAnim:SetOrigin(anchorPoint, 0, 0);
				fogFrame:ClearAllPoints();
				fogFrame:SetPoint(anchorPoint, self.MapTexture, anchorPoint, 0, 0);
				fogFrame:SetSize(fogFrame.FogTexture:GetSize());
				fogFrame:Show();
				break;
			end
		end
	else
		siegeBreakerFrame:SetFrameLevel(self.FogFrames[1]:GetFrameLevel() - 2); -- Set regular missions below fog and bonus circles
	end
end

function GarrisonShipyardMap_OnFogFrameUpdate(self)
	-- We need to manually show the highlight texture so that the ship mission buttons on
	-- the map can still consume the mouse enter events -->
	local shown =  self.FogTexture:IsShown() and
				   not self:GetParent():GetParent():GetParent().MissionComplete:IsShown() and
				   not self:GetParent().CompleteDialog:IsShown() and
				   self:IsMouseOver(self.topOffset, self.bottomOffset, self.leftOffset, self.rightOffset);

	if (shown) then
		self.missionFrame.FogHighlight:Show();
		if (not self.missionFrame.InProgressIcon:IsShown() and not self.missionFrame.SiegeBreakerHighlightAnim:IsPlaying()) then
			self.missionFrame.SiegeBreakerHighlightAnim:Play();
		end
	else
		self.missionFrame.FogHighlight:Hide();
		self.missionFrame.SiegeBreakerHighlightAnim:Stop();
	end
end

function GarrisonShipyardMap_UpdateMissionTime(frame)
	local timeLeftSec = frame.info.missionEndTime - GetServerTime();
	if ( timeLeftSec > 0 ) then
		frame.TimerText:SetText(SecondsToTime(timeLeftSec, false, false, 1));
	else
		frame.TimerText:SetText(format(D_SECONDS, 0));
	end

	if( timeLeftSec > 1800 ) then -- 30 minutes
		frame.TimerText:SetTextColor(1,1,1); -- white
	else
		frame.TimerText:SetTextColor(0.1765, 1, 0.0549); -- green
	end
end

function GarrisonShipyardMap_SetupBonus(self, missionFrame, mission)
	if (mission.type == "Ship-Bonus") then
		missionFrame.bonusRewardArea = true;
		for id, reward in pairs(mission.rewards) do
			local posX = reward.posX or 0;
			local posY = reward.posY or 0;
			posY = posY * -1;
			missionFrame.BonusAreaEffect:SetAtlas(reward.textureKit, true);
			missionFrame.BonusAreaEffect:ClearAllPoints();
			missionFrame.BonusAreaEffect:SetPoint("CENTER", self.MapTexture, "TOPLEFT", posX, posY);
			break;
		end
	else
		missionFrame.bonusRewardArea = nil;
		missionFrame.BonusAreaEffect:Hide();
	end
end

function GarrisonShipyardMap_SetClampedPosition(frame, mission, moveX, moveY)
	mission.adjustedPosX = mission.adjustedPosX + moveX;
	mission.adjustedPosY = mission.adjustedPosY + moveY;
	local mapTexture = GarrisonShipyardFrame.MissionTab.MissionList.MapTexture;

	-- Clamp adjusted coordinates to within 40 pixels of the border
	if (mission.adjustedPosX < 40) then
		mission.adjustedPosX = 40;
	elseif (mission.adjustedPosX > mapTexture:GetWidth() - 40) then
		mission.adjustedPosX = mapTexture:GetWidth() - 40;
	end
	if (mission.adjustedPosY > -40) then
		mission.adjustedPosY = -40;
	elseif (mission.adjustedPosY < -(mapTexture:GetHeight() - 40)) then
		mission.adjustedPosY = -(mapTexture:GetHeight() - 40);
	end
	frame:SetPoint("CENTER", mapTexture, "TOPLEFT", mission.adjustedPosX, mission.adjustedPosY);
end

-- For each mission, loop through all other missions. For any mission that overlaps with
-- my location, move both missions away from each other
function GarrisonShipyardMap_AdjustMissionPositions()
	local self = GarrisonShipyardFrame.MissionTab.MissionList;
	-- Missions can overlap by up to distBuffer before we push them away from each other
	local distBuffer = 10;
	local distBufferSquared = distBuffer * distBuffer;
	for i = 1, #self.missions do
		local frameA = self.missionFrames[i];
		if (frameA:IsShown()) then
			local missionA = self.missions[i];
			local radiusA = frameA:GetWidth() / 2;
			for j = 1, #self.missions do
				local frameB = self.missionFrames[j];
				if (i ~= j and frameB:IsShown()) then
					local missionB = self.missions[j];
					local distX = missionB.adjustedPosX - missionA.adjustedPosX;
					local distY = missionB.adjustedPosY - missionA.adjustedPosY;
					local distSquared = distX * distX + distY * distY;

					local radiusB = frameB:GetWidth() / 2;
					local minDistSquared = (radiusA + radiusB) * (radiusA + radiusB);
					if (distSquared + distBufferSquared < minDistSquared) then
						local minDist = math.sqrt(minDistSquared);
						local dist = math.sqrt(distSquared);
						-- We want to move each frame by half the amount that they overlap, minus the buffer space
						local distToMove = (minDist - dist - distBuffer / 2) / 2;

						-- Unit vector from center of frameA to center of frameB
						local vectorX = distX / dist;
						local vectorY = distY / dist;
						GarrisonShipyardMap_SetClampedPosition(frameA, missionA, -vectorX * distToMove, -vectorY * distToMove);
						GarrisonShipyardMap_SetClampedPosition(frameB, missionB, vectorX * distToMove, vectorY * distToMove);
					end
				end
			end
		end
	end
end

function GarrisonShipyardMap_UpdateMissions()
	local self = GarrisonShipyardFrame.MissionTab.MissionList;

	local inProgressMissions = C_Garrison.GetInProgressMissions(Enum.GarrisonFollowerType.FollowerType_6_2);
	C_Garrison.GetAvailableMissions(self.missions, Enum.GarrisonFollowerType.FollowerType_6_2);
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

		GarrisonShipyardMap_SetupFog(self, frame, mission.offeredGarrMissionTextureID);
		GarrisonShipyardMap_SetupBonus(self, frame, mission);

		-- If we have a siegebreaker mission that cannot be started, hide it
		if (mission.offeredGarrMissionTextureID ~= 0 and not mission.inProgress and not mission.canStart) then
			frame:Hide();
		else
			mission.mapPosX = mission.mapPosX;
			mission.mapPosY = -mission.mapPosY;
			mission.adjustedPosX = mission.mapPosX;
			mission.adjustedPosY = mission.mapPosY;
			frame:SetPoint("CENTER", self.MapTexture, "TOPLEFT", mission.mapPosX, mission.mapPosY);
			frame.info = mission;
			frame:SetHitRectInsets(10, 10, 10, 10);

			local mapAtlas = mission.typeTextureKit;

			if (mission.inProgress) then
				table.sort(mission.followers);
				local followerInfo = C_Garrison.GetFollowerInfo(mission.followers[1]);
				mapAtlas = mapAtlas .. "-MapBadge";
				local inProgressAtlas = followerInfo.textureKit .. "-Map";
				frame.Icon:SetAtlas(inProgressAtlas, true);
				frame.HighlightIcon:SetAtlas(inProgressAtlas, true);
				frame.FogHighlight:SetAtlas(inProgressAtlas, true);
				frame.InProgressIcon:SetAtlas(mapAtlas, true);
				frame.InProgressIcon:Show();
				frame.TimerBG:Show();
				frame.TimerText:Show();
				GarrisonShipyardMap_UpdateMissionTime(frame);
				frame.GlowRing:Show();
				frame.InProgressBoatPulseAnim:Play();
				frame.RareMissionAnim:Stop();
				frame.BonusMissionPulse:Stop();
				frame.BonusMissionAnim:Stop();
				frame:SetSize(83, 72);
			else
				mapAtlas = mapAtlas .. "-Map";
				frame.Icon:SetAtlas(mapAtlas, true);
				frame.HighlightIcon:SetAtlas(mapAtlas, true);
				frame.FogHighlight:SetAtlas(mapAtlas, true);
				frame.InProgressIcon:Hide();
				frame.TimerBG:Hide();
				frame.TimerText:Hide();
				frame.GlowRing:Hide();
				frame.InProgressBoatPulseAnim:Stop();
				if (mission.isRare) then
					frame.RareMissionAnim:Play();
				else
					frame.RareMissionAnim:Stop();
				end
				if (frame.bonusRewardArea) then
					frame.BonusMissionPulse:Play();
				else
					frame.BonusMissionPulse:Stop();
				end
				if (mission.hasBonusEffect) then
					frame.BonusMissionAnim:Play();
				else
					frame.BonusMissionAnim:Stop();
				end

				frame:SetSize(64, 64);
			end

			frame:Show();
		end
	end

	GarrisonShipyardMap_AdjustMissionPositions();

	-- Hide the rest of the frames that we have cached but are not used
	for j = #self.missions + 1, #self.missionFrames do
		self.missionFrames[j]:Hide();
	end

	GarrisonShipyardMap_UpdateBonusEffects();
	if (self.CompleteDialog:IsShown()) then
		self.CompleteDialog:Raise();
	end
end

function GarrisonMissionFrame_OnCloseShipyardTutorial()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	GarrisonMissionTutorialFrame:Hide();
	GarrisonShipyardMap_CheckTutorials();
end

function GarrisonShipyardMap_ShowTutorial(missionFrame, text)
	local tutorialFrame = GarrisonMissionTutorialFrame;
	tutorialFrame:SetParent(GarrisonShipyardFrame.MissionTab.MissionList);
	tutorialFrame:SetFrameStrata("DIALOG");
	tutorialFrame:SetPoint("TOPLEFT", GarrisonShipyardFrame, 0, -21);
	tutorialFrame:SetPoint("BOTTOMRIGHT", GarrisonShipyardFrame);
	tutorialFrame:Show();

	local helpTipInfo = {
		text = text,
		buttonStyle = HelpTip.ButtonStyle.Next,
		targetPoint = HelpTip.Point.TopEdgeCenter,
		offsetY = -8,
		onAcknowledgeCallback = GarrisonMissionFrame_OnCloseShipyardTutorial,
	};
	HelpTip:Show(tutorialFrame, helpTipInfo, missionFrame);
end

function GarrisonShipyardMap_CheckTutorials()
	if not GarrisonShipyardFrame:IsShown() then
		return;
	end
	local missionList = GarrisonShipyardFrame.MissionTab.MissionList;
	if ( missionList.CompleteDialog:IsShown() or GarrisonShipyardFrame.MissionComplete:IsShown() or
		(GarrisonMissionTutorialFrame:GetParent() == missionList and GarrisonMissionTutorialFrame:IsShown()) ) then
		return;
	end
	for i = 1, #missionList.missions do
		local mission = missionList.missions[i];
		local missionFrame = missionList.missionFrames[i];

		if ( tonumber(GetCVar("shipyardMissionTutorialFirst")) == 0 ) then
			GarrisonShipyardMap_ShowTutorial(missionFrame, GARRISON_SHIPYARD_MISSION_TUTORIAL_FIRST);
			SetCVar("shipyardMissionTutorialFirst", 1);
			return;
		elseif ( mission.offeredGarrMissionTextureID and mission.offeredGarrMissionTextureID ~= 0 and
			 tonumber(GetCVar("shipyardMissionTutorialBlockade")) == 0 ) then
			GarrisonShipyardMap_ShowTutorial(missionFrame, GARRISON_SHIPYARD_MISSION_TUTORIAL_BLOCKADE);
			SetCVar("shipyardMissionTutorialBlockade", 1);
			return;
		elseif ( missionFrame.bonusRewardArea and tonumber(GetCVar("shipyardMissionTutorialAreaBuff")) == 0 ) then
			GarrisonShipyardMap_ShowTutorial(missionFrame, GARRISON_SHIPYARD_MISSION_TUTORIAL_AREABUFF);
			SetCVar("shipyardMissionTutorialAreaBuff", 1);
			return;
		end
	end
	GarrisonMissionTutorialFrame:Hide();
end

function GarrisonShipyardMap_UpdateBonusEffects()
	local self = GarrisonShipyardFrame.MissionTab.MissionList;
	self.bonusEffects = C_Garrison.GetAllBonusAbilityEffects(Enum.GarrisonFollowerType.FollowerType_6_2);
	for i=1, #self.bonusEffects do
		local bonus = self.bonusEffects[i];

		-- Cache bonus effect frames
		local bonusFrame = self.bonusFrames[i];
		if (not bonusFrame) then
			bonusFrame = CreateFrame("FRAME", "GarrisonShipyardBonusAreaFrame" .. i, self, "GarrisonShipyardBonusAreaFrameTemplate");
			self.bonusFrames[i] = bonusFrame;
		end

		bonusFrame.CircleTexture:SetAtlas(bonus.textureKit, true);
		bonusFrame.CirclePulse:SetAtlas(bonus.textureKit, true);
		bonusFrame.CirclePulse:Show();
		bonusFrame.CircleTexture:SetAlpha(0.5);
		if (bonus.textureKit == "NavalMap-SmallBonusCircle") then
			bonusFrame.CircleGlowTrails:SetSize(144, 144);
		else
			bonusFrame.CircleGlowTrails:SetSize(190, 190);
		end
		bonusFrame:SetSize(bonusFrame.CircleTexture:GetSize());
		bonusFrame.icon = bonus.icon;
		bonusFrame.bonusAbilityID = bonus.bonusAbilityID;
		bonusFrame.startTime = bonus.startTime;
		bonusFrame.duration = bonus.duration;
		bonusFrame.radius = bonus.radius;
		bonusFrame.name = bonus.name;
		bonusFrame.description = bonus.description;
		bonusFrame:SetPoint("CENTER", self.MapTexture, "TOPLEFT", bonus.posX, -bonus.posY);
		bonusFrame:SetFrameLevel(self.FogFrames[1]:GetFrameLevel() - 1);
		bonusFrame.CircleGlowTrails:Show();
		bonusFrame.BonusMissionAnim:Play();
		bonusFrame:Show();
	end

	-- Hide the rest of the frames that we have cached but are not used
	for i = #self.bonusEffects + 1, #self.bonusFrames do
		self.bonusFrames[i]:Hide();
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

	GarrisonShipyardMapMissionTooltip:ClearAllPoints();
	GarrisonShipyardMapMissionTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", -10, -10);
	GarrisonShipyardMapMission_SetTooltip(self.info, self.info.inProgress);

	-- If this is a bonus mission, show the bonus area
	if (self.bonusRewardArea) then
		self.BonusAreaEffect:Show();
	end
end

function GarrisonShipyardMapMission_UpdateTooltipSize(self)
	local tooltipFrame = self;
	--
	-- Calculate the width
	--
	local tooltipWidth = 0;

	if (tooltipFrame.ItemTooltip:IsShown()) then
		tooltipWidth = max(tooltipWidth,  tooltipFrame.ItemTooltip.Tooltip:GetWidth() + 54);
	end

	if (GarrisonMissionListTooltipThreatsFrame:IsShown()) then
		tooltipWidth = max(tooltipWidth, GarrisonMissionListTooltipThreatsFrame:GetWidth());
	end

	local textNaturalWrapWidth = 250;
	if (tooltipWidth < textNaturalWrapWidth) then
		local maxTextWidth = 0;

		for i=1, #tooltipFrame.Ships do
			if (tooltipFrame.Ships[i]:IsShown()) then
				maxTextWidth = max(maxTextWidth, tooltipFrame.Ships[i]:GetStringWidth() + 20);
			end
		end
		for i=1, #tooltipFrame.Lines do
			if (tooltipFrame.Lines[i]:IsShown()) then
				maxTextWidth = max(maxTextWidth, tooltipFrame.Lines[i]:GetStringWidth() + 20);
			end
		end
		for i=1, #tooltipFrame.BonusEffects do
			if (tooltipFrame.BonusEffects[i]:IsShown()) then
				maxTextWidth = max(maxTextWidth, tooltipFrame.BonusEffects[i].Name:GetStringWidth() + 52); -- 52 to accomodate margins and icon
				maxTextWidth = max(maxTextWidth, tooltipFrame.BonusEffects[i].Description:GetStringWidth() + 52);
			end
		end
		if (tooltipFrame.BonusReward:IsShown()) then
			maxTextWidth = max(maxTextWidth, tooltipFrame.BonusReward.Name:GetStringWidth() + 48); -- 48 to accomodate margins and icon
			maxTextWidth = max(maxTextWidth, tooltipFrame.BonusReward.Description:GetStringWidth() + 48);
		end

		-- cap the width based on the strings to textNaturalWrapWidth
		maxTextWidth = min(maxTextWidth, textNaturalWrapWidth);
		tooltipWidth = max(maxTextWidth, tooltipWidth);
	end

	GarrisonShipyardMapMission_SetTooltipWidth(tooltipFrame, tooltipWidth);

	--
	-- Calculate the height:
	--
	local tooltipHeight = 10; -- bottom border
	for i=1, #tooltipFrame.Ships do
		if (tooltipFrame.Ships[i]:IsShown()) then
			tooltipHeight = tooltipHeight + tooltipFrame.Ships[i]:GetHeight() + tooltipFrame.Ships[i].yspacing;
		end
	end
	for i=1, #tooltipFrame.Lines do
		if (tooltipFrame.Lines[i]:IsShown()) then
			tooltipHeight = tooltipHeight + tooltipFrame.Lines[i]:GetHeight() + tooltipFrame.Lines[i].yspacing;
		end
	end
	if (tooltipFrame.ItemTooltip:IsShown()) then
		tooltipHeight = tooltipHeight + tooltipFrame.ItemTooltip:GetHeight() + tooltipFrame.ItemTooltip.yspacing;
	end
	for i=1, #tooltipFrame.BonusEffects do
		if (tooltipFrame.BonusEffects[i]:IsShown()) then
			tooltipHeight = tooltipHeight + tooltipFrame.BonusEffects[i]:GetHeight() + tooltipFrame.BonusEffects[i].yspacing;
		end
	end
	if (tooltipFrame.BonusReward:IsShown()) then
		tooltipHeight = tooltipHeight + tooltipFrame.BonusReward:GetHeight() + tooltipFrame.BonusReward.yspacing;
	end
	if (GarrisonMissionListTooltipThreatsFrame:IsShown()) then
		tooltipHeight = tooltipHeight + GarrisonMissionListTooltipThreatsFrame:GetHeight() + GarrisonMissionListTooltipThreatsFrame.yspacing;
	end

	tooltipFrame:SetHeight(tooltipHeight);
end

function GarrisonShipyardMapMission_SetTooltip(info, inProgress)
	local tooltipFrame = GarrisonShipyardMapMissionTooltip;
	tooltipFrame.Name:SetText(info.name);
	GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.Name);

	tooltipFrame.RareMission:SetShown(info.isRare);
	tooltipFrame.InProgress:SetShown(inProgress);
	tooltipFrame.InProgressTimeLeft:SetShown(inProgress and not info.isComplete);
	tooltipFrame.SuccessChance:SetShown(inProgress);
	tooltipFrame.Description:SetShown(not inProgress);
	tooltipFrame.NumFollowers:SetShown(not inProgress);
	tooltipFrame.MissionDuration:SetShown(not inProgress);
	tooltipFrame.MissionExpires:SetShown(not inProgress);
	tooltipFrame.TimeRemaining:SetShown(not inProgress);

	GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.Name);
	if (info.isRare) then
		GarrisonShipyardMapMission_AnchorToBottomWidget(tooltipFrame.RareMission, 0, -tooltipFrame.RareMission.yspacing);
		GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.RareMission);
	end
	if (inProgress) then
		if(info.isComplete) then
			tooltipFrame.InProgress:SetText(COMPLETE);
		else
			tooltipFrame.InProgress:SetText(GARRISON_SHIPYARD_MSSION_INPROGRESS_TOOLTIP);
		end
		GarrisonShipyardMapMission_AnchorToBottomWidget(tooltipFrame.InProgress, 0, -tooltipFrame.InProgress.yspacing);
		GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.InProgress);
		local missionInfo = C_Garrison.GetBasicMissionInfo(info.missionID);
		GarrisonMissionListTooltipThreatsFrame:Hide();

		if (not info.isComplete and missionInfo and missionInfo.timeLeft) then
			local timeLeft = missionInfo.timeLeft;
			tooltipFrame.InProgressTimeLeft:SetText(format(GARRISON_SHIPYARD_MISSION_INPROGRESS_TIMELEFT, timeLeft));
			GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.InProgressTimeLeft);
		end

		local successChance = C_Garrison.GetMissionSuccessChance(info.missionID);
		if (successChance) then
			GarrisonShipyardMapMission_AnchorToBottomWidget(tooltipFrame.SuccessChance, 0, -tooltipFrame.SuccessChance.yspacing);
			tooltipFrame.SuccessChance:SetText(format(GARRISON_MISSION_PERCENT_CHANCE, successChance));
			GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.SuccessChance);
		else
			tooltipFrame.SuccessChance:Hide();
		end
	else
		GarrisonShipyardMapMission_AnchorToBottomWidget(tooltipFrame.Description, 0, -tooltipFrame.Description.yspacing);
		tooltipFrame.Description:SetText(info.description);

		tooltipFrame.NumFollowers:SetText(string.format(GARRISON_SHIPYARD_MISSION_TOOLTIP_NUM_REQUIRED_FOLLOWERS, info.numFollowers));

		local timeString = NORMAL_FONT_COLOR_CODE .. TIME_LABEL .. FONT_COLOR_CODE_CLOSE .. " ";
		timeString = timeString .. HIGHLIGHT_FONT_COLOR_CODE .. info.duration .. FONT_COLOR_CODE_CLOSE;
		tooltipFrame.MissionDuration:SetText(timeString);
		GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.MissionDuration);

		local numThreats = GarrisonMissionButton_AddThreatsToTooltip(info.missionID, GarrisonShipyardFrame.followerTypeID, true);
		if (numThreats > 0) then
			GarrisonMissionListTooltipThreatsFrame:SetParent(tooltipFrame);
			GarrisonMissionListTooltipThreatsFrame:ClearAllPoints();
			GarrisonMissionListTooltipThreatsFrame:SetPoint("TOPLEFT", tooltipFrame.MissionDuration, "BOTTOMLEFT", 2, -12);
			GarrisonMissionListTooltipThreatsFrame.yspacing = 12;
			GarrisonMissionListTooltipThreatsFrame:Show();
			GarrisonShipyardMapMission_SetBottomWidget(GarrisonMissionListTooltipThreatsFrame, -2, 0);
		end

		if (info.isRare) then
			GarrisonShipyardMapMission_AnchorToBottomWidget(tooltipFrame.MissionExpires, 0, -tooltipFrame.MissionExpires.yspacing);
			tooltipFrame.MissionExpires:Show();
			tooltipFrame.TimeRemaining:SetText(info.offerTimeRemaining);
			tooltipFrame.TimeRemaining:Show();
			GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.TimeRemaining);
		else
			tooltipFrame.MissionExpires:Hide();
			tooltipFrame.TimeRemaining:Hide()
		end
	end

	tooltipFrame.BonusReward:Hide();
	tooltipFrame.ItemTooltip:Hide();
	tooltipFrame.Reward:Hide();
	GarrisonShipyardMapMission_AnchorToBottomWidget(tooltipFrame.RewardString, 0, -tooltipFrame.RewardString.yspacing);
	GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.RewardString);

	for id, reward in pairs(info.rewards) do
		if (reward.bonusAbilityID) then
			tooltipFrame.BonusReward.Icon:SetTexture(reward.icon);
			tooltipFrame.BonusReward.Name:SetText(reward.name);
			tooltipFrame.BonusReward.Description:SetText(reward.description);
			tooltipFrame.BonusReward:Show();
			tooltipFrame.BonusReward:SetHeight(tooltipFrame.BonusReward.Icon:GetTop() - tooltipFrame.BonusReward.Description:GetBottom());
			GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.BonusReward);
		elseif (reward.itemID) then
			EmbeddedItemTooltip_SetItemByID(tooltipFrame.ItemTooltip, reward.itemID);
			GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.ItemTooltip, -6, 0);
		elseif (reward.followerXP) then
			tooltipFrame.Reward:SetText(format(GARRISON_REWARD_XP_FORMAT, BreakUpLargeNumbers(reward.followerXP)));
			tooltipFrame.Reward:Show();
			GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.Reward);
		elseif (reward.currencyID ~= 0) then
			local currencyTexture = C_CurrencyInfo.GetCurrencyInfo(reward.currencyID).iconFileID;
			tooltipFrame.Reward:SetText(reward.quantity .. " |T" .. currencyTexture .. ":0:0:0:0|t");
			tooltipFrame.Reward:Show();
			GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.Reward);
		elseif (reward.currencyID == 0) then
			tooltipFrame.Reward:SetText(GetMoneyString(reward.quantity));
			tooltipFrame.Reward:Show();
			GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.Reward);
		end
		break;
	end

	local bonusEffects = C_Garrison.GetMissionBonusAbilityEffects(info.missionID);
	if (bonusEffects) then
		if (#bonusEffects > 0) then
			GarrisonShipyardMapMission_AnchorToBottomWidget(tooltipFrame.BonusTitle, 0, -tooltipFrame.BonusTitle.yspacing);
			tooltipFrame.BonusTitle:Show();
			GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.BonusTitle);
		else
			tooltipFrame.BonusTitle:Hide();
		end
		for i=1, #bonusEffects do
			local effectFrame = tooltipFrame.BonusEffects[i];
			if (not effectFrame) then
				effectFrame = CreateFrame("FRAME", "GarrisonBonusEffectTooltip" .. i, tooltipFrame, "GarrisonBonusEffectFrameTemplate");
				tooltipFrame.BonusEffects[i] = effectFrame;
			end
			GarrisonShipyardMapMission_AnchorToBottomWidget(effectFrame, 3, -effectFrame.yspacing);
			effectFrame.Icon:SetTexture(bonusEffects[i].icon);
			effectFrame.Name:SetText(bonusEffects[i].name);
			effectFrame.Description:SetText(bonusEffects[i].description);
			effectFrame:Show();
			GarrisonShipyardMapMission_SetBottomWidget(effectFrame, -3);
		end
		for i=#bonusEffects + 1, #tooltipFrame.BonusEffects do
			tooltipFrame.BonusEffects[i]:Hide();
		end
	end

	tooltipFrame.ShipsString:Hide();
	for i=1, #tooltipFrame.Ships do
		tooltipFrame.Ships[i]:Hide();
	end
	if (inProgress) then
		if (info.followers ~= nil) then
			GarrisonShipyardMapMission_AnchorToBottomWidget(tooltipFrame.ShipsString, 0, -tooltipFrame.ShipsString.yspacing);
			tooltipFrame.ShipsString:Show();
			for i=1, #(info.followers) do
				tooltipFrame.Ships[i]:SetText(format(GARRISON_SHIPYARD_SHIP_NAME, C_Garrison.GetFollowerName(info.followers[i])));
				GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.Ships[i]);
				tooltipFrame.Ships[i]:Show();
			end
		end
	end

	if (info.canStart or inProgress) then
		tooltipFrame.SiegebreakerWarning:Hide();
	else
		tooltipFrame.SiegebreakerWarning:Show();
		GarrisonShipyardMapMission_AnchorToBottomWidget(tooltipFrame.SiegebreakerWarning, 0, -tooltipFrame.SiegebreakerWarning.yspacing);
		GarrisonShipyardMapMission_SetBottomWidget(tooltipFrame.SiegebreakerWarning);
	end

	GarrisonShipyardMapMission_UpdateTooltipSize(tooltipFrame);

	tooltipFrame:Show();
end

function GarrisonShipyardMapMission_SetTooltipWidth(tooltip, width)
	tooltip:SetWidth(width);
	for i=1, #tooltip.Ships do
		tooltip.Ships[i]:SetWidth(width - 20);
	end
	for i=1, #tooltip.Lines do
		tooltip.Lines[i]:SetWidth(width - 20);
	end
	for i=1, #tooltip.BonusEffects do
		local bonusEffect = tooltip.BonusEffects[i];
		bonusEffect.Name:SetWidth(width - 52);
		bonusEffect.Description:SetWidth(width - 52);
		bonusEffect:SetSize(width - 20, bonusEffect.Name:GetHeight() + bonusEffect.Description:GetHeight() + 8);
		--bonusEffect:SetHeight(bonusEffect.Icon:GetTop() - bonusEffect.Description:GetBottom());
	end
end

local bottomWidget = {};

function GarrisonShipyardMapMission_SetBottomWidget(widget, x, y)
	bottomWidget.widget = widget;
	bottomWidget.x = x or 0;
	bottomWidget.y = y or 0;
end

function GarrisonShipyardMapMission_AnchorToBottomWidget(widget, x, y)
	widget:SetPoint("TOPLEFT", bottomWidget.widget, "BOTTOMLEFT", bottomWidget.x + x, bottomWidget.y + y);
end

function GarrisonShipyardMapMission_OnLeave(self, button)
	GarrisonShipyardMapMissionTooltip:Hide();
	if (self.bonusRewardArea) then
		self.BonusAreaEffect:Hide();
	end
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
	self.BuffsFrame.BuffsBG:SetAtlas("ShipMission_PartyBuffsBG");
	self.RewardsFrame.MissionXP:SetPoint("BOTTOM", self.RewardsFrame, "TOP", 0, 4);
end

function GarrisonShipyardMissionPage_OnEvent(self, event, ...)
	local mainFrame = self:GetParent():GetParent();
	if ( event == "GARRISON_FOLLOWER_LIST_UPDATE" or event == "GARRISON_FOLLOWER_XP_CHANGED" ) then
		local followerTypeID = ...;
		if (followerTypeID == mainFrame.followerTypeID) then
			mainFrame:UpdateMissionParty(self.Followers);
			if ( self.missionInfo ) then
				mainFrame:GetFollowerBuffsForMission(self.missionInfo.missionID);
				mainFrame.FollowerList:UpdateFollowers();
				mainFrame:UpdateMissionData(self);
				mainFrame:UpdateMissionParty(self.Followers);
				self:SetCounters(self.Followers, self.Enemies, self.missionInfo.missionID);
			end
		end
	end
	mainFrame:UpdateStartButton(self);
end

function GarrisonShipyardMissionPage_OnShow(self)
	local mainFrame = self:GetParent():GetParent();
	mainFrame.FollowerList:SetSortFuncs(GarrisonFollowerOptions[mainFrame.followerTypeID].missionFollowerSortFunc, GarrisonFollowerOptions[mainFrame.followerTypeID].missionFollowerInitSortFunc);
	mainFrame.FollowerList.showCounters = true;
	mainFrame.FollowerList.canExpand = true;
	mainFrame.FollowerList:Show();
	mainFrame:UpdateStartButton(self);
end

function GarrisonShipyardMissionPage_OnHide(self)
	local mainFrame = self:GetParent():GetParent();
	mainFrame.FollowerList.showCounters = false;
	mainFrame.FollowerList.canExpand = false;
	mainFrame.FollowerList:SetSortFuncs(GarrisonGarrisonFollowerList_DefaultSort, GarrisonFollowerList_InitializeDefaultSort);
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
		else
			if ( pulsed ) then
				followerFrame.PulseAnim:Stop();
			else
				followerFrame.PulseAnim:Play();
				pulsed = true;
			end
		end
	end
end

GarrisonShipyardFollowerTabMixin = { }

function GarrisonShipyardFollowerTabMixin:GetFollowerList()
	return self:GetParent():GetFollowerList();
end

---------------------------------------------------------------------------------
--- Garrison Shipyard Follower List Mixin Functions                           ---
---------------------------------------------------------------------------------

GarrisonShipyardFollowerList = {};

function GarrisonShipyardFollowerList:Initialize(followerType, followerTab)
	self.followerTab = followerTab or self:GetParent().FollowerTab;
	self.followerTab.followerList = self;
	self:Setup(self:GetParent(), followerType, "GarrisonShipFollowerButtonTemplate", 12);
end

function GarrisonShipyardFollowerList:OnEvent(event, ...)
	if (event == "GARRISON_FOLLOWER_UPGRADED") then
		if ( self.followerTab and self.followerTab.followerID and self.followerTab:IsVisible() ) then
			local followerID = ...;
			if ( followerID == self.followerTab.followerID ) then
				self.followerTab.Model:SetSpellVisualKit(6375);	-- level up visual;
				PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_FOLLOWER_LEVEL_UP);
			end
		end

		return true;
	end

	return GarrisonFollowerList.OnEvent(self, event, ...);
end

function GarrisonShipyardFollowerList:StopAnimations()
	local followerFrame = self.followerTab;
	for i = 1, #followerFrame.EquipmentFrame.Equipment do
		GarrisonEquipment_StopAnimations(followerFrame.EquipmentFrame.Equipment[i]);
	end
end

function GarrisonShipyardFollowerList:ShowThreatCountersFrame()
	self.followerTab.ThreatCountersFrame:Show();
end

function GarrisonShipyardFollowerList:UpdateValidSpellHighlight(followerID, followerInfo)
	local followerTab = self.followerTab;
	for i=1, #followerTab.EquipmentFrame.Equipment do
		followerTab.EquipmentFrame.Equipment[i].ValidSpellHighlight:Hide();
	end
	local index = 1;
	for i=1, #followerInfo.abilities do
		local ability = followerInfo.abilities[i];
		if (not ability.isTrait) then
			if (index <= #followerTab.EquipmentFrame.Equipment) then
				local equipment = followerTab.EquipmentFrame.Equipment[index];
				if (followerInfo.status ~= GARRISON_FOLLOWER_WORKING and followerInfo.status ~= GARRISON_FOLLOWER_ON_MISSION and
					(SpellCanTargetGarrisonFollowerAbility(followerID, ability.id) or ItemCanTargetGarrisonFollowerAbility(followerID, ability.id))) then
					equipment.ValidSpellHighlight:Show();
				end
			end
			index = index + 1;
		end
	end
end

function GarrisonShipyardFollowerList:ShowFollower(followerID, hideCounters)
	local followerList = self;
	local self = self.followerTab;
	local lastUpdate = self.lastUpdate;
	local mainFrame = self:GetParent();
	local followerInfo = C_Garrison.GetFollowerInfo(followerID);
	if (not followerInfo) then
		return;
	end
	self.followerID = followerID;
	self.Portrait:Show();
	self.Model:SetAlpha(0);
	local displayInfo = followerInfo.displayIDs and followerInfo.displayIDs[1];
	GarrisonMission_SetFollowerModel(self.Model, followerInfo.followerID, displayInfo and displayInfo.id, displayInfo and displayInfo.showWeapon);
	self.Model:SetHeightFactor(followerInfo.displayHeight or 0.5);
	self.Model:SetTargetDistance(0);
	self.Model:InitializeCamera((followerInfo.displayScale or 1) * (displayInfo.followerPageScale or 1));

	local atlas = followerInfo.textureKit .. "-List";
	self.Portrait:SetAtlas(atlas, false);
	local color = FOLLOWER_QUALITY_COLORS[followerInfo.quality];
	self.BoatName:SetText(format(GARRISON_SHIPYARD_SHIP_NAME, followerInfo.name));
	self.BoatName:SetVertexColor(color.r, color.g, color.b);
	self.BoatType:SetText(followerInfo.className);
	if (followerInfo.quality == Enum.ItemQuality.Epic) then
		self.Quality:SetAtlas("ShipMission_BoatRarity-Epic", true);
	elseif (followerInfo.quality == Enum.ItemQuality.Rare) then
		self.Quality:SetAtlas("ShipMission_BoatRarity-Rare", true);
	else
		self.Quality:SetAtlas("ShipMission_BoatRarity-Uncommon", true);
	end

	-- Follower cannot be upgraded anymore
	if (followerInfo.isMaxLevel and followerInfo.quality >= GARRISON_FOLLOWER_MAX_UPGRADE_QUALITY[followerInfo.followerTypeID]) then
		self.XPLabel:Hide();
		self.XPBar:Hide();
		self.XPText:Hide();
		self.XPText:SetText("");
	else
		self.XPLabel:SetText(GARRISON_FOLLOWER_XP_UPGRADE_STRING);
		self.XPLabel:SetWidth(0);
		self.XPLabel:SetFontObject("GameFontHighlight");
		self.XPLabel:Show();
		-- If the XPLabel text does not fit within 100 pixels, shrink the font.
		if (self.XPLabel:GetWidth() > 100) then
			self.XPLabel:SetWidth(100);
			self.XPLabel:SetFontObject("GameFontWhiteSmall");
		end
		self.XPBar:Show();
		self.XPBar:SetMinMaxValues(0, followerInfo.levelXP);
		self.XPBar.Label:SetFormattedText(GARRISON_FOLLOWER_XP_BAR_LABEL, BreakUpLargeNumbers(followerInfo.xp), BreakUpLargeNumbers(followerInfo.levelXP));
		self.XPBar:SetValue(followerInfo.xp);
		local xpLeft = followerInfo.levelXP - followerInfo.xp;
		self.XPText:SetText(format(GARRISON_FOLLOWER_XP_LEFT, xpLeft));
		self.XPText:Show();
	end
	GarrisonTruncationFrame_Check(self.BoatName);

	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		self.QualityFrame:Show();
		self.QualityFrame.Text:SetText(_G["ITEM_QUALITY"..followerInfo.quality.."_DESC"]);
	else
		self.QualityFrame:Hide();
	end

	if (not followerInfo.abilities) then
		followerInfo.abilities = C_Garrison.GetFollowerAbilities(followerID);
	end

	for i=1, #self.Traits do
		self.Traits[i].abilityID = nil;
		self.Traits[i].Counter:Hide();
	end
	for i=1, #self.EquipmentFrame.Equipment do
		self.EquipmentFrame.Equipment[i].abilityID = nil;
		self.EquipmentFrame.Equipment[i].Icon:Hide();
		self.EquipmentFrame.Equipment[i].Counter:Hide();
		self.EquipmentFrame.Equipment[i].followerList = self:GetFollowerList();
		self.EquipmentFrame.Equipment[i].followerID = followerInfo.followerID;
	end
	self.EquipmentFrame.Equipment1.Lock:SetShown(followerInfo.quality < Enum.ItemQuality.Rare);
	self.EquipmentFrame.Equipment2.Lock:SetShown(followerInfo.quality < Enum.ItemQuality.Epic);

	local traitIndex = 1;
	local equipmentIndex = 1;
	for i=1, #followerInfo.abilities do
		local ability = followerInfo.abilities[i];
		if (ability.isTrait) then
			if (traitIndex <= #self.Traits) then
				local trait = self.Traits[traitIndex];
				trait.abilityID = ability.id;
				trait.Portrait:SetTexture(ability.icon);
				trait.followerTypeID = followerInfo.followerTypeID;
				if (not hideCounters) then
					for id, counter in pairs(ability.counters) do
						trait.Counter.Icon:SetTexture(counter.icon);
						trait.Counter.tooltip = counter.name;
						trait.Counter.mainFrame = mainFrame;
						trait.Counter.info = counter;
						trait.Counter.followerTypeID = followerInfo.followerTypeID;
						trait.Counter:Show();

						if (counter.factor > GARRISON_HIGH_THREAT_VALUE) then
							trait.Counter.Border:SetAtlas("GarrMission_EncounterAbilityBorder-Lg");
						else
							trait.Counter.Border:SetAtlas("GarrMission_WeakEncounterAbilityBorder-Lg");
						end
						break;
					end
				end
			end
			traitIndex = traitIndex + 1;
		else
			if (equipmentIndex <= #self.EquipmentFrame.Equipment) then
				local equipment = self.EquipmentFrame.Equipment[equipmentIndex];
				equipment.abilityID = ability.id;
				equipment.followerTypeID = followerInfo.followerTypeID;
				if (ability.icon) then
					equipment.Icon:SetTexture(ability.icon);
					equipment.Icon:Show();
					if (not hideCounters) then
						for id, counter in pairs(ability.counters) do
							equipment.Counter.Icon:SetTexture(counter.icon);
							equipment.Counter.tooltip = counter.name;
							equipment.Counter.mainFrame = mainFrame;
							equipment.Counter.info = counter;
							equipment.Counter.followerTypeID = followerInfo.followerTypeID;
							equipment.Counter:Show();

							if (counter.factor > GARRISON_HIGH_THREAT_VALUE) then
								equipment.Counter.Border:SetAtlas("GarrMission_EncounterAbilityBorder-Lg");
							else
								equipment.Counter.Border:SetAtlas("GarrMission_WeakEncounterAbilityBorder-Lg");
							end

							break;
						end
					end

					if (followerInfo.isCollected and GarrisonFollowerAbilities_IsNew(lastUpdate, followerID, ability.id, GARRISON_FOLLOWER_ABILITY_TYPE_ABILITY)) then
						equipment.EquipAnim:Play();
					else
						GarrisonEquipment_StopAnimations(equipment);
					end
				else
					equipment.Icon:Hide();
				end
			end
			equipmentIndex = equipmentIndex + 1;
		end
	end
	followerList:UpdateValidSpellHighlight(followerID, followerInfo);

	self.lastUpdate = self:IsShown() and GetTime() or nil;
end

function GarrisonShipyardFollowerList:UpdateData()
	local mainFrame = self:GetParent();
	local followers = self.followers;
	local followersList = self.followersList;
	local numFollowers = #followersList;
	local scrollFrame = self.listScroll;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	self.NoShipsLabel:SetShown(numFollowers == 0);

	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index
		if ( index <= numFollowers) then
			local follower = followers[followersList[index]];
			button.isCollected = true;
			button.id = follower.followerID;
			button.info = follower;
			button.Portrait:SetAtlas(follower.textureKit .. "-List", true);
			button.BoatName:SetText(format(GARRISON_SHIPYARD_SHIP_NAME, follower.name));
			button.BoatType:SetText(follower.className);
			button.Status:SetText(follower.status);
			button.Selection:SetShown(button.id == mainFrame.selectedFollower);

			if (follower.quality == Enum.ItemQuality.Epic) then
				button.Quality:SetAtlas("ShipMission_BoatRarity-Epic", true);
			elseif (follower.quality == Enum.ItemQuality.Rare) then
				button.Quality:SetAtlas("ShipMission_BoatRarity-Rare", true);
			else
				button.Quality:SetAtlas("ShipMission_BoatRarity-Uncommon", true);
			end

			if (follower.status) then
				button.BusyFrame:Show();
				button.BusyFrame.Texture:SetColorTexture(unpack(GARRISON_FOLLOWER_BUSY_COLOR));
			else
				button.BusyFrame:Hide();
			end

			local color = FOLLOWER_QUALITY_COLORS[follower.quality];
			button.BoatName:SetTextColor(color.r, color.g, color.b);
			if (follower.xp == 0 or follower.levelXP == 0) then
				button.XPBar:Hide();
			else
				button.XPBar:Show();
				button.XPBar:SetWidth((follower.xp/follower.levelXP) * 228);
			end

			if (self.canExpand and button.id == self.expandedFollower and button.id == mainFrame.selectedFollower) then
				self:ExpandButton(button, self);
			else
				self:CollapseButton(button);
			end

			GarrisonFollowerButton_UpdateCounters(mainFrame, button, follower, self.showCounters, mainFrame.lastUpdate);

			button:Show();
		else
			button:Hide();
		end
	end

	local extraHeight = 0;
	if ( self.expandedFollower ) then
		extraHeight = self.expandedFollowerHeight - scrollFrame.buttonHeight;
	else
		extraHeight = 0;
	end
	local totalHeight = numFollowers * scrollFrame.buttonHeight + extraHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);

	self.lastUpdate = GetTime();
end

function GarrisonShipyardFollowerList:ExpandButton(button, followerListFrame)
	local abHeight = self:ExpandButtonAbilities(button, true);
	button:SetHeight(75 + abHeight);
	followerListFrame.expandedFollowerHeight = 75 + abHeight + 6;
end

function GarrisonShipyardFollowerList:CollapseButton(button)
	self:CollapseButtonAbilities(button);
	button:SetHeight(80);
end

---------------------------------------------------------------------------------
--- Ship Follower List                                                        ---
---------------------------------------------------------------------------------

function GarrisonShipFollowerListButton_OnClick(self, button)
	local mainFrame = self:GetParent():GetParent().followerFrame;
	local followerList = self:GetParent():GetParent():GetParent();
	PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_SELECT_FOLLOWER);

	if (button == "LeftButton") then
		mainFrame.selectedFollower = self.id;

		if (followerList.canExpand) then
			if (followerList.expandedFollower == self.id) then
				followerList.expandedFollower = nil;
				PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_FOLLOWER_ABILITY_CLOSE);
			else
				followerList.expandedFollower = self.id;
				PlaySound(SOUNDKIT.UI_GARRISON_COMMAND_TABLE_FOLLOWER_ABILITY_OPEN);
			end
		elseif (followerList.expandedFollower ~= self.id ) then
			followerList.expandedFollower = nil;
		end

		followerList:UpdateData();
		followerList:ShowFollower(self.id);
	elseif (button == "RightButton" and not followerList.isLandingPage) then
			if ( GarrisonShipyardFollowerOptionDropDown.followerID ~= self.id ) then
				CloseDropDownMenus();
			end
			GarrisonShipyardFollowerOptionDropDown.followerID = self.id;
			ToggleDropDownMenu(1, nil, GarrisonShipyardFollowerOptionDropDown, "cursor", 0, 0);
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		end
end

function GarrisonShipTrait_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") ) then
		local abilityLink = C_Garrison.GetFollowerAbilityLink(self.abilityID);
		if (abilityLink) then
			ChatEdit_InsertLink(abilityLink);
		end
	end
end

function GarrisonShipTrait_OnEnter(self)
	ShowGarrisonFollowerAbilityTooltip(self, self.abilityID, Enum.GarrisonFollowerType.FollowerType_6_2);
end

function GarrisonShipTrait_OnHide(self)
	HideGarrisonFollowerAbilityTooltip(Enum.GarrisonFollowerType.FollowerType_6_2);
end

function GarrisonShipEquipment_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") and self.Icon:IsShown() ) then
		local abilityLink = C_Garrison.GetFollowerAbilityLink(self.abilityID);
		if (abilityLink) then
			ChatEdit_InsertLink(abilityLink);
		end
	elseif (self.abilityID) then
		if ( button == "LeftButton") then
			GarrisonEquipment_AddEquipment(self);
		end
	end
end

function GarrisonShipEquipment_OnEnter(self)
	if (self.Lock:IsShown()) then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		GameTooltip:SetText(GARRISON_SHIPYARD_EQUIPMENT_UPGRADE_SLOT);
		if (self.quality == "rare") then
			GameTooltip:AddLine(GARRISON_SHIPYARD_EQUIPMENT_RARE_SLOT_TOOLTIP, 1, 1, 1, true);
		else
			GameTooltip:AddLine(GARRISON_SHIPYARD_EQUIPMENT_EPIC_SLOT_TOOLTIP, 1, 1, 1, true);
		end
		GameTooltip:Show();
	elseif (self.Icon:IsShown() and self.abilityID) then
		ShowGarrisonFollowerAbilityTooltip(self, self.abilityID, Enum.GarrisonFollowerType.FollowerType_6_2);
	else
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		GameTooltip:SetText(GARRISON_SHIPYARD_EQUIPMENT_EMPTY_SLOT_TOOLTIP);
		GameTooltip:Show();
	end
end

function GarrisonShipEquipment_OnHide(self)
	GameTooltip_Hide();
	HideGarrisonFollowerAbilityTooltip(Enum.GarrisonFollowerType.FollowerType_6_2);
end

function GarrisonShipEquipment_OnReceiveDrag(self)
	if (self.abilityID) then
		GarrisonEquipment_AddEquipment(self);
	end
end

function GarrisonShipFollowerListButton_OnDragStart(self, button)
	local followerList = self:GetParent():GetParent():GetParent();
	if (followerList.isLandingPage) then
		return;
	end
	local mainFrame = self:GetParent():GetParent():GetParent():GetParent();
	mainFrame:OnDragStartFollowerButton(GarrisonShipFollowerPlacer, self, 56);
end

function GarrisonShipFollowerListButton_OnDragStop(self, button)
	local followerList = self:GetParent():GetParent():GetParent();
	if (followerList.isLandingPage) then
		return;
	end
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

	local missionPage = self:GetParent();
	local xp = C_Garrison.GetFollowerXP(self.info.followerID);
	local levelXp = C_Garrison.GetFollowerLevelXP(self.info.followerID);

	GarrisonShipyardFollowerTooltip:ClearAllPoints();
	GarrisonShipyardFollowerTooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", -50, -30);
	GarrisonFollowerTooltip_Show(self.info.garrFollowerID,
		self.info.isCollected,
		C_Garrison.GetFollowerQuality(self.info.followerID),
		C_Garrison.GetFollowerLevel(self.info.followerID),
		xp,
		levelXp,
		C_Garrison.GetFollowerItemLevelAverage(self.info.followerID),
		C_Garrison.GetFollowerSpecializationAtIndex(self.info.followerID, 1),
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
		C_Garrison.GetFollowerUnderBiasReason(missionPage.missionInfo.missionID, self.info.followerID),
		GarrisonShipyardFollowerTooltip,
		231
		);
end

function GarrisonShipMissionPageFollowerFrame_OnLeave(self)
	GarrisonShipyardFollowerTooltip:Hide();
end

---------------------------------------------------------------------------------
--- Ship Renaming                                                             ---
---------------------------------------------------------------------------------

function GarrisonShipOptionsMenu_Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;

	info.text = GARRISON_SHIP_RENAME;
	info.func = 	function() StaticPopup_Show("GARRISON_SHIP_RENAME", nil, nil, self.followerID); end
	UIDropDownMenu_AddButton(info, level);

	info.text = GARRISON_SHIP_DECOMMISSION;
	local data = {};
	data.followerID = self.followerID;
	info.func = 	function() StaticPopup_Show("GARRISON_SHIP_DECOMMISSION", nil, nil, data); end
	local followerStatus = self.followerID and C_Garrison.GetFollowerStatus(self.followerID);
	if ( followerStatus == GARRISON_FOLLOWER_ON_MISSION ) then
		info.disabled = 1;
		info.tooltipWhileDisabled = 1;
		info.tooltipTitle = GARRISON_SHIP_DECOMMISSION;
		info.tooltipText = GARRISON_SHIP_CANNOT_DECOMMISSION_ON_MISSION;
		info.tooltipOnButton = 1;
	elseif ( C_Garrison.GetNumFollowers(Enum.GarrisonFollowerType.FollowerType_6_2) <  C_Garrison.GetFollowerSoftCap(Enum.GarrisonFollowerType.FollowerType_6_2) ) then
		info.disabled = 1;
		info.tooltipWhileDisabled = 1;
		info.tooltipTitle = GARRISON_SHIP_DECOMMISSION;
		info.tooltipText = GARRISON_SHIP_CANNOT_DECOMMISSION_UNTIL_FULL;
		info.tooltipOnButton = 1;
	end
	UIDropDownMenu_AddButton(info, level);

	info.text = CANCEL
	info.func = nil
	info.tooltipTitle = nil;
	info.disabled = nil;
	UIDropDownMenu_AddButton(info, level)
end

---------------------------------------------------------------------------------
--- GarrisonShipyardMissionListMixin                                                             ---
---------------------------------------------------------------------------------

GarrisonShipyardMissionListMixin = { }

function GarrisonShipyardMissionListMixin:UpdateCombatAllyMission()
	-- do nothing; there are no shipyard combat allies.
end