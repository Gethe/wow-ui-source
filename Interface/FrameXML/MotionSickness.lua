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
	self.focalCircle = false;
	self.landscapeDarkening = false;
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
		local canGlide = ...;
		self:FullUpdate(canGlide);
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:FullUpdate();
	elseif event == "UI_SCALE_CHANGED" then
		self:UpdateScale();
	end
end

function MotionSicknessMixin:FullUpdate(canGlide)
	if canGlide == nil then
		canGlide = select(2, C_PlayerInfo.GetGlidingInfo());
	end

	if canGlide then
		self:SetScript("OnUpdate", self.OnUpdate);
	else
		self:SetScript("OnUpdate", nil);
	end
	self:UpdateLandscapeDarkening(canGlide);
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

function MotionSicknessMixin:OnCVarChanged(cvar)
	local hasChange = false;

	if not cvar or cvar == "motionSicknessFocalCircle" then
		local oldFocalCircle = self.focalCircle;
		self.focalCircle = GetCVarBool("motionSicknessFocalCircle");
		if oldFocalCircle ~= self.focalCircle then
			hasChange = true;
		end
	end

	if not cvar or cvar == "motionSicknessLandscapeDarkening" then
		local oldLandscapeDarkening = self.landscapeDarkening;
		self.landscapeDarkening = GetCVarBool("motionSicknessLandscapeDarkening");
		if oldLandscapeDarkening ~= self.landscapeDarkening then
			hasChange = true;
		end
	end

	if not hasChange then
		return;
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

	self:FullUpdate();
end

function MotionSicknessMixin:UpdateLandscapeDarkening(canGlide)
	local doShow = false;
	if self.landscapeDarkening then	
		doShow = canGlide;
	end

	if doShow then
		for i, texture in ipairs(self.LandscapeDarkeningTextures) do
			texture:SetAlpha(0);
			texture:Show();
		end
	else
		for i, texture in ipairs(self.LandscapeDarkeningTextures) do
			texture:Hide();
		end
	end	
end