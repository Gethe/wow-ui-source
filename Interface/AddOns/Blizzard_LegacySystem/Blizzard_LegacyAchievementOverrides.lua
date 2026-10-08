-- Overrides for Blizzard_AchievementUI that need Legacy data; entry points that must work before this addon loads are in Blizzard_AchievementUI/Camelot.

function AchievementFrame_SetDateCompleted(frame, day, month, year)
	frame.DateCompleted:SetText(FormatShortDate(day, month, year));
	local padding = 5;
	frame.DateCompleted:SetWidth(frame.DateCompleted:GetStringWidth() + padding);
end

function AchievementFrame_ShowDateCompleted(parent, show)
	parent.DateCompleted:SetShown(show);
	if parent.Shield then
		if parent.Shield.CheckBackground then
			parent.Shield.CheckBackground:SetShown(show);
		end
		if parent.Shield.Check then
			parent.Shield.Check:SetShown(show);
		end
	end
end

function AchievementFrame_ShowAsComplete(completed, wasEarnedByMe)
	return completed and wasEarnedByMe;
end

function AchievementFrame_GetOverridePoints(points, achievementId)
	local legacyPoints = C_Traits.GetTraitCurrencyForAchievement(Constants.LegacyConsts.LEGACY_POINTS_TRAIT_CURRENCY_ID, achievementId);
	return legacyPoints;
end

function AchievementFrame_SelectAchievement(id, forceSelect)
	if ( (not LegacySystemFrame:IsShown() and not forceSelect) or (not C_AchievementInfo.IsValidAchievement(id)) ) then
		return;
	end

	local displayedId = AchievementFrame_FindDisplayedAchievement(id);
	LegacySystemFrame:SelectChallenge(displayedId);
end

function AchievementShield_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local parent = self:GetParent();
	local elementData = parent:GetElementData();
	if elementData then
		local rewardText = select(11, GetAchievementInfo(elementData.id));
		GameTooltip:AddLine(rewardText);
		GameTooltip:Show();
		return;
	end

	-- pass-through to the achievement button
	local func = parent:GetScript("OnEnter");
	if ( func ) then
		func(parent);
	end

	GameTooltip:Show();
end
