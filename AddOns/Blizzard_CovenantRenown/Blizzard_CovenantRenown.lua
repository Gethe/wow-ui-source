
local mainTextureKitRegions = {
	["Background"] = "CovenantSanctum-Renown-Background-%s",
	["TitleDivider"] = "CovenantSanctum-Renown-Title-Divider-%s",
	["Divider"] = "CovenantSanctum-Renown-Divider-%s",	
	["Anima"] = "CovenantSanctum-Renown-Anima-%s",
	["FinalToastSlabTexture"] = "CovenantSanctum-Renown-FinalToast-%s",
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

local finalToastSwirlEffects = 
{
	Kyrian = {119},
	Venthyr = {120},
	NightFae = {121, 123},
	Necrolord = {122},
}

local finalToastSounds =
{
	Kyrian = SOUNDKIT.UI_COVENANT_SANCTUM_RENOWN_MAX_KYRIAN,
	Venthyr = SOUNDKIT.UI_COVENANT_SANCTUM_RENOWN_MAX_VENTHYR,
	NightFae = SOUNDKIT.UI_COVENANT_SANCTUM_RENOWN_MAX_NIGHTFAE,
	Necrolord = SOUNDKIT.UI_COVENANT_SANCTUM_RENOWN_MAX_NECROLORD,
}

local g_sanctumTextureKit;
local function SetupTextureKit(frame, regions)
	SetupTextureKitOnRegions(g_sanctumTextureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end

local CovenantRenownEvents = {
	"COVENANT_RENOWN_INTERACTION_ENDED",
	"COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED",
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
	self:SetUpTextureKits();
	self:Refresh();
	self.TrackFrame:Init();
	FrameUtil.RegisterFrameForEvents(self, CovenantRenownEvents);
	PlaySound(SOUNDKIT.UI_COVENANT_SANCTUM_OPEN_WINDOW, nil, SOUNDKIT_ALLOW_DUPLICATES);
end

function CovenantRenownMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CovenantRenownEvents);
	self:SetCelebrationSwirlEffects(nil);
	self:CancelFinalToastSound();
	C_CovenantSanctumUI.EndInteraction();
	PlaySound(SOUNDKIT.UI_COVENANT_SANCTUM_CLOSE_WINDOW, nil, SOUNDKIT_ALLOW_DUPLICATES);
end

function CovenantRenownMixin:OnEvent(event, ...)
	if event == "COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED" then
		self:Refresh();
	elseif event == "COVENANT_RENOWN_INTERACTION_STARTED" then
		ShowUIPanel(self);
	elseif event == "COVENANT_RENOWN_INTERACTION_ENDED" then
		HideUIPanel(self);
	end
end

function CovenantRenownMixin:OnMouseWheel(direction)
	local track = self.TrackFrame;
	track:StartScroll(direction * -1);
	-- stop immediately so it only moves by 1 in direction
	track:StopScroll();
end

function CovenantRenownMixin:SetUpTextureKits()
	local covenantID = C_Covenants.GetActiveCovenantID();
	local covenantData = C_Covenants.GetCovenantData(covenantID);
	local textureKit = covenantData.textureKit;
	if g_sanctumTextureKit ~= textureKit then
		g_sanctumTextureKit = textureKit;

		NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, textureKit);
		NineSliceUtil.DisableSharpening(self.NineSlice);

		local atlas = "CovenantSanctum-RenownLevel-Border-%s";
		self.HeaderFrame.Background:SetAtlas(atlas:format(textureKit), TextureKitConstants.UseAtlasSize);

		UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-%s-ExitButtonBorder", -1, 1, textureKit);
		
		SetupTextureKit(self, mainTextureKitRegions);
	end
end

function CovenantRenownMixin:Refresh()
	local renownLevel = C_CovenantSanctumUI.GetRenownLevel();
	self.HeaderFrame.Level:SetText(renownLevel);

	local covenantID = C_Covenants.GetActiveCovenantID();
	local covenantData = C_Covenants.GetCovenantData(covenantID);
	self.CovenantName:SetText(covenantData.name);

	self:SetRewards(renownLevel + 1);
end

function CovenantRenownMixin:SetCelebrationSwirlEffects(swirlEffects)
	if swirlEffects == nil then
		self.CelebrationModelScene:ClearEffects();
	else
		for i, swirlEffect in ipairs(swirlEffects) do
			self.CelebrationModelScene:AddEffect(swirlEffect, self.FinalToast.SlabTexture);
		end
	end
end

function CovenantRenownMixin:SetRewards(level)
	self.rewardsPool:ReleaseAll();
	local rewards = C_CovenantSanctumUI.GetRenownRewardsForLevel(C_Covenants.GetActiveCovenantID(), level);
	local numRewards = #rewards;

	local renownLevel = C_CovenantSanctumUI.GetRenownLevel();
	local rewardUnlocked = level <= renownLevel;
		
	for i, rewardInfo in ipairs(rewards) do
		if i <= 2 then	-- TODO: remove
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
	end

	if numRewards > 0 then
		--self.Header:SetText(COVENANT_SANCTUM_TAB_RENOWN);
		self.FinalToast:Hide();
		self:SetCelebrationSwirlEffects(nil);
		self:CancelFinalToastSound()
	else
		-- TODO: Remove this block
		self.Header:SetText(COVENANT_SANCTUM_RENOWN_REWARD_TITLE_COMPLETE);

		local covenantData = C_Covenants.GetCovenantData(C_Covenants.GetActiveCovenantID());
		self.PreviewText:SetFormattedText(COVENANT_SANCTUM_RENOWN_REWARD_DESC_COMPLETE, covenantData and covenantData.name or "");

		self.FinalToast:Show();
		self.FinalToast:SetCovenantTextureKit(covenantData.textureKit);
		self:SetCelebrationSwirlEffects(finalToastSwirlEffects[covenantData.textureKit]);

		if not self.finalToastSoundHandle then
			local soundKitID = finalToastSounds[covenantData.textureKit];
			local _, soundHandle = PlaySound(soundKitID, nil, SOUNDKIT_ALLOW_DUPLICATES);
			self.finalToastSoundHandle = soundHandle;
		end
	end
	
	if level <= renownLevel then
		self.PreviewText:SetFormattedText(COVENANT_SANCTUM_RENOWN_LEVEL_UNLOCKED, level);
		self.PreviewText:SetTextColor(GREEN_FONT_COLOR:GetRGB());
	else
		self.PreviewText:SetFormattedText(COVENANT_SANCTUM_RENOWN_LEVEL_LOCKED, level);
		self.PreviewText:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	end
end

function CovenantRenownMixin:CancelFinalToastSound()
	if self.finalToastSoundHandle then
		StopSound(self.finalToastSoundHandle);
		self.finalToastSoundHandle = nil;
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

	local rewards = C_CovenantSanctumUI.GetRenownRewardsForLevel(C_Covenants.GetActiveCovenantID(), self:GetLevel());
	-- use first reward for icon
	self.rewardInfo = rewards[1];
	self:SetIcon();
end

function CovenantRenownLevelMixin:Refresh(level, selected)
	self:TryInit();

	local earned = self:GetLevel() <= level;
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
	self.IconBorder:SetAtlas(borderAtlas:format(g_sanctumTextureKit), TextureKitConstants.UseAtlasSize);

	if earned then
		self.Icon:SetDesaturated(false);
		self.Level:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		self.Check:Show();
	else
		self.Icon:SetDesaturated(true);
		self.Level:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		self.Check:Hide();
	end
end

function CovenantRenownLevelMixin:SetIcon()
	local icon, name, description = CovenantUtil.GetRenownRewardInfo(self.rewardInfo, GenerateClosure(self.SetIcon, self));
	self.Icon:SetTexture(icon);
end

function CovenantRenownLevelMixin:OnMouseUp()
	self:GetParent():GetParent():SelectLevel(self.info.level);
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
	local rewards = C_CovenantSanctumUI.GetRenownRewardsForLevel(C_Covenants.GetActiveCovenantID(), self:GetLevel());
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
		{ timeAfter = 0.6, speed = 1 },
		{ timeAfter = 1, speed = 2 },
		{ timeAfter = 1, speed = 4 },
	},
};

function CovenantRenownTrackFrameMixin:OnLoad()
	self.calculationWidth = self.elementWidth + self.elementSpacing;			-- this gets used in several functions
	self.visibleRadius = math.ceil((self.totalWidth + self.elementWidth) / 2);	-- an element is visible if its center falls within this distance from track center
	self.numElementsPerHalf = math.ceil(self.visibleRadius / self.calculationWidth);
end

function CovenantRenownTrackFrameMixin:Init()
	-- TODO: level up treatment
	
	local covenantID = C_Covenants.GetActiveCovenantID();

	-- get level data if first time or covenant changed
	local levels;
	if not self.covenantID or self.covenantID ~= covenantID then
		levels = C_CovenantSanctumUI.GetRenownLevels(covenantID);
	end

	-- create the frames if first time
	if not self.covenantID then
		self.Elements = { };
		local lastFrame;
		for i, levelInfo in ipairs(levels) do
			local frame = CreateFrame("FRAME", nil, self.ClipFrame, "CovenantRenownLevelTemplate");
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

	-- change the data if covenant is different (or first time)
	if self.covenantID ~= covenantID then
		self.covenantID = covenantID;
		for i, frame in ipairs(self.Elements) do
			frame:SetInfo(levels[i]);
		end
	end

	local nextLevel = C_CovenantSanctumUI.GetRenownLevel() + 1;
	self:SelectLevel(nextLevel);
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
		self:RefreshVisibleElements();
	end	
end

function CovenantRenownTrackFrameMixin:SelectLevel(level)
	local selectionIndex;
	for i, frame in ipairs(self.Elements) do
		if frame:GetLevel() == level then
			selectionIndex = i;
			break;
		end
	end
	self:SetSelection(selectionIndex);
end

function CovenantRenownTrackFrameMixin:SetSelection(index)
	local numElements = #self.Elements;
	index = index or numElements;
	index = Clamp(index, 1, numElements);
	self.selectedIndex = index;
	local offset = self:GetAbsoluteOffsetForIndex(index);
	self.headElement:SetPoint("CENTER", -offset, 0);
	self.offset = offset;
	self:RefreshVisibleElements();
end

function CovenantRenownTrackFrameMixin:RefreshVisibleElements()
	local level = C_CovenantSanctumUI.GetRenownLevel();
	local centerIndex = self:GetClosestIndexToCenter();

	for i = centerIndex - self.numElementsPerHalf, centerIndex + self.numElementsPerHalf do
		local frame = self.Elements[i];
		if frame then
			local selected = not self.moving and centerIndex == i;
			frame:Refresh(level, selected);

			local alpha = 0;
			local distance = math.abs(self:GetDistanceFromCenterForIndex(i));
			if distance <= self.fullAlphaRadius then
				alpha = 1;
			elseif distance <= self.visibleRadius then
				alpha = Lerp(1, 0, distance/self.visibleRadius);
			end
			frame.Level:SetAlpha(alpha);
		end
	end

	self.LeftButton:SetEnabled(self.offset > 0);
	self.RightButton:SetEnabled(self.offset < self:GetMaxOffset());
	
	if not self.moving then
		self:GetParent():SetRewards(self.Elements[centerIndex]:GetLevel());
	end
end

function CovenantRenownTrackFrameMixin:GetAbsoluteOffsetForIndex(index)
	return (index - 1) * self.calculationWidth;
end

function CovenantRenownTrackFrameMixin:GetMaxOffset()
	if not self.maxOffset then
		self.maxOffset = self:GetAbsoluteOffsetForIndex(#self.Elements);
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
	self:SetSelection(self.selectedIndex + direction);
	self.scrollTime = 0;
	self.direction = direction;
end

function CovenantRenownTrackFrameMixin:StopScroll(direction)
	self.scrollTime = nil;
	self.moving = false;
	self.stopRequested = false;
	-- figure out next based on offset
	local centerIndex = self:GetClosestIndexToCenter();
	local offset = self:GetAbsoluteOffsetForIndex(centerIndex);
	local delta = self.offset - offset;
	if delta < 1 or self.direction == -1 then
		self:SetSelection(centerIndex);
	else
		self:SetSelection(centerIndex + 1);
	end
end

function CovenantRenownTrackFrameMixin:RequestStop()
	self.stopRequested = true;
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
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function CovenantRenownTrackButtonMixin:OnMouseUp()
	if self:IsEnabled() then
		local track = self:GetParent();
		track:StopScroll();
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
end

function CovenantRenownTrackButtonMixin:OnDisable()
	local track = self:GetParent();
	track:RequestStop();
end