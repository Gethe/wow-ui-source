
EnumUtil = {};

function EnumUtil.MakeEnum(...)
	return tInvert({...});
end

function EnumUtil.IsValid(enumClass, enumValue)
	return tContains(enumClass, enumValue);
end

function EnumUtil.GenerateNameTranslation(enum)
	local keysByValue = tInvert(enum);
	return function (enumValue)
		local key = keysByValue[enumValue];
		return key or UNKNOWN..enumValue;
	end
end
