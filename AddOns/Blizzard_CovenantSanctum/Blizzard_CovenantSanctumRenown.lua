local function DEBUG_GetMilestones()
	local levels = { 6, 7, 11, 12, 14, 16, 21, 24, 26, 32, 34 };
	local milestones = { };
	for i, level in ipairs(levels) do
		local t = { level = level, locked = level > 11 };
		tinsert(milestones, t);
	end
	return milestones;
end

local mainTextureKitRegions = {
	["Background"] = "CovenantSanctum-Renown-Background-%s",
	["BackgroundTile"] = "UI-Frame-%s-BackgroundTile",
	["Divider"] = "CovenantSanctum-Renown-Divider-%s",
}
local rewardTextureKitRegions = {
	["Anima"] = "CovenantSanctum-Renown-Anima-%s",
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

CovenantSanctumRenownTabMixin = {};

function CovenantSanctumRenownTabMixin:OnLoad()
	self.milestonesPool = CreateFramePool("FRAME", self, "CovenantSanctumRenownMilestoneTemplate");
end

function CovenantSanctumRenownTabMixin:OnShow()
	self:SetUpTextureKits();
	self:Refresh();
end

function CovenantSanctumRenownTabMixin:SetUpTextureKits()
	local textureKit = self:GetParent():GetTextureKit();
	if g_sanctumTextureKit ~= textureKit then
		g_sanctumTextureKit = textureKit;

		SetupTextureKit(self, mainTextureKitRegions);
		SetupTextureKit(self.RewardFrame, rewardTextureKitRegions);
		SetupTextureKit(self.MilestonesFrame, milestonesTextureKitRegions);
	end
end

function CovenantSanctumRenownTabMixin:Refresh()
	self.milestonesPool:ReleaseAll();

	local milestones = DEBUG_GetMilestones();
	local spacing = 9;
	local lastFrame, nextUnlockLevel;
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

		if not nextUnlockLevel and milestoneInfo.locked then
			nextUnlockLevel = milestoneInfo.level;
			
		end
	end

	if nextUnlockLevel then
		self.RewardFrame.Description:SetFormattedText(COVENANT_SANCTUM_RENOWN_REWARD_DESC, nextUnlockLevel);
	else
		-- todo: need design
	end
end

CovenantSanctumRenownMilestoneMixin = { }

function CovenantSanctumRenownMilestoneMixin:SetMilestone(milestoneInfo)
	local atlas;
	if milestoneInfo.locked then
		atlas = "CovenantSanctum-Renown-Icon-Locked-%s";
		color = DISABLED_FONT_COLOR;
	else
		atlas = "CovenantSanctum-Renown-Icon-Unlocked-%s";
		color = NORMAL_FONT_COLOR;
	end
	local useAtlasSize = true;
	self.Icon:SetAtlas(atlas:format(g_sanctumTextureKit), useAtlasSize);
	self.Level:SetText(milestoneInfo.level);
	self.Level:SetTextColor(color:GetRGB());
	self.LevelBorder:SetDesaturated(milestoneInfo.locked);
end