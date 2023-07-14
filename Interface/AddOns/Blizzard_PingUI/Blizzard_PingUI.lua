PingFrameMixin = {};

function PingFrameMixin:OnLoad()
    RadialWheelFrameMixin.OnLoad(self);

    self:RegisterEvent("PING_RADIAL_WHEEL_FRAME_CREATED");
    self:RegisterEvent("PING_RADIAL_WHEEL_FRAME_DESTROYED");

    C_Ping.CreateFrame();
end

function PingFrameMixin:OnEvent(event, ...)
    if event == "PING_RADIAL_WHEEL_FRAME_CREATED" then
        self.radialParent = ...;
        self:ClearAllPoints();
        self:SetPoint("CENTER", self.radialParent);
    elseif event == "PING_RADIAL_WHEEL_FRAME_DESTROYED" then
        self:ClearAllPoints();
        self.radialParent = nil;
    end
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

PingListenerFrameMixin = {};

function PingListenerFrameMixin:OnLoad()
    self:RegisterEvent("PENDING_PING_OFF_SCREEN");

    PingManager:Initialize();
end

function PingListenerFrameMixin:OnEvent(event, ...)
	if event == "PENDING_PING_OFF_SCREEN" then
        self:ClearPendingPingInfo();
    end
end

function PingListenerFrameMixin:OnMouseDown()
    self.startX, self.startY = GetScaledCursorPosition(); -- The position where the ping wheel should show.
    self.checkX, self.checkY = GetCursorPosition(); -- The position on the screen we should check for targets from.
end

function PingListenerFrameMixin:OnMouseUp()
    if not self.pendingPingInfo then
        PingManager:DeterminePingTargetAndSend(self.checkX, self.checkY, self.startX, self.startY);
    end
end

function PingListenerFrameMixin:OnDragStart()
    if PingFrame.radialParent then
        self:BeginPendingPing();
    else
        -- Cannot show ping wheel correctly until radialParent is setup.
        UIErrorsFrame:AddMessage(PING_ERROR, RED_FONT_COLOR:GetRGBA());
    end
end

function PingListenerFrameMixin:OnDragStop()
    self:EndPendingPing();
end

function PingListenerFrameMixin:OnEnter()
    SetCursor("CAST_CURSOR");
end

function PingListenerFrameMixin:OnLeave()
    ResetCursor();
end

function PingListenerFrameMixin:BeginPendingPing()
    -- Get the current target, as well as the valid wedges to show for that target.
    local targetInfo = PingManager:DeterminePingTarget(self.checkX, self.checkY);

    if targetInfo.hasTarget then
        self.pendingPingInfo = targetInfo;
        self.pendingPingInfo.cooldownInfo = C_Ping.GetCooldownInfo();

        if self.pendingPingInfo.hasUITarget then
            PingFrame.radialParent:SetPoint("CENTER", "WorldFrame", "BOTTOMLEFT", self.startX, self.startY);
        end

        PingFrame:SelectionStart(self.pendingPingInfo.wedgeInfo, self.pendingPingInfo.hasUITarget, self.pendingPingInfo.cooldownInfo);
    else
        -- Show error no valid target.
        UIErrorsFrame:AddMessage(PING_ERROR, RED_FONT_COLOR:GetRGBA());
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
    local centerX, centerY = WorldFrame:GetCenter();
    local scale = UIParent:GetEffectiveScale() or 1;
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