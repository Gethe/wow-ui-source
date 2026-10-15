
-- Tree IDs for each progression entry
local ARCANIST_TREE_ID = 1160;
local ANTIQUARIAN_TREE_ID = 1165;
local OUTFITTER_TREE_ID = 1261;

-- All Scribe class trait tree IDs, used to aggregate progress across every Scribe class.
local SCRIBE_CLASS_IDS = { Enum.ScribeClassID.Witch, Enum.ScribeClassID.Slayer, Enum.ScribeClassID.Inquisitor };

-- Returns the trait tree IDs for every Scribe class.
local function GetScribeTreeIDs()
	local treeIDs = {};
	for _, classID in ipairs(SCRIBE_CLASS_IDS) do
		local classInfo = C_ScribeUI.GetClassInfoFromClassID(classID);
		if classInfo and classInfo.traitTreeID then
			table.insert(treeIDs, classInfo.traitTreeID);
		end
	end
	return treeIDs;
end

-- Returns totalActiveRanks, totalRanks for a given treeID.
-- Returns nil, nil when the configID cannot be resolved (tree not available).
local function GetRankProgress(treeID)
	local configID = C_Traits.GetConfigIDByTreeID(treeID);
	if not configID then
		return nil, nil;
	end

	local totalActiveRanks = 0;
	local totalRanks = 0;
	local treeNodes = C_Traits.GetTreeNodes(treeID);
	if treeNodes then
		for _, nodeID in ipairs(treeNodes) do
			local nodeInfo = C_Traits.GetNodeInfo(configID, nodeID);
			if nodeInfo then
				totalActiveRanks = totalActiveRanks + nodeInfo.activeRank;
				totalRanks = totalRanks + nodeInfo.maxRanks;
			end
		end
	end

	return totalActiveRanks, totalRanks;
end

local PROGRESSION_ENTRIES = {
	{
		name = WOWHACK_CHARACTER_PROGRESSION_ARCANIST,
		treeID = ARCANIST_TREE_ID,
		color = SCRIBE_POINTS_COLOR,
	},
	{
		name = WOWHACK_CHARACTER_PROGRESSION_ANTIQUARIAN,
		treeID = ANTIQUARIAN_TREE_ID,
		color = SCRIBE_POINTS_COLOR,
	},
	{
		name = WOWHACK_CHARACTER_PROGRESSION_OUTFITTER,
		treeID = OUTFITTER_TREE_ID,
		color = SCRIBE_POINTS_COLOR,
	},
	{
		name = WOWHACK_CHARACTER_PROGRESSION_SCRIBE,
		treeIDsCallback = GetScribeTreeIDs,
		color = SCRIBE_POINTS_COLOR,
	},
};

local CHARACTER_PROGRESSION_LIST_EVENTS = {
	"TRAIT_CONFIG_UPDATED",
	"TRAIT_NODE_CHANGED",
	"TRAIT_TREE_CURRENCY_INFO_UPDATED",
	"SCRIBE_CLASS_CHANGED",
};

CharacterProgressionLineMixin = {};

function CharacterProgressionLineMixin:Init(elementData)
	-- Since this uses a custom status bar setup, the value is overriden to empty
	elementData.value = "";
	CharacterSheetLineMixin.Init(self, elementData);

	self:UpdateBar(elementData.activeRanks, elementData.totalRanks);
end

function CharacterProgressionLineMixin:UpdateBar(activeRanks, totalRanks)
	local bar = self.Bar;
	bar:SetStatusBarColor(self.elementData.color.r, self.elementData.color.g, self.elementData.color.b);
	bar:SetMinMaxValues(0, totalRanks);
	bar:SetValue(activeRanks);
	bar.Label:SetText(string.format(WOWHACK_CHARACTER_PROGRESSION_BAR_FORMAT, activeRanks, totalRanks));
	bar.Spark:SetPoint("CENTER", bar.BarTexture, "RIGHT", 0, 0);
end

CharacterProgressionListMixin = CreateFromMixins(CharacterSheetListMixin);

function CharacterProgressionListMixin:OnLoad()
	CharacterSheetListMixin.OnLoad(self);
	FrameUtil.RegisterFrameForEvents(self, CHARACTER_PROGRESSION_LIST_EVENTS);
end

function CharacterProgressionListMixin:OnEvent(_event)
	self:Refresh();
end

function CharacterProgressionListMixin:BuildElements()
	local entries = {};
	for _, progressionEntry in ipairs(PROGRESSION_ENTRIES) do
		local treeIDs = progressionEntry.treeIDs;
		if not treeIDs and progressionEntry.treeIDsCallback then
			treeIDs = progressionEntry.treeIDsCallback();
		elseif not treeIDs and progressionEntry.treeID then
			treeIDs = { progressionEntry.treeID };
		end

		if treeIDs and #treeIDs > 0 then
			local hasAnyProgress = false;
			local totalActiveRanks = 0;
			local totalRanks = 0;
			for _, treeID in ipairs(treeIDs) do
				local activeRanks, ranks = GetRankProgress(treeID);
				if activeRanks then
					hasAnyProgress = true;
					totalActiveRanks = totalActiveRanks + activeRanks;
					totalRanks = totalRanks + ranks;
				end
			end

			if hasAnyProgress then
				table.insert(entries, {
					name = progressionEntry.name,
					-- value intentionally left empty; bar carries the display
					value = "",
					templateKey = "CharacterProgressionLineTemplate",
					activeRanks = totalActiveRanks,
					totalRanks = totalRanks,
					color = progressionEntry.color,
				});
			end
		end
	end
	return entries;
end

CharacterProgressionSummaryMixin = {};

function CharacterProgressionSummaryMixin:OnLoad()
	self.Header:SetHeaderText(WOWHACK_CHARACTER_SECTION_PROGRESSION);
end
