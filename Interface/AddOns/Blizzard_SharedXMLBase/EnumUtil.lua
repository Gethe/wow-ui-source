---------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
local _, tbl = ...;

if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	end

	setfenv(1, tbl);

	Import("tInvert");
	Import("tContains");
	Import("pairs");
	Import("UNKNOWN");
end
----------------

EnumUtil = {};

function EnumUtil.MakeEnum(...)
	return tInvert({...});
end

function EnumUtil.IsValid(enumClass, enumValue)
	return tContains(enumClass, enumValue);
end

function EnumUtil.GenerateNameTranslation(enum)
	return function (enumValue)
		for key, value in pairs(enum) do
			if value == enumValue then
				return key;
			end
		end

		return UNKNOWN..enumValue;
	end
end
