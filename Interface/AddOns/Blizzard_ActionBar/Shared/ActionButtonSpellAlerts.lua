ActionButtonSpellAlertManager = {
	activeAlerts = { };		-- tracks which buttons have alerts
	SpellAlertType = EnumUtil.MakeEnum(
		"Default",
		"AssistedCombatRotation"
	);
};

local self = ActionButtonSpellAlertManager;

local function GetAlertFrame(actionButton, create)
	local alertType = self.activeAlerts[actionButton];
	local frame;
	if alertType == self.SpellAlertType.Default then
		frame = actionButton.SpellActivationAlert;
		if not frame and create then
			frame = CreateFrame("Frame", nil, actionButton, "ActionButtonSpellAlertTemplate");
			actionButton.SpellActivationAlert = frame;
			local frameWidth, frameHeight = actionButton:GetSize();
			actionButton.SpellActivationAlert:SetSize(frameWidth * 1.4, frameHeight * 1.4);
			actionButton.SpellActivationAlert:SetPoint("CENTER", actionButton, "CENTER", 0, 0);		
		end
	elseif alertType == self.SpellAlertType.AssistedCombatRotation then
		local assistedCombatRotationFrame = actionButton.AssistedCombatRotationFrame;
		frame = assistedCombatRotationFrame.SpellActivationAlert;
		if not frame and create then
			frame = CreateFrame("Frame", nil, assistedCombatRotationFrame, "ActionButtonSpellAlertTemplate");
			assistedCombatRotationFrame.SpellActivationAlert = frame;
			frame:SetAllPoints();
			-- replace textures
			frame.ProcStartFlipbook:SetAtlas("OneButton_ProcStart_Flipbook");
			frame.ProcLoopFlipbook:SetAtlas("OneButton_ProcLoop_Flipbook");
		end
	end
	return frame;
end

-- Spell alerts for buttons on normal action bars should use the altGlow instead if any
-- action bar has an AssistedCombatRotation action, as players should be focusing on that.
-- The alert for an AssistedCombatRotation action button still uses the regular anim.
local function CheckAndSetArtStyle(actionButton)
	local alertType = self.activeAlerts[actionButton];
	if alertType == self.SpellAlertType.AssistedCombatRotation then
		return;
	end

	if not actionButton.bar or not actionButton.bar.isNormalBar then
		return;
	end

	local alertFrame = GetAlertFrame(actionButton);
	if not alertFrame then
		assertsafe(false, "Missing spell alert frame for %s", actionButton:GetDebugName());
		return;
	end

	if AssistedCombatManager:ShouldDowngradeSpellAlertForButton(actionButton) then
		alertFrame.ProcStartFlipbook:Hide();
		alertFrame.ProcLoopFlipbook:Hide();
		alertFrame.ProcAltGlow:Show();
	else
		alertFrame.ProcStartFlipbook:Show();
		alertFrame.ProcLoopFlipbook:Show();
		alertFrame.ProcAltGlow:Hide();
	end
end

local function HideAlert(actionButton)
	local alertFrame = GetAlertFrame(actionButton);
	if not alertFrame then
		assertsafe(false, "Missing spell alert frame for %s", actionButton:GetDebugName());
		return;
	end

	alertFrame:Hide();
	alertFrame.ProcStartAnim:Stop();
	self.activeAlerts[actionButton] = nil;
end

local function ShowAlert(actionButton, alertType)
	-- if there is an alert already, it must be a different type so hide it
	if self.activeAlerts[actionButton] then
		HideAlert(actionButton);
	end

	self.activeAlerts[actionButton] = alertType;
	local create = true;
	local alertFrame = GetAlertFrame(actionButton, create);
	alertFrame:Show();
	CheckAndSetArtStyle(actionButton);
	alertFrame.ProcStartAnim:Play();
end

do
	local function RefreshArtStyles()
		self.useAltGlow = C_ActionBar.HasAssistedCombatActionButtons();
		for actionButton, alertType in pairs(self.activeAlerts) do
			CheckAndSetArtStyle(actionButton);
		end
	end
	EventRegistry:RegisterCallback("ActionButton.OnAssistedCombatRotationFrameChanged", RefreshArtStyles);
	EventRegistry:RegisterCallback("AssistedCombatManager.OnAssistedHighlightSpellChange", RefreshArtStyles);
	EventRegistry:RegisterCallback("AssistedCombatManager.OnSetUseAssistedHighlight", RefreshArtStyles);
	EventRegistry:RegisterCallback("AssistedCombatManager.RotationSpellsUpdated", RefreshArtStyles);
end

-- public functions

function ActionButtonSpellAlertManager:ShowAlert(actionButton)
	local currentAlertType = self.activeAlerts[actionButton];
	local alertType = self.SpellAlertType.Default;
	if actionButton.action and C_ActionBar.IsAssistedCombatAction(actionButton.action) then
		alertType = self.SpellAlertType.AssistedCombatRotation;
	end
	if currentAlertType ~= alertType then
		ShowAlert(actionButton, alertType);
	end
end

function ActionButtonSpellAlertManager:HideAlert(actionButton)
	local currentAlertType = self.activeAlerts[actionButton];
	if currentAlertType then
		HideAlert(actionButton, alertType);
	end
end

function ActionButtonSpellAlertManager:HasAlert(actionButton)
	local alertType = self.activeAlerts[actionButton];
	local hasAlert = not not alertType;
	return hasAlert, alertType;
end

ActionButtonSpellAlertMixin = {};

function ActionButtonSpellAlertMixin:OnLoad()
	self.ProcStartAnim:SetScript("OnFinished", function()
		self.ProcLoop:Play();
	end);
end

function ActionButtonSpellAlertMixin:OnHide()
	if self.ProcLoop:IsPlaying() then
		self.ProcLoop:Stop();
	end
end
