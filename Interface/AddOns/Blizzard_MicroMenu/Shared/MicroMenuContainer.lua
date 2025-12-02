
MicroMenuPositionEnum = {
	BottomLeft = 1;
	BottomRight = 2;
	TopLeft = 3;
	TopRight = 4;
};

MicroMenuContainerMixin = {};

function MicroMenuContainerMixin:OnLoad()
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
end

function MicroMenuContainerMixin:OnEvent(event, ...)
	if ( event == "PLAYER_LEVEL_UP" or event == "TRIAL_STATUS_UPDATE" ) then
		UpdateMicroButtons();
	end
end

-- Manually wrote a layout method since we want to resize even around hidden frames
-- Also some custom logic for when the micro menu isn't parented to the container
function MicroMenuContainerMixin:Layout()
	local isHorizontal = not MicroMenu or MicroMenu.isHorizontal;

	local width, height = 0, 0;
	local function AddFrameSize(frame, includeOffset)
		local frameScale = frame:GetScale();

		if isHorizontal then
			width = width + frame:GetWidth() * frameScale;
			if includeOffset then
				local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint(1);
				width = width + math.abs(offsetX * frameScale);
			end

			height = math.max(height, frame:GetHeight() * frameScale);
		else
			width = math.max(width, frame:GetWidth() * frameScale);

			height = height + frame:GetHeight() * frameScale;
			if includeOffset then
				local point, relativeTo, relativePoint, offsetX, offsetY = frame:GetPoint(1);
				height = height + math.abs(offsetY * frameScale);
			end
		end
	end

	if MicroMenu then
		if MicroMenu:GetParent() ~= self then
			-- Don't update size if micro menu parented to container
			-- This is a temporary override and we don't want to resize while the menu is gone
			return;
		end

		MicroMenu:Layout();
		AddFrameSize(MicroMenu);
	end

	if QueueStatusButton then
		local includeOffsetYes = true;
		AddFrameSize(QueueStatusButton, includeOffsetYes);
	end

	self:SetSize(math.max(width, 1), math.max(height, 1));
end

function MicroMenuContainerMixin:GetPosition()
	local centerX, centerY = self:GetCenter();
	local halfScreenWidth = UIParent:GetWidth() / 2;
	local halfScreenHeight = UIParent:GetHeight() / 2;

	if centerY < halfScreenHeight then
		if centerX < halfScreenWidth then
			return MicroMenuPositionEnum.BottomLeft;
		else
			return MicroMenuPositionEnum.BottomRight;
		end
	else
		if centerX < halfScreenWidth then
			return MicroMenuPositionEnum.TopLeft;
		else
			return MicroMenuPositionEnum.TopRight;
		end
	end
end

MicroMenuMixin = {};

function MicroMenuMixin:OnLoad()
	self:InitializeButtons();
	self:SetNormalScale(1);
end

function MicroMenuMixin:GenerateButtonInfos()
	-- Override function.
end

function MicroMenuMixin:InitializeButtons()
	-- Button, plus GameRule that controls whether it is shown.
	local buttonInfos = self:GenerateButtonInfos();

	local function ShouldButtonBeAdded(buttonInfo)
		if buttonInfo.gameRule then
			if C_GameRules.IsGameRuleActive(buttonInfo.gameRule) then
				return false;
			end
		end

		if buttonInfo.callback then
			if buttonInfo.callback() then
				return false;
			end
		end

		return true;
	end

	for i, buttonInfo in ipairs(buttonInfos) do
		if ShouldButtonBeAdded(buttonInfo) then
			self:AddButton(buttonInfo.button);
		end
	end
end

function MicroMenuMixin:AddButton(button)
	self.numButtons = (self.numButtons or 0) + 1;
	button.layoutIndex = self.numButtons;
	button:SetParent(self);
	self.stride = self.isStacked and math.floor(self.numButtons / 2) or self.numButtons;
	self:MarkDirty();
end

-- Gets the button on the the extreme edge of the micro menu based on the inputs and the orientation of the bar
function MicroMenuMixin:GetEdgeButton(rightMost, topMost)
	local firstButton = nil;
	local lastButton = nil;
	for _, child in ipairs({self:GetChildren()}) do
		if child.layoutIndex then
			if not firstButton or (child.layoutIndex < firstButton.layoutIndex) then
				firstButton = child;
			end
			if not lastButton or (child.layoutIndex > lastButton.layoutIndex) then
				lastButton = child;
			end
		end
	end

	if not firstButton then
		return nil;
	end

	local firstButtonX, firstButtonY = firstButton:GetCenter();
	local lastButtonX, lastButtonY = lastButton:GetCenter();

	if self.isHorizontal then
		if rightMost then
			return firstButtonX > lastButtonX and firstButton or lastButton;
		else -- leftMost
			return firstButtonX < lastButtonX and firstButton or lastButton;
		end
	else
		if topMost then
			return firstButtonY > lastButtonY and firstButton or lastButton;
		else -- bottomMost
			return firstButtonY < lastButtonY and firstButton or lastButton;
		end
	end
end

function MicroMenuMixin:UpdateHelpTicketButtonAnchor(position)
	if not HelpOpenWebTicketButton then
		return;
	end

	-- Update help button anchor so it stays on screen
	local isOnBottomSideOfScreen, isOnLeftSideOfScreen;
	if position == MicroMenuPositionEnum.BottomLeft then
		isOnBottomSideOfScreen, isOnLeftSideOfScreen = true, true;
	elseif position == MicroMenuPositionEnum.BottomRight then
		isOnBottomSideOfScreen, isOnLeftSideOfScreen = true, false;
	elseif position == MicroMenuPositionEnum.TopLeft then
		isOnBottomSideOfScreen, isOnLeftSideOfScreen = false, true;
	elseif position == MicroMenuPositionEnum.TopRight then
		isOnBottomSideOfScreen, isOnLeftSideOfScreen = false, false;
	end

	local relativeTo = self:GetEdgeButton(isOnLeftSideOfScreen, isOnBottomSideOfScreen);
	local offsetY = isOnBottomSideOfScreen and 25 or -25;
	HelpOpenWebTicketButton:SetPoint("CENTER", relativeTo, "CENTER", 0, offsetY);
end

function MicroMenuMixin:UpdateQueueStatusAnchors(position)
	if QueueStatusButton then
		QueueStatusButton:UpdatePosition(position, self.isHorizontal);
	end

	if QueueStatusFrame then
		QueueStatusFrame:UpdatePosition(position, self.isHorizontal);
	end
end

function MicroMenuMixin:UpdateFramerateFrameAnchor(position)
	if not FramerateFrame then
		return;
	end

	FramerateFrame:UpdatePosition(position, self.isHorizontal);
end

function MicroMenuMixin:AnchorToMenuContainer(position)
	if self:GetParent() ~= MicroMenuContainer then
		-- If micro menu isn't parented to the default container then don't do anything
		-- It is temporarily being overridden to be positioned somewhere else
		return;
	end

	local point;
	if position == MicroMenuPositionEnum.BottomLeft then
		point = "BOTTOMLEFT";
	elseif position == MicroMenuPositionEnum.BottomRight then
		point = "BOTTOMRIGHT";
	elseif position == MicroMenuPositionEnum.TopLeft then
		point = "TOPLEFT";
	elseif position == MicroMenuPositionEnum.TopRight then
		point = "TOPRIGHT";
	end
	self:ClearAllPoints();
	self:SetPoint(point, MicroMenuContainer, point, 0, 0);
end

function MicroMenuMixin:SetQueueStatusScale(scale)
	if QueueStatusButton then
		QueueStatusButton:SetScale(scale);
	end

	self:UpdateQueueStatusAnchors(MicroMenuContainer:GetPosition());
end

function MicroMenuMixin:Layout()
	GridLayoutFrameMixin.Layout(self);

	local position = MicroMenuContainer:GetPosition();
	self:AnchorToMenuContainer(position);
	self:UpdateQueueStatusAnchors(position);
	self:UpdateFramerateFrameAnchor(position);
	self:UpdateHelpTicketButtonAnchor(position);
end

function MicroMenuMixin:UpdateScale()
	local useScale = self.overrideScale or self.normalScale;
	local featureScale = C_GameRules.GetGameRuleAsFloat(Enum.GameRule.MicrobarScale);
	if featureScale ~= 0 then
		self:SetScale(useScale * featureScale);
	else
		self:SetScale(useScale);
	end
end

function MicroMenuMixin:SetNormalScale(scale)
	self.normalScale = scale;
	self:UpdateScale();
end

function MicroMenuMixin:SetOverrideScale(overrideScale)
	self.overrideScale = overrideScale;
	self:UpdateScale();
end

function MicroMenuMixin:ClearOverrideScale()
	self:SetOverrideScale(nil);
end

--Positioning and visual states
function MicroMenuMixin:ResetMicroMenuPosition()
	self:SetParent(MicroMenuContainer);
	self.stride = self.numButtons;

	self:ClearOverrideScale();

	local forceFullUpdate = true;
	EditModeManagerFrame:UpdateSystem(MicroMenuContainer, forceFullUpdate);

	UpdateMicroButtons();
end

function MicroMenuMixin:OverrideMicroMenuPosition(parent, anchor, anchorTo, relAnchor, x, y, isStacked)
	self:SetOverrideScale(0.85);
	self:SetParent(parent);

	self.isStacked = isStacked;
	self.stride = (isStacked and self.numButtons / 2 or self.numButtons);
	self.isHorizontal = true;
	self.layoutFramesGoingRight = true;
	self.layoutFramesGoingUp = false;
	self:Layout();

	self:ClearAllPoints();
	self:SetPoint(anchor, anchorTo, relAnchor, x, y);

	UpdateMicroButtons();
end
