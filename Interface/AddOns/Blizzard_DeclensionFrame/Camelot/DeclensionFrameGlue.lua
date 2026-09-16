RUSSIAN_DECLENSION_PATTERNS = 5;

RUSSIAN_DECLENSION_TAB_LIST_NAME = {};
RUSSIAN_DECLENSION_TAB_LIST_NAME[1] = "DeclensionFrameDeclension1EditName";
RUSSIAN_DECLENSION_TAB_LIST_NAME[2] = "DeclensionFrameDeclension2EditName";
RUSSIAN_DECLENSION_TAB_LIST_NAME[3] = "DeclensionFrameDeclension3EditName";
RUSSIAN_DECLENSION_TAB_LIST_NAME[4] = "DeclensionFrameDeclension4EditName";
RUSSIAN_DECLENSION_TAB_LIST_NAME[5] = "DeclensionFrameDeclension5EditName";
RUSSIAN_DECLENSION_TAB_LIST_SURNAME = {};
RUSSIAN_DECLENSION_TAB_LIST_SURNAME[1] = "DeclensionFrameDeclension1EditSurname";
RUSSIAN_DECLENSION_TAB_LIST_SURNAME[2] = "DeclensionFrameDeclension2EditSurname";
RUSSIAN_DECLENSION_TAB_LIST_SURNAME[3] = "DeclensionFrameDeclension3EditSurname";
RUSSIAN_DECLENSION_TAB_LIST_SURNAME[4] = "DeclensionFrameDeclension4EditSurname";
RUSSIAN_DECLENSION_TAB_LIST_SURNAME[5] = "DeclensionFrameDeclension5EditSurname";

function DeclensionFrame_OnLoad(self)
	BackdropTemplateMixin.OnBackdropLoaded(self);
	self:RegisterEvent("FORCE_DECLINE_CHARACTER");
	self:RegisterEvent("CHARACTER_DECLINE_RESULT");
	self:RegisterEvent("CHARACTER_DECLINE_IN_PROGRESS");
	self.indexName = 1; -- the current declension set we want to use for first name
	self.indexSurname = 1; -- the current declension set we want to use for surname
	self.countName = 1; -- number of declension sets available for first name including DONOTDECLINE
	self.countSurname = 1; -- number of declension sets available for surname including DONOTDECLINE
end

function DeclensionFrame_OnEvent(self, event, ...)
	if ( event == "FORCE_DECLINE_CHARACTER" ) then
		self:Show();
	elseif ( event == "CHARACTER_DECLINE_RESULT" ) then
		local err = ...;
		if ( err ) then
			StaticPopup_Show("DECLINE_FAILED", _G[err]);
		else
			StaticPopup_HideAll();
		end
	elseif ( event == "CHARACTER_DECLINE_IN_PROGRESS" ) then
		StaticPopup_Show("OKAY", CHAR_DECLINE_IN_PROGRESS);
	end
end

function DeclensionFrame_Update()
	local declensionButton, exampleButton, declensionBoxName, declensionBoxSurname;

	if not CharacterSelect.selectedIndex then
		return;
	end
	local characterGuid = GetCharacterGUID(CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex));
	if not characterGuid then
		return;
	end

	local basicCharacterInfo = GetBasicCharacterInfo(characterGuid);

	if not basicCharacterInfo.surname then
		return;
	end

	DeclensionFrameNominative:SetText(basicCharacterInfo.characterName .. " " .. basicCharacterInfo.surname);

	-- GetNumDeclensionSets also includes DONOTDECLINE
	-- countName and countSurname could be 1, 2, or 3
	local countName = GetNumDeclensionSets(basicCharacterInfo.characterName, basicCharacterInfo.genderID);
	local countSurname = GetNumDeclensionSets(basicCharacterInfo.surname, basicCharacterInfo.genderID, Enum.NamePartType.Surname);

	if (countName < 1 or countSurname < 1) then
		DeclensionFrame:Hide(); -- something is wrong
		return;
	end

	DeclensionFrame.countName = countName;
	DeclensionFrame.countSurname = countSurname;

	-- number of combinations = count of name declesion sets * count of surname declesion sets 
	local count = countName * countSurname;

	-- index starts at 1 so hence -1 for multiplications
	local set = (DeclensionFrame.indexName -1) * countSurname + DeclensionFrame.indexSurname ;
	
	-- Save the count value so we know our max pages.
	DeclensionFrame.count = count;

	-- Hide the paging tool if there is only one set
	if ( count > 1 ) then
		DeclensionFrameSetPage:SetText(format(DECLENSION_SET, set, count));
		DeclensionFrame:SetHeight(330);
		DeclensionFrameSet:Show();
		if ( set == 1 and set < count ) then
			DeclensionFrameSetNext:Enable();
			DeclensionFrameSetPrev:Disable();
		elseif ( set == count and set ~= 1 ) then
			DeclensionFrameSetNext:Disable();
			DeclensionFrameSetPrev:Enable();
		elseif ( set <= count - 1 and set ~= 1 ) then
			DeclensionFrameSetNext:Enable();
			DeclensionFrameSetPrev:Enable();
		end
	else
		DeclensionFrame:SetHeight(310);
		DeclensionFrameSet:Hide();
	end

	-- First name declensions
	local names;
	if ( DeclensionFrame.names ) then
		names = DeclensionFrame.names;
		DeclensionFrame.names = nil;
	else
		names = { DeclineName(basicCharacterInfo.characterName, basicCharacterInfo.genderID, DeclensionFrame.indexName) };
	end

	-- Surname declensions
	local surnames;
	if ( DeclensionFrame.surnames ) then
		surnames = DeclensionFrame.surnames;
		DeclensionFrame.surnames = nil;
	else
		surnames = { DeclineName(basicCharacterInfo.surname, basicCharacterInfo.genderID, DeclensionFrame.indexSurname, Enum.NamePartType.Surname) };
	end

	for i=1, RUSSIAN_DECLENSION_PATTERNS do
		declensionButton = _G["DeclensionFrameDeclension"..i.."Type"];
		exampleButton = _G["DeclensionFrameDeclension"..i.."Example"];
		declensionBoxName = _G["DeclensionFrameDeclension"..i.."EditName"];
		declensionBoxName:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
		declensionBoxName:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
		declensionBoxName:SetText(names[i]);
		declensionBoxSurname = _G["DeclensionFrameDeclension"..i.."EditSurname"];
		declensionBoxSurname:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
		declensionBoxSurname:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
		declensionBoxSurname:SetText(surnames[i]);
		declensionButton:SetText(_G["RUSSIAN_DECLENSION_"..i]);
		exampleButton:SetText(format(_G["RUSSIAN_DECLENSION_EXAMPLE_"..i], names[i]..' '..surnames[i]));
	end
end

function DeclensionFrame_OnOkay()
	local valid = 1;
	local names = {};
	for i=1, RUSSIAN_DECLENSION_PATTERNS do
		names[i] = _G["DeclensionFrameDeclension"..i.."EditName"]:GetText();
		if ( not names[i] ) then
			valid = nil;
		end
	end

	local surnames = {};
	for i=1, RUSSIAN_DECLENSION_PATTERNS do
		surnames[i] = _G["DeclensionFrameDeclension"..i.."EditSurname"]:GetText();
		if ( not surnames[i] ) then
			valid = nil;
		end
	end

	if ( valid ) then
		DeclensionFrame:Hide();
		DeclineCharacter(CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex),
			names[1], names[2], names[3], names[4], names[5],
			surnames[1], surnames[2], surnames[3], surnames[4], surnames[5]);

	end
end

function DeclensionFrame_OnCancel()
	DeclensionFrame.indexName = 1;
	DeclensionFrame.indexSurname = 1;
	DeclensionFrame:Hide();
end

function DeclensionFrame_Next()
	-- Upon entering this function we can assume that
	-- countName > 1 and countSurname > 1 and indexSurname < countSurname and indexName < countName
	DeclensionFrame.indexSurname = DeclensionFrame.indexSurname + 1;
	if (DeclensionFrame.indexSurname > DeclensionFrame.countSurname) then
		DeclensionFrame.indexName = DeclensionFrame.indexName + 1;
		if (DeclensionFrame.indexName > DeclensionFrame.countName) then
			DeclensionFrame.indexSurname = DeclensionFrame.countSurname;
			DeclensionFrame.indexName = DeclensionFrame.countName;
		else
			DeclensionFrame.indexSurname = 1;
		end
	end

	DeclensionFrame_Update();
end

function DeclensionFrame_Prev()
	DeclensionFrame.indexSurname = DeclensionFrame.indexSurname - 1;
	if (DeclensionFrame.indexSurname <= 0) then
		DeclensionFrame.indexName = DeclensionFrame.indexName - 1;
		if (DeclensionFrame.indexName <= 0) then
			-- This cannot be.
			DeclensionFrame.indexSurname = 1;
			DeclensionFrame.indexName = 1;
		else
			DeclensionFrame.indexSurname = DeclensionFrame.countSurname; 
		end
	end
	DeclensionFrame_Update();
end
