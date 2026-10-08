
function TargetFrameMixin:OnLoad(unit, menuFunc)
	self:OnLoadBase(unit, menuFunc);

	-- Prevent Mainline standard localization overrides from changing the position of the level and name.
	self.TargetFrameContent.TargetFrameContentMain.skipLevelAndNameTextLocalizationAdjustment = true;

	local levelBackgroundCircle	= self.TargetFrameContent.TargetFrameContentMain.LevelBackgroundCircle;
	local levelText	= self.TargetFrameContent.TargetFrameContentMain.LevelText;
	levelText:ClearAllPoints();
	levelText:SetPoint("CENTER", levelBackgroundCircle, "CENTER", 0, -0.5);

	levelBackgroundCircle:Show();

	-- Since the level text is moved to the bottom right corner of the frame, move the name to the left so it can display longer names before truncating.
	local nameFrame = self.TargetFrameContent.TargetFrameContentMain.Name;
	nameFrame:SetWidth(117);
	nameFrame:ClearAllPoints();
	nameFrame:SetPoint("TOPLEFT", self.TargetFrameContent.TargetFrameContentMain.ReputationColor, "TOPRIGHT", -133, -1);

	local highLeveTexture = self.TargetFrameContent.TargetFrameContentContextual.HighLevelTexture;
	highLeveTexture:ClearAllPoints();
	highLeveTexture:SetPoint("CENTER", levelBackgroundCircle, "CENTER", 0, 0);
end

-- Overridden per game type to point UnitFrameUtil at whichever regions that flavor actually renders.
function TargetFrameMixin:GetPvPIndicatorElements()
	local targetFrameContentContextual = self.TargetFrameContent.TargetFrameContentContextual;
	return {
		pvpBackground = targetFrameContentContextual.PvpBackgroundCircle,
		pvpIcon = targetFrameContentContextual.PvpBackgroundIcon,
	};
end

function TargetFrameMixin:IsPvPBackgroundShown()
	for key, region in pairs(self:GetPvPIndicatorElements()) do
		if region:IsShown() then
			return true;
		end
	end
	return false;
end

function TargetFrameMixin:GetPortrait()
	return self.TargetFrameContainer.Portrait;
end
