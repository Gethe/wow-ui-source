local customOptions = 
{
	maxHealOverflowRatio = 1.0,
	ignoreOverAbsorbGlow = true,
	ignoreOverHealAbsorbGlow = true,
};

CommentatorNamePlateMixin = {}

function CommentatorNamePlateMixin:OnLoad()
	NamePlateUnitFrameMixin.OnLoad(self);
	
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
	self.UpdateNameOverride = self.OnUpdateNameOverride;
	self.UpdateHealthBorderOverride = self.OnUpdateHealthBorderOverride;

	-- We cannot leverage the setup functions or frame functions in Blizzard_Nameplates because many
	-- values are repeatedly overwritten (ex. UpdateNamePlateOptions).
	self.customOptions = customOptions;

	-- Attaching elements to inherited frames and textures to preserve as much of the original
	-- functionality as possible without redefining it in the XML.
	self.castBar.border = CreateFrame("FRAME", nil, self.castBar, "NamePlateFullBorderTemplate");
end

function CommentatorNamePlateMixin:OnEvent(event, ...)
	NamePlateUnitFrameMixin.OnEvent(self, event, ...);

	if event == "COMMENTATOR_TEAMS_SWAPPED" then
		self:SetBorderColors();
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

function CommentatorNamePlateMixin:UpdateAnchors()
	NamePlateUnitFrameMixin.UpdateAnchors(self);

	self.teamBorder:ClearAllPoints();
	PixelUtil.SetPoint(self.teamBorder, "TOPLEFT", self.HealthBarsContainer.selectedBorder, "TOPLEFT", 0, 0);
	PixelUtil.SetPoint(self.teamBorder, "BOTTOMRIGHT", self.HealthBarsContainer.selectedBorder, "BOTTOMRIGHT", 0, 0);

	self.castBar.border:UpdateSizes();

	self.ClassIcon:ClearAllPoints();
	PixelUtil.SetPoint(self.ClassIcon, "RIGHT", self.ClassificationFrame, "LEFT", 0, 0);

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

	PixelUtil.SetPoint(self.AurasFrame.BuffListFrame, "RIGHT", self.ClassIcon, "LEFT", -5, 0);
end

function CommentatorNamePlateMixin:OnUpdateNameOverride()
	self:UpdateNameText();

	-- CAF cannot continue.
	return true;
end

function CommentatorNamePlateMixin:SetBorderColors()
	local color = C_Commentator.GetTeamColorByUnit(self.unit);
	self.teamBorder:SetVertexColor(color.r, color.g, color.b, color.a);
	self.castBar.border:SetVertexColor(color.r, color.g, color.b, color.a);
end

function CommentatorNamePlateMixin:OnUpdateHealthBorderOverride()
	self:SetBorderColors();

	local class = select(2, UnitClass(self.unit))
	self.ClassIcon:SetAtlas(GetClassAtlas(class));

	-- CUF cannot continue.
	return true;
end

function CommentatorNamePlateMixin:UpdateCrowdControlAuras()
	local spellID, expirationTime, duration = C_Commentator.GetPlayerCrowdControlInfoByUnit(self.unit);
	local hasCC = spellID and expirationTime;
	if hasCC and self.ccSpellID ~= spellID then
		self.CCCooldown:SetCooldown(expirationTime - duration, duration);

		if spellID ~= nil then
			local icon = C_Spell.GetSpellTexture(spellID);
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
