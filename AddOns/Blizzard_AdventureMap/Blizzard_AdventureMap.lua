UIPanelWindows["AdventureMapFrame"] = { area = "center", pushable = 0, showFailedFunc = C_AdventureMap.Close, allowOtherPanels = 1 };

AdventureMapMixin = {};

function AdventureMapMixin:SetupTitle()
	self.BorderFrame.TitleText:SetText(ADVENTURE_MAP_TITLE);
	self.BorderFrame.Bg:SetColorTexture(0, 0, 0, 1);
	self.BorderFrame.Bg:SetParent(self);
	self.BorderFrame.TopTileStreaks:Hide();

	self.BorderFrame:SetPortraitToAsset([[Interface/Icons/inv_misc_map02]]);
end

-- Override
function AdventureMapMixin:OnLoad()
	MapCanvasMixin.OnLoad(self);

	local mapInsetPool = CreateFramePool("FRAME", self:GetCanvas(), "AdventureMapInsetTemplate", function(pool, mapInset) mapInset:OnReleased(); end);
	self:SetMapInsetPool(mapInsetPool);

	self:RegisterEvent("ADVENTURE_MAP_UPDATE_INSETS");

	self:SetupTitle();

	self:AddStandardDataProviders();
	self:ClearAreaTableIDAvailableForInsets();
end

function AdventureMapMixin:AddStandardDataProviders()
	self:AddDataProvider(CreateFromMixins(AdventureMap_QuestChoiceDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(QuestSessionDataProviderMixin));
end

function AdventureMapMixin:ClearAreaTableIDAvailableForInsets()
	self.areaTableIDsToDisplay = {};
end

function AdventureMapMixin:SetAreaTableIDAvailableForInsets(areaID)
	self.areaTableIDsToDisplay[areaID] = true;
end

-- Override
function AdventureMapMixin:OnShow()
	local mapID = C_AdventureMap.GetMapID();
	self:ClearAreaTableIDAvailableForInsets();
	self:SetMapID(mapID);
	MapCanvasMixin.OnShow(self);
end

-- Override
function AdventureMapMixin:OnHide()
	MapCanvasMixin.OnHide(self);

	AdventureMapQuestChoiceDialog:OnParentHide(self);
	C_AdventureMap.Close();
end

-- Override
function AdventureMapMixin:OnEvent(event, ...)
	if event == "ADVENTURE_MAP_UPDATE_INSETS" then
		self:RefreshInsets();
	end

	MapCanvasMixin.OnEvent(self, event, ...);
end

-- Override
function AdventureMapMixin:RefreshInsets()
	MapCanvasMixin.RefreshInsets(self);

	for insetIndex = 1, C_AdventureMap.GetNumMapInsets() do
		local mapID, title, description, collapsedIcon, areaTableID, numDetailTiles, normalizedX, normalizedY = C_AdventureMap.GetMapInsetInfo(insetIndex);
		if (self.areaTableIDsToDisplay[areaTableID]) then
			self:AddInset(insetIndex, mapID, title, description, collapsedIcon, numDetailTiles, normalizedX, normalizedY);
		end
	end
end

function AdventureMapMixin:IsMapInsetExpanded(mapInsetIndex)
	local mapID = C_AdventureMap.GetMapInsetInfo(mapInsetIndex);
	return not not self.expandedMapInsetsByMapID[mapID];
end