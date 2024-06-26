CharSelectSearchMixin = { };

function CharSelectSearchMixin:OnLoad()
	SearchBoxTemplate_OnLoad(self);

	self.Left:Hide();
	self.Middle:Hide();
	self.Right:Hide();

	self.searchIcon:SetAtlas("glues-characterSelect-icon-search", TextureKitConstants.UseAtlasSize);
	self.searchIcon:ClearAllPoints();
	self.searchIcon:SetPoint("LEFT", 6, -1);

	self.Backdrop = self:CreateTexture(nil, "BACKGROUND");
	self.Backdrop:SetAtlas("glues-characterSelect-searchbar", TextureKitConstants.UseAtlasSize);
	self.Backdrop:SetAllPoints(self);
	self.Backdrop:SetPoint("TOPLEFT", 0, 0);

	self.Instructions:SetText(SEARCH);
	self.Instructions:ClearAllPoints();
	self.Instructions:SetPoint("TOPLEFT", self, "TOPLEFT", 24, 0);
	self.Instructions:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -22, 0);

	self:SetTextInsets(24, 24, 0, 0);
end

function CharSelectSearchMixin:OnTextChanged()
	SearchBoxTemplate_OnTextChanged(self);
	CharacterSelectCharacterFrame:UpdateCharacterSelection();

	if self:GetText() == "" then
		-- Visually refresh character rendering.
		local noCreate = true;
		CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, noCreate);

		local elementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
			local characterID = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);
			return CharacterSelectListUtil.ContainsCharacterID(characterID, elementData);
		end);

		if elementData then
			CharacterSelectListUtil.ScrollToElement(elementData, ScrollBoxConstants.AlignNearest);
		end
	end
end

local function StringMatch(baseString, word)
	if baseString and string.find(string.lower(baseString), word, 1, true) then
		return true;
	end
	return false;
end

local function MatchAnyProfession(data, word)
	local raceID = data.raceID;
	local profession0 = data.profession0;
	local profession1 = data.profession1;
	local professionName0 = profession0 ~= 0 and GetSkillLineDisplayNameForRace(profession0, raceID) or nil;
	local professionName1 = profession1 ~= 0 and GetSkillLineDisplayNameForRace(profession1, raceID) or nil;
	if StringMatch(professionName0, word) or StringMatch(professionName1, word) then
		return true;
	end
	return false;
end

local function CheckCharacterDataForMatch(data, words)
	local matched = false;

	for _, word in ipairs(words) do
		if word ~= "" then
			local number = tonumber(word);
			if number then
				if data.experienceLevel == number then
					matched = true;
					break;
				end
			else
				if StringMatch(data.name, word) then
					matched = true;
					break;
				elseif StringMatch(data.raceName, word) then
					matched = true;
					break;
				elseif StringMatch(data.className, word) then
					matched = true;
					break;
				elseif StringMatch(data.areaName, word) then
					matched = true;
					break;
				elseif data.faction ~= "Neutral" and StringMatch(data.faction, word) then
					matched = true;
					break;
				elseif MatchAnyProfession(data, word) then
					matched = true;
					break;
				end
			end
		end
	end

	return matched;
end

function CharSelectSearchMixin:GenerateFilteredCharacters(dataProvider)
	local words;
	local hasValidTerms = false;

	local text = string.lower(self:GetText());
	words = { string.split(" ", text) };

	if words then
		for _, word in ipairs(words) do
			if word ~= "" then
				hasValidTerms = true;
			end
		end
	end

	if not hasValidTerms then
		return;
	end

	local filteredDataProvider = CreateDataProvider();

	for _, elementData in dataProvider:EnumerateEntireRange() do
		if elementData.isGroup then
			for _, characterElementData in ipairs(elementData.characterData) do
				local characterGuid = GetCharacterGUID(characterElementData.characterID);
				if characterGuid then
					local data = GetBasicCharacterInfo(characterGuid);
					if CheckCharacterDataForMatch(data, words) then
						filteredDataProvider:Insert(characterElementData);
					end
				end
			end
		elseif elementData.characterID then
			local characterGuid = GetCharacterGUID(elementData.characterID);
			if characterGuid then
				local data = GetBasicCharacterInfo(characterGuid);
				if CheckCharacterDataForMatch(data, words) then
					filteredDataProvider:Insert(elementData);
				end
			end
		end
	end

	return filteredDataProvider;
end