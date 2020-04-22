---------------------------------------------------------------------------------
--- Combat Log Helpers						                                  ---
---------------------------------------------------------------------------------

local function IsAllyBoardIndex(boardIndex) 
	return	boardIndex == Enum.GarrAutoBoardIndex.AllyLeftBack or
			boardIndex == Enum.GarrAutoBoardIndex.AllyRightBack or
			boardIndex == Enum.GarrAutoBoardIndex.AllyLeftFront or
			boardIndex == Enum.GarrAutoBoardIndex.AllyCenterFront or
			boardIndex == Enum.GarrAutoBoardIndex.AllyRightFront;
end

local function IsEventOffensive(eventType) 
	return	eventType == Enum.GarrAutoMissionEventType.MeleeDamage or
			eventType == Enum.GarrAutoMissionEventType.RangeDamage or
			eventType == Enum.GarrAutoMissionEventType.SpellMeleeDamage or 
			eventType == Enum.GarrAutoMissionEventType.SpellRangeDamage or 
			eventType == Enum.GarrAutoMissionEventType.PeriodicDamage or
			eventType == Enum.GarrAutoMissionEventType.Died;
end

local function EventHasPoints(eventType) 
	return	eventType == Enum.GarrAutoMissionEventType.MeleeDamage or
			eventType == Enum.GarrAutoMissionEventType.RangeDamage or
			eventType == Enum.GarrAutoMissionEventType.SpellMeleeDamage or 
			eventType == Enum.GarrAutoMissionEventType.SpellRangeDamage or 
			eventType == Enum.GarrAutoMissionEventType.PeriodicDamage or
			eventType == Enum.GarrAutoMissionEventType.Heal or
			eventType == Enum.GarrAutoMissionEventType.PeriodicHeal;
end

local function EventIsFollowedBySpell(eventType) 
	return	eventType == Enum.GarrAutoMissionEventType.PeriodicDamage or
			eventType == Enum.GarrAutoMissionEventType.PeriodicHeal;
end

local function GetActionForEvent(spellName, eventType) 
--TODO: Finalize design of combat log to stop using nonlocalized string
	if eventType == Enum.GarrAutoMissionEventType.MeleeDamage then
		return "meleed ";
	elseif  eventType == Enum.GarrAutoMissionEventType.RangeDamage then
		return "shot ";
	elseif  eventType == Enum.GarrAutoMissionEventType.SpellMeleeDamage then
		return "cast " .. spellName .. " at ";
	elseif  eventType == Enum.GarrAutoMissionEventType.SpellRangeDamage then
		return "cast " .. spellName .. " at ";
	elseif  eventType == Enum.GarrAutoMissionEventType.PeriodicDamage then
		return spellName .. " damage ticked "
	elseif  eventType == Enum.GarrAutoMissionEventType.ApplyAura then
		return "applied " .. spellName .. " to ";
	elseif  eventType == Enum.GarrAutoMissionEventType.Heal then
		return "cast " .. spellName .. " on ";
	elseif  eventType == Enum.GarrAutoMissionEventType.PeriodicHeal then
		return spellName .. " heal ticked ";
	elseif  eventType == Enum.GarrAutoMissionEventType.Died then
		return "killed ";
	elseif  eventType == Enum.GarrAutoMissionEventType.RemoveAura then
		return "removed the " .. spellName .. " aura ";
	else
		return "defaulted ";
	end
end

local function GetCombatLogTextColor(combatLogEvent)
	if IsAllyBoardIndex(combatLogEvent.casterBoardIndex) then
		if IsEventOffensive(combatLogEvent.type) then 
			return WHITE_FONT_COLOR;
		else
			return GREEN_FONT_COLOR;
		end
	else
		return RED_FONT_COLOR;
	end
end

---------------------------------------------------------------------------------
--- Adventures Combat Log Mixin				                                  ---
---------------------------------------------------------------------------------

AdventuresCombatLogMixin = { }

function AdventuresCombatLogMixin:OnLoad()
	self.CombatLogMessageFrame:SetMaxLines(5000);
	self.CombatLogMessageFrame:SetFading(false);
	self.CombatLogMessageFrame:SetFontObject(ChatFontNormal);
	self.CombatLogMessageFrame:SetIndentedWordWrap(true);
	self.CombatLogMessageFrame:SetJustifyH("LEFT");
	self.CombatLogMessageFrame:SetOnScrollChangedCallback(function(messageFrame, offset)
		messageFrame.ScrollBar:SetValue(messageFrame:GetNumMessages() - offset);
	end);
end

function AdventuresCombatLogMixin:Clear()
	self.CombatLogMessageFrame:Clear();
end

function AdventuresCombatLogMixin:AddCombatRound(roundIndex, currentRound) 
	self:AddCombatRoundHeader(roundIndex);
	for eventIndex = 1, #currentRound.events do 
		self:AddCombatEvent(currentRound.events[eventIndex]);
	end
end

function AdventuresCombatLogMixin:AddCombatRoundHeader(roundIndex) 
--TODO: Finalize design of combat log to stop using nonlocalized string
	self.CombatLogMessageFrame:AddMessage(" ");
	self.CombatLogMessageFrame:AddMessage("Round " .. roundIndex .. ":", YELLOW_FONT_COLOR:GetRGB());
	self.CombatLogMessageFrame:AddMessage(" ");
end

function AdventuresCombatLogMixin:AddCombatEvent(combatLogEvent)
--TODO: Finalize design of combat log to stop using nonlocalized string
	local autoCombatSpellRec = C_Garrison.GetAutoCombatSpellInfo(combatLogEvent.spellID);
	local spellName = autoCombatSpellRec and autoCombatSpellRec.name or "<Failed to find Rec>";

	local caster = self:GetNameAtBoardIndex(combatLogEvent.casterBoardIndex);
	local possessive = EventIsFollowedBySpell(combatLogEvent.type) and "'s " or " ";
	local action = GetActionForEvent(spellName, combatLogEvent.type);
	local target = self:GetTargetName(combatLogEvent.targetInfo);
	local eventHasPoints = EventHasPoints(combatLogEvent.type);
	local preposition =  eventHasPoints and " for " or "";
	local amount = eventHasPoints and #combatLogEvent.targetInfo > 0 and combatLogEvent.targetInfo[1].points or "";
	local textColor = GetCombatLogTextColor(combatLogEvent);

	self.CombatLogMessageFrame:AddMessage(caster .. possessive .. action .. target .. preposition .. amount, textColor:GetRGB());
end

function AdventuresCombatLogMixin:AddVictoryState(winState)
--TODO: Finalize design of combat log to stop using nonlocalized string
	local winStateText = winState and "won!" or "lost.";
	self.CombatLogMessageFrame:AddMessage("You " .. winStateText, YELLOW_FONT_COLOR:GetRGB());
end

function AdventuresCombatLogMixin:GetCompleteScreen()
	return self:GetParent();
end

function AdventuresCombatLogMixin:GetNameAtBoardIndex(boardIndex)
	local frame = self:GetCompleteScreen():GetFrameFromBoardIndex(boardIndex);
	return frame:GetName() or "";
end

function AdventuresCombatLogMixin:GetTargetName(targetInfo)
--TODO: Finalize design of combat log to stop using nonlocalized string
	if #targetInfo == 1 then 
		return self:GetNameAtBoardIndex(targetInfo[1].boardIndex);
	elseif #targetInfo > 1 then
		return "multiple targets";
	else 
		return "";
	end
end