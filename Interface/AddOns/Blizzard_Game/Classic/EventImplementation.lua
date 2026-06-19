function GameEvent.GetClassicRaidInstanceWelcomeMessage(dungeonName, daysLeft, hoursLeft, minutesLeft, locked)
	if locked == 0 then
		return format(RAID_INSTANCE_WELCOME, dungeonName, daysLeft, hoursLeft, minutesLeft);
	end

	if daysLeft == 0 and hoursLeft == 0 and minutesLeft == 0 then
		return format(RAID_INSTANCE_WELCOME_EXTENDED, dungeonName);
	end

	return format(RAID_INSTANCE_WELCOME, dungeonName, daysLeft, hoursLeft, minutesLeft);
end

function GameEvent.HandleRaidInstanceWelcome(_dispatcher, _event, dungeonName, daysLeft, hoursLeft, minutesLeft, locked)
	ChatFrameUtil.AddSystemMessage(GameEvent.GetClassicRaidInstanceWelcomeMessage(dungeonName, daysLeft, hoursLeft, minutesLeft, locked));
end

function GameEvent.HandleTaxiMapOpened(_dispatcher, _event, uiMapSystem)
	if uiMapSystem == Enum.UIMapSystem.Taxi then
		ShowTaxiMapFrame();
	end
end

function GameEvent.HandleDebugMenuToggled(_dispatcher, _event)
	UpdateTopLevelParentRelativeToDebugMenu();
end

function GameEvent.HandlePlayerSoftInteractChanged(_dispatcher, _event, previousTarget, currentTarget)
	if GetCVarBool("softTargettingInteractKeySound") then
		if not currentTarget then
			PlaySound(SOUNDKIT.UI_SOFT_TARGET_INTERACT_NOT_AVAILABLE);
		elseif previousTarget ~= currentTarget then
			PlaySound(SOUNDKIT.UI_SOFT_TARGET_INTERACT_AVAILABLE);
		end
	end
end

function GameEvent.HandleLFGEnabledStateChanged(_dispatcher, _event)
	SetLookingForGroupUIAvailable(C_LFGInfo.IsGroupFinderEnabled());
end

function GameEvent.HandleCurrentSpellCastChanged(_dispatcher, _event, arg1)
	if StaticPopup_IsAnyDialogShown() then
		if arg1 then
			StaticPopup_Hide("BIND_ENCHANT");
			StaticPopup_Hide("REPLACE_ENCHANT");
			StaticPopup_Hide("ACTION_WILL_BIND_ITEM");
		end
		StaticPopup_Hide("TRADE_REPLACE_ENCHANT");
		StaticPopup_Hide("END_BOUND_TRADEABLE");
	end
end

function GameEvent.HandleGuildInviteRequest(_dispatcher, _event, arg1, arg2)
	StaticPopup_Show("GUILD_INVITE", arg1, arg2);
end

function GameEvent.HandleGuildInviteCancel(_dispatcher, _event)
	StaticPopup_Hide("GUILD_INVITE");
end

function GameEvent.HandlePartyInviteRequest(_dispatcher, _event, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
	FlashClientIcon();

	local name, tank, healer, damage, isXRealm, allowMultipleRoles, inviterGuid = arg1, arg2, arg3, arg4, arg5, arg6, arg7;
	local text = isXRealm and INVITATION_XREALM or INVITATION;
	text = string.format(text, name);

	if WillAcceptInviteRemoveQueues() then
		text = text.."\n\n"..ACCEPTING_INVITE_WILL_REMOVE_QUEUE;
	end
	StaticPopup_Show("PARTY_INVITE", text);
end

function GameEvent.HandleMirrorTimerStart(_dispatcher, _event, arg1, arg2, arg3, arg4, arg5, arg6)
	MirrorTimer_Show(arg1, arg2, arg3, arg4, arg5, arg6);
end

function GameEvent.HandleCraftShow(_dispatcher, _event)
	ShowCraftFrame();
end

function GameEvent.HandleCraftClose(_dispatcher, _event)
	HideCraftFrame();
end

function GameEvent.HandleConfirmBarbersChoice(_dispatcher, _event, arg1)
	HideGossipFrame();
	ConfirmBarbersChoiceDialog_Show(arg1);
end

function GameEvent.HandleConfirmPetUnlearn(_dispatcher, _event, arg1)
	HideGossipFrame();
	ConfirmPetUnlearnDialog_Show(arg1);
end

function GameEvent.HandleAuctionHouseDisabled(_dispatcher, _event)
	StaticPopup_Show("AUCTION_HOUSE_DISABLED");
end

function GameEvent.HandleAuctionHouseShow(_dispatcher, _event)
	if IsUsingLegacyAuctionClient() then
		ShowAuctionFrame();
	else
		ShowAuctionHouseFrame();
	end
end

function GameEvent.HandleAuctionHouseClosed(_dispatcher, _event)
	if IsUsingLegacyAuctionClient() then
		HideAuctionFrame();
	else
		HideAuctionHouseFrame();
	end
end

function GameEvent.HandleBarberShopClose(_dispatcher, _event)
	HideBarberShopFrame();
end

function GameEvent.HandleAddonActionBlocked(_dispatcher, _event)
	DisplayInterfaceActionBlockedMessage();
end

function GameEvent.HandleEquipBindRefundableConfirm(_dispatcher, _event, arg1)
	StaticPopup_Hide("EQUIP_BIND");
	StaticPopup_Hide("EQUIP_BIND_TRADEABLE");
	StaticPopup_Show("EQUIP_BIND_REFUNDABLE", nil, nil, arg1);
end

function GameEvent.HandleLootBindConfirm(_dispatcher, _event, arg1)
	local _texture, item, _quantity, _itemID, quality, _locked = GetLootSlotInfo(arg1);
	StaticPopup_Show("LOOT_BIND", ITEM_QUALITY_COLORS[quality].hex..item.."|r", nil, arg1);
end

function GameEvent.HandleMacroActionBlocked(_dispatcher, _event)
	DisplayInterfaceActionBlockedMessage();
end

function GameEvent.HandleMacroActionForbidden(_dispatcher, _event)
	StaticPopup_Show("MACRO_ACTION_FORBIDDEN");
end

function GameEvent.HandleDeleteItemConfirm(_dispatcher, _event, arg1, arg2)
	if arg2 >= LE_ITEM_QUALITY_RARE and arg2 ~= LE_ITEM_QUALITY_HEIRLOOM then
		StaticPopup_Show("DELETE_GOOD_ITEM", arg1);
	else
		StaticPopup_Show("DELETE_ITEM", arg1);
	end
end

function GameEvent.HandleQuestAcceptConfirm(_dispatcher, _event, arg1, arg2)
	local _numEntries, numQuests = GetNumQuestLogEntries();
	if numQuests >= MAX_QUESTS then
		StaticPopup_Show("QUEST_ACCEPT_LOG_FULL", arg1, arg2);
	else
		StaticPopup_Show("QUEST_ACCEPT", arg1, arg2);
	end
end

function GameEvent.HandleStartLootRoll(_dispatcher, _event, arg1, arg2)
	GroupLootFrame_OpenNewFrame(arg1, arg2);
end

function GameEvent.HandleTradeSkillShow(_dispatcher, _event)
	ShowTradeSkillFrame();
end

function GameEvent.HandleTradeSkillClose(_dispatcher, _event)
	HideTradeSkillFrame();
end

function GameEvent.HandleVariablesLoaded(_dispatcher, event)
	LocalizeFrames();

	local lastTalkedToGM = GetCVar("lastTalkedToGM");
	if lastTalkedToGM ~= "" then
		RestoreGMChatFrameSession(lastTalkedToGM);
	end

	if CheckActiveStoreForFree then
		CheckActiveStoreForFree(event);
	else
		StoreFrame_CheckForFree(event);
	end

	EventUtil.TriggerOnVariablesLoaded();
end
