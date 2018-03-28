IslandsPartyPoseMixin = CreateFromMixins(PartyPoseMixin);

--Set the text for the leave button. 
function IslandsPartyPoseMixin:SetLeaveButtonText() 
	self.LeaveButton.Text:SetText(ISLAND_LEAVE);
end

--Sets the top banner to reflect the winner of the match. 
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

function IslandsPartyPoseMixin:LoadScreenData(mapID, questID, winner) 
	local partyPoseInfo = C_PartyPose.GetPartyPoseInfoByMapID(mapID); 
	UIWidgetManager:RegisterWidgetSetContainer(partyPoseInfo.widgetSetID, self.Score, SetupScoreWidgetAnchoring);
	self:SetModelScene(partyPoseInfo.modelSceneID);
	self:SetLeaveButtonText(); 
	self:SetTopBannerAndBackgroundFromWinner(winner); 
end