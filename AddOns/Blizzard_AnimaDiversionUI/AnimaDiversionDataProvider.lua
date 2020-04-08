AnimaDiversionDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

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

	local originPosition = C_Map.GetPlayerMapPosition(self:GetMap():GetMapID(), "player");
	self:AddOrigin(originPosition);

	self.lineThickness = Lerp(1, 2, Saturate(1 - self:GetMap():GetCanvasZoomPercent())) * 45;
	local animaNodes = C_AnimaDiversion.GetAnimaDiversionNodes();
	for _, nodeData in ipairs(animaNodes) do
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

function AnimaDiversionDataProviderMixin:AddOrigin(position)
	local pin = self:GetMap():AcquirePin("AnimaDiversionPinTemplate");
	pin:SetPosition(position.x, position.y);
	pin.owner = self; 
	pin.nodeData = nil;
	pin:Setup();
	pin:Show(); 
	self.origin = pin; 
end 

AnimaDiversionPinMixin = CreateFromMixins(MapCanvasPinMixin); 

function AnimaDiversionPinMixin:Setup() 
	self:Show();

	if(not self.nodeData) then 
		return; 
	end 

	self.Icon:SetTexture(self.nodeData.icon);
	self.isSelected = self.nodeData.state ~= Enum.AnimaDiversionNodeState.Available; 
	self.lineContainer:SetShown(self.isSelected); 
end 

function AnimaDiversionPinMixin:SetSelected()
	if(self.nodeData.state ~= Enum.AnimaDiversionNodeState.Available) then 
		return; 
	end 

	self.isSelected = not self.isSelected;
	self.lineContainer:SetShown(self.isSelected); 
end 

function AnimaDiversionPinMixin:OnMouseEnter() 
	if(not self.nodeData) then -- If we are the origin pin.. don't do anything (Aubrie TODO: Add a tooltip to this)
		return;
	end 
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddNormalLine(GameTooltip, self.nodeData.name);
	GameTooltip_AddHighlightLine(GameTooltip, self.nodeData.description);
	GameTooltip:Show(); 
end

function AnimaDiversionPinMixin:OnMouseLeave() 
	GameTooltip:Hide();
end

function AnimaDiversionPinMixin:OnClick(button) 
	if(not self.nodeData) then -- If we are the origin pin, don't do anything.
		return;
	end 

	self:SetSelected(); 
	AnimaDiversionFrame.SelectPinInfoFrame:SetupAndShow(self);
end 