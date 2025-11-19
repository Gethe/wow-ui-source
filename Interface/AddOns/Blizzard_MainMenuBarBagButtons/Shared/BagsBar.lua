
BagsBarMixin = {};

function BagsBarMixin:OnLoad()
	self.initialHeight = self:GetHeight(); -- "Short axis" length. Store this off for layout later.

	self.bagBarExpandToggleInitialWidth = self.hideExpandToggle and 0 or BagBarExpandToggle:GetWidth();
	self.bagBarExpandToggleInitialHeight = self.hideExpandToggle and 0 or BagBarExpandToggle:GetHeight();

	local bagsUIDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.BagsUIDisabled);
	if bagsUIDisabled then
		self:Hide();
		return;
	end

	EventUtil.ContinueOnVariablesLoaded(GenerateClosure(self.Layout, self));
	EventRegistry:RegisterCallback("MainMenuBarManager.OnExpandChanged", self.Layout, self);
end

function BagsBarMixin:GetBagButtonAnchorPoints()
	-- Returns Point, RelativePoint, xOffset, yOffset
	local padding = self.bagPadding or 0;

	if self:IsHorizontal() then
		if self:IsDirectionLeft() then
			return "RIGHT", "LEFT", -padding, 0;
		else
			return "LEFT", "RIGHT", padding, 0;
		end
	else
		if self:IsDirectionUp() then
			return "BOTTOM", "TOP", 0, padding;
		else
			return "TOP", "BOTTOM", 0, -padding;
		end
	end
end

function BagsBarMixin:GetBagBarLength()
	-- Measure the total length of the long axis of the bags bar. (Width if we're horizontal, height if we're vertical.)

	local isHorizontal = self:IsHorizontal();
	local totalLength = 0;

	for i, bagButton in MainMenuBarBagManager:EnumerateBagButtons() do
		if (isHorizontal) then
			totalLength = totalLength + bagButton:GetWidth();
		else
			totalLength = totalLength + bagButton:GetHeight();
		end

		if (i ~= 1) then
			totalLength = totalLength + (self.bagPadding or 0);
		end
	end

	-- Also include BagBarExpandToggle.
	if (not self.hideExpandToggle) then
		if (isHorizontal) then
			totalLength = totalLength + self.bagBarExpandToggleInitialWidth;
		else
			totalLength = totalLength + self.bagBarExpandToggleInitialHeight;
		end
	end

	return totalLength;
end

function BagsBarMixin:Layout()
	local isHorizontal = self:IsHorizontal();

	-- If any of our buttons care about orientation (e.g., Classic Keyring), make sure they're synced with us.
	for i, bagButton in MainMenuBarBagManager:EnumerateBagButtons() do
		if (bagButton.UpdateOrientation) then
			bagButton:UpdateOrientation(isHorizontal);
		end
	end

	-- Set bar and toggle button size based on orientation
	local longAxisLength = self:GetBagBarLength();
	if isHorizontal then
		self:SetSize(longAxisLength, self.initialHeight);
	else
		-- Swap width/height for vertical bags bar since the bar is horizontal by default
		self:SetSize(self.initialHeight, longAxisLength);
	end

	-- Get new bag anchor points
	local point, relativePoint, xOffset, yOffset = self:GetBagButtonAnchorPoints();

	-- Setup backpack button anchor
	MainMenuBarBackpackButton:ClearAllPoints();
	MainMenuBarBackpackButton:SetPoint(point, self, point);

	if (not self.hideExpandToggle) then
		if isHorizontal then
			BagBarExpandToggle:SetSize(self.bagBarExpandToggleInitialWidth, self.bagBarExpandToggleInitialHeight);
		else
			-- Swap width/height for vertical bags bar since the bar is horizontal by default
			BagBarExpandToggle:SetSize(self.bagBarExpandToggleInitialHeight, self.bagBarExpandToggleInitialWidth);
		end

		-- Update expand button
		BagBarExpandToggle:UpdateOrientation();
		BagBarExpandToggle:ClearAllPoints();
		BagBarExpandToggle:SetPoint(point, MainMenuBarBackpackButton, relativePoint);
	end

	-- Update other bag button anchors
	local anchorRelativeTo = self.hideExpandToggle and MainMenuBarBackpackButton or BagBarExpandToggle;
	for i, bagButton in MainMenuBarBagManager:EnumerateBagButtons() do
		if bagButton:IsShown() and bagButton ~= MainMenuBarBackpackButton then
			bagButton:ClearAllPoints();
			bagButton:SetPoint(point, anchorRelativeTo, relativePoint, xOffset, yOffset);
			anchorRelativeTo = bagButton;
		end
	end
end

function BagsBarMixin:IsHorizontal()
	return self.isHorizontal;
end

function BagsBarMixin:IsDirectionLeft()
	return self:IsHorizontal() and self.direction == Enum.BagsDirection.Left;
end

function BagsBarMixin:IsDirectionUp()
	return not self:IsHorizontal() and self.direction == Enum.BagsDirection.Up;
end
