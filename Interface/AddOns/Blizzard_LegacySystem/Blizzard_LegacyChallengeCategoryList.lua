
LegacyChallengeCategoryListMixin = CreateFromMixins(CallbackRegistryMixin);

function LegacyChallengeCategoryListMixin:IsCategorySelected(elementData)
	if not elementData or not elementData.categoryInfo then
		return false;
	end

	local categoryID = elementData.categoryInfo.id;
	if self.selectedInfo and (self.selectedInfo.id == categoryID) then
		return true;
	end

	-- A parent with no challenges of its own is never in the selection behavior, so track it separately.
	return elementData.isParent and (self.activeCollapsibleCategoryID == categoryID) or false;
end

function LegacyChallengeCategoryListMixin:RefreshCategorySelectionVisuals()
	self.ScrollBox:ForEachFrame(function(button)
		local elementData = button:GetData();
		if elementData then
			button:SetSelected(self:IsCategorySelected(elementData));
		end
	end);
end

function LegacyChallengeCategoryListMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	EventRegistry:RegisterCallback("Legacy.OpenToChallengeCategory", function(_, categoryID)
		local scrollToCategory = true;
		self:OpenToCategory(categoryID, scrollToCategory);
	end, self);

	local indent = 10;
	local padLeft = 0;
	local pad = 5;
	local spacing = 1;
	local view = CreateScrollBoxListTreeListView(indent, pad, pad, padLeft, pad, spacing);

	view:SetElementFactory(function(factory, node)
		local elementData = node:GetData();
		if elementData.categoryInfo then
			local function Initializer(button, node)
				local isSelected = self:IsCategorySelected(elementData);
				button:Init(node, isSelected);

				button:SetScript("OnClick", function(button, buttonName)
					local playInteractionSound = true;
					self:SelectCategory(elementData, node, button, playInteractionSound);
				end);
			end
			factory("LegacyChallengeCategoryTemplate", Initializer);
		end
	end);

	view:SetElementExtentCalculator(function(dataIndex, node)
		local elementData = node:GetData();
		local baseElementHeight = 20;
		local categoryPadding = 5;

		if elementData.categoryInfo then
			return baseElementHeight + categoryPadding;
		end

		if elementData.dividerHeight then
			return elementData.dividerHeight;
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
		if selected then
			local data = elementData:GetData();
			self.selectedInfo = data.categoryInfo;
			self.activeCollapsibleCategoryID = nil;

			EventRegistry:TriggerEvent("Legacy.SelectChallengeCategory", self.selectedInfo);
		end

		self:RefreshCategorySelectionVisuals();
	end;

	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);

	EventRegistry:RegisterCallback("Legacy.UnviewedChallengesUpdated", function()
		self.ScrollBox:ForEachFrame(function(button)
			button:RefreshNotificationIcon();
		end);
	end, self);
end

function LegacyChallengeCategoryListMixin:SelectCategory(elementData, node, button, playInteractionSound)
	if playInteractionSound then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end

	LegacyChallengeViewedUtil.MarkCategoryViewed(elementData.categoryInfo.id);

	if elementData.isParent then
		-- Set before clearing so the selection callback's refresh sees the new state.
		self.selectedInfo = nil;
		self.activeCollapsibleCategoryID = elementData.categoryInfo.id;
		self.selectionBehavior:ClearSelections();

		if not button then
			button = self.ScrollBox:FindFrame(elementData);
		end
		if not node then
			node = button:GetNode();
		end

		node:ToggleCollapsed();
		button:SetCollapseState(node:IsCollapsed());
		-- ClearSelections only fires the selection callback when something was selected.
		self:RefreshCategorySelectionVisuals();
	end

	if elementData.hasAchievements then
		self.selectionBehavior:Select(button);
	end
end

function LegacyChallengeCategoryListMixin:OpenToCategory(categoryID, scrollToCategory)
	local elementData = nil;
	local dataProvider = self.ScrollBox:GetDataProvider();
	if dataProvider then
		elementData = dataProvider:FindElementDataByPredicate(function(node)
			local data = node:GetData();
			local shouldSelect = data.categoryInfo and data.categoryInfo.id == categoryID;
			if shouldSelect then
				node:SetBranchCollapsed(false, false, false);

				EventRegistry:TriggerEvent("Legacy.RefreshCategoryButtonCollapseState");
			end
			return shouldSelect;
		end, TreeDataProviderConstants.IncludeCollapsed);
	end

	if elementData then
		LegacyChallengeViewedUtil.MarkCategoryViewed(categoryID);
		self.selectionBehavior:SelectElementData(elementData);
	end

	if scrollToCategory then
		self.ScrollBox:ScrollToElementData(elementData);
	end

	return elementData;
end

LegacyChallengeCategoryMixin = {};

function LegacyChallengeCategoryMixin:OnLoad()
	EventRegistry:RegisterCallback("Legacy.RefreshCategoryButtonCollapseState", function(_, info)
		self:RefreshButtonCollapseState();
	end, self);
end

function LegacyChallengeCategoryMixin:OnEnter()
	local isMouseOver = true;
	self:CheckHighlightTitle(isMouseOver);
end

function LegacyChallengeCategoryMixin:OnLeave()
	local isMouseOver = false;
	self:CheckHighlightTitle(isMouseOver);
end

function LegacyChallengeCategoryMixin:GetNode()
	return self.node;
end

function LegacyChallengeCategoryMixin:Init(node, selected)
	self.node = node;
	local elementData = node:GetData();
	local categoryInfo = elementData.categoryInfo;
	self:SetHeaderText(categoryInfo.name);

	self:SetCollapseState(node:IsCollapsed());

	local collapseButton = self:GetCollapseButton();
	local collapsable = elementData.isParent;
	self.collapsable = collapsable;
	collapseButton:SetShown(collapsable);
	self:RefreshCardArt();

	self.NotificationIcon:ClearAllPoints();
	if collapsable then
		self.NotificationIcon:SetPoint("RIGHT", collapseButton, "LEFT", -4, 0);
	else
		self.NotificationIcon:SetPoint("RIGHT", -10, 2);
	end

	self:RefreshNotificationIcon();

	self:SetSelected(selected);
end

-- Hovering is conveyed by the card art, so the highlight color matches the normal color.
function LegacyChallengeCategoryMixin:RefreshTitleColorState()
	local textColor;
	if self.selected then
		textColor = WHITE_FONT_COLOR;
	else
		textColor = NORMAL_FONT_COLOR;
	end

	self:SetTitleColor(false, textColor);
	self:SetTitleColor(true, textColor);
	self:CheckHighlightTitle(nil);
end

function LegacyChallengeCategoryMixin:RefreshCardArt()
	-- Leaf entries use the Legacy Challenge card art instead of the default list header art.
	local collapsable = self.collapsable;
	local selectedLeaf = (not collapsable) and self.selected;
	local normalAtlas = collapsable and "common-button-list-collapseExpand" or (selectedLeaf and "Legacy-Challenge-Left-Sub-Tab-selected" or "Legacy-Challenge-Left-Sub-Tab");
	local highlightAtlas = collapsable and "common-button-list-collapseExpand" or "Legacy-Challenge-Left-Sub-Tab-selected";

	self:GetNormalTexture():SetAtlas(normalAtlas, TextureKitConstants.UseAtlasSize);
	self:GetHighlightTexture():SetAtlas(highlightAtlas, TextureKitConstants.UseAtlasSize);
end

function LegacyChallengeCategoryMixin:RefreshNotificationIcon()
	local categoryInfo = self.node:GetData().categoryInfo;

	self.NotificationIcon:SetShown(LegacyChallengeViewedUtil.CategoryHasUnviewedChallenges(categoryInfo.id));
end

function LegacyChallengeCategoryMixin:RefreshButtonCollapseState()
	self:SetCollapseState(self.node:IsCollapsed());
end

function LegacyChallengeCategoryMixin:SetCollapseState(collapsed)
	self:GetCollapseButton():UpdateCollapsedState(collapsed);
end

function LegacyChallengeCategoryMixin:SetSelected(selected)
	self.selected = selected;
	self:RefreshTitleColorState();
	self:RefreshCardArt();
end
