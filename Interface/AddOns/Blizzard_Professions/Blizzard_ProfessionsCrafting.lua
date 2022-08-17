
ProfessionsGearSlotTemplateMixin = CreateFromMixins(PaperDollItemSlotButtonMixin);


ProfessionsCraftingPageMixin = {};

local ProfessionsCraftingPageEvents =
{
	"TRADE_SKILL_DATA_SOURCE_CHANGING",
	"TRADE_SKILL_DATA_SOURCE_CHANGED",
	"UPDATE_TRADESKILL_RECAST_READY",
	"TRADE_SKILL_CLOSE",
};

function ProfessionsCraftingPageMixin:OnLoad()
	self.RecipeList.FilterButton:SetResetFunction(Professions.SetDefaultFilters);
	self.RecipeList.FilterButton:SetScript("OnMouseDown", function(button, buttonName, down)
		UIMenuButtonStretchMixin.OnMouseDown(self.RecipeList.FilterButton, buttonName);
		ToggleDropDownMenu(1, nil, self.RecipeList.FilterDropDown, self.RecipeList.FilterButton, 74, 15);
	end);
	EventRegistry:RegisterCallback("ProfessionsRecipeListMixin.Event.OnRecipeSelected", self.OnRecipeSelected, self);

	UIDropDownMenu_SetInitializeFunction(self.RecipeList.FilterDropDown, GenerateClosure(self.InitFilterMenu, self));

	self.CreateButton:SetScript("OnClick", GenerateClosure(self.Create, self));
	self.CreateAllButton:SetScript("OnClick", GenerateClosure(self.CreateAll, self));

	self.RecipeList.SearchBox:SetScript("OnTextChanged", function(editBox)
		SearchBoxTemplate_OnTextChanged(editBox);
		Professions.OnRecipeListSearchTextChanged(editBox:GetText());
	end);

	self.LinkButton:SetScript("OnClick", function()
		if MacroFrameText and MacroFrameText:IsShown() and MacroFrameText:HasFocus() then
			local link = C_TradeSkillUI.GetTradeSkillListLink();
			if strlenutf8(MacroFrameText:GetText()) + strlenutf8(link) <= MacroFrameText:GetMaxLetters() then
				MacroFrameText:Insert(link);
			end
		else
			if ChatEdit_GetActiveWindow() then
				local link = C_TradeSkillUI.GetTradeSkillListLink();
				ChatEdit_InsertLink(link);
			else
				ToggleDropDownMenu(1, nil, self.LinkDropDown, self.LinkButton, 25, 25);
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
			end
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end);

	self.ViewGuildCraftersButton:SetScript("OnClick", function() self:OnViewGuildCraftersClicked(); end);

	self.TutorialButton:SetScript("OnClick", function() self:ToggleTutorial(); end);

	local function OnUseBestQualityModified(o, checked)
		local transaction = self.SchematicForm:GetTransaction();
		Professions.AllocateAllBasicReagents(transaction, checked);
		self.SchematicForm:SetManuallyAllocated(false);

		self:SetupCraftingButtons();
	end

	self.SchematicForm:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.UseBestQualityModified, OnUseBestQualityModified, self);
	
	local function OnAllocationsModified(o, checked)
		self:SetupCraftingButtons();
	end
	self.SchematicForm:RegisterCallback(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified, OnAllocationsModified);

	EventRegistry:RegisterCallback("Professions.ProfessionUpdated", self.OnProfessionUpdated, self);
	EventRegistry:RegisterCallback("Professions.ProfessionSelected", self.OnProfessionSelected, self);
	EventRegistry:RegisterCallback("Professions.ReagentClicked", self.OnReagentClicked, self);
	EventRegistry:RegisterCallback("Professions.TransactionUpdated", self.SetupCraftingButtons, self);

	UIDropDownMenu_Initialize(self.LinkDropDown, GenerateClosure(self.InitLinkDropdown, self), "MENU");

	self.flyoutSettings = 
	{
		onClickFunc = PaperDollFrameItemFlyoutButton_OnClick,
		getItemsFunc = PaperDollFrameItemFlyout_GetItems,
		postGetItemsFunc = PaperDollFrameItemFlyout_PostGetItems,
		hasPopouts = true,
		anchorX = 0,
		anchorY = -3,
		verticalAnchorX = 0,
		verticalAnchorY = 0,
		highlightSizeX = 45,
		highlightSizeY = 45,
		highlightOfsY = 3,
	};
end

function ProfessionsCraftingPageMixin:OnEvent(event, ...)
	if event == "TRADE_SKILL_DATA_SOURCE_CHANGING" then	
	elseif event == "TRADE_SKILL_DATA_SOURCE_CHANGED" then
		self:Reset();
		self.GuildFrame:Clear();
	elseif event == "UPDATE_TRADESKILL_RECAST_READY" then
		C_TradeSkillUI.ContinueRecast();
	elseif event == "TRADE_SKILL_CLOSE" then
		HideUIPanel(self);
	end
end

function ProfessionsCraftingPageMixin:InitLinkDropdown()
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	info.text = TRADESKILL_POST;
	info.isTitle = true;
	UIDropDownMenu_AddButton(info);

	info.isTitle = nil;
	info.notCheckable = true;
	info.func = function(_, channel)
		local link = C_TradeSkillUI.GetTradeSkillListLink();
		if link then
			ChatFrame_OpenChat(channel.." "..link, DEFAULT_CHAT_FRAME);
		end
	end;

	info.text = GUILD;
	info.arg1 = SLASH_GUILD1;
	info.disabled = not IsInGuild();
	UIDropDownMenu_AddButton(info);

	info.text = PARTY;
	info.arg1 = SLASH_PARTY1;
	info.disabled = (GetNumSubgroupMembers() == 0);
	UIDropDownMenu_AddButton(info);

	info.text = RAID;
	info.disabled = not IsInRaid();
	info.arg1 = SLASH_RAID1;
	UIDropDownMenu_AddButton(info);

	info.disabled = false

	local channels = { GetChannelList() };
	for i = 1, #channels, 3 do
		info.text = ChatFrame_ResolveChannelName(channels[i + 1]);
		info.arg1 = "/"..channels[i];
		info.disabled = channels[i + 2];
		UIDropDownMenu_AddButton(info);
	end
end

function ProfessionsCraftingPageMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsCraftingPageEvents);
end

function ProfessionsCraftingPageMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ProfessionsCraftingPageEvents);

	self.CraftingOutputLog:Close();
	if self:IsTutorialShown() then
		HelpPlate_Hide(false);
	end

	self:Reset();
end

function ProfessionsCraftingPageMixin:Reset()
	self.professionInfo = nil;
end

function ProfessionsCraftingPageMixin:GetDesiredPageWidth()
	local compact = C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging();
	return compact and 811 or 1105;
end

function ProfessionsCraftingPageMixin:OnReagentClicked(reagentName)
	self.RecipeList.SearchBox:SetText(reagentName);
end

function ProfessionsCraftingPageMixin:OnProfessionSelected(professionInfo)
	self:Init(professionInfo);
end

function ProfessionsCraftingPageMixin:OnProfessionUpdated(professionInfo)
	self:Init(professionInfo);
end

function ProfessionsCraftingPageMixin:InitFilterMenu(dropdown, level)
	Professions.InitFilterMenu(dropdown, level, GenerateClosure(self.UpdateFilterResetVisibility, self));
end

function ProfessionsCraftingPageMixin:UpdateFilterResetVisibility()
	self.RecipeList.FilterButton.ResetButton:SetShown(not Professions.IsUsingDefaultFilters());
end

function ProfessionsCraftingPageMixin:OnRecipeSelected(recipeInfo)
	-- The selected recipe from the list will be the first level. 
	-- Always forward the highest learned recipe to the schematic.
	local highestRecipe = Professions.GetHighestLearnedRecipe(recipeInfo);
	self.SchematicForm:Init(highestRecipe or recipeInfo);

	self.GuildFrame:Clear();

	local transaction = self.SchematicForm:GetTransaction();
	if transaction:IsRecipeType(Enum.TradeskillRecipeType.Salvage) then
		self.CreateMultipleInputBox:Disable();
		self.CreateMultipleInputBox:SetValue(0);
	else
		if recipeInfo.numAvailable > 0 then
			local count = math.max(1, C_TradeSkillUI.GetRecipeRepeatCount());
			self:SetupMultipleInputBox(count, recipeInfo.numAvailable);
		else
			self:SetupMultipleInputBox(0, 0);
		end
		
	end

	self:SetupCraftingButtons();
	local scrollToRecipe = false;
	self.RecipeList:SelectRecipe(recipeInfo, scrollToRecipe);
end

function ProfessionsCraftingPageMixin:SetupMultipleInputBox(count, countMax)
	if count > 0 and countMax > 0 then
		self.CreateMultipleInputBox:Enable();
		self.CreateMultipleInputBox:SetValue(count);
		self.CreateMultipleInputBox:SetMinMaxValues(1, countMax);
	else
		self.CreateMultipleInputBox:Disable();
		self.CreateMultipleInputBox:SetValue(0);
	end
end

function ProfessionsCraftingPageMixin:GetCraftableCount(count)
	local transaction = self.SchematicForm:GetTransaction();
	if transaction:IsRecipeType(Enum.TradeskillRecipeType.Salvage) then
		local salvageItem = transaction:GetSalvageAllocation();
		if salvageItem then
			local recipeSchematic = transaction:GetRecipeSchematic();
			local count = ItemUtil.GetCraftingReagentCount(salvageItem:GetItemID());
			return math.floor(count / recipeSchematic.quantityMax);
		else
			return 0;
		end
	else
		local intervals = math.huge;
		if self.SchematicForm:IsManuallyAllocated() then
			-- If manual, limit the count to the LCD of the allocated reagents.
			for index, allocations in transaction:EnumerateAllAllocations() do
				for _, allocation in allocations:Enumerate() do
					local possessed = Professions.GetReagentQuantityInPossession(allocation:GetReagent());
					intervals = math.min(intervals, math.floor(possessed / allocation:GetQuantity()));
				end
			end
		else
			-- If automatically allocated, then sum every reagent and divide by the quantity required.
			for index, reagents in transaction:EnumerateAllSlotReagents() do
				if transaction:IsSlotRequiredToCraft(index) then
					local total = 0;
					for _, reagent in ipairs(reagents) do
						total = total + Professions.GetReagentQuantityInPossession(reagent);
					end

					local required = transaction:GetQuantityRequiredInSlot(index);
					intervals = math.min(intervals, math.floor(total / required));
				end
			end
		end

		if intervals ~= math.huge then
			return intervals;
		end
		return 0;
	end
end

function ProfessionsCraftingPageMixin:SetupCraftingButtons()
	local currentRecipeInfo = self.SchematicForm:GetRecipeInfo();

	local isRuneforging = C_TradeSkillUI.IsRuneforging();
	if currentRecipeInfo ~= nil and currentRecipeInfo.learned and (Professions.InLocalCraftingMode() or C_TradeSkillUI.IsNPCCrafting() or isRuneforging)
	   and not currentRecipeInfo.isRecraft
	   and not currentRecipeInfo.isDummyRecipe and not currentRecipeInfo.isGatheringRecipe then
		self.CreateButton:Show();
		self.ViewGuildCraftersButton:Hide();

		local transaction = self.SchematicForm:GetTransaction();
		if currentRecipeInfo.createsItem and not transaction:HasRecraftAllocation() then
			self.CreateAllButton:Show();
			self.CreateMultipleInputBox:Show();
		else
			self.CreateAllButton:Hide();
			self.CreateMultipleInputBox:Hide();
		end

		if currentRecipeInfo.abilityVerb then
			-- abilityVerb is recipe-level override
			self.CreateButton:SetText(currentRecipeInfo.abilityVerb);
		elseif currentRecipeInfo.alternateVerb then
			-- alternateVerb is profession-level override
			self.CreateButton:SetText(currentRecipeInfo.alternateVerb);
		else
			self.CreateButton:SetText(CREATE_PROFESSION);
		end

		local countMax = self:GetCraftableCount();
		if currentRecipeInfo.abilityAllVerb then
			-- abilityAllVerb is recipe-level override
			self.CreateAllButton:SetTextToFit(currentRecipeInfo.abilityAllVerb:format(countMax));
		else
			self.CreateAllButton:SetTextToFit(PROFESSIONS_CREATE_ALL_COUNT:format(countMax));
		end

		local function IsRecipeOnCooldown(recipeID)
			local cooldown, isDayCooldown, charges, maxCharges = C_TradeSkillUI.GetRecipeCooldown(recipeID);
			if not cooldown then
				return false;
			end

			if charges > 0 then
				return false;
			end

			return true;
		end

		-- CAIS not relevant anymore since the client is denied login. Nevertheless, this is carried over from the
		-- previous implementation in case the CAIS system changes.
		local enabled = nil;
		if PartialPlayTime() then
			local reasonText = PLAYTIME_TIRED_ABILITY:format(REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60));
			self.CreateButton.tooltipText = reasonText;
			self.CreateAllButton.tooltipText = reasonText;
			enabled = false;
		elseif NoPlayTime() then
			local reasonText = PLAYTIME_UNHEALTHY_ABILITY:format(REQUIRED_REST_HOURS - math.floor(GetBillingTimeRested() / 60));
			self.CreateButton.tooltipText = reasonText;
			self.CreateAllButton.tooltipText = reasonText;
			enabled = false;
		elseif IsRecipeOnCooldown(currentRecipeInfo.recipeID) then
			self.CreateButton.tooltipText = PROFESSIONS_RECIPE_COOLDOWN;
			self.CreateAllButton.tooltipText = PROFESSIONS_RECIPE_COOLDOWN;
			enabled = false;
		else
			self.CreateButton.tooltipText = nil;
			self.CreateAllButton.tooltipText = nil;
			enabled = currentRecipeInfo.craftable and not currentRecipeInfo.disabled;
		end

		if enabled then
			if transaction:IsRecipeType(Enum.TradeskillRecipeType.Salvage) then
				enabled = transaction:HasAllocatedSalvageRequirements();
				if enabled then
					self:SetupMultipleInputBox(1, countMax);
				end
			else
				enabled = transaction:HasAllocatedReagentRequirements();
			end

			if not enabled then
				self.CreateButton.tooltipText = PROFESSIONS_INSUFFICIENT_REAGENTS;
				self.CreateAllButton.tooltipText = PROFESSIONS_INSUFFICIENT_REAGENTS;
			end
		end

		self.CreateButton:SetEnabled(enabled);
		self.CreateAllButton:SetEnabled(enabled);
		self.CreateMultipleInputBox:SetEnabled(enabled);

		if isRuneforging then
			self.CreateAllButton:Hide();
			self.CreateMultipleInputBox:Hide();
		end
	else
		self.CreateButton:Hide();
		self.CreateAllButton:Hide();
		self.CreateMultipleInputBox:Hide();
		
		if C_TradeSkillUI.IsTradeSkillGuild() then
			self.ViewGuildCraftersButton:Show();
			self.ViewGuildCraftersButton:SetEnabled(currentRecipeInfo and currentRecipeInfo.learned);
		else
			self.ViewGuildCraftersButton:Hide();
		end
	end
end

function ProfessionsCraftingPageMixin:Init(professionInfo)
	local oldProfessionInfo = self.professionInfo;
	self.professionInfo = professionInfo;

	local noStripCategories;
	if C_TradeSkillUI.IsRuneforging() then
		professionInfo.professionID = Constants.ProfessionConsts.RUNEFORGING_SKILL_LINE_ID;
		noStripCategories = {Constants.ProfessionConsts.RUNEFORGING_ROOT_CATEGORY_ID};
	end

	local changedProfessionID = not oldProfessionInfo or oldProfessionInfo.professionID ~= self.professionInfo.professionID;

	self.RankBar:SetShown(Professions.InLocalCraftingMode());

	local searching = self.RecipeList.SearchBox:HasText();
	local dataProvider = Professions.GenerateCraftingDataProvider(self.professionInfo.professionID, searching, noStripCategories);
	
	if searching or changedProfessionID then
		self.RecipeList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.DiscardScrollPosition);
	else
		self.RecipeList.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	end

	-- Because we're rebuilding the data provider, we need to either make an initial selection or
	-- reselect the recipe we previously had selected. If we've selected a recipe from another profession
	-- we ignore any previous selection.

	local function SelectInitialRecipe()
		-- Select an initial recipe. As mentioned above, every recipe in the data provider is the
		-- first recipe in the instance it has levels.
		for index, node in dataProvider:Enumerate() do
			local data = node:GetData();
			local recipeInfo = data.recipeInfo;
			if recipeInfo then
				return recipeInfo;
			end
		end
	end

	local currentRecipeInfo = nil;
	local openRecipeID = professionInfo.openRecipeID;
	if openRecipeID then
		local node = dataProvider:FindElementDataByPredicate(function(node)
			local data = node:GetData();
			local recipeInfo = data.recipeInfo;
			return recipeInfo and recipeInfo.recipeID == openRecipeID;
		end);

		assert(node, string.format("%d, %d", openRecipeID, dataProvider:GetSize()));
		if node then
			local data = node:GetData();
			currentRecipeInfo = data.recipeInfo;
		end
	else
		if changedProfessionID then
			currentRecipeInfo = SelectInitialRecipe();
		else
			currentRecipeInfo = self.SchematicForm:GetRecipeInfo();
			if currentRecipeInfo then
				currentRecipeInfo = Professions.GetFirstRecipe(currentRecipeInfo);
			else
				currentRecipeInfo = SelectInitialRecipe();
			end
		end
	end

	local hasRecipe = currentRecipeInfo ~= nil;
	if hasRecipe then
		local scrollToRecipe = openRecipeID ~= nil;
		local elementData = self.RecipeList:SelectRecipe(currentRecipeInfo, scrollToRecipe);
	else
		self.SchematicForm:Init();
		self:SetupCraftingButtons();
	end
end

function ProfessionsCraftingPageMixin:Refresh(professionInfo)
	self.SchematicForm.Background:SetAtlas(Professions.GetProfessionBackgroundAtlas(professionInfo), TextureKitConstants.IgnoreAtlasSize);

	local isRuneforging = C_TradeSkillUI.IsRuneforging();
	local useCondensedPanel = C_TradeSkillUI.IsNPCCrafting() or isRuneforging;
	local schematicWidth = useCondensedPanel and 500 or 793;
	self.SchematicForm:SetWidth(schematicWidth);
	
	if Professions.UpdateRankBarVisibility(self.RankBar, professionInfo) then
		self.RankBar:Update(professionInfo);
	end

	self:ConfigureInventorySlots(professionInfo);

	self.LinkButton:SetShown(C_TradeSkillUI.CanTradeSkillListLink() and Professions.InLocalCraftingMode());
	self.TutorialButton:SetShown(not isRuneforging);
	if self:IsTutorialShown() then
		HelpPlate_Hide(false);
	end
	self:UpdateFilterResetVisibility();
end

function ProfessionsCraftingPageMixin:CreateInternal(recipeID, count, recipeLevel)
	local transaction = self.SchematicForm:GetTransaction();
	if transaction:IsRecipeType(Enum.TradeskillRecipeType.Salvage) then
		local matchItemLocation = nil;
		local salvageItem = transaction:GetSalvageAllocation();
		local salvageItemID = salvageItem:GetItemID();
		ItemUtil.IteratePlayerInventory(function(bagItemLocation)
			local item = Item:CreateFromItemLocation(bagItemLocation);
			if item:GetItemID() == salvageItemID then
				matchItemLocation = bagItemLocation;
				return true;
			end
			return false;
		end);

		if matchItemLocation then
			C_TradeSkillUI.CraftSalvage(recipeID, count, matchItemLocation);
		end
	else
		local reagentsTbl = transaction:CreateCraftingReagentInfoTbl();
		if transaction:HasRecraftAllocation() then
			local result = C_TradeSkillUI.RecraftRecipe(transaction:GetRecraftAllocation(), reagentsTbl);
			if result then
				-- Create an expected table of item modifications so that we don't incorrectly deallocate
				-- an item modification slot on form refresh that has just been installed but hasn't been stamped
				-- with the item modification yet.
				transaction:GenerateExpectedItemModifications();
			end
		else
			C_TradeSkillUI.CraftRecipe(recipeID, count, reagentsTbl, recipeLevel);
		end
	end

	local successive = count > 1;
	self.CraftingOutputLog:Close();
	self.CraftingOutputLog:StartListening(successive);

	self.CreateMultipleInputBox:ClearFocus();

	self.SchematicForm.Details:Reset();
end

function ProfessionsCraftingPageMixin:OnViewGuildCraftersClicked()
	local professionInfo = C_TradeSkillUI.GetChildProfessionInfo();
	local effectiveSkillLineID = professionInfo.parentProfessionID or professionInfo.professionID;
	local currentRecipeInfo = self.SchematicForm:GetRecipeInfo();
	if effectiveSkillLineID and currentRecipeInfo.recipeID then
		self.GuildFrame:ShowGuildRecipe(effectiveSkillLineID, currentRecipeInfo.recipeID, self.SchematicForm:GetCurrentRecipeLevel());
	end
end

function ProfessionsCraftingPageMixin:CreateAll()
	local currentRecipeInfo = self.SchematicForm:GetRecipeInfo();
	self:CreateInternal(currentRecipeInfo.recipeID, currentRecipeInfo.numAvailable, self.SchematicForm:GetCurrentRecipeLevel());
end

function ProfessionsCraftingPageMixin:Create()
	local currentRecipeInfo = self.SchematicForm:GetRecipeInfo();
	self:CreateInternal(currentRecipeInfo.recipeID, self.CreateMultipleInputBox:GetValue(), self.SchematicForm:GetCurrentRecipeLevel());
end

function ProfessionsCraftingPageMixin:ConfigureInventorySlots(info)
	if (not Professions.InLocalCraftingMode()) or C_TradeSkillUI.IsRuneforging() or info.profession == nil then
		self:HideInventorySlots();
	else
		local professionSlots = C_TradeSkillUI.GetProfessionSlots(info.profession);
		for index, inventorySlot in ipairs(self.InventorySlots) do
			local show = tContains(professionSlots, inventorySlot.slotID);
			inventorySlot:SetShown(show);
		end
	end
end

function ProfessionsCraftingPageMixin:GetCurrentRecraftingRecipeID()
	local currentRecipeInfo = self.SchematicForm:GetRecipeInfo();
	if currentRecipeInfo and currentRecipeInfo.isRecraft then
		return currentRecipeInfo.recipeID;
	end
	return nil;
end

function ProfessionsCraftingPageMixin:HideInventorySlots()
	for index, inventorySlot in ipairs(self.InventorySlots) do
		inventorySlot:Hide();
	end
end

function ProfessionsCraftingPageMixin:AnyInventorySlotShown()
	for index, inventorySlot in ipairs(self.InventorySlots) do
		if inventorySlot:IsShown() then
			return true;
		end
	end

	return false;
end

ProfessionsCraftingPage_HelpPlate = 
{
	FramePos = { x = 5,	y = -22 },
	[1] = { ButtonPos = { x = 125,	y = -44 }, HighLightBox = { x = 0, y = -52, width = 297, height = 30 }, ToolTipDir = "DOWN", ToolTipText = PROFESSIONS_CRAFTING_HELP_FILTERS },
};

function ProfessionsCraftingPageMixin:UpdateTutorial()
	ProfessionsCraftingPage_HelpPlate.FrameSize = { width = self:GetDesiredPageWidth(), height = 635 };

	local numStaticAreas = 1;
	local maxTutorializedAreas = 7;
	for i = (numStaticAreas + 1), maxTutorializedAreas do
		ProfessionsCraftingPage_HelpPlate[i] = nil;
	end


	if self.SchematicForm.Reagents:IsShown() then
		local reagentsTopPoint = self.SchematicForm.Reagents:GetTop() - self:GetTop() + 30;
		local reagentsLeftPoint = self.SchematicForm.Reagents:GetLeft() - self:GetLeft() - 20;
		local basicReagentsBoxLeft = reagentsLeftPoint;
		local basicReagentsBoxTop = reagentsTopPoint;
		local reagentsBoxWidth = 225;
		local reagentsBoxHeight = 360;
		local reagentsButtonXOfs = 150;
		local reagentsButtonYOfs = -5;

		local basicReagentsSection =
		{
			ButtonPos = { x = basicReagentsBoxLeft + reagentsButtonXOfs, y = basicReagentsBoxTop + reagentsButtonYOfs },
			HighLightBox = { x = basicReagentsBoxLeft, y = basicReagentsBoxTop, width = reagentsBoxWidth, height = reagentsBoxHeight },
			ToolTipDir = "UP",
			ToolTipText = PROFESSIONS_CRAFTING_HELP_BASIC_REAGENTS,
		};
		table.insert(ProfessionsCraftingPage_HelpPlate, basicReagentsSection);

		if self.SchematicForm.OptionalReagents:IsShown() then
			local currentRecipeInfo = self.SchematicForm:GetRecipeInfo();
			local padding = 5;
			local optionalReagentsSection =
			{
				ButtonPos = { x = basicReagentsBoxLeft + reagentsBoxWidth + padding + reagentsButtonXOfs, y = basicReagentsBoxTop + reagentsButtonYOfs },
				HighLightBox = { x = basicReagentsBoxLeft + reagentsBoxWidth + padding, y = basicReagentsBoxTop, width = reagentsBoxWidth, height = reagentsBoxHeight },
				ToolTipDir = "UP",
				ToolTipText = (currentRecipeInfo and currentRecipeInfo.supportsQualities and C_TradeSkillUI.RecipeCanBeRecrafted(currentRecipeInfo.recipeID)) and PROFESSIONS_CRAFTING_HELP_OPTIONAL_REAGENTS_RECRAFTABLE or PROFESSIONS_CRAFTING_HELP_OPTIONAL_REAGENTS,
			};
			table.insert(ProfessionsCraftingPage_HelpPlate, optionalReagentsSection);
		end

		if self.SchematicForm.AllocateBestQualityCheckBox:IsShown() then
			local width = 210;
			local y = basicReagentsBoxTop - reagentsBoxHeight - 5;
			local bestQualityCheckboxSection =
			{
				ButtonPos = { x = basicReagentsBoxLeft + width - 25, y = y },
				HighLightBox = { x = basicReagentsBoxLeft, y = y, width = width, height = 60 },
				ToolTipDir = "RIGHT",
				ToolTipText = PROFESSIONS_CRAFTING_HELP_BEST_QUALITY,
			};
			table.insert(ProfessionsCraftingPage_HelpPlate, bestQualityCheckboxSection);
		end
	end

	local detailsShown = self.SchematicForm.Details:IsShown();
	local qualityMeter = self.SchematicForm.Details.QualityMeter;
	if detailsShown and qualityMeter:IsShown() then
		local qualityMeterTopPoint = qualityMeter:GetTop() - self:GetTop() + 14;
		local qualityMeterLeftPoint = qualityMeter:GetLeft() - self:GetLeft() - 5;
		local qualityMeterBoxWidth = 250;
		local qualityMeterSection =
		{
			ButtonPos = { x = qualityMeterLeftPoint + qualityMeterBoxWidth - 25, y = qualityMeterTopPoint },
			HighLightBox = { x = qualityMeterLeftPoint, y = qualityMeterTopPoint, width = qualityMeterBoxWidth, height = 60 },
			ToolTipDir = "RIGHT",
			ToolTipText = PROFESSIONS_CRAFTING_HELP_BAR,
		};
		table.insert(ProfessionsCraftingPage_HelpPlate, qualityMeterSection);
	end

	local finishingReagents = self.SchematicForm.Details.FinishingReagentSlotContainer;
	if detailsShown and finishingReagents:IsShown() then
		local finishingReagentsTopPoint = finishingReagents:GetTop() - self:GetTop();
		local finishingReagentsLeftPoint = finishingReagents:GetLeft() - self:GetLeft() + 50;
		local width = 150;
		local finishingReagentsSection =
		{
			ButtonPos = { x = finishingReagentsLeftPoint + width - 25, y = finishingReagentsTopPoint - 25 },
			HighLightBox = { x = finishingReagentsLeftPoint, y = finishingReagentsTopPoint, width = width, height = 80 },
			ToolTipDir = "RIGHT",
			ToolTipText = PROFESSIONS_CRAFTING_HELP_FINISHING_REAGENTS,
		};
		table.insert(ProfessionsCraftingPage_HelpPlate, finishingReagentsSection);
	end

	if self:AnyInventorySlotShown() then
		local gearSection =
		{
			ButtonPos = { x = 1066, y = -3 },
			HighLightBox = { x = 937, y = 1, width = 153, height = 56 },
			ToolTipDir = "RIGHT",
			ToolTipText = PROFESSIONS_CRAFTING_HELP_GEAR,
		};
		table.insert(ProfessionsCraftingPage_HelpPlate, gearSection);
	end
end

function ProfessionsCraftingPageMixin:ShowTutorial()
	self:UpdateTutorial();
	HelpPlate_Show(ProfessionsCraftingPage_HelpPlate, self, self.TutorialButton);
end

function ProfessionsCraftingPageMixin:IsTutorialShown()
	return HelpPlate_IsShowing(ProfessionsCraftingPage_HelpPlate);
end

function ProfessionsCraftingPageMixin:ToggleTutorial()
	if not self:IsTutorialShown() then
		self:ShowTutorial();
	else
		HelpPlate_Hide(true);
	end
end
