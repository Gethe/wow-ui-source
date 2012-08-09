MAX_ACCOUNT_MACROS = 36;
MAX_CHARACTER_MACROS = 18;
NUM_MACROS_PER_ROW = 6;
NUM_ICONS_PER_ROW = 5;
NUM_ICON_ROWS = 4;
NUM_MACRO_ICONS_SHOWN = NUM_ICONS_PER_ROW * NUM_ICON_ROWS;
MACRO_ICON_ROW_HEIGHT = 36;
local MACRO_ICON_FILENAMES = {};

UIPanelWindows["MacroFrame"] = { area = "left", pushable = 1, whileDead = 1, width = PANEL_DEFAULT_WIDTH };

function MacroFrame_Show()
	ShowUIPanel(MacroFrame);
end

function MacroFrame_OnLoad(self)
	MacroFrame_SetAccountMacros();
	PanelTemplates_SetNumTabs(MacroFrame, 2);
	PanelTemplates_SetTab(MacroFrame, 1);
end

function MacroFrame_OnShow(self)
	MacroFrame_Update();
	PlaySound("igCharacterInfoOpen");
	UpdateMicroButtons();
end

function MacroFrame_OnHide(self)
	MacroPopupFrame:Hide();
	MacroFrame_SaveMacro();
	--SaveMacros();
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();
end

function MacroFrame_SetAccountMacros()
	MacroFrame.macroBase = 0;
	MacroFrame.macroMax = MAX_ACCOUNT_MACROS;
	local numAccountMacros, numCharacterMacros = GetNumMacros();
	if ( numAccountMacros > 0 ) then
		MacroFrame_SelectMacro(MacroFrame.macroBase + 1);
	else
		MacroFrame_SelectMacro(nil);
	end
end

function MacroFrame_SetCharacterMacros()
	MacroFrame.macroBase = MAX_ACCOUNT_MACROS;
	MacroFrame.macroMax = MAX_CHARACTER_MACROS;
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
	local macroButtonName, macroButton, macroIcon, macroName;
	local name, texture, body;
	local selectedName, selectedBody, selectedIcon;

	if ( MacroFrame.macroBase == 0 ) then
		numMacros = numAccountMacros;
	else
		numMacros = numCharacterMacros;
	end

	-- Macro List
	local maxMacroButtons = max(MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS);
	for i=1, maxMacroButtons do
		macroButtonName = "MacroButton"..i;
		macroButton = _G[macroButtonName];
		macroIcon = _G[macroButtonName.."Icon"];
		macroName = _G[macroButtonName.."Name"];
		if ( i <= MacroFrame.macroMax ) then
			if ( i <= numMacros ) then
				name, texture, body = GetMacroInfo(MacroFrame.macroBase + i);
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
					MacroPopupFrame.selectedIconTexture = gsub( strupper(texture), "INTERFACE\\ICONS\\", "");
				else
					macroButton:SetChecked(0);
				end
			else
				macroButton:SetChecked(0);
				macroIcon:SetTexture("");
				macroName:SetText("");
				macroButton:Disable();
			end
			macroButton:Show();
		else
			macroButton:Hide();
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
	if ( numMacros < MacroFrame.macroMax ) then
		MacroNewButton:Enable();
	else
		MacroNewButton:Disable();
	end

	-- Disable Buttons
	if ( MacroPopupFrame:IsShown() ) then
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

function MacroButton_OnClick(self, button)
	MacroFrame_SaveMacro();
	MacroFrame_SelectMacro(MacroFrame.macroBase + self:GetID());
	MacroFrame_Update();
	MacroPopupFrame:Hide();
	MacroFrameText:ClearFocus();
end

function MacroFrameSaveButton_OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn");
	MacroFrame_SaveMacro();
	MacroFrame_Update();
	MacroPopupFrame:Hide();
	MacroFrameText:ClearFocus();
end

function MacroFrameCancelButton_OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn");
	MacroFrame_Update();
	MacroPopupFrame:Hide();
	MacroFrameText:ClearFocus();
end

function MacroFrame_SelectMacro(id)
	MacroFrame.selectedMacro = id;
end

function MacroFrame_DeleteMacro()
	local selectedMacro = MacroFrame.selectedMacro;
	DeleteMacro(selectedMacro);
	-- the order of the return values (account macros, character macros) matches up with the IDs of the tabs
	local numMacros = select(PanelTemplates_GetSelectedTab(MacroFrame), GetNumMacros());
	if ( selectedMacro > numMacros + MacroFrame.macroBase) then
		selectedMacro = selectedMacro - 1;
	end
	if ( selectedMacro <= MacroFrame.macroBase ) then
		MacroFrame.selectedMacro = nil;
	else
		MacroFrame.selectedMacro = selectedMacro;
	end
	MacroFrame_Update();
	MacroFrameText:ClearFocus();
end

function MacroNewButton_OnClick(self, button)
	MacroFrame_SaveMacro();
	MacroPopupFrame.mode = "new";
	MacroPopupFrame:Show();
end

function MacroEditButton_OnClick(self, button)
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

function MacroButtonContainer_OnLoad(self)
	local button;
	local maxMacroButtons = max(MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS);
	for i=1, maxMacroButtons do
		button = CreateFrame("CheckButton", "MacroButton"..i, self, "MacroButtonTemplate");
		button:SetID(i);
		if ( i == 1 ) then
			button:SetPoint("TOPLEFT", self, "TOPLEFT", 6, -6);
		elseif ( mod(i, NUM_MACROS_PER_ROW) == 1 ) then
			button:SetPoint("TOP", "MacroButton"..(i-NUM_MACROS_PER_ROW), "BOTTOM", 0, -10);
		else
			button:SetPoint("LEFT", "MacroButton"..(i-1), "RIGHT", 13, 0);
		end
	end
end

function MacroPopupFrame_OnShow(self)
	MacroPopupEditBox:SetFocus();

	PlaySound("igCharacterInfoOpen");
	RefreshPlayerSpellIconInfo();
	MacroPopupFrame_Update(self);
	MacroPopupOkayButton_Update();

	if ( self.mode == "new" ) then
		MacroFrameText:Hide();
		MacroPopupButton_SelectTexture(1);
	end
	
	-- Disable Buttons
	MacroEditButton:Disable();
	MacroDeleteButton:Disable();
	MacroNewButton:Disable();
	MacroFrameTab1:Disable();
	MacroFrameTab2:Disable();
	
end

function MacroPopupFrame_OnHide(self)
	if ( self.mode == "new" ) then
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
	if ( numMacros < MacroFrame.macroMax ) then
		MacroNewButton:Enable();
	end
	-- Enable tabs
	PanelTemplates_UpdateTabs(MacroFrame);
	MACRO_ICON_FILENAMES = nil;
	collectgarbage();
end

--[[
RefreshPlayerSpellIconInfo() builds the table MACRO_ICON_FILENAMES with known spells followed by all icons (could be repeats)
]]
function RefreshPlayerSpellIconInfo()

	MACRO_ICON_FILENAMES = {};
	MACRO_ICON_FILENAMES[1] = "INV_MISC_QUESTIONMARK";
	local index = 2;
	local numFlyouts = 0;

	for i = 1, GetNumSpellTabs() do
		local tab, tabTex, offset, numSpells, _ = GetSpellTabInfo(i);
		offset = offset + 1;
		local tabEnd = offset + numSpells;
		for j = offset, tabEnd - 1 do
			--to get spell info by slot, you have to pass in a pet argument
			local spellType, ID = GetSpellBookItemInfo(j, "player"); 
			if (spellType ~= "FUTURESPELL") then
				local spellTexture = strupper(GetSpellBookItemTexture(j, "player"));
				if ( not string.match( spellTexture, "INTERFACE\\BUTTONS\\") ) then
					MACRO_ICON_FILENAMES[index] = gsub( spellTexture, "INTERFACE\\ICONS\\", "");
					index = index + 1;
				end
			end
			if (spellType == "FLYOUT") then
				local _, _, numSlots, isKnown = GetFlyoutInfo(ID);
				if (isKnown and numSlots > 0) then
					for k = 1, numSlots do 
						local spellID, overrideSpellID, isKnown = GetFlyoutSlotInfo(ID, k)
						if (isKnown) then
							MACRO_ICON_FILENAMES[index] = gsub( strupper(GetSpellTexture(spellID)), "INTERFACE\\ICONS\\", ""); 
							index = index + 1;
						end
					end
				end
			end
		end
	end
	GetMacroIcons( MACRO_ICON_FILENAMES );
	GetMacroItemIcons( MACRO_ICON_FILENAMES );
end

function GetSpellorMacroIconInfo(index)
	if ( not index ) then
		return;
	end
	return MACRO_ICON_FILENAMES[index];
end

function MacroPopupFrame_Update(self)
	self = self or MacroPopupFrame;
	local numMacroIcons = #MACRO_ICON_FILENAMES;
	local macroPopupIcon, macroPopupButton;
	local macroPopupOffset = FauxScrollFrame_GetOffset(MacroPopupScrollFrame);
	local index;
	
	-- Determine whether we're creating a new macro or editing an existing one
	if ( self.mode == "new" ) then
		MacroPopupEditBox:SetText("");
	elseif ( self.mode == "edit" ) then
		local name, _, body = GetMacroInfo(MacroFrame.selectedMacro);
		MacroPopupEditBox:SetText(name);
	end
	
	-- Icon list
	local texture;
	for i=1, NUM_MACRO_ICONS_SHOWN do
		macroPopupIcon = _G["MacroPopupButton"..i.."Icon"];
		macroPopupButton = _G["MacroPopupButton"..i];
		index = (macroPopupOffset * NUM_ICONS_PER_ROW) + i;
		texture = GetSpellorMacroIconInfo(index);
		if ( index <= numMacroIcons and texture ) then
			macroPopupIcon:SetTexture("INTERFACE\\ICONS\\"..texture);
			macroPopupButton:Show();
		else
			macroPopupIcon:SetTexture("");
			macroPopupButton:Hide();
		end
		if ( MacroPopupFrame.selectedIcon and (index == MacroPopupFrame.selectedIcon) ) then
			macroPopupButton:SetChecked(1);
		elseif ( MacroPopupFrame.selectedIconTexture ==  texture ) then
			macroPopupButton:SetChecked(1);
		else
			macroPopupButton:SetChecked(nil);
		end
	end
	
	-- Scrollbar stuff
	FauxScrollFrame_Update(MacroPopupScrollFrame, ceil(numMacroIcons / NUM_ICONS_PER_ROW) , NUM_ICON_ROWS, MACRO_ICON_ROW_HEIGHT );
end

function MacroPopupFrame_CancelEdit()
	MacroPopupFrame:Hide();
	MacroFrame_Update();
	MacroPopupFrame.selectedIcon = nil;
end

function MacroPopupOkayButton_Update()
	local text = MacroPopupEditBox:GetText();
	text = string.gsub(text, "\"", "");
	if ( (strlen(text) > 0) and MacroPopupFrame.selectedIcon ) then
		MacroPopupOkayButton:Enable();
	else
		MacroPopupOkayButton:Disable();
	end
	if ( MacroPopupFrame.mode == "edit" and (strlen(text) > 0) ) then
		MacroPopupOkayButton:Enable();
	end
end

function MacroPopupButton_SelectTexture(selectedIcon)
	MacroPopupFrame.selectedIcon = selectedIcon;
	-- Clear out selected texture
	MacroPopupFrame.selectedIconTexture = nil;
	MacroFrameSelectedMacroButtonIcon:SetTexture("INTERFACE\\ICONS\\"..GetSpellorMacroIconInfo(MacroPopupFrame.selectedIcon));
	MacroPopupOkayButton_Update();
	local mode = MacroPopupFrame.mode;
	MacroPopupFrame.mode = nil;
	MacroPopupFrame_Update(MacroPopupFrame);
	MacroPopupFrame.mode = mode;
end

function MacroPopupButton_OnClick(self, button)
	MacroPopupButton_SelectTexture(self:GetID() + (FauxScrollFrame_GetOffset(MacroPopupScrollFrame) * NUM_ICONS_PER_ROW));
end

function MacroPopupOkayButton_OnClick(self, button)
	local index = 1
	local iconTexture = GetSpellorMacroIconInfo(MacroPopupFrame.selectedIcon);
	local text = MacroPopupEditBox:GetText();
	text = string.gsub(text, "\"", "");
	if ( MacroPopupFrame.mode == "new" ) then
		index = CreateMacro(text, iconTexture, nil, (MacroFrame.macroBase > 0));
	elseif ( MacroPopupFrame.mode == "edit" ) then
		index = EditMacro(MacroFrame.selectedMacro, text, iconTexture);
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
