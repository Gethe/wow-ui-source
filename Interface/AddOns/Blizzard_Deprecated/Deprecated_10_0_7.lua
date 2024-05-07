-- These are functions that were deprecated in 10.0.7 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	Enum.GarrisonType["Type_6_0"] = Enum.GarrisonType["Type_6_0_Garrison"];
	Enum.GarrisonType["Type_7_0"] = Enum.GarrisonType["Type_7_0_Garrison"];
	Enum.GarrisonType["Type_8_0"] = Enum.GarrisonType["Type_8_0_Garrison"];
	Enum.GarrisonType["Type_9_0"] = Enum.GarrisonType["Type_9_0_Garrison"];

	Enum.GarrisonFollowerType["FollowerType_6_0"] = Enum.GarrisonFollowerType["FollowerType_6_0_GarrisonFollower"];
	Enum.GarrisonFollowerType["FollowerType_6_2"] = Enum.GarrisonFollowerType["FollowerType_6_0_Boat"];
	Enum.GarrisonFollowerType["FollowerType_7_0"] = Enum.GarrisonFollowerType["FollowerType_7_0_GarrisonFollower"];
	Enum.GarrisonFollowerType["FollowerType_8_0"] = Enum.GarrisonFollowerType["FollowerType_8_0_GarrisonFollower"];
	Enum.GarrisonFollowerType["FollowerType_9_0"] = Enum.GarrisonFollowerType["FollowerType_9_0_GarrisonFollower"];
end