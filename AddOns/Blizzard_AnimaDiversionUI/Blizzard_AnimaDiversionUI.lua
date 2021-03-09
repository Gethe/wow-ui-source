local ANIMA_GEM_TEXTURE_INFO = "AnimaChannel-Bar-%s-Gem";
local OVERRIDE_MODEL_SCENE_FRAME_LEVEL = 511; 
local MAX_ANIMA_GEM_COUNT = 10; 

AnimaDiversionFrameMixin = { }; 

local fullGemsTextureKitAnimationEffectId = {
	["Kyrian"] = 24,
	["Venthyr"] = 27,
	["NightFae"] = 30,
	["Necrolord"] = 33, 
};

local newGemTextureKitAnimationEffectId = {
	["Kyrian"] = 23,
	["Venthyr"] = 26,
	["NightFae"] = 29,
	["Necrolord"] = 32, 
};

local textureKitToCovenantId = {
	["Kyrian"] = 1,
	["Venthyr"] = 2,
	["NightFae"] = 3,
	["Necrolord"] = 4, 
};

local textureKitToConfirmSound = {
	["Kyrian"] = SOUNDKIT.UI_9_0_ANIMA_DIVERSION_BASTION_CONFIRM_CHANNEL,
	["Venthyr"] = SOUNDKIT.UI_9_0_ANIMA_DIVERSION_REVENDRETH_CONFIRM_CHANNEL,
	["NightFae"] = SOUNDKIT.UI_9_0_ANIMA_DIVERSION_ARDENWEALD_CONFIRM_CHANNEL,
	["Necrolord"] = SOUNDKIT.UI_9_0_ANIMA_DIVERSION_MALDRAXXUS_CONFIRM_CHANNEL, 
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
					PlaySound(textureKitToConfirmSound[selectedNode.textureKit]);
					C_AnimaDiversion.SelectAnimaNode(selectedNode.nodeData.talentID, true);
					HelpTip:Acknowledge(AnimaDiversionFrame, ANIMA_DIVERSION_TUTORIAL_SELECT_LOCATION);
					HelpTip:Acknowledge(AnimaDiversionFrame.ReinforceProgressFrame, ANIMA_DIVERSION_TUTORIAL_FILL_BAR);
				end,
	OnShow = function(self, selectedNode)
		AnimaDiversionFrame:SetExclusiveSelectionNode(selectedNode);
		self.timeleft = C_DateAndTime.GetSecondsUntilDailyReset();
	end,
	OnHide = function(self, selectedNode)
		AnimaDiversionFrame:ClearExclusiveSelectionNode();
	end,
	hideOnEscape = 1,
};

StaticPopupDialogs["ANIMA_DIVERSION_CONFIRM_REINFORCE"] = {
	text = ANIMA_DIVERSION_CONFIRM_REINFORCE,
	button1 = YES,
	button2 = CANCEL,
	OnAccept =	function(self, selectedNode)
					PlaySound(SOUNDKIT.UI_COVENANT_ANIMA_DIVERSION_CONFIRM_REINFORCE);
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

	UIPanelCloseButton_SetBorderAtlas(self.CloseButton, "UI-Frame-Oribos-ExitButtonBorder", -1, 1);
end 

function AnimaDiversionFrameMixin:OnShow()
	self:UpdateTutorialTips();

	self:SetMapID(self.mapID);
	MapCanvasMixin.OnShow(self);

	self:ResetZoom();
	FrameUtil.RegisterFrameForEvents(self, ANIMA_DIVERSION_FRAME_EVENTS);

	PlaySound(SOUNDKIT.UI_COVENANT_ANIMA_DIVERSION_OPEN);

	if AnimaDiversionUtil.IsAnyNodeActive() then
		PlaySound(self.covenantData.animaChannelActiveSoundKit);
	end
end

function AnimaDiversionFrameMixin:OnHide()
	MapCanvasMixin.OnHide(self);
	FrameUtil.UnregisterFrameForEvents(self, ANIMA_DIVERSION_FRAME_EVENTS);
	self.ReinforceInfoFrame:Hide();
	self:StopGemsFullSound();
	PlaySound(SOUNDKIT.UI_COVENANT_ANIMA_DIVERSION_CLOSE);
end 

function AnimaDiversionFrameMixin:OnEvent(event, ...) 
	if (event == "ANIMA_DIVERSION_CLOSE") then
		HideUIPanel(self);
	elseif (event == "CURRENCY_DISPLAY_UPDATE") then 
		self:SetupBolsterProgressBar();
		self:SetupCurrencyFrame(); 
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
	local updateTutorialTipsClosure = GenerateClosure(self.UpdateTutorialTips, self);

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
			useParentStrata = true,
			onAcknowledgeCallback = updateTutorialTipsClosure,
		};

		HelpTip:Show(self, selectLocationHelpTipInfo);

		local fillBarHelpTipInfo = {
			text = ANIMA_DIVERSION_TUTORIAL_FILL_BAR,
			buttonStyle = HelpTip.ButtonStyle.None,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			offsetX = -17,
			autoEdgeFlipping = true,
			useParentStrata = true,
			onAcknowledgeCallback = updateTutorialTipsClosure,
		};

		HelpTip:Show(self.ReinforceProgressFrame, fillBarHelpTipInfo);
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

function AnimaDiversionFrameMixin:CanReinforceNode() 
	return self.bolsterProgress >= 10;
end 

function AnimaDiversionFrameMixin:AddBolsterEffectToGem(gem, effectID, overlay)
	local modelScene = overlay and self.ReinforceProgressFrame.OverlayModelScene or self.ReinforceProgressFrame.ModelScene;
	modelScene:AddEffect(effectID, gem, gem);
end

function AnimaDiversionFrameMixin:StopGemsFullSound()
	if self.gemsFullSoundHandle then
		StopSound(self.gemsFullSoundHandle);
		self.gemsFullSoundHandle = nil;
	end
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

	if isReinforceReady then
		if not self.gemsFullSoundHandle then
			local _, soundHandle = PlaySound(self.covenantData.animaGemsFullSoundKit);
			self.gemsFullSoundHandle = soundHandle;
		end
	else
		self:StopGemsFullSound();
	end

	local firstNewGem = (newBolsterProgress - numNewGems) + 1;

	for i=1, newBolsterProgress do
		local isNewGem = i >= firstNewGem;

		self.lastGem = self:SetupBolsterGem(i, isNewGem);

		if isNewGem then
			self:AddBolsterEffectToGem(self.lastGem, newGemEffectID, true);

			if not isReinforceReady then
				PlaySound(self.covenantData.animaNewGemSoundKit);
			end
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
	self:AddDataProvider(CreateFromMixins(AnimaDiversion_WorldQuestDataProviderMixin));	
	local pinFrameLevelsManager = self:GetPinFrameLevelsManager(); 
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WORLD_QUEST", 500);
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
	self.covenantData = C_Covenants.GetCovenantData(textureKitToCovenantId[self.uiTextureKit]);
	self.mapID = frameInfo.mapID; 
	self:SetupBolsterProgressBar();
	self:SetupCurrencyFrame(); 
	ShowUIPanel(self);
end 

function AnimaDiversionFrameMixin:SetupCurrencyFrame() 
	local animaCurrencyID, maxDisplayableValue = C_CovenantSanctumUI.GetAnimaInfo()
	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(animaCurrencyID);
	if(currencyInfo) then 
		self.AnimaDiversionCurrencyFrame.CurrencyFrame.Quantity:SetText(ANIMA_DIVERSION_CURRENCY_DISPLAY:format(currencyInfo.quantity, currencyInfo.iconFileID));
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
	PlaySound(AnimaDiversionFrame.covenantData.animaReinforceSelectSoundKit);
end 

AnimaNodeReinforceButtonMixin = { };
function AnimaNodeReinforceButtonMixin:OnClick()
	local selectedNode = self:GetParent():GetSelectedNode();
	if selectedNode then
		PlaySound(SOUNDKIT.UI_COVENANT_ANIMA_DIVERSION_CLICK_REINFORCE_BUTTON);
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