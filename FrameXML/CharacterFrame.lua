CHARACTERFRAME_SUBFRAMES = { "PaperDollFrame", "PetPaperDollFrame", "SkillFrame", "ReputationFrame", "PVPFrame" };

function ToggleCharacter(tab)
	-- Needs to be an "IsVisible" check
	if ( tab == "PetPaperDollFrame" and not HasPetUI() and not PetPaperDollFrame:IsVisible() ) then
		return;
	end
	
	local subFrame = getglobal(tab);
	if ( subFrame ) then
		PanelTemplates_SetTab(CharacterFrame, subFrame:GetID());
		if ( CharacterFrame:IsShown() ) then
			if ( subFrame:IsShown() ) then
				HideUIPanel(CharacterFrame);	
			else
				PlaySound("igCharacterInfoTab");
				CharacterFrame_ShowSubFrame(tab);
			end
		else
			ShowUIPanel(CharacterFrame);
			CharacterFrame_ShowSubFrame(tab);
		end
	end
end

function CharacterFrame_ShowSubFrame(frameName)
	for index, value in pairs(CHARACTERFRAME_SUBFRAMES) do
		if ( value == frameName ) then
			getglobal(value):Show()
		else
			getglobal(value):Hide();	
		end	
	end 
end

function CharacterFrameTab_OnClick()
	if ( this:GetName() == "CharacterFrameTab1" ) then
		ToggleCharacter("PaperDollFrame");
	elseif ( this:GetName() == "CharacterFrameTab2" ) then
		ToggleCharacter("PetPaperDollFrame");
	elseif ( this:GetName() == "CharacterFrameTab3" ) then
		ToggleCharacter("ReputationFrame");	
	elseif ( this:GetName() == "CharacterFrameTab4" ) then
		ToggleCharacter("SkillFrame");	
	elseif ( this:GetName() == "CharacterFrameTab5" ) then
		ToggleCharacter("PVPFrame");	
	end
	PlaySound("igCharacterInfoTab");
end

function CharacterFrame_OnLoad()
	this:RegisterEvent("UNIT_NAME_UPDATE");
	this:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	this:RegisterEvent("PLAYER_PVP_RANK_CHANGED");

	SetTextStatusBarTextPrefix(PlayerFrameHealthBar, HEALTH);
	SetTextStatusBarTextPrefix(PlayerFrameManaBar, MANA);
	SetTextStatusBarTextPrefix(MainMenuExpBar, XP);
	TextStatusBar_UpdateTextString(MainMenuExpBar);
	-- Tab Handling code
	PanelTemplates_SetNumTabs(this, 5);
	PanelTemplates_SetTab(this, 1);
end

function CharacterFrame_OnEvent(event)
	if ( not this:IsShown() ) then
		return;
	end
	if ( event == "UNIT_PORTRAIT_UPDATE" ) then
		if ( arg1 == "player" ) then
			SetPortraitTexture(CharacterFramePortrait, arg1);
		end
		return;
	elseif ( event == "UNIT_NAME_UPDATE" ) then
		if ( arg1 == "player" ) then
			CharacterNameText:SetText(UnitPVPName(arg1));
		end
		return;
	elseif ( event == "PLAYER_PVP_RANK_CHANGED" ) then
		CharacterNameText:SetText(UnitPVPName("player"));
	end
end

function CharacterFrame_OnShow()
	PlaySound("igCharacterInfoOpen");
	SetPortraitTexture(CharacterFramePortrait, "player");
	CharacterNameText:SetText(UnitPVPName("player"));
	UpdateMicroButtons();
	ShowTextStatusBarText(PlayerFrameHealthBar);
	ShowTextStatusBarText(PlayerFrameManaBar);
	ShowTextStatusBarText(MainMenuExpBar);
	ShowTextStatusBarText(PetFrameHealthBar);
	ShowTextStatusBarText(PetFrameManaBar);
	ShowWatchedReputationBarText();
end

function CharacterFrame_OnHide()
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();
	HideTextStatusBarText(PlayerFrameHealthBar);
	HideTextStatusBarText(PlayerFrameManaBar);
	HideTextStatusBarText(MainMenuExpBar);
	HideTextStatusBarText(PetFrameHealthBar);
	HideTextStatusBarText(PetFrameManaBar);
	HideWatchedReputationBarText();
end
