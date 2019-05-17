NUM_MACROS_PER_ROW = 6;
NUM_ICONS_PER_ROW = 10;
NUM_ICON_ROWS = 9;
NUM_MACRO_ICONS_SHOWN = NUM_ICONS_PER_ROW * NUM_ICON_ROWS;
MACRO_ICON_ROW_HEIGHT = 36;
local MACRO_ICON_FILENAMES = nil;

UIPanelWindows["MacroFrame"] = { area = "left", pushable = 1, whileDead = 1, width = PANEL_DEFAULT_WIDTH };

StaticPopupDialogs["CONFIRM_DELETE_SELECTED_MACRO"] = {
	text = CONFIRM_DELETE_MACRO,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		MacroFrame_DeleteMacro()
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1
};

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
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	UpdateMicroButtons();
	if ( not self.iconArrayBuilt ) then
		BuildIconArray(MacroPopupFrame, "MacroPopupButton", "MacroPopupButtonTemplate", NUM_ICONS_PER_ROW, NUM_ICON_ROWS);
		self.iconArrayBuilt = true;
	end
end

function MacroFrame_OnHide(self)
	MacroPopupFrame:Hide();
	MacroFrame_SaveMacro();
	--SaveMacros();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	UpdateMicroButtons();
	MACRO_ICON_FILENAMES = nil;
	collectgarbage();
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
					macroButton:SetChecked(true);
					MacroFrameSelectedMacroName:SetText(name);
					MacroFrameText:SetText(body);
					MacroFrameSelectedMacroButton:SetID(i);
					MacroFrameSelectedMacroButtonIcon:SetTexture(texture);
					if (type(texture) == "number") then
						MacroPopupFrame.selectedIconTexture = texture;
					elseif (type(texture) == "string") then
						MacroPopupFrame.selectedIconTexture = gsub( strupper(texture), "INTERFACE\\ICONS\\", "");
					else
						MacroPopupFrame.selectedIconTexture = nil;
					end
				else
					macroButton:SetChecked(false);
				end
			else
				macroButton:SetChecked(false);
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
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	MacroFrame_SaveMacro();
	MacroFrame_Update();
	MacroPopupFrame:Hide();
	MacroFrameText:ClearFocus();
end

function MacroFrameCancelButton_OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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

local MACRO_POPUP_FRAME_MINIMUM_PADDING = 40;
function MacroPopupFrame_AdjustAnchors(self)
	local rightSpace = GetScreenWidth() - MacroFrame:GetRight();
	self.parentLeft = MacroFrame:GetLeft();
	local leftSpace = self.parentLeft;
	
	self:ClearAllPoints();
	if ( leftSpace >= rightSpace ) then
		if ( leftSpace < self:GetWidth() + MACRO_POPUP_FRAME_MINIMUM_PADDING ) then
			self:SetPoint("TOPRIGHT", MacroFrame, "TOPLEFT", self:GetWidth() + MACRO_POPUP_FRAME_MINIMUM_PADDING - leftSpace, 0);
		else
			self:SetPoint("TOPRIGHT", MacroFrame, "TOPLEFT", -5, 0);
		end
	else
		if ( rightSpace < self:GetWidth() + MACRO_POPUP_FRAME_MINIMUM_PADDING ) then
			self:SetPoint("TOPLEFT", MacroFrame, "TOPRIGHT", rightSpace - (self:GetWidth() + MACRO_POPUP_FRAME_MINIMUM_PADDING), 0);
		else
			self:SetPoint("TOPLEFT", MacroFrame, "TOPRIGHT", 0, 0);
		end
	end
end
	
function MacroPopupFrame_OnLoad(self)
	MacroPopupScrollFrame.ScrollBar.scrollStep = 8 * MACRO_ICON_ROW_HEIGHT;
end

function MacroPopupFrame_OnShow(self)
	MacroPopupFrame_AdjustAnchors(self);
	MacroPopupEditBox:SetFocus();

	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
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

function MacroPopupFrame_OnUpdate(self)
	if (self.parentLeft ~= MacroFrame:GetLeft()) then
		MacroPopupFrame_AdjustAnchors(self);
	end
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
end

--[[
RefreshPlayerSpellIconInfo() builds the table MACRO_ICON_FILENAMES with known spells followed by all icons (could be repeats)
]]
function RefreshPlayerSpellIconInfo()
	if ( MACRO_ICON_FILENAMES ) then
		return;
	end
	
	-- We need to avoid adding duplicate spellIDs from the spellbook tabs for your other specs.
	local activeIcons = {};
	
	--[[for i = 1, GetNumSpellTabs() do
		local tab, tabTex, offset, numSpells, _ = GetSpellTabInfo(i);
		offset = offset + 1;
		local tabEnd = offset + numSpells;
		for j = offset, tabEnd - 1 do
			--to get spell info by slot, you have to pass in a pet argument
			local spellType, ID = GetSpellBookItemInfo(j, "player"); 
			if (spellType ~= "FUTURESPELL") then
				local fileID = GetSpellBookItemTexture(j, "player");
				if (fileID) then
					activeIcons[fileID] = true;
				end
			end
			if (spellType == "FLYOUT") then
				local _, _, numSlots, isKnown = GetFlyoutInfo(ID);
				if (isKnown and numSlots > 0) then
					for k = 1, numSlots do 
						local spellID, overrideSpellID, isKnown = GetFlyoutSlotInfo(ID, k)
						if (isKnown) then
							local fileID = GetSpellTexture(spellID);
							if (fileID) then
								activeIcons[fileID] = true;
							end
						end
					end
				end
			end
		end
	end]]

	MACRO_ICON_FILENAMES = { "INV_MISC_QUESTIONMARK" };
	for fileDataID in pairs(activeIcons) do
		MACRO_ICON_FILENAMES[#MACRO_ICON_FILENAMES + 1] = fileDataID;
	end

	GetLooseMacroIcons( MACRO_ICON_FILENAMES );
	-- GetLooseMacroItemIcons( MACRO_ICON_FILENAMES );
	GetMacroIcons( MACRO_ICON_FILENAMES );
	-- GetMacroItemIcons( MACRO_ICON_FILENAMES );
end

function GetSpellorMacroIconInfo(index)
	if ( not index ) then
		return;
	end
	local texture = MACRO_ICON_FILENAMES[index];
	local texnum = tonumber(texture);
	if (texnum ~= nil) then
		return texnum;
	else
		return texture;
	end
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
			if(type(texture) == "number") then
				macroPopupIcon:SetTexture(texture);
			else
				macroPopupIcon:SetTexture("INTERFACE\\ICONS\\"..texture);
			end		
			macroPopupButton:Show();
		else
			macroPopupIcon:SetTexture("");
			macroPopupButton:Hide();
		end
		if ( MacroPopupFrame.selectedIcon and (index == MacroPopupFrame.selectedIcon) ) then
			macroPopupButton:SetChecked(true);
		elseif ( MacroPopupFrame.selectedIconTexture == texture ) then
			macroPopupButton:SetChecked(true);
		else
			macroPopupButton:SetChecked(false);
		end
	end
	
	-- Scrollbar stuff
	FauxScrollFrame_Update(MacroPopupScrollFrame, ceil(numMacroIcons / NUM_ICONS_PER_ROW) + 1, NUM_ICON_ROWS, MACRO_ICON_ROW_HEIGHT );
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
		MacroPopupFrame.BorderBox.OkayButton:Enable();
	else
		MacroPopupFrame.BorderBox.OkayButton:Disable();
	end
	if ( MacroPopupFrame.mode == "edit" and (strlen(text) > 0) ) then
		MacroPopupFrame.BorderBox.OkayButton:Enable();
	end
end

function MacroPopupButton_SelectTexture(selectedIcon)
	MacroPopupFrame.selectedIcon = selectedIcon;
	-- Clear out selected texture
	MacroPopupFrame.selectedIconTexture = nil;
	local curMacroInfo = GetSpellorMacroIconInfo(MacroPopupFrame.selectedIcon);
	if(type(curMacroInfo) == "number") then
		MacroFrameSelectedMacroButtonIcon:SetTexture(curMacroInfo);
	else
		MacroFrameSelectedMacroButtonIcon:SetTexture("INTERFACE\\ICONS\\"..curMacroInfo);
	end	
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
