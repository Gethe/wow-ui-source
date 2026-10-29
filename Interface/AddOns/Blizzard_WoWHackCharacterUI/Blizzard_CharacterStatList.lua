
local STAT_LINE_ENTRIES = WoWHackCharacterStats.Entries;

local CHARACTER_STAT_LIST_EVENTS = {
	"UNIT_MAXHEALTH",
	"UNIT_MAXPOWER",
};

local CHARACTER_STAT_LIST_UNIT_EVENTS = {
	"UNIT_STATS",
};

CharacterStatListMixin = CreateFromMixins(CharacterSheetListMixin);

function CharacterStatListMixin:OnLoad()
	CharacterSheetListMixin.OnLoad(self);
end

function CharacterStatListMixin:OnShow()
	CharacterSheetListMixin.OnShow(self);

	FrameUtil.RegisterFrameForEvents(self, CHARACTER_STAT_LIST_EVENTS);
	FrameUtil.RegisterFrameForUnitEvents(self, CHARACTER_STAT_LIST_UNIT_EVENTS, "player");
end

function CharacterStatListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CHARACTER_STAT_LIST_EVENTS);
	FrameUtil.UnregisterFrameForEvents(self, CHARACTER_STAT_LIST_UNIT_EVENTS);
end

function CharacterStatListMixin:OnEvent(_event)
	self:Refresh();
end

local function MakeStatTooltipCallback(spellID)
	return function(button)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		GameTooltip:SetSpellByID(spellID);
		GameTooltip:Show();
	end;
end

function CharacterStatListMixin:BuildElements()
	local entries = {};
	for _i, entry in ipairs(STAT_LINE_ENTRIES) do
		table.insert(entries, {
			name = entry.name,
			tooltipCallback = MakeStatTooltipCallback(entry.spellTooltipID),
			value = entry.valueCallback(),
		});
	end
	return entries;
end

CharacterStatSummaryMixin = {};

function CharacterStatSummaryMixin:OnLoad()
	self.Header:SetHeaderText(WOWHACK_CHARACTER_SECTION_STATS);
end
