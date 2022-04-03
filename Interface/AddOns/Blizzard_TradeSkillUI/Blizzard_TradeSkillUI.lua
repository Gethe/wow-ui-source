UIPanelWindows["TradeSkillFrame"] = {area = "left", pushable = 3, showFailedFunc = C_TradeSkillUI.CloseTradeSkill, };

TradeSkillTypeColor = {
	optimal			= { r = 1.00, g = 0.50, b = 0.25,	font = GameFontNormalLeftOrange };
	medium			= { r = 1.00, g = 1.00, b = 0.00,	font = GameFontNormalLeftYellow };
	easy			= { r = 0.25, g = 0.75, b = 0.25,	font = GameFontNormalLeftLightGreen };
	trivial			= { r = 0.50, g = 0.50, b = 0.50,	font = GameFontNormalLeftGrey };
	header			= { r = 1.00, g = 0.82, b = 0,		font = GameFontNormalLeft };
	subheader		= { r = 1.00, g = 0.82, b = 0,		font = GameFontNormalLeft };
	nodifficulty	= { r = 0.96, g = 0.96, b = 0.96,	font = GameFontNormalLeftGrey };
};

TradeSkillUIMixin = CreateFromMixins(CallbackRegistryMixin);

TradeSkillUIMixin:GenerateCallbackEvents(
{
	"OptionalReagentUpdated",
	"OptionalReagentListClosed",
});

function TradeSkillUIMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	
	self.RecipeList:SetRecipeChangedCallback(function(...) self:OnRecipeChanged(...) end);

	self:RegisterEvent("TRADE_SKILL_DATA_SOURCE_CHANGING");
	self:RegisterEvent("TRADE_SKILL_DATA_SOURCE_CHANGED");
	self:RegisterEvent("TRADE_SKILL_LIST_UPDATE");
	self:RegisterEvent("TRADE_SKILL_DETAILS_UPDATE");
	self:RegisterEvent("TRADE_SKILL_NAME_UPDATE");

	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");

	self:RegisterEvent("TRADE_SKILL_CLOSE");
	self:RegisterEvent("GARRISON_TRADESKILL_NPC_CLOSED");

	UIDropDownMenu_Initialize(self.FilterDropDown, function(...) self:InitFilterMenu(...) end, "MENU");
	UIDropDownMenu_Initialize(self.LinkToDropDown, function(...) self:InitLinkToMenu(...) end, "MENU");
end

function TradeSkillUIMixin:OnEvent(event, ...)
	if event == "TRADE_SKILL_DATA_SOURCE_CHANGING" then
		if self:IsVisible() then
			self:RefreshRetrievingDataFrame();
			self.RecipeList:OnDataSourceChanging();
		end
	elseif event == "TRADE_SKILL_DATA_SOURCE_CHANGED" then
		if self:IsVisible() then
			self:RefreshRetrievingDataFrame();
			self:OnDataSourceChanged();
			if self.pendingRecipeIDToSelect then
				self.RecipeList:SelectedAndForceRecipeIDIntoView(self.pendingRecipeIDToSelect);
				self.pendingRecipeIDToSelect = nil;
			end
		end
	elseif event == "TRADE_SKILL_LIST_UPDATE" then
		if self:IsVisible() then
			self.RecipeList:Refresh();
			self.DetailsFrame:Refresh();
		end
	elseif event == "TRADE_SKILL_DETAILS_UPDATE" then
		if self:IsVisible() then
			self.DetailsFrame:Refresh();
		end
	elseif event == "TRADE_SKILL_NAME_UPDATE" then
		if self:IsVisible() then
			self:RefreshTitle();
		end
	elseif event == "SKILL_LINES_CHANGED" then
		if self:IsVisible() then
			self:RefreshSkillRank();
		end
	elseif event == "TRIAL_STATUS_UPDATE" then
		if self:IsVisible() then
			self:RefreshSkillRank();
		end
	elseif event == "TRADE_SKILL_CLOSE" then
		HideUIPanel(self);
	elseif event == "GARRISON_TRADESKILL_NPC_CLOSED" then
		HideUIPanel(self);
	end
end

function TradeSkillUIMixin:OnShow()
	self:RefreshRetrievingDataFrame();
	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_OPEN);
end

function TradeSkillUIMixin:OnHide()
	C_TradeSkillUI.CloseTradeSkill();
	C_Garrison.CloseGarrisonTradeskillNPC();
	PlaySound(SOUNDKIT.UI_PROFESSIONS_WINDOW_CLOSE);
end

function TradeSkillUIMixin:OnDataSourceChanged()
	local tradeSkillID = C_TradeSkillUI.GetTradeSkillLine();

	local tradeSkillChanged = self.lastTradeSkillID ~= tradeSkillID;
	self.lastTradeSkillID = tradeSkillChanged;

	self.RecipeList:OnDataSourceChanged(tradeSkillChanged);
	self.DetailsFrame:OnDataSourceChanged(tradeSkillChanged);
	self:RefreshSkillRank();
	self:RefreshTitle();

	self.LinkToButton:SetShown(C_TradeSkillUI.CanTradeSkillListLink());

	self:ClearSlotFilter();

	CloseDropDownMenus();
	self.SearchBox:SetText("");
end

function TradeSkillUIMixin:RefreshRetrievingDataFrame()
	self.RetrievingFrame:SetShown(not C_TradeSkillUI.IsTradeSkillReady());
end

function TradeSkillUIMixin:RefreshTitle()
	local tradeSkillID, skillLineName, skillLineRank, skillLineMaxRank, skillLineModifier, parentSkillLineID, parentSkillLineName =  C_TradeSkillUI.GetTradeSkillLine();

	if (parentSkillLineName) then
		skillLineName = parentSkillLineName;
	end

	self.LinkNameButton:Hide();

	if C_TradeSkillUI.IsTradeSkillGuild() then
		self:SetTitleFormatted(GUILD_TRADE_SKILL_TITLE, skillLineName);
		self:SetPortraitShown(false);

		self.TabardBackground:Show();
		self.TabardEmblem:Show();
		self.TabardBorder:Show();
		SetLargeGuildTabardTextures("player", self.TabardEmblem, self.TabardBackground, self.TabardBorder);
	else
		local linked, linkedName = C_TradeSkillUI.IsTradeSkillLinked();
		if linked and linkedName then
			self.LinkNameButton:Show();
			self:SetTitleFormatted("%s %s[%s]|r", TRADE_SKILL_TITLE:format(skillLineName), HIGHLIGHT_FONT_COLOR_CODE, linkedName);
			self.LinkNameButton.linkedName = linkedName;
			self.LinkNameButton:SetWidth(self.TitleText:GetStringWidth());
		else
			self.TitleText:SetFormattedText(TRADE_SKILL_TITLE, skillLineName);
			self.LinkNameButton.linkedName = nil;
		end

		self.TabardBackground:Hide();
		self.TabardEmblem:Hide();
		self.TabardBorder:Hide();
		self:SetPortraitShown(true);
		self:SetPortraitToAsset(C_TradeSkillUI.GetTradeSkillTexture(tradeSkillID));
	end
end

function TradeSkillUIMixin:OnRecipeChanged(recipeID)
	self.DetailsFrame:SetSelectedRecipeID(self.RecipeList:GetSelectedRecipeID());
	self.OptionalReagentList:Hide();
end

function TradeSkillUIMixin:SelectRecipe(recipeID)
	if self:IsVisible() and C_TradeSkillUI.IsTradeSkillReady() and not C_TradeSkillUI.IsDataSourceChanging() then
		self.RecipeList:OnLearnedTabClicked();
		self.RecipeList:SelectedAndForceRecipeIDIntoView(recipeID);
	else
		self.pendingRecipeIDToSelect = recipeID;
	end
end

function TradeSkillUIMixin:OnSearchTextChanged(searchBox)
	local text = searchBox:GetText();

	local minLevel, maxLevel;
	local approxLevel = text:match("^~(%d+)");
	if approxLevel then
		minLevel = approxLevel - 2;
		maxLevel = approxLevel + 2;
	else
		minLevel, maxLevel = text:match("^(%d+)%s*-*%s*(%d*)$");
	end
	if minLevel then
		if not maxLevel or maxLevel == "" then
			maxLevel = minLevel;
		end
		minLevel = tonumber(minLevel);
		maxLevel = tonumber(maxLevel);

		minLevel = math.max(1, math.min(10000, minLevel));
		maxLevel = math.max(1, math.min(10000, math.max(minLevel, maxLevel)));

		C_TradeSkillUI.SetRecipeItemNameFilter(nil);
		C_TradeSkillUI.SetRecipeItemLevelFilter(minLevel, maxLevel);
	else
		C_TradeSkillUI.SetRecipeItemNameFilter(text);
		C_TradeSkillUI.SetRecipeItemLevelFilter(0, 0);
	end
end

function TradeSkillUIMixin:ClearSlotFilter()
	C_TradeSkillUI.ClearInventorySlotFilter();
	C_TradeSkillUI.ClearRecipeCategoryFilter();
end

function TradeSkillUIMixin:SetSlotFilter(inventorySlotIndex, categoryID, subCategoryID)
	self:ClearSlotFilter();

	if inventorySlotIndex then
		C_TradeSkillUI.SetInventorySlotFilter(inventorySlotIndex, true, true);
	end

	if categoryID or subCategoryID then
		C_TradeSkillUI.SetRecipeCategoryFilter(categoryID, subCategoryID);
	end
end

local function GenerateRankText(skillLineName, skillLineRank, skillLineMaxRank, skillLineModifier)
	local rankText;
	if skillLineModifier > 0  then
		rankText = TRADESKILL_NAME_RANK_WITH_MODIFIER:format(skillLineName, skillLineRank, skillLineModifier, skillLineMaxRank);
	else
		rankText = TRADESKILL_NAME_RANK:format(skillLineName, skillLineRank, skillLineMaxRank);
	end

	if GameLimitedMode_IsActive() then
		local _, _, profCap = GetRestrictedAccountData();
		if skillLineRank >= profCap and profCap > 0 then
			return ("%s %s%s|r"):format(rankText, RED_FONT_COLOR_CODE, CAP_REACHED_TRIAL);
		end
	end
	return rankText;
end

function TradeSkillUIMixin:RefreshSkillRank()
	if C_TradeSkillUI.IsTradeSkillGuild() or C_TradeSkillUI.IsTradeSkillGuildMember() then
		self.RankFrame:Hide();
	else
		local tradeSkillID, skillLineName, skillLineRank, skillLineMaxRank, skillLineModifier = C_TradeSkillUI.GetTradeSkillLine();
		if not C_TradeSkillUI.IsTradeSkillReady() or not tradeSkillID or (C_TradeSkillUI.IsNPCCrafting() and skillLineMaxRank == 0) then
			self.RankFrame:Hide();
		else
			self.RankFrame:SetMinMaxValues(0, skillLineMaxRank);
			self.RankFrame:SetValue(skillLineRank);

			local rankText = GenerateRankText(skillLineName, skillLineRank, skillLineMaxRank, skillLineModifier);
			self.RankFrame.RankText:SetText(rankText);

			self.RankFrame:Show();
		end
	end
end

function TradeSkillUIMixin:InitFilterMenu(dropdown, level)
	local filterSystem = {
		filters = {
			{ type = FilterComponent.Checkbox, text = CRAFT_IS_MAKEABLE, set = C_TradeSkillUI.SetOnlyShowMakeableRecipes, isSet = C_TradeSkillUI.GetOnlyShowMakeableRecipes, },
			{ type = FilterComponent.Submenu, text = TRADESKILL_FILTER_SLOTS, value = 1, childrenInfo = {
					filters = {
						{ type = FilterComponent.CustomFunction, customFunc = function(level) TradeSkillFrame:AddInInventorySlotFilters(level) end, },
					},
				},
			},
			{ type = FilterComponent.Submenu, text = TRADESKILL_FILTER_CATEGORY, value = 2, childrenInfo = { filters = self:BuildCategoryFilterList() }, };
			{ type = FilterComponent.Submenu, text = SOURCES, value = 3, childrenInfo = {
					filters = {
						{ type = FilterComponent.TextButton, 
						  text = CHECK_ALL,
						  set = function() 	
										TradeSkillFrame_SetAllSourcesFiltered(false);
										UIDropDownMenu_Refresh(self.FilterDropDown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL); 
									end, 
						},
						{ type = FilterComponent.TextButton,
						  text = UNCHECK_ALL,
						  set = function() 	
										TradeSkillFrame_SetAllSourcesFiltered(true);
										UIDropDownMenu_Refresh(self.FilterDropDown, UIDROPDOWNMENU_MENU_VALUE, UIDROPDOWNMENU_MENU_LEVEL); 
									end, 
						},
						{ type = FilterComponent.DynamicFilterSet,
						  buttonType = FilterComponent.Checkbox, 
						  set = function(filter, value)
									C_TradeSkillUI.SetRecipeSourceTypeFilter(filter, not value);
								end;
						  isSet = function(filter) return not C_TradeSkillUI.IsRecipeSourceTypeFiltered(filter); end,
						  numFilters = C_PetJournal.GetNumPetSources,
						  filterValidation = C_TradeSkillUI.IsAnyRecipeFromSource,
						  globalPrepend = "BATTLE_PET_SOURCE_", 
						},
					},
				},
			},
		},
	};

	local skillLineMaxRank = C_TradeSkillUI.GetTradeSkillLine();
	local isNPCCrafting = C_TradeSkillUI.IsNPCCrafting() and skillLineMaxRank == 0;
	if not C_TradeSkillUI.IsTradeSkillGuild() and not isNPCCrafting then
		local onlyShowSkillUpRecipes = { type = FilterComponent.Checkbox, text = TRADESKILL_FILTER_HAS_SKILL_UP, set = C_TradeSkillUI.SetOnlyShowSkillUpRecipes, isSet = C_TradeSkillUI.GetOnlyShowSkillUpRecipes, };
		table.insert(filterSystem.filters, 2, onlyShowSkillUpRecipes);
	end

	FilterDropDownSystem.Initialize(dropdown, filterSystem, level);
end

function TradeSkillUIMixin:AddInInventorySlotFilters(level)
	local inventorySlots = { C_TradeSkillUI.GetAllFilterableInventorySlots() };
	for i, inventorySlot in ipairs(inventorySlots) do
		local onClick = function() TradeSkillFrame:SetSlotFilter(i, nil, nil); end;
		FilterDropDownSystem.AddTextButton(inventorySlot, onClick, level);
	end
end

function TradeSkillUIMixin:BuildCategoryFilterList()
	local categoryFilterList = {};

	local categories = { C_TradeSkillUI.GetCategories() };
	for i, categoryID in ipairs(categories) do
		local categoryData = C_TradeSkillUI.GetCategoryInfo(categoryID);

		local newCategoryFilter;
		local set = function() self:SetSlotFilter(nil, categoryID, nil); end;
		local isSubMenu = (select("#", C_TradeSkillUI.GetSubCategories(categoryID)) > 0);
		if isSubMenu then
			newCategoryFilter = { type = FilterComponent.Submenu, text = categoryData.name, value = categoryID, set = set, childrenInfo = { filters = self:BuildSubCategoryFilterList(categoryID) }, };
		else
			newCategoryFilter = { type = FilterComponent.TextButton, text = categoryData.name, set = set, };
		end
		table.insert(categoryFilterList, newCategoryFilter);
	end
	return categoryFilterList;
end

function TradeSkillUIMixin:BuildSubCategoryFilterList(categoryID)
	local subCategoryFilterList = {};

	local subCategories = { C_TradeSkillUI.GetSubCategories(categoryID) };
	for i, subCategoryID in ipairs(subCategories) do
		local subCategoryData = C_TradeSkillUI.GetCategoryInfo(subCategoryID);

		local set = function() self:SetSlotFilter(nil, categoryID, subCategoryID); end
		local newSubCategoryFilter = { type = FilterComponent.TextButton, text = subCategoryData.name, set = set, };
		table.insert(subCategoryFilterList, newSubCategoryFilter);
	end
	return subCategoryFilterList;
end

function TradeSkillUIMixin:OnLinkToButtonClicked()
	if MacroFrameText and MacroFrameText:IsShown() and MacroFrameText:HasFocus() then
		local link = C_TradeSkillUI.GetTradeSkillListLink();
		local text = MacroFrameText:GetText() .. link;
		if strlenutf8(text) <= MacroFrameText:GetMaxLetters() then
			MacroFrameText:Insert(link);
		end
	else
		local activeEditBox = ChatEdit_GetActiveWindow();
		if activeEditBox then
			local link = C_TradeSkillUI.GetTradeSkillListLink();
			ChatEdit_InsertLink(link);
		else
			ToggleDropDownMenu(1, nil, self.LinkToDropDown, self.LinkToButton, 25, 25);
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		end
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function TradeSkillUIMixin:InitLinkToMenu(dropdown, level)
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
	info.disabled = GetNumSubgroupMembers() == 0;
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

local TIME_BETWEEN_DOTS_SEC = .3;
function TradeSkillUIMixin:OnRetrievingFrameUpdate(elapsed)
	if self.RetrievingFrame.timeUntilNextDotSecs then
		self.RetrievingFrame.timeUntilNextDotSecs = self.RetrievingFrame.timeUntilNextDotSecs - elapsed;
	else
		self.RetrievingFrame.timeUntilNextDotSecs = TIME_BETWEEN_DOTS_SEC;
	end

	if self.RetrievingFrame.timeUntilNextDotSecs <= 0 then
		local dotCount = ((self.RetrievingFrame.dotCount or 0) + 1) % 4;

		self.RetrievingFrame.Dots:SetText(("."):rep(dotCount));
		self.RetrievingFrame.dotCount = dotCount;
		self.RetrievingFrame.timeUntilNextDotSecs = self.RetrievingFrame.timeUntilNextDotSecs + TIME_BETWEEN_DOTS_SEC;
	end
end

function TradeSkillUIMixin:IsRecipeLearned()
	return self.DetailsFrame:IsRecipeLearned();
end

function TradeSkillUIMixin:GetOptionalReagent(optionalReagentIndex)
	return self.DetailsFrame:GetOptionalReagent(optionalReagentIndex);
end

function TradeSkillUIMixin:GetOptionalReagentBonusText(itemID, slot)
	return self.DetailsFrame:GetOptionalReagentBonusText(itemID, slot);
end

function TradeSkillUIMixin:HasOptionalReagent(itemID)
	return self.DetailsFrame:HasOptionalReagent(itemID);
end

function TradeSkillUIMixin:OpenOptionalReagentSelection(selectedRecipeID, selectedRecipeLevel, optionalReagentIndex)
	local function ReagentSelectedCallback(option)
		self.DetailsFrame:SetOptionalReagent(optionalReagentIndex, option);
		self:CloseOptionalReagentSelection();
	end

	self.OptionalReagentList:OpenSelection(selectedRecipeID, selectedRecipeLevel, optionalReagentIndex, ReagentSelectedCallback);
	self.OptionalReagentList:Show();
end

function TradeSkillUIMixin:IsOptionalReagentListShown()
	return self.OptionalReagentList:IsShown();
end

function TradeSkillUIMixin:GetOptionalReagentListTutorialLine()
	return self.OptionalReagentList:GetTutorialLine();
end

function TradeSkillUIMixin:GetSelectedOptionalReagentIndex()
	return self:IsOptionalReagentListShown() and self.OptionalReagentList:GetOptionalReagentIndex() or nil;
end

function TradeSkillUIMixin:CloseOptionalReagentSelection(selectedRecipeID, optionalReagentIndex)
	self.OptionalReagentList:ClearSelection(selectedRecipeID, optionalReagentIndex)
	self.OptionalReagentList:Hide();
end
