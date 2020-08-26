local mainTextureKitRegions = {
	["Background"] = "CovenantSanctum-Renown-Background-%s",
	["BackgroundTile"] = "UI-Frame-%s-BackgroundTile",
	["Divider"] = "CovenantSanctum-Renown-Divider-%s",
	["Anima"] = "CovenantSanctum-Renown-Anima-%s",
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

local g_sanctumTextureKit;
local function SetupTextureKit(frame, regions)
	SetupTextureKitOnRegions(g_sanctumTextureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end

local function GetRenownRewardDisplayData(rewardInfo, onItemUpdateCallback)
	if rewardInfo.itemID then
		local item = Item:CreateFromItemID(rewardInfo.itemID);
		local icon, name;
		if item:IsItemDataCached() then
			icon = item:GetItemIcon();
			name = item:GetItemName();
		else
			item:ContinueOnItemLoad(onItemUpdateCallback);
		end
		return icon, name, RENOWN_REWARD_ITEM_NAME_FORMAT, RENOWN_REWARD_ITEM_DESCRIPTION;
	elseif rewardInfo.mountID then
		local name, spellID, icon = C_MountJournal.GetMountInfoByID(rewardInfo.mountID);
		return icon, name, RENOWN_REWARD_MOUNT_NAME_FORMAT, RENOWN_REWARD_MOUNT_DESCRIPTION;
	elseif rewardInfo.spellID then
		local name, _, icon = GetSpellInfo(rewardInfo.spellID);
		return icon, name, RENOWN_REWARD_SPELL_NAME_FORMAT, RENOWN_REWARD_SPELL_DESCRIPTION;
	elseif rewardInfo.titleID then
		local name = GetTitleName(rewardInfo.titleID);
		return nil, name, RENOWN_REWARD_TITLE_NAME_FORMAT, RENOWN_REWARD_TITLE_DESCRIPTION;
	elseif rewardInfo.transmogID then
		local itemID = C_Transmog.GetItemIDForSource(rewardInfo.transmogID);
		local item = Item:CreateFromItemID(itemID);
		local icon, name;
		if item:IsItemDataCached() then
			icon = item:GetItemIcon();
			name = item:GetItemName();
		else
			item:ContinueOnItemLoad(onItemUpdateCallback);
		end
		return icon, name, RENOWN_REWARD_TRANSMOG_NAME_FORMAT, RENOWN_REWARD_TRANSMOG_DESCRIPTION;
	elseif rewardInfo.transmogSetID then
		local icon = TransmogUtil.GetSetIcon(rewardInfo.transmogSetID);
		local setInfo = C_TransmogSets.GetSetInfo(rewardInfo.transmogSetID);
		return icon, setInfo.name, RENOWN_REWARD_TRANSMOGSET_NAME_FORMAT, RENOWN_REWARD_TRANSMOGSET_DESCRIPTION;
	elseif rewardInfo.garrFollowerID then
		local followerInfo = C_Garrison.GetFollowerInfo(rewardInfo.garrFollowerID);
		return followerInfo.portraitIconID, followerInfo.name, RENOWN_REWARD_FOLLOWER_NAME_FORMAT, RENOWN_REWARD_FOLLOWER_DESCRIPTION;
	elseif rewardInfo.transmogIllusionSourceID then
		local visualID, name, link, icon = C_TransmogCollection.GetIllusionSourceInfo(rewardInfo.transmogIllusionSourceID);
		return icon, name, RENOWN_REWARD_ILLUSION_NAME_FORMAT, RENOWN_REWARD_ILLUSION_DESCRIPTION;
	end
end

local function GetRenownRewardInfo(rewardInfo, onItemUpdateCallback)
	local icon, name, formatString, description = GetRenownRewardDisplayData(rewardInfo, onItemUpdateCallback);
	if name and formatString then
		name = formatString:format(name);
	else
		name = rewardInfo.name;
	end
	return (rewardInfo.icon or icon), name, (rewardInfo.description or description);
end

CovenantSanctumRenownTabMixin = {};

function CovenantSanctumRenownTabMixin:OnLoad()
	self.milestonesPool = CreateFramePool("FRAME", self.MilestonesFrame, "CovenantSanctumRenownMilestoneTemplate");
	self.rewardsPool = CreateFramePool("FRAME", self, "CovenantSanctumRenownRewardTemplate");
end

function CovenantSanctumRenownTabMixin:OnShow()
	self:SetUpTextureKits();
	self:Refresh();
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
end

function CovenantSanctumRenownTabMixin:OnHide()
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
end

function CovenantSanctumRenownTabMixin:OnEvent()
	self:Refresh();
end

function CovenantSanctumRenownTabMixin:SetUpTextureKits()
	local textureKit = self:GetParent():GetTextureKit();
	if g_sanctumTextureKit ~= textureKit then
		g_sanctumTextureKit = textureKit;

		SetupTextureKit(self, mainTextureKitRegions);
		SetupTextureKit(self.MilestonesFrame, milestonesTextureKitRegions);
	end
end

function CovenantSanctumRenownTabMixin:Refresh()
	self.milestonesPool:ReleaseAll();

	local milestones = C_CovenantSanctumUI.GetRenownMilestones();
	local spacing = 9;
	local lastFrame;
	for i, milestoneInfo in ipairs(milestones) do
		local milestoneFrame = self.milestonesPool:Acquire();
		milestoneFrame:SetMilestone(milestoneInfo);
		milestoneFrame:Show();
		if lastFrame then
			milestoneFrame:SetPoint("LEFT", lastFrame, "RIGHT", spacing, 0);
		else
			local frameWidth = milestoneFrame:GetWidth();
			local offset = ((#milestones - 1) * (frameWidth + spacing)) / 2;
			milestoneFrame:SetPoint("CENTER", self.MilestonesFrame, -offset, 0);
		end
		lastFrame = milestoneFrame;
	end
	self:RefreshRewards();
end

function CovenantSanctumRenownTabMixin:RefreshRewards()
	self.rewardsPool:ReleaseAll();
	local nextLevel = C_CovenantSanctumUI.GetRenownLevel() + 1;
	local rewards = C_CovenantSanctumUI.GetRenownRewardsForLevel(nextLevel);
	local numRewards = #rewards;
	
	for i, rewardInfo in ipairs(rewards) do
		local rewardFrame = self.rewardsPool:Acquire();
		if numRewards == 1 then
			rewardFrame:SetPoint("TOP", 0, -171);
		elseif numRewards == 2 then
			if i == 1 then
				rewardFrame:SetPoint("TOP", 0, -115);
			elseif i == 2 then
				rewardFrame:SetPoint("TOP", 0, -228);
			end
		else
			if i == 1 then
				rewardFrame:SetPoint("TOP", -195, -115);
			elseif i == 2 then
				rewardFrame:SetPoint("TOP", 195, -115);
			elseif i == 3 then
				rewardFrame:SetPoint("TOP", -195, -228);
			else
				rewardFrame:SetPoint("TOP", 195, -228);
			end
		end
		rewardFrame:SetReward(rewardInfo);
	end

	if numRewards > 0 then
		self.Description:SetFormattedText(COVENANT_SANCTUM_RENOWN_REWARD_DESC, nextLevel);
	else
		-- todo: need design
		self.Description:SetFormattedText(COVENANT_SANCTUM_RENOWN_REWARD_DESC, 0);
	end
end

CovenantSanctumRenownMilestoneMixin = { }

function CovenantSanctumRenownMilestoneMixin:SetMilestone(milestoneInfo)
	self.level = milestoneInfo.level;
	self.isCapstone = milestoneInfo.isCapstone;

	local atlas;
	if milestoneInfo.locked then
		if milestoneInfo.isCapstone then
			atlas = "CovenantSanctum-Renown-ImprovedIcon-Locked-%s";
		else
			atlas = "CovenantSanctum-Renown-Icon-Locked-%s";
		end
		color = DISABLED_FONT_COLOR;
	else
		if milestoneInfo.isCapstone then
			atlas = "CovenantSanctum-Renown-ImprovedIcon-Unlocked-%s";
		else	
			atlas = "CovenantSanctum-Renown-Icon-Unlocked-%s";
		end
		color = NORMAL_FONT_COLOR;
	end
	local useAtlasSize = true;
	self.Icon:SetAtlas(atlas:format(g_sanctumTextureKit), useAtlasSize);
	self.Level:SetText(milestoneInfo.level);
	self.Level:SetTextColor(color:GetRGB());
	self.LevelBorder:SetDesaturated(milestoneInfo.locked);
end

function CovenantSanctumRenownMilestoneMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -4, -4);
	self:RefreshTooltip();
end

function CovenantSanctumRenownMilestoneMixin:RefreshTooltip()
	if not GameTooltip:GetOwner() == self then
		return;
	end

	local onItemUpdateCallback = GenerateClosure(self.RefreshTooltip, self);
	local rewards = C_CovenantSanctumUI.GetRenownRewardsForLevel(self.level);
	local addRewards = true;
	if self.isCapstone then
		GameTooltip_SetTitle(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_TITLE);
		GameTooltip_AddNormalLine(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_DESC);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddHighlightLine(GameTooltip, RENOWN_REWARD_CAPSTONE_TOOLTIP_DESC2);
	else
		if #rewards == 1 then
			local icon, name, description = GetRenownRewardInfo(rewards[1], onItemUpdateCallback);
			GameTooltip_SetTitle(GameTooltip, name);
			GameTooltip_AddNormalLine(GameTooltip, description);
			addRewards = false;
		else
			GameTooltip_SetTitle(GameTooltip, string.format(RENOWN_REWARD_MILESTONE_TOOLTIP_TITLE, self.level));
		end
	end
	if addRewards then
		for i, rewardInfo in ipairs(rewards) do
			local icon, name, description = GetRenownRewardInfo(rewardInfo, onItemUpdateCallback);
			if name then
				GameTooltip_AddNormalLine(GameTooltip, string.format(RENOWN_REWARD_TOOLTIP_REWARD_LINE, name));
			end
		end
	end
	GameTooltip:Show();	
end

CovenantSanctumRenownRewardMixin = { }

function CovenantSanctumRenownRewardMixin:SetReward(rewardInfo)
	SetupTextureKit(self, rewardTextureKitRegions);
	self.rewardInfo = rewardInfo;
	self:RefreshReward();
	self:Show();
end

function CovenantSanctumRenownRewardMixin:RefreshReward()
	local icon, name, description = GetRenownRewardInfo(self.rewardInfo, GenerateClosure(self.RefreshReward, self));
	self.Icon:SetTexture(icon);
	self.Name:SetText(name);
	self.description = description;
end

function CovenantSanctumRenownRewardMixin:OnEnter()
	local name = self.Name:GetText();
	if name and self.description then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -14, -14);
		GameTooltip_SetTitle(GameTooltip, name);
		GameTooltip_AddNormalLine(GameTooltip, self.description);
		GameTooltip:Show();
	end
end