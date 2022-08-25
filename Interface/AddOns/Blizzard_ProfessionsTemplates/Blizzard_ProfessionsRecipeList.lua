local DifficultyColors = {
	[Enum.TradeskillRelativeDifficulty.Optimal] = DIFFICULT_DIFFICULTY_COLOR,
	[Enum.TradeskillRelativeDifficulty.Medium]	= FAIR_DIFFICULTY_COLOR,
	[Enum.TradeskillRelativeDifficulty.Easy] = EASY_DIFFICULTY_COLOR,
};

ProfessionsRecipeListMixin = CreateFromMixins(CallbackRegistryMixin);
ProfessionsRecipeListMixin:GenerateCallbackEvents(
{
	"OnRecipeSelected",
});

function ProfessionsRecipeListMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	local indent = 10;
	local padLeft = 0;
	local pad = 5;
	local spacing = 1;
	local view = CreateScrollBoxListTreeListView(indent, pad, pad, padLeft, pad, spacing);

	view:SetElementFactory(function(factory, node)
		local elementData = node:GetData();
		if elementData.categoryInfo then
			local function Initializer(button, node)
				button:Init(node);

				button:SetScript("OnClick", function(button, buttonName)
					node:ToggleCollapsed();
					button:SetCollapseState(node:IsCollapsed());
				end);

				button:SetScript("OnEnter", function()
					EventRegistry:TriggerEvent("ProfessionsDebug.CraftingRecipeListCategoryEntered", button, elementData.categoryInfo);
					ProfessionsRecipeListCategoryMixin.OnEnter(button);
				end);
			end
			factory("ProfessionsRecipeListCategoryTemplate", Initializer);
		elseif elementData.recipeInfo then
			local function Initializer(button, node)
				button:Init(node);
			
				local selected = self.selectionBehavior:IsElementDataSelected(node);
				button:SetSelected(selected);

				button:SetScript("OnClick", function(button, buttonName,  down)
					EventRegistry:TriggerEvent("ProfessionsDebug.CraftingRecipeListRecipeClicked", button, buttonName, down, elementData.recipeInfo);
					
					if buttonName == "LeftButton" then
						if IsModifiedClick() then
							local link = C_TradeSkillUI.GetRecipeLink(elementData.recipeInfo.recipeID);
							if not HandleModifiedItemClick(link) and IsModifiedClick("RECIPEWATCHTOGGLE") and Professions.CanTrackRecipe(elementData.recipeInfo) then
								local tracked = C_TradeSkillUI.IsRecipeTracked(elementData.recipeInfo.recipeID);
								C_TradeSkillUI.SetRecipeTracked(elementData.recipeInfo.recipeID, not tracked);
							end
						else
							self.selectionBehavior:Select(button);
						end
					elseif buttonName == "RightButton" then
						-- If additional context menu options are added, move this
						-- public view check to the dropdown initializer.
						if elementData.recipeInfo.learned and Professions.InLocalCraftingMode() then
							ToggleDropDownMenu(1, elementData.recipeInfo, self.ContextMenu, "cursor");
						end
					end
				end);

				button:SetScript("OnEnter", function()
					ProfessionsRecipeListRecipeMixin.OnEnter(button);
					EventRegistry:TriggerEvent("ProfessionsDebug.CraftingRecipeListRecipeEntered", button, elementData.recipeInfo);
				end);
			end
			factory("ProfessionsRecipeListRecipeTemplate", Initializer);
		else
			factory("Frame");
		end
	end);

	view:SetElementExtentCalculator(function(dataIndex, node)
		local elementData = node:GetData();
		local baseElementHeight = 20;
		local categoryPadding = 5;

		if elementData.recipeInfo then
			return baseElementHeight;
		end

		if elementData.categoryInfo then
			return baseElementHeight + categoryPadding;
		end

		if elementData.topPadding then
			return 1;
		end

		if elementData.bottomPadding then
			return 10;
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
	
	local function OnSelectionChanged(o, elementData, selected)
		local button = self.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end

		if selected then
			local data = elementData:GetData();
			assert(data.recipeInfo);

			local newRecipeID = data.recipeInfo.recipeID;
			local changed = self.previousRecipeID ~= newRecipeID;
			if changed then
				EventRegistry:TriggerEvent("ProfessionsRecipeListMixin.Event.OnRecipeSelected", data.recipeInfo);
				self.previousRecipeID = newRecipeID;
			end

		end
	end;

	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);

	UIDropDownMenu_SetInitializeFunction(self.ContextMenu, GenerateClosure(self.InitContextMenu, self));
	UIDropDownMenu_SetDisplayMode(self.ContextMenu, "MENU");
end

function ProfessionsRecipeListMixin:InitContextMenu(dropDown, level)
	local recipeInfo = UIDROPDOWNMENU_MENU_VALUE;
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	
	local currentlyFavorite = C_TradeSkillUI.IsRecipeFavorite(recipeInfo.recipeID);
	info.text = currentlyFavorite and BATTLE_PET_UNFAVORITE or BATTLE_PET_FAVORITE;
	info.func = GenerateClosure(C_TradeSkillUI.SetRecipeFavorite, recipeInfo.recipeID, not currentlyFavorite);

	UIDropDownMenu_AddButton(info, level);
end

function ProfessionsRecipeListMixin:SelectRecipe(recipeInfo)
	self.selectionBehavior:SelectElementDataByPredicate(function(node)
		local data = node:GetData();
		return data.recipeInfo and data.recipeInfo.recipeID == recipeInfo.recipeID and data.recipeInfo.favoritesInstance == recipeInfo.favoritesInstance;
	end);
end

ProfessionsRecipeListCategoryMixin = {};

function ProfessionsRecipeListCategoryMixin:OnEnter()
	self.Label:SetFontObject(GameFontHighlight_NoShadow);
	if self.RankBar.currentRank and self.RankBar.maxRank then
		self.RankBar.Rank:Show();
		self.RankBar.Rank:SetFormattedText("%d/%d", self.RankBar.currentRank, self.RankBar.maxRank);
	end
end

function ProfessionsRecipeListCategoryMixin:OnLeave()
	self.Label:SetFontObject(GameFontNormal_NoShadow);
	self.RankBar.Rank:Hide();
	self.RankBar.Rank:SetText("");
end

function ProfessionsRecipeListCategoryMixin:Init(node)
	local elementData = node:GetData();
	local categoryInfo = elementData.categoryInfo;
	self.Label:SetText(categoryInfo.name);

	self:SetCollapseState(node:IsCollapsed());
	if categoryInfo.hasProgressBar and not (C_TradeSkillUI.IsTradeSkillGuild() or C_TradeSkillUI.IsTradeSkillGuildMember()) and not tContains({C_TradeSkillUI.GetCategories()}, categoryInfo.categoryID) then
		self.RankBar:SetMinMaxValues(categoryInfo.skillLineStartingRank, categoryInfo.skillLineMaxLevel);
		self.RankBar:SetValue(categoryInfo.skillLineCurrentLevel);
		self.RankBar.currentRank = categoryInfo.skillLineCurrentLevel;
		self.RankBar.maxRank = categoryInfo.skillLineMaxLevel;
		self.RankBar:Show();
	else
		self.RankBar.currentRank = nil;
		self.RankBar.maxRank = nil;
		self.RankBar:Hide();
	end
end

function ProfessionsRecipeListCategoryMixin:SetCollapseState(collapsed)
	local atlas = collapsed and "Professions-recipe-header-expand" or "Professions-recipe-header-collapse";
	self.CollapseIcon:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
	self.CollapseIconAlphaAdd:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

ProfessionsRecipeListRecipeMixin = {};

function ProfessionsRecipeListRecipeMixin:OnLoad()
	local function OnLeave()
		self:OnLeave();
		GameTooltip_Hide();
	end

	self.LockedIcon:SetScript("OnLeave", OnLeave);
	self.SkillUps:SetScript("OnLeave", OnLeave);
end

function ProfessionsRecipeListRecipeMixin:GetLabelColor()
	return self.learned and PROFESSION_RECIPE_COLOR or DISABLED_FONT_COLOR;
end

function ProfessionsRecipeListRecipeMixin:Init(node)
	local elementData = node:GetData();
	local recipeInfo = Professions.GetHighestLearnedRecipe(elementData.recipeInfo) or elementData.recipeInfo;

	self.Label:SetText(recipeInfo.name);
	self.learned = recipeInfo.learned;
	self:SetLabelFontColors(self:GetLabelColor());

	local rightFrames = {};

	self.LockedIcon:Hide();

	local function OnClick(button, buttonName, down)
		self:Click(buttonName, down);
	end

	self.SkillUps:Hide();
	if recipeInfo.disabled then
		self.LockedIcon:SetScript("OnClick", OnClick);
		
		self.LockedIcon:SetScript("OnEnter", function()
			self:OnEnter();
			
			if recipeInfo.disabledReason then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
				GameTooltip_AddDisabledLine(GameTooltip, recipeInfo.disabledReason);
				GameTooltip:Show();
			end
		end);

		self.LockedIcon:Show();
		table.insert(rightFrames, self.LockedIcon);
	elseif not C_TradeSkillUI.IsTradeSkillGuild() and not C_TradeSkillUI.IsNPCCrafting() and not C_TradeSkillUI.IsRuneforging() then
		local skillUpAtlas;
		local xOfs = -3;
		local yOfs = 0;
		if recipeInfo.relativeDifficulty == Enum.TradeskillRelativeDifficulty.Easy then
			skillUpAtlas = "Professions-Icon-Skill-Low";
		elseif recipeInfo.relativeDifficulty == Enum.TradeskillRelativeDifficulty.Medium then
			skillUpAtlas = "Professions-Icon-Skill-Medium";
		elseif recipeInfo.relativeDifficulty == Enum.TradeskillRelativeDifficulty.Optimal then
			skillUpAtlas = "Professions-Icon-Skill-High";
			yOfs = 1;
		end

		if skillUpAtlas then
			self.SkillUps:ClearAllPoints();
			self.SkillUps:SetPoint("LEFT", self, "LEFT", xOfs, yOfs);

			self.SkillUps.Icon:SetAtlas(skillUpAtlas, TextureKitConstants.UseAtlasSize);
			self.SkillUps:SetScript("OnClick", OnClick);
			local multipleSkillUps = recipeInfo.numSkillUps > 1;
			self.SkillUps.Text:SetShown(multipleSkillUps);
			if multipleSkillUps then
				self.SkillUps.Text:SetText(recipeInfo.numSkillUps);
				self.SkillUps.Text:SetVertexColor(DifficultyColors[recipeInfo.relativeDifficulty]:GetRGB());
				self.SkillUps:SetScript("OnEnter", function()
					self:OnEnter();
					GameTooltip:SetOwner(self.SkillUps, "ANCHOR_RIGHT");
					GameTooltip_AddNormalLine(GameTooltip, SKILLUP_TOOLTIP:format(self.SkillUps.Text:GetText()));
					GameTooltip:Show();
				end);
			else
				self.SkillUps:SetScript("OnEnter", nil);
			end
			self.SkillUps:Show();
		end
	end

	local rightFramesWidth = 0;
	local rightFrame;
	for index, frame in ipairs(rightFrames) do
		frame:ClearAllPoints();
		if rightFrame then
			frame:SetPoint("RIGHT", rightFrame, "LEFT");
		else
			frame:SetPoint("RIGHT");
		end
		rightFrame = frame;
		rightFramesWidth = rightFramesWidth + frame:GetWidth();
	end
	
	local count = C_TradeSkillUI.GetCraftableCount(recipeInfo.recipeID);
	local hasCount = count > 0;
	if hasCount then
		self.Count:SetFormattedText(" [%d] ", count);
		self.Count:Show();
	else
		self.Count:Hide();
	end

	local padding = 10;
	local countWidth = hasCount and self.Count:GetStringWidth() or 0;
	local width = self:GetWidth() - (rightFramesWidth + countWidth + padding + self.SkillUps:GetWidth());
	self.Label:SetWidth(self:GetWidth());
	self.Label:SetWidth(math.min(width, self.Label:GetStringWidth()));
end

function ProfessionsRecipeListRecipeMixin:SetLabelFontColors(color)
	self.Label:SetVertexColor(color:GetRGB());
	self.Count:SetVertexColor(color:GetRGB());
end

function ProfessionsRecipeListRecipeMixin:OnEnter()
	self:SetLabelFontColors(HIGHLIGHT_FONT_COLOR);
	local recipeID = self.GetElementData().data.recipeInfo.recipeID
	local name = self.GetElementData().data.recipeInfo.name
	local iconID = self.GetElementData().data.recipeInfo.icon
	EventRegistry:TriggerEvent("Professions.RecipeListOnEnter", self, recipeID, name, iconID)
end


function ProfessionsRecipeListRecipeMixin:OnLeave()
	self:SetLabelFontColors(self:GetLabelColor());
end

function ProfessionsRecipeListRecipeMixin:SetSelected(selected)
	self.SelectedOverlay:SetShown(selected);
	self.HighlightOverlay:SetShown(not selected);
end