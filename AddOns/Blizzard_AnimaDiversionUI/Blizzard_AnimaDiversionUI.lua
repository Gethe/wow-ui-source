local ANIMA_GEM_TEXTURE_INFO = "AnimaChannel-Bar-%s-Gem";
local OVERRIDE_MODEL_SCENE_FRAME_LEVEL = 511; 
local MAX_ANIMA_GEM_COUNT = 10; 

AnimaDiversionFrameMixin = { }; 

local fullGemsTextureKitAnimationEffectId = {
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

StaticPopupDialogs["ANIMA_DIVERSION_CONFIRM_CHANNEL"] = {
	text = ANIMA_DIVERSION_CONFIRM_CHANNEL,
	button1 = YES,
	button2 = CANCEL,
	OnAccept =	function(self, selectedNode)
					C_AnimaDiversion.SelectAnimaNode(selectedNode.nodeData.talentID, true);
					HelpTip:Acknowledge(AnimaDiversionFrame, ANIMA_DIVERSION_TUTORIAL_SELECT_LOCATION);
				end,
	OnShow = function(self, selectedNode)
		AnimaDiversionFrame:SetExclusiveSelectionNode(selectedNode);
	end,
	OnHide = function(self, selectedNode)
		AnimaDiversionFrame.SelectPinInfoFrame:ClearSelectedNode();
		AnimaDiversionFrame:ClearExclusiveSelectionNode();
	end,
	hideOnEscape = 1,
};

StaticPopupDialogs["ANIMA_DIVERSION_CONFIRM_REINFORCE"] = {
	text = ANIMA_DIVERSION_CONFIRM_REINFORCE,
	button1 = YES,
	button2 = CANCEL,
	OnAccept =	function(self, selectedNode)
					C_AnimaDiversion.SelectAnimaNode(selectedNode.nodeData.talentID, false);
					HelpTip:Acknowledge(AnimaDiversionFrame, ANIMA_DIVERSION_TUTORIAL_SELECT_LOCATION_PERMANENT);
				end,
	OnShow = function(self, selectedNode)
		AnimaDiversionFrame:SetExclusiveSelectionNode(selectedNode);
	end,
	OnHide = function(self, selectedNode)
		AnimaDiversionFrame.ReinforceInfoFrame:ClearSelectedNode();
		AnimaDiversionFrame:ClearExclusiveSelectionNode();
	end,
	hideOnEscape = 1,
};

function AnimaDiversionFrameMixin:OnLoad() 
	MapCanvasMixin.OnLoad(self);	
	self:SetShouldZoomInOnClick(false);
	self:SetMouseWheelZoomMode(MAP_CANVAS_MOUSE_WHEEL_ZOOM_BEHAVIOR_NONE);
	self:SetShouldPanOnClick(false);
	self:AddStandardDataProviders();
	self.bolsterProgressGemPool = CreateFramePool("FRAME", self.ReinforceProgressFrame, "AnimaDiversionBolsterProgressGemTemplate");
	self.SelectPinInfoFrame.currencyPool = CreateFramePool("FRAME", self.SelectPinInfoFrame, "AnimaDiversionCurrencyCostFrameTemplate");

	UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-Oribos-ExitButtonBorder", -1, 1);
end 

function AnimaDiversionFrameMixin:OnShow()
	self:UpdateTutorialTips();

	self:SetMapID(self.mapID);
	MapCanvasMixin.OnShow(self);

	self:ResetZoom();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
	FrameUtil.RegisterFrameForEvents(self, ANIMA_DIVERSION_FRAME_EVENTS);
end

function AnimaDiversionFrameMixin:OnHide()
	MapCanvasMixin.OnHide(self);
	FrameUtil.UnregisterFrameForEvents(self, ANIMA_DIVERSION_FRAME_EVENTS);
	self.SelectPinInfoFrame:Hide();
	self.ReinforceInfoFrame:Hide();
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

function AnimaDiversionFrameMixin:HasAvailableNode()
	local animaNodes = C_AnimaDiversion.GetAnimaDiversionNodes(); 
	if animaNodes then
		for _, nodeData in ipairs(animaNodes) do
			if nodeData.state == Enum.AnimaDiversionNodeState.Available then
				return true;
			end
		end
	end

	return false;
end

function AnimaDiversionFrameMixin:UpdateTutorialTips()
	self.hasIntroTutorialShowing = false;

	local updateTutorialTipsClosure = GenerateClosure(self.UpdateTutorialTips, self);

	local spendAnimaHelpTipInfo = {
		text = ANIMA_DIVERSION_TUTORIAL_SPEND_ANIMA,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_ANIMA_DIVERSION_SPEND_ANIMA,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		offsetX = -50,
		checkCVars = true,
		autoEdgeFlipping = true,
		useParentStrata = true,
		onAcknowledgeCallback = updateTutorialTipsClosure,
	};

	if HelpTip:Show(self.AnimaDiversionCurrencyFrame, spendAnimaHelpTipInfo) then
		self.hasIntroTutorialShowing = true;
		return;
	end

	local fillBarHelpTipInfo = {
		text = ANIMA_DIVERSION_TUTORIAL_FILL_BAR,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFrames",
		bitfieldFlag = LE_FRAME_TUTORIAL_ANIMA_DIVERSION_FILL_BAR,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		offsetX = -17,
		checkCVars = true,
		autoEdgeFlipping = true,
		useParentStrata = true,
		onAcknowledgeCallback = function() self:UpdateTutorialTips(); self:RefreshAllDataProviders(); end,
	};

	if HelpTip:Show(self.ReinforceProgressFrame, fillBarHelpTipInfo) then
		self.hasIntroTutorialShowing = true;
		return;
	end

	if self:CanReinforceNode() then
		local reinforceLocationHelpTipInfo = {
			text = ANIMA_DIVERSION_TUTORIAL_SELECT_LOCATION_PERMANENT,
			buttonStyle = HelpTip.ButtonStyle.None,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_ANIMA_DIVERSION_REINFORCE_LOCATION,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			offsetX = 120,
			offsetY = 30,
			checkCVars = true,
			useParentStrata = true,
			onAcknowledgeCallback = updateTutorialTipsClosure,
		};

		if HelpTip:Show(self, reinforceLocationHelpTipInfo) then
			return;
		end
	end

	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ANIMA_DIVERSION_ACTIVATE_LOCATION) and self:HasAvailableNode() then
		local selectLocationHelpTipInfo = {
			text = ANIMA_DIVERSION_TUTORIAL_SELECT_LOCATION,
			buttonStyle = HelpTip.ButtonStyle.None,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_ANIMA_DIVERSION_ACTIVATE_LOCATION,
			targetPoint = HelpTip.Point.LeftEdgeCenter,
			offsetX = 120,
			offsetY = 30,
			checkCVars = true,
			useParentStrata = true,
			onAcknowledgeCallback = updateTutorialTipsClosure,
		};

		 HelpTip:Show(self, selectLocationHelpTipInfo)
	end
end

function AnimaDiversionFrameMixin:SetExclusiveSelectionNode(node)
	for pin in self:EnumeratePinsByTemplate("AnimaDiversionPinTemplate") do
		if pin ~= node and pin.visualState == Enum.AnimaDiversionNodeState.Available then
			if pin.nodeData.state == Enum.AnimaDiversionNodeState.SelectedTemporary then
				pin:SetVisualState(Enum.AnimaDiversionNodeState.SelectedTemporary);
			else
				pin:SetVisualState(Enum.AnimaDiversionNodeState.Cooldown);
			end
		end
	end
	self.disallowSelection = true;
end

function AnimaDiversionFrameMixin:ClearExclusiveSelectionNode()
	self:RefreshAllDataProviders();
	self.disallowSelection = false;
end

function AnimaDiversionFrameMixin:HasIntroTutorialShowing()
	return self.hasIntroTutorialShowing;
end

function AnimaDiversionFrameMixin:CanReinforceNode() 
	return self.bolsterProgress >= 10;
end 

function AnimaDiversionFrameMixin:AddBolsterEffectToGem(gem, effectID, overlay)
	local modelScene = overlay and self.ReinforceProgressFrame.OverlayModelScene or self.ReinforceProgressFrame.ModelScene;
	modelScene:AddEffect(effectID, gem, gem);
end

function AnimaDiversionFrameMixin:SetupBolsterProgressBar()
	self.bolsterProgressGemPool:ReleaseAll(); 
	self.ReinforceProgressFrame.ModelScene:ClearEffects();
	self.ReinforceProgressFrame.OverlayModelScene:ClearEffects();

	local gemsFullEffectID = fullGemsTextureKitAnimationEffectId[self.uiTextureKit];
	local newGemEffectID = newGemTextureKitAnimationEffectId[self.uiTextureKit];
	
	local newBolsterProgress =  math.min(MAX_ANIMA_GEM_COUNT, C_AnimaDiversion.GetReinforceProgress());
	local numNewGems =  0;
	if self.bolsterProgress and newBolsterProgress > self.bolsterProgress then
		numNewGems = newBolsterProgress - self.bolsterProgress;
	end
	self.bolsterProgress = newBolsterProgress; 

	local isReinforceReady = self:CanReinforceNode(); 
	local firstNewGem = (newBolsterProgress - numNewGems) + 1;

	for i=1, newBolsterProgress do
		local isNewGem = i >= firstNewGem;

		self.lastGem = self:SetupBolsterGem(i, isNewGem);

		if isNewGem then
			self:AddBolsterEffectToGem(self.lastGem, newGemEffectID, true);
		end

		if isReinforceReady then
			if numNewGems > 0 then
				C_Timer.After(0.5, GenerateClosure(self.AddBolsterEffectToGem, self, self.lastGem, gemsFullEffectID));
			else
				self:AddBolsterEffectToGem(self.lastGem, gemsFullEffectID);
			end
		end 
	end

	self.ReinforceInfoFrame:Init(); 
	self.ReinforceInfoFrame:SetShown(isReinforceReady);

	self:UpdateTutorialTips();
end 

function AnimaDiversionFrameMixin:SetupBolsterGem(index, isNew)
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

	if isNew then
		C_Timer.After(0.25, GenerateClosure(gem.Show, gem));
	else
		gem:Show();
	end

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
	ShowUIPanel(self);
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

function AnimaDiversionSelectionInfoMixin:ClearSelectedNode()
	if self.currentlySelectedNode then
		self:GetParent():RefreshAllDataProviders();
	end

	self.currentlySelectedNode = nil;
end 

function AnimaDiversionSelectionInfoMixin:SetupAndShow(node)
	if self.currentlySelectedNode then
		self.currentlySelectedNode:SetSelectedState(false);
	end

	node:SetSelectedState(true);

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

function AnimaDiversionSelectionInfoMixin:GetSelectedNode()
	return self.currentlySelectedNode;
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
	local selectedNode = self:GetParent():GetSelectedNode();
	if selectedNode then 
		StaticPopup_Show("ANIMA_DIVERSION_CONFIRM_CHANNEL", selectedNode.nodeData.name, nil, selectedNode);
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

function ReinforceInfoFrameMixin:OnHide()
	self.selectedNode = nil; 
end

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

function ReinforceInfoFrameMixin:GetSelectedNode()
	return self.selectedNode;
end 

function ReinforceInfoFrameMixin:ClearSelectedNode()
	if self.selectedNode then
		self:Init();
	end

	self.selectedNode = nil;
end 

function ReinforceInfoFrameMixin:SelectNodeToReinforce(node) 
	if not self.canReinforce or self.selectedNode == node or node.UnavailableState then 
		return; 
	end 

	if self.selectedNode then 
		self.selectedNode:SetSelectedState(false); 
	end

	self.selectedNode = node;
	node:SetReinforceState(true);
	node:SetSelectedState(true);
	self.Title:SetText(self.selectedNode.nodeData.name);
	self.AnimaNodeReinforceButton:Enable(); 
end 

AnimaNodeReinforceButtonMixin = { };
function AnimaNodeReinforceButtonMixin:OnClick()
	local selectedNode = self:GetParent():GetSelectedNode();
	if selectedNode then
		StaticPopup_Show("ANIMA_DIVERSION_CONFIRM_REINFORCE", selectedNode.nodeData.name, nil, selectedNode);
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