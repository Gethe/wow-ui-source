WarfrontEventRegisterMixin = {};

function WarfrontEventRegisterMixin:OnLoad()
	self:RegisterEvent("SCENARIO_UPDATE");
	self:RegisterEvent("SCENARIO_COMPLETED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
end

function WarfrontEventRegisterMixin:OnEvent(event)
	if ( event == "SCENARIO_UPDATE" or event == "PLAYER_ENTERING_WORLD" ) then
		-- temp
		local name = C_Scenario.GetInfo();
		self.inWarfrontScenario = (name == "The Battle for Stromgarde");
	elseif ( event == "SCENARIO_COMPLETED" and self.inWarfrontScenario ) then
		self:OnScenarioCompleted();
	end
end

function WarfrontEventRegisterMixin:OnScenarioCompleted()
	-- temp
	UIParentLoadAddOn("Blizzard_PVPUI");
	PlaySound(SOUNDKIT.PVP_THROUGH_QUEUE);
	TopBannerManager_Show(self, { name="The Battle for Stromgarde", description="Horde wins!" });
end
