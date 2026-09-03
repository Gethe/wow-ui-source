-- Displays the info about the unit to which the nameplate is attached.
-- This mixin is a child of a frame that has been created in code and is using NamePlateBaseMixin.
NamePlateCastingBarMixin = CreateFromMixins(CastingBarMixin, NamePlateComponentMixin);

function NamePlateCastingBarMixin:OnLoad()
	local unit = nil;
	local showTradeSkills = false;
	local showShield = true;
	CastingBarMixin.OnLoad(self, unit, showTradeSkills, showShield);

	PixelUtil.SetRoundLayoutToNearestPixelRecursively(self, true);
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
		self:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", 20.75 * hScale, 0.5 * vScale);
		self:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", -3.5 * hScale, 0.5 * vScale);

		-- Icon has a static location for Classic Style, and text is always inside cast bar.
		self.Icon:SetPoint("CENTER", self.Border, "LEFT", 11.5 * hScale, 0);
		self.Text:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -1 * vScale);
		self.Text:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, -1 * vScale);

		self.CastTargetNameText:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, 0);

		self.Background:SetColorTexture(0, 0, 0, 0.5);

		self.Border:Show();
		self.Border:SetPoint("CENTER", self:GetParent(), "CENTER", 0, 0);
		self.Border:SetSize(setupOptions.castBarBorderWidth, setupOptions.castBarBorderHeight);

		self.CastTargetIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -1.5 * hScale, 1 * vScale);
		self.CastTargetIndicator:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 1.5 * hScale, -2.25 * vScale);

		self.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark");
		self.Spark.offsetY = -1; -- CastingBarMixin uses this.
		self.Spark:SetSize(32, 32);

		self.BorderShield:SetTexture("Interface\\CastingBar\\UI-CastingBar-Small-Shield");
		self.BorderShield:SetSize(0, 0); -- For Classic Style, ignore fixed size and just use anchors.
		self.BorderShield:SetPoint("TOPLEFT", self, "TOPLEFT", -20 * hScale, 11 * vScale);
		self.BorderShield:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 13 * hScale, -13 * vScale);
	else
		-- If spell name is inside the cast bar, the cast bar is the bottom most region.
		-- Otherwise the icon and name are the bottom most region.
		if setupOptions.spellNameInsideCastBar == true then
			self:SetPoint("TOPLEFT", self:GetParent(), "TOPLEFT", 0, 0);
			self:SetPoint("BOTTOMRIGHT", self:GetParent(), "BOTTOMRIGHT", 0, 0);

			self.Icon:SetPoint("LEFT", self, "LEFT", 0, 0);
		else
			self.Icon:SetPoint("BOTTOMLEFT", self:GetParent(), "BOTTOMLEFT", 0, 0);

			self:SetPoint("BOTTOM", self.Icon, "TOP", 0, 0);
			self:SetPoint("LEFT", self:GetParent(), "BOTTOMLEFT", 0, 0);
			self:SetPoint("RIGHT", self:GetParent(), "BOTTOMRIGHT", 0, 0);
		end
		self.Text:SetPoint("LEFT", self.Icon, "RIGHT", 2, 0);

		self.CastTargetNameText:SetPoint("LEFT", self.Text, "RIGHT", 2, 0);
		self.CastTargetNameText:SetPoint("RIGHT", self, "RIGHT", -4, 0);

		self.Background:SetAtlas("ui-castingbar-background");

		self.Border:Hide()

		self.CastTargetIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -4, 4);
		self.CastTargetIndicator:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 4, -4);

		self.Spark:SetAtlas("ui-castingbar-pip");
		self.Spark.offsetY = 0; -- CastingBarMixin uses this.
		self.Spark:SetSize(4, 12);

		-- For non-Classic Styles, the uninterruptable spell icon occupies the same place on the screen as the spell icon.
		-- They don't display at the same time. Only interruptable spells display the spell icon.
		self.BorderShield:SetAtlas("nameplates-InterruptShield");
		self.BorderShield:SetSize(setupOptions.castBarShieldWidth, setupOptions.castBarShieldHeight);
		self.BorderShield:SetPoint("RIGHT", self.Icon, "RIGHT", 0, 0);
	end

	self.Icon:SetSize(setupOptions.castIconWidth, setupOptions.castIconHeight);

	-- The smallest nameplates need slightly different anchoring to look correct when everything is so scaled down.
	local namePlateSize = CVarCallbackRegistry:GetCVarNumberOrDefault(NamePlateConstants.SIZE_CVAR);
	if namePlateSize < 2 then
		self.ImportantCastIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -20, 3);
		self.ImportantCastIndicator:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 20, -3);
	else
		self.ImportantCastIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -26, 3);
		self.ImportantCastIndicator:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 25, -3);
	end
end
