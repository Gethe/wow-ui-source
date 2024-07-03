local ProfessionsRankBarEvents = 
{
	"SKILL_LINES_CHANGED",
	"TRIAL_STATUS_UPDATE",
}
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

ProfessionsRankBarDropdownMixin = CreateFromMixins(ButtonStateBehaviorMixin);

local function IsSelected(professionInfo)
	local baseProfessionInfo = C_TradeSkillUI.GetChildProfessionInfo();
	return baseProfessionInfo.professionID == professionInfo.professionID;
end

local function SetSelected(professionInfo)
	EventRegistry:TriggerEvent("Professions.SelectSkillLine", professionInfo);
end

function ProfessionsRankBarDropdownMixin:OnLoad()
	ButtonStateBehaviorMixin.OnLoad(self);

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_PROFESSIONS_RANK_BAR");

		local baseProfessionInfo = C_TradeSkillUI.GetBaseProfessionInfo();
		local title = rootDescription:CreateTitle(baseProfessionInfo.professionName);
		title:AddInitializer(function(frame, description, menu)
			local fontString = frame.fontString;
			fontString:SetPoint("RIGHT");
			fontString:SetPoint("LEFT")
			fontString:SetFontObject("GameFontNormal");
			fontString:SetJustifyH("CENTER");
		end);

		-- Add each expansion and skill display - Dragon Isles 50/100
		for index, professionInfo in ipairs(C_TradeSkillUI.GetChildProfessionInfos()) do
			local text = professionInfo.expansionName;
			local radio = rootDescription:CreateRadio(text, IsSelected, SetSelected, professionInfo);
			radio:AddInitializer(function(frame, description, menu)
				local fontString = frame.fontString;
				fontString:SetFontObject("GameFontHighlightOutline");

				local fontString2 = frame:AttachFontString();
				fontString2:SetHeight(20);
				fontString2:SetPoint("RIGHT");
				fontString2:SetFontObject("GameFontHighlightOutline");
				fontString2:SetTextToFit(string.format("%d/%d", professionInfo.skillLevel, professionInfo.maxSkillLevel));
			end);
		end

		rootDescription:SetMinimumWidth(250);
	end)
end

function ProfessionsRankBarDropdownMixin:GetAtlas()
	return GetWowStyle1ArrowButtonState(self);
end

function ProfessionsRankBarDropdownMixin:OnButtonStateChanged()
	self.Texture:SetAtlas(self:GetAtlas(), TextureKitConstants.UseAtlasSize);
end

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
		self:Update(Professions.GetProfessionInfo());
	end
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

	if sameRatio then
		return;
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