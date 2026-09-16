
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

function TargetFrameMixin:ShowPrestigeLevel(parentFrame, factionGroup, honorRewardInfo)
	self:ShowPvPIcon(parentFrame, factionGroup);
end

function TargetFrameMixin:ShowPvPIcon(parentFrame, factionGroup)
	local pvpBG = parentFrame.PvpBackgroundCircle;
	local pvpIcon = parentFrame.PvpBackgroundIcon;

	pvpBG:SetScale(0.8);
	pvpIcon:SetScale(0.8);
	pvpBG:SetPoint("TOP", pvpBG:GetParent(), "TOPRIGHT", -23, -50);
	pvpIcon:SetPoint("CENTER", pvpBG, "CENTER", 0, 0);

	if (factionGroup == "Horde") then
		pvpIcon:SetAtlas("UI-HUD-UnitFrame-SmallCircle-Horde", TextureKitConstants.UseAtlasSize);
	elseif (factionGroup == "Alliance") then
		pvpIcon:SetAtlas("UI-HUD-UnitFrame-SmallCircle-Alliance", TextureKitConstants.UseAtlasSize);
	elseif (factionGroup == "FFA" or factionGroup == "Neutral" or factionGroup == "neutral") then
		pvpIcon:SetAtlas("UI-HUD-UnitFrame-Player-PVP-FFAIcon", TextureKitConstants.UseAtlasSize);
	end

	pvpBG:Show();
	pvpIcon:Show();
end

function TargetFrameMixin:HidePvPFrames(parentFrame)
	parentFrame.PvpBackgroundIcon:Hide();
	parentFrame.PvpBackgroundCircle:Hide();
end

-- Camelot renders its PvP badge into its own PvpBackground regions, not the Mainline-only PrestigePortrait/PvpIcon
-- regions that UnitFrameUtil.UpdateUnitPvPIndicator targets, so this reimplements the pre-UnitFrameUtil update logic.
function TargetFrameMixin:CheckFaction()
	if (not UnitPlayerControlled(self.unit) and UnitIsTapDenied(self.unit)) then
		self.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetVertexColor(0.5, 0.5, 0.5);
		if (self.TargetFrameContainer.Portrait) then
			self.TargetFrameContainer.Portrait:SetVertexColor(0.5, 0.5, 0.5);
		end
	else
		self.TargetFrameContent.TargetFrameContentMain.ReputationColor:SetVertexColor(UnitSelectionColor(self.unit));
		if (self.TargetFrameContainer.Portrait) then
			self.TargetFrameContainer.Portrait:SetVertexColor(1.0, 1.0, 1.0);
		end
	end

	local unitFramePvPContextualDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.UnitFramePvPContextualDisabled);
	if (self.showPVP and (not unitFramePvPContextualDisabled)) then
		local factionGroup = UnitFactionGroup(self.unit);
		local targetFrameContentContextual = self.TargetFrameContent.TargetFrameContentContextual;
		if (UnitIsPVPFreeForAll(self.unit)) then
			local honorLevel = UnitHonorLevel(self.unit);
			local honorRewardInfo = C_PvP.GetHonorRewardInfo(honorLevel);
			if (honorRewardInfo) then
				self:ShowPrestigeLevel(targetFrameContentContextual, "neutral", honorRewardInfo);
			else
				self:ShowPvPIcon(targetFrameContentContextual, "FFA");
			end
		elseif (factionGroup and factionGroup ~= "Neutral" and UnitIsPVP(self.unit)) then
			local honorLevel = UnitHonorLevel(self.unit);
			local honorRewardInfo = C_PvP.GetHonorRewardInfo(honorLevel);
			if (honorRewardInfo) then
				self:ShowPrestigeLevel(targetFrameContentContextual, factionGroup, honorRewardInfo);
			else
				self:ShowPvPIcon(targetFrameContentContextual, factionGroup);
			end
		else
			self:HidePvPFrames(targetFrameContentContextual);
		end
	end
end

