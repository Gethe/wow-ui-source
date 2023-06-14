FramerateFrameMixin = {};

function FramerateFrameMixin:OnLoad()
	-- Position is based on position of micro menu
	local position = MicroMenuContainer:GetPosition();
	MicroMenu:UpdateFramerateFrameAnchor(position);
end

function FramerateFrameMixin:OnUpdate(elapsed)
	local timeLeft = self.fpsTime - elapsed
	if timeLeft <= 0 then
		self.fpsTime = FRAMERATE_FREQUENCY;
		local framerate = GetFramerate();
		self.FramerateText:SetFormattedText("%.1f", framerate);
		self:Layout();
	else
		self.fpsTime = timeLeft;
	end
end

function FramerateFrameMixin:OnShow()
	self.fpsTime = 0;
end

function FramerateFrameMixin:Toggle()
	self:SetShown(not self:IsShown());
end

function FramerateFrameMixin:BeginBenchmark()
	self.benchmark = true;
	self:Show();
end

function FramerateFrameMixin:EndBenchmark()
	self.benchmark = nil;
	self:Hide();
end

function FramerateFrameMixin:GetMicroMenuRelativeAnchoring(microMenuPosition, isMenuHorizontal)
	if isMenuHorizontal then
		if microMenuPosition == MicroMenuPositionEnum.BottomLeft then
			return "BOTTOMLEFT", "BOTTOMRIGHT", 5, 0;
		elseif microMenuPosition == MicroMenuPositionEnum.BottomRight then
			return "BOTTOMRIGHT", "BOTTOMLEFT", -5, 0;
		elseif microMenuPosition == MicroMenuPositionEnum.TopLeft then
			return "TOPLEFT", "TOPRIGHT", 5, 0;
		elseif microMenuPosition == MicroMenuPositionEnum.TopRight then
			return "TOPRIGHT", "TOPLEFT", -5, 0;
		end
	else
		if microMenuPosition == MicroMenuPositionEnum.BottomLeft then
			return "BOTTOMLEFT", "TOPLEFT", 0, 5;
		elseif microMenuPosition == MicroMenuPositionEnum.BottomRight then
			return "BOTTOMRIGHT", "TOPRIGHT", 0, 5;
		elseif microMenuPosition == MicroMenuPositionEnum.TopLeft then
			return "TOPLEFT", "BOTTOMLEFT", 0, -5;
		else -- MicroMenuPositionEnum.TopRight
			return "TOPRIGHT", "BOTTOMRIGHT", 0, -5;
		end
	end
end

function FramerateFrameMixin:UpdatePosition(microMenuPosition, isMenuHorizontal)
	-- Position relative to micro menu's position to avoid going off screen
	local point, relativePoint, offsetX, offsetY = self:GetMicroMenuRelativeAnchoring(microMenuPosition, isMenuHorizontal);

	self:ClearAllPoints();
	self:SetPoint(point, MicroMenuContainer, relativePoint, offsetX, offsetY);
end