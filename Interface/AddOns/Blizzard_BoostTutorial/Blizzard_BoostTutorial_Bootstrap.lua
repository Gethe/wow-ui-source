local AddonName = ...;

function GetCurrentScenarioType()
	local scenarioType = select(10, C_Scenario.GetInfo());
	return scenarioType;
end

function IsBoostTutorialScenario()
	return GetCurrentScenarioType() == LE_SCENARIO_TYPE_BOOST_TUTORIAL;
end

function BoostTutorial_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end
