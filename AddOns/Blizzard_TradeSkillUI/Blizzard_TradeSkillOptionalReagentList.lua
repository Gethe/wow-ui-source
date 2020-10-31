
OptionalReagentListLineMixin = {};

local OptionalReagentListLineState = {
	Available = 1,
	Current = 2,
	Selected = 3,
	Disabled = 4,
};

function OptionalReagentListLineMixin:OnHide()
	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
	self:UnregisterEvent("TRADE_SKILL_OPTIONAL_REAGENT_BONUS_TEXT_UPDATED");
end

function OptionalReagentListLineMixin:OnEvent(event, ...)
	if event == "GET_ITEM_INFO_RECEIVED" then
		self:UpdateDisplay();
	elseif event == "TRADE_SKILL_OPTIONAL_REAGENT_BONUS_TEXT_UPDATED" then
		local itemID = ...;
		if itemID == self:GetItemID() and self:IsMouseOver() then
			self:OnEnter();
		end
	end
end

function OptionalReagentListLineMixin:OnClick()
	if IsModifiedClick() then
		local itemName, itemLink = GetItemInfo(self:GetItemID());
		if HandleModifiedItemClick(itemLink) then
			return;
		end
	end

	if self:ShouldAllowSelection() then
		PlaySound(SOUNDKIT.UI_9_0_CRAFTING_CLICK_MAT_TO_SLOT);
		TemplatedListElementMixin.OnClick(self);
	end
end

function OptionalReagentListLineMixin:OnEnter()
	GameTooltip:SetOwner(self, "RIGHT");

	local title, text = self:GetTooltipText();

	GameTooltip_SetTitle(GameTooltip, title);

	local wrap = true;
	GameTooltip_AddHighlightLine(GameTooltip, text, wrap);

	if ItemUtil.GetOptionalReagentCount(self:GetItemID()) == 0 then
		GameTooltip_AddErrorLine(GameTooltip, OPTIONAL_REAGENT_NONE_AVAILABLE);
	end

	GameTooltip:Show();

	self:RegisterEvent("TRADE_SKILL_OPTIONAL_REAGENT_BONUS_TEXT_UPDATED");
end

function OptionalReagentListLineMixin:OnLeave()
	GameTooltip_Hide();

	self:UnregisterEvent("TRADE_SKILL_OPTIONAL_REAGENT_BONUS_TEXT_UPDATED");
end

function OptionalReagentListLineMixin:InitElement(optionalReagentList)
	self.optionalReagentList = optionalReagentList;
end

function OptionalReagentListLineMixin:GetOptionalReagentList()
	return self.optionalReagentList;
end

function OptionalReagentListLineMixin:GetItemID()
	return self:GetOptionalReagentList():GetItemID(self:GetListIndex());
end

function OptionalReagentListLineMixin:GetOption()
	return self:GetOptionalReagentList():GetOption(self:GetListIndex());
end

function OptionalReagentListLineMixin:ShouldAllowSelection()
	return self:GetState() ~= OptionalReagentListLineState.Disabled;
end

function OptionalReagentListLineMixin:SetState(state)
	self.state = state;

	local shouldAllowSelection = self:ShouldAllowSelection();
	local alpha = shouldAllowSelection and 1.0 or 0.3;
	self.Icon:SetAlpha(alpha);
	self.NameFrame:SetAlpha(alpha);
	self.Name:SetAlpha(alpha);
	self.IconBorder:SetAlpha(alpha);
	self.IconOverlay:SetAlpha(alpha);

	-- "Hide" the highlight texture with a 0 alpha while selection is disallowed. We can't disable the button since we need linking to work.
	self:GetHighlightTexture():SetAlpha(shouldAllowSelection and 1 or 0);

	self.SelectedTexture:SetShown(state == OptionalReagentListLineState.Selected);
end

function OptionalReagentListLineMixin:GetState()
	return self.state;
end

function OptionalReagentListLineMixin:CalculateState(itemID, itemCount)
	itemID = itemID or self:GetItemID();
	itemCount = itemCount or ItemUtil.GetOptionalReagentCount(itemID);

	local optionalReagentList = self:GetOptionalReagentList();
	if itemCount <= 0 or not optionalReagentList:IsRecipeLearned() then
		return OptionalReagentListLineState.Disabled;
	end

	if itemID == optionalReagentList:GetSelectedItemID() then
		return OptionalReagentListLineState.Current;
	end
	
	if optionalReagentList:HasOptionalReagent(itemID) then
		return OptionalReagentListLineState.Selected;
	end

	return OptionalReagentListLineState.Available;
end

function OptionalReagentListLineMixin:RefreshState(itemID, itemCount)
	itemID = itemID or self:GetItemID();
	itemCount = itemCount or ItemUtil.GetOptionalReagentCount(itemID);

	self:SetState(self:CalculateState(itemID, itemCount));
end

function OptionalReagentListLineMixin:UpdateDisplay()
	local option = self:GetOption();
	local itemID = option.itemID;
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(itemID);
	if not itemName then
		self:SetReagentText(RETRIEVING_ITEM_INFO);
		self:SetReagentQuality(Enum.ItemQuality.Common);
		self.Icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark");
		self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
		self:SetState(OptionalReagentListLineState.Disabled);
		return;
	end

	self:UnregisterEvent("GET_ITEM_INFO_RECEIVED");

	self:SetReagentText(itemName);
	self:SetReagentQuality(itemQuality);
	self.Icon:SetTexture(itemIcon);
	
	local itemCount = ItemUtil.GetOptionalReagentCount(itemID);
	self.Count:SetText(itemCount);

	self:RefreshState(itemID, itemCount);
end

function OptionalReagentListLineMixin:GetTooltipText()
	local option = self:GetOption();
	local itemID = option.itemID;
	local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon = GetItemInfo(itemID);
	if not itemName then
		return RETRIEVING_ITEM_INFO, "";
	end

	local itemQualityColor = ITEM_QUALITY_COLORS[itemQuality];
	return itemQualityColor.color:WrapTextInColorCode(itemName), option.bonusText;
end


OptionalReagentListMixin = {};

local OptionalReagentListEvents = {
	"TRADE_SKILL_LIST_UPDATE",
	"TRADE_SKILL_OPTIONAL_REAGENT_BONUS_TEXT_UPDATED",
};

function OptionalReagentListMixin:OnLoad()
	self.Inset:Hide();
	self:InitScrollFrame();
	
	local selectedHighlight = self.ScrollList:GetSelectedHighlight();
	selectedHighlight:SetAtlas("auctionhouse-ui-row-select", false);
	selectedHighlight:SetBlendMode("ADD");
	selectedHighlight:SetVertexColor(0.3, 0.8, 0.3);
	selectedHighlight:SetAlpha(0.8);

	self:Reset();
end

function OptionalReagentListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, OptionalReagentListEvents);

	local tradeSkillUI = self:GetTradeSkillUI();
	tradeSkillUI:RegisterCallback(TradeSkillUIMixin.Event.OptionalReagentUpdated, self.OnOptionalReagentUpdated, self);
	SetUIPanelAttribute(tradeSkillUI, "width", tradeSkillUI:GetWidth() + self:GetWidth());
	UpdateUIPanelPositions(tradeSkillUI);
end

function OptionalReagentListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, OptionalReagentListEvents);

	local tradeSkillUI = self:GetTradeSkillUI();
	tradeSkillUI:UnregisterCallback(TradeSkillUIMixin.Event.OptionalReagentUpdated, self);
	tradeSkillUI:TriggerEvent(TradeSkillUIMixin.Event.OptionalReagentListClosed);
	SetUIPanelAttribute(tradeSkillUI, "width", tradeSkillUI:GetWidth());
	UpdateUIPanelPositions(tradeSkillUI);

	self:Hide();
end

function OptionalReagentListMixin:OnEvent(event, ...)
	if event == "TRADE_SKILL_LIST_UPDATE" then
		self:RefreshScrollFrame();
	elseif event == "TRADE_SKILL_OPTIONAL_REAGENT_BONUS_TEXT_UPDATED" then
		local itemID = ...;
		for i, info in ipairs(self.listedOptions) do
			if info.itemID == itemID then
				info.bonusText = self:GetTradeSkillUI():GetOptionalReagentBonusTextText(itemID, self.optionalReagentIndex);
			end
		end
	end
end

function OptionalReagentListMixin:OnOptionalReagentUpdated(event, optionalReagentIndex)
	local skipUpdates = true;
	self:RefreshSelectedListIndex(skipUpdates);
	self:RefreshScrollFrame();
end

function OptionalReagentListMixin:InitScrollFrame()
	self.ScrollList:SetElementTemplate("OptionalReagentListLineTemplate", self);

	local function GetNumResultsCallback()
		return self:GetNumResults();
	end

	local function OnResultSelected(index)
		self:OnResultSelected(index);
	end

	self.ScrollList:SetGetNumResultsFunction(GetNumResultsCallback);
	self.ScrollList:SetSelectionCallback(OnResultSelected);
end

function OptionalReagentListMixin:Reset()
	self.selectedRecipeID = nil;
	self.optionalReagentSlots = {};
	self.optionalReagentIndex = nil;
	self.options = {};
	self.listedOptions = {};
	self.selectedCallback = nil;
end

function OptionalReagentListMixin:OpenSelection(selectedRecipeID, optionalReagentIndex, selectedCallback)
	if not selectedRecipeID then
		self:Reset();
		return;
	end

	if self.selectedRecipeID == selectedRecipeID then
		if self.optionalReagentIndex == optionalReagentIndex then
			return;
		end
	else
		self.selectedRecipeID = selectedRecipeID;
		self.optionalReagentSlots = C_TradeSkillUI.GetOptionalReagentInfo(self.selectedRecipeID);
		if optionalReagentIndex > #self.optionalReagentSlots then
			self:Reset();
			return;
		end
	end

	self.optionalReagentIndex = optionalReagentIndex;
	self.options = self.optionalReagentSlots[optionalReagentIndex].options;
	self.selectedCallback = selectedCallback;

	self:RefreshListedItems();
end

function OptionalReagentListMixin:GetOptionalReagentIndex()
	return self.optionalReagentIndex;
end

function OptionalReagentListMixin:ClearSelection()
	self:OpenSelection(nil);
end

function OptionalReagentListMixin:GetTradeSkillUI()
	return self:GetParent();
end

function OptionalReagentListMixin:GetSelectedItemID()
	return select(6, self:GetTradeSkillUI():GetOptionalReagent(self.optionalReagentIndex));
end

function OptionalReagentListMixin:IsRecipeLearned()
	return self:GetTradeSkillUI():IsRecipeLearned();
end

function OptionalReagentListMixin:HasOptionalReagent(itemID)
	return self:GetTradeSkillUI():HasOptionalReagent(itemID);
end

function OptionalReagentListMixin:OnResultSelected(listIndex)
	if self.selectedCallback then
		self.selectedCallback(self:GetOption(listIndex));
	end
end

function OptionalReagentListMixin:GetNumResults()
	return #self.listedOptions;
end

function OptionalReagentListMixin:GetItemID(listIndex)
	return self:GetOption(listIndex).itemID;
end

function OptionalReagentListMixin:GetOption(listIndex)
	return self.listedOptions[listIndex];
end

function OptionalReagentListMixin:RefreshScrollFrame()
	self.ScrollList:RefreshListDisplay();
end

function OptionalReagentListMixin:RefreshSelectedListIndex(skipUpdates)
	self.ScrollList:SetSelectedListIndex(nil, skipUpdates);

	local selectedItemID = self:GetSelectedItemID();
	if selectedItemID then
		for i = 1, #self.listedOptions do
			local listedItemID = self.listedOptions[i].itemID;
			if selectedItemID == listedItemID then
				self.ScrollList:SetSelectedListIndex(i, skipUpdates);
				break;
			end
		end
	end
end

function OptionalReagentListMixin:RefreshListedItems()
	local pendingListedOptions = {};
	if self:IsHidingUnowned() then
		for i = 1, #self.options do
			local option = self.options[i];
			if ItemUtil.GetOptionalReagentCount(option) > 0 then
				table.insert(pendingListedOptions, option);
			end
		end
	else
		pendingListedOptions = self.options;
	end

	self.listedOptions = {};
	
	for i, itemID in ipairs(pendingListedOptions) do
		local listedOption = itemID;
		local bonusText = self:GetTradeSkillUI():GetOptionalReagentBonusText(listedOption, self.optionalReagentIndex);
		self.listedOptions[i] = { itemID = itemID, bonusText = bonusText, };
	end

	if #self.listedOptions == 0 then
		HelpTip:HideAll(self:GetTradeSkillUI().DetailsFrame);
	else
		self:GetTradeSkillUI().DetailsFrame:CheckOptionalReagentTutorial();
	end

	local skipUpdates = true;
	self:RefreshSelectedListIndex(skipUpdates);

	self:RefreshScrollFrame();
end

function OptionalReagentListMixin:IsHidingUnowned()
	return self.HideUnownedButton:GetChecked();
end

function OptionalReagentListMixin:GetTutorialLine()
	for i = 1, #self.options do
		local option = self.options[i];
		if ItemUtil.GetOptionalReagentCount(option) > 0 then
			return self.ScrollList:GetElementFrame(i);
		end
	end

	return self.ScrollList:GetElementFrame(1);
end


OptionalReagentListHideUnownedButtonMixin = {};

function OptionalReagentListHideUnownedButtonMixin:OnLoad()
	self.text:SetText(OPTIONAL_REAGENT_LIST_HIDE_UNOWNED);
end

function OptionalReagentListHideUnownedButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self:GetParent():RefreshListedItems();
end


OptionalReagentListCloseButtonMixin = {};

function OptionalReagentListCloseButtonMixin:OnClick()
	self:GetParent():ClearSelection();
	self:GetParent():Hide();
	PlaySound(SOUNDKIT.UI_9_0_CRAFTING_CLOSE_REAGENT_WINDOW);
end
