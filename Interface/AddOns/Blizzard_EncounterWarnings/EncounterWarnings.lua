EncounterWarningsSystemDynamicEvents = {
	"ENCOUNTER_WARNING",
};

EncounterWarningsSystemFrameMixin = CreateFromMixins(EditModeEncounterEventsSystemMixin, ResizeLayoutMixin);

function EncounterWarningsSystemFrameMixin:OnLoad()
	EditModeEncounterEventsSystemMixin.OnSystemLoad(self);

	self:RegisterEvent("CLEAR_BOSS_EMOTES");
	self:RegisterEvent("PLAYER_IN_COMBAT_CHANGED");

	for _, cvarName in ipairs(EncounterWarningsVisibilityCVars) do
		CVarCallbackRegistry:SetCVarCachable(cvarName);
		CVarCallbackRegistry:RegisterCallback(cvarName, function() self:UpdateVisibility(); end, self);
	end
end

function EncounterWarningsSystemFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, EncounterWarningsSystemDynamicEvents);
	ResizeLayoutMixin.OnShow(self);
end

function EncounterWarningsSystemFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, EncounterWarningsSystemDynamicEvents);
end

function EncounterWarningsSystemFrameMixin:OnEvent(event, ...)
	if event == "ENCOUNTER_WARNING" then
		local encounterWarningInfo = ...;
		self:OnEncounterWarning(encounterWarningInfo);
	elseif event == "CLEAR_BOSS_EMOTES" then
		self:HideWarning();
	elseif event == "PLAYER_IN_COMBAT_CHANGED" then
		self:UpdateVisibility();
	end
end

function EncounterWarningsSystemFrameMixin:OnEncounterWarning(encounterWarningInfo)
	if self:GetSystemSeverity() ~= encounterWarningInfo.severity then
		-- This warning isn't appropriate for this frame.
		return;
	end

	if not encounterWarningInfo.shouldShowWarning then
		-- This warning has been hidden by user configuration.
		return;
	end

	if self:IsEditing() then
		-- Don't allow external warnings to interrupt edit mode previews.
		return;
	end

	-- The message sent down with the event may require formatting to include
	-- caster and target name information. Of these, the target name should
	-- be class colored.

	local formattedCasterName = encounterWarningInfo.casterName;
	local formattedTargetName = EncounterWarningsUtil.GetClassColoredTargetName(encounterWarningInfo);

	local formattedText = string.format(encounterWarningInfo.text, formattedCasterName, formattedTargetName);
	local trimmedText = string.trim(formattedText);
	encounterWarningInfo.text = trimmedText;

	self:ShowWarning(encounterWarningInfo);
end

function EncounterWarningsSystemFrameMixin:OnBossEmoteCleared()
	self:HideWarning();
end

function EncounterWarningsSystemFrameMixin:GetLayoutChildren()
	return { self.View };
end

function EncounterWarningsSystemFrameMixin:GetView()
	return self.View;
end

function EncounterWarningsSystemFrameMixin:ShowWarning(encounterWarningInfo)
	self.View:ShowWarning(encounterWarningInfo);
end

function EncounterWarningsSystemFrameMixin:HideWarning()
	self.View:HideWarning();
end

function EncounterWarningsSystemFrameMixin:ClearWarning()
	self.View:ClearWarning();
end

function EncounterWarningsSystemFrameMixin:GetSystemIndex()
	return self.systemIndex;
end

function EncounterWarningsSystemFrameMixin:GetSystemSeverity()
	return EncounterWarningsUtil.GetSeverityFromSystemIndex(self:GetSystemIndex());
end

function EncounterWarningsSystemFrameMixin:OnEditingChanged(isEditing)
	self:UpdateVisibility();

	if isEditing then
		local encounterWarningInfo = C_EncounterWarnings.GetEditModeWarningInfo(self:GetSystemSeverity());
		self:ShowWarning(encounterWarningInfo);
	else
		self:ClearWarning();
	end
end

function EncounterWarningsSystemFrameMixin:IsEditing()
	return self.isEditing;
end

function EncounterWarningsSystemFrameMixin:SetIsEditing(isEditing)
	if self.isEditing == isEditing then
		return;
	end

	self.isEditing = isEditing;
	self:OnEditingChanged(self.isEditing);
end

function EncounterWarningsSystemFrameMixin:IsExplicitlyShown()
	return self:GetAttribute("isExplicitlyShown") == true;
end

function EncounterWarningsSystemFrameMixin:SetExplicitlyShown(explicitlyShown)
	self:SetAttribute("explicitlyShown", explicitlyShown);
	self:UpdateVisibility();
end

function EncounterWarningsSystemFrameMixin:EvaluateVisibility()
	if self:IsEditing() then
		return true;
	elseif self:IsExplicitlyShown() then
		return true;
	elseif not EncounterWarningsUtil.ShouldShowFrameForSystem(self:GetSystemIndex()) then
		return false;
	end

	local visibility = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.Visibility);

	if visibility == Enum.EncounterEventsVisibility.Always then
		return true;
	elseif visibility == Enum.EncounterEventsVisibility.InEncounter then
		local isInEncounter = C_InstanceEncounter.IsEncounterInProgress();
		return isInEncounter;
	end

	return false;
end

function EncounterWarningsSystemFrameMixin:UpdateVisibility()
	local shouldShow = self:EvaluateVisibility();
	self:SetShown(shouldShow);
end

function EncounterWarningsSystemFrameMixin:UpdateSystemSettingIconSize()
	local iconScale = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.IconSize) * EncounterWarningsConstants.SizeToScaleMultiplier;
	self:GetView():SetIconScale(iconScale);
end

function EncounterWarningsSystemFrameMixin:UpdateSystemSettingOverallSize()
	local frameScale = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.OverallSize) * EncounterWarningsConstants.SizeToScaleMultiplier;
	self:SetScale(frameScale);
end

function EncounterWarningsSystemFrameMixin:UpdateSystemSettingTransparency()
	local frameAlpha = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.Transparency) * EncounterWarningsConstants.TransparencyToAlphaMultiplier;
	self:SetAlpha(frameAlpha);
end

function EncounterWarningsSystemFrameMixin:UpdateSystemSettingVisibility()
	self:UpdateVisibility();
end

function EncounterWarningsSystemFrameMixin:UpdateSystemSettingShowTooltips()
	local tooltipsEnabled = self:GetSettingValueBool(Enum.EditModeEncounterEventsSetting.ShowTooltips);
	self:GetView():SetTooltipsEnabled(tooltipsEnabled);
end
