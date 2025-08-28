function UIParent_Shared_OnLoad(self)
	self:RegisterEvent("REPORT_PLAYER_RESULT");
end

local sendReportResultToErrorString = {
	[Enum.SendReportResult.Success] = ERR_REPORT_SUBMITTED_SUCCESSFULLY,
	[Enum.SendReportResult.GeneralError] = ERR_REPORT_SUBMISSION_FAILED,
	[Enum.SendReportResult.TooManyReports] = REPORT_RESULT_TOO_MANY_REPORTS,
	[Enum.SendReportResult.RequiresChatLine] = REPORT_RESULT_REQUIRES_CHAT,
	[Enum.SendReportResult.RequiresChatLineOrVoice] = REPORT_RESULT_REQUIRES_CHAT_OR_VOICE,
};

local function GetErrorMessageFromSendReportResult(result)
	return sendReportResultToErrorString[result] or ERR_REPORT_SUBMISSION_FAILED;
end

local sendReportResultToChatString = {
	[Enum.SendReportResult.Success] = COMPLAINT_ADDED,
	[Enum.SendReportResult.GeneralError] = ERR_REPORT_SUBMISSION_FAILED,
	[Enum.SendReportResult.TooManyReports] = REPORT_RESULT_TOO_MANY_REPORTS,
	[Enum.SendReportResult.RequiresChatLine] = REPORT_RESULT_REQUIRES_CHAT,
	[Enum.SendReportResult.RequiresChatLineOrVoice] = REPORT_RESULT_REQUIRES_CHAT_OR_VOICE,
};

local function GetChatMessageFromSendReportResult(result)
	return sendReportResultToChatString[result] or ERR_REPORT_SUBMISSION_FAILED;
end

function UIParent_Shared_OnEvent(self, event, ...)
	if event == "REPORT_PLAYER_RESULT" then
		local result = ...;
		UIErrorsFrame:AddExternalErrorMessage(GetErrorMessageFromSendReportResult(result));
		DEFAULT_CHAT_FRAME:AddMessage(GetChatMessageFromSendReportResult(result));
	end
end

function OpenAchievementFrameToAchievement(achievementID)
	if ( not AchievementFrame ) then
		AchievementFrame_LoadUI();
	end
	if ( not AchievementFrame:IsShown() ) then
		AchievementFrame_ToggleAchievementFrame(false, C_AchievementInfo.IsGuildAchievement(achievementID));
	end

	AchievementFrame_SelectAchievement(achievementID);
end

function ToggleLFGFrame()
	if (C_LFGList.GetPremadeGroupFinderStyle() == Enum.PremadeGroupFinderStyle.Vanilla) then
		if (not C_AddOns.IsAddOnLoaded("Blizzard_GroupFinder_VanillaStyle")) then
			return;
		end

		ToggleLFGParentFrame();
	else
		PVEFrame_ToggleFrame();
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

-- Note: Numeric abbreviation data is presently defined in game-specific files.
NUMBER_ABBREVIATION_DATA = {};

function GetLocalizedNumberAbbreviationData()
	return NUMBER_ABBREVIATION_DATA;
end

function AbbreviateNumbers(value)
	for i, data in ipairs(GetLocalizedNumberAbbreviationData()) do
		if value >= data.breakpoint then
			local finalValue = math.floor(value / data.significandDivisor) / data.fractionDivisor;
			return finalValue .. data.abbreviation;
		end
	end
	return tostring(value);
end

UIParentManagedFrameMixin = { };
function UIParentManagedFrameMixin:OnShow()
	self.layoutParent:AddManagedFrame(self);
end

function UIParentManagedFrameMixin:OnHide()
	self.layoutParent:RemoveManagedFrame(self);
end

local function IsActionBarOverriden()
	return OverrideActionBar and OverrideActionBar:IsShown() or false;
end

local function UpdateFrameAlphaState(frame, isActionBarOverriden)
	if frame.hideWhenActionBarIsOverriden then
		local setToAlpha = isActionBarOverriden and 0 or 1;
		frame:SetAlpha(setToAlpha);

		-- Since the frame isn't actually hidden, give it a way to remove itself from layout
		-- if that's the desired behavior.
		if frame.ignoreInLayoutWhenActionBarIsOverriden then
			frame.ignoreInLayout = isActionBarOverriden;
		end
	end
end

UIParentManagedFrameContainerMixin = {};

function UIParentManagedFrameContainerMixin:OnLoad()
	self.showingFrames = {};
end

function UIParentManagedFrameContainerMixin:UpdateFrame(frame)
	frame:ClearAllPoints();
	frame:SetParent(frame.layoutOnBottom and self.BottomManagedLayoutContainer or self);
	self:Layout();
	self.BottomManagedLayoutContainer:Layout();

	if frame.isRightManagedFrame and ObjectiveTrackerFrame then
		ObjectiveTrackerFrame:UpdateHeight();
	end
end

function UIParentManagedFrameContainerMixin:AddManagedFrame(frame)
	if frame.ignoreFramePositionManager then
		return;
	end

	if frame.IsInDefaultPosition and not frame:IsInDefaultPosition() then
		return;
	end

	if not frame:IsShown() then
		return;
	end

	-- If the frame is being added to the list while the override action bar is shown it needs to
	-- have its alpha value updated.
	local isActionBarOverriden = IsActionBarOverriden();
	if isActionBarOverriden and not self.showingFrames[frame] then
		UpdateFrameAlphaState(frame, isActionBarOverriden);
	end

	self.showingFrames[frame] = frame;
	self:UpdateFrame(frame);
end

function UIParentManagedFrameContainerMixin:UpdateManagedFrames()
	for _, frame in pairs(self.showingFrames) do
		if frame then
			self:UpdateFrame(frame);
		end
	end

	self:AnimInManagedFrames();
end

function UIParentManagedFrameContainerMixin:ClearManagedFrames()
	self:AnimOutManagedFrames();
end

function UIParentManagedFrameContainerMixin:RemoveManagedFrame(frame)
	if not self.showingFrames[frame] then
		return;
	end
	self.showingFrames[frame] = nil;

	if not frame.IsInDefaultPosition then
		frame:ClearAllPoints();
	end

	if ObjectiveTrackerFrame then
		ObjectiveTrackerFrame:UpdateHeight();
	end

	local isActionBarOverriden = IsActionBarOverriden();
	if isActionBarOverriden then
		-- A managed frame flagged to be hidden when the action bar is overridden should no longer be
		-- hidden if it's no longer managed. Otherwise it can be stuck in a hidden state.
		local isActionBarOverridenForFrame = false;
		UpdateFrameAlphaState(frame, isActionBarOverridenForFrame);
	end

	self:Layout();
	self.BottomManagedLayoutContainer:Layout();
end

function UIParentManagedFrameContainerMixin:UpdateManagedFramesAlphaState()
	local isActionBarOverriden = IsActionBarOverriden();
	for frame in pairs(self.showingFrames) do
		UpdateFrameAlphaState(frame, isActionBarOverriden);
	end
end

--Aubrie TODO determine if we want to actually apply a fade out for pet battles?
function UIParentManagedFrameContainerMixin:AnimOutManagedFrames()
	for frame in pairs(self.showingFrames) do
		frame:SetAlpha(0);
	end
end

function UIParentManagedFrameContainerMixin:AnimInManagedFrames()
	for frame in pairs(self.showingFrames) do
		frame:SetAlpha(1);
	end
end

-- Addons --

local FailedAddOnLoad = {};

function UIParentLoadAddOn(name)
	local loaded, reason = C_AddOns.LoadAddOn(name);
	if ( not loaded ) then
		if ( not FailedAddOnLoad[name] ) then
			SetBasicMessageDialogText(format(ADDON_LOAD_FAILED, name, _G["ADDON_"..reason]));
			FailedAddOnLoad[name] = true;
		end
	end
	return loaded;
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

function BarberShopFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_BarberShopUI");
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

function TimeManager_LoadUI()
	UIParentLoadAddOn("Blizzard_TimeManager");
end

function TokenFrame_LoadUI()
	UIParentLoadAddOn("Blizzard_TokenUI");
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

function APIDocumentation_LoadUI()
	UIParentLoadAddOn("Blizzard_APIDocumentationGenerated");
end

function DeathRecap_LoadUI()
	UIParentLoadAddOn("Blizzard_DeathRecap");
end

function InClickBindingMode()
	return ClickBindingFrame and ClickBindingFrame:IsShown();
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

function CommunitiesFrame_IsEnabled()
	return C_Club.IsEnabled();
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

function OrderHallMissionFrame_EscapePressed()
	return OrderHallMissionFrame and OrderHallMissionFrame.EscapePressed and OrderHallMissionFrame:EscapePressed();
end

function OrderHallTalentFrame_EscapePressed()
	return OrderHallTalentFrame and OrderHallTalentFrame.EscapePressed and OrderHallTalentFrame:EscapePressed();
end

function BFAMissionFrame_EscapePressed()
	return BFAMissionFrame and BFAMissionFrame.EscapePressed and BFAMissionFrame:EscapePressed();
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

function GetSocialColoredName(displayName, guid)
	local _, color, relationship = SocialQueueUtil_GetRelationshipInfo(guid);
	if ( relationship ) then
		return color..displayName..FONT_COLOR_CODE_CLOSE;
	end
	return displayName;
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
	if (C_GameRules.IsHardcoreActive and C_GameRules.IsHardcoreActive()) then
		return;
	end
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

function IsPlayerAtEffectiveMaxLevel()
	return IsLevelAtEffectiveMaxLevel(UnitLevel("player"));
end

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

function nop()
end
