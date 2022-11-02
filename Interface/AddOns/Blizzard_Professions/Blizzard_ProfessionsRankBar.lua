local ProfessionsRankBarEvents = 
{
	"SKILL_LINES_CHANGED",
	"TRIAL_STATUS_UPDATE",
}

ProfessionsRankBarMixin = {};

function ProfessionsRankBarMixin:OnLoad()
	self.Flare:ClearAllPoints();
	self.Flare:SetPoint("RIGHT", self.Mask, "RIGHT", 0, 0);
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

function ProfessionsRankBarMixin:Update(professionInfo)
	local rankText = GenerateRankText(professionInfo.professionName, professionInfo.skillLevel, professionInfo.maxSkillLevel, professionInfo.skillModifier);
	self.Rank.Text:SetText(rankText);

	local professionChanged = self.lastProfession ~= professionInfo.profession;
	if professionChanged then
		self.lastProfession = professionInfo.profession;
		
		local kitSpecifier = Professions.GetAtlasKitSpecifier(professionInfo);
		local fillArtAtlasFormat = "Skillbar_Fill_Flipbook_%s";
		local stylizedFillAtlasName = kitSpecifier and fillArtAtlasFormat:format(kitSpecifier);
		local stylizedFillInfo = stylizedFillAtlasName and C_Texture.GetAtlasInfo(stylizedFillAtlasName);
		if not stylizedFillInfo then
			stylizedFillAtlasName = fillArtAtlasFormat:format("DefaultBlue");
			stylizedFillInfo = C_Texture.GetAtlasInfo(stylizedFillAtlasName);
		end
		self.Fill:SetAtlas(stylizedFillAtlasName, TextureKitConstants.IgnoreAtlasSize);

		local frameHeight = 34;
		local flipBookNumRows = stylizedFillInfo.height / frameHeight;
		self.BarAnimation.Flipbook:SetFlipBookRows(flipBookNumRows);
		self.BarAnimation.Flipbook:SetFlipBookFrames(flipBookNumRows * self.BarAnimation.Flipbook:GetFlipBookColumns());

		local flareArtAtlasFormat = "Skillbar_Flare_%s";
		local stylizedFlareAtlasName = kitSpecifier and flareArtAtlasFormat:format(kitSpecifier);
		local stylizedFlareInfo = stylizedFlareAtlasName and C_Texture.GetAtlasInfo(stylizedFlareAtlasName);
		self.Flare:SetShown(stylizedFlareInfo ~= nil);
		if stylizedFlareInfo then
			self.Flare:SetAtlas(stylizedFlareAtlasName, TextureKitConstants.IgnoreAtlasSize);
		end
	end

	local newRatio = 0;
	if professionInfo.maxSkillLevel > 0 then
		newRatio = math.min(professionInfo.skillLevel / professionInfo.maxSkillLevel, 1);
	end

	local sameRatio = self.ratio == newRatio;
	if professionChanged or not sameRatio then
		self.BarAnimation:Restart();
	end

	local isBarFull = (professionInfo.maxSkillLevel > 0 and professionInfo.skillLevel == professionInfo.maxSkillLevel);
	if isBarFull and not professionChanged and not sameRatio then
		self.FlareFadeOut:Restart();
	else
		self.FlareFadeOut:Stop();
		self.Flare:SetAlpha(isBarFull and 0 or 1);
	end

	if self.interpolator then
		self.interpolator:Cancel();
		self.interpolator = nil;
	end

	if sameRatio then
		return;
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