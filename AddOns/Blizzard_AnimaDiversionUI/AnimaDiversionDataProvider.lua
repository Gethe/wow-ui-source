local animaPinTextureKitRegions = {
	["Icon"] = "AnimaChannel-Icon-%s-Normal",
	["IconSelect"] = "AnimaChannel-Icon-%s-Select",
	["IconReinforce"] = "AnimaChannel-Icon-%s-Reinforce",
	["IconReady"] = "AnimaChannel-Icon-%s-Ready",
};

local ANIMA_DIVERSION_ORIGIN_PIN_BORDER = "AnimaChannel-Icon-Device-%s-Border";

AnimaDiversionDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function AnimaDiversionDataProviderMixin:OnShow()
	self:RegisterEvent("ANIMA_DIVERSION_TALENT_UPDATED");
end 

function AnimaDiversionDataProviderMixin:OnHide()
	self:UnregisterEvent("ANIMA_DIVERSION_TALENT_UPDATED");
end 

function AnimaDiversionDataProviderMixin:OnEvent(event, ...)
	if (event == "ANIMA_DIVERSION_TALENT_UPDATED") then 
		self:RefreshAllData(); 
	end
end 

function AnimaDiversionDataProviderMixin:SetupConnectionOnPin(pin)
	if(not self.origin) then 
		return; 
	end 

	pin.lineContainer = self.backgroundLinePool:Acquire();
	pin.lineContainer.Fill:SetThickness(self.lineThickness);
	pin.lineContainer.Fill:SetStartPoint("CENTER", self.origin);
	pin.lineContainer.Fill:SetEndPoint("CENTER", pin);
end

function AnimaDiversionDataProviderMixin:RemoveAllData()
	self:GetMap():RemoveAllPinsByTemplate("AnimaDiversionPinTemplate");
end 

function AnimaDiversionDataProviderMixin:RefreshAllData(fromOnShow)
	self:RemoveAllData();

	if not self.backgroundLinePool then
		self.backgroundLinePool = CreateFramePool("FRAME", self:GetMap():GetCanvas(), "AnimaDiversionConnectionTemplate", OnRelease);
	end

	self.backgroundLinePool:ReleaseAll(); 
	self.textureKit = C_AnimaDiversion.GetTextureKit();

	local originPosition = C_Map.GetPlayerMapPosition(self:GetMap():GetMapID(), "player");
	self:AddOrigin(originPosition, self.textureKit);

	self.lineThickness = Lerp(1, 2, Saturate(1 - self:GetMap():GetCanvasZoomPercent())) * 45;
	local animaNodes = C_AnimaDiversion.GetAnimaDiversionNodes(); 
	for _, nodeData in ipairs(animaNodes) do
		nodeData.textureKit = self.textureKit; 
		self:AddNode(nodeData);
	end 

end

function AnimaDiversionDataProviderMixin:AddNode(nodeData)
	local pin = self:GetMap():AcquirePin("AnimaDiversionPinTemplate");
	pin:SetPosition(nodeData.normalizedPosition.x, nodeData.normalizedPosition.y);
	pin.nodeData = nodeData;
	pin.owner = self;
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
	pin:Show(); 
	self.origin = pin; 
end 

AnimaDiversionPinMixin = CreateFromMixins(MapCanvasPinMixin); 

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
	self.lineContainer:SetShown(self.ReinforceState or self.SelectState);
end 

function AnimaDiversionPinMixin:SetReinforceState(reinforce) 
	self.IconReinforce:SetShown(reinforce);
	self.IconReady:SetShown(not reinforce and self.ReadyState);
	self.IconSelect:SetShown(not reinforce and self.SelectState);
	self.Icon:SetShown(not reinforce and self.UnavailableState);
end 

function AnimaDiversionPinMixin:SetSelected(reinforceNode)
	if(not self.ReadyState) then 
		return; 
	end 

	self.isSelected = not self.isSelected;
	self.lineContainer:SetShown(self.ReinforceState or self.SelectState); 
end 

function AnimaDiversionPinMixin:OnMouseEnter() 
	if(self.isSelected) then 
		return;
	end 

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if(not self.nodeData) then -- If we are the origin pin we want to show a special tooltip. 
		GameTooltip_AddHighlightLine(GameTooltip, ANIMA_DIVERSION_ORIGIN_TOOLTIP);
	else 
		GameTooltip_AddNormalLine(GameTooltip, self.nodeData.name);
		GameTooltip_AddHighlightLine(GameTooltip, self.nodeData.description);
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
	local reinforceNodeSelection = AnimaDiversionFrame:CanReinforceNode(); 
	self:SetSelected(reinforceNodeSelection); 

	if(self.isSelected) then 
		GameTooltip:Hide();
	end

	if(reinforceNodeSelection) then 
		AnimaDiversionFrame.ReinforceInfoFrame:SelectNodeToReinforce(self);
	else 
		AnimaDiversionFrame.SelectPinInfoFrame:SetupAndShow(self);
	end
end 