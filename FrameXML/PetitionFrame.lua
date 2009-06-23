
function PetitionFrame_Update(self)
	if ( CanSignPetition() ) then
		PetitionFrameSignButton:Enable();
	else
		PetitionFrameSignButton:Disable();
	end
	local petitionType, title, bodyText, maxSignatures, originatorName, isOriginator, minSignatures = GetPetitionInfo();
	if ( isOriginator ) then
		PetitionFrameRequestButton:Show();
		PetitionFrameSignButton:Hide();
		if ( petitionType == "guild" ) then
			PetitionFrameInstructions:SetText(GUILD_PETITION_LEADER_INSTRUCTIONS);
		elseif ( petitionType == "arena" ) then
			PetitionFrameInstructions:SetText(ARENA_PETITION_LEADER_INSTRUCTIONS);
		end
		PetitionFrameRenameButton:Show();
	else	
		PetitionFrameRequestButton:Hide();
		PetitionFrameSignButton:Show();
		if ( petitionType == "guild" ) then
			PetitionFrameInstructions:SetText(GUILD_PETITION_MEMBER_INSTRUCTIONS);
		elseif ( petitionType == "arena" ) then
			PetitionFrameInstructions:SetText(ARENA_PETITION_MEMBER_INSTRUCTIONS);
		end
		PetitionFrameRenameButton:Hide();
	end
	if ( petitionType == "guild" ) then
		PetitionFrameNpcNameText:SetFormattedText(GUILD_CHARTER_TEMPLATE, title);
		PetitionFrameCharterTitle:SetText(GUILD_NAME);
		PetitionFrameCharterName:SetText(title);
		PetitionFrameMasterTitle:SetText(GUILD_RANK0_DESC);
		PetitionFrameMasterName:SetText(originatorName);
		PetitionFrameRenameButton:SetText(RENAME_GUILD);
	elseif ( petitionType == "arena" ) then
		PetitionFrameNpcNameText:SetFormattedText(ARENA_CHARTER_TEMPLATE, title);
		PetitionFrameCharterTitle:SetText(ARENA_TEAM);
		PetitionFrameCharterName:SetText(title..", "..format(PVP_TEAMSIZE, minSignatures + 1, minSignatures + 1));
		PetitionFrameMasterTitle:SetText(ARENA_TEAM_CAPTAIN);
		PetitionFrameMasterName:SetText(originatorName);
		PetitionFrameRenameButton:SetText(RENAME_ARENA_TEAM);
	else
		PetitionFrameNpcNameText:SetText("Petition");
	end
	local memberText;
	local numNames = GetNumPetitionNames();
	if ( self.minSignatures ) then
		for i=1, self.minSignatures, 1 do
			memberText = _G["PetitionFrameMemberName"..i];
			memberText:Hide();
		end
	end
	for i=1, minSignatures do
		memberText = _G["PetitionFrameMemberName"..i];
		if ( i <= numNames ) then
			memberText:SetText(GetPetitionNameInfo(i));
		else			
			memberText:SetText(NOT_YET_SIGNED);
		end
		if ( i == minSignatures ) then
			PetitionFrameInstructions:SetPoint(	"TOPLEFT", memberText:GetName(), "BOTTOMLEFT", 0, -10);
		end
		memberText:Show();
	end
	self.minSignatures = minSignatures;
	self.petitionType = petitionType;
	if ( numNames >= maxSignatures ) then
		PetitionFrameRequestButton:Disable();
	else
		PetitionFrameRequestButton:Enable();
	end
end

