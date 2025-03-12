if not IsInGlobalEnvironment() then
	return;
end

-- UIPanel Management constants
UIPANEL_SKIP_SET_POINT = true;
UIPANEL_DO_SET_POINT = nil;
UIPANEL_VALIDATE_CURRENT_FRAME = true;

local CHECK_FIT_DEFAULT_EXTRA_WIDTH = 20;
local CHECK_FIT_DEFAULT_EXTRA_HEIGHT = 20;

local FRAME_POSITION_KEYS = {
	left = 1,
	center = 2,
	right = 3,
	doublewide = 4,
	fullscreen = 5,
};

--[[
UIPanelWindow attributes
======================================================
area: [string]  --  Desired area of UIParent the frame should show in. Depending on chosen area and other settings, where a frame actually shows can vary when multiple frames are open.
	full: Take up the full screen. Other non-full frames can't show with or replace a fullscreen frame.
	center: Take up center area. Can't be shown with any other frames in the left/center/right areas, but may be replaced by other frames if allowOtherPanels is 1.
	left: Take leftmost area of the screen. If pushable, may be shifted to center or right if other pushable frames are shown.
	doublewide: Take up left and center areas. Can be shown with another single-area frame if it's pushable.
	centerOrLeft: When no other panels are open, behaves as Center area panel, otherwise behaves as Left area panel
centerFrameSkipAnchoring: [bool]  --  If true on a frame using area "center," skips updating the frame's anchors when positioned
neverAllowOtherPanels: [0,1]  --  If 1 on a frame using area "center" or "full", prevents trying to show any other panel while that frame is shown
allowOtherPanels: [0,1]   -- (default 0 for "center" frames, otherwise 1)
						  -- If 1 on non center or full area frames, allows other panels to be shown in other areas at the same time.
						  -- If 1 on center frames, allows other frames to replace this one when opened. Also allows bags to be opened while this frame is open.
pushable: [0,1,..n]  --  (attribute used by frames using areas left/doublewide)
					 --  If 0, frame is not pushable to other areas; exact behavior is complicated. (Needs to be investigated to figure out what's actually intentional behavior vs legacy bugs)
					 --  If > 0, frame can be pushed to other areas than area attribute when other frames are also open.
					 --  Pushable frames are sorted by their pushable values, lower to higher, left to right.
					 --  Equal pushable value frames are sorted by how recently they were shown, oldest to newest, left to right.
whileDead: [0,1]  --  If 0, frame cannot be opened while the player is dead.
ignoreControlLost: [bool]  --  If true, do not close the frame when player loses control of character (ie when feared).
showFailedFunc: [func]  --  Function to call when attempting to show the frame via ShowUIPanel fails.
width: [number]  --  Override width to use instead of the frame's actual width for layout/position calculations.
height: [number]  --  Override height to use instead of the frame's actual height for layout/position calculations.
extraWidth: [number]  --  Extra buffer width to add when checking frame's width for layout/position calculations. Is added to 'width' if also set, otherwise is added to frame's actual width.
extraHeight: [number]  --  Extra buffer height to add when checking frame's height for layout/position calculations. Is added to 'height' if also set, otherwise is added to frame's actual height.
xoffset: [number]  --  X offset to add when positioning the frame within the UI parent.
yoffset: [number]  --  Y offset to add when positioning the frame within the UI parent. Actual y position is also clamped based on minYOffset & bottomClampOverride.
minYOffset: [number]  --  (default -10) Custom minimum amount of y offset the frame should have. Since Y offsets from the top are negative, this is numerically a "max" (ex: -20 is "more" offset than -10).
centerXOffset: [number]  --  X offset to add when positioning a centered frame. Useful for centerOrLeft frames to have a different value from xoffset when centered.
bottomClampOverride: [number]  --  (default 140) Custom bottom-most edge that a frame can be positioned to reach. Frame's y offset is calculated by taking this + minYOffset into account.
maximizePoint: [string]  --  [WARNING: Don't use this; this maximize/restore flow is very one-off specific to the World Map] Point that's passed to SetPoint if the frame is maximized via MaximizeUIPanel.
checkFit: [0,1]  --  If 1, frame is scaled down if needed to fit within the current size of the UIParent. This can help large frames stay visible on varying screen sizes/UI scales.
checkFitExtraWidth: [number]  --  (default 20) Extra buffer width added when checking the frame's current size when rescaling for checkFit.
checkFitExtraHeight: [number]  --  (default 20) Extra buffer height added when checking the frame's current size when rescaling for checkFit.
autoMinimizeWithOtherPanels: [bool] -- If true, frame will be automatically minimized if being shown with other UI panels, maximized if alone; requires setMinimizedFunc to also be set.
autoMinimizeOnCondition: [bool|func(frame)] -- Bool or Funcion that returns a bool to indicate whether frame should be minimized; Requires setMinimizedFunc to be set; If autoMinimizeWithOtherPanels is also true, frame will be minimized if this func returns true OR other frames are showing
setMinimizedFunc: [func(frame, bool)] -- Called to minimize/maximize the frame as part of auto minimize logic
]]--

-- Per panel settings
UIPanelWindows = {};

--Center Menu Frames
UIPanelWindows["GameMenuFrame"] =				{ area = "center",		pushable = 0,	whileDead = 1, centerFrameSkipAnchoring = true };
UIPanelWindows["HelpFrame"] =					{ area = "center",		pushable = 0,	whileDead = 1 };
UIPanelWindows["EditModeManagerFrame"] =		{ area = "center",		pushable = 0,	whileDead = 1, neverAllowOtherPanels = 1 };

-- Frames using the new Templates
UIPanelWindows["CharacterFrame"] =				{ area = "left",			pushable = 3,	whileDead = 1};
UIPanelWindows["ProfessionsBookFrame"] =		{ area = "left",			pushable = 1,	whileDead = 1, width = 575, height = 545 };
UIPanelWindows["TaxiFrame"] =					{ area = "left",			pushable = 0, 	width = 605, height = 580, showFailedFunc = CloseTaxiMap };
UIPanelWindows["PVPUIFrame"] =					{ area = "left",			pushable = 0,	whileDead = 1, width = 563};
UIPanelWindows["PVPBannerFrame"] =				{ area = "left",			pushable = 1};
UIPanelWindows["PVEFrame"] =					{ area = "left",			pushable = 1, 	whileDead = 1 };
UIPanelWindows["EncounterJournal"] =			{ area = "left",			pushable = 0, 	whileDead = 1, width = 830};
UIPanelWindows["CollectionsJournal"] =			{ area = "left",			pushable = 0, 	whileDead = 1, width = 733};
UIPanelWindows["TradeFrame"] =					{ area = "left",			pushable = 0};
UIPanelWindows["LootFrame"] =					{ area = "left",			pushable = 0};
UIPanelWindows["MerchantFrame"] =				{ area = "left",			pushable = 0};
UIPanelWindows["TabardFrame"] =					{ area = "left",			pushable = 0};
UIPanelWindows["PVPBannerFrame"] =				{ area = "left",			pushable = 1};
UIPanelWindows["MailFrame"] =					{ area = "left",			pushable = 0};
UIPanelWindows["BankFrame"] =					{ area = "left",			pushable = 6,	width = 425 };
UIPanelWindows["QuestLogPopupDetailFrame"] =	{ area = "left",			pushable = 0,	whileDead = 1 };
UIPanelWindows["QuestFrame"] =					{ area = "left",			pushable = 0};
UIPanelWindows["GuildRegistrarFrame"] =			{ area = "left",			pushable = 0};
UIPanelWindows["GossipFrame"] =					{ area = "left",			pushable = 0};
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
UIPanelWindows["CommunitiesGuildNewsFiltersFrame"] =		{ area = "left",			pushable = 1,	whileDead = 1 };
UIPanelWindows["ClubFinderGuildRecruitmentDialog"] =		{ area = "left",			pushable = 1,	whileDead = 1 };

-- Frames NOT using the new Templates
UIPanelWindows["AnimaDiversionFrame"] =			{ area = "center",			pushable = 0, 		xoffset = -16,	whileDead = 0, allowOtherPanels = 1 };
UIPanelWindows["CinematicFrame"] =				{ area = "full",			pushable = 0, 		xoffset = -16, 		yoffset = 12,	whileDead = 1 };
UIPanelWindows["ChatConfigFrame"] =				{ area = "center",			pushable = 0, 		xoffset = -16,	whileDead = 1 };
UIPanelWindows["ChromieTimeFrame"] =			{ area = "center",			pushable = 0, 		xoffset = -16,	whileDead = 0, allowOtherPanels = 1 };
UIPanelWindows["PVPMatchScoreboard"] =			{ area = "center",			pushable = 0, 		xoffset = -16,	yoffset = -125,	whileDead = 1,	ignoreControlLost = true, };
UIPanelWindows["PVPMatchResults"] =				{ area = "center",			pushable = 0, 		xoffset = -16,	yoffset = -41,	whileDead = 1,	ignoreControlLost = true, };
UIPanelWindows["PlayerChoiceFrame"] =			{ area = "center",			pushable = 0, 		xoffset = -16,	yoffset = -41,	whileDead = 0, allowOtherPanels = 1, ignoreControlLost = true };
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
UIPanelWindows["CovenantMissionFrame"] =		{ area = "center",			pushable = 0,		whileDead = 1, 		checkFit = 1,	allowOtherPanels = 1, extraWidth = 20,	extraHeight = 100 };
UIPanelWindows["BarberShopFrame"] =				{ area = "full",			pushable = 0,};
UIPanelWindows["TorghastLevelPickerFrame"] =	{ area = "center",			pushable = 0, 		xoffset = -16,		yoffset = 12,	whileDead = 0, allowOtherPanels = 1 };
UIPanelWindows["PerksProgramFrame"] =			{ area = "full",			pushable = 0,};
UIPanelWindows["ExpansionLandingPage"] =		{ area = "left",			pushable = 1,		whileDead = 1, 		width = 880, 	allowOtherPanels = 1};

local function SetFrameAttributes(frame, attributes)
	frame:SetAttributeNoHandler("UIPanelLayout-defined", true);
	for name, value in pairs(attributes) do
		frame:SetAttributeNoHandler("UIPanelLayout-"..name, value);
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

	frame:SetAttributeNoHandler("UIPanelLayout-"..name, value);
end

local function FramePositionDelegate_OnAttributeChanged(self, attribute)
	if ( attribute == "panel-show" ) then
		local contextKey = self:GetAttribute("panel-contextKey");
		local force = self:GetAttribute("panel-force");
		local frame = self:GetAttribute("panel-frame");
		self:ShowUIPanel(frame, force, contextKey);
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
	elseif ( attribute == "panel-update-scale-for-fit" ) then
		self:UpdateScaleForFitForOpenPanels();
	end
end

local FramePositionDelegate = CreateFrame("FRAME");
FramePositionDelegate:SetForbidden();
FramePositionDelegate:SetScript("OnAttributeChanged", FramePositionDelegate_OnAttributeChanged);

function FramePositionDelegate:ShowUIPanel(frame, force, contextKey)
	if ( AreAllPanelsDisallowed() ) then
		self:ShowUIPanelFailed(frame);
		return;
	end

	-- If the store-frame is open, we don't let people open up any other panels (just as if it were full-screened)
	if ( StoreFrame_IsShown and StoreFrame_IsShown() ) then
		self:ShowUIPanelFailed(frame);
		return;
	end

	if ( UnitIsDead("player") and not GetUIPanelAttribute(frame, "whileDead") ) then
		self:ShowUIPanelFailed(frame);
		NotWhileDeadError();
		return;
	end

	local frameArea = GetUIPanelAttribute(frame, "area");

	if ( (not force) and (not CanOpenPanels() and frameArea ~= "center" and frameArea ~= "full") ) then
		self:ShowUIPanelFailed(frame);
		return;
	end

	local framePushable = GetUIPanelAttribute(frame, "pushable") or 0;
	local frameAllowOtherPanels = GetUIPanelAttribute(frame, "allowOtherPanels") or 1;

	frame.uiPanelContextKey = contextKey and tostring(contextKey) or nil;

	local fullScreenFrame = self:GetUIPanel("fullscreen");
	local centerFrame = self:GetUIPanel("center");
	local leftFrame = self:GetUIPanel("left");
	local doublewideFrame = self:GetUIPanel("doublewide");
	local rightFrame = self:GetUIPanel("right");

	-- If we have a full-screen frame open, ignore other non-fullscreen open requests, unless certain conditions are met
	if ( fullScreenFrame and (frameArea ~= "full") ) then
		if force or GetUIPanelAttribute(fullScreenFrame, "allowOtherPanels") == 1 then
			self:SetUIPanel("fullscreen", nil, 1);
		else
			self:ShowUIPanelFailed(frame);
			return;
		end
	end

	if ( GetUIPanelAttribute(frame, "checkFit") == 1 ) then
		self:UpdateScaleForFit(frame);
	end

	if ( frameArea == "centerOrLeft" ) then
		-- If other frames already on the screen, use left
		if ( centerFrame or leftFrame or doublewideFrame or rightFrame ) then
			frameArea = "left";
		-- Otherwise if alone, use center
		else
			frameArea = "center";
		end
	end

	-- If we have a "center" frame open, only listen to other "center" open requests
	local centerArea, centerPushable;
	if ( centerFrame ) then
		centerArea = GetUIPanelAttribute(centerFrame, "area");
		if ( centerArea == "center" and GetUIPanelAttribute(centerFrame, "allowOtherPanels") ) then
			HideUIPanel(centerFrame);
			centerFrame = nil;
		else
			if ( centerArea and (centerArea == "center") and (frameArea ~= "center") and (frameArea ~= "full") ) then
				if ( force ) then
					centerFrame = nil;
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
		local skipSetPoints = GetUIPanelAttribute(frame, "centerFrameSkipAnchoring");
		self:SetUIPanel("center", frame, skipSetPoints);
		return;
	end

	-- Doublewide frames take up the left and center spots
	if ( frameArea == "doublewide" ) then
		if ( leftFrame ) then
			local leftPushable = GetUIPanelAttribute(leftFrame, "pushable") or 0;
			if ( leftPushable > 0 and CanShowRightUIPanel(leftFrame) ) then
				-- Push left to right
				self:MoveUIPanel("left", "right", UIPANEL_SKIP_SET_POINT);
			end
		elseif ( centerFrame ) then
			self:MoveUIPanel("center", "right", UIPANEL_SKIP_SET_POINT);
		end
		self:SetUIPanel("doublewide", frame);
		return;
	end

	-- If not pushable, close any doublewide frames
	if ( doublewideFrame ) then
		if ( framePushable == 0 ) then
			-- Set as left (closes doublewide) and slide over the right frame
			self:SetUIPanel("left", frame, 1);
			self:MoveUIPanel("right", "center");
		else
			-- If the new frame can be minimized it may fit in the right slot with the existing
			-- doublewide frame. Otherwise it will have to replace it in the left slot.
			self:EvaluateAutoMinimize(frame);

			if ( CanShowRightUIPanel(frame) ) then
				self:SetUIPanel("right", frame);
			else
				self:SetUIPanel("left", frame);
			end
		end
		return;
	end

	-- Try to put it on the left
	if ( not leftFrame ) then
		self:SetUIPanel("left", frame);
		return;
	end

	local leftPushable = GetUIPanelAttribute(leftFrame, "pushable") or 0;
	local leftAllowOtherPanels = GetUIPanelAttribute(leftFrame, "allowOtherPanels") or 1;

	-- Two open already
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
		local replaceLeft = (leftAllowOtherPanels == 0) or (frameAllowOtherPanels == 0) or ((leftPushable == 0) and (framePushable == 0));
		if replaceLeft then
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
	end

	if ( not skipSetPoint ) then
		securecall("UpdateUIPanelPositions", self[new]);
	end
end

function FramePositionDelegate:HideUIPanel(frame, skipSetPoint)
	self:HideUIPanelImplementation(frame, skipSetPoint);

	local contextKey = frame.uiPanelContextKey;
	if contextKey then
		EventRegistry:TriggerEvent("UIPanel.FrameHidden", contextKey);
	end
end

function FramePositionDelegate:HideUIPanelImplementation(frame, skipSetPoint)
	-- If we're hiding the full-screen frame, just hide it
	if ( frame == self:GetUIPanel("fullscreen") ) then
		self:SetUIPanel("fullscreen", nil);
		return;
	end

	-- If we're hiding the right frame, just hide it
	if ( frame == self:GetUIPanel("right") ) then
		self:SetUIPanel("right", nil, skipSetPoint);
		return;
	end

	-- If we're hiding the doublewide frame, determine where the right frame should go.
	if ( frame == self:GetUIPanel("doublewide") ) then
		local newLocation = "left";

		local rightFrame = self:GetUIPanel("right");
		if ( rightFrame ) then
			local area = GetUIPanelAttribute(rightFrame, "area");
			if ( area and area == "centerOrLeft" ) then
				newLocation = "center";
			end
		end

		-- Even if there's not a right frame call MoveUIPanel to hide the doublewide frame.
		self:MoveUIPanel("right", newLocation, skipSetPoint);
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
				-- If frame is a centerOrLeft frame and there's no right frame, also treat as a native center frame as now nothing else is open
				if ( area == "center" or (area == "centerOrLeft" and not self:GetUIPanel("right")) ) then
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
	if ( not FRAME_POSITION_KEYS[key] ) then
		return nil;
	end

	return self[key];
end

function FramePositionDelegate:IsAnyOtherUIPanelOpen(frame)
	local leftPanel = self:GetUIPanel("left");
	local centerPanel = self:GetUIPanel("center");
	local rightPanel = self:GetUIPanel("right");
	local doubleWidePanel = self:GetUIPanel("doublewide");

	return (leftPanel and leftPanel ~= frame)
		or (centerPanel and centerPanel ~= frame)
		or (rightPanel and rightPanel ~= frame)
		or (doubleWidePanel and doubleWidePanel ~= frame);
end

function FramePositionDelegate:UpdateUIPanelPositions(currentFrame)
	if ( self.updatingPanels ) then
		return;
	end
	self.updatingPanels = true;

	-- Update frame's scaling early so it can be properly accounted for in anchoring
	if ( currentFrame and GetUIPanelAttribute(currentFrame, "checkFit") == 1 ) then
		self:UpdateScaleForFit(currentFrame);
	end

	local topOffset = UIParent:GetAttribute("TOP_OFFSET");
	local leftOffset = UIParent:GetAttribute("LEFT_OFFSET");
	local centerOffset = UIParent:GetAttribute("CENTER_OFFSET");
	local rightOffset = UIParent:GetAttribute("RIGHT_OFFSET");
	local xSpacing = UIParent:GetAttribute("PANEl_SPACING_X");

	local frame = self:GetUIPanel("left");
	if ( frame ) then
		self:EvaluateAutoMinimize(frame);

		local scale = frame:GetScale();
		local xOff = GetUIPanelAttribute(frame,"xoffset") or 0;
		local yOff = GetUIPanelAttribute(frame,"yoffset") or 0;
		local bottomClampOverride = GetUIPanelAttribute(frame,"bottomClampOverride");
		local minYOffset = GetUIPanelAttribute(frame,"minYOffset");
		local yPos = ClampUIPanelY(frame, yOff + topOffset, minYOffset, bottomClampOverride);
		frame:ClearAllPoints();
		frame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", (leftOffset + xOff)/scale, yPos/scale);
		centerOffset = leftOffset + GetUIPanelWidth(frame) + xOff;
		UIParent:SetAttribute("CENTER_OFFSET", centerOffset);
		frame:Raise();
	else
		centerOffset = leftOffset;
		UIParent:SetAttribute("CENTER_OFFSET", centerOffset);

		frame = self:GetUIPanel("doublewide");
		if ( frame ) then
			self:EvaluateAutoMinimize(frame);

			local scale = frame:GetScale();
			local xOff = GetUIPanelAttribute(frame,"xoffset") or 0;
			local yOff = GetUIPanelAttribute(frame,"yoffset") or 0;
			local bottomClampOverride = GetUIPanelAttribute(frame,"bottomClampOverride");
			local minYOffset = GetUIPanelAttribute(frame,"minYOffset");
			local yPos = ClampUIPanelY(frame, yOff + topOffset, minYOffset, bottomClampOverride);
			frame:ClearAllPoints();
			frame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", (leftOffset + xOff)/scale, yPos/scale);
			rightOffset = leftOffset + GetUIPanelWidth(frame) + xOff;
			UIParent:SetAttribute("RIGHT_OFFSET", rightOffset);
			frame:Raise();
		end
	end

	frame = self:GetUIPanel("center");
	if ( frame ) then
		self:EvaluateAutoMinimize(frame);

		if ( CanShowCenterUIPanel(frame) ) then
			local area = GetUIPanelAttribute(frame, "area");
			if ( area == "centerOrLeft" ) then
				area = self:IsAnyOtherUIPanelOpen(frame) and "left" or "center";
			end

			local scale = frame:GetScale();
			local xOff = GetUIPanelAttribute(frame,"xoffset") or 0;
			local yOff = GetUIPanelAttribute(frame,"yoffset") or 0;
			local bottomClampOverride = GetUIPanelAttribute(frame,"bottomClampOverride");
			local minYOffset = GetUIPanelAttribute(frame,"minYOffset");
			local skipSetPoints = GetUIPanelAttribute(frame, "centerFrameSkipAnchoring");
			local yPos = ClampUIPanelY(frame, yOff + topOffset, minYOffset, bottomClampOverride);
			if ( area ~= "center" ) then
				frame:ClearAllPoints();
				xOff = xOff + xSpacing; -- add separating space
				frame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", (centerOffset + xOff)/scale, yPos/scale);
			elseif not skipSetPoints then
				frame:ClearAllPoints();
				-- Centered frames don't use xoffset to prevent undesired positioning (especially in
				-- centerOrLeft cases) but can use the centerXOffset attribute for special case positioning.
				local centerXOffset = GetUIPanelAttribute(frame,"centerXOffset") or 0;
				frame:SetPoint("TOP", "UIParent", "TOP", centerXOffset, yPos/scale);
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
		if ( frame ) then
			frame:Raise();
		end
	elseif ( not self:GetUIPanel("doublewide") ) then
		local leftPanel = self:GetUIPanel("left");
		if ( leftPanel ) then
			rightOffset = GetUIPanelWidth(leftPanel) + (GetUIPanelAttribute(leftPanel,"xoffset") or 0);
		else
			rightOffset = leftOffset + UIParent:GetAttribute("DEFAULT_FRAME_WIDTH") * 2
		end
	end
	UIParent:SetAttribute("RIGHT_OFFSET", rightOffset);

	frame = self:GetUIPanel("right");
	if ( frame ) then
		self:EvaluateAutoMinimize(frame);
		if ( CanShowRightUIPanel(frame) ) then
			local scale = frame:GetScale();
			local xOff = GetUIPanelAttribute(frame,"xoffset") or 0;
			local yOff = GetUIPanelAttribute(frame,"yoffset") or 0;
			local bottomClampOverride = GetUIPanelAttribute(frame,"bottomClampOverride");
			local minYOffset = GetUIPanelAttribute(frame,"minYOffset");
			local yPos = ClampUIPanelY(frame, yOff + topOffset, minYOffset, bottomClampOverride);
			xOff = xOff + xSpacing; -- add separating space
			frame:ClearAllPoints();
			frame:SetPoint("TOPLEFT", "UIParent", "TOPLEFT", (rightOffset + xOff)/scale, yPos/scale);
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
		if ( frame ) then
			frame:Raise();
		end
	end

	self.updatingPanels = nil;
end

function FramePositionDelegate:UpdateScaleForFitForOpenPanels()
	for key, index in pairs(FRAME_POSITION_KEYS) do
		local frame = self:GetUIPanel(key);
		if frame then
			self:UpdateScaleForFit(frame);
		end
	end

	self:UpdateUIPanelPositions();
end

function FramePositionDelegate:UpdateScaleForFit(frame)
	UIPanelUpdateScaleForFit(frame, GetUIPanelAttribute(frame, "checkFitExtraWidth") or CHECK_FIT_DEFAULT_EXTRA_WIDTH, GetUIPanelAttribute(frame, "checkFitExtraHeight") or CHECK_FIT_DEFAULT_EXTRA_HEIGHT);
end

function FramePositionDelegate:EvaluateAutoMinimize(frame)
	local autoMinimizeWithPanels = GetUIPanelAttribute(frame, "autoMinimizeWithOtherPanels");
	local autoMinimizeCondition = GetUIPanelAttribute(frame, "autoMinimizeOnCondition");
	if (not autoMinimizeWithPanels and autoMinimizeCondition == nil) then
		return;
	end
	local setMinimizedFunc = GetUIPanelAttribute(frame, "setMinimizedFunc");
	if (not setMinimizedFunc) then
		return;
	end

	-- Currently evaluating "Auto Minimize" options as "OR" conditions, so check for any of them being met

	local shouldBeMinimized = false;
	if autoMinimizeWithPanels and self:IsAnyOtherUIPanelOpen(frame) then
		shouldBeMinimized = true;
	end

	if not shouldBeMinimized and autoMinimizeCondition ~= nil then
		if type(autoMinimizeCondition) == "function" then
			shouldBeMinimized = autoMinimizeCondition(frame);
		else
			shouldBeMinimized = autoMinimizeCondition;
		end
	end

	setMinimizedFunc(frame, shouldBeMinimized);

	-- Now that the panel's minimized state has changed, ensure any scale to fit is updated for changes in size
	if GetUIPanelAttribute(frame, "checkFit") == 1 then
		self:UpdateScaleForFit(frame);
	end
end

function FramePositionDelegate:UIParentManageFramePositions()
	if not MainMenuBar:IsUserPlaced() and not MicroButtonAndBagsBar:IsUserPlaced() then
		local screenWidth = UIParent:GetWidth();
		local barScale = 1;
		local barWidth = MainMenuBar:GetWidth();
		local barMargin = MAIN_MENU_BAR_MARGIN;
		local bagsWidth = MicroButtonAndBagsBar:GetWidth();
		local contentsWidth = barWidth + bagsWidth;
		if contentsWidth > screenWidth then
			barScale = screenWidth / contentsWidth;
			barWidth = barWidth * barScale;
			bagsWidth = bagsWidth * barScale;
			barMargin = barMargin * barScale;
		end
		MainMenuBar:SetScale(barScale);
	end

	local customOverlayHeight = C_GameRules.GetGameRuleAsFloat(Enum.GameRule.CustomActionbarOverlayHeightOffset);
	local bottomActionBarHeight = EditModeUtil:GetBottomActionBarHeight() + customOverlayHeight;
	bottomActionBarHeight = bottomActionBarHeight > 0 and bottomActionBarHeight + 15 or MAIN_ACTION_BAR_DEFAULT_OFFSET_Y;
	UIParentBottomManagedFrameContainer.fixedWidth = 573;
	UIParentBottomManagedFrameContainer:ClearAllPoints();
	UIParentBottomManagedFrameContainer:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, bottomActionBarHeight);
	UIParentBottomManagedFrameContainer:Layout();
	UIParentBottomManagedFrameContainer.BottomManagedLayoutContainer:Layout();

	local rightAnchor = EditModeUtil:GetRightContainerAnchor();
	if(rightAnchor) then
		UIParentRightManagedFrameContainer:ClearAllPoints();
		UIParentRightManagedFrameContainer.fixedHeight = UIParent:GetHeight() - MinimapCluster:GetHeight() - 100;
		rightAnchor:SetPoint(UIParentRightManagedFrameContainer, true);
		UIParentRightManagedFrameContainer:Layout();
		UIParentRightManagedFrameContainer.BottomManagedLayoutContainer:Layout();
	end
	if(ObjectiveTrackerFrame and ObjectiveTrackerFrame:IsShown()) then
		ObjectiveTrackerFrame:UpdateHeight();
	end
	if(ContainerFrame) then
		UpdateContainerFrameAnchors();
	end

	local width, height = UIParentBottomManagedFrameContainer.BottomManagedLayoutContainer:GetSize();
	UIParentBottomManagedFrameContainer.BottomManagedLayoutContainer:SetShown(width > 0 and height > 0);
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

function ShowUIPanel(frame, force, contextKey)
	if ( CanAutoSetGamePadCursorControl(true) ) then
		SetGamePadCursorControl(true);
	end

	if ( not frame or frame:IsShown() ) then
		return;
	end

	if ( not CheckProtectedFunctionsAllowed() ) then
		return;
	end

	if ( frame.editModeManuallyShown or not GetUIPanelAttribute(frame, "area") ) then
		frame:Show();
		return;
	end

	-- Dispatch to secure code
	FramePositionDelegate:SetAttribute("panel-contextKey", contextKey);
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

	if ( frame.editModeManuallyShown or not GetUIPanelAttribute(frame, "area") ) then
		frame:Hide();
		return;
	end

	--Dispatch to secure code
	FramePositionDelegate:SetAttribute("panel-frame", frame);
	FramePositionDelegate:SetAttribute("panel-skipSetPoint", skipSetPoint);
	FramePositionDelegate:SetAttribute("panel-hide", true);
end

function SetUIPanelShown(frame, shown, force)
	if ( shown ) then
		ShowUIPanel(frame, force);
	else
		HideUIPanel(frame, force);
	end
end

function GetUIPanel(key)
	return FramePositionDelegate:GetUIPanel(key);
end

function GetUIPanelWidthUnscaled(frame, extraWidth)
	extraWidth = extraWidth or 0;
	extraWidth = extraWidth + (GetUIPanelAttribute(frame, "extraWidth") or 0);

	local frameWidth = GetUIPanelAttribute(frame, "width") or frame:GetWidth();

	return frameWidth + extraWidth;
end

function GetUIPanelHeightUnscaled(frame, extraHeight)
	extraHeight = extraHeight or 0;
	extraHeight = extraHeight + (GetUIPanelAttribute(frame, "extraHeight") or 0);

	local frameHeight = GetUIPanelAttribute(frame, "height") or frame:GetHeight();

	return frameHeight + extraHeight;
end

function GetUIPanelWidth(frame, extraWidth)
	local unscaledWidth = GetUIPanelWidthUnscaled(frame, extraWidth);
	return unscaledWidth * frame:GetScale();
end

function GetUIPanelHeight(frame, extraHeight)
	local unscaledHeight = GetUIPanelHeightUnscaled(frame, extraHeight);
	return unscaledHeight * frame:GetScale();
end

function UIPanelUpdateScaleForFit(frame, extraWidth, extraHeight)
	return FrameUtil.UpdateScaleForFitSpecific(frame, GetUIPanelWidthUnscaled(frame, extraWidth), GetUIPanelHeightUnscaled(frame, extraHeight));
end

--Allow a bit of overlap because there are built-in transparencies and buffers already
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
	-- The minimum amount the y can be offset (mathematically speaking it's a max since y offsets from the top are negative)
	local minimumOffset = minYOffset or -10;
	if (yOffset > minimumOffset) then
		yOffset = minimumOffset;
	end
	return yOffset;
end

function CanShowRightUIPanel(frame)
	local width = frame and GetUIPanelWidth(frame) or UIParent:GetAttribute("DEFAULT_FRAME_WIDTH");
	local rightSide = UIParent:GetAttribute("RIGHT_OFFSET") + width;
	return rightSide <= GetMaxUIPanelsWidth();
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

-- Returns false if there are exclusive-area frames blocking other non-exclusive frames from opening
function CanOpenPanels()
	local fullScreenFrame = GetUIPanel("fullscreen");
	if fullScreenFrame and GetUIPanelAttribute(fullScreenFrame, "allowOtherPanels") ~= 1 then
		return false;
	end

	local centerFrame = GetUIPanel("center");
	if ( not centerFrame ) then
		return true;
	end

	local area = GetUIPanelAttribute(centerFrame, "area");
	local allowOtherPanels = GetUIPanelAttribute(centerFrame, "allowOtherPanels");
	if ( area and (area == "center") and not allowOtherPanels ) then
		return false;
	end

	return true;
end

function AreAllPanelsDisallowed()
	local currentWindow = GetUIPanel("center");
	if not currentWindow then
		currentWindow = GetUIPanel("full");
		if not currentWindow then
			return false;
		end
	end

	local neverAllowOtherPanels = GetUIPanelAttribute(currentWindow, "neverAllowOtherPanels");
	return neverAllowOtherPanels;
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

function CloseWindows(ignoreCenter, frameToIgnore, context)
	-- This function will close all frames that are not the current frame
	local leftFrame = GetUIPanel("left");
	local centerFrame = GetUIPanel("center");
	local rightFrame = GetUIPanel("right");
	local doublewideFrame = GetUIPanel("doublewide");
	local fullScreenFrame = GetUIPanel("fullscreen");
	local found = leftFrame or centerFrame or rightFrame or doublewideFrame or fullScreenFrame;
	local ignoreControlLostLeft =  ( leftFrame ~= nil and context == "lossOfControl" and GetUIPanelAttribute( leftFrame, "ignoreControlLost" ) )
	local ignoreControlLostRight =  ( rightFrame ~= nil and context == "lossOfControl" and GetUIPanelAttribute( rightFrame, "ignoreControlLost" ) )
	local ignoreControlLostCenter =  ( centerFrame ~= nil and context == "lossOfControl" and GetUIPanelAttribute( centerFrame, "ignoreControlLost" ) )

	if ( ( not frameToIgnore or frameToIgnore ~= leftFrame ) and not ignoreControlLostLeft ) then
		HideUIPanel(leftFrame, UIPANEL_SKIP_SET_POINT);
	end

	HideUIPanel(fullScreenFrame, UIPANEL_SKIP_SET_POINT);
	HideUIPanel(doublewideFrame, UIPANEL_SKIP_SET_POINT);

	if ( ( not frameToIgnore or frameToIgnore ~= centerFrame ) and not ignoreControlLostCenter ) then
		if ( centerFrame ) then
			local area = GetUIPanelAttribute(centerFrame, "area");
			if ( area ~= "center" or not ignoreCenter ) then
				HideUIPanel(centerFrame, UIPANEL_SKIP_SET_POINT);
			end
		end
	end

	if ( ( not frameToIgnore or frameToIgnore ~= rightFrame ) and not ignoreControlLostRight ) then
		if ( rightFrame ) then
			HideUIPanel(rightFrame, UIPANEL_SKIP_SET_POINT);
		end
	end

	found = securecall("CloseSpecialWindows") or found;

	UpdateUIPanelPositions();

	return found;
end

-- When the player loses control we close all UIs, unless they're handled below
function CloseAllWindows_WithExceptions()
	CloseAllWindows(IsOptionFrameOpen(), "lossOfControl");
end

function CloseAllWindows(ignoreCenter, context)
	local bagsVisible = CloseAllBags();
	local windowsVisible = CloseWindows(ignoreCenter, nil, context );
	local anyClosed = (bagsVisible or windowsVisible);
	if (anyClosed and CanAutoSetGamePadCursorControl(false)) then
		SetGamePadCursorControl(false);
	end
	return anyClosed;
end

-- this function handles possibly tainted values and so
-- should always be called from secure code using securecall()
function CloseMenus()
	for index, value in pairs(UIMenus) do
		local menu = _G[value];
		if ( menu and menu:IsShown() ) then
			menu:Hide();
		end
	end
end

function UpdateUIPanelPositions(currentFrame)
	FramePositionDelegate:SetAttribute("panel-frame", currentFrame)
	FramePositionDelegate:SetAttribute("panel-update", true);
end

function UpdateScaleForFitForOpenPanels()
	FramePositionDelegate:SetAttribute("panel-update-scale-for-fit", true);
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
	if ( GameMenuFrame:IsShown() or SettingsPanel:IsShown() or (KeyBindingFrame and KeyBindingFrame:IsShown()) ) then
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