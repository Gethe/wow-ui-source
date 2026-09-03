function GameEvent.HandleSpellConfirmationPrompt(_dispatcher, _event, ...)
	local spellID, confirmType, text, duration, currencyID, currencyCost, difficultyID = ...;

	if confirmType == Enum.ConfirmationPromptUIType.StaticText then
		StaticPopup_Show("SPELL_CONFIRMATION_PROMPT", text, duration, spellID);
	elseif confirmType == Enum.ConfirmationPromptUIType.SimpleWarning then
		StaticPopup_Show("SPELL_CONFIRMATION_WARNING", text, nil, spellID);
	elseif confirmType == Enum.ConfirmationPromptUIType.BonusRoll then
		BonusRollFrame_StartBonusRoll(spellID, text, duration, currencyID, currencyCost, difficultyID);
	end
end

function GameEvent.HandleSpellConfirmationTimeout(_dispatcher, _event, ...)
	local spellID, confirmType = ...;
	if confirmType == Enum.ConfirmationPromptUIType.StaticText then
		StaticPopup_Hide("SPELL_CONFIRMATION_PROMPT", spellID);
	elseif confirmType == Enum.ConfirmationPromptUIType.SimpleWarning then
		StaticPopup_Hide("SPELL_CONFIRMATION_WARNING", spellID);
	elseif confirmType == Enum.ConfirmationPromptUIType.BonusRoll then
		BonusRollFrame_CloseBonusRoll();
	end
end

function GameEvent.HandleTalentsInvoluntarilyReset(_dispatcher, _event, ...)
	local isForPet = ...;
	if isForPet then
		StaticPopup_Show("TALENTS_INVOLUNTARILY_RESET_PET");
	else
		StaticPopup_Show("TALENTS_INVOLUNTARILY_RESET");
	end
end

function GameEvent.HandleProductDistributionsUpdated(_dispatcher, event)
	StoreFrame_CheckForFree(event);
end

function GameEvent.HandleLogoutCancel(_dispatcher, _event)
	CancelLogout();
	StaticPopup_Hide("CAMP");
	StaticPopup_Hide("QUIT");
end

function GameEvent.HandleEnableTaxiBenchmark(_dispatcher, _event)
	if not FramerateText:IsShown() then
		ToggleFramerate(true);
	end
	ChatFrameUtil.AddSystemMessage(BENCHMARK_TAXI_MODE_ON);
end

function GameEvent.HandleDisableTaxiBenchmark(_dispatcher, _event)
	if FramerateText.benchmark then
		ToggleFramerate();
	end
	ChatFrameUtil.AddSystemMessage(BENCHMARK_TAXI_MODE_OFF);
end

function GameEvent.HandleAuctionHouseNotification(_dispatcher, _event, ...)
	local auctionHouseNotification, formatArg = ...;
	ChatFrameUtil.AddSystemMessage(ChatFrameUtil.GetAuctionHouseNotificationText(auctionHouseNotification, formatArg));
end

function GameEvent.HandleConfirmTalentWipe(_dispatcher, _event, ...)
	local talentTab, pointCost = ...;
	HideGossipFrame();
	ConfirmTalentWipeDialog_Show(talentTab, pointCost);
end

function GameEvent.HandleConfirmXpLoss(_dispatcher, _event)
	local resSicknessTime = GetResSicknessDuration();
	if resSicknessTime then
		StaticPopup_Show("XP_LOSS", resSicknessTime, nil, resSicknessTime);
	else
		StaticPopup_Show("XP_LOSS_NO_SICKNESS", nil, nil, 1);
	end
	HideGossipFrame();
end

-- Overwritten in future flavors
function GameEvent.CheckPlayerEnteringWorldDeath()
	if GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1 then
		StaticPopup_Show("DEATH");
	end
end

-- Overwritten in future flavors
function GameEvent.CheckArenaInstance(CheckArenaInstance)
	if instanceType == "arena" or instanceType == "pvp" then
		Arena_LoadUI();
	end
end

local HandlePlayerEnteringWorld = GameEvent.HandlePlayerEnteringWorld;
function GameEvent.HandlePlayerEnteringWorld(dispatcher, event, isInitialLogin, isUIReload)
	HandlePlayerEnteringWorld(dispatcher, event, isInitialLogin, isUIReload);

	-- Fix for Bug 124392
	StaticPopup_Hide("LEVEL_GRANT_PROPOSED");

	local _, instanceType = IsInInstance();
	GameEvent.CheckArenaInstance(instanceType);

	if DoesInstanceTypeMatchBattlefieldMapSettings() then
		BattlefieldMap_LoadUI();
	end

	-- Vanilla Hardcore requires a dead guild leader to hand off leadership.
	GameEvent.CheckPlayerEnteringWorldDeath();

	local resurrectOfferer = ResurrectGetOfferer();
	if resurrectOfferer then
		if C_GameRules.IsHardcoreActive and C_GameRules.IsHardcoreActive() then
			return true;
		end
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

	UpdateUIParentPosition();

	--Bonus roll/spell confirmation.
	local spellConfirmations = GetSpellConfirmationPromptsInfo();

	for i, spellConfirmation in ipairs(spellConfirmations) do
		if spellConfirmation.spellID then
			if spellConfirmation.confirmType == Enum.ConfirmationPromptUIType.StaticText then
				StaticPopup_Show("SPELL_CONFIRMATION_PROMPT", spellConfirmation.text, spellConfirmation.duration, spellConfirmation.spellID);
			elseif spellConfirmation.confirmType == Enum.ConfirmationPromptUIType.SimpleWarning then
				StaticPopup_Show("SPELL_CONFIRMATION_WARNING", spellConfirmation.text, nil, spellConfirmation.spellID);
			elseif spellConfirmation.confirmType == Enum.ConfirmationPromptUIType.BonusRoll then
				BonusRollFrame_StartBonusRoll(spellConfirmation.spellID, spellConfirmation.text, spellConfirmation.duration, spellConfirmation.currencyID, spellConfirmation.currencyCost);
			end
		end
	end

	--Group Loot Roll Windows.
	local pendingLootRollIDs = GetActiveLootRollIDs();

	for i=1, #pendingLootRollIDs do
		GroupLootFrame_OpenNewFrame(pendingLootRollIDs[i], GetLootRollTimeLeft(pendingLootRollIDs[i]));
	end

	SetLookingForGroupUIAvailable(C_LFGInfo.IsGroupFinderEnabled());

	return true;
end

function GameEvent.HandleEquipBindConfirm(_dispatcher, _event, arg1)
	StaticPopup_Hide("EQUIP_BIND_TRADEABLE");
	StaticPopup_Show("EQUIP_BIND", nil, nil, arg1);
end

function GameEvent.HandleEquipBindTradeableConfirm(_dispatcher, _event, arg1)
	StaticPopup_Hide("EQUIP_BIND");
	StaticPopup_Show("EQUIP_BIND_TRADEABLE", nil, nil, arg1);
end

function GameEvent.HandleDuelToTheDeathRequested(_dispatcher, _event, arg1)
	StaticPopup_Show("DUEL_TO_THE_DEATH_REQUESTED", arg1, arg1);
end

function GameEvent.HandleCorpseInRange(_dispatcher, _event)
	StaticPopup_Show("RECOVER_CORPSE");
end

function GameEvent.HandleCorpseOutOfRange(_dispatcher, _event)
	StaticPopup_Hide("RECOVER_CORPSE");
	StaticPopup_Hide("RECOVER_CORPSE_INSTANCE");
	StaticPopup_Hide("XP_LOSS");
end

function GameEvent.HandlePlayerControlGained(_dispatcher, _event)
end

function GameEvent.HandlePlayerDead(_dispatcher, _event, arg1)
	if not StaticPopup_Visible("DEATH") then
		CloseAllWindows(1);
	end
	if (GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1) and (not ResurrectGetOfferer()) then
		StaticPopup_Show("DEATH");
	end
end
