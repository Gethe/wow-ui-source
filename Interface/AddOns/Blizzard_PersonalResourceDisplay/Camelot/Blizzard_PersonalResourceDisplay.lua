function PersonalResourceDisplayMixin:GetClassFrameInfo()
	if self.classID == Constants.UICharacterClasses.Rogue then
		return {
			template = "RogueComboPointBarTemplate",
			yOffset = -10,
		};
	end

	if self.classID == Constants.UICharacterClasses.Druid then
		return {
			template = "DruidComboPointBarTemplate",
			yOffset = -10,
		};
	end

	return nil;
end

-- Camelot has no specs; show the mana alt bar whenever the main bar isn't already showing mana (e.g. cat/bear form).
function DruidAlternatePowerBarMixin:AreRequirementsMet(classFileName, _specialization)
	local displayedPowerType = UnitPowerType("player");
	return classFileName == self.requiredClass and displayedPowerType ~= self.powerType;
end
