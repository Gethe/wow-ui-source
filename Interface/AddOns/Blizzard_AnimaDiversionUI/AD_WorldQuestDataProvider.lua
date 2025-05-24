AnimaDiversion_WorldQuestDataProviderMixin = CreateFromMixins(WorldQuestDataProviderMixin);

function AnimaDiversion_WorldQuestDataProviderMixin:GetPinTemplate()
	return "AnimaDiversion_WorldQuestPinTemplate";
end

AnimaDiversion_WorldQuestPinMixin = CreateFromMixins(WorldQuestPinMixin);

function AnimaDiversion_WorldQuestPinMixin:OnLoad()
	WorldQuestPinMixin.OnLoad(self);

	self:SetAlphaLimits(2.0, 0.6, 0.6);
	self:SetScalingLimits(1, 0.4125, 0.425);

	self:SetNudgeTargetFactor(0.015);
	self:SetNudgeZoomedOutFactor(1.0);
	self:SetNudgeZoomedInFactor(0.25);
end