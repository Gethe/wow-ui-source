
-- This function takes a token, gender, and/or ordinality and looks up the correct string token
-- The gender is a number with the following values:
-- nil - GENDER_NOT_APPLICABLE
-- 1 - GENDER_NONE
-- 2 - GENDER_MALE
-- 3 - GENDER_FEMALE
-- 4 - GENDER_MALE_PLURAL
-- 5 - GENDER_FEMALE_PLURAL
-- 6 - GENDER_MIXED_PLURAL

-- Tags applied to variable names are:
-- 1 - "_NONE"
-- 2 - ""	*Male is default!*
-- 3 - "_FEMALE"
-- 4 - "_MPLURAL"
-- 5 - "_FPLURAL"
-- 6 - "_MIXED"

-- MALE is default
GenderTagInfo = { "_NONE", nil, "_FEMALE", "_MPLURAL", "_FPLURAL", "_MIXED" };

MAX_GENDER_INDICES = 6;
MAX_PLURAL_INDICES = 4;

function GetText(token, gender, ordinal)
	local variable = token;
	local genderTag = GetGenderTag(gender);
	local pluralTag = GetPluralTag(ordinal);

	if ( pluralTag ) then
		variable = variable..pluralTag;
	end
	if ( genderTag ) then
		variable = variable..genderTag;
	end

	local string = getglobal(variable);
	if ( not string ) then
		if ( pluralTag and genderTag ) then
			string = getglobal(token..pluralTag);
			if ( not string ) then
				string = getglobal(token..genderTag);	
				if ( not string ) then
					string = getglobal(token);
				end
			end
		else
			string = getglobal(token);
		end
	end

	return string;
end

function GetPluralIndex(ordinal)
	if ( not ordinal or (ordinal == 1) ) then
		return 1;
	else
		return 2;
	end
end

function GetPluralTag(ordinal)
	local index = GetPluralIndex(ordinal);
	if ( (index <= 1) or (index > MAX_PLURAL_INDICES) ) then
		return nil;
	end
	return "_P"..(index - 1);
end

function GetGenderTag(gender)
	if ( not gender or (gender < 1) or (gender > MAX_GENDER_INDICES) ) then
		return nil;
	end
	return GenderTagInfo[gender];
end
