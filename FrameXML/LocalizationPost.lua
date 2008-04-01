RUSSIAN_DECLENSION_PATTERNS = 5;
RUSSIAN_DECLENSION = "Склонение";
RUSSIAN_DECLENSION_1 = "Родительный падеж";
RUSSIAN_DECLENSION_EXAMPLE_1 = "Я всегда рад приходу %s.";
RUSSIAN_DECLENSION_2 = "Дательный падеж";
RUSSIAN_DECLENSION_EXAMPLE_2 = "Вчера, например, я дал %s в лоб.";
RUSSIAN_DECLENSION_3 = "Винительный падеж";
RUSSIAN_DECLENSION_EXAMPLE_3 = "Сегодня я снова встретил %s.";
RUSSIAN_DECLENSION_4 = "Творительный падеж";
RUSSIAN_DECLENSION_EXAMPLE_4 = "Теперь мы с %s друзья.";
RUSSIAN_DECLENSION_5 = "Предложный падеж";
RUSSIAN_DECLENSION_EXAMPLE_5 = "Хотя я ничего не знаю о %s.";

RUSSIAN_DECLENSION_TAB_LIST = {};
RUSSIAN_DECLENSION_TAB_LIST[1] = "DeclensionFrameDeclension1Edit";
RUSSIAN_DECLENSION_TAB_LIST[2] = "DeclensionFrameDeclension2Edit";
RUSSIAN_DECLENSION_TAB_LIST[3] = "DeclensionFrameDeclension3Edit";
RUSSIAN_DECLENSION_TAB_LIST[4] = "DeclensionFrameDeclension4Edit";
RUSSIAN_DECLENSION_TAB_LIST[5] = "DeclensionFrameDeclension5Edit";

function DeclensionFrame_OnEvent(self, event, ...)
	if ( event == "PET_FORCE_NAME_DECLENSION" ) then
		this.name = ...;
		this:Show();
	end
	
end

function DeclensionFrame_Update()
	local declensionButton, exampleButton, declensionBox;
	local declension, example, declension;
	local backdropColor = DEFAULT_TOOLTIP_COLOR;
	
	local name = DeclensionFrame.name;
	DeclensionFrameNominative:SetText(name);

	local count = GetNumDeclensionSets(name);
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

	local names = { DeclineName(name, nil, set) };

	for i=1, RUSSIAN_DECLENSION_PATTERNS do
		declensionButton = getglobal("DeclensionFrameDeclension"..i.."Type");
		exampleButton = getglobal("DeclensionFrameDeclension"..i.."Example");
		declensionBox = getglobal("DeclensionFrameDeclension"..i.."Edit");
		declensionBox:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b);
		declensionBox:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
		declensionBox:SetText(names[i]);
		declensionButton:SetText(getglobal("RUSSIAN_DECLENSION_"..i));
		exampleButton:SetText(format(getglobal("RUSSIAN_DECLENSION_EXAMPLE_"..i), names[i]));
	end
end

function DeclensionFrame_OnOkay()
	local valid;
	local names = {};
	for i=1, RUSSIAN_DECLENSION_PATTERNS do
		names[i] = getglobal("DeclensionFrameDeclension"..i.."Edit"):GetText();
		if ( names[i] ) then
			valid = 1;
		else
			valid = nil;
		end
	end
	if ( valid ) then
		DeclineCharacter(DeclensionFrame.name, names[1], names[2], names[3], names[4], names[5]);
		DeclensionFrame:Hide();
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
	if ( set <  count ) then
		set = set + 1;
	end
	
	DeclensionFrame.set = set;
	DeclensionFrame_Update();
end

function DeclensionFrame_Prev()
	local set = DeclensionFrame.set;
	local count = DeclensionFrame.count;
	if ( not set ) then
		set = 1;
	end
	
	if ( set == count ) then
		set = set - 1;
	end
	DeclensionFrame.set = set;
	DeclensionFrame_Update();
end
