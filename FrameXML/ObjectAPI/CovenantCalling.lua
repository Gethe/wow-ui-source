CovenantCallingMixin = {};

function CovenantCallingMixin:Init(bounty)
	if bounty then
		Mixin(self, bounty);
		self.quest = QuestCache:Get(self.questID);
		self.isOnQuest = C_QuestLog.IsOnQuest(self.questID); -- The only reason it's safe to cache this is that when quests are updated, we rebuild everything.
	end

	self.isLockedToday = bounty == nil;
end

function CovenantCallingMixin:SetIndex(index)
	self.index = index;
end

function CovenantCallingMixin:IsLocked()
	return self.isLockedToday;
end

function CovenantCallingMixin:IsActive()
	return self.isOnQuest;
end

function CovenantCallingMixin:GetState()
	if self:IsLocked() then
		return Enum.CallingStates.QuestCompleted;
	elseif self:IsActive() then
		return Enum.CallingStates.QuestActive;
	else
		return Enum.CallingStates.QuestOffer;
	end
end

function CovenantCallingMixin:GetIcon(covenantData)
	if self:IsLocked() or self.icon == 0 then
		return ("Interface/Pictures/Callings-%s-Head-Disable"):format(covenantData.textureKit);
	end

	return self.icon;
end

function CovenantCallingMixin:GetBang()
	local state = self:GetState();
	if state == Enum.CallingStates.QuestActive and self.quest:IsComplete() then
		return "Callings-Turnin";
	elseif state == Enum.CallingStates.QuestOffer then
		return "Callings-Available";
	end

	return nil;
end

function CovenantCallingMixin:GetDaysUntilNext()
	if self:IsLocked() and self.index then
		return Constants.Callings.MaxCallings - self.index + 1;
	end

	return 0;
end

function CovenantCallingMixin:GetDaysUntilNextString()
	return _G["BOUNTY_BOARD_NO_CALLINGS_DAYS_" .. self:GetDaysUntilNext()] or BOUNTY_BOARD_NO_CALLINGS_DAYS_1;
end

function CovenantCalling_Create(bounty)
	return CreateAndInitFromMixin(CovenantCallingMixin, bounty);
end