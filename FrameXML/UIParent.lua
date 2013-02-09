TOOLTIP_UPDATE_TIME = 0.2;
ROTATIONS_PER_SECOND = .5;
BOSS_FRAME_CASTBAR_HEIGHT = 16;

-- Alpha animation stuff
FADEFRAMES = {};
FLASHFRAMES = {};

-- Pulsing stuff
PULSEBUTTONS = {};

-- Shine animation
SHINES_TO_ANIMATE = {};

-- Per panel settings
UIPanelWindows = {};

--Center Menu Frames
UIPanelWindows["GameMenuFrame"] =				{ area = "center",		pushable = 0,	whileDead = 1 };
UIPanelWindows["VideoOptionsFrame"] =			{ area = "center",		pushable = 0,	whileDead = 1 };
UIPanelWindows["AudioOptionsFrame"] =			{ area = "center",		pushable = 0,	whileDead = 1 };
UIPanelWindows["InterfaceOptionsFrame"] =		{ area = "center",		pushable = 0,	whileDead = 1 };
UIPanelWindows["HelpFrame"] =					{ area = "center",		pushable = 0,	whileDead = 1 };

-- Frames using the new Templates
UIPanelWindows["CharacterFrame"] =				{ area = "left",			pushable = 3,	whileDead = 1};
UIPanelWindows["SpellBookFrame"] =				{ area = "left",			pushable = 1,	whileDead = 1, width = 575, height = 545 };
UIPanelWindows["TaxiFrame"] =					{ area = "left",			pushable = 0, 	width = 605, height = 580 };
UIPanelWindows["PVPUIFrame"] =					{ area = "left",			pushable = 0,	whileDead = 1, width = 563};
UIPanelWindows["PVPBannerFrame"] =				{ area = "left",			pushable = 1};
UIPanelWindows["PetStableFrame"] =				{ area = "left",			pushable = 0};
UIPanelWindows["PVEFrame"] =					{ area = "left",			pushable = 0, 	whileDead = 1, width = 563};
UIPanelWindows["EncounterJournal"] =			{ area = "left",			pushable = 0, 	whileDead = 1, width = 830};
UIPanelWindows["PetJournalParent"] =			{ area = "left",			pushable = 0, 	whileDead = 1, width = 830};
UIPanelWindows["TradeFrame"] =					{ area = "left",			pushable = 1};
UIPanelWindows["LootFrame"] =					{ area = "left",			pushable = 7};
UIPanelWindows["MerchantFrame"] =				{ area = "left",			pushable = 0};
UIPanelWindows["TabardFrame"] =					{ area = "left",			pushable = 0};
UIPanelWindows["PVPBannerFrame"] =				{ area = "left",			pushable = 1};
UIPanelWindows["MailFrame"] =					{ area = "left",			pushable = 0};
UIPanelWindows["BankFrame"] =					{ area = "left",			pushable = 6,	width = 425 };
UIPanelWindows["QuestLogFrame"] =				{ area = "doublewide",		pushable = 0,	whileDead = 1 };
UIPanelWindows["QuestLogDetailFrame"] =			{ area = "left",			pushable = 1,	whileDead = 1 };
UIPanelWindows["QuestFrame"] =					{ area = "left",			pushable = 0};
UIPanelWindows["GuildRegistrarFrame"] =			{ area = "left",			pushable = 0};
UIPanelWindows["GossipFrame"] =					{ area = "left",			pushable = 0};
UIPanelWindows["DressUpFrame"] =				{ area = "left",			pushable = 2};
UIPanelWindows["PetitionFrame"] =				{ area = "left",			pushable = 0};
UIPanelWindows["ItemTextFrame"] =				{ area = "left",			pushable = 0};
UIPanelWindows["FriendsFrame"] =				{ area = "left",			pushable = 0,	whileDead = 1, extraWidth = 32};
UIPanelWindows["RaidParentFrame"] =				{ area = "left",			pushable = 1,	whileDead = 1 };
UIPanelWindows["RaidBrowserFrame"] =			{ area = "left",			pushable = 1,	};


-- Frames NOT using the new Templates
UIPanelWindows["WorldMapFrame"] =				{ area = "full",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 1 };
UIPanelWindows["CinematicFrame"] =				{ area = "full",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 1 };
UIPanelWindows["ChatConfigFrame"] =				{ area = "center",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 1 };
UIPanelWindows["WorldStateScoreFrame"] =		{ area = "center",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 1 };
UIPanelWindows["QuestChoiceFrame"] =			{ area = "center",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 0, allowOtherPanels = 1 };

local function GetUIPanelWindowInfo(frame, name)
	if ( not frame:GetAttribute("UIPanelLayout-defined") ) then
	    local info = UIPanelWindows[frame:GetName()];
	    if ( not info ) then
			return;
	    end
		frame:SetAttribute("UIPanelLayout-defined", true);
	    for name,value in pairs(info) do
			frame:SetAttribute("UIPanelLayout-"..name, value);
		end
	end
	return frame:GetAttribute("UIPanelLayout-"..name);
end

function SetUIPanelAttribute(frame, name, value)
	local info = UIPanelWindows[frame:GetName()];
	if ( not info ) then
		return;
	end
	
	if ( not frame:GetAttribute("UIPanelLayout-defined") ) then
		frame:SetAttribute("UIPanelLayout-defined", true);
		for name,value in pairs(info) do
			frame:SetAttribute("UIPanelLayout-"..name, value);
		end
	end
	
	frame:SetAttribute("UIPanelLayout-"..name, value);
end

-- These are windows that rely on a parent frame to be open.  If the parent closes or a pushable frame overlaps them they must be hidden.
UIChildWindows = {
	"OpenMailFrame",
	"GuildControlUI",
	"GuildMemberDetailFrame",
	"TokenFramePopup",
	"GuildBankPopupFrame",
	"GearManagerDialog",
};

UISpecialFrames = {
	"ItemRefTooltip",
	"ColorPickerFrame",
	"ScrollOfResurrectionFrame",
	"ScrollOfResurrectionSelectionFrame"
};

UIMenus = {
	"ChatMenu",
	"EmoteMenu",
	"LanguageMenu",
	"DropDownList1",
	"DropDownList2",
};

NUM_ITEM_QUALITIES = 7;

ITEM_QUALITY_COLORS = { };
for i = -1, NUM_ITEM_QUALITIES do
	ITEM_QUALITY_COLORS[i] = { };
	ITEM_QUALITY_COLORS[i].r,
	ITEM_QUALITY_COLORS[i].g,
	ITEM_QUALITY_COLORS[i].b,
	ITEM_QUALITY_COLORS[i].hex = GetItemQualityColor(i);
	ITEM_QUALITY_COLORS[i].hex = "|c"..ITEM_QUALITY_COLORS[i].hex;
end

function UIParent_OnLoad(self)
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
	self:RegisterEvent("GUILD_INVITE_REQUEST");
	self:RegisterEvent("GUILD_INVITE_CANCEL");
	self:RegisterEvent("ARENA_TEAM_INVITE_REQUEST");
	self:RegisterEvent("PLAYER_CAMPING");
	self:RegisterEvent("PLAYER_QUITING");
	self:RegisterEvent("LOGOUT_CANCEL");
	self:RegisterEvent("LOOT_BIND_CONFIRM");
	self:RegisterEvent("EQUIP_BIND_CONFIRM");
	self:RegisterEvent("AUTOEQUIP_BIND_CONFIRM");
	self:RegisterEvent("USE_BIND_CONFIRM");
	self:RegisterEvent("CONFIRM_BEFORE_USE");
	self:RegisterEvent("DELETE_ITEM_CONFIRM");
	self:RegisterEvent("QUEST_ACCEPT_CONFIRM");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	self:RegisterEvent("CURSOR_UPDATE");
	self:RegisterEvent("LOCALPLAYER_PET_RENAMED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("MIRROR_TIMER_START");
	self:RegisterEvent("DUEL_REQUESTED");
	self:RegisterEvent("DUEL_OUTOFBOUNDS");
	self:RegisterEvent("DUEL_INBOUNDS");
	self:RegisterEvent("DUEL_FINISHED");
	self:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED");
	self:RegisterEvent("PET_BATTLE_QUEUE_PROPOSE_MATCH");
	self:RegisterEvent("PET_BATTLE_QUEUE_PROPOSAL_DECLINED");
	self:RegisterEvent("PET_BATTLE_QUEUE_PROPOSAL_ACCEPTED");
	self:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUEST_CANCEL");
	self:RegisterEvent("TRADE_REQUEST_CANCEL");
	self:RegisterEvent("CONFIRM_XP_LOSS");
	self:RegisterEvent("CORPSE_IN_RANGE");
	self:RegisterEvent("CORPSE_IN_INSTANCE");
	self:RegisterEvent("CORPSE_OUT_OF_RANGE");
	self:RegisterEvent("AREA_SPIRIT_HEALER_IN_RANGE");
	self:RegisterEvent("AREA_SPIRIT_HEALER_OUT_OF_RANGE");
	self:RegisterEvent("BIND_ENCHANT");
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
	self:RegisterEvent("CONFIRM_DISENCHANT_ROLL");
	self:RegisterEvent("INSTANCE_BOOT_START");
	self:RegisterEvent("INSTANCE_BOOT_STOP");
	self:RegisterEvent("INSTANCE_LOCK_START");
	self:RegisterEvent("INSTANCE_LOCK_STOP");
	self:RegisterEvent("INSTANCE_LOCK_WARNING");
	self:RegisterEvent("CONFIRM_TALENT_WIPE");
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
	self:RegisterEvent("LEVEL_GRANT_PROPOSED");
	self:RegisterEvent("RAISED_AS_GHOUL");
	self:RegisterEvent("SOR_START_EXPERIENCE_INCOMPLETE");
	self:RegisterEvent("MISSING_OUT_ON_LOOT");
	self:RegisterEvent("SPELL_CONFIRMATION_PROMPT");
	self:RegisterEvent("SPELL_CONFIRMATION_TIMEOUT");
	
	-- Events for auction UI handling
	self:RegisterEvent("AUCTION_HOUSE_SHOW");
	self:RegisterEvent("AUCTION_HOUSE_CLOSED");
	self:RegisterEvent("AUCTION_HOUSE_DISABLED");
	
	-- Events for trainer UI handling
	self:RegisterEvent("TRAINER_SHOW");
	self:RegisterEvent("TRAINER_CLOSED");

	-- Events for trade skill UI handling
	self:RegisterEvent("TRADE_SKILL_SHOW");
	self:RegisterEvent("TRADE_SKILL_CLOSE");

	-- Events for Item socketing UI
	self:RegisterEvent("SOCKET_INFO_UPDATE");

	-- Events for taxi benchmarking
	self:RegisterEvent("ENABLE_TAXI_BENCHMARK");
	self:RegisterEvent("DISABLE_TAXI_BENCHMARK");

	-- Push to talk
	self:RegisterEvent("VOICE_PUSH_TO_TALK_START");
	self:RegisterEvent("VOICE_PUSH_TO_TALK_STOP");

	-- Events for BarberShop Handling
	self:RegisterEvent("BARBER_SHOP_OPEN");
	self:RegisterEvent("BARBER_SHOP_CLOSE");

	-- Events for Guild bank UI
	self:RegisterEvent("GUILDBANKFRAME_OPENED");
	self:RegisterEvent("GUILDBANKFRAME_CLOSED");

	-- Events for Achievements!
	self:RegisterEvent("ACHIEVEMENT_EARNED");

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
	
	-- Events for transmogrify
	self:RegisterEvent("TRANSMOGRIFY_OPEN");
	self:RegisterEvent("TRANSMOGRIFY_CLOSE");

	-- Events for void storage
	self:RegisterEvent("VOID_STORAGE_OPEN");
	self:RegisterEvent("VOID_STORAGE_CLOSE");
	
	-- Events for Trial caps
	self:RegisterEvent("TRIAL_CAP_REACHED_MONEY");
	self:RegisterEvent("TRIAL_CAP_REACHED_LEVEL");

	-- Events for black market
	self:RegisterEvent("BLACK_MARKET_OPEN");
	self:RegisterEvent("BLACK_MARKET_CLOSE");

	-- Events for item upgrades
	self:RegisterEvent("ITEM_UPGRADE_MASTER_OPENED");
	self:RegisterEvent("ITEM_UPGRADE_MASTER_CLOSED");

	-- Events for Pet Jornal
	self:RegisterEvent("PET_JOURNAL_NEW_BATTLE_SLOT");
	
	-- Events for Quest Choice
	self:RegisterEvent("QUEST_CHOICE_UPDATE");
end


-- Addons --

local FailedAddOnLoad = {};

function UIParentLoadAddOn(name)
	local loaded, reason = LoadAddOn(name);
	if ( not loaded ) then
		if ( not FailedAddOnLoad[name] ) then
			message(format(ADDON_LOAD_FAILED, name, _G["ADDON_"..reason]));
			FailedAddOnLoad[name] = true;
		end
	end
	return loaded;
end

function AuctionFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_AuctionUI");
end

function BattlefieldMinimap_LoadUI()
	UIParentLoadAddOn("Blizzard_BattlefieldMinimap");
end

function ClassTrainerFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_TrainerUI");
end

function CombatLog_LoadUI()
	UIParentLoadAddOn("Blizzard_CombatLog");
end

function GuildBankFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_GuildBankUI");
end

function InspectFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_InspectUI");
end

function KeyBindingFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_BindingUI");
end

function MacroFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_MacroUI");
end
function MacroFrame_SaveMacro()
	-- this will be overwritten with the real thing when the addon is loaded
end

function RaidFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_RaidUI");
end

function TalentFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_TalentUI");
end

function TradeSkillFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_TradeSkillUI");
end

function GMSurveyFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_GMSurveyUI");
end

function ItemSocketingFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ItemSocketingUI");
end

function BarberShopFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_BarberShopUI");
end

function AchievementFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_AchievementUI");
end

function TimeManager_LoadUI()
	UIParentLoadAddOn("Blizzard_TimeManager");
end

function TokenFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_TokenUI");
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

function ItemAlteration_LoadUI()
	UIParentLoadAddOn("Blizzard_ItemAlterationUI");
end

function VoidStorage_LoadUI()
	UIParentLoadAddOn("Blizzard_VoidStorageUI");
end

function ArchaeologyFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ArchaeologyUI");
end

function GMChatFrame_LoadUI(...)
	if ( IsAddOnLoaded("Blizzard_GMChatUI") ) then
		return;
	else
		UIParentLoadAddOn("Blizzard_GMChatUI");
		if ( select(1, ...) ) then
			GMChatFrame_OnEvent(GMChatFrame, ...);
		end
	end
end

function Arena_LoadUI()
	UIParentLoadAddOn("Blizzard_ArenaUI");
end

function GuildFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_GuildUI");
end

function LookingForGuildFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_LookingForGuildUI");
end

function EncounterJournal_LoadUI()
	UIParentLoadAddOn("Blizzard_EncounterJournal");
end

function PetJournal_LoadUI()
	UIParentLoadAddOn("Blizzard_PetJournal");
end

function BlackMarket_LoadUI()
	UIParentLoadAddOn("Blizzard_BlackMarketUI");
end

function ItemUpgrade_LoadUI()
	UIParentLoadAddOn("Blizzard_ItemUpgradeUI");
end

function PVP_LoadUI()
	UIParentLoadAddOn("Blizzard_PVPUI");
end

function QuestChoice_LoadUI()
	UIParentLoadAddOn("Blizzard_QuestChoice");
end

--[[
function MovePad_LoadUI()
	UIParentLoadAddOn("Blizzard_MovePad");
end
]]

function ShowMacroFrame()
	MacroFrame_LoadUI();
	if ( MacroFrame_Show ) then
		MacroFrame_Show();
	end
end

function InspectAchievements (unit)
	if (IsBlizzCon()) then
		return;
	end

	AchievementFrame_LoadUI();
	AchievementFrame_DisplayComparison(unit);
end

function ToggleAchievementFrame(stats)
	if ( ( HasCompletedAnyAchievement() or IsInGuild() ) and CanShowAchievementUI() ) then
		AchievementFrame_LoadUI();
		AchievementFrame_ToggleAchievementFrame(stats);
	end
end

function ToggleTalentFrame()
	if (IsBlizzCon() or (UnitLevel("player") < SHOW_SPEC_LEVEL)) then
		return;
	end

	TalentFrame_LoadUI();
	if ( PlayerTalentFrame_Toggle ) then
		PlayerTalentFrame_Toggle(GetActiveSpecGroup());
	end
end

function ToggleGlyphFrame()
	if (IsBlizzCon()) then
		return;
	end

	if ( UnitLevel("player") < SHOW_INSCRIPTION_LEVEL ) then
		return;
	end

	GlyphFrame_LoadUI();
	if ( GlyphFrame_Toggle ) then
		GlyphFrame_Toggle();
	end
end

function OpenGlyphFrame()
	if (IsBlizzCon()) then
		return;
	end

	if ( UnitLevel("player") < SHOW_INSCRIPTION_LEVEL ) then
		return;
	end

	GlyphFrame_LoadUI();
	if ( GlyphFrame_Open ) then
		GlyphFrame_Open();
	end
end

function ToggleBattlefieldMinimap()
	BattlefieldMinimap_LoadUI();
	if ( BattlefieldMinimap_Toggle ) then
		BattlefieldMinimap_Toggle();
	end
end

function ToggleTimeManager()
	TimeManager_LoadUI();
	if ( TimeManager_Toggle ) then
		TimeManager_Toggle();
	end
end

function ToggleCalendar()
	if (IsBlizzCon()) then
		return;
	end

	Calendar_LoadUI();
	if ( Calendar_Toggle ) then
		Calendar_Toggle();
	end
end

function ToggleGuildFrame()
	local factionGroup = UnitFactionGroup("player");
	if (IsBlizzCon() or factionGroup == "Neutral") then
		return;
	end

	if ( IsTrialAccount() ) then
		UIErrorsFrame:AddMessage(ERR_RESTRICTED_ACCOUNT, 1.0, 0.1, 0.1, 1.0);
		return;
	end
	if ( IsInGuild() ) then
		GuildFrame_LoadUI();
		if ( GuildFrame_Toggle ) then
			GuildFrame_Toggle();
		end
	else
		ToggleGuildFinder();
	end
end

function ToggleGuildFinder()
	local factionGroup = UnitFactionGroup("player");
	if (IsBlizzCon() or factionGroup == "Neutral") then
		return;
	end

	LookingForGuildFrame_LoadUI();
	if ( LookingForGuildFrame_Toggle ) then
		LookingForGuildFrame_Toggle();
	end
end

function ToggleLFDParentFrame()
	local factionGroup = UnitFactionGroup("player");
	if (IsBlizzCon() or factionGroup == "Neutral") then
		return;
	end

	if ( UnitLevel("player") >= SHOW_LFD_LEVEL ) then
		PVEFrame_ToggleFrame("GroupFinderFrame", LFDParentFrame);
	end
end

function ToggleHelpFrame()
	if ( HelpFrame:IsShown() ) then
		HideUIPanel(HelpFrame);
	else
		StaticPopup_Hide("HELP_TICKET");
		StaticPopup_Hide("HELP_TICKET_ABANDON_CONFIRM");
		StaticPopup_Hide("GM_RESPONSE_NEED_MORE_HELP");
		StaticPopup_Hide("GM_RESPONSE_RESOLVE_CONFIRM");
		StaticPopup_Hide("GM_RESPONSE_MUST_RESOLVE_RESPONSE");
		HelpFrame_ShowFrame();
	end
end

function ToggleRaidFrame()
	local factionGroup = UnitFactionGroup("player");
	if (IsBlizzCon() or factionGroup == "Neutral") then
		return;
	end

	ToggleFriendsFrame(4);
end

function ToggleRaidBrowser()
	local factionGroup = UnitFactionGroup("player");
	if (IsBlizzCon() or factionGroup == "Neutral") then
		return;
	end

	if ( RaidBrowserFrame:IsShown() ) then
		HideUIPanel(RaidBrowserFrame);
	else
		ShowUIPanel(RaidBrowserFrame);
	end

end

function ToggleEncounterJournal()
	if (IsBlizzCon()) then
		return;
	end

	if ( not EncounterJournal ) then
		EncounterJournal_LoadUI();
	end
	if ( EncounterJournal ) then
		ToggleFrame(EncounterJournal);
	end
end


function TogglePetJournal(whichFrame)
	if ( not PetJournalParent ) then
		PetJournal_LoadUI();
	end
	if ( PetJournalParent ) then
		ToggleFrame(PetJournalParent);
	end
	if (whichFrame and PetJournalParent:IsShown()) then
		PetJournalParent_SetTab(PetJournalParent, whichFrame);
	end
end

function TogglePVPUI()
	if (IsBlizzCon()) then
		return;
	end
	if (not PVPUIFrame) then
		PVP_LoadUI();
	end
	if ( UnitLevel("player") >= SHOW_PVP_LEVEL and not IsPlayerNeutral()) then
		PVPUIFrame_ToggleFrame()
	end
end

function InspectUnit(unit)
	if (IsBlizzCon()) then
		return;
	end

	InspectFrame_LoadUI();
	if ( InspectFrame_Show ) then
		InspectFrame_Show(unit);
	end
end


-- UIParent_OnEvent --
function UIParent_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6 = ...;
	if ( event == "CURRENT_SPELL_CAST_CHANGED" and #StaticPopup_DisplayedFrames > 0 ) then
		if ( arg1 ) then
			StaticPopup_Hide("BIND_ENCHANT");
			StaticPopup_Hide("REPLACE_ENCHANT");
		end
		StaticPopup_Hide("TRADE_REPLACE_ENCHANT");
		StaticPopup_Hide("END_BOUND_TRADEABLE");
	elseif ( event == "VARIABLES_LOADED" ) then
		LocalizeFrames();
		if ( WorldStateFrame_CanShowBattlefieldMinimap() ) then
			if ( not BattlefieldMinimap ) then
				BattlefieldMinimap_LoadUI();
			end
			BattlefieldMinimap:Show();
		end
		if ( not TimeManagerFrame and GetCVar("timeMgrAlarmEnabled") == "1" ) then
			-- We have to load the time manager here if the alarm is enabled because the alarm can go off
			-- even if the clock is not shown. WorldFrame_OnUpdate handles alarm checking while the clock
			-- is hidden.
			TimeManager_LoadUI();
		end
		local lastTalkedToGM = GetCVar("lastTalkedToGM");
		if ( lastTalkedToGM ~= "" ) then
			GMChatFrame_LoadUI();
			GMChatFrame:Show()
			local info = ChatTypeInfo["WHISPER"];
			GMChatFrame:AddMessage(format(GM_CHAT_LAST_SESSION, "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz:12:20:0:0:32:16:4:28:0:16|t "..
			"|HplayerGM:"..lastTalkedToGM.."|h".."["..lastTalkedToGM.."]".."|h"), info.r, info.g, info.b, info.id);
			GMChatFrameEditBox:SetAttribute("tellTarget", lastTalkedToGM);
			GMChatFrameEditBox:SetAttribute("chatType", "WHISPER");
		end
		TargetFrame_OnVariablesLoaded();
	elseif ( event == "PLAYER_LOGIN" ) then
		TimeManager_LoadUI();
		-- You can override this if you want a Combat Log replacement
		CombatLog_LoadUI();
	elseif ( event == "PLAYER_DEAD" ) then
		if ( not StaticPopup_Visible("DEATH") ) then
			CloseAllWindows(1);
		end
		if ( GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1 ) then
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
		local dialog = StaticPopup_Show("CHAT_CHANNEL_INVITE", arg1, arg2);
		if ( dialog ) then
			dialog.data = arg1;
		end
	elseif ( event == "CHANNEL_PASSWORD_REQUEST" ) then
		local dialog = StaticPopup_Show("CHAT_CHANNEL_PASSWORD", arg1);
		if ( dialog ) then
			dialog.data = arg1;
		end
	elseif ( event == "PARTY_INVITE_REQUEST" ) then
		-- if there's a role, it's an LFG invite
		if ( arg2 or arg3 or arg4 ) then
			StaticPopupSpecial_Show(LFGInvitePopup);
			LFGInvitePopup_Update(arg1, arg2, arg3, arg4);
		elseif ( arg5 ) then	--It's a X-realm invite
			StaticPopup_Show("PARTY_INVITE_XREALM", arg1);
		else
			StaticPopup_Show("PARTY_INVITE", arg1);
		end
	elseif ( event == "PARTY_INVITE_CANCEL" ) then
		StaticPopup_Hide("PARTY_INVITE");
		StaticPopup_Hide("PARTY_INVITE_XREALM");
		StaticPopupSpecial_Hide(LFGInvitePopup);
	elseif ( event == "GUILD_INVITE_REQUEST" ) then
		StaticPopup_Show("GUILD_INVITE", arg1, arg2);
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
		local texture, item, quantity, quality, locked = GetLootSlotInfo(arg1);
		local dialog = StaticPopup_Show("LOOT_BIND", ITEM_QUALITY_COLORS[quality].hex..item.."|r");
		if ( dialog ) then
			dialog.data = arg1;
		end
	elseif ( event == "EQUIP_BIND_CONFIRM" ) then
		StaticPopup_Hide("AUTOEQUIP_BIND");
		local dialog = StaticPopup_Show("EQUIP_BIND");
		if ( dialog ) then
			dialog.data = arg1;
		end
	elseif ( event == "AUTOEQUIP_BIND_CONFIRM" ) then
		StaticPopup_Hide("EQUIP_BIND");
		local dialog = StaticPopup_Show("AUTOEQUIP_BIND");
		if ( dialog ) then
			dialog.data = arg1;
		end
	elseif ( event == "USE_BIND_CONFIRM" ) then
		StaticPopup_Show("USE_BIND");
	elseif ( event == "CONFIRM_BEFORE_USE" ) then
		StaticPopup_Show("CONFIM_BEFORE_USE");
	elseif ( event == "DELETE_ITEM_CONFIRM" ) then
		-- Check quality
		if ( arg2 >= 3 ) then
			if (arg3 == 4) then -- quest item?
				StaticPopup_Show("DELETE_GOOD_QUEST_ITEM", arg1);
			else
				StaticPopup_Show("DELETE_GOOD_ITEM", arg1);
			end
		else
			if (arg3 == 4) then -- quest item?
				StaticPopup_Show("DELETE_QUEST_ITEM", arg1);
			else
				StaticPopup_Show("DELETE_ITEM", arg1);
			end
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
	elseif ( event == "CURSOR_UPDATE" ) then
		if ( not CursorHasItem() ) then
			StaticPopup_Hide("EQUIP_BIND");
			StaticPopup_Hide("AUTOEQUIP_BIND");
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		-- Get multi-actionbar states (before CloseAllWindows() since that may be hooked by AddOns)
		-- We don't want to call this, as the values GetActionBarToggles() returns are incorrect if it's called before the client mirrors SetActionBarToggles values from the server.
		-- SHOW_MULTI_ACTIONBAR_1, SHOW_MULTI_ACTIONBAR_2, SHOW_MULTI_ACTIONBAR_3, SHOW_MULTI_ACTIONBAR_4 = GetActionBarToggles();
		MultiActionBar_Update();

		-- Close any windows that were previously open
		CloseAllWindows(1);

		-- Until PVPFrame is checked in, this is placed here.
		for i=1, MAX_ARENA_TEAMS do
			GetArenaTeam(i);
		end

		VoiceChat_Toggle();

		UpdateMicroButtons();

		-- Fix for Bug 124392
		StaticPopup_Hide("LEVEL_GRANT_PROPOSED");
		StaticPopup_Hide("CONFIRM_LEAVE_BATTLEFIELD");
		
		local _, instanceType = IsInInstance();
		if ( instanceType == "arena" or instanceType == "pvp") then
			Arena_LoadUI();
		end
		if ( UnitIsGhost("player") ) then
			GhostFrame:Show();
		else
			GhostFrame:Hide();
		end
		if ( GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1 ) then
			StaticPopup_Show("DEATH");
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
		PlaySound("UI_PetBattles_PVP_ThroughQueue");
		StaticPopupSpecial_Show(PetBattleQueueReadyFrame);
	elseif ( event == "PET_BATTLE_QUEUE_PROPOSAL_DECLINED" or event == "PET_BATTLE_QUEUE_PROPOSAL_ACCEPTED" ) then
		StaticPopupSpecial_Hide(PetBattleQueueReadyFrame);
	elseif ( event == "TRADE_REQUEST_CANCEL" ) then
		StaticPopup_Hide("TRADE");
	elseif ( event == "CONFIRM_XP_LOSS" ) then
		local resSicknessTime = GetResSicknessDuration();
		if ( resSicknessTime ) then
			local dialog = nil;
			if (UnitLevel("player") <= 10) then
				dialog = StaticPopup_Show("XP_LOSS_NO_DURABILITY", resSicknessTime);
			else
				dialog = StaticPopup_Show("XP_LOSS", resSicknessTime);
			end
			if ( dialog ) then
				dialog.data = resSicknessTime;
			end
		else
			local dialog = nil;
			if (UnitLevel("player") <= 10) then
				dialog = StaticPopup_Show("XP_LOSS_NO_SICKNESS_NO_DURABILITY");
			else
				dialog = StaticPopup_Show("XP_LOSS_NO_SICKNESS");
			end
			if ( dialog ) then
				dialog.data = 1;
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
	elseif ( event == "BIND_ENCHANT" ) then
		StaticPopup_Show("BIND_ENCHANT");
	elseif ( event == "REPLACE_ENCHANT" ) then
		StaticPopup_Show("REPLACE_ENCHANT", arg1, arg2);
	elseif ( event == "TRADE_REPLACE_ENCHANT" ) then
		StaticPopup_Show("TRADE_REPLACE_ENCHANT", arg1, arg2);
	elseif ( event == "END_BOUND_TRADEABLE" ) then
		local dialog = StaticPopup_Show("END_BOUND_TRADEABLE", nil, nil, arg1);
	elseif ( event == "MACRO_ACTION_BLOCKED" or event == "ADDON_ACTION_BLOCKED" ) then
		if ( not INTERFACE_ACTION_BLOCKED_SHOWN ) then
			local info = ChatTypeInfo["SYSTEM"];
			DEFAULT_CHAT_FRAME:AddMessage(INTERFACE_ACTION_BLOCKED, info.r, info.g, info.b, info.id);
			INTERFACE_ACTION_BLOCKED_SHOWN = true;
		end
	elseif ( event == "MACRO_ACTION_FORBIDDEN" ) then
		StaticPopup_Show("MACRO_ACTION_FORBIDDEN");
	elseif ( event == "ADDON_ACTION_FORBIDDEN" ) then
		local dialog = StaticPopup_Show("ADDON_ACTION_FORBIDDEN", arg1);
		if ( dialog ) then
			dialog.data = arg1;
		end
	elseif ( event == "PLAYER_CONTROL_LOST" ) then
		if ( UnitOnTaxi("player") ) then
			return;
		end
		CloseAllWindows_WithExceptions();
		
		--[[
		-- Disable all microbuttons except the main menu
		SetDesaturation(MicroButtonPortrait, 1);
		
		Designers previously wanted these disabled when feared, they seem to have changed their minds
		CharacterMicroButton:Disable();
		SpellbookMicroButton:Disable();
		TalentMicroButton:Disable();
		QuestLogMicroButton:Disable();
		GuildMicroButton:Disable();
		WorldMapMicroButton:Disable();
		]]

		UIParent.isOutOfControl = 1;
	elseif ( event == "PLAYER_CONTROL_GAINED" ) then
		--[[
		-- Enable all microbuttons
		SetDesaturation(MicroButtonPortrait, nil);

		CharacterMicroButton:Enable();
		SpellbookMicroButton:Enable();
		TalentMicroButton:Enable();
		QuestLogMicroButton:Enable();
		GuildMicroButton:Enable();
		WorldMapMicroButton:Enable();
		]]

		UIParent.isOutOfControl = nil;
	elseif ( event == "START_LOOT_ROLL" ) then
		GroupLootFrame_OpenNewFrame(arg1, arg2);
	elseif ( event == "CONFIRM_LOOT_ROLL" ) then
		local texture, name, count, quality, bindOnPickUp = GetLootRollItemInfo(arg1);
		local dialog = StaticPopup_Show("CONFIRM_LOOT_ROLL", ITEM_QUALITY_COLORS[quality].hex..name.."|r");
		if ( dialog ) then
			dialog.text:SetFormattedText(arg3, ITEM_QUALITY_COLORS[quality].hex..name.."|r");
			StaticPopup_Resize(dialog, "CONFIRM_LOOT_ROLL");
			dialog.data = arg1;
			dialog.data2 = arg2;
		end
	elseif ( event == "MISSING_OUT_ON_LOOT" ) then
		MissingLootFrame_Show();
	elseif ( event == "SPELL_CONFIRMATION_PROMPT" ) then
		local spellID, confirmType, text, duration, currencyID = ...;
		if ( confirmType == CONFIRMATION_PROMPT_BONUS_ROLL ) then
			BonusRollFrame_StartBonusRoll(spellID, text, duration, currencyID);
		else
			StaticPopup_Show("SPELL_CONFIRMATION_PROMPT", text, duration, spellID);
		end
	elseif ( event == "SPELL_CONFIRMATION_TIMEOUT" ) then
		local spellID, confirmType = ...;
		if ( confirmType == CONFIRMATION_PROMPT_BONUS_ROLL ) then
			BonusRollFrame_CloseBonusRoll();
		else
			StaticPopup_Hide("SPELL_CONFIRMATION_PROMPT", spellID);
		end
	elseif ( event == "CONFIRM_DISENCHANT_ROLL" ) then
		local texture, name, count, quality, bindOnPickUp = GetLootRollItemInfo(arg1);
		local dialog = StaticPopup_Show("CONFIRM_LOOT_ROLL", ITEM_QUALITY_COLORS[quality].hex..name.."|r");
		if ( dialog ) then
			dialog.text:SetFormattedText(LOOT_NO_DROP_DISENCHANT, ITEM_QUALITY_COLORS[quality].hex..name.."|r");
			StaticPopup_Resize(dialog, "CONFIRM_LOOT_ROLL");
			dialog.data = arg1;
			dialog.data2 = arg2;
		end
	elseif ( event == "INSTANCE_BOOT_START" ) then
		StaticPopup_Show("INSTANCE_BOOT");
	elseif ( event == "INSTANCE_BOOT_STOP" ) then
		StaticPopup_Hide("INSTANCE_BOOT");
	elseif ( event == "INSTANCE_LOCK_START" ) then
		StaticPopup_Show("INSTANCE_LOCK", nil, nil, true);
	elseif ( event == "INSTANCE_LOCK_STOP" ) then
		StaticPopup_Hide("INSTANCE_LOCK");
	elseif ( event == "INSTANCE_LOCK_WARNING" ) then
		StaticPopup_Show("INSTANCE_LOCK", nil, nil, false);
	elseif ( event == "CONFIRM_TALENT_WIPE" ) then
		HideUIPanel(GossipFrame);
		StaticPopupDialogs["CONFIRM_TALENT_WIPE"].text = _G["CONFIRM_TALENT_WIPE_"..arg2];
		local dialog = StaticPopup_Show("CONFIRM_TALENT_WIPE");
		if ( dialog ) then
			MoneyFrame_Update(dialog:GetName().."MoneyFrame", arg1);
			-- open the talent UI to the player's active talent group...just so the player knows
			-- exactly which talent spec he is wiping
--			TalentFrame_LoadUI();
--			if ( PlayerTalentFrame_Open ) then
--				PlayerTalentFrame_Open(GetActiveSpecGroup());
--			end
		end
	elseif ( event == "CONFIRM_BINDER" ) then
		StaticPopup_Show("CONFIRM_BINDER", arg1);
	elseif ( event == "CONFIRM_SUMMON" ) then
		StaticPopup_Show("CONFIRM_SUMMON");
	elseif ( event == "CANCEL_SUMMON" ) then
		StaticPopup_Hide("CONFIRM_SUMMON");
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
		local dialog = StaticPopup_Show("GOSSIP_CONFIRM", arg2);
		if ( dialog ) then
			dialog.data = arg1;
			if ( arg3 > 0 ) then
				MoneyFrame_Update(dialog:GetName().."MoneyFrame", arg3);
			end
		end
	elseif ( event == "GOSSIP_ENTER_CODE" ) then
		local dialog = StaticPopup_Show("GOSSIP_ENTER_CODE");
		if ( dialog ) then
			dialog.data = arg1;
		end
	elseif ( event == "GOSSIP_CONFIRM_CANCEL" or event == "GOSSIP_CLOSED" ) then
		StaticPopup_Hide("GOSSIP_CONFIRM");
		StaticPopup_Hide("GOSSIP_ENTER_CODE");
		
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

	-- Events for trainer UI handling
	elseif ( event == "TRAINER_SHOW" ) then
		ClassTrainerFrame_LoadUI();
		if ( ClassTrainerFrame_Show ) then
			ClassTrainerFrame_Show();
		end
	elseif ( event == "TRAINER_CLOSED" ) then
		if ( ClassTrainerFrame_Hide ) then
			ClassTrainerFrame_Hide();
		end

	-- Events for trade skill UI handling
	elseif ( event == "TRADE_SKILL_SHOW" ) then
		TradeSkillFrame_LoadUI();
		if ( TradeSkillFrame_Show ) then
			TradeSkillFrame_Show();						
		end
	elseif ( event == "TRADE_SKILL_CLOSE" ) then
		if ( TradeSkillFrame_Hide ) then
			TradeSkillFrame_Hide();
		end

	-- Event for item socketing handling
	elseif ( event == "SOCKET_INFO_UPDATE" ) then
		ItemSocketingFrame_LoadUI();
		ItemSocketingFrame_Update();
		ShowUIPanel(ItemSocketingFrame);

	-- Event for BarberShop handling
	elseif ( event == "BARBER_SHOP_OPEN" ) then
		BarberShopFrame_LoadUI();
		if ( BarberShopFrame ) then
			ShowUIPanel(BarberShopFrame);
		end
	elseif ( event == "BARBER_SHOP_CLOSE" ) then
		if ( BarberShopFrame and BarberShopFrame:IsVisible() ) then
			BarberShopFrame:Hide();
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

	-- Event for barbershop handling
	elseif ( event == "BARBER_SHOP_OPEN" ) then
		BarberShopFrame_LoadUI();
		if ( BarberShopFrame ) then
			ShowUIPanel(BarberShopFrame);
		end
	elseif ( event == "BARBER_SHOP_CLOSE" ) then
		BarberShopFrame_LoadUI();
		if ( BarberShopFrame ) then
			HideUIPanel(BarberShopFrame);
		end
	
	-- Events for achievement handling
	elseif ( event == "ACHIEVEMENT_EARNED" ) then
		-- if ( not AchievementFrame ) then
			-- AchievementFrame_LoadUI();
			-- AchievementAlertFrame_ShowAlert(...);
		-- end
		-- self:UnregisterEvent(event);

	-- Display instance reset info
	elseif ( event == "RAID_INSTANCE_WELCOME" ) then
		local dungeonName = arg1;
		local lockExpireTime = arg2;
		local locked = arg3;
		local extended = arg4;
		local message;

		if ( locked == 0 ) then
			message = format(RAID_INSTANCE_WELCOME, dungeonName, SecondsToTime(lockExpireTime, nil, 1))
		else
			if ( lockExpireTime == 0 ) then
				message = format(RAID_INSTANCE_WELCOME_EXTENDED, dungeonName);
			else
				if ( extended == 0 ) then
					message = format(RAID_INSTANCE_WELCOME_LOCKED, dungeonName, SecondsToTime(lockExpireTime, nil, 1));
				else
					message = format(RAID_INSTANCE_WELCOME_LOCKED_EXTENDED, dungeonName, SecondsToTime(lockExpireTime, nil, 1));
				end
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
	
	-- Push to talk
	elseif ( event == "VOICE_PUSH_TO_TALK_START" and GetVoiceCurrentSessionID() ) then
		if ( GetCVarBool("PushToTalkSound") ) then
			PlaySound("VoiceChatOn");
		end
		-- Animate the player frame speaker even if not broadcasting
		if  ( GetCVar("VoiceChatMode") == "0" ) then
			UIFrameFadeIn(PlayerSpeakerFrame, 0.2, PlayerSpeakerFrame:GetAlpha(), 1);
		end
	elseif ( event == "VOICE_PUSH_TO_TALK_STOP" ) then
		if ( GetCVarBool("PushToTalkSound") and GetVoiceCurrentSessionID() ) then
			PlaySound("VoiceChatOff");
		end
		-- Stop Animation
		if  ( GetCVar("VoiceChatMode") == "0" and PlayerSpeakerFrame:GetAlpha() > 0 ) then
			UIFrameFadeOut(PlayerSpeakerFrame, 0.2, PlayerSpeakerFrame:GetAlpha(), 0);
		end
	elseif ( event == "LEVEL_GRANT_PROPOSED" ) then
		StaticPopup_Show("LEVEL_GRANT_PROPOSED", arg1);
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
		
	-- Events for Transmogrify UI handling
	elseif ( event == "TRANSMOGRIFY_OPEN" ) then
		ItemAlteration_LoadUI();
		if ( TransmogrifyFrame_Show ) then
			TransmogrifyFrame_Show();
		end
	elseif ( event == "TRANSMOGRIFY_CLOSE" ) then
		if ( TransmogrifyFrame_Hide ) then
			TransmogrifyFrame_Hide();
		end

	-- Events for Void Storage UI handling
	elseif ( event == "VOID_STORAGE_OPEN" ) then
		VoidStorage_LoadUI();
		if ( VoidStorageFrame_Show ) then
			VoidStorageFrame_Show();
		end
	elseif ( event == "VOID_STORAGE_CLOSE" ) then
		if ( VoidStorageFrame_Hide ) then
			VoidStorageFrame_Hide();
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

	-- Events for Pet Journal
	elseif ( event == "PET_JOURNAL_NEW_BATTLE_SLOT" ) then
		CompanionsMicroButtonAlert:Show();
		MicroButtonPulse(CompanionsMicroButton);
	
	-- Quest Choice trigger event
	
	elseif (event == "QUEST_CHOICE_UPDATE") then
		QuestChoice_LoadUI();
		if ( QuestChoiceFrame_Show) then
			QuestChoiceFrame_Show();
		end
	end
end

-- Frame Management --

-- UIPARENT_MANAGED_FRAME_POSITIONS stores all the frames that have positioning dependencies based on other frames.  

-- UIPARENT_MANAGED_FRAME_POSITIONS["FRAME"] = {
	--Note: this is out of date and there are several more options now.
	-- none = This value is used if no dependent frames are shown
	-- reputation = This is the offset used if the reputation watch bar is shown
	-- anchorTo = This is the object that the stored frame is anchored to
	-- point = This is the point on the frame used as the anchor
	-- rpoint = This is the point on the "anchorTo" frame that the stored frame is anchored to
	-- bottomEither = This offset is used if either bottom multibar is shown
	-- bottomLeft
	-- var = If this is set use _G[varName] = value instead of setpoint
-- };


-- some standard offsets
local actionBarOffset = 45;
local menuBarTop = 55;
local overrideActionBarTop = 40;
local petBattleTop = 60;

function UpdateMenuBarTop ()
	--Determines the optimal magic number based on resolution and action bar status.
	menuBarTop = 55;
	local width, height = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)");
	if ( tonumber(width) / tonumber(height ) > 4/3 ) then
		--Widescreen resolution
		menuBarTop = 75;
	end
end

UIPARENT_MANAGED_FRAME_POSITIONS = {
	--Items with baseY set to "true" are positioned based on the value of menuBarTop and their offset needs to be repeatedly evaluated as menuBarTop can change. 
	--"yOffset" gets added to the value of "baseY", which is used for values based on menuBarTop.
	["MultiBarBottomLeft"] = {baseY = 17, reputation = 1, maxLevel = 1, anchorTo = "ActionButton1", point = "BOTTOMLEFT", rpoint = "TOPLEFT"};
	["MultiBarRight"] = {baseY = 98, reputation = 1, anchorTo = "UIParent", point = "BOTTOMRIGHT", rpoint = "BOTTOMRIGHT"};
	["VoiceChatTalkers"] = {baseY = true, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, reputation = 1};
	["GroupLootContainer"] = {baseY = true, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, reputation = 1};
	["MissingLootFrame"] = {baseY = true, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, reputation = 1};
	["TutorialFrameAlertButton"] = {baseY = true, yOffset = -10, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, reputation = 1};
	["FramerateLabel"] = {baseY = true, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, reputation = 1, playerPowerBarAlt = 1, extraActionBarFrame = 1};
	["CastingBarFrame"] = {baseY = true, yOffset = 40, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, reputation = 1, tutorialAlert = 1, playerPowerBarAlt = 1, extraActionBarFrame = 1};
	["PlayerPowerBarAlt"] = {baseY = true, yOffset = 40, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, reputation = 1, tutorialAlert = 1, extraActionBarFrame = 1};
	["ExtraActionBarFrame"] = {baseY = true, yOffset = 40, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, reputation = 1, tutorialAlert = 1};
	["ChatFrame1"] = {baseY = true, yOffset = 40, bottomLeft = actionBarOffset-8, justBottomRightAndStance = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, reputation = 1, maxLevel = 1, point = "BOTTOMLEFT", rpoint = "BOTTOMLEFT", xOffset = 32};
	["ChatFrame2"] = {baseY = true, yOffset = 40, bottomRight = actionBarOffset-8, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, rightLeft = -2*actionBarOffset, rightRight = -actionBarOffset, reputation = 1, maxLevel = 1, point = "BOTTOMRIGHT", rpoint = "BOTTOMRIGHT", xOffset = -32};
	["StanceBarFrame"] = {baseY = 0, bottomLeft = actionBarOffset, reputation = 1, maxLevel = 1, anchorTo = "MainMenuBar", point = "BOTTOMLEFT", rpoint = "TOPLEFT", xOffset = 30};
	["PossessBarFrame"] = {baseY = 0, bottomLeft = actionBarOffset, reputation = 1, maxLevel = 1, anchorTo = "MainMenuBar", point = "BOTTOMLEFT", rpoint = "TOPLEFT", xOffset = 30};
	["MultiCastActionBarFrame"] = {baseY = 0, bottomLeft = actionBarOffset, reputation = 1, maxLevel = 1, anchorTo = "MainMenuBar", point = "BOTTOMLEFT", rpoint = "TOPLEFT", xOffset = 30};
	["AuctionProgressFrame"] = {baseY = true, yOffset = 18, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, reputation = 1, tutorialAlert = 1};
	
	-- Vars
	-- These indexes require global variables of the same name to be declared. For example, if I have an index ["FOO"] then I need to make sure the global variable
	-- FOO exists before this table is constructed. The function UIParent_ManageFramePosition will use the "FOO" table index to change the value of the FOO global
	-- variable so that other modules can use the most up-to-date value of FOO without having knowledge of the UIPARENT_MANAGED_FRAME_POSITIONS table.
	["CONTAINER_OFFSET_X"] = {baseX = 0, rightLeft = 2*actionBarOffset+3, rightRight = actionBarOffset+3, isVar = "xAxis"};
	["CONTAINER_OFFSET_Y"] = {baseY = true, yOffset = 10, bottomEither = actionBarOffset, reputation = 1, isVar = "yAxis"};
	["BATTLEFIELD_TAB_OFFSET_Y"] = {baseY = 210, bottomRight = actionBarOffset, reputation = 1, isVar = "yAxis"};
	["PETACTIONBAR_YPOS"] = {baseY = 97, bottomLeft = actionBarOffset, justBottomRightAndStance = actionBarOffset, reputation = 1, maxLevel = 1, isVar = "yAxis"};
	["MULTICASTACTIONBAR_YPOS"] = {baseY = 0, bottomLeft = actionBarOffset, reputation = 1, maxLevel = 1, isVar = "yAxis"};
};

-- If any Var entries in UIPARENT_MANAGED_FRAME_POSITIONS are used exclusively by addons, they should be declared here and not in one of the addon's files.
-- The reason why is that it is possible for UIParent_ManageFramePosition to be run before the addon loads.
BATTLEFIELD_TAB_OFFSET_Y = 0;


-- constant offsets
for _, data in pairs(UIPARENT_MANAGED_FRAME_POSITIONS) do
	for flag, value in pairs(data) do
		if ( flag == "reputation" ) then
			data[flag] = value * 9;
		elseif ( flag == "maxLevel" ) then
			data[flag] = value * -5;
		elseif ( flag == "pet" ) then
			data[flag] = value * 35;
		elseif ( flag == "tutorialAlert" ) then
			data[flag] = value * 35;
		end
	end
end

function UIParent_ManageFramePosition(index, value, yOffsetFrames, xOffsetFrames, hasBottomLeft, hasBottomRight, hasPetBar)
	local frame, xOffset, yOffset, anchorTo, point, rpoint;

	frame = _G[index];
	if ( not frame or (type(frame)=="table" and frame.ignoreFramePositionManager)) then
		return;
	end
	
	-- Always start with base as the base offset or default to zero if no "none" specified
	xOffset = 0;
	if ( value["baseX"] ) then
		xOffset = value["baseX"];
	elseif ( value["xOffset"] ) then
		xOffset = value["xOffset"];
	end
	yOffset = 0;
	if ( tonumber(value["baseY"]) ) then
		--tonumber(nil) and tonumber(boolean) evaluate as nil, tonumber(number) evaluates as a number, which evaluates as true.
		--This allows us to use the true value in baseY for flagging a frame's positioning as dependent upon the value of menuBarTop.
		yOffset = value["baseY"];
	elseif ( value["baseY"] ) then
		--value["baseY"] is true, use menuBarTop.
		yOffset = menuBarTop;
	end
	
	if ( value["yOffset"] ) then
		--This is so things based on menuBarTop can still have an offset. Otherwise you'd just use put the offset value in baseY.
		yOffset = yOffset + value["yOffset"];
	end
	
	-- Iterate through frames that affect y offsets
	local hasBottomEitherFlag;
	for _, flag in pairs(yOffsetFrames) do
		if ( value[flag] ) then
			if ( flag == "bottomEither" ) then
				hasBottomEitherFlag = 1;
			end
			yOffset = yOffset + value[flag];
		end
	end
	
	-- don't offset for the pet bar and bottomEither if the player has
	-- the bottom right bar shown and not the bottom left
	if ( hasBottomEitherFlag and hasBottomRight and hasPetBar and not hasBottomLeft ) then
		yOffset = yOffset - (value["pet"] or 0);
	end

	-- Iterate through frames that affect x offsets
	for _, flag in pairs(xOffsetFrames) do
		if ( value[flag] ) then
			xOffset = xOffset + value[flag];
		end
	end

	-- Set up anchoring info
	anchorTo = value["anchorTo"];
	point = value["point"];
	rpoint = value["rpoint"];
	if ( not anchorTo ) then
		anchorTo = "UIParent";
	end
	if ( not point ) then
		point = "BOTTOM";
	end
	if ( not rpoint ) then
		rpoint = "BOTTOM";
	end

	-- Anchor frame
	if ( value["isVar"] ) then
		if ( value["isVar"] == "xAxis" ) then
			_G[index] = xOffset;
		else
			_G[index] = yOffset;
		end
	else
		if ( frame ~= ChatFrame2 and not(frame:IsObjectType("frame") and frame:IsUserPlaced()) ) then
			frame:SetPoint(point, anchorTo, rpoint, xOffset, yOffset);
		end
	end
end

local function FramePositionDelegate_OnAttributeChanged(self, attribute)
	if ( attribute == "panel-show" ) then
		local force = self:GetAttribute("panel-force");
		local frame = self:GetAttribute("panel-frame");
		self:ShowUIPanel(frame, force);
	elseif ( attribute == "panel-hide" ) then
		local frame = self:GetAttribute("panel-frame");
		local skipSetPoint = self:GetAttribute("panel-skipSetPoint");
		self:HideUIPanel(frame, skipSetPoint);
	elseif ( attribute == "panel-update" ) then
		local frame = self:GetAttribute("panel-frame");
		self:UpdateUIPanelPositions(frame);
	elseif ( attribute == "uiparent-manage" ) then
		self:UIParentManageFramePositions();
	end
end

local FramePositionDelegate = CreateFrame("FRAME");
FramePositionDelegate:SetScript("OnAttributeChanged", FramePositionDelegate_OnAttributeChanged);

function FramePositionDelegate:ShowUIPanel(frame, force)
	local frameArea, framePushable;
	frameArea = GetUIPanelWindowInfo(frame, "area");
	if ( not CanOpenPanels() and frameArea ~= "center" and frameArea ~= "full" ) then
		self:ShowUIPanelFailed(frame);
		return;
	end
	framePushable = GetUIPanelWindowInfo(frame, "pushable") or 0;

	if ( UnitIsDead("player") and not GetUIPanelWindowInfo(frame, "whileDead") ) then
		NotWhileDeadError();
		return;
	end

	-- If we have a full-screen frame open, ignore other non-fullscreen open requests
	if ( self:GetUIPanel("fullscreen") and (frameArea ~= "full") ) then
		if ( force ) then
			self:SetUIPanel("fullscreen", nil, 1);
		else
			self:ShowUIPanelFailed(frame);
			return;
		end
	end

	-- If we have a "center" frame open, only listen to other "center" open requests
	local centerFrame = self:GetUIPanel("center");
	local centerArea, centerPushable;
	if ( centerFrame ) then
		if ( GetUIPanelWindowInfo(centerFrame, "allowOtherPanels") ) then
			HideUIPanel(centerFrame);
			centerFrame = nil;
		else	
			centerArea = GetUIPanelWindowInfo(centerFrame, "area");
			if ( centerArea and (centerArea == "center") and (frameArea ~= "center") and (frameArea ~= "full") ) then
				if ( force ) then
					self:SetUIPanel("center", nil, 1);
				else
					self:ShowUIPanelFailed(frame);
					return;
				end
			end
			centerPushable = GetUIPanelWindowInfo(centerFrame, "pushable") or 0;
		end
	end
	
	-- Full-screen frames just replace each other
	if ( frameArea == "full" ) then
		securecall("CloseAllWindows");
		self:SetUIPanel("fullscreen", frame);
		return;
	end
	
	-- Native "center" frames just replace each other, and they take priority over pushed frames
	if ( frameArea == "center" ) then
		securecall("CloseWindows");
		if ( not GetUIPanelWindowInfo(frame, "allowOtherPanels") ) then
			securecall("CloseAllBags");
		end
		self:SetUIPanel("center", frame, 1);
		return;
	end

	-- Doublewide frames take up the left and center spots
	if ( frameArea == "doublewide" ) then
		local leftFrame = self:GetUIPanel("left");
		if ( leftFrame ) then
			local leftPushable = GetUIPanelWindowInfo(leftFrame, "pushable") or 0;
			if ( leftPushable > 0 and CanShowRightUIPanel(leftFrame) ) then
				-- Push left to right
				self:MoveUIPanel("left", "right", 1);
			elseif ( centerFrame and CanShowRightUIPanel(centerFrame) ) then
				self:MoveUIPanel("center", "right", 1);
			end
		end
		self:SetUIPanel("doublewide", frame);
		return;
	end
	
	-- If not pushable, close any doublewide frames
	local doublewideFrame = self:GetUIPanel("doublewide");
	if ( doublewideFrame ) then
		if ( framePushable == 0 ) then
			-- Set as left (closes doublewide) and slide over the right frame
			self:SetUIPanel("left", frame, 1);
			self:MoveUIPanel("right", "center");
		elseif ( CanShowRightUIPanel(frame) ) then
			-- Set as right
			self:SetUIPanel("right", frame);
		else
			self:SetUIPanel("left", frame);
		end
		return;
	end
	
	-- Try to put it on the left
	local leftFrame = self:GetUIPanel("left");
	if ( not leftFrame ) then
		self:SetUIPanel("left", frame);
		return;
	end
	local leftPushable = GetUIPanelWindowInfo(leftFrame, "pushable") or 0;
	
	-- Two open already
	local rightFrame = self:GetUIPanel("right");
	if ( centerFrame and not rightFrame ) then
		-- If not pushable and left isn't pushable
		if ( leftPushable == 0 and framePushable == 0 ) then
			-- Replace left
			self:SetUIPanel("left", frame);
		elseif ( ( framePushable > centerPushable or centerArea == "center" ) and CanShowRightUIPanel(frame) ) then
			-- This one is highest priority, show as right
			self:SetUIPanel("right", frame);
		elseif ( framePushable < leftPushable ) then
			if ( centerArea == "center" ) then
				if ( CanShowRightUIPanel(leftFrame) ) then
					-- Skip center
					self:MoveUIPanel("left", "right", 1);
					self:SetUIPanel("left", frame);
				else
					-- Replace left
					self:SetUIPanel("left", frame);
				end
			else
				if ( CanShowUIPanels(frame, leftFrame, centerFrame) ) then
					-- Shift both
					self:MoveUIPanel("center", "right", 1);
					self:MoveUIPanel("left", "center", 1);
					self:SetUIPanel("left", frame);
				else
					-- Replace left
					self:SetUIPanel("left", frame);
				end
			end
		elseif ( framePushable <= centerPushable and centerArea ~= "center" and CanShowUIPanels(leftFrame, frame, centerFrame) ) then
			-- Push center
			self:MoveUIPanel("center", "right", 1);
			self:SetUIPanel("center", frame);
		elseif ( framePushable <= centerPushable and centerArea ~= "center" ) then
			-- Replace left
			self:SetUIPanel("left", frame);
		else
			-- Replace center
			self:SetUIPanel("center", frame);
		end
		
		return;
	end
	
	-- If there's only one open...
	if ( not centerFrame ) then
		-- If neither is pushable, replace
		if ( (leftPushable == 0) and (framePushable == 0) ) then
			self:SetUIPanel("left", frame);
			return;
		end

		-- Highest priority goes to center
		if ( leftPushable > framePushable ) then
			self:MoveUIPanel("left", "center", 1);
			self:SetUIPanel("left", frame);
		else
			self:SetUIPanel("center", frame);
		end
		
		return;
	end

	-- Three are shown
	local rightPushable = GetUIPanelWindowInfo(rightFrame, "pushable") or 0;
	if ( framePushable > rightPushable ) then
		-- This one is highest priority, slide the other two over
		if ( CanShowUIPanels(centerFrame, rightFrame, frame) ) then
			self:MoveUIPanel("center", "left", 1);
			self:MoveUIPanel("right", "center", 1);
			self:SetUIPanel("right", frame);
		else
			self:MoveUIPanel("right", "left", 1);
			self:SetUIPanel("center", frame);
		end
	elseif ( framePushable > centerPushable ) then
		-- This one is middle priority, so move the center frame to the left
		self:MoveUIPanel("center", "left", 1);
		self:SetUIPanel("center", frame);
	else
		self:SetUIPanel("left", frame);
	end
end

function FramePositionDelegate:ShowUIPanelFailed(frame)
	local showFailedFunc = _G[GetUIPanelWindowInfo(frame, "showFailedFunc")];
	if ( showFailedFunc ) then
		showFailedFunc(frame);
	end
end

function FramePositionDelegate:SetUIPanel(key, frame, skipSetPoint)
	if ( key == "fullscreen" ) then
		local oldFrame = self.fullscreen;
		self.fullscreen = frame;
	
		if ( oldFrame ) then
			oldFrame:Hide();
		end
	
		if ( frame ) then
			UIParent:Hide();
			frame:Show();
		else
			UIParent:Show();
			SetUIVisibility(true);
		end
		return;
	elseif ( key == "doublewide" ) then
		local oldLeft = self.left;
		local oldCenter = self.center;
		local oldDoubleWide = self.doublewide;
		self.doublewide = frame;
		self.left = nil;
		self.center = nil;
		
		if ( oldDoubleWide ) then
			oldDoubleWide:Hide();
		end
		
		if ( oldLeft ) then
			oldLeft:Hide();
		end
		
		if ( oldCenter ) then
			oldCenter:Hide();
		end
	elseif ( key ~= "left" and key ~= "center" and key ~= "right" ) then
		return;
	else
		local oldFrame = self[key];
		self[key] = frame;
		if ( oldFrame ) then
			oldFrame:Hide();
		else
			if ( self.doublewide ) then
				if ( key == "left" or key == "center" ) then
					self.doublewide:Hide();
					self.doublewide = nil;	
				end
			end
		end
	end
	
	if ( not skipSetPoint ) then
		securecall("UpdateUIPanelPositions", frame);
	end
	
	if ( frame ) then
		frame:Show();
		-- Hide all child windows
		securecall("CloseChildWindows");
	end
end

function FramePositionDelegate:MoveUIPanel(current, new, skipSetPoint)
	if ( current ~= "left" and current ~= "center" and current ~= "right" and new ~= "left" and new ~= "center" and new ~= "right" ) then
		return;
	end

	self:SetUIPanel(new, nil, skipSetPoint);
	if ( self[current] ) then
		self[current]:Raise();
		self[new] = self[current];
		self[current] = nil;
		if ( not skipSetPoint ) then
			securecall("UpdateUIPanelPositions");
		end
	end
end

function FramePositionDelegate:HideUIPanel(frame, skipSetPoint)
	-- If we're hiding the full-screen frame, just hide it
	if ( frame == self:GetUIPanel("fullscreen") ) then
		self:SetUIPanel("fullscreen", nil);
		return;
	end
	
	-- If we're hiding the right frame, just hide it
	if ( frame == self:GetUIPanel("right") ) then
		self:SetUIPanel("right", nil, skipSetPoint);
		return;
	elseif ( frame == self:GetUIPanel("doublewide") ) then
		-- Slide over any right frame (hides the doublewide)
		self:MoveUIPanel("right", "left", skipSetPoint);
		return;
	end

	-- If we're hiding the center frame, slide over any right frame
	local centerFrame = self:GetUIPanel("center");
	if ( frame == centerFrame ) then
		self:MoveUIPanel("right", "center", skipSetPoint);
	elseif ( frame == self:GetUIPanel("left") ) then
		-- If we're hiding the left frame, move the other frames left, unless the center is a native center frame
		if ( centerFrame ) then
			local area = GetUIPanelWindowInfo(centerFrame, "area");
			if ( area ) then
				if ( area == "center" ) then
					-- Slide left, skip the center
					self:MoveUIPanel("right", "left", skipSetPoint);
					return;
				else
					-- Slide everything left
					self:MoveUIPanel("center", "left", 1);
					self:MoveUIPanel("right", "center", skipSetPoint);
					return;
				end
			end
		end
		self:SetUIPanel("left", nil, skipSetPoint);
	else
		frame:Hide();
	end
end

function FramePositionDelegate:GetUIPanel(key)
	if ( key ~= "left" and key ~= "center" and key ~= "right" and key ~= "doublewide" and key ~= "fullscreen" ) then
		return nil;
	end
	
	return self[key];
end

function FramePositionDelegate:UpdateUIPanelPositions(currentFrame)
	if ( self.updatingPanels ) then
		return;
	end
	self.updatingPanels = true;
	
	local topOffset = UIParent:GetAttribute("TOP_OFFSET");
	local leftOffset = UIParent:GetAttribute("LEFT_OFFSET");
	local centerOffset = UIParent:GetAttribute("CENTER_OFFSET");
	local rightOffset = UIParent:GetAttribute("RIGHT_OFFSET");
	local xSpacing = UIParent:GetAttribute("PANEl_SPACING_X");

	local info;
	local frame = self:GetUIPanel("left");
	if ( frame ) then
		local xOff = GetUIPanelWindowInfo(frame,"xoffset") or 0;
		local yOff = GetUIPanelWindowInfo(frame,"yoffset") or 0;
		local yPos = ClampUIPanelY(frame, yOff + topOffset);
		frame:ClearAllPoints();
		frame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", leftOffset + xOff, yPos);
		centerOffset = leftOffset + GetUIPanelWidth(frame) + xOff;
		UIParent:SetAttribute("CENTER_OFFSET", centerOffset);
		frame:Raise();
	else
		frame = self:GetUIPanel("doublewide");
		if ( frame ) then
			local xOff = GetUIPanelWindowInfo(frame,"xoffset") or 0;
			local yOff = GetUIPanelWindowInfo(frame,"yoffset") or 0;
			local yPos = ClampUIPanelY(frame, yOff + topOffset);
			frame:ClearAllPoints();
			frame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", leftOffset + xOff, yPos);
			rightOffset = leftOffset + GetUIPanelWidth(frame) + xOff;
			UIParent:SetAttribute("RIGHT_OFFSET", rightOffset);
			frame:Raise();
		end
	end

	frame = self:GetUIPanel("center");
	if ( frame ) then
		if ( CanShowCenterUIPanel(frame) ) then
			local area = GetUIPanelWindowInfo(frame, "area");
			local xOff = GetUIPanelWindowInfo(frame,"xoffset") or 0;
			local yOff = GetUIPanelWindowInfo(frame,"yoffset") or 0;
			local yPos = ClampUIPanelY(frame, yOff + topOffset);
			if ( area ~= "center" ) then
				frame:ClearAllPoints();
				xOff = xOff + xSpacing; -- add sperating space
				frame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", centerOffset + xOff, yPos);
			end
			rightOffset = centerOffset + GetUIPanelWidth(frame) + xOff;
		else
			if ( frame == currentFrame ) then
				frame = self:GetUIPanel("left") or self:GetUIPanel("doublewide");
				if ( frame ) then
					self:HideUIPanel(frame);
					self.updatingPanels = nil;
					self:UpdateUIPanelPositions(currentFrame);
					return;
				end
			end
			self:SetUIPanel("center", nil, 1);
			rightOffset = centerOffset + UIParent:GetAttribute("DEFAULT_FRAME_WIDTH");
		end
		frame:Raise();
	elseif ( not self:GetUIPanel("doublewide") ) then
		if ( self:GetUIPanel("left") ) then
			rightOffset = centerOffset + UIParent:GetAttribute("DEFAULT_FRAME_WIDTH");
		else
			rightOffset = leftOffset + UIParent:GetAttribute("DEFAULT_FRAME_WIDTH") * 2
		end
	end
	UIParent:SetAttribute("RIGHT_OFFSET", rightOffset);

	frame = self:GetUIPanel("right");
	if ( frame ) then
		if ( CanShowRightUIPanel(frame) ) then
			local xOff = GetUIPanelWindowInfo(frame,"xoffset") or 0;
			local yOff = GetUIPanelWindowInfo(frame,"yoffset") or 0;
			local yPos = ClampUIPanelY(frame, yOff + topOffset);
			xOff = xOff + xSpacing; -- add sperating space
			frame:ClearAllPoints();
			frame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", rightOffset  + xOff, yPos);
		else
			if ( frame == currentFrame ) then
				frame = GetUIPanel("center") or GetUIPanel("left") or GetUIPanel("doublewide");
				if ( frame ) then
					self:HideUIPanel(frame);
					self.updatingPanels = nil;
					self:UpdateUIPanelPositions(currentFrame);
					return;
				end
			end
			self:SetUIPanel("right", nil, 1);
		end
		frame:Raise();
	end

	self.updatingPanels = nil;
end

function FramePositionDelegate:UIParentManageFramePositions()
	-- Update the variable with the happy magic number.
	UpdateMenuBarTop();
	
	-- Frames that affect offsets in y axis
	local yOffsetFrames = {};
	-- Frames that affect offsets in x axis
	local xOffsetFrames = {};
	
	-- Set up flags
	local hasBottomLeft, hasBottomRight, hasPetBar;
	
	if ( OverrideActionBar and OverrideActionBar:IsShown() ) then
		tinsert(yOffsetFrames, "overrideActionBar");
	elseif ( PetBattleFrame and PetBattleFrame:IsShown() ) then
		tinsert(yOffsetFrames, "petBattleFrame");
	else	
		if ( MultiBarBottomLeft:IsShown() or MultiBarBottomRight:IsShown() ) then
			tinsert(yOffsetFrames, "bottomEither");
		end
		if ( MultiBarBottomRight:IsShown() ) then
			tinsert(yOffsetFrames, "bottomRight");
			hasBottomRight = 1;
		end
		if ( MultiBarBottomLeft:IsShown() ) then
			tinsert(yOffsetFrames, "bottomLeft");
			hasBottomLeft = 1;
		end
		if ( MultiBarLeft:IsShown() ) then
			tinsert(xOffsetFrames, "rightLeft");
		elseif ( MultiBarRight:IsShown() ) then
			tinsert(xOffsetFrames, "rightRight");
		end
		if (PetActionBarFrame_IsAboveStance and PetActionBarFrame_IsAboveStance()) then
			tinsert(yOffsetFrames, "justBottomRightAndStance");
		end
		if ( ( PetActionBarFrame and PetActionBarFrame:IsShown() ) or ( StanceBarFrame and StanceBarFrame:IsShown() ) or
			 ( MultiCastActionBarFrame and MultiCastActionBarFrame:IsShown() ) or ( PossessBarFrame and PossessBarFrame:IsShown() ) or
			 ( MainMenuBarVehicleLeaveButton and MainMenuBarVehicleLeaveButton:IsShown() ) ) then
			tinsert(yOffsetFrames, "pet");
			hasPetBar = 1;
		end
		if ( ReputationWatchBar:IsShown() and MainMenuExpBar:IsShown() ) then
			tinsert(yOffsetFrames, "reputation");
		end
		if ( MainMenuBarMaxLevelBar:IsShown() ) then
			tinsert(yOffsetFrames, "maxLevel");
		end
		if ( TutorialFrameAlertButton:IsShown() ) then
			tinsert(yOffsetFrames, "tutorialAlert");
		end
		if ( PlayerPowerBarAlt:IsShown() ) then
			tinsert(yOffsetFrames, "playerPowerBarAlt");
		end
		if (ExtraActionBarFrame and ExtraActionBarFrame:IsShown() ) then
			tinsert(yOffsetFrames, "extraActionBarFrame");
		end
	end
	
	if ( menuBarTop == 55 ) then
		UIPARENT_MANAGED_FRAME_POSITIONS["TutorialFrameAlertButton"].yOffset = -10;
	else
		UIPARENT_MANAGED_FRAME_POSITIONS["TutorialFrameAlertButton"].yOffset = -30;
	end
	
	
	-- Iterate through frames and set anchors according to the flags set
	for index, value in pairs(UIPARENT_MANAGED_FRAME_POSITIONS) do
		if ( value.playerPowerBarAlt ) then
			value.playerPowerBarAlt = PlayerPowerBarAlt:GetHeight() + 10;
		end
		if ( value.extraActionBarFrame and ExtraActionBarFrame ) then
			value.extraActionBarFrame = ExtraActionBarFrame:GetHeight() + 10;
		end
		if ( value.bonusActionBar and BonusActionBarFrame ) then
			value.bonusActionBar = BonusActionBarFrame:GetHeight() - MainMenuBar:GetHeight();
		end
		securecall("UIParent_ManageFramePosition", index, value, yOffsetFrames, xOffsetFrames, hasBottomLeft, hasBottomRight, hasPetBar);
	end
	
	-- Custom positioning not handled by the loop

	-- Update Stance bar appearance
	if ( MultiBarBottomLeft:IsShown() ) then
		SlidingActionBarTexture0:Hide();
		SlidingActionBarTexture1:Hide();
		if ( StanceBarFrame ) then
			StanceBarLeft:Hide();
			StanceBarRight:Hide();
			StanceBarMiddle:Hide();
			for i=1, NUM_STANCE_SLOTS do
				_G["StanceButton"..i]:GetNormalTexture():SetWidth(52);
				_G["StanceButton"..i]:GetNormalTexture():SetHeight(52);
			end
		end
	else
		if (PetActionBarFrame_IsAboveStance and PetActionBarFrame_IsAboveStance()) then
			SlidingActionBarTexture0:Hide();
			SlidingActionBarTexture1:Hide();
		else
			SlidingActionBarTexture0:Show();
			SlidingActionBarTexture1:Show();
		end
		if ( StanceBarFrame ) then
			if ( GetNumShapeshiftForms() > 2 ) then
				StanceBarMiddle:Show();
			end
			StanceBarLeft:Show();
			StanceBarRight:Show();
			for i=1, NUM_STANCE_SLOTS do
				_G["StanceButton"..i]:GetNormalTexture():SetWidth(64);
				_G["StanceButton"..i]:GetNormalTexture():SetHeight(64);
			end
		end
	end

	-- HACK: we have too many bars in this game now...
	-- if the Stance bar is shown then hide the multi-cast bar
	-- we'll have to figure out what we should do in this case if it ever really becomes a problem
	-- HACK 2: if the possession bar is shown then hide the multi-cast bar
	-- yeah, way too many bars...
	if ( ( StanceBarFrame and StanceBarFrame:IsShown() ) or
		 ( PossessBarFrame and PossessBarFrame:IsShown() ) ) then
		HideMultiCastActionBar();
	elseif ( HasMultiCastActionBar and HasMultiCastActionBar() ) then
		ShowMultiCastActionBar();
	end

	-- If petactionbar is already shown, set its point in addition to changing its y target
	if ( PetActionBarFrame:IsShown() ) then
		PetActionBar_UpdatePositionValues();
		PetActionBarFrame:SetPoint("TOPLEFT", MainMenuBar, "BOTTOMLEFT", PETACTIONBAR_XPOS, PETACTIONBAR_YPOS);
	end

	-- Set battlefield minimap position
	if ( BattlefieldMinimapTab and not BattlefieldMinimapTab:IsUserPlaced() ) then
		BattlefieldMinimapTab:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMRIGHT", -225-CONTAINER_OFFSET_X, BATTLEFIELD_TAB_OFFSET_Y);
	end

	-- Setup y anchors
	local anchorY = 0
	local buffsAnchorY = min(0, MINIMAP_BOTTOM_EDGE_EXTENT - BuffFrame.bottomEdgeExtent);
	-- Count right action bars
	local rightActionBars = 0;
	if ( IsNormalActionBarState() ) then
		if ( SHOW_MULTI_ACTIONBAR_3 ) then
			rightActionBars = 1;
			if ( SHOW_MULTI_ACTIONBAR_4 ) then
				rightActionBars = 2;
			end
		end
	end
	
	-- Capture bars - need to move below buffs/debuffs if at least 1 right action bar is showing
	if ( NUM_EXTENDED_UI_FRAMES ) then
		local captureBar;
		local numCaptureBars = 0;
		for i=1, NUM_EXTENDED_UI_FRAMES do
			captureBar = _G["WorldStateCaptureBar"..i];
			if ( captureBar and captureBar:IsShown() ) then
				numCaptureBars = numCaptureBars + 1
				if ( numCaptureBars == 1 and rightActionBars > 0 ) then
					anchorY = min(anchorY, buffsAnchorY);
				end
				captureBar:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -CONTAINER_OFFSET_X, anchorY);
				anchorY = anchorY - captureBar:GetHeight() - 4;
			end
		end
	end
	
	--Setup Vehicle seat indicator offset - needs to move below buffs/debuffs if both right action bars are showing
	if ( VehicleSeatIndicator and VehicleSeatIndicator:IsShown() ) then
		if ( rightActionBars == 2 ) then
			anchorY = min(anchorY, buffsAnchorY);
			VehicleSeatIndicator:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -100, anchorY);
		elseif ( rightActionBars == 1 ) then
			VehicleSeatIndicator:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -62, anchorY);
		else
			VehicleSeatIndicator:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", 0, anchorY);
		end
		anchorY = anchorY - VehicleSeatIndicator:GetHeight() - 4;	--The -4 is there to give a small buffer for things like the QuestTimeFrame below the Seat Indicator
	end
	
	-- Boss frames - need to move below buffs/debuffs if both right action bars are showing
	local numBossFrames = 0;
	for i = 1, MAX_BOSS_FRAMES do
		if ( _G["Boss"..i.."TargetFrame"]:IsShown() ) then
			numBossFrames = i;
		end
	end
	if ( numBossFrames > 0 ) then
		if ( rightActionBars > 1 ) then
			anchorY = min(anchorY, buffsAnchorY);
		end
		Boss1TargetFrame:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -(CONTAINER_OFFSET_X * 1.3) + 60, anchorY * 1.333);	-- by 1.333 because it's 0.75 scale
		anchorY = anchorY - (numBossFrames * (68 + BOSS_FRAME_CASTBAR_HEIGHT) + BOSS_FRAME_CASTBAR_HEIGHT);
	end
	
	-- Setup durability offset
	if ( DurabilityFrame ) then
		DurabilityFrame:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -CONTAINER_OFFSET_X, anchorY);
		if ( DurabilityFrame:IsShown() ) then
			anchorY = anchorY - DurabilityFrame:GetHeight();
		end
	end
	
	if ( ArenaEnemyFrames ) then
		ArenaEnemyFrames:ClearAllPoints();
		ArenaEnemyFrames:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -CONTAINER_OFFSET_X, anchorY);
	end
	
	if ( ArenaPrepFrames ) then
		ArenaPrepFrames:ClearAllPoints();
		ArenaPrepFrames:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -CONTAINER_OFFSET_X, anchorY);
	end

	-- Watch frame - needs to move below buffs/debuffs if at least 1 right action bar is showing
	if ( rightActionBars > 0 ) then
		anchorY = min(anchorY, buffsAnchorY);
	end
	local numArenaOpponents = GetNumArenaOpponents();
	if ( not WatchFrame:IsUserPlaced() ) then
		if ( ArenaEnemyFrames and ArenaEnemyFrames:IsShown() and (numArenaOpponents > 0) ) then
			WatchFrame:ClearAllPoints();
			WatchFrame:SetPoint("TOPRIGHT", "ArenaEnemyFrame"..numArenaOpponents, "BOTTOMRIGHT", 2, -35);
		elseif ( ArenaPrepFrames and ArenaPrepFrames:IsShown() and (numArenaOpponents > 0) ) then
			WatchFrame:ClearAllPoints();
			WatchFrame:SetPoint("TOPRIGHT", "ArenaPrepFrame"..numArenaOpponents, "BOTTOMRIGHT", 2, -35);
		else
			-- We're using Simple Quest Tracking, automagically size and position!
			WatchFrame:ClearAllPoints();
			-- move up if only the minimap cluster is above, move down a little otherwise
			WatchFrame:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -CONTAINER_OFFSET_X, anchorY);
			-- OnSizeChanged for WatchFrame handles its redraw
		end
		WatchFrame:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -CONTAINER_OFFSET_X, CONTAINER_OFFSET_Y);
	end
	
	-- Update chat dock since the dock could have moved
	FCF_DockUpdate();
	UpdateContainerFrameAnchors();
end

-- Call this function to update the positions of all frames that can appear on the right side of the screen
function UIParent_ManageFramePositions()
	--Dispatch to secure code
	FramePositionDelegate:SetAttribute("uiparent-manage", true);
end

function ToggleFrame(frame)
	if ( frame:IsShown() ) then
		HideUIPanel(frame);
	else
		ShowUIPanel(frame);
	end
end

function ShowUIPanel(frame, force)	
	if ( not frame or frame:IsShown() ) then
		return;
	end
	if ( not GetUIPanelWindowInfo(frame, "area") ) then
		frame:Show();
		return;
	end
	
	-- Dispatch to secure code
	FramePositionDelegate:SetAttribute("panel-force", force);
	FramePositionDelegate:SetAttribute("panel-frame", frame);
	FramePositionDelegate:SetAttribute("panel-show", true);
end

function HideUIPanel(frame, skipSetPoint)
	if ( not frame or not frame:IsShown() ) then
		return;
	end
	
	if ( not GetUIPanelWindowInfo(frame, "area") ) then
		frame:Hide();
		return;
	end
	
	--Dispatch to secure code
	FramePositionDelegate:SetAttribute("panel-frame", frame);
	FramePositionDelegate:SetAttribute("panel-skipSetPoint", skipSetPoint);
	FramePositionDelegate:SetAttribute("panel-hide", true);
end

function HideParentPanel(self)	
	HideUIPanel(self:GetParent());
end

function GetUIPanel(key)
	return FramePositionDelegate:GetUIPanel(key);
end

function GetUIPanelWidth(frame)
	return GetUIPanelWindowInfo(frame, "width") or frame:GetWidth() + (GetUIPanelWindowInfo(frame, "extraWidth") or 0);
end

function GetUIPanelHeight(frame)
	return GetUIPanelWindowInfo(frame, "height") or frame:GetHeight() + (GetUIPanelWindowInfo(frame, "extraHeight") or 0);
end

--Allow a bit of overlap because there are built-in transparencies and buffers already
local MINIMAP_OVERLAP_ALLOWED = 60;

function GetMaxUIPanelsWidth()
--[[	local bufferBoundry = UIParent:GetRight() - UIParent:GetAttribute("RIGHT_OFFSET_BUFFER");
	if ( Minimap:IsShown() and not MinimapCluster:IsUserPlaced() ) then
		-- If the Minimap is in the default place, make sure you wont overlap it either
		return min(MinimapCluster:GetLeft()+MINIMAP_OVERLAP_ALLOWED, bufferBoundry);
	else
		-- If the minimap has been moved, make sure not to overlap the right side bars
		return bufferBoundry;
	end
]]
	return UIParent:GetRight() - UIParent:GetAttribute("RIGHT_OFFSET_BUFFER");
end

function ClampUIPanelY(frame, yOffset)
	local bottomPos = UIParent:GetTop() + yOffset - GetUIPanelHeight(frame);
	if (bottomPos < 140) then
		yOffset = yOffset + (140 - bottomPos);
	end	
	if (yOffset > -10) then
		yOffset = -10;
	end
	return yOffset;
end

function CanShowRightUIPanel(frame)
	local width;
	if ( frame ) then
		width = GetUIPanelWidth(frame);
	else
		width = UIParent:GetAttribute("DEFAULT_FRAME_WIDTH");
	end
	
	local rightSide = UIParent:GetAttribute("RIGHT_OFFSET") + width;
	if ( rightSide < GetMaxUIPanelsWidth() ) then
		return 1;
	end
end

function CanShowCenterUIPanel(frame)
	local width;
	if ( frame ) then
		width = GetUIPanelWidth(frame);
	else
		width = UIParent:GetAttribute("DEFAULT_FRAME_WIDTH");
	end
	
	local rightSide = UIParent:GetAttribute("CENTER_OFFSET") + width;
	if ( rightSide < GetMaxUIPanelsWidth() ) then
		return 1;
	end
end

function CanShowUIPanels(leftFrame, centerFrame, rightFrame)
	local offset = UIParent:GetAttribute("LEFT_OFFSET");

	if ( leftFrame ) then
		offset = offset + GetUIPanelWidth(leftFrame);
		if ( centerFrame ) then
			local area = GetUIPanelWindowInfo(centerFrame, "area");
			if ( area ~= "center" ) then
				offset = offset + ( GetUIPanelWindowInfo(centerFrame, "width") or UIParent:GetAttribute("DEFAULT_FRAME_WIDTH") );
			else
				offset = offset + GetUIPanelWidth(centerFrame);
			end
			if ( rightFrame ) then
				offset = offset + GetUIPanelWidth(rightFrame);
			end
		end
	elseif ( centerFrame ) then
		offset = GetUIPanelWidth(centerFrame);
	end
	
	if ( offset < GetMaxUIPanelsWidth() ) then
		return 1;
	end
end

function CanOpenPanels()
	--[[
	if ( UnitIsDead("player") ) then
		return nil;
	end
	
	Previously couldn't open frames if player was out of control i.e. feared
	if ( UnitIsDead("player") or UIParent.isOutOfControl ) then
		return nil;
	end
	]]

	local centerFrame = GetUIPanel("center");
	if ( not centerFrame ) then
		return 1;
	end

	local area = GetUIPanelWindowInfo(centerFrame, "area");
	local allowOtherPanels = GetUIPanelWindowInfo(centerFrame, "allowOtherPanels");
	if ( area and (area == "center") and not allowOtherPanels ) then
		return nil;
	end

	return 1;
end

-- this function handles possibly tainted values and so 
-- should always be called from secure code using securecall()
function CloseChildWindows()
	local childWindow;
	for index, value in pairs(UIChildWindows) do
		childWindow = _G[value];
		if ( childWindow ) then
			childWindow:Hide();
		end
	end
end

-- this function handles possibly tainted values and so 
-- should always be called from secure code using securecall()
function CloseSpecialWindows()
	local found;
	for index, value in pairs(UISpecialFrames) do
		local frame = _G[value];
		if ( frame and frame:IsShown() ) then
			frame:Hide();
			found = 1;
		end
	end
	return found;
end

function CloseWindows(ignoreCenter, frameToIgnore)
	-- This function will close all frames that are not the current frame
	local leftFrame = GetUIPanel("left");
	local centerFrame = GetUIPanel("center");
	local rightFrame = GetUIPanel("right");
	local doublewideFrame = GetUIPanel("doublewide");
	local fullScreenFrame = GetUIPanel("fullscreen");
	local found = leftFrame or centerFrame or rightFrame or doublewideFrame or fullScreenFrame;

	if ( not frameToIgnore or frameToIgnore ~= leftFrame ) then
		HideUIPanel(leftFrame, 1);
	end
	
	HideUIPanel(fullScreenFrame, 1);
	HideUIPanel(doublewideFrame, 1);
	
	if ( not frameToIgnore or frameToIgnore ~= centerFrame ) then
		if ( centerFrame ) then
			local area = GetUIPanelWindowInfo(centerFrame, "area");
			if ( area ~= "center" or not ignoreCenter ) then
				HideUIPanel(centerFrame, 1);
			end	
		end
	end
	
	if ( not frameToIgnore or frameToIgnore ~= rightFrame ) then
		if ( rightFrame ) then
			HideUIPanel(rightFrame, 1);
		end
	end

	found = securecall("CloseSpecialWindows") or found;
	
	UpdateUIPanelPositions();

	return found;
end

function CloseAllWindows_WithExceptions()
	-- Insert exceptions here, right now we just don't close the scoreFrame when the player loses control i.e. the game over spell effect
	if ( GetUIPanel("center") == WorldStateScoreFrame ) then
		CloseAllWindows(1);
	elseif ( IsOptionFrameOpen() ) then
		CloseAllWindows(1);
	else
		CloseAllWindows();
	end
end

function CloseAllWindows(ignoreCenter)
	local bagsVisible = nil;
	local windowsVisible = nil;
	for i=1, NUM_CONTAINER_FRAMES, 1 do
		local containerFrame = _G["ContainerFrame"..i];
		if ( containerFrame:IsShown() ) then
			containerFrame:Hide();
			bagsVisible = 1;
		end
	end
	windowsVisible = CloseWindows(ignoreCenter);
	return (bagsVisible or windowsVisible);
end

-- this function handles possibly tainted values and so 
-- should always be called from secure code using securecall()
function CloseMenus()
	local menusVisible = nil;
	local menu
	for index, value in pairs(UIMenus) do
		menu = _G[value];
		if ( menu and menu:IsShown() ) then
			menu:Hide();
			menusVisible = 1;
		end
	end
	return menusVisible;
end

function UpdateUIPanelPositions(currentFrame)
	FramePositionDelegate:SetAttribute("panel-frame", currentFrame)
	FramePositionDelegate:SetAttribute("panel-update", true);
end

function IsOptionFrameOpen()
	if ( GameMenuFrame:IsShown() or InterfaceOptionsFrame:IsShown() or (KeyBindingFrame and KeyBindingFrame:IsShown()) ) then
		return 1;
	else
		return nil;
	end
end

function LowerFrameLevel(frame)
	frame:SetFrameLevel(frame:GetFrameLevel()-1);
end

function RaiseFrameLevel(frame)
	frame:SetFrameLevel(frame:GetFrameLevel()+1);
end

function PassClickToParent(self, ...)
	self:GetParent():Click(...);
end

-- Function to reposition frames if they get dragged off screen
function ValidateFramePosition(frame, offscreenPadding, returnOffscreen)
	if ( not frame ) then
		return;
	end
	local left = frame:GetLeft();
	local right = frame:GetRight();
	local top = frame:GetTop();
	local bottom = frame:GetBottom();
	local newAnchorX, newAnchorY;
	if ( not offscreenPadding ) then
		offscreenPadding = 15;
	end
	if ( bottom < (0 + MainMenuBar:GetHeight() + offscreenPadding)) then
		-- Off the bottom of the screen
		newAnchorY = MainMenuBar:GetHeight() + frame:GetHeight() - GetScreenHeight(); 
	elseif ( top > GetScreenHeight() ) then
		-- Off the top of the screen
		newAnchorY =  0;
	end
	if ( left < 0 ) then
		-- Off the left of the screen
		newAnchorX = 0;
	elseif ( right > GetScreenWidth() ) then
		-- Off the right of the screen
		newAnchorX = GetScreenWidth() - frame:GetWidth();
	end
	if ( newAnchorX or newAnchorY ) then
		if ( returnOffscreen ) then
			return 1;
		else
			if ( not newAnchorX ) then
				newAnchorX = left;
			elseif ( not newAnchorY ) then
				newAnchorY = top - GetScreenHeight();
			end
			frame:ClearAllPoints();
			frame:SetPoint("TOPLEFT", nil, "TOPLEFT", newAnchorX, newAnchorY);
		end
		
		
	else
		if ( returnOffscreen ) then
			return nil;
		end
	end
end


-- Time --

function SecondsToTime(seconds, noSeconds, notAbbreviated, maxCount, roundUp)
	local time = "";
	local count = 0;
	local tempTime;
	seconds = roundUp and ceil(seconds) or floor(seconds);
	maxCount = maxCount or 2;
	if ( seconds >= 86400  ) then
		count = count + 1;
		if ( count == maxCount and roundUp ) then
			tempTime = ceil(seconds / 86400);
		else
			tempTime = floor(seconds / 86400);
		end
		if ( notAbbreviated ) then
			time = format(D_DAYS,tempTime);
		else
			time = format(DAYS_ABBR,tempTime);
		end
		seconds = mod(seconds, 86400);
	end
	if ( count < maxCount and seconds >= 3600  ) then
		count = count + 1;
		if ( time ~= "" ) then
			time = time..TIME_UNIT_DELIMITER;
		end
		if ( count == maxCount and roundUp ) then
			tempTime = ceil(seconds / 3600);
		else
			tempTime = floor(seconds / 3600);
		end
		if ( notAbbreviated ) then
			time = time..format(D_HOURS, tempTime);
		else
			time = time..format(HOURS_ABBR, tempTime);
		end
		seconds = mod(seconds, 3600);
	end
	if ( count < maxCount and seconds >= 60  ) then
		count = count + 1;
		if ( time ~= "" ) then
			time = time..TIME_UNIT_DELIMITER;
		end
		if ( count == maxCount and roundUp ) then
			tempTime = ceil(seconds / 60);
		else
			tempTime = floor(seconds / 60);
		end
		if ( notAbbreviated ) then
			time = time..format(D_MINUTES, tempTime);
		else
			time = time..format(MINUTES_ABBR, tempTime);
		end
		seconds = mod(seconds, 60);
	end
	if ( count < maxCount and seconds > 0 and not noSeconds ) then
		if ( time ~= "" ) then
			time = time..TIME_UNIT_DELIMITER;
		end
		seconds = format("%d", seconds);
		if ( notAbbreviated ) then
			time = time..format(D_SECONDS, seconds);
		else
			time = time..format(SECONDS_ABBR, seconds);
		end
	end
	return time;
end

function SecondsToTimeAbbrev(seconds)
	local tempTime;
	if ( seconds >= 86400  ) then
		tempTime = ceil(seconds / 86400);
		return DAY_ONELETTER_ABBR, tempTime;
	end
	if ( seconds >= 3600  ) then
		tempTime = ceil(seconds / 3600);
		return HOUR_ONELETTER_ABBR, tempTime;
	end
	if ( seconds >= 60  ) then
		tempTime = ceil(seconds / 60);
		return MINUTE_ONELETTER_ABBR, tempTime;
	end
	return SECOND_ONELETTER_ABBR, seconds;
end

function RecentTimeDate(year, month, day, hour)
	local lastOnline;
	if ( (year == 0) or (year == nil) ) then
		if ( (month == 0) or (month == nil) ) then
			if ( (day == 0) or (day == nil) ) then
				if ( (hour == 0) or (hour == nil) ) then
					lastOnline = LASTONLINE_MINS;
				else
					lastOnline = format(LASTONLINE_HOURS, hour);
				end
			else
				lastOnline = format(LASTONLINE_DAYS, day);
			end
		else
			lastOnline = format(LASTONLINE_MONTHS, month);
		end
	else
		lastOnline = format(LASTONLINE_YEARS, year);
	end
	return lastOnline;
end


-- Frame fading and flashing --

local frameFadeManager = CreateFrame("FRAME");

-- Generic fade function
function UIFrameFade(frame, fadeInfo)
	if (not frame) then
		return;
	end
	if ( not fadeInfo.mode ) then
		fadeInfo.mode = "IN";
	end
	local alpha;
	if ( fadeInfo.mode == "IN" ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 0;
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 1.0;
		end
		alpha = 0;
	elseif ( fadeInfo.mode == "OUT" ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 1.0;
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 0;
		end
		alpha = 1.0;
	end
	frame:SetAlpha(fadeInfo.startAlpha);

	frame.fadeInfo = fadeInfo;
	frame:Show();

	local index = 1;
	while FADEFRAMES[index] do
		-- If frame is already set to fade then return
		if ( FADEFRAMES[index] == frame ) then
			return;
		end
		index = index + 1;
	end
	tinsert(FADEFRAMES, frame);
	frameFadeManager:SetScript("OnUpdate", UIFrameFade_OnUpdate);
end

-- Convenience function to do a simple fade in
function UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = timeToFade;
	fadeInfo.startAlpha = startAlpha;
	fadeInfo.endAlpha = endAlpha;
	UIFrameFade(frame, fadeInfo);
end

-- Convenience function to do a simple fade out
function UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {};
	fadeInfo.mode = "OUT";
	fadeInfo.timeToFade = timeToFade;
	fadeInfo.startAlpha = startAlpha;
	fadeInfo.endAlpha = endAlpha;
	UIFrameFade(frame, fadeInfo);
end

function UIFrameFadeRemoveFrame(frame)
	tDeleteItem(FADEFRAMES, frame);
end

-- Function that actually performs the alpha change
--[[
Fading frame attribute listing
============================================================
frame.timeToFade  [Num]		Time it takes to fade the frame in or out
frame.mode  ["IN", "OUT"]	Fade mode
frame.finishedFunc [func()]	Function that is called when fading is finished
frame.finishedArg1 [ANYTHING]	Argument to the finishedFunc
frame.finishedArg2 [ANYTHING]	Argument to the finishedFunc
frame.finishedArg3 [ANYTHING]	Argument to the finishedFunc
frame.finishedArg4 [ANYTHING]	Argument to the finishedFunc
frame.fadeHoldTime [Num]	Time to hold the faded state
 ]]
 
function UIFrameFade_OnUpdate(self, elapsed)
	local index = 1;
	local frame, fadeInfo;
	while FADEFRAMES[index] do
		frame = FADEFRAMES[index];
		fadeInfo = FADEFRAMES[index].fadeInfo;
		-- Reset the timer if there isn't one, this is just an internal counter
		if ( not fadeInfo.fadeTimer ) then
			fadeInfo.fadeTimer = 0;
		end
		fadeInfo.fadeTimer = fadeInfo.fadeTimer + elapsed;

		-- If the fadeTimer is less then the desired fade time then set the alpha otherwise hold the fade state, call the finished function, or just finish the fade 
		if ( fadeInfo.fadeTimer < fadeInfo.timeToFade ) then
			if ( fadeInfo.mode == "IN" ) then
				frame:SetAlpha((fadeInfo.fadeTimer / fadeInfo.timeToFade) * (fadeInfo.endAlpha - fadeInfo.startAlpha) + fadeInfo.startAlpha);
			elseif ( fadeInfo.mode == "OUT" ) then
				frame:SetAlpha(((fadeInfo.timeToFade - fadeInfo.fadeTimer) / fadeInfo.timeToFade) * (fadeInfo.startAlpha - fadeInfo.endAlpha)  + fadeInfo.endAlpha);
			end
		else
			frame:SetAlpha(fadeInfo.endAlpha);
			-- If there is a fadeHoldTime then wait until its passed to continue on
			if ( fadeInfo.fadeHoldTime and fadeInfo.fadeHoldTime > 0  ) then
				fadeInfo.fadeHoldTime = fadeInfo.fadeHoldTime - elapsed;
			else
				-- Complete the fade and call the finished function if there is one
				UIFrameFadeRemoveFrame(frame);
				if ( fadeInfo.finishedFunc ) then
					fadeInfo.finishedFunc(fadeInfo.finishedArg1, fadeInfo.finishedArg2, fadeInfo.finishedArg3, fadeInfo.finishedArg4);
					fadeInfo.finishedFunc = nil;
				end
			end
		end
		
		index = index + 1;
	end
	
	if ( #FADEFRAMES == 0 ) then
		self:SetScript("OnUpdate", nil);
	end
end

function UIFrameIsFading(frame)
	for index, value in pairs(FADEFRAMES) do
		if ( value == frame ) then
			return 1;
		end
	end
	return nil;
end

local frameFlashManager = CreateFrame("FRAME");

local UIFrameFlashTimers = {};
local UIFrameFlashTimerRefCount = {};

-- Function to start a frame flashing
function UIFrameFlash(frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, syncId)
	if ( frame ) then
		local index = 1;
		-- If frame is already set to flash then return
		while FLASHFRAMES[index] do
			if ( FLASHFRAMES[index] == frame ) then
				return;
			end
			index = index + 1;
		end

		if (syncId) then
			frame.syncId = syncId;
			if (UIFrameFlashTimers[syncId] == nil) then
				UIFrameFlashTimers[syncId] = 0;
				UIFrameFlashTimerRefCount[syncId] = 0;
			end
			UIFrameFlashTimerRefCount[syncId] = UIFrameFlashTimerRefCount[syncId]+1;
		else
			frame.syncId = nil;
		end
		
		-- Time it takes to fade in a flashing frame
		frame.fadeInTime = fadeInTime;
		-- Time it takes to fade out a flashing frame
		frame.fadeOutTime = fadeOutTime;
		-- How long to keep the frame flashing
		frame.flashDuration = flashDuration;
		-- Show the flashing frame when the fadeOutTime has passed
		frame.showWhenDone = showWhenDone;
		-- Internal timer
		frame.flashTimer = 0;
		-- How long to hold the faded in state
		frame.flashInHoldTime = flashInHoldTime;
		-- How long to hold the faded out state
		frame.flashOutHoldTime = flashOutHoldTime;
		
		tinsert(FLASHFRAMES, frame);
		
		frameFlashManager:SetScript("OnUpdate", UIFrameFlash_OnUpdate);
	end
end

-- Called every frame to update flashing frames
function UIFrameFlash_OnUpdate(self, elapsed)
	local frame;
	local index = #FLASHFRAMES;
	
	-- Update timers for all synced frames
	for syncId, timer in pairs(UIFrameFlashTimers) do
		UIFrameFlashTimers[syncId] = timer + elapsed;
	end
	
	while FLASHFRAMES[index] do
		frame = FLASHFRAMES[index];
		frame.flashTimer = frame.flashTimer + elapsed;

		if ( (frame.flashTimer > frame.flashDuration) and frame.flashDuration ~= -1 ) then
			UIFrameFlashStop(frame);
		else
			local flashTime = frame.flashTimer;
			local alpha;
			
			if (frame.syncId) then
				flashTime = UIFrameFlashTimers[frame.syncId];
			end
			
			flashTime = flashTime%(frame.fadeInTime+frame.fadeOutTime+(frame.flashInHoldTime or 0)+(frame.flashOutHoldTime or 0));
			if (flashTime < frame.fadeInTime) then
				alpha = flashTime/frame.fadeInTime;
			elseif (flashTime < frame.fadeInTime+(frame.flashInHoldTime or 0)) then
				alpha = 1;
			elseif (flashTime < frame.fadeInTime+(frame.flashInHoldTime or 0)+frame.fadeOutTime) then
				alpha = 1 - ((flashTime - frame.fadeInTime - (frame.flashInHoldTime or 0))/frame.fadeOutTime);
			else
				alpha = 0;
			end
			
			frame:SetAlpha(alpha);
			frame:Show();
		end
		
		-- Loop in reverse so that removing frames is safe
		index = index - 1;
	end
	
	if ( #FLASHFRAMES == 0 ) then
		self:SetScript("OnUpdate", nil);
	end
end

-- Function to see if a frame is already flashing
function UIFrameIsFlashing(frame)
	for index, value in pairs(FLASHFRAMES) do
		if ( value == frame ) then
			return 1;
		end
	end
	return nil;
end

-- Function to stop flashing
function UIFrameFlashStop(frame)
	tDeleteItem(FLASHFRAMES, frame);
	frame:SetAlpha(1.0);
	frame.flashTimer = nil;
	if (frame.syncId) then
		UIFrameFlashTimerRefCount[frame.syncId] = UIFrameFlashTimerRefCount[frame.syncId]-1;
		if (UIFrameFlashTimerRefCount[frame.syncId] == 0) then
			UIFrameFlashTimers[frame.syncId] = nil;
			UIFrameFlashTimerRefCount[frame.syncId] = nil;
		end
		frame.syncId = nil;
	end
	if ( frame.showWhenDone ) then
		frame:Show();
	else
		frame:Hide();
	end
end

-- Functions to handle button pulsing (Highlight, Unhighlight)
function SetButtonPulse(button, duration, pulseRate)
	button.pulseDuration = pulseRate;
	button.pulseTimeLeft = duration
	-- pulseRate is actually seconds per pulse state
	button.pulseRate = pulseRate;
	button.pulseOn = 0;
	tinsert(PULSEBUTTONS, button);
end

-- Update the button pulsing
function ButtonPulse_OnUpdate(elapsed)
	for index, button in pairs(PULSEBUTTONS) do
		if ( button.pulseTimeLeft > 0 ) then
			if ( button.pulseDuration < 0 ) then
				if ( button.pulseOn == 1 ) then
					button:UnlockHighlight();
					button.pulseOn = 0;
				else
					button:LockHighlight();
					button.pulseOn = 1;
				end
				button.pulseDuration = button.pulseRate;
			end
			button.pulseDuration = button.pulseDuration - elapsed;
			button.pulseTimeLeft = button.pulseTimeLeft - elapsed;
		else
			button:UnlockHighlight();
			button.pulseOn = 0;
			tDeleteItem(PULSEBUTTONS, button);
		end
		
	end 
end

function ButtonPulse_StopPulse(button)
	for index, pulseButton in pairs(PULSEBUTTONS) do
		if ( pulseButton == button ) then
			tDeleteItem(PULSEBUTTONS, button);
		end
	end
end

function UIDoFramesIntersect(frame1, frame2)
	if ( ( frame1:GetLeft() < frame2:GetRight() ) and ( frame1:GetRight() > frame2:GetLeft() ) and
		( frame1:GetBottom() < frame2:GetTop() ) and ( frame1:GetTop() > frame2:GetBottom() ) ) then
		return true;
	else
		return false;
	end
end

-- Lua Helper functions --

function BuildListString(...)
	local text = ...;
	if ( not text ) then
		return nil;
	end
	local string = text;
	for i=2, select("#", ...) do
		text = select(i, ...);
		if ( text ) then
			string = string..", "..text;
		end
	end
	return string;
end

function BuildColoredListString(...)
	if ( select("#", ...) == 0 ) then
		return nil;
	end

	-- Takes input where odd items are the text and even items determine whether the arg should be colored or not
	local text, normal = ...;
	local string;
	if ( normal ) then
		string = text;
	else
		string = RED_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE;
	end
	for i=3, select("#", ...), 2 do
		text, normal = select(i, ...);
		if ( normal ) then
			-- If meets the condition
			string = string..", "..text;
		else
			-- If doesn't meet the condition
			string = string..", "..RED_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE;
		end
	end

	return string;
end

function BuildNewLineListString(...)
	local text;
	local index = 1;
	for i=1, select("#", ...) do
		text = select(i, ...);
		index = index + 1;
		if ( text ) then
			break;
		end
	end
	if ( not text ) then
		return nil;
	end
	local string = text;
	for i=index, select("#", ...) do
		text = select(i, ...);
		if ( text ) then
			string = string.."\n"..text;
		end
	end
	return string;
end

function BuildMultilineTooltip(globalStringName, tooltip, r, g, b)
	if ( not tooltip ) then
		tooltip = GameTooltip;
	end
	if ( not r ) then
		r = 1.0;
		g = 1.0;
		b = 1.0;
	end
	local i = 1;
	local string = _G[globalStringName..i];
	while (string) do
		tooltip:AddLine(string, "", r, g, b);
		i = i + 1;
		string = _G[globalStringName..i];
	end
end

function tDeleteItem(table, item)
	local index = 1;
	while table[index] do
		if ( item == table[index] ) then
			tremove(table, index);
		else
			index = index + 1;
		end
	end
end

function tContains(table, item)
	local index = 1;
	while table[index] do
		if ( item == table[index] ) then
			return 1;
		end
		index = index + 1;
	end
	return nil;
end

function CopyTable(settings)
	local copy = {};
	for k, v in pairs(settings) do
		if ( type(v) == "table" ) then
			copy[k] = CopyTable(v);
		else
			copy[k] = v;
		end
	end
	return copy;
end

function MouseIsOver(region, topOffset, bottomOffset, leftOffset, rightOffset)
	return region:IsMouseOver(topOffset, bottomOffset, leftOffset, rightOffset);
end

-- replace the C functions with local lua versions
function getglobal(varr)
	return _G[varr];
end

function setglobal(varr,value)
	_G[varr] = value;
end

-- Wrapper for the desaturation function
function SetDesaturation(texture, desaturation)
	texture:SetDesaturated(desaturation);
end

function GetMaterialTextColors(material)
	local textColor = MATERIAL_TEXT_COLOR_TABLE[material];
	local titleColor = MATERIAL_TITLETEXT_COLOR_TABLE[material];
	if ( not(textColor and titleColor) ) then
		textColor = MATERIAL_TEXT_COLOR_TABLE["Default"];
		titleColor = MATERIAL_TITLETEXT_COLOR_TABLE["Default"];
	end
	return textColor, titleColor;
end

-- Function that handles the escape key functions
function ToggleGameMenu()
	if ( not UIParent:IsShown() ) then
		UIParent:Show();
		SetUIVisibility(true);
	elseif ( securecall("StaticPopup_EscapePressed") ) then
	elseif ( GameMenuFrame:IsShown() ) then
		PlaySound("igMainMenuQuit");
		HideUIPanel(GameMenuFrame);
	elseif ( HelpFrame:IsShown() ) then
		ToggleHelpFrame();
	elseif ( VideoOptionsFrame:IsShown() ) then
		VideoOptionsFrameCancel:Click();
	elseif ( AudioOptionsFrame:IsShown() ) then
		AudioOptionsFrameCancel:Click();
	elseif ( InterfaceOptionsFrame:IsShown() ) then
		InterfaceOptionsFrameCancel:Click();
	elseif ( TimeManagerFrame and TimeManagerFrame:IsShown() ) then
		TimeManagerFrameCloseButton:Click();
	elseif ( MultiCastFlyoutFrame:IsShown() ) then
		MultiCastFlyoutFrame_Hide(MultiCastFlyoutFrame, true);
	elseif (SpellFlyout:IsShown() ) then
		SpellFlyout:Hide();
	elseif ( securecall("FCFDockOverflow_CloseLists") ) then
	elseif ( securecall("CloseMenus") ) then
	elseif ( CloseCalendarMenus and securecall("CloseCalendarMenus") ) then
	elseif ( CloseGuildMenus and securecall("CloseGuildMenus") ) then
	elseif ( SpellStopCasting() ) then
	elseif ( SpellStopTargeting() ) then
	elseif ( securecall("CloseAllWindows") ) then
	elseif ( LootFrame:IsShown() ) then
		-- if we're here, LootFrame was opened under the mouse (cvar "lootUnderMouse") so it didn't get closed by CloseAllWindows
		LootFrame:Hide();
	elseif ( ClearTarget() and (not UnitIsCharmed("player")) ) then
	elseif ( OpacityFrame:IsShown() ) then
		OpacityFrame:Hide();
	else
		PlaySound("igMainMenuOpen");
		ShowUIPanel(GameMenuFrame);
	end
end

-- Visual Misc --

function GetScreenHeightScale()
	local screenHeight = 768;
	return GetScreenHeight()/screenHeight;
end

function GetScreenWidthScale()
	local screenWidth = 1024;
	return GetScreenWidth()/screenWidth;
end

function ShowInspectCursor()
	SetCursor("INSPECT_CURSOR");
end

-- Helper function to show the inspect cursor if the ctrl key is down
function CursorUpdate(self)
	if ( IsModifiedClick("DRESSUP") and self.hasItem ) then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function CursorOnUpdate(self)
	if ( GameTooltip:IsOwned(self) ) then
		CursorUpdate(self);
	end
end

function AnimateTexCoords(texture, textureWidth, textureHeight, frameWidth, frameHeight, numFrames, elapsed, throttle)
	if ( not texture.frame ) then
		-- initialize everything
		texture.frame = 1;
		texture.throttle = throttle;
		texture.numColumns = floor(textureWidth/frameWidth);
		texture.numRows = floor(textureHeight/frameHeight);
		texture.columnWidth = frameWidth/textureWidth;
		texture.rowHeight = frameHeight/textureHeight;
	end
	local frame = texture.frame;
	if ( not texture.throttle or texture.throttle > throttle ) then
		local framesToAdvance = floor(texture.throttle / throttle);
		while ( frame + framesToAdvance > numFrames ) do
			frame = frame - numFrames;
		end
		frame = frame + framesToAdvance;
		texture.throttle = 0;
		local left = mod(frame-1, texture.numColumns)*texture.columnWidth;
		local right = left + texture.columnWidth;
		local bottom = ceil(frame/texture.numColumns)*texture.rowHeight;
		local top = bottom - texture.rowHeight;
		texture:SetTexCoord(left, right, top, bottom);

		texture.frame = frame;
	else
		texture.throttle = texture.throttle + elapsed;
	end
end


-- Bindings --

function GetBindingText(name, prefix, returnAbbr)
	if ( not name ) then
		return "";
	end
	local tempName = name;
	local i = strfind(name, "-");
	local dashIndex = nil;
	local count = 0;
	while ( i ) do
		if ( not dashIndex ) then
			dashIndex = i;
		else
			if ( i == 1 ) then
				-- this means two "-" in a row, so it's "-" in combination with a modifier key
				count = count - 1;
			end
			dashIndex = dashIndex + i;
		end
		count = count + 1;
		tempName = strsub(tempName, i + 1);
		i = strfind(tempName, "-");
	end

	local modKeys = '';
	if ( not dashIndex ) then
		dashIndex = 0;
	else
		modKeys = strsub(name, 1, dashIndex);

		if ( tempName == "CAPSLOCK" ) then
			gsub(tempName, "CAPSLOCK", "Caps");
		end
		
		-- replace for all languages
		-- for the "push-to-talk" binding
		modKeys = gsub(modKeys, "LSHIFT", LSHIFT_KEY_TEXT);
		modKeys = gsub(modKeys, "RSHIFT", RSHIFT_KEY_TEXT);
		modKeys = gsub(modKeys, "LCTRL", LCTRL_KEY_TEXT);
		modKeys = gsub(modKeys, "RCTRL", RCTRL_KEY_TEXT);
		modKeys = gsub(modKeys, "LALT", LALT_KEY_TEXT);
		modKeys = gsub(modKeys, "RALT", RALT_KEY_TEXT);
		
		-- use the SHIFT code if they decide to localize the CTRL further. The token is CTRL_KEY_TEXT
		if ( GetLocale() == "deDE") then
			modKeys = gsub(modKeys, "CTRL", "STRG");
		end
		-- Only doing French for now since all the other languages use SHIFT, remove the "if" if other languages localize it
		if ( GetLocale() == "frFR" ) then
			modKeys = gsub(modKeys, "SHIFT", SHIFT_KEY_TEXT);
		end
	end

	if ( returnAbbr ) then
		if ( count > 1 ) then
			return "·";
		else 
			modKeys = gsub(modKeys, "CTRL", "c");
			modKeys = gsub(modKeys, "SHIFT", "s");
			modKeys = gsub(modKeys, "ALT", "a");
			modKeys = gsub(modKeys, "STRG", "st");
		end
	end

	if ( not prefix ) then
		prefix = "";
	end

	-- fix for bug 103620: mouse buttons are not being translated properly
	if ( tempName == "LeftButton" ) then
		tempName = "BUTTON1";
	elseif ( tempName == "RightButton" ) then
		tempName = "BUTTON2";
	elseif ( tempName == "MiddleButton" ) then
		tempName = "BUTTON3";
	elseif ( tempName == "Button4" ) then
		tempName = "BUTTON4";
	elseif ( tempName == "Button5" ) then
		tempName = "BUTTON5";
	elseif ( tempName == "Button6" ) then
		tempName = "BUTTON6";
	elseif ( tempName == "Button7" ) then
		tempName = "BUTTON7";
	elseif ( tempName == "Button8" ) then
		tempName = "BUTTON8";
	elseif ( tempName == "Button9" ) then
		tempName = "BUTTON9";
	elseif ( tempName == "Button10" ) then
		tempName = "BUTTON10";
	elseif ( tempName == "Button11" ) then
		tempName = "BUTTON11";
	elseif ( tempName == "Button12" ) then
		tempName = "BUTTON12";
	elseif ( tempName == "Button13" ) then
		tempName = "BUTTON13";
	elseif ( tempName == "Button14" ) then
		tempName = "BUTTON14";
	elseif ( tempName == "Button15" ) then
		tempName = "BUTTON15";
	elseif ( tempName == "Button16" ) then
		tempName = "BUTTON16";
	elseif ( tempName == "Button17" ) then
		tempName = "BUTTON17";
	elseif ( tempName == "Button18" ) then
		tempName = "BUTTON18";
	elseif ( tempName == "Button19" ) then
		tempName = "BUTTON19";
	elseif ( tempName == "Button20" ) then
		tempName = "BUTTON20";
	elseif ( tempName == "Button21" ) then
		tempName = "BUTTON21";
	elseif ( tempName == "Button22" ) then
		tempName = "BUTTON22";
	elseif ( tempName == "Button23" ) then
		tempName = "BUTTON23";
	elseif ( tempName == "Button24" ) then
		tempName = "BUTTON24";
	elseif ( tempName == "Button25" ) then
		tempName = "BUTTON25";
	elseif ( tempName == "Button26" ) then
		tempName = "BUTTON26";
	elseif ( tempName == "Button27" ) then
		tempName = "BUTTON27";
	elseif ( tempName == "Button28" ) then
		tempName = "BUTTON28";
	elseif ( tempName == "Button29" ) then
		tempName = "BUTTON29";
	elseif ( tempName == "Button30" ) then
		tempName = "BUTTON30";
	elseif ( tempName == "Button31" ) then
		tempName = "BUTTON31";
	end

	local localizedName = nil;
	if ( IsMacClient() ) then
		-- see if there is a mac specific name for the key
		localizedName = _G[prefix..tempName.."_MAC"];
	end
	if ( not localizedName ) then
		localizedName = _G[prefix..tempName];
	end
	-- for the "push-to-talk" binding it can be just a modifier key
	if ( not localizedName ) then
		localizedName = _G[tempName.."_KEY_TEXT"];
	end
	if ( not localizedName ) then
		localizedName = tempName;
	end
	return modKeys..localizedName;
end


function GetBindingFromClick(input)
	local fullInput = "";

	-- MUST BE IN THIS ORDER (ALT, CTRL, SHIFT)
	if ( IsAltKeyDown() ) then
		fullInput = fullInput.."ALT-";
	end

	if ( IsControlKeyDown() ) then
		fullInput = fullInput.."CTRL-"
	end

	if ( IsShiftKeyDown() ) then
		fullInput = fullInput.."SHIFT-"
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
	if ( not IsInRaid() and GetNumGroupMembers() > MAX_PARTY_MEMBERS) then
		local dialog = StaticPopup_Show("CONVERT_TO_RAID");
		if ( dialog ) then
			dialog.data = name;
		end
	else
		InviteUnit(name);
	end
end

function UnitHasMana(unit)
	if ( UnitPowerMax(unit, SPELL_POWER_MANA) > 0 ) then
		return 1;
	end
	return nil;
end

function RaiseFrameLevelByTwo(frame)
	-- We do this enough that it saves closures.
	frame:SetFrameLevel(frame:GetFrameLevel()+2);
end

function ShowResurrectRequest(offerer)
	if ( ResurrectHasSickness() ) then
		StaticPopup_Show("RESURRECT", offerer);
	elseif ( ResurrectHasTimer() ) then
		StaticPopup_Show("RESURRECT_NO_SICKNESS", offerer);
	else
		StaticPopup_Show("RESURRECT_NO_TIMER", offerer);
	end
end

function RefreshAuras(frame, unit, numAuras, suffix, checkCVar, showBuffs)
	if ( showBuffs ) then
		RefreshBuffs(frame, unit, numAuras, suffix, checkCVar);
	else
		RefreshDebuffs(frame, unit, numAuras, suffix, checkCVar);
	end
end

function RefreshBuffs(frame, unit, numBuffs, suffix, checkCVar)
	local frameName = frame:GetName();

	frame.hasDispellable = nil;

	numBuffs = numBuffs or MAX_PARTY_BUFFS;
	suffix = suffix or "Buff";

	local unitStatus, statusColor;
	local debuffTotal = 0;
	local name, rank, icon, count, debuffType, duration, expirationTime;
	
	local filter;
	if ( checkCVar and SHOW_CASTABLE_BUFFS == "1" and UnitCanAssist("player", unit) ) then
		filter = "RAID";
	end
	
	for i=1, numBuffs do
		name, rank, icon, count, debuffType, duration, expirationTime = UnitBuff(unit, i, filter);

		local buffName = frameName..suffix..i;
		if ( icon ) then
			-- if we have an icon to show then proceed with setting up the aura

			-- set the icon
			local buffIcon = _G[buffName.."Icon"];
			buffIcon:SetTexture(icon);

			-- setup the cooldown
			local coolDown = _G[buffName.."Cooldown"];
			if ( coolDown ) then
				CooldownFrame_SetTimer(coolDown, expirationTime - duration, duration, 1);
			end

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
	local name, rank, icon, count, debuffType, duration, expirationTime, caster;
	local isEnemy = UnitCanAttack("player", unit);	
	
	local filter;
	if ( checkCVar and SHOW_DISPELLABLE_DEBUFFS == "1" and UnitCanAssist("player", unit) ) then
		filter = "RAID";
	end
		
	for i=1, numDebuffs do
		if ( unit == "party"..i ) then
			unitStatus = _G[frameName.."Status"];
		end

		name, rank, icon, count, debuffType, duration, expirationTime, caster = UnitDebuff(unit, i, filter);

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
				CooldownFrame_SetTimer(coolDown, expirationTime - duration, duration, 1);
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

function GetQuestDifficultyColor(level)
	return GetRelativeDifficultyColor(UnitLevel("player"), level);
end

--How difficult is this challenge for this unit?
function GetRelativeDifficultyColor(unitLevel, challengeLevel)
	local levelDiff = challengeLevel - unitLevel;
	local color;
	if ( levelDiff >= 5 ) then
		return QuestDifficultyColors["impossible"];
	elseif ( levelDiff >= 3 ) then
		return QuestDifficultyColors["verydifficult"];
	elseif ( levelDiff >= -2 ) then
		return QuestDifficultyColors["difficult"];
	elseif ( -levelDiff <= GetQuestGreenRange() ) then
		return QuestDifficultyColors["standard"];
	else
		return QuestDifficultyColors["trivial"];
	end
end

-- takes in a table with r, g, and b entries and converts it to a color string
function ConvertRGBtoColorString(color)
	local colorString = "|cff";
	local r = color.r * 255;
	local g = color.g * 255;
	local b = color.b * 255;
	colorString = colorString..string.format("%2x%2x%2x", r, g, b);
	return colorString;
end

function GetDungeonNameWithDifficulty(name, difficultyName)
	name = name or "";
	if ( difficultyName == "" ) then
		name = NORMAL_FONT_COLOR_CODE..name..FONT_COLOR_CODE_CLOSE;
	else
		name = NORMAL_FONT_COLOR_CODE..format(DUNGEON_NAME_WITH_DIFFICULTY, name, difficultyName)..FONT_COLOR_CODE_CLOSE;
	end
	return name;
end


-- Animated shine stuff --

function AnimatedShine_Start(shine, r, g, b)
	if ( not tContains(SHINES_TO_ANIMATE, shine) ) then
		shine.timer = 0;
		tinsert(SHINES_TO_ANIMATE, shine);
	end
	local shineName = shine:GetName();
	_G[shineName.."Shine1"]:Show();
	_G[shineName.."Shine2"]:Show();
	_G[shineName.."Shine3"]:Show();
	_G[shineName.."Shine4"]:Show();
	if ( r ) then
		_G[shineName.."Shine1"]:SetVertexColor(r, g, b);
		_G[shineName.."Shine2"]:SetVertexColor(r, g, b);
		_G[shineName.."Shine3"]:SetVertexColor(r, g, b);
		_G[shineName.."Shine4"]:SetVertexColor(r, g, b);
	end
	
end

function AnimatedShine_Stop(shine)
	tDeleteItem(SHINES_TO_ANIMATE, shine);
	local shineName = shine:GetName();
	_G[shineName.."Shine1"]:Hide();
	_G[shineName.."Shine2"]:Hide();
	_G[shineName.."Shine3"]:Hide();
	_G[shineName.."Shine4"]:Hide();
end

function AnimatedShine_OnUpdate(elapsed)
	local shine1, shine2, shine3, shine4;
	local speed = 2.5;
	local parent, distance;
	for index, value in pairs(SHINES_TO_ANIMATE) do
		shine1 = _G[value:GetName().."Shine1"];
		shine2 = _G[value:GetName().."Shine2"];
		shine3 = _G[value:GetName().."Shine3"];
		shine4 = _G[value:GetName().."Shine4"];
		value.timer = value.timer+elapsed;
		if ( value.timer > speed*4 ) then
			value.timer = 0;
		end
		parent = _G[value:GetName().."Shine"];
		distance = parent:GetWidth();
		if ( value.timer <= speed  ) then
			shine1:SetPoint("CENTER", parent, "TOPLEFT", value.timer/speed*distance, 0);
			shine2:SetPoint("CENTER", parent, "BOTTOMRIGHT", -value.timer/speed*distance, 0);
			shine3:SetPoint("CENTER", parent, "TOPRIGHT", 0, -value.timer/speed*distance);
			shine4:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, value.timer/speed*distance);
		elseif ( value.timer <= speed*2 ) then
			shine1:SetPoint("CENTER", parent, "TOPRIGHT", 0, -(value.timer-speed)/speed*distance);
			shine2:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, (value.timer-speed)/speed*distance);
			shine3:SetPoint("CENTER", parent, "BOTTOMRIGHT", -(value.timer-speed)/speed*distance, 0);
			shine4:SetPoint("CENTER", parent, "TOPLEFT", (value.timer-speed)/speed*distance, 0);
		elseif ( value.timer <= speed*3 ) then
			shine1:SetPoint("CENTER", parent, "BOTTOMRIGHT", -(value.timer-speed*2)/speed*distance, 0);
			shine2:SetPoint("CENTER", parent, "TOPLEFT", (value.timer-speed*2)/speed*distance, 0);
			shine3:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, (value.timer-speed*2)/speed*distance);
			shine4:SetPoint("CENTER", parent, "TOPRIGHT", 0, -(value.timer-speed*2)/speed*distance);
		else
			shine1:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, (value.timer-speed*3)/speed*distance);
			shine2:SetPoint("CENTER", parent, "TOPRIGHT", 0, -(value.timer-speed*3)/speed*distance);
			shine3:SetPoint("CENTER", parent, "TOPLEFT", (value.timer-speed*3)/speed*distance, 0);
			shine4:SetPoint("CENTER", parent, "BOTTOMRIGHT", -(value.timer-speed*3)/speed*distance, 0);
		end		
	end
end


-- Autocast shine stuff --

AUTOCAST_SHINE_R = .95;
AUTOCAST_SHINE_G = .95;
AUTOCAST_SHINE_B = .32;

AUTOCAST_SHINE_SPEEDS = { 2, 4, 6, 8 };
AUTOCAST_SHINE_TIMERS = { 0, 0, 0, 0 };

local AUTOCAST_SHINES = {};


function AutoCastShine_OnLoad(self)
	self.sparkles = {};
	
	local name = self:GetName();
	
	for i = 1, 16 do
		tinsert(self.sparkles, _G[name .. i]);
	end
end

function AutoCastShine_AutoCastStart(button, r, g, b)
	if ( AUTOCAST_SHINES[button] ) then
		return;
	end
	
	AUTOCAST_SHINES[button] = true;
	
	if ( not r ) then
		r, g, b = AUTOCAST_SHINE_R, AUTOCAST_SHINE_G, AUTOCAST_SHINE_B;
	end
	
	for _, sparkle in next, button.sparkles do
		sparkle:Show();
		sparkle:SetVertexColor(r, g, b);
	end
end

function AutoCastShine_AutoCastStop(button)
	AUTOCAST_SHINES[button] = nil;
	
	for _, sparkle in next, button.sparkles do
		sparkle:Hide();
	end
end

function AutoCastShine_OnUpdate(self, elapsed)	
	for i in next, AUTOCAST_SHINE_TIMERS do
		AUTOCAST_SHINE_TIMERS[i] = AUTOCAST_SHINE_TIMERS[i] + elapsed;
		if ( AUTOCAST_SHINE_TIMERS[i] > AUTOCAST_SHINE_SPEEDS[i]*4 ) then
			AUTOCAST_SHINE_TIMERS[i] = 0;
		end
	end
	
	for button in next, AUTOCAST_SHINES do
		self = button;
		local parent, distance = self, self:GetWidth();
		
		-- This is local to this function to save a lookup. If you need to use it elsewhere, might wanna make it global and use a local reference.
		local AUTOCAST_SHINE_SPACING = 6;	
			
		for i = 1, 4 do
			local timer = AUTOCAST_SHINE_TIMERS[i];
			local speed = AUTOCAST_SHINE_SPEEDS[i];
			
			if ( timer <= speed ) then
				local basePosition = timer/speed*distance;
				self.sparkles[0+i]:SetPoint("CENTER", parent, "TOPLEFT", basePosition, 0);
				self.sparkles[4+i]:SetPoint("CENTER", parent, "BOTTOMRIGHT", -basePosition, 0);
				self.sparkles[8+i]:SetPoint("CENTER", parent, "TOPRIGHT", 0, -basePosition);
				self.sparkles[12+i]:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, basePosition);
			elseif ( timer <= speed*2 ) then
				local basePosition = (timer-speed)/speed*distance;
				self.sparkles[0+i]:SetPoint("CENTER", parent, "TOPRIGHT", 0, -basePosition);
				self.sparkles[4+i]:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, basePosition);
				self.sparkles[8+i]:SetPoint("CENTER", parent, "BOTTOMRIGHT", -basePosition, 0);
				self.sparkles[12+i]:SetPoint("CENTER", parent, "TOPLEFT", basePosition, 0);	
			elseif ( timer <= speed*3 ) then
				local basePosition = (timer-speed*2)/speed*distance;
				self.sparkles[0+i]:SetPoint("CENTER", parent, "BOTTOMRIGHT", -basePosition, 0);
				self.sparkles[4+i]:SetPoint("CENTER", parent, "TOPLEFT", basePosition, 0);
				self.sparkles[8+i]:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, basePosition);
				self.sparkles[12+i]:SetPoint("CENTER", parent, "TOPRIGHT", 0, -basePosition);	
			else
				local basePosition = (timer-speed*3)/speed*distance;
				self.sparkles[0+i]:SetPoint("CENTER", parent, "BOTTOMLEFT", 0, basePosition);
				self.sparkles[4+i]:SetPoint("CENTER", parent, "TOPRIGHT", 0, -basePosition);
				self.sparkles[8+i]:SetPoint("CENTER", parent, "TOPLEFT", basePosition, 0);
				self.sparkles[12+i]:SetPoint("CENTER", parent, "BOTTOMRIGHT", -basePosition, 0);
			end
		end	
	end
end

function ConsolePrint(...)
	ConsoleAddMessage(strjoin(" ", tostringall(...)));
end

function GetTexCoordsByGrid(xOffset, yOffset, textureWidth, textureHeight, gridWidth, gridHeight)
	local widthPerGrid = gridWidth/textureWidth;
	local heightPerGrid = gridHeight/textureHeight;
	return (xOffset-1)*widthPerGrid, (xOffset)*widthPerGrid, (yOffset-1)*heightPerGrid, (yOffset)*heightPerGrid;
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

	--In DF groups, anyone may queue/dequeue. In RF groups, the leader or assistants may queue/dequeue.
	if ( HasLFGRestrictions() and (not IsInRaid() or UnitIsGroupAssistant("player")) ) then
		return true;
	end

	return false;
end

function RaidBrowser_IsEmpowered()
	return (not IsInGroup()) or UnitIsGroupLeader("player");
end

function GetLFGMode(category)
	local proposalExists, id, typeID, subtypeID, name, texture, role, hasResponded, totalEncounters, completedEncounters, numMembers, isLeader, isHoliday, proposalCategory = GetLFGProposal();
	local inParty, joined, queued, noPartialClear, achievements, lfgComment, slotCount = GetLFGInfoServer(category);
	local roleCheckInProgress, slots, members, roleUpdateCategory = GetLFGRoleUpdate();

	local partyCategory = nil;
	local partySlot = GetPartyLFGID();
	if ( partySlot ) then
		partyCategory = GetLFGCategoryForID(partySlot);
	end

	
	local empoweredFunc = LFD_IsEmpowered;
	if ( category == LE_LFG_CATEGORY_LFR ) then
		empoweredFunc = RaidBrowser_IsEmpowered;
	end
	if ( proposalExists and not hasResponded and proposalCategory == category ) then
		return "proposal", "unaccepted";
	elseif ( proposalExists and proposalCategory == category ) then
		return "proposal", "accepted";
	elseif ( queued ) then
		return "queued", (empoweredFunc() and "empowered" or "unempowered");
	elseif ( roleCheckInProgress and roleUpdateCategory == category ) then
		return "rolecheck";
	elseif ( category == LE_LFG_CATEGORY_LFR and joined ) then
		return "listed", (empoweredFunc() and "empowered" or "unempowered");
	elseif ( joined ) then
		return "suspended", (empoweredFunc() and "empowered" or "unempowered");	--We are "joined" to LFG, but not actually queued right now.
	elseif ( IsInGroup() and IsPartyLFG() and partyCategory == category ) then
		return "lfgparty";
	elseif ( IsPartyLFG() and IsInLFGDungeon() and partyCategory == category ) then
		return "abandonedInDungeon";
	end
end

function IsLFGModeActive(category)
	local partySlot = GetPartyLFGID();
	local partyCategory = nil;
	if ( partySlot ) then
		partyCategory = GetLFGCategoryForID(partySlot);
	end

	if ( partyCategory == category ) then
		return true;
	end
	return false;
end

--Like date(), but localizes AM/PM. In the future, could also localize other stuff.
function BetterDate(formatString, timeVal)
	local dateTable = date("*t", timeVal);
	local amString = (dateTable.hour >= 12) and TIMEMANAGER_PM or TIMEMANAGER_AM;
	
	--First, we'll replace %p with the appropriate AM or PM.
	formatString = gsub(formatString, "^%%p", amString)	--Replaces %p at the beginning of the string with the am/pm token
	formatString = gsub(formatString, "([^%%])%%p", "%1"..amString); -- Replaces %p anywhere else in the string, but doesn't replace %%p (since the first % escapes the second)
	
	return date(formatString, timeVal);
end

function GMError(...)
	if ( IsGMClient() ) then
		error(...);
	end
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

function ReverseQuestObjective(text, objectiveType)
	if ( objectiveType == "spell" ) then
		return text;
	end
	local _, _, arg1, arg2 = string.find(text, "(.*):%s(.*)");
	if ( arg1 and arg2 ) then
		return arg2.." "..arg1;
	else
		return text;
	end
end

local displayedCapMessage = false;
function TrialAccountCapReached_Inform(capType)
	if ( displayedCapMessage or not IsTrialAccount() ) then
		return;
	end
	
	
	local info = ChatTypeInfo.SYSTEM;
	if ( capType == "level" ) then
		DEFAULT_CHAT_FRAME:AddMessage(TRIAL_ACCOUNT_LEVEL_CAP_REACHED, info.r, info.g, info.b);
	elseif ( capType == "money" ) then
		DEFAULT_CHAT_FRAME:AddMessage(TRIAL_ACCOUNT_MONEY_CAP_REACHED, info.r, info.g, info.b);
	end
	displayedCapMessage = true;
end

function AbbreviateLargeNumbers(value)
	local strLen = strlen(value);
	local retString = value;
	if ( strLen > 8 ) then
		retString = string.sub(value, 1, -7)..SECOND_NUMBER_CAP;
	elseif ( strLen > 5 ) then
		retString = string.sub(value, 1, -4)..FIRST_NUMBER_CAP;
	elseif (strLen > 3 ) then
		retString = BreakUpLargeNumbers(value);
	end
	return retString;
end

function BreakUpLargeNumbers(value)
	local retString = "";
	if ( value < 1000 ) then
		if ( (value - math.floor(value)) == 0) then
			return value;
		end
		local decimal = (math.floor(value*100));
		retString = string.sub(decimal, 1, -3);
		retString = retString..DECIMAL_SEPERATOR;
		retString = retString..string.sub(decimal, -2);
		return retString;
	end

	value = math.floor(value);
	local strLen = strlen(value);
	if ( GetCVarBool("breakUpLargeNumbers") ) then
		if ( strLen > 6 ) then
			retString = string.sub(value, 1, -7)..LARGE_NUMBER_SEPERATOR;
		end
		if ( strLen > 3 ) then
			retString = retString..string.sub(value, -6, -4)..LARGE_NUMBER_SEPERATOR;
		end
		retString = retString..string.sub(value, -3, -1);
	else
		retString = value;
	end
	return retString;
end

function GetTimeStringFromSeconds(timeAmount, hasMS)
	local seconds, ms;
	-- milliseconds
	if ( hasMS ) then
		seconds = floor(timeAmount / 1000);
		ms = timeAmount - seconds * 1000;
	else
		seconds = timeAmount;
	end

	local hours = floor(seconds / 3600);
	local minutes = floor((seconds / 60) - (hours * 60));
	seconds = seconds - hours * 3600 - minutes * 60;
--	if ( hasMS ) then
--		return format(HOURS_MINUTES_SECONDS_MILLISECONDS, hours, minutes, seconds, ms);
--	else
		return format(HOURS_MINUTES_SECONDS, hours, minutes, seconds);
--	end
end

function ConfirmOrLeaveLFGParty()
	if ( not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
		return;
	end

	if ( IsPartyLFG() and not IsLFGComplete() ) then
		StaticPopup_Show("CONFIRM_LEAVE_INSTANCE_PARTY");
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
