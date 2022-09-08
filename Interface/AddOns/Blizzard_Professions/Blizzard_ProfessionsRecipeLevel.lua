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

function ProfessionsRecipeLevelBarMixin:SetExperience(currentExperience, maxExperience, currentLevel)
	self.currentExperience = currentExperience;
	self.maxExperience = maxExperience;
	self.currentLevel = currentLevel;

	if self:IsMaxLevel() then
		self:SetMinMaxValues(0, 1);
		self:SetValue(1);
		self.Rank:SetText(TRADESKILL_RECIPE_LEVEL_MAXIMUM);
	else
		self:SetMinMaxValues(0, maxExperience);
		self:SetValue(currentExperience);
		self.Rank:SetFormattedText(GENERIC_FRACTION_STRING, currentExperience, maxExperience);
	end
end

function ProfessionsRecipeLevelBarMixin:IsMaxLevel()
	return self.currentExperience == nil;
end

ProfessionsRecipeLevelSelectorMixin = {};

function ProfessionsRecipeLevelSelectorMixin:SetRecipeInfo(recipeInfo, currentLevel)
	self.recipeInfo = recipeInfo;
	self.currentLevel = currentLevel;

	self:SetText(TRADESKILL_RECIPE_LEVEL_DROPDOWN_BUTTON_FORMAT:format(currentLevel));
end

function ProfessionsRecipeLevelSelectorMixin:SetSelectorCallback(cb)
	self.cb = cb;
end

function ProfessionsRecipeLevelSelectorMixin:OnLoad()
	local function InitDropDown()
		for level = 1, self.recipeInfo.unlockedRecipeLevel do
			local info = UIDropDownMenu_CreateInfo();
			info.text = TRADESKILL_RECIPE_LEVEL_DROPDOWN_OPTION_FORMAT:format(level);
			info.func = GenerateClosure(self.cb, self.recipeInfo, level);
			info.checked = self.currentLevel == level;
			UIDropDownMenu_AddButton(info);
		end
	end

	UIDropDownMenu_SetInitializeFunction(self.RecipeLevelDropDown, InitDropDown);
	UIDropDownMenu_SetDisplayMode(self.RecipeLevelDropDown, "MENU");
	self.RecipeLevelDropDown.Text:SetJustifyH("CENTER");
end

function ProfessionsRecipeLevelSelectorMixin:OnEnter()
	UIMenuButtonStretchMixin.OnEnter(self);
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, TRADESKILL_RECIPE_LEVEL_DROPDOWN_TOOLTIP_TITLE);
	GameTooltip_AddNormalLine(GameTooltip, TRADESKILL_RECIPE_LEVEL_DROPDOWN_TOOLTIP_INFO);
	GameTooltip:Show();
end

function ProfessionsRecipeLevelSelectorMixin:OnLeave()
	UIMenuButtonStretchMixin.OnLeave(self);
	GameTooltip_Hide();
end

function ProfessionsRecipeLevelSelectorMixin:OnMouseDown(button)
	UIMenuButtonStretchMixin.OnMouseDown(self, button);
	ToggleDropDownMenu(1, nil, self.RecipeLevelDropDown, self, 110, 15);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end