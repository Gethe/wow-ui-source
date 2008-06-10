MAX_MACROS = 18;
NUM_MACRO_ICONS_SHOWN = 20;
NUM_ICONS_PER_ROW = 5;
NUM_ICON_ROWS = 4;
MACRO_ICON_ROW_HEIGHT = 36;

UIPanelWindows["MacroFrame"] = { area = "left", pushable = 5, whileDead = 1 };

function MacroFrame_Show()
	ShowUIPanel(MacroFrame);
end

function MacroFrame_OnLoad()
	MacroFrame_SetAccountMacros();
	PanelTemplates_SetNumTabs(MacroFrame, 2);
	PanelTemplates_SetTab(MacroFrame, 1);
end

function MacroFrame_OnShow()
	MacroFrame_Update();
	PlaySound("igCharacterInfoOpen");
end

function MacroFrame_OnHide()
	MacroPopupFrame:Hide();
	MacroFrame_SaveMacro();
	--SaveMacros();
	PlaySound("igCharacterInfoClose");
end

function MacroFrame_SetAccountMacros()
	MacroFrame.macroBase = 0;
	local numAccountMacros, numCharacterMacros = GetNumMacros();
	if ( numAccountMacros > 0 ) then
		MacroFrame_SelectMacro(MacroFrame.macroBase + 1);
	else
		MacroFrame_SelectMacro(nil);
	end
end

function MacroFrame_SetCharacterMacros()
	MacroFrame.macroBase = MAX_MACROS;
	local numAccountMacros, numCharacterMacros = GetNumMacros();
	if ( numCharacterMacros > 0 ) then
		MacroFrame_SelectMacro(MacroFrame.macroBase + 1);
	else
		MacroFrame_SelectMacro(nil);
	end
end

function MacroFrame_Update()
	local numMacros;
	local numAccountMacros, numCharacterMacros = GetNumMacros();
	local macroButton, macroIcon, macroName;
	local name, texture, body, isLocal;
	local selectedName, selectedBody, selectedIcon;

	if ( MacroFrame.macroBase == 0 ) then
		numMacros = numAccountMacros;
	else
		numMacros = numCharacterMacros;
	end

	-- Macro List
	for i=1, MAX_MACROS do
		macroButton = getglobal("MacroButton"..i);
		macroIcon = getglobal("MacroButton"..i.."Icon");
		macroName = getglobal("MacroButton"..i.."Name");
		if ( i <= numMacros ) then
			name, texture, body, isLocal = GetMacroInfo(MacroFrame.macroBase + i);
			macroIcon:SetTexture(texture);
			macroName:SetText(name);
			macroButton:Enable();
			-- Highlight Selected Macro
			if ( MacroFrame.selectedMacro and (i == (MacroFrame.selectedMacro - MacroFrame.macroBase)) ) then
				macroButton:SetChecked(1);
				MacroFrameSelectedMacroName:SetText(name);
				MacroFrameText:SetText(body);
				MacroFrameSelectedMacroButton:SetID(i);
				MacroFrameSelectedMacroButtonIcon:SetTexture(texture);
			else
				macroButton:SetChecked(0);
			end
		else
			macroButton:SetChecked(0);
			macroIcon:SetTexture("");
			macroName:SetText("");
			macroButton:Disable();
		end
	end

	-- Macro Details
	if ( MacroFrame.selectedMacro ~= nil ) then
		MacroFrame_ShowDetails();
		MacroDeleteButton:Enable();
	else
		MacroFrame_HideDetails();
		MacroDeleteButton:Disable();
	end
	
	--Update New Button
	if ( numMacros == MAX_MACROS ) then
		MacroNewButton:Disable();
	else
		MacroNewButton:Enable();
	end

	-- Disable Buttons
	if ( MacroPopupFrame:IsVisible() ) then
		MacroEditButton:Disable();
		MacroDeleteButton:Disable();
	else
		MacroEditButton:Enable();
		MacroDeleteButton:Enable();
	end

	if ( not MacroFrame.selectedMacro ) then
		MacroDeleteButton:Disable();
	end
end

function MacroFrame_AddMacroLine(line)
	if ( MacroFrameText:IsVisible() ) then
		MacroFrameText:SetText(MacroFrameText:GetText()..line);
	end
end

function MacroButton_OnClick()
	MacroFrame_SaveMacro();
	MacroFrame_SelectMacro(MacroFrame.macroBase + this:GetID());
	MacroFrame_Update();
	MacroPopupFrame:Hide();
	MacroFrameText:ClearFocus();
end

function MacroFrame_SelectMacro(id)
	MacroFrame.selectedMacro = id;
end

function MacroNewButton_OnClick()
	MacroFrame_SaveMacro();
	MacroPopupFrame.mode = "new";
	MacroPopupFrame:Show();
end

function MacroEditButton_OnClick()
	MacroFrame_SaveMacro();
	MacroPopupFrame.mode = "edit";
	MacroPopupFrame:Show();
end

function MacroFrame_HideDetails()
	MacroEditButton:Hide();
	MacroFrameCharLimitText:Hide();
	MacroFrameText:Hide();
	MacroFrameSelectedMacroName:Hide();
	MacroFrameSelectedMacroBackground:Hide();
	MacroFrameSelectedMacroButton:Hide();
end

function MacroFrame_ShowDetails()
	MacroEditButton:Show();
	MacroFrameCharLimitText:Show();
	MacroFrameEnterMacroText:Show();
	MacroFrameText:Show();
	MacroFrameSelectedMacroName:Show();
	MacroFrameSelectedMacroBackground:Show();
	MacroFrameSelectedMacroButton:Show();
end

function MacroPopupFrame_OnShow()
	if ( this.mode == "new" ) then
		MacroFrameText:Hide();
		MacroFrameSelectedMacroButtonIcon:SetTexture("");
		MacroPopupFrame.selectedIcon = nil;
	end
	MacroFrameText:ClearFocus();
	MacroPopupEditBox:SetFocus();

	PlaySound("igCharacterInfoOpen");
	MacroPopupFrame_Update();
	MacroPopupOkayButton_Update();

	-- Disable Buttons
	MacroEditButton:Disable();
	MacroDeleteButton:Disable();
	MacroNewButton:Disable();
	MacroFrameTab1:Disable();
	MacroFrameTab2:Disable();
end

function MacroPopupFrame_OnHide()
	if ( this.mode == "new" ) then
		MacroFrameText:Show();
		MacroFrameText:SetFocus();
	end
	
	-- Enable Buttons
	MacroEditButton:Enable();
	MacroDeleteButton:Enable();
	local numMacros;
	local numAccountMacros, numCharacterMacros = GetNumMacros();
	if ( MacroFrame.macroBase == 0 ) then
		numMacros = numAccountMacros;
	else
		numMacros = numCharacterMacros;
	end
	if ( numMacros < MAX_MACROS ) then
		MacroNewButton:Enable();
	end
	-- Enable tabs
	PanelTemplates_UpdateTabs(MacroFrame);
end

function MacroPopupFrame_Update()
	local numMacroIcons = GetNumMacroIcons();
	local macroPopupIcon, macroPopupButton;
	local macroPopupOffset = FauxScrollFrame_GetOffset(MacroPopupScrollFrame);
	local index;
	
	-- Determine whether we're creating a new macro or editing an existing one
	if ( this.mode == "new" ) then
		MacroPopupEditBox:SetText("");
	elseif ( this.mode == "edit" ) then
		local name, texture, body, isLocal = GetMacroInfo(MacroFrame.selectedMacro);
		MacroPopupEditBox:SetText(name);
	end
	
	-- Icon list
	for i=1, NUM_MACRO_ICONS_SHOWN do
		macroPopupIcon = getglobal("MacroPopupButton"..i.."Icon");
		macroPopupButton = getglobal("MacroPopupButton"..i);
		index = (macroPopupOffset * NUM_ICONS_PER_ROW) + i;
		if ( index <= numMacroIcons ) then
			macroPopupIcon:SetTexture(GetMacroIconInfo(index));
			macroPopupButton:Show();
		else
			macroPopupIcon:SetTexture("");
			macroPopupButton:Hide();
		end
		if ( index == MacroPopupFrame.selectedIcon ) then
			macroPopupButton:SetChecked(1);
		else
			macroPopupButton:SetChecked(nil);
		end
	end
	
	-- Scrollbar stuff
	FauxScrollFrame_Update(MacroPopupScrollFrame, ceil(numMacroIcons / NUM_ICONS_PER_ROW) , NUM_ICON_ROWS, MACRO_ICON_ROW_HEIGHT );
end

function MacroPopupOkayButton_Update()
	if ( (strlen(MacroPopupEditBox:GetText()) > 0) and MacroPopupFrame.selectedIcon ) then
		MacroPopupOkayButton:Enable();
	else
		MacroPopupOkayButton:Disable();
	end
	if ( MacroPopupFrame.mode == "edit" and (strlen(MacroPopupEditBox:GetText()) > 0) ) then
		MacroPopupOkayButton:Enable();
	end
end

function MacroPopupButton_OnClick()
	MacroPopupFrame.selectedIcon = this:GetID() + (FauxScrollFrame_GetOffset(MacroPopupScrollFrame) * NUM_ICONS_PER_ROW);
	MacroFrameSelectedMacroButtonIcon:SetTexture(GetMacroIconInfo(MacroPopupFrame.selectedIcon));
	MacroPopupOkayButton_Update();
	MacroPopupFrame_Update();
end

function MacroPopupOkayButton_OnClick()
	local index = 1
	if ( MacroPopupFrame.mode == "new" ) then
		index = CreateMacro(MacroPopupEditBox:GetText(), MacroPopupFrame.selectedIcon, nil, nil, (MacroFrame.macroBase > 0));
	elseif ( MacroPopupFrame.mode == "edit" ) then
		index = EditMacro(MacroFrame.selectedMacro, MacroPopupEditBox:GetText(), MacroPopupFrame.selectedIcon);
	end
	MacroPopupFrame:Hide();
	MacroFrame_SelectMacro(index);
	MacroFrame_Update();
end

function MacroFrame_SaveMacro()
	if ( MacroFrame.textChanged and MacroFrame.selectedMacro ) then
		EditMacro(MacroFrame.selectedMacro, nil, nil, MacroFrameText:GetText());
		MacroFrame.textChanged = nil;
	end
end
