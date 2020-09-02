local CONDUIT_PENDING_INSTALL_FONT_COLOR = CreateColor(0.0, 0.8, 1.0);

ConduitListCategoryButtonMixin = CreateFromMixins(CallbackRegistryMixin);

ConduitListCategoryButtonMixin:GenerateCallbackEvents(
	{
		"OnExpandedChanged",
	}
);

function ConduitListCategoryButtonMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self:SetExpanded(true);
end

local function GetConduitIconScale(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return 1.0;
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return 1.0;
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return 1.0;
	end
end

function ConduitListCategoryButtonMixin:Init(conduitType)
	local name = self.Container.Name;
	name:SetText(Soulbinds.GetConduitName(conduitType));
	name:SetWidth(name:GetStringWidth());

	local useAtlasSize = false;
	local icon = self.Container.ConduitIcon;
	icon:SetAtlas(Soulbinds.GetConduitEmblemAtlas(conduitType), false);
	icon:SetScale(GetConduitIconScale(conduitType));
end

function ConduitListCategoryButtonMixin:OnEnter()
	for index, element in ipairs(self.Container.Hovers) do
		element:Show();
	end
end

function ConduitListCategoryButtonMixin:OnLeave()
	for index, element in ipairs(self.Container.Hovers) do
		element:Hide();
	end
	GameTooltip_Hide();
end

function ConduitListCategoryButtonMixin:OnMouseDown()
	self.Container:AdjustPointsOffset(1, -1);
end

function ConduitListCategoryButtonMixin:OnMouseUp()
	self.Container:AdjustPointsOffset(-1, 1);
end

function ConduitListCategoryButtonMixin:OnClick(buttonName)
	self:SetExpanded(not self.expanded);
end

function ConduitListCategoryButtonMixin:SetExpanded(expanded)
	self.expanded = expanded;

	local atlas = expanded and "Soulbinds_Collection_CategoryHeader_Collapse" or "Soulbinds_Collection_CategoryHeader_Expand";
	local useAtlasSize = true;
	self.Container.ExpandableIcon:SetAtlas(atlas, useAtlasSize);

	self:TriggerEvent(ConduitListCategoryButtonMixin.Event.OnExpandedChanged, self.expanded);
end

function ConduitListCategoryButtonMixin:IsExpanded()
	return self.expanded;
end

ConduitListConduitButtonMixin = {};

ConduitListConduitButtonMixin.State =
{
	Uninstalled = 1,
	Installed = 2,
	Pending = 3,
}

ConduitListConduitButtonEvents = {
	"SOULBIND_PENDING_CONDUIT_CHANGED",
	"SOULBIND_CONDUIT_INSTALLED",
	"SOULBIND_CONDUIT_UNINSTALLED",
	"CURSOR_CHANGED",
};

function ConduitListConduitButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
end

function ConduitListConduitButtonMixin:Init(conduitData)
	self.conduitData = conduitData;
	self.conduit = SoulbindConduitMixin_Create(conduitData.conduitID, conduitData.conduitRank);

	local itemID = conduitData.conduitItemID;
	local item = Item:CreateFromItemID(itemID);
	local itemCallback = function()
		self.ConduitName:SetText(item:GetItemName());
	end;
	item:ContinueOnItemLoad(itemCallback);

	local icon = item:GetItemIcon();
	self.Icon:SetTexture(icon);
	self.Icon2:SetTexture(icon);

	local conduitQuality = C_Soulbinds.GetConduitQuality(conduitData.conduitID, conduitData.conduitRank);
	local color = ITEM_QUALITY_COLORS[conduitQuality];
	local r, g, b = color.r, color.g, color.b;
	self.IconOverlay:SetVertexColor(r, g, b);
	self.IconOverlay2:SetVertexColor(r, g, b);
	self.IconOverlayDark:SetVertexColor(0, 0, 0);
	self.ConduitName:SetTextColor(r, g, b);

	self.ConduitName:ClearAllPoints();
	local specName = conduitData.conduitSpecName;
	if specName then
		self.ConduitName:SetPoint("BOTTOMLEFT", self.Icon, "RIGHT", 10, -8);
		self.ConduitName:SetPoint("RIGHT");
		self.SpecName:SetText(specName);
	else
		self.ConduitName:SetPoint("LEFT", self.Icon, "RIGHT", 10, 0);
		self.ConduitName:SetPoint("RIGHT");
		self.SpecName:SetText("");
	end

	self:Update();
end

function ConduitListConduitButtonMixin:OnEvent(event, ...)
	if event == "SOULBIND_PENDING_CONDUIT_CHANGED" then
		local nodeID, conduitID, pending = ...;
		if conduitID == self.conduitData.conduitID then
			if pending then
				self:UpdateVisuals(ConduitListConduitButtonMixin.State.Pending);
			else
				self:UpdateVisuals(ConduitListConduitButtonMixin.State.Uninstalled);
			end
		end
	elseif event == "SOULBIND_CONDUIT_INSTALLED" then
		local nodeID, conduitData = ...;
		if conduitData.conduitID == self.conduitData.conduitID then
			self:UpdateVisuals(ConduitListConduitButtonMixin.State.Installed);
		end
	elseif event == "SOULBIND_CONDUIT_UNINSTALLED" then
		local nodeID, conduitData = ...;
		if conduitData.conduitID == self.conduitData.conduitID then
			self:UpdateVisuals(ConduitListConduitButtonMixin.State.Uninstalled);
		end
	elseif event == "CURSOR_CHANGED" then
		local conduitData = C_Soulbinds.GetConduitCollectionDataAtCursor();
		local pending = conduitData and conduitData.conduitID == self.conduitData.conduitID;
		self.PendingBackground:SetShown(pending);
	end
end

function ConduitListConduitButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ConduitListConduitButtonEvents);
end

function ConduitListConduitButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ConduitListConduitButtonEvents);
end

function ConduitListConduitButtonMixin:MatchesID(conduitID)
	return self.conduitData.conduitID == conduitID;
end

function ConduitListConduitButtonMixin:PlayUpdateAnimation()
	SoulbindViewer.ConduitList:PlayLearnAnimation(self);
end

function ConduitListConduitButtonMixin:UpdateVisuals(state)
	local installed = state == ConduitListConduitButtonMixin.State.Installed;
	local pending = state == ConduitListConduitButtonMixin.State.Pending;
	local dark = installed or pending;
	self.IconOverlayDark:SetShown(dark);
	self.IconDark:SetShown(dark);
	self.ConduitName:SetAlpha(dark and .5 or 1);
	self.SpecName:SetAlpha(dark and .5 or 1);
	
	self.Pending:SetShown(pending);
end

function ConduitListConduitButtonMixin:Update()
	self:UpdateVisuals(self:GetState());
end

function ConduitListConduitButtonMixin:GetState()
	local soulbindID = Soulbinds.GetOpenSoulbindID();
	local conduitID = self.conduitData.conduitID;
	local installed = C_Soulbinds.IsConduitInstalledInSoulbind(soulbindID, conduitID);
	if installed then
		return ConduitListConduitButtonMixin.State.Installed;
	end

	local pending = C_Soulbinds.HasPendingConduitInSoulbind(soulbindID, conduitID);
	if pending then
		return ConduitListConduitButtonMixin.State.Pending;
	end
	return ConduitListConduitButtonMixin.State.Uninstalled;
end

function ConduitListConduitButtonMixin:OnClick(buttonName)
	if buttonName == "LeftButton" then
		self:CreateCursor();
	elseif buttonName == "RightButton" then
		local soulbindID = Soulbinds.GetOpenSoulbindID();
		local conduitID = self.conduitData.conduitID;
		if C_Soulbinds.HasPendingConduitInSoulbind(soulbindID, conduitID) then
			local nodeID = C_Soulbinds.GetPendingNodeIDInSoulbind(soulbindID, conduitID);
			if nodeID > 0 then
				C_Soulbinds.RemovePendingConduit(nodeID);
			end
		end
	end
end

function ConduitListConduitButtonMixin:OnDragStart()
	self:CreateCursor();
end

function ConduitListConduitButtonMixin:CreateCursor()
	if C_Soulbinds.IsConduitInstalledInSoulbind(Soulbinds.GetOpenSoulbindID(), self.conduitData.conduitID) then
		return;
	end

	SetCursorVirtualItem(self.conduitData.conduitItemID, Enum.UICursorType.ConduitCollectionItem);
end

function ConduitListConduitButtonMixin:OnEnter(conduitData)
	local onConduitLoad = function()
		if self.conduitOnSpellLoadCb then
			self.conduitOnSpellLoadCb = nil;
		end

		GameTooltip:SetOwner(self.Icon, "ANCHOR_RIGHT", 190, 0);
		
		local conduitID = self.conduit:GetConduitID();
		GameTooltip:SetConduit(conduitID, self.conduit:GetConduitRank());

		local soulbindID = Soulbinds.GetOpenSoulbindID();
		if C_Soulbinds.IsConduitInstalledInSoulbind(soulbindID, conduitID) then
			GameTooltip_AddErrorLine(GameTooltip, CONDUIT_COLLECTION_ITEM_SOCKETED);
		elseif C_Soulbinds.HasPendingConduitInSoulbind(soulbindID, conduitID) then
			GameTooltip_AddColoredLine(GameTooltip, CONDUIT_COLLECTION_ITEM_PENDING, CONDUIT_PENDING_INSTALL_FONT_COLOR);
		end
		GameTooltip:Show();
	end;

	self.conduitOnSpellLoadCb = self.conduit:ContinueWithCancelOnSpellLoad(onConduitLoad);

	for index, element in ipairs(self.Hovers) do
		element:Show();
	end

	local conduitType = self.conduitData.conduitType;
	Soulbinds.SetPreviewConduitType(conduitType);
	SoulbindViewer:OnCollectionConduitEnter(conduitType);
end

function ConduitListConduitButtonMixin:OnLeave(collectionData)
	if self.conduitOnSpellLoadCb then
		self.conduitOnSpellLoadCb();
		self.conduitOnSpellLoadCb = nil;
	end

	GameTooltip_Hide();

	for index, element in ipairs(self.Hovers) do
		element:Hide();
	end
	
	Soulbinds.SetPreviewConduitType(nil);
	SoulbindViewer:OnCollectionConduitLeave();
end

ConduitListSectionMixin = CreateFromMixins(CallbackRegistryMixin);

ConduitListSectionMixin:GenerateCallbackEvents(
	{
		"OnCollapsibleChanged",
	}
);

function ConduitListSectionMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.pool = CreateFramePool("BUTTON", self.Container, "ConduitListConduitButtonTemplate");
	self.CategoryButton:RegisterCallback(ConduitListCategoryButtonMixin.Event.OnExpandedChanged, self.OnExpandedChanged, self);
end

function ConduitListSectionMixin:Init()
	local collection = C_Soulbinds.GetConduitCollection(self.conduitType);
	local isIndexTable = true;
	local activeCovenantID = C_Covenants.GetActiveCovenantID();
	local includeIf = function(collectionData)
		local covenantID = collectionData.covenantID;
		return not covenantID or covenantID == activeCovenantID;
	end;
	self.collection = tFilter(collection, includeIf, isIndexTable);

	table.sort(self.collection, function(a, b)
		local s1 = a.conduitSpecName or "";
		local s2 = b.conduitSpecName or "";
		local compare = strcmputf8i(s1, s2);
		if compare == 0 then
			return a.conduitRank < b.conduitRank;
		end
		return compare < 0;
	end);

	self.CategoryButton:Init(self.conduitType);

	return self:BuildConduits();
end

function ConduitListSectionMixin:Update()
	for conduitButton in self.pool:EnumerateActive() do
		conduitButton:Update();
	end
end

function ConduitListSectionMixin:FindConduitButton(conduitID)
	for conduitButton in self.pool:EnumerateActive() do
		if conduitButton:MatchesID(conduitID) then
			return conduitButton;
		end
	end
end

function ConduitListSectionMixin:AddCollectionData(collectionData)
	local conduitButton = self:FindConduitButton(collectionData.conduitID);
	if conduitButton then
		conduitButton:PlayUpdateAnimation();
		return true, conduitButton;
	end
	return false;
end

function ConduitListSectionMixin:BuildConduits()
	self.pool:ReleaseAll();

	local count = #self.collection;
	local function FactoryFunction(index)
		if index > count then
			return nil;
		end

		local frame = self.pool:Acquire();
		frame:Init(self.collection[index]);

		frame:SetPoint("LEFT", 0, 0);
		frame:SetPoint("RIGHT", 0, 0);
		frame:Show();
		return frame;
	end

	local anchor = AnchorUtil.CreateAnchor("TOPLEFT", self.Container, "TOPLEFT");
	local direction, stride, x, y = GridLayoutMixin.Direction.TopLeftToBottomRight, 1, 0, 1;
	local layout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY);
	AnchorUtil.GridLayoutFactoryByCount(FactoryFunction, count, anchor, layout);

	self:UpdateLayout();

	return count > 0;
end

function ConduitListSectionMixin:OnExpandedChanged(expanded)
	self.Container:SetShown(expanded);
	self.Spacer:SetShown(expanded);
	self:UpdateLayout();

	self:TriggerEvent(ConduitListSectionMixin.Event.OnCollapsibleChanged);
end

function ConduitListSectionMixin:UpdateLayout()
	self.Container:Layout();
	self:Layout();
end

function ConduitListSectionMixin:IsExpanded()
	return self.CategoryButton:IsExpanded();
end

function ConduitListSectionMixin:SetExpanded(expanded)
	self.CategoryButton:SetExpanded(expanded);
end

ConduitListMixin = {};

local ConduitListEvents =
{
	"SOULBIND_CONDUIT_COLLECTION_UPDATED",
	"SOULBIND_CONDUIT_COLLECTION_REMOVED",
	"SOULBIND_CONDUIT_COLLECTION_CLEARED",
};

function ConduitListMixin:OnLoad()
	for index, list in ipairs(self:GetLists()) do
		list:RegisterCallback(ConduitListSectionMixin.Event.OnCollapsibleChanged, self.OnCollapsibleChanged, self);
	end

	self.Clip:SetPoint("TOPLEFT", -200, 0);
	self.Clip:SetPoint("BOTTOMRIGHT", 200, 0);
end

function ConduitListMixin:OnEvent(event, ...)
	if event == "SOULBIND_CONDUIT_COLLECTION_UPDATED" then
		local collectionData = ...;
		self:OnCollectionDataUpdated(collectionData);
	elseif event == "SOULBIND_CONDUIT_COLLECTION_REMOVED" then
		self:Init();
	elseif event == "SOULBIND_CONDUIT_COLLECTION_CLEARED" then
		self:Init();
	end
end

function ConduitListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ConduitListEvents);
end

function ConduitListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ConduitListEvents);
end

function ConduitListMixin:GetLists()
	return self.ScrollBox.ScrollTarget.Lists;
end

function ConduitListMixin:Init()
	for index, list in ipairs(self:GetLists()) do
		list.layoutIndex = index;
		local populated = list:Init();
		list:SetShown(populated);
	end
	
	self.ScrollBox.ScrollTarget:Layout();

	local scrollValue = 0;
	local elementExtent = 41;
	ScrollUtil.Init(self.ScrollBar, self.ScrollBox, scrollValue, elementExtent);
end

function ConduitListMixin:Update()
	for index, list in ipairs(self:GetLists()) do
		list:Update();
	end
end

function ConduitListMixin:PlayLearnAnimation(button)
	local effects = self.Clip.Effects;
	effects:SetPoint("LEFT", button);
	for index, glow in ipairs(effects.Glows) do
		glow.Anim:Play();
	end

	local modelScene = self.Clip.ModelScene;
	if not modelScene.effect then
		local forceUpdate, stopAnim = true, true;
		local ADD_CONDUIT_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(259, 2101299);
		modelScene.effect = StaticModelInfo.SetupModelScene(modelScene, ADD_CONDUIT_MODEL_SCENE_INFO, forceUpdate, stopAnim);
	end
	
	modelScene:SetPoint("CENTER", button);
	local MODEL_SCENE_ACTOR_SETTINGS = {["effect"] = { startDelay=0, duration = 0.769, speed = 1 },};
	modelScene:ShowAndAnimateActors(MODEL_SCENE_ACTOR_SETTINGS);

	PlaySound(SOUNDKIT.SOULBINDS_CONDUIT_LEARNED);
end

function ConduitListMixin:OnCollectionDataUpdated(collectionData)
	self:Init();
	
	local conduitID = collectionData.conduitID;
	for index, list in ipairs(self:GetLists()) do
		local result, conduitButton = list:AddCollectionData(collectionData);
		if result then
			if not list:IsExpanded() then
				list:SetExpanded(true);
			end

			self.ScrollBox:ScrollTo(conduitButton);
			break;
		end
	end
end

function ConduitListMixin:OnCollapsibleChanged()
	self.ScrollBox.ScrollTarget:Layout();
end
