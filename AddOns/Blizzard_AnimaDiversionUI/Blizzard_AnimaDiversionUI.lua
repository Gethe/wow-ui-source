local ANIMA_GEM_TEXTURE_INFO = "AnimaChannel-Bar-%s-Gem";
local OVERRIDE_MODEL_SCENE_FRAME_LEVEL = 511; 
local MAX_ANIMA_GEM_COUNT = 10; 

AnimaDiversionFrameMixin = { }; 

local bolsterGemTextureKitAnimationEffectId = {
	["Kyrian"] = 24,
	["NightFae"] = 30,
	["Venthyr"] = 27,
	["Necrolord"] = 33, 
}; 

local newGemTextureKitAnimationEffectId = {
	["Kyrian"] = 23,
	["NightFae"] = 29,
	["Venthyr"] = 26,
	["Necrolord"] = 32, 
}; 

local ANIMA_DIVERSION_FRAME_EVENTS = {
	"ANIMA_DIVERSION_CLOSE",
	"CURRENCY_DISPLAY_UPDATE",
};

function AnimaDiversionFrameMixin:OnLoad() 
	MapCanvasMixin.OnLoad(self);	
	self:SetShouldZoomInOnClick(false);
	self:SetMouseWheelZoomMode(MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_NONE);
	self:SetShouldPanOnClick(false);
	self:AddStandardDataProviders();
	self.bolsterProgressGemPool = CreateFramePool("FRAME", self.ReinforceProgressFrame, "AnimaDiversionBolsterProgressGemTemplate");
	self.SelectPinInfoFrame.currencyPool = CreateFramePool("FRAME", self.SelectPinInfoFrame, "AnimaDiversionCurrencyCostFrameTemplate");
end 

function AnimaDiversionFrameMixin:OnShow()
	self:SetMapID(self.mapID);
	MapCanvasMixin.OnShow(self);

	self:ResetZoom();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
	FrameUtil.RegisterFrameForEvents(self, ANIMA_DIVERSION_FRAME_EVENTS);
end

function AnimaDiversionFrameMixin:OnHide()
	MapCanvasMixin.OnHide(self);
	FrameUtil.UnregisterFrameForEvents(self, ANIMA_DIVERSION_FRAME_EVENTS);
end 

function AnimaDiversionFrameMixin:OnEvent(event, ...) 
	if (event == "ANIMA_DIVERSION_CLOSE") then
		HideUIPanel(self);
	elseif (event == "CURRENCY_DISPLAY_UPDATE") then 
		self:SetupBolsterProgressBar();
		self:SetupCurrencyFrame(); 
		self.SelectPinInfoFrame:CurrencyUpdate();
	elseif(event == "ANIMA_DIVERSION_TALENT_UPDATED") then 
		self:SetupBolsterProgressBar();
	end 
	MapCanvasMixin.OnEvent(self, event, ...);
end 

function AnimaDiversionFrameMixin:CanReinforceNode() 
	return self.bolsterProgress >= 10;
end 

function AnimaDiversionFrameMixin:SetupBolsterProgressBar()
	self.bolsterProgressGemPool:ReleaseAll(); 
	self.bolsterProgress = C_AnimaDiversion.GetReinforceProgress(); 
	local effectID = nil; 
	local isReinforceReady = self:CanReinforceNode(); 

	self.ReinforceProgressFrame.ModelScene:ClearEffects();

	if(isReinforceReady) then 
		self.ReinforceProgressFrame.ModelScene:SetFrameLevel(OVERRIDE_MODEL_SCENE_FRAME_LEVEL);
		effectID = bolsterGemTextureKitAnimationEffectId[self.uiTextureKit]; 
	end 
	self.ReinforceProgressFrame.ModelScene:SetShown(isReinforceReady);
	for i=1, math.min(MAX_ANIMA_GEM_COUNT, self.bolsterProgress) do 
		self.lastGem = self:SetupBolsterGem(i); 
		if(isReinforceReady and effectID) then 
			self.ReinforceProgressFrame.ModelScene:AddEffect(effectID, self.lastGem, self.lastGem);
		end 
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
	gem.Gem:SetAtlas(atlas, true);
	gem:Show();
	return gem;
end 


function AnimaDiversionFrameMixin:AddStandardDataProviders() 
	self:AddDataProvider(CreateFromMixins(AnimaDiversionDataProviderMixin));
	local pinFrameLevelsManager = self:GetPinFrameLevelsManager(); 
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ANIMA_DIVERSION_MODELSCENE_PIN");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ANIMA_DIVERSION_PIN");
end 

function AnimaDiversionFrameMixin:SetupTextureKits(frame, regions)
	SetupTextureKitOnRegions(self.uiTextureKit, frame, regions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end 

function AnimaDiversionFrameMixin:TryShow(frameInfo)
	if(not frameInfo) then
		return; 
	end 

	self.uiTextureKit = frameInfo.textureKit; 
	self.mapID = frameInfo.mapID; 
	self:SetupBolsterProgressBar();
	self:SetupCurrencyFrame(); 
	self:Show(); 
end 

function AnimaDiversionFrameMixin:SetupCurrencyFrame() 
	local animaCurrencyID, maxDisplayableValue = C_CovenantSanctumUI.GetAnimaInfo()
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(animaCurrencyID);
	if(currencyInfo) then 
		self.AnimaDiversionCurrencyFrame.CurrencyFrame.Quantity:SetText(currencyInfo.quantity);	
		self.AnimaDiversionCurrencyFrame.CurrencyFrame.CurrencyIcon:SetTexture(currencyInfo.iconFileID);
	end 
end 


AnimaDiversionSelectionInfoMixin = { }; 

function AnimaDiversionSelectionInfoMixin:IsSelectionInfoShowingForNode(node)
	if (not self:IsShown() or not self.currentlySelectedNode) then 
		return false;
	end 

	if(self.currentlySelectedNode == node) then 
		return true; 
	end 
	return false; 
end

function AnimaDiversionSelectionInfoMixin:CurrencyUpdate()
	if( not self:IsShown()) then 
		return;
	end 

	if(self.currentlySelectedNode) then 
		self:SetupAndShow(self.currentlySelectedNode);
	end		
end 

function AnimaDiversionSelectionInfoMixin:OnHide()
	self.currentlySelectedNode = nil;
end 

function AnimaDiversionSelectionInfoMixin:SetupAndShow(node)
	self.currentlySelectedNode = node; 
	self:ClearAllPoints(); 
	self:SetPoint("LEFT", node, "RIGHT", 20, 0);

	local nodeInfo = node.nodeData; 
	self.Title:SetText(nodeInfo.name);
	self.Description:SetText(nodeInfo.description);

	local canAffordAnimaSelection = self:SetupCosts(nodeInfo.costs);

	local nodeAvailableForSelection = nodeInfo.state == Enum.AnimaDiversionNodeState.Available and canAffordAnimaSelection;
	self.SelectButton:SetShown(nodeAvailableForSelection);
	self.AlreadySelected:SetShown(not nodeAvailableForSelection);

	if	(not nodeAvailableForSelection) then 
		if (nodeInfo.state == Enum.AnimaDiversionNodeState.SelectedTemporary or nodeInfo.state == Enum.AnimaDiversionNodeState.SelectedPermanent) then 
			self.AlreadySelected:SetText(ANIMA_DIVERSION_NODE_SELECTED);
		elseif(not canAffordAnimaSelection) then 
			self.AlreadySelected:SetText(ANIMA_DIVERSION_NOT_ENOUGH_CURRENCY);
		else 
			self.AlreadySelected:SetText(ANIMA_DIVERSION_NODE_UNAVAILABLE);
		end 
	end 

	self:Layout(); 
	self:Show();
end 

function AnimaDiversionSelectionInfoMixin:GetNodeData()
	if(not self.currentlySelectedNode) then
		return nil;
	else 
		return self.currentlySelectedNode.nodeData; 
	end 
end 

function AnimaDiversionSelectionInfoMixin:SetupCosts(CurrencyCosts)
	local playerCanAfford = true; 
	self.currencyPool:ReleaseAll(); 
	for i, costInfo in ipairs(CurrencyCosts) do 
		self.lastCurrency = self:SetupSingleCurrency(i, costInfo); 
		if(not self.lastCurrency.canAfford) then 
			playerCanAfford = false; 
		end 
	end
	self.SelectButton:ClearAllPoints(); 
	self.SelectButton:SetPoint("TOP", self.lastCurrency, "BOTTOM", 10, -20);
	self.AlreadySelected:ClearAllPoints(); 
	self.AlreadySelected:SetPoint("CENTER", self.SelectButton); 
	return playerCanAfford; 
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
	currency.canAfford = currencyInfo.quantity >= costInfo.quantity;
	currency:Show(); 
	return currency;
end 

AnimaDiversionSelectButtonMixin = { }; 

function AnimaDiversionSelectButtonMixin:OnClick() 
	local selectedNodeData = self:GetParent():GetNodeData();
	if (selectedNodeData) then 
		C_AnimaDiversion.SelectAnimaNode(selectedNodeData.talentID, true);
		self:GetParent():Hide(); 
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

function ReinforceInfoFrameMixin:CanReinforceAnything()
	local animaNodes = C_AnimaDiversion.GetAnimaDiversionNodes(); 
	if (not animaNodes) then 
		return false;
	end 

	for _, nodeData in ipairs(animaNodes) do
		if (nodeData.state == Enum.AnimaDiversionNodeState.Available or nodeData.state == Enum.AnimaDiversionNodeState.SelectedTemporary) then 
			return true; 
		end
	end  
	return false; 
end 

function ReinforceInfoFrameMixin:Init()
	self.canReinforce = self:CanReinforceAnything();

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
	if( not self.canReinforce) then 
		return; 
	end 

	if(self.selectedNode) then 
		self.selectedNode:SetReinforceState(false); 
		if(node == self.selectedNode) then 
			self:Init();
			self.selectedNode = nil; 
			return; 
		end 
	end

	if(node.UnavailableState) then 
		return;
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

function AnimaNodeReinforceButtonMixin:OnEnter()
	if (not self:GetParent().canReinforce) then 
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 20, 0);
		GameTooltip_AddErrorLine(GameTooltip, ANIMA_DIVERSION_CANT_REINFORCE);
		GameTooltip:Show(); 
	end 
end 

function AnimaNodeReinforceButtonMixin:OnLeave()
	GameTooltip:Hide(); 
end 