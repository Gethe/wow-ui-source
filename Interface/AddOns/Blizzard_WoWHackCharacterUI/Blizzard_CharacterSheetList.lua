
local CHARACTER_SHEET_LINE_TEMPLATE = "CharacterSheetLineTemplate";
local CHARACTER_SHEET_LINE_ELEMENT_SPACING = 2;
local SCROLL_FRAME_LEFT_WITH_BAR = -20;
local SCROLL_FRAME_RIGHT_WITH_BAR = -20;
local SCROLL_FRAME_LEFT_WITHOUT_BAR = 0;
local SCROLL_FRAME_RIGHT_WITHOUT_BAR = 0;

CharacterSheetLineMixin = {};

function CharacterSheetLineMixin:Init(elementData)
	self.elementData = elementData;
	self.Name:SetText(elementData.name);
	self.Value:SetText(elementData.value or "");
	self.Background:SetShown(elementData.isAlternate);
end

function CharacterSheetLineMixin:OnEnter()
	if self.elementData and self.elementData.tooltipCallback then
		self.elementData.tooltipCallback(self);
	end
end

function CharacterSheetLineMixin:OnLeave()
	GameTooltip_Hide();
end

CharacterSheetListMixin = {};

function CharacterSheetListMixin:OnLoad()
	local view = CreateScrollBoxListLinearView();

	view:SetElementFactory(function(factory, elementData)
		local templateKey = elementData.templateKey or CHARACTER_SHEET_LINE_TEMPLATE;
		factory(templateKey, function(button, data)
			button:Init(data);
		end);
	end);

	local topPadding, bottomPadding, leftPadding, rightPadding = 0, 0, 40, 40;
	view:SetPadding(topPadding, bottomPadding, leftPadding, rightPadding, CHARACTER_SHEET_LINE_ELEMENT_SPACING);
	self.ScrollBox:SetEdgeFadeLength(8);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", self, "TOPLEFT", 0, 0), --SCROLL_FRAME_LEFT_WITH_BAR, 0),
		CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0), --SCROLL_FRAME_RIGHT_WITH_BAR, 0),
	};
	local scrollBoxAnchorsWithoutBar = {
		CreateAnchor("TOPLEFT", self, "TOPLEFT", 0, 0), --SCROLL_FRAME_LEFT_WITHOUT_BAR, 0),
		CreateAnchor("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0), --SCROLL_FRAME_RIGHT_WITHOUT_BAR, 0),
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
end

function CharacterSheetListMixin:OnShow()
	self:Refresh();
end

-- SetElements(entries): entries is an array of tables.
-- Required fields per entry: name (string), value (string or number).
-- Optional fields: tooltipCallback (function(button)), templateKey (string).
-- isAlternate is stamped automatically.
function CharacterSheetListMixin:SetElements(entries)
	local dataProvider = CreateDataProvider();
	for i, entry in ipairs(entries) do
		local element = CopyTable(entry);
		element.isAlternate = (i % 2 == 1);
		dataProvider:Insert(element);
	end
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

-- Subclasses implement BuildElements() to return the entries array.
function CharacterSheetListMixin:BuildElements()
	assertsafe(false, "Child of CharacterSheetListMixin must implement BuildElements");
	return nil;
end

function CharacterSheetListMixin:Refresh()
	local entries = self:BuildElements();
	if entries then
		self:SetElements(entries);
	end
end
