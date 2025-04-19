local AZERITE_XP_BAR_EVENTS = {
	"PLAYER_ENTERING_WORLD",
	"AZERITE_ITEM_EXPERIENCE_CHANGED", 
	"CVAR_UPDATE",
	"BAG_UPDATE",
};

local barAtlas = "UI-HUD-ExperienceBar-Fill-ArtifactPower";
local gainFlareAtlas = "UI-HUD-ExperienceBar-Flare-ArtifactPower-2x-Flipbook";
local levelUpAtlas = "UI-HUD-ExperienceBar-Fill-ArtifactPower-2x-Flipbook";

AzeriteBarMixin = {};

function AzeriteBarMixin:GetLevel()
	local azeriteItem = C_AzeriteItem.FindActiveAzeriteItem();
	if not azeriteItem then
		return nil;
	end

	if C_AzeriteItem.IsUnlimitedLevelingUnlocked() then
		return C_AzeriteItem.GetUnlimitedPowerLevel(azeriteItem);
	end

	return C_AzeriteItem.GetPowerLevel(azeriteItem);
end

function AzeriteBarMixin:Update()
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	local xp, totalLevelXp;
	if not azeriteItemLocation or AzeriteUtil.IsAzeriteItemLocationBankBag(azeriteItemLocation) then
		xp, totalLevelXp = 0, 1;
		self.level = -1;
	else
		xp, totalLevelXp = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation);
		self.level = self:GetLevel();
	end
	self.xpToNextLevel = totalLevelXp - xp;

	self:SetBarValues(xp, 0, totalLevelXp, self.level);
	self:UpdatePointsTooltip();
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
	self.StatusBar:SetBarTexture(barAtlas);
	self.StatusBar:SetAnimationTextures(gainFlareAtlas, levelUpAtlas);
	self.StatusBar:SetOnAnimatedValueChangedCallback(function() self:AnimatedValueChangedCallback(); end)
	self.StatusBar:SetIsMaxLevelFunctionOverride(function() return C_AzeriteItem.IsAzeriteItemAtMaxLevel(); end);
end

function AzeriteBarMixin:OnEvent(event, ...)
	if ( self:IsVisible() ) then 
		if ( event == "PLAYER_ENTERING_WORLD" or event == "AZERITE_ITEM_EXPERIENCE_CHANGED") then
			self:Update();
		elseif ( event == "CVAR_UPDATE" ) then
			local name, value = ...;
			if ( name == "xpBarText" ) then
				self:UpdateTextVisibility();
			end
		elseif ( event == "BAG_UPDATE" ) then
			local bagID = ...;
			if bagID > NUM_TOTAL_EQUIPPED_BAG_SLOTS then
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

	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	if AzeriteUtil.IsAzeriteItemLocationBankBag(azeriteItemLocation) then
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		GameTooltip:SetText(HEART_OF_AZEROTH_MISSING_ERROR, HIGHLIGHT_FONT_COLOR:GetRGB());
	else
		self:SetupPointsTooltip();
	end
end

function AzeriteBarMixin:OnLeave()
	self:HideText();
	GameTooltip_Hide();

	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	if AzeriteUtil.IsAzeriteItemLocationBankBag(azeriteItemLocation) then
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
		GameTooltip:SetText(AZERITE_POWER_TOOLTIP_TITLE:format(self.level, self.xpToNextLevel), HIGHLIGHT_FONT_COLOR:GetRGB());
		GameTooltip:AddLine(AZERITE_POWER_TOOLTIP_BODY:format(azeriteItemName));
		GameTooltip:Show();
	end);
end

function AzeriteBarMixin:UpdatePointsTooltip()
	if ( GameTooltip:IsOwned(self) ) then
		self:SetupPointsTooltip();
	end
end
