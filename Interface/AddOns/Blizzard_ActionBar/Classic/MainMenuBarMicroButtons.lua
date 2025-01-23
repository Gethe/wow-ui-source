MICRO_BUTTONS = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"QuestLogMicroButton",
	"SocialsMicroButton",
	"GuildMicroButton",
	"WorldMapMicroButton",
	"MainMenuMicroButton",
	"HelpMicroButton",
}

function MoveMicroButtons(anchor, anchorTo, relAnchor, x, y, isStacked)
	CharacterMicroButton:ClearAllPoints();
	CharacterMicroButton:SetPoint(anchor, anchorTo, relAnchor, x, y);
	UpdateMicroButtons();
end

function UpdateMicroButtons()
	local playerLevel = UnitLevel("player");
	local factionGroup = UnitFactionGroup("player");


	if ( CharacterFrame and CharacterFrame:IsShown() ) then
		CharacterMicroButton:SetButtonState("PUSHED", true);
		CharacterMicroButton_SetPushed();
	else
		CharacterMicroButton:SetButtonState("NORMAL");
		CharacterMicroButton_SetNormal();
	end

	if ( SpellBookFrame and SpellBookFrame:IsShown() ) then
		SpellbookMicroButton:SetButtonState("PUSHED", true);
	else
		SpellbookMicroButton:SetButtonState("NORMAL");
	end

	if ( PlayerTalentFrame and PlayerTalentFrame:IsShown() ) then
		TalentMicroButton:SetButtonState("PUSHED", true);
	else
		if ( playerLevel < SHOW_SPEC_LEVEL ) then
			TalentMicroButton:Hide();
			QuestLogMicroButton:SetPoint("BOTTOMLEFT", "TalentMicroButton", "BOTTOMLEFT", 0, 0);
		else
			TalentMicroButton:Show();
			QuestLogMicroButton:SetPoint("BOTTOMLEFT", "TalentMicroButton", "BOTTOMRIGHT", -3, 0);
		end
		TalentMicroButton:SetButtonState("NORMAL");
	end

	if ( QuestLogFrame and QuestLogFrame:IsVisible() ) then
		QuestLogMicroButton:SetButtonState("PUSHED", 1);
	else
		QuestLogMicroButton:SetButtonState("NORMAL");
	end

	SocialsMicroButton:UpdateMicroButton();

	GuildMicroButton:UpdateMicroButton();

	if (  WorldMapFrame and WorldMapFrame:IsShown() ) then
		WorldMapMicroButton:SetButtonState("PUSHED", true);
	else
		WorldMapMicroButton:SetButtonState("NORMAL");
	end

	if ( ( GameMenuFrame and GameMenuFrame:IsShown() )
		or ( KeyBindingFrame and KeyBindingFrame:IsShown())
		or ( MacroFrame and MacroFrame:IsShown()) ) then
		MainMenuMicroButton:SetButtonState("PUSHED", true);
		MainMenuMicroButton_SetPushed();
	else
		MainMenuMicroButton:SetButtonState("NORMAL");
		MainMenuMicroButton_SetNormal();
	end

	if ( HelpFrame and HelpFrame:IsVisible() ) then
		HelpMicroButton:SetButtonState("PUSHED", 1);
	else
		HelpMicroButton:SetButtonState("NORMAL");
	end

	-- Keyring microbutton
	if (KeyRingButton) then
		if ( IsBagOpen(KEYRING_CONTAINER) ) then
			KeyRingButton:SetButtonState("PUSHED", 1);
		else
			KeyRingButton:SetButtonState("NORMAL");
		end
	end
end

function SocialsMicroButton_UpdateNotificationIcon(self)
	if CommunitiesFrame_IsEnabled() and self:IsEnabled() then
		--self.NotificationOverlay:SetShown(HasUnseenCommunityInvitations() or CommunitiesUtil.DoesAnyCommunityHaveUnreadMessages());
		if ( not C_SocialRestrictions.IsChatDisabled() and (HasUnseenCommunityInvitations() or CommunitiesUtil.DoesAnyCommunityHaveUnreadMessages())) then
			if ((not CommunitiesFrame or not CommunitiesFrame:IsShown()) and not FriendsFrame:IsShown()) then
				self:LockHighlight();
			end
		end
	else
		--self.NotificationOverlay:SetShown(false);
	end
end
