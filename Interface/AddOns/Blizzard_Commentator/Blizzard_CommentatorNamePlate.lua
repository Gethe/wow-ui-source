
local barHeight = 18;
local customOptions = 
{
	healthBarHeight = barHeight,
	castBarHeight = barHeight,
	castBarFontHeight = 12,
	maxHealOverflowRatio = 1.0,
	ignoreIconSize = true,
	ignoreIconPoint = true,
	ignoreBarSize = true,
	ignoreBarPoints = true,
	ignoreOverAbsorbGlow = true,
	ignoreOverHealAbsorbGlow = true,
	nameFont = SystemFont_LargeNamePlateFixed,
};

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
	self.SetBarPointsOverride = self.OnSetBarPointsOverride;
	self.CommentatorTeamSwapped = self.OnCommentatorTeamSwapped;

	-- We cannot leverage the setup functions or frame functions in Blizzard_Nameplates because many
	-- values are repeatedly overwritten (ex. UpdateNamePlateOptions).
	self.customOptions = customOptions;

	-- Attaching elements to inherited frames and textures to preserve as much of the original
	-- functionality as possible without redefining it in the XML.
	self.castBar.border = CreateFrame("FRAME", nil, self.castBar, "NamePlateFullBorderTemplate");
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
	PixelUtil.SetSize(self.healthBar, 190, barHeight);
	PixelUtil.SetPoint(self.healthBar, "LEFT", self, "LEFT", 0, -10);
	
	self.healthBar:SetFrameLevel(self:GetFrameLevel() - 1);

	self.overAbsorbGlow:ClearAllPoints();
	PixelUtil.SetPoint(self.overAbsorbGlow, "BOTTOMLEFT", self.healthBar, "BOTTOMRIGHT", -8, -1);
	PixelUtil.SetPoint(self.overAbsorbGlow, "TOPLEFT", self.healthBar, "TOPRIGHT", -8, 1);
	PixelUtil.SetHeight(self.overAbsorbGlow, 8);
	
	self.overHealAbsorbGlow:ClearAllPoints();
	--PixelUtil.SetPoint(self.overHealAbsorbGlow, "BOTTOMRIGHT", self.healthBar, "BOTTOMLEFT", 2, -1);
	--PixelUtil.SetPoint(self.overHealAbsorbGlow, "TOPRIGHT", self.healthBar, "TOPLEFT", 2, 1);
	--PixelUtil.SetWidth(self.overHealAbsorbGlow, 8);
	
	PixelUtil.SetWidth(self.castBar, 170, barHeight);
	PixelUtil.SetPoint(self.castBar, "TOP", self.healthBar, "BOTTOM", 0, -6);
	
	self.castBar.Text:ClearAllPoints();
	local iconSize = barHeight + 2;
	local textOffset = iconSize / 2;
	PixelUtil.SetPoint(self.castBar.Text, "CENTER", self.castBar, "CENTER", textOffset, 0);
	
	self.castBar.Icon:ClearAllPoints();
	PixelUtil.SetSize(self.castBar.Icon, iconSize, iconSize);
	PixelUtil.SetPoint(self.castBar.Icon, "TOPLEFT", self.castBar, "TOPLEFT", -1, 1);
	
	self.castBar.border:UpdateSizes();

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

function CommentatorNamePlateMixin:OnSetupOverride()
	self.healthBar:SetStatusBarAtlas("_Bar-mid");
	self.castBar:SetStatusBarAtlas("_Bar-mid");
	self.myHealPrediction:SetAtlas("_Bar-mid");
	self.otherHealPrediction:SetAtlas("_Bar-mid");
	self.myHealAbsorb:SetAtlas("_Bar-mid");
	self.myHealAbsorb:SetVertexColor(21/255, 89/255, 72/255);
	self.totalAbsorb:SetAtlas("_Bar-mid");

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
	self.healthBar.border:SetVertexColor(color.r, color.g, color.b, color.a);
	self.castBar.border:SetVertexColor(color.r, color.g, color.b, color.a);
end

function CommentatorNamePlateMixin:OnUpdateHealthBorderOverride()
	self:SetBorderColors();

	local class = select(2, UnitClass(self.unit))
	self.ClassIcon:SetAtlas(GetClassAtlas(class));

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