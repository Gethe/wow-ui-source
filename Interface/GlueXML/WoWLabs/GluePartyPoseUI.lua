GluePartyPoseMixin = { };

local GLUE_PARTY_POSE_SCENEID = 735;
local CHARACTER_ROTATION_INCREMENT = 0.015;
local DISTANCE_FROM_TOP_PARTY_FRAME = -200;
local ACTOR_OUTLINE_SPELL_VISUAL_KIT = 196907;

function GluePartyPoseMixin:OnLoad()
	self.partyMemberFramePool = CreateFramePool("BUTTON", self, "PartyMemberFrameTemplate");
	self:RegisterEvent("LOBBY_MATCHMAKER_PARTY_UPDATE");
	PartyPoseDialogSpinner:Show();
end

function GluePartyPoseMixin:OnEvent(event, ...)
	if event == "LOBBY_MATCHMAKER_PARTY_UPDATE" then
		self:Init();
	end
end

function GluePartyPoseMixin:Clear()
	self.ModelScene:ClearScene();
	if self.partyMemberFramePool then 
		self.partyMemberFramePool:ReleaseAll()
	end
end

function GluePartyPoseMixin:Init()
	self.ModelScene:ClearScene();
	self.characterIndex = 0;
	self:SetModelScene( GLUE_PARTY_POSE_SCENEID, nil, false );
end

-- Creates the model scene and adds the actors from a particular ID.
function GluePartyPoseMixin:SetModelScene(sceneID, partyCategory, forceUpdate)
	self.ModelScene:SetFromModelSceneID(sceneID, forceUpdate);
	local members = C_WoWLabsMatchmaking.GetCurrentParty();

	self.partyMemberFramePool:ReleaseAll()

	local playeryActor = self.ModelScene:GetPlayerActor();
	if playeryActor then
		playeryActor:ReleaseFrontEndCharacterDisplays();
	end

	local actorIndex = 1;
	for i, memberInfo in ipairs(members) do
		local partyActor = nil;
		local isLocalPlayer = memberInfo.isLocalPlayer;
		if isLocalPlayer then
			partyActor = self.ModelScene:GetPlayerActor();
		else
			partyActor = self.ModelScene:GetActorByTag("party"..actorIndex);
			actorIndex = actorIndex + 1;
		end
		
		if partyActor then
			partyActor:SetFrontEndLobbyModelFromDefaultCharacterDisplay(self.characterIndex);
			local partyMemberFrame = self.partyMemberFramePool:Acquire(); 
			partyActor.partyMemberFrame = partyMemberFrame;
			partyMemberFrame.actor = partyActor;
			partyMemberFrame.modelScene = self.ModelScene;
			partyMemberFrame.layoutIndex = i;
			partyMemberFrame:Setup(memberInfo); 
			self:SetupPartyMemberFrame(partyActor);
			self.characterIndex = self.characterIndex + 1;
		end
	end

	self.ModelScene:Show();
end

function GluePartyPoseMixin:SetupPartyMemberFrame(actor)
	self.onActorSizeChangedCallback = self.onActorSizeChangedCallback or function(actor)
		local partyMemberFrame = actor.partyMemberFrame;
		local bottomX, bottomY, bottomZ, topX, topY, topZ = actor:GetActiveBoundingBox();

		-- postion of the actor
		local positionVector = CreateVector3D(actor:GetPosition());
		positionVector:ScaleBy(actor:GetScale());
		local posX, posY, posZ = positionVector:GetXYZ();

		local x, y, depthScale = self.ModelScene:Transform3DPointTo2D(posX - bottomX, posY + bottomY, posZ + bottomZ );
		if not x or not y or not depthScale then
			partyMemberFrame:Hide();
			return;
		end

		-- bottom left of the actor
		partyMemberFrame:ClearAllPoints();
		depthScale = Lerp(0.1, 1, ClampedPercentageBetween(depthScale, 0.8, 1));-- Scales down the texture depending on it's depthScale.
		local bottomDepthScale = depthScale;
		local VERTICAL_INSET = 20 * depthScale;
		local HORIZONTAL_INSET = 20 * depthScale;		
		local inverseScale = self.ModelScene:GetEffectiveScale() * depthScale; -- Need to apply the effective scale to account for UI Scaling.
		local xOffset = (x / inverseScale) + HORIZONTAL_INSET;
		local yOffset = (y / inverseScale) + VERTICAL_INSET;
		partyMemberFrame:SetPoint("BOTTOMLEFT", self.ModelScene, "BOTTOMLEFT", xOffset, yOffset);

		-- top right of the actor
		x, y, depthScale = self.ModelScene:Transform3DPointTo2D(posX + topX, posY + topY, posZ + topZ);
		depthScale = Lerp(0.1, 1, ClampedPercentageBetween(depthScale, 0.8, 1));-- Scales down the texture depending on it's depthScale.
		local topDepthScale = depthScale;
		inverseScale = self.ModelScene:GetEffectiveScale() * depthScale; -- Need to apply the effective scale to account for UI Scaling.
		local modelSceneWidth = self.ModelScene:GetWidth() / inverseScale;
		local modelSceneHeight = self.ModelScene:GetHeight() / inverseScale;
		xOffset = modelSceneWidth - (x / inverseScale) + HORIZONTAL_INSET;
		yOffset = modelSceneHeight - (y / inverseScale) + VERTICAL_INSET;
		partyMemberFrame:SetPoint("TOPRIGHT", self.ModelScene, "TOPRIGHT", -xOffset, -yOffset);
		
		xOffset = 15;
		yOffset = 25;
		partyMemberFrame.dropShadow:ClearAllPoints();
		partyMemberFrame.dropShadow:SetPoint("BOTTOMLEFT", partyMemberFrame, "BOTTOMLEFT", -xOffset/bottomDepthScale, (-yOffset * 1.25)/bottomDepthScale);
		partyMemberFrame.dropShadow:SetPoint("TOPRIGHT", partyMemberFrame, "BOTTOMRIGHT", xOffset/topDepthScale, (yOffset * 2)/topDepthScale);
	
		partyMemberFrame:SetScale(inverseScale);

		partyMemberFrame:Show();
		partyMemberFrame.MemberNameFrame.MemberName:SetText(partyMemberFrame.fullText);
		PartyPoseDialogSpinner:Hide();	
	end;

	actor:SetOnSizeChangedCallback(self.onActorSizeChangedCallback);
end

PartyMemberFrameTemplateMixin = { }; 
function PartyMemberFrameTemplateMixin:Setup(memberInfo)
	local memberNameFrame = self.MemberNameFrame;
	local memberNameText = StringSplitIntoTable("#", memberInfo.playerName)[1];
	memberNameFrame.MemberName:SetText(memberNameText);
	memberNameFrame.RenownLevel:SetText(memberInfo.renownLevel);

	--Show the leader icon in front of the party member if they are the leader of the group.. 
	memberNameFrame.LeaderIcon:SetShown(memberInfo.isPartyLeader and not C_WoWLabsMatchmaking.IsAloneInWoWLabsParty());
	--Show the ready icon on the end of the party member if they are ready.
	memberNameFrame.ReadyCheck:SetShown(memberInfo.isReady);
	memberNameFrame:Layout();

	self.memberGUID = memberInfo.partyMemberGUID; 
	self.memberName = memberInfo.playerName;
	self.isLocalPlayer = memberInfo.isLocalPlayer;
	self.fullText = memberNameText;
	self:Show();
end

function PartyMemberFrameTemplateMixin:OnClick(button)
	if not self.memberName or not self.memberGUID then
		return; 
	end 

	if button == "RightButton" then
		self:ToggleDropDown(self.memberName, self.memberGUID);
	end
end 

function PartyMemberFrameTemplateMixin:OnMouseDown(button)
    if button == "LeftButton" then
        self.actor.rotationStartX = GetCursorPosition();
        self.actor.initialRotation = self.actor:GetYaw();
		GluePartyPoseFrame.rotatingActor = true;
    end
end

function PartyMemberFrameTemplateMixin:OnMouseUp(button)
    if button == "LeftButton" then
        self.actor.rotationStartX = nil
		GluePartyPoseFrame.rotatingActor = false;
		if not self:IsMouseOver() then
			self.actor:SetSpellVisualKit(0);
		end
    end
end

function PartyMemberFrameTemplateMixin:OnUpdate()
    if self.actor.rotationStartX then
        local x = GetCursorPosition();
        local diff = (x - self.actor.rotationStartX) * CHARACTER_ROTATION_INCREMENT;
        self.actor.rotationStartX = GetCursorPosition();
        self.actor:SetYaw(self.actor:GetYaw() + diff);
    end
end

function PartyMemberFrameTemplateMixin:OnEnter()
	if not GluePartyPoseFrame.rotatingActor and self.actor then
		self.actor:SetSpellVisualKit(ACTOR_OUTLINE_SPELL_VISUAL_KIT);
		
		--C_WoWLabsMatchmaking.IsPlayer(self:GetGUID()) and not C_WoWLabsMatchmaking.IsAloneInWoWLabsParty()
		--C_WoWLabsMatchmaking.IsPartyLeader() and not C_WoWLabsMatchmaking.IsPlayer(self:GetGUID())

		local canShow = C_WoWLabsMatchmaking.IsPlayer(self.memberGUID) and not C_WoWLabsMatchmaking.IsAloneInWoWLabsParty() or C_WoWLabsMatchmaking.IsPartyLeader() and not C_WoWLabsMatchmaking.IsPlayer(self.memberGUID);
		self.ContextMenuIcon:SetShown(canShow);
	end
end

function PartyMemberFrameTemplateMixin:OnLeave()
	if self.actor and not GluePartyPoseFrame.rotatingActor then
		self.actor:SetSpellVisualKit(0);
		self.ContextMenuIcon:SetShown(false);
	end
end

function PartyMemberFrameTemplateMixin:OnLoad()
	self:RegisterForClicks("LeftButtonDown", "RightButtonUp");
end 

function PartyMemberFrameTemplateMixin:ToggleDropDown(name, guid)
	GluePartyFrameMemberDropdown.name = name;
	GluePartyFrameMemberDropdown.guid = guid;
	UIDropDownMenu_SetInitializeFunction(GluePartyFrameMemberDropdown, self.InitializeDropDown);
	UIDropDownMenu_SetDisplayMode(GluePartyFrameMemberDropdown, "MENU");
	ToggleDropDownMenu(1, nil, GluePartyFrameMemberDropdown, "cursor");
end

function PartyMemberFrameTemplateMixin:InitializeDropDown() 
	UnitPopup_ShowMenu(UIDROPDOWNMENU_OPEN_MENU, "GLUE_PARTY_MEMBER", nil, GluePartyFrameMemberDropdown.name, { guid = GluePartyFrameMemberDropdown.guid });
end


