local WARFRONTS_GRUNT_ACTORS_HORDE =
{
	grunt1  = 83858,
	grunt2  = 83860,
	grunt3  = 83960,
	grunt4 	= 83958,
	grunt5 	= 84009,
	grunt6  = 84011,
	grunt7 	= 85991,
	grunt8  = 87705,
	grunt9  = 86718,
	grunt10 = 86722,
}

local WARFRONTS_GRUNT_ACTORS_ALLIANCE =
{
	grunt1 	= 83056,
	grunt2  = 83057,
	grunt3  = 86833,
	grunt4	= 78939,
	grunt5  = 84310,
	grunt6 	= 87808,
	grunt7	= 87804,
	grunt8  = 71841,
	grunt9 	= 60949,
	grunt10 = 60990,
}

WarfrontsPartyPoseMixin = CreateFromMixins(PartyPoseMixin);

function WarfrontsPartyPoseMixin:AddActor(scene, displayID, name)
	local actor = scene:GetActorByTag(name);
	if (actor) then
		if (actor:SetModelByCreatureDisplayID(displayID)) then
			self:SetupShadow(actor);
		end
	end
end

function WarfrontsPartyPoseMixin:AddModelSceneActors(playerFactionGroup)
	local actors = playerFactionGroup == "Horde" and WARFRONTS_GRUNT_ACTORS_HORDE or WARFRONTS_GRUNT_ACTORS_ALLIANCE;
	for scriptTag, displayID in pairs(actors) do
		self:AddActor(self.ModelScene, displayID, scriptTag);
	end
end

function WarfrontsPartyPoseMixin:SetLeaveButtonText()
	self.LeaveButton.Text:SetText(WARFRONTS_LEAVE);
end

do
	local warfrontsStyleData =
	{
		Horde =
		{
			topperOffset = -37,
			Topper = "scoreboard-horde-header",
			topperBehindFrame = false,

			TitleBG = "scoreboard-header-horde",
			ModelSceneBG = "scoreboard-background-warfronts-horde",

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
			ModelSceneBG = "scoreboard-background-warfronts-alliance",

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
	}

	function WarfrontsPartyPoseMixin:LoadScreenData(mapID, winner)
		local partyPoseInfo = C_PartyPose.GetPartyPoseInfoByMapID(mapID);

		local playerFactionGroup = UnitFactionGroup("player");

		self:SetLeaveButtonText();

		local winnerFactionGroup = PLAYER_FACTION_GROUP[winner];
		self:PlaySounds(partyPoseInfo, winnerFactionGroup);

		if (winnerFactionGroup == playerFactionGroup) then
			self.TitleText:SetText(PARTY_POSE_VICTORY);
			self:SetModelScene(partyPoseInfo.victoryModelSceneID, LE_PARTY_CATEGORY_HOME);
		else
			self.TitleText:SetText(PARTY_POSE_DEFEAT);
			self:SetModelScene(partyPoseInfo.defeatModelSceneID, LE_PARTY_CATEGORY_HOME);
		end

		self:AddModelSceneActors(playerFactionGroup);

		self:SetupTheme(warfrontsStyleData[playerFactionGroup]);
	end
end

function WarfrontsPartyPoseMixin:OnEvent(event, ...)
	PartyPoseMixin.OnEvent(self, event, ...);
	if (event == "UI_MODEL_SCENE_INFO_UPDATED") then
		self:AddModelSceneActors(UnitFactionGroup("player"));
	end
end