
CharacterSelectListUtil = {
	GroupHeightExpanded = 454,
	GroupHeightCollapsed = 34,
	DividerHeight = 54,
	CharacterHeight = 95,
	CharacterGroupSlotCount = 4
};

-- for character reordering: key = button index, value = character ID
local s_characterReorderTranslation = {};

function CharacterSelectListUtil.CanReorder()
	return (CharacterSelectCharacterFrame.SearchBox:IsShown() and CharacterSelectCharacterFrame.SearchBox:GetText() == "") and
	not CharacterSelectUtil.IsUndeleting() and CharacterServicesMaster_AllowCharacterReordering(CharacterServicesMaster);
end

function CharacterSelectListUtil.CreateCompleteDataProvider()
	local dataProvider = CreateDataProvider();

	-- The starting index for ungrouped characters.
	local ungroupedCharacterIndex = 1;

	if not CharacterSelect.undeleting then
		local groupID = 1;
		local collapsedState = GetWarbandGroupCollapsedState(groupID);

		-- Group info
		local groupData = {
			isGroup = true,
			name = CHARACTER_SELECT_LIST_GROUP_HEADER,
			groupID = groupID,
			collapsed = collapsedState,
			heightExpanded = CharacterSelectListUtil.GroupHeightExpanded,
			heightCollapsed = CharacterSelectListUtil.GroupHeightCollapsed,
			characterSlots = CharacterSelectListUtil.CharacterGroupSlotCount,
			characterData = {}
		};

		for index = 1, groupData.characterSlots do
			local characterID = CharacterSelectListUtil.GetCharIDFromIndex(index);
			local isEmpty = characterID == 0;

			local characterData = {
				characterID = characterID,
				isEmpty = isEmpty,
				height = CharacterSelectListUtil.CharacterHeight
			}

			table.insert(groupData.characterData, characterData);
		end
		ungroupedCharacterIndex = ungroupedCharacterIndex + groupData.characterSlots;

		dataProvider:Insert(groupData);

		-- Divider info
		local dividerData = {
			isDivider = true,
			height = CharacterSelectListUtil.DividerHeight
		};
		dataProvider:Insert(dividerData);
	end

	-- Non-group character info
	-- Reference the translation table instead of GetNumCharacters, as this ensures any newly
	-- added empty card slots are caught in the count, and we don't drop the end characters.
	for index = ungroupedCharacterIndex, #s_characterReorderTranslation do
		local characterID = CharacterSelectListUtil.GetCharIDFromIndex(index);
		local characterData = {
			characterID = characterID,
			isEmpty = false,
			height = CharacterSelectListUtil.CharacterHeight
		}
		dataProvider:Insert(characterData);
	end

	return dataProvider;
end

function CharacterSelectListUtil.GenerateCharactersDataProvider()
	local completeDataProvider = CharacterSelectListUtil.CreateCompleteDataProvider();

	-- If we are searching, that takes priority over all other setups.
	if CharacterSelectCharacterFrame.SearchBox:IsShown() and CharacterSelectCharacterFrame.SearchBox:GetText() ~= "" then
		return CharacterSelectCharacterFrame.SearchBox:GenerateFilteredCharacters(completeDataProvider);
	end

	return completeDataProvider;
end

function CharacterSelectListUtil.GetCharIDFromIndex(index)
	return s_characterReorderTranslation[index] or 0;
end

function CharacterSelectListUtil.GetIndexFromCharID(charID)
	for index = 1, #s_characterReorderTranslation do
		if s_characterReorderTranslation[index] == charID then
			return index;
		end
	end
	return charID;
end

function CharacterSelectListUtil.BuildCharIndexToIDMapping(listSize)
	local includeEmptySlots = true;
	listSize = listSize or GetNumCharacters(includeEmptySlots);
	s_characterReorderTranslation = {};

	if listSize > 0 then
		for i = 1, listSize do
			local characterGuid = GetCharacterGUID(i);

			-- Check each entry if it's an empty character.
			if characterGuid == nil then
				tinsert(s_characterReorderTranslation, 0);
			else
				tinsert(s_characterReorderTranslation, i);
			end
		end
	end
end

function CharacterSelectListUtil.CheckBuildCharIndexToIDMapping()
	if CharacterSelect.undeleteChanged or not s_characterReorderTranslation or #s_characterReorderTranslation == 0 then
		CharacterSelectListUtil.BuildCharIndexToIDMapping();
	end
end

function CharacterSelectListUtil.SaveCharacterOrder()
	SaveCharacterOrder(s_characterReorderTranslation);
end

function CharacterSelectListUtil.UpdateCharacterOrderFromDataProvider(dataProvider)
	s_characterReorderTranslation = {};
	for _, elementData in dataProvider:EnumerateEntireRange() do
		if elementData.isGroup then
			for _, childElementData in ipairs(elementData.characterData) do
				tinsert(s_characterReorderTranslation, childElementData.characterID);
			end
		elseif not elementData.isDivider then
			tinsert(s_characterReorderTranslation, elementData.characterID);
		end
	end

	CharacterSelect.createIndex = #s_characterReorderTranslation + 1;
end

function CharacterSelectListUtil.ChangeCharacterOrder(originIndex, targetIndex)
	-- TODO:: Fix up CharacterSelect.selectedIndex. For now, we're forced to use the existing global state.
	local selectedCharacterID = s_characterReorderTranslation[CharacterSelect.selectedIndex];

	-- If the target character is currently an empty slot, and the origin character is not in a group,
	-- remove the target character, as empty slots cannot be outside of a group.
	local removeTargetCharacter = false;

	-- If the origin character is in a group, and the target character is not,
	-- instead of swapping them, add an empty slot.
	local insertEmptyCharacter = false;

	-- If we are swapping a grouped character with an empty slot within the same group,
	-- we treat that differently for animations from a normal swap.
	local sameGroupEmptyCharacterSwap = false;

	local originCharacterID = CharacterSelectListUtil.GetCharIDFromIndex(originIndex);
	local originElementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
		return CharacterSelectListUtil.ContainsCharacterID(originCharacterID, elementData);
	end);

	local targetCharacterID = CharacterSelectListUtil.GetCharIDFromIndex(targetIndex);
	local targetElementData = nil;

	-- The following case can happen if we are moving a character out of a group with no ungrouped characters, essentially making a new empty character slot.
	if originElementData and originElementData.isGroup and targetIndex > #s_characterReorderTranslation then
		insertEmptyCharacter = true;
	else
		targetElementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
			return CharacterSelectListUtil.ContainsCharacterID(targetCharacterID, elementData);
		end);
	end

	if originElementData and targetElementData then
		if not originElementData.isGroup and targetElementData.isGroup then
			local targetGuid = GetCharacterGUID(targetCharacterID);
			if not targetGuid then
				removeTargetCharacter = true;
			end
		elseif originElementData.isGroup and not targetElementData.isGroup then
			insertEmptyCharacter = true;
		elseif originElementData.isGroup and targetElementData.isGroup and originElementData.groupID == targetElementData.groupID then
			local targetGuid = GetCharacterGUID(targetCharacterID);
			if not targetGuid then
				sameGroupEmptyCharacterSwap = true;
			end
		end
	end

	if removeTargetCharacter then
		table.remove(s_characterReorderTranslation, targetIndex);
	elseif insertEmptyCharacter then
		table.insert(s_characterReorderTranslation, originIndex, 0);
	else
		local value = s_characterReorderTranslation[originIndex];
		table.remove(s_characterReorderTranslation, originIndex);
		table.insert(s_characterReorderTranslation, targetIndex, value);
	end

	CharacterSelect.createIndex = #s_characterReorderTranslation + 1;

	-- Get the origin frame element data index, in case we need it later for post move animations.
	local originElementDataIndex = nil;
	local originGuid = GetCharacterGUID(originCharacterID);
	local originFrame = CharacterSelectCharacterFrame.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		return CharacterSelectListUtil.GetCharacterPositionData(originGuid, elementData) ~= nil;
	end);

	if originFrame then
		if originElementData.isGroup then
			for _, character in ipairs(originFrame.groupButtons) do
				if character:GetCharacterID() == originCharacterID then
					originElementDataIndex = character:GetElementDataIndex();
					break;
				end
			end
		else
			originElementDataIndex = originFrame:GetElementDataIndex();
		end
	end

	CharacterSelectListUtil.UpdateSelectedIndex(selectedCharacterID);
	CharacterSelectCharacterFrame:UpdateCharacterSelection();

	-- Visually refresh character rendering now that things have moved.
	local noCreate = true;
	CharacterSelect_SelectCharacter(CharacterSelect.selectedIndex, noCreate);

	-- Ensure we update character display, as no update event will happen as we are not actually changing the selected character.
	CharacterSelect.CharacterSelectUI:SetCharacterDisplay(originCharacterID);

	-- Do any visual updates needed once things have updated (scroll to a character, play animations, etc.)
	local function AnimatePulseAnimForCharacter(frame)
		frame:AnimatePulse();
	end;

	local function AnimateGlowAnimForCharacter(frame)
		frame:AnimateGlow();
	end;

	local function AnimateGlowMoveAnimForCharacter(frame)
		frame:AnimateGlowMove();
	end;

	if removeTargetCharacter then
		CharacterSelectListUtil.ForCharacterDo(originCharacterID, AnimatePulseAnimForCharacter);

		-- In this case, the origin character got moved to where the empty character slot was, which has to be in a group.
		local groupFrame = CharacterSelectCharacterFrame.ScrollBox:FindFrameByPredicate(function(frame, elementData)
			return CharacterSelectListUtil.GetCharacterPositionData(originGuid, elementData) ~= nil;
		end);

		if groupFrame then
			groupFrame:AnimatePulse();
		end
	elseif insertEmptyCharacter then
		CharacterSelectListUtil.ForCharacterDo(originCharacterID, AnimateGlowAnimForCharacter);

		-- Play GlowFade anim on the newly created empty character slot, using the previously set originElementDataIndex.
		local originalGroupID = originElementData.groupID;
		local groupFrame = CharacterSelectCharacterFrame.ScrollBox:FindFrameByPredicate(function(frame, elementData)
			return elementData.isGroup and elementData.groupID == originalGroupID;
		end);

		if groupFrame then
			groupFrame.groupButtons[originElementDataIndex]:AnimateGlowFade();
		end
	elseif sameGroupEmptyCharacterSwap then
		CharacterSelectListUtil.ForCharacterDo(originCharacterID, AnimateGlowAnimForCharacter);
		originFrame.groupButtons[originElementDataIndex]:AnimateGlowFade();
	else
		CharacterSelectListUtil.ForCharacterDo(originCharacterID, AnimateGlowMoveAnimForCharacter);
		CharacterSelectListUtil.ForCharacterDo(targetCharacterID, AnimateGlowMoveAnimForCharacter);
	end

	-- Scroll to the updated element data, now that the move is complete.
	local updatedElementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
		return CharacterSelectListUtil.ContainsCharacterID(originCharacterID, elementData);
	end);

	if updatedElementData then
		CharacterSelectListUtil.ScrollToElement(updatedElementData, ScrollBoxConstants.AlignNearest);
	end
end

function CharacterSelectListUtil.UpdateSelectedIndex(selectedID)
	CharacterSelect.selectedIndex = tIndexOf(s_characterReorderTranslation, selectedID);
end

function CharacterSelectListUtil.AreAnyCharactersEligible(block)
	for index = 1, #s_characterReorderTranslation do
		local serviceInfo = block:GetServiceInfoByCharacterID(s_characterReorderTranslation[index]);
		if serviceInfo.isEligible then
			return true;
		end
	end

	return false;
end

function CharacterSelectListUtil.GetCharacterPositionData(characterGUID, elementData)
	if elementData.isGroup then
		for _, data in ipairs(elementData.characterData) do
			local guid = GetCharacterGUID(data.characterID);
			if characterGUID == guid then
				return data.characterID;
			end
		end
	elseif elementData.isDivider then
		return nil;
	else
		local guid = GetCharacterGUID(elementData.characterID);
		if characterGUID == guid then
			return elementData.characterID;
		end
	end

	return nil;
end

function CharacterSelectListUtil.ContainsCharacterID(characterID, elementData)
	if elementData.isGroup then
		for _, data in ipairs(elementData.characterData) do
			if data.characterID == characterID then
				return true;
			end
		end
	elseif elementData.isDivider then
		return false;
	else
		return elementData.characterID == characterID;
	end
end

function CharacterSelectListUtil.RunCallbackOnSlot(frame, callback)
	local elementData = frame:GetElementData();
	if elementData.isGroup then
		for _, character in ipairs(frame.groupButtons) do
			-- Don't run on empty character slots.
			if character:GetCharacterGUID() ~= nil then
				callback(character);
			end
		end
	elseif elementData.isDivider then
		return;
	else
		callback(frame);
	end
end

function CharacterSelectListUtil.ForEachCharacterDo(callback)
	CharacterSelectCharacterFrame.ScrollBox:ForEachFrame(function(frame)
		CharacterSelectListUtil.RunCallbackOnSlot(frame, callback);
	end);
end

function CharacterSelectListUtil.ForCharacterDo(characterID, callback)
	local guid = GetCharacterGUID(characterID);
	local frame = CharacterSelectCharacterFrame.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		return CharacterSelectListUtil.GetCharacterPositionData(guid, elementData) ~= nil;
	end);

	if frame then
		local frameElementData = frame:GetElementData();
		if frameElementData.isGroup then
			for _, character in ipairs(frame.groupButtons) do
				if character:GetCharacterID() == characterID then
					callback(character);
					break;
				end
			end
		else
			callback(frame);
		end
	end
end;

function CharacterSelectListUtil.ForceExpandGroup(groupElementData)
	groupElementData.collapsed = false;
	local groupFrame = CharacterSelectCharacterFrame.ScrollBox:FindFrame(groupElementData);
	if groupFrame then
		-- Update if showing.
		groupFrame:OnExpandedChanged(groupElementData);
	end
end

function CharacterSelectListUtil.ScrollToElement(elementData, alignment)
	-- Force expand the group, as we are about to scroll to it.
	if elementData.isGroup and elementData.collapsed then
		CharacterSelectListUtil.ForceExpandGroup(elementData);
	end
	CharacterSelectCharacterFrame.ScrollBox:ScrollToElementData(elementData, alignment);
end

function CharacterSelectListUtil.UpdateCharacter(frame, characterID)
	local characterGuid = GetCharacterGUID(characterID);
	local isEmpty = characterGuid == nil;

	local updatedCharacterData = {
		characterID = characterID,
		isEmpty = isEmpty,
		height = CharacterSelectListUtil.CharacterHeight
	}

	local elementData = frame:GetElementData();
	if elementData.isGroup then
		for _, buttonFrame in ipairs(frame.groupButtons) do
			if buttonFrame:GetCharacterID() == characterID then
				buttonFrame:SetData(updatedCharacterData);
				return;
			end
		end
	else
		frame:SetData(updatedCharacterData);
	end
end

function CharacterSelectListUtil.GetFirstOrLastCharacterIndex(last)
	local index = 0;

	local enumerateFunc = GenerateClosure(last and CharacterSelectCharacterFrame.ScrollBox.ReverseEnumerateDataProviderEntireRange or CharacterSelectCharacterFrame.ScrollBox.EnumerateDataProviderEntireRange, CharacterSelectCharacterFrame.ScrollBox);
	local ipairsFunc = last and ipairs_reverse or ipairs;

	for _, elementData in enumerateFunc() do
		if elementData.isGroup then
			local characterID;
			for _, data in ipairsFunc(elementData.characterData) do
				if not data.isEmpty then
					characterID = data.characterID;
					break;
				end
			end

			if characterID then
				index = CharacterSelectListUtil.GetIndexFromCharID(characterID);
				break;
			end
		elseif elementData.characterID then
			index = CharacterSelectListUtil.GetIndexFromCharID(elementData.characterID);
			break;
		end
	end

	return index;
end

function CharacterSelectListUtil.GetNextCharacterIndex(direction)
	local targetIndex = CharacterSelect.selectedIndex + direction;

	local function EvaluateElementData(elementData, iter)
		if elementData.isGroup then
			for _, data in iter(elementData.characterData) do
				local characterIndex = CharacterSelectListUtil.GetIndexFromCharID(data.characterID);
				if characterIndex == targetIndex then
					if data.isEmpty then
						targetIndex = targetIndex + direction;
					else
						return true;
					end
				end
			end
		elseif elementData.characterID then
			local characterIndex = CharacterSelectListUtil.GetIndexFromCharID(elementData.characterID);
			if characterIndex == targetIndex then
				return true;
			end
		end

		return false;
	end;

	if direction > 0 then
		for _, elementData in CharacterSelectCharacterFrame.ScrollBox:EnumerateDataProviderEntireRange() do
			if EvaluateElementData(elementData, ipairs) then
				return targetIndex;
			end
		end
		local last = false;
		return CharacterSelectListUtil.GetFirstOrLastCharacterIndex(last);
	else
		for _, elementData in CharacterSelectCharacterFrame.ScrollBox:ReverseEnumerateDataProviderEntireRange() do
			if EvaluateElementData(elementData, ipairs_reverse) then
				return targetIndex;
			end
		end
		local last = true;
		return CharacterSelectListUtil.GetFirstOrLastCharacterIndex(last);
	end
end

function CharacterSelectListUtil.GetVASInfoForGUID(guid)
	if not guid then
		return nil;
	end

	local productID, vasServiceState, vasServiceErrors = C_StoreGlue.GetVASPurchaseStateInfo(guid);
	local vasProductInfo = productID and C_StoreSecure.GetProductInfo(productID) or nil;
	return vasServiceState, vasServiceErrors, vasProductInfo;
end

function CharacterSelectListUtil.GetSelectedCharacterFrame()
	local characterID = CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex);
	local frame = CharacterSelectCharacterFrame.ScrollBox:FindFrameByPredicate(function(frame, elementData)
		return CharacterSelectListUtil.ContainsCharacterID(characterID, elementData);
	end);

	return frame;
end

function CharacterSelectListUtil.UpdateCharacterHighlight(guid, isHighlight)
	CharacterSelectListUtil.ForEachCharacterDo(function(frame)
		if frame.characterInfo.guid == guid then
			frame:UpdateHighlightUI(isHighlight);
		end
	end);
end

-- Click the actual character button in the scroll list, in case it may be otherwise disabled.
function CharacterSelectListUtil.ClickCharacterFrameByGUID(guid, isDoubleClick)
	-- First scroll to the character to have the frame present.
	local characterElementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
		return CharacterSelectListUtil.GetCharacterPositionData(guid, elementData) ~= nil;
	end);

	if characterElementData then
		CharacterSelectListUtil.ScrollToElement(characterElementData, ScrollBoxConstants.AlignNearest);

		-- Next, click the frame itself, as it could have behavior that gets overridden if in VAS flows.
		local frame = CharacterSelectCharacterFrame.ScrollBox:FindFrameByPredicate(function(frame, elementData)
			return elementData == characterElementData;
		end);

		if frame then
			if characterElementData.isGroup then
				for _, character in ipairs(frame.groupButtons) do
					if character:GetCharacterGUID() == guid then
						if isDoubleClick then
							character:GetScript("OnDoubleClick")(character);
						else
							character:GetScript("OnClick")(character);
						end
						break;
					end
				end
			elseif isDoubleClick then
				frame:GetScript("OnDoubleClick")(frame);
			else
				frame:GetScript("OnClick")(frame);
			end
		end
	end
end

-- Force select a character, regardless of state.
function CharacterSelectListUtil.SelectCharacterByGUID(guid)
	local characterID;
	local elementData = CharacterSelectCharacterFrame.ScrollBox:FindElementDataByPredicate(function(elementData)
		characterID = CharacterSelectListUtil.GetCharacterPositionData(guid, elementData);
		return characterID ~= nil;
	end);

	if elementData then
		local index = CharacterSelectListUtil.GetIndexFromCharID(characterID);
		CharacterSelectUtil.SelectAtIndex(index);

		CharacterSelectListUtil.ScrollToElement(elementData, ScrollBoxConstants.AlignCenter);

		CharacterSelectCharacterFrame:UpdateCharacterSelection();
		CharacterSelectListUtil.GetCharacterListUpdate();
		return true;
	end

	return false;
end

function CharacterSelectListUtil.GetCharacterListUpdate()
	CharacterSelect.waitingforCharacterList = true;
	GetCharacterListUpdate();
end

-- Called when we need to lock down or turn back on moving things in the scroll list, useful during various VAS flows.
function CharacterSelectListUtil.SetScrollListInteractiveState(state)
	CharacterSelectCharacterFrame:SetScrollEnabled(state);
	CharacterSelectCharacterFrame.ScrollBar:SetAlpha(state and 1 or .2);

	CharacterSelectCharacterFrame.SearchBox:SetEnabled(state);
	CharacterSelectCharacterFrame.SearchBox.clearButton:SetEnabled(state);
	CharacterSelectCharacterFrame.SearchBox:SetAlpha(state and 1 or .2);

	CharacterSelectCharacterFrame.ScrollBox:ForEachFrame(function(frame)
		local elementData = frame:GetElementData();
		if elementData.isGroup then
			frame.Header:SetEnabled(state);
			frame.Header:OnButtonStateChanged();
		end
	end);
end