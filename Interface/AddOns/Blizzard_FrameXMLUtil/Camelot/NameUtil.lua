NameUtil = {}

-- Take any unit name (may not be a player) and return a suitable display name.
function NameUtil.FormatUnitNameForDisplay(unit)
	local name, surname = UnitName(unit);

	if (surname) then
		return name..Constants.CharacterNameSeparatorConsts.CHARACTERNAME_SURNAME_SEPARATOR..surname;
	end

	return name;
end

function NameUtil.GetFullNameWithoutRealm(firstName, surname)
	if (firstName and firstName ~= "") and (surname and surname ~= "") then
		return firstName..Constants.CharacterNameSeparatorConsts.CHARACTERNAME_SURNAME_SEPARATOR..surname;
	else
		return firstName;
	end
end

function NameUtil.SplitPlayerNameIntoParts(playerFullName)
	return strmatch(playerFullName, "^([^-]+)"..Constants.CharacterNameSeparatorConsts.CHARACTERNAME_SURNAME_SEPARATOR.."(.*)")
end

function NameUtil.GetUnitFirstName(unit)
	-- name can be both name + surname, so we split it and return first name only
	local name, surname = UnitName(unit);
	if name and  RegionalUniqueNamesEnabled() then
		local name2, surname2 = strmatch(name, "^([^-]+)"..Constants.CharacterNameSeparatorConsts.CHARACTERNAME_SURNAME_SEPARATOR.."(.*)");
		return name2;
	end

	return name;
end

function NameUtil.IsPlayerMe(playerName, playerSurname)
	local myName, mySurname = UnitNameUnmodified("player");
	return (playerName == myName) and (playerSurname == mySurname);
end
