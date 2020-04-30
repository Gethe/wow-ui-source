local ANIMA_GEM_TEXTURE_INFO = "AnimaChannel-Bar-%s-Gem";
local MAX_ANIMA_GEM_COUNT = 10; 

AnimaDiversionFrameMixin = { }; 

function AnimaDiversionFrameMixin:OnLoad() 
	MapCanvasMixin.OnLoad(self);	
	self:SetShouldZoomInOnClick(false);
	self:SetShouldPanOnClick(false);
	self:AddStandardDataProviders();
	self.bolsterProgressGemPool = CreateTexturePool(self.ReinforceProgressFrame, "ARTWORK", AnimaDiversionBolsterProgressGem);
	self.SelectPinInfoFrame.currencyPool = CreateFramePool("FRAME", self.SelectPinInfoFrame, "AnimaDiversionCurrencyCostFrameTemplate");
end 

function AnimaDiversionFrameMixin:OnShow()
	self:SetMapID(self.mapID);
	MapCanvasMixin.OnShow(self);

	self:ResetZoom();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
	self:RegisterEvent("ANIMA_DIVERSION_CLOSE");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
end

function AnimaDiversionFrameMixin:OnHide()
	MapCanvasMixin.OnHide(self);
	self:UnregisterEvent("ANIMA_DIVERSION_CLOSE");
	self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE");
end 

function AnimaDiversionFrameMixin:OnEvent(event, ...) 
	if (event == "ANIMA_DIVERSION_CLOSE") then
		HideUIPanel(self);
	elseif (event == "CURRENCY_DISPLAY_UPDATE") then 
		self:SetupBolsterProgressBar(); 
	end 
end 

function AnimaDiversionFrameMixin:CanReinforceNode() 
	return self.bolsterProgress >= 10;
end 

function AnimaDiversionFrameMixin:SetupBolsterProgressBar()
	self.bolsterProgressGemPool:ReleaseAll(); 
	self.bolsterProgress = C_AnimaDiversion.GetReinforceProgress(); 
	for i=1, math.min(MAX_ANIMA_GEM_COUNT, self.bolsterProgress) do 
		self.lastGem = self:SetupBolsterGem(i); 
	end
	self.ReinforceInfoFrame:Init(); 
	self.ReinforceInfoFrame:SetShown(self:CanReinforceNode()); 
end 

function AnimaDiversionFrameMixin:SetupBolsterGem(index)
	local gem = self.bolsterProgressGemPool:Acquire(); 
	if(index == 1) then 
		gem:SetPoint("LEFT", self.ReinforceProgressFrame, 27, -5);
	elseif(index > 5) then
		gem:SetPoint("LEFT", self.lastGem, "RIGHT", -3, 0);
	else 
		gem:SetPoint("LEFT", self.lastGem, "RIGHT", -2, 0);	
	end
	local atlas = GetFinalNameFromTextureKit(ANIMA_GEM_TEXTURE_INFO, self.uiTextureKit);
	gem:SetAtlas(atlas, true);
	gem:Show();
	return gem;
end 


function AnimaDiversionFrameMixin:AddStandardDataProviders() 
	self:AddDataProvider(CreateFromMixins(AnimaDiversionDataProviderMixin));
end 

function AnimaDiversionFrameMixin:SetupTextureKits(frame, regions)
	SetupTextureKitOnRegions(self.uiTextureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end 

function AnimaDiversionFrameMixin:SetupFramesWithTextureKit()
	NineSliceUtil.ApplyUniqueCornersLayout(self.NineSlice, self.uiTextureKit); 
end

function AnimaDiversionFrameMixin:TryShow(frameInfo)
	if(not frameInfo) then
		return; 
	end 

	self.uiTextureKit = frameInfo.textureKit; 
	self.mapID = frameInfo.mapID; 
	self:SetupFramesWithTextureKit(); 
	self:SetupBolsterProgressBar();
	self:SetupCurrencyFrame(); 
	self:Show(); 
end 

function AnimaDiversionFrameMixin:SetupCurrencyFrame() 
	local currencyID = C_AnimaDiversion.GetPlayerCovenantAnimaCurrencyID(); 
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID);
	if(currencyInfo) then 
		self.AnimaDiversionCurrencyFrame.CurrencyFrame.Quantity:SetText(currencyInfo.quantity);	
		self.AnimaDiversionCurrencyFrame.CurrencyFrame.CurrencyIcon:SetTexture(currencyInfo.iconFileID);
	end 
end 


AnimaDiversionSelectionInfoMixin = { }; 

function AnimaDiversionSelectionInfoMixin:SetupAndShow(node)
	if(self.currentlySelectedNode and self.currentlySelectedNode ~= node) then 
		self.currentlySelectedNode:SetSelected(); 
	end 

	self.currentlySelectedNode = node; 
	self:ClearAllPoints(); 
	self:SetPoint("LEFT", node, "RIGHT", 20, 0);

	local nodeInfo = node.nodeData; 
	self.Title:SetText(nodeInfo.name);
	self.Description:SetText(nodeInfo.description);
	self.showingNode = node;

	local nodeNotAvailableForSelection = nodeInfo.state ~= Enum.AnimaDiversionNodeState.Available;
	self.SelectButton:SetShown(nodeInfo.state == Enum.AnimaDiversionNodeState.Available);
	self.AlreadySelected:SetShown(nodeNotAvailableForSelection);

	if	(nodeNotAvailableForSelection) then 
		if (nodeInfo.state == Enum.AnimaDiversionNodeState.SelectedTemporary or nodeInfo.state == Enum.AnimaDiversionNodeState.SelectedPermanent) then 
			self.AlreadySelected:SetText(ANIMA_DIVERSION_NODE_SELECTED);
		else 
			self.AlreadySelected:SetText(ANIMA_DIVERSION_NODE_UNAVAILABLE);
		end 
	end 

	self:SetupCosts(nodeInfo.costs);
	self:Layout(); 
	self:Show();
end 

function AnimaDiversionSelectionInfoMixin:GetNodeData()
	if(not self.showingNode) then
		return nil;
	else 
		return self.showingNode.nodeData; 
	end 
end 

function AnimaDiversionSelectionInfoMixin:SetupCosts(CurrencyCosts)
	self.currencyPool:ReleaseAll(); 
	for i, costInfo in ipairs(CurrencyCosts) do 
		self.lastCurrency = self:SetupSingleCurrency(i, costInfo); 
	end
	self.SelectButton:ClearAllPoints(); 
	self.SelectButton:SetPoint("TOP", self.lastCurrency, "BOTTOM", 10, -20);
	self.AlreadySelected:ClearAllPoints(); 
	self.AlreadySelected:SetPoint("CENTER", self.SelectButton); 
end 

function AnimaDiversionSelectionInfoMixin:SetupSingleCurrency(index, costInfo)
	local currency = self.currencyPool:Acquire(); 
	if(index == 1) then 
		currency:SetPoint("TOP", self.Description, "BOTTOM", -15, 8);
	else 
		currency:SetPoint("TOP", self.lastCurrency, "BOTTOM", 0, -10);	
	end

	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(costInfo.currencyID);
	if(currencyInfo) then 
		currency.Quantity:SetText(costInfo.quantity);	
		currency.CurrencyIcon:SetTexture(currencyInfo.iconFileID);
	end 

	currency.currencyInfo = currencyInfo; 
	currency:Show(); 
	return currency;
end 

AnimaDiversionSelectButtonMixin = { }; 

function AnimaDiversionSelectButtonMixin:OnClick() 
	local selectedNodeData = self:GetParent():GetNodeData();
	if (selectedNodeData) then 
		C_AnimaDiversion.SelectAnimaNode(selectedNodeData.talentID, true);
	end		
end

AnimaDiversionCurrencyFrameMixin = { }; 

function AnimaDiversionCurrencyFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, ANIMA_DIVERSION_CURRENCY_TOOLTIP_TITLE, true);
	GameTooltip_AddHighlightLine(GameTooltip, ANIMA_DIVERSION_CURRENCY_TOOLTIP_DESCRIPTION, true);
	GameTooltip:Show(); 
end 

function AnimaDiversionCurrencyFrameMixin:OnLeave()
	GameTooltip:Hide(); 
end 

ReinforceProgressFrameMixin = { }; 

function ReinforceProgressFrameMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, ANIMA_DIVERSION_REINFORCE_STREAM_TOOLTIP_TITLE, true);
	GameTooltip_AddHighlightLine(GameTooltip,ANIMA_DIVERSION_REINFORCE_STREAM_TOOLTIP_DESCRIPTION, true);
	GameTooltip:Show(); 
end 

function ReinforceProgressFrameMixin:OnLeave()
	GameTooltip:Hide(); 
end 

ReinforceInfoFrameMixin = { };
function ReinforceInfoFrameMixin:Init()
	self.Title:SetText(ANIMA_DIVERSION_REINFORCE_READY);
	self.AnimaNodeReinforceButton:Disable(); 
end 

function ReinforceInfoFrameMixin:GetNodeData()
	if(not self.selectedNode) then
		return nil;
	else 
		return self.selectedNode.nodeData; 
	end 
end 

function ReinforceInfoFrameMixin:SelectNodeToReinforce(node) 
	
	if(self.selectedNode) then 
		self.selectedNode:SetReinforceState(false); 
		if(node == self.selectedNode) then 
			self:Init();
			self.selectedNode = nil; 
			return; 
		end 
	end

	self.selectedNode = node; 
	node:SetReinforceState(true); 
	self.Title:SetText(self.selectedNode.nodeData.name);
	self.AnimaNodeReinforceButton:Enable(); 
	
end 

AnimaNodeReinforceButtonMixin = { };
function AnimaNodeReinforceButtonMixin:OnClick()
	local selectedNodeData = self:GetParent():GetNodeData();
	if (selectedNodeData) then 
		C_AnimaDiversion.SelectAnimaNode(selectedNodeData.talentID, false);
	end 
end