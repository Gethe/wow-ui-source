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

function CovenantCallingMixin:GetIndex()
	return self.index;
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

function CovenantCalling_Create(bounty)
	return CreateAndInitFromMixin(CovenantCallingMixin, bounty);
end

local CallingsUpdater = CreateFrame("Frame");
CallingsUpdater:SetScript("OnEvent", function(self, event, ...)
	if event == "COVENANT_CALLINGS_UPDATED" then
		self:OnCallingsUpdated(...)
	elseif event == "QUEST_TURNED_IN" then
		local questID = ...;
		if C_QuestLog.IsQuestCalling(questID) then
			self:Request();
		end
	end
end);

CallingsUpdater:RegisterEvent("COVENANT_CALLINGS_UPDATED");
CallingsUpdater:RegisterEvent("QUEST_TURNED_IN");

function CallingsUpdater:OnCallingsUpdated(callings)
	self.completedCount = 0;
	self.availableCount = 0;
	self.callingsUnlocked = C_CovenantCallings.AreCallingsUnlocked();
	self.callings = callings;

	if self.callingsUnlocked then
		for index = 1, Constants.Callings.MaxCallings do
			local calling = callings[index];
			if calling then
				if not C_QuestLog.IsOnQuest(calling.questID) then
					self.availableCount = self.availableCount + 1;
				end
			else
				self.completedCount = self.completedCount + 1;
			end
		end
	end

	EventRegistry:TriggerEvent("CovenantCallings.CallingsUpdated", self.callings, self.completedCount, self.availableCount);
end

function CallingsUpdater:Request()
	local now = GetTime();
	if not self.lastRequestTime or now - self.lastRequestTime > 1 then
		self.lastRequestTime = now;
		C_CovenantCallings.RequestCallings();
	end
end

function CovenantCalling_CheckCallings()
	CallingsUpdater:Request();
end

function CovenantCalling_GetCompletedCount()
	return CallingsUpdater.completedCount or 0;
end

function CovenantCalling_GetAvailableCount()
	return CallingsUpdater.availableCount or 0;
end

function CovenantCalling_AreCallingsUnlocked()
	return CallingsUpdater.callingsUnlocked;
end