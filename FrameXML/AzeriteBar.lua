local AZERITE_XP_BAR_EVENTS = {
	"PLAYER_ENTERING_WORLD",
	"AZERITE_ITEM_EXPERIENCE_CHANGED", 
	"CVAR_UPDATE",
};
AzeriteBarMixin = CreateFromMixins(StatusTrackingBarMixin);

function AzeriteBarMixin:ShouldBeVisible()
	return C_AzeriteItem.HasActiveAzeriteItem(); 
end

function AzeriteBarMixin:Update()
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem(); 
	
	if (not azeriteItemLocation) then 
		return; 
	end
	
	local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation); 
	
	self.xp, self.totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation);
	self.currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation); 
	self.xpToNextLevel = self.totalLevelXP - self.xp; 
		
	self:SetBarValues(self.xp, 0, self.totalLevelXP);
	self:UpdatePointsTooltip();
	self:Show();
end

function AzeriteBarMixin:UpdateOverlayFrameText()
	if ( self.OverlayFrame.Text:IsShown() ) then
		local xp = self.StatusBar:GetAnimatedValue();
		local _, totalLevelXP = self.StatusBar:GetMinMaxValues();
		self.OverlayFrame.Text:SetFormattedText(AZERITE_POWER_BAR, FormatPercentage(xp / totalLevelXP, true));
	end
end

function AzeriteBarMixin:AnimatedValueChangedCallback()
	self:UpdateOverlayFrameText();
	self:UpdatePointsTooltip();
end

function AzeriteBarMixin:OnLoad() 
	self:SetBarColor(ARTIFACT_BAR_COLOR:GetRGB());
	self.StatusBar:SetOnAnimatedValueChangedCallback(function() self:AnimatedValueChangedCallback(); end)
	self.priority = 3; 
end

function AzeriteBarMixin:OnEvent(event, ...)
	if ( self:IsVisible() ) then 
		if ( event == "PLAYER_ENTERING_WORLD" or event == "AZERITE_ITEM_EXPERIENCE_CHANGED") then
			self:Update();
		elseif ( event == "CVAR_UPDATE" ) then
			local name, value = ...;
			if ( name == "XP_BAR_TEXT" ) then
				self:UpdateTextVisibility();
			end
		end
	end
end

function AzeriteBarMixin:OnShow() 
	FrameUtil.RegisterFrameForEvents(self, AZERITE_XP_BAR_EVENTS);
	self:UpdateTextVisibility(); 
end

function AzeriteBarMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, AZERITE_XP_BAR_EVENTS);
end

function AzeriteBarMixin:OnEnter()
	self:ShowText(); 
	self:UpdateOverlayFrameText();
	self:SetupPointsTooltip();
end

function AzeriteBarMixin:OnLeave()
	self:HideText();
	GameTooltip_Hide();
	self:CancelItemLoadCallback();
end

function AzeriteBarMixin:CancelItemLoadCallback()
	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end
end

function AzeriteBarMixin:SetupPointsTooltip() 
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem(); 
	local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation); 
	
	self.itemDataLoadedCancelFunc = azeriteItem:ContinueWithCancelOnItemLoad(function()
		local azeriteItemName = azeriteItem:GetItemName(); 
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		GameTooltip:SetText(AZERITE_POWER_TOOLTIP_TITLE:format(self.currentLevel, self.xpToNextLevel), HIGHLIGHT_FONT_COLOR:GetRGB());
		GameTooltip:AddLine(AZERITE_POWER_TOOLTIP_BODY:format(azeriteItemName));
		GameTooltip:Show();
	end);
end

function AzeriteBarMixin:UpdatePointsTooltip()
	if ( self:IsShown() ) then
		self:SetupPointsTooltip();
	end
end
