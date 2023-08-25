---------------
--NOTE - Please do not change this section
local _, tbl, secureCapsuleGet = ...;
assertsafe(secureCapsuleGet ~= nil, "SecureCapsuleGet not provided to secure environment.");
tbl.SecureCapsuleGet = secureCapsuleGet;
tbl.setfenv = tbl.SecureCapsuleGet("setfenv");
tbl.getfenv = tbl.SecureCapsuleGet("getfenv");
tbl.type = tbl.SecureCapsuleGet("type");
tbl.unpack = tbl.SecureCapsuleGet("unpack");
tbl.error = tbl.SecureCapsuleGet("error");
tbl.pcall = tbl.SecureCapsuleGet("pcall");
tbl.pairs = tbl.SecureCapsuleGet("pairs");
tbl.setmetatable = tbl.SecureCapsuleGet("setmetatable");
tbl.getmetatable = tbl.SecureCapsuleGet("getmetatable");
tbl.pcallwithenv = tbl.SecureCapsuleGet("pcallwithenv");

local function CleanFunction(f)
	local f = function(...)
		local function HandleCleanFunctionCallArgs(success, ...)
			if success then
				return ...;
			else
				tbl.error("Error in secure capsule function execution: "..(...));
			end
		end
		return HandleCleanFunctionCallArgs(tbl.pcallwithenv(f, tbl, ...));
	end
	setfenv(f, tbl);
	return f;
end

local function CleanTable(t, tableCopies)
	if not tableCopies then
		tableCopies = {};
	end

	local cleaned = {};
	tableCopies[t] = cleaned;

	for k, v in tbl.pairs(t) do
		if tbl.type(v) == "table" then
			if ( tableCopies[v] ) then
				cleaned[k] = tableCopies[v];
			else
				cleaned[k] = CleanTable(v, tableCopies);
			end
		elseif tbl.type(v) == "function" then
			cleaned[k] = CleanFunction(v);
		else
			cleaned[k] = v;
		end
	end
	return cleaned;
end

local function Import(name)
	if tbl[name] ~= nil then
		return;
	end

	local skipTableCopy = true;
	local val = tbl.SecureCapsuleGet(name, skipTableCopy);
	if tbl.type(val) == "function" then
		tbl[name] = CleanFunction(val);
	elseif tbl.type(val) == "table" then
		tbl[name] = CleanTable(val);
	else
		tbl[name] = val;
	end
end

if tbl.getmetatable(tbl) == nil then
	local secureEnvMetatable =
	{
		__metatable = false,
		__environment = false,
	}
	tbl.setmetatable(tbl, secureEnvMetatable);
end

setfenv(1, tbl);
----------------

Import("C_CVar");
Import("C_Ping");
Import("C_PingSecure");
Import("C_Timer");
Import("C_UI");
Import("Enum");

Import("GetCVar");
Import("GetCursorPosition");
Import("GetScaledCursorPositionForFrame");
Import("ResetCursor");
Import("SetCursor");
Import("tonumber");
Import("Vector2D_CalculateAngleBetween");
Import("Vector2D_Cross");
Import("Vector2D_Dot");

----------------

function GetScaledCursorPosition_Insecure()
	local x, y = GetScaledCursorPositionForFrame(C_UI.GetUIParent());
	return x, y;
end

local function GetWorldFrameCenter_Insecure()
	local worldFrame = C_UI.GetWorldFrame();
	local centerX, centerY = worldFrame:GetCenter();
	return centerX, centerY;
end

local function GetUIParentScale_Insecure()
	local uiParent = C_UI.GetUIParent();
	return uiParent:GetEffectiveScale();
end


PingFrameMixin = {};

function PingFrameMixin:OnLoad()
    RadialWheelFrameMixin.OnLoad(self);

	C_PingSecure.SetPingRadialWheelCreatedCallback(function(...) self:RadialWheelCreated(...) end);

    self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function PingFrameMixin:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
		self:Initialize();
	end
end

function PingFrameMixin:Initialize()
    if self.initialized then
		return;
	end

	C_PingSecure.CreateFrame();
	self.initialized = true;
end

function PingFrameMixin:RadialWheelCreated(radialParent)
    self.radialParent = radialParent;
    self:ClearAllPoints();
    self:SetPoint("CENTER", self.radialParent);
end

function PingFrameMixin:EvaluateResult(overrideTargetGUID)
    local result = self:SelectionEnd();

    -- If cancel was selected result is nil.
    if result then
        PingManager:SendPing(result.type, overrideTargetGUID, PingListenerFrame.startX, PingListenerFrame.startY);
    else
        -- Ping cancelled.
        PingManager:CancelPendingPing();
    end
end

PingListenerFrameMixin = {
    PingRadialKeyDownDuration = 0.15;
};

function PingListenerFrameMixin:OnLoad()
    C_PingSecure.SetPendingPingOffScreenCallback(function(...) self:OnPendingPingOffScreen(...) end);
	C_PingSecure.SetTogglePingListenerCallback(function(...) self:TogglePingListener(...) end);
	C_PingSecure.SetPingCooldownStartedCallback(function(...) self:PingCooldownStarted(...) end);

    PingManager:Initialize();

    self.enabledState = false;
end

function PingListenerFrameMixin:PingCooldownStarted(cooldownInfo)
	self.cooldownInfo = cooldownInfo;
    SetCursor("PING_ERROR_CURSOR");
    self:SetupCooldownTimer();
end

function PingListenerFrameMixin:OnPendingPingOffScreen()
	self.pendingPingForceCancelled = true;
    self:ClearPendingPingInfo();
end

function PingListenerFrameMixin:OnMouseDown()
    if self:GetPingMode() == Enum.PingMode.KeyDown then
        return;
    end

    self:SetCursorPositions();
end

function PingListenerFrameMixin:OnMouseUp()
    if self:GetPingMode() == Enum.PingMode.KeyDown then
        return;
    end

    if not self.pendingPingInfo then
        PingManager:DeterminePingTargetAndSend(self.checkX, self.checkY, self.startX, self.startY);
    end
end

function PingListenerFrameMixin:OnDragStart()
    if self:GetPingMode() == Enum.PingMode.KeyDown then
        return;
    end

    if PingFrame.radialParent then
        self:BeginPendingPing();
    else
        -- Cannot show ping wheel correctly until radialParent is setup.
		C_PingSecure.DisplayError(PING_FAILED_GENERIC);
    end
end

function PingListenerFrameMixin:OnDragStop()
    if self:GetPingMode() == Enum.PingMode.KeyDown then
        return;
    end

    self:EndPendingPing();
end

function PingListenerFrameMixin:OnEnter()
    self.cooldownInfo = C_PingSecure.GetCooldownInfo();

    -- If on cooldown, make sure correct mouse cursor is shown.
    if self.cooldownInfo then
        local nowMs = GetTime() * 1000;
        if nowMs < self.cooldownInfo.endTimeMs then
            SetCursor("PING_ERROR_CURSOR");
            self:SetupCooldownTimer();
            return;
        end
    end

    SetCursor("PING_CURSOR");
end

function PingListenerFrameMixin:OnLeave()
    ResetCursor();
end

function PingListenerFrameMixin:TogglePingListener(enabled)
    if self.enabledState == enabled then
        return;
    end

    self.enabledState = enabled;
    if enabled then
        -- If not the drag flow, start the timer until the radial wheel is shown.
        if self:GetPingMode() == Enum.PingMode.KeyDown then
            self:SetCursorPositions();
            self.radialTimer = C_Timer.NewTimer(self.PingRadialKeyDownDuration, function()
                self:BeginPendingPing();
                self.radialTimer = nil;
            end);
        end

        self:Show();
    else
        if self:GetPingMode() == Enum.PingMode.KeyDown then
            if self.pendingPingInfo then
                self:EndPendingPing();
            -- Do not attempt to send a contextual ping if a radial wheel was shown but since cancelled (gone off screen, triggered over invalid target, etc.)
            elseif not self.pendingPingForceCancelled then
                -- If no pending ping, send a contextual ping (ping listener keybind was released before the radial wheel was shown).
                self:SetCursorPositions();
                PingManager:DeterminePingTargetAndSend(self.checkX, self.checkY, self.startX, self.startY);
            end

            if self.radialTimer then
                self.radialTimer:Cancel();
                self.radialTimer = nil;
            end
        else
            PingListenerFrame:CancelPendingPing();
        end

		self.cooldownInfo = nil;
        if self.cooldownTimer then
            self.cooldownTimer:Cancel();
            self.cooldownTimer = nil;
        end

        self.pendingPingForceCancelled = nil;
		self:Hide();
    end
end

function PingListenerFrameMixin:SetupCooldownTimer()
    if self.cooldownTimer then
        self.cooldownTimer:Cancel();
        self.cooldownTimer = nil;
    end

    local cooldownDuration = (self.cooldownInfo.endTimeMs / 1000) - GetTime();
    self.cooldownTimer = C_Timer.NewTimer(cooldownDuration, function()
        SetCursor("PING_CURSOR");
        self.cooldownTimer = nil;
    end);
end

function PingListenerFrameMixin:GetPingMode()
    return tonumber(GetCVar("pingMode"));
end

function PingListenerFrameMixin:SetCursorPositions()
    self.startX, self.startY = securecallfunction(GetScaledCursorPosition_Insecure); -- The position where the ping wheel should show.
    self.checkX, self.checkY = GetCursorPosition(); -- The position on the screen we should check for targets from.
end

function PingListenerFrameMixin:BeginPendingPing()
    -- Get the current target, as well as the valid wedges to show for that target.
    local targetInfo = PingManager:DeterminePingTarget(self.checkX, self.checkY);

    if targetInfo.hasTarget then
        self.pendingPingInfo = targetInfo;

        if self.pendingPingInfo.hasUITarget then
            PingFrame.radialParent:SetPoint("CENTER", "WorldFrame", "BOTTOMLEFT", self.startX, self.startY);
        end

        PingFrame:SelectionStart(self.pendingPingInfo.wedgeInfo, self.pendingPingInfo.hasUITarget, self.cooldownInfo);
    else
        -- Show error no valid target.
        self.pendingPingForceCancelled = true;
		C_PingSecure.DisplayError(PING_FAILED_GENERIC);
    end
end

function PingListenerFrameMixin:EndPendingPing()
    if self.pendingPingInfo then
        PingFrame:EvaluateResult(self.pendingPingInfo.overrideTargetGUID);
        self:ClearPendingPingInfo();
    end
end

function PingListenerFrameMixin:CancelPendingPing()
    if self.pendingPingInfo then
        PingManager:CancelPendingPing();
        self:ClearPendingPingInfo();
    end
end

function PingListenerFrameMixin:ClearPendingPingInfo()
    self.pendingPingInfo = nil;
    PingFrame:AnimateOutro();
end

PingPinFrameMixin = {};

local PIN_FLIP_BOOK_INFO = {
    ["Assist"] = { sizeX=81, sizeY=48, anchorX=-17.5, anchorY=4 },
    ["Attack"] = { sizeX=55, sizeY=70, anchorX=-12.2, anchorY=-14 },
    ["OnMyWay"] = { sizeX=50, sizeY=68, anchorX=0, anchorY=10.5 },
    ["Warning"] = { sizeX=32, sizeY=80.5, anchorX=0, anchorY=1.5 },
    ["NonThreat"] = { sizeX=65, sizeY=75, anchorX=0.3, anchorY=0.9 },
    ["Threat"] = { sizeX=65, sizeY=75, anchorX=0.5, anchorY=0.9 },
};

local function GetPinFlipBookInfo(uiTextureKit)
	return PIN_FLIP_BOOK_INFO[uiTextureKit];
end

function PingPinFrameMixin:OnUpdate(elapsed)
    self:UpdateClampedArrow();
end

function PingPinFrameMixin:SetPinStyle(uiTextureKit, isWorldPoint)
    self.isWorldPoint = isWorldPoint;

    self.Icon:SetAtlas(("Ping_Marker_Icon_%s"):format(uiTextureKit), true);
    self.IconFlipBook:SetAtlas(("Ping_Marker_Flipbook_%s"):format(uiTextureKit), false);
    self.ClampedPin.Pointer:SetAtlas(("Ping_OVMarker_Pointer_%s"):format(uiTextureKit), true);

    local flipBookInfo = GetPinFlipBookInfo(uiTextureKit);
    if flipBookInfo then
        self.hasFlipBook = true;
        self.IconFlipBook:ClearAllPoints();
        self.IconFlipBook:SetSize(flipBookInfo.sizeX, flipBookInfo.sizeY);
        self.IconFlipBook:SetPoint("CENTER", self.Icon, "CENTER", flipBookInfo.anchorX, flipBookInfo.anchorY);
    else
        self.hasFlipBook = false;
    end

    if self.isWorldPoint then
        self.GroundPin.Background:SetAtlas(("Ping_GroundMarker_BG_%s"):format(uiTextureKit), true);
        self.GroundPin.BackgroundHighlight:SetAtlas(("Ping_GroundMarker_BG_%s"):format(uiTextureKit), true);
        self.GroundPin.BackgroundStem:SetAtlas(("Ping_GroundMarker_Pin_%s"):format(uiTextureKit), true);
        self.GroundPin.Stroke:SetAtlas(("Ping_GroundMarker_Stroke_%s"):format(uiTextureKit), true);
    else
        self.UnitPin.Background:SetAtlas(("Ping_UnitMarker_BG_%s"):format(uiTextureKit), true);
    end

    self:UpdatePinTargetStyle();
    self.ClampedPin:SetShown(false);
end

function PingPinFrameMixin:UpdatePinTargetStyle()
    if self.isWorldPoint then
        self.Icon:ClearAllPoints();
        self.Icon:SetPoint("CENTER", self.GroundPin.Background, "CENTER");
    else
        self.Icon:ClearAllPoints();
        self.Icon:SetPoint("CENTER", self.UnitPin.Background, "CENTER", 0, 3);
    end

    self.GroundPin:SetShown(self.isWorldPoint);
    self.UnitPin:SetShown(not self.isWorldPoint);
end

function PingPinFrameMixin:UpdatePinClampedStyle(state)
    self.isClamped = state;

    self.ClampedPin:SetShown(self.isClamped);
    if self.isClamped then
        self.GroundPin:Hide();
        self.UnitPin:Hide();

        self.Icon:ClearAllPoints();
        self.Icon:SetPoint("CENTER", self.ClampedPin.Background, "CENTER");
        self:SetScript("OnUpdate", self.OnUpdate);

        if self.isWorldPoint and self.IntroAnimGround:IsPlaying() then
            self.IntroAnimGround:Stop();
        elseif self.IntroAnimUnit:IsPlaying() then
            self.IntroAnimUnit:Stop();
        end
    else
        self:UpdatePinTargetStyle();

        self:SetScript("OnUpdate", nil);
    end
end

local function GetCenterScreenPoint()
    local centerX, centerY = securecallfunction(GetWorldFrameCenter_Insecure);
    local scale = securecallfunction(GetUIParentScale_Insecure) or 1;
    return centerX / scale, centerY / scale;
end

function PingPinFrameMixin:UpdateClampedArrow()
    local centerScreenX, centerScreenY = GetCenterScreenPoint();
    local centerIconX, centerIconY = self:GetCenter();

    if centerIconX and centerIconY then
        local angle = Vector2D_CalculateAngleBetween(centerScreenX - centerIconX, centerScreenY - centerIconY, 0, 1);
        self.ClampedPin.Pointer:SetRotation(-angle);
    end
end

function PingPinFrameMixin:AnimateIntro()
    self:Show();
    if self.isWorldPoint then
        self.IntroAnimGround:Restart();

        if self.hasFlipBook then
            self.IntroAnimGround_FlipBook:Restart();
        end
    else
        self.IntroAnimUnit:Restart();

        if self.hasFlipBook then
            self.IntroAnimUnit_FlipBook:Restart();
        end
    end
end

PingPinFlipBookAnimMixin = {};

function PingPinFlipBookAnimMixin:OnPlay()
    local parent = self:GetParent();
    parent.Icon:Hide();
    parent.IconFlipBook:Show();
end

function PingPinFlipBookAnimMixin:OnFinished()
    local parent = self:GetParent();
    parent.Icon:Show();
    parent.IconFlipBook:Hide();
end