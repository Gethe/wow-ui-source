--------------------------------------------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;
tbl.SecureCapsuleGet = SecureCapsuleGet;

local function Import(name)
	tbl[name] = tbl.SecureCapsuleGet(name);
end

Import("IsOnGlueScreen");

if ( tbl.IsOnGlueScreen() ) then
	tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	Import("C_StoreGlue");
end

setfenv(1, tbl);
--------------------------------------------------

Import("TOOLTIP_DEFAULT_BACKGROUND_COLOR");
Import("IsTrialAccount");
Import("IsVeteranTrialAccount");
Import("bit");

StoreTooltipBackdropMixin = {};

function StoreTooltipBackdropMixin:StoreTooltipOnLoad()
	NineSliceUtil.DisableSharpening(self);

	local bgR, bgG, bgB = TOOLTIP_DEFAULT_BACKGROUND_COLOR:GetRGB();
	self:SetCenterColor(bgR, bgG, bgB, 1);
end


StoreBulletPointMixin = {};
function StoreBulletPointMixin:OnLoad()
	BulletPointWithTextureMixin.OnLoad(self);
	self.Text:SetFontObject("GameFontNormalMed1");
	self.Text:SetTextColor(1, 0.84, 0.55);
end

function StoreBulletPointMixin:OnHyperlinkEnter()
	local grandparent = self:GetParent():GetParent();
	local onEnterScript = grandparent:GetScript("OnEnter");
	if onEnterScript then
		onEnterScript(grandparent);
	end
end

function StoreBulletPointMixin:OnHyperlinkLeave()
	local grandparent = self:GetParent():GetParent();
	local onLeaveScript = grandparent:GetScript("OnLeave");
	if onLeaveScript then
		onLeaveScript(grandparent);
	end
end

function StoreBulletPointMixin:OnHyperlinkClick(link)
	local grandparent = self:GetParent():GetParent();
	if not grandparent:IsEnabled() then
		return;
	end
	GetURLIndexAndLoadURL(self, link);
end

local function SelectCategoryGroupID(groupID)
	StoreFrame_SetSelectedPageNum(1);
	StoreFrame_SetSelectedCategoryID(groupID);
	StoreFrame_SetCategory(groupID);
	StoreProductCard_UpdateAllStates();
end


CategoryTreeScrollContainerMixin = {};
function CategoryTreeScrollContainerMixin:OnLoad()
	self:RegisterEvent("STORE_PRODUCTS_UPDATED");

	local DefaultPad = 4;
	local DefaultSpacing = 2;
	local indent = 10;
	local view = CreateScrollBoxListTreeListView(indent, DefaultPad, DefaultPad, DefaultPad, DefaultPad, DefaultSpacing);

	local function ExpandParentOfChild(childNode, dataProvider)
		local childData = childNode:GetData();
		local parentGroupID = childData.parentGroupID;

		local collapsed = false;
		dataProvider:SetCollapsedByPredicate(collapsed, function(node)
			local data = node:GetData();
			return data.groupID == parentGroupID;
		end);
	end

	local function SetParentCollapsedState(node, button)
		if button.ParentIndicator then
			local childCount = node:GetSize();
			button.ParentIndicator:SetShown(childCount > 0);
			if node:IsCollapsed() then
				button.ParentIndicator:SetAtlas("Campaign_HeaderIcon_Closed");
				button.ParentIndicator:SetDesaturation(0);
			else
				button.ParentIndicator:SetAtlas("Campaign_HeaderIcon_Open");
				button.ParentIndicator:SetDesaturation(1);
			end
		end
	end

	local function CategoryInit(button, node)
		local data = node:GetData();
		local groupID = data.groupID;
		local productGroupInfo = C_StoreSecure.GetProductGroupInfo(groupID);
		local isTopLevelCategory = data.parentGroupID == 0;

		if isTopLevelCategory then
			button.Icon:SetTexture(productGroupInfo.texture);
			SetParentCollapsedState(node, button);
		end
		button.Text:SetText(productGroupInfo.groupName);		

		local disabled = StoreFrame_IsProductGroupDisabled(groupID);
		button:SetEnabled(not disabled);
		button.Category:SetDesaturated(disabled);
		button.Text:SetFontObject(disabled and "GameFontDisable" or "GameFontNormal");
		if isTopLevelCategory then
			button.Icon:SetDesaturated(disabled);
			button.IconFrame:SetDesaturated(disabled);
		end
				
		local enabledForTrial = bit.band(productGroupInfo.flags, Enum.BattlepayProductGroupFlag.EnabledForTrial) == Enum.BattlepayProductGroupFlag.EnabledForTrial;
		local enabledForVeteran = bit.band(productGroupInfo.flags, Enum.BattlepayProductGroupFlag.EnabledForVeteran) == Enum.BattlepayProductGroupFlag.EnabledForVeteran;
		if IsTrialAccount() and not enabledForTrial then
			button.disabledTooltip = STORE_CATEGORY_TRIAL_DISABLED_TOOLTIP;
		elseif IsVeteranTrialAccount() and not enabledForVeteran then
			button.disabledTooltip = STORE_CATEGORY_VETERAN_DISABLED_TOOLTIP;
		elseif disabled then
			button.disabledTooltip = productGroupInfo.disabledTooltip;
		else
			button.disabledTooltip = nil;
		end

		button.SelectedTexture:SetShown(false);
		if self.selectionBehavior:IsElementDataSelected(node) then
			button.SelectedTexture:SetShown(true);
		else
			local selectedNode = self.selectionBehavior:GetFirstSelectedElementData();
			if selectedNode then
				local selectedData = selectedNode:GetData();
				if selectedData.parentGroupID == groupID then
					button.SelectedTexture:SetShown(true);
				end
			end
		end

		button:SetScript("OnClick", function(button, buttonName)
			local node = button:GetElementData();
			local data = node:GetData();

			local firstNode = node:GetFirstNode();
			if firstNode then
				local dataProvider = self.ScrollBox:GetDataProvider();
				self:ExpandSelectFirstChild(node, dataProvider);
			else
				self.selectionBehavior:ToggleSelectElementData(node);
			end
			PlaySound(SOUNDKIT.UI_IG_STORE_PAGE_NAV_BUTTON);
		end);
		button:SetScript("OnEnter", function(button)
			if button.disabledTooltip then
	 			StoreTooltip:ClearAllPoints();
				StoreTooltip:SetPoint("BOTTOMLEFT", button, "TOPRIGHT");
				StoreTooltip_Show("", button.disabledTooltip);
			else
				button.HighlightTexture:Show();
			end
		end);
		button:SetScript("OnLeave", function(button)
			button.HighlightTexture:Hide();
			StoreTooltip:Hide();
		end);
	end

	view:SetElementFactory(function(factory, node)
		local data = node:GetData();
		local categoryTemplate = data.parentGroupID == 0 and "StoreCategoryTemplate" or "StoreSubCategoryTemplate";
		factory(categoryTemplate, CategoryInit);
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local function OnSelectionChanged(o, node, selected)
		local dataProvider = self.ScrollBox:GetDataProvider();
		local button = self.ScrollBox:FindFrame(node);
		if button then
			local childCount = node:GetSize();
			local data = node:GetData();
			local parentGroupID = data.parentGroupID;

			if childCount == 0 then				
				if selected then
					if parentGroupID > 0 then
						ExpandParentOfChild(node, dataProvider);
					else
						dataProvider:CollapseAll();
					end
					SelectCategoryGroupID(data.groupID);
				end				
			else
				if selected then
					if parentGroupID == 0 then
						self:ExpandSelectFirstChild(node, dataProvider);
					else
						ExpandParentOfChild(node, dataProvider);
						SelectCategoryGroupID(data.groupID);
					end
				end
			end
			if selected then
				for _, frame in self.ScrollBox:EnumerateFrames() do
					frame.SelectedTexture:SetShown(false);
				end
				button.SelectedTexture:SetShown(true);

				local parentNode = node.parent;
				local parentFrame = self.ScrollBox:FindFrame(parentNode);
				if parentFrame then
					parentFrame.SelectedTexture:SetShown(true);
				end
			end
			for _, frame in self.ScrollBox:EnumerateFrames() do
				local node = frame:GetElementData();
				SetParentCollapsedState(node, frame);
			end
		end
	end;
	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);	
end

function CategoryTreeScrollContainerMixin:ExpandSelectFirstChild(node, dataProvider)
	node:SetCollapsed(false);
	local parentFrame = self.ScrollBox:FindFrame(node);	
	parentFrame.ParentIndicator:SetAtlas("Campaign_HeaderIcon_Open");

	local firstChildNode = node.nodes[1];
	self.selectionBehavior:SelectElementData(firstChildNode);
	local data = firstChildNode:GetData();
	SelectCategoryGroupID(data.groupID);
end

function CategoryTreeScrollContainerMixin:OnHide()
	StoreFrame_SetSelectedCategoryID(nil);
	self.selectionBehavior:ClearSelections();
	self.ScrollBox:RemoveDataProvider();
end

function CategoryTreeScrollContainerMixin:OnEvent(event, ...)
	if event == "STORE_PRODUCTS_UPDATED" then
		self:UpdateCategories();

		local dataProvider = self.ScrollBox:GetDataProvider();
		local childrenNodes = dataProvider:GetChildrenNodes();
		local node = dataProvider:GetFirstChildNode();

		-- If a category has already been selected (e.g. via UpgradeAccount), use that.
		-- Otherwise, use the first node.
		for idx, child in ipairs(childrenNodes) do
			if(child.data and child.data.groupID == StoreFrame_GetSelectedCategoryID()) then
				node = child;
				break;
			end
		end

		if node then
			local firstNode = node:GetFirstNode();
			if firstNode then
				self:ExpandSelectFirstChild(node, dataProvider);
			else
				self.selectionBehavior:ToggleSelectElementData(node);
			end
		end
	end
end

local function HasProductGroupChildren(groupID, productGroups)
	for _, productGroup in ipairs(productGroups) do
		if productGroup and productGroup.parentGroupID == groupID then
			return true;
		end
	end
	return false;
end

local function FindParentProductGroup(parentGroupID, productGroups)
	for _, productGroup in ipairs(productGroups) do
		if productGroup and productGroup.groupID == parentGroupID then
			return productGroup;
		end
	end
	return nil;
end

function CategoryTreeScrollContainerMixin:UpdateCategories()
	local productGroups = C_StoreSecure.GetProductGroups();
	local dataProvider = CreateTreeDataProvider();
	local productGroupMap = {};
	for _, productGroup in ipairs(productGroups) do
		local groupID = productGroup.groupID;
		local validCategory = (#StoreFrame_FilterEntries(C_StoreSecure.GetProducts(groupID)) ~= 0) or HasProductGroupChildren(groupID, productGroups);

		if validCategory then
			local parentGroupID = productGroup.parentGroupID;
			local hasParent = parentGroupID > 0;
			if hasParent then
				local parentProductGroup = 	FindParentProductGroup(parentGroupID, productGroups);
				parentGroupEntry = productGroupMap[parentGroupID];
				if not parentGroupEntry and parentProductGroup then
					productGroupMap[parentGroupID] = parentProductGroup;
					dataProvider:Insert(parentProductGroup);
					parentGroupEntry = productGroupMap[parentGroupID];
				end

				if parentGroupEntry then
					local parentGroup = productGroupMap[parentGroupID];
					if not parentGroup.children then
						parentGroup.children = {};
					end
					parentGroup.children[groupID] = productGroup;

					dataProvider:InsertInParentByPredicate(productGroup, function(node)
						local data = node:GetData();
						return data.groupID == parentGroupID;
					end);
				end
			else
				if productGroupMap[groupID] == nil then
					productGroupMap[groupID] = productGroup;
					dataProvider:Insert(productGroup);
				end
			end
		end
	end
	self.ScrollBox:SetDataProvider(dataProvider);
end
