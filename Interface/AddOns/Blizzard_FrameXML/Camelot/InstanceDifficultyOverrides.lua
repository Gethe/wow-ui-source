local DifficultyTooltips = {
	[5] = DUNGEON_DIFFICULTY_5PLAYER,
	[10] = RAID_DIFFICULTY_10PLAYER,
	[20] = RAID_DIFFICULTY_20PLAYER,
	[40] = RAID_DIFFICULTY_40PLAYER,
}

function InstanceDifficultyMixin:GetDifficultyTooltip(maxPlayers, instanceGroupSize, difficultyName, isLFR, lfgID, difficulty)
	if maxPlayers == 5 then
		GameTooltip_SetTitle(GameTooltip, LFG_TYPE_DUNGEON);
		GameTooltip_AddNormalLine(GameTooltip, DUNGEON_DIFFICULTY_5PLAYER);
	else
		local tooltipText = DifficultyTooltips[maxPlayers];
		if tooltipText then
			if difficulty == DifficultyUtil.ID.DungeonNormal then
				GameTooltip_SetTitle(GameTooltip, LFG_TYPE_DUNGEON);
			else
				GameTooltip_SetTitle(GameTooltip, LFG_TYPE_RAID);
			end
			GameTooltip_AddNormalLine(GameTooltip, tooltipText);
		end
	end
end

function InstanceDifficultyMixin:SetInstanceFrameText(instanceFrame, instanceGroupSize, maxPlayers)
	if ( maxPlayers == 0 or self:IsInDelve() ) then
		instanceFrame.Text:SetText("");
	else
		instanceFrame.Text:SetText(maxPlayers);
	end
end
