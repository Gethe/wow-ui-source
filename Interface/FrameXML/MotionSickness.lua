MotionSicknessMixin = {
	landscapeDarkeningMinSpeed = 14,			-- speed at which to start min alpha from 0
	landscapeDarkeningMinAlpha = 0,				-- alpha at min speed
	landscapeDarkeningMaxSpeed = 100,			-- speed at which to hit max alpha
	landscapeDarkeningMaxAlpha = 0.8,			-- alpha at max speed
	landscapeDarkeningUseFixedScale = true,		-- whether to ignore uiScale
	landscapeDarkeningArtScale = 0.75,			-- how to resize the asset
	landscapeDarkeningUseOval = false,			-- whether to use oval asset instead of circle one
	landscapeDarkeningVerticalOffset = 60;		-- vertical offset from center

	focalCircleUseFixedScale = true,			-- whether to ignore uiScale
	focalCircleArtScale = 0.85,					-- how to resize the asset
	focalCircleVerticalOffset = 60,				-- vertical offset from center
	
	landscapeDarkeningCircleAtlas = "motion-sickness-darkening-circle-black",
	landscapeDarkeningOvalAtlas = "motion-sickness-darkening-oval-black",
	focalCircleAtlas = "motion-sickness-reticle",
};

function MotionSicknessMixin:OnLoad()
	EventUtil.ContinueOnVariablesLoaded(
		function()
			self:RegisterEvent("CVAR_UPDATE");
			self:OnCVarChanged();
		end
	);
end

function MotionSicknessMixin:ApplySettings()
	self.FocalCircle:SetAtlas(self.focalCircleAtlas);
	self.FocalCircle:SetPoint("CENTER", 0, self.focalCircleVerticalOffset);
	
	local focalCircleAtlasInfo = C_Texture.GetAtlasInfo(self.focalCircleAtlas);
	self.FocalCircle:SetSize(focalCircleAtlasInfo.width * self.focalCircleArtScale, focalCircleAtlasInfo.height * self.focalCircleArtScale);
	
	self:ApplyDarkening();
end

function MotionSicknessMixin:ApplyDarkening()
	local landscapeDarkeningAtlas = self.landscapeDarkeningUseOval and self.landscapeDarkeningOvalAtlas or self.landscapeDarkeningCircleAtlas;
	self.LandscapeDarkeningCenter:SetAtlas(landscapeDarkeningAtlas, TextureKitConstants.UseAtlasSize);
	self.LandscapeDarkeningCenter:SetPoint("CENTER", 0, self.landscapeDarkeningVerticalOffset);

	local landscapeDarkeningAtlasInfo = C_Texture.GetAtlasInfo(landscapeDarkeningAtlas);
	self.LandscapeDarkeningCenter:SetSize(landscapeDarkeningAtlasInfo.width * self.landscapeDarkeningArtScale, landscapeDarkeningAtlasInfo.height * self.landscapeDarkeningArtScale);

	self:UpdateScale();
end

function MotionSicknessMixin:SetLandscapeDarkeningUseOval(useOval)
	self.landscapeDarkeningUseOval = useOval;
	self:ApplySettings();
end

function MotionSicknessMixin:OnEvent(event, ...)
	if event == "CVAR_UPDATE" then
		local cvar = ...;
		if cvar == "motionSicknessFocalCircle" or "motionSicknessLandscapeDarkening" then
			self:OnCVarChanged(cvar);
		end
	elseif event == "PLAYER_CAN_GLIDE_CHANGED" then
		local eventCanGlide = ...;
		self:UpdateFocalCircle();
		self:UpdateLandscapeDarkening(eventCanGlide);
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UpdateFocalCircle();
		self:UpdateLandscapeDarkening();
	elseif event == "UI_SCALE_CHANGED" then
		self:UpdateScale();
	end
end

function MotionSicknessMixin:UpdateScale()
	if self.focalCircleUseFixedScale then
		local parentScale = UIParent:GetScale();
		self.FocalCircle:SetScale(1 / parentScale);
	end
	if self.landscapeDarkeningUseFixedScale then
		local parentScale = UIParent:GetScale();
		self.LandscapeDarkeningCenter:SetScale(1 / parentScale);
	end	
end

function MotionSicknessMixin:OnUpdate()
	local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo();
	local alpha = 0;

	if forwardSpeed >= self.landscapeDarkeningMaxSpeed then
		alpha = self.landscapeDarkeningMaxAlpha;
	elseif forwardSpeed >= self.landscapeDarkeningMinSpeed then
		local maxDelta = self.landscapeDarkeningMaxSpeed - self.landscapeDarkeningMinSpeed;
		local speed = forwardSpeed - self.landscapeDarkeningMinSpeed;
		alpha = Lerp(self.landscapeDarkeningMinAlpha, self.landscapeDarkeningMaxAlpha, speed/maxDelta);
	end

	for i, texture in ipairs(self.LandscapeDarkeningTextures) do
		texture:SetAlpha(alpha);
	end

	local showFocalCircle = self.focalCircle and forwardSpeed > 0;
	self.FocalCircle:SetShown(showFocalCircle);
end

function MotionSicknessMixin:UpdateFocalCircle()
	local doShow = self.focalCircle and (select(3, C_PlayerInfo.GetGlidingInfo()) > 0);
	self.FocalCircle:SetShown(doShow);
end

function MotionSicknessMixin:OnCVarChanged(cvar)
	if not cvar or cvar == "motionSicknessFocalCircle" then
		self.focalCircle = GetCVarBool("motionSicknessFocalCircle");
	end

	if not cvar or cvar == "motionSicknessLandscapeDarkening" then
		self.landscapeDarkening = GetCVarBool("motionSicknessLandscapeDarkening");
	end

	if self.focalCircle or self.landscapeDarkening then
		if not self.init then
			self:ApplySettings();
			self.init = true;
		end
		self:RegisterEvent("PLAYER_CAN_GLIDE_CHANGED");
		self:RegisterEvent("UI_SCALE_CHANGED");
		self:RegisterEvent("PLAYER_ENTERING_WORLD");
	else
		self:UnregisterEvent("PLAYER_CAN_GLIDE_CHANGED");
		self:UnregisterEvent("UI_SCALE_CHANGED");
		self:UnregisterEvent("PLAYER_ENTERING_WORLD");
	end

	if not cvar or cvar == "motionSicknessFocalCircle" then
		self:UpdateFocalCircle();
	end
	if not cvar or cvar == "motionSicknessLandscapeDarkening" then
		self:UpdateLandscapeDarkening();
	end
end

function MotionSicknessMixin:UpdateLandscapeDarkening(eventCanGlide)
	local doShow = false;
	if self.landscapeDarkening then
		local isGliding, canGlide, forwardSpeed = C_PlayerInfo.GetGlidingInfo();

		if eventCanGlide == nil then
			doShow = canGlide;
		else
			doShow = eventCanGlide
		end
	end

	if doShow then
		for i, texture in ipairs(self.LandscapeDarkeningTextures) do
			texture:SetAlpha(0);
			texture:Show();
		end
		self:SetScript("OnUpdate", self.OnUpdate);	
	else
		for i, texture in ipairs(self.LandscapeDarkeningTextures) do
			texture:Hide();
		end
		self:SetScript("OnUpdate", nil);
	end	
end