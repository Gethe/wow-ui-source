CustomGossipManagerMixin = {}; 

CUSTOM_GOSSIP_FRAME_EVENTS = {
	"GOSSIP_SHOW", 
	"GOSSIP_CLOSED",
}
function CustomGossipManagerMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, CUSTOM_GOSSIP_FRAME_EVENTS);
end 

function CustomGossipManagerMixin:OnEvent(event, ...)
	if (event == "GOSSIP_SHOW") then
		self:HandleOpenEvent(...)
	elseif (event == "GOSSIP_CLOSED") then 
		self:HideOpenedUIPanel(); 
	end 
end 

-- Aubrie TODO: Set up specific system events Routes to the specific systems from here. 
function CustomGossipManagerMixin:HandleOpenEvent(textureKit)
	if(not textureKit) then 
		GossipFrame_HandleShow(GossipFrame); 
	end 

	-- Assign the texture kit to the appropriate system frame
end 

-- AUBRIE TODO: Figure out which system is showing here. 
function CustomGossipManagerMixin:HideOpenedUIPanel()
	if(GossipFrame:IsShown()) then 
		GossipFrame_HandleHide(GossipFrame);
	end

	-- Handle other systems hides here. 
end 

CustomGossipFrameBaseMixin = {};

function CustomGossipFrameBaseMixin:OnLoad()
	self.ScrollFrame.update = function() self:RefreshLayout() end;
end 

--To be overriden
function CustomGossipFrameBaseMixin:SetupFrames()
end 

function CustomGossipFrameBaseMixin:BuildOptionList() 
	self.gossipOptions = C_GossipInfo.GetOptions();
end

--To be overriden
function CustomGossipFrameBaseMixin:RefreshLayout() 
end 

function CustomGossipFrameBaseMixin:SetupScrollFrameTextures(scrollFrameTextureKitRegions)
	SetupTextureKitOnRegions(self.textureKit, self.scrollFrame, scrollFrameTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end 

function CustomGossipFrameBaseMixin:SetupBackgroundFrameTexture(backgroundTextureKitRegions)
	SetupTextureKitOnRegions(self.textureKit, self, backgroundTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end 

function CustomGossipFrameBaseMixin:SetupFrameTextures(textureKitRegions) 
	SetupTextureKitOnRegions(self.textureKit, self, textureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end 

CustomGossipOptionButtonBaseMixin = {}; 

function CustomGossipOptionButtonBaseMixin:OnClick() 
	C_GossipInfo.SelectOption(self.index);
end 

function CustomGossipOptionButtonBaseMixin:Setup(textureKit, buttonInfo, index, buttonTextureKitRegions)
	self.Title:SetText(buttonInfo.name);
	self.index = index; 
	if (textureKit and buttonTextureKitRegions) then 
		SetupTextureKitOnRegions(textureKit, scrollFrame, buttonTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	end 
	self:Show(); 
end 