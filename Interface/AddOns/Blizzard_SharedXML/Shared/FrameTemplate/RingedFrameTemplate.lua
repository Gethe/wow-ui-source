
RingedFrameWithTooltipMixin = {};
function RingedFrameWithTooltipMixin:OnLoad()
	if self.simpleTooltipLine then
		self:AddTooltipLine(self.simpleTooltipLine, HIGHLIGHT_FONT_COLOR);
	end
end

function RingedFrameWithTooltipMixin:ClearTooltipLines()
	self.tooltipLines = nil;
end

function RingedFrameWithTooltipMixin:AddTooltipLine(lineText, lineColor)
	if not self.tooltipLines then
		self.tooltipLines = {};
	end

	table.insert(self.tooltipLines, {text = lineText, color = lineColor or NORMAL_FONT_COLOR});
end

function RingedFrameWithTooltipMixin:AddBlankTooltipLine()
	self:AddTooltipLine(" ");
end

function RingedFrameWithTooltipMixin:GetAppropriateTooltip()
	error("You must implement GetAppropriateTooltip on your mixin!");
end

function RingedFrameWithTooltipMixin:SetupAnchors(tooltip)
	if self.tooltipAnchor == "ANCHOR_TOPRIGHT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", self.tooltipXOffset, self.tooltipYOffset);
	elseif self.tooltipAnchor == "ANCHOR_TOPLEFT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -self.tooltipXOffset, self.tooltipYOffset);
	elseif self.tooltipAnchor == "ANCHOR_BOTTOMRIGHT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", self.tooltipXOffset, self.tooltipYOffset);
	elseif self.tooltipAnchor == "ANCHOR_BOTTOMLEFT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", -self.tooltipXOffset, self.tooltipYOffset);
	else
		tooltip:SetOwner(self, self.tooltipAnchor, self.tooltipXOffset, self.tooltipYOffset);
	end
end

function RingedFrameWithTooltipMixin:AddExtraStuffToTooltip()
end

function RingedFrameWithTooltipMixin:OnEnter()
	if self.tooltipLines then
		local tooltip = self:GetAppropriateTooltip();

		self:SetupAnchors(tooltip);

		if self.tooltipMinWidth then
			tooltip:SetMinimumWidth(self.tooltipMinWidth);
		end

		if self.tooltipPadding then
			tooltip:SetPadding(self.tooltipPadding, self.tooltipPadding, self.tooltipPadding, self.tooltipPadding);
		end

		for _, lineInfo in ipairs(self.tooltipLines) do
			GameTooltip_AddColoredLine(tooltip, lineInfo.text, lineInfo.color);
		end

		self:AddExtraStuffToTooltip();

		tooltip:Show();
	end
end

function RingedFrameWithTooltipMixin:OnLeave()
	local tooltip = self:GetAppropriateTooltip();
	tooltip:Hide();
end

RingedMaskedButtonMixin = CreateFromMixins(RingedFrameWithTooltipMixin);

function RingedMaskedButtonMixin:OnLoad()
	RingedFrameWithTooltipMixin.OnLoad(self);

	self.CircleMask:SetPoint("TOPLEFT", self, "TOPLEFT", self.circleMaskSizeOffset, -self.circleMaskSizeOffset);
	self.CircleMask:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.circleMaskSizeOffset, self.circleMaskSizeOffset);

	self.New:SetPoint("CENTER", self, "BOTTOM", 0, self.newTagYOffset);

	local hasRingSizes = self.ringWidth and self.ringHeight;
	if hasRingSizes then
		self.Ring:SetAtlas(self.ringAtlas);
		self.Ring:SetSize(self.ringWidth, self.ringHeight);
		self.Flash.Ring:SetAtlas(self.ringAtlas);
		self.Flash.Ring:SetSize(self.ringWidth, self.ringHeight);
		self.Flash.Ring2:SetAtlas(self.ringAtlas);
		self.Flash.Ring2:SetSize(self.ringWidth, self.ringHeight);
	else
		self.Ring:SetAtlas(self.ringAtlas, true);
		self.Flash.Ring:SetAtlas(self.ringAtlas, true);
		self.Flash.Ring2:SetAtlas(self.ringAtlas, true);
	end

	self.NormalTexture:AddMaskTexture(self.CircleMask);
	self.PushedTexture:AddMaskTexture(self.CircleMask);
	self.DisabledOverlay:AddMaskTexture(self.CircleMask);
	self.DisabledOverlay:SetAlpha(self.disabledOverlayAlpha);
	self.CheckedTexture:SetSize(self.checkedTextureSize, self.checkedTextureSize);
	self.Flash.Portrait:AddMaskTexture(self.CircleMask);

	if self.flipTextures then
		self.NormalTexture:SetTexCoord(1, 0, 0, 1);
		self.PushedTexture:SetTexCoord(1, 0, 0, 1);
		self.Flash.Portrait:SetTexCoord(1, 0, 0, 1);
	end

	if self.BlackBG then
		self.BlackBG:AddMaskTexture(self.CircleMask);
	end
end

function RingedMaskedButtonMixin:SetIconAtlas(atlas)
	self:SetNormalAtlas(atlas);
	self:SetPushedAtlas(atlas);
	self.Flash.Portrait:SetAtlas(atlas);
end

function RingedMaskedButtonMixin:ClearFlashTimer()
	if self.FlashTimer then
		self.FlashTimer:Cancel();
	end
end

function RingedMaskedButtonMixin:StartFlash()
	self:ClearFlashTimer();

	local function playFlash()
		self.Flash:Show();
		self.Flash.Anim:Play();
	end

	self.FlashTimer = C_Timer.NewTimer(0.8, playFlash);
end

function RingedMaskedButtonMixin:StopFlash()
	self:ClearFlashTimer();
	self.Flash.Anim:Stop();
	self.Flash:Hide();
end

function RingedMaskedButtonMixin:SetEnabledState(enabled)
	local buttonEnableState = enabled or self.allowSelectionOnDisable;
	self:SetEnabled(buttonEnableState);

	local normalTex = self:GetNormalTexture();
	if normalTex then
		normalTex:SetDesaturated(not enabled);
	end

	local pushedTex = self:GetPushedTexture();
	if pushedTex then
		pushedTex:SetDesaturated(not enabled);
	end

	self.Ring:SetAtlas(self.ringAtlas..(enabled and "" or "-disabled"));

	self.DisabledOverlay:SetShown(not enabled);
end

function RingedMaskedButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		self.CheckedTexture:SetPoint("CENTER", self, "CENTER", 1, -1);
		self.CircleMask:SetPoint("TOPLEFT", self.PushedTexture, "TOPLEFT", self.circleMaskSizeOffset, -self.circleMaskSizeOffset);
		self.CircleMask:SetPoint("BOTTOMRIGHT", self.PushedTexture, "BOTTOMRIGHT", -self.circleMaskSizeOffset, self.circleMaskSizeOffset);
		self.Ring:SetPoint("CENTER", self, "CENTER", 1, -1);
		self.Flash:SetPoint("CENTER", self, "CENTER", 1, -1);
	end
end

function RingedMaskedButtonMixin:OnMouseUp(button)
	self.CheckedTexture:SetPoint("CENTER");
	self.CircleMask:SetPoint("TOPLEFT", self.NormalTexture, "TOPLEFT", self.circleMaskSizeOffset, -self.circleMaskSizeOffset);
	self.CircleMask:SetPoint("BOTTOMRIGHT", self.NormalTexture, "BOTTOMRIGHT", -self.circleMaskSizeOffset, self.circleMaskSizeOffset);
	self.Ring:SetPoint("CENTER");
	self.Flash:SetPoint("CENTER");
end

function RingedMaskedButtonMixin:UpdateHighlightTexture()
	if self:GetChecked() then
		self.HighlightTexture:SetAtlas("charactercreate-ring-select");
		self.HighlightTexture:SetPoint("TOPLEFT", self.CheckedTexture);
		self.HighlightTexture:SetPoint("BOTTOMRIGHT", self.CheckedTexture);
	else
		self.HighlightTexture:SetAtlas(self.ringAtlas);
		self.HighlightTexture:SetPoint("TOPLEFT", self.Ring);
		self.HighlightTexture:SetPoint("BOTTOMRIGHT", self.Ring);
	end
end
