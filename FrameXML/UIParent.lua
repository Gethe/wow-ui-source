TOOLTIP_UPDATE_TIME = 0.2;
ROTATIONS_PER_SECOND = .5;

-- Alpha animation stuff
FADEFRAMES = {};
FLASHFRAMES = {};

-- Pulsing stuff
PULSEBUTTONS = {};

-- Needs to be defined here so the manage frames function works properly
BATTLEFIELD_TAB_OFFSET_Y = 0;

UIPanelWindows = {};
UIPanelWindows["GameMenuFrame"] =		{ area = "center",	pushable = 0,	whileDead = 1 };
UIPanelWindows["OptionsFrame"] =		{ area = "center",	pushable = 0,	whileDead = 1 };
UIPanelWindows["SoundOptionsFrame"] =		{ area = "center",	pushable = 0,	whileDead = 1 };
UIPanelWindows["UIOptionsFrame"] =		{ area = "center",	pushable = 0,	whileDead = 1 };
UIPanelWindows["CharacterFrame"] =		{ area = "left",	pushable = 2 ,	whileDead = 1};
UIPanelWindows["ItemTextFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["SpellBookFrame"] =		{ area = "left",	pushable = 0,	whileDead = 1 };
UIPanelWindows["LootFrame"] =			{ area = "left",	pushable = 7 };
UIPanelWindows["TaxiFrame"] =			{ area = "left",	pushable = 0 };
UIPanelWindows["QuestFrame"] =			{ area = "left",	pushable = 0 };
UIPanelWindows["QuestLogFrame"] =		{ area = "left",	pushable = 0,	whileDead = 1 };
UIPanelWindows["MerchantFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["TradeFrame"] =			{ area = "left",	pushable = 1 };
UIPanelWindows["BankFrame"] =			{ area = "left",	pushable = 6 };
UIPanelWindows["FriendsFrame"] =		{ area = "left",	pushable = 0,	whileDead = 1 };
UIPanelWindows["WorldMapFrame"] =		{ area = "full",	pushable = 0,	whileDead = 1 };
UIPanelWindows["CinematicFrame"] =		{ area = "full",	pushable = 0 };
UIPanelWindows["TabardFrame"] =			{ area = "left",	pushable = 0 };
UIPanelWindows["GuildRegistrarFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["PetitionFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["HelpFrame"] =			{ area = "center",	pushable = 0,	whileDead = 1 };
UIPanelWindows["GossipFrame"] =			{ area = "left",	pushable = 0 };
UIPanelWindows["MailFrame"] =			{ area = "left",	pushable = 0 };
UIPanelWindows["BattlefieldFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["PetStableFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["WorldStateScoreFrame"] =	{ area = "center",	pushable = 0,	whileDead = 1 };
UIPanelWindows["DressUpFrame"] =		{ area = "left",	pushable = 2 };
UIPanelWindows["MinigameFrame"] =		{ area = "left",	pushable = 0 };

-- These are windows that rely on a parent frame to be open.  If the parent closes or a pushable frame overlaps them they must be hidden.
UIChildWindows = {
	"OpenMailFrame",
	"GuildControlPopupFrame",
	"GuildMemberDetailFrame",
	"GuildInfoFrame",
};

UISpecialFrames = {
	"ItemRefTooltip",
	"ColorPickerFrame"
};

UIMenus = {
	"ChatMenu",
	"EmoteMenu",
	"LanguageMenu",
	"DropDownList1",
	"DropDownList2"
};

ITEM_QUALITY_COLORS = { };
for i = -1, 6 do
	ITEM_QUALITY_COLORS[i] = { };
	ITEM_QUALITY_COLORS[i].r,
	ITEM_QUALITY_COLORS[i].g,
	ITEM_QUALITY_COLORS[i].b,
	ITEM_QUALITY_COLORS[i].hex = GetItemQualityColor(i);
end

function UIParent_OnLoad()
	this:RegisterEvent("PLAYER_DEAD");
	this:RegisterEvent("PLAYER_ALIVE");
	this:RegisterEvent("PLAYER_UNGHOST");
	this:RegisterEvent("RESURRECT_REQUEST");
	this:RegisterEvent("PLAYER_SKINNED");
	this:RegisterEvent("TRADE_REQUEST");
	this:RegisterEvent("PARTY_INVITE_REQUEST");
	this:RegisterEvent("PARTY_INVITE_CANCEL");
	this:RegisterEvent("GUILD_INVITE_REQUEST");
	this:RegisterEvent("GUILD_INVITE_CANCEL");
	this:RegisterEvent("PLAYER_CAMPING");
	this:RegisterEvent("PLAYER_QUITING");
	this:RegisterEvent("LOGOUT_CANCEL");
	this:RegisterEvent("LOOT_BIND_CONFIRM");
	this:RegisterEvent("EQUIP_BIND_CONFIRM");
	this:RegisterEvent("AUTOEQUIP_BIND_CONFIRM");
	this:RegisterEvent("USE_BIND_CONFIRM");
	this:RegisterEvent("DELETE_ITEM_CONFIRM");
	this:RegisterEvent("QUEST_ACCEPT_CONFIRM");
	this:RegisterEvent("CURSOR_UPDATE");
	this:RegisterEvent("LOCALPLAYER_PET_RENAMED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("MIRROR_TIMER_START");
	this:RegisterEvent("DUEL_REQUESTED");
	this:RegisterEvent("DUEL_OUTOFBOUNDS");
	this:RegisterEvent("DUEL_INBOUNDS");
	this:RegisterEvent("DUEL_FINISHED");
	this:RegisterEvent("TRADE_REQUEST_CANCEL");
	this:RegisterEvent("CONFIRM_XP_LOSS");
	this:RegisterEvent("CORPSE_IN_RANGE");
	this:RegisterEvent("CORPSE_IN_INSTANCE");
	this:RegisterEvent("CORPSE_OUT_OF_RANGE");
	this:RegisterEvent("AREA_SPIRIT_HEALER_IN_RANGE");
	this:RegisterEvent("AREA_SPIRIT_HEALER_OUT_OF_RANGE");
	this:RegisterEvent("BIND_ENCHANT");
	this:RegisterEvent("REPLACE_ENCHANT");
	this:RegisterEvent("TRADE_REPLACE_ENCHANT");
	this:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
	this:RegisterEvent("MACRO_ACTION_FORBIDDEN");
	this:RegisterEvent("ADDON_ACTION_FORBIDDEN");
	this:RegisterEvent("MEMORY_EXHAUSTED");
	this:RegisterEvent("MEMORY_RECOVERED");
	this:RegisterEvent("PLAYER_CONTROL_LOST");
	this:RegisterEvent("PLAYER_CONTROL_GAINED");
	this:RegisterEvent("START_LOOT_ROLL");
	this:RegisterEvent("CONFIRM_LOOT_ROLL");
	this:RegisterEvent("INSTANCE_BOOT_START");
	this:RegisterEvent("INSTANCE_BOOT_STOP");
	this:RegisterEvent("CONFIRM_TALENT_WIPE");
	this:RegisterEvent("CONFIRM_PET_UNLEARN");
	this:RegisterEvent("CONFIRM_BINDER");
	this:RegisterEvent("CONFIRM_SUMMON");
	this:RegisterEvent("GOSSIP_ENTER_CODE");
	this:RegisterEvent("BILLING_NAG_DIALOG");
	this:RegisterEvent("IGR_BILLING_NAG_DIALOG");
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("RAID_ROSTER_UPDATE");
	this:RegisterEvent("READY_CHECK");

	-- Events for auction UI handling
	this:RegisterEvent("AUCTION_HOUSE_SHOW");
	this:RegisterEvent("AUCTION_HOUSE_CLOSED");

	-- Events for trainer UI handling
	this:RegisterEvent("TRAINER_SHOW");
	this:RegisterEvent("TRAINER_CLOSED");

	-- Events for trade skill UI handling
	this:RegisterEvent("TRADE_SKILL_SHOW");
	this:RegisterEvent("TRADE_SKILL_CLOSE");

	-- Events for craft UI handling
	this:RegisterEvent("CRAFT_SHOW");
	this:RegisterEvent("CRAFT_CLOSE");

	TALENT_FRAME_WAS_SHOWN = nil;
	RegisterForSave("TALENT_FRAME_WAS_SHOWN");
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

function CraftFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_CraftUI");
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

function ShowMacroFrame()
	MacroFrame_LoadUI();
	if ( MacroFrame_Show ) then
		MacroFrame_Show();
	end
end

function ToggleTalentFrame()
	if ( UnitLevel("player") < 10 ) then
		return;
	end

	TalentFrame_LoadUI();
	if ( TalentFrame_Toggle ) then
		TalentFrame_Toggle();
	end
end

function ToggleBattlefieldMinimap()
	BattlefieldMinimap_LoadUI();
	if ( BattlefieldMinimap_Toggle ) then
		BattlefieldMinimap_Toggle();
	end
end

function InspectUnit(unit)
	InspectFrame_LoadUI();
	if ( InspectFrame_Show ) then
		InspectFrame_Show(unit);
	end
end

function UIParent_OnEvent(event)
	if ( event == "VARIABLES_LOADED" ) then
		LocalizeFrames();
		-- Update nameplates
		UpdateNameplates();
		return;
	end
	if ( event == "PLAYER_DEAD" ) then
		if ( not StaticPopup_Visible("DEATH") ) then
			CloseAllWindows(1);
			if ( GetReleaseTimeRemaining() > 0 or GetReleaseTimeRemaining() == -1 ) then
				StaticPopup_Show("DEATH");
			end
		end
		return;
	end	
	if ( event == "PLAYER_ALIVE" ) then
		StaticPopup_Hide("DEATH");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		return;
	end
	if ( event == "PLAYER_UNGHOST" ) then
		StaticPopup_Hide("RESURRECT");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		StaticPopup_Hide("RESURRECT_NO_TIMER");
		StaticPopup_Hide("SKINNED");
		StaticPopup_Hide("SKINNED_REPOP");
		return;
	end
	if ( event == "RESURRECT_REQUEST" ) then
		if ( ResurrectHasSickness() ) then
			StaticPopup_Show("RESURRECT", arg1);
		elseif ( ResurrectHasTimer() ) then
			StaticPopup_Show("RESURRECT_NO_SICKNESS", arg1);
		else
			StaticPopup_Show("RESURRECT_NO_TIMER", arg1);
		end
		return;
	end
	if ( event == "PLAYER_SKINNED" ) then
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
		return;		
	end
	if ( event == "TRADE_REQUEST" ) then
		StaticPopup_Show("TRADE", arg1);
		return;
	end
	if ( event == "PARTY_INVITE_REQUEST" ) then
		StaticPopup_Show("PARTY_INVITE", arg1);
		return;
	end
	if ( event == "PARTY_INVITE_CANCEL" ) then
		StaticPopup_Hide("PARTY_INVITE");
		return;
	end
	if ( event == "GUILD_INVITE_REQUEST" ) then
		StaticPopup_Show("GUILD_INVITE", arg1, arg2);
		return;
	end
	if ( event == "GUILD_INVITE_CANCEL" ) then
		StaticPopup_Hide("GUILD_INVITE");
		return;
	end
	if ( event == "PLAYER_CAMPING" ) then
		StaticPopup_Show("CAMP");
		return;
	end
	if ( event == "PLAYER_QUITING" ) then
		StaticPopup_Show("QUIT");
		return;
	end
	if ( event == "LOGOUT_CANCEL" ) then
		StaticPopup_Hide("CAMP");
		StaticPopup_Hide("QUIT");
		return;
	end
	if ( event == "LOOT_BIND_CONFIRM" ) then
		local dialog = StaticPopup_Show("LOOT_BIND");
		if ( dialog ) then
			dialog.data = arg1;
		end
		return;
	end
	if ( event == "EQUIP_BIND_CONFIRM" ) then
		StaticPopup_Hide("AUTOEQUIP_BIND");
		local dialog = StaticPopup_Show("EQUIP_BIND");
		if ( dialog ) then
			dialog.data = arg1;
		end
		return;
	end
	if ( event == "AUTOEQUIP_BIND_CONFIRM" ) then
		StaticPopup_Hide("EQUIP_BIND");
		local dialog = StaticPopup_Show("AUTOEQUIP_BIND");
		if ( dialog ) then
			dialog.data = arg1;
		end
		return;
	end
	if ( event == "USE_BIND_CONFIRM" ) then
		StaticPopup_Show("USE_BIND");
		return;
	end
	if ( event == "DELETE_ITEM_CONFIRM" ) then
		-- Check quality
		if ( arg2 >= 3 ) then
			StaticPopup_Show("DELETE_GOOD_ITEM", arg1);
		else
			StaticPopup_Show("DELETE_ITEM", arg1);
		end
		return;
	end
	if ( event == "QUEST_ACCEPT_CONFIRM" ) then
		StaticPopup_Show("QUEST_ACCEPT", arg1, arg2);
		return;
	end
	if ( event == "CURSOR_UPDATE" ) then
		StaticPopup_Hide("EQUIP_BIND");
		StaticPopup_Hide("AUTOEQUIP_BIND");
		return;
	end
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		-- Get multi-actionbar states
		SHOW_MULTI_ACTIONBAR_1, SHOW_MULTI_ACTIONBAR_2, SHOW_MULTI_ACTIONBAR_3, SHOW_MULTI_ACTIONBAR_4 = GetActionBarToggles();
		MultiActionBar_Update();
		-- Update nameplates
		UpdateNameplates();
		return;
	end
	if ( event == "RAID_ROSTER_UPDATE" ) then
		-- Hide/Show party member frames
		RaidOptionsFrame_UpdatePartyFrames();
	end
	if ( event == "MIRROR_TIMER_START" ) then
		MirrorTimer_Show(arg1, arg2, arg3, arg4, arg5, arg6);
		return;
	end
	if ( event == "DUEL_REQUESTED" ) then
		StaticPopup_Show("DUEL_REQUESTED", arg1);
		return;
	end
	if ( event == "DUEL_OUTOFBOUNDS" ) then
		StaticPopup_Show("DUEL_OUTOFBOUNDS");
		return;
	end
	if ( event == "DUEL_INBOUNDS" ) then
		StaticPopup_Hide("DUEL_OUTOFBOUNDS");
		return;
	end
	if ( event == "DUEL_FINISHED" ) then
		StaticPopup_Hide("DUEL_REQUESTED");
		StaticPopup_Hide("DUEL_OUTOFBOUNDS");
		return;
	end
	if ( event == "TRADE_REQUEST_CANCEL" ) then
		StaticPopup_Hide("TRADE");
		return;
	end
	if ( event == "CONFIRM_XP_LOSS" ) then
		local resSicknessTime = GetResSicknessDuration();
		if ( resSicknessTime ) then
			local dialog = StaticPopup_Show("XP_LOSS", resSicknessTime);
			if ( dialog ) then
				dialog.data = resSicknessTime;
			end
		else
			local dialog = StaticPopup_Show("XP_LOSS_NO_SICKNESS");
			if ( dialog ) then
				dialog.data = 1;
			end
		end
		HideUIPanel(GossipFrame);
		return;
	end
	if ( event == "CORPSE_IN_RANGE" ) then
		StaticPopup_Show("RECOVER_CORPSE");
		return;
	end
	if ( event == "CORPSE_IN_INSTANCE" ) then
		StaticPopup_Show("RECOVER_CORPSE_INSTANCE");
		return;
	end
	if ( event == "CORPSE_OUT_OF_RANGE" ) then
		StaticPopup_Hide("RECOVER_CORPSE");
		StaticPopup_Hide("RECOVER_CORPSE_INSTANCE");
		StaticPopup_Hide("XP_LOSS");
		return;
	end
	if ( event == "AREA_SPIRIT_HEALER_IN_RANGE" ) then
		StaticPopup_Show("AREA_SPIRIT_HEAL");
		return;
	end
	if ( event == "AREA_SPIRIT_HEALER_OUT_OF_RANGE" ) then
		StaticPopup_Hide("AREA_SPIRIT_HEAL");
		return;
	end
	if ( event == "BIND_ENCHANT" ) then
		StaticPopup_Show("BIND_ENCHANT");
		return;
	end
	if ( event == "REPLACE_ENCHANT" ) then
		StaticPopup_Show("REPLACE_ENCHANT", arg1, arg2);
		return;
	end
	if ( event == "TRADE_REPLACE_ENCHANT" ) then
		StaticPopup_Show("TRADE_REPLACE_ENCHANT", arg1, arg2);
		return;
	end
	if ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
		StaticPopup_Hide("BIND_ENCHANT");
		StaticPopup_Hide("REPLACE_ENCHANT");
		StaticPopup_Hide("TRADE_REPLACE_ENCHANT");
		return;
	end
	if ( event == "MACRO_ACTION_FORBIDDEN" ) then
		StaticPopup_Show("MACRO_ACTION_FORBIDDEN");
		return;
	end
	if ( event == "ADDON_ACTION_FORBIDDEN" ) then
		local dialog = StaticPopup_Show("ADDON_ACTION_FORBIDDEN", arg1);
		if ( dialog ) then
			dialog.data = arg1;
		end
		return;
	end
	if ( event == "MEMORY_EXHAUSTED" ) then
		StaticPopup_Show("MEMORY_EXHAUSTED", arg1);
		return;
	end
	if ( event == "MEMORY_RECOVERED" ) then
		StaticPopup_Hide("MEMORY_EXHAUSTED");
		return;
	end
	if ( event == "PLAYER_CONTROL_LOST" ) then
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
		SocialsMicroButton:Disable();
		WorldMapMicroButton:Disable();
		]]


		UIParent.isOutOfControl = 1;
		return;
	end
	if ( event == "PLAYER_CONTROL_GAINED" ) then
		--[[
		-- Enable all microbuttons
		SetDesaturation(MicroButtonPortrait, nil);

		CharacterMicroButton:Enable();
		SpellbookMicroButton:Enable();
		TalentMicroButton:Enable();
		QuestLogMicroButton:Enable();
		SocialsMicroButton:Enable();
		WorldMapMicroButton:Enable();
		]]

		UIParent.isOutOfControl = nil;
		return;
	end
	if ( event == "START_LOOT_ROLL" ) then
		GroupLootFrame_OpenNewFrame(arg1, arg2);
		return;
	end
	if ( event == "CONFIRM_LOOT_ROLL" ) then
		local dialog = StaticPopup_Show("CONFIRM_LOOT_ROLL");
		if ( dialog ) then
			dialog.data = arg1;
			dialog.data2 = arg2;
		end
		return;
	end
	if ( event == "INSTANCE_BOOT_START" ) then
		StaticPopup_Show("INSTANCE_BOOT");
		return;
	end
	if ( event == "INSTANCE_BOOT_STOP" ) then
		StaticPopup_Hide("INSTANCE_BOOT");
		return;
	end
	if ( event == "CONFIRM_TALENT_WIPE" ) then
		local dialog = StaticPopup_Show("CONFIRM_TALENT_WIPE");
		if ( dialog ) then
			MoneyFrame_Update(dialog:GetName().."MoneyFrame", arg1);
		end
		return;
	end
	if ( event == "CONFIRM_PET_UNLEARN" ) then
		local dialog = StaticPopup_Show("CONFIRM_PET_UNLEARN");
		if ( dialog ) then
			MoneyFrame_Update(dialog:GetName().."MoneyFrame", arg1);
		end
		return;
	end
	if ( event == "CONFIRM_BINDER" ) then
		StaticPopup_Show("CONFIRM_BINDER", arg1);
		return;
	end
	if ( event == "CONFIRM_SUMMON" ) then
		StaticPopup_Show("CONFIRM_SUMMON");
		return;
	end
	if ( event == "BILLING_NAG_DIALOG" ) then
		StaticPopup_Show("BILLING_NAG", arg1);
		return;
	end
	if ( event == "IGR_BILLING_NAG_DIALOG" ) then
		StaticPopup_Show("IGR_BILLING_NAG");
		return;
	end
	if ( event == "GOSSIP_ENTER_CODE" ) then
		local dialog = StaticPopup_Show("GOSSIP_ENTER_CODE");
		if ( dialog ) then
			dialog.data = arg1;
		end
		return;
	end
	if ( event == "READY_CHECK" ) then
		ShowReadyCheck();
		return;
	end

	-- Events for auction UI handling
	if ( event == "AUCTION_HOUSE_SHOW" ) then
		AuctionFrame_LoadUI();
		if ( AuctionFrame_Show ) then
			AuctionFrame_Show();
		end
		return;
	end
	if ( event == "AUCTION_HOUSE_CLOSED" ) then
		if ( AuctionFrame_Hide ) then
			AuctionFrame_Hide();
		end
		return;
	end

	-- Events for trainer UI handling
	if ( event == "TRAINER_SHOW" ) then
		ClassTrainerFrame_LoadUI();
		if ( ClassTrainerFrame_Show ) then
			ClassTrainerFrame_Show();
		end
		return;
	end
	if ( event == "TRAINER_CLOSED" ) then
		if ( ClassTrainerFrame_Hide ) then
			ClassTrainerFrame_Hide();
		end
		return;
	end

	-- Events for trade skill UI handling
	if ( event == "TRADE_SKILL_SHOW" ) then
		TradeSkillFrame_LoadUI();
		if ( TradeSkillFrame_Show ) then
			TradeSkillFrame_Show();						
		end
		return;
	end
	if ( event == "TRADE_SKILL_CLOSE" ) then
		if ( TradeSkillFrame_Hide ) then
			TradeSkillFrame_Hide();
		end
		return;
	end

	-- Events for craft UI handling
	if ( event == "CRAFT_SHOW" ) then
		CraftFrame_LoadUI();
		if ( CraftFrame_Show ) then
			CraftFrame_Show();
		end
		return;
	end
	if ( event == "CRAFT_CLOSE" ) then
		if ( CraftFrame_Hide ) then
			CraftFrame_Hide();
		end
		return;
	end
end

local FailedAddOnLoad = {};

function UIParentLoadAddOn(name)
	local loaded, reason = LoadAddOn(name);
	if ( not loaded ) then
		if ( not FailedAddOnLoad[name] ) then
			message(format(TEXT(ADDON_LOAD_FAILED), name, TEXT(getglobal("ADDON_"..reason))));
			FailedAddOnLoad[name] = true;
		end
	end
	return loaded;
end

function ShowUIPanel(frame, force)	
	if ( not frame or frame:IsVisible() ) then
		return;
	end
	
	local info = UIPanelWindows[frame:GetName()];
	if ( not CanOpenPanels() and info and info.area ~= "center" ) then
		return;
	end
	if ( not info ) then
		frame:Show();
		return;
	end

	if ( UnitIsDead("player") and not info.whileDead ) then
		NotWhileDeadError();
		return;
	end

	-- If we have a full-screen frame open, ignore other non-fullscreen open requests
	if ( GetFullScreenFrame() and (info.area ~= "full") ) then
		if ( force ) then
			SetFullScreenFrame(nil);
		else
			return;
		end
	end

	-- If we have a "center" frame open, only listen to other "center" open requests
	local centerFrame = GetCenterFrame();
	local centerInfo = nil;
	if ( centerFrame ) then
		centerInfo = UIPanelWindows[centerFrame:GetName()];
		if ( centerInfo and (centerInfo.area == "center")  and (info.area ~= "center") ) then
			if ( force ) then
				SetCenterFrame(nil);
			else
				return;
			end
		end
	end
	
	-- Full-screen frames just replace each other
	if ( info.area == "full" ) then
		CloseAllWindows();
		SetFullScreenFrame(frame);
		return;
	end
	
	-- Native "center" frames just replace each other, and they take priority over pushed frames
	if ( info.area == "center" ) then
		CloseWindows();
		CloseAllBags();
		SetCenterFrame(frame, 1);
		return;
	end

	-- Doublewide frames take up the left and center spots
	if ( info.area == "doublewide" ) then
		SetDoublewideFrame(frame);
		return;
	end
	
	-- Close any doublewide frames
	local doublewideFrame = GetDoublewideFrame();
	if ( doublewideFrame ) then
		doublewideFrame:Hide();
	end
	
	-- Try to put it on the left
	local leftFrame = GetLeftFrame();
	if ( not leftFrame ) then
		SetLeftFrame(frame);
		return;
	end

	-- If there's only one open...
	leftInfo = UIPanelWindows[leftFrame:GetName()];
	if ( not centerFrame ) then
		-- If neither is pushable, replace
		if ( (leftInfo.pushable == 0) and (info.pushable == 0) ) then
			SetLeftFrame(frame);
			return;
		end

		-- Highest priority goes to center
		if ( leftInfo.pushable > info.pushable ) then
			MovePanelToCenter();
			SetLeftFrame(frame);
		else
			SetCenterFrame(frame);
		end
		return;
	end

	-- Center is already taken too...
	if ( info.pushable > centerInfo.pushable ) then
		-- This one is highest priority, so move the center frame back to the left
		MovePanelToLeft();
		SetCenterFrame(frame);
	else
		SetLeftFrame(frame);
	end
end

function HideUIPanel(frame)
	if ( not frame or not frame:IsShown() ) then
		return;
	end

	-- If we're hiding the full-screen frame, just hide it
	if ( frame == GetFullScreenFrame() ) then
		SetFullScreenFrame(nil);
		return;
	end

	-- If we're hiding the center frame, just hide it
	if ( frame == GetCenterFrame() ) then
		SetCenterFrame(nil);
		return;
	end
	
	-- If we're hiding the left frame, move the center frame back left, unless it's a native center frame
	if ( frame == GetLeftFrame() ) then
		local centerFrame = GetCenterFrame();
		if ( centerFrame ) then
			local info = UIPanelWindows[centerFrame:GetName()];
			if ( info and (info.area == "left") ) then
				MovePanelToLeft();
				return;
			end
		end
		SetLeftFrame(nil);
		return;
	end

	frame:Hide();
end

function SetDoublewideFrame(frame)
	local oldFrame1 = UIParent.left;
	local oldFrame2 = UIParent.center;
	UIParent.doublewide = frame;
	UIParent.left = nil;
	UIParent.center = nil;

	if ( oldFrame1 ) then
		oldFrame1:Hide();
	end
	
	if ( oldFrame2 ) then
		oldFrame2:Hide();
	end

	if ( frame ) then
		frame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 0, -104);
		frame:Show();
	end
end

function SetLeftFrame(frame)
	local oldFrame = UIParent.left;
	UIParent.left = frame;

	if ( oldFrame ) then
		oldFrame:Hide();
	end	

	if ( frame ) then
		frame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 0, -104);
		frame:Show();
		--HidePartyFrame();
	else
		--ShowPartyFrame();
	end
end

function SetCenterFrame(frame, skipSetPoint)
	local oldFrame = UIParent.center;
	UIParent.center = frame;

	if ( oldFrame ) then
		oldFrame:Hide();
	end

	if ( frame ) then
		frame:Show();
		if ( not skipSetPoint ) then
			frame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 384, -104);
		end
		-- Hide all child windows
		local childWindow;
		for index, value in UIChildWindows do
			childWindow = getglobal(value);
			if ( childWindow ) then
				childWindow:Hide();
			end
		end
	end

	
end

function SetFullScreenFrame(frame)
	local oldFrame = UIParent.fullscreen;
	UIParent.fullscreen = frame;

	if ( oldFrame ) then
		oldFrame:Hide();
	end

	if ( frame ) then
		UIParent:Hide();
		frame:Show();
	else
		UIParent:Show();
	end
end

function MovePanelToLeft()
	if ( UIParent.center ) then
		SetLeftFrame(nil);
		UIParent.center:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 0, -104);
		UIParent.left = UIParent.center
		UIParent.center = nil;
	end
end

function MovePanelToCenter()
	if ( UIParent.left ) then
		SetCenterFrame(nil);
		UIParent.left:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", 384, -104);
		UIParent.left:Raise();
		UIParent.center = UIParent.left;
		UIParent.left = nil;
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

	local centerFrame = GetCenterFrame();
	if ( not centerFrame ) then
		return 1;
	end

	local info = UIPanelWindows[centerFrame:GetName()];
	if ( info and (info.area == "center") ) then
		return nil;
	end

	return 1;
end

function GetFullScreenFrame()
	return UIParent.fullscreen;
end

function GetCenterFrame()
	return UIParent.center;
end

function GetLeftFrame()
	return UIParent.left;
end

function GetDoublewideFrame()
	return UIParent.doublewide;
end

function CloseWindows(ignoreCenter)
	-- This function will close all frames that are not the current frame
	local leftFrame = GetLeftFrame();
	local centerFrame = GetCenterFrame();
	local doublewideFrame = GetDoublewideFrame();
	local fullScreenFrame = GetFullScreenFrame();
	local found = leftFrame or centerFrame or fullScreenFrame;

	HideUIPanel(leftFrame);
	HideUIPanel(fullScreenFrame);
	HideUIPanel(doublewideFrame);

	if ( centerFrame ) then
		local info = UIPanelWindows[centerFrame:GetName()];
		if ( not info or (info.area ~= "center") or not ignoreCenter ) then
			HideUIPanel(centerFrame);
		end	
	end

	local frame;
	for index, value in UISpecialFrames do
		frame = getglobal(value);
		if ( frame and frame:IsVisible() ) then
			frame:Hide();
			found = 1;
		end
	end

	return found;
end

function CloseAllWindows_WithExceptions()
	-- Insert exceptions here, right now we just don't close the scoreFrame when the player loses control i.e. the game over spell effect
	if ( GetCenterFrame() == WorldStateScoreFrame ) then
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
		local containerFrame = getglobal("ContainerFrame"..i);
		if ( containerFrame:IsShown() ) then
			containerFrame:Hide();
			bagsVisible = 1;
		end
	end
	windowsVisible = CloseWindows(ignoreCenter);
	return (bagsVisible or windowsVisible);
end

function CloseMenus()
	local menusVisible = nil;
	for index, value in UIMenus do
		menu = getglobal(value);
		if ( menu and menu:IsVisible() ) then
			menu:Hide();
			menusVisible = 1;
		end
	end
	return menusVisible;
end

function IsOptionFrameOpen()
	if ( GameMenuFrame:IsVisible() or OptionsFrame:IsVisible() or UIOptionsFrame:IsVisible() or SoundOptionsFrame:IsVisible() or (KeyBindingFrame and KeyBindingFrame:IsVisible()) ) then
		return 1;
	else
		return nil;
	end
end

function SecondsToTime(seconds, noSeconds)
	local time = "";
	local count = 0;
	local tempTime;
	seconds = floor(seconds);
	if ( seconds > 86400  ) then
		tempTime = floor(seconds / 86400);
		time = tempTime.." "..GetText("DAYS_ABBR", nil, tempTime).." ";
		seconds = mod(seconds, 86400);
		count = count + 1;
	end
	if ( seconds > 3600  ) then
		tempTime = floor(seconds / 3600);
		time = time..tempTime.." "..GetText("HOURS_ABBR", nil, tempTime).." ";
		seconds = mod(seconds, 3600);
		count = count + 1;
	end
	if ( count < 2 and seconds >= 60  ) then
		tempTime = floor(seconds / 60);
		time = time..tempTime.." "..GetText("MINUTES_ABBR", nil, tempTime).." ";
		seconds = mod(seconds, 60);
		count = count + 1;
	end
	if ( count < 2 and seconds > 0 and not noSeconds ) then
		seconds = format("%d", seconds);
		time = time..seconds.." "..GetText("SECONDS_ABBR", nil, seconds).." ";
	end
	return time;
end

function SecondsToTimeAbbrev(seconds)
	local tempTime;
	if ( seconds > 86400  ) then
		tempTime = ceil(seconds / 86400);
		return format(DAY_ONELETTER_ABBR, tempTime);
	end
	if ( seconds > 3600  ) then
		tempTime = ceil(seconds / 3600);
		return format(HOUR_ONELETTER_ABBR, tempTime);
	end
	if ( seconds > 60  ) then
		tempTime = ceil(seconds / 60);
		return format(MINUTE_ONELETTER_ABBR, tempTime);
	end
	return format(SECOND_ONELETTER_ABBR, seconds);
end

function BuildListString(...)
	local string = arg[1];
	for i=2, arg.n do
		string = string..", "..arg[i];
	end
	return string;
end

function BuildColoredListString(...)
	if ( arg.n == 0 ) then
		return nil;
	end

	-- Takes input where odd items are the text and even items determine whether the arg should be colored or not
	local string;
	if ( arg[2] ) then
		string = arg[1];
	else
		string = RED_FONT_COLOR_CODE.. arg[1]..FONT_COLOR_CODE_CLOSE;
	end
	for i=3, arg.n, 2 do
		if ( arg[i+1] ) then
			-- If meets the condition
			string = string..", "..arg[i];
		else
			-- If doesn't meet the condition
			string = string..", "..RED_FONT_COLOR_CODE..arg[i]..FONT_COLOR_CODE_CLOSE;
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
	local string = getglobal(globalStringName..i);
	while (string) do
		tooltip:AddLine(string, "", r, g, b);
		i = i + 1;
		string = getglobal(globalStringName..i);
	end
end

-- Generic fade function
function UIFrameFade(frame, fadeInfo)
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
	if ( frame ) then
		-- If frame is already set to fade then return
		local index = 1;
		while FADEFRAMES[index] do
			if ( FADEFRAMES[index] == frame ) then
				return;
			end
			index = index + 1;
		end
		frame:Show();
		tinsert(FADEFRAMES, frame);
	end
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

function UIFrameFlashRemoveFrame(frame)
	tDeleteItem(FLASHFRAMES, frame);
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
function UIFrameFadeUpdate(elapsed)
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
end

function UIFrameIsFading(frame)
	for index, value in FADEFRAMES do
		if ( value == frame ) then
			return 1;
		end
	end
	return nil;
end

-- Function to start a frame flashing
function UIFrameFlash(frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime)
	if ( frame ) then
		local index = 1;
		-- If frame is already set to flash then return
		while FLASHFRAMES[index] do
			if ( FLASHFRAMES[index] == frame ) then
				return;
			end
			index = index + 1;
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
		-- Initial flash mode
		frame.flashMode = "IN";
		-- How long to hold the faded in state
		frame.flashInHoldTime = flashInHoldTime;
		-- How long to hold the faded out state
		frame.flashOutHoldTime = flashOutHoldTime;
		
		tinsert(FLASHFRAMES, frame);
	end
end

-- Called every frame to update flashing frames
function UIFrameFlashUpdate(elapsed)
	local frame;
	local index = 1;
	local fadeInfo;
	while FLASHFRAMES[index] do
		frame = FLASHFRAMES[index];
		frame.flashTimer = frame.flashTimer + elapsed;
		-- If flashDuration is exceeded
		if ( (frame.flashTimer > frame.flashDuration) and frame.flashDuration ~= -1 ) then
			UIFrameFadeRemoveFrame(frame);
			UIFrameFlashRemoveFrame(frame);
			frame:SetAlpha(1.0);
			frame.flashTimer = nil;
			if ( frame.showWhenDone ) then
				frame:Show();
			else
				frame:Hide();
			end
		else
			-- You'll only have a flashMode when the previous flash fade is finished
			if ( frame.flashMode ) then
				fadeInfo = {};
				if ( frame.flashMode == "IN" ) then
					fadeInfo.timeToFade = frame.fadeInTime;
					fadeInfo.mode = "IN";
					fadeInfo.finishedFunc = UIFrameFlashSwitch;
					fadeInfo.finishedArg1 = frame:GetName();
					fadeInfo.finishedArg2 = "OUT";
					fadeInfo.fadeHoldTime = frame.flashOutHoldTime;
					UIFrameFade(frame, fadeInfo);
				elseif ( frame.flashMode == "OUT" ) then
					fadeInfo.timeToFade = frame.fadeOutTime;
					fadeInfo.mode = "OUT";
					fadeInfo.finishedFunc = UIFrameFlashSwitch;
					fadeInfo.finishedArg1 = frame:GetName();
					fadeInfo.finishedArg2 = "IN";
					fadeInfo.fadeHoldTime = frame.flashInHoldTime;
					UIFrameFade(frame, fadeInfo);
				end
				frame.flashMode = nil;
			end
		end
		
		index = index + 1;
	end
end

-- Function to switch the flash mode
function UIFrameFlashSwitch(frameName, mode)
	local frame = getglobal(frameName);
	frame.flashMode = mode;
end

-- Function to see if a frame is already flashing
function UIFrameIsFlashing(frame)
	for index, value in FLASHFRAMES do
		if ( value == frame ) then
			return 1;
		end
	end
	return nil;
end

-- Function to stop flashing
function UIFrameFlashStop(frame)
	frame.flashDuration = 0;
	frame:Hide();
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
	for index, button in PULSEBUTTONS do
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
	for index, pulseButton in PULSEBUTTONS do
		if ( pulseButton == button ) then
			tDeleteItem(PULSEBUTTONS, button);
		end
	end
end

-- Table Utility Functions
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

function MouseIsOver(frame, topOffset, bottomOffset, leftOffset, rightOffset)
	local x, y = GetCursorPosition();
	x = x / frame:GetEffectiveScale();
	y = y / frame:GetEffectiveScale();

	local left = frame:GetLeft();
	local right = frame:GetRight();
	local top = frame:GetTop();
	local bottom = frame:GetBottom();
	if ( not topOffset ) then
		topOffset = 0;
		bottomOffset = 0;
		leftOffset = 0;
		rightOffset = 0;
	end
	
	-- Hack to fix a symptom not the real issue
	if ( not left ) then
		return;
	end

	left = left + leftOffset;
	right = right + rightOffset;
	top = top + topOffset;
	bottom = bottom + bottomOffset;
	if ( (x > left and x < right) and (y > bottom and y < top) ) then
		return 1;
	else
		return nil;
	end
end

-- Generic model rotation functions
function Model_OnLoad()
	this.rotation = 0.61;
	this:SetRotation(this.rotation);
end

function Model_RotateLeft(model, rotationIncrement)
	if ( not rotationIncrement ) then
		rotationIncrement = 0.03;
	end
	model.rotation = model.rotation - rotationIncrement;
	model:SetRotation(model.rotation);
	PlaySound("igInventoryRotateCharacter");
end

function Model_RotateRight(model, rotationIncrement)
	if ( not rotationIncrement ) then
		rotationIncrement = 0.03;
	end
	model.rotation = model.rotation + rotationIncrement;
	model:SetRotation(model.rotation);
	PlaySound("igInventoryRotateCharacter");
end

function Model_OnUpdate(elapsedTime, model, rotationsPerSecond)
	if ( not rotationsPerSecond ) then
		rotationsPerSecond = ROTATIONS_PER_SECOND;
	end
	if ( getglobal(model:GetName().."RotateLeftButton"):GetButtonState() == "PUSHED" ) then
		model.rotation = model.rotation + (elapsedTime * 2 * PI * rotationsPerSecond);
		if ( model.rotation < 0 ) then
			model.rotation = model.rotation + (2 * PI);
		end
		model:SetRotation(model.rotation);
	end
	if ( getglobal(model:GetName().."RotateRightButton"):GetButtonState() == "PUSHED" ) then
		model.rotation = model.rotation - (elapsedTime * 2 * PI * rotationsPerSecond);
		if ( model.rotation > (2 * PI) ) then
			model.rotation = model.rotation - (2 * PI);
		end
		model:SetRotation(model.rotation);
	end
end

-- Function that handles the escape key functions
function ToggleGameMenu(clicked)
	if ( clicked ) then
		if ( OptionsFrame:IsVisible() ) then
			OptionsFrameCancel:Click();
		end
		if ( GameMenuFrame:IsVisible() ) then
			PlaySound("igMainMenuQuit");
			HideUIPanel(GameMenuFrame);
		else
			CloseMenus();
			CloseAllWindows()
			PlaySound("igMainMenuOpen");
			ShowUIPanel(GameMenuFrame);
		end
		return;
	end

	if ( StaticPopup_EscapePressed() ) then
	elseif ( OptionsFrame:IsVisible() ) then
		OptionsFrameCancel:Click();
	elseif ( GameMenuFrame:IsVisible() ) then
		PlaySound("igMainMenuQuit");
		HideUIPanel(GameMenuFrame);
	elseif ( CloseMenus() ) then
	elseif ( SpellStopCasting() ) then
	elseif ( SpellStopTargeting() ) then
	elseif ( CloseAllWindows() ) then
	elseif ( ClearTarget() ) then
	else
		PlaySound("igMainMenuOpen");
		ShowUIPanel(GameMenuFrame);
	end
end

-- Wrapper for the desaturation function
function SetDesaturation(texture, desaturation)
	local shaderSupported = texture:SetDesaturated(desaturation);
	if ( not shaderSupported ) then
		if ( desaturation ) then
			texture:SetVertexColor(0.5, 0.5, 0.5);
		else
			texture:SetVertexColor(1.0, 1.0, 1.0);
		end
		
	end
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
	if ( top < (0 + MainMenuBar:GetHeight() + offscreenPadding)) then
		-- Off the bottom of the screen
		newAnchorY = MainMenuBar:GetHeight() + frame:GetHeight() - GetScreenHeight(); 
	elseif ( bottom > GetScreenHeight() ) then
		-- Off the top of the screen
		newAnchorY =  0;
	end
	if ( right < 0 ) then
		-- Off the left of the screen
		newAnchorX = 0;
	elseif ( left > GetScreenWidth() ) then
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

--[[ 
UIPARENT_MANAGED_FRAME_POSITIONS stores all the frames that have positioning dependencies based on other frames.  

UIPARENT_MANAGED_FRAME_POSITIONS["FRAME"] = {
	none = This value is used if no dependent frames are shown
	reputation = This is the offset used if the reputation watch bar is shown
	anchorTo = This is the object that the stored frame is anchored to
	point = This is the point on the frame used as the anchor
	rpoint = This is the point on the "anchorTo" frame that the stored frame is anchored to
	bottomEither = This offset is used if either bottom multibar is shown
	bottomLeft
	var = If this is set use setglobal(varName, value) instead of setpoint
};
]]
UIPARENT_MANAGED_FRAME_POSITIONS = {};
-- Frames
UIPARENT_MANAGED_FRAME_POSITIONS["MultiBarBottomLeft"] = {baseY = 17, reputation = 9, maxLevel = -5, anchorTo = "ActionButton1", point = "BOTTOMLEFT", rpoint = "TOPLEFT"};
UIPARENT_MANAGED_FRAME_POSITIONS["GroupLootFrame1"] = {baseY = 60, bottomEither = 42, pet = 42, reputation = 9};
UIPARENT_MANAGED_FRAME_POSITIONS["TutorialFrameParent"] = {baseY = 55, bottomEither = 47, pet = 42, reputation = 9};
UIPARENT_MANAGED_FRAME_POSITIONS["FramerateLabel"] = {baseY = 64, bottomEither = 42, pet = 42, reputation = 9};
UIPARENT_MANAGED_FRAME_POSITIONS["CastingBarFrame"] = {baseY = 60, bottomEither = 40, pet = 40, reputation = 9};
UIPARENT_MANAGED_FRAME_POSITIONS["ChatFrame1"] = {baseY = 85, bottomLeft = 17, pet = 17, reputation = 9, maxLevel = -5, anchorTo = "UIParent", point = "BOTTOMLEFT", rpoint = "BOTTOMLEFT", xOffset = 32};
UIPARENT_MANAGED_FRAME_POSITIONS["ChatFrame2"] = {baseY = 85, bottomRight = 17, rightLeft = -88, rightRight = -43, reputation = 9, maxLevel = -5, anchorTo = "UIParent", point = "BOTTOMRIGHT", rpoint = "BOTTOMRIGHT", xOffset = -32};
UIPARENT_MANAGED_FRAME_POSITIONS["ShapeshiftBarFrame"] = {baseY = 0, bottomLeft = 45, reputation = 9, maxLevel = -5, anchorTo = "MainMenuBar", point = "BOTTOMLEFT", rpoint = "TOPLEFT", xOffset = 30};

-- Vars
UIPARENT_MANAGED_FRAME_POSITIONS["CONTAINER_OFFSET_X"] = {baseX = 0, rightLeft = 90, rightRight = 45, isVar = "xAxis"};
UIPARENT_MANAGED_FRAME_POSITIONS["CONTAINER_OFFSET_Y"] = {baseY = 70, bottomEither = 27, bottomRight = 0, reputation = 9, isVar = "yAxis", pet = 23};
UIPARENT_MANAGED_FRAME_POSITIONS["BATTLEFIELD_TAB_OFFSET_Y"] = {baseY = 210, bottomRight = 40, reputation = 9, isVar = "yAxis"};
UIPARENT_MANAGED_FRAME_POSITIONS["PETACTIONBAR_YPOS"] = {baseY = 97, bottomLeft = 43, reputation = 9, maxLevel = -5, isVar = "yAxis"};

-- Call this function to update the positions of all frames that can appear on the right side of the screen
function UIParent_ManageFramePositions()
	-- Frames that affect offsets in y axis
	local yOffsetFrames = {};
	-- Frames that affect offsets in x axis
	local xOffsetFrames = {};
	
	-- Set up flags
	if ( SHOW_MULTI_ACTIONBAR_1 or SHOW_MULTI_ACTIONBAR_2 ) then
		tinsert(yOffsetFrames, "bottomEither");
	end
	if ( SHOW_MULTI_ACTIONBAR_2) then
		tinsert(yOffsetFrames, "bottomRight");
	end
	if ( SHOW_MULTI_ACTIONBAR_1 ) then
		tinsert(yOffsetFrames, "bottomLeft");
	end
		
	if ( MultiBarLeft:IsShown() ) then
		tinsert(xOffsetFrames, "rightLeft");
	elseif ( MultiBarRight:IsShown() ) then
		tinsert(xOffsetFrames, "rightRight");
	end

	if ( ( PetActionBarFrame and PetActionBarFrame:IsShown() ) or ( ShapeshiftBarFrame and ShapeshiftBarFrame:IsShown() ) ) then
		tinsert(yOffsetFrames, "pet");
	end
	if ( ReputationWatchBar:IsShown() and MainMenuExpBar:IsShown() ) then
		tinsert(yOffsetFrames, "reputation");
	end
	if ( MainMenuBarMaxLevelBar:IsShown() ) then
		tinsert(yOffsetFrames, "maxLevel");
	end
	
	-- Iterate through frames and set anchors according to the flags set
	local frame, xOffset, yOffset, anchorTo, point, rpoint;
	for index, value in UIPARENT_MANAGED_FRAME_POSITIONS do
		frame = getglobal(index);
		if ( frame ) then
			-- Always start with base as the base offset or default to zero if no "none" specified
			xOffset = 0;
			if ( value["baseX"] ) then
				xOffset = value["baseX"];
			elseif ( value["xOffset"] ) then
				xOffset = value["xOffset"];
			end
			yOffset = 0;
			if ( value["baseY"] ) then
				yOffset = value["baseY"];
			end
			
			-- Iterate through frames that affect y offsets
			local hasBottomLeft, hasPetBar;
			for flag, flagValue in yOffsetFrames do
				if ( value[flagValue] ) then
					if ( flagValue == "bottomLeft" ) then
						hasBottomLeft = 1;
					elseif ( flagValue == "pet" ) then
						hasPetBar = 1;
					elseif ( flagValue == "bottomRight" ) then
						hasBottomRight = 1;
					end
					yOffset = yOffset + value[flagValue];
				end
			end

			if ( hasBottomLeft and hasPetBar ) then
				yOffset = yOffset + 23;
			end

			-- Iterate through frames that affect x offsets
			for flag, flagValue in xOffsetFrames do
				if ( value[flagValue] ) then
					xOffset = xOffset + value[flagValue];
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
					setglobal(index, xOffset);
				else
					setglobal(index, yOffset);
				end
			else
				if ((frame == ChatFrame1 or frame == ChatFrame2) and SIMPLE_CHAT == "1") then
					frame:SetPoint(point, anchorTo, rpoint, xOffset, yOffset);
				elseif ( not(frame:IsObjectType("frame") and frame:IsUserPlaced()) ) then
					frame:SetPoint(point, anchorTo, rpoint, xOffset, yOffset);
				end
			end
		end
	end
	
	-- Custom positioning not handled by the loop
	-- Set battlefield minimap position
	if ( BattlefieldMinimapTab and not BattlefieldMinimapTab:IsUserPlaced() ) then
		BattlefieldMinimapTab:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMRIGHT", -225-CONTAINER_OFFSET_X, BATTLEFIELD_TAB_OFFSET_Y);
	end

	-- Update shapeshift bar appearance
	if ( MultiBarBottomLeft:IsShown() ) then
		SlidingActionBarTexture0:Hide();
		SlidingActionBarTexture1:Hide();
		if ( ShapeshiftBarFrame ) then
			ShapeshiftBarLeft:Hide();
			ShapeshiftBarRight:Hide();
			ShapeshiftBarMiddle:Hide();
			for i=1, GetNumShapeshiftForms() do
				getglobal("ShapeshiftButton"..i.."NormalTexture"):SetWidth(50);
				getglobal("ShapeshiftButton"..i.."NormalTexture"):SetHeight(50);
			end
		end
	else
		if ( GetNumShapeshiftForms() > 2 ) then
			ShapeshiftBarMiddle:Show();
		end
		SlidingActionBarTexture0:Show();
		SlidingActionBarTexture1:Show();
		if ( ShapeshiftBarFrame ) then
			ShapeshiftBarLeft:Show();
			ShapeshiftBarRight:Show();
			for i=1, GetNumShapeshiftForms() do
				getglobal("ShapeshiftButton"..i.."NormalTexture"):SetWidth(64);
				getglobal("ShapeshiftButton"..i.."NormalTexture"):SetHeight(64);
			end
		end
	end

	-- If petactionbar is already shown have to set its point is addition to changing its y target
	if ( PetActionBarFrame:IsShown() ) then
		PetActionBarFrame:SetPoint("TOPLEFT", MainMenuBar, "BOTTOMLEFT", PETACTIONBAR_XPOS, PETACTIONBAR_YPOS);
	end

	-- Setup y anchors
	local anchorY = 0;
	-- Capture bars
	if ( NUM_EXTENDED_UI_FRAMES ) then
		local captureBar;
		local numCaptureBars = 0;
		for i=1, NUM_EXTENDED_UI_FRAMES do
			captureBar = getglobal("WorldStateCaptureBar"..i);
			if ( captureBar and captureBar:IsShown() ) then
				captureBar:SetPoint("TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -CONTAINER_OFFSET_X, anchorY);
				anchorY = anchorY - captureBar:GetHeight();
			end
		end	
	end
	-- Quest timers
	QuestTimerFrame:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -CONTAINER_OFFSET_X, anchorY);
	if ( QuestTimerFrame:IsShown() ) then
		anchorY = anchorY - QuestTimerFrame:GetHeight();
	end
	-- Setup durability offset
	if ( DurabilityFrame ) then
		local durabilityOffset = 0;
		if ( DurabilityShield:IsShown() or DurabilityOffWeapon:IsShown() or DurabilityRanged:IsShown() ) then
			durabilityOffset = 20;
		end
		DurabilityFrame:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -CONTAINER_OFFSET_X-durabilityOffset, anchorY);
		if ( DurabilityFrame:IsShown() ) then
			anchorY = anchorY - DurabilityFrame:GetHeight();
		end
	end
	
	QuestWatchFrame:SetPoint("TOPRIGHT", "MinimapCluster", "BOTTOMRIGHT", -CONTAINER_OFFSET_X, anchorY);

	-- Update chat dock since the dock could have moved
	FCF_DockUpdate();
	updateContainerFrameAnchors();
end

function PlayerStatus_OnUpdate(elapsed)
	local min, max = PlayerFrameHealthBar:GetMinMaxValues();
	if ( (PlayerFrameHealthBar:GetValue()/(max - min) <= 0.2) and not LowHealthFrame.flashing and tonumber(SHOW_FULLSCREEN_STATUS) ~= 0 ) then
		UIFrameFlash(LowHealthFrame, 0.5, 0.5, 100);
		LowHealthFrame.flashing = 1;
	elseif ( ((PlayerFrameHealthBar:GetValue()/(max - min) > 0.1) and LowHealthFrame.flashing) or UnitIsDead("player") ) then
		UIFrameFlash(LowHealthFrame, 1, 1, 0);
		LowHealthFrame.flashing = nil;
	elseif ( UIParent.isOutOfControl and not OutOfControlFrame.flashing and tonumber(SHOW_FULLSCREEN_STATUS) ~= 0 ) then
		UIFrameFlash(OutOfControlFrame, 0.5, 0.5, 100);
		OutOfControlFrame.flashing = 1;
	elseif ( not UIParent.isOutOfControl and OutOfControlFrame.flashing ) then
		UIFrameFlash(OutOfControlFrame, 0.5, 0.5, 0);
		OutOfControlFrame.flashing = nil;
	end
end

function GetScreenHeightScale()
	local screenHeight = 768;
	return GetScreenHeight()/screenHeight;
end

function GetScreenWidthScale()
	local screenWidth = 1024;
	return GetScreenWidth()/screenWidth;
end

-- Helper function to show the inspect cursor if the ctrl key is down
function CursorUpdate()
	if ( IsControlKeyDown() and this.hasItem ) then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

function CursorOnUpdate()
	if ( GameTooltip:IsOwned(this) ) then
		CursorUpdate();
	end
end

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
		if ( GetLocale() == "deDE") then
			modKeys = gsub(modKeys, "CTRL", "STRG");
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
	local localizedName = nil;
	if ( IsMacClient() ) then
		-- see if there is a mac specific name for the key
		localizedName = getglobal(prefix..tempName.."_MAC");
	end
	if ( not localizedName ) then
		localizedName = getglobal(prefix..tempName);
	end
	if ( not localizedName ) then
		localizedName = tempName;
	end
	return modKeys..localizedName;
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

function LowerFrameLevel(frame)
	frame:SetFrameLevel(frame:GetFrameLevel()-1);
end

function RaiseFrameLevel(frame)
	frame:SetFrameLevel(frame:GetFrameLevel()+1);
end
