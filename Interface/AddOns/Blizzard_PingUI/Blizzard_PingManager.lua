
PingManager = {};

local PING_NAME_STRINGS = {
    [Enum.PingSubjectType.Assist] = PING_TYPE_ASSIST,
    [Enum.PingSubjectType.Attack] = PING_TYPE_ATTACK,
    [Enum.PingSubjectType.OnMyWay] = PING_TYPE_ON_MY_WAY,
    [Enum.PingSubjectType.Warning] = PING_TYPE_WARNING,
};

local PING_RESULT_STRINGS = {
    [Enum.PingResult.FailedSpamming] = PING_FAILED_SPAMMING,
	[Enum.PingResult.FailedGeneric] = PING_FAILED_GENERIC,
    [Enum.PingResult.FailedDisabledByLeader] = PING_FAILED_DISABLED_BY_LEADER,
    [Enum.PingResult.FailedDisabledBySettings] = PING_FAILED_DISABLED_BY_SETTINGS,
    [Enum.PingResult.FailedOutOfPingArea] = PING_FAILED_OUT_OF_PING_AREA,
	[Enum.PingResult.FailedSquelched] = PING_FAILED_SQUELCHED,
    [Enum.PingResult.FailedUnspecified] = PING_FAILED_UNSPECIFIED,
	[Enum.PingResult.FailedSilent] = "",
};

local function GetPingNameString(type)
	return PING_NAME_STRINGS[type] or "";
end

local function GetPingResultString(type)
	return PING_RESULT_STRINGS[type] or PING_FAILED_UNSPECIFIED;
end

local function SortWedges(a, b)
	return a.orderIndex < b.orderIndex;
end

function PingManager:Initialize()
	self:SetupDefaultPingOptions();

	local function PingPinReset(_framePool, frame)
		frame:Reset();
		frame:ClearAllPoints();
		frame:Hide();
	end
	self.pingPinPool = CreateFramePool("FRAME", nil, "PingPinFrameTemplate", PingPinReset);
	self.activePinFrames = {};

	self.pingSpotPool = CreateFramePool("FRAME", nil, "PingSpotFrameTemplate");

	C_PingSecure.SetPingPinFrameAddedCallback(function(...) self:OnPingPinFrameAdded(...) end);
	C_PingSecure.SetPingPinFrameRemovedCallback(function(...) self:OnPingPinFrameRemoved(...) end);
	C_PingSecure.SetPingPinFrameScreenClampStateUpdatedCallback(function(...) self:OnPingPinFrameScreenClampStateUpdated(...) end);
	C_PingSecure.SetSendMacroPingCallback(function(...) self:SendMacroPing(...) end);
end

function PingManager:SetupDefaultPingOptions()
    self.defaultWedgeInfo = {};

    local pingTypeData = C_Ping.GetDefaultPingOptions();
    table.sort(pingTypeData, SortWedges);

    local formattedIcon = "Ping_Wheel_Icon_%s";
    for i, data in ipairs(pingTypeData) do
        local wedgeInfo = {
            type = data.type,
            icon = formattedIcon:format(data.uiTextureKitID or ""),
            text = GetPingNameString(data.type),
        };

        table.insert(self.defaultWedgeInfo, wedgeInfo);
    end
end

function PingManager:OnPingPinFrameAdded(frame, uiTextureKit, isWorldPoint, actionInfo)
    local existingPin = self.activePinFrames[frame];
    if existingPin then
        return;
    end

    local pin = self.pingPinPool:Acquire();
    pin:SetParent(frame);
    pin:SetPoint("CENTER", frame);
	pin:SetPinStyle(uiTextureKit, isWorldPoint, actionInfo);
    pin:AnimateIntro();

    self.activePinFrames[frame] = pin;
end

function PingManager:OnPingPinFrameRemoved(frame)
    local pin = self.activePinFrames[frame];
    if pin then
        pin:ClearAllPoints();
        self.activePinFrames[frame] = nil;

        pin.OutroAnim:SetScript("OnFinished", function()
            pin.OutroAnim:SetScript("OnFinished", nil);
            pin:Hide();

            self.pingPinPool:Release(pin);
        end);
        pin.OutroAnim:Restart();
    end
end

function PingManager:OnPingPinFrameScreenClampStateUpdated(frame, state)
    local pin = self.activePinFrames[frame];
    if pin then
        pin:UpdatePinClampedStyle(state);
    end
end

local function GetTargetPingReceiverInfo_Insecure(posX, posY)
	local pingInfo = {
		frameFound = false,
		isPingable = false,
		allowRadialWheel = false,
		uiTargetInfo = {}
	};

	local pingFrame = C_PingSecure.GetTargetPingReceiver(posX, posY);
	if pingFrame then
		pingInfo.frameFound = true;

		-- If this frame implements PingableTypeMixin.
		if pingFrame.GetIsPingable then
			pingInfo.isPingable = pingFrame:GetIsPingable();
			pingInfo.allowRadialWheel = pingFrame:GetAllowRadialWheel();
			pingInfo.uiTargetInfo = pingFrame:GetTargetInfo();
		end
	end

	return pingInfo;
end

-- Used for radial wheel.
function PingManager:DeterminePingTarget(posX, posY)
	local result = {
		targetState = Enum.PingSetTargetState.Failed,
		hasUITarget = false,
		allowRadialWheel = false,
		wedgeInfo = {},
		uiTargetInfo = {}
	};

	-- First, see if the cursor is over any valid pingable UI (either as a blocking frame, or a pingable target).
	-- Frames marked as topLevel are marked as valid, usually for being ping blockers.  If marked with the ping-top-level-pass-through attribute, they will no longer be considered valid.
	-- Frames specifically marked with the ping-receiver attribute are also caught here.
	local pingInfo = securecallfunction(GetTargetPingReceiverInfo_Insecure, posX, posY);
	if pingInfo.frameFound then
		-- If not pingable, then this is blocking UI for the ping system, do not make further checks.
		if pingInfo.isPingable then
			result.targetState = Enum.PingSetTargetState.Ok;
			result.hasUITarget = true;

			-- This frame is a valid target, but might only accept contextual pings and not radial wheel pinging. Check for that.
			if pingInfo.allowRadialWheel then
				result.allowRadialWheel = pingInfo.allowRadialWheel;
				result.wedgeInfo = self.defaultWedgeInfo;
				result.uiTargetInfo = pingInfo.uiTargetInfo;
			end
		end
	else
		result.targetState = C_PingSecure.SetHitTestPingTarget(posX, posY);
		if result.targetState == Enum.PingSetTargetState.Ok then
			-- Valid object or world point target found.
			result.allowRadialWheel = true;
			result.wedgeInfo = self.defaultWedgeInfo;
		end
	end

	return result;
end

-- Used for contextual ping.
function PingManager:DeterminePingTargetAndSend(posX, posY, spotX, spotY)
	local pingInfo = securecallfunction(GetTargetPingReceiverInfo_Insecure, posX, posY);
	if pingInfo.frameFound then
		if pingInfo.isPingable then
			-- pingType is contextual here, we figure out the type later.
			self:SendPing(nil, pingInfo.uiTargetInfo, spotX, spotY);
		else
			-- This is a blocking UI dialog for the ping system, do not make further checks.
			C_PingSecure.DisplayError(PING_FAILED_GENERIC);
		end
	else
		self:SendContextualWorldPing(spotX, spotY);
	end
end

function PingManager:SendContextualWorldPing(spotX, spotY)
	local pingResult = C_PingSecure.SetHitTestTargetAndSendPing();

    if pingResult.result ~= Enum.PingResult.Success then
		C_PingSecure.DisplayError(GetPingResultString(pingResult.result));
        return;
    end

	if pingResult.type and spotX and spotY then
		self:ShowPingSpot(pingResult.type, spotX, spotY);
    end
end

function PingManager:SendMacroPing(macroInfo)
	local type = macroInfo.type;
	local uiTargetInfo = {};
	local spotX, spotY; -- Spot should only be set if we are dynamically determining our target.
	local setTargetState = Enum.PingSetTargetState.Ok;

	if macroInfo.spellID then
		uiTargetInfo.spellID = macroInfo.spellID;
	elseif macroInfo.itemID then
		uiTargetInfo.itemID = macroInfo.itemID;
	elseif macroInfo.targetToken then
		-- Unique to macros. Should target be the cursor, pass through all UI and ignore units, only targetting the environment (also ignores Ping Target setting).
		local forcePointPing = macroInfo.targetToken == "cursor";
		if forcePointPing then
			local cursorX, cursorY = GetCursorPosition();
			spotX, spotY = securecallfunction(GetScaledCursorPosition_Insecure);
			setTargetState = C_PingSecure.SetHitTestPingTarget(cursorX, cursorY, forcePointPing);
		else
			uiTargetInfo.guid = UnitGUID(macroInfo.targetToken);
		end
	else
		local cursorX, cursorY = GetCursorPosition();
		spotX, spotY = securecallfunction(GetScaledCursorPosition_Insecure);

		local pingInfo = securecallfunction(GetTargetPingReceiverInfo_Insecure, cursorX, cursorY);
		if pingInfo.frameFound then
			if pingInfo.isPingable then
				uiTargetInfo = pingInfo.uiTargetInfo;
			else
				-- This is a blocking UI dialog for the ping system, do not make further checks.
				setTargetState = Enum.PingSetTargetState.Failed;
			end
		else
			setTargetState = C_PingSecure.SetHitTestPingTarget(cursorX, cursorY);
		end
	end

	if setTargetState == Enum.PingSetTargetState.Ok then
		self:SendPing(type, uiTargetInfo, spotX, spotY);
	elseif setTargetState == Enum.PingSetTargetState.Failed then
		C_PingSecure.DisplayError(PING_FAILED_GENERIC);
	end
end

function PingManager:SendPing(type, uiTargetInfo, spotX, spotY)
	-- There are several different kinds of pings that a player could be trying to send, each with a different set of params.
	local pingResult;
	if uiTargetInfo.spellID then
		pingResult = C_PingSecure.SendPlayerSpellPing(uiTargetInfo.spellID);
	elseif uiTargetInfo.spellCategoryID then
		pingResult = C_PingSecure.SendPlayerSpellCategoryPing(uiTargetInfo.spellCategoryID);
	elseif uiTargetInfo.itemID then
		pingResult = C_PingSecure.SendPlayerItemPing(uiTargetInfo.itemID);
	elseif uiTargetInfo.guid then
		pingResult = C_PingSecure.SendUnitPing(uiTargetInfo.guid, type, uiTargetInfo.isPlayerResource);
	else
		-- Fallback UI ping, also used for all non-UI pings.
		pingResult = C_PingSecure.SendHitTestPing(type);
	end

	if pingResult.result ~= Enum.PingResult.Success then
		C_PingSecure.DisplayError(GetPingResultString(pingResult.result));
		return;
	end

	if spotX and spotY then
		self:ShowPingSpot(pingResult.type, spotX, spotY);
	end
end

function PingManager:CancelPendingPing()
	C_PingSecure.ClearHitTestPingInfo();
end

function PingManager:ShowPingSpot(type, posX, posY)
    local pingSpot = self.pingSpotPool:Acquire();
    pingSpot:ClearAllPoints();
    pingSpot:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", posX, posY);

    local uiTextureKit = C_Ping.GetTextureKitForType(type);
    pingSpot.GlowIn:SetAtlas(("Ping_SpotGlw_%s_In"):format(uiTextureKit), true);
    pingSpot.GlowOut:SetAtlas(("Ping_SpotGlw_%s_Out"):format(uiTextureKit), true);

    pingSpot.PulseAnim:SetScript("OnFinished", function()
        pingSpot.PulseAnim:SetScript("OnFinished", nil);
        pingSpot:Hide();

        self.pingSpotPool:Release(pingSpot);
    end);
    pingSpot:Show();
    pingSpot.PulseAnim:Restart();
end
