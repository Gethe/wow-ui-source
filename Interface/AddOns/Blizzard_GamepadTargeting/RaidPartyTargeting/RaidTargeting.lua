RaidTargetingManagerMixin = {};

function RaidTargetingManagerMixin:OnLoad()
	self.isRaidTargetingActive = false;
	self.targetUnit = nil;
end

function RaidTargetingManagerMixin:IsActive()
	return self.isRaidTargetingActive;
end

function RaidTargetingManagerMixin:SetActive(inActive)
	self.isRaidTargetingActive = inActive;
	if (not self.isRaidTargetingActive) then
		self:SetTargetUnit(nil);
	end
end

function RaidTargetingManagerMixin:GetTargetUnit()
	return self.targetUnit;
end

function RaidTargetingManagerMixin:HasTargetUnit()
	return self.targetUnit ~= nil;
end

--inUnit should be a unit string like "raid4"
function RaidTargetingManagerMixin:SetTargetUnit(inUnit)
	self.targetUnit = inUnit;
end
