local GAME_MODE_XP_BAR_EVENTS = {
	"PLAYER_ENTERING_WORLD",
	"GAME_MODE_EXP_BAR_DATA_UPDATED",
	"CVAR_UPDATE",
};

local barAtlas = "UI-HUD-ExperienceBar-Fill-Talebound";
local gainFlareAtlas = "UI-HUD-ExperienceBar-Flare-XP-2x-Flipbook";
local levelUpAtlas = "UI-HUD-ExperienceBar-Fill-Experience-2x-Flipbook";

GameModeExpBarMixin = {};

function GameModeExpBarMixin:Update()
	local xp = C_GameModeExpBar.GetCurrentXP();
	local maxXP = C_GameModeExpBar.GetMaxXPForLevel();
	self.level = C_GameModeExpBar.GetCurrentLevel();
	self.xpToNextLevel = maxXP - xp;

	self:SetBarValues(xp, 0, maxXP, self.level);
	self:UpdatePointsTooltip();
end

function GameModeExpBarMixin:UpdateOverlayFrameText()
	if self.OverlayFrame.Text:IsShown() then
		local xp = C_GameModeExpBar.GetCurrentXP();
		local maxXP = C_GameModeExpBar.GetMaxXPForLevel();
		self.OverlayFrame.Text:SetText(XP_STATUS_BAR_TEXT:format(xp, maxXP));
	end
end

function GameModeExpBarMixin:AnimatedValueChangedCallback()
	self:UpdateOverlayFrameText();
	self:UpdatePointsTooltip();
end

function GameModeExpBarMixin:OnLoad()
	self.StatusBar:SetBarTexture(barAtlas);
	self.StatusBar:SetAnimationTextures(gainFlareAtlas, levelUpAtlas);
	self.StatusBar:SetOnAnimatedValueChangedCallback(function() self:AnimatedValueChangedCallback(); end);
end

function GameModeExpBarMixin:OnEvent(event, ...)
	if self:IsVisible() then
		if event == "PLAYER_ENTERING_WORLD" or event == "GAME_MODE_EXP_BAR_DATA_UPDATED" then
			self:Update();
		elseif event == "CVAR_UPDATE" then
			local name = ...;
			if name == "xpBarText" then
				self:UpdateTextVisibility();
			end
		end
	end
end

function GameModeExpBarMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, GAME_MODE_XP_BAR_EVENTS);
	self:UpdateTextVisibility();
end

function GameModeExpBarMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, GAME_MODE_XP_BAR_EVENTS);
end

function GameModeExpBarMixin:OnEnter()
	self:ShowText();
	self:UpdateOverlayFrameText();
	self:SetupPointsTooltip();
end

function GameModeExpBarMixin:OnLeave()
	self:HideText();
	GameTooltip_Hide();
end

function GameModeExpBarMixin:SetupPointsTooltip()
	local xp = C_GameModeExpBar.GetCurrentXP();
	local maxXP = C_GameModeExpBar.GetMaxXPForLevel();
	GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
	GameTooltip:AddLine(string.format(XP_STATUS_BAR_TEXT, xp, maxXP));
	GameTooltip:Show();
end

function GameModeExpBarMixin:UpdatePointsTooltip()
	if GameTooltip:IsOwned(self) then
		self:SetupPointsTooltip();
	end
end
