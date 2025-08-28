TOOLTIP_UPDATE_TIME = 0.2;
BOSS_FRAME_CASTBAR_HEIGHT = 16;

-- Mirror of the same Variable in StoreSecureUI.lua and GlueParent.lua
WOW_GAMES_CATEGORY_ID = 33;

-- Alpha animation stuff
FADEFRAMES = {};
FLASHFRAMES = {};

-- Pulsing stuff
PULSEBUTTONS = {};

-- Shine animation
SHINES_TO_ANIMATE = {};

-- Macros
MAX_ACCOUNT_MACROS = 120;
MAX_CHARACTER_MACROS = 30;

CVarCallbackRegistry:SetCVarCachable("showCastableBuffs");
CVarCallbackRegistry:SetCVarCachable("showDispelDebuffs");

ITEM_QUALITY_COLORS = { };
for i = 0, NUM_LE_ITEM_QUALITYS - 1 do
	local r, g, b = C_Item.GetItemQualityColor(i);
	local color = CreateColor(r, g, b, 1);
	ITEM_QUALITY_COLORS[i] = { r = r, g = g, b = b, hex = color:GenerateHexColorMarkup(), color = color };
end

WORLD_QUEST_QUALITY_COLORS = {
	[LE_WORLD_QUEST_QUALITY_COMMON] = ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_COMMON];
	[LE_WORLD_QUEST_QUALITY_RARE] = ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_RARE];
	[LE_WORLD_QUEST_QUALITY_EPIC] = ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_EPIC];
};

function UIParent_OnLoad(self)
	-- First register for any shared events
	UIParent_Shared_OnLoad(self);

	self:RegisterEvent("PLAYER_LOGIN");
	self:RegisterEvent("PLAYER_DEAD");
	self:RegisterEvent("SELF_RES_SPELL_CHANGED");
	self:RegisterEvent("PLAYER_ALIVE");
	self:RegisterEvent("PLAYER_UNGHOST");
	self:RegisterEvent("RESURRECT_REQUEST");
	self:RegisterEvent("PLAYER_SKINNED");
	self:RegisterEvent("TRADE_REQUEST");
	self:RegisterEvent("CHANNEL_INVITE_REQUEST");
	self:RegisterEvent("CHANNEL_PASSWORD_REQUEST");
	self:RegisterEvent("PARTY_INVITE_REQUEST");
	self:RegisterEvent("PARTY_INVITE_CANCEL");
	self:RegisterEvent("ARENA_TEAM_INVITE_REQUEST");
	self:RegisterEvent("GUILD_INVITE_CANCEL");
	self:RegisterEvent("PLAYER_CAMPING");
	self:RegisterEvent("PLAYER_QUITING");
	self:RegisterEvent("LOGOUT_CANCEL");
	self:RegisterEvent("LOOT_BIND_CONFIRM");
	self:RegisterEvent("EQUIP_BIND_CONFIRM");
	self:RegisterEvent("EQUIP_BIND_REFUNDABLE_CONFIRM");
	self:RegisterEvent("EQUIP_BIND_TRADEABLE_CONFIRM");
	self:RegisterEvent("USE_BIND_CONFIRM");
	self:RegisterEvent("USE_NO_REFUND_CONFIRM");
	self:RegisterEvent("CONFIRM_BEFORE_USE");
	self:RegisterEvent("DELETE_ITEM_CONFIRM");
	self:RegisterEvent("QUEST_ACCEPT_CONFIRM");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	self:RegisterEvent("CURSOR_CHANGED");
	self:RegisterEvent("LOCALPLAYER_PET_RENAMED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("MIRROR_TIMER_START");
	self:RegisterEvent("DUEL_REQUESTED");
	self:RegisterEvent("DUEL_OUTOFBOUNDS");
	self:RegisterEvent("DUEL_INBOUNDS");
	self:RegisterEvent("DUEL_FINISHED");
	self:RegisterEvent("TRADE_REQUEST_CANCEL");
	self:RegisterEvent("CONFIRM_XP_LOSS");
	self:RegisterEvent("CORPSE_IN_RANGE");
	self:RegisterEvent("CORPSE_IN_INSTANCE");
	self:RegisterEvent("CORPSE_OUT_OF_RANGE");
	self:RegisterEvent("AREA_SPIRIT_HEALER_IN_RANGE");
	self:RegisterEvent("AREA_SPIRIT_HEALER_OUT_OF_RANGE");
	self:RegisterEvent("BIND_ENCHANT");
	self:RegisterEvent("ACTION_WILL_BIND_ITEM");
	self:RegisterEvent("REPLACE_ENCHANT");
	self:RegisterEvent("TRADE_REPLACE_ENCHANT");
	self:RegisterEvent("END_BOUND_TRADEABLE");
	self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
	self:RegisterEvent("MACRO_ACTION_BLOCKED");
	self:RegisterEvent("ADDON_ACTION_BLOCKED");
	self:RegisterEvent("MACRO_ACTION_FORBIDDEN");
	self:RegisterEvent("ADDON_ACTION_FORBIDDEN");
	self:RegisterEvent("PLAYER_CONTROL_LOST");
	self:RegisterEvent("PLAYER_CONTROL_GAINED");
	self:RegisterEvent("START_LOOT_ROLL");
	self:RegisterEvent("CONFIRM_LOOT_ROLL");
	self:RegisterEvent("INSTANCE_BOOT_START");
	self:RegisterEvent("INSTANCE_BOOT_STOP");
	self:RegisterEvent("INSTANCE_LOCK_START");
	self:RegisterEvent("INSTANCE_LOCK_STOP");
	self:RegisterEvent("INSTANCE_LOCK_WARNING");
	self:RegisterEvent("CONFIRM_TALENT_WIPE");
	self:RegisterEvent("CONFIRM_BARBERS_CHOICE");
	self:RegisterEvent("CONFIRM_PET_UNLEARN");
	self:RegisterEvent("CONFIRM_BINDER");
	self:RegisterEvent("CONFIRM_SUMMON");
	self:RegisterEvent("CANCEL_SUMMON");
	self:RegisterEvent("GOSSIP_CONFIRM");
	self:RegisterEvent("GOSSIP_CONFIRM_CANCEL");
	self:RegisterEvent("GOSSIP_ENTER_CODE");
	self:RegisterEvent("GOSSIP_CLOSED");
	self:RegisterEvent("BILLING_NAG_DIALOG");
	self:RegisterEvent("IGR_BILLING_NAG_DIALOG");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("RAID_INSTANCE_WELCOME");
	self:RegisterEvent("SPELL_CONFIRMATION_PROMPT");
	self:RegisterEvent("SPELL_CONFIRMATION_TIMEOUT");
	self:RegisterEvent("SAVED_VARIABLES_TOO_LARGE");
	self:RegisterEvent("EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED");
	self:RegisterEvent("BAG_OVERFLOW_WITH_FULL_INVENTORY");
	self:RegisterEvent("AUCTION_HOUSE_SCRIPT_DEPRECATED");
	self:RegisterEvent("LOADING_SCREEN_ENABLED");
	self:RegisterEvent("LOADING_SCREEN_DISABLED");
	self:RegisterEvent("ALERT_REGIONAL_CHAT_DISABLED");
	self:RegisterEvent("BARBER_SHOP_OPEN");
	self:RegisterEvent("BARBER_SHOP_CLOSE");
	self:RegisterEvent("RAISED_AS_GHOUL");
	self:RegisterEvent("LFG_ENABLED_STATE_CHANGED");

	-- Events for auction UI handling
	self:RegisterEvent("AUCTION_HOUSE_SHOW");
	self:RegisterEvent("AUCTION_HOUSE_CLOSED");
	self:RegisterEvent("AUCTION_HOUSE_DISABLED");
	self:RegisterEvent("AUCTION_HOUSE_SHOW_FORMATTED_NOTIFICATION");
	self:RegisterEvent("AUCTION_HOUSE_SHOW_NOTIFICATION")

	-- Events for trade skill UI handling
	self:RegisterEvent("TRADE_SKILL_SHOW");
	self:RegisterEvent("TRADE_SKILL_CLOSE");

	-- Events for Item socketing UI
	self:RegisterEvent("SOCKET_INFO_UPDATE");

	-- Events for craft UI handling
	self:RegisterEvent("CRAFT_SHOW");
	self:RegisterEvent("CRAFT_CLOSE");

	-- Events for taxi benchmarking
	self:RegisterEvent("ENABLE_TAXI_BENCHMARK");
	self:RegisterEvent("DISABLE_TAXI_BENCHMARK");

	-- Events for Guild bank UI
	self:RegisterEvent("GUILDBANKFRAME_OPENED");
	self:RegisterEvent("GUILDBANKFRAME_CLOSED");

	-- Events for Glyphs!
	self:RegisterEvent("USE_GLYPH");

	--Events for GMChatUI
	self:RegisterEvent("CHAT_MSG_WHISPER");

	-- Events for WoW Mouse
	self:RegisterEvent("WOW_MOUSE_NOT_FOUND");

	-- Events for talent wipes
	self:RegisterEvent("TALENTS_INVOLUNTARILY_RESET");

	-- Events for reforging
	self:RegisterEvent("FORGE_MASTER_OPENED");
	self:RegisterEvent("FORGE_MASTER_CLOSED");

	-- Events for Archaeology
	self:RegisterEvent("ARCHAEOLOGY_TOGGLE");
	self:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST");

	-- Events for Trial caps
	self:RegisterEvent("TRIAL_CAP_REACHED_MONEY");
	self:RegisterEvent("TRIAL_CAP_REACHED_LEVEL");

	-- debug menu
	self:RegisterEvent("DEBUG_MENU_TOGGLED");

	self:RegisterEvent("BEHAVIORAL_NOTIFICATION");

	-- Shop (for Asia promotion)
	self:RegisterEvent("PRODUCT_DISTRIBUTIONS_UPDATED");

	self:RegisterEvent("TOKEN_AUCTION_SOLD");

	self:RegisterEvent("TAXIMAP_OPENED");

	-- Invite confirmations
	self:RegisterEvent("GROUP_INVITE_CONFIRMATION");

	--Event(s) for soft targetting
	self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED");

	-- Event(s) for Notched displays
	self:RegisterEvent("NOTCHED_DISPLAY_MODE_CHANGED");
end

function UIParent_OnShow(self)
	if ( self.firstTimeLoaded ~= 1 ) then
		CloseAllWindows();
		self.firstTimeLoaded = nil;
	end

	if ( LowHealthFrame ) then
		LowHealthFrame:EvaluateVisibleState();
	end
end

function UIParent_OnHide(self)
	if ( LowHealthFrame ) then
		LowHealthFrame:EvaluateVisibleState();
	end
end

function UIParent_OnUpdate(self, elapsed)
	FCF_OnUpdate(elapsed);
	ButtonPulse_OnUpdate(elapsed);
	AnimatedShine_OnUpdate(elapsed);
	HelpOpenWebTicketButton_OnUpdate(HelpOpenWebTicketButton, elapsed);
end

function AuctionFrame_LoadUI()
	if( IsUsingLegacyAuctionClient() ) then
		UIParentLoadAddOn("Blizzard_AuctionUI");
	else
		UIParentLoadAddOn("Blizzard_AuctionHouseUI");
	end
end

function CraftFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_CraftUI");
end

function EncounterJournal_LoadUI()
	UIParentLoadAddOn("Blizzard_EncounterJournal");
end

function GuildBankFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_GuildBankUI");
end

function TalentFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_TalentUI");
end

function TradeSkillFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_TradeSkillUI");
end

function ItemSocketingFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ItemSocketingUI");
end

function AchievementFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_AchievementUI");
end

function GlyphFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_GlyphUI");
end

function Calendar_LoadUI()
	UIParentLoadAddOn("Blizzard_Calendar");
end

function Reforging_LoadUI()
	UIParentLoadAddOn("Blizzard_ReforgingUI");
end

function ArchaeologyFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ArchaeologyUI");
end

function Arena_LoadUI()
	UIParentLoadAddOn("Blizzard_ArenaUI");
end

function CollectionsJournal_LoadUI()
	UIParentLoadAddOn("Blizzard_Collections");
end

local playerEnteredWorld = false;
local varsLoaded = false;
function NPETutorial_AttemptToBegin(event)
	if ( NewPlayerExperience and not NewPlayerExperience.IsActive ) then
		NewPlayerExperience:Begin();
		return;
	end
	if( event == "PLAYER_ENTERING_WORLD" ) then
		playerEnteredWorld = true;
	elseif ( event == "VARIABLES_LOADED" ) then
		varsLoaded = true;
	end
	if ( playerEnteredWorld and varsLoaded ) then
		Tutorial_LoadUI();
	end
end

function ShowMacroFrame()
	MacroFrame_LoadUI();
	if ( MacroFrame_Show ) then
		MacroFrame_Show();
	end
end

function InspectAchievements (unit)
	if (Kiosk.IsEnabled()) then
		return;
	end

	AchievementFrame_LoadUI();
	AchievementFrame_DisplayComparison(unit);
end

function ToggleAchievementFrame(stats)
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( ( HasCompletedAnyAchievement() or IsInGuild() ) and CanShowAchievementUI() ) then
		AchievementFrame_LoadUI();
		AchievementFrame_ToggleAchievementFrame(stats);
	end
end

function ToggleTalentFrame()
	if (not C_SpecializationInfo.CanPlayerUseTalentSpecUI()) then
		return;
	end

	TalentFrame_LoadUI();
	if ( PlayerTalentFrame:IsShown() ) then
		HideUIPanel(PlayerTalentFrame);
	else
		ShowUIPanel(PlayerTalentFrame);
	end
end

function ToggleGlyphFrame()
	if ( UnitLevel("player") < SHOW_INSCRIPTION_LEVEL ) then
		return;
	end

	GlyphFrame_LoadUI();
	if ( GlyphFrame_Toggle ) then
		GlyphFrame_Toggle();
	end
end

function OpenGlyphFrame()
	if ( UnitLevel("player") < SHOW_INSCRIPTION_LEVEL ) then
		return;
	end

	GlyphFrame_LoadUI();
	if ( GlyphFrame_Open ) then
		GlyphFrame_Open();
	end
end

function GetBattlefieldMapInstanceType()
	local _, instanceType = IsInInstance();
	if instanceType == "pvp" or instanceType == "none" then
		return instanceType;
	end
	return nil;
end

function ToggleBattlefieldMap()
	BattlefieldMap_LoadUI();
	BattlefieldMapFrame:Toggle();
end

function ToggleCalendar()
	Calendar_LoadUI();
	if ( Calendar_Toggle ) then
		Calendar_Toggle();
	end
end

function IsCommunitiesUIDisabledByTrialAccount()
	return IsTrialAccount() or (not C_Club.IsEnabled() and IsVeteranTrialAccount() and not IsInGuild());
end

function ToggleGuildFrame()
	if (Kiosk.IsEnabled()) then
		return;
	end

	if(C_CVar.GetCVarBool("useClassicGuildUI")) then
		ToggleFriendsFrame(FRIEND_TAB_GUILD);
		return;
	end

	local factionGroup = UnitFactionGroup("player");
	if (factionGroup == "Neutral") then
		return;
	end

	if ( IsCommunitiesUIDisabledByTrialAccount() ) then
		UIErrorsFrame:AddMessage(ERR_RESTRICTED_ACCOUNT_TRIAL, 1.0, 0.1, 0.1, 1.0);
		return;
	elseif ( CommunitiesFrame_IsEnabled() ) then
		if ( not BNConnected() ) then
			UIErrorsFrame:AddMessage(ERR_GUILD_AND_COMMUNITIES_UNAVAILABLE, 1.0, 0.1, 0.1, 1.0);
			return;
		elseif ( C_Club.IsRestricted() ~= Enum.ClubRestrictionReason.None ) then
			return;
	end

		ToggleCommunitiesFrame();
	else
		if ( ToggleGuildFinder ) then
			ToggleGuildFinder();
		end
	end
end

function ToggleHelpFrame()
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( HelpFrame:IsShown() ) then
		HideUIPanel(HelpFrame);
	else
		HelpFrame:ShowFrame();
	end
end

function CanShowEncounterJournal()
	return true;
end

function ToggleEncounterJournal()
	if ( Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING ) then
		return;
	end

	if ( not EncounterJournal ) then
		EncounterJournal_LoadUI();
	end
	if ( EncounterJournal ) then
		ToggleFrame(EncounterJournal);
		return true;
	end
	return false;
end

function ToggleCommunitiesFrame()
	ToggleFrame(CommunitiesFrame);
end

COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS = 1;
COLLECTIONS_JOURNAL_TAB_INDEX_PETS = COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS + 1;
COLLECTIONS_JOURNAL_TAB_INDEX_TOYS = COLLECTIONS_JOURNAL_TAB_INDEX_PETS + 1;
COLLECTIONS_JOURNAL_TAB_INDEX_HEIRLOOMS = COLLECTIONS_JOURNAL_TAB_INDEX_TOYS + 1;
COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES = COLLECTIONS_JOURNAL_TAB_INDEX_HEIRLOOMS + 1;

function ToggleCollectionsJournal(tabIndex)
	if Kiosk.IsEnabled() then
		return;
	end

	if CollectionsJournal then
		local tabMatches = not tabIndex or tabIndex == PanelTemplates_GetSelectedTab(CollectionsJournal);
		local isShown = CollectionsJournal:IsShown() and tabMatches;
		SetCollectionsJournalShown(not isShown, tabIndex);
	else
		SetCollectionsJournalShown(true, tabIndex);
	end
end

function SetCollectionsJournalShown(shown, tabIndex)
	if not CollectionsJournal then
		CollectionsJournal_LoadUI();
	end
	if CollectionsJournal then
		if shown then
			ShowUIPanel(CollectionsJournal);
			if tabIndex then
				CollectionsJournal_SetTab(CollectionsJournal, tabIndex);
			end
		else
			HideUIPanel(CollectionsJournal);
		end
	end
end

function ToggleToyCollection(autoPageToCollectedToyID)
	CollectionsJournal_LoadUI();
	ToyBox.autoPageToCollectedToyID = autoPageToCollectedToyID;
	SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_TOYS);
end

function ToggleStoreUI()
	if (Kiosk.IsEnabled()) then
		return;
	end

	local wasShown = StoreFrame_IsShown();
	if ( not wasShown ) then
		--We weren't showing, now we are. We should hide all other panels.
		securecall("CloseAllWindows");
	end
	StoreFrame_SetShown(not wasShown);
end

function SetStoreUIShown(shown)
	if (Kiosk.IsEnabled()) then
		return;
	end

	local wasShown = StoreFrame_IsShown();
	if ( not wasShown and shown ) then
		--We weren't showing, now we are. We should hide all other panels.
		securecall("CloseAllWindows");
	end
	StoreFrame_SetShown(shown);
end

function OpenDeathRecapUI(id)
	--[[if (not DeathRecapFrame) then
		DeathRecap_LoadUI();
	end
	DeathRecapFrame_OpenRecap(id);]]
end

function InspectUnit(unit)
	InspectFrame_LoadUI();
	if ( InspectFrame_Show ) then
		InspectFrame_Show(unit);
	end
end

-- UIParent_OnEvent --
function UIParent_OnEvent(self, event, ...)
	-- First handle any shared events
	UIParent_Shared_OnEvent(self, event, ...);

	local arg1, arg2, arg3, arg4, arg5, arg6 = ...;
	if ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
		if ( StaticPopup_IsAnyDialogShown() ) then
			if ( arg1 ) then
				StaticPopup_Hide("BIND_ENCHANT");
				StaticPopup_Hide("REPLACE_ENCHANT");
				StaticPopup_Hide("ACTION_WILL_BIND_ITEM");
			end
			StaticPopup_Hide("TRADE_REPLACE_ENCHANT");
			StaticPopup_Hide("END_BOUND_TRADEABLE");
		end
	elseif ( event == "VARIABLES_LOADED" ) then
		UIParent.variablesLoaded = true;

		LocalizeFrames();

		local lastTalkedToGM = GetCVar("lastTalkedToGM");
		if ( lastTalkedToGM ~= "" ) then
			GMChatFrame_LoadUI();
			GMChatFrame:Show()
			local info = ChatTypeInfo["WHISPER"];
			GMChatFrame:AddMessage(format(GM_CHAT_LAST_SESSION, "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t "..
				GetGMLink(lastTalkedToGM, "["..lastTalkedToGM.."]")), info.r, info.g, info.b, info.id);
			GMChatFrameEditBox:SetAttribute("tellTarget", lastTalkedToGM);
			GMChatFrameEditBox:SetAttribute("chatType", "WHISPER");
		end
		TargetFrame_OnVariablesLoaded();

		StoreFrame_CheckForFree(event);
		EventUtil.TriggerOnVariablesLoaded();
	elseif ( event == "PLAYER_LOGIN" ) then
		TimeManager_LoadUI();
		-- You can override this if you want a Combat Log replacement
		CombatLog_LoadUI();
	elseif ( event == "PLAYER_DEAD" ) then
		if ( not StaticPopup_Visible("DEATH") ) then
			CloseAllWindows(1);
		end
		if ( (GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1) and (not ResurrectGetOfferer()) ) then
			StaticPopup_Show("DEATH");
		end
	elseif ( event == "SELF_RES_SPELL_CHANGED" ) then
		if ( StaticPopup_Visible("DEATH") ) then
			StaticPopup_Show("DEATH"); --If we're already showing a death prompt, we should refresh it.
		end
	elseif ( event == "PLAYER_ALIVE" or event == "RAISED_AS_GHOUL" ) then
		StaticPopup_Hide("DEATH");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		if ( UnitIsGhost("player") ) then
			GhostFrame:Show();
		else
			GhostFrame:Hide();
		end
	elseif ( event == "PLAYER_UNGHOST" ) then
		StaticPopup_Hide("RESURRECT");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		StaticPopup_Hide("RESURRECT_NO_TIMER");
		StaticPopup_Hide("SKINNED");
		StaticPopup_Hide("SKINNED_REPOP");
		GhostFrame:Hide();
	elseif ( event == "RESURRECT_REQUEST" ) then
		ShowResurrectRequest(arg1);
	elseif ( event == "PLAYER_SKINNED" ) then
		StaticPopup_Hide("RESURRECT");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		StaticPopup_Hide("RESURRECT_NO_TIMER");

		--[[
		if (arg1 == 1) then
			StaticPopup_Show("SKINNED_REPOP");
		else
			StaticPopup_Show("SKINNED");
		end
		]]
		UIErrorsFrame:AddMessage(DEATH_CORPSE_SKINNED, 1.0, 0.1, 0.1, 1.0);
	elseif ( event == "TRADE_REQUEST" ) then
		StaticPopup_Show("TRADE", arg1);
	elseif ( event == "CHANNEL_INVITE_REQUEST" ) then
		if ( GetCVarBool("blockChannelInvites") ) then
			DeclineChannelInvite(arg1);
		else
			StaticPopup_Show("CHAT_CHANNEL_INVITE", arg1, arg2, arg1);
		end
	elseif ( event == "CHANNEL_PASSWORD_REQUEST" ) then
		StaticPopup_Show("CHAT_CHANNEL_PASSWORD", arg1, nil, arg1);
	elseif ( event == "PARTY_INVITE_REQUEST" ) then
		FlashClientIcon();

		local name, tank, healer, damage, isXRealm, allowMultipleRoles, inviterGuid = ...;
		local text = isXRealm and INVITATION_XREALM or INVITATION;
		text = string.format(text, name);

		if ( WillAcceptInviteRemoveQueues() ) then
			text = text.."\n\n"..ACCEPTING_INVITE_WILL_REMOVE_QUEUE;
		end
		StaticPopup_Show("PARTY_INVITE", text);
	elseif ( event == "PARTY_INVITE_CANCEL" ) then
		StaticPopup_Hide("PARTY_INVITE");
		StaticPopupSpecial_Hide(LFGInvitePopup);
	elseif ( event == "GUILD_INVITE_CANCEL" ) then
		StaticPopup_Hide("GUILD_INVITE");
	elseif ( event == "ARENA_TEAM_INVITE_REQUEST" ) then
		StaticPopup_Show("ARENA_TEAM_INVITE", arg1, arg2);
	elseif ( event == "ARENA_TEAM_INVITE_CANCEL" ) then
		StaticPopup_Hide("ARENA_TEAM_INVITE");
	elseif ( event == "PLAYER_CAMPING" ) then
		StaticPopup_Show("CAMP");
	elseif ( event == "PLAYER_QUITING" ) then
		StaticPopup_Show("QUIT");
	elseif ( event == "LOGOUT_CANCEL" ) then
		StaticPopup_Hide("CAMP");
		StaticPopup_Hide("QUIT");
	elseif ( event == "LOOT_BIND_CONFIRM" ) then
		local texture, item, quantity, itemID, quality, locked = GetLootSlotInfo(arg1);
		StaticPopup_Show("LOOT_BIND", ITEM_QUALITY_COLORS[quality].hex..item.."|r", nil, arg1);
	elseif ( event == "EQUIP_BIND_CONFIRM" ) then
		StaticPopup_Hide("EQUIP_BIND_REFUNDABLE");
		StaticPopup_Hide("EQUIP_BIND_TRADEABLE");
		StaticPopup_Show("EQUIP_BIND", nil, nil, arg1);
	elseif ( event == "EQUIP_BIND_REFUNDABLE_CONFIRM" ) then
		StaticPopup_Hide("EQUIP_BIND");
		StaticPopup_Hide("EQUIP_BIND_TRADEABLE");
		StaticPopup_Show("EQUIP_BIND_REFUNDABLE", nil, nil, arg1);
	elseif ( event == "EQUIP_BIND_TRADEABLE_CONFIRM" ) then
		StaticPopup_Hide("EQUIP_BIND");
		StaticPopup_Hide("EQUIP_BIND_REFUNDABLE");
		StaticPopup_Show("EQUIP_BIND_TRADEABLE", nil, nil, arg1);
	elseif ( event == "USE_BIND_CONFIRM" ) then
		StaticPopup_Show("USE_BIND");
	elseif( event == "USE_NO_REFUND_CONFIRM" )then
		StaticPopup_Show("USE_NO_REFUND_CONFIRM");
	elseif ( event == "CONFIRM_BEFORE_USE" ) then
		StaticPopup_Show("CONFIM_BEFORE_USE");
	elseif ( event == "DELETE_ITEM_CONFIRM" ) then
		-- Check quality, ignore heirlooms
		if ( arg2 >= LE_ITEM_QUALITY_RARE and arg2 ~= LE_ITEM_QUALITY_HEIRLOOM ) then
			StaticPopup_Show("DELETE_GOOD_ITEM", arg1);
		else
			StaticPopup_Show("DELETE_ITEM", arg1);
		end
	elseif ( event == "QUEST_ACCEPT_CONFIRM" ) then
		local numEntries, numQuests = GetNumQuestLogEntries();
		if( numQuests >= MAX_QUESTS) then
			StaticPopup_Show("QUEST_ACCEPT_LOG_FULL", arg1, arg2);
		else
			StaticPopup_Show("QUEST_ACCEPT", arg1, arg2);
		end
	elseif ( event =="QUEST_LOG_UPDATE" or event == "UNIT_QUEST_LOG_CHANGED" ) then
		local frameName = StaticPopup_Visible("QUEST_ACCEPT_LOG_FULL");
		if( frameName ) then
			local numEntries, numQuests = GetNumQuestLogEntries();
			local button = _G[frameName.."Button1"];
			if( numQuests < MAX_QUESTS ) then
				button:Enable();
			else
				button:Disable();
			end
		end
	elseif ( event == "CURSOR_CHANGED" ) then
		if ( not CursorHasItem() ) then
			StaticPopup_Hide("EQUIP_BIND");
			StaticPopup_Hide("EQUIP_BIND_TRADEABLE");
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		-- Get multi-actionbar states (before CloseAllWindows() since that may be hooked by AddOns)
		-- We don't want to call this, as the values GetActionBarToggles() returns are incorrect if it's called before the client mirrors SetActionBarToggles values from the server.
		-- SHOW_MULTI_ACTIONBAR_1, SHOW_MULTI_ACTIONBAR_2, SHOW_MULTI_ACTIONBAR_3, SHOW_MULTI_ACTIONBAR_4 = GetActionBarToggles();
		MultiActionBar_Update();

		-- Close any windows that were previously open
		CloseAllWindows(1);

		UpdateMicroButtons();

		-- Fix for Bug 124392
		StaticPopup_Hide("LEVEL_GRANT_PROPOSED");
		StaticPopup_Hide("CONFIRM_LEAVE_BATTLEFIELD");

		local _, instanceType = IsInInstance();
		if ( instanceType == "arena" or instanceType == "pvp") then
			Arena_LoadUI();
		end
		if ( C_Commentator.IsSpectating() ) then
			Commentator_LoadUI();
		end
		if ( not BattlefieldMapFrame and DoesInstanceTypeMatchBattlefieldMapSettings() ) then
			BattlefieldMap_LoadUI();
		end

		if ( GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1 ) then
			StaticPopup_Show("DEATH");
		end

		local alreadyShowingSummonPopup = StaticPopup_Visible("CONFIRM_SUMMON_STARTING_AREA") or StaticPopup_Visible("CONFIRM_SUMMON_SCENARIO") or StaticPopup_Visible("CONFIRM_SUMMON")
		if ( not alreadyShowingSummonPopup and C_SummonInfo.GetSummonConfirmTimeLeft() > 0 ) then
			local summonReason = C_SummonInfo.GetSummonReason();
			local isSkippingStartingArea = C_SummonInfo.IsSummonSkippingStartExperience();
			if ( isSkippingStartingArea ) then -- check if skiping start experience
				StaticPopup_Show("CONFIRM_SUMMON_STARTING_AREA");
			elseif (summonType == LE_SUMMON_REASON_SCENARIO) then
				StaticPopup_Show("CONFIRM_SUMMON_SCENARIO");
			else
				StaticPopup_Show("CONFIRM_SUMMON");
			end
		end

		UpdateUIParentRelativeToDebugMenu();

		--Bonus roll/spell confirmation.
		local spellConfirmations = GetSpellConfirmationPromptsInfo();

		for i, spellConfirmation in ipairs(spellConfirmations) do
			if spellConfirmation.spellID then
				if spellConfirmation.confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_STATIC_TEXT then
					StaticPopup_Show("SPELL_CONFIRMATION_PROMPT", spellConfirmation.text, spellConfirmation.duration, spellConfirmation.spellID);
				elseif spellConfirmation.confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_SIMPLE_WARNING then
					StaticPopup_Show("SPELL_CONFIRMATION_WARNING", spellConfirmation.text, nil, spellConfirmation.spellID);
				elseif spellConfirmation.confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL then
					BonusRollFrame_StartBonusRoll(spellConfirmation.spellID, spellConfirmation.text, spellConfirmation.duration, spellConfirmation.currencyID, spellConfirmation.currencyCost);
				end
			end
		end

		local resurrectOfferer = ResurrectGetOfferer();
		if resurrectOfferer then
			ShowResurrectRequest(resurrectOfferer);
		end

		--Group Loot Roll Windows.
		local pendingLootRollIDs = GetActiveLootRollIDs();

		for i=1, #pendingLootRollIDs do
			GroupLootFrame_OpenNewFrame(pendingLootRollIDs[i], GetLootRollTimeLeft(pendingLootRollIDs[i]));
		end

		self.battlefieldBannerShown = nil;

		SetLookingForGroupUIAvailable(C_LFGInfo.IsGroupFinderEnabled());

		UpdateUIParentPosition();

		if Kiosk.IsEnabled() then
			C_AddOns.LoadAddOn("Blizzard_Kiosk");
		end
		if ( UnitIsGhost("player") ) then
			GhostFrame:Show();
		else
			GhostFrame:Hide();
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		-- Hide/Show party member frames
		RaidOptionsFrame_UpdatePartyFrames();
		if ( not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
			StaticPopup_Hide("CONFIRM_LEAVE_INSTANCE_PARTY");
		end
	elseif ( event == "MIRROR_TIMER_START" ) then
		MirrorTimer_Show(arg1, arg2, arg3, arg4, arg5, arg6);
	elseif ( event == "DUEL_REQUESTED" ) then
		StaticPopup_Show("DUEL_REQUESTED", arg1);
	elseif ( event == "DUEL_OUTOFBOUNDS" ) then
		StaticPopup_Show("DUEL_OUTOFBOUNDS");
	elseif ( event == "DUEL_INBOUNDS" ) then
		StaticPopup_Hide("DUEL_OUTOFBOUNDS");
	elseif ( event == "DUEL_FINISHED" ) then
		StaticPopup_Hide("DUEL_REQUESTED");
		StaticPopup_Hide("DUEL_OUTOFBOUNDS");
	elseif ( event == "PET_BATTLE_PVP_DUEL_REQUESTED" ) then
		StaticPopup_Show("PET_BATTLE_PVP_DUEL_REQUESTED", arg1);
	elseif ( event == "PET_BATTLE_PVP_DUEL_REQUEST_CANCEL" ) then
		StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED");
	elseif ( event == "PET_BATTLE_QUEUE_PROPOSE_MATCH" ) then
		PlaySound(SOUNDKIT.UI_PET_BATTLES_PVP_THROUGH_QUEUE);
		StaticPopupSpecial_Show(PetBattleQueueReadyFrame);
	elseif ( event == "PET_BATTLE_QUEUE_PROPOSAL_DECLINED" or event == "PET_BATTLE_QUEUE_PROPOSAL_ACCEPTED" ) then
		StaticPopupSpecial_Hide(PetBattleQueueReadyFrame);
	elseif ( event == "TRADE_REQUEST_CANCEL" ) then
		StaticPopup_Hide("TRADE");
	elseif ( event == "CONFIRM_XP_LOSS" ) then
		local resSicknessTime = GetResSicknessDuration();
		if ( resSicknessTime ) then
			if (UnitLevel("player") < Constants.LevelConstsExposed.MIN_RES_SICKNESS_LEVEL) then
				StaticPopup_Show("XP_LOSS_NO_SICKNESS_NO_DURABILITY", resSicknessTime, nil, resSicknessTime);
			else
				StaticPopup_Show("XP_LOSS", resSicknessTime, nil, resSicknessTime);
			end
		else
			if (UnitLevel("player") <= Constants.LevelConstsExposed.MIN_RES_SICKNESS_LEVEL) then
				StaticPopup_Show("XP_LOSS_NO_SICKNESS_NO_DURABILITY", nil, nil, 1);
			else
				StaticPopup_Show("XP_LOSS_NO_SICKNESS", nil, nil, 1);
			end
		end
		HideUIPanel(GossipFrame);
	elseif ( event == "CORPSE_IN_RANGE" ) then
		StaticPopup_Show("RECOVER_CORPSE");
	elseif ( event == "CORPSE_IN_INSTANCE" ) then
		StaticPopup_Show("RECOVER_CORPSE_INSTANCE");
	elseif ( event == "CORPSE_OUT_OF_RANGE" ) then
		StaticPopup_Hide("RECOVER_CORPSE");
		StaticPopup_Hide("RECOVER_CORPSE_INSTANCE");
		StaticPopup_Hide("XP_LOSS");
	elseif ( event == "AREA_SPIRIT_HEALER_IN_RANGE" ) then
		AcceptAreaSpiritHeal();
		StaticPopup_Show("AREA_SPIRIT_HEAL");
	elseif ( event == "AREA_SPIRIT_HEALER_OUT_OF_RANGE" ) then
		StaticPopup_Hide("AREA_SPIRIT_HEAL");
	elseif (event == "ACTION_WILL_BIND_ITEM") then
		StaticPopup_Show("ACTION_WILL_BIND_ITEM");
	elseif ( event == "BIND_ENCHANT" ) then
		StaticPopup_Show("BIND_ENCHANT");
	elseif ( event == "REPLACE_ENCHANT" ) then
		StaticPopup_Show("REPLACE_ENCHANT", arg1, arg2);
	elseif ( event == "TRADE_REPLACE_ENCHANT" ) then
		StaticPopup_Show("TRADE_REPLACE_ENCHANT", arg1, arg2);
	elseif ( event == "END_BOUND_TRADEABLE" ) then
		local dialog = StaticPopup_Show("END_BOUND_TRADEABLE", nil, nil, arg1);
	elseif ( event == "MACRO_ACTION_BLOCKED" or event == "ADDON_ACTION_BLOCKED" ) then
		DisplayInterfaceActionBlockedMessage();
	elseif ( event == "MACRO_ACTION_FORBIDDEN" ) then
		StaticPopup_Show("MACRO_ACTION_FORBIDDEN");
	elseif ( event == "ADDON_ACTION_FORBIDDEN" ) then
		StaticPopup_Show("ADDON_ACTION_FORBIDDEN", arg1, nil, arg1);
	elseif ( event == "PLAYER_CONTROL_LOST" ) then
		if ( UnitOnTaxi("player") ) then
			return;
		end
		CloseAllWindows_WithExceptions();

		UIParent.isOutOfControl = 1;
	elseif ( event == "PLAYER_CONTROL_GAINED" ) then
		UIParent.isOutOfControl = nil;
	elseif ( event == "START_LOOT_ROLL" ) then
		GroupLootFrame_OpenNewFrame(arg1, arg2);
	elseif ( event == "CONFIRM_LOOT_ROLL" ) then
		local texture, name, count, quality, bindOnPickUp = GetLootRollItemInfo(arg1);
		local dialog = StaticPopup_Show("CONFIRM_LOOT_ROLL", ITEM_QUALITY_COLORS[quality].hex..name.."|r");
		if ( dialog ) then
			dialog:SetFormattedText(arg3, ITEM_QUALITY_COLORS[quality].hex..name.."|r");
			dialog:Resize("CONFIRM_LOOT_ROLL");
			dialog.data = arg1;
			dialog.data2 = arg2;
		end
	elseif ( event == "SPELL_CONFIRMATION_PROMPT" ) then
		local spellID, confirmType, text, duration, currencyID, currencyCost, difficultyID = ...;
		if ( confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_STATIC_TEXT ) then
			StaticPopup_Show("SPELL_CONFIRMATION_PROMPT", text, duration, spellID);
		elseif ( confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_SIMPLE_WARNING ) then
			StaticPopup_Show("SPELL_CONFIRMATION_WARNING", text, nil, spellID);
		elseif ( confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL ) then
			BonusRollFrame_StartBonusRoll(spellID, text, duration, currencyID, currencyCost, difficultyID);
		end
	elseif ( event == "SPELL_CONFIRMATION_TIMEOUT" ) then
		local spellID, confirmType = ...;
		if ( confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_STATIC_TEXT ) then
			StaticPopup_Hide("SPELL_CONFIRMATION_PROMPT", spellID);
		elseif ( confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_SIMPLE_WARNING ) then
			StaticPopup_Hide("SPELL_CONFIRMATION_WARNING", spellID);
		elseif ( confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL ) then
			BonusRollFrame_CloseBonusRoll();
		end
	elseif ( event == "SAVED_VARIABLES_TOO_LARGE" ) then
		local addonName = ...;
		StaticPopup_Show("SAVED_VARIABLES_TOO_LARGE", addonName);
	elseif ( event == "CONFIRM_DISENCHANT_ROLL" ) then
		local texture, name, count, quality, bindOnPickUp = GetLootRollItemInfo(arg1);
		local dialog = StaticPopup_Show("CONFIRM_LOOT_ROLL", ITEM_QUALITY_COLORS[quality].hex..name.."|r");
		if ( dialog ) then
			dialog:SetFormattedText(LOOT_NO_DROP_DISENCHANT, ITEM_QUALITY_COLORS[quality].hex..name.."|r");
			dialog:Resize("CONFIRM_LOOT_ROLL");
			dialog.data = arg1;
			dialog.data2 = arg2;
		end
	elseif ( event == "INSTANCE_BOOT_START" ) then
		StaticPopup_Show("INSTANCE_BOOT");
	elseif ( event == "INSTANCE_BOOT_STOP" ) then
		StaticPopup_Hide("INSTANCE_BOOT");
	elseif ( event == "INSTANCE_LOCK_START" ) then
		StaticPopup_Show("INSTANCE_LOCK", nil, nil, { enforceTime = true });
	elseif ( event == "INSTANCE_LOCK_STOP" ) then
		StaticPopup_Hide("INSTANCE_LOCK");
	elseif ( event == "INSTANCE_LOCK_WARNING" ) then
		StaticPopup_Show("INSTANCE_LOCK", nil, nil, { enforceTime = false });
	elseif ( event == "CONFIRM_TALENT_WIPE" ) then
		HideUIPanel(GossipFrame);
		StaticPopupDialogs["CONFIRM_TALENT_WIPE"].text = _G["CONFIRM_TALENT_WIPE_"..arg2];
		local dialog = StaticPopup_Show("CONFIRM_TALENT_WIPE");
		if ( dialog ) then
			MoneyFrame_Update(dialog.MoneyFrame, arg1);
			-- open the talent UI to the player's active talent group...just so the player knows
			-- exactly which talent spec he is wiping
			TalentFrame_LoadUI();
			if ( PlayerTalentFrame_Open ) then
				PlayerTalentFrame_Open(false, C_SpecializationInfo.GetActiveSpecGroup());
			end
		end
	elseif ( event == "CONFIRM_BARBERS_CHOICE" ) then
		HideUIPanel(GossipFrame);
		StaticPopupDialogs["CONFIRM_BARBERS_CHOICE"].text = _G["BARBERS_CHOICE_CONFIRM"];
		local dialog = StaticPopup_Show("CONFIRM_BARBERS_CHOICE");
		if ( dialog ) then
			MoneyFrame_Update(dialog.MoneyFrame, arg1);
		end
	elseif ( event == "CONFIRM_PET_UNLEARN" ) then
		HideUIPanel(GossipFrame);
		local dialog = StaticPopup_Show("CONFIRM_PET_UNLEARN");
		if ( dialog ) then
			MoneyFrame_Update(dialog.MoneyFrame, arg1);
		end
	elseif ( event == "CONFIRM_BINDER" ) then
		StaticPopup_Show("CONFIRM_BINDER", arg1);
	elseif ( event == "CONFIRM_SUMMON" ) then
		local summonType, skipStartingArea = arg1, arg2;
		if ( skipStartingArea ) then -- check if skiping start experience
			StaticPopup_Show("CONFIRM_SUMMON_STARTING_AREA");
		elseif (summonType == LE_SUMMON_REASON_SCENARIO) then
			StaticPopup_Show("CONFIRM_SUMMON_SCENARIO");
		else
			StaticPopup_Show("CONFIRM_SUMMON");
		end
	elseif ( event == "CANCEL_SUMMON" ) then
		StaticPopup_Hide("CONFIRM_SUMMON");
		StaticPopup_Hide("CONFIRM_SUMMON_SCENARIO");
		StaticPopup_Hide("CONFIRM_SUMMON_STARTING_AREA");
	elseif ( event == "BILLING_NAG_DIALOG" ) then
		StaticPopup_Show("BILLING_NAG", arg1);
	elseif ( event == "IGR_BILLING_NAG_DIALOG" ) then
		StaticPopup_Show("IGR_BILLING_NAG");
	elseif ( event == "GOSSIP_CONFIRM" ) then
		if ( arg3 > 0 ) then
			StaticPopupDialogs["GOSSIP_CONFIRM"].hasMoneyFrame = 1;
		else
			StaticPopupDialogs["GOSSIP_CONFIRM"].hasMoneyFrame = nil;
		end
		local dialog = StaticPopup_Show("GOSSIP_CONFIRM", arg2, nil, arg1);
		if ( dialog and arg3 > 0 ) then
			MoneyFrame_Update(dialog.MoneyFrame, arg3);
		end
	elseif ( event == "GOSSIP_ENTER_CODE" ) then
		StaticPopup_Show("GOSSIP_ENTER_CODE", nil, nil, arg1);
	elseif ( event == "GOSSIP_CONFIRM_CANCEL" or event == "GOSSIP_CLOSED" ) then
		StaticPopup_Hide("GOSSIP_CONFIRM");
		StaticPopup_Hide("GOSSIP_ENTER_CODE");
	elseif ( event == "ALERT_REGIONAL_CHAT_DISABLED" ) then
		StaticPopup_Show("REGIONAL_CHAT_DISABLED")

	--Events for handling Auction UI
	elseif ( event == "AUCTION_HOUSE_SHOW" ) then
		AuctionFrame_LoadUI();
		if ( AuctionFrame_Show ) then
			AuctionFrame_Show();
		end
	elseif ( event == "AUCTION_HOUSE_CLOSED" ) then
		if ( AuctionFrame_Hide ) then
			AuctionFrame_Hide();
		end
	elseif ( event == "AUCTION_HOUSE_DISABLED" ) then
		StaticPopup_Show("AUCTION_HOUSE_DISABLED");
	elseif ( event == "AUCTION_HOUSE_SHOW_NOTIFICATION" or event == "AUCTION_HOUSE_SHOW_FORMATTED_NOTIFICATION" ) then
		local auctionHouseNotification, formatArg = ...;
		Chat_AddSystemMessage(ChatFrameUtil.GetAuctionHouseNotificationText(auctionHouseNotification, formatArg));

	-- Events for trade skill UI handling
	elseif ( event == "TRADE_SKILL_SHOW" ) then
		TradeSkillFrame_LoadUI();
		ShowUIPanel(TradeSkillFrame);
	elseif ( event == "TRADE_SKILL_CLOSE" ) then
		HideUIPanel(TradeSkillFrame);
	elseif ( event == "OBLITERUM_FORGE_SHOW" ) then
		ObliterumForgeFrame_LoadUI();
		ShowUIPanel(ObliterumForgeFrame);
	elseif ( event == "SCRAPPING_MACHINE_SHOW" ) then
		ScrappingMachineFrame_LoadUI();
		ShowUIPanel(ScrappingMachineFrame);
	-- Event for item socketing handling
	elseif ( event == "SOCKET_INFO_UPDATE" ) then
		ItemSocketingFrame_LoadUI();
		ItemSocketingFrame_Update();
		ShowUIPanel(ItemSocketingFrame);

	-- Events for craft UI handling
	elseif ( event == "CRAFT_SHOW" ) then
		CraftFrame_LoadUI();
		ShowUIPanel(CraftFrame);
	elseif ( event == "CRAFT_CLOSE" ) then
		HideUIPanel(CraftFrame);
	elseif ( event == "ARTIFACT_UPDATE" ) then
			ArtifactFrame_LoadUI();
			ShowUIPanel(ArtifactFrame);
	elseif ( event == "ARTIFACT_RESPEC_PROMPT" ) then
		ArtifactFrame_LoadUI();
		ShowUIPanel(ArtifactFrame);

		if C_ArtifactUI.GetPointsRemaining() < C_ArtifactUI.GetRespecCost() then
			StaticPopup_Show("NOT_ENOUGH_POWER_ARTIFACT_RESPEC", BreakUpLargeNumbers(C_ArtifactUI.GetRespecCost()));
		else
			StaticPopup_Show("CONFIRM_ARTIFACT_RESPEC", BreakUpLargeNumbers(C_ArtifactUI.GetRespecCost()));
		end

	elseif ( event == "ARTIFACT_ENDGAME_REFUND" ) then
		local numRefunded, refundedTier, bagOrInventorySlot = ...;
		ArtifactFrame_LoadUI();
		ArtifactFrame:OnTraitsRefunded(numRefunded, refundedTier);

	elseif ( event == "ARTIFACT_RELIC_FORGE_UPDATE" ) then
		ArtifactFrame_LoadUI();
		ShowUIPanel(ArtifactRelicForgeFrame);

	elseif ( event == "ADVENTURE_MAP_OPEN" ) then
		Garrison_LoadUI();
		local followerTypeID = ...;
		if ( followerTypeID == LE_FOLLOWER_TYPE_GARRISON_7_0 ) then
		ShowUIPanel(OrderHallMissionFrame);
		else
			ShowUIPanel(BFAMissionFrame);
		end

	-- Event for BarberShop handling
	elseif ( event == "BARBER_SHOP_OPEN" ) then
		BarberShopFrame_LoadUI();
		if ( BarberShopFrame ) then
			ShowUIPanel(BarberShopFrame);
		end
	elseif ( event == "BARBER_SHOP_CLOSE" ) then
		if ( BarberShopFrame and BarberShopFrame:IsVisible() ) then
			HideUIPanel(BarberShopFrame);
		end

	-- Event for guildbank handling
	elseif ( event == "GUILDBANKFRAME_OPENED" ) then
		GuildBankFrame_LoadUI();
		if ( GuildBankFrame ) then
			ShowUIPanel(GuildBankFrame);
			if ( not GuildBankFrame:IsVisible() ) then
				CloseGuildBankFrame();
			end
		end
	elseif ( event == "GUILDBANKFRAME_CLOSED" ) then
		if ( GuildBankFrame ) then
			HideUIPanel(GuildBankFrame);
		end

	-- Events for Glyphs
	elseif ( event == "USE_GLYPH" ) then
		OpenGlyphFrame();
		return;

	-- Display instance reset info
	elseif ( event == "RAID_INSTANCE_WELCOME" ) then
		local dungeonName = arg1;
		local daysLeft = arg2;
		local hoursLeft = arg3;
		local minutesLeft = arg4;
		local locked = arg5;

		local message;

		if ( locked == 0 ) then
			message = format(RAID_INSTANCE_WELCOME, dungeonName, daysLeft, hoursLeft, minutesLeft)
		else
			if ( lockExpireTime == 0 ) then
				message = format(RAID_INSTANCE_WELCOME_EXTENDED, dungeonName);
			else
				message = format(RAID_INSTANCE_WELCOME, dungeonName, daysLeft, hoursLeft, minutesLeft);

			end
		end

		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(message, info.r, info.g, info.b, info.id);

	-- Events for taxi benchmarking
	elseif ( event == "ENABLE_TAXI_BENCHMARK" ) then
		if ( not FramerateText:IsShown() ) then
			ToggleFramerate(true);
		end
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(BENCHMARK_TAXI_MODE_ON, info.r, info.g, info.b, info.id);
	elseif ( event == "DISABLE_TAXI_BENCHMARK" ) then
		if ( FramerateText.benchmark ) then
			ToggleFramerate();
		end
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(BENCHMARK_TAXI_MODE_OFF, info.r, info.g, info.b, info.id);
	elseif ( event == "LEVEL_GRANT_PROPOSED" ) then
		local isAlliedRace, hasHeritageArmorUnlocked = UnitAlliedRaceInfo("player");
		if (isAlliedRace and not hasHeritageArmorUnlocked) then
			StaticPopup_Show("LEVEL_GRANT_PROPOSED_ALLIED_RACE", arg1);
		else
			StaticPopup_Show("LEVEL_GRANT_PROPOSED", arg1);
		end
	elseif ( event == "CHAT_MSG_WHISPER" and arg6 == "GM" ) then	--GMChatUI
		GMChatFrame_LoadUI(event, ...);
	elseif ( event == "WOW_MOUSE_NOT_FOUND" ) then
		StaticPopup_Show("WOW_MOUSE_NOT_FOUND");
	elseif ( event == "TALENTS_INVOLUNTARILY_RESET" ) then
		if ( arg1 ) then
			StaticPopup_Show("TALENTS_INVOLUNTARILY_RESET_PET");
		else
			StaticPopup_Show("TALENTS_INVOLUNTARILY_RESET");
		end
	elseif (event == "SPEC_INVOLUNTARILY_CHANGED" ) then
		StaticPopup_Show("SPEC_INVOLUNTARILY_CHANGED")
	elseif( event == "EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED" ) then
		StaticPopup_Show("EXPERIMENTAL_CVAR_WARNING");
	elseif ( event == "BAG_OVERFLOW_WITH_FULL_INVENTORY") then
		StaticPopup_Show("CLIENT_INVENTORY_FULL_OVERFLOW");
	elseif ( event == "AUCTION_HOUSE_SCRIPT_DEPRECATED") then
		StaticPopup_Show("AUCTION_HOUSE_DEPRECATED");

	-- Events for Reforging UI handling
	elseif ( event == "FORGE_MASTER_OPENED" ) then
		Reforging_LoadUI();
		if ( ReforgingFrame_Show ) then
			ReforgingFrame_Show();
		end
	elseif ( event == "FORGE_MASTER_CLOSED" ) then
		if ( ReforgingFrame_Hide ) then
			ReforgingFrame_Hide();
		end

	-- Events for Archaeology
	elseif ( event == "ARCHAEOLOGY_TOGGLE" ) then
		ArchaeologyFrame_LoadUI();
		if ( ArchaeologyFrame_Show and not ArchaeologyFrame:IsShown()) then
			ArchaeologyFrame_Show();
		elseif ( ArchaeologyFrame_Hide ) then
			ArchaeologyFrame_Hide();
		end
	elseif ( event == "ARCHAEOLOGY_SURVEY_CAST" ) then
		ArchaeologyFrame_LoadUI();
		--ArcheologyDigsiteProgressBar:OnEvent(event, ...); -- Add this line if we add the Archaeology progress bar back in.
		self:UnregisterEvent("ARCHAEOLOGY_SURVEY_CAST");

	-- Events for Transmogrify UI handling
	elseif ( event == "TRANSMOGRIFY_OPEN" ) then
		CollectionsJournal_LoadUI();
		if ( WardrobeFrame ) then
			ShowUIPanel(WardrobeFrame);
		end
	elseif ( event == "TRANSMOGRIFY_CLOSE" ) then
		if ( WardrobeFrame ) then
			HideUIPanel(WardrobeFrame);
		end

	-- Events for adventure journal
	elseif ( event == "AJ_OPEN" ) then
		if (C_AdventureJournal.CanBeShown()) then
			if ( not EncounterJournal ) then
				EncounterJournal_LoadUI();
			end
			ShowUIPanel(EncounterJournal);
			EJSuggestFrame_OpenFrame();
		end
	--Events for Trial caps
	elseif ( event == "TRIAL_CAP_REACHED_MONEY" ) then
		TrialAccountCapReached_Inform("money");
	elseif ( event == "TRIAL_CAP_REACHED_LEVEL" ) then
		TrialAccountCapReached_Inform("level");

	elseif( event == "SOR_START_EXPERIENCE_INCOMPLETE" ) then
		StaticPopup_Show("ERR_SOR_STARTING_EXPERIENCE_INCOMPLETE");

	-- Events for Black Market UI handling
	elseif ( event == "BLACK_MARKET_OPEN" ) then
		BlackMarket_LoadUI();
		if ( BlackMarketFrame_Show ) then
			BlackMarketFrame_Show();
		end
	elseif ( event == "BLACK_MARKET_CLOSE" ) then
		if ( BlackMarketFrame_Hide ) then
			BlackMarketFrame_Hide();
		end

	-- Events for Item Upgrading
	elseif ( event == "ITEM_UPGRADE_MASTER_OPENED" ) then
		ItemUpgrade_LoadUI();
		if ( ItemUpgradeFrame_Show ) then
			ItemUpgradeFrame_Show();
		end
	elseif ( event == "ITEM_UPGRADE_MASTER_CLOSED" ) then
		if ( ItemUpgradeFrame_Hide ) then
			ItemUpgradeFrame_Hide();
		end

	-- Events for Toy Box
	elseif ( event == "TOYS_UPDATED" ) then
		if ( not CollectionsJournal ) then
			local itemID, new = ...;
			if ( itemID and new ) then
				-- Toy box isn't loaded, save that this itemid is new in this session incase the journal is opened later
				if not self.newToys then
					self.newToys = {};
				end
				self.newToys[itemID] = true;

				self.mostRecentCollectedToyID = itemID;
				SetCVar("petJournalTab", 3);
			end
		end

	-- Events for Heirloom Journal
	elseif ( event == "HEIRLOOM_UPGRADE_TARGETING_CHANGED" ) then
		local isPendingHeirloomUpgrade = ...;
		if ( isPendingHeirloomUpgrade ) then
			if ( not CollectionsJournal ) then
				CollectionsJournal_LoadUI();
			end
			HeirloomsJournal:SetFindClosestUpgradeablePage(isPendingHeirloomUpgrade);
			ShowUIPanel(CollectionsJournal);
			CollectionsJournal_SetTab(CollectionsJournal, 4);
		end
	elseif ( event == "HEIRLOOMS_UPDATED" ) then
		if ( not CollectionsJournal ) then
			local itemID, updateReason = ...;
			if ( itemID and updateReason == "NEW" ) then
				-- Heirloom journal isn't loaded, save that this itemid is new in this session incase the journal is opened later
				if not self.newHeirlooms then
					self.newHeirlooms = {};
				end
				self.newHeirlooms[itemID] = true;
			end
		end

	-- Events for Wardrobe
	elseif ( event == "TRANSMOG_COLLECTION_UPDATED" ) then
		if ( not CollectionsJournal ) then
			local latestAppearanceID, latestAppearanceCategoryID = C_TransmogCollection.GetLatestAppearance();
			if ( latestAppearanceID and latestAppearanceID ~= self.latestAppearanceID ) then
				self.latestAppearanceID = latestAppearanceID;
				SetCVar("petJournalTab", 5);
			end
		end

	-- Quest Choice trigger event

	elseif ( event == "QUEST_CHOICE_UPDATE" ) then
		local uiTextureKitID = select(4, GetQuestChoiceInfo());
		if (uiTextureKitID and uiTextureKitID ~= 0) then
			WarboardQuestChoice_LoadUI();
			WarboardQuestChoiceFrame:TryShow();
		else
			QuestChoice_LoadUI();
			QuestChoiceFrame:TryShow();
		end
	elseif ( event == "GARRISON_ARCHITECT_OPENED") then
		if (not GarrisonBuildingFrame) then
			Garrison_LoadUI();
		end
		ShowUIPanel(GarrisonBuildingFrame);
	elseif ( event == "GARRISON_ARCHITECT_CLOSED" ) then
		if ( GarrisonBuildingFrame ) then
			HideUIPanel(GarrisonBuildingFrame);
		end
	elseif ( event == "GARRISON_MISSION_NPC_OPENED") then
		local followerType = ...;
		if followerType ~= LE_FOLLOWER_TYPE_GARRISON_7_0 then
			local frameName = GarrisonFollowerOptions[followerType].missionFrame;
			if (not _G[frameName]) then
				Garrison_LoadUI();
			end
			local frame = _G[frameName];
			frame.followerTypeID = followerType;
			ShowUIPanel(frame);
		end
	elseif ( event == "GARRISON_MISSION_NPC_CLOSED" ) then
		if ( GarrisonMissionFrame ) then
			HideUIPanel(GarrisonMissionFrame);
		end
		if ( BFAMissionFrame ) then
			HideUIPanel(BFAMissionFrame);
		end
	elseif ( event == "GARRISON_SHIPYARD_NPC_OPENED") then
		if (not GarrisonShipyardFrame) then
			Garrison_LoadUI();
		end
		GarrisonShipyardFrame.followerTypeID = ...;
		ShowUIPanel(GarrisonShipyardFrame);
	elseif ( event == "GARRISON_SHIPYARD_NPC_CLOSED" ) then
		if ( GarrisonShipyardFrame ) then
			HideUIPanel(GarrisonShipyardFrame);
		end
	elseif ( event == "SHIPMENT_CRAFTER_OPENED" ) then
		if (not GarrisonCapacitiveDisplayFrame) then
			Garrison_LoadUI();
		end
	elseif ( event == "GARRISON_MONUMENT_SHOW_UI") then
		if(not GarrisonMonumentFrame)then
			Garrison_LoadUI();
		end
		GarrisonMonuntmentFrame_OnEvent(GarrisonMonumentFrame, event, ...);
	elseif ( event == "GARRISON_RECRUITMENT_NPC_OPENED") then
		if(not GarrisonRecruiterFrame)then
			Garrison_LoadUI();
		end
		ShowUIPanel(GarrisonRecruiterFrame);
	elseif ( event == "GARRISON_TALENT_NPC_OPENED") then
		OrderHall_LoadUI();
		OrderHallTalentFrame:SetGarrisonType(...);
		ToggleOrderHallTalentUI();
	elseif ( event == "BEHAVIORAL_NOTIFICATION") then
		self:UnregisterEvent("BEHAVIORAL_NOTIFICATION");
		C_AddOns.LoadAddOn("Blizzard_BehavioralMessaging");
		BehavioralMessagingTray:OnEvent(event, ...);
	elseif ( event == "PRODUCT_DISTRIBUTIONS_UPDATED" ) then
		StoreFrame_CheckForFree(event);
	elseif ( event == "TOKEN_AUCTION_SOLD" ) then
		local info = ChatTypeInfo["SYSTEM"];
		local itemName = C_Item.GetItemInfo(WOW_TOKEN_ITEM_ID);
		if (itemName) then
			DEFAULT_CHAT_FRAME:AddMessage(ERR_AUCTION_SOLD_S:format(itemName), info.r, info.g, info.b, info.id);
		else
			self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
		end
	elseif ( event == "GET_ITEM_INFO_RECEIVED" ) then
		local itemID = ...;
		if (itemID == WOW_TOKEN_ITEM_ID) then
			local info = ChatTypeInfo["SYSTEM"];
			local itemName = C_Item.GetItemInfo(WOW_TOKEN_ITEM_ID);
			DEFAULT_CHAT_FRAME:AddMessage(ERR_AUCTION_SOLD_S:format(itemName), info.r, info.g, info.b, info.id);
			self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
		end
	elseif ( event == "TALKINGHEAD_REQUESTED" ) then
		if ( not TalkingHeadFrame ) then
			TalkingHead_LoadUI();
			TalkingHeadFrame_PlayCurrent();
		end
		self:UnregisterEvent("TALKINGHEAD_REQUESTED");
	elseif (event == "CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN") then
			ChallengeMode_LoadUI();
		ChallengesKeystoneFrame:ShowKeystoneFrame();
	elseif (event == "CHALLENGE_MODE_COMPLETED") then
		if (not ChallengeModeCompleteBanner) then
			ChallengeMode_LoadUI();
			ChallengeModeCompleteBanner:OnEvent(event, ...);
		end
		self:UnregisterEvent("CHALLENGE_MODE_COMPLETED");
	elseif (event == "UNIT_AURA") then
		OrderHall_CheckCommandBar();
	elseif (event == "TAXIMAP_OPENED") then
		local uiMapSystem = ...;
		if (uiMapSystem == Enum.UIMapSystem.Taxi) then
			ShowUIPanel(TaxiFrame);
		end
	elseif (event == "SCENARIO_UPDATE") then
		BoostTutorial_AttemptLoad();
	elseif (event == "DEBUG_MENU_TOGGLED") then
		UpdateUIParentRelativeToDebugMenu();
	elseif ( event == "GROUP_INVITE_CONFIRMATION" ) then
		UpdateInviteConfirmationDialogs();
	elseif ( event == "CONTRIBUTION_COLLECTOR_OPEN" ) then
		UIParentLoadAddOn("Blizzard_Contribution");
		ContributionCollectionUI_Show();
	elseif (event == "CONTRIBUTION_COLLECTOR_CLOSE" ) then
		if ( ContributionCollectionUI_Hide ) then
			ContributionCollectionUI_Hide();
		end
	elseif (event == "ALLIED_RACE_OPEN") then
		AlliedRaces_LoadUI();
		local raceID = ...;
		AlliedRacesFrame:LoadRaceData(raceID);
		ShowUIPanel(AlliedRacesFrame);
	elseif (event == "ISLAND_COMPLETED") then
		IslandsPartyPose_LoadUI();
		local mapID, winner = ...;
		IslandsPartyPoseFrame:LoadScreenData(mapID, winner);
		ShowUIPanel(IslandsPartyPoseFrame);
	elseif (event == "WARFRONT_COMPLETED") then
		WarfrontsPartyPose_LoadUI();
		local mapID, winner = ...;
		WarfrontsPartyPoseFrame:LoadScreenData(mapID, winner);
		ShowUIPanel(WarfrontsPartyPoseFrame);
	-- Event(s) for Azerite Respec
	elseif (event == "RESPEC_AZERITE_EMPOWERED_ITEM_OPENED") then
		AzeriteRespecFrame_LoadUI();
		ShowUIPanel(AzeriteRespecFrame);
	elseif (event == "ISLANDS_QUEUE_OPEN") then
		IslandsQueue_LoadUI();
		ShowUIPanel(IslandsQueueFrame);
	elseif(event == "PLAYER_SOFT_INTERACT_CHANGED") then
		if(GetCVarBool("softTargettingInteractKeySound")) then
			local previousTarget, currentTarget = ...;
			if(not currentTarget) then
				PlaySound(SOUNDKIT.UI_SOFT_TARGET_INTERACT_NOT_AVAILABLE);
			elseif(previousTarget ~= currentTarget) then
				PlaySound(SOUNDKIT.UI_SOFT_TARGET_INTERACT_AVAILABLE);
			end
		end
	elseif (event == "NOTCHED_DISPLAY_MODE_CHANGED") then
		UpdateUIParentPosition();
	elseif (event == "LFG_ENABLED_STATE_CHANGED") then
		SetLookingForGroupUIAvailable(C_LFGInfo.IsGroupFinderEnabled());
	end
end

-- Function that handles the escape key functions
function ToggleGameMenu()
	if Menu.GetManager():HandleESC() then
		return;
	end

	if ( CanAutoSetGamePadCursorControl(true) and (not IsModifierKeyDown()) ) then
		-- There are a few gameplay related cancel cases we want to handle before toggling cursor control on.
		if ( SpellStopCasting() ) then
		elseif ( SpellStopTargeting() ) then
		elseif ( ClearTarget() and (not UnitIsCharmed("player")) ) then
		else
			SetGamePadCursorControl(true);
		end
	elseif ( not UIParent:IsShown() ) then
		UIParent:Show();
		SetUIVisibility(true);
	elseif ( C_Commentator.IsSpectating() and IsFrameLockActive("COMMENTATOR_SPECTATING_MODE") ) then
		Commentator:SetFrameLock(false);
	elseif ( ModelPreviewFrame:IsShown() ) then
		ModelPreviewFrame:Hide();
	elseif ( StoreFrame_EscapePressed and StoreFrame_EscapePressed() ) then
	elseif ( WowTokenRedemptionFrame_EscapePressed and WowTokenRedemptionFrame_EscapePressed() ) then
	elseif ( securecall("StaticPopup_EscapePressed") ) then
	elseif ( GameMenuFrame:IsShown() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_QUIT);
		HideUIPanel(GameMenuFrame);
	elseif ( HelpFrame:IsShown() ) then
		ToggleHelpFrame();
	elseif ( SocialBrowserFrame and SocialBrowserFrame:IsShown() ) then
		SocialBrowserFrame:Hide();
	elseif ( SocialPostFrame and Social_IsShown() ) then
		Social_SetShown(false);
	elseif ( securecall("FCFDockOverflow_CloseLists") ) then
	elseif ( securecall("CloseMenus") ) then
	elseif ( CloseCalendarMenus and securecall("CloseCalendarMenus") ) then
	elseif ( CloseGuildMenus and securecall("CloseGuildMenus") ) then
	elseif ( GarrisonMissionFrame_ClearMouse and securecall("GarrisonMissionFrame_ClearMouse") ) then
	elseif ( GarrisonMissionFrame and GarrisonMissionFrame.MissionTab and GarrisonMissionFrame.MissionTab.MissionPage and GarrisonMissionFrame.MissionTab.MissionPage:IsVisible() ) then
		GarrisonMissionFrame.MissionTab.MissionPage.CloseButton:Click();
	elseif ( GarrisonShipyardFrame_ClearMouse and securecall("GarrisonShipyardFrame_ClearMouse") ) then
	elseif ( GarrisonShipyardFrame and GarrisonShipyardFrame.MissionTab and GarrisonShipyardFrame.MissionTab.MissionPage and GarrisonShipyardFrame.MissionTab.MissionPage:IsVisible() ) then
		GarrisonShipyardFrame.MissionTab.MissionPage.CloseButton:Click();
	elseif ( securecall("OrderHallMissionFrame_EscapePressed") ) then
	elseif ( securecall("OrderHallTalentFrame_EscapePressed") ) then
	elseif ( securecall("BFAMissionFrame_EscapePressed") ) then
	elseif ( SpellStopCasting() ) then
	elseif ( SpellStopTargeting() ) then
	elseif ( securecall("CloseAllWindows") ) then
	elseif ( LootFrame:IsShown() ) then
		-- if we're here, LootFrame was opened under the mouse (cvar "lootUnderMouse") so it didn't get closed by CloseAllWindows
		LootFrame:Hide();
	elseif ( ClearTarget() and (not UnitIsCharmed("player")) ) then
	elseif ( OpacityFrame:IsShown() ) then
		OpacityFrame:Hide();
	elseif ( ChallengesKeystoneFrame and ChallengesKeystoneFrame:IsShown() ) then
		ChallengesKeystoneFrame:Hide();
	elseif ( CanAutoSetGamePadCursorControl(false) and (not IsModifierKeyDown()) ) then
		SetGamePadCursorControl(false);
	elseif ( ReportFrame:IsShown() ) then
		ReportFrame:Hide();
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
		ShowUIPanel(GameMenuFrame);
	end
end


-- Bindings --

function GetBindingFromClick(input)
	local fullInput = "";

	-- MUST BE IN THIS ORDER (ALT, CTRL, SHIFT, META)
	if ( IsAltKeyDown() ) then
		fullInput = fullInput.."ALT-";
	end

	if ( IsControlKeyDown() ) then
		fullInput = fullInput.."CTRL-"
	end

	if ( IsShiftKeyDown() ) then
		fullInput = fullInput.."SHIFT-"
	end

	if ( IsMetaKeyDown() ) then
		 fullInput = fullInput.."META-"
	 end

	if ( input == "LeftButton" ) then
		fullInput = fullInput.."BUTTON1";
	elseif ( input == "RightButton" ) then
		fullInput = fullInput.."BUTTON2";
	elseif ( input == "MiddleButton" ) then
		fullInput = fullInput.."BUTTON3";
	elseif ( input == "Button4" ) then
		fullInput = fullInput.."BUTTON4";
	elseif ( input == "Button5" ) then
		fullInput = fullInput.."BUTTON5";
	elseif ( input == "Button6" ) then
		fullInput = fullInput.."BUTTON6";
	elseif ( input == "Button7" ) then
		fullInput = fullInput.."BUTTON7";
	elseif ( input == "Button8" ) then
		fullInput = fullInput.."BUTTON8";
	elseif ( input == "Button9" ) then
		fullInput = fullInput.."BUTTON9";
	elseif ( input == "Button10" ) then
		fullInput = fullInput.."BUTTON10";
	elseif ( input == "Button11" ) then
		fullInput = fullInput.."BUTTON11";
	elseif ( input == "Button12" ) then
		fullInput = fullInput.."BUTTON12";
	elseif ( input == "Button13" ) then
		fullInput = fullInput.."BUTTON13";
	elseif ( input == "Button14" ) then
		fullInput = fullInput.."BUTTON14";
	elseif ( input == "Button15" ) then
		fullInput = fullInput.."BUTTON15";
	elseif ( input == "Button16" ) then
		fullInput = fullInput.."BUTTON16";
	elseif ( input == "Button17" ) then
		fullInput = fullInput.."BUTTON17";
	elseif ( input == "Button18" ) then
		fullInput = fullInput.."BUTTON18";
	elseif ( input == "Button19" ) then
		fullInput = fullInput.."BUTTON19";
	elseif ( input == "Button20" ) then
		fullInput = fullInput.."BUTTON20";
	elseif ( input == "Button21" ) then
		fullInput = fullInput.."BUTTON21";
	elseif ( input == "Button22" ) then
		fullInput = fullInput.."BUTTON22";
	elseif ( input == "Button23" ) then
		fullInput = fullInput.."BUTTON23";
	elseif ( input == "Button24" ) then
		fullInput = fullInput.."BUTTON24";
	elseif ( input == "Button25" ) then
		fullInput = fullInput.."BUTTON25";
	elseif ( input == "Button26" ) then
		fullInput = fullInput.."BUTTON26";
	elseif ( input == "Button27" ) then
		fullInput = fullInput.."BUTTON27";
	elseif ( input == "Button28" ) then
		fullInput = fullInput.."BUTTON28";
	elseif ( input == "Button29" ) then
		fullInput = fullInput.."BUTTON29";
	elseif ( input == "Button30" ) then
		fullInput = fullInput.."BUTTON30";
	elseif ( input == "Button31" ) then
		fullInput = fullInput.."BUTTON31";
	else
		fullInput = fullInput..input;
	end

	return GetBindingByKey(fullInput);
end


-- Game Logic --

function RealPartyIsFull()
	if ( (GetNumSubgroupMembers(LE_PARTY_CATEGORY_HOME) < MAX_PARTY_MEMBERS) or (IsInRaid(LE_PARTY_CATEGORY_HOME) and (GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) < MAX_RAID_MEMBERS)) ) then
		return false;
	else
		return true;
	end
end

function CanGroupInvite()
	if ( IsInGroup() ) then
		if ( UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") ) then
			return true;
		else
			return false;
		end
	else
		return true;
	end
end

function InviteToGroup(name)
	if ( not IsInRaid() and GetNumGroupMembers() > MAX_PARTY_MEMBERS and CanGroupInvite() ) then
		StaticPopup_Show("CONVERT_TO_RAID", nil, nil, name);
	else
		C_PartyInfo.InviteUnit(name);
	end
end

function RefreshBuffs(frame, unit, numBuffs, suffix, checkCVar)
	local frameName = frame:GetName();

	frame.hasDispellable = nil;

	numBuffs = numBuffs or MAX_PARTY_BUFFS;
	suffix = suffix or "Buff";

	local unitStatus, statusColor;
	local debuffTotal = 0;
	local name, icon, count, debuffType, duration, expirationTime;

	local filter;
	if ( checkCVar and CVarCallbackRegistry:GetCVarValueBool("showCastableBuffs") and UnitCanAssist("player", unit) ) then
		filter = "RAID";
	end

	for i=1, numBuffs do
		name, icon, count, debuffType, duration, expirationTime = UnitBuff(unit, i, filter);

		local buffName = frameName..suffix..i;
		if ( icon ) then
			-- if we have an icon to show then proceed with setting up the aura

			-- set the icon
			local buffIcon = _G[buffName.."Icon"];
			buffIcon:SetTexture(icon);

			-- setup the cooldown
			--[[local coolDown = _G[buffName.."Cooldown"];
			if ( coolDown ) then
				CooldownFrame_Set(coolDown, expirationTime - duration, duration, true);
			end]]

			-- show the aura
			_G[buffName]:Show();
		else
			-- no icon, hide the aura
			_G[buffName]:Hide();
		end
	end
end

function RefreshDebuffs(frame, unit, numDebuffs, suffix, checkCVar)
	local frameName = frame:GetName();

	frame.hasDispellable = nil;

	numDebuffs = numDebuffs or MAX_PARTY_DEBUFFS;
	suffix = suffix or "Debuff";

	local unitStatus, statusColor;
	local debuffTotal = 0;
	local name, icon, count, debuffType, duration, expirationTime, caster;
	local isEnemy = UnitCanAttack("player", unit);

	local filter;
	if ( checkCVar and CVarCallbackRegistry:GetCVarValueBool("showDispelDebuffs") and UnitCanAssist("player", unit) ) then
		filter = "RAID";
	end

	for i=1, numDebuffs do
		if ( unit == "party"..i ) then
			unitStatus = _G[frameName.."Status"];
		end

		name, icon, count, debuffType, duration, expirationTime, caster = UnitDebuff(unit, i, filter);

		local debuffName = frameName..suffix..i;
		if ( icon and ( SHOW_CASTABLE_DEBUFFS == "0" or not isEnemy or caster == "player" ) ) then
			-- if we have an icon to show then proceed with setting up the aura

			-- set the icon
			local debuffIcon = _G[debuffName.."Icon"];
			debuffIcon:SetTexture(icon);

			-- setup the border
			local debuffBorder = _G[debuffName.."Border"];
			local debuffColor = DebuffTypeColor[debuffType] or DebuffTypeColor["none"];
			debuffBorder:SetVertexColor(debuffColor.r, debuffColor.g, debuffColor.b);

			-- record interesting data for the aura button
			statusColor = debuffColor;
			frame.hasDispellable = 1;
			debuffTotal = debuffTotal + 1;

			-- setup the cooldown
			local coolDown = _G[debuffName.."Cooldown"];
			if ( coolDown ) then
				CooldownFrame_Set(coolDown, expirationTime - duration, duration, true);
			end

			-- show the aura
			_G[debuffName]:Show();
		else
			-- no icon, hide the aura
			_G[debuffName]:Hide();
		end
	end

	frame.debuffTotal = debuffTotal;
	-- Reset unitStatus overlay graphic timer
	if ( frame.numDebuffs and debuffTotal >= frame.numDebuffs ) then
		frame.debuffCountdown = 30;
	end
	if ( unitStatus and statusColor ) then
		unitStatus:SetVertexColor(statusColor.r, statusColor.g, statusColor.b);
	end
end

function GetQuestDifficultyColor(level, isScaling)
	if (isScaling) then
		return GetScalingQuestDifficultyColor(level);
	end

	return GetRelativeDifficultyColor(UnitLevel("player"), level);
end

function GetCreatureDifficultyColor(level)
	return GetRelativeDifficultyColor(UnitLevel("player"), level);
end

--How difficult is this challenge for this unit?
function GetRelativeDifficultyColor(unitLevel, challengeLevel)
	local levelDiff = challengeLevel - unitLevel;
	local color;
	if ( levelDiff >= 5 ) then
		return QuestDifficultyColors["impossible"], QuestDifficultyHighlightColors["impossible"];
	elseif ( levelDiff >= 3 ) then
		return QuestDifficultyColors["verydifficult"], QuestDifficultyHighlightColors["verydifficult"];
	elseif ( levelDiff >= -2 ) then
		return QuestDifficultyColors["difficult"], QuestDifficultyHighlightColors["difficult"];
	elseif ( -levelDiff <= GetQuestGreenRange() ) then
		return QuestDifficultyColors["standard"], QuestDifficultyHighlightColors["standard"];
	else
		return QuestDifficultyColors["trivial"], QuestDifficultyHighlightColors["trivial"];
	end
end

function GetScalingQuestDifficultyColor(questLevel)
	local playerLevel = UnitLevel("player");
	local levelDiff = questLevel - playerLevel;
	if ( levelDiff >= 5 ) then
		return QuestDifficultyColors["impossible"], QuestDifficultyHighlightColors["impossible"];
	elseif ( levelDiff >= 3 ) then
		return QuestDifficultyColors["verydifficult"], QuestDifficultyHighlightColors["verydifficult"];
	elseif ( levelDiff >= 0 ) then
		return QuestDifficultyColors["difficult"], QuestDifficultyHighlightColors["difficult"];
	elseif ( -levelDiff <= GetScalingQuestGreenRange() ) then
		return QuestDifficultyColors["standard"], QuestDifficultyHighlightColors["standard"];
	else
		return QuestDifficultyColors["trivial"], QuestDifficultyHighlightColors["trivial"];
	end
end

function LFD_IsEmpowered()
	--Solo players are always empowered.
	if ( not IsInGroup() ) then
		return true;
	end

	--The leader may always queue/dequeue
	if ( UnitIsGroupLeader("player") ) then
		return true;
	end

	return false;
end

function SetLargeGuildTabardTextures(unit, emblemTexture, backgroundTexture, borderTexture, tabardData)
	-- texure dimensions are 1024x1024, icon dimensions are 64x64
	local emblemSize, columns, offset;
	if ( emblemTexture ) then
		emblemSize = 64 / 1024;
		columns = 16
		offset = 0;
		emblemTexture:SetTexture("Interface\\GuildFrame\\GuildEmblemsLG_01");
	end
	SetGuildTabardTextures(emblemSize, columns, offset, unit, emblemTexture, backgroundTexture, borderTexture, tabardData);
end

function SetSmallGuildTabardTextures(unit, emblemTexture, backgroundTexture, borderTexture, tabardData)
	-- texure dimensions are 256x256, icon dimensions are 16x16, centered in 18x18 cells
	local emblemSize, columns, offset;
	if ( emblemTexture ) then
		emblemSize = 18 / 256;
		columns = 14;
		offset = 1 / 256;
		emblemTexture:SetTexture("Interface\\GuildFrame\\GuildEmblems_01");
	end
	SetGuildTabardTextures(emblemSize, columns, offset, unit, emblemTexture, backgroundTexture, borderTexture, tabardData);
end

function SetDoubleGuildTabardTextures(unit, leftEmblemTexture, rightEmblemTexture, backgroundTexture, borderTexture, tabardData)
	if ( leftEmblemTexture and rightEmblemTexture ) then
		SetGuildTabardTextures(nil, nil, nil, unit, leftEmblemTexture, backgroundTexture, borderTexture, tabardData);
		rightEmblemTexture:SetTexture(leftEmblemTexture:GetTexture());
		rightEmblemTexture:SetVertexColor(leftEmblemTexture:GetVertexColor());
	end
end

function SetGuildTabardTextures(emblemSize, columns, offset, unit, emblemTexture, backgroundTexture, borderTexture, tabardData)
	local bkgR, bkgG, bkgB, borderR, borderG, borderB, emblemR, emblemG, emblemB, emblemFilename;
	if ( tabardData ) then
		bkgR = tabardData[1];
		bkgG = tabardData[2];
		bkgB = tabardData[3];
		borderR = tabardData[4];
		borderG = tabardData[5];
		borderB = tabardData[6];
		emblemR = tabardData[7];
		emblemG = tabardData[8];
		emblemB = tabardData[9];
		emblemFilename = tabardData[10];
	else
		bkgR, bkgG, bkgB, borderR, borderG, borderB, emblemR, emblemG, emblemB, emblemFilename = GetGuildLogoInfo(unit);
	end
	if ( emblemFilename ) then
		if ( backgroundTexture ) then
			backgroundTexture:SetVertexColor(bkgR / 255, bkgG / 255, bkgB / 255);
		end
		if ( borderTexture ) then
			borderTexture:SetVertexColor(borderR / 255, borderG / 255, borderB / 255);
		end
		if ( emblemSize ) then
			local index = emblemFilename:match("([%d]+)");
			if ( index) then
				index = tonumber(index);
				local xCoord = mod(index, columns) * emblemSize;
				local yCoord = floor(index / columns) * emblemSize;
				emblemTexture:SetTexCoord(xCoord + offset, xCoord + emblemSize - offset, yCoord + offset, yCoord + emblemSize - offset);
			end
			emblemTexture:SetVertexColor(emblemR / 255, emblemG / 255, emblemB / 255);
		elseif ( emblemTexture ) then
			emblemTexture:SetTexture(emblemFilename);
			emblemTexture:SetVertexColor(emblemR / 255, emblemG / 255, emblemB / 255);
		end
	else
		-- tabard lacks design
		if ( backgroundTexture ) then
			backgroundTexture:SetVertexColor(0.2245, 0.2088, 0.1794);
		end
		if ( borderTexture ) then
			borderTexture:SetVertexColor(0.2, 0.2, 0.2);
		end
		if ( emblemTexture ) then
			if ( emblemSize ) then
				if ( emblemSize == 18 / 256 ) then
					emblemTexture:SetTexture("Interface\\GuildFrame\\GuildLogo-NoLogoSm");
				else
					emblemTexture:SetTexture("Interface\\GuildFrame\\GuildLogo-NoLogo");
				end
				emblemTexture:SetTexCoord(0, 1, 0, 1);
				emblemTexture:SetVertexColor(1, 1, 1, 1);
			else
				emblemTexture:SetTexture("");
			end
		end
	end
end

function GetDisplayedAllyFrames()
	local useCompact = GetCVarBool("useCompactPartyFrames")
	if ( IsActiveBattlefieldArena() and not useCompact ) then
		return "party";
	elseif ( IsInGroup() and (IsInRaid() or useCompact) ) then
		return "raid";
	elseif ( IsInGroup() ) then
		return "party";
	else
		return nil;
	end
end

NUMBER_ABBREVIATION_DATA = {
	-- Order these from largest to smallest
	-- (significandDivisor and fractionDivisor should multiply to be equal to breakpoint)
	{ breakpoint = 100000000,	abbreviation = SECOND_NUMBER_CAP_NO_SPACE,	significandDivisor = 10000000,	fractionDivisor = 1 },
	{ breakpoint = 10000000,	abbreviation = SECOND_NUMBER_CAP_NO_SPACE,	significandDivisor = 1000000,	fractionDivisor = 1 },
	{ breakpoint = 1000000,		abbreviation = SECOND_NUMBER_CAP_NO_SPACE,	significandDivisor = 100000,		fractionDivisor = 10 },
	{ breakpoint = 10000,		abbreviation = FIRST_NUMBER_CAP_NO_SPACE,	significandDivisor = 1000,		fractionDivisor = 1 },
	{ breakpoint = 1000,		abbreviation = FIRST_NUMBER_CAP_NO_SPACE,	significandDivisor = 100,		fractionDivisor = 10 },
}

function AbbreviateNumbers(value)
	for i, data in ipairs(NUMBER_ABBREVIATION_DATA) do
		if value >= data.breakpoint then
			local finalValue = math.floor(value / data.significandDivisor) / data.fractionDivisor;
			return finalValue .. data.abbreviation;
		end
	end
	return tostring(value);
end

function IsInLFDBattlefield()
	return false;
end

function LeaveInstanceParty()
	if ( IsInLFDBattlefield() ) then
		LFGTeleport(true);
	else
		LeaveParty();
	end
end

function ConfirmOrLeaveBattlefield()
	if ( GetBattlefieldWinner() ) then
		LeaveBattlefield();
	else
		StaticPopup_Show("CONFIRM_LEAVE_BATTLEFIELD");
	end
end

function RGBToColorCode(r, g, b)
	return format("|cff%02x%02x%02x", r*255, g*255, b*255);
end

function RGBTableToColorCode(rgbTable)
	return RGBToColorCode(rgbTable.r, rgbTable.g, rgbTable.b);
end

function WillAcceptInviteRemoveQueues()
	--Dungeon/Raid Finder
	for i=1, NUM_LE_LFG_CATEGORYS do
		local mode = GetLFGMode(i);
		if ( mode and mode ~= "lfgparty" ) then
			return true;
		end
	end

	--PvP
	for i=1, GetMaxBattlefieldID() do
		local status, _, _, _, _, _, _, _, _, _, _, _, asGroup = GetBattlefieldStatus(i);
		if ( ( status == "queued" or status == "confirmed" ) and asGroup ) then
			return true;
		end
	end

	return false;
end

--Only really works on friends and guild-mates
function GetDisplayedInviteType(guid)
	if ( IsInGroup() ) then
		if ( UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") ) then
			return "INVITE";
		else
			return "SUGGEST_INVITE";
		end
	else
		if ( not guid ) then
			return "INVITE";
		end

		local party = UnitInParty(guid);--, isSoloQueueParty = C_SocialQueue.GetGroupForPlayer(guid);
		if ( party ) then
			return "REQUEST_INVITE";
		else
			return "INVITE";
		end
	end
end

function ShakeFrameRandom(frame, magnitude, duration, frequency)
	if frequency <= 0 then
		return;
	end

	local shake = {};
	for i = 1, math.ceil(duration / frequency) do
		local xVariation, yVariation = RandomFloatInRange(-magnitude, magnitude), RandomFloatInRange(-magnitude, magnitude);
		shake[i] = { x = xVariation, y = yVariation };
	end

	ShakeFrame(frame, shake, duration, frequency);
end

function ShakeFrame(frame, shake, maximumDuration, frequency)
	if ( frame.shakeTicker and not frame.shakeTicker:IsCancelled() )  then
		return;
	end
	local point, relativeFrame, relativePoint, x, y = frame:GetPoint();
	local shakeIndex = 1;
	local endTime = GetTime() + maximumDuration;
	frame.shakeTicker = C_Timer.NewTicker(frequency, function()
		local xVariation, yVariation = shake[shakeIndex].x, shake[shakeIndex].y;
		frame:SetPoint(point, relativeFrame, relativePoint, x + xVariation, y + yVariation);
		shakeIndex = shakeIndex + 1;
		if shakeIndex > #shake or GetTime() >= endTime then
			frame:SetPoint(point, relativeFrame, relativePoint, x, y);
			frame.shakeTicker:Cancel();
		end
	end);
end

function ChatClassColorOverrideShown()
	local value = GetCVar("chatClassColorOverride");
	if value == "0" then
		return true;
	elseif value == "1" then
		return false;
	else
		return nil;
	end
end

 -- takes into account the current expansion
 -- NOTE: it's not safe to cache this value as it could change in the middle of the session
function GetEffectivePlayerMaxLevel()
	return GetMaxPlayerLevel();
end

function IsLevelAtEffectiveMaxLevel(level)
	return level >= GetEffectivePlayerMaxLevel();
end

-- From SocialQueue.lua
function SocialQueueUtil_GetRelationshipInfo(guid, missingNameFallback, clubId)
	local hasFocus, characterName, client, realmName, realmID, faction, race, class, _, zoneName, level, gameText, broadcast, broadcastTime, online, bnetIDGameAccount, bnetIDAccount = BNGetGameAccountInfoByGUID(guid);
	if ( characterName and bnetIDAccount ) then
		local bnetIDAccountFriend, accountName = BNGetFriendInfoByID(bnetIDAccount);
		if ( accountName ) then
			return accountName, FRIENDS_BNET_NAME_COLOR_CODE, "bnfriend", GetBNPlayerLink(accountName, accountName, bnetIDAccountFriend, 0, 0, 0);
		end
	end

	local name, normalizedRealmName = select(6, GetPlayerInfoByGUID(guid));
	name = (name or missingNameFallback) or UNKNOWNOBJECT;
	local linkName = name;
	local playerLink;

	if name ~= UNKNOWNOBJECT then
		playerLink = GetPlayerLink(linkName, name);
	end

	if ( C_FriendList.IsFriend(guid) ) then
		return name, FRIENDS_WOW_NAME_COLOR_CODE, "wowfriend", playerLink;
	end

	if ( IsGuildMember(guid) ) then
		return name, RGBTableToColorCode(ChatTypeInfo.GUILD), "guild", playerLink;
	end

	if ( clubId ) then
		return name, FRIENDS_WOW_NAME_COLOR_CODE, "club", playerLink;
	end

	return name, FRIENDS_WOW_NAME_COLOR_CODE, nil, playerLink;
end

local INTERFACE_ACTION_BLOCKED_SHOWN = false;
function DisplayInterfaceActionBlockedMessage()
	if ( not INTERFACE_ACTION_BLOCKED_SHOWN ) then
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(INTERFACE_ACTION_BLOCKED, info.r, info.g, info.b, info.id);
		INTERFACE_ACTION_BLOCKED_SHOWN = true;
	end
end
-- Set the overall UI state to show or not show the LFG UI.
function SetLookingForGroupUIAvailable(available)
	if (available) then
		LFGMicroButton:Show();
		MiniMapWorldMapButton:Show();
	else
		LFGMicroButton:Hide();
		MiniMapWorldMapButton:Hide();
	end
end
