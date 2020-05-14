SuperTrackedFrameMixin = {};

function SuperTrackedFrameMixin:OnLoad()
	self:RegisterEvent("NAVIGATION_FRAME_CREATED");
	self:RegisterEvent("NAVIGATION_FRAME_DESTROYED");
end

function SuperTrackedFrameMixin:OnEvent(event, ...)
	if event == "NAVIGATION_FRAME_CREATED" then
		self:InitializeNavigationFrame();
	elseif event == "NAVIGATION_FRAME_DESTROYED" then
		self:ShutdownNavigationFrame();
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

	local function GetTargetAlpha()
		local state = C_Navigation.GetTargetState();
		return navStateToTargetAlpha[state];
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

		return FrameDeltaLerp(self:GetAlpha(), GetTargetAlpha() * additionalFade, 0.1);
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
		local v = CreateVector2D(navX - centerX, navY - centerY);
		local angle = Vector2D_CalculateAngleBetween(v.x, v.y, RIGHT_VECTOR.x, RIGHT_VECTOR.y);
		local x = self.majorAxis * math.cos(angle);
		local y = self.minorAxis * math.sin(angle);

		self:SetPoint("CENTER", WorldFrame, "CENTER", x, -y);
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

function SuperTrackedFrameMixin:InitializeNavigationFrame()
	assert(self.navFrame == nil);
	self.navFrame = C_Navigation.GetFrame();
	self:SetShown(self.navFrame ~= nil);

	if self.navFrame then
		self:SetPoint("CENTER", self.navFrame);
		self:UpdateIconSize();

		-- Experimental clamping modes, pick one and erase the other
		self.clampMode = 1;

		-- Circular
		self.clampRadius = 350;

		-- Elliptical
		self.majorAxis = 500;
		self.minorAxis = 200;
	end
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