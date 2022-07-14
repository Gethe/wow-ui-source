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

	local professionChanged = self.lastParentProfessionName ~= professionInfo.parentProfessionName;
	if professionChanged then
		self.lastParentProfessionName = professionInfo.parentProfessionName;
		self.Fill:SetAtlas(("Professions_ProgBar_Static_%s"):format(professionInfo.parentProfessionName));
	end
	
	local function UpdateBar(u, width)
		self.Fill:SetTexCoord(1.0 - u, 1, 0, 1);
		self.Fill:SetWidth(width);
		self.Fill:SetShown(width ~= 0); -- Workaround for a bug where setting the Fill's width to 0 causes it to appear at 512 width.
	end

	local newRatio = 0;
	if professionInfo.maxSkillLevel > 0 then
		newRatio = professionInfo.skillLevel / professionInfo.maxSkillLevel;
	end

	local width = self:GetWidth();
	local newFillWidth = width * newRatio;

	if professionChanged then
		UpdateBar(newRatio, newFillWidth);
	else
		local oldFillWidth = self.Fill:GetWidth();
		local oldRatio = (oldFillWidth / width);

		local interpolator = CreateInterpolator(InterpolatorUtil.InterpolateEaseOut);
		interpolator:Interpolate(0, 1, .5, function(value)
			local u = InterpolatorUtil.InterpolateLinear(oldRatio, newRatio, value);
			local width = InterpolatorUtil.InterpolateLinear(oldFillWidth, newFillWidth, value);
			UpdateBar(u, width);
		end);
	end
end