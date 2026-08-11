CooldownViewerEditAlertBaseMixin = {};

function CooldownViewerEditAlertBaseMixin:GetIcon()
	return self.Icon;
end

function CooldownViewerEditAlertBaseMixin:GetNameLabel()
	return self.Name;
end

function CooldownViewerEditAlertBaseMixin:GetAddButton()
	return self.AddButton;
end

function CooldownViewerEditAlertBaseMixin:OnLoad()
	self:GetAddButton():SetScript("OnClick", function()
		self:AddCurrentAlert();
		self:Hide();
	end);
end

function CooldownViewerEditAlertBaseMixin:SetOwner(owner)
	self.owner = owner;
	self:SetParent(owner);
	self:SetPoint("TOPLEFT", owner, "TOPRIGHT", owner:GetExtraPanelWidth(), 0);
end

function CooldownViewerEditAlertBaseMixin:OnShow()
	SetUIPanelAttribute(self.owner, "extraWidth", self:GetWidth() + (2 * self.owner:GetExtraPanelWidth()));
	UpdateUIPanelPositions(self.owner);
end

function CooldownViewerEditAlertBaseMixin:OnHide()
	SetUIPanelAttribute(self.owner, "extraWidth", self.owner:GetExtraPanelWidth());
	UpdateUIPanelPositions(self.owner);
end

function CooldownViewerEditAlertBaseMixin:Display(isNewAlert)
	self:UpdateAddButton(isNewAlert);
	self:Show();
end

function CooldownViewerEditAlertBaseMixin:UpdateAddButton(isNewAlert)
	self:GetAddButton():SetText(isNewAlert and COOLDOWN_VIEWER_SETTINGS_ALERT_MENU_BUTTON_ADD_ALERT or COOLDOWN_VIEWER_SETTINGS_ALERT_MENU_BUTTON_EDIT_EXISTING_ALERT);
end

function CooldownViewerEditAlertBaseMixin:AddCurrentAlert()
	assertsafe(false, "Override in derived mixin.");
end
