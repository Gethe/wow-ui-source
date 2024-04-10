local function SetupTextureKit(frame, textureKit, regions)
	SetupTextureKitOnRegions(textureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end

RewardTrackFrameMixin = { 
	totalWidth = 570,
	elementWidth = 55,
	elementSpacing = -2,
	fullAlphaRadius = 94,	-- distance from Center where full alpha is applied to text
	
	scrollSpeeds = {
		{ timeAfter = 0.6, speed = 2 },
		{ timeAfter = 1, speed = 3 },
		{ timeAfter = 1, speed = 4 },
	},
};

function RewardTrackFrameMixin:OnLoad()
	self.calculationWidth = self.elementWidth + self.elementSpacing;			-- this gets used in several functions
	self.visibleRadius = math.ceil((self.totalWidth + self.elementWidth) / 2);	-- an element is visible if its center falls within this distance from track center
	self.numElementsPerHalf = math.ceil(self.visibleRadius / self.calculationWidth);

	self.elementPool = CreateFramePool("FRAME", self.ClipFrame, self.elementTemplate);

	local defaultTrackButtonXOffset, defaultTrackButtonYOffset = 4, 0;
	self.LeftButton:ClearAllPoints();
	self.LeftButton:SetPoint("RIGHT", self, "LEFT", self.LeftButton.direction * (self.rewardButtonXOffset or defaultTrackButtonXOffset), self.rewardButtonYOffset or defaultTrackButtonYOffset);
	self.RightButton:ClearAllPoints();
	self.RightButton:SetPoint("LEFT", self, "RIGHT", self.RightButton.direction * (self.rewardButtonXOffset or defaultTrackButtonXOffset), self.rewardButtonYOffset or defaultTrackButtonYOffset);
end

function RewardTrackFrameMixin:OnHide()
	if self.scrollTime then
		self:StopScroll();
	end
end

function RewardTrackFrameMixin:Init(elementList)
	self.elementPool:ReleaseAll();

	self.numElements = #elementList;
	self.Elements = { };
	local lastFrame;
	for i = 1, #elementList do
		local frame = self.elementPool:Acquire();
		frame.index = i;
		tinsert(self.Elements, frame);
		if lastFrame then
			frame:SetPoint("LEFT", lastFrame, "RIGHT", self.elementSpacing, 0);
		else
			self.headElement = frame;
			frame:SetPoint("CENTER");
		end
		frame:Show();
		lastFrame = frame;
	end

	for i, elementInfo in ipairs(elementList) do
		self.Elements[i]:SetInfo(elementList[i]);
	end
end

function RewardTrackFrameMixin:GetElements()
	return self.Elements;
end

function RewardTrackFrameMixin:OnUpdate(elapsed)
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

function RewardTrackFrameMixin:SetSelection(index, forceRefresh, skipSound, overrideStopSound)
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

function RewardTrackFrameMixin:RefreshView()
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
	self.JumpLeftButton:SetEnabled(self.selectedIndex > 1);
	self.JumpRightButton:SetEnabled(self.selectedIndex < self.numElements);
end

function RewardTrackFrameMixin:GetCenterIndex()
	return self.centerIndex;
end

function RewardTrackFrameMixin:GetDesiredAlphaForIndex(index)
	local alpha = 0;
	local distance = math.abs(self:GetDistanceFromCenterForIndex(index));
	if distance <= self.fullAlphaRadius then
		alpha = 1;
	elseif distance <= self.visibleRadius then
		alpha = Lerp(1, 0, distance/self.visibleRadius);
	end
	return alpha;
end

function RewardTrackFrameMixin:GetAbsoluteOffsetForIndex(index)
	return (index - 1) * self.calculationWidth;
end

function RewardTrackFrameMixin:GetMaxOffset()
	self.maxOffset = self:GetAbsoluteOffsetForIndex(self.numElements);
	return self.maxOffset;
end

function RewardTrackFrameMixin:GetClosestIndexToCenter()
	local index = self.offset / self.calculationWidth;
	index = math.floor(index) + 1;
	return index;
end

function RewardTrackFrameMixin:GetDistanceFromCenterForIndex(index)
	return (index - 1) * self.calculationWidth - self.offset;
end

function RewardTrackFrameMixin:StartScroll(direction)
	self.scrollTime = 0;
	self.direction = direction;
end

function RewardTrackFrameMixin:StopScroll(direction)
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

function RewardTrackFrameMixin:RequestStop()
	if self.scrollTime then
		self.stopRequested = true;
	end
end

RewardTrackButtonMixin = { };

function RewardTrackButtonMixin:OnLoad()
	if self.direction == 1 then
		self:GetNormalTexture():SetTexCoord(1, 0, 0, 1);
		self:GetHighlightTexture():SetTexCoord(1, 0, 0, 1);
		self:GetPushedTexture():SetTexCoord(1, 0, 0, 1);
		self:GetDisabledTexture():SetTexCoord(1, 0, 0, 1);
	end
end

function RewardTrackButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		local track = self:GetParent();
		track:StartScroll(self.direction);
		if track.scrollStartSound then
			PlaySound(track.scrollStartSound);
		end
	end
end

function RewardTrackButtonMixin:OnMouseUp()
	if self:IsEnabled() then
		local track = self:GetParent();
		track:StopScroll();
	end
end

function RewardTrackButtonMixin:OnDisable()
	local track = self:GetParent();
	track:RequestStop();
end

RewardTrackJumpButtonMixin = { };

function RewardTrackJumpButtonMixin:OnLoad()
	if self.direction == 1 then
		self:GetNormalTexture():SetTexCoord(1, 0, 0, 1);
		self:GetHighlightTexture():SetTexCoord(1, 0, 0, 1);
		self:GetPushedTexture():SetTexCoord(1, 0, 0, 1);
		self:GetDisabledTexture():SetTexCoord(1, 0, 0, 1);
	end
end

function RewardTrackJumpButtonMixin:OnClick()
	if self:IsEnabled() then
		local track = self:GetParent();
		local rewardFrame = track:GetParent();
		local elements = track:GetElements();
		local selectedElement = elements[track.selectedIndex];

		local jumpLevel;
		local selectedLevel = selectedElement:GetLevel();
		local nextUnlock = math.min(rewardFrame.actualLevel + 1, rewardFrame.maxLevel);
		if self.direction == 1 then
			jumpLevel = selectedLevel < nextUnlock and nextUnlock or rewardFrame.maxLevel;
		else
			jumpLevel = selectedLevel > nextUnlock and nextUnlock or 1;
		end
		rewardFrame:CancelLevelEffect();
		local fromOnShow, forceRefresh = false, true;
		rewardFrame:SelectLevel(jumpLevel, fromOnShow, forceRefresh);
		if track.scrollStartSound then
			PlaySound(track.scrollStartSound);
		end
	end
end

RewardTrackSkipLevelUpButtonMixin = { };

function RewardTrackSkipLevelUpButtonMixin:OnClick()
	local rewardFrame = self:GetParent();

	rewardFrame:CancelLevelEffect();
	local nextUnlock = math.min(rewardFrame.actualLevel + 1, rewardFrame.maxLevel);
	local fromOnShow, forceRefresh = false, true;
	rewardFrame:SelectLevel(nextUnlock, fromOnShow, forceRefresh);
end

RenownLevelMixin = { };

function RenownLevelMixin:SetInfo(info)
	self.info = info;
	self.init = false;
end

function RenownLevelMixin:GetLevel()
	return self.info and self.info.level or 0;
end

function RenownLevelMixin:TryInit()
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

	self:SetIcon();
end

function RenownLevelMixin:Refresh(actualLevel, displayLevel, selected)
	self:TryInit();

	local level = self:GetLevel();
	local earned = level <= displayLevel;
	local borderAtlas;
	-- There is no "Standard" milestone border, using the default instead
	local textureKit = self.info.textureKit or "Standard";
	if selected then
		borderAtlas = "CovenantSanctum-Renown-Next-Border-%s";
		if self.info.isCapstone then
			borderAtlas = "CovenantSanctum-Renown-Hexagon-Next-Border-%s";
		elseif self.info.isMilestone and textureKit ~= "Standard" then
			borderAtlas = "CovenantSanctum-Renown-Special-Next-Border-%s";
		end
	elseif earned then
		borderAtlas = "CovenantSanctum-Renown-Icon-Border-%s";
		if self.info.isCapstone then
			borderAtlas = "CovenantSanctum-Renown-Hexagon-Border-%s";
		elseif self.info.isMilestone and textureKit ~="Standard" then
			borderAtlas = "CovenantSanctum-Renown-Special-Border-%s";
		end
	else
		borderAtlas = "CovenantSanctum-Renown-Icon-Border-Disabled";
		if self.info.isCapstone then
			borderAtlas = "CovenantSanctum-Renown-Hexagon-Border-Disabled";
		elseif self.info.isMilestone and textureKit ~="Standard" then
			borderAtlas = "CovenantSanctum-Renown-Special-Disabled-Border-%s";
		end
	end
	self.IconBorder:SetAtlas(borderAtlas:format(textureKit), TextureKitConstants.UseAtlasSize);

	if earned then
		self.Icon:SetDesaturated(false);
		self.Level:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	else
		self.Icon:SetDesaturated(true);
		self.Level:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	end
	self.Check:SetShown(level <= actualLevel);
end

function RenownLevelMixin:SetIcon()
	local icon, name, description = RenownRewardUtil.GetRenownRewardInfo(self.info.rewardInfo[1], GenerateClosure(self.SetIcon, self));
	self.Icon:SetTexture(icon);
end

function RenownLevelMixin:ApplyAlpha(alpha)
	self.Level:SetAlpha(alpha);
end

function RenownLevelMixin:OnMouseUp()
	local track = self:GetParent():GetParent();
	track:GetParent():CancelLevelEffect();
	track:SetSelection(self.index);
end

function RenownLevelMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -8, -8);
	self:RefreshTooltip();
end

function RenownLevelMixin:RefreshTooltip()
	if not GameTooltip:GetOwner() == self then
		return;
	end

	local onItemUpdateCallback = GenerateClosure(self.RefreshTooltip, self);
	local rewards = self.info.rewardInfo;
	local addRewards = true;
	if self.isCapstone then
		GameTooltip_SetTitle(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_TITLE);
		GameTooltip_AddNormalLine(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_DESC);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddHighlightLine(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_DESC2);
	else
		if #rewards == 1 then
			local icon, name, description = RenownRewardUtil.GetRenownRewardInfo(rewards[1], onItemUpdateCallback);
			GameTooltip_SetTitle(GameTooltip, name);
			GameTooltip_AddNormalLine(GameTooltip, description);
			addRewards = false;
		else
			GameTooltip_SetTitle(GameTooltip, string.format(RENOWN_REWARD_MILESTONE_TOOLTIP_TITLE, self.info.level));
		end
	end
	if addRewards then
		for i, rewardInfo in ipairs(rewards) do
			local icon, name, description = RenownRewardUtil.GetRenownRewardInfo(rewardInfo, onItemUpdateCallback);
			if name then
				GameTooltip_AddNormalLine(GameTooltip, string.format(RENOWN_REWARD_TOOLTIP_REWARD_LINE, name));
			end
		end
	end
	GameTooltip:Show();	
end