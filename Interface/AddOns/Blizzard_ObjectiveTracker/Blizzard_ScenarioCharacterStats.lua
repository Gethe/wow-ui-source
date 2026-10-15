local STAT_LINE_TEMPLATE = "ScenarioTrackerStatLineTemplate";
local STAT_LINE_SPACING = 15;
local STAT_LIST_TOP_PADDING = 14;
local STAT_LIST_BOTTOM_PADDING = 8;
local STAT_LIST_RIGHT_PADDING = 4;

local BLOCK_MIN_HEIGHT = 80;
local BLOCK_MAX_HEIGHT = 230;

local SCROLL_BOX_TOP_Y_OFFSET = -72;
local SCROLL_BOX_BOTTOM_Y_OFFSET = 0;
local SCROLL_FRAME_RIGHT_WITH_BAR = -20;
local SCROLL_FRAME_RIGHT_WITHOUT_BAR = -4;

local CHARACTER_STAT_LIST_EVENTS = {
	"UNIT_MAXHEALTH",
	"UNIT_MAXPOWER",
	"UNIT_STATS",
	"PLAYER_DAMAGE_DONE_MODS",
};

ScenarioTrackerStatLineMixin = {};

function ScenarioTrackerStatLineMixin:SetName(statName)
	self.Name:SetText(statName);
end

function ScenarioTrackerStatLineMixin:SetValue(value)
	self.Value:SetText(value);
end

local function GetHealth()
	return UnitHealthMax("player");
end

local function GetMana()
	return UnitPowerMax("player", Enum.PowerType.Mana);
end

local function GetEnergy()
	return UnitPowerMax("player", Enum.PowerType.Energy);
end

local function GetPower()
	return UnitAttackPower("player");
end

local function GetCritRaw()
	return math.ceil(GetCritChance());
end

local function GetCrit()
	return format("%d%%", GetCritRaw());
end

local function GetMeleeHitAvoidanceRaw()
	return math.ceil(-GetMeleeHitChanceTakenModifier());
end

local function GetMeleeHitAvoidance()
	return format("%d%%", GetMeleeHitAvoidanceRaw());
end

local function FormatPercent(value)
	return format("%d%%", value);
end

local DELTA_SOURCE_HEALTH = "health";
local DELTA_SOURCE_ATTACK_POWER = "maxStatChange";
local DELTA_SOURCE_CRIT_PERCENT = "critPercent";
local DELTA_SOURCE_DODGE_PERCENT = "meleeHitChanceTakenChange";

local function MakeStatLineEntry(statName, valueCallback, deltaSource, rawValueCallback, formatCallback)
	return {
		name = statName,
		valueCallback = valueCallback,
		deltaSource = deltaSource,
		rawValueCallback = rawValueCallback,
		formatCallback = formatCallback,
	};
end

local function MakePowerDeltaSource(powerType)
	return { source = "power", key = powerType };
end

local STAT_LINE_ENTRIES = {
	MakeStatLineEntry(WOWHACK_STAT_LINE_HEALTH, GetHealth, DELTA_SOURCE_HEALTH),
	MakeStatLineEntry(WOWHACK_STAT_LINE_MANA, GetMana, MakePowerDeltaSource(Enum.PowerType.Mana)),
	MakeStatLineEntry(WOWHACK_STAT_LINE_ENERGY, GetEnergy, MakePowerDeltaSource(Enum.PowerType.Energy)),
	MakeStatLineEntry(ATTACK_POWER, GetPower, DELTA_SOURCE_ATTACK_POWER),
	MakeStatLineEntry(CRIT_CHANCE, GetCrit, DELTA_SOURCE_CRIT_PERCENT, GetCritRaw, FormatPercent),
	-- This is the WoWHack version of melee avoidance
	MakeStatLineEntry(DODGE, GetMeleeHitAvoidance, DELTA_SOURCE_DODGE_PERCENT, GetMeleeHitAvoidanceRaw, FormatPercent),
};

ScenarioTrackerCharacterStatsBlockMixin = {};

function ScenarioTrackerCharacterStatsBlockMixin:OnLoad()
	if C_GameRules.IsWoWHack() then 
		-- Show when the tiered entrance traits is shown.
		EventRegistry:RegisterCallback("TieredEntranceTraits.TraitsListShown", self.Show, self);
		EventRegistry:RegisterCallback("TieredEntranceTraits.TraitsListHidden", self.Hide, self);

		-- Registers delta changes from player choice
		EventRegistry:RegisterCallback("PlayerChoiceOption.OnOptionEnter", self.SetStatDeltas, self);
		EventRegistry:RegisterCallback("PlayerChoiceOption.OnOptionLeave", self.ClearStatDeltas, self);
	end

	self.Header:SetText(PAPERDOLL_SIDEBAR_STATS);
	self:InitStatLines();
end

function ScenarioTrackerCharacterStatsBlockMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CHARACTER_STAT_LIST_EVENTS);
	self:UpdateStats();
end

function ScenarioTrackerCharacterStatsBlockMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CHARACTER_STAT_LIST_EVENTS);
end

function ScenarioTrackerCharacterStatsBlockMixin:OnEvent(_event)
	self:UpdateStats();
end

function ScenarioTrackerCharacterStatsBlockMixin:InitStatLines()
	local view = CreateScrollBoxListLinearView(STAT_LIST_TOP_PADDING, STAT_LIST_BOTTOM_PADDING, 0, STAT_LIST_RIGHT_PADDING, STAT_LINE_SPACING);
	view:SetElementInitializer(STAT_LINE_TEMPLATE, function(statLine, elementData)
		statLine:SetName(elementData.name);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local dataProvider = CreateDataProvider();
	dataProvider:Insert(unpack(STAT_LINE_ENTRIES));
	self.ScrollBox:SetDataProvider(dataProvider);

	local statLineHeight = C_XMLUtil.GetTemplateInfo(STAT_LINE_TEMPLATE).height;
	local numStatLines = #STAT_LINE_ENTRIES;
	local contentHeight = ScrollUtil.CalculateScrollBoxElementExtent(numStatLines, statLineHeight, STAT_LINE_SPACING) + self.ScrollBox:GetExtentPadding();

	local chromeHeight = math.abs(SCROLL_BOX_TOP_Y_OFFSET) + math.abs(SCROLL_BOX_BOTTOM_Y_OFFSET);
	local blockHeight = math.max(BLOCK_MIN_HEIGHT, math.min(BLOCK_MAX_HEIGHT, chromeHeight + contentHeight));
	self:SetHeight(blockHeight);

	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", self, "TOPLEFT", 0, SCROLL_BOX_TOP_Y_OFFSET),
		CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", SCROLL_FRAME_RIGHT_WITH_BAR, SCROLL_BOX_BOTTOM_Y_OFFSET),
	};
	local scrollBoxAnchorsWithoutBar = {
		CreateAnchor("TOPLEFT", self, "TOPLEFT", 0, SCROLL_BOX_TOP_Y_OFFSET),
		CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", SCROLL_FRAME_RIGHT_WITHOUT_BAR, SCROLL_BOX_BOTTOM_Y_OFFSET),
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
end


function ScenarioTrackerCharacterStatsBlockMixin:SetStatDeltas(spellID)
	if not spellID then
		return;
	end

	local healthChange, powerTypeChanges, statAuraChanges = C_Spell.GetAuraStatChanges(spellID);

	self.statDeltas = {};
	self.statDeltas[DELTA_SOURCE_HEALTH] = healthChange ~= 0 and healthChange or nil;

	if statAuraChanges then
		self.statDeltas[DELTA_SOURCE_ATTACK_POWER] = statAuraChanges.maxStatChange ~= 0 and statAuraChanges.maxStatChange or nil;
		self.statDeltas[DELTA_SOURCE_CRIT_PERCENT] = statAuraChanges.critPercentChange ~= 0 and statAuraChanges.critPercentChange or nil;
		self.statDeltas[DELTA_SOURCE_DODGE_PERCENT] = statAuraChanges.meleeHitChanceTakenChange ~= 0 and statAuraChanges.meleeHitChanceTakenChange or nil;
	end

	self.statDeltas.power = {};
	for _, change in ipairs(powerTypeChanges) do
		if change.amount ~= 0 then
			self.statDeltas.power[change.powerType] = change.amount;
		end
	end

	self:UpdateStats();
end

function ScenarioTrackerCharacterStatsBlockMixin:ClearStatDeltas()
	self.statDeltas = nil;
	self:UpdateStats();
end

function ScenarioTrackerCharacterStatsBlockMixin:GetDeltaForEntry(elementData)
	if not self.statDeltas or not elementData.deltaSource then
		return nil;
	end

	local deltaSource = elementData.deltaSource;
	if type(deltaSource) == "table" and deltaSource.source == "power" then
		return self.statDeltas.power and self.statDeltas.power[deltaSource.key];
	end

	return self.statDeltas[deltaSource];
end

function ScenarioTrackerCharacterStatsBlockMixin:UpdateStats()
	self.ScrollBox:ForEachFrame(function(statLine, elementData)
		local currentDisplay = elementData.valueCallback();
		local delta = self:GetDeltaForEntry(elementData);
		if delta then
			local currentRaw = elementData.rawValueCallback and elementData.rawValueCallback() or currentDisplay;
			local newRaw = currentRaw + delta;
			local formatFn = elementData.formatCallback or tostring;
			local newDisplay = formatFn(newRaw);
			statLine:SetValue(currentDisplay .. " > " .. GREEN_FONT_COLOR:WrapTextInColorCode(newDisplay));
		else
			statLine:SetValue(currentDisplay);
		end
	end);
end

function ScenarioTrackerCharacterStatsBlockMixin:SetTextureKit(textureKit)
	self.BG:SetAtlas(string.format("%s-challenge-flyout", textureKit), false);
	self.ScrollShadows.TopRule:SetAtlas(string.format("%s-line-top", textureKit), true);
end
