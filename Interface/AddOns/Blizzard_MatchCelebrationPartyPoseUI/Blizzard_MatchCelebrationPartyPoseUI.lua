MatchCelebrationPartyPoseMixin = CreateFromMixins(PartyPoseMixin);

function MatchCelebrationPartyPoseMixin:LoadPartyPose(partyPoseData, forceUpdate)
	PartyPoseMixin.LoadPartyPose(self, partyPoseData, forceUpdate);

	local showExtraButton = C_PartyPose.HasExtraAction(partyPoseData.partyPoseInfo.partyPoseID);
	if showExtraButton then
		self.ButtonContainer.ExtraButton:Show(); 
		self.ButtonContainer.ExtraButton:SetText(partyPoseData.partyPoseInfo.extraButtonText or CLOSE);
	else
		self.ButtonContainer.ExtraButton:Hide(); 
	end

	local hideLeaveButton = FlagsUtil.IsSet(partyPoseData.partyPoseInfo.flags, Enum.PartyPoseFlags.HideLeaveInstanceButton);
	self.ButtonContainer.LeaveButton:SetShown(not hideLeaveButton);
end

function MatchCelebrationPartyPoseMixin:SetLeaveButtonText()
	self.ButtonContainer.LeaveButton:SetText(INSTANCE_LEAVE);
end

function MatchCelebrationPartyPoseMixin:GetPartyPoseDataFromPartyPoseID(partyPoseID, winner)
	local partyPoseData = PartyPoseMixin.GetPartyPoseDataFromPartyPoseID(self, partyPoseID, winner);

	local textureKit = partyPoseData.partyPoseInfo.uiTextureKit or "";
	local titleBGAtlas = GetFinalNameFromTextureKit("%s-header", textureKit); 
	local modelSceneBackgroundAtlas = GetFinalNameFromTextureKit("%s-background", textureKit);
	local topperAtlas = GetFinalNameFromTextureKit("%s-topper", textureKit); 

	partyPoseData.themeData = { 
		TitleBG = C_Texture.GetAtlasInfo(titleBGAtlas) and titleBGAtlas or "scoreboard-header-alliance",
		Topper =  C_Texture.GetAtlasInfo(topperAtlas) and topperAtlas or nil;
		topperOffset = -45,
		nineSliceLayout = "UniqueCornersLayout",
		nineSliceTextureKit = textureKit,
		partyCategory = LE_PARTY_CATEGORY_HOME,
	}
	partyPoseData.modelSceneData = {
		ModelSceneBG =  C_Texture.GetAtlasInfo(modelSceneBackgroundAtlas) and modelSceneBackgroundAtlas or "scoreboard-background-voidzone-arathi",
	}

	self.Border.Center:Hide(); --Since we have a background displaying over this, we don't want it to show
	return partyPoseData;
end

function MatchCelebrationPartyPoseMixin:LoadPartyPose(partyPoseData, forceUpdate)
	PartyPoseMixin.LoadPartyPose(self, partyPoseData, forceUpdate);

	self.ExtraButton:SetText(self.partyPoseData.partyPoseInfo.extraButtonText or "");
	self.ExtraButton:SetEnabled(C_PartyPose.HasExtraAction(self.partyPoseData.partyPoseInfo.partyPoseID)); 
	self.ExtraButton:Show();
end

MatchCelebrationMainButtonMixin = {};

function MatchCelebrationMainButtonMixin:OnClick()
	ConfirmOrLeaveLFGParty();
	HideUIPanel(MatchCelebrationPartyPoseFrame);
end 

MatchCelebrationExtraButtonMixin = {};

function MatchCelebrationExtraButtonMixin:OnClick()
	local partyPoseID = MatchCelebrationPartyPoseFrame.partyPoseData.partyPoseInfo.partyPoseID; 
	if partyPoseID then 
		C_PartyPose.ExtraAction(partyPoseID);
		HideUIPanel(MatchCelebrationPartyPoseFrame);
	end
end