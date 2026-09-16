--[[
	This file is for utilities / helpers that support BlizzCon2026 functionality.
]]
BlizzCon2026 = {};

function BlizzCon2026:IsActive()
	return C_BlizzCon2026.IsActive();
end

function BlizzCon2026:IsDungeonExperience()
	return self:IsActive() and C_BlizzCon2026.GetExperience() == Enum.Bc26Experience.Dungeon;
end

function BlizzCon2026:IsSkyborneExperience()
	return self:IsActive() and C_BlizzCon2026.GetExperience() == Enum.Bc26Experience.Skyborne;
end

function BlizzCon2026:IsColdSwapEnabled()
	--[[
		A reload before the session has started will break the experience. Only allow
		ColdSwap (and therefore, reloaduing the UI) to trigger if a session is in flight.
	]]
	local isSessionActive = Kiosk and Kiosk.IsSessionActive();
	return self:IsActive() and isSessionActive and C_BlizzCon2026.IsColdSwapFeatureEnabled();
end
