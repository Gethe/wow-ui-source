local ProfessionsRankBarEvents = 
{
	"SKILL_LINES_CHANGED",
	"TRIAL_STATUS_UPDATE",
}

ProfessionsRankBarMixin = {};

function ProfessionsRankBarMixin:OnLoad(event, ...)
	if event == "SKILL_LINES_CHANGED" or event == "TRIAL_STATUS_UPDATE" then
		self:Update(C_TradeSkillUI.GetChildProfessionInfo());
	end
end

function ProfessionsRankBarMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsRankBarEvents);
end

function ProfessionsRankBarMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ProfessionsRankBarEvents);

	self.ratio = nil;
	self.lastProfession = nil;
end

function ProfessionsRankBarMixin:OnEvent(event, ...)
	if event == "SKILL_LINES_CHANGED" or event == "TRIAL_STATUS_UPDATE" then
		self:Update(C_TradeSkillUI.GetChildProfessionInfo());
	end
end

function ProfessionsRankBarMixin:OnEnter()
	self.Experience:Show();
	self.Rank:Show();
end

function ProfessionsRankBarMixin:OnLeave()
	self.Experience:Hide();
	self.Rank:Hide();
end

local function GenerateRankText(professionName, skillLevel, maxSkillLevel, skillModifier)
	local rankText;
	if skillModifier > 0  then
		rankText = TRADESKILL_NAME_RANK_WITH_MODIFIER:format(professionName, skillLevel, skillModifier, maxSkillLevel);
	else
		rankText = TRADESKILL_NAME_RANK:format(professionName, skillLevel, maxSkillLevel);
	end

	if GameLimitedMode_IsActive() then
		local professionCap = select(3, GetRestrictedAccountData());
		if skillLevel >= professionCap and professionCap > 0 then
			return ("%s %s%s|r"):format(rankText, RED_FONT_COLOR_CODE, CAP_REACHED_TRIAL);
		end
	end
	return rankText;
end

local flipbookAnimDuration =
{
	[Enum.Profession.Blacksmithing] = 2.6,
	[Enum.Profession.Enchanting] = 2.6,
	[Enum.Profession.Tailoring] = 2.6,
	[Enum.Profession.Jewelcrafting] = 2.6,
	[Enum.Profession.Alchemy] = 1.5,
	[Enum.Profession.Leatherworking] = 1.5,
};

function ProfessionsRankBarMixin:Update(professionInfo)
	local rankText = GenerateRankText(professionInfo.professionName, professionInfo.skillLevel, professionInfo.maxSkillLevel, professionInfo.skillModifier);
	self.Rank.Text:SetText(rankText);

	self.Fill:SetAtlas("Skillbar_Fill_Flipbook_DefaultBlue", TextureKitConstants.IgnoreAtlasSize);
	-- TODO:: Re-activate specialized fills
	--[[
	local professionChanged = self.lastProfession ~= professionInfo.profession;
	if professionChanged then
		self.lastProfession = professionInfo.profession;
		
		local kitSpecifier = Professions.GetAtlasKitSpecifier(professionInfo);
		local fillArtAtlasFormat = "Skillbar_Fill_Flipbook_%s";
		local stylizedFillAtlasName = kitSpecifier and fillArtAtlasFormat:format(kitSpecifier);
		local stylizedFillInfo = stylizedFillAtlasName and C_Texture.GetAtlasInfo(stylizedFillAtlasName);
		local duration = flipbookAnimDuration[professionInfo.profession];
		if not stylizedFillInfo or not duration then
			stylizedFillAtlasName = fillArtAtlasFormat:format("Blacksmithing");
			stylizedFillInfo = C_Texture.GetAtlasInfo(stylizedFillAtlasName);
			duration = flipbookAnimDuration[Enum.Profession.Blacksmithing];
		end
		self.Fill:SetAtlas(stylizedFillAtlasName, TextureKitConstants.IgnoreAtlasSize);

		local frameHeight = 34;
		local flipBookNumRows = stylizedFillInfo.height / frameHeight;
		self.BarAnimation.Flipbook:SetFlipBookRows(flipBookNumRows);
		self.BarAnimation.Flipbook:SetFlipBookFrames(flipBookNumRows * self.BarAnimation.Flipbook:GetFlipBookColumns());
		self.BarAnimation.Flipbook:SetDuration(duration);
	end
	--]]

	local newRatio = 0;
	if professionInfo.maxSkillLevel > 0 then
		newRatio = professionInfo.skillLevel / professionInfo.maxSkillLevel;
	end

	local sameRatio = self.ratio == newRatio;

	-- TODO:: Re-activate animation
	--[[
	if professionChanged or not sameRatio then
		self.BarAnimation:Restart();
	end
	--]]

	if sameRatio then
		return;
	end

	if self.interpolator then
		self.interpolator:Cancel();
		self.interpolator = nil;
	end

	local width = self.Fill:GetWidth();

	local function UpdateBar(progress)
		self.Mask:SetWidth(width * progress);
	end

	if professionChanged then
		UpdateBar(newRatio);
	else
		self.interpolator = CreateInterpolator(InterpolatorUtil.InterpolateEaseOut);
		local oldRatio = self.ratio or 0;
		self.interpolator:Interpolate(0, 1, .5, function(value)
			local u = InterpolatorUtil.InterpolateLinear(oldRatio, newRatio, value);
			UpdateBar(u);
		end, function() self.interpolator = nil; end);
	end

	self.ratio = newRatio;
end