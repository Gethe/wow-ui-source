HousingBlueprintBaseFrameMixin = {};

function HousingBlueprintBaseFrameMixin:BaseOnLoad()
	self.HeaderText:SetText(self.headerText);
	self.CloseButton:SetScript("OnClick", function()
		self:HideSelf();
	end);
end

function HousingBlueprintBaseFrameMixin:BaseOnShow()
	EventRegistry:RegisterCallback("UI.AlternateTopLevelParentChanged", self.UpdateParent, self);
	EventRegistry:RegisterCallback("HousingBlueprint.FrameShown", self.OnOtherFrameShown, self);
end

function HousingBlueprintBaseFrameMixin:BaseOnHide()
	EventRegistry:UnregisterCallback("UI.AlternateTopLevelParentChanged", self);
	EventRegistry:UnregisterCallback("HousingBlueprint.FrameShown", self);
end

function HousingBlueprintBaseFrameMixin:OnOtherFrameShown(frame)
	if self.isExclusive and frame.isExclusive and frame ~= self then
		self:HideSelf();
	end
end

function HousingBlueprintBaseFrameMixin:UpdateParent()
	self:ShowSelf();
end

function HousingBlueprintBaseFrameMixin:IsOperationInProgress()
	-- Must be overriden
	assert(false);
end

function HousingBlueprintBaseFrameMixin:GetNonPanelAnchor()
	-- Optional override
	return "BOTTOM", nil, "CENTER", 0, 0;
end

function HousingBlueprintBaseFrameMixin:ShowSelf()
	if not self:IsShown() then
		EventRegistry:TriggerEvent("HousingBlueprint.FrameShown", self);
	end

	-- Extra handling required to support either showing as a normal UI Panel OR on top of the House Editor
	-- If we ever refactor how the entire "top level parent" handling works this should be able to be drastically simplified
	local topLevelParent = GetAppropriateTopLevelParent();
	self:SetParent(topLevelParent);
	if topLevelParent == UIParent then
		self:SetFullInputBlockerEnabled(false);
		ShowUIPanel(self);
	else
		self:SetFrameStrata("HIGH");
		self:ClearAllPoints();
		local point, relativeTo, relativePoint, x, y = self:GetNonPanelAnchor();
		self:SetPoint(point, relativeTo, relativePoint, x, y);
		-- If showing above some other context, use a fullscreen input blocker behind the dialog to avoid accidentally
		-- interacting with something in the background
		self:SetFullInputBlockerEnabled(true);
		self:Show();
	end
end

function HousingBlueprintBaseFrameMixin:HideSelf()
	self:SetFullInputBlockerEnabled(false);
	-- Extra handling required to support either showing as a normal UI Panel OR on top of the House Editor
	-- If we ever refactor how the entire "top level parent" handling works this should be able to be drastically simplified
	local topLevelParent = self:GetParent();
	if topLevelParent == UIParent then
		HideUIPanel(self);
	else
		self:ClearAllPoints();
		self:Hide();
	end
end

function HousingBlueprintBaseFrameMixin:SetFullInputBlockerEnabled(enabled)
	if enabled then
		local parent = self:GetParent();
		self.FullscreenInputBlocker:ClearAllPoints();
		self.FullscreenInputBlocker:SetPoint("TOPLEFT", parent);
		self.FullscreenInputBlocker:SetPoint("BOTTOMRIGHT", parent);
		self.FullscreenInputBlocker:Show();
	else
		self.FullscreenInputBlocker:ClearAllPoints();
		self.FullscreenInputBlocker:Hide();
	end
end

function HousingBlueprintBaseFrameMixin:TryHandleEscape()
	if not self:IsShown() then
		return false;
	end

	if not self.isWaitingForResult then
		self:HideSelf();
	end
	return true;
end
