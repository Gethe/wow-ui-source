local CONDUIT_PENDING_INSTALL_FONT_COLOR = CreateColor(0.0, 0.8, 1.0);

ConduitListCategoryButtonMixin = {};

local function GetConduitIconScale(conduitType)
	if conduitType == Enum.SoulbindConduitType.Potency then
		return 1.0;
	elseif conduitType == Enum.SoulbindConduitType.Endurance then
		return 1.0;
	elseif conduitType == Enum.SoulbindConduitType.Finesse then
		return 1.0;
	end
end

function ConduitListCategoryButtonMixin:Init(conduitType, collapsed)
	local name = self.Container.Name;
	name:SetText(Soulbinds.GetConduitName(conduitType));
	name:SetWidth(name:GetStringWidth() + 40);

	local icon = self.Container.ConduitIcon;
	icon:SetAtlas(Soulbinds.GetConduitEmblemAtlas(conduitType));
	icon:SetScale(GetConduitIconScale(conduitType));
	icon:SetPoint("LEFT", name, "RIGHT", -40, -1);

	self.collapsed = collapsed;
	self:SetCollapsedVisuals(collapsed);
end

function ConduitListCategoryButtonMixin:OnEnter()
	for index, texture in ipairs(self.Container.Hovers) do
		texture:Show();
	end
end

function ConduitListCategoryButtonMixin:OnLeave()
	for index, texture in ipairs(self.Container.Hovers) do
		texture:Hide();
	end
	GameTooltip_Hide();
end

function ConduitListCategoryButtonMixin:OnMouseDown()
	self.Container:AdjustPointsOffset(1, -1);
end

function ConduitListCategoryButtonMixin:OnMouseUp()
	self.Container:AdjustPointsOffset(-1, 1);
end

function ConduitListCategoryButtonMixin:SetCollapsedVisuals(collapsed)
	if collapsed then
		self.Container.ExpandableIcon:SetAtlas("Soulbinds_Collection_CategoryHeader_Expand", TextureKitConstants.UseAtlasSize);
	else
		self.Container.ExpandableIcon:SetAtlas("Soulbinds_Collection_CategoryHeader_Collapse", TextureKitConstants.UseAtlasSize);
	end
end

function ConduitListCategoryButtonMixin:SetCollapsed(collapsed)
	local changed = self.collapsed ~= collapsed;
	if not changed then
		return;
	end
	self.collapsed = collapsed;

	if collapsed then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF, nil, SOUNDKIT_ALLOW_DUPLICATES);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end

	self:SetCollapsedVisuals(collapsed);
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
		self.ConduitName:SetSize(150, 30);
		self.ConduitName:SetText(item:GetItemName());
		self.ConduitName:SetHeight(self.ConduitName:GetStringHeight());
		
		local yOffset = self.ConduitName:GetNumLines() > 1 and -6 or 0;
		self.ConduitName:ClearAllPoints();
		self.ConduitName:SetPoint("BOTTOMLEFT", self.Icon, "RIGHT", 10, yOffset);
		self.ConduitName:SetWidth(150);

		self.ItemLevel:SetPoint("TOPLEFT", self.ConduitName, "BOTTOMLEFT", 0, 0);
		self.ItemLevel:SetText(conduitData.conduitItemLevel);
	end;
	item:ContinueOnItemLoad(itemCallback);

	local icon = item:GetItemIcon();
	self.Icon:SetTexture(icon);
	self.Icon2:SetTexture(icon);
	self.IconPulse:SetTexture(icon);

	local conduitQuality = C_Soulbinds.GetConduitQuality(conduitData.conduitID, conduitData.conduitRank);
	local color = ITEM_QUALITY_COLORS[conduitQuality];
	local r, g, b = color.r, color.g, color.b;
	self.IconOverlay:SetVertexColor(r, g, b);
	self.IconOverlay2:SetVertexColor(r, g, b);
	self.IconOverlayDark:SetVertexColor(0, 0, 0);
	self.ConduitName:SetTextColor(r, g, b);

	local conduitSpecName = conduitData.conduitSpecName;
	if conduitSpecName then
		local specIDs = C_SpecializationInfo.GetSpecIDs(conduitData.conduitSpecSetID);
		self.Spec.Icon:SetTexture(select(4, GetSpecializationInfoByID(specIDs[1])));

		local isCurrentSpec = C_SpecializationInfo.MatchesCurrentSpecSet(conduitData.conduitSpecSetID);
		if isCurrentSpec then
			self.Spec.stateAlpha = 1;
			self.Spec.stateAtlas = "soulbinds_collection_specborder_primary";
			self.ItemLevel:SetTextColor(WHITE_FONT_COLOR:GetRGB());
		else
			self.Spec.stateAlpha = .4;
			self.Spec.stateAtlas = "soulbinds_collection_specborder_secondary";
			self.ItemLevel:SetTextColor(GRAY_FONT_COLOR:GetRGB());
		end
		self.Spec.Icon:SetAlpha(self.Spec.stateAlpha);

		self.Spec:SetScript("OnEnter", function()
			GameTooltip:SetOwner(self.Spec, "ANCHOR_RIGHT");
			GameTooltip_AddHighlightLine(GameTooltip, conduitSpecName);
			GameTooltip:Show();
		end);
		self.Spec:SetScript("OnLeave", function()
			GameTooltip_Hide();
		end);
		self.Spec:Show();
	else
		self.ItemLevel:SetTextColor(WHITE_FONT_COLOR:GetRGB());
		self.Spec:Hide();
		self.Spec:SetScript("OnEnter", nil);
		self.Spec:SetScript("OnLeave", nil);
		self.Spec.stateAlpha = 1;
		self.Spec.stateAtlas = "soulbinds_collection_specborder_primary";
	end

	self:Update();
end

function ConduitListConduitButtonMixin:OnEvent(event, ...)
	if event == "SOULBIND_PENDING_CONDUIT_CHANGED" then
		local nodeID, conduitID = ...;
		self:Update();
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
	self.ConduitName:SetAlpha(dark and .5 or 1);
	self.ItemLevel:SetAlpha(dark and .2 or 1);
	self.IconOverlayDark:SetShown(dark);
	self.IconDark:SetShown(dark);
	
	local specIconAlpha = dark and .2 or self.Spec.stateAlpha;
	local specIconAtlas = dark and "soulbinds_collection_specborder_tertiary" or self.Spec.stateAtlas;
	self.Spec.IconOverlay:SetAtlas(specIconAtlas, TextureKitConstants.UseAtlasSize);
	self.Spec.Icon:SetAlpha(specIconAlpha);
	self.Pending:SetShown(pending);
end

function ConduitListConduitButtonMixin:Update()
	self:UpdateVisuals(self:GetState());
end

function ConduitListConduitButtonMixin:GetState()
	local soulbindID = Soulbinds.GetOpenSoulbindID();
	local conduitID = self.conduitData.conduitID;
	
	local pendingInstallNodeID = C_Soulbinds.FindNodeIDPendingInstall(soulbindID, conduitID);
	if pendingInstallNodeID > 0 then
		return ConduitListConduitButtonMixin.State.Pending;
	end

	local pendingUninstallNodeID = C_Soulbinds.FindNodeIDPendingUninstall(soulbindID, conduitID);
	if pendingUninstallNodeID > 0 then
		return ConduitListConduitButtonMixin.State.Uninstalled;
	end

	local installed = C_Soulbinds.IsConduitInstalledInSoulbind(soulbindID, conduitID);
	if installed then
		return ConduitListConduitButtonMixin.State.Installed;
	end

	return ConduitListConduitButtonMixin.State.Uninstalled;
end

function ConduitListConduitButtonMixin:OnClick(buttonName)
	if buttonName == "LeftButton" then
		local linked = false;
		if IsModifiedClick("CHATLINK") then
			linked = HandleModifiedItemClick(self.conduit:GetHyperlink());
		end

		if not linked then
			self:CreateCursor();
		end
	elseif buttonName == "RightButton" then
		local soulbindID = Soulbinds.GetOpenSoulbindID();
		local conduitID = self.conduitData.conduitID;

		local pendingInstallNodeID = C_Soulbinds.FindNodeIDPendingInstall(soulbindID, conduitID);
		if pendingInstallNodeID > 0 then
			C_Soulbinds.UnmodifyNode(pendingInstallNodeID);
		else
			local pendingUninstallNodeID = C_Soulbinds.FindNodeIDPendingUninstall(soulbindID, conduitID);
			if pendingUninstallNodeID > 0 then
				C_Soulbinds.UnmodifyNode(pendingUninstallNodeID);
			end
		end

		SoulbindViewer:OnCollectionConduitClick(conduitID);
	end
end

function ConduitListConduitButtonMixin:OnDragStart()
	self:CreateCursor();
end

function ConduitListConduitButtonMixin:CreateCursor()
	SetCursorVirtualItem(self.conduitData.conduitItemID, Enum.UICursorType.ConduitCollectionItem);
end

function ConduitListConduitButtonMixin:OnEnter(conduitData)
	if not self.conduit then
		return;
	end

	local onConduitLoad = function()
		if self.conduitOnSpellLoadCb then
			self.conduitOnSpellLoadCb = nil;
		end

		GameTooltip:SetOwner(self.Icon, "ANCHOR_RIGHT", 178, 0);
		
		local conduitID = self.conduit:GetConduitID();
		GameTooltip:SetConduit(conduitID, self.conduit:GetConduitRank());

		local soulbindID = Soulbinds.GetOpenSoulbindID();
		if C_Soulbinds.FindNodeIDPendingInstall(soulbindID, conduitID) > 0 then
			GameTooltip_AddColoredLine(GameTooltip, CONDUIT_COLLECTION_ITEM_PENDING, CONDUIT_PENDING_INSTALL_FONT_COLOR);
		else
			if C_Soulbinds.FindNodeIDPendingUninstall(soulbindID, conduitID) == 0 then
				if C_Soulbinds.IsConduitInstalledInSoulbind(soulbindID, conduitID) then
					GameTooltip_AddErrorLine(GameTooltip, CONDUIT_COLLECTION_ITEM_SOCKETED);
				end	
			end
		end
		GameTooltip:Show();
	end;

	self.conduitOnSpellLoadCb = self.conduit:ContinueWithCancelOnSpellLoad(onConduitLoad);

	for index, texture in ipairs(self.Hovers) do
		texture:Show();
	end

	local conduitType = self.conduitData.conduitType;
	local conduitID = self.conduitData.conduitID;
	Soulbinds.SetPreviewConduit(conduitType, conduitID);
	SoulbindViewer:OnCollectionConduitEnter(conduitType, self.conduit:GetConduitID());
end

function ConduitListConduitButtonMixin:OnLeave(collectionData)
	if self.conduitOnSpellLoadCb then
		self.conduitOnSpellLoadCb();
		self.conduitOnSpellLoadCb = nil;
	end

	GameTooltip_Hide();

	for index, texture in ipairs(self.Hovers) do
		texture:Hide();
	end
	
	Soulbinds.ClearPreviewConduit();
	SoulbindViewer:OnCollectionConduitLeave();
end

function ConduitListConduitButtonMixin:SetConduitPulsePlaying(playing)
	self.IconOverlayPulse.Anim:SetPlaying(playing);
	self.IconPulse.Anim:SetPlaying(playing);
end

ConduitListSectionMixin = {}

function ConduitListSectionMixin:OnLoad()
	self.CategoryButton:SetScript("OnClick", function(button, buttonName, down)
		local newCollapsed = self.Container:IsShown();
		self:GetElementData().collapsed = newCollapsed;
		self:SetCollapsed(newCollapsed);
	end);

	self.pool = CreateFramePool("BUTTON", self.Container, "ConduitListConduitButtonTemplate");
end

function ConduitListSectionMixin:Init(elementData)
	self.pool:ReleaseAll();

	local conduitDatas = CopyTable(elementData.conduitDatas);
	self.conduitType = elementData.conduitType;

	local frames = {};
	local count = #conduitDatas;
	local function FactoryFunction(index)
		if index > count then
			return nil;
		end

		local frame = self.pool:Acquire();
		table.insert(frames, frame);
		frame:SetPoint("LEFT", self.Container, "LEFT", 0, 0);
		frame:SetPoint("RIGHT", self.Container, "RIGHT", 0, 0);
		frame:Show();
		return frame;
	end

	local direction, stride, x, y, paddingX, paddingY = GridLayoutMixin.Direction.TopLeftToBottomRight, 1, 0, 1, 0, 0;
	local anchor = AnchorUtil.CreateAnchor("TOPLEFT", self.Container, "TOPLEFT");
	local layout = AnchorUtil.CreateGridLayout(direction, stride, paddingX, paddingY);
	AnchorUtil.GridLayoutFactoryByCount(FactoryFunction, count, anchor, layout);
	
	self.CategoryButton:Init(self.conduitType, elementData.collapsed);

	self:SetCollapsed(elementData.collapsed);

	if self.currentContinuable then
		self.currentContinuable:Cancel();
	end
	self.currentContinuable = ContinuableContainer:Create();

	local matchesSpecSet = {};

	for index, conduitData in ipairs(conduitDatas) do
		local specSetID = conduitData.conduitSpecSetID;
		if not matchesSpecSet[specSetID] then
			matchesSpecSet[specSetID] = C_SpecializationInfo.MatchesCurrentSpecSet(specSetID);
		end

		if not conduitData.conduitSpecName then
			conduitData.sortingCategory = 1;
		elseif matchesSpecSet[specSetID] then
			conduitData.sortingCategory = 2;
		else
			conduitData.sortingCategory = 3;
		end

		conduitData.item = Item:CreateFromItemID(conduitData.conduitItemID);
		self.currentContinuable:AddContinuable(conduitData.item);
	end
	
	self.currentContinuable:ContinueOnLoad(function()
		local sorter = function(lhs, rhs)
			if lhs.sortingCategory == rhs.sortingCategory then
				if (not lhs.conduitSpecName or not rhs.conduitSpecName) or lhs.conduitSpecName == rhs.conduitSpecName then
					if lhs.conduitRank ~= rhs.conduitRank then
						return lhs.conduitRank > rhs.conduitRank;	
					end
					return lhs.item:GetItemName() < rhs.item:GetItemName();
				else
					return lhs.conduitSpecName < rhs.conduitSpecName;
				end
			else
				return lhs.sortingCategory < rhs.sortingCategory;
			end
		end;
		table.sort(conduitDatas, sorter);

		for index, conduitData in ipairs(conduitDatas) do
			frames[index]:Init(conduitData);
		end
		
		local newConduitData = elementData.newConduitData;
		if newConduitData then
			elementData.newConduitData = nil;
			self:PlayUpdateAnim(newConduitData);
		end
	end);
end

function ConduitListSectionMixin:Update()
	for conduitButton in self.pool:EnumerateActive() do
		conduitButton:Update();
	end
end

function ConduitListSectionMixin:SetConduitPulsePlaying(playing)
	for conduitButton in self.pool:EnumerateActive() do
		conduitButton:SetConduitPulsePlaying(playing);
	end
end

function ConduitListSectionMixin:FindConduitButton(conduitID)
	for conduitButton in self.pool:EnumerateActive() do
		if conduitButton:MatchesID(conduitID) then
			return conduitButton;
		end
	end
end

function ConduitListSectionMixin:PlayUpdateAnim(conduitData)
	local conduitButton = self:FindConduitButton(conduitData.conduitID);
	if conduitButton then
		conduitButton:PlayUpdateAnimation();
		return true, conduitButton;
	end
	return false;
end

function ConduitListSectionMixin:IsCollapsed()
	return self:GetElementData().collapsed;
end

function ConduitListSectionMixin:SetCollapsed(collapsed)
	self.CategoryButton:SetCollapsed(collapsed);

	local shown = not collapsed;
	self.Container:SetShown(shown);
	self.Spacer:SetShown(shown);
	self:Layout();
end

ConduitListMixin = {};

local ConduitListEvents =
{
	"SOULBIND_CONDUIT_COLLECTION_UPDATED",
	"SOULBIND_CONDUIT_COLLECTION_REMOVED",
	"SOULBIND_CONDUIT_COLLECTION_CLEARED",
	"PLAYER_SPECIALIZATION_CHANGED",
};

function ConduitListMixin:OnLoad()
	local buttonHeight = 42;
	local topSpacer = 10;
	local bottomSpacer = 5;
	local catButtonExtent = 23;
	local containerOffset = 5;
	local expandedExtent = catButtonExtent + topSpacer + bottomSpacer + containerOffset;
	local collapsedExtent = catButtonExtent + topSpacer;

	local view = CreateScrollBoxListLinearView();
	view:SetElementExtentCalculator(function(dataIndex, elementData)
		if elementData.collapsed then
			return collapsedExtent;
		else
			return (#elementData.conduitDatas * buttonHeight) + expandedExtent;
		end
	end);
	view:SetElementInitializer("ConduitListSectionTemplate", function(list, elementData)
		list:Init(elementData);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
	ScrollUtil.AddResizableChildrenBehavior(self.ScrollBox);
end

function ConduitListMixin:OnEvent(event, ...)
	if event == "SOULBIND_CONDUIT_COLLECTION_UPDATED" then
		local collectionData = ...;
		self:OnCollectionDataUpdated(collectionData);
	elseif event == "SOULBIND_CONDUIT_COLLECTION_REMOVED" then
		self:Init();
	elseif event == "SOULBIND_CONDUIT_COLLECTION_CLEARED" then
		self:Init();
	elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
		self:Init();
	end
end

function ConduitListMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ConduitListEvents);
end

function ConduitListMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ConduitListEvents);
end

function ConduitListMixin:SetConduitPreview(preview)
	self.preview = preview;
end

function ConduitListMixin:SetConduitListConduitsPulsePlaying(conduitType, playing)
	local section = self:FindListSection(conduitType);
	if section then
		section:SetConduitPulsePlaying(playing);
	end
end

function ConduitListMixin:FindListSection(conduitType)
	local section = self.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		return frame.conduitType == conduitType;
	end);
	return section;
end

function ConduitListMixin:Init()
	local conduitTypes = {
		Enum.SoulbindConduitType.Endurance,
		Enum.SoulbindConduitType.Finesse,
		Enum.SoulbindConduitType.Potency,
	};

	local listDatas = {};
	for i, conduitType in ipairs(conduitTypes) do
		local conduitDatas = C_Soulbinds.GetConduitCollection(conduitType);
		if #conduitDatas > 0 then
			table.insert(listDatas, {conduitDatas = conduitDatas, conduitType = conduitType});
		end
	end

	local dataProvider = CreateDataProvider(listDatas);
	self.ScrollBox:SetDataProvider(dataProvider);
	local anyShown = #listDatas > 0;
	self:UpdateCollectionShown(anyShown);
end

function ConduitListMixin:Update()
	self.ScrollBox:ForEachFrame(function(list)
		list:Update();
	end);
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
	local MODEL_SCENE_ACTOR_SETTINGS = {["effect"] = { startDelay = 0, duration = 0.769, speed = 1 },};
	modelScene:ShowAndAnimateActors(MODEL_SCENE_ACTOR_SETTINGS);

	PlaySound(SOUNDKIT.SOULBINDS_CONDUIT_LEARNED);
end

function ConduitListMixin:OnCollectionDataUpdated(conduitData)
	local conduitType = conduitData.conduitType;
	
	local dataProvider = self.ScrollBox:GetDataProvider();
	local dataIndex, foundElementData = dataProvider:FindByPredicate(function(elementData)
		return elementData.conduitType == conduitType;
	end);
	
	if dataIndex then
		local conduitID = conduitData.conduitID;
		local existingConduitIndex = FindInTableIf(foundElementData.conduitDatas, function(elementData)
			return elementData.conduitID == conduitID;
		end);

		if existingConduitIndex then
			foundElementData.conduitDatas[existingConduitIndex] = conduitData;
		else
			table.insert(foundElementData.conduitDatas, conduitData);
		end

		foundElementData.newConduitData = conduitData;

		local list = self.ScrollBox:FindFrame(foundElementData);
		if list then
			list:Init(foundElementData);
		end
		self.ScrollBox:ScrollToElementDataIndex(dataIndex);
	else
		local newElementData = {conduitDatas = {conduitData}, conduitType = conduitType};
		newElementData.newConduitData = conduitData;
		dataProvider:Insert(newElementData);

		self.ScrollBox:ScrollToElementData(newElementData);
	end

	self:UpdateCollectionShown(true);
end

function ConduitListMixin:UpdateCollectionShown(shown)
	self.preview:SetShown(not shown);
end
