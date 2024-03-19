
MatchCelebrationPartyPoseMixin = CreateFromMixins(PartyPoseMixin);

function MatchCelebrationPartyPoseMixin:SetLeaveButtonText()
	self.LeaveButton:SetText(WOW_LABS_REMATCH);
end

do
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
end

function MatchCelebrationPartyPoseMixin:LoadPartyPose(partyPoseData, forceUpdate)
	PartyPoseMixin.LoadPartyPose(self, partyPoseData, forceUpdate);

	self.ExtraButton:SetText(self.partyPoseData.partyPoseInfo.extraButtonText or "");
	self.ExtraButton:SetEnabled(C_PartyPose.HasExtraAction(self.partyPoseData.partyPoseInfo.partyPoseID)); 
	self.ExtraButton:Show();
end		

MatchCelebrationMainButtonMixin = { }; 
function MatchCelebrationMainButtonMixin:OnClick()
	ForceLogout();
	HideUIPanel(self:GetParent());
end 

MatchCelebrationExtraButtonMixin = { }; 
function MatchCelebrationExtraButtonMixin:OnClick()
	local partyPoseID = self:GetParent().partyPoseData.partyPoseInfo.partyPoseID; 
	if (partyPoseID) then 
		C_PartyPose.ExtraAction(partyPoseID);
		HideUIPanel(self:GetParent());
	end
end