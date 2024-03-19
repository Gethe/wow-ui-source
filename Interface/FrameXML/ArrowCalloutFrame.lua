local DirectionData = {
	[Enum.ArrowCalloutDirection.Up] = {
		Anchor			= "TOP";
		RelativePoint	= "BOTTOM";
		ContentOffsetY	= 5;
		Opposite		= "DOWN";
	},
	[Enum.ArrowCalloutDirection.Down] = {
		Anchor			= "BOTTOM";
		RelativePoint	= "TOP";
		ContentOffsetY	= -5;
		Opposite		= "UP";
	},
	[Enum.ArrowCalloutDirection.Left] = {
		Anchor			= "LEFT";
		RelativePoint	= "RIGHT";
		ContentOffsetX	= -5;
		Opposite		= "RIGHT";
	},
	[Enum.ArrowCalloutDirection.Right] = {
		Anchor			= "RIGHT";
		RelativePoint	= "LEFT";
		ContentOffsetX	= 5;
		Opposite		= "LEFT";
	},
}

local ArrowDirection = {
	[Enum.ArrowCalloutDirection.Up] = {
		Anchor			= "TOP";
		RelativePoint	= "TOP";
		ContentOffsetY	= -23;
	},
	[Enum.ArrowCalloutDirection.Down] = {
		Anchor			= "BOTTOM";
		RelativePoint	= "BOTTOM";
		ContentOffsetY	= -43;
	},
	[Enum.ArrowCalloutDirection.Left] = {
		Anchor			= "RIGHT";
		RelativePoint	= "LEFT";
		ContentOffsetX	= 23;
	},
	[Enum.ArrowCalloutDirection.Right] = {
		Anchor			= "LEFT";
		ContentOffsetX	= -23;
		RelativePoint	= "RIGHT";
	},
}

local ArrowTemplate = 
{
	[Enum.ArrowCalloutDirection.Up] = "ArrowCalloutPointerUp", 
	[Enum.ArrowCalloutDirection.Down] = "ArrowCalloutPointerDown", 
	[Enum.ArrowCalloutDirection.Left] = "ArrowCalloutPointerLeft", 
	[Enum.ArrowCalloutDirection.Right] = "ArrowCalloutPointerRight", 
}

ArrowCalloutMixin = {};

function ArrowCalloutMixin:OnLoad()
	self:RegisterEvent("SHOW_ARROW_CALLOUT");
	self:RegisterEvent("HIDE_ARROW_CALLOUT");
	self:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED");
	
	if C_GameEnvironmentManager.GetCurrentGameEnvironment() == Enum.GameEnvironment.WoWLabs then
		EventRegistry:RegisterCallback("GameTooltip.HideTooltip", function() C_ArrowCalloutManager.HideWorldLootObjectCallout() end);
	end

	self.currentCallouts = { }; 
	self.calloutPool = CreateFramePoolCollection();
	self.calloutPool:CreatePool("FRAME", self, "ArrowCalloutContainerTemplate");
	self.calloutPool:CreatePool("FRAME", self, "ArrowCalloutContainerTemplateWithCloseButtonTemplate");
	self.calloutPool:CreatePool("FRAME", self, "WidgetContainerCalloutTemplate");
end 

function ArrowCalloutMixin:OnEvent(event, ...)
	if(event == "PLAYER_SOFT_INTERACT_CHANGED") then 
		local previousTarget, currentTarget = ...;
		if (previousTarget ~= currentTarget) then
			C_ArrowCalloutManager.HideWorldLootObjectCallout();

			if (currentTarget) then 
				C_ArrowCalloutManager.SetWorldLootObjectCalloutFromGUID(currentTarget); 
			end
		end
	elseif (event == "SHOW_ARROW_CALLOUT") then 
		local calloutInfo = ...;
		self:Setup(calloutInfo); 
	elseif (event == "HIDE_ARROW_CALLOUT") then
		local currentCalloutID = ...;
		self:HideCallout(...); 
	end
end 

function ArrowCalloutMixin:HideCallout(calloutID) 
	if(not calloutID) then
		return; 
	end 
	local callout = self.currentCallouts[calloutID]; 
	if(callout) then 
		self.calloutPool:Release(callout); 
		self.currentCallouts[calloutID] = nil;  
	end
end

function ArrowCalloutMixin:Setup(calloutInfo)
	if(not calloutInfo) then 
		return; 
	end 

	local anchorFrame = _G[calloutInfo.calloutFrame];
	if(not anchorFrame or self.currentCallouts[calloutInfo.calloutID]) then 
		return; 
	end
	local pool;
	if (calloutInfo.calloutType == Enum.ArrowCalloutType.Tutorial) then 
		pool = self.calloutPool:GetPool("ArrowCalloutContainerTemplateWithCloseButtonTemplate"); 
	elseif (calloutInfo.calloutType == Enum.ArrowCalloutType.WidgetContainerNoBorder) then 
		pool = self.calloutPool:GetPool("WidgetContainerCalloutTemplate"); 
	else 
		pool = self.calloutPool:GetPool("ArrowCalloutContainerTemplate"); 
	end 
	local calloutFrame = pool:Acquire(); 
	self.currentCallouts[calloutInfo.calloutID] = calloutFrame; 
	self:AnchorCallout(calloutFrame, calloutInfo);
	calloutFrame:Setup(calloutInfo); 
	calloutFrame:Show(); 
end

function ArrowCalloutMixin:AnchorCallout(callout, calloutInfo)
	local anchorFrame = _G[calloutInfo.calloutFrame]; 
	local direction = calloutInfo.calloutDirection; 
	
	if(not anchorFrame) then 
		return; 
	end

	local directionData = DirectionData[direction];
	if(not directionData) then
		return; 
	end 

	callout:ClearAllPoints();
	callout:SetPoint(directionData.Anchor, anchorFrame, directionData.RelativePoint, calloutInfo.offsetX, calloutInfo.offsetY);
end		

function ArrowCalloutMixin:OnKeyDown(key)
	if(key == "TAB" and self.calloutPool:GetNumActive() > 0) then 
		C_ArrowCalloutManager.SwapWorldLootObjectCallout();
		self:SetPropagateKeyboardInput(false);	
	else
		self:SetPropagateKeyboardInput(true);
	end 
end

function ArrowCalloutMixin:OnGamePadButtonDown(key)
	if(key == "PAD4" and self.calloutPool:GetNumActive() > 0) then 
		C_ArrowCalloutManager.SwapWorldLootObjectCallout();
	else 
		local keybind = GetBindingFromClick(key);
		if(keybind) then 
			RunBinding(keybind);
		end 
	end
end

ArrowCalloutContainerMixin = { }
function ArrowCalloutContainerMixin:OnLoad()
	self.arrowPool = CreateFramePoolCollection();
	self.arrowPool:CreatePool("FRAME", self, "ArrowCalloutPointerUp");
	self.arrowPool:CreatePool("FRAME", self, "ArrowCalloutPointerDown");
	self.arrowPool:CreatePool("FRAME", self, "ArrowCalloutPointerLeft");
	self.arrowPool:CreatePool("FRAME", self, "ArrowCalloutPointerRight");
end 

function ArrowCalloutContainerMixin:OnKeyDown(key)
	if(#self.currentCallouts > 0 and key == "TAB") then 
		self:SetPropagateKeyboardInput(false);
		C_ArrowCalloutManager.SwapWorldLootObjectCallout();
	else
		self:SetPropagateKeyboardInput(true);
	end 
end

function ArrowCalloutContainerMixin:Setup(calloutInfo)
	local content = calloutInfo.calloutText; 
	local direction = calloutInfo.calloutDirection; 
	
	self.calloutInfo = calloutInfo; 

	self.arrowPool:ReleaseAll(); 
	
	local maximumWidth = 226; 
	self.Content.Text:SetSize(0,0);
	self.Content.Text:SetText(content);
	self.Content.Text:SetWidth(math.min(maximumWidth, self.Content.Text:GetWidth()))
	self.Content:SetHeight(self.Content.Text:GetHeight() + self.heightPadding);
	self.Content:SetWidth(self.Content.Text:GetWidth() + self.widthPadding);

	local arrowButtonTemplate =	ArrowTemplate[direction];
	local pool = self.arrowPool:GetPool(arrowButtonTemplate);
	local arrowButton = pool:Acquire();

	local arrowDirection = ArrowDirection[direction];
	arrowButton:ClearAllPoints();
	arrowButton:SetPoint(arrowDirection.Anchor, self.Content, arrowDirection.RelativePoint, arrowDirection.ContentOffsetX or 0, arrowDirection.ContentOffsetY or 0)
	arrowButton:Show();
	arrowButton.Anim:Play()
	self:Layout(); 
end 

ArrowCalloutCloseButtonMixin = { };
function ArrowCalloutCloseButtonMixin:OnClick()
	C_ArrowCalloutManager.AcknowledgeCallout(self:GetParent().calloutInfo.calloutID);
end 

WidgetContainerCalloutTemplateMixin = { }; 

function WidgetContainerCalloutTemplateMixin:Setup(calloutInfo)
	if(calloutInfo.uiWidgetSetID) then 
		self:RegisterForWidgetSet(calloutInfo.uiWidgetSetID, DefaultWidgetLayout);
	end 
	self:Layout(); 
end 