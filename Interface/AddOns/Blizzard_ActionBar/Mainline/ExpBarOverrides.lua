
local unrestedBarAtlas = "UI-HUD-ExperienceBar-Fill-Experience";
local unrestedGainFlareAtlas = "UI-HUD-ExperienceBar-Flare-XP-2x-Flipbook";
local unrestedLevelUpAtlas = "UI-HUD-ExperienceBar-Fill-Experience-2x-Flipbook";

local restedBarAtlas = "UI-HUD-ExperienceBar-Fill-Rested";
local restedGainFlareAtlas = "UI-HUD-ExperienceBar-Flare-Rested-2x-Flipbook";
local restedLevelUpAtlas = "UI-HUD-ExperienceBar-Fill-Rested-2x-Flipbook";

function ExpBarMixin:UpdateCurrentText()
	self:SetBarText(XP_STATUS_BAR_TEXT:format(self.currXP, self.maxBar));
end

function ExpBarMixin:UpdateStatusBarTextures(isRested)
	self.StatusBar:SetBarTexture(isRested and restedBarAtlas or unrestedBarAtlas);
	self.StatusBar:SetAnimationTextures(isRested and restedGainFlareAtlas or unrestedGainFlareAtlas,
		isRested and restedLevelUpAtlas or unrestedLevelUpAtlas);
end

function ExhaustionTickMixin:ExhaustionToolTipText()
	local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState();
	if(not exhaustionStateID) then
		return;
	end

	local currXP, nextXP = self:GetParent():GetLevelData();
	local percentXP = math.ceil(currXP/nextXP*100);

	local tooltip = GetAppropriateTooltip();
	GameTooltip_SetDefaultAnchor(tooltip, UIParent);
	GameTooltip_SetTitle(tooltip, XP_TEXT:format(BreakUpLargeNumbers(currXP), BreakUpLargeNumbers(nextXP), percentXP));
	GameTooltip_AddHighlightLine(tooltip, EXHAUST_TOOLTIP1:format(exhaustionStateName, exhaustionStateMultiplier * 100));

	if not IsResting() and (exhaustionStateID == 4 or exhaustionStateID == 5) then
		GameTooltip_AddHighlightLine(tooltip, EXHAUST_TOOLTIP2);
	end

	if GameLimitedMode_IsBankedXPActive() then
		local bankedLevels = UnitTrialBankedLevels("player");
		local bankedXP = UnitTrialXP("player");

		if bankedLevels > 0 or bankedXP > 0 then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddNormalLine(tooltip, XP_TEXT_BANKED_XP_HEADER);
		end

		if bankedLevels > 0 then
			GameTooltip_AddHighlightLine(tooltip, TRIAL_CAP_BANKED_LEVELS_TOOLTIP:format(bankedLevels));
		elseif bankedXP > 0 then
			GameTooltip_AddHighlightLine(tooltip, TRIAL_CAP_BANKED_XP_TOOLTIP);
		end
	end

	GameTooltip:Show();
end
