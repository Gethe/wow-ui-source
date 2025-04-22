-- UIPanel Management constants
UIPANEL_SKIP_SET_POINT = true;
UIPANEL_DO_SET_POINT = nil;
UIPANEL_VALIDATE_CURRENT_FRAME = true;

-- Per panel settings
UIPanelWindows = {};

local function SetFrameAttributes(frame, attributes)
		frame:SetAttribute("UIPanelLayout-defined", true);
	for name, value in pairs(attributes) do
			frame:SetAttribute("UIPanelLayout-"..name, value);
		end
end

function RegisterUIPanel(frame, attributes)
	local name = frame:GetName();
	if not UIPanelWindows[name] then
		UIPanelWindows[name] = attributes;
		--SetFrameAttributes(frame, attributes);
	end
end

local function GetUIPanelAttribute(frame, name)
	if not frame:GetAttribute("UIPanelLayout-defined") then
	    local attributes = UIPanelWindows[frame:GetName()];
	    if not attributes then
			return;
	    end
		SetFrameAttributes(frame, attributes);
	end
	return frame:GetAttribute("UIPanelLayout-"..name);
end

function SetUIPanelAttribute(frame, name, value)
	local attributes = UIPanelWindows[frame:GetName()];
	if not attributes then
		return;
	end

	if not frame:GetAttribute("UIPanelLayout-defined") then
		SetFrameAttributes(frame, attributes);
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
};

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
	local yOffset = 0;
	local xOffset = -180;

	if OrderHallCommandBar and OrderHallCommandBar:IsShown() then
		topOffset = 12;
		yOffset = OrderHallCommandBar:GetHeight();
	end

	if PlayerFrame and not PlayerFrame:IsUserPlaced() and not PlayerFrame_IsAnimatedOut(PlayerFrame) then
		PlayerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -19, -4 - topOffset)
	end

	if TargetFrame and not TargetFrame:IsUserPlaced() then
		TargetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 250, -4 - topOffset);
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

	local y = -(buffOffset + 13)
	BuffFrame:SetPoint("TOPRIGHT", MinimapCluster, "TOPLEFT", -10, y);
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
	["PETACTIONBAR_YOFFSET"] = {baseY = 0, bottomEither = actionBarOffset, watchBar = 1, maxLevel = 1, isVar = "yAxis"};
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
		self:MoveUIPanel(GetUIPanelAttribute(frame, "area"), "fullscreen", UIPANEL_DO_SET_POINT, UIPANEL_VALIDATE_CURRENT_FRAME);
		frame:ClearAllPoints();
		frame:SetPoint(GetUIPanelAttribute(frame, "maximizePoint"));
	elseif ( attribute == "panel-restore" ) then
		local frame = self:GetAttribute("panel-frame");
		self:MoveUIPanel("fullscreen", GetUIPanelAttribute(frame, "area"), UIPANEL_DO_SET_POINT, UIPANEL_VALIDATE_CURRENT_FRAME);
	end
end

local FramePositionDelegate = CreateFrame("FRAME");
FramePositionDelegate:SetForbidden();
FramePositionDelegate:SetScript("OnAttributeChanged", FramePositionDelegate_OnAttributeChanged);

function FramePositionDelegate:ShowUIPanel(frame, force)
	local frameArea, framePushable;
	frameArea = GetUIPanelAttribute(frame, "area");
	if ( not CanOpenPanels() and frameArea ~= "center" and frameArea ~= "full" ) then
		self:ShowUIPanelFailed(frame);
		return;
	end
	framePushable = GetUIPanelAttribute(frame, "pushable") or 0;

	if ( UnitIsDead("player") and not GetUIPanelAttribute(frame, "whileDead") ) then
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

	if ( GetUIPanelAttribute(frame, "checkFit") == 1 ) then
		self:UpdateScaleForFit(frame);
	end

	-- If we have a "center" frame open, only listen to other "center" open requests
	local centerFrame = self:GetUIPanel("center");
	local centerArea, centerPushable;
	if ( centerFrame ) then
		if ( GetUIPanelAttribute(centerFrame, "allowOtherPanels") ) then
			HideUIPanel(centerFrame);
			centerFrame = nil;
		else
			centerArea = GetUIPanelAttribute(centerFrame, "area");
			if ( centerArea and (centerArea == "center") and (frameArea ~= "center") and (frameArea ~= "full") ) then
				if ( force ) then
					self:SetUIPanel("center", nil, 1);
				else
					self:ShowUIPanelFailed(frame);
					return;
				end
			end
			centerPushable = GetUIPanelAttribute(centerFrame, "pushable") or 0;
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
		if ( not GetUIPanelAttribute(frame, "allowOtherPanels") ) then
			securecall("CloseAllBags");
		end
		self:SetUIPanel("center", frame, 1);
		return;
	end

	-- Doublewide frames take up the left and center spots
	if ( frameArea == "doublewide" ) then
		local leftFrame = self:GetUIPanel("left");
		if ( leftFrame ) then
			local leftPushable = GetUIPanelAttribute(leftFrame, "pushable") or 0;
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
	local leftPushable = GetUIPanelAttribute(leftFrame, "pushable") or 0;

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
	local rightPushable = GetUIPanelAttribute(rightFrame, "pushable") or 0;
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
	if GetUIPanelAttribute(frame, "showFailedFunc") then
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
			local area = GetUIPanelAttribute(centerFrame, "area");
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
		local xOff = GetUIPanelAttribute(frame,"xoffset") or 0;
		local yOff = GetUIPanelAttribute(frame,"yoffset") or 0;
		local bottomClampOverride = GetUIPanelAttribute(frame,"bottomClampOverride");
		local minYOffset = GetUIPanelAttribute(frame,"minYOffset");
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
			local xOff = GetUIPanelAttribute(frame,"xoffset") or 0;
			local yOff = GetUIPanelAttribute(frame,"yoffset") or 0;
			local bottomClampOverride = GetUIPanelAttribute(frame,"bottomClampOverride");
			local minYOffset = GetUIPanelAttribute(frame,"minYOffset");
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
			local area = GetUIPanelAttribute(frame, "area");
			local xOff = GetUIPanelAttribute(frame,"xoffset") or 0;
			local yOff = GetUIPanelAttribute(frame,"yoffset") or 0;
			local bottomClampOverride = GetUIPanelAttribute(frame,"bottomClampOverride");
			local minYOffset = GetUIPanelAttribute(frame,"minYOffset");
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
			local xOff = GetUIPanelAttribute(frame,"xoffset") or 0;
			local yOff = GetUIPanelAttribute(frame,"yoffset") or 0;
			local bottomClampOverride = GetUIPanelAttribute(frame,"bottomClampOverride");
			local minYOffset = GetUIPanelAttribute(frame,"minYOffset");
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

	if ( currentFrame and GetUIPanelAttribute(currentFrame, "checkFit") == 1 ) then
		self:UpdateScaleForFit(currentFrame);
	end

	self.updatingPanels = nil;
end

function FramePositionDelegate:UpdateScaleForFit(frame)
	local horizRatio = UIParent:GetWidth() / GetUIPanelWidth(frame);
	local vertRatio = UIParent:GetHeight() / GetUIPanelHeight(frame);
	if ( horizRatio < 1 or vertRatio < 1 ) then
		frame:SetScale(min(horizRatio, vertRatio));
	else
		frame:SetScale(1);
	end
end

function FramePositionDelegate:UIParentManageFramePositions()
	UIPARENT_VARIABLE_OFFSETS["rightActionBarsX"] = VerticalMultiBarsContainer and VerticalMultiBarsContainer:GetWidth() or 0;

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
		if (MultiBarBottomLeft and MultiBarBottomLeft:IsShown()) or (MultiBarBottomRight and MultiBarBottomRight:IsShown()) then
			tinsert(yOffsetFrames, "bottomEither");
		end
		if ( MultiBarBottomRight and MultiBarBottomRight:IsShown() ) then
			tinsert(yOffsetFrames, "bottomRight");
			hasBottomRight = 1;
		end
		if ( MultiBarBottomLeft and MultiBarBottomLeft:IsShown() ) then
			tinsert(yOffsetFrames, "bottomLeft");
			hasBottomLeft = 1;
		end
		-- TODO: Leaving this here for now since ChatFrame2 references it. Do we still need ChatFrame2 to be managed?
		if ( MultiBarRight and MultiBarRight:IsShown() ) then
			tinsert(xOffsetFrames, "rightRight");
		end
		if ( MultiBarRight and MultiBarRight:IsShown() ) then
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
		numWatchBars = numWatchBars + ((ReputationWatchBar and ReputationWatchBar:IsShown()) and 1 or 0);
		numWatchBars = numWatchBars + ((MainMenuExpBar and MainMenuExpBar:IsShown()) and 1 or 0);
		if ( numWatchBars > 1 ) then
			tinsert(yOffsetFrames, "watchBar");
		end
		if ( MainMenuBarMaxLevelBar and MainMenuBarMaxLevelBar:IsShown() ) then
			tinsert(yOffsetFrames, "maxLevel");
		end
		if ( PlayerPowerBarAlt and PlayerPowerBarAlt:IsShown() and not PlayerPowerBarAlt:IsUserPlaced() ) then
			local barInfo = GetUnitPowerBarInfo(PlayerPowerBarAlt.unit);
			if ( not barInfo or not barInfo.anchorTop ) then
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
		if ( value.castingBar and CastingBarFrame) then
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
	if ( MultiBarBottomLeft and MultiBarBottomLeft:IsShown() ) then
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
		if (SlidingActionBarTexture0 and SlidingActionBarTexture1) then
			if ((MultiBarBottomRight and MultiBarBottomRight:IsShown()) or (PetActionBarFrame_IsAboveStance and PetActionBarFrame_IsAboveStance())) then
				SlidingActionBarTexture0:Hide();
				SlidingActionBarTexture1:Hide();
			else
				SlidingActionBarTexture0:Show();
				SlidingActionBarTexture1:Show();
			end
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

	FramePositionDelegate_Override_HandleExtraBars();

	-- If petactionbar is already shown, set its point in addition to changing its y target
	if (PetActionBarFrame and PetActionBarFrame:IsShown() ) then
		PetActionBarFrame:UpdatePositionValues();
	end

	-- Set battlefield minimap position
	if ( BattlefieldMapTab and not BattlefieldMapTab:IsUserPlaced() ) then
		BattlefieldMapTab:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMRIGHT", -BATTLEFIELD_MAP_WIDTH-CONTAINER_OFFSET_X, BATTLEFIELD_TAB_OFFSET_Y);
	end

	-- Setup y anchors
	local anchorY = 0
	local buffsAnchorY = 0;
	if (BuffFrame) then
		buffsAnchorY = min(0, (MINIMAP_BOTTOM_EDGE_EXTENT or 0) - BuffFrame.bottomEdgeExtent);
	end
	-- Count right action bars
	local rightActionBars = 0;
	if ( IsNormalActionBarState and IsNormalActionBarState() ) then
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

	anchorY = FramePositionDelegate_Override_QuestTimerOffsets(anchorY);

	anchorY = FramePositionDelegate_Override_VehicleSeatIndicatorOffsets(anchorY);

	-- Boss frames - need to move below buffs/debuffs if both right action bars are showing
	local numBossFrames = 0;
	if (MAX_BOSS_FRAMES) then
		for i = 1, MAX_BOSS_FRAMES do
			if ( _G["Boss"..i.."TargetFrame"]:IsShown() ) then
				numBossFrames = i;
			end
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

	anchorY = FramePositionDelegate_Override_QuestWatchFrameOffsets(anchorY, rightActionBars, buffsAnchorY);

	-- Update chat dock since the dock could have moved
	if ( FCF_DockUpdate ) then
		FCF_DockUpdate();
	end

	if UpdateContainerFrameAnchors then
		UpdateContainerFrameAnchors();
	end
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

	if ( not GetUIPanelAttribute(frame, "area") ) then
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

	if ( not GetUIPanelAttribute(frame, "area") ) then
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
	return GetUIPanelAttribute(frame, "width") or frame:GetWidth() + (GetUIPanelAttribute(frame, "extraWidth") or 0);
end

function GetUIPanelHeight(frame)
	return GetUIPanelAttribute(frame, "height") or frame:GetHeight() + (GetUIPanelAttribute(frame, "extraHeight") or 0);
end

-- Allow a bit of overlap because there are built-in transparencies and buffers already
-- local MINIMAP_OVERLAP_ALLOWED = 60;

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
			local area = GetUIPanelAttribute(centerFrame, "area");
			if ( area ~= "center" ) then
				offset = offset + ( GetUIPanelAttribute(centerFrame, "width") or UIParent:GetAttribute("DEFAULT_FRAME_WIDTH") );
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

	local area = GetUIPanelAttribute(centerFrame, "area");
	local allowOtherPanels = GetUIPanelAttribute(centerFrame, "allowOtherPanels");
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
			local area = GetUIPanelAttribute(centerFrame, "area");
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
	local ignoreCenter = (centerFrame and GetUIPanelAttribute(centerFrame, "ignoreControlLost")) or IsOptionFrameOpen();

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
	if ( GameMenuFrame:IsShown() or (KeyBindingFrame and KeyBindingFrame:IsShown()) ) then
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
