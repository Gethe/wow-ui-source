PROFESSIONS_SCHEMATIC_REAGENTS_Y_OFFSET = 0; -- Extra space for localization.

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

local LayoutEntry = EnumUtil.MakeEnum("Cooldown", "Description", "Source", "FirstCraftBonus");

local function CreateVerticalLayoutOrganizer(anchor, xPadding, yPadding)
	local OrganizerMixin = {entries = {}};

	xPadding = xPadding or 0;
	yPadding = yPadding or 0;

	function OrganizerMixin:Add(frame, order, xPadding, yPadding)
		table.insert(self.entries, {
			frame = frame, 
			order = order, 
			xPadding = xPadding or 0,
			yPadding = yPadding or 0,
		});
	end

	function OrganizerMixin:Layout()
		table.sort(self.entries, function(lhs, rhs)
			return lhs.order < rhs.order;
		end);

		local relative = nil;
		for index, entry in ipairs(self.entries) do
			entry.frame:ClearAllPoints();

			if relative then
				local x = xPadding + entry.xPadding;
				local y = -(yPadding + entry.yPadding);
				entry.frame:SetPoint("TOPLEFT", relative, "BOTTOMLEFT", x, y);
			else
				entry.frame:SetPoint(anchor:Get());
			end
			relative = entry.frame;
		end
	end

	return CreateFromMixins(OrganizerMixin);
end

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
	"CRAFTING_DETAILS_UPDATE",
};

function ProfessionsRecipeSchematicFormMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.elapsed = 0;
	self.extraSlotFrames = {};

	local function PoolReset(pool, slot)
		slot:Reset();
		slot.Button:SetScript("OnEnter", nil);
		slot.Button:SetScript("OnClick", nil);
		slot.Button:SetScript("OnMouseDown", nil);
		FramePool_HideAndClearAnchors(pool, slot);
	end

	self.reagentSlotPool = CreateFramePool("FRAME", self, "ProfessionsReagentSlotTemplate", PoolReset);
	self.selectedRecipeLevels = {};

	self.RecraftingRequiredTools:SetPoint("TOPLEFT", self.RecraftingOutputText, "BOTTOMLEFT", 0, -4);

	self.AllocateBestQualityCheckBox.text:SetText(LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(PROFESSIONS_USE_BEST_QUALITY_REAGENTS));
	self.AllocateBestQualityCheckBox:SetScript("OnClick", function(button, buttonName, down)
		local checked = button:GetChecked();
		Professions.SetShouldAllocateBestQualityReagents(checked);

		self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.UseBestQualityModified, checked);
		
		self:UpdateAllSlots();

		-- Trick to re-fire the OnEnter script to update the tooltip.
		self.AllocateBestQualityCheckBox:Hide();
		self.AllocateBestQualityCheckBox:Show();
		PlaySound(SOUNDKIT.UI_PROFESSION_USE_BEST_REAGENTS_CHECKBOX);
	end);

	self.AllocateBestQualityCheckBox:SetScript("OnEnter", function(button)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		local checked = button:GetChecked();
		if checked then
			GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_USE_LOWEST_QUALITY_REAGENTS);
		else
			GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_USE_HIGHEST_QUALITY_REAGENTS);
		end
		GameTooltip:Show();
	end);
	self.AllocateBestQualityCheckBox:SetScript("OnLeave", GameTooltip_Hide);

	self.TrackRecipeCheckBox.text:SetText(LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(PROFESSIONS_TRACK_RECIPE));
	self.TrackRecipeCheckBox:SetPoint("TOPRIGHT", -(self.TrackRecipeCheckBox.text:GetStringWidth() + 20), -16);
	self.TrackRecipeCheckBox:SetScript("OnClick", function(button, buttonName, down)
		local currentRecipeInfo = self:GetRecipeInfo();
		local checked = button:GetChecked();
		C_TradeSkillUI.SetRecipeTracked(currentRecipeInfo.recipeID, checked);
		PlaySound(SOUNDKIT.UI_PROFESSION_TRACK_RECIPE_CHECKBOX);
	end);

	self.RecipeLevelBar:SetPoint("TOPLEFT", self.OutputText, "TOPRIGHT", 57, 0);

	self.Stars:SetPoint("TOPLEFT", self.OutputText, "TOPLEFT", 0, -15);
	self.Stars:SetScript("OnLeave", GameTooltip_Hide);

	self.RecipeLevelSelector:SetSelectorCallback(function(recipeInfo, level)
		self:SetSelectedRecipeLevel(recipeInfo.recipeID, level);
		self:Init(recipeInfo);
	end);

	self.statsChangedHandler = GenerateClosure(self.OnAllocationsChanged, self);
	
	local function SetFavoriteTooltip(button)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		GameTooltip_AddHighlightLine(GameTooltip, button:GetChecked() and BATTLE_PET_UNFAVORITE or BATTLE_PET_FAVORITE);
		GameTooltip:Show();
	end

	self.FavoriteButton:SetScript("OnClick", function(button, buttonName, down)
		local checked = button:GetChecked();
		local currentRecipeInfo = self:GetRecipeInfo();
		C_TradeSkillUI.SetRecipeFavorite(currentRecipeInfo.recipeID, checked);

		self.FavoriteButton:SetIsFavorite(checked);
		PlaySound(SOUNDKIT.UI_PROFESSION_TRACK_RECIPE_CHECKBOX);

		SetFavoriteTooltip(button);
	end);

	self.FavoriteButton:SetScript("OnEnter", function(button)
		SetFavoriteTooltip(button);
	end);

	self.FavoriteButton:SetScript("OnLeave", GameTooltip_Hide);

	self.FirstCraftBonus:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.FirstCraftBonus, "ANCHOR_RIGHT");
		GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_FIRST_CRAFT_DESCRIPTION);
		GameTooltip:Show();
	end);
end

function ProfessionsRecipeSchematicFormMixin:OnShow()
    FrameUtil.RegisterFrameForEvents(self, ProfessionsRecipeFormEvents);

	local recipeInfo = self:GetRecipeInfo();
	if recipeInfo then
		-- Details, including optional reagent unlocks, may have changed due to purchasing specialization points
		self:Init(recipeInfo, self.isRecraftOverride);
		self:UpdateDetailsStats();
	end

	self.canUpdate = true;
end

function ProfessionsRecipeSchematicFormMixin:OnHide()
    FrameUtil.UnregisterFrameForEvents(self, ProfessionsRecipeFormEvents);

	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);

	self.QualityDialog:Close();
	self.canUpdate = false;
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
	elseif event == "CRAFTING_DETAILS_UPDATE" then
		self:UpdateDetailsStats();
	end
end

local UpdateInterval = .75;
function ProfessionsRecipeSchematicFormMixin:OnUpdate(dt)
	if self.canUpdate and (self.UpdateCooldown or self.UpdateRequiredTools) then
		self.elapsed = self.elapsed - dt;
		if self.elapsed <= 0 then
			self.elapsed = UpdateInterval;

			if self.UpdateCooldown then
				self.UpdateCooldown();
			end

			if self.UpdateRequiredTools then
				self.UpdateRequiredTools();
			end
		end
	end
end

function ProfessionsRecipeSchematicFormMixin:Refresh()
	local recipeInfo = self:GetRecipeInfo();
	if recipeInfo then
		-- Details may have changed due to purchasing specialization points
		self:Init(recipeInfo);
		self:UpdateDetailsStats();
	end
end

function ProfessionsRecipeSchematicFormMixin:GetRecipeOperationInfo()
	local recipeInfo = self.currentRecipeInfo;
	if recipeInfo then
		if self.recipeSchematic.hasGatheringOperationInfo then
			return C_TradeSkillUI.GetGatheringOperationInfo(recipeInfo.recipeID);
		elseif self.recipeSchematic.hasCraftingOperationInfo then
			local recraftItemGUID, recraftOrderID = self.transaction:GetRecraftAllocation();
			if recraftOrderID then
				return C_TradeSkillUI.GetCraftingOperationInfoForOrder(recipeInfo.recipeID, self.transaction:CreateCraftingReagentInfoTbl(), recraftOrderID);
			else
				return C_TradeSkillUI.GetCraftingOperationInfo(recipeInfo.recipeID, self.transaction:CreateCraftingReagentInfoTbl(), self.transaction:GetAllocationItemGUID());
			end
		end
		end
	end

function ProfessionsRecipeSchematicFormMixin:ClearTransaction()
	self.transaction = nil;
end

local RequirementTypeToString =
{
	[Enum.RecipeRequirementType.SpellFocus] = "SpellFocusRequirement",
	[Enum.RecipeRequirementType.Totem] = "TotemRequirement",
	[Enum.RecipeRequirementType.Area] = "AreaRequirement",
};
local StringToRequirementType = tInvert(RequirementTypeToString);

local function FormatRequirements(requirements)
	local formattedRequirements = {};
	for index, recipeRequirement in ipairs(requirements) do
		table.insert(formattedRequirements, LinkUtil.FormatLink(RequirementTypeToString[recipeRequirement.type], recipeRequirement.name));
		table.insert(formattedRequirements, recipeRequirement.met);
	end
	return formattedRequirements;
end

function ProfessionsRecipeSchematicFormMixin:Init(recipeInfo, isRecraftOverride)
	local xPadding = 0;
	local yPadding = 4;
	local anchor = AnchorUtil.CreateAnchor("TOPLEFT", self.OutputIcon, "BOTTOMLEFT", -1, -12);
	local organizer = CreateVerticalLayoutOrganizer(anchor, xPadding, yPadding);

	self.UpdateRequiredTools = nil;
	self.UpdateCooldown = nil;

	self.OutputIcon:Hide();
	self.OutputText:Hide();
	self.OutputSubText:Hide();
	self.Description:Hide();
	self.RecraftingDescription:Hide();
	self.RequiredTools:Hide();
	self.RecraftingRequiredTools:Hide();
	self.RecraftingOutputText:Hide();
	self.Stars:SetScript("OnEnter", nil);
	self.Stars:Hide();
	self.RecipeLevelBar:Hide();
	self.RecipeLevelSelector:Hide();
	self.Cooldown:Hide();
	self.Cooldown:SetText("");
	self.RecipeSourceButton:Hide();
	self.FirstCraftBonus:Hide();
	self.FavoriteButton:Hide();
	self.TrackRecipeCheckBox:Hide();
	self.AllocateBestQualityCheckBox:Hide();
	self.Reagents:Hide();
	self.OptionalReagents:Hide();
	self.Details:Hide();

	self.currentRecipeInfo = recipeInfo;

	local hasRecipe = recipeInfo ~= nil;

	for _, frame in ipairs(self.extraSlotFrames) do
		frame:SetShown(false);
	end

	if not hasRecipe then
		self.Details:CancelAllAnims();
		return;
	end

	local recipeID = recipeInfo.recipeID;
	local isRecipeInfoRecraft = recipeInfo.isRecraft;
	local isRecraft = isRecraftOverride;
	if isRecraft == nil then
		isRecraft = isRecipeInfoRecraft;
	end
	self.isRecraftOverride = isRecraftOverride;

	local recraftTransitionData = Professions.GetRecraftingTransitionData();
	if recraftTransitionData and isRecraftOverride == nil then
		isRecraft = true;
	end

	local newTransaction = not self.transaction or (self.transaction:GetRecipeID() ~= recipeID);
	if not newTransaction and (self.transaction and self.transaction:IsRecraft()) and isRecraftOverride == nil then
		isRecraft = true;
	end
	
	if newTransaction then
		self.QualityDialog:Close();
	end

	ItemButtonUtil.TriggerEvent(ItemButtonUtil.Event.ItemContextChanged);

	self.RecraftingDescription:SetShown(isRecipeInfoRecraft);

	if isRecraft then
		self.RecraftingOutputText:Show();
	else
		self.OutputIcon:Show();
		self.OutputText:Show();
	end

	local showFavoriteButton = self.canShowFavoriteButton and recipeInfo.learned and not isRecraft;
	self.FavoriteButton:SetShown(showFavoriteButton);
	if showFavoriteButton then
		local isFavorite = C_TradeSkillUI.IsRecipeFavorite(recipeID);
		self.FavoriteButton:SetChecked(isFavorite);
		self.FavoriteButton:SetIsFavorite(isFavorite);

		self.FavoriteButton:ClearAllPoints();
		self.FavoriteButton:SetPoint("LEFT", self.OutputText, "RIGHT", 4, 1);
	end

	self.recipeSchematic = C_TradeSkillUI.GetRecipeSchematic(recipeID, isRecraft, self:GetCurrentRecipeLevel());
	local isSalvage = self.recipeSchematic.recipeType == Enum.TradeskillRecipeType.Salvage;

	if newTransaction then
		self.transaction = CreateProfessionsRecipeTransaction(self.recipeSchematic);
		self.transaction:SetRecraft(isRecraft);
	else
		-- Remove allocation handlers while we're initializing the form
		-- otherwise we're going to flood the details stats panel with
		-- irrelevant events. Altrnatively, the details panel could
		-- defer handling the changed event until end of frame, but it
		-- would first need to be guaranteed that no state is accessed
		-- off the details frame that would not have been set as expected.
		self.transaction:SetAllocationsChangedHandler(nil);
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

		if newTransaction then
			for slotIndex, reagentSlotSchematic in ipairs(self.recipeSchematic.reagentSlotSchematics) do
				if reagentSlotSchematic.dataSlotType == Enum.TradeskillSlotDataType.ModifiedReagent then
					AllocateModification(slotIndex, reagentSlotSchematic);
				end
			end
		end
	end

	self.TrackRecipeCheckBox:SetShown(not isRecraft and self.showTrackRecipe and Professions.CanTrackRecipe(recipeInfo));
	self.TrackRecipeCheckBox:SetChecked(C_TradeSkillUI.IsRecipeTracked(recipeInfo.recipeID));

	if newTransaction or not self.transaction:IsManuallyAllocated() then
		self.transaction:SanitizeOptionalAllocations();
		-- Unless the allocation has been manually changed, the 'best quality reagent' option is used to
		-- auto-allocate the reagents.
		Professions.AllocateAllBasicReagents(self.transaction, Professions.ShouldAllocateBestQualityReagents());
	else
		-- We still need to sanitize the transaction to remove allocations we no longer have even if
		-- we're manually allocating. When we run out of a reagent, we expect the allocation to be
		-- removed.
		self.transaction:SanitizeAllocations();
	end

	-- Verifies that targets are still valid, and that the item modifications
	-- for the item are updated if a recraft target.
	self.transaction:SanitizeTargetAllocations();

	if self.QualityDialog:IsShown() then
		local slotIndex = self.QualityDialog:GetSlotIndex();
		local allocationsCopy = self.transaction:GetAllocationsCopy(slotIndex);
		self.QualityDialog:ReinitAllocations(allocationsCopy);
	end

	local function UpdateCooldown()
		local cooldown, isDayCooldown, charges, maxCharges = C_TradeSkillUI.GetRecipeCooldown(recipeID);
		if maxCharges and charges and maxCharges > 0 and (charges > 0 or not cooldown) then
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
	end

	UpdateCooldown();

	local cooldownText = self.Cooldown:GetText();
	if cooldownText and cooldownText ~= "" then
		self.Cooldown:Show();
		organizer:Add(self.Cooldown, LayoutEntry.Cooldown);
		self.UpdateCooldown = UpdateCooldown;
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
		organizer:Add(self.RecipeSourceButton, LayoutEntry.Source, 0, 10);
	end

	if recipeInfo.learned and not self.RecipeSourceButton:IsVisible() and recipeInfo.firstCraft and not isRecraft then
		self.FirstCraftBonus:Show();
		organizer:Add(self.FirstCraftBonus, LayoutEntry.FirstCraftBonus, 0, 10);
	end

	if self.loader then
		self.loader:Cancel();
	end
	self.loader = CreateProfessionsRecipeLoader(self.recipeSchematic, function()
		local reagents = self.transaction:CreateCraftingReagentInfoTbl();

		if not isRecraft then
			local firstRecipeInfo = Professions.GetFirstRecipe(recipeInfo);
			if not firstRecipeInfo then
				return;
			end
			local spell = Spell:CreateFromSpellID(firstRecipeInfo.recipeID);
			local description = C_TradeSkillUI.GetRecipeDescription(spell:GetSpellID(), reagents, self.transaction:GetAllocationItemGUID());
			if description and description ~= "" then
				self.Description:SetText(description);
				self.Description:SetHeight(600);
				self.Description:SetHeight(self.Description:GetStringHeight() + 1);
				self.Description:Show();
			else
				self.Description:SetText("");
				self.Description:SetHeight(1);
			end
			organizer:Add(self.Description, LayoutEntry.Description, 0, 5);
			
			organizer:Layout();
		end

		local outputItemInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, reagents, self.transaction:GetAllocationItemGUID());
		local text;
		if outputItemInfo.hyperlink then
			local item = Item:CreateFromItemLink(outputItemInfo.hyperlink);
			text = WrapTextInColor(item:GetItemName(), item:GetItemQualityColor().color);
		else
			text = WrapTextInColor(self.recipeSchematic.name, NORMAL_FONT_COLOR);
		end
		
		local function SetOutputText(fontString, text)
			fontString:SetText(text);
			fontString:SetWidth(800);
			fontString:SetWidth(fontString:GetStringWidth());
			fontString:SetHeight(fontString:GetStringHeight());
		end

		if isRecipeInfoRecraft then
			SetOutputText(self.RecraftingOutputText, PROFESSIONS_CRAFTING_RECRAFTING);
		elseif isRecraft then
			SetOutputText(self.RecraftingOutputText, PROFESSIONS_CRAFTING_FORM_RECRAFTING_HEADER:format(text));
		else
			SetOutputText(self.OutputText, text);
		end

		Professions.SetupOutputIcon(self.OutputIcon, self.transaction, outputItemInfo);
		self.OutputIcon.Count:SetShown(not recipeInfo.isGatheringRecipe);
	end);

	self.OutputIcon:SetScript("OnEnter", function()
		GameTooltip:SetOwner(self.OutputIcon, "ANCHOR_RIGHT");
		local reagents = self.transaction:CreateCraftingReagentInfoTbl();

		self.OutputIcon:SetScript("OnUpdate", function() 
			GameTooltip:SetRecipeResultItem(self.recipeSchematic.recipeID, reagents, self.transaction:GetAllocationItemGUID(), self:GetCurrentRecipeLevel());
		end);

	end);
	self.OutputIcon:SetScript("OnLeave", function()
		GameTooltip_Hide(); 
		self.OutputIcon:SetScript("OnUpdate", nil);
	end);

	self.OutputIcon:SetScript("OnClick", function()
		local outputItemInfo = C_TradeSkillUI.GetRecipeOutputItemData(recipeID, self.transaction:CreateCraftingReagentInfoTbl(), self.transaction:GetAllocationItemGUID());
		HandleModifiedItemClick(outputItemInfo.hyperlink);
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
		self.RecraftingRequiredTools:Hide();
		self.RequiredTools:Hide();

		if #C_TradeSkillUI.GetRecipeRequirements(recipeID) > 0 then
			local fontString = isRecraft and self.RecraftingRequiredTools or self.RequiredTools;
			fontString:Show();
			
			self.UpdateRequiredTools = function()
				-- Requirements need to be fetched on every update because it contains the updated
				-- .met field that we need to colorize the string correctly.
				assertsafe(recipeID == self.currentRecipeInfo.recipeID, ("Mismatch between captured recipeID '%s' and frame self.currentRecipeInfo.recipeID '%s'"):format(tostring(recipeID), tostring(self.currentRecipeInfo.recipeID)));
				local requirements = C_TradeSkillUI.GetRecipeRequirements(recipeID);
				if (#requirements > 0) then
					local requirementsText = BuildColoredListString(unpack(FormatRequirements(requirements)));
					fontString:SetText(PROFESSIONS_REQUIRED_TOOLS:format(requirementsText));
				else
					fontString:SetText("");
				end
			end

			self.UpdateRequiredTools();
		end

		if self.Stars:IsShown() then
			self.RequiredTools:SetPoint("TOPLEFT", self.OutputText, "BOTTOMLEFT", 0, -20);
		else
			self.RequiredTools:SetPoint("TOPLEFT", self.OutputText, "BOTTOMLEFT", 0, -4);
		end
	end

	self.reagentSlotPool:ReleaseAll();
	self.reagentSlots = {};
	self.Reagents:Show();
	self.OptionalReagents:Show();

	local slotParents =
	{
		[Enum.CraftingReagentType.Basic] = self.Reagents, 
		[Enum.CraftingReagentType.Optional] = self.OptionalReagents,
		[Enum.CraftingReagentType.Finishing] = self.Details.FinishingReagentSlotContainer,
	};

	if isRecraft then
		if not self.recraftSlot then
			self.recraftSlot = CreateFrame("FRAME", nil, self, "ProfessionsRecraftSlotTemplate");
			self.recraftSlot:SetPoint("TOPLEFT", self.RecraftingOutputText, "BOTTOMLEFT", 0, -30);
			table.insert(self.extraSlotFrames, self.recraftSlot);
		end
		self.recraftSlot:Show();
		self.recraftSlot:Init(self.transaction);

		self.recraftSlot.InputSlot:SetScript("OnMouseDown", function(button, buttonName, down)
			if buttonName == "LeftButton" then
				local flyout = ToggleProfessionsItemFlyout(self.recraftSlot.InputSlot, ProfessionsFrame);
				if flyout then
					local function OnFlyoutItemSelected(o, flyout, elementData)
						Professions.TransitionToRecraft(elementData.itemGUID);
						
						local itemLocation = C_Item.GetItemLocation(elementData.itemGUID);
						C_Sound.PlayItemSound(Enum.ItemSoundType.Drop, itemLocation);
					end
		
					flyout.GetElementsImplementation = function(self)
						local itemGUIDs = C_TradeSkillUI.GetRecraftItems(recipeID);
						local items = ItemUtil.TransformItemGUIDsToItems(itemGUIDs);
						local elementData = {items = items, itemGUIDs = itemGUIDs};
						return elementData;
					end

					flyout.OnElementEnterImplementation = function(elementData, tooltip)
						tooltip:SetItemByGUID(elementData.itemGUID);

						local learned = C_TradeSkillUI.IsOriginalCraftRecipeLearned(elementData.itemGUID);
						if not learned then
							GameTooltip_AddBlankLineToTooltip(tooltip);
							GameTooltip_AddErrorLine(tooltip, PROFESSIONS_ITEM_RECRAFT_UNLEARNED);
						end
					end
					
					flyout.OnElementEnabledImplementation = function(button, elementData)
						return C_TradeSkillUI.IsOriginalCraftRecipeLearned(elementData.itemGUID);
					end

					local canModifyFilter = false;
					flyout:Init(self.recraftSlot.InputSlot, self.transaction, canModifyFilter);
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

				local reagents = self.transaction:CreateCraftingReagentInfoTbl();
				GameTooltip:SetRecipeResultItem(self.recipeSchematic.recipeID, reagents, self.transaction:GetRecraftAllocation(), self:GetCurrentRecipeLevel());
			end
		end);
	end

	if isRecipeInfoRecraft then
		self.RecraftingDescription:SetPoint("TOPLEFT", self.recraftSlot, "BOTTOMLEFT");
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
								self.transaction:SetManuallyAllocated(true);

								slot:Update();

								self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
							end

							self.QualityDialog:RegisterCallback(ProfessionsQualityDialogMixin.Event.Accepted, OnAllocationsAccepted, slot);
							
							local allocationsCopy = self.transaction:GetAllocationsCopy(slotIndex);
							local disallowZeroAllocations = true;
							self.QualityDialog:Open(recipeID, reagentSlotSchematic, allocationsCopy, slotIndex, disallowZeroAllocations);
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
					local currencyID = slot.Button:GetCurrencyID();
					if currencyID then
						GameTooltip:SetCurrencyByID(currencyID);
					else
						GameTooltip:SetRecipeReagentItem(recipeID, reagentSlotSchematic.dataSlotIndex);
					end
					GameTooltip:Show();
				end);
			end
		else
			local locked, lockedReason = Professions.GetReagentSlotStatus(reagentSlotSchematic, recipeInfo);
			slot.Button:SetLocked(locked);

			slot.UndoButton:SetScript("OnClick", function(button)
				AllocateModification(slotIndex, reagentSlotSchematic);

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
					Professions.SetupOptionalReagentTooltip(slot, recipeID, reagentType, reagentSlotSchematic.slotInfo.slotText, exchangeOnly, self.transaction:GetAllocationItemGUID(), slot:IsUnallocatable());

					slot.Button.InputOverlay.AddIconHighlight:SetShown(not slot:IsUnallocatable());
				end
				GameTooltip:Show();
			end);
			
			slot.Button:SetScript("OnMouseDown", function(button, buttonName, down)
				if locked then
					return;
				end

				if not slot:IsUnallocatable() then
					if buttonName == "LeftButton" then
						local flyout = ToggleProfessionsItemFlyout(slot.Button, ProfessionsFrame);
						if flyout then
							local function OnFlyoutItemSelected(o, flyout, elementData)
								local item = elementData.item;
								
								local function AllocateFlyoutItem()
									if ItemUtil.GetCraftingReagentCount(item:GetItemID()) == 0 then
										return;
									end

									local reagent = Professions.CreateCraftingReagentByItemID(item:GetItemID());
									self.transaction:OverwriteAllocation(slotIndex, reagent, reagentSlotSchematic.quantityRequired);
									
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
								local items = Professions.GenerateFlyoutItemsTable(itemIDs, filterOwned);
								local elementData = {items = items};
								return elementData;
							end
							
							flyout.OnElementEnterImplementation = function(elementData, tooltip)
								Professions.FlyoutOnElementEnterImplementation(elementData, tooltip, recipeID, self.transaction:GetAllocationItemGUID());
							end

							flyout.OnElementEnabledImplementation = nil;

							flyout:Init(slot.Button, self.transaction);
							flyout:RegisterCallback(ProfessionsItemFlyoutMixin.Event.ItemSelected, OnFlyoutItemSelected, slot);
						end
					elseif buttonName == "RightButton" then
						if self.transaction:HasAllocations(slotIndex) then
							local function Deallocate()
								self.transaction:ClearAllocations(slotIndex);

								slot:ClearItem();

								self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
							end
							
							local modification = self.transaction:GetModification(reagentSlotSchematic.dataSlotIndex);
							local allocate = not (modification and self.transaction:HasAllocatedItemID(modification.itemID));
							if allocate then
								Deallocate();
							else
								local modItem = Item:CreateFromItemID(modification.itemID);
								local dialogData = {callback = Deallocate, itemName = modItem:GetItemName()};
								StaticPopup_Show("PROFESSIONS_RECRAFT_REPLACE_OPTIONAL_REAGENT", nil, nil, dialogData);	
							end
						end
					end
				end
			end);
		end
	end
	
	if isSalvage then
		if not self.salvageSlot then
			self.salvageSlot = CreateFrame("FRAME", nil, self, "ProfessionsReagentSalvageTemplate");
			table.insert(self.extraSlotFrames, self.salvageSlot);
		end
		self.salvageSlot:Show();
		self.salvageSlot:Init(self.transaction, self.recipeSchematic.quantityMax);

		self.salvageSlot.Button:SetScript("OnMouseDown", function(button, buttonName, down)
			if buttonName == "LeftButton" then
				local flyout = ToggleProfessionsItemFlyout(self.salvageSlot.Button, ProfessionsFrame);
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
						local targetItems = C_TradeSkillUI.GetCraftingTargetItems(itemIDs);
						local items = {};
						for index, targetItem in ipairs(targetItems) do
							table.insert(items, Item:CreateFromItemGUID(targetItem.itemGUID));
						end

						if not filterOwned then
							for index, itemID in ipairs(itemIDs) do
								local contained = ContainsIf(targetItems, function(targetItem)
									return targetItem.itemID == itemID;
								end);
								if not contained then
									table.insert(items, Item:CreateFromItemID(itemID));
								end
							end
						end
						return {items = items, onlyCountStack = true,};
					end

					flyout.OnElementEnterImplementation = function(elementData, tooltip)
						Professions.FlyoutOnElementEnterImplementation(elementData, tooltip, recipeID, self.transaction:GetAllocationItemGUID());
					end

					flyout.OnElementEnabledImplementation = function(button, elementData)
						local item = elementData.item;
						local quantity = item:GetItemGUID() and item:GetStackCount() or nil;
						return (quantity ~= nil) and (quantity >= self.recipeSchematic.quantityMax);
					end

					flyout:Init(self.salvageSlot.Button, self.transaction);
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
				local itemID = salvageItem:GetItemID();
				if itemID then
					GameTooltip:SetItemByID(itemID);
					GameTooltip_AddBlankLineToTooltip(GameTooltip);
					GameTooltip_AddInstructionLine(GameTooltip, SALVAGE_REAGENT_TOOLTIP_CLICK_TO_REMOVE);
				end
			else
				GameTooltip_AddInstructionLine(GameTooltip, SALVAGE_REAGENT_TOOLTIP_CLICK_TO_ADD);
			end
			GameTooltip:Show();
		end);
	end

	local isEnchant = (self.recipeSchematic.recipeType == Enum.TradeskillRecipeType.Enchant) and not C_TradeSkillUI.IsRuneforging();
	if isEnchant then
		if not self.enchantSlot then
			self.enchantSlot = CreateFrame("FRAME", nil, self, "ProfessionsReagentEnchantTemplate");
			table.insert(self.extraSlotFrames, self.enchantSlot);
		end
		self.enchantSlot:Show();
		self.enchantSlot:Init(self.transaction);
	
		self.enchantSlot.Button:SetScript("OnMouseDown", function(button, buttonName, down)
			if buttonName == "LeftButton" then
				local flyout = ToggleProfessionsItemFlyout(self.enchantSlot.Button, ProfessionsFrame);
				if flyout then
					local function OnFlyoutItemSelected(o, flyout, elementData)
						local item = elementData.item;
						if ItemUtil.GetCraftingReagentCount(item:GetItemID()) == 0 then
							return;
						end
	
						self.transaction:SetEnchantAllocation(item);
	
						self.enchantSlot:SetItem(item);
	
						self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
					end
		
					flyout.GetElementsImplementation = function(self, filterOwned)
						local itemGUIDs = C_TradeSkillUI.GetEnchantItems(recipeID);

						local function CopyPredicate(item)
							return item:GetItemID();
						end
						local items = TableUtil.CopyUniqueByPredicate(ItemUtil.TransformItemGUIDsToItems(itemGUIDs), 
							TableUtil.Constants.IsIndexTable, CopyPredicate);

						local elementsData = {items = items, itemGUIDs = itemGUIDs};
						return elementsData;
					end
	
					flyout.OnElementEnterImplementation = function(elementData, tooltip)
						tooltip:SetOwner(self.enchantSlot.Button, "ANCHOR_RIGHT");
						tooltip:SetItemByGUID(elementData.itemGUID);
						tooltip:Show();
					end
	
					flyout.OnElementEnabledImplementation = nil;
	
					local canModifyFilter = false;
					flyout:Init(self.enchantSlot.Button, self.transaction, canModifyFilter);
					flyout:RegisterCallback(ProfessionsItemFlyoutMixin.Event.ItemSelected, OnFlyoutItemSelected, slot);
				end
			elseif buttonName == "RightButton" then
				self.transaction:ClearEnchantAllocations();
	
				self.enchantSlot:ClearItem();
	
				self:TriggerEvent(ProfessionsRecipeSchematicFormMixin.Event.AllocationsModified);
			end
		end);

		self.enchantSlot.Button:SetScript("OnEnter", function(button)
			GameTooltip:SetOwner(button, "ANCHOR_RIGHT");

			local item = self.transaction:GetEnchantAllocation();
			if item then
				GameTooltip:SetItemByGUID(item:GetItemGUID());
				GameTooltip_AddBlankLineToTooltip(GameTooltip);
				GameTooltip_AddInstructionLine(GameTooltip, ENCHANT_TARGET_TOOLTIP_CLICK_TO_REPLACE);
			else
				GameTooltip_AddInstructionLine(GameTooltip, ENCHANT_TARGET_TOOLTIP_CLICK_TO_ADD);
			end
			GameTooltip:Show();
		end);
	end

	local basicSlots;
	if isSalvage then
		basicSlots = {self.salvageSlot};
	else
		basicSlots = self:GetSlotsByReagentType(Enum.CraftingReagentType.Basic);
	end

	local optionalSlots;
	if isEnchant then
		optionalSlots = {self.enchantSlot};
		self.OptionalReagents:SetText(PROFESSIONS_REAGENT_CONTAINER_ENCHANT_LABEL);
	else
		optionalSlots = self:GetSlotsByReagentType(Enum.CraftingReagentType.Optional);
		self.OptionalReagents:SetText(PROFESSIONS_OPTIONAL_REAGENT_CONTAINER_LABEL);
	end

	Professions.LayoutReagentSlots(basicSlots, self.Reagents, optionalSlots, self.OptionalReagents, self.VerticalDivider);
	
	if basicSlots and #basicSlots > 0 then
		self.Reagents:Show();

		self.Reagents:ClearAllPoints();
		if isRecraft then
			self.Reagents:SetPoint("TOP", self.OutputIcon, "BOTTOM", 66, -98 + PROFESSIONS_SCHEMATIC_REAGENTS_Y_OFFSET);
		else
			self.Reagents:SetPoint("TOPLEFT", self.Description, "BOTTOMLEFT", 0, -50);
		end
	else
		self.Reagents:Hide();
	end

	local operationInfo;
	local professionLearned = Professions.GetProfessionInfo().skillLevel > 0;
	if professionLearned then
		operationInfo = self:GetRecipeOperationInfo();
	end

	local finishingSlots = self:GetSlotsByReagentType(Enum.CraftingReagentType.Finishing);
	local hasFinishingSlots = finishingSlots ~= nil;
	if professionLearned and Professions.InLocalCraftingMode() and recipeInfo.supportsCraftingStats and ((operationInfo ~= nil and #operationInfo.bonusStats > 0) or recipeInfo.supportsQualities or recipeInfo.isGatheringRecipe or hasFinishingSlots) then
		Professions.LayoutFinishingSlots(finishingSlots, self.Details.FinishingReagentSlotContainer);
		
		self.Details:ClearAllPoints();
		if recipeInfo.isGatheringRecipe then
			self.Details:SetPoint("TOPLEFT", self.Description, "BOTTOMLEFT", 0, -30);
		else
			self.Details:SetPoint("TOPRIGHT", self, "TOPRIGHT", -30, -85);
		end
		
		self.Details:SetData(self.transaction, recipeInfo, hasFinishingSlots);
		self.Details:Show();
		self:UpdateDetailsStats(operationInfo);
	end

	self:UpdateRecraftSlot(operationInfo);

	if professionLearned and Professions.DoesSchematicIncludeReagentQualities(self.recipeSchematic) then
		self.AllocateBestQualityCheckBox:Show();
		self.AllocateBestQualityCheckBox:SetChecked(Professions.ShouldAllocateBestQualityReagents());
	else
		self.AllocateBestQualityCheckBox:Hide();
	end

	self.transaction:SetAllocationsChangedHandler(self.statsChangedHandler);

	organizer:Layout();

	if self.postInit then
		self.postInit();
	end
end

function ProfessionsRecipeSchematicFormMixin:OnAllocationsChanged()
	local operationInfo = self:GetRecipeOperationInfo();
	self:UpdateDetailsStats(operationInfo);
	self:UpdateRecraftSlot(operationInfo);
end

function ProfessionsRecipeSchematicFormMixin:UpdateRecraftSlot(operationInfo)
	if self.recraftSlot and self.recraftSlot:IsShown() then
		if not operationInfo then
			operationInfo = self:GetRecipeOperationInfo();
		end

		if operationInfo then
			SetItemCraftingQualityOverlayOverride(self.recraftSlot.OutputSlot, operationInfo.craftingQuality);
		end
	end
end

function ProfessionsRecipeSchematicFormMixin:UpdateDetailsStats(operationInfo)
	if self.Details:IsShown() and self.Details:HasData() then
		if not operationInfo then
			operationInfo = self:GetRecipeOperationInfo();
		end

		if operationInfo then
			self.Details:SetStats(operationInfo, self.currentRecipeInfo.supportsQualities, self.currentRecipeInfo.isGatheringRecipe);
		end
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

function ProfessionsRecipeSchematicFormMixin:OnHyperlinkEnter(link, text, fontString, left, bottom, width, height)
	local requirementType = StringToRequirementType[link];
	if requirementType == Enum.RecipeRequirementType.Totem or requirementType == Enum.RecipeRequirementType.SpellFocus then
		GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
		GameTooltip:ClearAllPoints();
		GameTooltip:SetPoint("BOTTOMLEFT", fontString, "TOPLEFT", left + width, bottom);
		local sourceText = (requirementType == Enum.RecipeRequirementType.Totem) and PROFESSIONS_REQUIREMENT_TOOL or PROFESSIONS_REQUIREMENT_TABLE;
		GameTooltip_AddNormalLine(GameTooltip, sourceText);
		GameTooltip:Show();
	end
end

function ProfessionsRecipeSchematicFormMixin:OnHyperlinkLeave()
	GameTooltip_Hide();
end

ProfessionsFavoriteButtonMixin = {};

function ProfessionsFavoriteButtonMixin:SetIsFavorite(isFavorite)
	local atlas = isFavorite and "auctionhouse-icon-favorite" or "auctionhouse-icon-favorite-off";
	self.NormalTexture:SetAtlas(atlas);

	self.HighlightTexture:SetAtlas(atlas);
	self.HighlightTexture:SetAlpha(isFavorite and 0.2 or 0.4);
end