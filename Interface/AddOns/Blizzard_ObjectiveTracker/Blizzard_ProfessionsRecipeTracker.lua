local function GetRecipeID(block)
	return math.abs(block.id);
end

local function IsRecraftBlock(block)
	return block.id < 0;
end

local settings = {
	headerText = PROFESSIONS_TRACKER_HEADER_PROFESSION,
	events = { "CURRENCY_DISPLAY_UPDATE", "TRACKED_RECIPE_UPDATE", "BAG_UPDATE_DELAYED" },
	blockTemplate = "ObjectiveTrackerAnimBlockTemplate",
	lineTemplate = "ObjectiveTrackerAnimLineTemplate",
};

ProfessionsRecipeTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings);

local IsRecrafting = true;

function ProfessionsRecipeTrackerMixin:OnEvent(event, ...)
	if event == "CURRENCY_DISPLAY_UPDATE" then
		self:MarkDirty();
	elseif event == "TRACKED_RECIPE_UPDATE" then
		local recipeID, added = ...;
		if added then
			self:SetNeedsFanfare(recipeID);
		end
		self:MarkDirty();
	elseif event == "BAG_UPDATE_DELAYED" then
		self:MarkDirty();
	end
end

function ProfessionsRecipeTrackerMixin:OnBlockHeaderClick(block, mouseButton)
	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		local link = C_TradeSkillUI.GetRecipeLink(GetRecipeID(block));
		if link then
			ChatEdit_InsertLink(link);
		end
	elseif mouseButton ~= "RightButton" then
		if not ProfessionsFrame then
			ProfessionsFrame_LoadUI();
		end
		if IsModifiedClick("RECIPEWATCHTOGGLE") then
			local track = false;
			C_TradeSkillUI.SetRecipeTracked(GetRecipeID(block), track, IsRecraftBlock(block));
		else
			if not IsRecraftBlock(block) then
				local recipeID = GetRecipeID(block);
				if C_TradeSkillUI.IsRecipeProfessionLearned(recipeID) then
					C_TradeSkillUI.OpenRecipe(recipeID)
				else
					Professions.InspectRecipe(recipeID);
				end
			end
		end
	else
		MenuUtil.CreateContextMenu(self:GetContextMenuParent(), function(owner, rootDescription)
			rootDescription:SetTag("MENU_PROFESSIONS_RECIPE_TRACKER");

			local recipeId = GetRecipeID(block);
			if not IsRecraftBlock(block) and IsSpellKnown(recipeId) then
				rootDescription:CreateButton(PROFESSIONS_TRACKING_VIEW_RECIPE, function()
			C_TradeSkillUI.OpenRecipe(recipeID);
				end);
	end
			rootDescription:CreateButton(PROFESSIONS_UNTRACK_RECIPE, function()
		local track = false;
				C_TradeSkillUI.SetRecipeTracked(recipeId, track, IsRecraftBlock(block));
			end);
		end);
	end
end

function ProfessionsRecipeTrackerMixin:LayoutContents()
	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end

	self.continuableContainer = ContinuableContainer:Create();
	local function LoadItems(recipes)
		for _, recipeID in ipairs(recipes) do
			local reagents = ProfessionsUtil.CreateRecipeReagentsForAllBasicReagents(recipeID);
			for reagentIndex, reagent in ipairs(reagents) do
				if reagent.itemID then
					self.continuableContainer:AddContinuable(Item:CreateFromItemID(reagent.itemID));
				end
			end
		end
	end

	-- Load regular and recraft recipe items.
	LoadItems(C_TradeSkillUI.GetRecipesTracked(IsRecrafting));
	LoadItems(C_TradeSkillUI.GetRecipesTracked(not IsRecrafting));
	
	-- We can continue to layout each of the blocks if every item is loaded, otherwise
	-- we need to wait until the items load, then notify the objective tracker to try again.
	local allLoaded = true;
	local function OnItemsLoaded()
		if allLoaded then
			if not self:AddRecipes(IsRecrafting) then
				return;
			end
			if not self:AddRecipes(not IsRecrafting) then
				return;
			end
		else
			self:MarkDirty();
		end
	end
	-- The assignment of allLoaded is only meaningful if false. If and when the callback
	-- is invoked later, it will force an update. If the value was true, the callback would have
	-- already been invoked prior to returning.
	allLoaded = self.continuableContainer:ContinueOnLoad(OnItemsLoaded);	
end

function ProfessionsRecipeTrackerMixin:AddRecipes(isRecraft)
	for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked(isRecraft)) do
		if not self:AddRecipe(recipeID, isRecraft) then
			return false;
		end
	end
	return true;
end

function ProfessionsRecipeTrackerMixin:AddRecipe(recipeID, isRecraft)
	local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft);
	local blockID = NegateIf(recipeID, isRecraft);
	local block = self:GetBlock(blockID);
	local blockName = isRecraft and PROFESSIONS_CRAFTING_FORM_RECRAFTING_HEADER:format(recipeSchematic.name) or recipeSchematic.name;
	block:SetHeader(blockName);

	local eligibleSlots = {};
	for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
		if ProfessionsUtil.IsReagentSlotRequired(reagentSlotSchematic) then
			if ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic) then
				table.insert(eligibleSlots, 1, {slotIndex = slotIndex, reagentSlotSchematic = reagentSlotSchematic});
			else
				table.insert(eligibleSlots, {slotIndex = slotIndex, reagentSlotSchematic = reagentSlotSchematic});
			end
		end
	end

	for idx, tbl in ipairs(eligibleSlots) do
		local slotIndex = tbl.slotIndex;
		local reagentSlotSchematic = tbl.reagentSlotSchematic;
		if ProfessionsUtil.IsReagentSlotRequired(reagentSlotSchematic) then
			local reagent = reagentSlotSchematic.reagents[1];
			local quantityRequired = reagentSlotSchematic.quantityRequired;
			local quantity = ProfessionsUtil.AccumulateReagentsInPossession(reagentSlotSchematic.reagents);
			local name = nil;

			if ProfessionsUtil.IsReagentSlotBasicRequired(reagentSlotSchematic) then
				if reagent.itemID then
					local item = Item:CreateFromItemID(reagent.itemID);
					name = item:GetItemName();
				elseif reagent.currencyID then
					local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reagent.currencyID);
					if currencyInfo then
						name = currencyInfo.name;
					end
				end
			elseif ProfessionsUtil.IsReagentSlotModifyingRequired(reagentSlotSchematic) then
				if reagentSlotSchematic.slotInfo then
					name = reagentSlotSchematic.slotInfo.slotText;
				end
			end

			if name then
				local text = PROFESSIONS_TRACKER_REAGENT_FORMAT:format(PROFESSIONS_TRACKER_REAGENT_COUNT_FORMAT:format(quantity, quantityRequired), name)
				local metQuantity = quantity >= quantityRequired;
				local dashStyle = metQuantity and OBJECTIVE_DASH_STYLE_HIDE or OBJECTIVE_DASH_STYLE_SHOW;
				local colorStyle = OBJECTIVE_TRACKER_COLOR[metQuantity and "Complete" or "Normal"];
				local line = block:AddObjective(slotIndex, text, nil, nil, dashStyle, colorStyle);				
				line.Icon:SetShown(metQuantity);
			end
		end
	end
	
	return self:LayoutBlock(block);
end