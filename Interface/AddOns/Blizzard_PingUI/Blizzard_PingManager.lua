
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

    local function PingPinReset(framePool, frame)
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

function PingManager:OnPingPinFrameAdded(frame, uiTextureKit, isWorldPoint)
    local existingPin = self.activePinFrames[frame];
    if existingPin then
        return;
    end

    local pin = self.pingPinPool:Acquire();
    pin:SetParent(frame);
    pin:SetPoint("CENTER", frame);
    pin:SetPinStyle(uiTextureKit, isWorldPoint);
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

-- Returns: frameFound, isPingable, contextualPingType, targetPingGUID
local function GetTargetPingReceiverInfo_Insecure(posX, posY)
	local pingFrame = C_PingSecure.GetTargetPingReceiver(posX, posY);
	if pingFrame then
		local frameFound = true;
		return frameFound, pingFrame.IsPingable, pingFrame.GetContextualPingType and pingFrame:GetContextualPingType(), pingFrame.GetTargetPingGUID and pingFrame:GetTargetPingGUID();
	end
	return false, nil, nil, nil;
end

-- Used for ping wheel.
function PingManager:DeterminePingTarget(posX, posY)
    local result = {
        hasTarget = false,
        hasUITarget = false,
        wedgeInfo = {},
        overrideTargetGUID = nil,
    };

    -- First, see if the cursor is over any valid pingable UI (either as a blocking frame, or a pingable target).
    -- Frames marked as topLevel are marked as valid, usually for being ping blockers.  If marked with the ping-top-level-pass-through attribute, they will no longer be considered valid.
    -- Frames specifically marked with the ping-receiver attribute are also caught here.
	local frameFound, isPingable, contextualPingType, targetPingGUID = securecallfunction(GetTargetPingReceiverInfo_Insecure, posX, posY);
    if frameFound then
        -- If not pingable, then this is a blocking UI dialog for the ping system, do not make further checks.
        if isPingable then
            result.hasTarget = true;
            result.hasUITarget = true;
            result.wedgeInfo = self.defaultWedgeInfo;
            result.overrideTargetGUID = targetPingGUID;
        end
    elseif C_PingSecure.GetTargetWorldPing(posX, posY) then
        -- Valid object or world point target found.
        result.hasTarget = true;
        result.wedgeInfo = self.defaultWedgeInfo;
    end

    return result;
end

-- Used for contextual ping.
function PingManager:DeterminePingTargetAndSend(posX, posY, spotX, spotY)
	local frameFound, isPingable, contextualPingType, targetPingGUID = securecallfunction(GetTargetPingReceiverInfo_Insecure, posX, posY);
    if frameFound then
        if isPingable then
            local pingResult = C_PingSecure.SendPing(contextualPingType, targetPingGUID);
            if pingResult ~= Enum.PingResult.Success then
				C_PingSecure.DisplayError(GetPingResultString(pingResult));
            else
                self:ShowPingSpot(contextualPingType, spotX, spotY);
            end
        else
            -- This is a blocking UI dialog for the ping system, do not make further checks.
			C_PingSecure.DisplayError(PING_FAILED_GENERIC);
        end
    else
        self:SendContextualWorldPing(spotX, spotY);
    end
end

function PingManager:SendContextualWorldPing(spotX, spotY)
    local pingResult = C_PingSecure.GetTargetWorldPingAndSend();

    if pingResult.result ~= Enum.PingResult.Success then
		C_PingSecure.DisplayError(GetPingResultString(pingResult.result));
        return;
    end

    if pingResult.contextualPingType and spotX and spotY then
        self:ShowPingSpot(pingResult.contextualPingType, spotX, spotY);
    end
end

function PingManager:SendMacroPing(type, targetUnitToken)
    local targetGUID;
    local spotX, spotY;

    if targetUnitToken then
        targetGUID = UnitGUID(targetUnitToken);

        if not type then
            type = PingUtil:GetContextualPingTypeForUnit(targetGUID);
        end
    else
        local cursorX, cursorY = GetCursorPosition();
        spotX, spotY = securecallfunction(GetScaledCursorPosition_Insecure); -- Only set spot if we are dynamically determining our target

		local frameFound, isPingable, contextualPingType, targetPingGUID = securecallfunction(GetTargetPingReceiverInfo_Insecure, cursorX, cursorY);
        if frameFound then
            if isPingable then
                targetGUID = targetPingGUID;
                if not type then
                    type = contextualPingType;
                end
            else
                -- This is a blocking UI dialog for the ping system, do not make further checks.
				C_PingSecure.DisplayError(PING_FAILED_GENERIC);
                return;
            end
        else
            if not type then
                self:SendContextualWorldPing(spotX, spotY);
                return;
            end

            C_PingSecure.GetTargetWorldPing(cursorX, cursorY);
        end
    end

    self:SendPing(type, targetGUID, spotX, spotY);
end

function PingManager:SendPing(type, overrideTargetGUID, spotX, spotY)
    -- overrideTargetGUID can be nil.
    local pingResult = C_PingSecure.SendPing(type, overrideTargetGUID);

    if pingResult ~= Enum.PingResult.Success then
		C_PingSecure.DisplayError(GetPingResultString(pingResult));
        return;
    end

    if spotX and spotY then
        self:ShowPingSpot(type, spotX, spotY);
    end
end

function PingManager:CancelPendingPing()
    C_PingSecure.ClearPendingPingInfo();
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