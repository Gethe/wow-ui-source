local LEGACY_CHALLENGE_OBJECTIVE_COLUMNS = 2;
local LEGACY_CHALLENGE_BASE_DESCRIPTION_WIDTH = 400;

-- Must match the font the Description/HiddenDescription font strings inherit in Blizzard_LegacySystemTemplates.xml.
local LEGACY_CHALLENGE_DESCRIPTION_FONT = "SystemFont_Shadow_Med1";

local LEGACY_CHALLENGE_ART = {
	card = {
		completed = "Legacy-Challenge-Cards",
		incomplete = "Legacy-Challenge-Cards-Disable",
	},
	expandedCard = {
		top = { completed = "Legacy-Challenge-Cards-tiled-top", incomplete = "Legacy-Challenge-Cards-tiled-top-Disable" },
		middle = { completed = "Legacy-Challenge-Cards-tiled-vertical", incomplete = "Legacy-Challenge-Cards-tiled-vertical-Disable" },
		bottom = { completed = "Legacy-Challenge-Cards-tiled-bottom", incomplete = "Legacy-Challenge-Cards-tiled-bottom-Disable" },
	},
	titleBar = {
		completed = { account = "Legacy-Challenge-Cards-Ribbon-Blue", normal = "Legacy-Challenge-Cards-Ribbon-Brown" },
		incomplete = { account = "Legacy-Challenge-Cards-Ribbon-Blue-Disable", normal = "Legacy-Challenge-Cards-Ribbon-Brown-Disable" },
	},
	plusMinus = {
		collapsed = "128-redbutton-plus",
		expanded = "128-redbutton-minus",
	},
	text = {
		color = WHITE_FONT_COLOR,
		dimmedColor = GRAY_FONT_COLOR,
	},
	description = {
		offsetX = 72,
		offsetXWithPlusMinus = 95,
		offsetY = -2,
	},
	objectives = {
		rowHeight = 30,
		spacingX = 10,
		spacingY = 5,
		offsetX = 20,
		offsetY = -23,
	},
};

local function ShouldShowCriteriaProgress(flags, quantity, reqQuantity)
	if not flags or not quantity or not reqQuantity or reqQuantity <= 0 then
		return false;
	end

	return bit.band(flags, EVALUATION_TREE_FLAG_PROGRESS_BAR) == EVALUATION_TREE_FLAG_PROGRESS_BAR;
end

local function GetTitleBarAtlas(completed, accountWide)
	local art = LEGACY_CHALLENGE_ART.titleBar;
	local stateArt = completed and art.completed or art.incomplete;
	return accountWide and stateArt.account or stateArt.normal;
end

-- ACHIEVEMENTUI_FONTHEIGHT tracks the achievement description font, which the Legacy cards do not use.
local function CalculateNumLines(fontString)
	local _font, fontHeight = fontString:GetFont();
	if not fontHeight or fontHeight <= 0 then
		return 0;
	end

	return math.ceil(fontString:GetHeight() / fontHeight);
end

local function CalculateExpandedHeight(collapsedHeight, objectivesHeight, descriptionHeight, numLines)
	local height = collapsedHeight + objectivesHeight;
	if objectivesHeight > 0 or numLines > AchievementTemplateMixin.GetMaxCollapsedLines() then
		height = height + descriptionHeight - ACHIEVEMENTBUTTON_DESCRIPTIONHEIGHT;
	end

	return height;
end

local function GetLegacyChallengeDescriptionWidth()
	return LEGACY_CHALLENGE_BASE_DESCRIPTION_WIDTH;
end

-- The base shield gets Saturate/Desaturate assigned by AchievementShield_OnLoad, which this template omits
-- because the Legacy points art is identical for completed and incomplete challenges.
LegacyChallengeShieldMixin = {};

function LegacyChallengeShieldMixin:Saturate()
end

function LegacyChallengeShieldMixin:Desaturate()
end

LegacyChallengeIconFrameMixin = {};

function LegacyChallengeIconFrameMixin:Saturate()
	self.texture:SetDesaturated(false);
end

function LegacyChallengeIconFrameMixin:Desaturate()
	self.texture:SetDesaturated(true);
end

LegacyChallengeCriteriaMixin = {};

function LegacyChallengeCriteriaMixin:Init(text, completed, flags, quantity, reqQuantity)
	local art = LEGACY_CHALLENGE_ART.text;
	local showProgress = ShouldShowCriteriaProgress(flags, quantity, reqQuantity);
	local color = completed and art.color or art.dimmedColor;

	self.showingProgress = showProgress;

	-- Counted criteria replace the text row with the Legacy point bar art, since the count carries the meaning.
	self.Name:SetShown(not showProgress);
	self.Name:SetText(text);
	self.Name:SetTextColor(color:GetRGBA());
	self.Check:SetShown(completed and not showProgress);
	self.Background:SetShown(not showProgress);

	self.ProgressBarBackground:SetShown(showProgress);
	self.ProgressBar:SetShown(showProgress);
	if showProgress then
		self.ProgressBar:SetMinMaxValues(0, reqQuantity);
		self.ProgressBar:SetValue(Clamp(quantity, 0, reqQuantity));
		self.ProgressBar.Text:SetFormattedText(GENERIC_FRACTION_STRING_WITH_SPACING, quantity, reqQuantity);
	end
end

function LegacyChallengeCriteriaMixin:IsShowingProgress()
	return self.showingProgress;
end

LegacyChallengeObjectivesMixin = {};

function LegacyChallengeObjectivesMixin:OnLoad()
	self.criteriaPool = CreateFramePool("FRAME", self, "LegacyChallengeCriteriaTemplate");
	self:Clear();
end

function LegacyChallengeObjectivesMixin:OnHide()
	if self.clearOnClose then
		self:Clear();
	end
end

function LegacyChallengeObjectivesMixin:Clear()
	self.criteriaPool:ReleaseAll();
	self:ClearAllPoints();
	self:SetHeight(0);
end

function LegacyChallengeObjectivesMixin:CalculateHeight(numCriteria)
	if numCriteria == 0 then
		return 0;
	end

	local art = LEGACY_CHALLENGE_ART.objectives;
	local numRows = math.ceil(numCriteria / LEGACY_CHALLENGE_OBJECTIVE_COLUMNS);
	return numRows * art.rowHeight + (numRows - 1) * art.spacingY;
end

function LegacyChallengeObjectivesMixin:Display(id, width)
	self.criteriaPool:ReleaseAll();

	local art = LEGACY_CHALLENGE_ART.objectives;
	local numCriteria = GetAchievementNumCriteria(id) or 0;
	local height = self:CalculateHeight(numCriteria);
	self:SetHeight(height);
	if numCriteria == 0 then
		return 0;
	end

	local cellWidth = (width - art.spacingX - (2 * art.offsetX)) / LEGACY_CHALLENGE_OBJECTIVE_COLUMNS;

	for i = 1, numCriteria do
		local criteriaString, _criteriaType, criteriaCompleted, quantity, reqQuantity, _charName, criteriaFlags = GetAchievementCriteriaInfo(id, i);

		local criteria = self.criteriaPool:Acquire();
		criteria:Init(criteriaString, criteriaCompleted, criteriaFlags, quantity, reqQuantity);

		local row = math.floor((i - 1) / LEGACY_CHALLENGE_OBJECTIVE_COLUMNS);
		local offsetY = -row * (art.rowHeight + art.spacingY);

		criteria:ClearAllPoints();

		-- A lone progress bar spans the card rather than sitting in a half-width column.
		if numCriteria == 1 and criteria:IsShowingProgress() then
			criteria:SetHeight(art.rowHeight);
			criteria:SetPoint("TOPLEFT", self, "TOPLEFT", art.offsetX, offsetY);
			criteria:SetPoint("TOPRIGHT", self, "TOPRIGHT", -art.offsetX, offsetY);
		else
			local isLeftColumn = math.fmod(i, LEGACY_CHALLENGE_OBJECTIVE_COLUMNS) == 1;
			local point = isLeftColumn and "TOPLEFT" or "TOPRIGHT";
			local offsetX = isLeftColumn and art.offsetX or -art.offsetX;

			criteria:SetSize(cellWidth, art.rowHeight);
			criteria:SetPoint(point, self, point, offsetX, offsetY);
		end

		criteria:Show();
	end

	return height;
end

LegacyChallengeTemplateMixin = CreateFromMixins(AchievementTemplateMixin);

function LegacyChallengeTemplateMixin:OnLoad()
	AchievementTemplateMixin.OnLoad(self);

	-- Base OnLoad sizes the collapsed description with the shared achievement font height, not the Legacy card font.
	local _font, fontHeight = self.Description:GetFont();
	self.Description:SetHeight(fontHeight * AchievementTemplateMixin.GetMaxCollapsedLines());

	local descriptionWidth = GetLegacyChallengeDescriptionWidth();
	self.Description:SetWidth(descriptionWidth);
	self.HiddenDescription:SetWidth(descriptionWidth);
end

function LegacyChallengeTemplateMixin:Init(elementData)
	AchievementTemplateMixin.Init(self, elementData);

	-- Saturate/Desaturate and Collapse/Expand all early out on recycled buttons, so refresh unconditionally.
	self:RefreshStateArt();
end

function LegacyChallengeTemplateMixin:OnClick(buttonName, down)
	AchievementTemplateMixin.OnClick(self, buttonName, down);

	if buttonName == "LeftButton" then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end

	if InputUtil.IsGamepadUIEnabled() then
		local CHALLENGES_PAGE_IDX = 2;
		local gamepadFooter = LegacySystemFrame.footers[CHALLENGES_PAGE_IDX];
		if gamepadFooter then
			gamepadFooter:Refresh();
		end
	end
end

function LegacyChallengeTemplateMixin:InitRewards(_rewardText)
	-- no-op for Legacy Challenges
end

function LegacyChallengeTemplateMixin:SetRewardVertexColor(_r, _g, _b)
	-- no-op for Legacy Challenges
end

function LegacyChallengeTemplateMixin:ShowGuildArt()
	-- no-op for Legacy Challenges
end

function LegacyChallengeTemplateMixin:HideGuildArt()
	-- no-op for Legacy Challenges
end

-- Legacy Challenges have no offscreen measuring frame; CalculateSelectedHeight sizes rows instead of measuring them.
function LegacyChallengeTemplateMixin:GetObjectiveFrame()
	return LegacyChallengeObjectives;
end

function LegacyChallengeTemplateMixin:DisplayObjectives(id, completed)
	local art = LEGACY_CHALLENGE_ART.objectives;
	local objectivesFrame = self:GetObjectiveFrame();
	objectivesFrame:ClearAllPoints();
	objectivesFrame:SetParent(self);
	objectivesFrame.completed = completed;

	local width = self:GetWidth();
	local objectivesHeight = objectivesFrame:Display(id, width) or 0;
	if objectivesHeight > 0 then
		objectivesFrame:SetPoint("TOP", self.HiddenDescription, "BOTTOM", 0, art.offsetY);
		objectivesFrame:SetPoint("LEFT", self, "LEFT");
		objectivesFrame:SetPoint("RIGHT", self, "RIGHT");
		objectivesFrame:Show();
	else
		objectivesFrame:Hide();
	end

	objectivesFrame.id = id;
	return CalculateExpandedHeight(self:GetCollapsedHeight(), objectivesHeight, self.HiddenDescription:GetHeight(), CalculateNumLines(self.HiddenDescription));
end

-- The ScrollBox sizes rows from this before they are built, so it measures a placeholder instead of the button.
function LegacyChallengeTemplateMixin.CalculateSelectedHeight(elementData, collapsedHeight)
	local id, _name, _points, _completed, _month, _day, _year, description = GetAchievementInfo(elementData.category, elementData.index);
	local objectivesHeight = LegacyChallengeObjectives:CalculateHeight(GetAchievementNumCriteria(id) or 0);

	-- The shared placeholder measures in the achievement description font, so match the Legacy card font while measuring.
	local placeholder = AchievementFrame.PlaceholderHiddenDescription;
	local previousFontObject = placeholder:GetFontObject();
	placeholder:SetFontObject(LEGACY_CHALLENGE_DESCRIPTION_FONT);
	placeholder:SetText(description);

	local descriptionHeight = placeholder:GetHeight();
	local numLines = CalculateNumLines(placeholder);

	placeholder:SetFontObject(previousFontObject);

	return CalculateExpandedHeight(collapsedHeight or ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT, objectivesHeight, descriptionHeight, numLines);
end

function LegacyChallengeTemplateMixin:SetHighlightShown(_shown)
	-- no-op for Legacy Challenges; the card art conveys selection
end

-- The XML template owns the icon frame art; this override only keeps the base achievement/guild art from being applied.
function LegacyChallengeTemplateMixin:UpdateHeaderArt()
end

-- The Legacy texture kit has no zero-point badge, so the points icon is simply hidden.
function LegacyChallengeTemplateMixin:UpdateShieldArt(points)
	self.Shield.Icon:SetShown(points > 0);
end

function LegacyChallengeTemplateMixin:UpdatePlusMinusTexture()
	AchievementTemplateMixin.UpdatePlusMinusTexture(self);

	local art = LEGACY_CHALLENGE_ART.description;
	local offsetX = self:ShouldShowPlusMinus() and art.offsetXWithPlusMinus or art.offsetX;
	self.Description:SetPoint("TOPLEFT", self.TitleBar, "BOTTOMLEFT", offsetX, art.offsetY);
	self.HiddenDescription:SetPoint("TOPLEFT", self.TitleBar, "BOTTOMLEFT", offsetX, art.offsetY);
end

function LegacyChallengeTemplateMixin:UpdatePlusMinusArt()
	local art = LEGACY_CHALLENGE_ART.plusMinus;
	self.PlusMinus:SetAtlas(self.collapsed and art.collapsed or art.expanded);
end

-- Selection-dependent art, so it cannot live in Saturate/Desaturate alone.
function LegacyChallengeTemplateMixin:RefreshStateArt()
	if not self.id then
		return; -- This happens when we create buttons
	end

	local selected = self:IsSelected();
	local dimmed = not self.completed and not selected;

	self.Background:SetAtlas(self.completed and LEGACY_CHALLENGE_ART.card.completed or LEGACY_CHALLENGE_ART.card.incomplete, TextureKitConstants.IgnoreAtlasSize);

	local expandedCard = LEGACY_CHALLENGE_ART.expandedCard;
	local variant = self.completed and "completed" or "incomplete";
	self.BackgroundTop:SetAtlas(expandedCard.top[variant], TextureKitConstants.UseAtlasSize);
	self.BackgroundMiddle:SetAtlas(expandedCard.middle[variant], TextureKitConstants.UseAtlasSize);
	self.BackgroundMiddle:SetVertTile(true); -- SetAtlas re-applies the atlas wrap mode, clearing the tiling set in XML.
	self.BackgroundBottom:SetAtlas(expandedCard.bottom[variant], TextureKitConstants.UseAtlasSize);

	self.SelectedOverlay:SetShown(selected);

	local textColor = dimmed and LEGACY_CHALLENGE_ART.text.dimmedColor or LEGACY_CHALLENGE_ART.text.color;
	self.Label:SetTextColor(textColor:GetRGBA());
	self.Description:SetTextColor(textColor:GetRGBA());
	self.HiddenDescription:SetTextColor(textColor:GetRGBA());

	if dimmed then
		self.Icon:Desaturate();
	else
		self.Icon:Saturate();
	end
end

-- Expanded cards tile a top/middle/bottom set instead of stretching the single-piece background.
function LegacyChallengeTemplateMixin:UpdateBackgroundForHeight(_height)
	local expanded = not self.collapsed;
	self.Background:SetShown(not expanded);
	self.BackgroundTop:SetShown(expanded);
	self.BackgroundMiddle:SetShown(expanded);
	self.BackgroundBottom:SetShown(expanded);
end

function LegacyChallengeTemplateMixin:Saturate()
	self.saturatedStyle = self.accountWide and "account" or "normal";

	self:RefreshStateArt();
	self.TitleBar:SetAtlas(GetTitleBarAtlas(true, self.accountWide), TextureKitConstants.IgnoreAtlasSize);

	self.Shield:Saturate();
	self:UpdatePlusMinusTexture();
end

function LegacyChallengeTemplateMixin:Desaturate()
	self.saturatedStyle = nil;

	self:RefreshStateArt();
	self.TitleBar:SetAtlas(GetTitleBarAtlas(false, self.accountWide), TextureKitConstants.IgnoreAtlasSize);

	self.Shield:Desaturate();
	self:UpdatePlusMinusTexture();
end
