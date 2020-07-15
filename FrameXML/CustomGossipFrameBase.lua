CustomGossipManagerMixin = {};

CUSTOM_GOSSIP_FRAME_EVENTS = {
	"GOSSIP_SHOW",
	"GOSSIP_CLOSED",
}

do
	local function HandleNPEGuideGossipShow(textureKit)
		LoadAddOn("Blizzard_NewPlayerExperienceGuide");
		ShowUIPanel(GuideFrame);
		return GuideFrame;
	end

	function CustomGossipManagerMixin:OnLoad()
		FrameUtil.RegisterFrameForEvents(self, CUSTOM_GOSSIP_FRAME_EVENTS);

		-- NOTE: This shim exists because the guide system lives in a demand-loaded addon
		self:RegisterHandler("npe-guide", HandleNPEGuideGossipShow);
	end

end

function CustomGossipManagerMixin:OnEvent(event, ...)
	if (event == "GOSSIP_SHOW") then
		self:HandleOpenEvent(...)
	elseif (event == "GOSSIP_CLOSED") then
		self:HideOpenedUIPanel();
	end
end

function CustomGossipManagerMixin:HandleOpenEvent(textureKit)
	if(not textureKit) then
		GossipFrame_HandleShow(GossipFrame);
	else
		assert(not self.customFrame)
		local handler = self:GetHandler(textureKit);
		if handler then
			self.customFrame = handler(textureKit);
		end
	end
end

function CustomGossipManagerMixin:HideOpenedUIPanel()
	if(GossipFrame:IsShown()) then
		GossipFrame_HandleHide(GossipFrame);
	elseif self.customFrame then
		HideUIPanel(self.customFrame);
		self.customFrame = nil;
	end
end

function CustomGossipManagerMixin:RegisterHandler(textureKit, handlerFn)
	if not self.handlers then
		self.handlers = {};
	end

	self.handlers[textureKit] = handlerFn;
end

function CustomGossipManagerMixin:GetHandler(textureKit)
	return self.handlers and self.handlers[textureKit];
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