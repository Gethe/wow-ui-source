local BarHeight = 18;

CommentatorNamePlateMixin = {}

function CommentatorNamePlateMixin:OnLoad()
	CompactUnitFrame_OnLoad(self);
	
	-- Purposely inverting the upscaling so that our frame appears 1:1 at 1080p.
	self:SetScale(COMMENTATOR_INVERSE_SCALE);

	self:RegisterEvent("COMMENTATOR_TEAMS_SWAPPED");
	self:RegisterEvent("LOSS_OF_CONTROL_COMMENTATOR_ADDED");
	self:RegisterEvent("LOSS_OF_CONTROL_COMMENTATOR_UPDATE");
	self:RegisterEvent("UPDATE_ACTIVE_BATTLEFIELD");

	-- These functions are called from CUF functions so we can intercept the handling
	-- if necessary; returning true will prevent CUF from continuing in the case there is
	-- any conflicting behavior. Note that functions like OnUpdate and OnSizeChanged cannot
	-- be assigned in our XML because they are hijacked by CUF.
	self.SizeChangedOverride = self.OnSizeChangedOverride;
	self.SetupOverride = self.OnSetupOverride;
	self.UpdateNameOverride = self.OnUpdateNameOverride;
	self.UpdateHealthBorderOverride = self.OnUpdateHealthBorderOverride;
	self.UpdateHealthColorOverride = self.OnUpdateHealthColorOverride;
	self.CommentatorTeamSwapped = self.OnCommentatorTeamSwapped;

	-- Attaching elements to inherited frames and textures to preserve as much of the original
	-- functionality as possible without redefining it in the XML.
	self:GetHealthBar().border:ClearAllPoints();
	self:GetHealthBar().border = CreateFrame("FRAME", nil, self:GetHealthBar(), "CommentatorNamePlateFullBorderTemplate");
	self:GetHealthBar():SetStatusBarAtlas("_Bar-mid");
	self:GetHealthBar():SetHeight(BarHeight);
	
	self:GetCastBar():SetScript("OnShow", nil);
	self:GetCastBar().Border:SetAlpha(0);
	self:GetCastBar().border = CreateFrame("FRAME", nil, self:GetCastBar(), "CommentatorNamePlateFullBorderTemplate");
	self:GetCastBar():SetStatusBarAtlas("_Bar-mid");
	
	self:GetCastBar().Flash:ClearAllPoints();
	self:GetCastBar().Flash:SetAllPoints();
	self:GetCastBar().Flash:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-BarFill");
	self:GetCastBar().Flash:SetBlendMode("ADD");

	local fontName, fontSize, fontFlags = self.CastBar.Text:GetFont();
	self:GetCastBar():SetHeight(BarHeight);
	self:GetCastBar().Text:SetFont(fontName, 12, fontFlags);

	self.name:SetFontObject(SystemFont_LargeNamePlateFixed);

	self.LevelFrame:Hide();
end

function CommentatorNamePlateMixin:GetCastBar()
	return self.CastBar;
end

function CommentatorNamePlateMixin:GetHealthBar()
	return self.healthBar;
end

function CommentatorNamePlateMixin:OnEvent(event, ...)
	CompactUnitFrame_OnEvent(self, event, ...);

	if ( event == "COMMENTATOR_TEAMS_SWAPPED" ) then
		local swapped = ...;
		if self.CommentatorTeamSwapped then
			self:CommentatorTeamSwapped(swapped);
		end
	elseif event == "LOSS_OF_CONTROL_COMMENTATOR_ADDED" then
		local guid , index = ...;
		if UnitGUID(self.unit) == guid then
			self:ApplyLossOfControlAtIndex(index);
		end
	elseif event == "LOSS_OF_CONTROL_COMMENTATOR_UPDATE" then
		local guid = ...;
		if UnitGUID(self.unit) == guid then
			self:ApplyLossOfControlAtIndex(LOSS_OF_CONTROL_ACTIVE_INDEX);
		end
	elseif event == "UPDATE_ACTIVE_BATTLEFIELD" then
		self:SetBorderColors();
	end
end

function CommentatorNamePlateMixin:OnUpdate(elapsed)
	CompactUnitFrame_OnUpdate(self, elapsed);

	self:UpdateCrowdControlAuras();
end

function CommentatorNamePlateMixin:OnSizeChanged(w, h)
	PixelUtil.SetPoint(self.healthBar, "LEFT", self, "LEFT", 12, 5);
	PixelUtil.SetPoint(self.healthBar, "RIGHT", self, "RIGHT", -12, 5);
end

function CommentatorNamePlateMixin:GetNameText()
	if self.ccDisplayText and GetCVarBool("commentatorLossOfControlTextNameplate") then
		return self.ccDisplayText;
	else
		local name = GetUnitName(self.unit, true);
		local overrideName = C_Commentator.GetPlayerOverrideName(name);
		return overrideName or name;
	end
end

function CommentatorNamePlateMixin:UpdateNameText()
	local text = self:GetNameText();
	self.name:SetText(text);
end

function CommentatorNamePlateMixin:ApplyLossOfControlData(data)
	if data and data.locType ~= "SCHOOL_INTERRUPT" then
		self.ccDisplayText = data.displayText;
	else
		self.ccDisplayText = nil;
	end

	self:UpdateNameText();
end

function CommentatorNamePlateMixin:ApplyLossOfControlAtIndex(index)
	local data = C_LossOfControl.GetActiveLossOfControlDataByUnit(self.unit, index);
	self:ApplyLossOfControlData(data);
end

function CommentatorNamePlateMixin:SetPointsByPixelUtil()
	self.healthBar:ClearAllPoints();
	PixelUtil.SetSize(self.healthBar, 190, BarHeight);
	PixelUtil.SetPoint(self.healthBar, "LEFT", self, "LEFT", 0, -10);
	
	self.healthBar:SetFrameLevel(self:GetFrameLevel() - 1);
	self.healthBar.border:UpdateSizes();

	PixelUtil.SetWidth(self:GetCastBar(), 170, BarHeight);
	PixelUtil.SetPoint(self:GetCastBar(), "TOP", self.healthBar, "BOTTOM", 0, -6);
	
	self:GetCastBar().Text:ClearAllPoints();
	local iconSize = BarHeight + 2;
	local textOffset = iconSize / 2;
	PixelUtil.SetPoint(self:GetCastBar().Text, "CENTER", self:GetCastBar(), "CENTER", textOffset, 0);
	
	self:GetCastBar().Icon:ClearAllPoints();
	self:GetCastBar().Icon:SetDrawLayer("OVERLAY", 7);
	PixelUtil.SetSize(self:GetCastBar().Icon, iconSize, iconSize);
	PixelUtil.SetPoint(self:GetCastBar().Icon, "TOPLEFT", self:GetCastBar(), "TOPLEFT", -1, 1);

	self:GetCastBar().border:UpdateSizes();

	self.name:ClearAllPoints();
	PixelUtil.SetPoint(self.name, "BOTTOM", self.healthBar, "TOP", 0, 4);

	self.ClassIcon:ClearAllPoints();
	PixelUtil.SetPoint(self.ClassIcon, "RIGHT", self.healthBar, "LEFT", 0, 0);

	self.CCIcon:ClearAllPoints();
	PixelUtil.SetPoint(self.CCIcon, "CENTER", self.ClassIcon, "CENTER", 0, 0);
	
	self.ClassOverlay:ClearAllPoints();
	PixelUtil.SetPoint(self.ClassOverlay, "CENTER", self.ClassIcon, "CENTER", 0, 0);
	
	self.CCText:ClearAllPoints();
	PixelUtil.SetPoint(self.CCText, "CENTER", self.ClassIcon, "CENTER", 0, 30);
	
	self.CCCooldown:ClearAllPoints();
	PixelUtil.SetPoint(self.CCCooldown, "CENTER", self.CCIcon, "CENTER", 0, 0);
	
	self.Mask:ClearAllPoints();
	PixelUtil.SetPoint(self.Mask, "CENTER", self.ClassIcon, "CENTER", 0, 0);
end

function CommentatorNamePlateMixin:OnSetupOverride(setupOptions, frameOptions)
	self:SetPointsByPixelUtil();
	-- CUF can continue.
	return false;
end

function CommentatorNamePlateMixin:OnSizeChangedOverride()
	self:SetPointsByPixelUtil();
	
	-- CUF can continue.
	return false;
end

function CommentatorNamePlateMixin:OnUpdateNameOverride()
	self:UpdateNameText();

	-- CAF cannot continue.
	return true;
end

function CommentatorNamePlateMixin:SetBorderColors()
	local color = C_Commentator.GetTeamColorByUnit(self.unit);
	self:GetHealthBar().border:SetVertexColor(color.r, color.g, color.b, color.a);
	self:GetCastBar().border:SetVertexColor(color.r, color.g, color.b, color.a);
end

function CommentatorNamePlateMixin:OnUpdateHealthBorderOverride()
	self:SetBorderColors();

	local class = select(2, UnitClass(self.unit))
	self.ClassIcon:SetAtlas(GetClassAtlas(class));

	-- CUF cannot continue.
	return true;
end

function CommentatorNamePlateMixin:OnUpdateHealthColorOverride()
	local localizedClass, englishClass = UnitClass(self.unit);
	local classColor = RAID_CLASS_COLORS[englishClass];
	self:GetHealthBar():SetStatusBarColor(classColor.r, classColor.g, classColor.b);

	-- CUF cannot continue.
	return true;
end

function CommentatorNamePlateMixin:OnCommentatorTeamSwapped(swapped)
	self:SetBorderColors();
end

function CommentatorNamePlateMixin:UpdateCrowdControlAuras()
	local spellID, expirationTime, duration = C_Commentator.GetPlayerCrowdControlInfoByUnit(self.unit);
	local hasCC = spellID and expirationTime;
	if hasCC and self.ccSpellID ~= spellID then
		self.CCCooldown:SetCooldown(expirationTime - duration, duration);

		if spellID ~= nil then
			local icon = select(3, GetSpellInfo(spellID));
			if icon then
				self.CCIcon:SetTexture(icon);
			end
		end
	end
	self.CCIcon:SetShown(hasCC);

	self.ccExpirationTime = expirationTime;
	self.ccSpellID = spellID;

	local timeRemaining = self.ccExpirationTime and math.max(self.ccExpirationTime - GetTime(), 0) or 0;
	if timeRemaining > 0 then
		self.CCText:SetFormattedText("%.1f", timeRemaining);
		self.CCText:Show();
	else
		self.CCText:Hide();
		self.CCCooldown:Clear();
	end
end

CommentatorNamePlateBorderTemplateMixin = {};

function CommentatorNamePlateBorderTemplateMixin:SetVertexColor(r, g, b, a)
	for i, texture in ipairs(self.Textures) do
		texture:SetVertexColor(r, g, b, a);
	end
end

function CommentatorNamePlateBorderTemplateMixin:SetBorderSizes(borderSize, borderSizeMinPixels, upwardExtendHeightPixels, upwardExtendHeightMinPixels)
	self.borderSize = borderSize;
	self.borderSizeMinPixels = borderSizeMinPixels;
	self.upwardExtendHeightPixels = upwardExtendHeightPixels;
	self.upwardExtendHeightMinPixels = upwardExtendHeightMinPixels;
end

function CommentatorNamePlateBorderTemplateMixin:UpdateSizes()
	local borderSize = self.borderSize or 1;
	local minPixels = self.borderSizeMinPixels or 2;

	local upwardExtendHeightPixels = self.upwardExtendHeightPixels or borderSize;
	local upwardExtendHeightMinPixels = self.upwardExtendHeightMinPixels or minPixels;

	PixelUtil.SetWidth(self.Left, borderSize, minPixels);
	PixelUtil.SetPoint(self.Left, "TOPRIGHT", self, "TOPLEFT", 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels);
	PixelUtil.SetPoint(self.Left, "BOTTOMRIGHT", self, "BOTTOMLEFT", 0, -borderSize, 0, minPixels);

	PixelUtil.SetWidth(self.Right, borderSize, minPixels);
	PixelUtil.SetPoint(self.Right, "TOPLEFT", self, "TOPRIGHT", 0, upwardExtendHeightPixels, 0, upwardExtendHeightMinPixels);
	PixelUtil.SetPoint(self.Right, "BOTTOMLEFT", self, "BOTTOMRIGHT", 0, -borderSize, 0, minPixels);

	PixelUtil.SetHeight(self.Bottom, borderSize, minPixels);
	PixelUtil.SetPoint(self.Bottom, "TOPLEFT", self, "BOTTOMLEFT", 0, 0);
	PixelUtil.SetPoint(self.Bottom, "TOPRIGHT", self, "BOTTOMRIGHT", 0, 0);

	if self.Top then
		PixelUtil.SetHeight(self.Top, borderSize, minPixels);
		PixelUtil.SetPoint(self.Top, "BOTTOMLEFT", self, "TOPLEFT", 0, 0);
		PixelUtil.SetPoint(self.Top, "BOTTOMRIGHT", self, "TOPRIGHT", 0, 0);
	end
end