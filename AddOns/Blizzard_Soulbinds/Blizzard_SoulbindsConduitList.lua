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
	local categoryName = Soulbinds.GetConduitName(conduitType);
	self.Name:SetText(categoryName);
	self.Name:SetWidth(self.Name:GetStringWidth());

	local atlas = Soulbinds.GetConduitEmblemAtlas(conduitType);
	local useAtlasSize = false;
	self.ConduitIcon:SetAtlas(atlas, false);
	local scale = GetConduitIconScale(conduitType);
	self.ConduitIcon:SetScale(scale);
end

function ConduitListCategoryButtonMixin:OnEnter()
	for index, element in ipairs(self.Hovers) do
		element:Show();
	end
end

function ConduitListCategoryButtonMixin:OnLeave()
	for index, element in ipairs(self.Hovers) do
		element:Hide();
	end
	GameTooltip_Hide();
end

function ConduitListCategoryButtonMixin:OnMouseDown()
	-- TODO Category shifting
end

function ConduitListCategoryButtonMixin:OnMouseUp()
	-- TODO Category shifting
end

function ConduitListCategoryButtonMixin:OnClick(buttonName)
	self:SetExpanded(not self.expanded);
	self:TriggerEvent(ConduitListCategoryButtonMixin.Event.OnExpandedChanged, self.expanded);
end

function ConduitListCategoryButtonMixin:SetExpanded(expanded)
	self.expanded = expanded;

	local atlas = expanded and "Soulbinds_Collection_CategoryHeader_Collapse" or "Soulbinds_Collection_CategoryHeader_Expand";
	local useAtlasSize = true;
	self.ExpandableIcon:SetAtlas(atlas, useAtlasSize);
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

	local color = ITEM_QUALITY_COLORS[Enum.ItemQuality.Epic];
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

	self:SanitizeAvailability();
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

local ADD_CONDUIT_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(259, 2101299);

function ConduitListConduitButtonMixin:PlayUpdateAnimation()
	for index, glow in ipairs(self.Effects.Glows) do
		glow.Anim:Play();
	end

	-- Commented out until animation work is finished.
	--if not self.ModelScene.effect then
	--	local forceUpdate, stopAnim = true, true;
	--	self.ModelScene.effect = StaticModelInfo.SetupModelScene(self.ModelScene, ADD_CONDUIT_MODEL_SCENE_INFO, forceUpdate, stopAnim);
	--end
	--
	--self.ModelScene:SetDesaturation(1.0);
	--local MODEL_SCENE_ACTOR_SETTINGS = {["effect"] = { startDelay = 0.79, duration = 0.769, speed = 1 },};
	--self.ModelScene:ShowAndAnimateActors(MODEL_SCENE_ACTOR_SETTINGS);
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

function ConduitListConduitButtonMixin:SanitizeAvailability()
	self:UpdateVisuals(self:GetState());
end

function ConduitListConduitButtonMixin:GetState()
	local soulbindID = Soulbinds.GetOpenSoulbind();
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
		local soulbindID = Soulbinds.GetOpenSoulbind();
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
	if C_Soulbinds.IsConduitInstalledInSoulbind(Soulbinds.GetOpenSoulbind(), self.conduitData.conduitID) then
		return;
	end

	SetCursorVirtualItem(self.conduitData.conduitItemID, Enum.UICursorType.ConduitCollectionItem);
end

function ConduitListConduitButtonMixin:OnEnter(conduitData)
	local onConduitLoad = function()
		if self.conduitOnSpellLoadCb then
			self.conduitOnSpellLoadCb = nil;
		end

		GameTooltip:SetOwner(self.Icon, "ANCHOR_RIGHT");
		
		local conduitID = self.conduit:GetConduitID();
		GameTooltip:SetConduit(conduitID, self.conduit:GetConduitRank());

		local soulbindID = Soulbinds.GetOpenSoulbind();
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
		"OnContainerVisibilityChanged",
	}
);

function ConduitListSectionMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);

	self.pool = CreateFramePool("BUTTON", self.Container, "ConduitListConduitButtonTemplate");
	self.CategoryButton:RegisterCallback(ConduitListCategoryButtonMixin.Event.OnExpandedChanged, self.OnExpandedChanged, self);
end

function ConduitListSectionMixin:OnEnter()
	-- FIXME Forward button events to section.
end

function ConduitListSectionMixin:OnLeave()
	-- FIXME Forward button events to section.
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

function ConduitListSectionMixin:FindConduitbutton(conduitID)
	for conduitButton in self.pool:EnumerateActive() do
		if conduitButton:MatchesID(conduitID) then
			return conduitButton;
		end
	end
end

function ConduitListSectionMixin:AddCollectionData(collectionData)
	local conduitButton = self:FindConduitbutton(collectionData.conduitID);
	if conduitButton then
		conduitButton:PlayUpdateAnimation();
		return true;
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
	self:UpdateLayout();

	self:TriggerEvent(ConduitListSectionMixin.Event.OnContainerVisibilityChanged);
end

function ConduitListSectionMixin:UpdateLayout()
	self.Container:Layout();
	self:Layout();
end

ConduitListMixin = {};

local ConduitListEvents =
{
	"SOULBIND_CONDUIT_COLLECTION_UPDATED",
	"SOULBIND_CONDUIT_COLLECTION_REMOVED",
	"SOULBIND_CONDUIT_COLLECTION_CLEARED",
};

function ConduitListMixin:OnLoad()
	ScrollFrame_OnLoad(self);

	self.ScrollBar:ClearAllPoints();
	self.ScrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", -14, -51);
	self.ScrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", -14, 58);
	self.ScrollBar.doNotHide = true;

	for index, list in ipairs(self.ScrollChild.Lists) do
		list:RegisterCallback(ConduitListSectionMixin.Event.OnContainerVisibilityChanged, self.OnContainerVisibilityChanged, self);
	end
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

function ConduitListMixin:Init()
	for index, list in ipairs(self.ScrollChild.Lists) do
		list.layoutIndex = index;
		local populated = list:Init();
		list:SetShown(populated);
	end
	self.ScrollChild:Layout();
end

function ConduitListMixin:OnCollectionDataUpdated(collectionData)
	self:Init();
	
	local conduitID = collectionData.conduitID;
	for index, list in ipairs(self.ScrollChild.Lists) do
		if list:AddCollectionData(collectionData) then
			break;
		end
	end
end

function ConduitListMixin:OnContainerVisibilityChanged()
	self.ScrollChild:Layout();
end