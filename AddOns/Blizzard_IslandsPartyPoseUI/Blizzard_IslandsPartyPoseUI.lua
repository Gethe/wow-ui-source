local AZERITE_POWER_SPELL_VISUAL_KIT_ID = 96781; -- Heart of Azeroth Channel Spell. 
IslandsPartyPoseMixin = CreateFromMixins(PartyPoseMixin);

function IslandsPartyPoseMixin:SetLeaveButtonText() 
	self.LeaveButton.Text:SetText(ISLAND_LEAVE);
end

function IslandsPartyPoseMixin:SetTopBannerAndBackgroundFromWinner(winner)
	if (winner == "Horde") then
		self.TitleText:SetText(VICTORY_TEXT0); 
		self.TitleBg:SetAtlas("scoreboard-header-horde", true); 
		self.ModelScene.Bg:SetAtlas("scoreboard-background-islands-horde"); 
	elseif (winner == "Alliance") then
		self.TitleText:SetText(VICTORY_TEXT1); 
		self.TitleBg:SetAtlas("scoreboard-header-alliance", true); 
		self.ModelScene.Bg:SetAtlas("scoreboard-background-islands-alliance"); 
	end
end

function IslandsPartyPoseMixin:LoadScreenData(mapID, winner) 
	self.rewardPool:ReleaseAll(); 
	local partyPoseInfo = C_PartyPose.GetPartyPoseInfoByMapID(mapID); 
	UIWidgetManager:RegisterWidgetSetContainer(partyPoseInfo.widgetSetID, self.Score);
	
	self:PlayModelSceneAnimations(false);
	self:SetModelScene(partyPoseInfo.modelSceneID, LE_PARTY_CATEGORY_INSTANCE);
	self:ApplyVisualKitToEachActor(AZERITE_POWER_SPELL_VISUAL_KIT_ID); 
	self:SetLeaveButtonText(); 
	
	local factionWinner = PLAYER_FACTION_GROUP[winner];
	self:SetTopBannerAndBackgroundFromWinner(factionWinner); 
end