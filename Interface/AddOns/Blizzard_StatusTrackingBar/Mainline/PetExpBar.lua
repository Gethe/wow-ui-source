local unrestedBarAtlas = "UI-HUD-ExperienceBar-Fill-Experience";
local unrestedGainFlareAtlas = "UI-HUD-ExperienceBar-Flare-XP-2x-Flipbook";
local unrestedLevelUpAtlas = "UI-HUD-ExperienceBar-Fill-Experience-2x-Flipbook";

PetExpBarMixin = {};

function PetExpBarMixin:GetLevelData()
	-- Overriden by StableUI.lua
	local currXP, nextXP = GetPetExperience();
	local level = UnitLevel("pet");

	return currXP, nextXP, level;
end

function PetExpBarMixin:Update()
	local level;
	self.currXP, self.maxBar, level = self:GetLevelData();
	local minBar = 0;
	self:SetBarValues(self.currXP, minBar, self.maxBar, level);

	self:UpdateCurrentText();
end

function PetExpBarMixin:UpdateCurrentText()
	self:SetBarText(XP_STATUS_BAR_TEXT:format(self.currXP, self.maxBar));
end

function PetExpBarMixin:OnLoad()
	self.StatusBar:SetBarTexture(unrestedBarAtlas);
	self.StatusBar:SetAnimationTextures(unrestedGainFlareAtlas, unrestedLevelUpAtlas);

	self.StatusBar:InitializeTextStatusBar();

	self.StatusBar:SetFrameStrata("HIGH");
	self.OverlayFrame:SetFrameStrata("DIALOG");
	self.StatusBar:SetWidth(self:GetWidth());

	self:Update();

	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UNIT_PET_EXPERIENCE");
	self:RegisterEvent("CVAR_UPDATE");
end

function PetExpBarMixin:OnEvent(event, ...)
	if( event == "CVAR_UPDATE") then
		local cvar = ...;
		if( cvar == "xpBarText" ) then
			self:UpdateTextVisibility();
		end
	elseif ( event == "UNIT_PET_EXPERIENCE" or event == "PLAYER_ENTERING_WORLD" ) then
		self:Update();
	end
end

function PetExpBarMixin:OnShow()
	self:UpdateTextVisibility();
	self:Update();
end

function PetExpBarMixin:OnEnter()
	self.StatusBar:UpdateTextString();
	self:ShowText();
	self:UpdateCurrentText();
end

function PetExpBarMixin:OnLeave()
	self:HideText();
	GameTooltip:Hide();
end

function PetExpBarMixin:OnValueChanged()
	if ( not self:IsShown() ) then
		return;
	end
	self:Update();
end
