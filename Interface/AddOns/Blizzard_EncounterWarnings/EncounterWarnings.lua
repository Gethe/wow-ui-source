EncounterWarningsSystemFrameMixin = CreateFromMixins(EditModeEncounterEventsSystemMixin, ResizeLayoutMixin);

function EncounterWarningsSystemFrameMixin:OnLoad()
	EditModeEncounterEventsSystemMixin.OnSystemLoad(self);

	self:RegisterEvent("ENCOUNTER_WARNING");
	self:RegisterEvent("CLEAR_BOSS_EMOTES");

	for _, cvarName in ipairs(EncounterWarningsVisibilityCVars) do
		CVarCallbackRegistry:SetCVarCachable(cvarName);
		CVarCallbackRegistry:RegisterCallback(cvarName, function() self:UpdateVisibility(); end, self);
	end
end

function EncounterWarningsSystemFrameMixin:OnShow()
	ResizeLayoutMixin.OnShow(self);
end

function EncounterWarningsSystemFrameMixin:OnEvent(event, ...)
	if event == "ENCOUNTER_WARNING" then
		local encounterWarningInfo = ...;
		self:OnEncounterWarning(encounterWarningInfo);
	elseif event == "CLEAR_BOSS_EMOTES" then
		self:OnClearBossEmotes();
	end
end

function EncounterWarningsSystemFrameMixin:OnEncounterWarning(encounterWarningInfo)
	if self:GetSystemSeverity() ~= encounterWarningInfo.severity then
		return;
	end

	-- EETODO: There's some disgusting hacks in here. Right now the BCTs
	-- we're getting down embed the icon as texture markup into the text.
	--
	-- Ideally, this needs splitting out to a separate field and sending down
	-- the wire separate from the BCT. Until that's done, the iconFileID
	-- we're getting down with the event is a hardcoded zero.

	local originalText = encounterWarningInfo.text;
	local iconFileAsset = string.match(originalText, "|T([^:|]+)");
	local maintainColor = true;
	local maintainBrackets = true;
	local stripNewlines = true;
	local maintainAtlases = false;
	local unformattedText = StripHyperlinks(originalText, maintainColor, maintainBrackets, stripNewlines, maintainAtlases);

	if encounterWarningInfo.iconFileID == 0 then
		encounterWarningInfo.iconFileID = iconFileAsset;
	end

	-- EETODO: Bindings generator needs to properly support conditional
	-- secret + nilable; right now it just gives you a conditional secret
	-- with no nilable wrapper - so, force it to nil if zero here.

	if encounterWarningInfo.tooltipSpellID == 0 then
		encounterWarningInfo.tooltipSpellID = nil;
	end

	-- The message sent down with the event may require formatting to include
	-- caster and target name information. Of these, the target name should
	-- be class colored - but we allow disabling that via a view setting.

	local formattedCasterName = encounterWarningInfo.casterName;
	local formattedTargetName;

	if EncounterWarningsViewSettings.ShouldClassColorTargetNames(self.View) then
		formattedTargetName = EncounterWarningsUtil.GetClassColoredTargetName(encounterWarningInfo);
	else
		formattedTargetName = encounterWarningInfo.targetName;
	end

	local formattedText = string.format(unformattedText, formattedCasterName, formattedTargetName);
	encounterWarningInfo.text = formattedText;

	if encounterWarningInfo.duration == 0 then
		encounterWarningInfo.duration = EncounterWarningsConstants.DefaultMessageHoldTime;
	end

	self:ShowWarning(encounterWarningInfo);

	-- EETODO: Investigate TTS routing.
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
		-- EETODO: Move this to native code and set up some static dummy spell recs.
		local dummyWarningInfo = {
			iconFileID = 134400,
			severity = self:GetSystemSeverity(),
			text = self.systemNameString,
			tooltipSpellID = nil,
			duration = nil,
		};

		self:ShowWarning(dummyWarningInfo);
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
	elseif visibility == Enum.EncounterEventsVisibility.Hidden then
		return false;
	elseif visibility == Enum.EncounterEventsVisibility.InCombat then
		local isInCombat = UnitAffectingCombat("player");
		return isInCombat;
	end

	return false;
end

function EncounterWarningsSystemFrameMixin:UpdateVisibility()
	local shouldShow = self:EvaluateVisibility();
	self:SetShown(shouldShow);
end

function EncounterWarningsSystemFrameMixin:UpdateSystemSettingIconSize()
	local iconScale = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.IconSize) / 100;
	EncounterWarningsViewSettings.SetIconScale(self.View, iconScale);
end

function EncounterWarningsSystemFrameMixin:UpdateSystemSettingOverallSize()
	local frameScale = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.OverallSize) / 100;
	self:SetScale(frameScale);
end

function EncounterWarningsSystemFrameMixin:UpdateSystemSettingTransparency()
	local frameAlpha = self:GetSettingValue(Enum.EditModeEncounterEventsSetting.Transparency) / 100;
	self:SetAlpha(frameAlpha);
end

function EncounterWarningsSystemFrameMixin:UpdateSystemSettingVisibility()
	self:UpdateVisibility();
end

function EncounterWarningsSystemFrameMixin:UpdateSystemSettingShowTooltips()
	local tooltipsEnabled = self:GetSettingValueBool(Enum.EditModeEncounterEventsSetting.ShowTooltips);
	EncounterWarningsViewSettings.SetTooltipsEnabled(self.View, tooltipsEnabled);
end
