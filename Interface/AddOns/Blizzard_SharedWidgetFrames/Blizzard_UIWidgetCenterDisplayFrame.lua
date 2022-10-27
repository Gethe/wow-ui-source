
local textureKitBackgroundFormat = "%s-Background"; 
local widgetContainerYOffsetsByTextureKit = { 
	["completiondialog-dragonflightcampaign"] = 43, 
}

WidgetCenterDisplayFrameMixin = { };
function WidgetCenterDisplayFrameMixin:OnLoad()
	self:RegisterEvent("GENERIC_WIDGET_DISPLAY_SHOW");
end

function WidgetCenterDisplayFrameMixin:OnEvent(event, ...)
	if(event == "GENERIC_WIDGET_DISPLAY_SHOW") then 
		self:Setup(...); 
	end 
end

function WidgetCenterDisplayFrameMixin:OnHide() 
	self.WidgetContainer:UnregisterForWidgetSet();
end

function WidgetCenterDisplayFrameMixin:Setup(displayInfo)
	if(not displayInfo) then 
		return; 
	end

	self:Show(); 
	if(displayInfo.title) then 
		self.TitleContainer.Title:SetText(displayInfo.title); 
	end

	self.WidgetContainer:UnregisterForWidgetSet();

	if(displayInfo.uiWidgetSetID) then 
		self.WidgetContainer:RegisterForWidgetSet(displayInfo.uiWidgetSetID, DefaultWidgetLayout);
		local widgetContainerOffsetY = widgetContainerYOffsetsByTextureKit[displayInfo.uiTextureKit];
		if (widgetContainerOffsetY) then 
			self.WidgetContainer:ClearAllPoints(); 
			self.WidgetContainer:SetPoint("TOP", self.TitleContainer, "BOTTOM", 0, widgetContainerOffsetY);
		end
	end

	if(displayInfo.uiTextureKit) then 
		local atlas = GetFinalNameFromTextureKit(textureKitBackgroundFormat, displayInfo.uiTextureKit);
		if(atlas) then 
			self.Background:SetAtlas(atlas, TextureKitConstants.IgnoreAtlasSize);
		else 
			self.Background:SetAtlas(nil);
		end
	end

	self.fixedWidth = displayInfo.frameWidth > 0 and displayInfo.frameWidth or nil; 
	self.fixedHeight = displayInfo.frameHeight > 0 and displayInfo.frameHeight or nil; 
	
	self.TitleContainer.fixedWidth = self.fixedWidth or self:GetWidth();
	self.TitleContainer.Title:SetWidth(self.TitleContainer.fixedWidth);
	self.TitleContainer:Layout();
	self:Layout();
end 

UIWidgetCenterDisplayFrameButtonMixin = { };

function UIWidgetCenterDisplayFrameButtonMixin:OnClick()
	self:GetParent():Hide(); 
end		