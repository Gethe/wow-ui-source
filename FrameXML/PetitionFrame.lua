MAX_PETITION_SIGNATURES = 9;

function PetitionFrame_Update()
	if ( CanSignPetition() ) then
		PetitionFrameSignButton:Enable();
	else
		PetitionFrameSignButton:Disable();
	end
	local petitionType, title, bodyText, maxSignatures, originatorName, isOriginator = GetPetitionInfo();
	if ( isOriginator ) then
		PetitionFrameRequestButton:Show();
		PetitionFrameSignButton:Hide();
		PetitionFrameInstructions:SetText(GUILD_PETITION_LEADER_INSTRUCTIONS);
	else	
		PetitionFrameRequestButton:Hide();
		PetitionFrameSignButton:Show();
		PetitionFrameInstructions:SetText(GUILD_PETITION_MEMBER_INSTRUCTIONS);
	end
	if ( petitionType == "charter" ) then
		PetitionFrameNpcNameText:SetText(format(TEXT(GUILD_CHARTER_TEMPLATE), title));
		PetitionFrameCharterName:SetText(title);
		PetitionFrameMasterName:SetText(originatorName);
	else
		PetitionFrameNpcNameText:SetText("Petition");
	end
	local memberText;
	local numNames = GetNumPetitionNames();
	for i=1, MAX_PETITION_SIGNATURES do
		memberText = getglobal("PetitionFrameMemberName"..i);
		if ( i <= numNames ) then
			memberText:SetText(GetPetitionNameInfo(i));
		else
			memberText:SetText(NOT_YET_SIGNED);
		end
	end
	if ( numNames >= maxSignatures ) then
		PetitionFrameRequestButton:Disable();
	else
		PetitionFrameRequestButton:Enable();
	end
end