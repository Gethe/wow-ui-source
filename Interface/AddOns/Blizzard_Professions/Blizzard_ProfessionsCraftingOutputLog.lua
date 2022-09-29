local ScrollBoxPad = 6;
local ScrollBoxSpacing = 2;
local ElementBonusRowHeight = 31;

ProfessionsCraftingOutputLogElementMixin = {};

function ProfessionsCraftingOutputLogElementMixin:OnLoad()
	self.resourcesFramePool = CreateFramePool("ItemButton", self);
		
	self.ItemContainer.CritText:SetScript("OnLeave", GameTooltip_Hide);
	self.ItemContainer.Item:SetScript("OnLeave", GameTooltip_Hide);

	self.Multicraft.Text:SetText(PROFESSIONS_OUTPUT_MULTICRAFT);
	self.Multicraft.Text:SetScript("OnLeave", GameTooltip_Hide);
	self.Multicraft.Item.noProfessionQualityOverlay = true;

	self.Resources.Text:SetText(PROFESSIONS_OUTPUT_RESOURCE_RETURN);
	self.Resources.Text:SetScript("OnLeave", GameTooltip_Hide);

	self.CreationBonus.Text:SetText(PROFESSIONS_OUTPUT_FIRST_CREATE_BONUS);
	self.CreationBonus.Text:SetScript("OnLeave", GameTooltip_Hide);
	self.CreationBonus.Item:SetScript("OnLeave", GameTooltip_Hide);
end

function ProfessionsCraftingOutputLogElementMixin:Init()
	self.resourcesFramePool:ReleaseAll();

	local resultData = self:GetElementData();

	local continuableContainer = ContinuableContainer:Create();
	local item = Item:CreateFromItemLink(resultData.hyperlink);
	continuableContainer:AddContinuable(item);
	
	local function OnItemLoaded()
		self.ItemContainer.Text:SetText(item:GetItemName());
		self.ItemContainer.Text:SetTextColor(item:GetItemQualityColorRGB());

		self.ItemContainer.Item:SetItem(resultData.hyperlink);
		self.ItemContainer.Item:SetItemButtonCount(resultData.quantity);
		self.ItemContainer.Item:SetScript("OnEnter", function(button)
			GameTooltip:SetOwner(self.ItemContainer.Item, "ANCHOR_RIGHT");
			GameTooltip:SetHyperlink(resultData.hyperlink);
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
		local resourcesContainer = ContinuableContainer:Create();
		for index, resource in ipairs(resultData.resourcesReturned) do
			local item = Item:CreateFromItemID(resource.itemID);
			resourcesContainer:AddContinuable(item);
		end

		local function FactoryFunction(index)
			local resource = resultData.resourcesReturned[index];
			if resource then
				local itemButton = self.resourcesFramePool:Acquire();
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

		resourcesContainer:ContinueOnLoad(OnResourcesLoaded);

		table.insert(rows, self.Resources);
	end

	if resultData.awardSpecPoint then
		local currencyInfo = Professions.GetCurrentProfessionCurrencyInfo();
		self.CreationBonus.Item:SetItemButtonTexture(currencyInfo.iconFileID);
		self.CreationBonus.Item:SetScript("OnEnter", function(button)
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT", 0, 0);
			Professions.SetupProfessionsCurrencyTooltip(currencyInfo);
			GameTooltip:Show();
		end);

		self.CreationBonus.Text:SetScript("OnEnter", function(text)
			GameTooltip:SetOwner(text, "ANCHOR_RIGHT", 0, 0);
			GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_OUTPUT_FIRST_CREATE_DESC);
			GameTooltip:Show();
		end);

		table.insert(rows, self.CreationBonus);
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
		if resultData.awardSpecPoint then
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

function ProfessionsCraftingOutputLogMixin:OnEvent(event, ...)
	if event == "TRADE_SKILL_ITEM_CRAFTED_RESULT" then
		local resultData = ...;

		if not self.ScrollBox:HasDataProvider() then
			self.ScrollBox:SetDataProvider(CreateDataProvider());
		end

		self.ScrollBox:InsertElementData(resultData);

		if self:IsShown() then
			self:Resize();
		else
			self:Open();
		end

		self.ScrollBox:ScrollToEnd();
	end
end

function ProfessionsCraftingOutputLogMixin:OnHide()
	self:UnregisterEvents();
	self:UnregisterEvent("TRADE_SKILL_ITEM_CRAFTED_RESULT");

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

	local height = 0;
	local panelMaxHeight = self:GetPanelMaxHeight();
	for index, elementData in dataProvider:Enumerate() do
		height = height + elementExtentCalculator(index, elementData);
		-- Skip the rest if we've already met the max height.
		if height >= panelMaxHeight then
			return panelMaxHeight;
		end
	end
	return height;
end

function ProfessionsCraftingOutputLogMixin:StartListening()
	self:RegisterEvent("TRADE_SKILL_ITEM_CRAFTED_RESULT");
end