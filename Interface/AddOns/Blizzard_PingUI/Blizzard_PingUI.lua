
function GetScaledCursorPosition_Insecure()
	local x, y = InputUtil.GetCursorPosition(C_UI.GetUIParent());
	return x, y;
end

local function GetWorldFrameCenter_Insecure()
	local worldFrame = C_UI.GetWorldFrame();
	local centerX, centerY = worldFrame:GetCenter();
	return centerX, centerY;
end

local function GetTopLevelParentScale_Insecure()
	local topLevelParent = C_UI.GetUIParent();
	return topLevelParent:GetEffectiveScale();
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

function PingFrameMixin:EvaluateResult(uiTargetInfo)
    local result = self:SelectionEnd();

    -- If cancel was selected result is nil.
    if result then
		PingManager:SendPing(result.type, uiTargetInfo, PingListenerFrame.startX, PingListenerFrame.startY);
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
		-- Cannot show radial wheel correctly until radialParent is setup.
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
    self.cooldownInfo = C_Ping.GetCooldownInfo();

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
	self.startX, self.startY = securecallfunction(GetScaledCursorPosition_Insecure); -- The position where the radial wheel should show.
	self.checkX, self.checkY = GetCursorPosition(); -- The position on the screen we should check for targets from.
end

function PingListenerFrameMixin:BeginPendingPing()
	-- Get the current target, as well as the valid wedges to show for that target.
	local targetInfo = PingManager:DeterminePingTarget(self.checkX, self.checkY);

	if targetInfo.targetState == Enum.PingSetTargetState.Ok then
		-- If a UI target is found, but it does not support the radial wheel, just send a contextual ping instead.
		if targetInfo.hasUITarget and not targetInfo.allowRadialWheel then
			self.pendingPingForceCancelled = true;
			PingManager:DeterminePingTargetAndSend(self.checkX, self.checkY, self.startX, self.startY);
		elseif targetInfo.allowRadialWheel then
			self.pendingPingInfo = targetInfo;

			if self.pendingPingInfo.hasUITarget then
				PingFrame.radialParent:SetPoint("CENTER", "WorldFrame", "BOTTOMLEFT", self.startX, self.startY);
			end

			PingFrame:SelectionStart(self.pendingPingInfo.wedgeInfo, self.pendingPingInfo.hasUITarget, self.cooldownInfo);
		end
	else
		self.pendingPingForceCancelled = true;

		-- Show error no valid target.
		if targetInfo.targetState == Enum.PingSetTargetState.Failed then
			C_PingSecure.DisplayError(PING_FAILED_GENERIC);
		end
	end
end

function PingListenerFrameMixin:EndPendingPing()
	if self.pendingPingInfo then
		PingFrame:EvaluateResult(self.pendingPingInfo.uiTargetInfo);
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

-- Some visuals are different if colorblind mode is set. These assets may not always be present for all types though, so fall back to normal assets as needed.
local function SetPingPinColorblindAtlas(texture, atlas)
	local colorblindMode = CVarCallbackRegistry:GetCVarValueBool("colorblindMode");
	if colorblindMode then
		local atlasColorblind = atlas.."_colorblind";
		if C_Texture.GetAtlasInfo(atlasColorblind) then
			texture:SetAtlas(atlasColorblind, TextureKitConstants.UseAtlasSize);
		else
			texture:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
		end
	else
		texture:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
	end
end

function PingPinFrameMixin:OnUpdate(elapsed)
    self:UpdateClampedArrow();
end

function PingPinFrameMixin:Reset()
	self.Icon:Hide();
	self.ActionInfo:Hide();
	CooldownFrame_Clear(self.ActionInfo.Cooldown);
end

function PingPinFrameMixin:SetPinStyle(uiTextureKit, isWorldPoint, actionInfo)
	self.hasAction = actionInfo ~= nil;
	if self.hasAction then
		self.ActionInfo.Icon:SetTexture(actionInfo.textureFileDataID);
		local iconOverlayAtlas = ("Ping_CD_Overlay-%s"):format(uiTextureKit);
		SetPingPinColorblindAtlas(self.ActionInfo.IconOverlay, iconOverlayAtlas);

		if actionInfo.cooldownInfo and actionInfo.cooldownInfo.durationMs > 0 then
			local percentage = (actionInfo.cooldownInfo.durationMs - actionInfo.cooldownInfo.remainingMs) / actionInfo.cooldownInfo.durationMs;
			local durationSeconds = actionInfo.cooldownInfo.durationMs / 1000;
			CooldownFrame_SetDisplayAsPercentage(self.ActionInfo.Cooldown, percentage, durationSeconds);
		end

		self.hasFlipBook = false;
	else
		self.Icon:SetAtlas(("Ping_Marker_Icon_%s"):format(uiTextureKit), true);

		self.IconFlipBook:SetAtlas(("Ping_Marker_Flipbook_%s"):format(uiTextureKit), false);
		local flipBookInfo = GetPinFlipBookInfo(uiTextureKit);
		if flipBookInfo then
			self.hasFlipBook = true;
			self.IconFlipBook:ClearAllPoints();
			self.IconFlipBook:SetSize(flipBookInfo.sizeX, flipBookInfo.sizeY);
			self.IconFlipBook:SetPoint("CENTER", self.Icon, "CENTER", flipBookInfo.anchorX, flipBookInfo.anchorY);
		else
			self.hasFlipBook = false;
		end
	end

	local clampedPointerAtlas = ("Ping_OVMarker_Pointer_%s"):format(uiTextureKit);
	SetPingPinColorblindAtlas(self.ClampedPin.Pointer, clampedPointerAtlas);

	self.isWorldPoint = isWorldPoint;
    if self.isWorldPoint then
        self.GroundPin.Background:SetAtlas(("Ping_GroundMarker_BG_%s"):format(uiTextureKit), true);
        self.GroundPin.BackgroundHighlight:SetAtlas(("Ping_GroundMarker_BG_%s"):format(uiTextureKit), true);
        self.GroundPin.BackgroundStem:SetAtlas(("Ping_GroundMarker_Pin_%s"):format(uiTextureKit), true);
        self.GroundPin.Stroke:SetAtlas(("Ping_GroundMarker_Stroke_%s"):format(uiTextureKit), true);
    else
		local unitBackgroundAtlas = ("Ping_UnitMarker_BG_%s"):format(uiTextureKit);
		SetPingPinColorblindAtlas(self.UnitPin.Background, unitBackgroundAtlas);
    end

    self:UpdatePinTargetStyle();
    self.ClampedPin:SetShown(false);
end

function PingPinFrameMixin:UpdatePinTargetStyle()
    if self.isWorldPoint then
		if self.hasAction then
			self.ActionInfo:ClearAllPoints();
			self.ActionInfo:SetPoint("CENTER", self.GroundPin.Background, "CENTER");
		else
			self.Icon:ClearAllPoints();
			self.Icon:SetPoint("CENTER", self.GroundPin.Background, "CENTER");
		end
    else
		if self.hasAction then
			self.ActionInfo:ClearAllPoints();
			self.ActionInfo:SetPoint("CENTER", self.UnitPin.Background, "CENTER", 0, 3);
		else
			self.Icon:ClearAllPoints();
			self.Icon:SetPoint("CENTER", self.UnitPin.Background, "CENTER", 0, 3);
		end
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

		if self.hasAction then
			self.ActionInfo:ClearAllPoints();
			self.ActionInfo:SetPoint("CENTER", self.ClampedPin.Background, "CENTER");
		else
			self.Icon:ClearAllPoints();
			self.Icon:SetPoint("CENTER", self.ClampedPin.Background, "CENTER");
		end

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
    local scale = securecallfunction(GetTopLevelParentScale_Insecure) or 1;
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

	if self.hasAction then
		self.ActionInfo:Show();
	end

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


UnitPingIconFrameMixin = {};

function UnitPingIconFrameMixin:OnLoad()
	self:RegisterEvent("UNIT_PING_PIN_ADDED");
	self:RegisterEvent("UNIT_PING_PIN_REMOVED");
end

function UnitPingIconFrameMixin:OnEvent(event, ...)
	if event == "UNIT_PING_PIN_ADDED" then
		if self.isRaidFrame and not GetCVarBool("showPingsOnRaidFrames") then
			return;
		end

		local guid, uiTextureKit = ...;
		if self:IsGUIDMatch(guid) then
			self:ShowPing(uiTextureKit);
		end
	elseif event == "UNIT_PING_PIN_REMOVED" then
		local guid = ...;
		if self:IsGUIDMatch(guid) then
			self:ClearPing();
		end
	end
end

function UnitPingIconFrameMixin:ShowPing(uiTextureKit)
	self.IconFrame.BackgroundMarker:SetAtlas(("Ping_Frame_BG_%s"):format(uiTextureKit), TextureKitConstants.UseAtlasSize);
	self.IconFrame.Icon:SetAtlas(("Ping_Frame_%s"):format(uiTextureKit), TextureKitConstants.UseAtlasSize);
	self.IconFrame:Show();
end

function UnitPingIconFrameMixin:ClearPing()
	self.IconFrame:Hide();
end

-- To be called by frames using associated template, as each may have bespoke setups.
function UnitPingIconFrameMixin:SetGUIDMatch(isMatch)
	self.isMatch = isMatch;
end

function UnitPingIconFrameMixin:IsGUIDMatch(guid)
	return self.isMatch and self.isMatch(guid);
end
