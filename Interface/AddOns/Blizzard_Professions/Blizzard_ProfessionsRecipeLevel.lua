ProfessionsRecipeLevelBarMixin = {};

function ProfessionsRecipeLevelBarMixin:OnLoad()
	self:SetStatusBarColor(TRADESKILL_EXPERIENCE_COLOR:GetRGB());
end

function ProfessionsRecipeLevelBarMixin:OnEnter()
	self.Rank:Show();

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if self:IsMaxLevel() then
		GameTooltip_SetTitle(GameTooltip, TRADESKILL_RECIPE_LEVEL_TOOLTIP_HIGHEST_RANK, NORMAL_FONT_COLOR);
		GameTooltip_AddColoredLine(GameTooltip, TRADESKILL_RECIPE_LEVEL_TOOLTIP_HIGHEST_RANK_EXPLANATION, GREEN_FONT_COLOR);
	else
		local experiencePercent = math.floor((self.currentExperience / self.maxExperience) * 100);
		GameTooltip_SetTitle(GameTooltip, TRADESKILL_RECIPE_LEVEL_TOOLTIP_RANK_FORMAT:format(self.currentLevel), NORMAL_FONT_COLOR);
		GameTooltip_AddHighlightLine(GameTooltip, TRADESKILL_RECIPE_LEVEL_TOOLTIP_EXPERIENCE_FORMAT:format(self.currentExperience, self.maxExperience, experiencePercent));
		GameTooltip_AddColoredLine(GameTooltip, TRADESKILL_RECIPE_LEVEL_TOOLTIP_LEVELING_FORMAT:format(self.currentLevel + 1), GREEN_FONT_COLOR);
	end

	GameTooltip:Show();
end

function ProfessionsRecipeLevelBarMixin:OnLeave()
	self.Rank:Hide();

	GameTooltip_Hide();
end

function ProfessionsRecipeLevelBarMixin:SetExperience(recipeInfo)
	self.currentExperience = recipeInfo.currentRecipeExperience;
	self.maxExperience = recipeInfo.nextLevelRecipeExperience;
	self.currentLevel = recipeInfo.unlockedRecipeLevel;

	if self:IsMaxLevel() then
		self:SetMinMaxValues(0, 1);
		self:SetValue(1);
		self.Rank:SetText(TRADESKILL_RECIPE_LEVEL_MAXIMUM);
	else
		self:SetMinMaxValues(0, self.maxExperience);
		self:SetValue(self.currentExperience);
		self.Rank:SetFormattedText(GENERIC_FRACTION_STRING, self.currentExperience, self.maxExperience);
	end
end

function ProfessionsRecipeLevelBarMixin:IsMaxLevel()
	return self.currentExperience == nil;
end

ProfessionsRecipeLevelDropdownMixin = {};

function ProfessionsRecipeLevelDropdownMixin:OnLoad()
	self:SetWidth(110);
	self.Text:SetJustifyH("CENTER");

	self:SetSelectionTranslator(function(selection)
		return TRADESKILL_RECIPE_LEVEL_DROPDOWN_BUTTON_FORMAT:format(selection.data);
	end);
end

function ProfessionsRecipeLevelDropdownMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, TRADESKILL_RECIPE_LEVEL_DROPDOWN_TOOLTIP_TITLE);
	GameTooltip_AddNormalLine(GameTooltip, TRADESKILL_RECIPE_LEVEL_DROPDOWN_TOOLTIP_INFO);
	GameTooltip:Show();
end

function ProfessionsRecipeLevelDropdownMixin:OnLeave()
	GameTooltip_Hide();
end

function ProfessionsRecipeLevelDropdownMixin:SetRecipeInfo(recipeInfo, currentLevel)
	self.recipeInfo = recipeInfo;
	self.currentLevel = currentLevel;

	local function IsSelected(level)
		return self.currentLevel == level;
	end

	local function SetSelected(level)
		self.currentLevel = level;

		if self.callback then
			self.callback(self.recipeInfo, level);
		end
	end
	
	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_PROFESSIONS_RECIPE_LEVEL");

		for level = 1, self.recipeInfo.unlockedRecipeLevel do
			local text = TRADESKILL_RECIPE_LEVEL_DROPDOWN_OPTION_FORMAT:format(level);
			rootDescription:CreateRadio(text, IsSelected, SetSelected, level);
		end
	end);
end

function ProfessionsRecipeLevelDropdownMixin:SetSelectionCallback(callback)
	self.callback = callback;
end