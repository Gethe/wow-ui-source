MAX_MACROS = 18;
NUM_MACRO_ICONS_SHOWN = 20;
NUM_ICONS_PER_ROW = 5;
NUM_ICON_ROWS = 4;
MACRO_ICON_ROW_HEIGHT = 36;

function MacroFrame_OnLoad()
	if ( GetNumMacros() > 0 ) then
		MacroFrame_SelectMacro(1);
		MacroFrameSelectedMacroButton:SetID(1);
	else
		MacroFrame_SelectMacro(nil);
	end
end

function MacroFrame_OnShow()
	MacroFrame_Update();
	PlaySound("igCharacterInfoOpen");
	--MacroNewButton:SetText(NEW);
end

function MacroFrame_OnHide()
	MacroPopupFrame:Hide();
	if ( MacroFrame.textChanged and GetNumMacros() > 0) then
		EditMacro(MacroFrame.selectedMacro, nil, nil, MacroFrameText:GetText(), 1);		
	end
	MacroFrame.textChanged = nil;
	SaveMacros();
	PlaySound("igCharacterInfoClose");
end

function MacroFrame_Update()
	local numMacros	= GetNumMacros();
	local macroButton, macroIcon, macroName;
	local name, texture, body, isLocal;
	local selectedName, selectedBody, selectedIcon;
	
	-- Macro List
	for i=1, MAX_MACROS do
		macroButton = getglobal("MacroButton"..i);
		macroIcon = getglobal("MacroButton"..i.."Icon");
		macroName = getglobal("MacroButton"..i.."Name");
		if ( i <= numMacros ) then
			name, texture, body, isLocal = GetMacroInfo(i);
			macroIcon:SetTexture(texture);
			macroName:SetText(name);
			macroButton:Enable();
			-- Highlight Selected Macro
			if ( i == MacroFrame.selectedMacro ) then
				macroButton:SetChecked(1);
				MacroFrameSelectedMacroName:SetText(name);
				MacroFrameText:SetText(body);
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
	
	if ( numMacros == MAX_MACROS or MacroPopupFrame:IsVisible() ) then
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
	if ( MacroFrame.textChanged ) then
		EditMacro(MacroFrame.selectedMacro, nil, nil, MacroFrameText:GetText(), 1);		
	end
	MacroFrame.textChanged = nil;
	MacroFrame_SelectMacro(this:GetID());
	MacroFrameSelectedMacroButton:SetID(this:GetID());
	MacroFrame_Update();
	MacroPopupFrame:Hide();
	MacroFrameText:ClearFocus();
end

function MacroFrame_SelectMacro(id)
	MacroFrame.selectedMacro = id;
end

function MacroNewButton_OnClick()
	if ( MacroNewButton:GetText() == COMPLETE ) then
		MacroFrameText:ClearFocus();
		--MacroNewButton:SetText(NEW);
		return;
	end
	
	MacroPopupFrame.mode = "new";
	if ( MacroFrame.textChanged and MacroFrame.selectedMacro ) then
		EditMacro(MacroFrame.selectedMacro, nil, nil, MacroFrameText:GetText(), 1);		
	end
	MacroFrameText:Hide();
	MacroFrame.textChanged = nil;
	MacroFrameSelectedMacroButtonIcon:SetTexture("");
	MacroPopupFrame.selectedIcon = nil;
	MacroPopupFrame:Show();
	--MacroNewButton:SetText(COMPLETE);
end

function MacroEditButton_OnClick()
	MacroPopupFrame.mode = "edit";
	if ( MacroFrame.textChanged ) then
		EditMacro(MacroFrame.selectedMacro, nil, nil, MacroFrameText:GetText(), 1);		
	end
	MacroFrame.textChanged = nil;
	MacroPopupOkayButton_Update();
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
	MacroPopupFrame_Update();
	PlaySound("igCharacterInfoOpen");
	MacroFrameText:ClearFocus();
	MacroPopupEditBox:SetFocus();
	MacroPopupOkayButton_Update();

	-- Disable Buttons
	MacroEditButton:Disable();
	MacroDeleteButton:Disable();
	MacroNewButton:Disable();
end

function MacroPopupFrame_OnHide()
	if ( this.mode == "new" ) then
		MacroFrameText:Show();
		MacroFrameText:SetFocus();
	end
	
	-- Enable Buttons
	MacroEditButton:Enable();
	MacroDeleteButton:Enable();
	MacroNewButton:Enable();
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
	MacroPopupFrame.selectedIcon =  this:GetID() + (FauxScrollFrame_GetOffset(MacroPopupScrollFrame) * NUM_ICONS_PER_ROW)
	MacroFrameSelectedMacroButtonIcon:SetTexture(GetMacroIconInfo(MacroPopupFrame.selectedIcon));
	MacroPopupOkayButton_Update();
	MacroPopupFrame_Update();
end

function MacroPopupOkayButton_OnClick()
	if ( MacroPopupFrame.mode == "new" ) then
		CreateMacro(MacroPopupEditBox:GetText(), MacroPopupFrame.selectedIcon, nil, 1);
	elseif ( MacroPopupFrame.mode == "edit" ) then
		EditMacro(MacroFrame.selectedMacro, MacroPopupEditBox:GetText(), MacroPopupFrame.selectedIcon);
	end
	MacroFrame_SelectMacro(GetMacroIndexByName(MacroPopupEditBox:GetText()));
	MacroPopupFrame:Hide();
	MacroFrame_Update();
end

function MacroFrame_EditMacro()
	if ( MacroFrameText:IsVisible() ) then
		if ( MacroFrame.textChanged ) then
			EditMacro(MacroFrame.selectedMacro, nil, nil, MacroFrameText:GetText(), 1);
			MacroFrame.textChanged = nil;
		end
	end
end