function LoadMicroButtonTextures(name)
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	this:RegisterEvent("UPDATE_BINDINGS");
	local prefix = "Interface\\Buttons\\UI-MicroButton-";
	this:SetNormalTexture(prefix..name.."-Up");
	this:SetPushedTexture(prefix..name.."-Down");
	this:SetDisabledTexture(prefix..name.."-Disabled");
	this:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight");
end

function MicroButtonTooltipText(text, action)
	if ( GetBindingKey(action) ) then
		return text.." "..NORMAL_FONT_COLOR_CODE.."("..GetBindingText(GetBindingKey(action), "KEY_")..")"..FONT_COLOR_CODE_CLOSE;
	else
		return text;
	end
	
end

function UpdateMicroButtons()
	if ( CharacterFrame:IsShown() ) then
		CharacterMicroButton:SetButtonState("PUSHED", 1);
		CharacterMicroButton_SetPushed();
	else
		CharacterMicroButton:SetButtonState("NORMAL");
		CharacterMicroButton_SetNormal();
	end
	
	if ( SpellBookFrame:IsShown() ) then
		SpellbookMicroButton:SetButtonState("PUSHED", 1);
	else
		SpellbookMicroButton:SetButtonState("NORMAL");
	end

	if ( PlayerTalentFrame and PlayerTalentFrame:IsShown() ) then
		TalentMicroButton:SetButtonState("PUSHED", 1);
	else
		TalentMicroButton:SetButtonState("NORMAL");
	end

	if ( QuestLogFrame:IsShown() ) then
		QuestLogMicroButton:SetButtonState("PUSHED", 1);
	else
		QuestLogMicroButton:SetButtonState("NORMAL");
	end
	
	if ( ( GameMenuFrame:IsShown() ) 
		or ( OptionsFrame:IsShown()) 
		or ( AudioOptionsFrame:IsShown()) 
		or ( InterfaceOptionsFrame and InterfaceOptionsFrame:IsShown()) 
		or ( KeyBindingFrame and KeyBindingFrame:IsShown()) 
		or ( MacroFrame and MacroFrame:IsShown()) ) then
		MainMenuMicroButton:SetButtonState("PUSHED", 1);
	else
		MainMenuMicroButton:SetButtonState("NORMAL");
	end

	if ( FriendsFrame:IsShown() ) then
		SocialsMicroButton:SetButtonState("PUSHED", 1);
	else
		SocialsMicroButton:SetButtonState("NORMAL");
	end

	if ( LFGParentFrame:IsShown() ) then
		LFGMicroButton:SetButtonState("PUSHED", 1);
	else
		LFGMicroButton:SetButtonState("NORMAL");
	end

	if ( HelpFrame:IsShown() ) then
		HelpMicroButton:SetButtonState("PUSHED", 1);
	else
		HelpMicroButton:SetButtonState("NORMAL");
	end
	
	-- Keyring microbutton
	if ( IsBagOpen(KEYRING_CONTAINER) ) then
		KeyRingButton:SetButtonState("PUSHED", 1);
	else
		KeyRingButton:SetButtonState("NORMAL");
	end
end

function CharacterMicroButton_OnLoad()
	SetPortraitTexture(MicroButtonPortrait, "player");
	this:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up");
	this:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down");
	this:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight");
	this:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	this:RegisterEvent("UPDATE_BINDINGS");
	this:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	this.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
	this.newbieText = NEWBIE_TOOLTIP_CHARACTER;
end

function CharacterMicroButton_OnEvent()
	if ( event == "UNIT_PORTRAIT_UPDATE" ) then
		if ( arg1 == "player" ) then
			SetPortraitTexture(MicroButtonPortrait, arg1);
		end
		return;
	elseif ( event == "UPDATE_BINDINGS" ) then
		this.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
	end
end

function CharacterMicroButton_SetPushed()
	MicroButtonPortrait:SetTexCoord(0.2666, 0.8666, 0, 0.8333);
	MicroButtonPortrait:SetAlpha(0.5);
end

function CharacterMicroButton_SetNormal()
	MicroButtonPortrait:SetTexCoord(0.2, 0.8, 0.0666, 0.9);
	MicroButtonPortrait:SetAlpha(1.0);
end

--Talent button specific functions
function TalentMicroButton_OnEvent()
	if ( event == "PLAYER_LEVEL_UP" ) then
		UpdateTalentButton();
		if ( not CharacterFrame:IsShown() ) then
			SetButtonPulse(this, 60, 1);
		end
	elseif ( event == "UNIT_LEVEL" or event == "PLAYER_ENTERING_WORLD" ) then
		UpdateTalentButton();
	elseif ( event == "UPDATE_BINDINGS" ) then
		this.tooltipText =  MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS");
	end
end

function UpdateTalentButton()
	if ( UnitLevel("player") < 10 ) then
		TalentMicroButton:Hide();
		QuestLogMicroButton:SetPoint("BOTTOMLEFT", "TalentMicroButton", "BOTTOMLEFT", 0, 0);
	else	
		TalentMicroButton:Show();
		QuestLogMicroButton:SetPoint("BOTTOMLEFT", "TalentMicroButton", "BOTTOMRIGHT", -2, 0);
	end
end