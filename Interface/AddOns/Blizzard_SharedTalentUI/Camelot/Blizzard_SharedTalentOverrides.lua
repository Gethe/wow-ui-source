function TalentButtonUtil.GetColorForBaseVisualState(visualState)
	if (visualState == TalentButtonUtil.BaseVisualState.Gated) or (visualState == TalentButtonUtil.BaseVisualState.Disabled) or (visualState == TalentButtonUtil.BaseVisualState.Locked) then
		return DISABLED_FONT_COLOR;
	elseif visualState == TalentButtonUtil.BaseVisualState.Selectable then
		return GREEN_FONT_COLOR;
	elseif visualState == TalentButtonUtil.BaseVisualState.RefundInvalid then
		return RED_FONT_COLOR;
	elseif visualState == TalentButtonUtil.BaseVisualState.DisplayError then
		return RED_FONT_COLOR;
	elseif visualState ~= TalentButtonUtil.BaseVisualState.Maxed then
		return GREEN_FONT_COLOR;
	end

	-- visualState == TalentButtonUtil.BaseVisualState.Normal
	return YELLOW_FONT_COLOR;
end

function TalentButtonArtMixin:UpdateStateBorder(visualState)
	local isDisabled = (visualState == TalentButtonUtil.BaseVisualState.Gated)
					or (visualState == TalentButtonUtil.BaseVisualState.Locked)
					or (visualState == TalentButtonUtil.BaseVisualState.Disabled);

	if (visualState == TalentButtonUtil.BaseVisualState.RefundInvalid) then
		self:SetBorderAtlas(self.artSet.refundInvalid, visualState);
	elseif (visualState == TalentButtonUtil.BaseVisualState.DisplayError) then
		self:SetBorderAtlas(self.artSet.displayError, visualState);
	elseif (visualState == TalentButtonUtil.BaseVisualState.Gated) then
		self:SetBorderAtlas(self.artSet.locked, visualState);
	elseif (visualState == TalentButtonUtil.BaseVisualState.Selectable) then
		self:SetBorderAtlas(self.artSet.selectable, visualState);
	elseif (visualState == TalentButtonUtil.BaseVisualState.Maxed) then
		self:SetBorderAtlas(self.artSet.maxed, visualState);
	elseif (visualState ~= TalentButtonUtil.BaseVisualState.Maxed and not isDisabled) then
		self:SetBorderAtlas(self.artSet.selectable, visualState);
	elseif not isDisabled then
		self:SetBorderAtlas(self.artSet.normal, visualState);
	else
		self:SetBorderAtlas(self.artSet.disabled, visualState);
	end
end

function TalentFrameBaseMixin:ShowOrHideGlowOnChangesPending()
	local _, canApplyChanges = self:GetConfigApplicationState();

	if canApplyChanges then
		self.ApplyButton.YellowGlow:Show();
	else
		GlowEmitterFactory:Hide(self.ApplyButton);
		self.ApplyButton.YellowGlow:Hide();
	end
end

function TalentFrameBaseMixin:ShouldAddEdgeRequirementsToTooltip(requiresAllPrecedingTraits, numOfEdges, areAllPrecedingEdgesActive)
	return numOfEdges > 0 and not areAllPrecedingEdgesActive;
end
