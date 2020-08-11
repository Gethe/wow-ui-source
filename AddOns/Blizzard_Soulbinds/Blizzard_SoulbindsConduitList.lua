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

ConduitListConduitButtonMixin = CreateFromMixins(CallbackRegistryMixin);

ConduitListConduitButtonMixin:GenerateCallbackEvents(
	{
		"OnEnter",
		"OnLeave",
	}
);
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

end

function ConduitListConduitButtonMixin:MatchesID(conduitID)
	return self.conduitData.conduitID == conduitID;
end

local ADD_CONDUIT_MODEL_SCENE_INFO = StaticModelInfo.CreateModelSceneEntry(259, 2101299);

function ConduitListConduitButtonMixin:PlayUpdateAnimation()
	for index, glow in ipairs(self.Effects.Glows) do
		glow.Anim:Play();
	end

	if not self.ModelScene.effect then
		local forceUpdate, stopAnim = true, true;
		self.ModelScene.effect = StaticModelInfo.SetupModelScene(self.ModelScene, ADD_CONDUIT_MODEL_SCENE_INFO, forceUpdate, stopAnim);
	end

	self.ModelScene:SetDesaturation(1.0);
	local MODEL_SCENE_ACTOR_SETTINGS = {["effect"] = { startDelay = 0.79, duration = 0.769, speed = 1 },};
	self.ModelScene:ShowAndAnimateActors(MODEL_SCENE_ACTOR_SETTINGS);
end

function ConduitListConduitButtonMixin:OnClick(buttonName)
	self:CreateCursor();
end

function ConduitListConduitButtonMixin:OnDragStart()
	self:CreateCursor();
end

function ConduitListConduitButtonMixin:OnDragStop()
end

function ConduitListConduitButtonMixin:CreateCursor()
	local conduitCollectionCursor = 20; -- FIXME tagify
	SetCursorVirtualItem(self.conduitData.conduitItemID, conduitCollectionCursor);
end

function ConduitListConduitButtonMixin:OnEnter(conduitData)
	local onConduitLoad = function()
		GameTooltip:SetOwner(self.Icon, "ANCHOR_RIGHT");
		GameTooltip:SetConduit(self.conduit:GetConduitID(), self.conduit:GetRank()); 
		GameTooltip:Show();
	end;
	self.conduit:ContinueOnSpellLoad(onConduitLoad);

	for index, element in ipairs(self.Hovers) do
		element:Show();
	end

	-- FIXME
	--self:TriggerEvent(ConduitListConduitButtonMixin.Event.OnEnter);
	SoulbindViewer:OnCollectionConduitEnter(self.conduitData.conduitType);
end

function ConduitListConduitButtonMixin:OnLeave(collectionData)
	GameTooltip_Hide();

	for index, element in ipairs(self.Hovers) do
		element:Hide();
	end
	
	-- FIXME
	--self:TriggerEvent(ConduitListConduitButtonMixin.Event.OnLeave);
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

function ConduitListSectionMixin:Init(conduitType)
	local collection = C_Soulbinds.GetConduitCollection(conduitType);
	local isIndexTable = true;
	local activeCovenantID = C_Covenants.GetActiveCovenantID();
	local includeIf = function(collectionData)
		local covenantID = collectionData.covenantID;
		return not covenantID or covenantID == activeCovenantID and collectionData.conduitID > 3; -- conduitID > 3 temp
	end;
	self.collection = tFilter(collection, includeIf, isIndexTable)
	self.CategoryButton:Init(conduitType);

	self:BuildConduits();
end

function ConduitListSectionMixin:FindConduitbutton(conduitID)
	for conduitButton in self.pool:EnumerateActive() do
		if conduitButton:MatchesID(conduitID) then
			return conduitButton;
		end
	end
	return false;
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
	end
end

function ConduitListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ConduitListEvents);
end

function ConduitListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ConduitListEvents);
end

function ConduitListMixin:Init()
	self.ScrollChild.Potency:Init(Enum.SoulbindConduitType.Potency);
	self.ScrollChild.Endurance:Init(Enum.SoulbindConduitType.Endurance);
	self.ScrollChild.Finesse:Init(Enum.SoulbindConduitType.Finesse);
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