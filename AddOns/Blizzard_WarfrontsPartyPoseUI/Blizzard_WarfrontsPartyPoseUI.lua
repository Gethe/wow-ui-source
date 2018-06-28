local WARFRONTS_GRUNT_ACTORS_HORDE =
{
	grunt1 = 83860, -- ORCMALE_HD.m2 (Grunt)
	grunt2 = 87186, -- TROLLFEMALE_HD.m2 (Witch Doctor)
	grunt3 = 85979, -- BLOODELFFEMALE_HD.m2 (Warcaster)
	grunt4 = 81941, -- GOBLINMALE.m2 (Wistel)
	grunt5 = 83958, -- TROLLMALE_HD.m2 (Axe Thrower)
	grunt6 = 84011, -- TAURENFEMALE_HD.m2 (Warrior)
	grunt7 = 83858, -- ORCFEMALE_HD.m2 (Grunt)
	grunt8 = 83766, -- ORCMALE_HD.m2 (Peon)
}

local WARFRONTS_GRUNT_ACTORS_ALLIANCE =
{
	grunt1 = 86715, -- humanguard_m.m2 (human male footman)
	grunt2 = 86833, -- DWARFFEMALE_HD.m2 (dwarf female rifleman)
	grunt3 = 84310, -- GNOMEFEMALE_HD.m2 (gnome female engineer)
	grunt4 = 86989, -- HUMANFEMALE_HD.m2 (human female priest)
	grunt5 = 86823, -- DWARFMALE_HD.m2 (dwarf male rifleman)
	grunt6 = 86814, -- humanknight_m.m2 (human male knight)
	grunt7 = 87004, -- HUMANFEMALE_HD.m2 (human female sorceress)
	grunt8 = 87528, -- draeneipeacekeeper_m.m2 (draenei male paladin)
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
	self.LeaveButton:SetText(WARFRONTS_LEAVE);
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