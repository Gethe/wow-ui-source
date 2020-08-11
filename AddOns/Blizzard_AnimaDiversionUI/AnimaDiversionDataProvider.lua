local animaPinTextureKitRegions = {
	["Icon"] = "AnimaChannel-Icon-%s-Normal",
	["IconSelect"] = "AnimaChannel-Icon-%s-Select",
	["IconReinforce"] = "AnimaChannel-Icon-%s-Reinforce",
	["IconReady"] = "AnimaChannel-Icon-%s-Ready",
};

local reinforceNodeTextureKitAnimationEffectId = {
	["Kyrian"] = 22,
	["NightFae"] = 28,
	["Venthyr"] = 25,
	["Necrolord"] = 31, 
}; 

local animaConnectionLineColors = { 
	["Kyrian"] = CreateColor(0.55, 0.81, 0.90), 
	["NightFae"] = CreateColor(0, 0.33, 0.97),
	["Venthyr"] = CreateColor(0.81, 0.06, 0.06),
	["Necrolord"] = CreateColor(0.1, 0.82, 0.30), 
}; 

local ANIMA_DIVERSION_DATA_PROVIDER_FRAME_EVENTS = {
	"ANIMA_DIVERSION_TALENT_UPDATED",
	"CURRENCY_DISPLAY_UPDATE",
};

local ANIMA_DIVERSION_ORIGIN_PIN_BORDER = "AnimaChannel-Icon-Device-%s-Border";
local ANIMA_REINFORCE_MODEL_EFFECT_ID = 35;

AnimaDiversionDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function AnimaDiversionDataProviderMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, ANIMA_DIVERSION_DATA_PROVIDER_FRAME_EVENTS);
end 

function AnimaDiversionDataProviderMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, ANIMA_DIVERSION_DATA_PROVIDER_FRAME_EVENTS);
end 

function AnimaDiversionDataProviderMixin:OnEvent(event, ...)
	if event == "ANIMA_DIVERSION_TALENT_UPDATED" or event == "CURRENCY_DISPLAY_UPDATE" then
		self:RefreshAllData(); 
	end
end 

function AnimaDiversionDataProviderMixin:SetupConnectionOnPin(pin)
	if(not self.origin or not animaConnectionLineColors[self.textureKit]) then 
		return; 
	end 

	pin.lineContainer = self.backgroundLinePool:Acquire();
	pin.lineContainer.Fill:SetVertexColor(animaConnectionLineColors[self.textureKit]:GetRGB());
	pin.lineContainer.Fill:SetThickness(self.lineThickness);
	pin.lineContainer.Fill:SetStartPoint("CENTER", self.origin);
	pin.lineContainer.Fill:SetEndPoint("CENTER", pin);
end

function AnimaDiversionDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("AnimaDiversionPinTemplate");
	self:GetMap():RemoveAllPinsByTemplate("AnimaDiversionModelScenePinTemplate");
end

function AnimaDiversionDataProviderMixin:CanReinforceNode() 
	return self.bolsterProgress >= 10;
end 

function AnimaDiversionDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();
	self.bolsterProgress = C_AnimaDiversion.GetReinforceProgress();

	if not self.backgroundLinePool then
		self.backgroundLinePool = CreateFramePool("FRAME", self:GetMap():GetCanvas(), "AnimaDiversionConnectionTemplate", OnRelease);
	end
	self.backgroundLinePool:ReleaseAll(); 
	self.textureKit = C_AnimaDiversion.GetTextureKit();

	self.forceReinforceState = self:CanReinforceNode();
	if (self.forceReinforceState) then 
		self:AddModelScene(); 
	end 

	if(self.modelScenePin) then 
		self.modelScenePin.ModelScene:ClearEffects(); 
	end 

	local originPosition = C_AnimaDiversion.GetOriginPosition();
	if(originPosition) then 
		self:AddOrigin(originPosition, self.textureKit);
	end

	self.lineThickness = Lerp(1, 2, Saturate(1 - self:GetMap():GetCanvasZoomPercent())) * 85;
	local animaNodes = C_AnimaDiversion.GetAnimaDiversionNodes(); 
	if (not animaNodes) then 
		return;
	end 

	for _, nodeData in ipairs(animaNodes) do
		nodeData.textureKit = self.textureKit
		self:AddNode(nodeData);
	end 

end

function AnimaDiversionDataProviderMixin:AddNode(nodeData)
	local pin = self:GetMap():AcquirePin("AnimaDiversionPinTemplate");

	pin:SetPosition(nodeData.normalizedPosition.x, nodeData.normalizedPosition.y);
	pin.nodeData = nodeData;
	pin.owner = self;
	pin.forceReinforceState = self.forceReinforceState; 
	pin:SetSize(150,175);

	self:SetupConnectionOnPin(pin);
	pin:Setup(); 
end

function AnimaDiversionDataProviderMixin:AddOrigin(position, textureKit)
	local pin = self:GetMap():AcquirePin("AnimaDiversionPinTemplate");

	pin:SetPosition(position.x, position.y);
	pin.owner = self; 
	pin.nodeData = nil;
	pin.textureKit = textureKit;
	pin:Setup();
	pin:SetSize(175,175); 
	pin:Show(); 
	self.origin = pin; 
end 

function AnimaDiversionDataProviderMixin:AddModelScene()
	local pin = self:GetMap():AcquirePin("AnimaDiversionModelScenePinTemplate");
	pin:SetPosition(0.5, 0.5);
	self.modelScenePin = pin; 
	local width = self:GetMap():DenormalizeHorizontalSize(1.0); 
	local height = self:GetMap():DenormalizeVerticalSize(1.0);
	pin:SetSize(width, height);
	pin.ModelScene:SetSize(width, height);
	pin.ModelScene:SetFrameLevel(1000);
end 

AnimaDiversionModelScenePinMixin = CreateFromMixins(MapCanvasPinMixin); 
function AnimaDiversionModelScenePinMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_ANIMA_DIVERSION_MODELSCENE_PIN");
end 

AnimaDiversionPinMixin = CreateFromMixins(MapCanvasPinMixin); 
function AnimaDiversionPinMixin:OnLoad()
	self:UseFrameLevelType("PIN_FRAME_LEVEL_ANIMA_DIVERSION_PIN");
end 

function AnimaDiversionPinMixin:SetupPinStatus()
	if(not self.nodeData) then
		return; 
	end 

	self.ReadyState = self.nodeData.state == Enum.AnimaDiversionNodeState.Available;
	self.ReinforceState = self.nodeData.state == Enum.AnimaDiversionNodeState.SelectedPermanent;
	self.SelectState = self.nodeData.state == Enum.AnimaDiversionNodeState.SelectedTemporary;
	self.UnavailableState = self.nodeData.state == Enum.AnimaDiversionNodeState.Unavailable;
end 

function AnimaDiversionPinMixin:SetupOrigin()
	self.IconReady:Hide();
	self.IconReinforce:Hide();
	self.Icon:SetAtlas("AnimaChannel-Icon-Device", TextureKitConstants.UseAtlasSize);
	self.Icon:Show(); 

	local borderAtlas = GetFinalNameFromTextureKit(ANIMA_DIVERSION_ORIGIN_PIN_BORDER, self.textureKit);
	self.IconSelect:SetAtlas(borderAtlas, TextureKitConstants.UseAtlasSize)
	self.IconSelect:Show();

	if(self.reinforceEffect) then 
		self.reinforceEffect:CancelEffect(); 
		self.reinforceEffect = nil; 
	end 
end 

function AnimaDiversionPinMixin:SetState(enabled)
	self.IconReady:SetDesaturated(not enabled);
	self.IconReinforce:SetDesaturated(not enabled);
	self.IconSelect:SetDesaturated(not enabled);
	self.Icon:SetDesaturated(not enabled);
end

function AnimaDiversionPinMixin:SetEffects()
	if(self.owner.modelScenePin) then 
		if(self.nodeData and self.ReadyState) then 
			local effectID = reinforceNodeTextureKitAnimationEffectId[self.nodeData.textureKit];
			if (effectID) then 
				self.owner.modelScenePin.ModelScene:AddEffect(effectID, self, self);
			end 
		end
	end 
end
function AnimaDiversionPinMixin:Setup() 
	self:Show();

	if(not self.nodeData) then
		self:SetupOrigin();
		return; 
	end 

	self:SetupPinStatus(); 
	SetupTextureKitOnRegions(self.nodeData.textureKit, self, animaPinTextureKitRegions, TextureKitConstants.DoNotSetVisibility, TextureKitConstants.UseAtlasSize);
	self.IconReady:SetShown(self.ReadyState);
	self.IconReinforce:SetShown(self.ReinforceState);
	self.IconSelect:SetShown(self.SelectState);
	self.Icon:SetShown(self.UnavailableState);

	self:SetEffects(); 
	if (self.lineContainer) then 
		self.lineContainer:SetShown(self.ReinforceState or self.SelectState);
	end
	self:SetState(not self.UnavailableState);
end 

function AnimaDiversionPinMixin:SetReinforceState(reinforce) 
	self.IconSelect:SetShown(self.SelectState or reinforce);
	self.IconReinforce:SetShown(self.ReinforceState);
	self.IconReady:SetShown(not reinforce and self.ReadyState);
	self.Icon:SetShown(self.UnavailableState and not reinforce);

	if(reinforce and self.nodeData and self.ReinforceState) then 
		if(not self.sparkleEffect or not self.sparkleEffect:IsActive()) then
			self.sparkleEffect = self.owner.modelScenePin.ModelScene:AddEffect(ANIMA_REINFORCE_MODEL_EFFECT_ID, self, self);
		end
	end
end 

function AnimaDiversionPinMixin:OnMouseEnter() 
	if(AnimaDiversionFrame.SelectPinInfoFrame:IsSelectionInfoShowingForNode(self)) then 
		return;
	end 

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if(not self.nodeData) then -- If we are the origin pin we want to show a special tooltip. 
		GameTooltip_AddHighlightLine(GameTooltip, ANIMA_DIVERSION_ORIGIN_TOOLTIP);
	else 
		GameTooltip_AddNormalLine(GameTooltip, self.nodeData.name);
		GameTooltip_AddHighlightLine(GameTooltip, self.nodeData.description);
		if(self.UnavailableState) then 
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddErrorLine(GameTooltip, ANIMA_DIVERSION_NODE_UNAVAILABLE);
		elseif (self.ReinforceState) then 
			GameTooltip_AddBlankLineToTooltip(GameTooltip);
			GameTooltip_AddColoredLine(GameTooltip, ANIMA_DIVERSION_POI_REINFORCED, GREEN_FONT_COLOR);
		end
	end 

	GameTooltip:Show(); 
end

function AnimaDiversionPinMixin:OnMouseLeave() 
	GameTooltip:Hide();
end

function AnimaDiversionPinMixin:OnClick(button) 
	if(not self.nodeData) then -- If we are the origin pin, don't do anything.
		return;
	end 

	if(self.UnavailableState or self.ReinforceState) then 
		return; 
	end 

	local reinforceNodeSelection = self.owner:CanReinforceNode(); 

	if(AnimaDiversionFrame.SelectPinInfoFrame:IsSelectionInfoShowingForNode(self)) then 
		GameTooltip:Hide();
	end

	if(reinforceNodeSelection) then 
		AnimaDiversionFrame.ReinforceInfoFrame:SelectNodeToReinforce(self);
	else 
		AnimaDiversionFrame.SelectPinInfoFrame:SetupAndShow(self);
		if(AnimaDiversionFrame.SelectPinInfoFrame:IsSelectionInfoShowingForNode(self)) then 
			GameTooltip:Hide();
		end
	end
end 