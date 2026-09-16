----------------- Base Customization child frame -----------------

CustomizationContentFrameMixin = {};

function CustomizationContentFrameMixin:SetCustomizationFrame(customizationFrame)
	self.customizationFrame = customizationFrame;
end

function CustomizationContentFrameMixin:GetCustomizationFrame()
	return self.customizationFrame;
end

----------------- Base Button -----------------

CustomizationBaseButtonMixin = CreateFromMixins(CustomizationContentFrameMixin);

function CustomizationBaseButtonMixin:OnBaseButtonClick()
	-- This propagated click isn't intended for the parent frame to handle button-specific logic
	-- It's rather meant as "a button in the frame was clicked" for general things like interaction tracking for server update/timeout handling
	self:GetCustomizationFrame():OnButtonClick();
end

----------------- Base Frame With Tooltip -----------------

CustomizationFrameWithTooltipMixin = CreateFromMixins(RingedFrameWithTooltipMixin);

function CustomizationFrameWithTooltipMixin:GetAppropriateTooltip()
	return CustomizationNoHeaderTooltip;
end

----------------- Base Masked Frame With Tooltip -----------------

CustomizationMaskedButtonMixin = CreateFromMixins(RingedMaskedButtonMixin)
function CustomizationMaskedButtonMixin:GetAppropriateTooltip()
	return CustomizationNoHeaderTooltip;
end

----------------- Base Frame With Expandable Tooltip -----------------

CustomizationFrameWithExpandableTooltipMixin = {};

function CustomizationFrameWithExpandableTooltipMixin:ClearTooltipLines()
	self.tooltipLines = nil;
	self.expandedTooltipFrame = nil;
	self.postTooltipLines = nil;
end

function CustomizationFrameWithExpandableTooltipMixin:AddExpandedTooltipFrame(frame)
	self.expandedTooltipFrame = frame;
end

function CustomizationFrameWithExpandableTooltipMixin:AddPostTooltipLine(lineText, lineColor)
	if not self.postTooltipLines then
		self.postTooltipLines = {};
	end

	table.insert(self.postTooltipLines, {text = lineText, color = lineColor or NORMAL_FONT_COLOR});
end

function CustomizationFrameWithExpandableTooltipMixin:AddExtraStuffToTooltip()
	local tooltip = self:GetAppropriateTooltip();

	if self.expandedTooltipFrame then
		if self:GetCustomizationFrame():GetTooltipsExpanded() then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_InsertFrame(tooltip, self.expandedTooltipFrame);
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddDisabledLine(tooltip, RIGHT_CLICK_FOR_LESS);
		else
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddDisabledLine(tooltip, RIGHT_CLICK_FOR_MORE);
		end
	end

	if self.postTooltipLines then
		GameTooltip_AddBlankLineToTooltip(tooltip);

		for _, lineInfo in ipairs(self.postTooltipLines) do
			GameTooltip_AddColoredLine(tooltip, lineInfo.text, lineInfo.color);
		end
	end
end

function CustomizationFrameWithExpandableTooltipMixin:OnMouseUp(button)
	if button == "RightButton" and self.expandedTooltipFrame then
		self:GetCustomizationFrame():ToggleTooltipsExpanded();
		if self:IsMouseMotionFocus() then
			self:OnEnter();
		end
	end
	RingedMaskedButtonMixin.OnMouseUp(self);
end

----------------- Small Button -----------------

CustomizationSmallButtonMixin = CreateFromMixins(CustomizationFrameWithTooltipMixin, CustomizationContentFrameMixin);

function CustomizationSmallButtonMixin:OnLoad()
	CustomizationFrameWithTooltipMixin.OnLoad(self);
	self.Icon:SetAtlas(self.iconAtlas);
	self.HighlightTexture:SetAtlas(self.iconAtlas);
end

function CustomizationSmallButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		self.Icon:SetPoint("CENTER", self.PushedTexture);
	end
end

function CustomizationSmallButtonMixin:OnMouseUp()
	self.Icon:SetPoint("CENTER");
end

function CustomizationSmallButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
end

----------------- Click Or Hold Button -----------------

-- Expects to inherit CustomizationSmallButtonMixin

CustomizationClickOrHoldButtonMixin = {};

function CustomizationClickOrHoldButtonMixin:OnHide()
	self.waitTimerSeconds = nil;
	self:SetScript("OnUpdate", nil);
end

function CustomizationClickOrHoldButtonMixin:DoClickAction()
end

function CustomizationClickOrHoldButtonMixin:DoHoldAction(elapsed)
end

function CustomizationClickOrHoldButtonMixin:OnClick()
	CustomizationSmallButtonMixin.OnClick(self);

	if not self.wasHeld then
		self:DoClickAction();
	end
end

function CustomizationClickOrHoldButtonMixin:OnUpdate(elapsed)
	if self.waitTimerSeconds then
		self.waitTimerSeconds = self.waitTimerSeconds - elapsed;
		if self.waitTimerSeconds >= 0 then
			return;
		else
			-- waitTimerSeconds is now negative, so add it to elapsed to remove any leftover wait time
			elapsed = elapsed + self.waitTimerSeconds;
			self.waitTimerSeconds = nil;
		end
	end

	self.wasHeld = true;
	self:DoHoldAction(elapsed);
end

function CustomizationClickOrHoldButtonMixin:OnMouseDown()
	CustomizationSmallButtonMixin.OnMouseDown(self);
	self.wasHeld = false;
	self.waitTimerSeconds = self.holdWaitTimeSeconds;
	self:SetScript("OnUpdate", self.OnUpdate);
end

function CustomizationClickOrHoldButtonMixin:OnMouseUp()
	CustomizationSmallButtonMixin.OnMouseUp(self);
	self.waitTimerSeconds = nil;
	self:SetScript("OnUpdate", nil);
end

CustomizationNoHeaderTooltipMixin = {};

function CustomizationNoHeaderTooltipMixin:OnLoad()
	SharedTooltip_OnLoad(self);
	TopLevelParentScaleFrameMixin.OnScaleFrameLoad(self);
end
