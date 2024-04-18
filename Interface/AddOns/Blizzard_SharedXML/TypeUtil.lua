--These functions are terrible, but they support legacy slash commands.
function ValueToBoolean(valueToCheck, defaultValue, defaultReturn)
	if ( type(valueToCheck) == "nil" ) then
		return false;
	elseif ( type(valueToCheck) == "boolean" ) then
		return valueToCheck;
	elseif ( type(valueToCheck) == "number" ) then
		return valueToCheck ~= 0;
	elseif ( type(valueToCheck) == "string" ) then
		return StringToBoolean(valueToCheck, defaultReturn);
	else
		return defaultReturn;
	end
end

function StringToBoolean(stringToCheck, defaultReturn)
	stringToCheck = string.lower(stringToCheck);
	local firstChar = string.sub(stringToCheck, 1, 1);

	if ( firstChar == "0" or firstChar == "n" or firstChar == "f" or stringToCheck == "off" or stringToCheck == "disabled" ) then
		return false;
	elseif ( firstChar == "1" or firstChar == "2" or firstChar == "3" or firstChar == "4" or firstChar == "5" or
				firstChar == "6" or firstChar == "7" or firstChar == "8" or firstChar == "9" or firstChar == "y" or
				firstChar == "t" or stringToCheck == "on" or stringToCheck == "enabled" ) then
		return true;
	end

	return defaultReturn;
end