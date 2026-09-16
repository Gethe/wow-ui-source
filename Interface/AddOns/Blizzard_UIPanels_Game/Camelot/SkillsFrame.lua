
local SKILL_RANKS_PER_SKILL_LEVEL = 5;

local function CreateWeaponSkillDisplay(isRanged)
	local weaponSkillDisplay = {};
	weaponSkillDisplay.isRanged = isRanged;

	return weaponSkillDisplay;
end

local WEAPON_SKILL_LINES = {
	[43]	= CreateWeaponSkillDisplay(false),	-- Swords
	[44]	= CreateWeaponSkillDisplay(false),	-- Axes
	[45]	= CreateWeaponSkillDisplay(true),	-- Bows
	[46]	= CreateWeaponSkillDisplay(true),	-- Guns
	[54]	= CreateWeaponSkillDisplay(false),	-- Maces
	[55]	= CreateWeaponSkillDisplay(false),	-- Two-Handed Swords
	[136]	= CreateWeaponSkillDisplay(false),	-- Staves
	[160]	= CreateWeaponSkillDisplay(false),	-- Two-Handed Maces
	[172]	= CreateWeaponSkillDisplay(false),	-- Two-Handed Axes
	[173]	= CreateWeaponSkillDisplay(false),	-- Daggers
	[176]	= CreateWeaponSkillDisplay(true),	-- Thrown
	[226]	= CreateWeaponSkillDisplay(true),	-- Crossbows
	[228]	= CreateWeaponSkillDisplay(true),	-- Wands
	[229]	= CreateWeaponSkillDisplay(false),	-- Polearms
	[162]	= CreateWeaponSkillDisplay(false),	-- Fist Weapons / Unarmed
	[3014]	= CreateWeaponSkillDisplay(false),	-- Feral Combat
};

local HIDDEN_SKILL_LINE_CATEGORIES = {
	[7] = true, -- Class Skills
};

local DEFENSE_SKILL_ID = 95;

local function ClampPercentage(value)
	return math.max(-100.0, math.min(100.0, value));
end

local function GetWeaponSkillDiff(levelOffset, weaponSkill)
	local targetDefenseSkill = (UnitLevel("player") + levelOffset) * SKILL_RANKS_PER_SKILL_LEVEL;
	return targetDefenseSkill - weaponSkill;
end

local function GetHitDodgeParryChance(levelOffset, weaponSkill)
	return GetWeaponSkillDiff(levelOffset, weaponSkill) * -0.04;
end

local function GetCriticalHitChance(levelOffset, weaponSkill)
	return GetWeaponSkillDiff(levelOffset, weaponSkill) * -0.04;
end

local function GetGlancingBlowPenalty(levelOffset, weaponSkill)
	local skillDiff = GetWeaponSkillDiff(levelOffset, weaponSkill);

	local low = 1.30 - 0.05 * skillDiff;
	if skillDiff > 10 then
		low = low + 0.1;
	end
	low = math.min(low, 0.91);
	low = math.max(low, 0.01);

	local high = 1.20 - 0.03 * skillDiff;
	if skillDiff > 10 then
		high = high + 0.1;
	end
	high = math.max(high, 0.20);
	high = math.min(high, 0.99);

	return 100.0 - math.max(0.0, math.min(1.0, (low + high) / 2.0)) * 100.0;
end

local function GetGlancingBlowChance(levelOffset, weaponSkill)
	local maxRating = UnitLevel("player") * SKILL_RANKS_PER_SKILL_LEVEL;
	weaponSkill = math.min(maxRating, weaponSkill);

	local difference = GetWeaponSkillDiff(levelOffset, weaponSkill);
	local chance = 0.02 * difference + 0.1;

	return ClampPercentage(chance * 100.0);
end

local WEAPON_SKILL_BOSS_LEVEL_OFFSET = 3;
local WEAPON_SKILL_SAME_LEVEL_OFFSET = 0;

local function FormatSignedPercent(value)
	if value == -0.0 then
		value = 0.0; -- Fixes "-0.0%" showing up in the UI
	end

	local text = format("%.2f%%", value);
	if value > 0 then
		text = "+"..text;
	end

	return text;
end

local function FormatPercent(value)
	return format("%.0f%%", value);
end

SkillsFrameMixin = {};

function SkillsFrameMixin:OnLoad()
	local view = CreateScrollBoxListLinearView();

	local function Initializer(button, elementData)
		button:Initialize(elementData);
	end

	view:SetElementIndentCalculator(function(elementData)
		local isTopLevelHeader = elementData.isHeader and not elementData.isChild;
		if isTopLevelHeader then
			return 0;
		end

		local isChildOfSubHeader = not elementData.isHeader and elementData.isChild;
		if isChildOfSubHeader then
			return 46;
		end

		return 2;
	end);

	view:SetElementFactory(function(factory, elementData)
		if not elementData.isHeader then
			factory("SkillsEntryTemplate", Initializer);
			return;
		end

		local isTopLevelHeader = elementData.isHeader and not elementData.isChild;
		if isTopLevelHeader then
			factory("SkillsHeaderTemplate", Initializer);
			return;
		end

		local isSubHeader = elementData.isHeader and elementData.isChild;
		if isSubHeader then
			factory("SkillsSubHeaderTemplate", Initializer);
			return;
		end
	end);

	local topPadding, bottomPadding, leftPadding, rightPadding = 10, 10, 10, 10;
	local elementSpacing = 3;
	view:SetPadding(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	if CharacterFrame and CharacterFrame.ModeTabs and CharacterFrame.ModeTabs.SkillsTab then
		CharacterFrame.ModeTabs.SkillsTab:SetShown(true);
	end
end

function SkillsFrameMixin:OnShow()
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:SelectFirstSkillIfNoneSelected();
	self:Update();
end

local function ShouldShowSkillLine(skillInfo)
	return (not skillInfo.isHeader and not HIDDEN_SKILL_LINE_CATEGORIES[skillInfo.skillLineCategoryID]) or
							(skillInfo.isHeader and not HIDDEN_SKILL_LINE_CATEGORIES[skillInfo.skillID]);
end

-- Opening the tab with an empty detail pane reads as broken, so fall back to the first real
-- skill. Headers are skipped; the detail pane has nothing to show for them.
function SkillsFrameMixin:SelectFirstSkillIfNoneSelected()
	local selectedIndex = C_SkillInfo.GetSelectedSkill();
	if selectedIndex and selectedIndex > 0 then
		local selectedInfo = C_SkillInfo.GetSkillLineInfo(selectedIndex);
		if selectedInfo and not selectedInfo.isHeader then
			return;
		end
	end

	for index = 1, C_SkillInfo.GetNumSkillLines() do
		local skillInfo = C_SkillInfo.GetSkillLineInfo(index);
		-- Match the filter Update uses to build the list so we land on a visible entry.
		if skillInfo and skillInfo.parentSkillLineID == 0 and not skillInfo.isHeader and ShouldShowSkillLine(skillInfo) then
			C_SkillInfo.SetSelectedSkill(index);
			EventRegistry:TriggerEvent("SkillsFrame.NewSkillLineSelected");
			return;
		end
	end
end

function SkillsFrameMixin:OnHide()
	self:UnregisterEvent("SKILL_LINES_CHANGED");
end

function SkillsFrameMixin:OnEvent(event, ...)
	if event == "SKILL_LINES_CHANGED" then
		self:Update();
	end
end

function SkillsFrameMixin:Update()
	local skillsList = {};
	for index = 1, C_SkillInfo.GetNumSkillLines() do
		local skillInfo = C_SkillInfo.GetSkillLineInfo(index);

		if skillInfo and skillInfo.parentSkillLineID == 0 and ShouldShowSkillLine(skillInfo) then
			skillInfo.skillIndex = index;
			if skillInfo.skillID == DEFENSE_SKILL_ID then
				skillInfo.modifier = select(2, UnitDefenseSkill("player"));
			end
			tinsert(skillsList, skillInfo);
		end
	end

	self.ScrollBox:SetDataProvider(CreateDataProvider(skillsList), ScrollBoxConstants.RetainScrollPosition);

	self.SkillDetailFrame:Refresh();
end

SkillDetailFrameMixin = CreateFromMixins(CharacterFrameSidePaneMixin, CallbackRegistryMixin);

local SKILL_DETAIL_DESCRIPTION_HEIGHT = 120;
local WEAPON_SKILL_DETAIL_DESCRIPTION_HEIGHT = 40;

function SkillDetailFrameMixin:OnLoad()
	CharacterFrameSidePaneMixin.OnLoad(self);
	CallbackRegistryMixin.OnLoad(self);
	self:AddStaticEventMethod(EventRegistry, "SkillsFrame.NewSkillLineSelected", self.Refresh);

	self.Description:ClearAllPoints();
	self.Description:SetPoint("TOP", self.RankBar, "BOTTOM", 0, -8);
	self.Description:SetPoint("LEFT", self, "LEFT", 0, 0);
	self.Description:SetPoint("RIGHT", self, "RIGHT", -14, 0);
end

function SkillDetailFrameMixin:OnShow()
	self:Refresh();
end

function SkillDetailFrameMixin:GetSelectedSkillInfo()
	local selectedIndex = C_SkillInfo.GetSelectedSkill();
	if not selectedIndex or selectedIndex <= 0 then
		return nil;
	end

	local skillInfo = C_SkillInfo.GetSkillLineInfo(selectedIndex);
	if not skillInfo or skillInfo.isHeader then
		return nil;
	end

	return skillInfo;
end

function SkillDetailFrameMixin:Refresh()
	local skillInfo = self:GetSelectedSkillInfo();
	if not skillInfo then
		self:SetEmpty(SKILL_DETAIL_SELECT_PROMPT);
		self.RankBar:Hide();
		return;
	end

	self:ClearEmpty();
	self.RankBar:Show();

	local height = SKILL_DETAIL_DESCRIPTION_HEIGHT;
	
	local weaponSkillData = WEAPON_SKILL_LINES[skillInfo.skillID];
	if weaponSkillData then
		height = WEAPON_SKILL_DETAIL_DESCRIPTION_HEIGHT;
	end

	self:SetPaneTitle(skillInfo.name, nil);
	self:SetPaneTitleColor(CHARACTER_FRAME_SIDE_PANEL_SKILL_COLOR);
	self:RefreshRankBar(skillInfo);
	self:SetDescription(skillInfo.description, height);

	self:ResetRows();
	if weaponSkillData then
		self:AddWeaponSkillRows(skillInfo);
	end
	self:LayoutRows();
end

function SkillDetailFrameMixin:RefreshRankBar(skillInfo)
	SkillsEntryMixin.InitializeBarForStandardSkill(self, skillInfo, self.RankBar);
	self.RankBar:TryShowBarProgressText();
end

function SkillDetailFrameMixin:AddWeaponSkillRows(skillInfo)
	local weaponSkillData = WEAPON_SKILL_LINES[skillInfo.skillID];
	if not weaponSkillData then
		return;
	end

	local weaponSkill = skillInfo.rank + skillInfo.modifier;
	local isRanged = weaponSkillData.isRanged;

	self:AddSpacer(6);
	self:AddCategory(WEAPON_SKILL_DETAIL_SAME_LEVEL_HEADER);

	local sameLevelHit = FormatSignedPercent(GetHitDodgeParryChance(WEAPON_SKILL_SAME_LEVEL_OFFSET, weaponSkill));
	local sameLevelCrit = FormatSignedPercent(GetCriticalHitChance(WEAPON_SKILL_SAME_LEVEL_OFFSET, weaponSkill));
	local sameLevelFormat = isRanged and WEAPON_SKILL_DETAIL_SAME_LEVEL_RANGED or WEAPON_SKILL_DETAIL_SAME_LEVEL;
	self:AddWrappedRow(sameLevelFormat:format(sameLevelHit, sameLevelCrit), NORMAL_FONT_COLOR);

	self:AddSpacer(8);
	self:AddCategory(WEAPON_SKILL_DETAIL_BOSS_HEADER);

	local bossHit = FormatSignedPercent(GetHitDodgeParryChance(WEAPON_SKILL_BOSS_LEVEL_OFFSET, weaponSkill));
	local bossCrit = FormatSignedPercent(GetCriticalHitChance(WEAPON_SKILL_BOSS_LEVEL_OFFSET, weaponSkill));

	if isRanged then
		self:AddWrappedRow(WEAPON_SKILL_DETAIL_BOSS_RANGED:format(bossHit, bossCrit), NORMAL_FONT_COLOR);
	else
		local glancingChance = FormatPercent(GetGlancingBlowChance(WEAPON_SKILL_BOSS_LEVEL_OFFSET, weaponSkill));
		local glancingPenalty = FormatPercent(GetGlancingBlowPenalty(WEAPON_SKILL_BOSS_LEVEL_OFFSET, weaponSkill));
		self:AddWrappedRow(WEAPON_SKILL_DETAIL_BOSS:format(bossHit, bossCrit, glancingChance, glancingPenalty), NORMAL_FONT_COLOR);
	end
end

SkillsHeaderMixin = {};

function SkillsHeaderMixin:Initialize(elementData)
	self.elementData = elementData;
	self.skillIndex = elementData.skillIndex;

	self.Name:SetText(self.elementData.name or "");

	local collapsed = self:IsCollapsed();
	if collapsed then
		self.StateIcon:SetAtlas("common-button-list-plus", TextureKitConstants.UseAtlasSize);
	else
		self.StateIcon:SetAtlas("common-button-list-minus", TextureKitConstants.UseAtlasSize);
	end
end

function SkillsHeaderMixin:IsCollapsed()
	return self.elementData.isCollapsed;
end

function SkillsHeaderMixin:ToggleCollapsed()
	if self:IsCollapsed() then
		C_SkillInfo.ExpandSkillHeader(self.skillIndex);
	else
		C_SkillInfo.CollapseSkillHeader(self.skillIndex);
	end
end

function SkillsHeaderMixin:OnMouseDown()
	self.Name:AdjustPointsOffset(1, -1);
end

function SkillsHeaderMixin:OnMouseUp()
	self.Name:AdjustPointsOffset(-1, 1);
end

function SkillsHeaderMixin:OnClick()
	self:ToggleCollapsed();
end

SkillsEntryMixin = CreateFromMixins(CallbackRegistryMixin);

function SkillsEntryMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	self:AddDynamicEventMethod(EventRegistry, "SkillsFrame.NewSkillLineSelected", self.RefreshHighlightVisuals);

	self.Content.BackgroundHighlight:SetFrameLevel(self:GetFrameLevel() - 1);
end

function SkillsEntryMixin:Initialize(elementData)
	self.elementData = elementData;
	self.skillIndex = elementData.skillIndex;

	self.Content.Name:SetText(self.elementData.name or "");

	self:InitializeBarForStandardSkill(self.elementData, self.Content.SkillsBar);

	self:RefreshHighlightVisuals();
	self.Content.SkillsBar:TryShowBarProgressText();
end

function SkillsEntryMixin:OnClick()
	C_SkillInfo.SetSelectedSkill(self.skillIndex or 0);

	if self:IsSelected() then
		-- Selecting a skill while the pane is closed would show nothing, so open it.
		CharacterFrame:SetRightPaneCollapsed(false);
	end

	EventRegistry:TriggerEvent("SkillsFrame.NewSkillLineSelected");
end

function SkillsEntryMixin:OnMouseDown()
	self.Content:AdjustPointsOffset(1, -1);
end

function SkillsEntryMixin:OnMouseUp()
	self.Content:AdjustPointsOffset(-1, 1);
end

function SkillsEntryMixin:OnEnter()
	self.Content.SkillsBar:TryShowBarProgressText();

	self:RefreshHighlightVisuals();
end

function SkillsEntryMixin:OnLeave()
	self:RefreshHighlightVisuals();
end

function SkillsEntryMixin:IsSelected()
	return C_SkillInfo.GetSelectedSkill() == self.skillIndex;
end

function SkillsEntryMixin:RefreshHighlightVisuals()
	self:RefreshBackgroundHighlight();
end

function SkillsEntryMixin:RefreshBackgroundHighlight()
	self:RefreshBackgroundHighlightColor();
	self:RefreshBackgroundHighlightOpacity();
end

function SkillsEntryMixin:RefreshBackgroundHighlightColor()
	local highlightColor = WHITE_FONT_COLOR;
	for index, region in ipairs(self.Content.BackgroundHighlight.TextureRegions) do
		region:SetVertexColor(highlightColor:GetRGB());
	end
end

function SkillsEntryMixin:RefreshBackgroundHighlightOpacity()
	local isSelected, isMouseOver = self:IsSelected(), self:IsMouseOver();
	local entryNeedsHighlight = isSelected or isMouseOver;
	if not entryNeedsHighlight then
		self.Content.BackgroundHighlight:SetAlpha(0);
		return;
	end

	local alpha = (isSelected and 0.20) or (isMouseOver and 0.10) or 0;
	self.Content.BackgroundHighlight:SetAlpha(alpha);
end

local function NormalizeBarValues(minValue, maxValue, currentValue)
	maxValue = maxValue - minValue;
	currentValue = currentValue - minValue;
	minValue = 0;

	return minValue, maxValue, currentValue;
end

local function IsSingleRankSkill(skillData)
	return skillData.maxRank == 1;
end

function SkillsEntryMixin:InitializeBarForStandardSkill(skillData, skillsBar)
	skillsBar:SetFillTextureByColorType(ColoredProgressBarMixin.ColorType.Blue);
	skillsBar:UpdateBarColor(WHITE_FONT_COLOR);

	local minValue = 0;
	local maxValue = skillData.maxRank;
	local currentValue = skillData.rank;
	minValue, maxValue, currentValue = NormalizeBarValues(minValue, maxValue, currentValue);

	skillsBar:UpdateBarValues(minValue, maxValue, currentValue);

	local text;

	if ( skillData.modifier == 0 ) then
		text = skillData.rank.." / "..skillData.maxRank;
	else
		text = skillData.rank.." |cnPURE_GREEN_COLOR:(+"..skillData.modifier..")|r / "..skillData.maxRank;
	end

	skillsBar:UpdateBarProgressText(text);
end

SkillsSubHeaderMixin = CreateFromMixins(SkillsEntryMixin);

function SkillsSubHeaderMixin:Initialize(elementData)
	SkillsEntryMixin.Initialize(self, elementData);

	self.Content.Name:ClearAllPoints();
	self.Content.Name:SetPoint("LEFT", self.ToggleCollapseButton, "RIGHT", 4, 0);
	self.Content.Name:SetPoint("RIGHT", self.Content.SkillsBar, "LEFT", -10, 0);

	self.ToggleCollapseButton:RefreshIcon();
end

function SkillsSubHeaderMixin:OnClick()
	self:ToggleCollapsed();
end

function SkillsSubHeaderMixin:IsCollapsed()
	return self.elementData.isCollapsed;
end

function SkillsSubHeaderMixin:ToggleCollapsed()
	if self:IsCollapsed() then
		C_SkillInfo.ExpandSkillHeader(self.skillIndex);
	else
		C_SkillInfo.CollapseSkillHeader(self.skillIndex);
	end
end

SkillsSubHeaderToggleCollapseButtonMixin = {};

function SkillsSubHeaderToggleCollapseButtonMixin:GetHeader()
	return self:GetParent();
end

function SkillsSubHeaderToggleCollapseButtonMixin:RefreshIcon()
	local header = self:GetHeader();
	self:GetNormalTexture():SetAtlas(header:IsCollapsed() and "campaign_headericon_closed" or "campaign_headericon_open", TextureKitConstants.UseAtlasSize);
	self:GetPushedTexture():SetAtlas(header:IsCollapsed() and "campaign_headericon_closedpressed" or "campaign_headericon_openpressed", TextureKitConstants.UseAtlasSize);
end

function SkillsSubHeaderToggleCollapseButtonMixin:OnClick()
	self:GetHeader():ToggleCollapsed();
end

SkillsBarMixin = CreateFromMixins(ColoredProgressBarMixin);

function SkillsBarMixin:OnLoad()
	ColoredProgressBarMixin.OnLoad(self);

	self:SetFillTextureByColorType(ColoredProgressBarMixin.ColorType.Blue);
end

function SkillsBarMixin:UpdateBarValues(minValue, maxValue, currentValue)
	local percent = 0;
	if maxValue ~= 0 then
		percent = currentValue / maxValue;
	end

	self:SetFillPercent(percent);
end

function SkillsBarMixin:UpdateBarColor(color)
	self.Fill:SetVertexColor(color:GetRGB());
end

function SkillsBarMixin:UpdateBarProgressText(barProgressText)
	self.barProgressText = barProgressText;
end

function SkillsBarMixin:TryShowBarProgressText()
	if not self.barProgressText then
		return;
	end

	self:SetText(self.barProgressText);
end
