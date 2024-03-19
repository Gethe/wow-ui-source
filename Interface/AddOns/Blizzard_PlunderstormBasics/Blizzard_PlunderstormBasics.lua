
local function GetPlayerPartyMemberInfo()
	local members = C_WoWLabsMatchmaking.GetCurrentParty();
	for i, memberInfo in ipairs(members) do
		if memberInfo.isLocalPlayer then
			return memberInfo;
		end
	end

	return nil;
end


PlunderstormBasicsLifetimePlunderMixin = {};

function PlunderstormBasicsLifetimePlunderMixin:OnEnter()
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip_AddHighlightLine(tooltip, PLUNDERSTORM_LIFETIME_PLUNDER_TOOLTIP);
	tooltip:Show();
end

function PlunderstormBasicsLifetimePlunderMixin:OnLeave()
	local tooltip = GetAppropriateTooltip();
	if tooltip:GetOwner() == self then
		tooltip:Hide();
	end
end


PlunderstormBasicsContainerFrameMixin = {};

function PlunderstormBasicsContainerFrameMixin:OnShow()
	local lifetimePlunder = self:GetLifetimePlunder();
	local hasLifetimePlunder = (lifetimePlunder ~= nil);
	self.LifetimePlunder:SetShown(hasLifetimePlunder);
	if hasLifetimePlunder then
		local LifetimePlunderIconID = 133784;
		local iconMarkup = CreateSimpleTextureMarkup(LifetimePlunderIconID, 16, 16);
		self.LifetimePlunder:SetText(("%s %s"):format(BreakUpLargeNumbers(lifetimePlunder), iconMarkup));
	end
end

function PlunderstormBasicsContainerFrameMixin:GetLifetimePlunder()
	-- In-game we can use the currency directly.
	if C_CurrencyInfo then
		-- Avoiding adding a proper constant for this so there's no leaking. Should really be something like Constants.CurrencyConsts.CURRENCY_ID_LIFETIME_PLUNDER
		local LifetimePlunderCurrencyType = 2922;
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(LifetimePlunderCurrencyType);
		if currencyInfo then
			return currencyInfo.quantity;
		end
	else
		local memberInfo = GetPlayerPartyMemberInfo();
		if memberInfo then
			return memberInfo.lifetimePlunder;
		end
	end

	return nil;
end

function PlunderstormBasicsContainerFrameMixin:SetBottomFrame(bottomFrame)
	self.bottomFrame = bottomFrame;
	self:UpdateScaleToFit();
end

function PlunderstormBasicsContainerFrameMixin:OnCleaned()
	self:UpdateScaleToFit();
end

function PlunderstormBasicsContainerFrameMixin:UpdateScaleToFit()
	self:SetScale(1.0);

	if not self.bottomFrame then
		return;
	end

	local totalSpace = self:GetHeight();
	local bottomSpace = self:GetBottom() - self.bottomFrame:GetTop();
	if bottomSpace >= 0 then
		return;
	end

	self:SetScale((totalSpace + bottomSpace) / totalSpace);
end


PlunderstormRenownPreviewMixin = {};

function PlunderstormRenownPreviewMixin:OnLoad()
	self:RegisterEvent("LOBBY_MATCHMAKER_PARTY_UPDATE");

	self.rewardsPool = CreateFramePool("FRAME", self.RewardsContainer, "MajorFactionRenownRewardTemplate");
end

function PlunderstormRenownPreviewMixin:OnShow()
	self:UpdateRewards();
end

function PlunderstormRenownPreviewMixin:OnEvent(event)
	if event == "LOBBY_MATCHMAKER_PARTY_UPDATE" then
		self:UpdateRewards();
	end
end

function PlunderstormRenownPreviewMixin:GetMajorFactionID()
	return Constants.MajorFactionsConsts.PLUNDERSTORM_MAJOR_FACTION_ID;
end

function PlunderstormRenownPreviewMixin:GetCurrentRenownLevel()
	if C_MajorFactions then
		return C_MajorFactions.GetCurrentRenownLevel(self:GetMajorFactionID());
	else
		local memberInfo = GetPlayerPartyMemberInfo();
		if memberInfo then
			return memberInfo.renownLevel;
		end
	end

	return nil;
end

function PlunderstormRenownPreviewMixin:HasMaximumRenownLevel()
	if C_MajorFactions then
		return C_MajorFactions.HasMaximumRenown(self:GetMajorFactionID());
	else
		local currentRenown = self:GetCurrentRenownLevel();
		return currentRenown and C_PlunderstormRenown.IsMaximumRenownLevel(currentRenown) or false;
	end
end

function PlunderstormRenownPreviewMixin:GetRenownRewardsForLevel(renownLevel)
	if C_MajorFactions then
		return C_MajorFactions.GetRenownRewardsForLevel(self:GetMajorFactionID(), renownLevel);
	else
		return C_PlunderstormRenown.GetRenownRewardsForLevel(renownLevel);
	end
end

function PlunderstormRenownPreviewMixin:GetRenownTextureKit()
	if C_MajorFactions then
		return C_MajorFactions.GetMajorFactionData(self:GetMajorFactionID()).textureKit;
	else
		return C_PlunderstormRenown.GetRenownTextureKit();
	end
end

function PlunderstormRenownPreviewMixin:UpdateRewards()
	BaseLayoutMixin.OnShow(self);

	self.rewardsPool:ReleaseAll();
	self:GetParent():MarkDirty();

	local currentRenownLevel = self:GetCurrentRenownLevel();

	-- If we don't have data or are maxed then we don't show a reward preview.
	if not currentRenownLevel or self:HasMaximumRenownLevel() then
		self.ignoreInLayout = true;
		self:Hide();
		return;
	else
		self.ignoreInLayout = nil;
		self:Show();
	end

	local previewLevel = currentRenownLevel + 1;

	local rewardAnchor = self.RewardsContainer;
	self.PreviewDescription:SetText(WOWLABS_RENOWN_PREVIEW_BODY_FORMAT:format(previewLevel));
	local rewards = self:GetRenownRewardsForLevel(previewLevel);
	for i, rewardInfo in ipairs(rewards) do
		local rewardFrame = self.rewardsPool:Acquire();

		-- We're showing a preview of next level's rewards.
		local rewardUnlocked = false;
		rewardFrame:SetReward(rewardInfo, rewardUnlocked, self:GetRenownTextureKit());
		rewardFrame:SetScale(0.65);

		if i == 1 then
			rewardFrame:SetPoint("TOP", rewardAnchor, "TOP");
		else
			rewardFrame:SetPoint("TOP", rewardAnchor, "BOTTOM", 0, -10);
		end

		rewardAnchor = rewardFrame;
	end

	self.RewardsContainer:MarkDirty();
	self:MarkDirty();
end
