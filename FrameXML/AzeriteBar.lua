local AZERITE_XP_BAR_EVENTS = {
	"PLAYER_ENTERING_WORLD",
	"AZERITE_ITEM_EXPERIENCE_CHANGED", 
	"CVAR_UPDATE",
	"BAG_UPDATE",
};
AzeriteBarMixin = CreateFromMixins(StatusTrackingBarMixin);

function AzeriteBarMixin:ShouldBeVisible()
	local isMaxLevel = C_AzeriteItem.IsAzeriteItemAtMaxLevel();
	if isMaxLevel then
		return false;
	end
	local azeriteItem = C_AzeriteItem.FindActiveAzeriteItem();
	return azeriteItem and azeriteItem:IsEquipmentSlot() and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItem);
end

function AzeriteBarMixin:Update()
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem(); 
	
	if (not azeriteItemLocation) then 
		return; 
	end
	
	local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation); 
	
	if AzeriteUtil.IsAzeriteItemLocationBankBag(azeriteItemLocation) then
		self.xp, self.totalLevelXP = 0, 1;
		self.currentLevel = -1;
	else
		self.xp, self.totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation);
		self.currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation); 
	end
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
	self.priority = 0; 
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
		elseif ( event == "BAG_UPDATE" ) then
			local bagID = ...;
			if bagID > NUM_BAG_SLOTS then
				self:Update();
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
	if self.currentLevel == -1 then
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		GameTooltip:SetText(HEART_OF_AZEROTH_MISSING_ERROR, HIGHLIGHT_FONT_COLOR:GetRGB());
	else
		self:SetupPointsTooltip();
	end
end

function AzeriteBarMixin:OnLeave()
	self:HideText();
	GameTooltip_Hide();
	if self.currentLevel ~= -1 then
		self:CancelItemLoadCallback();
	end
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
	if ( GameTooltip:IsOwned(self) ) then
		self:SetupPointsTooltip();
	end
end
