PingManager = {};

local PING_NAME_STRINGS = {
    [Enum.PingSubjectType.Assist] = PING_TYPE_ASSIST,
    [Enum.PingSubjectType.Attack] = PING_TYPE_ATTACK,
    [Enum.PingSubjectType.OnMyWay] = PING_TYPE_ON_MY_WAY,
    [Enum.PingSubjectType.Warning] = PING_TYPE_WARNING,
};

local PING_RESULT_STRINGS = {
    [Enum.PingResult.FailedSpamming] = PING_FAILED_SPAMMING,
    [Enum.PingResult.FailedInvalidTarget] = PING_FAILED_INVALID_TARGET,
    [Enum.PingResult.FailedDisabledByLeader] = PING_FAILED_DISABLED_BY_LEADER,
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

    EventRegistry:RegisterFrameEventAndCallback("PING_PIN_FRAME_ADDED", self.OnPingPinFrameAdded, self);
    EventRegistry:RegisterFrameEventAndCallback("PING_PIN_FRAME_REMOVED", self.OnPingPinFrameRemoved, self);
    EventRegistry:RegisterFrameEventAndCallback("PING_PIN_FRAME_SCREEN_CLAMP_STATE_UPDATED", self.OnPingPinFrameScreenClampStateUpdated, self);
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
    local pingFrame = C_Ping.GetTargetPingReceiver(posX, posY);
    if pingFrame then
        -- If not pingable, then this is a blocking UI dialog for the ping system, do not make further checks.
        if pingFrame.IsPingable then
            result.hasTarget = true;
            result.hasUITarget = true;
            result.wedgeInfo = self.defaultWedgeInfo;
            result.overrideTargetGUID = pingFrame:GetTargetPingGUID();
        end
    elseif C_Ping.GetTargetWorldPing(posX, posY) then
        -- Valid object or world point target found.
        result.hasTarget = true;
        result.wedgeInfo = self.defaultWedgeInfo;
    end

    return result;
end

-- Used for contextual ping.
function PingManager:DeterminePingTargetAndSend(posX, posY, spotX, spotY)
    local pingFrame = C_Ping.GetTargetPingReceiver(posX, posY);
    if pingFrame then
        if pingFrame.IsPingable then
            local contextualType = pingFrame:GetContextualPingType();
            local overrideTargetGUID = pingFrame:GetTargetPingGUID();

            local pingResult = C_Ping.SendPing(contextualType, overrideTargetGUID);
            if pingResult ~= Enum.PingResult.Success then
                UIErrorsFrame:AddMessage(GetPingResultString(pingResult), RED_FONT_COLOR:GetRGBA());
            else
                self:ShowPingSpot(contextualType, spotX, spotY);
            end
        else
            -- This is a blocking UI dialog for the ping system, do not make further checks.
            UIErrorsFrame:AddMessage(PING_ERROR, RED_FONT_COLOR:GetRGBA());
        end
    else
        self:SendContextualWorldPing(spotX, spotY);
    end
end

function PingManager:SendContextualWorldPing(spotX, spotY)
    local pingResult = C_Ping.GetTargetWorldPingAndSend();

    if pingResult.result ~= Enum.PingResult.Success then
        UIErrorsFrame:AddMessage(GetPingResultString(pingResult.result), RED_FONT_COLOR:GetRGBA());
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
            type = PingUtil:GetContextualPingTypeForUnit(targetUnitToken);
        end
    else
        local cursorX, cursorY = GetCursorPosition();
        spotX, spotY = GetScaledCursorPosition(); -- Only set spot if we are dynamically determining our target

        local pingFrame = C_Ping.GetTargetPingReceiver(cursorX, cursorY);
        if pingFrame then
            if pingFrame.IsPingable then
                targetGUID = pingFrame:GetTargetPingGUID();
                if not type then
                    type = pingFrame:GetContextualPingType();
                end
            else
                -- This is a blocking UI dialog for the ping system, do not make further checks.
                UIErrorsFrame:AddMessage(PING_ERROR, RED_FONT_COLOR:GetRGBA());
                return;
            end
        else
            if not type then
                self:SendContextualWorldPing(spotX, spotY);
                return;
            end

            C_Ping.GetTargetWorldPing(cursorX, cursorY);
        end
    end

    self:SendPing(type, targetGUID, spotX, spotY);
end

function PingManager:SendPing(type, overrideTargetGUID, spotX, spotY)
    -- overrideTargetGUID can be nil.
    local pingResult = C_Ping.SendPing(type, overrideTargetGUID);

    if pingResult ~= Enum.PingResult.Success then
        UIErrorsFrame:AddMessage(GetPingResultString(pingResult), RED_FONT_COLOR:GetRGBA());
        return;
    end

    if spotX and spotY then
        self:ShowPingSpot(type, spotX, spotY);
    end
end

function PingManager:CancelPendingPing()
    C_Ping.ClearPendingPingInfo();
end

function PingManager:ShowPingSpot(type, posX, posY)
    local pingSpot = self.pingSpotPool:Acquire();
    pingSpot:ClearAllPoints();
    pingSpot:SetPoint("CENTER", UIParent, "BOTTOMLEFT", posX, posY);

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