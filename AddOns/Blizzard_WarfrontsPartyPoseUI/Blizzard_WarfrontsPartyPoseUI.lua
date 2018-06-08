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

local DANCE_ANIMATION_ID = 147;
local COWER_ANIMATION_ID = 225;

WarfrontsPartyPoseMixin = CreateFromMixins(PartyPoseMixin);

function WarfrontsPartyPoseMixin:AddActor(scene, displayID, name)
	local actor = scene:GetActorByTag(name);
	if (actor) then
		if (actor:SetModelByCreatureDisplayID(displayID)) then 
			self:SetupShadow(actor);
		end
	end
end

function WarfrontsPartyPoseMixin:PlayAnimationBasedOnVictory(isWinner)
	local animationID; 
	
	if (isWinner) then
		animationID = DANCE_ANIMATION_ID; --Dance
	else 
		animationID = COWER_ANIMATION_ID; --Cower
	end
	
	for actor in self.ModelScene:EnumerateActiveActors() do
		actor:SetAnimation(animationID);
	end
end

function WarfrontsPartyPoseMixin:AddModelSceneActors()
	local factionGroup = UnitFactionGroup("player");
	local actors = factionGroup == "Horde" and WARFRONTS_GRUNT_ACTORS_HORDE or WARFRONTS_GRUNT_ACTORS_ALLIANCE;
	for scriptTag, displayID in pairs(actors) do
		self:AddActor(self.ModelScene, displayID, scriptTag); 
	end
end

function WarfrontsPartyPoseMixin:SetLeaveButtonText() 
	self.LeaveButton.Text:SetText(WARFRONTS_LEAVE);
end

function WarfrontsPartyPoseMixin:SetTexturesBasedOnCurrentFaction(faction)
	if (faction == "Horde") then 
		self.TitleBg:SetAtlas("scoreboard-header-horde", true); 
		self.ModelScene.Bg:SetAtlas("scoreboard-background-warfronts-horde"); 
	else 
		self.TitleBg:SetAtlas("scoreboard-header-alliance", true); 
		self.ModelScene.Bg:SetAtlas("scoreboard-background-warfronts-alliance"); 
	end
end

function WarfrontsPartyPoseMixin:SetTopBannerAndBackgroundFromWinner(winner)
	local currentFaction = UnitFactionGroup("player");
	if (winner == currentFaction) then
		self.TitleText:SetText(PARTY_POSE_VICTORY); 
		self:PlayAnimationBasedOnVictory(true); 
	else
		self.TitleText:SetText(PARTY_POSE_DEFEAT); 
		self:PlayAnimationBasedOnVictory(false); 
	end
	
	self:SetTexturesBasedOnCurrentFaction(currentFaction); 
end

function WarfrontsPartyPoseMixin:LoadScreenData(mapID, winner) 
	local partyPoseInfo = C_PartyPose.GetPartyPoseInfoByMapID(mapID); 
	
	self:SetModelScene(partyPoseInfo.modelSceneID, LE_PARTY_CATEGORY_HOME);
	self:AddModelSceneActors();
	
	self:SetLeaveButtonText(); 
	
	local factionWinner = PLAYER_FACTION_GROUP[winner];
	self:SetTopBannerAndBackgroundFromWinner(factionWinner); 
end

function WarfrontsPartyPoseMixin:OnLoad()
	PartyPoseMixin.OnLoad(self);
end

function WarfrontsPartyPoseMixin:OnEvent(event, ...) 
	PartyPoseMixin.OnEvent(self, event, ...); 
	if (event == "UI_MODEL_SCENE_INFO_UPDATED") then
		self:AddModelSceneActors();
	end
end