
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
	"COVENANT_RENOWN_INTERACTION_ENDED",
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
	
	self:RegisterEvent("COVENANT_RENOWN_INTERACTION_STARTED");

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
	elseif event == "COVENANT_RENOWN_INTERACTION_STARTED" then
		ShowUIPanel(self);
	elseif event == "COVENANT_RENOWN_INTERACTION_ENDED" then
		HideUIPanel(self);
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
		local levels = C_CovenantSanctumUI.GetRenownLevels(covenantID);
		self.TrackFrame:Init(#levels);
		local elements = self.TrackFrame:GetElements();
		for i, levelInfo in ipairs(levels) do
			elements[i]:SetInfo(levels[i]);
		end
		self.maxLevel = levels[#levels].level;
	end
end

function CovenantRenownMixin:GetLevels()
	local renownLevel = C_CovenantSanctumUI.GetRenownLevel();
	self.actualLevel = renownLevel;	
	local cvarName = "lastRenownForCovenant"..g_covenantID;
	local lastRenownLevel = tonumber(GetCVar(cvarName));
	if lastRenownLevel < renownLevel then
		renownLevel = lastRenownLevel;
	end
	self.displayLevel = renownLevel;
end

function CovenantRenownMixin:Refresh(fromOnShow)
	self.HeaderFrame.Level:SetText(self.actualLevel);
	local displayLevel = math.min(self.displayLevel + 1, self.maxLevel);
	self:SetRewards(displayLevel);
	self:SelectLevel(displayLevel, fromOnShow);
	if self.displayLevel < self.actualLevel then
		self.levelEffectTimer = C_Timer.NewTimer(levelEffectDelay, function()
			self:PlayLevelEffect();
		end);
	end
	self:CheckTutorials();
end

function CovenantRenownMixin:SelectLevel(level, fromOnShow)
	local selectionIndex;
	local elements = self.TrackFrame:GetElements();
	for i, frame in ipairs(elements) do
		if frame:GetLevel() == level then
			selectionIndex = i;
			break;
		end
	end
	local forceRefresh = false;
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
		rewardFrame:SetReward(rewardInfo, rewardUnlocked);
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

CovenantRenownLevelMixin = { };

function CovenantRenownLevelMixin:SetInfo(info)
	self.info = info;
	self.init = false;
end

function CovenantRenownLevelMixin:GetLevel()
	return self.info and self.info.level or 0;
end

function CovenantRenownLevelMixin:TryInit()
	if self.init then
		return;
	end

	self.init = true;
	self.Level:SetText(self.info.level);

	if self.info.isCapstone then
		self.Icon:AddMaskTexture(self.HexMask);
		self.HighlightTexture:SetAtlas("CovenantSanctum-Renown-Hexagon-Hover", TextureKitConstants.UseAtlasSize);
	else
		self.Icon:RemoveMaskTexture(self.HexMask);
		self.HighlightTexture:SetAtlas("CovenantSanctum-Renown-Icon-Hover", TextureKitConstants.UseAtlasSize);
	end

	local maskTexture = self:GetParent().Mask;
	for i, texture in ipairs(self.Textures) do
		texture:AddMaskTexture(maskTexture);
	end

	local rewards = C_CovenantSanctumUI.GetRenownRewardsForLevel(g_covenantID, self:GetLevel());
	-- use first reward for icon
	self.rewardInfo = rewards[1];
	self:SetIcon();
end

function CovenantRenownLevelMixin:Refresh(actualLevel, displayLevel, selected)
	self:TryInit();

	local level = self:GetLevel();
	local earned = level <= displayLevel;
	local borderAtlas;
	if selected then
		borderAtlas = "CovenantSanctum-Renown-Next-Border-%s";
		if self.info.isCapstone then
			borderAtlas = "CovenantSanctum-Renown-Hexagon-Next-Border-%s";
		elseif self.info.isMilestone then
			borderAtlas = "CovenantSanctum-Renown-Special-Next-Border-%s";
		end
	elseif earned then
		borderAtlas = "CovenantSanctum-Renown-Icon-Border-%s";
		if self.info.isCapstone then
			borderAtlas = "CovenantSanctum-Renown-Hexagon-Border-%s";
		elseif self.info.isMilestone then
			borderAtlas = "CovenantSanctum-Renown-Special-Border-%s";
		end
	else
		borderAtlas = "CovenantSanctum-Renown-Icon-Border-Disabled";
		if self.info.isCapstone then
			borderAtlas = "CovenantSanctum-Renown-Hexagon-Border-Disabled";
		elseif self.info.isMilestone then
			borderAtlas = "CovenantSanctum-Renown-Special-Disabled-Border-%s";
		end
	end
	self.IconBorder:SetAtlas(borderAtlas:format(g_covenantData.textureKit), TextureKitConstants.UseAtlasSize);

	if earned then
		self.Icon:SetDesaturated(false);
		self.Level:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	else
		self.Icon:SetDesaturated(true);
		self.Level:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	end
	self.Check:SetShown(level <= actualLevel);
end

function CovenantRenownLevelMixin:SetIcon()
	local icon, name, description = CovenantUtil.GetRenownRewardInfo(self.rewardInfo, GenerateClosure(self.SetIcon, self));
	self.Icon:SetTexture(icon);
end

function CovenantRenownLevelMixin:ApplyAlpha(alpha)
	self.Level:SetAlpha(alpha);
end

function CovenantRenownLevelMixin:OnMouseUp()
	local track = self:GetParent():GetParent();
	track:GetParent():CancelLevelEffect();
	track:SetSelection(self.index);
end

function CovenantRenownLevelMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -8, -8);
	self:RefreshTooltip();
end

function CovenantRenownLevelMixin:RefreshTooltip()
	if not GameTooltip:GetOwner() == self then
		return;
	end

	local onItemUpdateCallback = GenerateClosure(self.RefreshTooltip, self);
	local rewards = C_CovenantSanctumUI.GetRenownRewardsForLevel(g_covenantID, self:GetLevel());
	local addRewards = true;
	if self.isCapstone then
		GameTooltip_SetTitle(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_TITLE);
		GameTooltip_AddNormalLine(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_DESC);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddHighlightLine(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_DESC2);
	else
		if #rewards == 1 then
			local icon, name, description = CovenantUtil.GetRenownRewardInfo(rewards[1], onItemUpdateCallback);
			GameTooltip_SetTitle(GameTooltip, name);
			GameTooltip_AddNormalLine(GameTooltip, description);
			addRewards = false;
		else
			GameTooltip_SetTitle(GameTooltip, string.format(RENOWN_REWARD_MILESTONE_TOOLTIP_TITLE, self.info.level));
		end
	end
	if addRewards then
		for i, rewardInfo in ipairs(rewards) do
			local icon, name, description = CovenantUtil.GetRenownRewardInfo(rewardInfo, onItemUpdateCallback);
			if name then
				GameTooltip_AddNormalLine(GameTooltip, string.format(RENOWN_REWARD_TOOLTIP_REWARD_LINE, name));
			end
		end
	end
	GameTooltip:Show();	
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
	local icon, name, description = CovenantUtil.GetRenownRewardInfo(self.rewardInfo, GenerateClosure(self.RefreshReward, self));
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

CovenantRenownTrackFrameMixin = { 
	totalWidth = 570,
	elementWidth = 55,
	elementSpacing = -2,
	fullAlphaRadius = 94,	-- distance from Center where full alpha is applied to text
	
	scrollSpeeds = {
		{ timeAfter = 0.6, speed = 2 },
		{ timeAfter = 1, speed = 3 },
		{ timeAfter = 1, speed = 4 },
	},

	elementTemplate = "CovenantRenownLevelTemplate",

	scrollStartSound = SOUNDKIT.UI_COVENANT_RENOWN_SLIDE_START,
	scrollStopSound = SOUNDKIT.UI_COVENANT_RENOWN_SLIDE_STOP,
	scrollCenterChangeSound = SOUNDKIT.UI_COVENANT_RENOWN_SLIDE_START,
};

function CovenantRenownTrackFrameMixin:OnLoad()
	self.calculationWidth = self.elementWidth + self.elementSpacing;			-- this gets used in several functions
	self.visibleRadius = math.ceil((self.totalWidth + self.elementWidth) / 2);	-- an element is visible if its center falls within this distance from track center
	self.numElementsPerHalf = math.ceil(self.visibleRadius / self.calculationWidth);
end

function CovenantRenownTrackFrameMixin:OnHide()
	if self.scrollTime then
		self:StopScroll();
	end
end

function CovenantRenownTrackFrameMixin:Init(numElements)
	if not self.headElement then
		self.numElements = numElements;
		self.Elements = { };
		local lastFrame;
		for i = 1, numElements do
			local frame = CreateFrame("FRAME", nil, self.ClipFrame, self.elementTemplate);
			frame.index = i;
			tinsert(self.Elements, frame);
			if lastFrame then
				frame:SetPoint("LEFT", lastFrame, "RIGHT", self.elementSpacing, 0);
			else
				self.headElement = frame;
				frame:SetPoint("CENTER");
			end
			lastFrame = frame;
		end
	end
end

function CovenantRenownTrackFrameMixin:GetElements()
	return self.Elements;
end

function CovenantRenownTrackFrameMixin:OnUpdate(elapsed)
	if self.stopRequested then
		self:StopScroll();
	end
	if not self.scrollTime then
		return;
	end

	self.scrollTime = self.scrollTime + elapsed;
	local speed = 0;
	local runningTime = 0;
	for i, speedData in ipairs(self.scrollSpeeds) do
		runningTime = runningTime + speedData.timeAfter;
		if self.scrollTime >= runningTime then
			speed = speedData.speed;
		else
			break;
		end
	end

	self.moving = speed > 0;
	if self.moving then
		local offset = self.offset + speed * self.direction * self.scrollTime;
		offset = Clamp(offset, 0, self:GetMaxOffset());
		self.offset = offset;
		self.headElement:SetPoint("CENTER", -offset, 0);
		self:RefreshView();

		if not self.loopingSoundHandle and self.scrollLoopSound then
			self.loopingSoundHandle = select(2, PlaySound(self.scrollLoopSound));
		end
	end	
end

function CovenantRenownTrackFrameMixin:SetSelection(index, forceRefresh, skipSound, overrideStopSound)
	-- stops other sources (like parent's mousewheel) from interfering during movement
	if self.scrollTime then
		return;
	end

	index = index or self.numElements;
	index = Clamp(index, 1, self.numElements);
	if self.selectedIndex ~= index and not skipSound and self.scrollStopSound then
		PlaySound(self.scrollStopSound);
	end
	self.selectedIndex = index;
	local offset = self:GetAbsoluteOffsetForIndex(index);
	self.headElement:SetPoint("CENTER", -offset, 0);
	self.offset = offset;
	if forceRefresh then
		self.centerIndex = nil;
	end
	self:RefreshView();
end

function CovenantRenownTrackFrameMixin:RefreshView()
	local centerIndex = self:GetClosestIndexToCenter();
	if self.centerIndex ~= centerIndex then
		self.centerIndex = centerIndex;
		local leftIndex = math.max(1, centerIndex - self.numElementsPerHalf);
		local rightIndex = math.min(centerIndex + self.numElementsPerHalf, self.numElements);
		self:GetParent():OnTrackUpdate(leftIndex, centerIndex, rightIndex, self.moving);
		if self.moving and self.scrollCenterChangeSound then
			PlaySound(self.scrollCenterChangeSound);
		end
	end

	self.LeftButton:SetEnabled(self.offset > 0);
	self.RightButton:SetEnabled(self.offset < self:GetMaxOffset());	
end

function CovenantRenownTrackFrameMixin:GetCenterIndex()
	return self.centerIndex;
end

function CovenantRenownTrackFrameMixin:GetDesiredAlphaForIndex(index)
	local alpha = 0;
	local distance = math.abs(self:GetDistanceFromCenterForIndex(index));
	if distance <= self.fullAlphaRadius then
		alpha = 1;
	elseif distance <= self.visibleRadius then
		alpha = Lerp(1, 0, distance/self.visibleRadius);
	end
	return alpha;
end

function CovenantRenownTrackFrameMixin:GetAbsoluteOffsetForIndex(index)
	return (index - 1) * self.calculationWidth;
end

function CovenantRenownTrackFrameMixin:GetMaxOffset()
	if not self.maxOffset then
		self.maxOffset = self:GetAbsoluteOffsetForIndex(self.numElements);
	end
	return self.maxOffset;
end

function CovenantRenownTrackFrameMixin:GetClosestIndexToCenter()
	local index = self.offset / self.calculationWidth;
	index = math.floor(index) + 1;
	return index;
end

function CovenantRenownTrackFrameMixin:GetDistanceFromCenterForIndex(index)
	return (index - 1) * self.calculationWidth - self.offset;
end

function CovenantRenownTrackFrameMixin:StartScroll(direction)
	self.scrollTime = 0;
	self.direction = direction;
end

function CovenantRenownTrackFrameMixin:StopScroll(direction)
	self.scrollTime = nil;
	if not self.moving and self.direction then
		self:SetSelection(self.selectedIndex + self.direction);
	end
	self.moving = false;
	self.stopRequested = false;
	if self.loopingSoundHandle then
		StopSound(self.loopingSoundHandle);
		self.loopingSoundHandle = nil;
	end
	-- figure out next based on offset
	local centerIndex = self:GetClosestIndexToCenter();
	local offset = self:GetAbsoluteOffsetForIndex(centerIndex);
	local delta = self.offset - offset;
	local forceRefresh = true;
	if delta < 1 or self.direction == -1 then
		self:SetSelection(centerIndex, forceRefresh);
	else
		self:SetSelection(centerIndex + 1, forceRefresh);
	end
end

function CovenantRenownTrackFrameMixin:RequestStop()
	if self.scrollTime then
		self.stopRequested = true;
	end
end

CovenantRenownTrackButtonMixin = { };

function CovenantRenownTrackButtonMixin:OnLoad()
	if self.direction == 1 then
		self:GetNormalTexture():SetTexCoord(1, 0, 0, 1);
		self:GetHighlightTexture():SetTexCoord(1, 0, 0, 1);
		self:GetPushedTexture():SetTexCoord(1, 0, 0, 1);
		self:GetDisabledTexture():SetTexCoord(1, 0, 0, 1);
	end
end

function CovenantRenownTrackButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		local track = self:GetParent();
		track:StartScroll(self.direction);
		if track.scrollStartSound then
			PlaySound(track.scrollStartSound);
		end
	end
end

function CovenantRenownTrackButtonMixin:OnMouseUp()
	if self:IsEnabled() then
		local track = self:GetParent();
		track:StopScroll();
	end
end

function CovenantRenownTrackButtonMixin:OnDisable()
	local track = self:GetParent();
	track:RequestStop();
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