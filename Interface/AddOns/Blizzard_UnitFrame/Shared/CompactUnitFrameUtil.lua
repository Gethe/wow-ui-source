
-- Copied from CompactUnitFrame.lua
local NATIVE_UNIT_FRAME_DEBUFF_SCALE_MIN = 0.5;
local NATIVE_UNIT_FRAME_DEBUFF_SCALE_MAX = 2;
local NATIVE_UNIT_FRAME_BUFF_SCALE_MIN = 0.5;
local NATIVE_UNIT_FRAME_BUFF_SCALE_MAX = 2;

CompactUnitFrameUtil = {};

CompactUnitFrameUtil.NativeFrameWidth = 72;
CompactUnitFrameUtil.NativeFrameHeight = 36;
CompactUnitFrameUtil.PowerBarHeight = 8;
CompactUnitFrameUtil.DispelDebuffSize = 14;
CompactUnitFrameUtil.FrameInset = 1;
CompactUnitFrameUtil.AbsorbGlowOffset = 7;
CompactUnitFrameUtil.AbsorbGlowWidth = 16;
CompactUnitFrameUtil.StatusTextInset = 3;

local DEFAULT_OPTION_TABLE = CopyTable(DefaultCompactUnitFrameOptions);

local DEFAULT_CONFIG = {
	alpha = 1,

	-- Note: groupType is used to index edit mode and override frameWidth, frameHeight, and auraScale
	groupType = nil,
	frameWidth = CompactUnitFrameUtil.NativeFrameWidth,
	frameHeight = CompactUnitFrameUtil.NativeFrameHeight,
	auraSize = 11,
	debuffAuraScale = 1,
	buffAuraScale = 1,

	displayPowerBar = true,
	displayOnlyHealerPowerBars = false,

	maxBuffs = 6,
	maxDebuffs = 5,
	maxDispelDebuffs = 3,

	centerStatusIconSize = 22,

	optionTable = DEFAULT_OPTION_TABLE;
};

local function SetupAbsorbElement(element, ...)
	if element then
		element:ClearAllPoints();
		SetTextureWithAddressModeOptions(element, ...);
	end
end

local function ScaleFontString(fontString, scale)
	local fontSize = select(2, fontString:GetFont());
	if not fontString.cachedBaseFontSize then
		fontString.cachedBaseFontSize = fontSize;
	end

	local newSize = fontString.cachedBaseFontSize * scale;
	fontString:SetFontHeight(newSize);
	fontString:SetHeight(newSize);
end

local function GetDebuffIconScale(config)
	return Clamp(EditModeManagerFrame:GetRaidFrameIconScale(config.groupType, config.debuffAuraScale), NATIVE_UNIT_FRAME_DEBUFF_SCALE_MIN, NATIVE_UNIT_FRAME_DEBUFF_SCALE_MAX);
end

local function GetBuffIconScale(config)
	return Clamp(EditModeManagerFrame:GetRaidFrameIconScale(config.groupType, config.buffAuraScale), NATIVE_UNIT_FRAME_BUFF_SCALE_MIN, NATIVE_UNIT_FRAME_BUFF_SCALE_MAX);
end

local function GetFrameSize(config)
	local frameWidth = EditModeManagerFrame:GetRaidFrameWidth(config.groupType, config.frameWidth);
	local frameHeight = EditModeManagerFrame:GetRaidFrameHeight(config.groupType, config.frameHeight);
	return frameWidth, frameHeight;
end

local function GetComponentScale(frame)
	-- We scale certain components for frames that are bigger relative to the default.
	local frameWidth, frameHeight = frame:GetSize();
	return min(frameHeight / DEFAULT_CONFIG.frameHeight, frameWidth / DEFAULT_CONFIG.frameWidth);
end

-- config fields:
--		groupType (enum)
--		frameWidth (number)
--		frameHeight (number)
local function ApplySize(frame, config)
	local frameWidth, frameHeight = GetFrameSize(config);
	frame:SetSize(frameWidth, frameHeight);
end

--	config fields:
--		displayPowerBar (bool)
--		displayOnlyHealerPowerBars (bool)
local function ApplyPowerBarLayout(frame, config)
	frame.powerBarUsedHeight = 0;

	local powerBar = frame.powerBar;
	if not powerBar then
		return;
	end

	if not config.displayPowerBar then
		powerBar:Hide();
		return;
	end

	local role = UnitGroupRolesAssigned(frame.unit);
	if config.displayOnlyHealerPowerBars and (role ~= "HEALER") then
		powerBar:Hide();
		return;
	end

	powerBar:Show();
	frame.powerBarUsedHeight = CompactUnitFrameUtil.PowerBarHeight;

	powerBar:GetStatusBarTexture():SetDrawLayer("BORDER");

	local displayBorder = EditModeManagerFrame:ShouldRaidFrameDisplayBorder(config.groupType);
	local borderGap = displayBorder and -2 or 0;
	powerBar:SetPoint("TOPLEFT", frame.healthBar, "BOTTOMLEFT", 0, borderGap);
	powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -CompactUnitFrameUtil.FrameInset, CompactUnitFrameUtil.FrameInset);
end

local function ApplyHealthBarLayout(frame)
	local healthBar = frame.healthBar;
	local powerBarUsedHeight = frame.powerBarUsedHeight or 0;
	local bottom = CompactUnitFrameUtil.FrameInset + powerBarUsedHeight;
	healthBar:SetPoint("TOPLEFT", frame, "TOPLEFT", CompactUnitFrameUtil.FrameInset, -CompactUnitFrameUtil.FrameInset);
	healthBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -CompactUnitFrameUtil.FrameInset, bottom);
	frame.TempMaxHealthLoss:SetShouldAdjustHealthBarAnchor(-1, bottom);
	frame.TempMaxHealthLoss:InitializeMaxHealthLossBar(frame, frame.healthBar);
end

local function ApplyHealPredictionLayout(frame)
	frame.myHealPrediction:ClearAllPoints();
	frame.myHealPrediction:SetColorTexture(CUF_MY_HEAL_PREDICTION_COLOR:GetRGBA());

	frame.otherHealPrediction:ClearAllPoints();
	frame.otherHealPrediction:SetColorTexture(CUF_OTHER_HEAL_PREDICTION_COLOR:GetRGBA());

	frame.myHealAbsorbLeftShadow:ClearAllPoints();
end

-- config fields:
--		groupType (enum)
local function ApplyAuraOrganizationType(frame, config)
	local auraOrganizationType = EditModeManagerFrame:GetRaidFrameAuraOrganizationType(config.groupType);
	CompactUnitFrameLayoutTemplates_LayoutFrameElement(frame, frame.roleIcon, auraOrganizationType, "Role");
	CompactUnitFrameLayoutTemplates_LayoutFrameElement(frame, frame.name, auraOrganizationType, "Name");
end

local function ApplyAbsorbBarLayout(frame)
	SetupAbsorbElement(frame.myHealAbsorb, "raidframe-absorb-fill", TextureKitConstants.IgnoreAtlasSize, TextureKitConstants.AddressModeWrap, TextureKitConstants.AddressModeWrap);
	SetupAbsorbElement(frame.myHealAbsorbOverlay, "RaidFrame-Absorb-Overlay", TextureKitConstants.IgnoreAtlasSize, TextureKitConstants.AddressModeWrap, TextureKitConstants.AddressModeWrap);
	SetupAbsorbElement(frame.totalAbsorb, "raidframe-shield-fill", TextureKitConstants.IgnoreAtlasSize, TextureKitConstants.AddressModeWrap, TextureKitConstants.AddressModeWrap);
	SetupAbsorbElement(frame.totalAbsorbOverlay, "RaidFrame-Shield-Overlay", TextureKitConstants.IgnoreAtlasSize, TextureKitConstants.AddressModeWrap, TextureKitConstants.AddressModeWrap);
	SetupAbsorbElement(frame.overAbsorbGlow, "RaidFrame-Shield-Overshield", TextureKitConstants.IgnoreAtlasSize, TextureKitConstants.AddressModeClamp, TextureKitConstants.AddressModeClamp);
	SetupAbsorbElement(frame.overHealAbsorbGlow, "RaidFrame-Absorb-Overabsorb", TextureKitConstants.IgnoreAtlasSize, TextureKitConstants.AddressModeClamp, TextureKitConstants.AddressModeClamp);
	SetupAbsorbElement(frame.TempMaxHealthLoss:GetStatusBarTexture(), "raidframe-MaximumHealthReduction-Overlay", TextureKitConstants.IgnoreAtlasSize, TextureKitConstants.AddressModeWrap, TextureKitConstants.AddressModeWrap);

	frame.totalAbsorb.overlay = frame.totalAbsorbOverlay;
	frame.totalAbsorbOverlay:SetAllPoints(frame.totalAbsorb);

	if frame.myHealAbsorbOverlay then
		frame.myHealAbsorbOverlay:SetAllPoints(frame.myHealAbsorb);
	end

	frame.overAbsorbGlow:SetBlendMode("ADD");
	frame.overAbsorbGlow:SetPoint("BOTTOMLEFT", frame.healthBar, "BOTTOMRIGHT", -CompactUnitFrameUtil.AbsorbGlowOffset, 0);
	frame.overAbsorbGlow:SetPoint("TOPLEFT", frame.healthBar, "TOPRIGHT", -CompactUnitFrameUtil.AbsorbGlowOffset, 0);
	frame.overAbsorbGlow:SetWidth(CompactUnitFrameUtil.AbsorbGlowWidth);

	frame.overHealAbsorbGlow:SetBlendMode("ADD");
	frame.overHealAbsorbGlow:SetPoint("BOTTOMRIGHT", frame.healthBar, "BOTTOMLEFT", CompactUnitFrameUtil.AbsorbGlowOffset, 0);
	frame.overHealAbsorbGlow:SetPoint("TOPRIGHT", frame.healthBar, "TOPLEFT", CompactUnitFrameUtil.AbsorbGlowOffset, 0);
	frame.overHealAbsorbGlow:SetWidth(CompactUnitFrameUtil.AbsorbGlowWidth);
end

local function ApplyStatusTextLayout(frame)
	local componentScale = GetComponentScale(frame);
	ScaleFontString(frame.statusText, componentScale);

	local frameHeight = frame:GetHeight();
	local yOffset = frameHeight / 3 - 2;

	frame.statusText:ClearAllPoints();
	frame.statusText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", CompactUnitFrameUtil.StatusTextInset, yOffset);
	frame.statusText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -CompactUnitFrameUtil.StatusTextInset, yOffset);
end

local function ApplyReadyCheckLayout(frame)
	local componentScale = GetComponentScale(frame);
	local readyCheckSize = 20 * componentScale;
	frame.readyCheckIcon:SetSize(readyCheckSize, readyCheckSize);

	local frameHeight = frame:GetHeight();
	local yOffset = frameHeight / 3 - 4;

	frame.readyCheckIcon:ClearAllPoints();
	frame.readyCheckIcon:SetPoint("BOTTOM", frame, "BOTTOM", 0, yOffset);
end

--	config fields:
--		maxBuffs (number)
--		maxDebuffs (number)
--		maxDispelDebuffs (number)
--		groupType (enum)
--		debuffAuraScale (number)
--		buffAuraScale (number)
--		auraSize (number)
--		frameWidth (number)
--		frameHeight (number)
--		centerStatusIconSize (number)
local function ApplyAuraLayout(frame, config)
	CompactUnitFrame_SetMaxBuffs(frame, config.maxBuffs);
	CompactUnitFrame_SetMaxDebuffs(frame, config.maxDebuffs);
	CompactUnitFrame_SetMaxDispelDebuffs(frame, config.maxDispelDebuffs);

	local debuffIconScale = GetDebuffIconScale(config);
	local debuffAuraSize = config.auraSize * debuffIconScale;
	local buffIconScale = GetBuffIconScale(config);
	local buffAuraSize = config.auraSize * buffIconScale;
	local componentScale = GetComponentScale(frame);
	local powerBarUsedHeight = frame.powerBarUsedHeight or 0;
	local auraOrganizationType = EditModeManagerFrame:GetRaidFrameAuraOrganizationType(config.groupType);

	frame:SetDebuffBorderScale(debuffIconScale);
	frame:SetDebuffAuraSize(debuffAuraSize);
	frame:SetBuffBorderScale(buffIconScale);
	frame:SetBuffAuraSize(buffAuraSize);
	frame:SetBigDefensiveAuraSize(config.centerStatusIconSize * componentScale);
	frame:SetAuraOrganizationType(auraOrganizationType);
	frame:SetPowerBarUsedHeight(powerBarUsedHeight);

	local forceUpdatePrivateAuras = true;
	frame:UpdatePrivateAuras(forceUpdatePrivateAuras);
end

--	config fields:
--		groupType (enum)
--		frameWidth (number)
--		frameHeight (number)
--		centerStatusIconSize (number)
local function ApplyCenterStatusIconLayout(frame, config)
	local componentScale = GetComponentScale(frame);
	local size = config.centerStatusIconSize * componentScale;

	frame.centerStatusIcon:SetSize(size, size);
end

function CompactUnitFrameUtil.GenerateNewConfig(configOptions)
	setmetatable(configOptions, { __index = DEFAULT_CONFIG });
	return configOptions;
end

-- Intended to be passed to CompactUnitFrame_SetUpFrame as the setup callback:
--   CompactUnitFrame_SetUpFrame(frame, CompactUnitFrameUtil.ApplyConfig, myConfigTable);
-- See CompactUnitFrameUtil.GenerateNewConfig to generate your own config.
-- This is an extensible replacement for DefaultCompactUnitFrameSetup which relies on specific
-- branching partially based on inspecting the frame. Eventually this could replace DefaultCompactUnitFrameSetup
-- entirely, but until we set up proper configs for existing usages this is just an option for new code.
function CompactUnitFrameUtil.ApplyConfig(frame, config)
	config = config or DEFAULT_CONFIG;

	frame:SetAlpha(config.alpha);

	ApplySize(frame, config);

	-- Power bar must be applied first; it determines frame.powerBarUsedHeight.
	ApplyPowerBarLayout(frame, config);
	ApplyHealthBarLayout(frame);
	ApplyHealPredictionLayout(frame);
	ApplyAbsorbBarLayout(frame);
	ApplyAuraOrganizationType(frame, config);
	ApplyStatusTextLayout(frame);
	ApplyReadyCheckLayout(frame);
	ApplyAuraLayout(frame, config);
	ApplyCenterStatusIconLayout(frame, config);

	-- We need to call our setup function on UpdateAll since our config depends on the unit assigned into the frame
	-- This is specifically for deciding whether to show the power bar due to settings like displayOnlyHealerPowerBars
	frame.updateAllSetupFuncArg = config;
	frame.updateAllSetupFunc = CompactUnitFrameUtil.ApplyConfig;

	CompactUnitFrame_SetOptionTable(frame, config.optionTable);
end
