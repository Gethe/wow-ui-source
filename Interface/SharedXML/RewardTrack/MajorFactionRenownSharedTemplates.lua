
local rewardTextureKitRegions = {
	["Toast"] = "UI-%s-Reward-Slate",
	["IconBorder"] = "UI-%s-RewardFrame",
};

MajorFactionRenownRewardMixin = {};

function MajorFactionRenownRewardMixin:SetReward(rewardInfo, unlocked, textureKit)
	self.Check:SetShown(unlocked);
	self.rewardInfo = rewardInfo;
	self.textureKit = textureKit;
	self:RefreshReward();
	self:Show();
end

function MajorFactionRenownRewardMixin:GetRewardInfo(callback)
	if RenownRewardUtil then
		return RenownRewardUtil.GetRenownRewardInfo(self.rewardInfo, callback);
	else
		-- When shown at glues we require direct overrides to display correctly.
		return self.rewardInfo.icon, self.rewardInfo.name, self.rewardInfo.description;
	end
end

function MajorFactionRenownRewardMixin:RefreshReward()
	SetupTextureKitOnRegions(self.textureKit, self, rewardTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	local icon, name, description = self:GetRewardInfo(GenerateClosure(self.RefreshReward, self));
	self.Icon:SetTexture(icon);
	self.Name:SetText(name);
	self.description = description;
end

function MajorFactionRenownRewardMixin:OnEnter()
	local name = self.Name:GetText();
	if name and self.description then
		local tooltip = GetAppropriateTooltip();
		tooltip:SetOwner(self, "ANCHOR_RIGHT", -14, -14);
		GameTooltip_SetTitle(tooltip, name);
		GameTooltip_AddNormalLine(tooltip, self.description);
		tooltip:Show();
	end
end

function MajorFactionRenownRewardMixin:OnLeave()
	local tooltip = GetAppropriateTooltip();
	tooltip:Hide();
end
