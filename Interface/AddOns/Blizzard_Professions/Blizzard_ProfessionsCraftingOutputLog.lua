local UpdateFrame = CreateFrame("FRAME", nil, UIParent);
UpdateFrame.remaining = 0;
UpdateFrame:Show();

local ScrollBoxPad = 6;
local ScrollBoxSpacing = 7;
local ElementBonusRowHeight = 31;

local function ReconfigureCountPointAndScale(itemButton)
	itemButton:SetItemButtonAnchorPoint("BOTTOMRIGHT", 0, 2);
	itemButton:SetItemButtonScale(1.4);
end

ProfessionsCraftingOutputLogElementMixin = {};

function ProfessionsCraftingOutputLogElementMixin:OnLoad()
	self.itemButtonPool = CreateFramePool("ItemButton", self);
		
	self.ItemContainer.CritText:SetScript("OnLeave", GameTooltip_Hide);
	self.ItemContainer.Item:SetScript("OnLeave", GameTooltip_Hide);

	self.Multicraft.Text:SetText(PROFESSIONS_OUTPUT_MULTICRAFT);
	self.Multicraft.Text:SetScript("OnLeave", GameTooltip_Hide);
	self.Multicraft.Item.noProfessionQualityOverlay = true;

	self.Resources.Text:SetText(PROFESSIONS_OUTPUT_RESOURCE_RETURN);
	self.Resources.Text:SetScript("OnLeave", GameTooltip_Hide);

	self.BonusCraft.Text:SetText(PROFESSIONS_OUTPUT_FIRST_CREATE_BONUS);
	self.BonusCraft.Text:SetScript("OnLeave", GameTooltip_Hide);
end

function ProfessionsCraftingOutputLogElementMixin:Init()
	self.itemButtonPool:ReleaseAll();

	local resultData = self:GetElementData();
	local continuableContainer = ContinuableContainer:Create();
	local item = Item:CreateFromItemLink(resultData.hyperlink);
	continuableContainer:AddContinuable(item);
	
	local function OnItemLoaded()
		if resultData.isEnchant then
			self.ItemContainer.Text:SetText(ENCHANTED_TOOLTIP_LINE:format(item:GetItemName()));
		else
			self.ItemContainer.Text:SetText(item:GetItemName());
		end
		self.ItemContainer.Text:SetTextColor(item:GetItemQualityColorRGB());

		self.ItemContainer.Item:SetItem(resultData.hyperlink);
		self.ItemContainer.Item:SetItemButtonCount(resultData.quantity);
		self.ItemContainer.Item:SetScript("OnEnter", function(button)
			GameTooltip:SetOwner(self.ItemContainer.Item, "ANCHOR_RIGHT");
			if resultData.preferHyperlink or not resultData.itemGUID then
				GameTooltip:SetHyperlink(resultData.hyperlink);
			else
				GameTooltip:SetItemByGUID(resultData.itemGUID);
			end
		end);
	end

	continuableContainer:ContinueOnLoad(OnItemLoaded);
	
	if resultData.isCrit then
		self.ItemContainer.CritText:SetScript("OnEnter", function(text)
			GameTooltip:SetOwner(text, "ANCHOR_RIGHT");
			GameTooltip_AddHighlightLine(GameTooltip, PROFESSIONS_OUTPUT_INSPIRATION_TITLE);
			GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_OUTPUT_INSPIRATION_DESC);
			GameTooltip:Show();
		end);

		self.ItemContainer.CritFrame:Show();
		self.ItemContainer.CritText:Show();
	else
		self.ItemContainer.CritFrame:Hide();
		self.ItemContainer.CritText:Hide();
	end

	local rows = {};
	if resultData.multicraft > 0 then
		self.Multicraft.Item:SetItem(resultData.hyperlink);
		self.Multicraft.Text:SetScript("OnEnter", function(text)
			GameTooltip:SetOwner(text, "ANCHOR_RIGHT");
			GameTooltip_AddHighlightLine(GameTooltip, PROFESSIONS_OUTPUT_MULTICRAFT_TITLE);
			local tooltipText = PROFESSIONS_OUTPUT_MULTICRAFT_DESC:format(resultData.multicraft);
			GameTooltip_AddNormalLine(GameTooltip, tooltipText);
			GameTooltip:Show();
		end);

		table.insert(rows, self.Multicraft);
	end

	if resultData.resourcesReturned then
		local container = ContinuableContainer:Create();
		for index, resource in ipairs(resultData.resourcesReturned) do
			local item = Item:CreateFromItemID(resource.itemID);
			container:AddContinuable(item);
		end

		local function FactoryFunction(index)
			local resource = resultData.resourcesReturned[index];
			if resource then
				local itemButton = self.itemButtonPool:Acquire();
				itemButton:SetScale(.6);
				return itemButton;
			end
			return nil;
		end

		local count = #resultData.resourcesReturned;
		local anchor = AnchorUtil.CreateAnchor("LEFT", self.Resources.Bracket, "RIGHT", 5, -10);
		local direction, stride, paddingX, paddingY = GridLayoutMixin.Direction.TopLeftToBottomRight, count, 4, 0;
		local layout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY);
		local itemButtons = AnchorUtil.GridLayoutFactoryByCount(FactoryFunction, count, anchor, layout);

		local function OnResourcesLoaded()
			for index, itemButton in ipairs(itemButtons) do
				local resource = resultData.resourcesReturned[index];

				local item = Item:CreateFromItemID(resource.itemID);
				itemButton:SetItem(resource.itemID);
				itemButton:SetItemButtonCount(resource.quantity);
				ReconfigureCountPointAndScale(itemButton);
				itemButton:Show();

				itemButton:SetScript("OnLeave", GameTooltip_Hide);
				itemButton:SetScript("OnEnter", function(button)
					GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
					GameTooltip:SetItemByID(resource.itemID);
				end);
			end
			
			self.Resources.Text:SetScript("OnEnter", function(text)
				GameTooltip:SetOwner(text, "ANCHOR_RIGHT");
				GameTooltip_AddHighlightLine(GameTooltip, PROFESSIONS_OUTPUT_RESOURCEFULNESS_TITLE);
				GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_OUTPUT_RESOURCEFULNESS_DESC);
				GameTooltip:Show();
			end);
		end

		self.Resources.Text:SetPoint("LEFT", itemButtons[count], "RIGHT", 7, 0);
		self.Resources.Text:SetPoint("RIGHT", -3, 0);

		container:ContinueOnLoad(OnResourcesLoaded);

		table.insert(rows, self.Resources);
	end

	if resultData.bonusCraft and #resultData.bonusData > 0 then
		local container = ContinuableContainer:Create();
		for index, bonusData in ipairs(resultData.bonusData) do
			if bonusData.itemID then
				local item = Item:CreateFromItemID(bonusData.itemID);
				container:AddContinuable(item);
			end
		end

		local function FactoryFunction(index)
			local bonusData = resultData.bonusData[index];
			if bonusData then
				local button = self.itemButtonPool:Acquire();
				button:SetScale(.6);
				return button;
			end
			return nil;
		end

		local count = #resultData.bonusData;
		local anchor = AnchorUtil.CreateAnchor("LEFT", self.BonusCraft.Bracket, "RIGHT", 5, -10);
		local direction, stride, paddingX, paddingY = GridLayoutMixin.Direction.TopLeftToBottomRight, count, 4, 0;
		local layout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY);
		local itemButtons = AnchorUtil.GridLayoutFactoryByCount(FactoryFunction, count, anchor, layout);

		local function OnBonusesLoaded()
			for index, itemButton in ipairs(itemButtons) do
				local bonusData = resultData.bonusData[index];
				if bonusData.itemID then
					local item = Item:CreateFromItemID(bonusData.itemID);
					itemButton:SetItem(bonusData.itemID);
					itemButton:SetItemButtonCount(bonusData.quantity);
					ReconfigureCountPointAndScale(itemButton);

					itemButton:SetScript("OnEnter", function(button)
						GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
						GameTooltip:SetItemByID(bonusData.itemID);
					end);
				elseif bonusData.currencyID then
					local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(bonusData.currencyID);
					itemButton:SetItemButtonTexture(currencyInfo.iconFileID);
					itemButton:SetItemButtonCount(bonusData.showCurrencyText and bonusData.quantity or 1);
					ReconfigureCountPointAndScale(itemButton);

					itemButton:SetScript("OnEnter", function(button)
						GameTooltip:SetOwner(button, "ANCHOR_RIGHT", 0, 0);
						
						local tooltipInfo = CreateBaseTooltipInfo("GetCurrencyByID", bonusData.currencyID);
						tooltipInfo.linePreCall = function(tooltip, lineData)
							if lineData.type == Enum.TooltipDataLineType.CurrencyTotal then
								local amountText = NORMAL_FONT_COLOR:WrapTextInColorCode(AMOUNT_RECEIVED_COLON);
								GameTooltip_AddHighlightLine(tooltip, string.format("%s %d", amountText, bonusData.quantity));
								return true;
							end
						end;
						GameTooltip:ProcessInfo(tooltipInfo);
					end);
				end
				itemButton:Show();
				itemButton:SetScript("OnLeave", GameTooltip_Hide);
			end

			self.BonusCraft.Text:SetScript("OnEnter", function(text)
				GameTooltip:SetOwner(text, "ANCHOR_RIGHT", 0, 0);
				GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_OUTPUT_FIRST_CREATE_DESC);
				GameTooltip:Show();
			end);
		end

		self.BonusCraft.Text:SetPoint("LEFT", itemButtons[count], "RIGHT", 7, 0);
		self.BonusCraft.Text:SetPoint("RIGHT", -3, 0);

		container:ContinueOnLoad(OnBonusesLoaded);

		table.insert(rows, self.BonusCraft);
	end

	for index, row in ipairs(self.Rows) do
		row:ClearAllPoints();
		row:Hide();
	end

	local offset = -46;
	for index, row in ipairs(rows) do
		row:SetPoint("TOPLEFT", 0, offset);
		row:SetPoint("TOPRIGHT", 0, offset);
		row:Show();
		offset = offset - ElementBonusRowHeight;
	end

	if not resultData.displayed then
		resultData.displayed = true;
		self.ShowAnim:Play();
	end
end

ProfessionsCraftingOutputLogMixin = CreateFromMixins(CallbackRegistryMixin);

ProfessionsCraftingOutputLogMixin:GenerateCallbackEvents(
{
    "OrderRecraft",
});

function ProfessionsCraftingOutputLogMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	ScrollingFlatPanelMixin.OnLoad(self);
	
	self.pendingResultData = {};

	local view = CreateScrollBoxListLinearView(ScrollBoxPad, ScrollBoxPad, ScrollBoxPad, ScrollBoxPad, ScrollBoxSpacing);
	
	local function Initializer(frame, resultData)
		frame:Init(resultData);
	end
	view:SetElementInitializer("ProfessionsCraftingOutputLogElementTemplate", Initializer);

	view:SetElementExtentCalculator(function(dataIndex, resultData)
		local height = 46;
		local rows = 0;
		if resultData.multicraft > 0 then
			rows = rows + 1;
		end
		if resultData.resourcesReturned then
			rows = rows + 1;
		end
		if resultData.bonusCraft then
			rows = rows + 1;
		end
		return height + (rows * ElementBonusRowHeight);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	self.ScrollBox:SetShadowsFrameLevel(self.ScrollBox.ScrollTarget:GetFrameLevel() + 15);
	self.ScrollBox:SetShadowsScale(0.2);
	self.ScrollBox:GetUpperShadowTexture():SetTexCoord(0, 1, 1, 0);
	self.ScrollBox:GetUpperShadowTexture():SetPoint("TOPLEFT", 30, 0);
	self.ScrollBox:GetUpperShadowTexture():SetPoint("TOPRIGHT", -30, 0);
	self.ScrollBox:GetLowerShadowTexture():SetPoint("BOTTOMLEFT", 30, 0);
	self.ScrollBox:GetLowerShadowTexture():SetPoint("BOTTOMRIGHT", -30, 0);
end

function ProfessionsCraftingOutputLogMixin:ProcessPendingResultData(resultData)
	resultData.bonusData = {};
	
	-- This item or currency may have arrived before or after the original item, so we
	-- always need to consider saving off this data in case an item with bonusCraft arrives.
	local inserted = false;
	if resultData.operationID then
		if resultData.bonusCraft or resultData.firstCraftReward then
			local parentResultData = FindValueInTableIf(self.pendingResultData, function(data)
				return data.operationID == resultData.operationID;
			end);
			if parentResultData then
				table.insert(parentResultData.bonusData, resultData);
				inserted = true;
			end
		end
	end
	
	if not inserted then
		table.insert(self.pendingResultData, resultData);
	end

	-- If we're expecting additional items, we're going to wait a small amount of time
	-- for additional items or currencies (Artisan's Mettle, Knowledge XP, etc.) to be sent to us.
	if UpdateFrame.remaining <= 0 then
		UpdateFrame:SetScript("OnUpdate", function(updateFrame, dt)
			updateFrame.remaining = math.max(0, updateFrame.remaining - dt);
			if updateFrame.remaining <= 0 then
				updateFrame:SetScript("OnUpdate", nil);
				self:FinalizePendingResultData();
			end
		end);
		
		local waitSeconds = .350;
		UpdateFrame.remaining = waitSeconds;
	end
end

function ProfessionsCraftingOutputLogMixin:OnEvent(event, ...)
	if event == "TRADE_SKILL_ITEM_CRAFTED_RESULT" then
		local resultData = ...;
		self:ProcessPendingResultData(resultData);
	elseif event == "TRADE_SKILL_CURRENCY_REWARD_RESULT" then
		local resultData = ...;
		self:ProcessPendingResultData(resultData);
	end
end

function ProfessionsCraftingOutputLogMixin:FinalizePendingResultData()
	if not self.ScrollBox:HasDataProvider() then
		self.ScrollBox:SetDataProvider(CreateDataProvider());
	end

	for index, resultData in ipairs_reverse(self.pendingResultData) do
		local childResultData = FindValueInTableIf(self.pendingResultData, function(data)
			return data.operationID and data.firstCraftReward and (resultData.operationID == data.operationID);
		end);
		if childResultData then
			table.remove(self.pendingResultData, index);
			table.insert(resultData.bonusData, childResultData);
		end
	end

	for index, resultData in ipairs_reverse(self.pendingResultData) do
		-- We're only expecting to display the original item with bonus items
		-- and currencies contained within it.
		if resultData.operationID and not resultData.firstCraftReward then
			self.ScrollBox:InsertElementData(resultData);
		end
	end

	-- We may encounter the same itemGUID multiple times if the item was recrafted.
	-- In those cases, opt to display the item tooltip via hyperlink instead of item guid.
	-- The most recent item will continue to be displayed via item guid.
	local found = {};
	self.ScrollBox:ReverseForEachElementData(function(resultData)
		local itemGUID = resultData.itemGUID;
		if itemGUID then
			local wasFound = found[itemGUID];
			found[itemGUID] = true;

			if wasFound then
				resultData.preferHyperlink = true;
			end
		end
	end);

	self.pendingResultData = {};

	if self:IsShown() then
		self:Resize();
	else
		self:Open();
	end

	self.ScrollBox:ScrollToEnd();
end

function ProfessionsCraftingOutputLogMixin:OnHide()
	self:UnregisterEvents();
	self:UnregisterEvent("TRADE_SKILL_ITEM_CRAFTED_RESULT");
	self:UnregisterEvent("TRADE_SKILL_CURRENCY_REWARD_RESULT");

	self.ScrollBox:ClearDataProvider();
end

function ProfessionsCraftingOutputLogMixin:OnCloseCallback()
	ScrollingFlatPanelMixin.OnCloseCallback(self);
	PlaySound(SOUNDKIT.UI_PROFESSION_CRAFTING_RESULT_EXIT);
end

function ProfessionsCraftingOutputLogMixin:CalculateElementsHeight()
	local view = self.ScrollBox:GetView();
	local elementExtentCalculator = view:GetElementExtentCalculator();
	local dataProvider = self.ScrollBox:GetDataProvider();

	local spacing = 0;
	local height = 0;
	local panelMaxHeight = self:GetPanelMaxHeight();
	for index, elementData in dataProvider:Enumerate() do
		height = height + elementExtentCalculator(index, elementData) + spacing;
		spacing = ScrollBoxSpacing;
		-- Skip the rest if we've already met the max height.
		if height >= panelMaxHeight then
			return panelMaxHeight;
		end
	end
	return height;
end

function ProfessionsCraftingOutputLogMixin:StartListening()
	self:RegisterEvent("TRADE_SKILL_ITEM_CRAFTED_RESULT");
	self:RegisterEvent("TRADE_SKILL_CURRENCY_REWARD_RESULT");
end