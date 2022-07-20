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

	self:UpdateDetailsStats();
end

function ProfessionsRecipeSchematicFormMixin:OnHide()
    FrameUtil.UnregisterFrameForEvents(self, ProfessionsRecipeFormEvents);

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

	self.currentRecipeInfo = recipeInfo;

	local hasRecipe = recipeInfo ~= nil;

	for _, frame in ipairs(self.recipeInfoFrames) do
		frame:SetShown(hasRecipe);
	end

	if not hasRecipe then
		return;
	end

	local recipeID = recipeInfo.recipeID;
	self.recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, self:GetCurrentRecipeLevel());

	local function OnChanged()
		self:UpdateDetailsStats();
	end

	local function AllocateAutomatically()
		Professions.AllocateAllBasicReagents(self.transaction, Professions.ShouldAllocateBestQualityReagents());
		self:SetManuallyAllocated(false);
	end

	local newRecipe = not self.transaction or (self.transaction:GetRecipeID() ~= recipeID);
	if newRecipe then
		self.transaction = CreateProfessionsRecipeTransaction(self.recipeSchematic, OnChanged);
	end
	
	local function CanTrack(transaction)
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
	if learned and (newRecipe or not self:IsManuallyAllocated()) then
		-- Unless the allocation has been manually changed, the 'best quality reagent' option is used to
		-- auto-allocate the reagents. We can recalculate new allocations for this.
		Professions.AllocateAllBasicReagents(self.transaction, Professions.ShouldAllocateBestQualityReagents());
		self:SetManuallyAllocated(false);
	end

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
		if outputItemInfo.hyperlink then
			local item = Item:CreateFromItemLink(outputItemInfo.hyperlink);
			self.OutputText:SetText(item:GetItemName());
			self.OutputText:SetWidth(300);
			self.OutputText:SetWidth(self.OutputText:GetStringWidth());
			self.OutputText:SetTextColor(item:GetItemQualityColorRGB());
		else
			self.OutputText:SetText(self.recipeSchematic.name);
			self.OutputText:SetWidth(300);
			self.OutputText:SetWidth(self.OutputText:GetStringWidth());
			self.OutputText:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		end

		self.OutputText:SetHeight(self.OutputText:GetStringHeight());
		
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

	local requiredToolsString = BuildColoredListString(C_TradeSkillUI.GetRecipeTools(recipeID));
	if requiredToolsString then
		self.RequiredTools:SetFormattedText(PROFESSIONS_REQUIRED_TOOLS, requiredToolsString);
		self.RequiredTools:Show();
	else
		self.RequiredTools:Hide();
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
					GameTooltip:SetRecipeReagentItem(recipeID, slotIndex);
					GameTooltip:Show();
				end);
			end
		else
			local locked, lockedReason = Professions.GetReagentSlotStatus(reagentSlotSchematic, recipeInfo);
			slot.Button:SetLocked(locked);

			slot.Button:SetScript("OnEnter", function()
				GameTooltip:SetOwner(slot.Button, "ANCHOR_RIGHT");

				if locked then
					local title = (reagentType == Enum.CraftingReagentType.Finishing) and FINISHING_REAGENT_TOOLTIP_TITLE:format(reagentSlotSchematic.slotInfo.slotText) or EMPTY_OPTIONAL_REAGENT_TOOLTIP_TITLE;
					GameTooltip_SetTitle(GameTooltip, title);
					GameTooltip_AddErrorLine(GameTooltip, lockedReason);
				else
					Professions.SetupOptionalReagentTooltip(slot, recipeID, reagentType, reagentSlotSchematic.slotInfo.slotText);

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
							local function OnFlyoutItemSelected(o, flyout, item)
								if ItemUtil.GetCraftingReagentCount(item:GetItemID()) == 0 then
									return;
								end

								local reagent = Professions.CreateCraftingReagent(item:GetItemID(), nil);
								self.transaction:OverwriteAllocation(slotIndex, reagent, reagentSlotSchematic.quantityRequired);
								self:SetManuallyAllocated(true);

								slot:SetItem(item);

								self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
							end

							local itemIDs = Professions.ExtractItemIDsFromCraftingReagents(reagentSlotSchematic.reagents);
							flyout:Init(slot.Button, self.transaction, self.transaction:GetRecipeID(), itemIDs);
							flyout:RegisterCallback(ProfessionsItemFlyoutMixin.Event.ItemSelected, OnFlyoutItemSelected, slot);
						end
					elseif buttonName == "RightButton" then
						self.transaction:ClearAllocations(slotIndex);

						slot:ClearItem();

						self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
					end
				end
			end);
		end
	end
	
	local isSalvage = self.recipeSchematic.recipeType == Enum.TradeskillRecipeType.Salvage;
	if isSalvage then
		if not self.salvageSlot then
			self.salvageSlot = CreateFrame("FRAME", nil, self, "ProfessionsReagentSalvageTemplate");
			self.salvageSlot:SetPoint("TOPLEFT", 100, -100);
		end
		self.salvageSlot:Show();
		self.salvageSlot:Init(self.transaction, self.recipeSchematic.quantityMax);

		self.salvageSlot.Button:SetScript("OnMouseDown", function(button, buttonName, down)
			if buttonName == "LeftButton" then
				local flyout = ToggleProfessionsItemFlyout(self.salvageSlot.Button);
				if flyout then
					local function OnFlyoutItemSelected(o, flyout, item)
						if ItemUtil.GetCraftingReagentCount(item:GetItemID()) == 0 then
							return;
						end

						self.transaction:SetSalvageAllocation(item);
						self:SetManuallyAllocated(true);

						self.salvageSlot:SetItem(item);

						self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
					end
		
					local itemIDs = C_TradeSkillUI.GetSalvagableItemIDs(recipeID);
					flyout:Init(self.salvageSlot.Button, nilTransaction, recipeID, itemIDs);
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
	else
		self.Reagents:Hide();
	end

	-- fixme learned
	local operationInfo = C_TradeSkillUI.GetCraftingOperationInfo(self.currentRecipeInfo.recipeID, self.transaction:CreateCraftingReagentInfoTbl());
	local finishingSlots = self:GetSlotsByReagentType(Enum.CraftingReagentType.Finishing);
	local hasFinishingSlots = finishingSlots ~= nil;
	if learned and Professions.InLocalCraftingMode() and recipeInfo.supportsCraftingStats and ((operationInfo ~= nil and #operationInfo.bonusStats > 0) or recipeInfo.supportsQualities or hasFinishingSlots) then
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