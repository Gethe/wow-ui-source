local DifficultyData = {
	[Enum.TradeskillRelativeDifficulty.Optimal] = { color = CreateColor(1, .5, .25), font = GameFontNormalLeftOrange, colorblindPrefix = "[+++] "};
	[Enum.TradeskillRelativeDifficulty.Medium]	= { color = CreateColor(1, 1, 0), font = GameFontNormalLeftYellow, colorblindPrefix = "[++] "};
	[Enum.TradeskillRelativeDifficulty.Easy] = { color = CreateColor(.25, .75, .25), font = GameFontNormalLeftLightGreen, colorblindPrefix = "[+] "};
	[Enum.TradeskillRelativeDifficulty.Trivial]	= { color = CreateColor(.5, .5, .5), font = GameFontNormalLeftGrey };
};
local ZeroDifficultyData = { color = CreateColor(.96, .96, .96), font = GameFontNormalLeftGrey };

local function GetDifficultyData(difficulty)
	if difficulty then
		return DifficultyData[difficulty];
	end
	return ZeroDifficultyData;
end

local function GetDifficultyFont(difficulty)
	local difficultyData = GetDifficultyData(difficulty);
	return difficultyData.font;
end

local function GetDifficultyColor(difficulty)
	local difficultyData = GetDifficultyData(difficulty);
	return difficultyData.color;
end

local function GetColorblindDifficultyPrefix(difficulty)
	if ENABLE_COLORBLIND_MODE == "1" then
		local difficultyData = GetDifficultyData(difficulty);
		local colorblindPrefix = difficultyData.colorblindPrefix;
		if colorblindPrefix then
			return colorblindPrefix;
		end
	end
	return "";
end

local function SetVertexColor(color, ...)
	local r, g, b = color:GetRGB();
	for index = 1, select("#", ...) do
		local region = select(index, ...);
		region:SetVertexColor(r, g, b);
	end
end

ProfessionsRecipeListMixin = CreateFromMixins(CallbackRegistryMixin);
ProfessionsRecipeListMixin:GenerateCallbackEvents(
{
	"OnRecipeSelected",
});

function ProfessionsRecipeListMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	local indent = 14;
	local padLeft = 14;
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
							if not HandleModifiedItemClick(link) and IsModifiedClick("RECIPEWATCHTOGGLE") then
								local tracked = C_TradeSkillUI.IsRecipeTracked(elementData.recipeInfo.recipeID);
								C_TradeSkillUI.SetRecipeTracked(elementData.recipeInfo.recipeID, not tracked);
							end
						else
							self.selectionBehavior:Select(button);
						end
					elseif buttonName == "RightButton" then
						ToggleDropDownMenu(1, elementData.recipeInfo, self.ContextMenu, "cursor");
					end
				end);

				button:SetScript("OnEnter", function()
					ProfessionsRecipeListRecipeMixin.OnEnter(button);
					EventRegistry:TriggerEvent("ProfessionsDebug.CraftingRecipeListRecipeEntered", button, elementData.recipeInfo);
				end);
			end
			factory("ProfessionsRecipeListRecipeTemplate", Initializer);
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

			EventRegistry:TriggerEvent("ProfessionsRecipeListMixin.Event.OnRecipeSelected", data.recipeInfo);
		end
	end;

	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);

	UIDropDownMenu_SetInitializeFunction(self.ContextMenu, GenerateClosure(self.InitContextMenu, self));
	UIDropDownMenu_SetDisplayMode(self.ContextMenu, "MENU");

	local function DropDownInitializer(dropDown, level)
		for index, professionInfo in ipairs(C_TradeSkillUI.GetChildProfessionInfos()) do
			local info = UIDropDownMenu_CreateInfo();
			info.notCheckable = true;
			info.text = professionInfo.professionName;
			info.func = function()
				EventRegistry:TriggerEvent("Professions.SelectSkillLine", professionInfo);
			end;
			UIDropDownMenu_AddButton(info);
		end
	end

	UIDropDownMenu_SetInitializeFunction(self.SkillLineDropDown, DropDownInitializer);
	UIDropDownMenu_SetWidth(self.SkillLineDropDown, 277);
	local function ProfessionSelectedCallback(_, professionInfo)
		self.SkillLineDropDown.Text:SetText(professionInfo.professionName);
		self.SkillLineDropDown:SetShown(not (C_TradeSkillUI.IsNPCCrafting() or C_TradeSkillUI.IsRuneforging()));
	end
	EventRegistry:RegisterCallback("Professions.ProfessionSelected", ProfessionSelectedCallback, self);
	self.SkillLineDropDown.Text:SetJustifyH("LEFT");
	self.SkillLineDropDown.Text:ClearAllPoints();
	self.SkillLineDropDown.Text:SetPoint("LEFT", self.SkillLineDropDown.Left, "RIGHT", 0, 2);
end

function ProfessionsRecipeListMixin:InitContextMenu(dropDown, level)
	local recipeInfo = UIDROPDOWNMENU_MENU_VALUE;
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	
	if recipeInfo.learned and Professions.InLocalCraftingMode() then
		local currentlyFavorite = C_TradeSkillUI.IsRecipeFavorite(recipeInfo.recipeID);
		info.text = currentlyFavorite and PROFESSIONS_UNFAVORITE or PROFESSIONS_FAVORITE;
		info.func = GenerateClosure(C_TradeSkillUI.SetRecipeFavorite, recipeInfo.recipeID, not currentlyFavorite);
		UIDropDownMenu_AddButton(info, level);
	end

	local tracked = C_TradeSkillUI.IsRecipeTracked(recipeInfo.recipeID);
	info.text = tracked and PROFESSIONS_UNTRACK_RECIPE or PROFESSIONS_TRACK_RECIPE;
	info.func = GenerateClosure(C_TradeSkillUI.SetRecipeTracked, recipeInfo.recipeID, not tracked);
	UIDropDownMenu_AddButton(info, level);
end

function ProfessionsRecipeListMixin:SelectRecipe(recipeInfo, scrollToRecipe)
	local elementData = self.selectionBehavior:SelectElementDataByPredicate(function(node)
		local data = node:GetData();
		return data.recipeInfo and data.recipeInfo.recipeID == recipeInfo.recipeID;
	end);

	if scrollToRecipe then
		self.ScrollBox:ScrollToElementData(elementData, ScrollBoxConstants.AlignCenter, ScrollBoxConstants.NoScrollInterpolation);
	end
	return elementData;
end

ProfessionsRecipeListElementMixin = {};

function ProfessionsRecipeListElementMixin:OnEnter()
	self.MouseoverOverlay:Show();
end

function ProfessionsRecipeListElementMixin:OnLeave()
	self.MouseoverOverlay:Hide();
end

ProfessionsRecipeListCategoryMixin = CreateFromMixins(ProfessionsRecipeListElementMixin);

function ProfessionsRecipeListCategoryMixin:OnEnter()
	ProfessionsRecipeListElementMixin.OnEnter(self);
	
	if self.RankBar.currentRank and self.RankBar.maxRank then
		self.RankBar.Rank:Show();
		self.RankBar.Rank:SetFormattedText("%d/%d", self.RankBar.currentRank, self.RankBar.maxRank);
	end
end

function ProfessionsRecipeListCategoryMixin:OnLeave()
	ProfessionsRecipeListElementMixin.OnLeave(self);

	self.RankBar.Rank:Hide();
	self.RankBar.Rank:SetText("");
end

function ProfessionsRecipeListCategoryMixin:Init(node)
	local elementData = node:GetData();
	local categoryInfo = elementData.categoryInfo;
	self.Label:SetText(categoryInfo.name);

	self:SetCollapseState(node:IsCollapsed());

	if categoryInfo.hasProgressBar and not (C_TradeSkillUI.IsTradeSkillGuild() or C_TradeSkillUI.IsTradeSkillGuildMember()) then
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
	local atlas = collapsed and "Soulbinds_Collection_CategoryHeader_Expand" or "Soulbinds_Collection_CategoryHeader_Collapse";
	self.CollapseIcon:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

ProfessionsRecipeListRecipeMixin = CreateFromMixins(ProfessionsRecipeListElementMixin);

function ProfessionsRecipeListRecipeMixin:OnLoad()
	local function OnLeave()
		self:OnLeave();
		GameTooltip_Hide();
	end

	self.LockedIcon:SetScript("OnLeave", OnLeave);
	self.SkillUps:SetScript("OnLeave", OnLeave);
end

function ProfessionsRecipeListRecipeMixin:Init(node)
	local elementData = node:GetData();
	local recipeInfo = Professions.GetHighestLearnedRecipe(elementData.recipeInfo) or elementData.recipeInfo;

	if C_TradeSkillUI.IsTradeSkillGuild() then
		self:SetDifficulty(Enum.TradeskillRelativeDifficulty.Easy);
	elseif C_TradeSkillUI.IsNPCCrafting() then
		self:SetDifficulty(nil);
	else
		self:SetDifficulty(recipeInfo.relativeDifficulty);
	end

	self.Label:SetFormattedText("%s%s", GetColorblindDifficultyPrefix(recipeInfo.relativeDifficulty), recipeInfo.name);

	local rightFrames = {};

	self.SkillUps:Hide();
	self.Stars:Hide();
	self.LockedIcon:Hide();

	local function OnClick(button, buttonName, down)
		self:Click(buttonName, down);
	end

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
	else
		if Professions.HasRecipeRanks(recipeInfo) then
			local rank = Professions.GetRecipeRankLearned(recipeInfo);
			for index, star in ipairs(self.Stars.Stars) do
				star.Earned:SetShown(index <= rank);	
			end

			self.Stars:Show();
			table.insert(rightFrames, self.Stars);
		end
	
		if recipeInfo.numSkillUps > 1 and recipeInfo.relativeDifficulty == Enum.TradeskillRelativeDifficulty.Optimal and not C_TradeSkillUI.IsTradeSkillGuild() and not C_TradeSkillUI.IsNPCCrafting() then
			self.SkillUps:Show();
			self.SkillUps.Text:SetText(recipeInfo.numSkillUps);
			self.SkillUps:SetScript("OnClick", OnClick);
			self.SkillUps:SetScript("OnEnter", function()
				self:OnEnter();

				GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
				GameTooltip_AddNormalLine(GameTooltip, SKILLUP_TOOLTIP:format(self.SkillUps.Text:GetText()));
				GameTooltip:Show();
			end);

			table.insert(rightFrames, self.SkillUps);
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
	
	local hasCount = recipeInfo.numAvailable > 0;
	if hasCount then
		self.Count:SetFormattedText("[%d] ", recipeInfo.numAvailable);
		self.Count:Show();
	else
		self.Count:Hide();
	end

	self:SetAlpha(recipeInfo.learned and 1.0 or .65);

	local padding = 10;
	local countWidth = hasCount and self.Count:GetStringWidth() or 0;
	local width = self:GetWidth() - (rightFramesWidth + countWidth + padding);
	self.Label:SetWidth(self:GetWidth());
	self.Label:SetWidth(math.min(width, self.Label:GetStringWidth()));
end

function ProfessionsRecipeListRecipeMixin:SetLabelFontObjects(fontObject)
	self.Label:SetFontObject(fontObject);
	self.Count:SetFontObject(fontObject);
end

function ProfessionsRecipeListRecipeMixin:SetDifficulty(difficulty)
	self.difficulty = difficulty;

	self:SetLabelFontObjects(GetDifficultyFont(difficulty));

	SetVertexColor(GetDifficultyColor(difficulty), self.Label, self.Count, self.SkillUps.Text, self.SkillUps.Icon, self.SelectedOverlay);
end

function ProfessionsRecipeListRecipeMixin:OnEnter()
	ProfessionsRecipeListElementMixin.OnEnter(self);
	
	self:SetLabelFontObjects(GameFontHighlightLeft);

	SetVertexColor(HIGHLIGHT_FONT_COLOR, self.Label, self.Count, self.SkillUps.Text, self.SkillUps.Icon);
end


function ProfessionsRecipeListRecipeMixin:OnLeave()
	ProfessionsRecipeListElementMixin.OnLeave(self);

	if not self.SelectedOverlay:IsShown() then
		self:SetLabelFontObjects(GetDifficultyFont(difficulty));

		SetVertexColor(GetDifficultyColor(self.difficulty), self.Label, self.Count, self.SkillUps.Text, self.SkillUps.Icon);
	end
end

function ProfessionsRecipeListRecipeMixin:SetSelected(selected)
	if selected then
		SetVertexColor(HIGHLIGHT_FONT_COLOR, self.Label, self.Count, self.SkillUps.Text, self.SkillUps.Icon);
		self.SelectedOverlay:Show();
	else
		SetVertexColor(GetDifficultyColor(self.difficulty), self.Label, self.Count, self.SkillUps.Text, self.SkillUps.Icon);
		self.SelectedOverlay:Hide();
	end
end