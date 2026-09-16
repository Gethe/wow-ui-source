local HouseFavorBarEvents = {
	"PLAYER_ENTERING_WORLD",
	"HOUSE_LEVEL_FAVOR_UPDATED", 
	"CVAR_UPDATE",
};

local barAtlas = "UI-HUD-ExperienceBar-Fill-ArtifactPower";
local gainFlareAtlas = "UI-HUD-ExperienceBar-Flare-ArtifactPower-2x-Flipbook";
local levelUpAtlas = "UI-HUD-ExperienceBar-Fill-ArtifactPower-2x-Flipbook";

HouseFavorBarMixin = {};

function HouseFavorBarMixin:Update()
	local current, minBar, maxBar, level = 0, 0, 1, 1;
	if self.houseLevelFavor then
		current = self.houseLevelFavor.houseFavor;
		level = self.houseLevelFavor.houseLevel;
		minBar = C_Housing.GetHouseLevelFavorForLevel(level);
		maxBar = C_Housing.GetHouseLevelFavorForLevel(level + 1);
	end
	if maxBar ~= 0 then
		self:SetBarValues(current, minBar, maxBar, level);
	end
end

function HouseFavorBarMixin:UpdateOverlayFrameText()
	if self.OverlayFrame.Text:IsShown() then
		local xp = self.StatusBar:GetAnimatedValue();
		local _, totalLevelXP = self.StatusBar:GetMinMaxValues();
		self.OverlayFrame.Text:SetFormattedText(HOUSING_DASHBOARD_NEIGHBORHOOD_FAVOR, xp, totalLevelXP);
	end
end

function HouseFavorBarMixin:AnimatedValueChangedCallback()
	self:UpdateOverlayFrameText();
end

function HouseFavorBarMixin:OnLoad()
	self.StatusBar:SetBarTexture(barAtlas);
	self.StatusBar:SetAnimationTextures(gainFlareAtlas, levelUpAtlas);
	self.StatusBar:SetOnAnimatedValueChangedCallback(function() self:AnimatedValueChangedCallback(); end)
	self.StatusBar:SetIsMaxLevelFunctionOverride(function()
		if self.houseLevelFavor then
			return self.houseLevelFavor.houseLevel >= C_Housing.GetMaxHouseLevel();
		end

		return false;
	end);
end

function HouseFavorBarMixin:OnEvent(event, ...)
	if event == "HOUSE_LEVEL_FAVOR_UPDATED" then
		local houseLevelFavor = ...;
		if houseLevelFavor.houseGUID == C_Housing.GetTrackedHouseGuid() then
			self.houseLevelFavor = houseLevelFavor;
			self:Update();
		end
	elseif event == "CVAR_UPDATE" then
		local name, value = ...;
		if name == "xpBarText" then
			self:UpdateTextVisibility();
		elseif name == "trackedHouseFavor" then
			self.trackedHouseGUID = value;
		end
	end
end

function HouseFavorBarMixin:OnShow() 
	FrameUtil.RegisterFrameForEvents(self, HouseFavorBarEvents);
	self:UpdateTextVisibility();
	C_Housing.GetCurrentHouseLevelFavor(C_Housing.GetTrackedHouseGuid());
end

function HouseFavorBarMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, HouseFavorBarEvents);
end

function HouseFavorBarMixin:OnEnter()
	self:ShowText();
	self:UpdateOverlayFrameText();
end

function HouseFavorBarMixin:OnLeave()
	self:HideText();
end

