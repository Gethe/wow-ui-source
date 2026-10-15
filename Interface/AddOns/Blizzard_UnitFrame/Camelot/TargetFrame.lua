--
-- Target Frame
--

function TargetFrameMixin:OnLoad(unit, menuFunc)
	self:OnLoadBase(unit, menuFunc);

	local targetFrameContentMain = self.TargetFrameContent.TargetFrameContentMain;

	-- Prevent Mainline standard localization overrides from changing the position of the level and name.
	targetFrameContentMain.skipLevelAndNameTextLocalizationAdjustment = true;

	-- Since the level text is moved to the bottom right corner of the frame, move the name to the left so it can display longer names before truncating.
	local nameFrame = targetFrameContentMain.Name;
	local reputationColor = targetFrameContentMain.ReputationColor;
	nameFrame:SetJustifyH("CENTER");
	nameFrame:SetWidth(117);
	nameFrame:ClearAllPoints();
	nameFrame:SetPoint("TOPLEFT", reputationColor, "TOPRIGHT", -133, -4);

	reputationColor:ClearAllPoints();
	reputationColor:SetPoint("TOPRIGHT", targetFrameContentMain, "TOPRIGHT", -75, -26);

	local manaBar = targetFrameContentMain.ManaBar;
	manaBar:SetWidth(134);
	manaBar:ClearAllPoints();
	manaBar:SetPoint("TOPRIGHT", targetFrameContentMain.HealthBarsContainer, "BOTTOMRIGHT", 4, -1);
	manaBar.RightText:ClearAllPoints();
	manaBar.RightText:SetPoint("RIGHT", manaBar, "RIGHT", -3, 0);

	local levelBackgroundCircle	= targetFrameContentMain.LevelBackgroundCircle;
	local levelText	= targetFrameContentMain.LevelText;
	levelText:ClearAllPoints();
	levelText:SetPoint("CENTER", levelBackgroundCircle, "CENTER", 0, -0.5);
	levelBackgroundCircle:Show();

	local highLeveTexture = self.TargetFrameContent.TargetFrameContentContextual.HighLevelTexture;
	highLeveTexture:ClearAllPoints();
	highLeveTexture:SetPoint("CENTER", levelBackgroundCircle, "CENTER", 0, 0);

	local flash = self.TargetFrameContainer.Flash;
	flash:ClearAllPoints();
	flash:SetPoint("CENTER", TargetFrame.TargetFrameContainer, "CENTER", -1, 1);
end

-- Overridden per game type to point UnitFrameUtil at whichever regions that flavor actually renders.
function TargetFrameMixin:GetPvPIndicatorElements()
	local targetFrameContentContextual = self.TargetFrameContent.TargetFrameContentContextual;
	return {
		pvpIcon = targetFrameContentContextual.PvpBackgroundIcon,
	};
end

function TargetFrameMixin:ArePvPElementsShown()
	for _key, region in pairs(self:GetPvPIndicatorElements()) do
		if region:IsShown() then
			return true;
		end
	end
	return false;
end

function TargetFrameMixin:GetPortrait()
	return self.TargetFrameContainer.Portrait;
end

function TargetFrameMixin:UpdateHealthBarVisuals(classification)
	local healthBarsContainer = self.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer;
	local healthBar = healthBarsContainer.HealthBar;

	healthBarsContainer.TempMaxHealthLoss.TempMaxHealthLossTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-TempHPLoss", TextureKitConstants.UseAtlasSize);
	healthBar.HealthBarTexture:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health", TextureKitConstants.UseAtlasSize);
	healthBar:ClearAllPoints();
	healthBar:SetPoint("TOPLEFT", healthBarsContainer, "TOPLEFT", 0, 3);
	healthBarsContainer:SetHeight(15);
	healthBarsContainer:SetWidth(126);
	healthBarsContainer:SetPoint("BOTTOMRIGHT", self.TargetFrameContainer, "LEFT", 147, -9);

	healthBarsContainer.HealthBarMask:SetAtlas("UI-HUD-UnitFrame-Target-PortraitOn-Bar-Health-Mask", TextureKitConstants.UseAtlasSize);
	healthBarsContainer.HealthBarMask:SetPoint("TOPLEFT", -1, 9);
end

--
-- Target of Target Frame
--

function TargetOfTargetMixin:OnLoad()
	self:OnLoadBase();

	self.Name:SetJustifyH("CENTER");
	self.Name:ClearAllPoints();
	self.Name:SetPoint("TOPLEFT", self.Portrait, "TOPRIGHT", 2, -1);

	self.HealthBar:ClearAllPoints();
	self.HealthBar:SetPoint("BOTTOMRIGHT", self, "RIGHT", -5, -3);
	self.HealthBar.HealthBarMask:ClearAllPoints();
	self.HealthBar.HealthBarMask:SetPoint("TOPLEFT", self.HealthBar, "TOPLEFT", -26, 3);

	self.ManaBar:SetWidth(74);
	self.ManaBar:SetHeight(7);
	self.ManaBar:ClearAllPoints();
	self.ManaBar:SetPoint("TOPLEFT", self.HealthBar, "BOTTOMLEFT", -2, -2);
end