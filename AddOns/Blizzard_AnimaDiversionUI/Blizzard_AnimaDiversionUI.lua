
AnimaDiversionFrameMixin = { }; 
function AnimaDiversionFrameMixin:OnLoad() 
	MapCanvasMixin.OnLoad(self);	
	self:SetShouldZoomInOnClick(false);
	self:SetShouldPanOnClick(false);
	self:AddStandardDataProviders();
end 

function AnimaDiversionFrameMixin:OnShow()
	self:SetMapID(self.mapID);
	MapCanvasMixin.OnShow(self);

	self:ResetZoom();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
	self:RegisterEvent("ANIMA_DIVERSION_CLOSE");
end

function AnimaDiversionFrameMixin:OnHide()
	MapCanvasMixin.OnHide(self);
	self:UnregisterEvent("ANIMA_DIVERSION_CLOSE");
end 

function AnimaDiversionFrameMixin:OnEvent(event, ...) 
	if (event == "ANIMA_DIVERSION_CLOSE") then
		HideUIPanel(self);
	end 
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
	self:Show(); 
end 

AnimaDiversionSelectionInfoMixin = { }; 

function AnimaDiversionSelectionInfoMixin:SetupAndShow(node)
	self:ClearAllPoints(); 
	self:SetPoint("LEFT", node, "RIGHT", 20, 0);

	local nodeInfo = node.nodeData; 
	self.Title:SetText(nodeInfo.name);
	self.Description:SetText(nodeInfo.description);
	self.Cost:SetText(nodeInfo.cost);
	self.showingNode = node;

	self.SelectButton:SetShown(nodeInfo.state == Enum.AnimaDiversionNodeState.Available);
	self.AlreadySelected:SetShown(nodeInfo.state ~= Enum.AnimaDiversionNodeState.Available)
	self:Show();
end 

AnimaDiversionSelectButtonMixin = { }; 

function AnimaDiversionSelectButtonMixin:OnClick() 
	C_AnimaDiversion.SelectAnimaNode(self:GetParent().showingNode.nodeData.talentID);
end 

