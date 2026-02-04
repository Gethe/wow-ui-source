CombatTextUtil = {};

function CombatTextUtil.StandardScroll(frame, value)
	-- Calculate x and y positions
	local xPos = value.startX+((frame.textLocations.endX - frame.textLocations.startX)*value.scrollTime/CombatTextConstants.MessageScrollSpeed);
	local yPos = value.startY+((value.endY - frame.textLocations.startY)*value.scrollTime/CombatTextConstants.MessageScrollSpeed);
	return xPos, yPos;
end

function CombatTextUtil.FountainScroll(_frame, value)
	-- Calculate x and y positions
	local radius = 150;
	local xPos = value.startX-value.xDir*(radius*(1-cos(90*value.scrollTime/CombatTextConstants.MessageScrollSpeed)));
	local yPos = value.startY+radius*sin(90*value.scrollTime/CombatTextConstants.MessageScrollSpeed);
	return xPos, yPos;
end

function CombatTextUtil.GetPowerEnumFromEnergizeString(power)
	return CombatTextPowerEnumFromEnergizeStringLookup[power] or Enum.PowerType.NumPowerTypes;
end

function CombatTextUtil.RegisterCachableCVars()
	for cvarName in pairs(CombatTextCachableCVars) do
		CVarCallbackRegistry:SetCVarCachable(cvarName);
	end
end

function CombatTextUtil.UpdateEventRegistration(frame, registerForEvents)
	local eventList = GetKeysArray(CombatTextFrameEvents);

	if registerForEvents then
		FrameUtil.RegisterFrameForEvents(frame, eventList);
	else
		FrameUtil.UnregisterFrameForEvents(frame, eventList);
	end
end

function CombatTextUtil.GetFormattedBlockMessage(_existingMessage, damageReductionAmount)
	-- BLOCK events are formatted with a damage reduction amount in Mainline.

	return COMBAT_TEXT_BLOCK_REDUCED:format(damageReductionAmount);
end

function CombatTextUtil.GetBasicPowerTypeColor(_existingColor, powerType)
	-- Basic power messages for MANA, ENERGY, etc. recovery are colored by
	-- default in Mainline.

	return GetPowerBarColor(powerType);
end

function CombatTextUtil.GetComboPointsMessageInfo(_messageType, _data, displayType)
	-- UNIT_POWER_UPDATE events generate additional messages for combo point
	-- gains in Classic, which this logic replicates.

	local comboPoints = GetComboPoints("player", "target");

	if comboPoints > 0 then
		local messageType = "COMBO_POINTS";
		local data = comboPoints;

		-- Show message as a crit if max combo points
		if comboPoints == MAX_COMBO_POINTS then
			displayType = "crit";
		end

		return messageType, data, displayType;
	end
end

function CombatTextUtil.GetRunePowerUpdateMessage(_runeIndex, _outColor)
	-- Basic rune update messages just use a static string.
	return COMBAT_TEXT_RUNE_DEATH;
end
