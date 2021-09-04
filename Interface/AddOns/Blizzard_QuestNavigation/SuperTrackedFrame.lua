SuperTrackedFrameMixin = {};

function SuperTrackedFrameMixin:OnLoad()
	self:RegisterEvent("NAVIGATION_FRAME_CREATED");
	self:RegisterEvent("NAVIGATION_FRAME_DESTROYED");
	self:RegisterEvent("SUPER_TRACKING_CHANGED");
end

function SuperTrackedFrameMixin:OnEvent(event, ...)
	if event == "NAVIGATION_FRAME_CREATED" then
		self:InitializeNavigationFrame();
	elseif event == "NAVIGATION_FRAME_DESTROYED" then
		self:ShutdownNavigationFrame();
	elseif event == "SUPER_TRACKING_CHANGED" then
		self:UpdateIcon();
	end
end

function SuperTrackedFrameMixin:OnUpdate()
	self:CheckInitializeNavigationFrame(false);

	if self.navFrame then
		self:UpdateClampedState();
		self:UpdatePosition();
		self:UpdateArrow();
		self:UpdateDistanceText();
		self:UpdateAlpha();
	end
end

function SuperTrackedFrameMixin:UpdateClampedState()
	local clamped = C_Navigation.WasClampedToScreen();
	self.clampedChanged = clamped ~= self.isClamped;
	self.isClamped = clamped;

	if self.clampedChanged then
		self:PingNavFrame();
	end
end

function SuperTrackedFrameMixin:PingNavFrame()
	-- Disabled for now
	-- UIFrameFlash(self, 	fadeInTime,	fadeOutTime,	flashDuration, 	showWhenDone, 	flashInHoldTime, 	flashOutHoldTime, 	syncId)
	-- UIFrameFlash(self.Icon, 		.5,	.5,				2, 				true, 			0, 					0, 					nil);
end

do
	local navStateToTargetAlpha =
	{
		[Enum.NavigationState.Invalid] = 0.0,
		[Enum.NavigationState.Occluded] = 0.6,
		[Enum.NavigationState.InRange] = 1.0,
	};

	function SuperTrackedFrameMixin:GetTargetAlphaBaseValue()
		local state = C_Navigation.GetTargetState();
		local alpha = navStateToTargetAlpha[state];
		if alpha and alpha > 0 then
			if self.isClamped then
				return 1; -- Just to make the indicator easier to see
			end
		end

		return alpha;
	end

	function SuperTrackedFrameMixin:GetTargetAlpha()
		if not C_Navigation.HasValidScreenPosition() then
			return 0;
		end

		local mouseX, mouseY = GetCursorPosition();
		local scale = UIParent:GetEffectiveScale();
		mouseX = mouseX / scale
		mouseY = mouseY / scale;
		local centerX, centerY = self:GetCenter();
		local mouseToNavVec = CreateVector2D(mouseX - centerX, mouseY - centerY);
		local mouseToNavDistanceSq = mouseToNavVec:GetLengthSquared();
		local additionalFade = ClampedPercentageBetween(mouseToNavDistanceSq, 0, self.navFrameRadiusSq * 2);

		return FrameDeltaLerp(self:GetAlpha(), self:GetTargetAlphaBaseValue() * additionalFade, 0.1);
	end

	function SuperTrackedFrameMixin:SetTargetAlphaForState(state, alpha)
		navStateToTargetAlpha[state] = alpha;
	end

	function SuperTrackedFrameMixin:UpdateAlpha()
		self:SetAlpha(self:GetTargetAlpha());
	end
end

do
	local UP_VECTOR = CreateVector2D(0, 1);
	local RIGHT_VECTOR = CreateVector2D(1, 0);

	local function GetCenterScreenPoint()
		local centerX, centerY = WorldFrame:GetCenter();
		local scale = UIParent:GetEffectiveScale() or 1;
		return centerX / scale, centerY / scale;
	end

	function SuperTrackedFrameMixin:UpdateArrow()
		if self.isClamped then
			local centerScreenX, centerScreenY = GetCenterScreenPoint();
			local indicatorX, indicatorY = self:GetCenter();
			local indicatorVec = CreateVector2D(indicatorX - centerScreenX, indicatorY - centerScreenY);

			local angle = Vector2D_CalculateAngleBetween(indicatorVec.x, indicatorVec.y, UP_VECTOR.x, UP_VECTOR.y);
			self.Arrow:SetRotation(-angle);

			local toArrowX, toArrowY = Vector2D_Normalize(indicatorVec.x, indicatorVec.y);
			self.Arrow:SetPoint("CENTER", self, "CENTER", toArrowX * self.navFrameRadius, toArrowY * self.navFrameRadius);
		end

		self.Arrow:SetShown(self.isClamped);
	end

	function SuperTrackedFrameMixin:ClampCircular()
		local centerX, centerY = GetCenterScreenPoint();
		local navX, navY = self.navFrame:GetCenter();
		local v = CreateVector2D(navX - centerX, navY - centerY);
		v:Normalize();
		v:ScaleBy(self.clampRadius);
		self:SetPoint("CENTER", WorldFrame, "CENTER", v.x, v.y);
	end

	function SuperTrackedFrameMixin:ClampElliptical()
		local centerX, centerY = GetCenterScreenPoint();
		local navX, navY = self.navFrame:GetCenter();

		-- This is the point we want to find the intersection, translated to origin
		local pX = navX - centerX;
		local pY = navY - centerY;
		local denominator = math.sqrt(self.majorAxisSquared * pY * pY + self.minorAxisSquared * pX * pX);

		if denominator ~= 0 then
			local ratio = self.axesMultiplied / denominator;
			local intersectionX = pX * ratio;
			local intersectionY = pY * ratio;

			self:SetPoint("CENTER", WorldFrame, "CENTER", intersectionX, intersectionY);
		end
	end

	function SuperTrackedFrameMixin:UpdatePosition()
		if self.isClamped or self.clampedChanged then
			self:ClearAllPoints();

			if self.isClamped then
				if self.clampMode == 0 then
					self:ClampCircular();
				else
					self:ClampElliptical();
				end
			else
				self:SetPoint("CENTER", self.navFrame, "CENTER");
			end
		end
	end
end

function SuperTrackedFrameMixin:UpdateDistanceText()
	if not self.isClamped then
		local distance = C_Navigation.GetDistance();
		self.DistanceText:SetText(IN_GAME_NAVIGATION_RANGE:format(Round(distance)));
	end

	self.DistanceText:SetShown(not self.isClamped);
end

function SuperTrackedFrameMixin:UpdateIconSize()
	self.navFrameRadius = math.max(self.Icon:GetSize());
	self.navFrameRadiusSq = self.navFrameRadius * self.navFrameRadius;
end

local iconLookup = {
	[Enum.SuperTrackingType.Quest] = "Navigation-Tracked-Icon",
	[Enum.SuperTrackingType.UserWaypoint] = "Waypoint-MapPin-Tracked",
	[Enum.SuperTrackingType.Corpse] = "Navigation-Tombstone-Icon",
};

function SuperTrackedFrameMixin:UpdateIcon()
	local superTrackingType = C_SuperTrack.GetHighestPrioritySuperTrackingType() or Enum.SuperTrackingType.Quest;
	local atlas = iconLookup[superTrackingType] or "Navigation-Tracked-Icon";
	self.Icon:SetAtlas(atlas, true);
	self:UpdateIconSize();
end

function SuperTrackedFrameMixin:InitializeNavigationFrame()
	assert(self.navFrame == nil);
	self.navFrame = C_Navigation.GetFrame();
	self:SetShown(self.navFrame ~= nil);

	if self.navFrame then
		self:SetPoint("CENTER", self.navFrame);
		self:UpdateIcon();

		-- Experimental clamping modes, pick one and erase the other
		self.clampMode = 1;

		-- Circular
		self.clampRadius = 350;

		-- Elliptical
		self:SetEllipticalRadii(500, 200);
	end
end

function SuperTrackedFrameMixin:SetEllipticalRadii(major, minor)
	self.majorAxis = major;
	self.minorAxis = minor;
	self.majorAxisSquared = self.majorAxis * self.majorAxis;
	self.minorAxisSquared = self.minorAxis * self.minorAxis;
	self.axesMultiplied = self.majorAxis * self.minorAxis;
end

function SuperTrackedFrameMixin:CheckInitializeNavigationFrame()
	if not self.navFrame then
		self:InitializeNavigationFrame();
	end
end

function SuperTrackedFrameMixin:ShutdownNavigationFrame()
	self:ClearAllPoints();
	self.navFrame = nil;
end