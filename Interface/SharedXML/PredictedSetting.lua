PredictedSettingBaseMixin = {};

-- The wrapTable here should have functions to specific keys based on which type of setting you are wrapping.
-- All tables must have a getFunction key that returns the "real" value.
-- The PredictedSetting wrapTable should have a setFunction key with a function that takes a value and sets the real value to this value.
--   This function can return a true/false value noting if the set succeeded or not.
-- The PredictedToggle wrapTable should have a toggleFunction key that is the function to call to toggle the real value.
function PredictedSettingBaseMixin:SetUp(wrapTable)
	self.wrapTable = wrapTable;
end

function PredictedSettingBaseMixin:Clear()
	self.predictedValue = nil;
end

function PredictedSettingBaseMixin:Get()
	if (self.predictedValue ~= nil) then
		return self.predictedValue;
	end
	return self.wrapTable.getFunction();
end

PredictedSettingMixin = CreateFromMixins(PredictedSettingBaseMixin);

function PredictedSettingMixin:Set(value)
	local validated = self.wrapTable.setFunction(value);
	if (validated ~= false) then
		self.predictedValue = value;
	end
end

function CreatePredictedSetting(wrapTable)
	local predictedSetting = CreateFromMixins(PredictedSettingMixin);
	predictedSetting:SetUp(wrapTable);
	return predictedSetting;
end

PredictedToggleMixin = CreateFromMixins(PredictedSettingBaseMixin)

function PredictedToggleMixin:SetUp(wrapTable)
	PredictedSettingBaseMixin.SetUp(self, wrapTable);
	self.currentValue = self.wrapTable.getFunction();
end

function PredictedToggleMixin:Toggle()
	self.predictedValue = not self.currentValue;
	self.wrapTable.toggleFunction();
end

function PredictedToggleMixin:UpdateCurrentValue()
	self.currentValue = self.wrapTable.getFunction();
end

function CreatePredictedToggle(wrapTable)
	local predictedToggle = CreateFromMixins(PredictedToggleMixin);
	predictedToggle:SetUp(wrapTable);
	return predictedToggle;
end