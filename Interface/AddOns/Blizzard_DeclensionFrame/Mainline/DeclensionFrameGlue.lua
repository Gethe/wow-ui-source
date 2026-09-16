RUSSIAN_DECLENSION_PATTERNS = 5;

RUSSIAN_DECLENSION_TAB_LIST = {};
RUSSIAN_DECLENSION_TAB_LIST[1] = "DeclensionFrameDeclension1Edit";
RUSSIAN_DECLENSION_TAB_LIST[2] = "DeclensionFrameDeclension2Edit";
RUSSIAN_DECLENSION_TAB_LIST[3] = "DeclensionFrameDeclension3Edit";
RUSSIAN_DECLENSION_TAB_LIST[4] = "DeclensionFrameDeclension4Edit";
RUSSIAN_DECLENSION_TAB_LIST[5] = "DeclensionFrameDeclension5Edit";

function DeclensionFrame_OnLoad(self)
	BackdropTemplateMixin.OnBackdropLoaded(self);
	self:RegisterEvent("FORCE_DECLINE_CHARACTER");
	self:RegisterEvent("CHARACTER_DECLINE_RESULT");
	self:RegisterEvent("CHARACTER_DECLINE_IN_PROGRESS");
	self.set = 1;
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
	local declensionButton, exampleButton, declensionBox;

	if not CharacterSelect.selectedIndex then
		return;
	end
	local characterGuid = GetCharacterGUID(CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex));
	if not characterGuid then
		return;
	end

	local basicCharacterInfo = GetBasicCharacterInfo(characterGuid);
	DeclensionFrameNominative:SetText(basicCharacterInfo.characterName);

	local count = GetNumDeclensionSets(basicCharacterInfo.characterName, basicCharacterInfo.genderID);
	local set = DeclensionFrame.set;

	if ( not set ) then
		set = 1;
	end

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
		elseif ( set == count - 1 and set ~= 1 ) then
			DeclensionFrameSetNext:Enable();
			DeclensionFrameSetPrev:Enable();
		end
	else
		DeclensionFrame:SetHeight(310);
		DeclensionFrameSet:Hide();
	end

	local names;
	if ( DeclensionFrame.names ) then
		names = DeclensionFrame.names;
		DeclensionFrame.names = nil;
	else
		names = { DeclineName(basicCharacterInfo.characterName, basicCharacterInfo.genderID, set) };
	end

	for i=1, RUSSIAN_DECLENSION_PATTERNS do
		declensionButton = _G["DeclensionFrameDeclension"..i.."Type"];
		exampleButton = _G["DeclensionFrameDeclension"..i.."Example"];
		declensionBox = _G["DeclensionFrameDeclension"..i.."Edit"];
		declensionBox:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
		declensionBox:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
		declensionBox:SetText(names[i]);
		declensionButton:SetText(_G["RUSSIAN_DECLENSION_"..i]);
		exampleButton:SetText(format(_G["RUSSIAN_DECLENSION_EXAMPLE_"..i], names[i]));
	end
end

function DeclensionFrame_OnOkay()
	local valid;
	local names = {};
	for i=1, RUSSIAN_DECLENSION_PATTERNS do
		names[i] = _G["DeclensionFrameDeclension"..i.."Edit"]:GetText();
		if ( names[i] ) then
			valid = 1;
		else
			valid = nil;
		end
	end
	if ( valid ) then
		DeclensionFrame:Hide();
		DeclineCharacter(CharacterSelectListUtil.GetCharIDFromIndex(CharacterSelect.selectedIndex), names[1], names[2], names[3], names[4], names[5]);
	end
end

function DeclensionFrame_OnCancel()
	DeclensionFrame.set = 1;
	DeclensionFrame:Hide();
end

function DeclensionFrame_Next()
	local set = DeclensionFrame.set;
	local count = DeclensionFrame.count;
	if ( not set ) then
		set = 1;
	end

	set = set + 1;
	DeclensionFrame.set = set;
	DeclensionFrame_Update();
end

function DeclensionFrame_Prev()
	local set = DeclensionFrame.set;
	local count = DeclensionFrame.count;
	if ( not set ) then
		set = 1;
	end

	set = set - 1;
	DeclensionFrame.set = set;
	DeclensionFrame_Update();
end
