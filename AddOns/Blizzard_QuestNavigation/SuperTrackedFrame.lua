SuperTrackedFrameMixin = {};

function SuperTrackedFrameMixin:OnLoad()
	self:RegisterEvent("NAVIGATION_FRAME_CREATED");
	self.isShown = false;
end

function SuperTrackedFrameMixin:OnEvent(event, ...)
	if event == "NAVIGATION_FRAME_CREATED" then
		self:AnchorToNavigationFrame();
	end
end

function SuperTrackedFrameMixin:OnUpdate()
	self:CheckAnchorToNavigationFrame(false);

	if self.navFrame then
		local distanceToQuest = C_Navigation.GetDistance();
		local clamped = C_Navigation.WasClampedToScreen();
		self:UpdateArrow(clamped);

		self.DistanceText:SetText(IN_GAME_NAVIGATION_RANGE:format(Round(distanceToQuest)));
		self.navFrame:SetAlpha(self:GetTargetAlpha());
	end
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
		local centerX, centerY = self.navFrame:GetCenter();
		local mouseToNavVec = CreateVector2D(mouseX - centerX, mouseY - centerY);
		local mouseToNavDistanceSq = mouseToNavVec:GetLengthSquared();
		local additionalFade = ClampedPercentageBetween(mouseToNavDistanceSq, 0, self.navFrameRadiusSq * 2);

		return FrameDeltaLerp(self.navFrame:GetAlpha(), GetTargetAlpha() * additionalFade, 0.1);
	end

	function SuperTrackedFrameMixin:SetTargetAlphaForState(state, alpha)
		navStateToTargetAlpha[state] = alpha;
	end
end

do
	local UP_VECTOR = CreateVector2D(0, 1);

	function SuperTrackedFrameMixin:UpdateArrow(isClamped)
		if isClamped then
			local centerScreenX, centerScreenY = WorldFrame:GetCenter();
			local indicatorX, indicatorY = self:GetCenter();
			local indicatorVec = CreateVector2D(indicatorX - centerScreenX, indicatorY - centerScreenY);

			local angle = Vector2D_CalculateAngleBetween(indicatorVec.x, indicatorVec.y, UP_VECTOR.x, UP_VECTOR.y);
			self.Arrow:SetRotation(-angle);

			local toArrowX, toArrowY = Vector2D_Normalize(indicatorVec.x, indicatorVec.y);
			self.Arrow:SetPoint("CENTER", self, "CENTER", toArrowX * self.navFrameRadius, toArrowY * self.navFrameRadius);
		end

		self.Arrow:SetShown(isClamped);
	end
end

function SuperTrackedFrameMixin:AnchorToNavigationFrame()
	self.navFrame = C_Navigation.GetFrame();
	self:SetShown(self.navFrame ~= nil);

	if self.navFrame then
		self:ClearAllPoints();
		self:SetParent(self.navFrame);
		self:SetPoint("CENTER", self.navFrame, "CENTER");

		local frameSize = math.max(self.Icon:GetSize());
		self.navFrame:SetSize(frameSize, frameSize);
		self.navFrameRadius = frameSize;
		self.navFrameRadiusSq = self.navFrameRadius * self.navFrameRadius;
	end
end

function SuperTrackedFrameMixin:CheckAnchorToNavigationFrame()
	if not self.navFrame then
		self:AnchorToNavigationFrame();
	end
end