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
			GameTooltip:SetHyperlink(resultData.hyperlink);
		end);
	end

	continuableContainer:ContinueOnLoad(OnItemLoaded);
	
	-- Inspiration has been replaced with Ingenuity
	if resultData.hasIngenuityProc and resultData.ingenuityRefund > 0 then
		self.ItemContainer.CritText:SetScript("OnEnter", function(text)
			GameTooltip:SetOwner(text, "ANCHOR_RIGHT");
			GameTooltip_AddHighlightLine(GameTooltip, PROFESSIONS_OUTPUT_INGENUITY_TITLE);
			GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_OUTPUT_INGENUITY_DESC:format(resultData.ingenuityRefund));
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
			local resourceItem = Item:CreateFromItemID(resource.itemID);
			container:AddContinuable(resourceItem);
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

	if #resultData.childData > 0 then
		local container = ContinuableContainer:Create();
		for index, childData in ipairs(resultData.childData) do
			if childData.itemID then
				local childItem = Item:CreateFromItemID(childData.itemID);
				container:AddContinuable(childItem);
			end
		end

		local function FactoryFunction(index)
			local childData = resultData.childData[index];
			if childData then
				local button = self.itemButtonPool:Acquire();
				button:SetScale(.6);
				return button;
			end
			return nil;
		end

		local count = #resultData.childData;
		local anchor = AnchorUtil.CreateAnchor("LEFT", self.BonusCraft.Bracket, "RIGHT", 5, -10);
		local direction, stride, paddingX, paddingY = GridLayoutMixin.Direction.TopLeftToBottomRight, count, 4, 0;
		local layout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY);
		local itemButtons = AnchorUtil.GridLayoutFactoryByCount(FactoryFunction, count, anchor, layout);

		local function OnBonusesLoaded()
			for index, itemButton in ipairs(itemButtons) do
				local childData = resultData.childData[index];
				if childData.itemID then
					local item = Item:CreateFromItemID(childData.itemID);
					itemButton:SetItem(childData.itemID);
					itemButton:SetItemButtonCount(childData.quantity);
					ReconfigureCountPointAndScale(itemButton);

					itemButton:SetScript("OnEnter", function(button)
						GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
						GameTooltip:SetItemByID(childData.itemID);
					end);
				elseif childData.currencyID then
					local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(childData.currencyID);
					itemButton:SetItemButtonTexture(currencyInfo.iconFileID);
					itemButton:SetItemButtonCount(childData.showCurrencyText and childData.quantity or 1);
					ReconfigureCountPointAndScale(itemButton);

					itemButton:SetScript("OnEnter", function(button)
						GameTooltip:SetOwner(button, "ANCHOR_RIGHT", 0, 0);
						
						local tooltipInfo = CreateBaseTooltipInfo("GetCurrencyByID", childData.currencyID);
						tooltipInfo.linePreCall = function(tooltip, lineData)
							if lineData.type == Enum.TooltipDataLineType.CurrencyTotal then
								local amountText = NORMAL_FONT_COLOR:WrapTextInColorCode(AMOUNT_RECEIVED_COLON);
								GameTooltip_AddHighlightLine(tooltip, string.format("%s %d", amountText, childData.quantity));
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
	self:RegisterEvent("TRADE_SKILL_ITEM_CRAFTED_RESULT");
	self:RegisterEvent("TRADE_SKILL_CURRENCY_REWARD_RESULT");

	self.updateFrame = CreateFrame("FRAME", nil, UIParent);
	self.updateFrame.remaining = 0;
	self.updateFrame:Show();
	
	local view = CreateScrollBoxListLinearView(ScrollBoxPad, ScrollBoxPad, ScrollBoxPad, ScrollBoxPad, ScrollBoxSpacing);
	view:SetElementInitializer("ProfessionsCraftingOutputLogElementTemplate", function(frame, resultData)
		frame:Init(resultData);
	end);

	view:SetElementExtentCalculator(function(dataIndex, resultData)
		local height = 46;
		local rows = 0;
		if resultData.multicraft > 0 then
			rows = rows + 1;
		end
		if resultData.resourcesReturned then
			rows = rows + 1;
		end
		if #resultData.childData > 0 then
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
	
	self.parentResults = {};
	self.childResults = {};
end

function ProfessionsCraftingOutputLogMixin:ProcessResultData(resultData)
	-- We expect operationID on every result to pair child rewards with their a parent, 
	-- but in case this ever arrives without one, treat it like we would a parent so it
	-- appears in the list. XP (currency) and Artisan's Mettle are first craft rewards
	-- and should appear as children to some parent reward.
	if (not resultData.firstCraftReward) or (resultData.operationID == 0) then
		-- Child data with matching operation ID will be moved to .childData after our
		-- timer expires. 
		resultData.childData = {};

		table.insert(self.parentResults, resultData);
	else
		table.insert(self.childResults, resultData);
	end

	-- Always expect additional results. We don't know how many more many be inbound so
	-- we need to set an arbitrary timer that should be enough for the server to finish
	-- sending it.
	local waitSeconds = .35;
	self:RestartTimer(waitSeconds);
end

function ProfessionsCraftingOutputLogMixin:RestartTimer(waitSeconds)
	if self.updateFrame.remaining <= 0 then
		self.updateFrame:SetScript("OnUpdate", function(updateFrame, dt)
			updateFrame.remaining = math.max(0, updateFrame.remaining - dt);
			if updateFrame.remaining <= 0 then
				updateFrame:SetScript("OnUpdate", nil);
				self:FinalizeResultData();
			end
		end);
		
		self.updateFrame.remaining = waitSeconds;
	end
end

function ProfessionsCraftingOutputLogMixin:OnEvent(event, ...)
	if event == "TRADE_SKILL_ITEM_CRAFTED_RESULT" or event == "TRADE_SKILL_CURRENCY_REWARD_RESULT" then
		local resultData = ...;
		self:ProcessResultData(resultData);
	end
end

function ProfessionsCraftingOutputLogMixin:FinalizeResultData()
	local dataProvider = self.ScrollBox:GetDataProvider();
	if not dataProvider then
		dataProvider = CreateDataProvider();
		self.ScrollBox:SetDataProvider(dataProvider);
	end

	-- Move child reward data into a parent with a matching operation ID.
	for index, childResultData in ipairs_reverse(self.childResults) do
		local parentResultData = FindValueInTableIf(self.parentResults, function(resultData)
			return childResultData.operationID == resultData.operationID;
		end);

		if parentResultData then
			-- We found a parent for this data, remove it from the pending list.
			table.remove(self.childResults, index);
			table.insert(parentResultData.childData, childResultData);
		end
	end

	for index, parentResultData in ipairs(self.parentResults) do
		dataProvider:Insert(parentResultData);
	end

	self.childResults = {};
	self.parentResults = {};

	if self:IsShown() then
		self:Resize();
	else
		self:Open();
	end

	self.ScrollBox:ScrollToEnd();
end

function ProfessionsCraftingOutputLogMixin:OnHide()
	self.ScrollBox:RemoveDataProvider();
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

function ProfessionsCraftingOutputLogMixin:Cleanup()
	self.ScrollBox:Flush();
	self:Hide();
end