local ROOT_CATEGORY_ID = -1;

local function BuildOrderedCategoryIDs(source)
	local orderedEntries = {};
	for key, value in next, source do
		if value and type(key) == "number" then
			tinsert(orderedEntries, { index = key, id = value });
		end
	end

	table.sort(orderedEntries, function(left, right)
		return left.index < right.index;
	end);

	local orderedIDs = {};
	for _, entry in ipairs(orderedEntries) do
		tinsert(orderedIDs, entry.id);
	end

	return orderedIDs;
end

local function BuildCategoryEntriesFromSource(sourceCategories)
	local categoryEntries = {};
	local orderedSourceCategories = BuildOrderedCategoryIDs(sourceCategories);
	local rootCategoryIDs = {};
	local childCategoryIDsByParentID = {};

	for _, categoryID in ipairs(orderedSourceCategories) do
		local _, parentCategoryID = GetCategoryInfo(categoryID);
		if parentCategoryID == ROOT_CATEGORY_ID then
			tinsert(rootCategoryIDs, categoryID);
		else
			childCategoryIDsByParentID[parentCategoryID] = childCategoryIDsByParentID[parentCategoryID] or {};
			tinsert(childCategoryIDsByParentID[parentCategoryID], categoryID);
		end
	end

	-- Walking children from a parent index guarantees deep descendants are emitted once their parent is emitted.
	local emittedCategoryIDs = {};
	local function AddCategoryAndChildren(categoryID, parentCategoryID, isChild)
		if emittedCategoryIDs[categoryID] then
			return;
		end

		emittedCategoryIDs[categoryID] = true;
		tinsert(categoryEntries, {
			categoryID = categoryID,
			parentCategoryID = parentCategoryID,
			isChild = isChild,
		});

		local childCategoryIDs = childCategoryIDsByParentID[categoryID];
		if childCategoryIDs then
			for _, childCategoryID in ipairs(childCategoryIDs) do
				AddCategoryAndChildren(childCategoryID, categoryID, true);
			end
		end
	end

	for _, rootCategoryID in ipairs(rootCategoryIDs) do
		AddCategoryAndChildren(rootCategoryID, nil, false);
	end

	return categoryEntries;
end

StatisticsFrameMixin = {};

function StatisticsFrameMixin:OnLoad()
	local indent = 20;
	local padding = 10;
	local elementSpacing = 3;
	local view = CreateScrollBoxListTreeListView(indent, padding, padding, padding, padding, elementSpacing);

	local function Initializer(button, treeNode)
		button:Initialize(treeNode);
	end

	view:SetElementFactory(function(factory, treeNode)
		local elementData = treeNode:GetData();
		if not elementData.isCategory then
			factory("StatisticsEntryTemplate", Initializer);
		elseif treeNode:GetDepth() > 1 then
			factory("StatisticsSubHeaderTemplate", Initializer);
		else
			factory("StatisticsHeaderTemplate", Initializer);
		end
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	CharacterFrame.ModeTabs.StatisticsTab:SetShown(true);
	CharacterFrame:UpdateTabLayout();
end

function StatisticsFrameMixin:OnShow()
	self:RegisterEvent("CRITERIA_UPDATE");
	self:Update();
end

function StatisticsFrameMixin:OnHide()
	self:UnregisterEvent("CRITERIA_UPDATE");
end

function StatisticsFrameMixin:OnEvent(event, ...)
	if event == "CRITERIA_UPDATE" then
		self:Update();
	end
end

function StatisticsFrameMixin:BuildCategoryData()
	local rawStatisticCategories = GetStatisticsCategoryList();
	local categoryEntries = BuildCategoryEntriesFromSource(rawStatisticCategories);
	return categoryEntries;
end

function StatisticsFrameMixin:AppendStatisticRows(categoryNode, categoryEntry)
	local numStats = GetCategoryNumAchievements(categoryEntry.categoryID);
	for statIndex = 1, numStats do
		local quantity, skip, statID = GetStatistic(categoryEntry.categoryID, statIndex);
		if not skip and statID then
			local statName = select(2, GetAchievementInfo(statID));

			local value = tonumber(quantity);
			local valueText;
			if value and value > 0 then
				valueText = tostring(value);
			else
				valueText = "--";
			end

			categoryNode:Insert({
				isCategory = false,
				statID = statID,
				name = statName or UNKNOWN,
				value = valueText,
			});
		end
	end
end

function StatisticsFrameMixin:Update()
	self.categoryEntries = self:BuildCategoryData();

	local dataProvider = CreateTreeDataProvider();
	local categoryNodesByID = {};

	for _, categoryEntry in ipairs(self.categoryEntries) do
		local categoryName = GetCategoryInfo(categoryEntry.categoryID);
		local categoryData = {
			isCategory = true,
			categoryID = categoryEntry.categoryID,
			name = categoryName or UNKNOWN,
			parentCategoryID = categoryEntry.parentCategoryID,
		};

		local parentNode = categoryEntry.parentCategoryID and categoryNodesByID[categoryEntry.parentCategoryID];
		local categoryNode;
		if parentNode then
			categoryNode = parentNode:Insert(categoryData);
		else
			categoryNode = dataProvider:Insert(categoryData);
		end

		categoryNodesByID[categoryEntry.categoryID] = categoryNode;
		self:AppendStatisticRows(categoryNode, categoryEntry);
	end

	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

local function ShowTooltipIfTextIsTruncated(owner, nameRegion)
	if not nameRegion:IsTruncated() then
		return;
	end

	local text = nameRegion:GetText();
	if not text or text == "" then
		return;
	end

	GameTooltip:SetOwner(owner, "ANCHOR_RIGHT");
	GameTooltip:SetText(text);
	GameTooltip:Show();
end

local function HideTooltip(owner)
	if GameTooltip:GetOwner() == owner then
		GameTooltip_Hide();
	end
end

StatisticsHeaderMixin = {};

function StatisticsHeaderMixin:Initialize(elementData)
	self.treeNode = elementData;
	self.elementData = elementData:GetData();
	self.Name:SetText(self.elementData.name);
	self:RefreshStateIcon();
end

function StatisticsHeaderMixin:RefreshStateIcon()
	local atlas = self.treeNode:IsCollapsed() and "common-button-list-plus" or "common-button-list-minus";
	self.StateIcon:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);
end

function StatisticsHeaderMixin:OnMouseDown()
	self.Name:AdjustPointsOffset(1, -1);
end

function StatisticsHeaderMixin:OnMouseUp()
	self.Name:AdjustPointsOffset(-1, 1);
end

function StatisticsHeaderMixin:OnClick()
	self.treeNode:ToggleCollapsed(TreeDataProviderConstants.RetainChildCollapse, TreeDataProviderConstants.DoInvalidation);
	self:RefreshStateIcon();
end

function StatisticsHeaderMixin:OnEnter()
	ShowTooltipIfTextIsTruncated(self, self.Name);
end

function StatisticsHeaderMixin:OnLeave()
	HideTooltip(self);
end

StatisticsEntryMixin = {};

function StatisticsEntryMixin:OnLoad()
	self.Content.BackgroundHighlight:SetFrameLevel(self:GetFrameLevel() - 1);
end

function StatisticsEntryMixin:Initialize(elementData)
	self.treeNode = elementData;
	self.elementData = elementData:GetData();

	self.Content.Name:SetText(self.elementData.name);
	self.Content.Value:SetText(self.elementData.value or "--");

	self:RefreshHighlightVisuals();
end

function StatisticsEntryMixin:OnClick()
end

function StatisticsEntryMixin:OnMouseDown()
	self.Content:AdjustPointsOffset(1, -1);
end

function StatisticsEntryMixin:OnMouseUp()
	self.Content:AdjustPointsOffset(-1, 1);
end

function StatisticsEntryMixin:OnEnter()
	self:RefreshHighlightVisuals();
	ShowTooltipIfTextIsTruncated(self, self.Content.Name);
end

function StatisticsEntryMixin:OnLeave()
	self:RefreshHighlightVisuals();
	HideTooltip(self);
end

function StatisticsEntryMixin:RefreshHighlightVisuals()
	self:RefreshBackgroundHighlight();
end

function StatisticsEntryMixin:RefreshBackgroundHighlight()
	self:RefreshBackgroundHighlightColor();
	self:RefreshBackgroundHighlightOpacity();
end

function StatisticsEntryMixin:RefreshBackgroundHighlightColor()
	for _, region in ipairs(self.Content.BackgroundHighlight.TextureRegions) do
		region:SetVertexColor(WHITE_FONT_COLOR:GetRGB());
	end
end

function StatisticsEntryMixin:RefreshBackgroundHighlightOpacity()
	self.Content.BackgroundHighlight:SetAlpha(self:IsMouseOver() and 0.10 or 0);
end

StatisticsSubHeaderMixin = CreateFromMixins(StatisticsEntryMixin);

function StatisticsSubHeaderMixin:Initialize(elementData)
	StatisticsEntryMixin.Initialize(self, elementData);

	self.Content.Value:SetText("");
	self.Content.Name:ClearAllPoints();
	self.Content.Name:SetPoint("LEFT", self.ToggleCollapseButton, "RIGHT", 4, 0);
	self.Content.Name:SetPoint("RIGHT", self.Content, "RIGHT", -24, 0);

	self.ToggleCollapseButton:RefreshIcon();
end

function StatisticsSubHeaderMixin:OnClick()
	self.treeNode:ToggleCollapsed(TreeDataProviderConstants.RetainChildCollapse, TreeDataProviderConstants.DoInvalidation);
	self.ToggleCollapseButton:RefreshIcon();
end

StatisticsSubHeaderToggleCollapseButtonMixin = {};

function StatisticsSubHeaderToggleCollapseButtonMixin:GetHeader()
	return self:GetParent();
end

function StatisticsSubHeaderToggleCollapseButtonMixin:RefreshIcon()
	local header = self:GetHeader();
	local isCollapsed = header.treeNode:IsCollapsed();
	self:GetNormalTexture():SetAtlas(isCollapsed and "campaign_headericon_closed" or "campaign_headericon_open", TextureKitConstants.UseAtlasSize);
	self:GetPushedTexture():SetAtlas(isCollapsed and "campaign_headericon_closedpressed" or "campaign_headericon_openpressed", TextureKitConstants.UseAtlasSize);
end

function StatisticsSubHeaderToggleCollapseButtonMixin:OnClick()
	local header = self:GetHeader();
	header.treeNode:ToggleCollapsed(TreeDataProviderConstants.RetainChildCollapse, TreeDataProviderConstants.DoInvalidation);
	self:RefreshIcon();
end
