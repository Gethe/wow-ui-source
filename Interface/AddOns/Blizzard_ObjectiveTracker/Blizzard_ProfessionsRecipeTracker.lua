PROFESSION_RECIPE_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable("PROFESSION_RECIPE_TRACKER_MODULE");
PROFESSION_RECIPE_TRACKER_MODULE.updateReasonModule = OBJECTIVE_TRACKER_UPDATE_MODULE_PROFESSION_RECIPE;
PROFESSION_RECIPE_TRACKER_MODULE:SetHeader(ObjectiveTrackerFrame.BlocksFrame.ProfessionHeader, PROFESSIONS_TRACKER_HEADER_PROFESSION);

-- *****************************************************************************************************
-- ***** BLOCK DROPDOWN FUNCTIONS
-- *****************************************************************************************************

local function RecipeObjectiveTracker_OnOpenDropDown(self)
	local block = self.activeFrame;
	
	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;
	
	info.text = PROFESSIONS_TRACKING_VIEW_RECIPE;
	info.func = function()
		C_TradeSkillUI.OpenRecipe(block.id);
	end;
	info.arg1 = block.id;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	
	info.text = PROFESSIONS_UNTRACK_RECIPE;
	info.func = function()
		C_TradeSkillUI.SetRecipeTracked(block.id, false);
	end;
	info.arg1 = block.id;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
end

function PROFESSION_RECIPE_TRACKER_MODULE:OnBlockHeaderClick(block, mouseButton)
	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		local link = C_TradeSkillUI.GetRecipeLink(block.id);
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	elseif ( mouseButton ~= "RightButton" ) then
		CloseDropDownMenus();
		if ( not ProfessionsFrame ) then
			ProfessionsFrame_LoadUI();
		end
		if ( IsModifiedClick("RECIPEWATCHTOGGLE") ) then
			C_TradeSkillUI.SetRecipeTracked(block.id, false);
		else
			C_TradeSkillUI.OpenRecipe(block.id);
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
	for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked()) do
		local itemIDs = Professions.CreateRecipeItemIDsForAllBasicReagents(recipeID);
		for _, item in ipairs(ItemUtil.TransformItemIDsToItems(itemIDs)) do
			self.continuableContainer:AddContinuable(item);
		end
	end
	local function Layout()
		local colorStyle = OBJECTIVE_TRACKER_COLOR["Normal"];
		local isRecraft = false;

		for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked()) do
			local recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft);
			local block = self:GetBlock(recipeID);
			self:SetBlockHeader(block, recipeSchematic.name);

			for slotIndex, reagentSlotSchematic in ipairs(recipeSchematic.reagentSlotSchematics) do
				if reagentSlotSchematic.reagentType == Enum.CraftingReagentType.Basic then
					local reagent = reagentSlotSchematic.reagents[1];
					if reagent.itemID then
						local item = Item:CreateFromItemID(reagent.itemID);
						local itemName = item:GetItemName();
						local quantity = Professions.AccumulateReagentsInPossession(reagentSlotSchematic.reagents);
						local quantityRequired = reagentSlotSchematic.quantityRequired;
						local text = PROFESSIONS_TRACKER_REAGENT_FORMAT:format(PROFESSIONS_TRACKER_REAGENT_COUNT_FORMAT:format(quantity, quantityRequired), itemName)
						
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
	local function GetAllBasicReagentItemIDs()
		local itemIDs = {};
		for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked()) do
			for _, itemID in ipairs(Professions.CreateRecipeItemIDsForAllBasicReagents(recipeID)) do
				table.insert(itemIDs, itemID);	
			end
		end
		return itemIDs;
	end

	local itemIDs = GetAllBasicReagentItemIDs();

	local function OnItemCountChanged(o, itemID)
		if tContains(itemIDs, itemID) then
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_PROFESSION_RECIPE);
		end
	end
	EventRegistry:RegisterFrameEvent("ITEM_COUNT_CHANGED");
	EventRegistry:RegisterCallback("ITEM_COUNT_CHANGED", OnItemCountChanged, PROFESSION_RECIPE_TRACKER_MODULE);

	local function OnTrackedRecipeUpdate(o, recipeID, tracked)
		itemIDs = GetAllBasicReagentItemIDs();
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_PROFESSION_RECIPE);
	end

	EventRegistry:RegisterFrameEvent("TRACKED_RECIPE_UPDATE");
	EventRegistry:RegisterCallback("TRACKED_RECIPE_UPDATE", OnTrackedRecipeUpdate, PROFESSION_RECIPE_TRACKER_MODULE);

	local function OnSkillLinesChanged(o)
		for _, recipeID in ipairs(C_TradeSkillUI.GetRecipesTracked()) do
			if not C_TradeSkillUI.IsRecipeProfessionLearned(recipeID) then
				C_TradeSkillUI.SetRecipeTracked(recipeID, false);
			end
		end
	end
	EventRegistry:RegisterFrameEvent("SKILL_LINES_CHANGED");
	EventRegistry:RegisterCallback("SKILL_LINES_CHANGED", OnSkillLinesChanged, PROFESSION_RECIPE_TRACKER_MODULE);
end