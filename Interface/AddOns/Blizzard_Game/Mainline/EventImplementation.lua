function GameEvent.HandleGarrisonFollowerTargetSpell(_dispatcher, _event)
	if SpellCanTargetGarrisonFollower(0) or SpellCanTargetGarrisonFollowerAbility(0, 0) then
		local followerTypeID = GetFollowerTypeIDFromSpell();
		local frame = _G[GarrisonFollowerOptions[followerTypeID].missionFrame];

		if frame and frame:IsShown() then
			if (not C_Garrison.TargetSpellHasFollowerTemporaryAbility() or not frame:HasMission()) and PanelTemplates_GetSelectedTab(frame) ~= 2 then
				frame:SelectTab(2);
			end
		else
			local landingPageTabIndex;
			local garrisonType = C_Garrison.GetLandingPageGarrisonType();
			local garrTypeID = GarrisonFollowerOptions[followerTypeID].garrisonType;
			if garrTypeID == garrisonType then
				if C_Garrison.HasGarrison(garrTypeID) then
					if followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat then
						landingPageTabIndex = 3;
					else
						landingPageTabIndex = 2;
					end

					ShowGarrisonLandingPage(garrTypeID);

					if PanelTemplates_GetSelectedTab(GarrisonLandingPage) ~= landingPageTabIndex then
						GarrisonLandingPageTab_SetTab(_G["GarrisonLandingPageTab"..landingPageTabIndex]);
					end
				end
			end
		end
	end

	if SpellCanTargetGarrisonMission() then
		if not Garrison_LoadUI() then
			return;
		end

		if GarrisonMissionFrame:IsShown() then
			if PanelTemplates_GetSelectedTab(GarrisonMissionFrame) ~= 1 then
				GarrisonMissionFrame_SelectTab(1);
			end
			if PanelTemplates_GetSelectedTab(GarrisonMissionFrame.MissionTab.MissionList) ~= 2 then
				GarrisonMissionListTab_SetTab(GarrisonMissionFrame.MissionTab.MissionList.Tab2);
			end
		elseif C_Garrison.HasGarrison(Enum.GarrisonType.Type_6_0_Garrison) then
			ShowGarrisonLandingPage(Enum.GarrisonType.Type_6_0_Garrison);

			if PanelTemplates_GetSelectedTab(GarrisonLandingPage) ~= 1 then
				GarrisonLandingPageTab_SetTab(GarrisonLandingPageTab1);
			end
			if PanelTemplates_GetSelectedTab(GarrisonLandingPageReport) ~= GarrisonLandingPageReport.InProgress then
				GarrisonLandingPageReport_SetTab(GarrisonLandingPageReport.InProgress);
			end
		end
	end
end

function GameEvent.HandleCurrentSpellCastChanged(_dispatcher, _event, arg1)
	GameEvent.HandleGarrisonFollowerTargetSpell();
	if StaticPopup_IsAnyDialogShown() then
		if arg1 then
			StaticPopup_Hide("BIND_ENCHANT");
			StaticPopup_Hide("REPLACE_ENCHANT");
			StaticPopup_Hide("ACTION_WILL_BIND_ITEM");
		end
		StaticPopup_Hide("TRADE_REPLACE_ENCHANT");
		StaticPopup_Hide("END_BOUND_TRADEABLE");
		StaticPopup_Hide("REPLACE_TRADESKILL_ENCHANT");
		if not SpellCanTargetGarrisonFollower(0) then
			StaticPopup_Hide("CONFIRM_FOLLOWER_UPGRADE");
			StaticPopup_Hide("CONFIRM_FOLLOWER_TEMPORARY_ABILITY");
		end
	end
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function GameEvent.HandlePlayerSoftInteractChanged(_dispatcher, _event, previousTarget, currentTarget)
	if GetCVarBool("softTargettingInteractKeySound") then
		if not currentTarget then
			if previousTarget then
				PlaySound(SOUNDKIT.UI_SOFT_TARGET_INTERACT_NOT_AVAILABLE);
			end
		elseif previousTarget ~= currentTarget then
			PlaySound(SOUNDKIT.UI_SOFT_TARGET_INTERACT_AVAILABLE);
		end
	end
end


local function IsGlobalMouseEventHandled(buttonName, event)
	for _, region in ipairs(GetMouseFoci()) do
		if region and region.HandlesGlobalMouseEvent and region:HandlesGlobalMouseEvent(buttonName, event) then
			return true;
		end
	end
	return false;
end

local function HasVisibleAutoCompleteBox(autoCompleteBoxList, mouseFocus)
	for i, box in ipairs(autoCompleteBoxList) do
		if box:IsShown() and DoesAncestryInclude(box, mouseFocus) then
			return true;
		end
	end
	return false;
end

local StickyFocusRequestMixin = {};

function StickyFocusRequestMixin:AddFrame(frame)
	if not self.frames then
		self.frames = {};
	end

	tinsert(self.frames, frame);
end

local function ClearCurrentKeyboardFocus(event, buttonName)
	if event == "GLOBAL_MOUSE_DOWN" and buttonName == "LeftButton" and not IsModifierKeyDown() then
		local keyBoardFocus = GetCurrentKeyBoardFocus();
		if keyBoardFocus and keyBoardFocus.ClearFocus then
			if keyBoardFocus.HasStickyFocus and keyBoardFocus:HasStickyFocus() then
				return;
			end

			local stickyFocusRequest = CreateFromMixins(StickyFocusRequestMixin);
			EventRegistry:TriggerEvent("UI.QueryStickyFocusFrames", stickyFocusRequest);

			for _, mouseFocus in ipairs(GetMouseFoci()) do
				if mouseFocus == keyBoardFocus or HasVisibleAutoCompleteBox(stickyFocusRequest.frames or {}, mouseFocus) then
					return;
				end
			end

			keyBoardFocus:ClearFocus();
		end
	end
end

function GameEvent.HandleGlobalMouseEvent(_dispatcher, event, buttonID)
	if IsMouseButton(buttonID) and GetConvertedKeyOrButton(buttonID) == GetBindingKey("TOGGLEPINGLISTENER") then
		C_Ping.TogglePingListener(event == "GLOBAL_MOUSE_DOWN");
	end

	if not IsGlobalMouseEventHandled(buttonID, event) then
		UIDropDownMenu_HandleGlobalMouseEvent(buttonID, event);
	end

	ClearCurrentKeyboardFocus(event, buttonID);
end

function GameEvent.HandleScriptedAnimationsUpdate(_dispatcher, _event)
	ScriptedAnimationEffectsUtil.ReloadDB();
end

function GameEvent.HandleShowHyperlinkTooltip(_dispatcher, _event, hyperlink)
	GameTooltip_ShowEventHyperlink(hyperlink);
end

function GameEvent.HandleHideHyperlinkTooltip(_dispatcher, _event)
	GameTooltip_HideEventHyperlink();
end

function GameEvent.HandleShowPartyPoseUi(_dispatcher, _event, partyPoseID, won)
	ShowMatchCelebrationPartyPoseFrame(partyPoseID, won);
end

function GameEvent.HandlePingSystemError(_dispatcher, _event, errorMsg)
	UIErrorsFrame:AddMessage(errorMsg, RED_FONT_COLOR:GetRGBA());
end

function GameEvent.HandleRemixEndOfEvent(_dispatcher, _event)
	StaticPopup_Show("REMIX_END_OF_EVENT_NOTICE");
end

function GameEvent.HandleShowJourneysUi(_dispatcher, _event, factionID)
	OpenEncounterJournalToJourney(factionID);
end

function GameEvent.HandleScenarioUpdate(_dispatcher, _event)
	if IsBoostTutorialScenario() then
		BoostTutorial_LoadUI();
	end
end

function GameEvent.HandleInviteToPartyConfirmation(_dispatcher, _event, ...)
	OnInviteToPartyConfirmation(...);
end

function GameEvent.HandleAlliedRaceOpen(_dispatcher, _event, raceID)
	AlliedRacesFrame_TryShow(raceID);
end

function GameEvent.HandleIslandCompleted(_dispatcher, _event, mapID, winner)
	IslandsPartyPoseFrame_TryShow(mapID, winner);
end

function GameEvent.HandleWarfrontCompleted(_dispatcher, _event, mapID, winner)
	WarfrontsPartyPoseFrame_TryShow(mapID, winner);
end

function GameEvent.HandleCovenantPreviewOpen(_dispatcher, _event, ...)
	TryShowCovenantPreviewFrame(...);
end

function GameEvent.HandleAnimaDiversionOpen(_dispatcher, _event, ...)
	TryShowAnimaDiversionFrame(...);
end

function GameEvent.HandleRuneforgeLegendaryCraftingOpened(_dispatcher, _event, isUpgrade)
	ShowRuneforgeFrame(isUpgrade);
end

function GameEvent.HandleTraitSystemInteractionStarted(_dispatcher, _event, traitTreeID)
	TraitUtil.OpenTraitFrame(traitTreeID);
end

function GameEvent.HandleRemixArtifactUpdate(_dispatcher, _event)
	ShowRemixArtifactFrame();
end

function GameEvent.HandlePlayerDead(_dispatcher, _event)
	if not StaticPopup_Visible("DEATH") then
		CloseAllWindows(1);
	end
	local releaseSpiritGhostDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.ReleaseSpiritGhostDisabled);
	if not releaseSpiritGhostDisabled then
		if (GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1) and (not ResurrectGetOfferer()) then
			StaticPopup_Show("DEATH");
		end
	end
end

function GameEvent.HandleSelfResSpellChanged(_dispatcher, _event)
	if StaticPopup_Visible("DEATH") then
		StaticPopup_Show("DEATH");
	end
end

function GameEvent.HandlePlayerAlive(_dispatcher, _event)
	StaticPopup_Hide("DEATH");
	StaticPopup_Hide("RESURRECT_NO_SICKNESS");
	StaticPopup_Hide("RESURRECT_NO_TIMER");
	StaticPopup_Hide("RESURRECT");
	local releaseSpiritGhostDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.ReleaseSpiritGhostDisabled);
	local canShow = not releaseSpiritGhostDisabled and UnitIsGhost("player");
	SetGhostFrameShown(canShow);
end

function GameEvent.HandlePlayerUnghost(_dispatcher, _event)
	StaticPopup_Hide("RESURRECT");
	StaticPopup_Hide("RESURRECT_NO_SICKNESS");
	StaticPopup_Hide("RESURRECT_NO_TIMER");
	StaticPopup_Hide("SKINNED");
	StaticPopup_Hide("SKINNED_REPOP");
	SetGhostFrameShown(false);
end

function GameEvent.HandleLeavingTutorialArea(_dispatcher, _event)
	StaticPopup_Show("LEAVING_TUTORIAL_AREA");
end

function GameEvent.HandleUiErrorPopup(_dispatcher, _event, ...)
	local errorType, errorMessage = ...;
	local systemPrefix = "UI_ERROR_";
	StaticPopup_ShowNotification(systemPrefix, errorType, errorMessage);
end

function GameEvent.HandleUiScaleChanged(_dispatcher, _event)
	UpdateScaleForFitForOpenPanels();
end

function GameEvent.HandlePlayerPlunderstormTransfering(_dispatcher, _event)
	StaticPopup_Show("PLUNDERSTORM_LEAVE");
end

function GameEvent.HandleLogoutCancel(_dispatcher, _event)
	CancelLogout();
	StaticPopup_Hide("CAMP");
	StaticPopup_Hide("PLUNDERSTORM_LEAVE");
	StaticPopup_Hide("QUIT");
end

function GameEvent.HandleLootBindConfirm(_dispatcher, _event, arg1)
	local _texture, item, _quantity, _currencyID, quality, _locked = GetLootSlotInfo(arg1);
	local textArg1 = item;
	local colorData = ColorManager.GetColorDataForItemQuality(quality);
	if colorData then
		textArg1 = colorData.hex..item.."|r";
	end
	StaticPopup_Show("LOOT_BIND", textArg1, nil, arg1);
end

function GameEvent.HandleEquipBindConfirm(_dispatcher, _event, arg1, arg2)
	StaticPopup_Hide("EQUIP_BIND_REFUNDABLE");
	StaticPopup_Hide("EQUIP_BIND_TRADEABLE");
	StaticPopup_Show("EQUIP_BIND", nil, nil, { slot = arg1, itemLocation = arg2 });
end

function GameEvent.HandleEquipBindRefundableConfirm(_dispatcher, _event, arg1, arg2)
	StaticPopup_Hide("EQUIP_BIND");
	StaticPopup_Hide("EQUIP_BIND_TRADEABLE");
	StaticPopup_Show("EQUIP_BIND_REFUNDABLE", nil, nil, { slot = arg1, itemLocation = arg2 });
end

function GameEvent.HandleEquipBindTradeableConfirm(_dispatcher, _event, arg1, arg2)
	StaticPopup_Hide("EQUIP_BIND");
	StaticPopup_Hide("EQUIP_BIND_REFUNDABLE");
	StaticPopup_Show("EQUIP_BIND_TRADEABLE", nil, nil, { slot = arg1, itemLocation = arg2 });
end

function GameEvent.HandleConvertToBindToAccountConfirm(_dispatcher, _event)
	StaticPopup_Show("CONVERT_TO_BIND_TO_ACCOUNT_CONFIRM");
end

function GameEvent.HandleDeleteItemConfirm(_dispatcher, _event, arg1, arg2, _arg3, arg4)
	if arg2 >= Enum.ItemQuality.Rare and arg2 ~= Enum.ItemQuality.Heirloom then
		if arg4 == 1 then
			StaticPopup_Show("DELETE_GOOD_QUEST_ITEM", arg1);
		else
			StaticPopup_Show("DELETE_GOOD_ITEM", arg1);
		end
	else
		if arg4 == 1 then
			StaticPopup_Show("DELETE_QUEST_ITEM", arg1);
		else
			StaticPopup_Show("DELETE_ITEM", arg1);
		end
	end
end

function GameEvent.HandleQuestAcceptConfirm(_dispatcher, _event, arg1, arg2)
	local _numEntries, numQuests = C_QuestLog.GetNumQuestLogEntries();
	if numQuests >= MAX_QUESTS then
		StaticPopup_Show("QUEST_ACCEPT_LOG_FULL", arg1, arg2);
	else
		StaticPopup_Show("QUEST_ACCEPT", arg1, arg2);
	end
end

function GameEvent.HandleSettingsLoaded(_dispatcher, _event)
	MultiActionBar_Update();
end

function GameEvent.HandleUpdateBattlefieldStatus(_dispatcher, _event)
	local bannerName;
	local bannerDescription;

	if C_PvP.IsInBrawl() then
		local brawlInfo = C_PvP.GetActiveBrawlInfo();
		if brawlInfo then
			bannerName = brawlInfo.name;
			bannerDescription = brawlInfo.shortDescription;
		end
	else
		for i = 1, GetMaxBattlefieldID() do
			local status, mapName, _, _, _, _, _, _, _, shortDescription = GetBattlefieldStatus(i);
			if status == "active" then
				bannerName = mapName;
				bannerDescription = shortDescription;
				break;
			end
		end
	end

	if bannerName and PVPUI_LoadUI() then
		C_Timer.After(1, function()
			TopBannerManager_Show(PvPObjectiveBannerFrame, { name = bannerName, description = bannerDescription });
		end);

		-- This function becomes no-op after displaying the banner.
		GameEvent.HandleUpdateBattlefieldStatus = nop;
	end
end

function GameEvent.HandleActionBlocked(_dispatcher, _event, arg1)
	AddonTooltip_ActionBlocked(arg1);
	DisplayInterfaceActionBlockedMessage();
end

function GameEvent.HandleMacroActionForbidden(_dispatcher, _event, arg1)
	AddonTooltip_ActionBlocked(arg1);
	StaticPopup_Show("MACRO_ACTION_FORBIDDEN");
end

function GameEvent.HandleStartLootRoll(_dispatcher, _event, arg1, arg2)
	GroupLootContainer_AddRoll(arg1, arg2);
end

function GameEvent.HandleSpellConfirmationPrompt(_dispatcher, _event, ...)
	local spellID, confirmType, text, duration, currencyID, currencyCost, difficultyID, displayItemID, itemContext, treasureContextLevel = ...;
	if confirmType == Enum.ConfirmationPromptUIType.StaticText then
		StaticPopup_Show("SPELL_CONFIRMATION_PROMPT", text, duration, spellID);
	elseif confirmType == Enum.ConfirmationPromptUIType.StaticTextAlert then
		StaticPopup_Show("SPELL_CONFIRMATION_PROMPT_ALERT", text, duration, spellID);
	elseif confirmType == Enum.ConfirmationPromptUIType.SimpleWarning then
		StaticPopup_Show("SPELL_CONFIRMATION_WARNING", text, nil, spellID);
	elseif confirmType == Enum.ConfirmationPromptUIType.SimpleWarningAlert then
		StaticPopup_Show("SPELL_CONFIRMATION_WARNING_ALERT", text, nil, spellID);
	elseif confirmType == Enum.ConfirmationPromptUIType.BonusRoll then
		BonusRollFrame_StartBonusRoll(spellID, text, duration, currencyID, currencyCost, difficultyID, displayItemID, itemContext, treasureContextLevel);
	end
end

function GameEvent.HandleSpellConfirmationTimeout(_dispatcher, _event, ...)
	local spellID, confirmType = ...;
	if confirmType == Enum.ConfirmationPromptUIType.StaticText then
		StaticPopup_Hide("SPELL_CONFIRMATION_PROMPT", spellID);
	elseif confirmType == Enum.ConfirmationPromptUIType.StaticTextAlert then
		StaticPopup_Hide("SPELL_CONFIRMATION_PROMPT_ALERT", spellID);
	elseif confirmType == Enum.ConfirmationPromptUIType.SimpleWarning then
		StaticPopup_Hide("SPELL_CONFIRMATION_WARNING", spellID);
	elseif confirmType == Enum.ConfirmationPromptUIType.SimpleWarningAlert then
		StaticPopup_Hide("SPELL_CONFIRMATION_WARNING_ALERT", spellID);
	elseif confirmType == Enum.ConfirmationPromptUIType.BonusRoll then
		BonusRollFrame_CloseBonusRoll();
	end
end

function GameEvent.HandleConfirmDisenchantRoll(_dispatcher, _event, arg1, arg2)
	ConfirmDisenchantRollDialog_Show(arg1, arg2);
end

function GameEvent.HandleConfirmTalentWipe(_dispatcher, _event, arg1, arg2)
	HideGossipFrame();
	ConfirmTalentWipeDialog_Show(arg1, arg2);
end

function GameEvent.HandleDuelFinished(_dispatcher, _event)
	StaticPopup_Hide("DUEL_REQUESTED");
	StaticPopup_Hide("DUEL_OUTOFBOUNDS");
end

function GameEvent.HandlePetBattlePvpDuelRequested(_dispatcher, _event, arg1)
	StaticPopup_Show("PET_BATTLE_PVP_DUEL_REQUESTED", arg1);
end

function GameEvent.HandlePetBattlePvpDuelRequestCancel(_dispatcher, _event)
	StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED");
end

function GameEvent.HandlePetBattleQueueProposeMatch(_dispatcher, _event)
	PlaySound(SOUNDKIT.UI_PET_BATTLES_PVP_THROUGH_QUEUE);
	StaticPopupSpecial_Show(PetBattleQueueReadyFrame);
end

function GameEvent.HandlePetBattleQueueProposalResult(_dispatcher, _event)
	StaticPopupSpecial_Hide(PetBattleQueueReadyFrame);
end

function GameEvent.HandleAuctionHouseShow(_dispatcher, _event)
	if GameLimitedMode_IsActive() then
		UIErrorsFrame:AddExternalErrorMessage(ERR_FEATURE_RESTRICTED_TRIAL);
		C_AuctionHouse.CloseAuctionHouse();
	else
		ShowAuctionHouseFrame();
	end
end

function GameEvent.HandleAuctionHouseClosed(_dispatcher, _event)
	HideAuctionHouseFrame();
end

function GameEvent.HandleAuctionHouseDisabled(_dispatcher, _event)
	StaticPopup_Show("AUCTION_HOUSE_DISABLED");
end

function GameEvent.HandleAuctionHouseNotification(_dispatcher, _event, auctionHouseNotification, formatArg)
	ChatFrameUtil.AddSystemMessage(ChatFrameUtil.GetAuctionHouseNotificationText(auctionHouseNotification, formatArg));
end

function GameEvent.HandleTradeSkillShow(_dispatcher, _event)
	ShowProfessionsFrame();
end

function GameEvent.HandleCraftingHouseDisabled(_dispatcher, _event)
	StaticPopup_Show("CRAFTING_HOUSE_DISABLED");
end

function GameEvent.HandleCraftingOrdersShowCustomer(_dispatcher, _event)
	if GameLimitedMode_IsActive() then
		UIErrorsFrame:AddExternalErrorMessage(ERR_FEATURE_RESTRICTED_TRIAL);
	else
		ShowProfessionsCustomerOrdersFrame();
	end
end

function GameEvent.HandleCraftingOrdersHideCustomer(_dispatcher, _event)
	HideProfessionsCustomerOrdersFrame();
end

function GameEvent.HandleProfessionEquipmentChanged(_dispatcher, _event, skillLineID, isTool)
	local cvar = isTool and "professionToolSlotsExampleShown" or "professionAccessorySlotsExampleShown";
	if not GetCVarBool(cvar) then
		SetCVar(cvar, "1");
		ShowProfessionEquipmentHelpTip(skillLineID);
	end
end

function GameEvent.HandleProfessionRespecConfirmation(_dispatcher, _event, professionName)
	StaticPopup_Show("CONFIRM_PROFESSION_RESPEC", professionName);
end

function GameEvent.HandleSocketInfoUpdate(_dispatcher, _event)
	ShowItemSocketingFrame();
end

function GameEvent.HandleUseGlyph(dispatcher, event, ...)
	dispatcher:UnregisterEvent("USE_GLYPH");
	OpenPlayerSpellsToGlyphTarget(event, ...);
end

function GameEvent.HandleEnchantSpellSelected(dispatcher, _event)
	PlaySound(SOUNDKIT.ENCHANTMENT_SELECTED);
	ItemButtonUtil.OpenAndFilterBags(dispatcher);
	ItemButtonUtil.OpenAndFilterCharacterFrame();
end

function GameEvent.HandleUpdateSpellTargetItemContext(_dispatcher, _event)
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
end

function GameEvent.HandleArtifactUpdate(_dispatcher, _event)
	ShowArtifactFrame();
end

function GameEvent.HandleArtifactRespecPrompt(_dispatcher, _event)
	ShowArtifactFrame();

	if C_ArtifactUI.GetPointsRemaining() < C_ArtifactUI.GetRespecCost() then
		StaticPopup_Show("NOT_ENOUGH_POWER_ARTIFACT_RESPEC", BreakUpLargeNumbers(C_ArtifactUI.GetRespecCost()));
	else
		StaticPopup_Show("CONFIRM_ARTIFACT_RESPEC", BreakUpLargeNumbers(C_ArtifactUI.GetRespecCost()));
	end
end

function GameEvent.HandleArtifactEndgameRefund(_dispatcher, _event, numRefunded, refundedTier)
	ArtifactFrame_OnTraitsRefunded(numRefunded, refundedTier);
end

function GameEvent.HandleArtifactRelicForgeUpdate(_dispatcher, _event)
	ShowArtifactRelicForgeFrame();
end

function GameEvent.HandleAdventureMapOpen(_dispatcher, _event, followerTypeID)
	ShowAdventureMapFrameForFollowerType(followerTypeID);
end

function GameEvent.HandleBarberShopClose(_dispatcher, _event)
	HideBarberShopFrame();
end

function GameEvent.HandlePerksProgramOpen(_dispatcher, _event)
	ShowPerksProgramFrame();
end

function GameEvent.HandlePerksProgramDisabled(_dispatcher, _event)
	StaticPopup_Show("PERKS_PROGRAM_DISABLED");
end

function GameEvent.HandleEnableTaxiBenchmark(_dispatcher, _event)
	FramerateFrame:BeginBenchmark();
	ChatFrameUtil.AddSystemMessage(BENCHMARK_TAXI_MODE_ON);
end

function GameEvent.HandleDisableTaxiBenchmark(_dispatcher, _event)
	FramerateFrame:EndBenchmark();
	ChatFrameUtil.AddSystemMessage(BENCHMARK_TAXI_MODE_OFF);
end

function GameEvent.HandleTalentsInvoluntarilyReset(_dispatcher, _event, isForPet)
	if not C_PlayerInfo.IsReturningCharacter() then
		if isForPet then
			StaticPopup_Show("TALENTS_INVOLUNTARILY_RESET_PET");
		else
			StaticPopup_Show("TALENTS_INVOLUNTARILY_RESET");
		end
	end
end

function GameEvent.HandleSpecInvoluntarilyChanged(_dispatcher, _event)
	StaticPopup_Show("SPEC_INVOLUNTARILY_CHANGED");
end

function GameEvent.HandleArchaeologyToggle(_dispatcher, _event)
	ArchaeologyFrame_ToggleUI();
end

function GameEvent.HandleArchaeologySurveyCast(dispatcher, event, ...)
	ArcheologyDigsiteProgressBar_OnSurveyCast(event, ...);
	dispatcher:UnregisterEvent("ARCHAEOLOGY_SURVEY_CAST");
end

function GameEvent.HandleToysUpdated(dispatcher, _event, itemID, isNewToy)
	if not CollectionsJournal then
		if itemID and isNewToy then
			if not dispatcher.newToys then
				dispatcher.newToys = {};
			end
			dispatcher.newToys[itemID] = true;
			dispatcher.autoPageToCollectedToyID = itemID;
			SetCVar("petJournalTab", COLLECTIONS_JOURNAL_TAB_INDEX_TOYS);
		end
	end
end

function GameEvent.HandleHeirloomUpgradeTargetingChanged(_dispatcher, _event, isPendingHeirloomUpgrade)
	if isPendingHeirloomUpgrade and not DISALLOW_FRAME_TOGGLING then
		ShowHeirloomsJournalToClosestUpgradeablePage();
	end
end

function GameEvent.HandleHeirloomsUpdated(dispatcher, _event, itemID, updateReason)
	if not CollectionsJournal then
		if itemID and updateReason == "NEW" then
			if not dispatcher.newHeirlooms then
				dispatcher.newHeirlooms = {};
			end
			dispatcher.newHeirlooms[itemID] = true;
		end
	end
end

function GameEvent.HandleTransmogCollectionUpdated(dispatcher, _event)
	if not CollectionsJournal then
		local latestAppearanceID = C_TransmogCollection.GetLatestAppearance();
		if latestAppearanceID and latestAppearanceID ~= dispatcher.latestAppearanceID then
			dispatcher.latestAppearanceID = latestAppearanceID;
			SetCVar("petJournalTab", 5);
		end
	end
end

function GameEvent.HandlePlayerChoiceUpdate(_dispatcher, _event)
	ShowPendingPlayerChoiceResponseUI();
end

function GameEvent.HandleProductDistributionsUpdated(_dispatcher, event)
	CheckActiveStoreForFree(event);
end

function GameEvent.HandleGarrisonMissionNpcOpened(_dispatcher, _event, followerType)
	ShowGarrisonMissionFrameForFollowerType(followerType);
end

function GameEvent.HandleGarrisonMissionNpcClosed(_dispatcher, _event)
	HideGarrisonMissionFrames();
end

function GameEvent.HandleGarrisonShipyardNpcOpened(_dispatcher, _event, ...)
	ShowGarrisonShipyardFrame(...);
end

function GameEvent.HandleGarrisonShipyardNpcClosed(_dispatcher, _event)
	HideGarrisonShipyardFrame();
end

function GameEvent.HandleShipmentCrafterOpened(_dispatcher, _event)
	ShowGarrisonCapacitiveDisplayFrame();
end

function GameEvent.HandleGarrisonRecruitmentNpcOpened(_dispatcher, _event)
	ShowGarrisonRecruiterFrame();
end

function GameEvent.HandleGarrisonTalentNpcOpened(_dispatcher, _event, ...)
	OpenOrderHallTalentUI(...);
end

local function GetRaidInstanceWelcomeMessage(dungeonName, lockExpireTime, locked, extended)
	if locked == 0 then
		return format(RAID_INSTANCE_WELCOME, dungeonName, SecondsToTime(lockExpireTime, nil, 1));
	end

	if lockExpireTime == 0 then
		return format(RAID_INSTANCE_WELCOME_EXTENDED, dungeonName);
	end

	if extended == 0 then
		return format(RAID_INSTANCE_WELCOME_LOCKED, dungeonName, SecondsToTime(lockExpireTime, nil, 1));
	end

	return format(RAID_INSTANCE_WELCOME_LOCKED_EXTENDED, dungeonName, SecondsToTime(lockExpireTime, nil, 1));
end

local function GetDailyResetInstanceWelcomeMessage(instanceName, resetTime)
	return format(DAILY_RESET_INSTANCE_WELCOME, instanceName, SecondsToTime(resetTime, nil, 1));
end

local function GetInstanceResetWarningMessage(warningString, resetTime)
	return format(warningString, SecondsToTime(resetTime, nil, 1));
end

function GameEvent.HandleRaidInstanceWelcome(_dispatcher, _event, dungeonName, lockExpireTime, locked, extended)
	ChatFrameUtil.AddSystemMessage(GetRaidInstanceWelcomeMessage(dungeonName, lockExpireTime, locked, extended));
end

function GameEvent.HandleDailyResetInstanceWelcome(_dispatcher, _event, instanceName, resetTime)
	ChatFrameUtil.AddSystemMessage(GetDailyResetInstanceWelcomeMessage(instanceName, resetTime));
end

function GameEvent.HandleInstanceResetWarning(_dispatcher, _event, warningString, resetTime)
	ChatFrameUtil.AddSystemMessage(GetInstanceResetWarningMessage(warningString, resetTime));
end

function GameEvent.HandleLoadingScreenEnabled(_dispatcher, _event)
	TopBannerManager_LoadingScreenEnabled();
end

function GameEvent.HandleLoadingScreenDisabled(_dispatcher, _event)
	TopBannerManager_LoadingScreenDisabled();
end

function GameEvent.HandleChallengeModeKeystoneReceptableOpen(_dispatcher, _event)
	ShowChallengesKeystoneFrame();
end

function GameEvent.HandleChallengeModeCompleted(dispatcher, event, ...)
	ChallengeModeCompleteBanner_OnChallengeModeCompleted(event, ...);
	dispatcher:UnregisterEvent("CHALLENGE_MODE_COMPLETED");
end

function GameEvent.HandleTaxiMapOpened(_dispatcher, _event, uiMapSystem)
	if uiMapSystem == Enum.UIMapSystem.Taxi then
		ShowTaxiMapFrame();
	else
		ShowFlightMapFrame();
	end
end

function GameEvent.HandleResurrectRequest(_dispatcher, _event, arg1)
	if C_GameRules.IsHardcoreActive and C_GameRules.IsHardcoreActive() then
		return true;
	end
	if ResurrectHasSickness() then
		StaticPopup_Show("RESURRECT", arg1);
	elseif ResurrectHasTimer() then
		StaticPopup_Show("RESURRECT_NO_SICKNESS", arg1);
	else
		StaticPopup_Show("RESURRECT_NO_TIMER", arg1);
	end
	return false;
end

function GameEvent.HandlePartyInviteRequest(_dispatcher, _event, ...)
	FlashClientIcon();
	local name, tank, healer, damage, isXRealm, allowMultipleRoles, inviterGuid, isQuestSessionActive = ...;
	local _modifiedName, color, selfRelationship = SocialQueueUtil_GetRelationshipInfo(inviterGuid);
	if selfRelationship then
		name = color..name..FONT_COLOR_CODE_CLOSE;
	end
	if tank or healer or damage then
		StaticPopupSpecial_Show(LFGInvitePopup);
		LFGInvitePopup_Update(name, tank, healer, damage, allowMultipleRoles, isQuestSessionActive);
	else
		local text = isXRealm and INVITATION_XREALM or INVITATION;
		text = string.format(text, name);
		if WillAcceptInviteRemoveQueues() then
			text = text.."\n\n"..ACCEPTING_INVITE_WILL_REMOVE_QUEUE;
		end
		if isQuestSessionActive then
			ShowQuestSessionGroupInviteReceivedConfirmation(name, text);
		else
			StaticPopup_Show("PARTY_INVITE", text);
		end
	end
end

local HandlePlayerEnteringWorld = GameEvent.HandlePlayerEnteringWorld;
function GameEvent.HandlePlayerEnteringWorld(dispatcher, event, isInitialLogin, isUIReload)
	HandlePlayerEnteringWorld(dispatcher, event, isInitialLogin, isUIReload);

	if C_PlayerChoice.IsWaitingForPlayerChoiceResponse() and not UnitIsDeadOrGhost("player") then
		ShowPendingPlayerChoiceResponseUI();
	end

	local releaseSpiritGhostDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.ReleaseSpiritGhostDisabled);
	if not releaseSpiritGhostDisabled then
		SetGhostFrameShown(UnitIsGhost("player"));
		if GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1 then
			StaticPopup_Show("DEATH");
		end
	end

	local resurrectOfferer = ResurrectGetOfferer();
	if resurrectOfferer then
		if ResurrectHasSickness() then
			StaticPopup_Show("RESURRECT", resurrectOfferer);
		elseif ResurrectHasTimer() then
			StaticPopup_Show("RESURRECT_NO_SICKNESS", resurrectOfferer);
		else
			StaticPopup_Show("RESURRECT_NO_TIMER", resurrectOfferer);
		end
	end

	local alreadyShowingSummonPopup = IsSummonConfirmationDialogVisible();
	if not alreadyShowingSummonPopup and C_SummonInfo.GetSummonConfirmTimeLeft() > 0 then
		local summonReason = C_SummonInfo.GetSummonReason();
		local isSkippingStartingArea = C_SummonInfo.IsSummonSkippingStartExperience();
		ShowSummonConfirmationDialog(summonReason, isSkippingStartingArea);
	end

	PrintLootSpecialization();

	local spellConfirmations = GetSpellConfirmationPromptsInfo();
	for i, spellConfirmation in ipairs(spellConfirmations) do
		if spellConfirmation.spellID then
			if spellConfirmation.confirmType == Enum.ConfirmationPromptUIType.StaticText then
				StaticPopup_Show("SPELL_CONFIRMATION_PROMPT", spellConfirmation.text, spellConfirmation.duration, spellConfirmation.spellID);
			elseif spellConfirmation.confirmType == Enum.ConfirmationPromptUIType.StaticTextAlert then
				StaticPopup_Show("SPELL_CONFIRMATION_PROMPT_ALERT", spellConfirmation.text, spellConfirmation.duration, spellConfirmation.spellID);
			elseif spellConfirmation.confirmType == Enum.ConfirmationPromptUIType.SimpleWarning then
				StaticPopup_Show("SPELL_CONFIRMATION_WARNING", spellConfirmation.text, nil, spellConfirmation.spellID);
			elseif spellConfirmation.confirmType == Enum.ConfirmationPromptUIType.SimpleWarningAlert then
				StaticPopup_Show("SPELL_CONFIRMATION_WARNING_ALERT", spellConfirmation.text, nil, spellConfirmation.spellID);
			elseif spellConfirmation.confirmType == Enum.ConfirmationPromptUIType.BonusRoll then
				BonusRollFrame_StartBonusRoll(spellConfirmation.spellID, spellConfirmation.text, spellConfirmation.duration, spellConfirmation.currencyID, spellConfirmation.currencyCost, spellConfirmation.difficultyID, spellConfirmation.displayItemID, spellConfirmation.itemContext, spellConfirmation.treasureContextLevel);
			end
		end
	end

	local pendingLootRollIDs = GetActiveLootRollIDs();
	for i=1, #pendingLootRollIDs do
		GroupLootContainer_AddRoll(pendingLootRollIDs[i], C_Loot.GetLootRollDuration(pendingLootRollIDs[i]));
	end

	if IsBoostTutorialScenario() then
		BoostTutorial_LoadUI();
	end

	if IsTrialAccount() or IsVeteranTrialAccount() then
		SubscriptionInterstitial_LoadUI();
	end

	local isExpansionTrial = GetExpansionTrialInfo();
	if isExpansionTrial then
		ExpansionTrial_LoadUI();
	end

	if PlayerIsTimerunning() then
		RemixArtifactTutorialUI_LoadUI();
	end

	if C_Housing.IsInsideHouseOrPlot() then
		HousingControls_LoadUI();
	end

	return true;
end

function GameEvent.HandleConfirmXpLoss(_dispatcher, _event)
	local resSicknessTime = GetResSicknessDuration();
	if resSicknessTime then
		if UnitLevel("player") < Constants.LevelConstsExposed.MIN_RES_SICKNESS_LEVEL then
			StaticPopup_Show("XP_LOSS_NO_SICKNESS_NO_DURABILITY", resSicknessTime, nil, resSicknessTime);
		else
			StaticPopup_Show("XP_LOSS", resSicknessTime, nil, resSicknessTime);
		end
	end
end

function GameEvent.HandleCorpseInRange(_dispatcher, _event)
	StaticPopup_Show("RECOVER_CORPSE");
end

function GameEvent.HandleCorpseInInstance(_dispatcher, _event)
	StaticPopup_Show("RECOVER_CORPSE_INSTANCE");
end

function GameEvent.HandleCorpseOutOfRange(_dispatcher, _event)
	StaticPopup_Hide("RECOVER_CORPSE");
	StaticPopup_Hide("RECOVER_CORPSE_INSTANCE");
	StaticPopup_Hide("XP_LOSS");
end

function GameEvent.HandleReplaceTradeskillEnchant(_dispatcher, _event, arg1, arg2)
	StaticPopup_Show("REPLACE_TRADESKILL_ENCHANT", arg1, arg2);
end

function GameEvent.HandleWorldCursorTooltipUpdate(_dispatcher, _event, anchorType)
	GameTooltip:SetWorldCursor(anchorType);
end

function GameEvent.HandleCvarUpdate(_dispatcher, _event, cvarName)
	if cvarName == "showTutorials" and GetCVarBool(cvarName) then
		if not NPE_InitializeIfLoaded() then
			NPE_LoadUI();
		end
	end
end

function GameEvent.CheckNPETutorial()
	if C_PlayerInfo.IsPlayerNPERestricted() and UnitLevel("player") == 1 then
		-- Hacky 9.0.1 fix for WOW9-58485...just force tutorials to on if they are entering Exile's Reach on a level 1 character
		SetCVar("showTutorials", 1);
	end

	NPE_LoadUI();
end

function GameEvent.HandleVariablesLoaded(_dispatcher, event)
	LocalizeFrames();

	if GetCVar("timeMgrAlarmEnabled") == "1" then
		TimeManager_LoadUI();
	end

	if GetCVar("showBattlefieldMinimap") == "1" then
		BattlefieldMap_LoadUI();
	end

	if not C_ChatInfo.AreOutgoingAddonChatMessagesRestricted() then
		CooldownBroadcaster_LoadUI();
	end

	local lastTalkedToGM = GetCVar("lastTalkedToGM");
	if lastTalkedToGM ~= "" then
		RestoreGMChatFrameSession(lastTalkedToGM);
	end

	CheckActiveStoreForFree(event);

	EventUtil.TriggerOnVariablesLoaded();
end
