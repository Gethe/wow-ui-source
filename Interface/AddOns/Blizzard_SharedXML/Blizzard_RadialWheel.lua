---------------
--NOTE - Please do not change this section
local _, tbl = ...;
if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;
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

	Import("AnchorUtil");
	Import("C_Texture");
	Import("C_UI");
	Import("EasingUtil");
	Import("math");

	Import("CalculateAngleBetween");
	Import("CalculateDistanceSq");
	Import("Clamp");
	Import("ClampedPercentageBetween");
	Import("GetScaledCursorPositionForFrame");
	Import("GetTime");
	Import("ipairs");
	Import("Lerp");
	Import("PercentageBetween");
	Import("Saturate");
	Import("select");
end

----------------

local RADIAL_FORMAT_SMALL = "%s_Small";
local RADIAL_FORMAT_DISABLED = "%s_Disabled";
local RADIAL_FORMAT_COOLDOWN = "%s_CoolDown";
local RADIAL_FORMAT_COUNT = "%s_Count_%d";
local RADIAL_FORMAT_GLOW = "%s_Glow";
local TWO_PI = 2 * math.pi;

local function FormatStringForSize(string, isSmall)
    return isSmall and RADIAL_FORMAT_SMALL:format(string) or string;
end

RadialWheelFrameMixin = {
    MinimumWedgeDistanceSquared = 500;
    MinimumWedgeDistanceSquaredSmall = 150;
};

function RadialWheelFrameMixin:OnLoad()
    self.wedgeAngleOffsetInitial = (.5 * math.pi); -- Start with quarter offset (to have a wedge on top of the wheel for layout)
    self.radialWheelWedgePool = CreateFramePool("FRAME", self, "RadialWheelWedgeButtonTemplate");
    self.radialParent = nil; -- to be overridden by whatever system uses this.
    self.OutroAnim:SetScript("OnFinished", function() self:Hide(); end);
end

function RadialWheelFrameMixin:OnUpdate()
    self:UpdateSelection();
end

local function GetScaledCursorPosition_Insecure()
	local x, y = GetScaledCursorPositionForFrame(C_UI.GetUIParent());
	return x, y;
end

function RadialWheelFrameMixin:UpdateSelection(forceUpdate)
    -- Get angle of mouse position relative to center of frame to know which wedge we are selecting.
    local x, y = securecallfunction(GetScaledCursorPosition_Insecure);
    local radialParentX, radialParentY = select(4, self.radialParent:GetPoint());
    if not forceUpdate and x == self.lastX and y == self.lastY and radialParentX == self.lastRadialParentX and radialParentY == self.lastRadialParentY then
        return;
    end

    self.lastX, self.lastY = x, y;
    self.lastRadialParentX, self.lastRadialParentY = radialParentX, radialParentY;

	if self.radialParent then
        local centerX, centerY = self.radialParent:GetCenter();

        -- Minimum distance for a selection, to account for middle button.
        local distance = CalculateDistanceSq(centerX, centerY, x, y);
        local minDistance = self.isSmall and self.MinimumWedgeDistanceSquaredSmall or self.MinimumWedgeDistanceSquared;
        if distance <= minDistance then
            if self.currentSelected then
                self.currentSelected:SetSelected(false);
            end
            self.currentSelected = self.CancelButton;
            self.CancelButton:SetSelected(true);

            self.Pointer:Hide();
            return;
        end

        self.CancelButton:SetSelected(false);

        if self:IsOnCooldown() then
            self.Pointer:Hide();
            return;
        end

        local angle = CalculateAngleBetween(centerX, centerY, x, y); -- In radians

        self.Pointer:Show();
        self.Pointer:SetRotation(angle);

        angle = angle - self.wedgeAngleOffsetInitial + self.wedgeAngleIntervalRadiansHalf;
        if angle < 0 then
            angle = angle + TWO_PI;
        end

        local targetWedgeIndex = 1;
        while angle >= self.wedgeAngleIntervalRadians do
            targetWedgeIndex = targetWedgeIndex + 1;
            angle = angle - self.wedgeAngleIntervalRadians;
        end

        -- If wedge changed, unselect old and reselect new.
        local targetWedge = self.radialWheelWedgeButtons[targetWedgeIndex];
        if targetWedge ~= self.currentSelected then
            if self.currentSelected then
                self.currentSelected:SetSelected(false);
            end
            self.currentSelected = targetWedge;
            self.currentSelected:SetSelected(true);
        end
    end
end

function RadialWheelFrameMixin:SelectionStart(wedges, isSmall, cooldownInfo)
    self.isSmall = isSmall;
    self.cooldownInfo = cooldownInfo;
    self.numWedges = #wedges;

    if self.currentSelected then
        -- Visual cleanup.
        self.currentSelected:SetSelected(false);
    end

    self.currentSelected = nil;
    self.wedgeAngleIntervalRadians = TWO_PI / #wedges;
    self.wedgeAngleIntervalRadiansHalf = (self.wedgeAngleIntervalRadians * .5) -- Used for wedge detection calculation in OnUpdate.

    self:UpdateFrameTexture();
    self.Background:SetAtlas(FormatStringForSize("Radial_Wheel_BG", self.isSmall), true);
    self.Pointer:SetAtlas(FormatStringForSize("Radial_Wheel_Select_Pointer", self.isSmall), true);
    self.Pointer:Show();

    self.CancelButton.SelectedTexture:SetAtlas(FormatStringForSize("Radial_Wheel_Select_Close", self.isSmall), true);
    self.CancelButton.Icon:SetAtlas(FormatStringForSize("Radial_Wheel_Icon_Close", self.isSmall), true);
    self.CancelButton.Text:SetText(nil);
    self.CancelButton.IntroAnim:Restart();

    self:SetupRadialWedgeButtons(wedges);
    self:UpdateCooldownState();
    self.IntroAnim:Restart();
    self:Show();

    self:SetScript("OnUpdate", self.OnUpdate);
end

function RadialWheelFrameMixin:SelectionEnd()
    if self.currentSelected then
        if self.currentSelected == self.CancelButton then
            return nil;
        else
            -- Resulting wedge selected.
            return self.currentSelected;
        end
    end
end

function RadialWheelFrameMixin:AnimateOutro()
    self.isWheelClosing = true;

    self:SetScript("OnUpdate", nil);

    self.lastX, self.lastY = nil, nil;
    self.Pointer:Hide();

    self.OutroAnim:Restart();
    self.CancelButton:SetSelected(false);
    self.CancelButton.OutroAnim:Restart();

    if self.Cooldown:IsShown() and not self.Cooldown.OutroAnim:IsPlaying() then
        self.Cooldown:Pause();
        self.Cooldown.OutroAnim:Restart();
    end

    for _, wedgeFrame in ipairs(self.radialWheelWedgeButtons) do
        wedgeFrame:SetSelected(false);
        wedgeFrame:AnimateOutro();
    end
end

function RadialWheelFrameMixin:SetupRadialWedgeButtons(wedges)
    self.isWheelClosing = false;

    self.radialWheelWedgePool:ReleaseAll();
    self.radialWheelWedgeButtons = {};
    local angle = self.wedgeAngleOffsetInitial;
    local selectedTexture = ("Radial_Wheel_Select_Wedge_Count_%d"):format(self.numWedges);

    -- Distances out from center to be positioned.
    local wedgeSpacing = self.isSmall and 40 or 80;
    local wedgeSelectedSpacing = self.isSmall and 10 or 20;
	for i=1, #wedges do
        local wedgeFrame = self.radialWheelWedgePool:Acquire();
        local wedgeInfo = wedges[i];

        -- General identifier associated with each wedge, useful when evaluating result.
        wedgeFrame.type = wedgeInfo.type;

		local frameX = math.cos(angle) * wedgeSpacing;
		local frameY = math.sin(angle) * wedgeSpacing;
        wedgeFrame:SetPoint("CENTER", self, "CENTER", frameX, frameY);

		local selectedX = math.cos(angle) * wedgeSelectedSpacing;
		local selectedY = math.sin(angle) * wedgeSelectedSpacing;

        wedgeFrame.SelectedTexture:SetAtlas(FormatStringForSize(selectedTexture, self.isSmall), true);
        wedgeFrame.SelectedTexture:SetRotation(angle);
        wedgeFrame.SelectedTexture:SetPoint("CENTER", selectedX, selectedY);

        wedgeFrame:SetEnabled(not self:IsOnCooldown());
        wedgeFrame:SetIsSmall(self.isSmall);
        wedgeFrame:SetIcon(wedgeInfo.icon);
        wedgeFrame:SetText(wedgeInfo.text);
        wedgeFrame:SetSelected(false);

        -- Text has different anchoring depending on which quadrant of the wheel the wedge is in (to be generally on the outside of the wedge).
        local quarterPi = .25 * math.pi;
        wedgeFrame.Text:ClearAllPoints();
        if (angle > quarterPi) and (angle <= math.pi - quarterPi) then
            wedgeFrame.Text:SetPoint("BOTTOM", wedgeFrame.Icon, "TOP", 0, 10);
        elseif (angle > math.pi - quarterPi) and (angle <= math.pi + quarterPi) then
            wedgeFrame.Text:SetPoint("RIGHT", wedgeFrame.Icon, "LEFT");
        elseif (angle > math.pi + quarterPi) and (angle <= TWO_PI - quarterPi) then
            wedgeFrame.Text:SetPoint("TOP", wedgeFrame.Icon, "BOTTOM", 0, -10);
        else
            wedgeFrame.Text:SetPoint("LEFT", wedgeFrame.Icon, "RIGHT");
        end

        self.radialWheelWedgeButtons[i] = wedgeFrame;
        wedgeFrame:Show();

        wedgeFrame.angle = angle;
        wedgeFrame:AnimateIntro();

        angle = angle + self.wedgeAngleIntervalRadians;
    end
end

function RadialWheelFrameMixin:IsOnCooldown()
    local nowMs = GetTime() * 1000;
    return self.cooldownInfo and nowMs < self.cooldownInfo.endTimeMs;
end

function RadialWheelFrameMixin:UpdateCooldownState()
    local isOnCooldown = self:IsOnCooldown();

    for _, wedgeButton in ipairs(self.radialWheelWedgeButtons) do
        wedgeButton:SetEnabled(not isOnCooldown);
    end

    self:UpdateFrameTexture();

    if isOnCooldown then
        local cooldownBackgroundAtlasName = FormatStringForSize("Radial_Wheel_BarBG_CoolDown", self.isSmall);
        self.Cooldown.Background:SetAtlas(cooldownBackgroundAtlasName, true);

        local cooldownEdgeFxAtlasName = FormatStringForSize("Radial_Wheel_Bar_CoolDownFX", self.isSmall);
        self.Cooldown.EdgeFx:SetAtlas(cooldownEdgeFxAtlasName, true);

        local cooldownSwipeAtlasName = FormatStringForSize("Radial_Wheel_Bar_CoolDown", self.isSmall);
        local cooldownSwipeAtlasInfo = C_Texture.GetAtlasInfo(cooldownSwipeAtlasName);
        self.Cooldown:SetSwipeTexture(cooldownSwipeAtlasInfo.file or cooldownSwipeAtlasInfo.filename);
        self.Cooldown:SetSize(cooldownSwipeAtlasInfo.width, cooldownSwipeAtlasInfo.height);

        local lowTexCoords = { x = cooldownSwipeAtlasInfo.leftTexCoord, y = cooldownSwipeAtlasInfo.topTexCoord };
        local highTexCoords = { x = cooldownSwipeAtlasInfo.rightTexCoord, y = cooldownSwipeAtlasInfo.bottomTexCoord };
        self.Cooldown:SetTexCoordRange(lowTexCoords, highTexCoords);

        local cooldownStartTimeSeconds = self.cooldownInfo.startTimeMs / 1000;
        local cooldownDurationSeconds = (self.cooldownInfo.endTimeMs - self.cooldownInfo.startTimeMs) / 1000;
        self.Cooldown:Resume();
        self.Cooldown:SetCooldown(cooldownStartTimeSeconds, cooldownDurationSeconds);
    else
        self.Cooldown:Hide();
    end
end

function RadialWheelFrameMixin:OnCooldownDone()
    if not self.isWheelClosing then
        self:UpdateCooldownState();

        local forceUpdate = true;
        self:UpdateSelection(forceUpdate);

        for _, wedgeButton in ipairs(self.radialWheelWedgeButtons) do
            wedgeButton:AnimateCooldownDone();
        end
    end
end

function RadialWheelFrameMixin:UpdateFrameTexture()
    local frameAtlasName = "Radial_Wheel_Frame";
    frameAtlasName = self:IsOnCooldown() and RADIAL_FORMAT_COOLDOWN:format(frameAtlasName) or frameAtlasName;
    frameAtlasName = RADIAL_FORMAT_COUNT:format(frameAtlasName, self.numWedges);
    frameAtlasName = FormatStringForSize(frameAtlasName, self.isSmall);
    self.Frame:SetAtlas(frameAtlasName, true);
end

RadialWheelButtonMixin = {};

local buttonAnimValues = {
    Intro = {
        duration = 0.2;
        distanceLarge = -20;
        distanceSmall = -10;
    },
    Outro = {
        duration = 0.13;
        distanceLarge = -20;
        distanceSmall = -10;
    },
    CooldownDone = {
        duration = 0.2;
        distanceLarge = -10;
        distanceSmall = -10;
    },
}

function RadialWheelButtonMixin:OnHide()
    self:CleanupAnimations();
end

function RadialWheelButtonMixin:OnUpdate()
    local now = GetTime();
    local percent = ClampedPercentageBetween(now, self.animStartTime, self.animEndTime);
    local offsetX = Lerp(self.animStartX, self.animEndX, EasingUtil.InOutCubic(percent));
    local offsetY = Lerp(self.animStartY, self.animEndY, EasingUtil.InOutCubic(percent));
    self:SetAnimatingFramePoint(offsetX, offsetY);

    if percent >= 1 then
        self:StopAnimatingFrame();
    end
end

function RadialWheelButtonMixin:CacheAnimatingFrameInfo(frame)
    self.animatingFrameInfo = {
        frame = frame,
        initialAnchor = AnchorUtil.CreateAnchorFromPoint(frame, 1);
    };
end

function RadialWheelButtonMixin:SetAnimatingFramePoint(extraOffsetX, extraOffsetY)
    local clearAllPoints = true;
    self.animatingFrameInfo.initialAnchor:SetPointWithExtraOffset(self.animatingFrameInfo.frame, clearAllPoints, extraOffsetX, extraOffsetY);
end

function RadialWheelButtonMixin:StopAnimatingFrame()
    if not self.animatingFrameInfo then
        return;
    end

    self:SetScript("OnUpdate", nil);

    local offsetX, offsetY = 0, 0;
    self:SetAnimatingFramePoint(offsetX, offsetY);
    self.animatingFrameInfo = nil;
end

function RadialWheelButtonMixin:SetAnimationTimes(valuesTable)
    self.animStartTime = GetTime();
	self.animEndTime = self.animStartTime + valuesTable.duration;
end

function RadialWheelButtonMixin:SetupForAnimation(animValuesKey, animatingFrame, isAnimatingOutward)
    local valuesTable = buttonAnimValues[animValuesKey];

    local animDistance = self.isSmall and valuesTable.distanceSmall or valuesTable.distanceLarge;
    local animXDistance = math.cos(self.angle) * animDistance;
    local animYDistance = math.sin(self.angle) * animDistance;
    if isAnimatingOutward then
        self.animStartX = animXDistance;
        self.animStartY = animYDistance;
        self.animEndX = 0;
        self.animEndY = 0;
    else
        self.animStartX = 0;
        self.animStartY = 0;
        self.animEndX = animXDistance;
        self.animEndY = animYDistance;
    end

    self:CacheAnimatingFrameInfo(animatingFrame);
    self:SetAnimationTimes(valuesTable);
    self:SetScript("OnUpdate", self.OnUpdate);
end

function RadialWheelButtonMixin:AnimateIntro()
    self:CleanupAnimations();

    local isAnimatingOutward = true;
    self:SetupForAnimation("Intro", self.Icon, isAnimatingOutward);

    self.IntroAnim:Restart();
end

function RadialWheelButtonMixin:AnimateOutro()
    self:CleanupAnimations();

    local isAnimatingOutward = false;
    self:SetupForAnimation("Outro", self.Icon, isAnimatingOutward);

    self.OutroAnim:Restart();
end

function RadialWheelButtonMixin:AnimateCooldownDone()
    self:CleanupAnimations();

    if not self.isSmall then
        local isAnimatingOutward = true;
        self:SetupForAnimation("CooldownDone", self.Text, isAnimatingOutward);
    end

    self.CooldownDoneAnim:Restart();
end

function RadialWheelButtonMixin:CleanupAnimations()
    self.IntroAnim:Stop();
    self.OutroAnim:Stop();
    self.CooldownDoneAnim:Stop();
    self.CooldownDoneAnim:OnFinished();

    self:StopAnimatingFrame();
end

function RadialWheelButtonMixin:SetSelected(state)
    self.isSelected = state;
    self:UpdateSelectedState();
end

function RadialWheelButtonMixin:UpdateSelectedState()
    local isSelectedAndEnabled = self.isSelected and self:GetEnabled();
    self.SelectedTexture:SetShown(isSelectedAndEnabled);

    if not self.ignoreScaleChangesOnSelect then
        self.Icon:SetScale(isSelectedAndEnabled and 1 or 0.9);
        self.Text:SetScale(isSelectedAndEnabled and 1 or 0.9);
    end
end

function RadialWheelButtonMixin:SetEnabled(enabled)
    self.enabled = enabled;
    self:UpdateSelectedState();
    self:UpdateIcon();
    self:UpdateTextShownState();
end

function RadialWheelButtonMixin:GetEnabled()
    if self.enabledOverride ~= nil then
        return self.enabledOverride;
    end
    return self.enabled;
end

function RadialWheelButtonMixin:SetIsSmall(isSmall)
    self.isSmall = isSmall;

    self:UpdateIcon();
    self:UpdateTextShownState();
end

function RadialWheelButtonMixin:SetIcon(iconAtlasName)
    self.iconAtlasName = iconAtlasName;
    self:UpdateIcon();
end

function RadialWheelButtonMixin:UpdateIcon()
    if not self.iconAtlasName then
        return;
    end

    local formattedAtlasName = self.iconAtlasName;
    formattedAtlasName = self:GetEnabled() and formattedAtlasName or RADIAL_FORMAT_DISABLED:format(formattedAtlasName);
    formattedAtlasName = FormatStringForSize(formattedAtlasName, self.isSmall);
    self.Icon:SetAtlas(formattedAtlasName, true);

    formattedAtlasName = self.iconAtlasName;
    formattedAtlasName = RADIAL_FORMAT_GLOW:format(formattedAtlasName);
    formattedAtlasName = FormatStringForSize(formattedAtlasName, self.isSmall);
    self.IconGlow:SetAtlas(formattedAtlasName, true);
end

function RadialWheelButtonMixin:SetText(text)
    self.Text:SetText(text);
end

function RadialWheelButtonMixin:UpdateTextShownState()
    self.Text:SetShown(not self.isSmall and self:GetEnabled());
end

RadialWheelButtonCooldownDoneAnimMixin = {};

function RadialWheelButtonCooldownDoneAnimMixin:OnPlay()
    self:GetParent().IconGlow:Show();
end

function RadialWheelButtonCooldownDoneAnimMixin:OnFinished()
    self:GetParent().IconGlow:Hide();
end

RadialWheelCooldownMixin = {};

function RadialWheelCooldownMixin:OnLoad()
    self.SetCooldownBase = self.SetCooldown;
    self.SetCooldown = self.SetCooldownOverride;
end

function RadialWheelCooldownMixin:OnShow()
    self.IntroAnim:Restart();
end

function RadialWheelCooldownMixin:SetCooldownOverride(startTimeSeconds, durationSeconds, ...)
    self.startTimeSeconds, self.durationSeconds = startTimeSeconds, durationSeconds;
    self:SetScript("OnUpdate", self.OnUpdate);
    self.EdgeFx:Show();

    self:SetCooldownBase(startTimeSeconds, durationSeconds, ...);
end

function RadialWheelCooldownMixin:OnUpdate()
    local nowSeconds = GetTime();
    local progressPercentage = Saturate((nowSeconds - self.startTimeSeconds) / self.durationSeconds);
    local rotationRadians = progressPercentage * TWO_PI;
    self.EdgeFx:SetRotation(-rotationRadians);
end

function RadialWheelCooldownMixin:OnCooldownDone()
    -- Force cooldown to show 100% and stick there
    -- Setting cooldown to 99.99% since setting it to 100 automatically "finishes" it and hides the cooldown
	self:Pause();
	self:SetCooldown(GetTime() - 99.99, 100);

    self.OutroAnim:Restart();
end

function RadialWheelCooldownMixin:OnOutroAnimFinished()
    self.startTimeSeconds, self.durationSeconds = nil, nil;
    self:SetScript("OnUpdate", nil);
    self.EdgeFx:Hide();

    local radialWheel = self:GetParent();
    radialWheel:OnCooldownDone();
end

RadialWheelCooldownOutroAnimMixin = {};

function RadialWheelCooldownOutroAnimMixin:OnFinished()
    local cooldown = self:GetParent();
    cooldown:OnOutroAnimFinished();
end