IslandsPartyPoseMixin = CreateFromMixins(PartyPoseMixin);

function IslandsPartyPoseMixin:SetLeaveButtonText()
	self.LeaveButton:SetText(ISLAND_LEAVE);
end

do
	local islandsStyleData =
	{
		Horde =
		{
			topperOffset = -37,
			Topper = "scoreboard-horde-header",
			topperBehindFrame = false,

			TitleBG = "scoreboard-header-horde",
			ModelSceneBG = "scoreboard-background-islands-horde",

			Top = "_scoreboard-horde-tiletop",
			Bottom = "_scoreboard-horde-tilebottom",
			Left = "!scoreboard-horde-tileleft",
			Right = "!scoreboard-horde-tileright",
			TopLeft = "scoreboard-horde-corner",
			TopRight = "scoreboard-horde-corner",
			BottomLeft = "scoreboard-horde-corner",
			BottomRight = "scoreboard-horde-corner",

			-- one-off
			bottomCornerYOffset = -24;
		},

		Alliance =
		{
			topperOffset = -28,
			Topper = "scoreboard-alliance-header",
			topperBehindFrame = false,

			TitleBG = "scoreboard-header-alliance",
			ModelSceneBG = "scoreboard-background-islands-alliance",

			Top = "_scoreboard-alliance-tiletop",
			Bottom = "_scoreboard-alliance-tilebottom",
			Left = "!scoreboard-alliance-tileleft",
			Right = "!scoreboard-alliance-tileright",
			TopLeft = "scoreboard-alliance-corner",
			TopRight = "scoreboard-alliance-corner",
			BottomLeft = "scoreboard-alliance-corner",
			BottomRight = "scoreboard-alliance-corner",

			-- one-off
			bottomCornerYOffset = -20;
		},
	};

	function IslandsPartyPoseMixin:LoadScreenData(mapID, winner)
		local partyPoseInfo = C_PartyPose.GetPartyPoseInfoByMapID(mapID);
		UIWidgetManager:RegisterWidgetSetContainer(partyPoseInfo.widgetSetID, self.Score);

		self:SetLeaveButtonText();

		local winnerFactionGroup = PLAYER_FACTION_GROUP[winner];
		local playerFactionGroup = UnitFactionGroup("player");
		self:PlaySounds(partyPoseInfo, winnerFactionGroup);
		if (winnerFactionGroup == playerFactionGroup) then
			self.TitleText:SetText(PARTY_POSE_VICTORY);
			self:SetModelScene(partyPoseInfo.victoryModelSceneID, LE_PARTY_CATEGORY_INSTANCE);
		else
			self.TitleText:SetText(PARTY_POSE_DEFEAT);
			self:SetModelScene(partyPoseInfo.defeatModelSceneID, LE_PARTY_CATEGORY_INSTANCE);
		end

		self:SetupTheme(islandsStyleData[playerFactionGroup]);
	end
end