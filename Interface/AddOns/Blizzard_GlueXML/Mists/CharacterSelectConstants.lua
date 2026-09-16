
CHARACTER_SELECT_HEIGHT = 710;
CHARACTER_SELECT_MAX_CHARACTERS = 11;

function CharacterSelect_UseSpecialCreateButtons()
	return GetNumCharacters() >= CHARACTER_SELECT_MAX_CHARACTERS;
end