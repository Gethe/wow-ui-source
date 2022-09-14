ProfessionsTableConstants = {};
ProfessionsTableConstants.StandardPadding = 10;
ProfessionsTableConstants.NoPadding = 0;
ProfessionsTableConstants.Name = 
{
	Width = 100,
	Padding = ProfessionsTableConstants.NoPadding,
	FillCoefficient = 1.0,
	LeftCellPadding = ProfessionsTableConstants.StandardPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};
ProfessionsTableConstants.Tip = 
{
	Width = 50,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};
ProfessionsTableConstants.Quality = 
{
	Width = 60,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};
ProfessionsTableConstants.Reagents = 
{
	Width = 125,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};
ProfessionsTableConstants.Expiration = 
{
	Width = 80,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};
ProfessionsTableConstants.ItemName = 
{
	Width = 300,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};
ProfessionsTableConstants.Ilvl = 
{
	Width = 100,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};
ProfessionsTableConstants.Slots = 
{
	Width = 100,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};
ProfessionsTableConstants.Level = 
{
	Width = 100,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};
ProfessionsTableConstants.Skill = 
{
	Width = 100,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};

ProfessionsSortOrder = EnumUtil.MakeEnum("Name", "Tip", "Reagents", "Quality", "Expiration", "ItemName", "Ilvl", "Slots", "Level", "Skill");

local function GetHeaderNameFromSortOrder(sortOrder)
	if sortOrder == ProfessionsSortOrder.Name then
		return PROFESSIONS_COLUMN_HEADER_ITEM;
	elseif sortOrder == ProfessionsSortOrder.Tip then
		return PROFESSIONS_COLUMN_HEADER_TIP;
	elseif sortOrder == ProfessionsSortOrder.Quality then
		return PROFESSIONS_COLUMN_HEADER_QUALITY;
	elseif sortOrder == ProfessionsSortOrder.Reagents then
		return PROFESSIONS_COLUMN_HEADER_REAGENTS;
	elseif sortOrder == ProfessionsSortOrder.Expiration then
		return PROFESSIONS_COLUMN_HEADER_EXPIRATION;
	elseif sortOrder == ProfessionsSortOrder.ItemName then
		return AUCTION_HOUSE_BROWSE_HEADER_NAME;
	elseif sortOrder == ProfessionsSortOrder.Ilvl then
		return ITEM_LEVEL_ABBR;
	elseif sortOrder == ProfessionsSortOrder.Slots then
		return AUCTION_HOUSE_BROWSE_HEADER_CONTAINER_SLOTS;
	elseif sortOrder == ProfessionsSortOrder.Level then
		return AUCTION_HOUSE_BROWSE_HEADER_REQUIRED_LEVEL;
	elseif sortOrder == ProfessionsSortOrder.Skill then
		return AUCTION_HOUSE_BROWSE_HEADER_RECIPE_SKILL;
	end
end

ProfessionsReagentContainerMixin = {};

function ProfessionsReagentContainerMixin:OnLoad()
	self:SetText(self.labelText);
end

function ProfessionsReagentContainerMixin:SetText(text)
	self.Label:SetText(text);
end

ProfessionsCrafterTableHeaderStringMixin = CreateFromMixins(TableBuilderElementMixin);

function ProfessionsCrafterTableHeaderStringMixin:OnClick()
	self.owner:SetSortOrder(self.sortOrder);
	self:UpdateArrow();
end

function ProfessionsCrafterTableHeaderStringMixin:Init(owner, headerText, sortOrder)
	self:SetText(headerText);

	self.owner = owner;
	self.sortOrder = sortOrder;
	self:UpdateArrow();
end

function ProfessionsCrafterTableHeaderStringMixin:UpdateArrow()
	local sortOrder, ascending = self.owner:GetSortOrder();
	if sortOrder == self.sortOrder then
		self.Arrow:Show();
		if ascending then
			self.Arrow:SetTexCoord(0, 1, 0, 1);
		else
			self.Arrow:SetTexCoord(0, 1, 1, 0);
		end
	else
		self.Arrow:Hide();
	end
end

ProfessionsTableBuilderMixin = {};

function ProfessionsTableBuilderMixin:AddColumnInternal(owner, sortOrder, cellTemplate, ...)
	local column = self:AddColumn();

	if sortOrder then
		local headerName = GetHeaderNameFromSortOrder(sortOrder);
		column:ConstructHeader("BUTTON", "ProfessionsCrafterTableHeaderStringTemplate", owner, headerName, sortOrder);
	end

	column:ConstructCells("FRAME", cellTemplate, owner, ...);

	return column;
end

function ProfessionsTableBuilderMixin:AddUnsortableColumnInternal(owner, headerText, cellTemplate, ...)
	local column = self:AddColumn();
	local sortOrder = nil;
	column:ConstructHeader("BUTTON", "ProfessionsCrafterTableHeaderStringTemplate", owner, headerText, sortOrder);
	column:ConstructCells("FRAME", cellTemplate, owner, ...);
	return column;
end

function ProfessionsTableBuilderMixin:AddFixedWidthColumn(owner, padding, width, leftCellPadding, rightCellPadding, sortOrder, cellTemplate, ...)
	local column = self:AddColumnInternal(owner, sortOrder, cellTemplate, ...);
	column:SetFixedConstraints(width, padding);
	column:SetCellPadding(leftCellPadding, rightCellPadding);
	return column;
end

function ProfessionsTableBuilderMixin:AddFillColumn(owner, padding, fillCoefficient, leftCellPadding, rightCellPadding, sortOrder, cellTemplate, ...)
	local column = self:AddColumnInternal(owner, sortOrder, cellTemplate, ...);
	column:SetFillConstraints(fillCoefficient, padding);
	column:SetCellPadding(leftCellPadding, rightCellPadding);
	return column;
end

function ProfessionsTableBuilderMixin:AddUnsortableFixedWidthColumn(owner, padding, width, leftCellPadding, rightCellPadding, headerText, cellTemplate, ...)
	local column = self:AddUnsortableColumnInternal(owner, headerText, cellTemplate, ...);
	column:SetFixedConstraints(width, padding);
	column:SetCellPadding(leftCellPadding, rightCellPadding);
	return column;
end

function ProfessionsTableBuilderMixin:AddUnsortableFillColumn(owner, padding, fillCoefficient, leftCellPadding, rightCellPadding, headerText, cellTemplate, ...)
	local column = self:AddUnsortableColumnInternal(owner, headerText, cellTemplate, ...);
	column:SetFillConstraints(fillCoefficient, padding);
	column:SetCellPadding(leftCellPadding, rightCellPadding);
	return column;
end

ProfessionsTableCellTextMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsTableCellTextMixin:SetText(text)
	self.Text:SetText(text);
end
ProfessionsCrafterTableCellNameMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCrafterTableCellNameMixin:Populate(rowData, dataIndex)
	local order = rowData;
	local text = order:GetName();
	ProfessionsTableCellTextMixin.SetText(self, text);
end

ProfessionsCrafterTableCellTipMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCrafterTableCellTipMixin:Populate(rowData, dataIndex)
	local order = rowData;
	local text = GetMoneyString(order.tip);
	ProfessionsTableCellTextMixin.SetText(self, text);
end

ProfessionsCrafterTableCellQualityMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCrafterTableCellQualityMixin:Populate(rowData, dataIndex)
	local order = rowData;
	local atlasSize = 25;
	local text = CreateAtlasMarkup(Professions.GetIconForQuality(order.quality), atlasSize, atlasSize);
	ProfessionsTableCellTextMixin.SetText(self, text);
end

ProfessionsCrafterTableCellReagentsMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCrafterTableCellReagentsMixin:Populate(rowData, dataIndex)
	local order = rowData;
	local text = Professions.GetOrderReagentsSummaryText(order);
	ProfessionsTableCellTextMixin.SetText(self, text);
end

ProfessionsCrafterTableCellExpirationMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCrafterTableCellExpirationMixin:Populate(rowData, dataIndex)
	local order = rowData;
	local text = Professions.GetOrderDurationText(order.duration);
	ProfessionsTableCellTextMixin.SetText(self, text);
end

ProfessionsCustomerTableCellItemNameMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCustomerTableCellItemNameMixin:Populate(rowData, dataIndex)
	local option = rowData.option;
	local item = Item:CreateFromItemID(option.itemID);
	item:ContinueOnItemLoad(function()
		local icon = item:GetItemIcon();
		self.Icon:SetTexture(icon);

		local qualityColor = item:GetItemQualityColor().color;
		local name = qualityColor:WrapTextInColorCode(option.itemName);
		self.Text:SetText(name);
	end);
end

ProfessionsCustomerTableCellIlvlMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCustomerTableCellIlvlMixin:Populate(rowData, dataIndex)
	local option = rowData.option;
	ProfessionsTableCellTextMixin.SetText(self, option.iLvl);
end

ProfessionsCustomerTableCellSlotsMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCustomerTableCellSlotsMixin:Populate(rowData, dataIndex)
	local option = rowData.option;
	ProfessionsTableCellTextMixin.SetText(self, option.slots);
end

ProfessionsCustomerTableCellLevelMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCustomerTableCellLevelMixin:Populate(rowData, dataIndex)
	local option = rowData.option;
	ProfessionsTableCellTextMixin.SetText(self, option.level);
end

ProfessionsCustomerTableCellSkillMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCustomerTableCellSkillMixin:Populate(rowData, dataIndex)
	local option = rowData.option;
	ProfessionsTableCellTextMixin.SetText(self, option.skill);
end