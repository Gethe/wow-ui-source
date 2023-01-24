PROFESSION_RECIPE_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable("PROFESSION_RECIPE_TRACKER_MODULE");
PROFESSION_RECIPE_TRACKER_MODULE.updateReasonModule = OBJECTIVE_TRACKER_UPDATE_MODULE_PROFESSION_RECIPE;
PROFESSION_RECIPE_TRACKER_MODULE:SetHeader(ObjectiveTrackerFrame.BlocksFrame.ProfessionHeader, PROFESSIONS_TRACKER_HEADER_PROFESSION);

local IsRecrafting = true;

-- *****************************************************************************************************
-- ***** BLOCK DROPDOWN FUNCTIONS
-- *****************************************************************************************************

local function GetRecipeID(block)
	return math.abs(block.id);
end

local function IsRecraftBlock(block)
	return block.id < 0;
end

local function RecipeObjectiveTracker_OnOpenDropDown(self)
	local block = self.activeFrame;
	
	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;
	
	if not IsRecraftBlock(block) and IsSpellKnown(GetRecipeID(block)) then
		info.text = PROFESSIONS_TRACKING_VIEW_RECIPE;
		info.func = function()
			C_TradeSkillUI.OpenRecipe(recipeID);
		end;
		info.arg1 = block.id;
		info.checked = false;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end
	
	info.text = PROFESSIONS_UNTRACK_RECIPE;
	info.func = function()
		local track = false;
		C_TradeSkillUI.SetRecipeTracked(GetRecipeID(block), track, IsRecraftBlock(block));
	end;
	info.arg1 = block.id;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
end

function PROFESSION_RECIPE_TRACKER_MODULE:OnBlockHeaderClick(block, mouseButton)
	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		local link = C_TradeSkillUI.GetRecipeLink(GetRecipeID(block));
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	elseif ( mouseButton ~= "RightButton" ) then
		CloseDropDownMenus();
		if ( not ProfessionsFrame ) then
			ProfessionsFrame_LoadUI();
		end
		if ( IsModifiedClick("RECIPEWATCHTOGGLE") ) then
			local track = false;
			C_TradeSkillUI.SetRecipeTracked(GetRecipeID(block), track, IsRecraftBlock(block));
		else
			if not IsRecraftBlock(block) then
				C_TradeSkillUI.OpenRecipe(GetRecipeID(block));
			end
		end
	else
		ObjectiveTracker_ToggleDropDown(block, RecipeObjectiveTracker_OnOpenDropDown);
	end
end

-- *****************************************************************************************************
-- ***** UPDATE FUNCTIONS
-- *****************************************************************************************************
local LINE_TYPE_ANIM = { template = "QuestObjectiveAnimLineTemplate", freeLines = { } };

function PROFESSION_RECIPE_TRACKER_MODULE:Update()
	self:BeginLayout();

	if self.continuableContainer then
		self.continuableContainer:Cancel();
	end

	self.continuableContainer = ContinuableContainer:Create();
	local function LoadItems(recipes)
		for _, recipeID in ipairs(recipes) do
			local reagents = Professions.CreateRecipeReagentsForAllBasicReagents(recipeID);
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

	local function Layout()
		local colorStyle = OBJECTIVE_TRACKER_COLOR["Normal"];

		local function AddObjectives(isRecraft)
			for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked(isRecraft)) do
				local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft);
				local blockID = NegateIf(recipeID, isRecraft);
				local block = self:GetBlock(blockID);
				local blockName = isRecraft and PROFESSIONS_CRAFTING_FORM_RECRAFTING_HEADER:format(recipeSchematic.name) or recipeSchematic.name;
				self:SetBlockHeader(block, blockName);

				for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
					if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic then
						local reagent = reagentSlotSchematic.reagents[1];
						local quantityRequired = reagentSlotSchematic.quantityRequired;
						local quantity = Professions.AccumulateReagentsInPossession(reagentSlotSchematic.reagents);
						local name = nil;
						if reagent.itemID then
							local item = Item:CreateFromItemID(reagent.itemID);
							name = item:GetItemName();
						elseif reagent.currencyID then
							local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(reagent.currencyID);
							if currencyInfo then
								name = currencyInfo.name;
							end
						end

						if name then
							local text = PROFESSIONS_TRACKER_REAGENT_FORMAT:format(PROFESSIONS_TRACKER_REAGENT_COUNT_FORMAT:format(quantity, quantityRequired), name)
							local metQuantity = quantity >= quantityRequired;
							local dashStyle = metQuantity and OBJECTIVE_DASH_STYLE_HIDE or OBJECTIVE_DASH_STYLE_SHOW;
							local colorStyle = OBJECTIVE_TRACKER_COLOR[metQuantity and "Complete" or "Normal"];
							line = self:AddObjective(block, slotIndex, text, LINE_TYPE_ANIM, nil, dashStyle, colorStyle);
							line.Check:SetShown(metQuantity);
						end
					end
				end

				block:SetHeight(block.height);

				if ( ObjectiveTracker_AddBlock(block) ) then
					block:Show();
					self:FreeUnusedLines(block);
				else
					block.used = false;
					break;
				end
			end
		end

		AddObjectives(IsRecrafting);
		AddObjectives(not IsRecrafting);
	end

	-- We can continue to layout each of the blocks if every item is loaded, otherwise
	-- we need to wait until the items load, then notify the objective tracker to try again.
	local allLoaded = true;
	local function OnItemsLoaded()
		if allLoaded then
			Layout();
		else
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_PROFESSION_RECIPE);
		end
	end
	-- The assignment of allLoaded is only meaningful if false. If and when the callback
	-- is invoked later, it will force an update. If the value was true, the callback would have
	-- already been invoked prior to returning.
	allLoaded = self.continuableContainer:ContinueOnLoad(OnItemsLoaded);

	self:EndLayout();
end

function ProfessionsRecipeTracking_Initialize()
	local function GetAllBasicReagentIDs()
		local currencyIDs = {};
		local itemIDs = {};
		local function AddIDs(isRecraft)
			for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked(isRecraft)) do
				for _, reagent in ipairs(Professions.CreateRecipeReagentsForAllBasicReagents(recipeID)) do
					if reagent.itemID then
						table.insert(itemIDs, reagent.itemID);	
					elseif reagent.currencyID then
						table.insert(currencyIDs, reagent.currencyID);	
					end
				end
			end
		end

		AddIDs(IsRecrafting);
		AddIDs(not IsRecrafting);
		return itemIDs, currencyIDs;
	end

	-- itemIDs and currencyIDs captured by OnItemCountChanged will be updated by OnTrackedRecipeUpdate below.
	local itemIDs, currencyIDs = GetAllBasicReagentIDs();

	local function OnItemCountChanged(o, itemID)
		if tContains(itemIDs, itemID) then
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_PROFESSION_RECIPE);
		end
	end
	EventRegistry:RegisterFrameEvent("ITEM_COUNT_CHANGED");
	EventRegistry:RegisterCallback("ITEM_COUNT_CHANGED", OnItemCountChanged, PROFESSION_RECIPE_TRACKER_MODULE);

	local function OnCurrencyChanged(o, currencyID)
		if tContains(currencyIDs, currencyID) then
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_PROFESSION_RECIPE);
		end
	end
	EventRegistry:RegisterFrameEvent("CURRENCY_DISPLAY_UPDATE");
	EventRegistry:RegisterCallback("CURRENCY_DISPLAY_UPDATE", OnCurrencyChanged, PROFESSION_RECIPE_TRACKER_MODULE);

	local function OnTrackedRecipeUpdate(o, recipeID, tracked)
		itemIDs, currencyIDs = GetAllBasicReagentIDs();
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_PROFESSION_RECIPE);
	end

	EventRegistry:RegisterFrameEvent("TRACKED_RECIPE_UPDATE");
	EventRegistry:RegisterCallback("TRACKED_RECIPE_UPDATE", OnTrackedRecipeUpdate, PROFESSION_RECIPE_TRACKER_MODULE);

	local function UntrackRecipeIfUnlearned(isRecraft)
		for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked(isRecraft)) do
			if not C_TradeSkillUI.IsRecipeProfessionLearned(recipeID) then
				local track = false;
				C_TradeSkillUI.SetRecipeTracked(recipeID, track, isRecraft);
			end
		end
	end

	local function OnSkillLinesChanged(o)
		UntrackRecipeIfUnlearned(IsRecrafting);
		UntrackRecipeIfUnlearned(not IsRecrafting);
	end
	EventRegistry:RegisterFrameEvent("SKILL_LINES_CHANGED");
	EventRegistry:RegisterCallback("SKILL_LINES_CHANGED", OnSkillLinesChanged, PROFESSION_RECIPE_TRACKER_MODULE);
end