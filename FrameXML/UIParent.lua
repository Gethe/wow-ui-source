TOOLTIP_UPDATE_TIME = 0.2;
ROTATIONS_PER_SECOND = .5;

-- Alpha animation stuff
FADEFRAMES = {};
FLASHFRAMES = {};

-- Pulsing stuff
PULSEBUTTONS = {};

UIPanelWindows = {};
UIPanelWindows["GameMenuFrame"] =		{ area = "center",	pushable = 0 };
UIPanelWindows["OptionsFrame"] =		{ area = "center",	pushable = 0 };
UIPanelWindows["SoundOptionsFrame"] =		{ area = "center",	pushable = 0 };
UIPanelWindows["UIOptionsFrame"] =		{ area = "center",	pushable = 0 };
UIPanelWindows["CharacterFrame"] =		{ area = "left",	pushable = 2 };
UIPanelWindows["InspectFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["ItemTextFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["SpellBookFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["LootFrame"] =			{ area = "left",	pushable = 7 };
UIPanelWindows["TaxiFrame"] =			{ area = "left",	pushable = 0 };
UIPanelWindows["QuestFrame"] =			{ area = "left",	pushable = 0 };
UIPanelWindows["QuestLogFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["ClassTrainerFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["TradeSkillFrame"] =		{ area = "left",	pushable = 3 };
UIPanelWindows["MerchantFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["TradeFrame"] =			{ area = "left",	pushable = 1 };
UIPanelWindows["BankFrame"] =			{ area = "left",	pushable = 6 };
UIPanelWindows["FriendsFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["SuggestFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["CraftFrame"] =			{ area = "left",	pushable = 4 };
UIPanelWindows["WorldMapFrame"] =		{ area = "full",	pushable = 0 };
UIPanelWindows["KeyBindingFrame"] =		{ area = "center",	pushable = 0 };
UIPanelWindows["CinematicFrame"] =		{ area = "full",	pushable = 0 };
UIPanelWindows["TabardFrame"] =			{ area = "left",	pushable = 0 };
UIPanelWindows["GuildRegistrarFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["PetitionFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["HelpFrame"] =			{ area = "center",	pushable = 0 };
UIPanelWindows["MacroFrame"] =			{ area = "left",	pushable = 5 };
UIPanelWindows["GossipFrame"] =			{ area = "left",	pushable = 0 };
UIPanelWindows["MailFrame"] =			{ area = "left",	pushable = 0 };
UIPanelWindows["BattlefieldFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["TalentFrame"] =			{ area = "left",	pushable = 6 };
UIPanelWindows["PetStableFrame"] =		{ area = "left",	pushable = 0 };
UIPanelWindows["AuctionFrame"] =		{ area = "doublewide",	pushable = 0 };

-- These are windows that rely on a parent frame to be open.  If the parent closes or a pushable frame overlaps them they must be hidden.
UIChildWindows = {
	"OpenMailFrame",
	"GuildControlPopupFrame",

};

UISpecialFrames = {
	"ItemRefTooltip",
	"TutorialFrame",
	"ColorPickerFrame"
};

UIMenus = {
	"ChatMenu",
	"EmoteMenu",
	"LanguageMenu",
	"UnitPopup",
	"DropDownList1",
	"DropDownList2"
};

function UIParent_OnLoad()
	this:RegisterEvent("PLAYER_DEAD");
	this:RegisterEvent("PLAYER_ALIVE");
	this:RegisterEvent("PLAYER_UNGHOST");
	this:RegisterEvent("RESURRECT_REQUEST");
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
	this:RegisterEvent("REPLACE_ENCHANT");
	this:RegisterEvent("TRADE_REPLACE_ENCHANT");
	this:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
	this:RegisterEvent("MEMORY_EXHAUSTED");
	this:RegisterEvent("PLAYER_CONTROL_LOST");
	this:RegisterEvent("PLAYER_CONTROL_GAINED");
	this:RegisterEvent("START_LOOT_ROLL");
	this:RegisterEvent("INSTANCE_BOOT_START");
	this:RegisterEvent("INSTANCE_BOOT_STOP");
	this:RegisterEvent("CONFIRM_TALENT_WIPE");
	this:RegisterEvent("CONFIRM_SUMMON");
	this:RegisterEvent("BILLING_NAG_DIALOG");
end

function UIParent_OnEvent(event)
	if ( event == "PLAYER_DEAD" ) then
		if ( not StaticPopup_Visible("DEATH") ) then
			CloseAllWindows(1);
			StaticPopup_Show("DEATH");
		end
		return;
	end
	if ( event == "PLAYER_ALIVE" ) then
		StaticPopup_Hide("DEATH");
		return;
	end
	if ( event == "PLAYER_UNGHOST" ) then
		StaticPopup_Hide("RESURRECT");
		return;
	end
	if ( event == "RESURRECT_REQUEST" ) then
		if ( ResurrectHasSickness() ) then
			StaticPopup_Show("RESURRECT", arg1);
		else
			StaticPopup_Show("RESURRECT_NO_SICKNESS", arg1);
		end
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
		StaticPopup_Show("DELETE_ITEM", arg1);
		return;
	end
	if ( event == "QUEST_ACCEPT_CONFIRM" ) then
		StaticPopup_Show("QUEST_ACCEPT", arg1, arg2);
		return;
	end
	if ( event == "CURSOR_UPDATE" ) then
		StaticPopup_Hide("AUTOEQUIP_BIND");
		StaticPopup_Hide("DELETE_ITEM");
		return;
	end
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		CloseAllWindows();
		return;
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
	if ( event == "REPLACE_ENCHANT" ) then
		StaticPopup_Show("REPLACE_ENCHANT", arg1, arg2);
		return;
	end
	if ( event == "TRADE_REPLACE_ENCHANT" ) then
		StaticPopup_Show("TRADE_REPLACE_ENCHANT", arg1, arg2);
		return;
	end
	if ( event == "CURRENT_SPELL_CAST_CHANGED" ) then
		StaticPopup_Hide("REPLACE_ENCHANT");
		StaticPopup_Hide("TRADE_REPLACE_ENCHANT");
		return;
	end
	if ( event == "MEMORY_EXHAUSTED" ) then
		StaticPopup_Show("MEMORY_EXHAUSTED");
		return;
	end
	if ( event == "PLAYER_CONTROL_LOST" ) then
		if ( UnitOnTaxi("player") ) then
			return;
		end
		CloseAllWindows();
		-- Disable all microbuttons except the main menu
		SetDesaturation(MicroButtonPortrait, 1);
		
		CharacterMicroButton:Disable();
		SpellbookMicroButton:Disable();
		TalentMicroButton:Disable();
		QuestLogMicroButton:Disable();
		SocialsMicroButton:Disable();
		WorldMapMicroButton:Disable();
		
		UIParent.isOutOfControl = 1;
		return;
	end
	if ( event == "PLAYER_CONTROL_GAINED" ) then
		-- Enable all microbuttons
		SetDesaturation(MicroButtonPortrait, nil);
		CharacterMicroButton:Enable();
		SpellbookMicroButton:Enable();
		TalentMicroButton:Enable();
		QuestLogMicroButton:Enable();
		SocialsMicroButton:Enable();
		WorldMapMicroButton:Enable();
		
		UIParent.isOutOfControl = nil;
		return;
	end
	if ( event == "START_LOOT_ROLL" ) then
		GroupLootFrame_OpenNewFrame(arg1);
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
	if ( event == "CONFIRM_SUMMON" ) then
		StaticPopup_Show("CONFIRM_SUMMON");
		return;
	end
	if ( event == "BILLING_NAG_DIALOG" ) then
		StaticPopup_Show("BILLING_NAG", arg1);
		return;
	end
end

function ShowUIPanel(frame, force)	
	if ( not frame or frame:IsVisible() ) then
		return;
	end
	if ( not CanOpenPanels() and (frame ~= GameMenuFrame and frame ~= UIOptionsFrame and frame ~= SoundOptionsFrame and frame ~= OptionsFrame and frame ~= KeyBindingFrame and frame ~= HelpFrame and frame ~= SuggestFrame) ) then
		return;
	end

	local info = UIPanelWindows[frame:GetName()];
	if ( not info ) then
		frame:Show();
		return;
	end

	if ( UnitIsDead("player") and (info.area ~= "center") and (info.area ~= "full") and (frame ~= SuggestFrame) ) then
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
		UIParent.center = UIParent.left
		UIParent.left = nil;
	end
end

function CanOpenPanels()
	if ( UnitIsDead("player") or UIParent.isOutOfControl ) then
		return nil;
	end

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

function SecondsToTime(seconds)
	local time = "";
	local count = 0;
	local tempTime;
	if ( seconds > 86400  ) then
		tempTime = floor(seconds / 86400);
		timeTag = GetPluralTag(tempTime);
		time = tempTime.." "..GetText("DAYS_ABBR", nil, tempTime).." ";
		seconds = mod(seconds, 86400);
		count = count + 1;
	end
	if ( seconds > 3600  ) then
		tempTime = floor(seconds / 3600);
		timeTag = GetPluralTag(tempTime);
		time = time..tempTime.." "..GetText("HOURS_ABBR", nil, tempTime).." ";
		seconds = mod(seconds, 3600);
		count = count + 1;
	end
	if ( count < 2 and seconds > 60  ) then
		tempTime = floor(seconds / 60);
		timeTag = GetPluralTag(tempTime);
		time = time..tempTime.." "..GetText("MINUTES_ABBR", nil, tempTime).." ";
		seconds = mod(seconds, 60);
		count = count + 1;
	end
	if ( count < 2 ) then
		timeTag = GetPluralTag(seconds);
		time = time..seconds.." "..GetText("SECONDS_ABBR", nil, seconds).." ";
	end
	return time;
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
		local index = 1;
		-- If frame is already set to flash then return
		while FLASHFRAMES[index] do
			if ( FLASHFRAMES[index] == frame ) then
				return;
			end
			index = index + 1;
		end
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
		end
		index = index + 1;
	end
end

function MouseIsOver(frame, topOffset, bottomOffset, leftOffset, rightOffset)
	local x, y = GetCursorPosition();
	x = x / frame:GetScale();
	y = y / frame:GetScale();

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