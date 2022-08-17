
local mainTextureKitRegions = {
	["Background"] = "CovenantSanctum-Renown-Background-%s",
	["TitleDivider"] = "CovenantSanctum-Renown-Title-Divider-%s",
	["Divider"] = "CovenantSanctum-Renown-Divider-%s",	
	["Anima"] = "CovenantSanctum-Renown-Anima-%s",
	["FinalToastSlabTexture"] = "CovenantSanctum-Renown-FinalToast-%s",
	["SelectedLevelGlow"] = "CovenantSanctum-Renown-Next-Glow-%s",
}
local rewardTextureKitRegions = {
	["Toast"] = "CovenantSanctum-Renown-Toast-%s",
	["IconBorder"] = "CovenantSanctum-Icon-Border-%s",
}
local milestonesTextureKitRegions = {
	["Left"] = "UI-Frame-%s-TitleLeft",
	["Right"] = "UI-Frame-%s-TitleRight",
	["Middle"] = "_UI-Frame-%s-TitleMiddle",
};

local renownAvailableIconTextureKitRegion = {
	["Icon"] = "covenantsanctum-renown-icon-available-%s",
}

local finalToastSwirlEffects = {
	[Enum.CovenantType.Kyrian] = {119},
	[Enum.CovenantType.Venthyr] = {120},
	[Enum.CovenantType.NightFae] = {121, 123},
	[Enum.CovenantType.Necrolord] = {122},
};

local levelEffects = {
	[Enum.CovenantType.Kyrian] = 125,
	[Enum.CovenantType.Venthyr] = 124,
	[Enum.CovenantType.NightFae] = 126,
	[Enum.CovenantType.Necrolord] = 127,
};

local levelEffectDelay = 0.5;

local g_covenantID;
local g_covenantData;

local function SetupTextureKit(frame, regions)
	SetupTextureKitOnRegions(g_covenantData.textureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end

local CovenantRenownEvents = {
	"COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED",
	"COVENANT_RENOWN_CATCH_UP_STATE_UPDATE",
};

CovenantRenownMixin = {};

function CovenantRenownMixin:OnLoad()
	local attributes =
	{
		area = "left",
		pushable = 0,
		allowOtherPanels = 1,
		width = 755,
		height = 540,
	};
	RegisterUIPanel(CovenantRenownFrame, attributes);
	self.FinalToastSlabTexture = self.FinalToast.SlabTexture;

	self.rewardsPool = CreateFramePool("FRAME", self, "CovenantRenownRewardTemplate");
end

function CovenantRenownMixin:OnShow()
	self:SetUpCovenantData();
	self:GetLevels();
	local fromOnShow = true;
	self:Refresh(fromOnShow);
	self:CheckTutorials();
	C_CovenantSanctumUI.RequestCatchUpState();
	FrameUtil.RegisterFrameForEvents(self, CovenantRenownEvents);
	PlaySound(SOUNDKIT.UI_COVENANT_RENOWN_OPEN_WINDOW);
end

function CovenantRenownMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CovenantRenownEvents);
	self:SetCelebrationSwirlEffects(nil);
	self:CancelLevelEffect();
	C_CovenantSanctumUI.EndInteraction();
	PlaySound(SOUNDKIT.UI_COVENANT_RENOWN_CLOSE_WINDOW);

	local cvarName = "lastRenownForCovenant"..g_covenantID;
	SetCVar(cvarName, self.actualLevel);
end

function CovenantRenownMixin:OnEvent(event, ...)
	if event == "COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED" then
		self:Refresh();
	elseif event == "COVENANT_RENOWN_CATCH_UP_STATE_UPDATE" then 
		if(self.HeaderFrame:IsMouseOver()) then 
			CovenantRenownHeaderFrameMixin.OnEnter(self.HeaderFrame);
		end 
		self.HeaderFrame:SetupRenownAvailableIcon(); 
	end
end

function CovenantRenownMixin:OnMouseWheel(direction)
	local track = self.TrackFrame;
	local centerIndex = track:GetCenterIndex();
	centerIndex = centerIndex + (direction * -1);
	local forceRefresh = false;
	local skipSound = false;
	local overrideStopSound = SOUNDKIT.UI_COVENANT_RENOWN_SLIDE_START;
	track:SetSelection(centerIndex, forceRefresh, skipSound, overrideStopSound);
end

function CovenantRenownMixin:SetUpCovenantData()
	local covenantID = C_Covenants.GetActiveCovenantID();
	local covenantData = C_Covenants.GetCovenantData(covenantID);
	if g_covenantID ~= covenantID then
		g_covenantID = covenantID;
		g_covenantData = covenantData;

		local textureKit = covenantData.textureKit;

		NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, textureKit);
		NineSliceUtil.DisableSharpening(self.NineSlice);

		local atlas = "CovenantSanctum-RenownLevel-Border-%s";
		self.HeaderFrame.Background:SetAtlas(atlas:format(textureKit), TextureKitConstants.UseAtlasSize);

		UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-%s-ExitButtonBorder", -1, 1, textureKit);
		
		SetupTextureKit(self, mainTextureKitRegions);

		-- the track
		local renownLevelsInfo = C_CovenantSanctumUI.GetRenownLevels(covenantID);
		for i, levelInfo in ipairs(renownLevelsInfo) do
			levelInfo.rewardInfo = C_CovenantSanctumUI.GetRenownRewardsForLevel(g_covenantID, i);
		end
		self.TrackFrame:Init(renownLevelsInfo);
		self.maxLevel = renownLevelsInfo[#renownLevelsInfo].level;
	end
end

function CovenantRenownMixin:GetLevels()
	local renownLevel = C_CovenantSanctumUI.GetRenownLevel();
	self.actualLevel = renownLevel;	
	local cvarName = "lastRenownForCovenant"..g_covenantID;
	local lastRenownLevel = tonumber(GetCVar(cvarName)) or 1;
	if lastRenownLevel < renownLevel then
		renownLevel = lastRenownLevel;
	end
	self.displayLevel = renownLevel;
end

function CovenantRenownMixin:Refresh(fromOnShow)
	self.HeaderFrame.Level:SetText(self.actualLevel);
	local displayLevel = math.min(self.displayLevel + 1, self.maxLevel);
	self:SetRewards(displayLevel);	
	local forceRefresh = true;
	self:SelectLevel(displayLevel, fromOnShow, forceRefresh);
	self.LevelSkipButton:SetShown((self.actualLevel - self.displayLevel) > 3 );
	if self.displayLevel < self.actualLevel then
		self.levelEffectTimer = C_Timer.NewTimer(levelEffectDelay, function()
			self:PlayLevelEffect();
		end);
	end
	self:CheckTutorials();
end

function CovenantRenownMixin:SelectLevel(level, fromOnShow, forceRefresh)
	local selectionIndex;
	local elements = self.TrackFrame:GetElements();
	for i, frame in ipairs(elements) do
		if frame:GetLevel() == level then
			selectionIndex = i;
			break;
		end
	end
	local skipSound = fromOnShow;
	self.TrackFrame:SetSelection(selectionIndex, forceRefresh, skipSound);
end

function CovenantRenownMixin:OnTrackUpdate(leftIndex, centerIndex, rightIndex, isMoving)
	local track = self.TrackFrame;
	local elements = track:GetElements();
	local selectedElement = elements[centerIndex];
	local selectedLevel = selectedElement:GetLevel();
	if self.displayLevel ~= self.actualLevel and selectedLevel ~= self.displayLevel + 1 then
		self:CancelLevelEffect();
		self:Refresh();
		return;
	end
	local elements = track:GetElements();
	for i = leftIndex, rightIndex do
		local selected = not self.moving and centerIndex == i;
		local frame = elements[i];
		frame:Refresh(self.actualLevel, self.displayLevel, selected);
		local alpha = track:GetDesiredAlphaForIndex(i);
		frame:ApplyAlpha(alpha);
	end
	if not isMoving then
		self:SetRewards(selectedLevel);
		self.SelectedLevelGlow:SetPoint("CENTER", elements[centerIndex]);
		self.SelectedLevelGlow:Show();
	else
		self.SelectedLevelGlow:Hide();
	end
end

function CovenantRenownMixin:OnLevelEffectFinished()
	self.levelEffect = nil;
	self.displayLevel = self.displayLevel + 1;
	self:Refresh();
end

function CovenantRenownMixin:PlayLevelEffect()
	local effectID = levelEffects[g_covenantID];
	local target, onEffectFinish = nil, nil;
	local onEffectResolution = GenerateClosure(self.OnLevelEffectFinished, self);
	self.levelEffect = self.LevelModelScene:AddEffect(effectID, self.TrackFrame, self.TrackFrame, onEffectFinish, onEffectResolution);

	local centerIndex = self.TrackFrame:GetCenterIndex();
	local elements = self.TrackFrame:GetElements();
	local frame = elements[centerIndex];
	local selected = true;
	frame:Refresh(self.actualLevel, self.displayLevel + 1, selected);

	local fanfareSound = g_covenantData.renownFanfareSoundKitID;
	if fanfareSound then
		PlaySound(fanfareSound);
	end
end

function CovenantRenownMixin:CancelLevelEffect()
	self.LevelSkipButton:Hide();
	if self.displayLevel ~= self.actualLevel then
		self.displayLevel = self.actualLevel;
		if self.levelEffect then
			self.levelEffect:CancelEffect();
			self.levelEffect = nil;
		end
		if self.levelEffectTimer then
			self.levelEffectTimer:Cancel();
			self.levelEffectTimer = nil;
		end
		self.displayLevel = self.actualLevel;
	end
end

function CovenantRenownMixin:SetCelebrationSwirlEffects(swirlEffects)
	if swirlEffects == nil then
		self.CelebrationModelScene:ClearEffects();
	elseif not self.CelebrationModelScene:HasActiveEffects() then
		for i, swirlEffect in ipairs(swirlEffects) do
			self.CelebrationModelScene:AddEffect(swirlEffect, self.CelebrationModelSceneTarget);
		end
	end
end

function CovenantRenownMixin:SetRewards(level)
	self.rewardsPool:ReleaseAll();
	local rewards = C_CovenantSanctumUI.GetRenownRewardsForLevel(g_covenantID, level);
	local numRewards = #rewards;

	local renownLevel = C_CovenantSanctumUI.GetRenownLevel();
	local rewardUnlocked = level <= renownLevel;

	for i, rewardInfo in ipairs(rewards) do
		local rewardFrame = self.rewardsPool:Acquire();
		if numRewards == 1 then
			rewardFrame:SetPoint("TOP", 0, -299);
		else
			if i == 1 then
				rewardFrame:SetPoint("TOP", 0, -254);
			elseif i == 2 then
				rewardFrame:SetPoint("TOP", 0, -364);
			end
		end
		rewardFrame:SetReward(rewardInfo, rewardUnlocked, g_covenantData.textureKit, rewardTextureKitRegions);
	end

	if level <= renownLevel then
		self.PreviewText:SetFormattedText(COVENANT_SANCTUM_RENOWN_LEVEL_UNLOCKED, level);
		self.PreviewText:SetTextColor(GREEN_FONT_COLOR:GetRGB());
		self:SetCelebrationSwirlEffects(finalToastSwirlEffects[g_covenantID]);
	else
		self.PreviewText:SetFormattedText(COVENANT_SANCTUM_RENOWN_LEVEL_LOCKED, level);
		self.PreviewText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		self:SetCelebrationSwirlEffects(nil);
	end
end

function CovenantRenownMixin:CheckTutorials()
	-- using acknowledgeOnHide so need to check this
	if not self:IsShown() then
		return;
	end
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_COVENANT_RENOWN_REWARDS) then
		if self.displayLevel == self.actualLevel then
			local helpTipInfo = {
				text = COVENANT_RENOWN_TUTORIAL_REWARDS,
				buttonStyle = HelpTip.ButtonStyle.Close,
				cvarBitfield = "closedInfoFrames",
				bitfieldFlag = LE_FRAME_TUTORIAL_COVENANT_RENOWN_REWARDS,
				targetPoint = HelpTip.Point.RightEdgeCenter,
				offsetX = 94,
				acknowledgeOnHide = true,
				onAcknowledgeCallback = GenerateClosure(self.CheckTutorials, self),
			};
			HelpTip:Show(self, helpTipInfo, self.TrackFrame);
		end
	elseif not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_COVENANT_RENOWN_PROGRESS) then
		local helpTipInfo = {
			text = COVENANT_RENOWN_TUTORIAL_PROGRESS,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_COVENANT_RENOWN_PROGRESS,
			targetPoint = HelpTip.Point.BottomEdgeCenter,
			offsetY = 22,
			acknowledgeOnHide = true,
		};
		HelpTip:Show(self, helpTipInfo, self.HeaderFrame);
	end
end

CovenantRenownRewardMixin = { };

function CovenantRenownRewardMixin:SetReward(rewardInfo, unlocked)
	SetupTextureKit(self, rewardTextureKitRegions);
	self.Check:SetShown(unlocked);
	self.rewardInfo = rewardInfo;
	self:RefreshReward();
	self:Show();
end

function CovenantRenownRewardMixin:RefreshReward()
	local icon, name, description = RenownRewardUtil.GetRenownRewardInfo(self.rewardInfo, GenerateClosure(self.RefreshReward, self));
	self.Icon:SetTexture(icon);
	self.Name:SetText(name);
	self.description = description;
end

function CovenantRenownRewardMixin:OnEnter()
	local name = self.Name:GetText();
	if name and self.description then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -14, -14);
		GameTooltip_SetTitle(GameTooltip, name);
		GameTooltip_AddNormalLine(GameTooltip, self.description);
		GameTooltip:Show();
	end
end

CovenantRenownHeaderFrameMixin = { }; 
function CovenantRenownHeaderFrameMixin:OnEnter()
	local covenantName = g_covenantData.name;
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -40, 130);

	if (C_CovenantSanctumUI.HasMaximumRenown()) then 
		GameTooltip_AddNormalLine(GameTooltip, RENOWN_LEVEL_MAXIMUM:format(covenantName));
	elseif (C_CovenantSanctumUI.IsWeeklyRenownCapped()) then
		GameTooltip_AddNormalLine(GameTooltip, RENOWN_LEVEL_CAUGHT_UP);
	elseif (C_CovenantSanctumUI.IsPlayerInRenownCatchUpMode()) then 
		GameTooltip_AddNormalLine(GameTooltip, RENOWN_LEVEL_CATCH_UP_MODE);
	else 
		GameTooltip_AddNormalLine(GameTooltip, RENOWN_LEVEL_CURRENT);
	end 
	GameTooltip:Show(); 
end 

function CovenantRenownHeaderFrameMixin:OnLeave()
	GameTooltip:Hide();
end 

function CovenantRenownHeaderFrameMixin:SetupRenownAvailableIcon()
	local hasRenownAvailable = not C_CovenantSanctumUI.IsWeeklyRenownCapped() and not C_CovenantSanctumUI.HasMaximumRenown();
	self.Icon:SetShown(hasRenownAvailable);
	SetupTextureKit(self, renownAvailableIconTextureKitRegion);
end 