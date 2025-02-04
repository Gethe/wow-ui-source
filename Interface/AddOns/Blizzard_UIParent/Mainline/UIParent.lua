TOOLTIP_UPDATE_TIME = 0.2;
BOSS_FRAME_CASTBAR_HEIGHT = 16;

-- Pulsing stuff
PULSEBUTTONS = {};

-- Shine animation
SHINES_TO_ANIMATE = {};

-- Macros
MAX_ACCOUNT_MACROS = 120;
MAX_CHARACTER_MACROS = 30;

CVarCallbackRegistry:SetCVarCachable("showCastableBuffs");
CVarCallbackRegistry:SetCVarCachable("showDispelDebuffs");

-- These are windows that rely on a parent frame to be open.  If the parent closes or a pushable frame overlaps them they must be hidden.
UIChildWindows = {
	"OpenMailFrame",
	"GuildMemberDetailFrame",
	"GuildBankPopupFrame",
	"GearManagerDialog",
};

function GetNotchHeight()
    local notchHeight = 0;

    if (C_UI.ShouldUIParentAvoidNotch()) then
        notchHeight = select(4, C_UI.GetTopLeftNotchSafeRegion());
        if (notchHeight) then
            local _, physicalHeight = GetPhysicalScreenSize();
            local normalizedHeight = notchHeight / physicalHeight;
            local _, uiParentHeight = UIParent:GetSize();
            notchHeight = normalizedHeight * uiParentHeight;
        end
    end

	return notchHeight;
end

-- Hooked by DesignerBar.lua if that addon is loaded
function GetUIParentOffset()
    local notchHeight = GetNotchHeight();
	local debugBarsHeight = DebugBarManager:GetTotalHeight();
	return math.max(debugBarsHeight, notchHeight);
end

function UpdateUIParentPosition()
	local topOffset = GetUIParentOffset();
	UIParent:SetPoint("TOPLEFT", 0, -topOffset);
end

function UpdateUIElementsForClientScene(sceneType)
	if sceneType == Enum.ClientSceneType.MinigameSceneType then
		PlayerFrame:Hide();
		TargetFrame:Hide();
	else
		PlayerFrame:SetShown(true);
		TargetFrame:Update();
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
	"DropDownList1",
	"DropDownList2",
	"DropDownList3",
};

ITEM_QUALITY_COLORS = { };
for i = 0, Enum.ItemQualityMeta.NumValues - 1 do
	local r, g, b = C_Item.GetItemQualityColor(i);
	local color = CreateColor(r, g, b, 1);
	ITEM_QUALITY_COLORS[i] = { r = r, g = g, b = b, hex = color:GenerateHexColorMarkup(), color = color };
end

WORLD_QUEST_QUALITY_COLORS = {
	[Enum.WorldQuestQuality.Common] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Common];
	[Enum.WorldQuestQuality.Rare] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Rare];
	[Enum.WorldQuestQuality.Epic] = ITEM_QUALITY_COLORS[Enum.ItemQuality.Epic];
};

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
	self:RegisterEvent("PLAYER_CAMPING");
	self:RegisterEvent("PLAYER_QUITING");
	self:RegisterEvent("LOGOUT_CANCEL");
	self:RegisterEvent("LOOT_BIND_CONFIRM");
	self:RegisterEvent("EQUIP_BIND_CONFIRM");
	self:RegisterEvent("EQUIP_BIND_REFUNDABLE_CONFIRM");
	self:RegisterEvent("EQUIP_BIND_TRADEABLE_CONFIRM");
	self:RegisterEvent("USE_BIND_CONFIRM");
	self:RegisterEvent("CONVERT_TO_BIND_TO_ACCOUNT_CONFIRM");
	self:RegisterEvent("USE_NO_REFUND_CONFIRM");
	self:RegisterEvent("CONFIRM_BEFORE_USE");
	self:RegisterEvent("DELETE_ITEM_CONFIRM");
	self:RegisterEvent("QUEST_ACCEPT_CONFIRM");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	self:RegisterEvent("CURSOR_CHANGED");
	self:RegisterEvent("LOCALPLAYER_PET_RENAMED");
	self:RegisterEvent("SETTINGS_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
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
	self:RegisterEvent("ACTION_WILL_BIND_ITEM");
	self:RegisterEvent("REPLACE_ENCHANT");
	self:RegisterEvent("REPLACE_TRADESKILL_ENCHANT");
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
	self:RegisterEvent("DAILY_RESET_INSTANCE_WELCOME");
	self:RegisterEvent("INSTANCE_RESET_WARNING");
	self:RegisterEvent("RAISED_AS_GHOUL");
	self:RegisterEvent("SPELL_CONFIRMATION_PROMPT");
	self:RegisterEvent("SPELL_CONFIRMATION_TIMEOUT");
	self:RegisterEvent("SAVED_VARIABLES_TOO_LARGE");
	self:RegisterEvent("EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED");
	self:RegisterEvent("BAG_OVERFLOW_WITH_FULL_INVENTORY");
	self:RegisterEvent("AUCTION_HOUSE_SCRIPT_DEPRECATED");
	self:RegisterEvent("LOADING_SCREEN_ENABLED");
	self:RegisterEvent("LOADING_SCREEN_DISABLED");
	self:RegisterEvent("CVAR_UPDATE");
	self:RegisterEvent("LEAVING_TUTORIAL_AREA");
	self:RegisterEvent("UI_ERROR_POPUP");
	self:RegisterEvent("ALERT_REGIONAL_CHAT_DISABLED");
	self:RegisterEvent("UI_SCALE_CHANGED");

	-- Events for auction UI handling
	self:RegisterEvent("AUCTION_HOUSE_SHOW");
	self:RegisterEvent("AUCTION_HOUSE_CLOSED");
	self:RegisterEvent("AUCTION_HOUSE_DISABLED");
	self:RegisterEvent("AUCTION_HOUSE_SHOW_FORMATTED_NOTIFICATION");
	self:RegisterEvent("AUCTION_HOUSE_SHOW_NOTIFICATION")

	-- Events for trade skill UI handling
	self:RegisterEvent("TRADE_SKILL_SHOW");
	self:RegisterEvent("CRAFTING_HOUSE_DISABLED");
	self:RegisterEvent("CRAFTINGORDERS_SHOW_CUSTOMER");
	self:RegisterEvent("CRAFTINGORDERS_HIDE_CUSTOMER");
	self:RegisterEvent("CRAFTINGORDERS_SHOW_CRAFTER");
	self:RegisterEvent("CRAFTINGORDERS_HIDE_CRAFTER");
	self:RegisterEvent("PROFESSION_EQUIPMENT_CHANGED");
	self:RegisterEvent("PROFESSION_RESPEC_CONFIRMATION");

	-- Events for Item socketing UI
	self:RegisterEvent("SOCKET_INFO_UPDATE");

	-- Events for Artifact UI
	self:RegisterEvent("ARTIFACT_UPDATE");
	self:RegisterEvent("ARTIFACT_RESPEC_PROMPT");
	self:RegisterEvent("ARTIFACT_RELIC_FORGE_UPDATE");

	-- Events for Adventure Map UI
	self:RegisterEvent("ADVENTURE_MAP_OPEN");

	-- Events for taxi benchmarking
	self:RegisterEvent("ENABLE_TAXI_BENCHMARK");
	self:RegisterEvent("DISABLE_TAXI_BENCHMARK");

	-- Events for BarberShop Handling
	self:RegisterEvent("BARBER_SHOP_OPEN");
	self:RegisterEvent("BARBER_SHOP_CLOSE");

	-- Events for PerksProgram Handling
	self:RegisterEvent("PERKS_PROGRAM_OPEN");
	self:RegisterEvent("PERKS_PROGRAM_DISABLED");

	--Events for GMChatUI
	self:RegisterEvent("CHAT_MSG_WHISPER");

	-- Events for WoW Mouse
	self:RegisterEvent("WOW_MOUSE_NOT_FOUND");

	-- Events for talent wipes
	self:RegisterEvent("TALENTS_INVOLUNTARILY_RESET");

    -- Events for disabled specs
    self:RegisterEvent("SPEC_INVOLUNTARILY_CHANGED");

	-- Events for Archaeology
	self:RegisterEvent("ARCHAEOLOGY_TOGGLE");
	self:RegisterEvent("ARCHAEOLOGY_SURVEY_CAST");

	-- Events for Trial caps
	self:RegisterEvent("TRIAL_CAP_REACHED_MONEY");
	self:RegisterEvent("TRIAL_CAP_REACHED_LEVEL");

	-- Events for Toy Box
	self:RegisterEvent("TOYS_UPDATED");

	-- Events for Heirlooms Journal
	self:RegisterEvent("HEIRLOOM_UPGRADE_TARGETING_CHANGED");
	self:RegisterEvent("HEIRLOOMS_UPDATED");

	-- Events for Wardrobe
	self:RegisterEvent("TRANSMOG_COLLECTION_UPDATED");

	-- Events for Player Choice
	self:RegisterEvent("PLAYER_CHOICE_UPDATE");

	-- Lua warnings
	self:RegisterEvent("LUA_WARNING");

	-- Garrison
	self:RegisterEvent("GARRISON_MISSION_NPC_OPENED");
	self:RegisterEvent("GARRISON_MISSION_NPC_CLOSED");
	self:RegisterEvent("GARRISON_SHIPYARD_NPC_OPENED");
	self:RegisterEvent("GARRISON_SHIPYARD_NPC_CLOSED");
	self:RegisterEvent("SHIPMENT_CRAFTER_OPENED");

	self:RegisterEvent("GARRISON_MONUMENT_SHOW_UI");
	self:RegisterEvent("GARRISON_RECRUITMENT_NPC_OPENED");
	self:RegisterEvent("GARRISON_TALENT_NPC_OPENED");
	self:RegisterEvent("BEHAVIORAL_NOTIFICATION");

	-- Shop (for Asia promotion)
	self:RegisterEvent("PRODUCT_DISTRIBUTIONS_UPDATED");

	self:RegisterEvent("TOKEN_AUCTION_SOLD");

	-- Challenge Mode 2.0
	self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN");
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED");

	-- Used for Order Hall UI
	self:RegisterUnitEvent("UNIT_AURA", "player");

	self:RegisterEvent("TAXIMAP_OPENED");

	-- Used to determine when to load BoostTutorial
	self:RegisterEvent("SCENARIO_UPDATE");

	-- Invite confirmations
	self:RegisterEvent("GROUP_INVITE_CONFIRMATION");
	self:RegisterEvent("INVITE_TO_PARTY_CONFIRMATION");

	-- Event(s) for the ArtifactUI
	self:RegisterEvent("ARTIFACT_ENDGAME_REFUND");

	-- Event(s) for PVP
	self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS");
	self:RegisterEvent("PVP_BRAWL_INFO_UPDATED");

	-- Event(s) for Allied Races
	self:RegisterEvent("ALLIED_RACE_OPEN");

	-- Event(s) for Islands
	self:RegisterEvent("ISLAND_COMPLETED");

	-- Event(s) for Warfronts
	self:RegisterEvent("WARFRONT_COMPLETED");

	-- Event(s) for Party Pose
	self:RegisterEvent("SHOW_PARTY_POSE_UI");

	-- Events for Reporting SYSTEM
	self:RegisterEvent("REPORT_PLAYER_RESULT");

	-- Events for Global Mouse Down
	self:RegisterEvent("GLOBAL_MOUSE_DOWN");
	self:RegisterEvent("GLOBAL_MOUSE_UP");

	-- Event(s) for Covenant Preview UI
	self:RegisterEvent("COVENANT_PREVIEW_OPEN");

	-- Event(s) for Anima Diversion UI
	self:RegisterEvent("ANIMA_DIVERSION_OPEN");

	-- Event(s) for Runeforge UI
	self:RegisterEvent("RUNEFORGE_LEGENDARY_CRAFTING_OPENED");

	 -- Events for Trait Systems
    self:RegisterEvent("TRAIT_SYSTEM_INTERACTION_STARTED");

	-- Event(s) for the ScriptAnimationEffect System
	self:RegisterEvent("SCRIPTED_ANIMATIONS_UPDATE");

    -- Event(s) for Notched displays
    self:RegisterEvent("NOTCHED_DISPLAY_MODE_CHANGED");

    -- Event(s) for Client Scenes
    self:RegisterEvent("CLIENT_SCENE_OPENED");
    self:RegisterEvent("CLIENT_SCENE_CLOSED");

	-- Event(s) for returning player prompts
	self:RegisterEvent("RETURNING_PLAYER_PROMPT");

	--Event(s) for soft targetting
	self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED");

	-- Tooltip data events that need to go to GameTooltip
	self:RegisterEvent("SHOW_HYPERLINK_TOOLTIP");
	self:RegisterEvent("HIDE_HYPERLINK_TOOLTIP");
	self:RegisterEvent("WORLD_CURSOR_TOOLTIP_UPDATE");

	-- Event(s) for ping system
	self:RegisterEvent("PING_SYSTEM_ERROR");

	-- Event(s) for PlayerSpells
	self:RegisterEvent("USE_GLYPH");

	-- Event(s) for Enchanting
	self:RegisterEvent("ENCHANT_SPELL_SELECTED");

	-- Events(s) for updating spell based item contexts
	self:RegisterEvent("UPDATE_SPELL_TARGET_ITEM_CONTEXT");

	-- Events(s) for Remix Event
	self:RegisterEvent("REMIX_END_OF_EVENT");
end

function UIParent_OnShow(self)
	if ( self.firstTimeLoaded ~= 1 ) then
		CloseAllWindows();
		self.firstTimeLoaded = nil;
	end

	if ( LowHealthFrame ) then
		LowHealthFrame:EvaluateVisibleState();
	end

	if ActionStatus then
		ActionStatus:UpdateParent();
	end

	if ( UIParentBottomManagedFrameContainer ) then
		UIParentBottomManagedFrameContainer:UpdateManagedFrames();
	end
	if ( UIParentRightManagedFrameContainer ) then
		UIParentRightManagedFrameContainer:UpdateManagedFrames();
	end

	C_AddOns.LoadAddOn("Blizzard_AccountStore");
	AccountStoreFrame:SetStoreFrontID(Constants.AccountStoreConsts.PlunderstormStoreFrontID);
end

function UIParent_OnHide(self)
	if ( LowHealthFrame ) then
		LowHealthFrame:EvaluateVisibleState();
	end

	if ActionStatus then
		ActionStatus:UpdateParent();
	end
	if ( UIParentBottomManagedFrameContainer ) then
		UIParentBottomManagedFrameContainer:ClearManagedFrames();
	end
	if ( UIParentRightManagedFrameContainer ) then
		UIParentRightManagedFrameContainer:ClearManagedFrames();
	end
end

-- Addons --

local FailedAddOnLoad = {};

function UIParentLoadAddOn(name)
	local loaded, reason = C_AddOns.LoadAddOn(name);
	if ( not loaded ) then
		if ( not FailedAddOnLoad[name] ) then
			message(format(ADDON_LOAD_FAILED, name, _G["ADDON_"..reason]));
			FailedAddOnLoad[name] = true;
		end
	end
	return loaded;
end

function ItemInteraction_LoadUI()
	UIParentLoadAddOn("Blizzard_ItemInteractionUI");
end

function IslandsQueue_LoadUI()
	UIParentLoadAddOn("Blizzard_IslandsQueueUI");
end

function PartyPose_LoadUI()
	UIParentLoadAddOn("Blizzard_PartyPoseUI");
end

function IslandsPartyPose_LoadUI()
	UIParentLoadAddOn("Blizzard_IslandsPartyPoseUI");
end

function WarfrontsPartyPose_LoadUI()
	UIParentLoadAddOn("Blizzard_WarfrontsPartyPoseUI");
end

function MatchCelebrationPartyPose_LoadUI()
	UIParentLoadAddOn("Blizzard_MatchCelebrationPartyPoseUI");
end

function AlliedRaces_LoadUI()
	UIParentLoadAddOn("Blizzard_AlliedRacesUI");
end

function AuctionHouseFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_AuctionHouseUI");
end

function ProfessionsCustomerOrders_LoadUI()
	UIParentLoadAddOn("Blizzard_ProfessionsCustomerOrders");
end

function BattlefieldMap_LoadUI()
	UIParentLoadAddOn("Blizzard_BattlefieldMap");
end

function ClassTrainerFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_TrainerUI");
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

function ClickBindingFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ClickBindingUI");
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

function PlayerSpellsFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_PlayerSpells");
end

function ProfessionsBook_LoadUI()
	UIParentLoadAddOn("Blizzard_ProfessionsBook");
end

function ProfessionsFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_Professions");
end

function ObliterumForgeFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ObliterumUI");
end

function ScrappingMachineFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ScrappingMachineUI");
end

function ItemSocketingFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ItemSocketingUI");
end

function ArtifactFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ArtifactUI");
end

function AdventureMapFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_AdventureMap");
end

function BarberShopFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_BarberShopUI");
end

function PerksProgramFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_PerksProgram");
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

function Calendar_LoadUI()
	UIParentLoadAddOn("Blizzard_Calendar");
end

function VoidStorage_LoadUI()
	UIParentLoadAddOn("Blizzard_VoidStorageUI");
end

function ArchaeologyFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ArchaeologyUI");
end

function GMChatFrame_LoadUI(...)
	if ( C_AddOns.IsAddOnLoaded("Blizzard_GMChatUI") ) then
		return;
	else
		UIParentLoadAddOn("Blizzard_GMChatUI");
		if ( select(1, ...) ) then
			GMChatFrame_OnEvent(GMChatFrame, ...);
		end
	end
end

function EncounterJournal_LoadUI()
	UIParentLoadAddOn("Blizzard_EncounterJournal");
end

function CollectionsJournal_LoadUI()
	if C_GameRules.IsGameRuleActive(Enum.GameRule.CollectionsPanelDisabled) then
		return;
	end
	UIParentLoadAddOn("Blizzard_Collections");
end

function BlackMarket_LoadUI()
	UIParentLoadAddOn("Blizzard_BlackMarketUI");
end

function ItemUpgrade_LoadUI()
	-- ACHURCHILL TODO: remove once item upgrade testing is done
	if not OldItemUpgradeFrame then
		UIParentLoadAddOn("Blizzard_ItemUpgradeUI");
	end
end

function PlayerChoice_LoadUI()
	UIParentLoadAddOn("Blizzard_PlayerChoice");
end

function Garrison_LoadUI()
	UIParentLoadAddOn("Blizzard_GarrisonUI");
end

function OrderHall_LoadUI()
	UIParentLoadAddOn("Blizzard_OrderHallUI");
end

function MajorFactions_LoadUI()
	UIParentLoadAddOn("Blizzard_MajorFactions");
end

function ChallengeMode_LoadUI()
	UIParentLoadAddOn("Blizzard_ChallengesUI");
end

function FlightMap_LoadUI()
	UIParentLoadAddOn("Blizzard_FlightMap");
end

function APIDocumentation_LoadUI()
	UIParentLoadAddOn("Blizzard_APIDocumentationGenerated");
end

function CovenantSanctum_LoadUI()
	UIParentLoadAddOn("Blizzard_CovenantSanctum");
end

function CovenantRenown_LoadUI()
	UIParentLoadAddOn("Blizzard_CovenantRenown");
end

function WeeklyRewards_LoadUI()
	UIParentLoadAddOn("Blizzard_WeeklyRewards");
end

function WeeklyRewards_ShowUI()
	if not WeeklyRewardsFrame then
		WeeklyRewards_LoadUI();
	end

	local force = true;	-- this could be called from the world map which might be in fullscreen mode
	ShowUIPanel(WeeklyRewardsFrame, force);
end

--[[
function MovePad_LoadUI()
	UIParentLoadAddOn("Blizzard_MovePad");
end
]]

function NPE_CheckTutorials()
	if C_PlayerInfo.IsPlayerNPERestricted() and UnitLevel("player") == 1 then
		-- Hacky 9.0.1 fix for WOW9-58485...just force tutorials to on if they are entering Exile's Reach on a level 1 character
		SetCVar("showTutorials", 1);
	end

	NPE_LoadUI();
end

function NPE_LoadUI()
	if ( not GetTutorialsEnabled() or C_AddOns.IsAddOnLoaded("Blizzard_NewPlayerExperience") ) then
		return;
	end
	local isRestricted = C_PlayerInfo.IsPlayerNPERestricted();
	if  isRestricted then
		UIParentLoadAddOn("Blizzard_NewPlayerExperience");
	end
end

function BoostTutorial_AttemptLoad()
	if IsBoostTutorialScenario() and not C_AddOns.IsAddOnLoaded("Blizzard_BoostTutorial") then
		UIParentLoadAddOn("Blizzard_BoostTutorial");
	end
end

function ClassTrial_IsExpansionTrialUpgradeDialogShowing()
	if ExpansionTrialThanksForPlayingDialog then
		return ExpansionTrialThanksForPlayingDialog:IsShowingExpansionTrialUpgrade();
	end

	if ExpansionTrialCheckPointDialog then
		return ExpansionTrialCheckPointDialog:IsShowingExpansionTrialUpgrade();
	end

	return false;
end

function ExpansionTrial_CheckLoadUI()
	local isExpansionTrial = GetExpansionTrialInfo();
	if isExpansionTrial then
		UIParentLoadAddOn("Blizzard_ExpansionTrial");
	end
end

function DeathRecap_LoadUI()
	UIParentLoadAddOn("Blizzard_DeathRecap");
end

function AzeriteRespecFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_AzeriteRespecUI");
end

function ChromieTimeFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_ChromieTimeUI");
end

function CovenantPreviewFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_CovenantPreviewUI");
end

function AnimaDiversionFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_AnimaDiversionUI");
end

function RuneforgeFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_RuneforgeUI");
end

function GenericTraitUI_LoadUI()
	UIParentLoadAddOn("Blizzard_GenericTraitUI");
end

function SubscriptionInterstitial_LoadUI()
	C_AddOns.LoadAddOn("Blizzard_SubscriptionInterstitialUI");
end

local playerEnteredWorld = false;
local varsLoaded = false;
function NPETutorial_AttemptToBegin(event)
	if( event == "PLAYER_ENTERING_WORLD" ) then
		playerEnteredWorld = true;
	elseif ( event == "VARIABLES_LOADED" ) then
		varsLoaded = true;
	end
	if ( playerEnteredWorld and varsLoaded ) then
		NPE_CheckTutorials();
	end
end

function OrderHall_CheckCommandBar()
	if (not OrderHallCommandBar or not OrderHallCommandBar:IsShown()) then
		if (C_Garrison.IsPlayerInGarrison(Enum.GarrisonType.Type_7_0_Garrison)) then
			OrderHall_LoadUI();
			OrderHallCommandBar:Show();
		end
	end
end

function ShowMacroFrame()
	if ( DISALLOW_FRAME_TOGGLING ) then
		return;
	end

	local macrosDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.MacrosDisabled);
	if macrosDisabled then
		return;
	end

	MacroFrame_LoadUI();
	if ( MacroFrame_Show ) then
		MacroFrame_Show();
	end
end

function InspectAchievements (unit)
	if ( Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING ) then
		return;
	end

	AchievementFrame_LoadUI();
	AchievementFrame_DisplayComparison(unit);
end

function ToggleAchievementFrame(stats)
	if ( Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING ) then
		return;
	end

	if ( ( HasCompletedAnyAchievement() or IsInGuild() ) and CanShowAchievementUI() ) then
		AchievementFrame_LoadUI();
		AchievementFrame_ToggleAchievementFrame(stats);
	end
end

function ToggleClickBindingFrame()
	ClickBindingFrame_LoadUI();
	if ( ClickBindingFrame_Toggle ) then
		ClickBindingFrame_Toggle();
	end
end

function InClickBindingMode()
	return ClickBindingFrame and ClickBindingFrame:IsShown();
end

function ToggleBattlefieldMap()
	if DISALLOW_FRAME_TOGGLING then
		return
	end
	BattlefieldMap_LoadUI();
	if ( BattlefieldMapFrame ) then
		BattlefieldMapFrame:Toggle();
	end
end

function ToggleTimeManager()
	TimeManager_LoadUI();
	if ( TimeManager_Toggle ) then
		TimeManager_Toggle();
	end
end

function ToggleCalendar()
	if ( Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING ) then
		return;
	end

	Calendar_LoadUI();
	if ( Calendar_Toggle ) then
		Calendar_Toggle();
	end
end

function IsCommunitiesUIDisabledByTrialAccount()
	return IsTrialAccount();
end

function ToggleGuildFrame()
	if ( Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING ) then
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
		ToggleGuildFinder();
	end
end

local function ToggleClubFinderBasedOnType(isGuildType)
	ToggleCommunitiesFrame();
	local communitiesFrame = CommunitiesFrame;

	if( not communitiesFrame:IsShown()) then
		return;
	end

	if (isGuildType) then
		communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.GUILD_FINDER);
	else
		communitiesFrame:SetDisplayMode(COMMUNITIES_FRAME_DISPLAY_MODES.COMMUNITY_FINDER);
	end

	communitiesFrame.GuildFinderFrame.isGuildType = isGuildType;
	communitiesFrame.GuildFinderFrame.selectedTab = 1;
	communitiesFrame.GuildFinderFrame:UpdateType();

	communitiesFrame:SelectClub(nil);
	communitiesFrame.Inset:Hide();
end

function ToggleGuildFinder()
	if ( Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING ) then
		return;
	end

	local factionGroup = UnitFactionGroup("player");
	if (factionGroup == "Neutral") then
		return;
	end

	ToggleClubFinderBasedOnType(true);
end

function ToggleCommunityFinder()
	if ( Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING ) then
		return;
	end

	local factionGroup = UnitFactionGroup("player");
	if (factionGroup == "Neutral") then
		return;
	end

	ToggleClubFinderBasedOnType(false);
end

function ToggleLFDParentFrame()
	if ( Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING ) then
		return;
	end

	local factionGroup = UnitFactionGroup("player");
	if (factionGroup == "Neutral") then
		return;
	end

	local canUse, failureReason = C_LFGInfo.CanPlayerUseGroupFinder();
	if canUse then
		PVEFrame_ToggleFrame("GroupFinderFrame", LFDParentFrame);
	end
end

function ToggleHelpFrame(contextKey)
	if (Kiosk.IsEnabled()) then
		return;
	end

	if ( HelpFrame:IsShown() ) then
		HideUIPanel(HelpFrame);
	else
		local key = nil;
		HelpFrame:ShowFrame(key, contextKey);
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

function ToggleRaidBrowser()
	if (Kiosk.IsEnabled()) then
		return;
	end

	local factionGroup = UnitFactionGroup("player");
	if (factionGroup == "Neutral") then
		return;
	end

	if ( RaidBrowserFrame:IsShown() ) then
		HideUIPanel(RaidBrowserFrame);
	else
		ShowUIPanel(RaidBrowserFrame);
	end
end

function CanShowEncounterJournal()
	if ( not C_AdventureJournal.CanBeShown() ) then
		return false;
	end

	return true;
end

function ToggleEncounterJournal()
	if ( Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING ) then
		return;
	end

	if ( not CanShowEncounterJournal() ) then
		return false;
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
	if ( Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING ) then
		return;
	end

	ToggleFrame(CommunitiesFrame);
end

function CommunitiesFrame_IsEnabled()
	return C_Club.IsEnabled();
end

COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS = 1;
COLLECTIONS_JOURNAL_TAB_INDEX_PETS = COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS + 1;
COLLECTIONS_JOURNAL_TAB_INDEX_TOYS = COLLECTIONS_JOURNAL_TAB_INDEX_PETS + 1;
COLLECTIONS_JOURNAL_TAB_INDEX_HEIRLOOMS = COLLECTIONS_JOURNAL_TAB_INDEX_TOYS + 1;
COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES = COLLECTIONS_JOURNAL_TAB_INDEX_HEIRLOOMS + 1;
COLLECTIONS_JOURNAL_TAB_INDEX_WARBAND_SCENES = COLLECTIONS_JOURNAL_TAB_INDEX_APPEARANCES + 1;

function ToggleCollectionsJournal(tabIndex)
	if DISALLOW_FRAME_TOGGLING then
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
	if DISALLOW_FRAME_TOGGLING then
		return;
	end

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
	if DISALLOW_FRAME_TOGGLING then
		return;
	end

	CollectionsJournal_LoadUI();
	ToyBox.autoPageToCollectedToyID = autoPageToCollectedToyID;
	SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_TOYS);
end

local function IsPVPTabAllowed()
	if PlayerGetTimerunningSeasonID() then
		-- PVP Tab is disabled during Timerunning, so don't allow the toggle key to show it
		return false;
	end
	return true;
end

function TogglePVPUI()
	if ( Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING ) then
		return;
	end

	if not IsPVPTabAllowed() then
		return;
	end

	local canUse, failureReason = C_LFGInfo.CanPlayerUseGroupFinder();
	if canUse then
		PVEFrame_ToggleFrame("PVPUIFrame", nil);
	end
end

function ToggleStoreUI(contextKey)
	if ( Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING ) then
		return;
	end

	local wasShown = StoreFrame_IsShown();
	if ( not wasShown ) then
		--We weren't showing, now we are. We should hide all other panels.
		securecall("CloseAllWindows");
	end
	StoreFrame_SetShown(not wasShown, contextKey);
end

function SetStoreUIShown(shown)
	if ( Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING ) then
		return;
	end

	local wasShown = StoreFrame_IsShown();
	if ( not wasShown and shown ) then
		--We weren't showing, now we are. We should hide all other panels.
		securecall("CloseAllWindows");
	end
	StoreFrame_SetShown(shown);
end

function ToggleGarrisonBuildingUI()
	if (not GarrisonBuildingFrame) then
		Garrison_LoadUI();
	end
	GarrisonBuildingUI_ToggleFrame();
end

function ToggleGarrisonMissionUI()
	if (not GarrisonMissionFrame) then
		Garrison_LoadUI();
	end
	GarrisonMissionFrame_ToggleFrame();
end

function ToggleCovenantMissionUI()
	if (not CovenantMissionFrame) then
		Garrison_LoadUI();
	end
	ShowUIPanel(CovenantMissionFrame);
end

function ToggleOrderHallTalentUI()
	if (not OrderHallTalentFrame) then
		OrderHall_LoadUI();
	end
	OrderHallTalentFrame_ToggleFrame();
end

function ToggleCovenantRenown()
	if (not CovenantRenownFrame) then
		CovenantRenown_LoadUI();
	end
	ToggleFrame(CovenantRenownFrame);
end

function ToggleMajorFactionRenown(majorFactionID)
	if (not MajorFactionRenownFrame) then
		MajorFactions_LoadUI();
	end

	if not majorFactionID then
		ToggleFrame(MajorFactionRenownFrame);
		return;
	end

	if MajorFactionRenownFrame:IsShown() then
		if MajorFactionRenownFrame:GetCurrentFactionID() == majorFactionID then
			HideUIPanel(MajorFactionRenownFrame);
			return;
		end

		HideUIPanel(MajorFactionRenownFrame);
		EventRegistry:TriggerEvent("MajorFactionRenownMixin.MajorFactionRenownRequest", majorFactionID);
		ShowUIPanel(MajorFactionRenownFrame);
	else
		EventRegistry:TriggerEvent("MajorFactionRenownMixin.MajorFactionRenownRequest", majorFactionID);
		ToggleMajorFactionRenown();
	end
end

function ToggleExpansionLandingPage()
	ToggleFrame(ExpansionLandingPage);
end

function ToggleProfessionsBook()
	if not ProfessionsBookFrame then
		ProfessionsBook_LoadUI();
	end

	ToggleFrame(ProfessionsBookFrame);
end


function OpenDeathRecapUI(id)
	if (not DeathRecapFrame) then
		DeathRecap_LoadUI();
	end
	DeathRecapFrame_OpenRecap(id);
end

function InspectUnit(unit)
	InspectFrame_LoadUI();
	if ( InspectFrame_Show ) then
		if ( PlayerSpellsFrame and PlayerSpellsFrame:IsInspecting() ) then
			-- If already inspecting a unit's talents, close that frame to clear out that prior inspect before starting the new inspect
			HideUIPanel(PlayerSpellsFrame);
		end

		InspectFrame_Show(unit);
	end
end

function OpenAzeriteEmpoweredItemUIFromItemLocation(itemLocation)
	UIParentLoadAddOn("Blizzard_AzeriteUI");

	ShowUIPanel(AzeriteEmpoweredItemUI);
	if AzeriteEmpoweredItemUI:IsShown() then -- may fail to display
		AzeriteEmpoweredItemUI:SetToItemAtLocation(itemLocation);
	end
end

function OpenAzeriteEmpoweredItemUIFromLink(itemLink, overrideClassID, overrideSelectedPowersList)
	UIParentLoadAddOn("Blizzard_AzeriteUI");

	ShowUIPanel(AzeriteEmpoweredItemUI);
	if AzeriteEmpoweredItemUI:IsShown() then -- may fail to display
		AzeriteEmpoweredItemUI:SetToItemLink(itemLink, overrideClassID, overrideSelectedPowersList);
	end
end

function OpenAzeriteEssenceUIFromItemLocation(itemLocation)
	UIParentLoadAddOn("Blizzard_AzeriteEssenceUI");

	if AzeriteEssenceUI then
		AzeriteEssenceUI:TryShow();
	end
end

function OpenProfessionUIToSkillLine(skillLineID)
	ProfessionsFrame_LoadUI();
	local currBaseProfessionInfo = C_TradeSkillUI.GetBaseProfessionInfo();
	if currBaseProfessionInfo == nil or currBaseProfessionInfo.professionID ~= skillLineID then
		C_TradeSkillUI.OpenTradeSkill(skillLineID);
	end
	ProfessionsFrame:SetTab(ProfessionsFrame.recipesTabID);
	ShowUIPanel(ProfessionsFrame);
end

local function PlayBattlefieldBanner(self)
	-- battlefields
	if ( not self.battlefieldBannerShown ) then
		local bannerName, bannerDescription;

		if (C_PvP.IsInBrawl()) then
			local brawlInfo = C_PvP.GetActiveBrawlInfo();
			if (brawlInfo) then
				bannerName = brawlInfo.name;
				bannerDescription = brawlInfo.shortDescription;
			end
		else
		    for i=1, GetMaxBattlefieldID() do
			    local status, mapName, _, _, _, _, _, _, _, shortDescription, _ = GetBattlefieldStatus(i);
			    if ( status and status == "active" ) then
				    bannerName = mapName;
				    bannerDescription = shortDescription;
				    break;
			    end
		    end
		end

		if ( bannerName ) then
			UIParentLoadAddOn("Blizzard_PVPUI");
			C_Timer.After(1, function() TopBannerManager_Show(PvPObjectiveBannerFrame, { name=bannerName, description=bannerDescription }); end);
			self.battlefieldBannerShown = true;
		end
	end
end

local function HandlesGlobalMouseEvent(focus, buttonName, event)
	return focus and focus.HandlesGlobalMouseEvent and focus:HandlesGlobalMouseEvent(buttonName, event);
end

local function HasVisibleAutoCompleteBox(autoCompleteBoxList, mouseFocus)
	for i, box in ipairs(autoCompleteBoxList) do
		if box:IsShown() and DoesAncestryInclude(box, mouseFocus) then
			return true;
		end
	end
	return false;
end

-- UIParent_OnEvent --
function UIParent_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6 = ...;
	if ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
		if ( SpellCanTargetGarrisonFollower(0) or SpellCanTargetGarrisonFollowerAbility(0, 0) ) then
			local followerTypeID = GetFollowerTypeIDFromSpell();
			local frame = _G[GarrisonFollowerOptions[followerTypeID].missionFrame];

			if (frame and frame:IsShown()) then
				if ( (not C_Garrison.TargetSpellHasFollowerTemporaryAbility() or not frame:HasMission()) and PanelTemplates_GetSelectedTab(frame) ~= 2 ) then
					frame:SelectTab(2)
				end
			else
				local landingPageTabIndex;
				local garrisonType = C_Garrison.GetLandingPageGarrisonType();
				local garrTypeID = GarrisonFollowerOptions[followerTypeID].garrisonType;
				if(garrTypeID == garrisonType) then
					if (C_Garrison.HasGarrison(garrTypeID)) then
						if (followerTypeID == Enum.GarrisonFollowerType.FollowerType_6_0_Boat) then
							landingPageTabIndex = 3;
						else
							landingPageTabIndex = 2;
						end

						ShowGarrisonLandingPage(garrTypeID);

						-- switch to the followers tab
						if ( PanelTemplates_GetSelectedTab(GarrisonLandingPage) ~= landingPageTabIndex ) then
							GarrisonLandingPageTab_SetTab(_G["GarrisonLandingPageTab"..landingPageTabIndex]);
						end
					end
				end
			end
		end
		if ( SpellCanTargetGarrisonMission() ) then
			-- TODO: Determine garrison/follower mission type for this spell
			if ( not GarrisonLandingPage ) then
				Garrison_LoadUI();
			end
			-- if the mission UI is already open, go with that
			if ( GarrisonMissionFrame:IsShown() ) then
				if ( PanelTemplates_GetSelectedTab(GarrisonMissionFrame) ~= 1 ) then
					GarrisonMissionFrame_SelectTab(1);
				end
				if ( PanelTemplates_GetSelectedTab(GarrisonMissionFrame.MissionTab.MissionList) ~= 2 ) then
					GarrisonMissionListTab_SetTab(GarrisonMissionFrame.MissionTab.MissionList.Tab2);
				end
			else
				if (C_Garrison.HasGarrison(Enum.GarrisonType.Type_6_0_Garrison)) then
					ShowGarrisonLandingPage(Enum.GarrisonType.Type_6_0_Garrison);

					-- switch to the mission tab
					if ( PanelTemplates_GetSelectedTab(GarrisonLandingPage) ~= 1 ) then
						GarrisonLandingPageTab_SetTab(GarrisonLandingPageTab1);
					end
					if ( PanelTemplates_GetSelectedTab(GarrisonLandingPageReport) ~= GarrisonLandingPageReport.InProgress ) then
						GarrisonLandingPageReport_SetTab(GarrisonLandingPageReport.InProgress);
					end
				end
			end
		end
		if ( StaticPopup_HasDisplayedFrames() ) then
			if ( arg1 ) then
				StaticPopup_Hide("BIND_ENCHANT");
				StaticPopup_Hide("REPLACE_ENCHANT");
				StaticPopup_Hide("ACTION_WILL_BIND_ITEM");
			end
			StaticPopup_Hide("TRADE_REPLACE_ENCHANT");
			StaticPopup_Hide("END_BOUND_TRADEABLE");
			StaticPopup_Hide("REPLACE_TRADESKILL_ENCHANT");
			if ( not SpellCanTargetGarrisonFollower(0) ) then
				StaticPopup_Hide("CONFIRM_FOLLOWER_UPGRADE");
				StaticPopup_Hide("CONFIRM_FOLLOWER_TEMPORARY_ABILITY");
			end
		end
		ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
	elseif event == "WORLD_CURSOR_TOOLTIP_UPDATE" then
		local anchorType = ...;
		GameTooltip:SetWorldCursor(anchorType);
	elseif ( event == "CVAR_UPDATE" ) then
		local cvarName = ...;
		if cvarName and cvarName == "showTutorials" then
			local showTutorials = GetCVarBool("showTutorials");
			if ( showTutorials ) then
				if ( C_AddOns.IsAddOnLoaded("Blizzard_NewPlayerExperience") ) then
					NewPlayerExperience:Initialize();
				else
					NPE_LoadUI();
				end
			end
		end
	elseif ( event == "VARIABLES_LOADED" ) then
		UIParent.variablesLoaded = true;

		LocalizeFrames();
		if ( not TimeManagerFrame and GetCVar("timeMgrAlarmEnabled") == "1" ) then
			-- We have to load the time manager here if the alarm is enabled because the alarm can go off
			-- even if the clock is not shown. WorldFrame_OnUpdate handles alarm checking while the clock
			-- is hidden.
			TimeManager_LoadUI();
		end

		if ( not BattlefieldMapFrame and GetCVar("showBattlefieldMinimap") == "1" ) then
			BattlefieldMap_LoadUI();
		end

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

		NPETutorial_AttemptToBegin(event);

		StoreFrame_CheckForFree(event);
	elseif ( event == "PLAYER_LOGIN" ) then
		TimeManager_LoadUI();
		-- You can override this if you want a Combat Log replacement
		CombatLog_LoadUI();
	elseif ( event == "PLAYER_DEAD" ) then
		if ( not StaticPopup_Visible("DEATH") ) then
			CloseAllWindows(1);
		end
		local releaseSpiritGhostDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.ReleaseSpiritGhostDisabled);
		if (not releaseSpiritGhostDisabled) then
			if ( (GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1) and (not ResurrectGetOfferer()) ) then
				StaticPopup_Show("DEATH");
			end
		end
	elseif ( event == "SELF_RES_SPELL_CHANGED" ) then
		if ( StaticPopup_Visible("DEATH") ) then
			StaticPopup_Show("DEATH"); --If we're already showing a death prompt, we should refresh it.
		end
	elseif ( event == "PLAYER_ALIVE" or event == "RAISED_AS_GHOUL" ) then
		StaticPopup_Hide("DEATH");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		StaticPopup_Hide("RESURRECT_NO_TIMER");
		StaticPopup_Hide("RESURRECT");

		local releaseSpiritGhostDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.ReleaseSpiritGhostDisabled);
		if ( not releaseSpiritGhostDisabled and UnitIsGhost("player") ) then
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
	elseif event == "LEAVING_TUTORIAL_AREA" then
		StaticPopup_Show("LEAVING_TUTORIAL_AREA");
	elseif event == "UI_ERROR_POPUP" then
		local errorType, errorMessage = ...;
		local systemPrefix = "UI_ERROR_";
		StaticPopup_ShowNotification(systemPrefix, errorType, errorMessage);
	elseif ( event == "ALERT_REGIONAL_CHAT_DISABLED" ) then
		StaticPopup_Show("REGIONAL_CHAT_DISABLED");
	elseif ( event == "UI_SCALE_CHANGED" ) then
		UpdateScaleForFitForOpenPanels();
	elseif ( event == "PARTY_INVITE_REQUEST" ) then
		FlashClientIcon();

		local name, tank, healer, damage, isXRealm, allowMultipleRoles, inviterGuid, isQuestSessionActive = ...;

		-- Color the name by our relationship
		local modifiedName, color, selfRelationship = SocialQueueUtil_GetRelationshipInfo(inviterGuid);
		if ( selfRelationship ) then
			name = color..name..FONT_COLOR_CODE_CLOSE;
		end

		-- if there's a role, it's an LFG invite
		if ( tank or healer or damage ) then
			StaticPopupSpecial_Show(LFGInvitePopup);
			LFGInvitePopup_Update(name, tank, healer, damage, allowMultipleRoles, isQuestSessionActive);
		else
			local text = isXRealm and INVITATION_XREALM or INVITATION;
			text = string.format(text, name);

			if ( WillAcceptInviteRemoveQueues() ) then
				text = text.."\n\n"..ACCEPTING_INVITE_WILL_REMOVE_QUEUE;
			end

			if isQuestSessionActive then
				QuestSessionManager:ShowGroupInviteReceivedConfirmation(name, text);
			else
				StaticPopup_Show("PARTY_INVITE", text);
			end
		end
	elseif ( event == "PARTY_INVITE_CANCEL" ) then
		StaticPopup_Hide("PARTY_INVITE");
		StaticPopupSpecial_Hide(LFGInvitePopup);
	elseif ( event == "GUILD_INVITE_REQUEST" ) then
		StaticPopup_Show("GUILD_INVITE", arg1, arg2);
	elseif ( event == "GUILD_INVITE_CANCEL" ) then
		StaticPopup_Hide("GUILD_INVITE");
	elseif ( event == "PLAYER_CAMPING" ) then
		StaticPopup_Show("CAMP");
	elseif ( event == "PLAYER_PLUNDERSTORM_TRANSFERING" ) then
		StaticPopup_Show("PLUNDERSTORM_LEAVE");
	elseif ( event == "PLAYER_QUITING" ) then
		StaticPopup_Show("QUIT");
	elseif ( event == "LOGOUT_CANCEL" ) then
		CancelLogout();
		StaticPopup_Hide("CAMP");
		StaticPopup_Hide("PLUNDERSTORM_LEAVE");
		StaticPopup_Hide("QUIT");
	elseif ( event == "LOOT_BIND_CONFIRM" ) then
		local texture, item, quantity, currencyID, quality, locked = GetLootSlotInfo(arg1);
		local dialog = StaticPopup_Show("LOOT_BIND", ITEM_QUALITY_COLORS[quality].hex..item.."|r");
		if ( dialog ) then
			dialog.data = arg1;
		end
	elseif ( event == "EQUIP_BIND_CONFIRM" ) then
		StaticPopup_Hide("EQUIP_BIND_REFUNDABLE");
		StaticPopup_Hide("EQUIP_BIND_TRADEABLE");
		local textArg1, textArg2 = nil, nil;
		StaticPopup_Show("EQUIP_BIND", textArg1, textArg2, { slot = arg1, itemLocation = arg2 });
	elseif ( event == "EQUIP_BIND_REFUNDABLE_CONFIRM" ) then
		StaticPopup_Hide("EQUIP_BIND");
		StaticPopup_Hide("EQUIP_BIND_TRADEABLE");
		local textArg1, textArg2 = nil, nil;
		StaticPopup_Show("EQUIP_BIND_REFUNDABLE", textArg1, textArg2, { slot = arg1, itemLocation = arg2 });
	elseif ( event == "EQUIP_BIND_TRADEABLE_CONFIRM" ) then
		StaticPopup_Hide("EQUIP_BIND");
		StaticPopup_Hide("EQUIP_BIND_REFUNDABLE");
		local textArg1, textArg2 = nil, nil;
		StaticPopup_Show("EQUIP_BIND_TRADEABLE", textArg1, textArg2, { slot = arg1, itemLocation = arg2 });
	elseif ( event == "USE_BIND_CONFIRM" ) then
		StaticPopup_Show("USE_BIND");
	elseif ( event == "CONVERT_TO_BIND_TO_ACCOUNT_CONFIRM" ) then
		StaticPopup_Show("CONVERT_TO_BIND_TO_ACCOUNT_CONFIRM");
	elseif( event == "USE_NO_REFUND_CONFIRM" )then
		StaticPopup_Show("USE_NO_REFUND_CONFIRM");
	elseif ( event == "CONFIRM_BEFORE_USE" ) then
		StaticPopup_Show("CONFIM_BEFORE_USE");
	elseif ( event == "DELETE_ITEM_CONFIRM" ) then
		-- Check quality, ignore heirlooms
		if ( arg2 >= Enum.ItemQuality.Rare and arg2 ~= Enum.ItemQuality.Heirloom ) then
			if (arg4 == 1) then -- quest item?
				StaticPopup_Show("DELETE_GOOD_QUEST_ITEM", arg1);
			else
				StaticPopup_Show("DELETE_GOOD_ITEM", arg1);
			end
		else
			if (arg4 == 1) then -- quest item?
				StaticPopup_Show("DELETE_QUEST_ITEM", arg1);
			else
				StaticPopup_Show("DELETE_ITEM", arg1);
			end
		end
	elseif ( event == "QUEST_ACCEPT_CONFIRM" ) then
		local numEntries, numQuests = C_QuestLog.GetNumQuestLogEntries();
		if( numQuests >= MAX_QUESTS) then
			StaticPopup_Show("QUEST_ACCEPT_LOG_FULL", arg1, arg2);
		else
			StaticPopup_Show("QUEST_ACCEPT", arg1, arg2);
		end
	elseif ( event =="QUEST_LOG_UPDATE" or event == "UNIT_QUEST_LOG_CHANGED" ) then
		local frameName = StaticPopup_Visible("QUEST_ACCEPT_LOG_FULL");
		if( frameName ) then
			local numEntries, numQuests = C_QuestLog.GetNumQuestLogEntries();
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
	elseif ( event == "SETTINGS_LOADED" ) then
		-- Get multi-actionbar states
		-- We don't want to call this, as the values GetActionBarToggles() returns are incorrect if it's called before the client mirrors SetActionBarToggles values from the server.
		-- SHOW_MULTI_ACTIONBAR_1, SHOW_MULTI_ACTIONBAR_2, SHOW_MULTI_ACTIONBAR_3, SHOW_MULTI_ACTIONBAR_4 = GetActionBarToggles();
		MultiActionBar_Update();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		-- Close any windows that were previously open
		CloseAllWindows(1);

		UpdateMicroButtons();

		-- Fix for Bug 124392
		StaticPopup_Hide("CONFIRM_LEAVE_BATTLEFIELD");

		if ( C_Commentator.IsSpectating() ) then
			Commentator_LoadUI();
		end

		if(C_PlayerChoice.IsWaitingForPlayerChoiceResponse()) then
			if not UnitIsDeadOrGhost("player") then
				if not PlayerChoiceFrame then
					PlayerChoice_LoadUI();
				end
				PlayerChoiceToggle_TryShow();
				PlayerChoiceTimeRemaining:TryShow();
			end
		end

		local releaseSpiritGhostDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.ReleaseSpiritGhostDisabled);
	    if ( not releaseSpiritGhostDisabled ) then
			if ( UnitIsGhost("player") ) then
				GhostFrame:Show();
			else
				GhostFrame:Hide();
			end
			if ( GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1 ) then
				StaticPopup_Show("DEATH");
			end
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

		-- display loot specialization setting
		PrintLootSpecialization();

		UpdateUIParentPosition();

		--Bonus roll/spell confirmation.
		local spellConfirmations = GetSpellConfirmationPromptsInfo();

		for i, spellConfirmation in ipairs(spellConfirmations) do
			if spellConfirmation.spellID then
				if spellConfirmation.confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_STATIC_TEXT then
					StaticPopup_Show("SPELL_CONFIRMATION_PROMPT", spellConfirmation.text, spellConfirmation.duration, spellConfirmation.spellID);
				elseif spellConfirmation.confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_STATIC_TEXT_ALERT then
					StaticPopup_Show("SPELL_CONFIRMATION_PROMPT_ALERT", spellConfirmation.text, spellConfirmation.duration, spellConfirmation.spellID);
				elseif spellConfirmation.confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_SIMPLE_WARNING then
					StaticPopup_Show("SPELL_CONFIRMATION_WARNING", spellConfirmation.text, nil, spellConfirmation.spellID);
				elseif spellConfirmation.confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_SIMPLE_WARNING_ALERT then
					StaticPopup_Show("SPELL_CONFIRMATION_WARNING_ALERT", spellConfirmation.text, nil, spellConfirmation.spellID);
				elseif spellConfirmation.confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_BONUS_ROLL then
					BonusRollFrame_StartBonusRoll(spellConfirmation.spellID, spellConfirmation.text, spellConfirmation.duration, spellConfirmation.currencyID, spellConfirmation.currencyCost, spellConfirmation.difficultyID);
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
			GroupLootContainer_AddRoll(pendingLootRollIDs[i], C_Loot.GetLootRollDuration(pendingLootRollIDs[i]));
		end
		OrderHall_CheckCommandBar();

		self.battlefieldBannerShown = nil;

		NPETutorial_AttemptToBegin(event);
		BoostTutorial_AttemptLoad();

		if Kiosk.IsEnabled() then
			C_AddOns.LoadAddOn("Blizzard_Kiosk");

			local isInitialLogin, isUIReload = arg1, arg2;
			if isInitialLogin and not isUIReload then
				KioskSessionStartedDialog:Show();
			end
		end

		if IsTrialAccount() or IsVeteranTrialAccount() then
			SubscriptionInterstitial_LoadUI();
		end

		ExpansionTrial_CheckLoadUI();
	elseif ( event == "UPDATE_BATTLEFIELD_STATUS" or event == "PVP_BRAWL_INFO_UPDATED" ) then
		PlayBattlefieldBanner(self);
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		-- Hide/Show party member frames
		UpdateRaidAndPartyFrames();
		if ( not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
			StaticPopup_Hide("CONFIRM_LEAVE_INSTANCE_PARTY");
		end
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
			if (UnitLevel("player") < Constants.LevelConstsExposed.MIN_RES_SICKNESS_LEVEL) then
				dialog = StaticPopup_Show("XP_LOSS_NO_SICKNESS_NO_DURABILITY", resSicknessTime);
			else
				dialog = StaticPopup_Show("XP_LOSS", resSicknessTime);
			end
			if ( dialog ) then
				dialog.data = resSicknessTime;
			end
		end
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
	elseif ( event == "REPLACE_TRADESKILL_ENCHANT" ) then
		StaticPopup_Show("REPLACE_TRADESKILL_ENCHANT", arg1, arg2);
	elseif ( event == "END_BOUND_TRADEABLE" ) then
		local dialog = StaticPopup_Show("END_BOUND_TRADEABLE", nil, nil, arg1);
	elseif ( event == "MACRO_ACTION_BLOCKED" or event == "ADDON_ACTION_BLOCKED" ) then
		AddonTooltip_ActionBlocked(arg1);
		DisplayInterfaceActionBlockedMessage();
	elseif ( event == "MACRO_ACTION_FORBIDDEN" ) then
		AddonTooltip_ActionBlocked(arg1);
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
		SetDesaturation(MicroButtonPortrait, true);

		Designers previously wanted these disabled when feared, they seem to have changed their minds
		CharacterMicroButton:Disable();
		ProfessionMicroButton:Disable();
		PlayerSpellsMicroButton:Disable();
		QuestLogMicroButton:Disable();
		GuildMicroButton:Disable();
		WorldMapMicroButton:Disable();
		]]

		UIParent.isOutOfControl = 1;
	elseif ( event == "PLAYER_CONTROL_GAINED" ) then
		--[[
		-- Enable all microbuttons
		SetDesaturation(MicroButtonPortrait, false);

		CharacterMicroButton:Enable();
		ProfessionMicroButton:Enable();
		PlayerSpellsMicroButton:Enable();
		QuestLogMicroButton:Enable();
		GuildMicroButton:Enable();
		WorldMapMicroButton:Enable();
		]]

		UIParent.isOutOfControl = nil;
	elseif ( event == "START_LOOT_ROLL" ) then
		GroupLootContainer_AddRoll(arg1, arg2);
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
		elseif ( confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_STATIC_TEXT_ALERT ) then
			StaticPopup_Show("SPELL_CONFIRMATION_PROMPT_ALERT", text, duration, spellID);
		elseif ( confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_SIMPLE_WARNING ) then
			StaticPopup_Show("SPELL_CONFIRMATION_WARNING", text, nil, spellID);
		elseif ( confirmType == LE_SPELL_CONFIRMATION_PROMPT_TYPE_SIMPLE_WARNING_ALERT ) then
			StaticPopup_Show("SPELL_CONFIRMATION_WARNING_ALERT", text, nil, spellID);
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
		if (C_Garrison.IsOnGarrisonMap()) then
			StaticPopup_Show("GARRISON_BOOT");
		else
			StaticPopup_Show("INSTANCE_BOOT");
		end
	elseif ( event == "INSTANCE_BOOT_STOP" ) then
		StaticPopup_Hide("INSTANCE_BOOT");
		StaticPopup_Hide("GARRISON_BOOT");
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

	--Events for handling Auction UI
	elseif ( event == "AUCTION_HOUSE_SHOW" ) then
		if ( GameLimitedMode_IsActive() ) then
			UIErrorsFrame:AddExternalErrorMessage(ERR_FEATURE_RESTRICTED_TRIAL);
			C_AuctionHouse.CloseAuctionHouse();
		else
			AuctionHouseFrame_LoadUI();
			ShowUIPanel(AuctionHouseFrame);
		end
	elseif ( event == "AUCTION_HOUSE_CLOSED" ) then
		if ( AuctionHouseFrame ) then
			HideUIPanel(AuctionHouseFrame);
		end
	elseif ( event == "AUCTION_HOUSE_DISABLED" ) then
		StaticPopup_Show("AUCTION_HOUSE_DISABLED");
	elseif ( event == "AUCTION_HOUSE_SHOW_NOTIFICATION" or event == "AUCTION_HOUSE_SHOW_FORMATTED_NOTIFICATION" ) then
		local auctionHouseNotification, formatArg = ...;
		Chat_AddSystemMessage(ChatFrameUtil.GetAuctionHouseNotificationText(auctionHouseNotification, formatArg));

	-- Events for trade skill UI handling
	elseif ( event == "TRADE_SKILL_SHOW" ) then
		ProfessionsFrame_LoadUI();
		ShowUIPanel(ProfessionsFrame);
	elseif ( event == "CRAFTING_HOUSE_DISABLED") then
		StaticPopup_Show("CRAFTING_HOUSE_DISABLED");
	elseif ( event == "CRAFTINGORDERS_SHOW_CUSTOMER" ) then
		if ( GameLimitedMode_IsActive() ) then
			UIErrorsFrame:AddExternalErrorMessage(ERR_FEATURE_RESTRICTED_TRIAL);
		else
			ProfessionsCustomerOrders_LoadUI();
			ShowUIPanel(ProfessionsCustomerOrdersFrame);
		end
	elseif ( event == "CRAFTINGORDERS_HIDE_CUSTOMER" ) then
		if ( ProfessionsCustomerOrdersFrame ) then
			HideUIPanel(ProfessionsCustomerOrdersFrame);
		end
	elseif ( event == "PROFESSION_EQUIPMENT_CHANGED" ) then
		local skillLineID, isTool = ...;
		local cvar = isTool and "professionToolSlotsExampleShown" or "professionAccessorySlotsExampleShown";
		if not GetCVarBool(cvar) then
			SetCVar(cvar, "1");
			OpenProfessionUIToSkillLine(skillLineID);

			local helpTipInfo =
			{
				text = PROFESSION_EQUIPMENT_LOCATION_HELPTIP,
				buttonStyle = HelpTip.ButtonStyle.Close,
				targetPoint = HelpTip.Point.LeftEdgeTop,
				alignment = HelpTip.Alignment.Left,
				offsetX = 940,
				offsetY = -48,
			};
			HelpTip:Show(ProfessionsFrame.CraftingPage, helpTipInfo, ProfessionsFrame.CraftingPage);
		end
	elseif ( event == "PROFESSION_RESPEC_CONFIRMATION" ) then 
		StaticPopup_Show("CONFIRM_PROFESSION_RESPEC", arg1);
	-- Event for item socketing handling
	elseif ( event == "SOCKET_INFO_UPDATE" ) then
		ItemSocketingFrame_LoadUI();
		ItemSocketingFrame_Update();
		ShowUIPanel(ItemSocketingFrame);

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
		if ( followerTypeID == Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower ) then
			ShowUIPanel(OrderHallMissionFrame);
		elseif ( followerTypeID == Enum.GarrisonFollowerType.FollowerType_8_0_GarrisonFollower ) then
			ShowUIPanel(BFAMissionFrame);
		elseif ( followerTypeID == Enum.GarrisonFollowerType.FollowerType_9_0_GarrisonFollower ) then
			ShowUIPanel(CovenantMissionFrame);
		end

	-- Event for BarberShop handling
	elseif ( event == "BARBER_SHOP_OPEN" ) then
		if not BarberShopFrame then
			BarberShopFrame_LoadUI();
		end

		ShowUIPanel(BarberShopFrame);
	elseif ( event == "BARBER_SHOP_CLOSE" ) then
		if ( BarberShopFrame and BarberShopFrame:IsVisible() ) then
			HideUIPanel(BarberShopFrame);
		end

	-- Event for PerksProgram handling
	elseif ( event == "PERKS_PROGRAM_OPEN" ) then
		if not PerksProgramFrame then
			PerksProgramFrame_LoadUI();
		end

		ShowUIPanel(PerksProgramFrame);
	elseif ( event == "PERKS_PROGRAM_DISABLED" ) then
		StaticPopup_Show("PERKS_PROGRAM_DISABLED");

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

	elseif ( event == "DAILY_RESET_INSTANCE_WELCOME" ) then
		local instanceName = arg1;
		local resetTime = arg2;
		message = format(DAILY_RESET_INSTANCE_WELCOME, instanceName, SecondsToTime(resetTime, nil, 1));
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(message, info.r, info.g, info.b, info.id);

	elseif ( event == "INSTANCE_RESET_WARNING" ) then
		local warningString = arg1;
		local resetTime = arg2;
		message = format(warningString, SecondsToTime(resetTime, nil, 1));
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(message, info.r, info.g, info.b, info.id);

	-- Events for taxi benchmarking
	elseif ( event == "ENABLE_TAXI_BENCHMARK" ) then
		FramerateFrame:BeginBenchmark();
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(BENCHMARK_TAXI_MODE_ON, info.r, info.g, info.b, info.id);
	elseif ( event == "DISABLE_TAXI_BENCHMARK" ) then
		FramerateFrame:EndBenchmark();
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(BENCHMARK_TAXI_MODE_OFF, info.r, info.g, info.b, info.id);
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
		ArcheologyDigsiteProgressBar:OnEvent(event, ...);
		self:UnregisterEvent("ARCHAEOLOGY_SURVEY_CAST");
	--Events for Trial caps
	elseif ( event == "TRIAL_CAP_REACHED_MONEY" ) then
		TrialAccountCapReached_Inform("money");
	elseif ( event == "TRIAL_CAP_REACHED_LEVEL" ) then
		TrialAccountCapReached_Inform("level");
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

				self.autoPageToCollectedToyID = itemID;
				SetCVar("petJournalTab", COLLECTIONS_JOURNAL_TAB_INDEX_TOYS);
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
	elseif ( event == "PLAYER_CHOICE_UPDATE" ) then
		PlayerChoice_LoadUI();
		PlayerChoiceFrame:TryShow();
		PlayerChoiceToggle_TryShow();
	elseif ( event == "LUA_WARNING" ) then
		HandleLuaWarning(...);
	elseif ( event == "GARRISON_MISSION_NPC_OPENED") then
		local followerType = ...;
		if followerType ~= Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower then
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

		if ( CovenantMissionFrame ) then
			HideUIPanel(CovenantMissionFrame);
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
		ShowUIPanel(GarrisonCapacitiveDisplayFrame);
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
	elseif ( event == "LOADING_SCREEN_ENABLED" ) then
		TopBannerManager_LoadingScreenEnabled();
	elseif ( event == "LOADING_SCREEN_DISABLED" ) then
		TopBannerManager_LoadingScreenDisabled()
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
		else
			FlightMap_LoadUI();
			ShowUIPanel(FlightMapFrame);
		end
	elseif (event == "SCENARIO_UPDATE") then
		BoostTutorial_AttemptLoad();
    elseif (event == "NOTCHED_DISPLAY_MODE_CHANGED") then
        UpdateUIParentPosition();
	elseif (event == "CLIENT_SCENE_OPENED") then
		local sceneType = ...;
		UpdateUIElementsForClientScene(sceneType);
	elseif (event == "CLIENT_SCENE_CLOSED") then
		UpdateUIElementsForClientScene(nil);
	elseif ( event == "GROUP_INVITE_CONFIRMATION" ) then
		UpdateInviteConfirmationDialogs();
	elseif ( event == "INVITE_TO_PARTY_CONFIRMATION" ) then
		OnInviteToPartyConfirmation(...);
	elseif (event == "ALLIED_RACE_OPEN") then
		AlliedRaces_LoadUI();
		local raceID = ...;
		AlliedRacesFrame:LoadRaceData(raceID);
		ShowUIPanel(AlliedRacesFrame);
	elseif (event == "ISLAND_COMPLETED") then
		IslandsPartyPose_LoadUI();
		local mapID, winner = ...;
		IslandsPartyPoseFrame:LoadScreen(mapID, winner);
		ShowUIPanel(IslandsPartyPoseFrame);
	elseif (event == "WARFRONT_COMPLETED") then
		WarfrontsPartyPose_LoadUI();
		local mapID, winner = ...;
		WarfrontsPartyPoseFrame:LoadScreen(mapID, winner);
		ShowUIPanel(WarfrontsPartyPoseFrame);
	elseif (event == "COVENANT_PREVIEW_OPEN") then
		CovenantPreviewFrame_LoadUI();
		CovenantPreviewFrame:TryShow(...);
	elseif (event == "ANIMA_DIVERSION_OPEN") then
		AnimaDiversionFrame_LoadUI();
		AnimaDiversionFrame:TryShow(...);
	elseif (event == "RUNEFORGE_LEGENDARY_CRAFTING_OPENED") then
		RuneforgeFrame_LoadUI();

		local isUpgrade = ...;
		RuneforgeFrame:SetRuneforgeState(isUpgrade and RuneforgeUtil.RuneforgeState.Upgrade or RuneforgeUtil.RuneforgeState.Craft);

		ShowUIPanel(RuneforgeFrame);
	elseif (event == "TRAIT_SYSTEM_INTERACTION_STARTED") then
		local traitTreeID = ...;
		--! TODO Getting companionID either from season data or player data has not been implemented yet. When done, pass companionID to this function
		if traitTreeID == C_DelvesUI.GetTraitTreeForCompanion() then
			ShowUIPanel(DelvesCompanionConfigurationFrame);
		else
			GenericTraitUI_LoadUI();
	
			GenericTraitFrame:SetTreeID(traitTreeID);
			ShowUIPanel(GenericTraitFrame);
		end
	-- Events for Reporting system
	elseif (event == "REPORT_PLAYER_RESULT") then
		local success = ...;
		if (success) then
			UIErrorsFrame:AddExternalWarningMessage(ERR_REPORT_SUBMITTED_SUCCESSFULLY);
			DEFAULT_CHAT_FRAME:AddMessage(COMPLAINT_ADDED);
		else
			UIErrorsFrame:AddExternalErrorMessage(ERR_REPORT_SUBMISSION_FAILED);
			DEFAULT_CHAT_FRAME:AddMessage(ERR_REPORT_SUBMISSION_FAILED);
		end
	elseif (event == "GLOBAL_MOUSE_DOWN" or event == "GLOBAL_MOUSE_UP") then
		local buttonID = ...;

		-- Ping Listener.
		-- When pinging UI, if the ping keybind is mapped to any mouse button the input gets consumed before it would hit the normal logic in Bindings.
    	-- Below logic catches the input and handles this case specifically.
		-- TogglePingListener is restricted, so this is must be done before dropdown handling to avoid taint propagation
		if IsMouseButton(buttonID) and GetConvertedKeyOrButton(buttonID) == GetBindingKey("TOGGLEPINGLISTENER") then
			C_Ping.TogglePingListener(event == "GLOBAL_MOUSE_DOWN");
		end

		-- Close dropdown(s).
		local mouseFoci = GetMouseFoci();
		for _, mouseFocus in ipairs(mouseFoci) do
			if not HandlesGlobalMouseEvent(mouseFocus, buttonID, event) then
				UIDropDownMenu_HandleGlobalMouseEvent(buttonID, event);
			end
		end

		-- Clear keyboard focus.
		local autoCompleteBoxList = { AutoCompleteBox }
		if LFGListFrame and LFGListFrame.SearchPanel and LFGListFrame.SearchPanel.AutoCompleteFrame then
			tinsert(autoCompleteBoxList, LFGListFrame.SearchPanel.AutoCompleteFrame);
		end


		for _, mouseFocus in ipairs(mouseFoci) do
			if not HasVisibleAutoCompleteBox(autoCompleteBoxList, mouseFocus) then
				if event == "GLOBAL_MOUSE_DOWN" and buttonID == "LeftButton" and not IsModifierKeyDown() then
					local keyBoardFocus = GetCurrentKeyBoardFocus();
					if keyBoardFocus then
						local hasStickyFocus = keyBoardFocus.HasStickyFocus and keyBoardFocus:HasStickyFocus();
						if keyBoardFocus.ClearFocus and not hasStickyFocus and keyBoardFocus ~= mouseFocus then
							keyBoardFocus:ClearFocus();
						end
 					end
				end
			end
		end
	elseif (event == "SCRIPTED_ANIMATIONS_UPDATE") then
		ScriptedAnimationEffectsUtil.ReloadDB();
	elseif event == "SHOW_HYPERLINK_TOOLTIP" then
		local hyperlink = ...;
		GameTooltip_ShowEventHyperlink(hyperlink);
	elseif event == "HIDE_HYPERLINK_TOOLTIP" then
		GameTooltip_HideEventHyperlink();
	elseif (event == "RETURNING_PLAYER_PROMPT") then
		StaticPopup_Show("RETURNING_PLAYER_PROMPT");
	elseif(event == "PLAYER_SOFT_INTERACT_CHANGED") then
		if(GetCVarBool("softTargettingInteractKeySound")) then
			local previousTarget, currentTarget = ...;
			if(not currentTarget) then
				PlaySound(SOUNDKIT.UI_SOFT_TARGET_INTERACT_NOT_AVAILABLE);
			elseif(previousTarget ~= currentTarget) then
				PlaySound(SOUNDKIT.UI_SOFT_TARGET_INTERACT_AVAILABLE);
			end
		end
	elseif event == "SHOW_PARTY_POSE_UI" then
		MatchCelebrationPartyPose_LoadUI();
		local partyPoseID, won = ...;
		MatchCelebrationPartyPoseFrame:LoadScreenByPartyPoseID(partyPoseID, won);
		ShowUIPanel(MatchCelebrationPartyPoseFrame);
	elseif event == "PING_SYSTEM_ERROR" then
		local errorMsg = ...;
		UIErrorsFrame:AddMessage(errorMsg, RED_FONT_COLOR:GetRGBA());
	elseif event == "USE_GLYPH" then
		self:UnregisterEvent("USE_GLYPH");
		if(not PlayerSpellsFrame) then
			PlayerSpellsUtil.OpenToSpellBookTab();
			PlayerSpellsFrame.SpellBookFrame:OnEvent(event, ...);
		end
	elseif event == "ENCHANT_SPELL_SELECTED" then
		PlaySound(SOUNDKIT.ENCHANTMENT_SELECTED);
		ItemButtonUtil.OpenAndFilterBags(self);
		ItemButtonUtil.OpenAndFilterCharacterFrame();
	elseif event == "UPDATE_SPELL_TARGET_ITEM_CONTEXT" then
		ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);
	elseif event == "REMIX_END_OF_EVENT" then
		StaticPopup_Show("REMIX_END_OF_EVENT_NOTICE");
	end
end

--Aubrie TODO.. Convert these into horizontal layout frames? It's fine for now tho..
function UIParent_UpdateTopFramePositions()
	local yOffset = 0;
	local xOffset = -230;

	if OrderHallCommandBar and OrderHallCommandBar:IsShown() then
		yOffset = OrderHallCommandBar:GetHeight();
	end

	local buffOffset = 0;
	local gmChatStatusFrameShown = GMChatStatusFrame and GMChatStatusFrame:IsShown();
	local ticketStatusFrameShown = TicketStatusFrame and TicketStatusFrame:IsShown();
	local notificationAnchorTo = UIParent;
	if gmChatStatusFrameShown then
		GMChatStatusFrame:SetPoint("TOPRIGHT", xOffset, yOffset);

		buffOffset = math.max(buffOffset, GMChatStatusFrame:GetHeight());
		notificationAnchorTo = GMChatStatusFrame;
	end

	if ticketStatusFrameShown then
		if gmChatStatusFrameShown then
			TicketStatusFrame:SetPoint("TOPRIGHT", GMChatStatusFrame, "TOPLEFT");
		else
			TicketStatusFrame:SetPoint("TOPRIGHT", xOffset, yOffset);
		end

		buffOffset = math.max(buffOffset, TicketStatusFrame:GetHeight());
		notificationAnchorTo = TicketStatusFrame;
	end

	local reportNotificationShown = BehavioralMessagingTray and BehavioralMessagingTray:IsShown();
	if reportNotificationShown then
		BehavioralMessagingTray:ClearAllPoints();
		if notificationAnchorTo ~= UIParent then
			BehavioralMessagingTray:SetPoint("TOPRIGHT", notificationAnchorTo, "TOPLEFT");
		else
			BehavioralMessagingTray:SetPoint("TOPRIGHT", xOffset, yOffset);
		end

		buffOffset = math.max(buffOffset, BehavioralMessagingTray:GetHeight());
	end

	if BuffFrame:IsInDefaultPosition() then
		local y = -(buffOffset + 13)
		BuffFrame:SetPoint("TOPRIGHT", MinimapCluster, "TOPLEFT", -10, y);
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

function GetScaledCursorPositionForFrame(frame)
	local uiScale = frame:GetEffectiveScale();
	local x, y = GetCursorPosition();
	return x / uiScale, y / uiScale;
end

function GetScaledCursorPosition()
	local x, y = GetScaledCursorPositionForFrame(UIParent);
	return x, y;
end

function GetScaledCursorDelta()
	local uiScale = GetAppropriateTopLevelParent():GetEffectiveScale();
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
	return {textColor:GetRGB()}, {titleColor:GetRGB()};
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
	elseif ( EditModeManagerFrame:IsShown() ) then
		EditModeManagerFrame.CloseButton:Click();
	elseif ( SocialBrowserFrame and SocialBrowserFrame:IsShown() ) then
		SocialBrowserFrame:Hide();
	elseif ( SettingsPanel:IsShown() ) then
		SettingsPanel:Close();
	elseif ( SocialPostFrame and Social_IsShown() ) then
		Social_SetShown(false);
	elseif ( TimeManagerFrame and TimeManagerFrame:IsShown() ) then
		TimeManagerFrameCloseButton:Click();
	elseif ( MultiCastFlyoutFrame:IsShown() ) then
		MultiCastFlyoutFrame_Hide(MultiCastFlyoutFrame, true);
	elseif (not DISALLOW_SPELL_FLYOUTS and SpellFlyout:IsShown() ) then
		SpellFlyout:Hide();
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
	elseif(MatchCelebrationPartyPoseFrame and MatchCelebrationPartyPoseFrame:IsShown()) then
	elseif ( SoulbindViewer and SoulbindViewer:HandleEscape()) then
	elseif ( ProfessionsFrame and ProfessionsFrame:IsShown() ) then
		ProfessionsFrame:CheckConfirmClose();
	elseif ( securecall("CloseAllWindows") ) then
	elseif ( CovenantPreviewFrame and CovenantPreviewFrame:IsShown()) then
		CovenantPreviewFrame:HandleEscape();
	elseif ( LootFrame:IsShown() ) then
		-- if we're here, LootFrame was opened under the mouse (cvar "lootUnderMouse") so it didn't get closed by CloseAllWindows
		LootFrame:Hide();
	elseif ( C_SpectatingUI and not C_SpectatingUI.IsSpectating() and ClearTarget() and (not UnitIsCharmed("player")) ) then
	elseif ( OpacityFrame:IsShown() ) then
		OpacityFrame:Hide();
	elseif ( SplashFrame:IsShown() ) then
		SplashFrame:Close();
	elseif ( ChallengesKeystoneFrame and ChallengesKeystoneFrame:IsShown() ) then
		ChallengesKeystoneFrame:Hide();
	elseif ( CanAutoSetGamePadCursorControl(false) and (not IsModifierKeyDown()) ) then
		SetGamePadCursorControl(false);
	elseif(ALLOW_PLAYER_CHOICE_ON_GAME_MENU_TOGGLE and PlayerChoiceFrame and PlayerChoiceFrame:IsShown()) then
	elseif(ReportFrame and ReportFrame:IsShown()) then
		ReportFrame:Hide();
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

-- Game Logic --

function OnInviteToPartyConfirmation(name, willConvertToRaid, questSessionActive)
	if questSessionActive then
		QuestSessionManager:OnInviteToPartyConfirmation(name, willConvertToRaid);
	elseif willConvertToRaid then
		local dialog = StaticPopup_Show("CONVERT_TO_RAID");
		if ( dialog ) then
			dialog.data = name;
		end
	else
		C_PartyInfo.ConfirmInviteUnit(name);
	end
end

function GetSocialColoredName(displayName, guid)
	local _, color, relationship = SocialQueueUtil_GetRelationshipInfo(guid);
	if ( relationship ) then
		return color..displayName..FONT_COLOR_CODE_CLOSE;
	end
	return displayName;
end

local function AllowAutoAcceptInviteConfirmation(isQuickJoin, isSelfRelationship)
	return isQuickJoin and isSelfRelationship and GetCVarBool("autoAcceptQuickJoinRequests") and not C_QuestSession.Exists();
end

local function ShouldAutoAcceptInviteConfirmation(invite)
	local confirmationType, name, guid, rolesInvalid, willConvertToRaid = GetInviteConfirmationInfo(invite);
	local _, _, _, isQuickJoin, clubID = C_PartyInfo.GetInviteReferralInfo(invite);
	local _, _, selfRelationship = SocialQueueUtil_GetRelationshipInfo(guid, name, clubID);
	return AllowAutoAcceptInviteConfirmation(isQuickJoin, selfRelationship);
end

function UpdateInviteConfirmationDialogs()
	local invite = GetNextPendingInviteConfirmation();
	if invite then
		HandlePendingInviteConfirmation(invite);
	end
end

function HandlePendingInviteConfirmation(invite)
	if C_QuestSession.HasJoined() then
		HandlePendingInviteConfirmation_QuestSession(invite);
	else
		HandlePendingInviteConfirmation_StaticPopup(invite);
	end
end

function HandlePendingInviteConfirmation_StaticPopup(invite)
	if not StaticPopup_FindVisible("GROUP_INVITE_CONFIRMATION") then
		if ShouldAutoAcceptInviteConfirmation(invite) then
			RespondToInviteConfirmation(invite, true);
		else
			local text = CreatePendingInviteConfirmationText(invite);
			StaticPopup_Show("GROUP_INVITE_CONFIRMATION", text, nil, invite);
		end
	end
end

function HandlePendingInviteConfirmation_QuestSession(invite)
	-- Chances are that we never want to auto-accept in a quest session,
	-- so always show the dialog.
	local text = CreatePendingInviteConfirmationText(invite);
	QuestSessionManager:ShowGroupInviteConfirmation(invite, text);
end

function CreatePendingInviteConfirmationText(invite)
	local confirmationType, name, guid, rolesInvalid, willConvertToRaid, _, _, _, isCrossFaction, playerFactionGroup, localizedFaction = GetInviteConfirmationInfo(invite);

	if confirmationType == LE_INVITE_CONFIRMATION_REQUEST then
		return CreatePendingInviteConfirmationText_Request(invite, name, guid, rolesInvalid, willConvertToRaid, isCrossFaction, playerFactionGroup, localizedFaction);
	elseif confirmationType == LE_INVITE_CONFIRMATION_SUGGEST then
		return CreatePendingInviteConfirmationText_Suggest(invite, name, guid, rolesInvalid, willConvertToRaid, isCrossFaction, playerFactionGroup, localizedFaction);
	else
		return CreatePendingInviteConfirmationText_AppendWarnings("", invite, name, guid, rolesInvalid, willConvertToRaid);
	end
end

function CreatePendingInviteConfirmationText_Request(invite, name, guid, rolesInvalid, willConvertToRaid, isCrossFaction, playerFactionGroup, localizedFaction)
	local coloredName, coloredSuggesterName = CreatePendingInviteConfirmationNames(invite, name, guid, rolesInvalid, willConvertToRaid);

	if isCrossFaction then
		coloredName = CROSS_FACTION_PLAYER_NAME:format(coloredName, localizedFaction);
	end

	local suggesterGuid, _, relationship, isQuickJoin, clubId = C_PartyInfo.GetInviteReferralInfo(invite);

	--If we ourselves have a relationship with this player, we'll just act as if they asked through us.
	local _, _, selfRelationship = SocialQueueUtil_GetRelationshipInfo(guid, name, clubId);

	local text;

	if selfRelationship then
		local clubLink = clubId and GetCommunityLink(clubId) or nil;
		if ( clubLink and selfRelationship == "club" ) then
			if isQuickJoin then
				text = INVITE_CONFIRMATION_REQUEST_FROM_COMMUNITY_QUICKJOIN:format(coloredName, clubLink);
			else
				text = INVITE_CONFIRMATION_REQUEST_FROM_COMMUNITY:format(coloredName, clubLink);
			end
		elseif isQuickJoin then
			text = INVITE_CONFIRMATION_REQUEST_QUICKJOIN:format(coloredName);
		else
			text = INVITE_CONFIRMATION_REQUEST:format(coloredName);
		end
	elseif suggesterGuid then
		if relationship == Enum.PartyRequestJoinRelation.Friend then
			text = (isQuickJoin and INVITE_CONFIRMATION_REQUEST_FRIEND_QUICKJOIN or INVITE_CONFIRMATION_REQUEST_FRIEND):format(coloredSuggesterName, coloredName);
		elseif relationship == Enum.PartyRequestJoinRelation.Guild then
			text = (isQuickJoin and INVITE_CONFIRMATION_REQUEST_GUILD_QUICKJOIN or INVITE_CONFIRMATION_REQUEST_GUILD):format(coloredSuggesterName, coloredName);
		elseif relationship == Enum.PartyRequestJoinRelation.Club then
			text = (isQuickJoin and INVITE_CONFIRMATION_REQUEST_COMMUNITY_QUICKJOIN or INVITE_CONFIRMATION_REQUEST_COMMUNITY):format(coloredSuggesterName, coloredName);
		else
			text = INVITE_CONFIRMATION_REQUEST:format(coloredName);
		end
	else
		text = (isQuickJoin and INVITE_CONFIRMATION_REQUEST_QUICKJOIN or INVITE_CONFIRMATION_REQUEST):format(coloredName);
	end

	return CreatePendingInviteConfirmationText_AppendWarnings(text, invite, name, guid, rolesInvalid, willConvertToRaid);
end

function CreatePendingInviteConfirmationNames(invite, name, guid, rolesInvalid, willConvertToRaid)
	local suggesterGuid, suggesterName, relationship, isQuickJoin, clubId = C_PartyInfo.GetInviteReferralInfo(invite);

	--If we ourselves have a relationship with this player, we'll just act as if they asked through us.
	local _, color, selfRelationship, playerLink = SocialQueueUtil_GetRelationshipInfo(guid, name, clubId);

	name = (playerLink and isQuickJoin) and ("["..playerLink.."]") or name;

	if selfRelationship or isQuickJoin then
		name = color .. name .. FONT_COLOR_CODE_CLOSE;
	end

	if selfRelationship then
		return name;
	elseif suggesterGuid then
		suggesterName = GetSocialColoredName(suggesterName, suggesterGuid);

		if relationship == Enum.PartyRequestJoinRelation.Friend or relationship == Enum.PartyRequestJoinRelation.Guild or relationship == Enum.PartyRequestJoinRelation.Club then
			return name, suggesterName;
		else
			return name;
		end
	else
		return name;
	end
end

function CreatePendingInviteConfirmationText_Suggest(invite, name, guid, rolesInvalid, willConvertToRaid, isCrossFaction, playerFactionGroup, localizedFaction)
	local suggesterGuid, suggesterName, relationship, isQuickJoin = C_PartyInfo.GetInviteReferralInfo(invite);
	suggesterName = GetSocialColoredName(suggesterName, suggesterGuid);
	name = GetSocialColoredName(name, guid);

	if isCrossFaction then
		name = CROSS_FACTION_PLAYER_NAME:format(name, localizedFaction);
	end

	-- Only using a single string here, if somebody is suggesting a person to join the group, QuickJoin text doesn't apply.
	local text = INVITE_CONFIRMATION_SUGGEST:format(suggesterName, name);

	return CreatePendingInviteConfirmationText_AppendWarnings(text, invite, name, guid, rolesInvalid, willConvertToRaid)
end

function CreatePendingInviteConfirmationText_AppendWarnings(text, invite, name, guid, rolesInvalid, willConvertToRaid)
	local warnings = CreatePendingInviteConfirmationText_GetWarnings(invite, name, guid, rolesInvalid, willConvertToRaid);
	if warnings ~= "" then
		if text ~= "" then
			return text.."\n\n"..warnings;
		else
			return warnings;
		end
	end

	return text;
end

function CreatePendingInviteConfirmationText_GetWarnings(invite, name, guid, rolesInvalid, willConvertToRaid)
	local warnings = {};
	local invalidQueues = C_PartyInfo.GetInviteConfirmationInvalidQueues(invite);
	if invalidQueues and #invalidQueues > 0 then
		if rolesInvalid then
			table.insert(warnings, INSTANCE_UNAVAILABLE_OTHER_NO_VALID_ROLES:format(name));
		end

		table.insert(warnings, INVITE_CONFIRMATION_QUEUE_WARNING:format(name));

		for i=1, #invalidQueues do
			local queueName = SocialQueueUtil_GetQueueName(invalidQueues[i]);
			table.insert(warnings, NORMAL_FONT_COLOR:WrapTextInColorCode(queueName));
		end
	end

	if willConvertToRaid then
		table.insert(warnings, RED_FONT_COLOR:WrapTextInColorCode(LFG_LIST_CONVERT_TO_RAID_WARNING));
	end

	return table.concat(warnings, "\n");
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

	local filter = ( checkCVar and CVarCallbackRegistry:GetCVarValueBool("showCastableBuffs") and UnitCanAssist("player", unit) ) and "HELPFUL|RAID" or "HELPFUL";
	local numFrames = 0;
	AuraUtil.ForEachAura(unit, filter, numBuffs, function(...)
		local name, icon, count, debuffType, duration, expirationTime = ...;

		-- if we have an icon to show then proceed with setting up the aura
		if ( icon ) then
			numFrames = numFrames + 1;
			local buffName = frameName..suffix..numFrames;

			-- set the icon
			local buffIcon = _G[buffName.."Icon"];
			buffIcon:SetTexture(icon);

			-- setup the cooldown
			local coolDown = _G[buffName.."Cooldown"];
			if ( coolDown ) then
				CooldownFrame_Set(coolDown, expirationTime - duration, duration, true);
			end

			-- show the aura
			_G[buffName]:Show();
		end
		return numFrames >= numBuffs;
	end);

	for i=numFrames + 1,numBuffs do
		local buffName = frameName..suffix..i;
		local buffFrame = _G[buffName];
		if buffFrame then
			buffFrame:Hide();
		else
			break;
		end
	end
end

function RefreshDebuffs(frame, unit, numDebuffs, suffix, checkCVar)
	local frameName = frame:GetName();
	suffix = suffix or "Debuff";
	local frameNameWithSuffix = frameName..suffix;

	frame.hasDispellable = nil;

	numDebuffs = numDebuffs or MAX_PARTY_DEBUFFS;

	local unitStatus, statusColor;
	local debuffTotal = 0;
	local isEnemy = UnitCanAttack("player", unit);

	local filter = ( checkCVar and CVarCallbackRegistry:GetCVarValueBool("showDispelDebuffs") and UnitCanAssist("player", unit) ) and "HARMFUL|RAID" or "HARMFUL";

	if strsub(unit, 1, 5) == "party" then
		unitStatus = _G[frameName.."Status"];
	end
	AuraUtil.ForEachAura(unit, filter, numDebuffs, function(...)
		local name, icon, count, debuffType, duration, expirationTime, caster = ...;

		if ( icon and ( SHOW_CASTABLE_DEBUFFS == "0" or not isEnemy or caster == "player" ) ) then
			debuffTotal = debuffTotal + 1;
			local debuffName = frameNameWithSuffix..debuffTotal;
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

			-- setup the cooldown
			local coolDown = _G[debuffName.."Cooldown"];
			if ( coolDown ) then
				CooldownFrame_Set(coolDown, expirationTime - duration, duration, true);
			end

			-- show the aura
			_G[debuffName]:Show();
		end
		return debuffTotal >= numDebuffs;
	end);

	for i=debuffTotal+1,numDebuffs do
		local debuffName = frameNameWithSuffix..i;
		_G[debuffName]:Hide();
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

-- New Color API
-- This function is intended to be used with C++ wrapped functions that return the difficulty of content instead
-- of hand calculating the difficulty in the UI like the below APIs do. You should get difficulty color
-- like this:
-- local difficulty = C_PlayerInfo.GetContentDifficultyCreatureForPlayer(self.unit)
-- local color = GetDifficultyColor(difficulty);
function GetDifficultyColor(difficulty)
	if (difficulty == Enum.RelativeContentDifficulty.Trivial) then
		return QuestDifficultyColors["trivial"], QuestDifficultyHighlightColors["trivial"]; -- Grey
	elseif (difficulty == Enum.RelativeContentDifficulty.Easy) then
		return QuestDifficultyColors["standard"], QuestDifficultyHighlightColors["standard"]; -- Green
	elseif (difficulty == Enum.RelativeContentDifficulty.Fair) then
		return QuestDifficultyColors["difficult"], QuestDifficultyHighlightColors["difficult"]; -- Yellow
	elseif (difficulty == Enum.RelativeContentDifficulty.Difficult) then
		return QuestDifficultyColors["verydifficult"], QuestDifficultyHighlightColors["verydifficult"]; -- Orange
	elseif (difficulty == Enum.RelativeContentDifficulty.Impossible) then
		return QuestDifficultyColors["impossible"], QuestDifficultyHighlightColors["impossible"]; -- Red
	else
		return QuestDifficultyColors["difficult"], QuestDifficultyHighlightColors["difficult"]; -- Yellow
	end
end

-- Old Color API (See Comment Above: New Color API)
function GetQuestDifficultyColor(level, isScaling, optQuestID)
	if optQuestID and C_QuestLog.IsQuestDisabledForSession(optQuestID) then
		return QuestDifficultyColors["disabled"], QuestDifficultyHighlightColors["disabled"];
	end

	if (isScaling) then
		return GetScalingQuestDifficultyColor(level);
	end

	return GetRelativeDifficultyColor(UnitEffectiveLevel("player"), level);
end

-- Old Color API (See Comment Above: New Color API)
function GetCreatureDifficultyColor(level)
	return GetRelativeDifficultyColor(UnitEffectiveLevel("player"), level);
end

--How difficult is this challenge for this unit?
-- Old Color API (See Comment Above: New Color API)
function GetRelativeDifficultyColor(unitLevel, challengeLevel)
	local levelDiff = challengeLevel - unitLevel;
	local color;
	if ( levelDiff >= 5 ) then
		return QuestDifficultyColors["impossible"], QuestDifficultyHighlightColors["impossible"];
	elseif ( levelDiff >= 3 ) then
		return QuestDifficultyColors["verydifficult"], QuestDifficultyHighlightColors["verydifficult"];
	elseif ( levelDiff >= -4 ) then
		return QuestDifficultyColors["difficult"], QuestDifficultyHighlightColors["difficult"];
	elseif ( -levelDiff <= UnitQuestTrivialLevelRange("player") ) then
		return QuestDifficultyColors["standard"], QuestDifficultyHighlightColors["standard"];
	else
		return QuestDifficultyColors["trivial"], QuestDifficultyHighlightColors["trivial"];
	end
end

-- Old Color API (See Comment Above: New Color API)
function GetScalingQuestDifficultyColor(questLevel)
	local playerLevel = UnitEffectiveLevel("player");
	local levelDiff = questLevel - playerLevel;
	if ( levelDiff >= 5 ) then
		return QuestDifficultyColors["impossible"], QuestDifficultyHighlightColors["impossible"];
	elseif ( levelDiff >= 3 ) then
		return QuestDifficultyColors["verydifficult"], QuestDifficultyHighlightColors["verydifficult"];
	elseif ( levelDiff >= 0 ) then
		return QuestDifficultyColors["difficult"], QuestDifficultyHighlightColors["difficult"];
	elseif ( -levelDiff <= UnitQuestTrivialLevelRangeScaling("player") ) then
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




function ConsolePrint(...)
	local printMsg = string.join(" ", tostringall(...));
	C_Log.LogMessage(Enum.LogPriority.Normal, printMsg);
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

function GetLFGMode(category, lfgID)
	if ( category ~= LE_LFG_CATEGORY_RF ) then
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

function OnExcessiveErrors()
	StaticPopup_Show("TOO_MANY_LUA_ERRORS");
end

function ShouldShowArenaParty()
	return IsActiveBattlefieldArena() and not C_PvP.IsInBrawl();
end

function ShouldShowPartyFrames()
	return ShouldShowArenaParty() or (IsInGroup() and not IsInRaid()) or EditModeManagerFrame:ArePartyFramesForcedShown();
end

function ShouldShowRaidFrames()
	return not ShouldShowArenaParty() and IsInRaid() or EditModeManagerFrame:AreRaidFramesForcedShown();
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
	-- Order these from largest to smallest.
	--
	-- significandDivisor and fractionDivisor should multiply such that they
	-- become equal to a named order of magnitude, such as thousands or
	-- millions.
	--
	-- Breakpoints should generally be specified as pairs, with one at the
	-- named order (1,000) with fractionDivisor = 10, and one a single order
	-- higher (eg. 10,000) with fractionDivisor = 1.
	--
	-- This ruleset means numbers like "1234" will be abbreviated to "1.2k"
	-- and numbers like "12345" to "12k".
	--
	-- Note that this table may be overridden in Localization!

	{ breakpoint = 10000000000000,	abbreviation = FOURTH_NUMBER_CAP_NO_SPACE,		significandDivisor = 1000000000000,	fractionDivisor = 1 },
	{ breakpoint = 1000000000000,	abbreviation = FOURTH_NUMBER_CAP_NO_SPACE,		significandDivisor = 100000000000,	fractionDivisor = 10 },
	{ breakpoint = 10000000000,		abbreviation = THIRD_NUMBER_CAP_NO_SPACE,		significandDivisor = 1000000000,	fractionDivisor = 1 },
	{ breakpoint = 1000000000,		abbreviation = THIRD_NUMBER_CAP_NO_SPACE,		significandDivisor = 100000000,		fractionDivisor = 10 },
	{ breakpoint = 10000000,		abbreviation = SECOND_NUMBER_CAP_NO_SPACE,		significandDivisor = 1000000,		fractionDivisor = 1 },
	{ breakpoint = 1000000,			abbreviation = SECOND_NUMBER_CAP_NO_SPACE,		significandDivisor = 100000,		fractionDivisor = 10 },
	{ breakpoint = 10000,			abbreviation = FIRST_NUMBER_CAP_NO_SPACE,		significandDivisor = 1000,			fractionDivisor = 1 },
	{ breakpoint = 1000,			abbreviation = FIRST_NUMBER_CAP_NO_SPACE,		significandDivisor = 100,			fractionDivisor = 10 },
};

function IsInLFDBattlefield()
	return IsLFGModeActive(LE_LFG_CATEGORY_BATTLEFIELD);
end

function LeaveInstanceParty()
	if ( IsInLFDBattlefield() ) then
		local currentMapID, _, lfgID = select(8, GetInstanceInfo());
		local _, typeID, subtypeID, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, lfgMapID = GetLFGDungeonInfo(lfgID);
		if currentMapID == lfgMapID and subtypeID == LE_LFG_CATEGORY_BATTLEFIELD then
			LFGTeleport(true);
			return;
		end
	end
	C_PartyInfo.LeaveParty(LE_PARTY_CATEGORY_INSTANCE);
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

-- WALK_IN party members automatically leave the party upon zoning out
-- Porting out of a delve is only allowed when the delve is complete (unless a hearthstone or other tool is used)
function LeaveWalkInParty()
	C_PartyInfo.DelveTeleportOut();
end

function ConfirmOrLeaveParty()
	if ( not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
		return;
	end

	if ( IsPartyLFG() ) then
		ConfirmOrLeaveLFGParty();
	-- If the party is walk-in (aka Delve) let the player leave
	elseif ( C_PartyInfo.IsPartyWalkIn() ) then
		LeaveWalkInParty();
	end
end

function ConfirmOrLeaveBattlefield()
	if ( GetBattlefieldWinner() ) then
		LeaveBattlefield();
	else
		StaticPopupDialogs["CONFIRM_LEAVE_BATTLEFIELD"].acceptDelay = C_PvP.IsInRatedMatchWithDeserterPenalty() and 5 or nil;
		StaticPopup_Show("CONFIRM_LEAVE_BATTLEFIELD");
	end
end

function ConfirmSurrenderArena()
	StaticPopup_Show("CONFIRM_SURRENDER_ARENA");
end

function GetCurrentScenarioType()
	local scenarioType = select(10, C_Scenario.GetInfo());
	return scenarioType;
end

function IsBoostTutorialScenario()
	return GetCurrentScenarioType() == LE_SCENARIO_TYPE_BOOST_TUTORIAL;
end

function PrintLootSpecialization()
	local specID = GetLootSpecialization();
	local sex = UnitSex("player");
	local lootSpecChoice;
	if ( specID and specID > 0 ) then
		local id, name = GetSpecializationInfoByID(specID, sex);
		lootSpecChoice = format(ERR_LOOT_SPEC_CHANGED_S, name);
--[[	else
		local specIndex = GetSpecialization();
		if ( specIndex) then
			local specID, specName = GetSpecializationInfo(specIndex, nil, nil, nil, sex);
			if ( specName ) then
				lootSpecChoice = format(ERR_LOOT_SPEC_CHANGED_S, format(LOOT_SPECIALIZATION_DEFAULT, specName));
			end
		end]]
	end
	if ( lootSpecChoice ) then
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(lootSpecChoice, info.r, info.g, info.b, info.id);
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

function WillAcceptInviteRemoveQueues()
	--Dungeon/Raid Finder
	for i=1, NUM_LE_LFG_CATEGORYS do
		local mode = GetLFGMode(i);
		if ( mode and mode ~= "lfgparty" ) then
			return true;
		end
	end

	--Don't need to look at LFGList listings because we can't accept invites while in one

	--LFGList applications
	local apps = C_LFGList.GetApplications();
	for i=1, #apps do
		local _, appStatus = C_LFGList.GetApplicationInfo(apps[i]);
		if ( appStatus == "applied" or appStatus == "invited" ) then
			return true;
		end
	end

	--PvP
	for i=1, GetMaxBattlefieldID() do
		local status, mapName, teamSize, registeredMatch, suspend, _, _, _, _, _, _, isSoloQueue = GetBattlefieldStatus(i);
		if ( (status == "queued" or status == "confirmed" ) and not isSoloQueue ) then
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

		local party, isSoloQueueParty = C_SocialQueue.GetGroupForPlayer(guid);
		if ( party and not isSoloQueueParty ) then --In a real party, not a secret hidden party for solo queuing
			return "REQUEST_INVITE";
		elseif ( WillAcceptInviteRemoveQueues() ) then
			return "INVITE";
		elseif ( party ) then --They are queued solo for something
			return "REQUEST_INVITE";
		else
			return "INVITE";
		end
	end
end

function nop()
end

-- Currency Overflow --
function WillCurrencyRewardOverflow(currencyID, rewardQuantity)
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
	local quantity = currencyInfo.useTotalEarnedForMaxQty and currencyInfo.totalEarned or currencyInfo.quantity;
	return currencyInfo.maxQuantity > 0 and rewardQuantity + quantity > currencyInfo.maxQuantity;
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

function IsLevelAtEffectiveMaxLevel(level)
	return level >= GetMaxLevelForPlayerExpansion();
end

function IsPlayerAtEffectiveMaxLevel()
	return IsLevelAtEffectiveMaxLevel(UnitLevel("player"));
end

local INTERFACE_ACTION_BLOCKED_COUNT = 0;

function DisplayInterfaceActionBlockedMessage()
	if ( INTERFACE_ACTION_BLOCKED_COUNT > 50000 ) then
		INTERFACE_ACTION_BLOCKED_COUNT = 0;
	end
	INTERFACE_ACTION_BLOCKED_COUNT = INTERFACE_ACTION_BLOCKED_COUNT + 1;

	if ( INTERFACE_ACTION_BLOCKED_COUNT == 1 ) then
		local info = ChatTypeInfo["SYSTEM"];
		DEFAULT_CHAT_FRAME:AddMessage(INTERFACE_ACTION_BLOCKED, info.r, info.g, info.b, info.id);
	end
end
function AllowChatFramesToShow(chatFrame)
	-- this is InGame - and we always show while InGame.  chatFrame is not referenced, only Glues
	return true;
end
