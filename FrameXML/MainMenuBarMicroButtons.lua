function LoadMicroButtonTextures(self, name)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	local prefix = "Interface\\Buttons\\UI-MicroButton-";
	self:SetNormalTexture(prefix..name.."-Up");
	self:SetPushedTexture(prefix..name.."-Down");
	self:SetDisabledTexture(prefix..name.."-Disabled");
	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight");
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
		or ( InterfaceOptionsFrame:IsShown()) 
		or ( KeyBindingFrame and KeyBindingFrame:IsShown()) 
		or ( MacroFrame and MacroFrame:IsShown()) ) then
		MainMenuMicroButton:SetButtonState("PUSHED", 1);
		MainMenuMicroButton_SetPushed();
	else
		MainMenuMicroButton:SetButtonState("NORMAL");
		MainMenuMicroButton_SetNormal();
	end

	if ( PVPParentFrame:IsShown() ) then
		PVPMicroButton:SetButtonState("PUSHED", 1);
		PVPMicroButton_SetPushed();
	else
		PVPMicroButton:SetButtonState("NORMAL");
		PVPMicroButton_SetNormal();
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
	
	if ( AchievementFrame and AchievementFrame:IsShown() ) then
		AchievementMicroButton:SetButtonState("PUSHED", 1);
	else
		AchievementMicroButton:SetButtonState("NORMAL");
	end

	-- Keyring microbutton
	if ( IsBagOpen(KEYRING_CONTAINER) ) then
		KeyRingButton:SetButtonState("PUSHED", 1);
	else
		KeyRingButton:SetButtonState("NORMAL");
	end
end

function AchievementMicroButton_Update()
	if ( not CanShowAchievementUI() ) then
		AchievementMicroButton:Hide();
		QuestLogMicroButton:SetPoint("BOTTOMLEFT", AchievementMicroButton, "BOTTOMLEFT", 0, 0);
	else
		AchievementMicroButton:Show();
		QuestLogMicroButton:SetPoint("BOTTOMLEFT", AchievementMicroButton, "BOTTOMRIGHT", -3, 0);
	end
end

function CharacterMicroButton_OnLoad(self)
	SetPortraitTexture(MicroButtonPortrait, "player");
	self:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up");
	self:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down");
	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("UPDATE_BINDINGS");
	self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
	self.newbieText = NEWBIE_TOOLTIP_CHARACTER;
end

function CharacterMicroButton_OnEvent(self, event, ...)
	if ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...;
		if ( unit == "player" ) then
			SetPortraitTexture(MicroButtonPortrait, unit);
		end
		return;
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
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

function MainMenuMicroButton_SetPushed()
	MainMenuMicroButton:SetButtonState("PUSHED", 1);
	MainMenuBarPerformanceBar:SetPoint("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 9, -36);
end

function MainMenuMicroButton_SetNormal()
	MainMenuMicroButton:SetButtonState("NORMAL");
	MainMenuBarPerformanceBar:SetPoint("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 10, -34);
end

--Talent button specific functions
function TalentMicroButton_OnEvent(self, event, ...)
	if ( event == "PLAYER_LEVEL_UP" ) then
		UpdateTalentButton();
		if ( not CharacterFrame:IsShown() ) then
			SetButtonPulse(self, 60, 1);
		end
	elseif ( event == "UNIT_LEVEL" or event == "PLAYER_ENTERING_WORLD" ) then
		UpdateTalentButton();
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText =  MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS");
	end
end

function UpdateTalentButton()
	if ( UnitLevel("player") < 10 ) then
		TalentMicroButton:Hide();
		AchievementMicroButton:SetPoint("BOTTOMLEFT", "TalentMicroButton", "BOTTOMLEFT", 0, 0);
	else	
		TalentMicroButton:Show();
		AchievementMicroButton:SetPoint("BOTTOMLEFT", "TalentMicroButton", "BOTTOMRIGHT", -2, 0);
	end
end