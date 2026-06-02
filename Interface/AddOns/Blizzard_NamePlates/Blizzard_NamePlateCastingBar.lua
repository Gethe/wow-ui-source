-- Displays the info about the unit to which the nameplate is attached.
-- This mixin is a child of a frame that has been created in code and is using NamePlateBaseMixin.
NamePlateCastingBarMixin = CreateFromMixins(CastingBarMixin, NamePlateComponentMixin);

function NamePlateCastingBarMixin:OnLoad()
	local unit = nil;
	local showTradeSkills = false;
	local showShield = true;
	CastingBarMixin.OnLoad(self, unit, showTradeSkills, showShield);
end

function NamePlateCastingBarMixin:ShouldShowCastBar()
	if self:IsShowOnlyName() then
		return false;
	end

	if self:IsWidgetsOnlyMode() then
		return false;
	end

	return CastingBarMixin.ShouldShowCastBar(self);
end

function NamePlateCastingBarMixin:ApplyStyleAndAnchoring(setupOptions)
	self.classicStyleCastBar = setupOptions.useClassicCastBar;
	self.HideIconWhenNotInterruptible = setupOptions.hideIconWhenNotInterruptible;

	self:ClearAllPoints();
	self.Border:ClearAllPoints();
	self.BorderShield:ClearAllPoints();
	self.CastTargetIndicator:ClearAllPoints();
	self.CastTargetNameText:ClearAllPoints();
	self.Icon:ClearAllPoints();
	self.Text:ClearAllPoints();

	if setupOptions.useClassicCastBar then
		local hScale = setupOptions.horizontalScale;
		local vScale = setupOptions.verticalScale;

		-- The actual cast progress bar (which is self) is offset for Classic, to align with the border.
		PixelUtil.SetPoint(self, "TOPLEFT", self:GetParent(), "TOPLEFT", 20.75 * hScale, 0.5 * vScale);
		PixelUtil.SetPoint(self, "BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", -3.5 * hScale, 0.5 * vScale);

		-- Icon has a static location for Classic Style, and text is always inside cast bar.
		PixelUtil.SetPoint(self.Icon, "CENTER", self.Border, "LEFT", 11.5 * hScale, 0);
		PixelUtil.SetPoint(self.Text, "TOPLEFT", self, "TOPLEFT", 0, -1 * vScale);
		PixelUtil.SetPoint(self.Text, "BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, -1 * vScale);

		PixelUtil.SetPoint(self.CastTargetNameText, "TOPRIGHT", self, "BOTTOMRIGHT", 0, 0);

		self.Background:SetColorTexture(0, 0, 0, 0.5);

		self.Border:Show();
		PixelUtil.SetPoint(self.Border, "CENTER", self:GetParent(), "CENTER", 0, 0);
		PixelUtil.SetSize(self.Border, setupOptions.castBarBorderWidth, setupOptions.castBarBorderHeight);

		PixelUtil.SetPoint(self.CastTargetIndicator, "TOPLEFT", self, "TOPLEFT", -1.5 * hScale, 1 * vScale);
		PixelUtil.SetPoint(self.CastTargetIndicator, "BOTTOMRIGHT", self, "BOTTOMRIGHT", 1.5 * hScale, -2.25 * vScale);

		self.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark");
		self.Spark.offsetY = -1; -- CastingBarMixin uses this.
		PixelUtil.SetSize(self.Spark, 32, 32);

		self.BorderShield:SetTexture("Interface\\CastingBar\\UI-CastingBar-Small-Shield");
		PixelUtil.SetSize(self.BorderShield, 0, 0); -- For Classic Style, ignore fixed size and just use anchors.
		PixelUtil.SetPoint(self.BorderShield, "TOPLEFT", self, "TOPLEFT", -20 * hScale, 11 * vScale);
		PixelUtil.SetPoint(self.BorderShield, "BOTTOMRIGHT", self, "BOTTOMRIGHT", 13 * hScale, -13 * vScale);
	else
		-- If spell name is inside the cast bar, the cast bar is the bottom most region.
		-- Otherwise the icon and name are the bottom most region.
		if setupOptions.spellNameInsideCastBar == true then
			PixelUtil.SetPoint(self, "TOPLEFT", self:GetParent(), "TOPLEFT", 0, 0);
			PixelUtil.SetPoint(self, "BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", 0, 0);

			PixelUtil.SetPoint(self.Icon, "LEFT", self, "LEFT", 0, 0);
		else
			PixelUtil.SetPoint(self.Icon, "BOTTOMLEFT", self:GetParent(), "BOTTOMLEFT", 0, 0);

			PixelUtil.SetPoint(self, "BOTTOM", self.Icon, "TOP", 0, 0);
			PixelUtil.SetPoint(self, "LEFT", self:GetParent(), "BOTTOMLEFT", 0, 0);
			PixelUtil.SetPoint(self, "RIGHT", self:GetParent(), "BOTTOMRIGHT", 0, 0);
		end
		PixelUtil.SetPoint(self.Text, "LEFT", self.Icon, "RIGHT", 2, 0);

		PixelUtil.SetPoint(self.CastTargetNameText, "LEFT", self.Text, "RIGHT", 2, 0);
		PixelUtil.SetPoint(self.CastTargetNameText, "RIGHT", self, "RIGHT", -4, 0);

		self.Background:SetAtlas("ui-castingbar-background");

		self.Border:Hide()

		PixelUtil.SetPoint(self.CastTargetIndicator, "TOPLEFT", self, "TOPLEFT", -4, 4);
		PixelUtil.SetPoint(self.CastTargetIndicator, "BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, -4);

		self.Spark:SetAtlas("ui-castingbar-pip");
		self.Spark.offsetY = 0; -- CastingBarMixin uses this.
		PixelUtil.SetSize(self.Spark, 4, 12);

		-- For non-Classic Styles, the uninterruptable spell icon occupies the same place on the screen as the spell icon.
		-- They don't display at the same time. Only interruptable spells display the spell icon.
		self.BorderShield:SetAtlas("nameplates-InterruptShield");
		PixelUtil.SetSize(self.BorderShield, setupOptions.castBarShieldWidth, setupOptions.castBarShieldHeight);
		PixelUtil.SetPoint(self.BorderShield, "RIGHT", self.Icon, "RIGHT", 0, 0);
	end

	PixelUtil.SetSize(self.Icon, setupOptions.castIconWidth, setupOptions.castIconHeight);

	-- The smallest nameplates need slightly different anchoring to look correct when everything is so scaled down.
	local namePlateSize = CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.SIZE_CVAR);
	if namePlateSize < 2 then
		PixelUtil.SetPoint(self.ImportantCastIndicator, "TOPLEFT", self, "TOPLEFT", -20, 3);
		PixelUtil.SetPoint(self.ImportantCastIndicator, "BOTTOMRIGHT", self, "BOTTOMRIGHT", 20, -3);
	else
		PixelUtil.SetPoint(self.ImportantCastIndicator, "TOPLEFT", self, "TOPLEFT", -26, 3);
		PixelUtil.SetPoint(self.ImportantCastIndicator, "BOTTOMRIGHT", self, "BOTTOMRIGHT", 25, -3);
	end
end
