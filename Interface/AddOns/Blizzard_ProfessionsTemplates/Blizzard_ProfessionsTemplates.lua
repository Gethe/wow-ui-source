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
	Width = 130,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = 25,
};
ProfessionsTableConstants.NumAvailable = 
{
	Width = 100,
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
	Width = 90,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};
ProfessionsTableConstants.Expiration = 
{
	Width = 60,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};
ProfessionsTableConstants.ItemName = 
{
	Width = 330,
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
ProfessionsTableConstants.Status = 
{
	Width = 130,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};
ProfessionsTableConstants.CustomerName = 
{
	Width = 160,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};
ProfessionsTableConstants.OrderType = 
{
	Width = 130,
	Padding = ProfessionsTableConstants.StandardPadding,
	LeftCellPadding = ProfessionsTableConstants.NoPadding,
	RightCellPadding = ProfessionsTableConstants.NoPadding,
};

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
		return CreateAtlasMarkup("auctionhouse-icon-clock", 16, 16, 2, -2);
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
	elseif sortOrder == ProfessionsSortOrder.Status then
		return CRAFTING_ORDERS_BROWSE_HEADER_STATUS;
	elseif sortOrder == ProfessionsSortOrder.AverageTip then
		return CRAFTING_ORDERS_BROWSE_HEADER_AVG_TIP;
	elseif sortOrder == ProfessionsSortOrder.MaxTip then
		return CRAFTING_ORDERS_BROWSE_HEADER_MAX_TIP;
	elseif sortOrder == ProfessionsSortOrder.NumAvailable then
		return CRAFTING_ORDERS_BROWSE_HEADER_AVAILABLE;
	elseif sortOrder == ProfessionsSortOrder.CustomerName then
		return CRAFTING_ORDERS_BROWSE_HEADER_CUSTOMER_NAME;
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
	if not self.sortOrder then
		return;
	end
	
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
	local order = rowData.option;
	local text;
	if order.reagentState == Enum.CraftingOrderReagentsType.All then
		text = PROFESSIONS_COLUMN_REAGENTS_ALL;
	elseif order.reagentState == Enum.CraftingOrderReagentsType.Some then
		text = PROFESSIONS_COLUMN_REAGENTS_PARTIAL;
	elseif order.reagentState == Enum.CraftingOrderReagentsType.None then
		text = PROFESSIONS_COLUMN_REAGENTS_NONE;
	end
	ProfessionsTableCellTextMixin.SetText(self, text);
end

local function ReagentIconFrameReset(pool, frame)
	frame:Reset();
	frame:ClearAllPoints();
	frame:Hide();
	frame:SetParent(nil);
end
local reagentIconFramePool = CreateFramePool("BUTTON", nil, "ProfessionsCrafterTableCellReagentsButtonTemplate", ReagentIconFrameReset);

function ProfessionsCrafterTableCellReagentsMixin:OnEnter()
	self:GetParent().HighlightTexture:Show();

	local order = self.rowData.option;

	if order.reagentState ~= Enum.CraftingOrderReagentsType.None then
		local reagents = {};
		for _, orderReagentInfo in ipairs(order.reagents) do
			if orderReagentInfo.source == Enum.CraftingOrderReagentSource.Any and orderReagentInfo.isBasicReagent then
				local itemID = orderReagentInfo.reagent.itemID;
				local slotIndex = orderReagentInfo.slotIndex;

				local _, existingReagent = FindInTableIf(reagents, function(r) return r.slotIndex == slotIndex; end);
				if existingReagent == nil then
					table.insert(reagents, {slotIndex = slotIndex, itemID = itemID, multipleQualities = false});
				else
					existingReagent.multipleQualities = true;
				end
			end
		end

		table.sort(reagents, function(l, r) return l.slotIndex < r.slotIndex; end);

		for idx, reagent in ipairs(reagents) do
			local reagentIconFrame = reagentIconFramePool:Acquire();
			reagentIconFrame:SetItem(reagent.itemID);
			reagentIconFrame.layoutIndex = idx;
			reagentIconFrame:SetParent(self.ReagentsContainer);

			if reagent.multipleQualities and reagentIconFrame.ProfessionQualityOverlay and reagentIconFrame.ProfessionQualityOverlay:IsShown() then
				reagentIconFrame.ProfessionQualityOverlay:SetAtlas("Professions-Icon-Quality-Mixed-Inv", TextureKitConstants.UseAtlasSize);
			end

			reagentIconFrame:Show();
		end
		self.ReagentsContainer:Layout();

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_InsertFrame(GameTooltip, self.ReagentsContainer);
		GameTooltip:Show();
	end
end

function ProfessionsCrafterTableCellReagentsMixin:OnLeave()
	self:GetParent().HighlightTexture:Hide();

	GameTooltip:Hide();
	reagentIconFramePool:ReleaseAll();
end

ProfessionsCrafterTableCellCommissionMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCrafterTableCellCommissionMixin:Populate(rowData, dataIndex)
	local order = rowData.option;
	self.TipMoneyDisplayFrame:SetAmount(order[self.tipKey]);
end

ProfessionsCrafterTableCellItemNameMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCrafterTableCellItemNameMixin:Populate(rowData, dataIndex)
	local order = rowData.option;
	local item = Item:CreateFromItemID(order.itemID);
	item:ContinueOnItemLoad(function()
		if item:GetItemID() ~= self.rowData.option.itemID then
			-- Callback from a previous async request
			return;
		end
		local icon = item:GetItemIcon();
		self.Icon:SetTexture(icon);

		local qualityColor = item:GetItemQualityColor().color;
		local itemName = qualityColor:WrapTextInColorCode(item:GetItemName());
		if order.isRecraft then
			itemName = PROFESSIONS_RECRAFT_ORDER_NAME_FMT:format(itemName);
		end
		if order.minQuality and order.minQuality > 1 then
			local smallIcon = true;
			local qualityAtlas = Professions.GetChatIconMarkupForQuality(order.minQuality, smallIcon);
			itemName = itemName.." "..qualityAtlas;
		end

		self.Text:SetText(itemName);
	end);
end

ProfessionsCrafterTableCellExpirationMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCrafterTableCellExpirationMixin:Populate(rowData, dataIndex)
	local order = rowData.option;
	local remainingTime = Professions.GetCraftingOrderRemainingTime(order.expirationTime);
	local seconds = remainingTime >= 60 and remainingTime or 60; -- Never show < 1min
	self.remainingTime = seconds;
	local timeText = Professions.OrderTimeLeftFormatter:Format(seconds);
	if seconds <= Constants.ProfessionConsts.PUBLIC_CRAFTING_ORDER_STALE_THRESHOLD then
		timeText = ERROR_COLOR:WrapTextInColorCode(timeText);
	end
	ProfessionsTableCellTextMixin.SetText(self, timeText);
end

function ProfessionsCrafterTableCellExpirationMixin:OnEnter()
	self:GetParent().HighlightTexture:Show();

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local noSeconds = true;
	GameTooltip_AddNormalLine(GameTooltip, AUCTION_HOUSE_TOOLTIP_DURATION_FORMAT:format(SecondsToTime(self.remainingTime, noSeconds)));
	if self.remainingTime <= Constants.ProfessionConsts.PUBLIC_CRAFTING_ORDER_STALE_THRESHOLD and self.rowData.option.orderType == Enum.CraftingOrderType.Public then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_ORDER_ABOUT_TO_EXPIRE);
	end
	GameTooltip:Show();
end

function ProfessionsCrafterTableCellExpirationMixin:OnLeave()
	self:GetParent().HighlightTexture:Hide();

	GameTooltip:Hide();
end

ProfessionsCrafterTableCellNumAvailableMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCrafterTableCellNumAvailableMixin:Populate(rowData, dataIndex)
	local order = rowData.option;
	ProfessionsTableCellTextMixin.SetText(self, order.numAvailable);
end

ProfessionsCrafterTableCellCustomerNameMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCrafterTableCellCustomerNameMixin:Populate(rowData, dataIndex)
	local order = rowData.option;
	ProfessionsTableCellTextMixin.SetText(self, order.customerName);
end

ProfessionsCustomerTableCellItemNameMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCustomerTableCellItemNameMixin:Populate(rowData, dataIndex)
	local order = rowData.option;
	local item = Item:CreateFromItemID(order.itemID);
	item:ContinueOnItemLoad(function()
		local icon = item:GetItemIcon();
		self.Icon:SetTexture(icon);

		local qualityColor = item:GetItemQualityColor().color;
		local itemName = qualityColor:WrapTextInColorCode(item:GetItemName());
		if order.isRecraft then
			itemName = PROFESSIONS_RECRAFT_ORDER_NAME_FMT:format(itemName);
		end
		if order.minQuality and order.minQuality > 1 then
			local smallIcon = true;
			local qualityAtlas = Professions.GetChatIconMarkupForQuality(order.minQuality, smallIcon);
			itemName = itemName.." "..qualityAtlas;
		end

		self.Text:SetText(itemName);
	end);
end

ProfessionsCustomerTableCellIlvlMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCustomerTableCellIlvlMixin:Populate(rowData, dataIndex)
	local order = rowData.option;

	local text = order.iLvlMax and CRAFTING_ORDER_ILVL_DISPLAY_RANGE:format(order.iLvlMin, order.iLvlMax) or order.iLvlMin;
	ProfessionsTableCellTextMixin.SetText(self, text);
end

function ProfessionsCustomerTableCellIlvlMixin:OnEnter()
	self:GetParent():OnLineEnter();

	local order = self.rowData.option;

	if not order.qualityIlvlBonuses or not order.craftingQualityIDs then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, PROFESSIONS_CRAFTING_QUALITY_BONUSES:format(order.itemName));
	for index, ilvlBonus in ipairs(order.qualityIlvlBonuses) do
		local outputItemInfo = C_TradeSkillUI.GetRecipeOutputItemData(order.spellID, {}, nil, order.craftingQualityIDs[index]);
		local item = Item:CreateFromItemLink(outputItemInfo.hyperlink);
		if item:IsItemDataCached() then
			local atlasSize = 25;
			local atlasMarkup = CreateAtlasMarkup(Professions.GetIconForQuality(index), atlasSize, atlasSize);
			GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_CRAFTING_QUALITY_BONUS_INCR:format(atlasMarkup, item:GetCurrentItemLevel(), ilvlBonus));
		else
			local continuableContainer = ContinuableContainer:Create();
			continuableContainer:AddContinuable(item);
			continuableContainer:ContinueOnLoad(function()
				self:OnEnter(cap, isRight);
			end);
		end
	end
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip_AddHighlightLine(GameTooltip, PROFESSIONS_OPTIONAL_REAGENTS_ILVL_DISCLAIMER);
	GameTooltip:Show();
end

function ProfessionsCustomerTableCellIlvlMixin:OnLeave()
	self:GetParent():OnLineLeave();

	GameTooltip:Hide();
end

ProfessionsCustomerTableCellSlotsMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCustomerTableCellSlotsMixin:Populate(rowData, dataIndex)
	local order = rowData.option;
	ProfessionsTableCellTextMixin.SetText(self, order.slots);
end

ProfessionsCustomerTableCellLevelMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCustomerTableCellLevelMixin:Populate(rowData, dataIndex)
	local order = rowData.option;
	ProfessionsTableCellTextMixin.SetText(self, order.level);
end

ProfessionsCustomerTableCellSkillMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCustomerTableCellSkillMixin:Populate(rowData, dataIndex)
	local order = rowData.option;
	ProfessionsTableCellTextMixin.SetText(self, order.skill);
end

ProfessionsCustomerTableCellStatusMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCustomerTableCellStatusMixin:Populate(rowData, dataIndex)
	local order = rowData.option;

	local statusText;
	if order.orderState == Enum.CraftingOrderState.Creating or order.orderState == Enum.CraftingOrderState.Created then
		statusText = PROFESSIONS_CRAFTING_ORDER_LISTED;
	elseif order.orderState == Enum.CraftingOrderState.Claiming or order.orderState == Enum.CraftingOrderState.Claimed or order.orderState == Enum.CraftingOrderState.Crafting or order.orderState == Enum.CraftingOrderState.Recrafting then
		statusText = PROFESSIONS_CRAFTING_ORDER_IN_PROGRESS;
	elseif order.orderState == Enum.CraftingOrderState.Expiring or order.orderState == Enum.CraftingOrderState.Expired then
		statusText = PROFESSIONS_CRAFTING_ORDER_EXPIRED;
	elseif order.orderState == Enum.CraftingOrderState.Fulfilling or order.orderState == Enum.CraftingOrderState.Fulfilled then
		statusText = PROFESSIONS_CRAFTING_ORDER_COMPLETED;
	elseif order.orderState == Enum.CraftingOrderState.Rejecting or order.orderState == Enum.CraftingOrderState.Rejected then
		statusText = PROFESSIONS_CRAFTING_ORDER_REJECTED;
	elseif order.orderState == Enum.CraftingOrderState.Canceling or order.orderState == Enum.CraftingOrderState.Canceled then
		statusText = PROFESSIONS_CRAFTING_ORDER_CANCELED;
	end

	ProfessionsTableCellTextMixin.SetText(self, statusText);
end

ProfessionsCustomerTableCellTypeMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCustomerTableCellTypeMixin:Populate(rowData, dataIndex)
	local order = rowData.option;

	local typeText;
	if order.orderType == Enum.CraftingOrderType.Public then
		typeText = PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_PUBLIC;
	elseif order.orderType == Enum.CraftingOrderType.Guild then
		typeText = PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_GUILD;
	elseif order.orderType == Enum.CraftingOrderType.Personal then
		typeText = PROFESSIONS_CRAFTING_FORM_ORDER_RECIPIENT_PRIVATE;
	end

	ProfessionsTableCellTextMixin.SetText(self, typeText);
end

ProfessionsCustomerTableCellExpirationMixin = CreateFromMixins(TableBuilderCellMixin);

function ProfessionsCustomerTableCellExpirationMixin:Populate(rowData, dataIndex)
	local order = rowData.option;
	self.isClaimed = order.orderState == Enum.CraftingOrderState.Claiming or order.orderState == Enum.CraftingOrderState.Claimed or order.orderState == Enum.CraftingOrderState.Crafting or order.orderState == Enum.CraftingOrderState.Recrafting;
	if not (self.isClaimed or order.orderState == Enum.CraftingOrderState.Creating or order.orderState == Enum.CraftingOrderState.Created) then
		self:SetScript("OnEnter", nil);
		self:SetMouseMotionEnabled(false);
		ProfessionsTableCellTextMixin.SetText(self, "");
		return;
	end
	self:SetScript("OnEnter", self.OnEnter);
	self:SetMouseMotionEnabled(true);

	local remainingTime = Professions.GetCraftingOrderRemainingTime(order.expirationTime);
	local seconds = remainingTime >= 60 and remainingTime or 60; -- Never show < 1min
	self.remainingTime = seconds;
	local timeText = Professions.OrderTimeLeftFormatter:Format(seconds);
	if seconds <= Constants.ProfessionConsts.PUBLIC_CRAFTING_ORDER_STALE_THRESHOLD then
		timeText = ERROR_COLOR:WrapTextInColorCode(timeText);
	end
	if self.isClaimed then
		timeText = timeText..CRAFTING_ORDER_PENDING;
	end
	ProfessionsTableCellTextMixin.SetText(self, timeText);
end

function ProfessionsCustomerTableCellExpirationMixin:OnEnter()
	self:GetParent().HighlightTexture:Show();

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local noSeconds = true;
	GameTooltip_AddNormalLine(GameTooltip, AUCTION_HOUSE_TOOLTIP_DURATION_FORMAT:format(SecondsToTime(self.remainingTime, noSeconds)));
	if self.isClaimed then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddNormalLine(GameTooltip, CRAFTING_ORDER_WONT_EXPIRE);
	end
	GameTooltip:Show();
end

function ProfessionsCustomerTableCellExpirationMixin:OnLeave()
	self:GetParent().HighlightTexture:Hide();

	GameTooltip:Hide();
end

ProfessionsRecipeListPanelMixin = {};

function ProfessionsRecipeListPanelMixin:StoreCollapses(scrollbox)
	self.collapses = {};
	local dataProvider = scrollbox:GetDataProvider();
	local childrenNodes = dataProvider:GetChildrenNodes();
	for idx, child in ipairs(childrenNodes) do
		if child.data and child:IsCollapsed() then
			self.collapses[child.data.categoryInfo.categoryID] = true;
		end
	end
end

function ProfessionsRecipeListPanelMixin:GetCollapses()
	return self.collapses;
end
