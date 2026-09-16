NameUtil = {}

-- Take a unit name (may not be a player) and return a displayable name. Includes option to hide surname, and show realm relation.
function NameUtil.FormatUnitNameForDisplay(unit, showSurname)
	local name, surname = UnitName(unit);
	local relationship = UnitRealmRelationship(unit);

	if ( surname and surname ~= "" ) then
		if ( showSurname ) then
			return name..Constants.CharacterNameSeparatorConsts.CHARACTERNAME_REALMNAME_SEPARATOR..surname;
		else
			-- Server names are shown, do we need to show the foreign server label
			if (relationship == LE_REALM_RELATION_VIRTUAL) then
				return name;
			else
				return name..FOREIGN_SERVER_LABEL;
			end
		end
	else
		return name;
	end
end

function NameUtil.GetFullNameWithoutRealm(firstName, surname)
	return firstName;
end

-- Accepts John-Smith and returns two strings ("John", "Smith").
function NameUtil.SplitPlayerNameIntoParts(playerFullName)
	return strmatch(playerFullName, "^([^-]+)"..Constants.CharacterNameSeparatorConsts.CHARACTERNAME_REALMNAME_SEPARATOR.."(.*)")
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

function NameUtil.IsPlayerMe(playerName, serverName)
	local myName, myServerName= UnitNameUnmodified("player");
	return (playerName == myName) and (serverName == myServerName);
end
