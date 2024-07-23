CustomGossipManagerMixin = {};

CUSTOM_GOSSIP_FRAME_EVENTS = {
	"GOSSIP_SHOW",
	"GOSSIP_CLOSED",
}

do
	local function HandleNPEGuideGossipShow(textureKit)
		C_AddOns.LoadAddOn("Blizzard_NewPlayerExperienceGuide");
		ShowUIPanel(GuideFrame);
		return GuideFrame;
	end

	local function HandleTorghastLevelPickerGossipShow(textureKit)
		C_AddOns.LoadAddOn("Blizzard_TorghastLevelPicker");
		TorghastLevelPickerFrame:TryShow(textureKit);
		return TorghastLevelPickerFrame;
	end

	local function HandleDelvesDifficultyPickerGossipShow(textureKit)
		C_AddOns.LoadAddOn("Blizzard_DelvesDifficultyPicker");
		DelvesDifficultyPickerFrame:TryShow(textureKit);
		return DelvesDifficultyPickerFrame;
	end

	function CustomGossipManagerMixin:OnLoad()
		FrameUtil.RegisterFrameForEvents(self, CUSTOM_GOSSIP_FRAME_EVENTS);

		-- NOTE: This shim exists because the guide system lives in a demand-loaded addon
		self:RegisterHandler("npe-guide", HandleNPEGuideGossipShow);
		self:RegisterHandler("skoldushall", HandleTorghastLevelPickerGossipShow);
		self:RegisterHandler("mortregar", HandleTorghastLevelPickerGossipShow);
		self:RegisterHandler("coldheartinterstitia", HandleTorghastLevelPickerGossipShow);
		self:RegisterHandler("fracturechambers", HandleTorghastLevelPickerGossipShow);
		self:RegisterHandler("soulforges", HandleTorghastLevelPickerGossipShow);
		self:RegisterHandler("theupperreaches", HandleTorghastLevelPickerGossipShow);
		self:RegisterHandler("twistingcorridors", HandleTorghastLevelPickerGossipShow);
		self:RegisterHandler("delves-difficulty-picker", HandleDelvesDifficultyPickerGossipShow);
	end

end

function CustomGossipManagerMixin:OnEvent(event, ...)
	if (event == "GOSSIP_SHOW") then
		self:HandleOpenEvent(...)
	elseif (event == "GOSSIP_CLOSED") then
		local interactionIsContinuing = ...;
		self:HideOpenedUIPanel(interactionIsContinuing);
	end
end

function CustomGossipManagerMixin:HandleOpenEvent(textureKit)
	if(not textureKit) then
		GossipFrame:HandleShow();
	else
		local handler = self:GetHandler(textureKit);
		if handler then
			self.customFrame = handler(textureKit);
		else 
			GossipFrame:HandleShow(textureKit);
		end
	end
end

function CustomGossipManagerMixin:HideOpenedUIPanel(interactionIsContinuing)
	if(GossipFrame:IsShown()) then
		GossipFrame:HandleHide(interactionIsContinuing);
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

-- To be overriden
function CustomGossipFrameBaseMixin:OnLoad()

end

--To be overriden
function CustomGossipFrameBaseMixin:SetupFrames()
end

local function GossipOptionSort(leftInfo, rightInfo)
	return leftInfo.orderIndex < rightInfo.orderIndex;
end  

function CustomGossipFrameBaseMixin:BuildOptionList()
	self.gossipOptions = C_GossipInfo.GetOptions();
	table.sort(self.gossipOptions, GossipOptionSort);
end

--To be overriden
function CustomGossipFrameBaseMixin:RefreshLayout()
end

function CustomGossipFrameBaseMixin:SetupBackgroundFrameTexture(backgroundTextureKitRegions)
	SetupTextureKitOnRegions(self.textureKit, self, backgroundTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end

function CustomGossipFrameBaseMixin:SetupFrameTextures(textureKitRegions)
	SetupTextureKitOnRegions(self.textureKit, self, textureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
end

CustomGossipFrameBaseGridMixin = { }; 

function CustomGossipFrameBaseGridMixin:LayoutGridInit(anchor, overridePaddingX, overridePaddingY, overrideDirection)
	if(not self.gossipOptionsPool) then 
		return;
	end 

	self.gossipOptionsPool:ReleaseAll();

	self.totalNumGossipOptions = #self.gossipOptions;

	if(self.totalNumGossipOptions <= 0 ) then 
		return; 
	end 
	self.gossipOptionsByIndex = {};

	local function FactoryFunction(index)
		if index > self.totalNumGossipOptions then
			return nil;
		end
		local frame = self.gossipOptionsPool:Acquire();
		self.gossipOptionsByIndex[index] = frame;
		return frame;
	end

	local totalWidth = self.GridLayoutContainer:GetWidth();
	local totalHeight = self.GridLayoutContainer:GetHeight();
	AnchorUtil.GridLayoutFactory(FactoryFunction, anchor, totalWidth, totalHeight, overrideDirection, overridePaddingX, overridePaddingY);

	self.maxOptionsPerPage = #self.gossipOptionsByIndex;
	self.numPages = math.ceil(self.totalNumGossipOptions / self.maxOptionsPerPage); 
	self:SetStartingPage(1); 
	self:SetupOptionsByStartingIndex(1);
end

function CustomGossipFrameBaseGridMixin:SetupOptionsByStartingIndex(index)
	if(not self.gossipOptions) then 
		return;
	end 

	if(index > self.totalNumGossipOptions) then 
		return;
	end 
	for i=1, self.maxOptionsPerPage do
		if (index <= self.totalNumGossipOptions and self.gossipOptions[index]) then	
			self.gossipOptionsByIndex[i]:Setup(self.textureKit, self.gossipOptions[index], index);
			self.gossipOptionsByIndex[i]:Show(); 
		else 
			self.gossipOptionsByIndex[i]:Hide(); 
		end 
		index = index + 1;
	end
end 

function CustomGossipFrameBaseGridMixin:NextGridPage()
	if(not self.gossipOptionsPool) then
		return; 
	end 

	self.gossipOptionsPool:ReleaseAll();
	
end 

CustomGossipOptionButtonBaseMixin = {};

--Override in custom system.
function CustomGossipOptionButtonBaseMixin:ShouldOptionBeEnabled(enabled)
end 

--Override in custom system.
function CustomGossipOptionButtonBaseMixin:SetState()

end 

--Override in custom system.
function CustomGossipOptionButtonBaseMixin:Setup()

end 

function CustomGossipOptionButtonBaseMixin:OnClick()
	C_GossipInfo.SelectOptionByIndex(self.index);
end

function CustomGossipOptionButtonBaseMixin:SetupBase(textureKit, buttonInfo, index, buttonTextureKitRegions)
	self.Title:SetText(buttonInfo.name);
	self.Title:Show(); 
	self.index = index; 
	if (textureKit and buttonTextureKitRegions) then
		SetupTextureKitOnRegions(textureKit, self, buttonTextureKitRegions, TextureKitConstants.SetVisibility, TextureKitConstants.UseAtlasSize);
	end
	self:Show();
end