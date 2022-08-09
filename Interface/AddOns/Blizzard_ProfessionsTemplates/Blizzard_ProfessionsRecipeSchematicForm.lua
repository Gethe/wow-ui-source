StaticPopupDialogs["PROFESSIONS_RECRAFT_REPLACE_OPTIONAL_REAGENT"] = {
	text = "",
	button1 = ACCEPT,
	button2 = CANCEL,

	OnShow = function(self, data)
		self.text:SetText(PROFESSIONS_RECRAFTING_REPLACE_OPTIONAL:format(data.itemName));
	end,

	OnAccept = function(self, data)
		data.callback();
	end,

	showAlert = 1,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
};

local cooldownFormatter = CreateFromMixins(SecondsFormatterMixin);
cooldownFormatter:Init(
	SecondsFormatterConstants.ZeroApproximationThreshold, 
	SecondsFormatter.Abbreviation.Truncate, 
	SecondsFormatterConstants.DontRoundUpLastUnit, 
	SecondsFormatterConstants.DontConvertToLower);

local LayoutEntry = EnumUtil.MakeEnum("Cooldown", "Description", "Source");

ProfessionsRecipeSchematicFormMixin = CreateFromMixins(CallbackRegistryMixin);

ProfessionsRecipeSchematicFormMixin:GenerateCallbackEvents(
{
    "UseBestQualityModified",
    "AllocationsModified",
});

local ProfessionsRecipeFormEvents =
{
    "NEW_RECIPE_LEARNED",
	"TRACKED_RECIPE_UPDATE",
	"TRADE_SKILL_ITEM_UPDATE",
};

function ProfessionsRecipeSchematicFormMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	local function PoolReset(pool, slot)
		slot:Reset();
		slot.Button:SetScript("OnEnter", nil);
		slot.Button:SetScript("OnClick", nil);
		slot.Button:SetScript("OnMouseDown", nil);
		FramePool_HideAndClearAnchors(pool, slot);
	end

	self.Stars:SetPoint("LEFT", self.OutputText, "RIGHT", 10, -1);
	self.RecipeLevelBar:SetPoint("LEFT", self.OutputText, "RIGHT", 10, -1);

	self.reagentSlotPool = CreateFramePool("FRAME", self, "ProfessionsReagentSlotTemplate", PoolReset);
	self.selectedRecipeLevels = {};

	self.AllocateBestQualityCheckBox.text:SetText(LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(PROFESSIONS_USE_BEST_QUALITY_REAGENTS));
	self.AllocateBestQualityCheckBox:SetScript("OnClick", function(button, buttonName, down)
		local checked = button:GetChecked();
		Professions.SetShouldAllocateBestQualityReagents(checked);

		self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.UseBestQualityModified, checked);
		
		self:UpdateAllSlots();

		-- Trick to re-fire the OnEnter script to update the tooltip.
		self:Hide();
		self:Show();
	end);

	self.AllocateBestQualityCheckBox:SetScript("OnEnter", function(button)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		local checked = button:GetChecked();
		if checked then
			GameTooltip_AddHighlightLine(GameTooltip, PROFESSIONS_USE_LOWEST_QUALITY_REAGENTS);
		else
			GameTooltip_AddHighlightLine(GameTooltip, PROFESSIONS_USE_HIGHEST_QUALITY_REAGENTS);
		end
		GameTooltip:Show();
	end);
	self.AllocateBestQualityCheckBox:SetScript("OnLeave", GameTooltip_Hide);

	self.TrackRecipeCheckBox.text:SetText(LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(PROFESSIONS_TRACK_RECIPE));
	self.TrackRecipeCheckBox:SetScript("OnClick", function(button, buttonName, down)
		local currentRecipeInfo = self:GetRecipeInfo();
		local checked = button:GetChecked();
		C_TradeSkillUI.SetRecipeTracked(currentRecipeInfo.recipeID, checked);
	end);

	self.Stars:SetScript("OnLeave", GameTooltip_Hide);

	self.RecipeLevelSelector:SetSelectorCallback(function(recipeInfo, level)
		self:SetSelectedRecipeLevel(recipeInfo.recipeID, level);
		self:Init(recipeInfo);
	end);
end

function ProfessionsRecipeSchematicFormMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, ProfessionsRecipeFormEvents);

	local recipeInfo = self:GetRecipeInfo();
	if recipeInfo then
		-- Details may have changed due to purchasing specialization points
		self:Init(recipeInfo);
		self:UpdateDetailsStats();
	end
end

function ProfessionsRecipeSchematicFormMixin:OnHide()
    FrameUtil.UnregisterFrameForEvents(self, ProfessionsRecipeFormEvents);

	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);

	self.QualityDialog:Close();
end

function ProfessionsRecipeSchematicFormMixin:OnEvent(event, ...)
	if event == "NEW_RECIPE_LEARNED" then
		local recipeID, recipeLevel, baseRecipeID = ...;
		local currentRecipeInfo = self:GetRecipeInfo();
		if currentRecipeInfo and currentRecipeInfo.recipeID == baseRecipeID then
			self:SetSelectedRecipeLevel(baseRecipeID, recipeLevel);
			self:Init(currentRecipeInfo);
		end
	elseif event == "TRACKED_RECIPE_UPDATE" then
		local recipeID, tracked = ...
		self.TrackRecipeCheckBox:SetChecked(tracked);
	elseif event == "TRADE_SKILL_ITEM_UPDATE" then
		if self.transaction and self.transaction:IsRecraft() then
			local itemGUID = ...;
			if itemGUID == self.transaction:GetRecraftAllocation() then
				local clearExpected = true;
				self.transaction:SanitizeRecraftAllocation(clearExpected);
				self.transaction:SanitizeOptionalAllocations();
			end
		end
	end
end

function ProfessionsRecipeSchematicFormMixin:Init(recipeInfo)
	local stride = 1;
	local xPadding = 0;
	local yPadding = 0;
	local anchor = AnchorUtil.CreateAnchor("TOPLEFT", self.OutputIcon, "BOTTOMLEFT", 7, -10);
	local organizer = AnchorUtil.CreateGridLayoutOrganizer(stride, anchor, xPadding, yPadding);

	self.OutputSubText:Hide();
	self.RequiredTools:Hide();
	self.Description:Hide();
	self.Stars:SetScript("OnEnter", nil);
	self.Stars:Hide();
	self.RecipeLevelBar:Hide();
	self.RecipeLevelSelector:Hide();
	self.Cooldown:Hide();
	self.Cooldown:SetText("");
	self.RecipeSourceButton:Hide();
	self.QualityDialog:Close();

	self.currentRecipeInfo = recipeInfo;

	local hasRecipe = recipeInfo ~= nil;

	for _, frame in ipairs(self.recipeInfoFrames) do
		frame:SetShown(hasRecipe);
	end

	if not hasRecipe then
		return;
	end

	local recipeID = recipeInfo.recipeID;
	local isRecipeInfoRecraft = recipeInfo.isRecraft;
	local isRecraft = isRecipeInfoRecraft;

	local recraftTransitionData = Professions.EraseRecraftingTransitionData();
	if recraftTransitionData then
		isRecraft = true;
	end

	local newTransaction = not self.transaction or recraftTransitionData or (self.transaction:GetRecipeID() ~= recipeID);
	if not newTransaction and (self.transaction and self.transaction:IsRecraft()) then
		isRecraft = true;
	end
	
	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);

	self.RecraftingDescription:SetShown(isRecipeInfoRecraft);

	if isRecraft then
		self.RecraftingOutputText:Show();

		self.OutputIcon:Hide();
		self.RequiredTools:Hide();
		self.OutputText:Hide();
	else
		self.OutputIcon:Show();
		self.OutputText:Show();
		self.RequiredTools:Show();

		self.RecraftingOutputText:Hide();
	end

	self.recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft, self:GetCurrentRecipeLevel());

	if newTransaction then
		local onChanged = GenerateClosure(self.UpdateDetailsStats, self);
		self.transaction = CreateProfessionsRecipeTransaction(self.recipeSchematic, onChanged);
		self.transaction:SetRecraft(isRecraft);
	end

	local function AllocateModification(slotIndex, reagentSlotSchematic)
		local modification = self.transaction:GetModification(reagentSlotSchematic.dataSlotIndex);
		if modification and modification.itemID > 0 then
			local reagent = Professions.CreateCraftingReagentByItemID(modification.itemID);
			self.transaction:OverwriteAllocation(slotIndex, reagent, reagentSlotSchematic.quantityRequired);
		end
	end

	if recraftTransitionData then
		self.transaction:SetRecraftAllocation(recraftTransitionData.itemGUID);

		for slotIndex, reagentSlotSchematic in ipairs(self.recipeSchematic.reagentSlotSchematics) do
			if reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent then
				AllocateModification(slotIndex, reagentSlotSchematic);
			end
		end
	end

	local function CanTrack(transaction)
		if isRecipeInfoRecraft then
			return false;
		end

		if not Professions.InLocalCraftingMode() then
			return false;
		end

		if C_TradeSkillUI.IsRuneforging() then
			return false;
		end

		if self.transaction:IsRecipeType(Enum.TradeskillRecipeType.Salvage) then
			return false; 
		end

		return true;
	end

	self.TrackRecipeCheckBox:SetShown(CanTrack());
	self.TrackRecipeCheckBox:SetChecked(C_TradeSkillUI.IsRecipeTracked(recipeInfo.recipeID));

	local learned = recipeInfo.learned;
	if learned and (newTransaction or not self:IsManuallyAllocated()) then
		self.transaction:SanitizeOptionalAllocations();
		-- Unless the allocation has been manually changed, the 'best quality reagent' option is used to
		-- auto-allocate the reagents.
		Professions.AllocateAllBasicReagents(self.transaction, Professions.ShouldAllocateBestQualityReagents());
		self:SetManuallyAllocated(false);
	else
		-- We still need to sanitize the transaction to remove allocations we no longer have even if
		-- we're manually allocating. When we run out of a reagent, we expect the allocation to be
		-- removed.
		self.transaction:SanitizeAllocations();
	end

	-- Verifies that the recraft target is still valid, and that the item modifications
	-- for the item are updated.
	self.transaction:SanitizeRecraftAllocation();

	local cooldown, isDayCooldown, charges, maxCharges = C_TradeSkillUI.GetRecipeCooldown(recipeID);
	if maxCharges > 0 and (charges > 0 or not cooldown) then
		self.Cooldown:SetFormattedText(TRADESKILL_CHARGES_REMAINING, charges, maxCharges);
		self.Cooldown:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
	elseif recipeInfo.disabled then
		self.Cooldown:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		self.Cooldown:SetText(recipeInfo.disabledReason);
	else
		local function SetCooldownRemaining(cooldown)
			self.Cooldown:SetText(COOLDOWN_REMAINING.." "..cooldownFormatter:Format(cooldown));
		end

		self.Cooldown:SetTextColor(RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		if not cooldown then
			self.Cooldown:SetText("");
		elseif not isDayCooldown then
			cooldownFormatter:SetMinInterval(SecondsFormatter.Interval.Seconds);
			SetCooldownRemaining(cooldown);
		elseif cooldown > SECONDS_PER_DAY then
			cooldownFormatter:SetMinInterval(SecondsFormatter.Interval.Days);
			SetCooldownRemaining(cooldown);
		else
			self.Cooldown:SetText(COOLDOWN_EXPIRES_AT_MIDNIGHT);
		end
	end

	local cooldownText = self.Cooldown:GetText();
	if cooldownText and cooldownText ~= "" then
		self.Cooldown:Show();
		organizer:Add(self.Cooldown, LayoutEntry.Cooldown);
	end

	local sourceText, sourceTextIsForNextRank;
	if not recipeInfo.learned then
		sourceText = C_TradeSkillUI.GetRecipeSourceText(recipeID);
	elseif recipeInfo.nextRecipeID then
		sourceText = C_TradeSkillUI.GetRecipeSourceText(recipeInfo.nextRecipeID);
		sourceTextIsForNextRank = true;
	end

	if sourceText then
		if sourceTextIsForNextRank then
			self.RecipeSourceButton.Text:SetText(TRADESKILL_NEXT_RANK_HEADER);
		else
			self.RecipeSourceButton.Text:SetText(TRADESKILL_UNLEARNED_RECIPE_HEADER);
		end

		self.RecipeSourceButton:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self.RecipeSourceButton, "ANCHOR_RIGHT");
			GameTooltip_AddHighlightLine(GameTooltip, sourceText);
			GameTooltip:SetMinimumWidth(400);
			GameTooltip:Show();
		end);

		self.RecipeSourceButton:Show();
		organizer:Add(self.RecipeSourceButton, LayoutEntry.Source);
	end

	if self.loader then
		self.loader:Cancel();
	end
	self.loader = CreateProfessionsRecipeLoader(self.recipeSchematic, function()
		local firstRecipeInfo = Professions.GetFirstRecipe(recipeInfo);
		local spell = Spell:CreateFromSpellID(firstRecipeInfo.recipeID);
		local description = C_TradeSkillUI.GetRecipeDescription(spell:GetSpellID());
		if description and description ~= "" then
			self.Description:SetText(description);
			self.Description:SetHeight(200);
			self.Description:SetHeight(self.Description:GetStringHeight() + 1);
			self.Description:Show();
			organizer:Add(self.Description, LayoutEntry.Description);
		end

		organizer:Layout();

		local outputItemInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeID);
		local text;
		if outputItemInfo.hyperlink then
			local item = Item:CreateFromItemLink(outputItemInfo.hyperlink);
			local color = item:GetItemQualityColor().color;
			text = WrapTextInColor(item:GetItemName(), color);
		else
			text = WrapTextInColor(self.recipeSchematic.name, NORMAL_FONT_COLOR);
		end
		
		local function SetOutputText(fontString, text)
			fontString:SetText(text);
			fontString:SetWidth(300);
			fontString:SetWidth(fontString:GetStringWidth());
			fontString:SetHeight(fontString:GetStringHeight());
		end

		if isRecipeInfoRecraft then
			SetOutputText(self.RecraftingOutputText, "Recrafting");
		elseif isRecraft then
			SetOutputText(self.RecraftingOutputText, PROFESSIONS_CRAFTING_FORM_RECRAFTING_HEADER:format(text));
		else
			SetOutputText(self.OutputText, text);
		end

		Professions.SetupOutputIcon(self.OutputIcon, self.transaction, outputItemInfo);
	end);

	self.OutputIcon:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.OutputIcon, "ANCHOR_RIGHT");

		local optionalReagents = self.transaction:CreateCraftingReagentInfoTbl();
		GameTooltip:SetRecipeResultItem(self.recipeSchematic.recipeID, optionalReagents, self:GetCurrentRecipeLevel());
	end);
	self.OutputIcon:SetScript("OnLeave", GameTooltip_Hide);

	self.OutputIcon:SetScript("OnClick", function()
		-- HRO TODO: Make this get a hyperlink with quality
		local link = C_TradeSkillUI.GetRecipeItemLink(recipeID);
		HandleModifiedItemClick(link);
	end);

	if Professions.HasRecipeRanks(recipeInfo) then
		local rank = Professions.GetRecipeRankLearned(recipeInfo);

		self.Stars:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self.Stars, "ANCHOR_TOPLEFT");
			GameTooltip:SetRecipeRankInfo(recipeID, rank);
			GameTooltip:Show();
		end);

		for index, star in ipairs(self.Stars.Stars) do
			star.Earned:SetShown(index <= rank);
		end

		self.Stars:Show();
	elseif recipeInfo.unlockedRecipeLevel then
		self.RecipeLevelBar:SetExperience(recipeInfo.currentRecipeExperience, recipeInfo.nextLevelRecipeExperience, recipeInfo.unlockedRecipeLevel);

		if not self:GetCurrentRecipeLevel() then
			self:SetSelectedRecipeLevel(recipeID, recipeInfo.unlockedRecipeLevel);
		end

		self.RecipeLevelSelector:SetRecipeInfo(recipeInfo, self:GetCurrentRecipeLevel());
		self.RecipeLevelSelector:Show();
		self.RecipeLevelBar:Show();
	end

	do
		local function SetRequiredToolsText(fontString, text)
			fontString:SetText(text);
			fontString:SetWidth(300);
			fontString:SetWidth(fontString:GetStringWidth());
			fontString:SetHeight(fontString:GetStringHeight());
			fontString:Show();
		end
		
		self.RecraftingRequiredTools:Hide();
		self.RequiredTools:Hide();

		local toolsString = BuildColoredListString(C_TradeSkillUI.GetRecipeTools(recipeID));
		if toolsString then
			local text = PROFESSIONS_REQUIRED_TOOLS:format(toolsString);
			if isRecraft then
				SetRequiredToolsText(self.RecraftingRequiredTools, text);
			else
				SetRequiredToolsText(self.RequiredTools, text);
			end
		end
	end

	self.reagentSlotPool:ReleaseAll();
	self.reagentSlots = {};
	if self.salvageSlot then
		self.salvageSlot:Hide();
	end

	local slotParents =
	{
		[Enum.CraftingReagentType.Basic] = self.Reagents, 
		[Enum.CraftingReagentType.Optional] = self.OptionalReagents,
		[Enum.CraftingReagentType.Finishing] = self.Details.FinishingReagentSlotContainer,
	};

	if isRecraft then
		if not self.recraftSlot then
			self.recraftSlot = CreateFrame("FRAME", nil, self, "ProfessionsReagentRecraftTemplate");
			self.recraftSlot:SetPoint("TOPLEFT", self.RecraftingOutputText, "BOTTOMLEFT", 0, -30);
		end
		self.recraftSlot:Show();
		self.recraftSlot:Init(self.transaction);

		self.recraftSlot.InputSlot:SetScript("OnMouseDown", function(button, buttonName, down)
			if buttonName == "LeftButton" then
				local flyout = ToggleProfessionsItemFlyout(self.recraftSlot.InputSlot);
				if flyout then
					local function OnFlyoutItemSelected(o, flyout, elementData)
						Professions.TransitionToRecraft(elementData.itemGUID);
					end
		
					flyout.GetElementsImplementation = function(self)
						local itemGUIDs = C_TradeSkillUI.GetRecraftItems(recipeID);
						local items = ItemUtil.TransformItemGUIDsToItems(itemGUIDs);
						local elementData = {items = items, itemGUIDs = itemGUIDs};
						return elementData;
					end

					flyout.OnElementEnterImplementation = function(elementData, tooltip)
						tooltip:SetItemByGUID(elementData.itemGUID);
					end

					local cannotFilter = true;
					flyout:Init(self.recraftSlot.InputSlot, nilTransaction, cannotFilter);
					flyout:RegisterCallback(ProfessionsItemFlyoutMixin.Event.ItemSelected, OnFlyoutItemSelected, slot);
				end
			end
		end);

		self.recraftSlot.InputSlot:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self.recraftSlot.InputSlot, "ANCHOR_RIGHT");

			local itemGUID = self.transaction:GetRecraftAllocation();
			if itemGUID then
				GameTooltip:SetItemByGUID(itemGUID);
				GameTooltip_AddBlankLineToTooltip(GameTooltip);
				GameTooltip_AddInstructionLine(GameTooltip, RECRAFT_REAGENT_TOOLTIP_CLICK_TO_REPLACE);
			else
				GameTooltip_AddInstructionLine(GameTooltip, RECRAFT_REAGENT_TOOLTIP_CLICK_TO_ADD);
			end
			GameTooltip:Show();
		end);

		self.recraftSlot.OutputSlot:SetScript("OnEnter", function()
			local itemGUID = self.transaction:GetRecraftAllocation();
			if itemGUID then
				GameTooltip:SetOwner(self.recraftSlot.OutputSlot, "ANCHOR_RIGHT");

				local optionalReagents = self.transaction:CreateCraftingReagentInfoTbl();
				GameTooltip:SetRecipeResultItem(self.recipeSchematic.recipeID, optionalReagents, self:GetCurrentRecipeLevel());
			end
		end);

		self.RecraftingRequiredTools:SetPoint("TOPLEFT", self.recraftSlot, "BOTTOMLEFT", 0, -15);
	else
		if self.recraftSlot then
			self.recraftSlot:Hide();
		end
	end

	if isRecipeInfoRecraft then
		self.RecraftingDescription:SetPoint("TOPLEFT", self.recraftSlot, "BOTTOMLEFT", 0, -20);
		self.RecraftingDescription:SetTextColor(GRAY_FONT_COLOR:GetRGB());
	end

	for slotIndex, reagentSlotSchematic in ipairs(self.recipeSchematic.reagentSlotSchematics) do
		local reagentType = reagentSlotSchematic.reagentType;

		local slots = self.reagentSlots[reagentType];
		if not slots then
			slots = {};
			self.reagentSlots[reagentType] = slots;
		end

		local slot = self.reagentSlotPool:Acquire();
		table.insert(slots, slot);

		slot:SetParent(slotParents[reagentType]);
		
		slot.CustomerState:SetShown(false);
		slot:SetQuantityAvailableCallback(Professions.AccumulateReagentsInPossession);
		slot:Init(self.transaction, reagentSlotSchematic);
		slot:Show();

		if reagentType == Enum.CraftingReagentType.Basic then
			if Professions.InLocalCraftingMode() and Professions.GetReagentInputMode(reagentSlotSchematic) == Professions.ReagentInputMode.Quality then
				slot.Button:SetScript("OnClick", function(button, buttonName, down)
					if IsShiftKeyDown() then
						local qualityIndex = Professions.FindFirstQualityAllocated(self.transaction, reagentSlotSchematic) or 1;
						local handled, link = Professions.HandleQualityReagentItemLink(recipeID, reagentSlotSchematic, qualityIndex);
						if not handled then
							Professions.TriggerReagentClickedEvent(link);
						end
						return;
					end

					if not slot:IsUnallocatable() then
						if buttonName == "LeftButton" then
							local function OnAllocationsAccepted(dialog, allocations, reagentSlotSchematic)
								self.transaction:OverwriteAllocations(reagentSlotSchematic.slotIndex, allocations);
								self:SetManuallyAllocated(true);

								slot:Update();

								self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
							end

							self.QualityDialog:RegisterCallback(ProfessionsQualityDialogMixin.Event.Accepted, OnAllocationsAccepted, slot);
							
							local allocationsCopy = self.transaction:GetAllocationsCopy(slotIndex);
							self.QualityDialog:Open(recipeID, reagentSlotSchematic, allocationsCopy);
						end
					end
				end);

				slot.Button:SetScript("OnEnter", function()
					GameTooltip:SetOwner(slot.Button, "ANCHOR_RIGHT");
					Professions.SetupQualityReagentTooltip(slot, self.transaction);
					GameTooltip:Show();
				end);
			else
				slot.Button:SetScript("OnClick", function(button, buttonName, down)
					if IsShiftKeyDown() then
						local handled, link = Professions.HandleFixedReagentItemLink(recipeID, reagentSlotSchematic);
						if not handled then
							Professions.TriggerReagentClickedEvent(link);
						end
					end
				end);

				slot.Button:SetScript("OnEnter", function()
					GameTooltip:SetOwner(slot.Button, "ANCHOR_RIGHT");
					GameTooltip:SetRecipeReagentItem(recipeID, reagentSlotSchematic.dataSlotIndex);
					GameTooltip:Show();
				end);
			end
		else
			local locked, lockedReason = Professions.GetReagentSlotStatus(reagentSlotSchematic, recipeInfo);
			slot.Button:SetLocked(locked);

			slot.UndoButton:SetScript("OnClick", function(button)
				AllocateModification(slotIndex, reagentSlotSchematic);

				self:SetManuallyAllocated(true);

				slot:RestoreOriginalItem();

				self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
			end);

			slot.Button:SetScript("OnEnter", function()
				GameTooltip:SetOwner(slot.Button, "ANCHOR_RIGHT");

				if locked then
					local title = (reagentType == Enum.CraftingReagentType.Finishing) and FINISHING_REAGENT_TOOLTIP_TITLE:format(reagentSlotSchematic.slotInfo.slotText) or EMPTY_OPTIONAL_REAGENT_TOOLTIP_TITLE;
					GameTooltip_SetTitle(GameTooltip, title);
					GameTooltip_AddErrorLine(GameTooltip, lockedReason);
				else
					local exchangeOnly = self.transaction:HasModification(reagentSlotSchematic.dataSlotIndex);
					Professions.SetupOptionalReagentTooltip(slot, recipeID, reagentType, reagentSlotSchematic.slotInfo.slotText, exchangeOnly);

					slot.Button.InputOverlay.AddIconHighlight:SetShown(true);
				end
				GameTooltip:Show();
			end);
			
			slot.Button:SetScript("OnMouseDown", function(button, buttonName, down)
				if locked then
					return;
				end

				if not slot:IsUnallocatable() then
					if buttonName == "LeftButton" then
						local flyout = ToggleProfessionsItemFlyout(slot.Button);
						if flyout then
							local function OnFlyoutItemSelected(o, flyout, elementData)
								local item = elementData.item;
								
								local function AllocateFlyoutItem()
									if ItemUtil.GetCraftingReagentCount(item:GetItemID()) == 0 then
										return;
									end

									local reagent = Professions.CreateCraftingReagentByItemID(item:GetItemID());
									self.transaction:OverwriteAllocation(slotIndex, reagent, reagentSlotSchematic.quantityRequired);
									
									-- This sets manual allocation to limit the create multiple to the exact
									-- configuration provided. If 3 of an optional reagent were assigned but
									-- 9 items could be made without it, the create multiple count should be limited to
									-- 3. Create multiple is only ever uncapped when no optionals are provided and
									-- the quality of a basic reagent hasn't been hand tweaked.
									self:SetManuallyAllocated(true);

									slot:SetItem(item);

									self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
								end

								local modification = self.transaction:GetModification(reagentSlotSchematic.dataSlotIndex);
								local allocate = not (modification and self.transaction:HasAllocatedItemID(modification.itemID));
								if allocate then
									AllocateFlyoutItem();
								else
									local modItem = Item:CreateFromItemID(modification.itemID);
									local dialogData = {callback = AllocateFlyoutItem, itemName = modItem:GetItemName()};
									StaticPopup_Show("PROFESSIONS_RECRAFT_REPLACE_OPTIONAL_REAGENT", nil, nil, dialogData);	
								end
							end

							flyout.GetElementsImplementation = function(self, filterOwned)
								local itemIDs = Professions.ExtractItemIDsFromCraftingReagents(reagentSlotSchematic.reagents);
								if filterOwned then
									itemIDs = ItemUtil.FilterOwnedItems(itemIDs);
								end
								local items = ItemUtil.TransformItemIDsToItems(itemIDs);
								local elementData = {items = items};
								return elementData;
							end
							
							flyout.OnElementEnterImplementation = function(elementData, tooltip)
								Professions.FlyoutOnElementEnterImplementation(elementData, tooltip, recipeID);
							end

							local cannotFilter = false;
							flyout:Init(slot.Button, self.transaction, cannotFilter);
							flyout:RegisterCallback(ProfessionsItemFlyoutMixin.Event.ItemSelected, OnFlyoutItemSelected, slot);
						end
					elseif buttonName == "RightButton" then
						-- Optional reagents cannot be removed, only replaced.
						if not self.transaction:HasModification(reagentSlotSchematic.dataSlotIndex) then
							self.transaction:ClearAllocations(slotIndex);

							slot:ClearItem();

							self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
						end
					end
				end
			end);
		end
	end
	
	local isSalvage = self.recipeSchematic.recipeType == Enum.TradeskillRecipeType.Salvage;
	if isSalvage then
		if not self.salvageSlot then
			self.salvageSlot = CreateFrame("FRAME", nil, self, "ProfessionsReagentSalvageTemplate");
		end
		self.salvageSlot:Show();
		self.salvageSlot:Init(self.transaction, self.recipeSchematic.quantityMax);

		self.salvageSlot.Button:SetScript("OnMouseDown", function(button, buttonName, down)
			if buttonName == "LeftButton" then
				local flyout = ToggleProfessionsItemFlyout(self.salvageSlot.Button);
				if flyout then
					local function OnFlyoutItemSelected(o, flyout, elementData)
						local item = elementData.item;
						if ItemUtil.GetCraftingReagentCount(item:GetItemID()) == 0 then
							return;
						end

						self.transaction:SetSalvageAllocation(item);

						self.salvageSlot:SetItem(item);

						self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
					end
					
		
					flyout.GetElementsImplementation = function(self, filterOwned)
						local itemIDs = C_TradeSkillUI.GetSalvagableItemIDs(recipeID);
						if filterOwned then
							itemIDs = ItemUtil.FilterOwnedItems(itemIDs);
						end
						local items = ItemUtil.TransformItemIDsToItems(itemIDs);
						local elementData = {items = items};
						return elementData;
					end

					flyout.OnElementEnterImplementation = function(elementData, tooltip)
						Professions.FlyoutOnElementEnterImplementation(elementData, tooltip, recipeID);
					end

					local cannotFilter = false;
					flyout:Init(self.salvageSlot.Button, nilTransaction, cannotFilter);
					flyout:RegisterCallback(ProfessionsItemFlyoutMixin.Event.ItemSelected, OnFlyoutItemSelected, slot);
				end
			elseif buttonName == "RightButton" then
				self.transaction:ClearSalvageAllocations();

				self.salvageSlot:ClearItem();

				self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
			end
		end);

		self.salvageSlot.Button:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self.salvageSlot.Button, "ANCHOR_RIGHT");

			local salvageItem = self.transaction:GetSalvageAllocation();
			if salvageItem then
				GameTooltip:SetItemByID(salvageItem:GetItemID());
				GameTooltip_AddBlankLineToTooltip(GameTooltip);
				GameTooltip_AddInstructionLine(GameTooltip, SALVAGE_REAGENT_TOOLTIP_CLICK_TO_REMOVE);
			else
				GameTooltip_AddInstructionLine(GameTooltip, SALVAGE_REAGENT_TOOLTIP_CLICK_TO_ADD);
			end
			GameTooltip:Show();
		end);
	else
		if self.salvageSlot then
			self.salvageSlot:Hide();
		end
	end

	if not learned then
		for key, reagentType in pairs(Enum.CraftingReagentType) do
			local slots = self:GetSlotsByReagentType(reagentType);
			if slots then
				for index, slot in ipairs(slots) do
					slot:SetUnallocatable(true);
				end
			end
		end
	end

	local basicSlots;
	if isSalvage then
		basicSlots = {self.salvageSlot};
	else
		basicSlots = self:GetSlotsByReagentType(Enum.CraftingReagentType.Basic);
	end

	Professions.LayoutReagentSlots(basicSlots, self.Reagents, 
		self:GetSlotsByReagentType(Enum.CraftingReagentType.Optional), self.OptionalReagents, self.VerticalDivider);
	
	if basicSlots and #basicSlots > 0 then
		self.Reagents:Show();

		if isRecraft then
			self.Reagents:SetPoint("TOP", self.OutputIcon, "BOTTOM", 75, -123);
		else
			self.Reagents:SetPoint("TOP", self.OutputIcon, "BOTTOM", 75, -65);
		end
	else
		self.Reagents:Hide();
	end

	local professionLearned = C_TradeSkillUI.GetChildProfessionInfo().skillLevel > 0;
	local operationInfo = professionLearned and C_TradeSkillUI.GetCraftingOperationInfo(self.currentRecipeInfo.recipeID, self.transaction:CreateCraftingReagentInfoTbl()) or nil;
	local finishingSlots = self:GetSlotsByReagentType(Enum.CraftingReagentType.Finishing);
	local hasFinishingSlots = finishingSlots ~= nil;
	if professionLearned and Professions.InLocalCraftingMode() and recipeInfo.supportsCraftingStats and ((operationInfo ~= nil and #operationInfo.bonusStats > 0) or recipeInfo.supportsQualities or hasFinishingSlots) then
		Professions.LayoutFinishingSlots(finishingSlots, self.Details.FinishingReagentSlotContainer);
		
		self.Details:SetOutputItemName(recipeInfo.name);
		self.Details.FinishingReagentSlotContainer:SetShown(hasFinishingSlots);
		self.Details:SetRecipeInfo(recipeInfo);
		
		if not self.transaction:IsRecipeType(Enum.TradeskillRecipeType.Salvage) then
			self.AllocateBestQualityCheckBox:Show();
			self.AllocateBestQualityCheckBox:SetChecked(Professions.ShouldAllocateBestQualityReagents());
		else
			self.AllocateBestQualityCheckBox:Hide();
		end

		self.Details:Show();

		self.Details:SetTransaction(self.transaction);
		self:UpdateDetailsStats();
	else
		self.AllocateBestQualityCheckBox:Hide();
		self.Details:Hide();
	end

	organizer:Layout();
end

function ProfessionsRecipeSchematicFormMixin:SetManuallyAllocated(manuallyAllocated)
	self.manuallyAllocated = manuallyAllocated;
end

function ProfessionsRecipeSchematicFormMixin:IsManuallyAllocated()
	return self.manuallyAllocated;
end

function ProfessionsRecipeSchematicFormMixin:UpdateDetailsStats()
	if self.currentRecipeInfo ~= nil and self.Details:IsShown() then
		local operationInfo = C_TradeSkillUI.GetCraftingOperationInfo(self.currentRecipeInfo.recipeID, self.transaction:CreateCraftingReagentInfoTbl());
		self.Details:SetStats(operationInfo, self.currentRecipeInfo.supportsQualities);
	end
end

function ProfessionsRecipeSchematicFormMixin:SetSelectedRecipeLevel(recipeID, recipeLevel)
	self.selectedRecipeLevels[recipeID] = recipeLevel;
end

function ProfessionsRecipeSchematicFormMixin:GetSelectedRecipeLevel(recipeID)
	return self.selectedRecipeLevels[recipeID];
end

function ProfessionsRecipeSchematicFormMixin:GetTransaction()
	return self.transaction;
end

function ProfessionsRecipeSchematicFormMixin:GetRecipeInfo()
	return self.currentRecipeInfo;
end

function ProfessionsRecipeSchematicFormMixin:SetOutputSubText(text)
	self.OutputSubText:SetText(text);
	self.OutputSubText:Show();
end

function ProfessionsRecipeSchematicFormMixin:UpdateAllSlots()
	for slot in self.reagentSlotPool:EnumerateActive() do
		slot:Update();
	end
end

function ProfessionsRecipeSchematicFormMixin:GetSlots()
	local slots = {};
	for slot in self.reagentSlotPool:EnumerateActive() do
		table.insert(slots, slot);
	end
	return slots;
end

function ProfessionsRecipeSchematicFormMixin:GetSlotsByReagentType(reagentType)
	return self.reagentSlots[reagentType];
end

function ProfessionsRecipeSchematicFormMixin:GetCurrentRecipeLevel()
	return self.currentRecipeInfo and self:GetSelectedRecipeLevel(self.currentRecipeInfo.recipeID);
end