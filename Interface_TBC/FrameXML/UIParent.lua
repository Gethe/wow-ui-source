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
MAX_CHARACTER_MACROS = 18;

-- UIPanel Management constants
UIPANEL_SKIP_SET_POINT = true;
UIPANEL_DO_SET_POINT = nil;
UIPANEL_VALIDATE_CURRENT_FRAME = true;

-- Per panel settings
UIPanelWindows = {};

--Center Menu Frames
UIPanelWindows["GameMenuFrame"] =				{ area = "center",		pushable = 0,	whileDead = 1 };
UIPanelWindows["VideoOptionsFrame"] =			{ area = "center",		pushable = 0,	whileDead = 1 };
UIPanelWindows["AudioOptionsFrame"] =			{ area = "center",		pushable = 0,	whileDead = 1 };
UIPanelWindows["InterfaceOptionsFrame"] =		{ area = "center",		pushable = 0,	whileDead = 1 };
UIPanelWindows["HelpFrame"] =					{ area = "center",		pushable = 0,	whileDead = 1 };

-- Frames using the new Templates
UIPanelWindows["PVPUIFrame"] =					{ area = "left",			pushable = 0,	whileDead = 1, width = 563};
UIPanelWindows["PVPBannerFrame"] =				{ area = "left",			pushable = 1};
UIPanelWindows["PetStableFrame"] =				{ area = "left",			pushable = 0};
UIPanelWindows["PVEFrame"] =					{ area = "left",			pushable = 1, 	whileDead = 1 };
UIPanelWindows["EncounterJournal"] =			{ area = "left",			pushable = 0, 	whileDead = 1, width = 830};
UIPanelWindows["CollectionsJournal"] =			{ area = "left",			pushable = 0, 	whileDead = 1, width = 733};
UIPanelWindows["TradeFrame"] =					{ area = "left",			pushable = 1};
UIPanelWindows["LootFrame"] =					{ area = "left",			pushable = 7};
UIPanelWindows["MerchantFrame"] =				{ area = "left",			pushable = 0};
UIPanelWindows["TabardFrame"] =					{ area = "left",			pushable = 0};
UIPanelWindows["PVPBannerFrame"] =				{ area = "left",			pushable = 1};
UIPanelWindows["MailFrame"] =					{ area = "left",			pushable = 0};
UIPanelWindows["QuestLogPopupDetailFrame"] =	{ area = "left",			pushable = 0,	whileDead = 1 };
UIPanelWindows["DressUpFrame"] =				{ area = "left",			pushable = 2};
UIPanelWindows["PetitionFrame"] =				{ area = "left",			pushable = 0};
UIPanelWindows["ItemTextFrame"] =				{ area = "left",			pushable = 0};
UIPanelWindows["FriendsFrame"] =				{ area = "left",			pushable = 0,	whileDead = 1 };
UIPanelWindows["RaidParentFrame"] =				{ area = "left",			pushable = 1,	whileDead = 1 };
UIPanelWindows["RaidBrowserFrame"] =			{ area = "left",			pushable = 1,	};
UIPanelWindows["DeathRecapFrame"] =				{ area = "center",			pushable = 0,	whileDead = 1, allowOtherPanels = 1};
UIPanelWindows["WardrobeFrame"] =				{ area = "left",			pushable = 0,	width = 965 };
UIPanelWindows["AlliedRacesFrame"] =			{ area = "left",			pushable = 1,	whileDead = 1 };
UIPanelWindows["GuildControlUI"] =				{ area = "left",			pushable = 1,	whileDead = 1,		yoffset = 4, };
UIPanelWindows["CommunitiesFrame"] =			{ area = "left",			pushable = 1,	whileDead = 1 };
UIPanelWindows["CommunitiesGuildLogFrame"] =	{ area = "left",			pushable = 1,	whileDead = 1, 		yoffset = 4, };
UIPanelWindows["CommunitiesGuildTextEditFrame"] = 			{ area = "left",			pushable = 1,	whileDead = 1 };
UIPanelWindows["CommunitiesGuildRecruitmentFrame"] =		{ area = "left",			pushable = 1,	whileDead = 1 };
UIPanelWindows["CommunitiesGuildNewsFiltersFrame"] =		{ area = "left",			pushable = 1,	whileDead = 1 };

-- Resurrected Classic Frames that don't use the new Templates.
-- The offset and width values help the Classic frames blend in with modern frames that use ButtonFrameTemplate.
UIPanelWindows["CharacterFrame"] =				{ area = "left",			pushable = 3,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["SpellBookFrame"] =				{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	height = 424,	whileDead = 1 };
UIPanelWindows["PlayerTalentFrame"] =					{ area = "left",			pushable = 6,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["QuestLogFrame"] =				{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["GossipFrame"] =					{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["QuestFrame"] =					{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["DressUpFrame"] =				{ area = "left",			pushable = 2,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["InspectFrame"] =				{ area = "left",			pushable = 2,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["ClassTrainerFrame"] =			{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["TradeSkillFrame"] =				{ area = "left",			pushable = 3,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["CraftFrame"] =					{ area = "left",			pushable = 4,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["PetStableFrame"] =				{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["BankFrame"] =					{ area = "left",			pushable = 6,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["TabardFrame"] =					{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["GuildRegistrarFrame"] =			{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["ArenaRegistrarFrame"] =			{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["PetitionFrame"] =				{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["BattlefieldFrame"] =			{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["AuctionFrame"] =				{ area = "doublewide",		pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 840 }
UIPanelWindows["TaxiFrame"] =					{ area = "left",			pushable = 0, 		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	showFailedFunc = CloseTaxiMap };
UIPanelWindows["ItemTextFrame"] =				{ area = "left",			pushable = 0, 		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["ArenaFrame"] =					{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };
UIPanelWindows["LFGParentFrame"] =				{ area = "left",			pushable = 0,		xoffset = -16,		yoffset = 12,	bottomClampOverride = 140+12,	width = 353,	height = 424,	whileDead = 1 };

-- Frames NOT using the new Templates
UIPanelWindows["CinematicFrame"] =				{ area = "full",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 1 };
UIPanelWindows["ChatConfigFrame"] =				{ area = "center",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 1 };
UIPanelWindows["WorldStateScoreFrame"] =		{ area = "center",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 1,	ignoreControlLost = true, };
UIPanelWindows["QuestChoiceFrame"] =			{ area = "center",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 0, allowOtherPanels = 1 };
UIPanelWindows["WarboardQuestChoiceFrame"] =	{ area = "center",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 0, allowOtherPanels = 1 };
UIPanelWindows["GarrisonBuildingFrame"] =		{ area = "center",			pushable = 0,		whileDead = 1, 		width = 1002, 	allowOtherPanels = 1};
UIPanelWindows["GarrisonMissionFrame"] =		{ area = "center",			pushable = 0,		whileDead = 1, 		checkFit = 1,	allowOtherPanels = 1, extraWidth = 20,	extraHeight = 100 };
UIPanelWindows["GarrisonShipyardFrame"] =		{ area = "center",			pushable = 0,		whileDead = 1, 		checkFit = 1,	allowOtherPanels = 1, extraWidth = 20,	extraHeight = 100 };
UIPanelWindows["GarrisonLandingPage"] =			{ area = "left",			pushable = 1,		whileDead = 1, 		width = 830, 	yoffset = 9,	allowOtherPanels = 1};
UIPanelWindows["GarrisonMonumentFrame"] =		{ area = "center",			pushable = 0,		whileDead = 1, 		width = 333, 	allowOtherPanels = 1};
UIPanelWindows["GarrisonRecruiterFrame"] =		{ area = "left",			pushable = 0};
UIPanelWindows["GarrisonRecruitSelectFrame"] =	{ area = "center",			pushable = 0};
UIPanelWindows["OrderHallMissionFrame"] =		{ area = "center",			pushable = 0,		whileDead = 1, 		checkFit = 1,	allowOtherPanels = 1, extraWidth = 20,	extraHeight = 100 };
UIPanelWindows["OrderHallTalentFrame"] =		{ area = "left",			pushable = 0,		xoffset = 16};
UIPanelWindows["ChallengesKeystoneFrame"] =		{ area = "center",			pushable = 0};
UIPanelWindows["BFAMissionFrame"] =				{ area = "center",			pushable = 0,		whileDead = 1, 		checkFit = 1,	allowOtherPanels = 1, extraWidth = 20,	extraHeight = 100 };

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
	"GuildControlPopupFrame",
	"GuildMemberDetailFrame",
	"GuildInfoFrame",
	"TokenFramePopup",
	"GuildBankPopupFrame",
	"GearManagerDialog",
};

function UpdateUIParentRelativeToDebugMenu()
	if (DebugMenu and DebugMenu.IsVisible()) then
		UIParent:SetPoint("TOPLEFT", 0, -DebugMenu.GetMenuHeight());
	else
		UIParent:SetPoint("TOPLEFT", 0, 0);
	end
end

UISpecialFrames = {
	"ItemRefTooltip",
	"ColorPickerFrame",
	"FloatingPetBattleAbilityTooltip",
	"FloatingGarrisonFollowerTooltip",
	"FloatingGarrisonShipyardFollowerTooltip"
};

UIMenus = {
	"ChatMenu",
	"EmoteMenu",
	"LanguageMenu",
	"DropDownList1",
	"DropDownList2",
};

ITEM_QUALITY_COLORS = { };
for i = 0, NUM_LE_ITEM_QUALITYS - 1 do
	local r, g, b = GetItemQualityColor(i);
	local color = CreateColor(r, g, b, 1);
	ITEM_QUALITY_COLORS[i] = { r = r, g = g, b = b, hex = color:GenerateHexColorMarkup(), color = color };
end

WORLD_QUEST_QUALITY_COLORS = {
	[LE_WORLD_QUEST_QUALITY_COMMON] = ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_COMMON];
	[LE_WORLD_QUEST_QUALITY_RARE] = ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_RARE];
	[LE_WORLD_QUEST_QUALITY_EPIC] = ITEM_QUALITY_COLORS[LE_ITEM_QUALITY_EPIC];
};

-- Protecting from addons since we use this in GetScaledCursorDelta which is used in secure code.
local _UIParentGetEffectiveScale;
local _UIParentRef;
function UIParent_OnLoad(self)
	_UIParentGetEffectiveScale = self.GetEffectiveScale;
	_UIParentRef = self;
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
	self:RegisterEvent("CURSOR_UPDATE");
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
	self:RegisterEvent("SHOW_AADC_ALERT");

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

	-- Events for craft UI handling
	self:RegisterEvent("CRAFT_SHOW");
	self:RegisterEvent("CRAFT_CLOSE");

	-- Events for taxi benchmarking
	self:RegisterEvent("ENABLE_TAXI_BENCHMARK");
	self:RegisterEvent("DISABLE_TAXI_BENCHMARK");
	
	-- Events for Guild bank UI
	self:RegisterEvent("GUILDBANKFRAME_OPENED");
	self:RegisterEvent("GUILDBANKFRAME_CLOSED");

	--Events for GMChatUI
	self:RegisterEvent("CHAT_MSG_WHISPER");

	-- Events for WoW Mouse
	self:RegisterEvent("WOW_MOUSE_NOT_FOUND");

	-- Events for talent wipes
	self:RegisterEvent("TALENTS_INVOLUNTARILY_RESET");

	-- Events for Trial caps
	self:RegisterEvent("TRIAL_CAP_REACHED_MONEY");
	self:RegisterEvent("TRIAL_CAP_REACHED_LEVEL");

	-- Lua warnings
	self:RegisterEvent("LUA_WARNING");

	-- debug menu
	self:RegisterEvent("DEBUG_MENU_TOGGLED");

	-- Shop (for Asia promotion)
	self:RegisterEvent("PRODUCT_DISTRIBUTIONS_UPDATED");

	self:RegisterEvent("TOKEN_AUCTION_SOLD");

	self:RegisterEvent("TAXIMAP_OPENED");

	-- Invite confirmations
	self:RegisterEvent("GROUP_INVITE_CONFIRMATION");

	-- Event(s) for PVP
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
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

function BattlefieldMap_LoadUI()
	UIParentLoadAddOn("Blizzard_BattlefieldMap");
end

function ClassTrainerFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_TrainerUI");
end

function CraftFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_CraftUI");
end

function CombatLog_LoadUI()
	UIParentLoadAddOn("Blizzard_CombatLog");
end

function Commentator_LoadUI()
	UIParentLoadAddOn("Blizzard_Commentator");
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

function SocialFrame_LoadUI()
	AchievementFrame_LoadUI();
	UIParentLoadAddOn("Blizzard_SocialUI");
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

function TimeManager_LoadUI()
	UIParentLoadAddOn("Blizzard_TimeManager");
end

function TokenFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_TokenUI");
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

function Store_LoadUI()
	UIParentLoadAddOn("Blizzard_StoreUI");
end

function APIDocumentation_LoadUI()
	UIParentLoadAddOn("Blizzard_APIDocumentation");
end

--[[
function MovePad_LoadUI()
	UIParentLoadAddOn("Blizzard_MovePad");
end
]]

function DeathRecap_LoadUI()
	UIParentLoadAddOn("Blizzard_DeathRecap");
end

function Communities_LoadUI()
	UIParentLoadAddOn("Blizzard_Communities");
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

function ToggleTalentFrame()
	if (UnitLevel("player") < SHOW_TALENT_LEVEL) then
		return;
	end

	TalentFrame_LoadUI();
	if ( PlayerTalentFrame:IsShown() ) then
		HideUIPanel(PlayerTalentFrame);
	else
		ShowUIPanel(PlayerTalentFrame);
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

function IsCommunitiesUIDisabledByTrialAccount()
	return IsTrialAccount() or (not C_Club.IsEnabled() and IsVeteranTrialAccount() and not IsInGuild());
end

function ToggleGuildFrame()
	if (Kiosk.IsEnabled()) then
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
	elseif ( IsInGuild() ) then
		GuildFrame_LoadUI();
		if ( GuildFrame_Toggle ) then
			GuildFrame_Toggle();
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

function ToggleRaidFrame()
	if (Kiosk.IsEnabled()) then
		return;
	end

	local factionGroup = UnitFactionGroup("player");
	if (factionGroup == "Neutral") then
		return;
	end

	ToggleFriendsFrame(FRIEND_TAB_RAID);
end

function CanShowEncounterJournal()
	return false;
end

function ToggleCommunitiesFrame()
	Communities_LoadUI();
	ToggleFrame(CommunitiesFrame);
end

function CommunitiesFrame_IsEnabled()
	return C_Club.IsEnabled();
end

function ToggleStoreUI()
	if (Kiosk.IsEnabled()) then
		return;
	end

	Store_LoadUI();

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

	Store_LoadUI();

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

local function PlayBattlefieldBanner(self)
	-- battlefields
	if ( not self.battlefieldBannerShown ) then
		local bannerName, bannerDescription;

		for i=1, GetMaxBattlefieldID() do
			local status, _, _, _, _, _, _, _, _, _, _, _, asGroup, shortDescription = GetBattlefieldStatus(i);
			if ( status and status == "active" ) then
				bannerName = mapName;
				bannerDescription = shortDescription;
				break;
			end
		end
	end
end

-- UIParent_OnEvent --
function UIParent_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6 = ...;
	if ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
		if ( #StaticPopup_DisplayedFrames > 0 ) then
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
	elseif ( event == "PLAYER_UNGHOST" ) then
		StaticPopup_Hide("RESURRECT");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		StaticPopup_Hide("RESURRECT_NO_TIMER");
		StaticPopup_Hide("SKINNED");
		StaticPopup_Hide("SKINNED_REPOP");
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
			local dialog = StaticPopup_Show("CHAT_CHANNEL_INVITE", arg1, arg2);
			if ( dialog ) then
				dialog.data = arg1;
			end
		end
	elseif ( event == "CHANNEL_PASSWORD_REQUEST" ) then
		local dialog = StaticPopup_Show("CHAT_CHANNEL_PASSWORD", arg1);
		if ( dialog ) then
			dialog.data = arg1;
		end
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
		local texture, item, quantity, itemID, quality, locked = GetLootSlotInfo(arg1);
		local dialog = StaticPopup_Show("LOOT_BIND", ITEM_QUALITY_COLORS[quality].hex..item.."|r");
		if ( dialog ) then
			dialog.data = arg1;
		end
	elseif ( event == "EQUIP_BIND_CONFIRM" ) then
		StaticPopup_Hide("EQUIP_BIND_REFUNDABLE");
		StaticPopup_Hide("EQUIP_BIND_TRADEABLE");
		local dialog = StaticPopup_Show("EQUIP_BIND");
		if ( dialog ) then
			dialog.data = arg1;
		end
	elseif ( event == "EQUIP_BIND_REFUNDABLE_CONFIRM" ) then
		StaticPopup_Hide("EQUIP_BIND");
		StaticPopup_Hide("EQUIP_BIND_TRADEABLE");
		local dialog = StaticPopup_Show("EQUIP_BIND_REFUNDABLE");
		if ( dialog ) then
			dialog.data = arg1;
		end
	elseif ( event == "EQUIP_BIND_TRADEABLE_CONFIRM" ) then
		StaticPopup_Hide("EQUIP_BIND");
		StaticPopup_Hide("EQUIP_BIND_REFUNDABLE");
		local dialog = StaticPopup_Show("EQUIP_BIND_TRADEABLE");
		if ( dialog ) then
			dialog.data = arg1;
		end
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
	elseif ( event == "CURSOR_UPDATE" ) then
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

		if Kiosk.IsEnabled() then
			LoadAddOn("Blizzard_Kiosk");
		end
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" or event == "PVP_BRAWL_INFO_UPDATED" ) then
		PlayBattlefieldBanner(self);
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
			local dialog = nil;
			dialog = StaticPopup_Show("XP_LOSS", resSicknessTime);
			if ( dialog ) then
				dialog.data = resSicknessTime;
			end
		else
			local dialog = nil;
			dialog = StaticPopup_Show("XP_LOSS_NO_SICKNESS");
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
		local dialog = StaticPopup_Show("ADDON_ACTION_FORBIDDEN", arg1);
		if ( dialog ) then
			dialog.data = arg1;
		end
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
			dialog.text:SetFormattedText(arg3, ITEM_QUALITY_COLORS[quality].hex..name.."|r");
			StaticPopup_Resize(dialog, "CONFIRM_LOOT_ROLL");
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
	elseif ( event == "CONFIRM_PET_UNLEARN" ) then
		HideUIPanel(GossipFrame);
		local dialog = StaticPopup_Show("CONFIRM_PET_UNLEARN");
		if ( dialog ) then
			MoneyFrame_Update(dialog:GetName().."MoneyFrame", arg1);
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
	elseif ( event == "SHOW_AADC_ALERT" ) then
		StaticPopup_Show("AADC_ALERT")

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
		ArcheologyDigsiteProgressBar_OnEvent(ArcheologyDigsiteProgressBar, event, ...);
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
	elseif ( event == "LUA_WARNING" ) then
		HandleLuaWarning(...);
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
	elseif ( event == "PRODUCT_DISTRIBUTIONS_UPDATED" ) then
		StoreFrame_CheckForFree(event);
	elseif ( event == "TOKEN_AUCTION_SOLD" ) then
		local info = ChatTypeInfo["SYSTEM"];
		local itemName = GetItemInfo(WOW_TOKEN_ITEM_ID);
		if (itemName) then
			DEFAULT_CHAT_FRAME:AddMessage(ERR_AUCTION_SOLD_S:format(itemName), info.r, info.g, info.b, info.id);
		else
			self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
		end
	elseif ( event == "GET_ITEM_INFO_RECEIVED" ) then
		local itemID = ...;
		if (itemID == WOW_TOKEN_ITEM_ID) then
			local info = ChatTypeInfo["SYSTEM"];
			local itemName = GetItemInfo(WOW_TOKEN_ITEM_ID);
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
	end
end

-- Frame Management --

-- UIPARENT_MANAGED_FRAME_POSITIONS stores all the frames that have positioning dependencies based on other frames.

-- UIPARENT_MANAGED_FRAME_POSITIONS["FRAME"] = {
	--Note: this is out of date and there are several more options now.
	-- none = This value is used if no dependent frames are shown
	-- watchBar = This is the offset used if the reputation or artifact watch bar is shown
	-- anchorTo = This is the object that the stored frame is anchored to
	-- point = This is the point on the frame used as the anchor
	-- rpoint = This is the point on the "anchorTo" frame that the stored frame is anchored to
	-- bottomEither = This offset is used if either bottom multibar is shown
	-- bottomLeft
	-- var = If this is set use _G[varName] = value instead of setpoint
-- };


-- some standard offsets
local actionBarOffset = 42;
local menuBarTop = 55;
local overrideActionBarTop = 40;
local petBattleTop = 60;

function UpdateMenuBarTop ()
	--Determines the optimal magic number based on resolution and action bar status.
	menuBarTop = 55;
	local width = GetScreenWidth();
	local height = GetScreenHeight();
	if ( ( width / height ) > 4/3 ) then
		--Widescreen resolution
		menuBarTop = 75;
	end
end

function UIParent_UpdateTopFramePositions()
	local topOffset = 0;
	local buffsAreaTopOffset = 0;

	if (OrderHallCommandBar and OrderHallCommandBar:IsShown()) then
		topOffset = 12;
		buffsAreaTopOffset = OrderHallCommandBar:GetHeight();
	end

	if (PlayerFrame and not PlayerFrame:IsUserPlaced() and not PlayerFrame_IsAnimatedOut(PlayerFrame)) then
		PlayerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -19, -4 - topOffset)
	end

	if (TargetFrame and not TargetFrame:IsUserPlaced()) then
		TargetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 250, -4 - topOffset);
	end

	local ticketStatusFrameShown = TicketStatusFrame and TicketStatusFrame:IsShown();
	local gmChatStatusFrameShown = GMChatStatusFrame and GMChatStatusFrame:IsShown();
	if (ticketStatusFrameShown) then
		TicketStatusFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -180, 0 - buffsAreaTopOffset);
		buffsAreaTopOffset = buffsAreaTopOffset + TicketStatusFrame:GetHeight();
	end
	if (gmChatStatusFrameShown) then
		GMChatStatusFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -170, -5 - buffsAreaTopOffset);
		buffsAreaTopOffset = buffsAreaTopOffset + GMChatStatusFrame:GetHeight() + 5;
	end
	if (not ticketStatusFrameShown and not gmChatStatusFrameShown) then
		buffsAreaTopOffset = buffsAreaTopOffset + 13;
	end

	BuffFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -205, 0 - buffsAreaTopOffset);
end

UIPARENT_ALTERNATE_FRAME_POSITIONS = {}

UIPARENT_MANAGED_FRAME_POSITIONS = {
	--Items with baseY set to "true" are positioned based on the value of menuBarTop and their offset needs to be repeatedly evaluated as menuBarTop can change.
	--"yOffset" gets added to the value of "baseY", which is used for values based on menuBarTop.
	["MultiBarBottomLeft"] = {baseY = 17, watchBar = 1, maxLevel = 1, anchorTo = "ActionButton1", point = "BOTTOMLEFT", rpoint = "TOPLEFT"};
	["GroupLootContainer"] = {baseY = true, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, watchBar = 1};
	["TutorialFrameParent"] = {baseY = true, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, watchBar = 1};
	["FramerateLabel"] = {baseY = true, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, watchBar = 1, playerPowerBarAlt = 1, extraActionBarFrame = 1};
	["ArcheologyDigsiteProgressBar"] = {baseY = true, yOffset = 40, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, watchBar = 1, tutorialAlert = 1, playerPowerBarAlt = 1, extraActionBarFrame = 1, ZoneAbilityFrame = 1, castingBar = 1};
	["CastingBarFrame"] = {baseY = true, yOffset = 40, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, watchBar = 1, tutorialAlert = 1, playerPowerBarAlt = 1, extraActionBarFrame = 1, ZoneAbilityFrame = 1, talkingHeadFrame = 1, classResourceOverlayFrame = 1, classResourceOverlayOffset = 1};
	["ClassResourceOverlayParentFrame"] = {baseY = true, yOffset = 0, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, watchBar = 1, tutorialAlert = 1, playerPowerBarAlt = 1, extraActionBarFrame = 1, ZoneAbilityFrame = 1 };
	["ExtraActionBarFrame"] = {baseY = true, yOffset = 0, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, watchBar = 1, tutorialAlert = 1};
	["ZoneAbilityFrame"] = {baseY = true, yOffset = 100, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, watchBar = 1, tutorialAlert = 1, extraActionBarFrame = 1};
	["ChatFrame1"] = {baseY = true, yOffset = 40, bottomLeft = actionBarOffset-8, justBottomRightAndStance = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, watchBar = 1, maxLevel = 1, point = "BOTTOMLEFT", rpoint = "BOTTOMLEFT", xOffset = 32};
	["ChatFrame2"] = {baseY = true, yOffset = 40, bottomRight = actionBarOffset-8, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, rightLeft = -2*actionBarOffset, rightRight = -actionBarOffset, watchBar = 1, maxLevel = 1, point = "BOTTOMRIGHT", rpoint = "BOTTOMRIGHT", xOffset = -32};
	["StanceBarFrame"] = {baseY = 0, bottomLeft = actionBarOffset, watchBar = 1, maxLevel = 1, anchorTo = "MainMenuBar", point = "BOTTOMLEFT", rpoint = "TOPLEFT", xOffset = 30};
	["PossessBarFrame"] = {baseY = 0, bottomLeft = actionBarOffset, watchBar = 1, maxLevel = 1, anchorTo = "MainMenuBar", point = "BOTTOMLEFT", rpoint = "TOPLEFT", xOffset = 30};
	["MultiCastActionBarFrame"] = {baseY = 8, bottomLeft = actionBarOffset, watchBar = 1, maxLevel = 1, anchorTo = "MainMenuBar", point = "BOTTOMLEFT", rpoint = "TOPLEFT", xOffset = 30};
	["AuctionProgressFrame"] = {baseY = true, yOffset = 18, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, watchBar = 1, tutorialAlert = 1};
	["TalkingHeadFrame"] = {baseY = true, yOffset = 0, bottomEither = actionBarOffset, overrideActionBar = overrideActionBarTop, petBattleFrame = petBattleTop, bonusActionBar = 1, pet = 1, watchBar = 1, tutorialAlert = 1, playerPowerBarAlt = 1, extraActionBarFrame = 1, ZoneAbilityFrame = 1, classResourceOverlayFrame = 1};

	-- Vars
	-- These indexes require global variables of the same name to be declared. For example, if I have an index ["FOO"] then I need to make sure the global variable
	-- FOO exists before this table is constructed. The function UIParent_ManageFramePosition will use the "FOO" table index to change the value of the FOO global
	-- variable so that other modules can use the most up-to-date value of FOO without having knowledge of the UIPARENT_MANAGED_FRAME_POSITIONS table.
	["CONTAINER_OFFSET_X"] = {baseX = 0, rightActionBarsX = "variable", isVar = "xAxis"};
	["CONTAINER_OFFSET_Y"] = {baseY = 70, bottomEither = 27, bottomRight = 0, watchBar = 1, isVar = "yAxis", pet = 1}; -- Adjusted so that Backpack + 4 Mooncloth Bags takes up only 2 columns (like 1.12).
	["PETACTIONBAR_YPOS"] = {baseY = 97, bottomLeft = actionBarOffset, justBottomRightAndStance = actionBarOffset, watchBar = 1, maxLevel = 1, isVar = "yAxis"};
	["MULTICASTACTIONBAR_YPOS"] = {baseY = 0, bottomLeft = actionBarOffset, watchBar = 1, maxLevel = 1, isVar = "yAxis"};
	["OBJTRACKER_OFFSET_X"] = {baseX = 12, rightActionBarsX = "variable", isVar = "xAxis"};
	["BATTLEFIELD_TAB_OFFSET_Y"] = {baseY = 260, bottomRight = actionBarOffset, watchBar = 1, isVar = "yAxis"};
};

local UIPARENT_VARIABLE_OFFSETS = {
	["rightActionBarsX"] = 0,
};

-- If any Var entries in UIPARENT_MANAGED_FRAME_POSITIONS are used exclusively by addons, they should be declared here and not in one of the addon's files.
-- The reason why is that it is possible for UIParent_ManageFramePosition to be run before the addon loads.
OBJTRACKER_OFFSET_X = 0;
BATTLEFIELD_TAB_OFFSET_Y = 0;

-- constant offsets
for _, data in pairs(UIPARENT_MANAGED_FRAME_POSITIONS) do
	for flag, value in pairs(data) do
		if ( flag == "watchBar" ) then
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
		local flagValue = value[flag];
		if ( flagValue ) then
			if ( flagValue == "variable" ) then
				yOffset = yOffset + UIPARENT_VARIABLE_OFFSETS[flag];
			else
			if ( flag == "bottomEither" ) then
				hasBottomEitherFlag = 1;
			end
				yOffset = yOffset + flagValue;
			end
		end
	end

	-- don't offset for the pet bar and bottomEither if the player has
	-- the bottom right bar shown and not the bottom left
	if ( hasBottomEitherFlag and hasBottomRight and hasPetBar and not hasBottomLeft ) then
		yOffset = yOffset - (value["pet"] or 0);
	end

	-- Iterate through frames that affect x offsets
	for _, flag in pairs(xOffsetFrames) do
		local flagValue = value[flag];
		if ( flagValue ) then
			if ( flagValue == "variable" ) then
				xOffset = xOffset + UIPARENT_VARIABLE_OFFSETS[flag];
			else
				xOffset = xOffset + flagValue;
			end
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
	elseif ( attribute == "panel-maximize" ) then
		local frame = self:GetAttribute("panel-frame");
		self:MoveUIPanel(GetUIPanelWindowInfo(frame, "area"), "fullscreen", UIPANEL_DO_SET_POINT, UIPANEL_VALIDATE_CURRENT_FRAME);
		frame:ClearAllPoints();
		frame:SetPoint(GetUIPanelWindowInfo(frame, "maximizePoint"));
	elseif ( attribute == "panel-restore" ) then
		local frame = self:GetAttribute("panel-frame");
		self:MoveUIPanel("fullscreen", GetUIPanelWindowInfo(frame, "area"), UIPANEL_DO_SET_POINT, UIPANEL_VALIDATE_CURRENT_FRAME);
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
		self:ShowUIPanelFailed(frame);
		NotWhileDeadError();
		return;
	end

	-- If the store-frame is open, we don't let people open up any other panels (just as if it were full-screened)
	if ( StoreFrame_IsShown and StoreFrame_IsShown() ) then
		self:ShowUIPanelFailed(frame);
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

	-- check if the UI fits due to scaling issues
	if ( GetUIPanelWindowInfo(frame, "checkFit") == 1 ) then
		local horizRatio = UIParent:GetWidth() / GetUIPanelWidth(frame);
		local vertRatio = UIParent:GetHeight() / GetUIPanelHeight(frame);
		if ( horizRatio < 1 or vertRatio < 1 ) then
			frame:SetScale(min(horizRatio, vertRatio));
		else
			frame:SetScale(1);
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
				self:MoveUIPanel("left", "right", UIPANEL_SKIP_SET_POINT);
			elseif ( centerFrame and CanShowRightUIPanel(centerFrame) ) then
				self:MoveUIPanel("center", "right", UIPANEL_SKIP_SET_POINT);
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
					self:MoveUIPanel("left", "right", UIPANEL_SKIP_SET_POINT);
					self:SetUIPanel("left", frame);
				else
					-- Replace left
					self:SetUIPanel("left", frame);
				end
			else
				if ( CanShowUIPanels(frame, leftFrame, centerFrame) ) then
					-- Shift both
					self:MoveUIPanel("center", "right", UIPANEL_SKIP_SET_POINT);
					self:MoveUIPanel("left", "center", UIPANEL_SKIP_SET_POINT);
					self:SetUIPanel("left", frame);
				else
					-- Replace left
					self:SetUIPanel("left", frame);
				end
			end
		elseif ( framePushable <= centerPushable and centerArea ~= "center" and CanShowUIPanels(leftFrame, frame, centerFrame) ) then
			-- Push center
			self:MoveUIPanel("center", "right", UIPANEL_SKIP_SET_POINT);
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
			self:MoveUIPanel("left", "center", UIPANEL_SKIP_SET_POINT);
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
			self:MoveUIPanel("center", "left", UIPANEL_SKIP_SET_POINT);
			self:MoveUIPanel("right", "center", UIPANEL_SKIP_SET_POINT);
			self:SetUIPanel("right", frame);
		else
			self:MoveUIPanel("right", "left", UIPANEL_SKIP_SET_POINT);
			self:SetUIPanel("center", frame);
		end
	elseif ( framePushable > centerPushable ) then
		-- This one is middle priority, so move the center frame to the left
		self:MoveUIPanel("center", "left", UIPANEL_SKIP_SET_POINT);
		self:SetUIPanel("center", frame);
	else
		self:SetUIPanel("left", frame);
	end
end

function FramePositionDelegate:ShowUIPanelFailed(frame)
	if GetUIPanelWindowInfo(frame, "showFailedFunc") then
		frame:ExecuteAttribute("UIPanelLayout-showFailedFunc");
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

function FramePositionDelegate:MoveUIPanel(current, new, skipSetPoint, skipOperationUnlessCurrentIsValid)
	if ( current ~= "left" and current ~= "center" and current ~= "right" and new ~= "left" and new ~= "center" and new ~= "right" ) then
		return;
	end

	if skipOperationUnlessCurrentIsValid and not self[current] then
		return;
	end

	self:SetUIPanel(new, nil, skipSetPoint);
	if ( self[current] ) then
		self[current]:Raise();
		self[new] = self[current];
		self[current] = nil;
		if ( not skipSetPoint ) then
			securecall("UpdateUIPanelPositions", self[new]);
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
					self:MoveUIPanel("center", "left", UIPANEL_SKIP_SET_POINT);
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
		local bottomClampOverride = GetUIPanelWindowInfo(frame,"bottomClampOverride");
		local minYOffset = GetUIPanelWindowInfo(frame,"minYOffset");
		local yPos = ClampUIPanelY(frame, yOff + topOffset, minYOffset, bottomClampOverride);
		frame:ClearAllPoints();
		frame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", leftOffset + xOff, yPos);
		centerOffset = leftOffset + GetUIPanelWidth(frame) + xOff;
		UIParent:SetAttribute("CENTER_OFFSET", centerOffset);
		frame:Raise();
	else
		centerOffset = leftOffset;
		UIParent:SetAttribute("CENTER_OFFSET", centerOffset);
		
		frame = self:GetUIPanel("doublewide");
		if ( frame ) then
			local xOff = GetUIPanelWindowInfo(frame,"xoffset") or 0;
			local yOff = GetUIPanelWindowInfo(frame,"yoffset") or 0;
			local bottomClampOverride = GetUIPanelWindowInfo(frame,"bottomClampOverride");
			local minYOffset = GetUIPanelWindowInfo(frame,"minYOffset");
			local yPos = ClampUIPanelY(frame, yOff + topOffset, minYOffset, bottomClampOverride);
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
			local bottomClampOverride = GetUIPanelWindowInfo(frame,"bottomClampOverride");
			local minYOffset = GetUIPanelWindowInfo(frame,"minYOffset");
			local yPos = ClampUIPanelY(frame, yOff + topOffset, minYOffset, bottomClampOverride);
			if ( area ~= "center" ) then
				frame:ClearAllPoints();
				xOff = xOff + xSpacing; -- add separating space
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
			local bottomClampOverride = GetUIPanelWindowInfo(frame,"bottomClampOverride");
			local minYOffset = GetUIPanelWindowInfo(frame,"minYOffset");
			local yPos = ClampUIPanelY(frame, yOff + topOffset, minYOffset, bottomClampOverride);
			xOff = xOff + xSpacing; -- add separating space
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
	UIPARENT_VARIABLE_OFFSETS["rightActionBarsX"] = VerticalMultiBarsContainer:GetWidth();

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
		-- TODO: Leaving this here for now since ChatFrame2 references it. Do we still need ChatFrame2 to be managed?
		if ( MultiBarRight:IsShown() ) then
			tinsert(xOffsetFrames, "rightRight");
		end
		if ( MultiBarRight:IsShown() ) then
			tinsert(xOffsetFrames, "rightActionBarsX");
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
		local numWatchBars = 0;
		numWatchBars = numWatchBars + (ReputationWatchBar:IsShown() and 1 or 0);
		numWatchBars = numWatchBars + (MainMenuExpBar:IsShown() and 1 or 0);
		if ( numWatchBars > 1 ) then
			tinsert(yOffsetFrames, "watchBar");
		end
		if ( MainMenuBarMaxLevelBar:IsShown() ) then
			tinsert(yOffsetFrames, "maxLevel");
		end
		if ( PlayerPowerBarAlt and PlayerPowerBarAlt:IsShown() and not PlayerPowerBarAlt:IsUserPlaced() ) then
			local anchorTop = select(10, UnitAlternatePowerInfo(PlayerPowerBarAlt.unit));
			if ( not anchorTop ) then
				tinsert(yOffsetFrames, "playerPowerBarAlt");
			end
		end
		if (ExtraActionBarFrame and ExtraActionBarFrame:IsShown() ) then
			tinsert(yOffsetFrames, "extraActionBarFrame");
		end
		if (ZoneAbilityFrame and ZoneAbilityFrame:IsShown()) then
			tinsert(yOffsetFrames, "ZoneAbilityFrame");
		end
		if ( TalkingHeadFrame and TalkingHeadFrame:IsShown() ) then
			tinsert(yOffsetFrames, "talkingHeadFrame");
		end
		if ( ClassResourceOverlayParentFrame and ClassResourceOverlayParentFrame:IsShown() ) then
			tinsert(yOffsetFrames, "classResourceOverlayFrame");
			tinsert(yOffsetFrames, "classResourceOverlayOffset");
		end
		if ( CastingBarFrame and not CastingBarFrame:GetAttribute("ignoreFramePositionManager") ) then
			tinsert(yOffsetFrames, "castingBar");
		end
	end

	-- Iterate through frames and set anchors according to the flags set
	for index, value in pairs(UIPARENT_MANAGED_FRAME_POSITIONS) do
		if ( value.extraActionBarFrame and ExtraActionBarFrame ) then
			value.extraActionBarFrame = ExtraActionBarFrame:GetHeight() + 10;
		end
		if ( value.ZoneAbilityFrame and ZoneAbilityFrame ) then
			value.ZoneAbilityFrame = ZoneAbilityFrame:GetHeight() + 90;
		end

		if ( value.bonusActionBar and BonusActionBarFrame ) then
			value.bonusActionBar = BonusActionBarFrame:GetHeight() - MainMenuBar:GetHeight();
		end
		if ( value.castingBar ) then
			value.castingBar = CastingBarFrame:GetHeight() + 14;
		end
		if ( value.talkingHeadFrame and TalkingHeadFrame and TalkingHeadFrame:IsShown() ) then
			value.talkingHeadFrame = TalkingHeadFrame:GetHeight() - 10;
		end
		if ( ClassResourceOverlayParentFrame and ClassResourceOverlayParentFrame:IsShown() ) then
			if ( value.classResourceOverlayFrame ) then
				value.classResourceOverlayFrame = ClassResourceOverlayParentFrame:GetHeight() + 10;
			end
			if ( value.classResourceOverlayOffset ) then
				value.classResourceOverlayOffset = -20;
			end
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

	-- If petactionbar is already shown, set its point in addition to changing its y target
	if ( PetActionBarFrame:IsShown() ) then
		PetActionBar_UpdatePositionValues();
		PetActionBarFrame:SetPoint("TOPLEFT", MainMenuBar, "BOTTOMLEFT", PETACTIONBAR_XPOS, PETACTIONBAR_YPOS);
	end

	-- Set battlefield minimap position
	if ( BattlefieldMapTab and not BattlefieldMapTab:IsUserPlaced() ) then
		BattlefieldMapTab:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMRIGHT", -BATTLEFIELD_MAP_WIDTH-CONTAINER_OFFSET_X, BATTLEFIELD_TAB_OFFSET_Y);
	end

	-- Setup y anchors
	local anchorY = 0
	local buffsAnchorY = min(0, (MINIMAP_BOTTOM_EDGE_EXTENT or 0) - BuffFrame.bottomEdgeExtent);
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

	-- BelowMinimap Widgets - need to move below buffs/debuffs if at least 1 right action bar is showing
	if UIWidgetBelowMinimapContainerFrame and UIWidgetBelowMinimapContainerFrame:GetHeight() > 0 then
		if rightActionBars > 0 then
					anchorY = min(anchorY, buffsAnchorY);
				end

		UIWidgetBelowMinimapContainerFrame:ClearAllPoints();
		UIWidgetBelowMinimapContainerFrame:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -CONTAINER_OFFSET_X, anchorY);

		anchorY = anchorY - UIWidgetBelowMinimapContainerFrame:GetHeight() - 4;
	end

	-- Quest timers
	QuestTimerFrame:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -CONTAINER_OFFSET_X, anchorY);
	if ( QuestTimerFrame:IsShown() ) then
		anchorY = anchorY - QuestTimerFrame:GetHeight();
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

	-- QuestWatchFrame
	if ( rightActionBars > 0 ) then
		anchorY = min(anchorY, buffsAnchorY);
	end
	if ( QuestWatchFrame ) then
		QuestWatchFrame:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -CONTAINER_OFFSET_X, anchorY);
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

-- We keep direct references to protect against replacement.
local InCombatLockdown = InCombatLockdown;
local issecure = issecure;

-- We no longer allow addons to show or hide UI panels in combat.
local function CheckProtectedFunctionsAllowed()
	if ( InCombatLockdown() and not issecure() ) then
		DisplayInterfaceActionBlockedMessage();
		return false;
	end

	return true;
end

function ShowUIPanel(frame, force)
	if ( CanAutoSetGamePadCursorControl(true) ) then
		SetGamePadCursorControl(true);
	end

	if ( not frame or frame:IsShown() ) then
		return;
	end

	if ( not CheckProtectedFunctionsAllowed() ) then
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

	if ( not CheckProtectedFunctionsAllowed() ) then
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

function ShowOptionsPanel(optionsFrame, lastFrame, categoryToSelect)
	-- NOTE: Toggle isn't currently necessary because showing an options panel hides everything else.
	ShowUIPanel(optionsFrame);
	optionsFrame.lastFrame = lastFrame;

	if categoryToSelect then
		OptionsFrame_OpenToCategory(optionsFrame, categoryToSelect);
	end
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

function ClampUIPanelY(frame, yOffset, minYOffset, bottomClampOverride)
	local bottomPos = UIParent:GetTop() + yOffset - GetUIPanelHeight(frame);
	local bottomClamp = bottomClampOverride or 140;
	if (bottomPos < bottomClamp) then
		yOffset = yOffset + (bottomClamp - bottomPos);
	end
	if (yOffset > -10) then
		yOffset = minYOffset or -10;
	end
	return yOffset;
end

function CanShowRightUIPanel(frame)
	local width = frame and GetUIPanelWidth(frame) or UIParent:GetAttribute("DEFAULT_FRAME_WIDTH");
	local rightSide = UIParent:GetAttribute("RIGHT_OFFSET") + width;
	return rightSide < GetMaxUIPanelsWidth();
end

function CanShowCenterUIPanel(frame)
	local width = frame and GetUIPanelWidth(frame) or UIParent:GetAttribute("DEFAULT_FRAME_WIDTH");
	local rightSide = UIParent:GetAttribute("CENTER_OFFSET") + width;
	return rightSide < GetMaxUIPanelsWidth();
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
		HideUIPanel(leftFrame, UIPANEL_SKIP_SET_POINT);
	end

	HideUIPanel(fullScreenFrame, UIPANEL_SKIP_SET_POINT);
	HideUIPanel(doublewideFrame, UIPANEL_SKIP_SET_POINT);

	if ( not frameToIgnore or frameToIgnore ~= centerFrame ) then
		if ( centerFrame ) then
			local area = GetUIPanelWindowInfo(centerFrame, "area");
			if ( area ~= "center" or not ignoreCenter ) then
				HideUIPanel(centerFrame, UIPANEL_SKIP_SET_POINT);
			end
		end
	end

	if ( not frameToIgnore or frameToIgnore ~= rightFrame ) then
		if ( rightFrame ) then
			HideUIPanel(rightFrame, UIPANEL_SKIP_SET_POINT);
		end
	end

	found = securecall("CloseSpecialWindows") or found;
	
	UpdateUIPanelPositions();

	return found;
end

function CloseAllWindows_WithExceptions()
	-- When the player loses control we close all UIs, unless they're handled below
	local centerFrame = GetUIPanel("center");
	local ignoreCenter = (centerFrame and GetUIPanelWindowInfo(centerFrame, "ignoreControlLost")) or IsOptionFrameOpen();
	
	CloseAllWindows(ignoreCenter);
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
	local anyClosed = (bagsVisible or windowsVisible);
	if (anyClosed and CanAutoSetGamePadCursorControl(false)) then
		SetGamePadCursorControl(false);
	end
	return anyClosed;
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

function MaximizeUIPanel(currentFrame, maximizePoint)
	FramePositionDelegate:SetAttribute("panel-frame", currentFrame)
	FramePositionDelegate:SetAttribute("panel-maximize", true);
end

function RestoreUIPanelArea(currentFrame)
	FramePositionDelegate:SetAttribute("panel-frame", currentFrame)
	FramePositionDelegate:SetAttribute("panel-restore", true);
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
		-- How long to keep the frame flashing, -1 means forever
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

function GetScaledCursorPosition()
	local uiScale = UIParent:GetEffectiveScale();
	local x, y = GetCursorPosition();
	return x / uiScale, y / uiScale;
end

function GetScaledCursorDelta()
	local uiScale = _UIParentGetEffectiveScale(_UIParentRef);
	local x, y = GetCursorDelta();
	return x / uiScale, y / uiScale;
end

function MouseIsOver(region, topOffset, bottomOffset, leftOffset, rightOffset)
	return region:IsMouseOver(topOffset, bottomOffset, leftOffset, rightOffset);
end

-- replace the C functions with local lua versions
function getglobal(varr)
	return _G[varr];
end

local forceinsecure = forceinsecure;
function setglobal(varr,value)
	forceinsecure();
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

function OrderHallMissionFrame_EscapePressed()
	return OrderHallMissionFrame and OrderHallMissionFrame.EscapePressed and OrderHallMissionFrame:EscapePressed();
end

function OrderHallTalentFrame_EscapePressed()
	return OrderHallTalentFrame and OrderHallTalentFrame.EscapePressed and OrderHallTalentFrame:EscapePressed();
end

function BFAMissionFrame_EscapePressed()
	return BFAMissionFrame and BFAMissionFrame.EscapePressed and BFAMissionFrame:EscapePressed();
end

-- Function that handles the escape key functions
function ToggleGameMenu()
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
	elseif ( VideoOptionsFrame:IsShown() ) then
		VideoOptionsFrameCancel:Click();
	elseif ( AudioOptionsFrame:IsShown() ) then
		AudioOptionsFrameCancel:Click();
	elseif ( SocialBrowserFrame and SocialBrowserFrame:IsShown() ) then
		SocialBrowserFrame:Hide();
	elseif ( InterfaceOptionsFrame:IsShown() ) then
		InterfaceOptionsFrameCancel:Click();
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
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
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
		local dialog = StaticPopup_Show("CONVERT_TO_RAID");
		if ( dialog ) then
			dialog.data = name;
		end
	else
		InviteUnit(name);
	end
end

function GetSocialColoredName(displayName, guid)
	local _, color, relationship = SocialQueueUtil_GetRelationshipInfo(guid);
	if ( relationship ) then
		return color..displayName..FONT_COLOR_CODE_CLOSE;
	end
	return displayName;
end

function UpdateInviteConfirmationDialogs()
	if ( StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION") ) then
		return;
	end

	local firstInvite = GetNextPendingInviteConfirmation();
	if ( not firstInvite ) then
		return;
	end

	local confirmationType, name, guid, rolesInvalid, willConvertToRaid = GetInviteConfirmationInfo(firstInvite);
	local text = "";
	if ( confirmationType == LE_INVITE_CONFIRMATION_REQUEST ) then
		local suggesterGuid, suggesterName, relationship, isQuickJoin = GetInviteReferralInfo(firstInvite);

		--If we ourselves have a relationship with this player, we'll just act as if they asked through us.
		local _, color, selfRelationship, playerLink = SocialQueueUtil_GetRelationshipInfo(guid, name);
		local safeLink = playerLink and "["..playerLink.."]" or name;

		if ( selfRelationship ) then
			if ( isQuickJoin ) then
				text = text..INVITE_CONFIRMATION_REQUEST_QUICKJOIN:format(color..safeLink..FONT_COLOR_CODE_CLOSE);
			else
				text = text..INVITE_CONFIRMATION_REQUEST:format(color..name..FONT_COLOR_CODE_CLOSE);
			end
		elseif ( suggesterGuid ) then
			suggesterName = GetSocialColoredName(suggesterName, suggesterGuid);

			if ( relationship == LE_INVITE_CONFIRMATION_RELATION_FRIEND ) then
				if ( isQuickJoin ) then
					text = text..INVITE_CONFIRMATION_REQUEST_FRIEND_QUICKJOIN:format(suggesterName, color..safeLink..FONT_COLOR_CODE_CLOSE);
				else
					text = text..INVITE_CONFIRMATION_REQUEST_FRIEND:format(suggesterName, name);
				end
			elseif ( relationship == LE_INVITE_CONFIRMATION_RELATION_GUILD ) then
				if ( isQuickJoin ) then
					text = text..string.format(INVITE_CONFIRMATION_REQUEST_GUILD_QUICKJOIN, suggesterName, color..safeLink..FONT_COLOR_CODE_CLOSE);
				else
					text = text..string.format(INVITE_CONFIRMATION_REQUEST_GUILD, suggesterName, name);
				end
			else
				if ( isQuickJoin ) then
					text = text..string.format(INVITE_CONFIRMATION_REQUEST, color..safeLink..FONT_COLOR_CODE_CLOSE);
				else
					text = text..string.format(INVITE_CONFIRMATION_REQUEST, name);
				end
			end
		else
			if ( isQuickJoin ) then
				text = text..string.format(INVITE_CONFIRMATION_REQUEST_QUICKJOIN, color..safeLink..FONT_COLOR_CODE_CLOSE);
			else
				text = text..string.format(INVITE_CONFIRMATION_REQUEST, name);
			end
		end
	elseif ( confirmationType == LE_INVITE_CONFIRMATION_SUGGEST ) then
		local suggesterGuid, suggesterName, relationship, isQuickJoin = GetInviteReferralInfo(firstInvite);
		suggesterName = GetSocialColoredName(suggesterName, suggesterGuid);
		name = GetSocialColoredName(name, guid);

		-- Only using a single string here, if somebody is suggesting a person to join the group, QuickJoin text doesn't apply.
		text = text..string.format(INVITE_CONFIRMATION_SUGGEST, suggesterName, name);
	end

	local invalidQueues = C_PartyInfo.GetInviteConfirmationInvalidQueues(firstInvite);
	if ( invalidQueues and #invalidQueues > 0 ) then
		if ( text ~= "" ) then
			text = text.."\n\n"
		end

		if ( rolesInvalid ) then
			text = text..string.format(INSTANCE_UNAVAILABLE_OTHER_NO_VALID_ROLES, name).."\n";
		end
		text = text..string.format(INVITE_CONFIRMATION_QUEUE_WARNING, name);
		for i=1, #invalidQueues do
			local queueName = SocialQueueUtil_GetQueueName(invalidQueues[i]);
			text = text.."\n"..NORMAL_FONT_COLOR_CODE..queueName..FONT_COLOR_CODE_CLOSE;
		end
	end

	if ( willConvertToRaid ) then
		text = text.."\n\n"..RED_FONT_COLOR_CODE..LFG_LIST_CONVERT_TO_RAID_WARNING..FONT_COLOR_CODE_CLOSE;
	end

	StaticPopup_Show("GROUP_INVITE_CONFIRMATION", text, nil, firstInvite);
end

function UnitHasMana(unit)
	if ( UnitPowerMax(unit, Enum.PowerType.Mana) > 0 ) then
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
	local name, icon, count, debuffType, duration, expirationTime;

	local filter;
	if ( checkCVar and SHOW_CASTABLE_BUFFS == "1" and UnitCanAssist("player", unit) ) then
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
	if ( checkCVar and SHOW_DISPELLABLE_DEBUFFS == "1" and UnitCanAssist("player", unit) ) then
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
			--[[local coolDown = _G[debuffName.."Cooldown"];
			if ( coolDown ) then
				CooldownFrame_Set(coolDown, expirationTime - duration, duration, true);
			end]]

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

function RaidBrowser_IsEmpowered()
	return (not IsInGroup()) or UnitIsGroupLeader("player");
end

function GetLFGMode(category, lfgID)
	--[[if ( category ~= LE_LFG_CATEGORY_RF ) then
		lfgID = nil; --HACK - RF works differently from everything else. You can queue for multiple RF slots with different ride tickets.
	end

	local proposalExists, id, typeID, subtypeID, name, texture, role, hasResponded, totalEncounters, completedEncounters, numMembers, isLeader, isHoliday, proposalCategory = GetLFGProposal();
	local inParty, joined, queued, noPartialClear, achievements, lfgComment, slotCount = GetLFGInfoServer(category, lfgID);
	local roleCheckInProgress, slots, members, roleUpdateCategory, roleUpdateID = GetLFGRoleUpdate();

	local partyCategory = nil;
	local partySlot = GetPartyLFGID();
	if ( partySlot ) then
		partyCategory = GetLFGCategoryForID(partySlot);
	end


	local empoweredFunc = LFD_IsEmpowered;
	if ( category == LE_LFG_CATEGORY_LFR ) then
		empoweredFunc = RaidBrowser_IsEmpowered;
	end
	if ( proposalExists and not hasResponded and proposalCategory == category and (not lfgID or lfgID == id) ) then
		return "proposal", "unaccepted";
	elseif ( proposalExists and proposalCategory == category and (not lfgID or lfgID == id) ) then
		return "proposal", "accepted";
	elseif ( queued ) then
		return "queued", (empoweredFunc() and "empowered" or "unempowered");
	elseif ( roleCheckInProgress and roleUpdateCategory == category and (not lfgID or lfgID == roleUpdateID) ) then
		return "rolecheck";
	elseif ( category == LE_LFG_CATEGORY_LFR and joined ) then
		return "listed", (empoweredFunc() and "empowered" or "unempowered");
	elseif ( joined ) then
		return "suspended", (empoweredFunc() and "empowered" or "unempowered");	--We are "joined" to LFG, but not actually queued right now.
	elseif ( IsInGroup() and IsPartyLFG() and partyCategory == category and (not lfgID or lfgID == partySlot) ) then
		if IsAllowedToUserTeleport() then
			return "lfgparty", "teleport";
		end
		if IsLFGComplete() then
			return "lfgparty", "complete";
		end
		return "lfgparty", "noteleport";
	elseif ( IsPartyLFG() and IsInLFGDungeon() and partyCategory == category and (not lfgID or lfgID == partySlot) ) then
		return "abandonedInDungeon";
	end]]
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

function OnExcessiveErrors()
	StaticPopup_Show("TOO_MANY_LUA_ERRORS");
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

local displayedCapMessage = false;
function TrialAccountCapReached_Inform(capType)
	if ( displayedCapMessage or not GameLimitedMode_IsActive() ) then
		return;
	end


	local info = ChatTypeInfo.SYSTEM;
	if ( capType == "level" ) then
		DEFAULT_CHAT_FRAME:AddMessage(CAPPED_LEVEL_TRIAL, info.r, info.g, info.b);
	elseif ( capType == "money" ) then
		DEFAULT_CHAT_FRAME:AddMessage(CAPPED_MONEY_TRIAL, info.r, info.g, info.b);
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

function GetTimeStringFromSeconds(timeAmount, hasMS, dropZeroHours)
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
	if ( dropZeroHours and hours == 0 ) then
		return format(MINUTES_SECONDS, minutes, seconds);
	else
		return format(HOURS_MINUTES_SECONDS, hours, minutes, seconds);
	end
--	end
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

function ConfirmOrLeaveLFGParty()
	if ( not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
		return;
	end

	if ( IsPartyLFG() and not IsLFGComplete() ) then
		local partyLFGSlot = GetPartyLFGID();
		local partyLFGCategory = nil;
		if ( partyLFGSlot ) then
			partyLFGCategory = GetLFGCategoryForID(partyLFGSlot);
		end
		StaticPopup_Show("CONFIRM_LEAVE_INSTANCE_PARTY", partyLFGCategory == LE_LFG_CATEGORY_WORLDPVP and CONFIRM_LEAVE_BATTLEFIELD or CONFIRM_LEAVE_INSTANCE_PARTY);
	else
		LeaveInstanceParty();
	end
end

function ConfirmOrLeaveBattlefield()
	if ( GetBattlefieldWinner() ) then
		LeaveBattlefield();
	else
		StaticPopup_Show("CONFIRM_LEAVE_BATTLEFIELD");
	end
end

function BuildIconArray(parent, baseName, template, rowSize, numRows, onButtonCreated)
	local previousButton = CreateFrame("CheckButton", baseName.."1", parent, template);
	local cornerButton = previousButton;
	previousButton:SetID(1);
	previousButton:SetPoint("TOPLEFT", 26, -85);
	if ( onButtonCreated ) then
		onButtonCreated(parent, previousButton);
	end

	local numIcons = rowSize * numRows;
	for i = 2, numIcons do
		local newButton = CreateFrame("CheckButton", baseName..i, parent, template);
		newButton:SetID(i);
		if ( i % rowSize == 1 ) then
			newButton:SetPoint("TOPLEFT", cornerButton, "BOTTOMLEFT", 0, -8);
			cornerButton = newButton;
		else
			newButton:SetPoint("LEFT", previousButton, "RIGHT", 10, 0);
		end

		previousButton = newButton;
		newButton:Hide();
		if ( onButtonCreated ) then
			onButtonCreated(parent, newButton);
		end
	end
end

function GetSmoothProgressChange(value, displayedValue, range, elapsed, minPerSecond, maxPerSecond)
	maxPerSecond = maxPerSecond or 0.7;
	minPerSecond = minPerSecond or 0.3;
	minPerSecond = max(minPerSecond, 1/range);	--Make sure we're moving at least 1 unit/second (will only matter if our maximum power is 3 or less);

	local diff = displayedValue - value;
	local diffRatio = diff / range;
	local change = range * ((minPerSecond/abs(diffRatio) + maxPerSecond - minPerSecond) * diffRatio) * elapsed;
	if ( abs(change) > abs(diff) or abs(diffRatio) < 0.01 ) then
		return value;
	else
		return displayedValue - change;
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
	--[[if ( IsInGroup() ) then
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
	end]]
	return "INVITE";
end

function nop()
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

-- Currency Overflow --
function WillCurrencyRewardOverflow(currencyID, rewardQuantity)
	local name, quantity, icon, earnedThisWeek, weeklyMax, maxQuantity, discovered, rarity = GetCurrencyInfo(currencyID);
	return maxQuantity > 0 and rewardQuantity + quantity > maxQuantity;
end

function GetColorForCurrencyReward(currencyID, rewardQuantity, defaultColor)
	if WillCurrencyRewardOverflow(currencyID, rewardQuantity) then
		return RED_FONT_COLOR;
	elseif defaultColor then
		return defaultColor;
	else
		return HIGHLIGHT_FONT_COLOR;
	end
end

function GetSortedSelfResurrectOptions()
	local options = C_DeathInfo.GetSelfResurrectOptions();
	if ( not options ) then
		return nil;
	end
	table.sort(options, function(a, b)
		if ( a.canUse ~= b.canUse ) then
			return a.canUse;
		end
		if ( a.isLimited ~= b.isLimited ) then
			return not a.isLimited;
		end
		-- lowest priority is first
		return a.priority < b.priority end
	);
	return options;
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

function IsPlayerAtEffectiveMaxLevel()
	return IsLevelAtEffectiveMaxLevel(UnitLevel("player"));
end

-- From SocialQueue.lua
function SocialQueueUtil_GetRelationshipInfo(guid, missingNameFallback, clubId)
	local hasFocus, characterName, client, realmName, realmID, faction, race, class, _, zoneName, level, gameText, broadcast, broadcastTime, online, bnetIDGameAccount, bnetIDAccount = BNGetGameAccountInfoByGUID(guid);
	if ( characterName and bnetIDAccount ) then
		local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount, client, isOnline, lastOnline, isBnetAFK, isBnetDND, messageText, noteText, isRIDFriend, messageTime = BNGetFriendInfoByID(bnetIDAccount);
		if ( accountName ) then
			return accountName, FRIENDS_BNET_NAME_COLOR_CODE, "bnfriend", GetBNPlayerLink(accountName, accountName, bnetIDAccount, 0, 0, 0);
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

function DisplayInterfaceActionBlockedMessage()
	if ( not INTERFACE_ACTION_BLOCKED_SHOWN ) then
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(INTERFACE_ACTION_BLOCKED, info.r, info.g, info.b, info.id);
		INTERFACE_ACTION_BLOCKED_SHOWN = true;
	end
end