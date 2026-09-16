local AddonName = ...;

function GetBattlefieldMapInstanceType()
	local _, instanceType = IsInInstance();
	if instanceType == "pvp" or instanceType == "none" then
		return instanceType;
	end
	return nil;
end

function ToggleBattlefieldMap()
	BattlefieldMap_ToggleUI();
end
