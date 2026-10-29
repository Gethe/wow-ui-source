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

ScenarioTrackerCharacterStatsBlockMixin = {};

function ScenarioTrackerCharacterStatsBlockMixin:OnLoad()
	-- WoWHackCharacterStats is not defined in every game type; the block stays inert without it.
	if not WoWHackCharacterStats then
		return;
	end

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
		self:UpdateStatLine(statLine, elementData);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local statLineEntries = WoWHackCharacterStats.Entries;
	local dataProvider = CreateDataProvider();
	dataProvider:Insert(unpack(statLineEntries));
	self.ScrollBox:SetDataProvider(dataProvider);

	local statLineHeight = C_XMLUtil.GetTemplateInfo(STAT_LINE_TEMPLATE).height;
	local numStatLines = #statLineEntries;
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

	local DeltaSource = WoWHackCharacterStats.DeltaSource;
	local DELTA_SOURCE_HEALTH = DeltaSource.Health;
	local DELTA_SOURCE_ATTACK_POWER = DeltaSource.AttackPower;
	local DELTA_SOURCE_CRIT_PERCENT = DeltaSource.CritPercent;
	local DELTA_SOURCE_DODGE_PERCENT = DeltaSource.DodgePercent;

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

	self.statDeltas.statPoints = {};
	for _, entry in ipairs(WoWHackCharacterStats.Entries) do
		local deltaSource = entry.deltaSource;
		if type(deltaSource) == "table" and deltaSource.source == "statPoints" then
			local change = C_WoWHackCharacterStats.GetStatPointsChangeBySpellID(deltaSource.key, spellID);
			if change ~= 0 then
				self.statDeltas.statPoints[deltaSource.key] = change;
			end
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

	if type(deltaSource) == "table" and deltaSource.source == "statPoints" then
		return self.statDeltas.statPoints and self.statDeltas.statPoints[deltaSource.key];
	end

	return self.statDeltas[deltaSource];
end

function ScenarioTrackerCharacterStatsBlockMixin:UpdateStatLine(statLine, elementData)
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
end

function ScenarioTrackerCharacterStatsBlockMixin:UpdateStats()
	self.ScrollBox:ForEachFrame(function(statLine, elementData)
		self:UpdateStatLine(statLine, elementData);
	end);
end

function ScenarioTrackerCharacterStatsBlockMixin:SetTextureKit(textureKit)
	self.BG:SetAtlas(string.format("%s-challenge-flyout", textureKit), false);
	self.ScrollShadows.TopRule:SetAtlas(string.format("%s-line-top", textureKit), true);
end
