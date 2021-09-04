FlightMap_WorldQuestDataProviderMixin = CreateFromMixins(WorldQuestDataProviderMixin);

function FlightMap_WorldQuestDataProviderMixin:GetPinTemplate()
	return "FlightMap_WorldQuestPinTemplate";
end

FlightMap_WorldQuestPinMixin = CreateFromMixins(WorldQuestPinMixin);

function FlightMap_WorldQuestPinMixin:OnLoad()
	WorldQuestPinMixin.OnLoad(self);

	self:SetAlphaLimits(2.0, 0.0, 1.0);
	self:SetScalingLimits(1, 0.4125, 0.425);

	self:SetNudgeTargetFactor(0.015);
	self:SetNudgeZoomedOutFactor(1.0);
	self:SetNudgeZoomedInFactor(0.25);
end

function FlightMap_WorldQuestPinMixin:RefreshVisuals()
	WorldQuestPinMixin.RefreshVisuals(self);

	if QuestUtils_IsQuestWatched(self.questID) then
		self:SetAlphaLimits(1.0, 1.0, 1.0);
	else
		self:SetAlphaLimits(2.0, 0.0, 1.0);
	end
end
