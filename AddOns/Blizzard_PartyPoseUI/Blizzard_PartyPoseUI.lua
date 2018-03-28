PartyPoseMixin = { };

-- Anchors the widget container to the left bottom corner on the frame. 
function SetupScoreWidgetAnchoring(widgetContainer, sortedWidgets)
	for index, widgetFrame in ipairs(sortedWidgets) do
		if ( index == 1 ) then
			widgetFrame:SetPoint("TOP");
		else
			local relative = sortedWidgets[index - 1];
			widgetFrame:SetPoint("TOP", relative, "BOTTOM");
		end
	end
end

-- Moves the shadow to underneath the model actor in the model scene. 
function PartyPoseMixin:SetupShadow(actor)
	local shadowTexture = self.ModelScene.shadowPool:Acquire(); 
	 
	local positionVector = CreateVector3D(actor:GetPosition())
	positionVector:ScaleBy(actor:GetScale());
	local x, y, depthScale = self.ModelScene:Transform3DPointTo2D(positionVector:GetXYZ()); 
	
	if (not x or not y or not depthScale) then 
		return;
	end
	
	shadowTexture:ClearAllPoints();
	
	-- Scales down the texture depending on it's depthScale. 
	shadowTexture:SetScale(depthScale); 
	
	-- Need to apply the effective scale to account for UI Scaling. 
	local inverseScale = self.ModelScene:GetEffectiveScale() * depthScale; 
	
	-- The position of the character can be found by the offset on the screen. 
	shadowTexture:SetPoint("CENTER", self.ModelScene, "BOTTOMLEFT", (x / inverseScale) + 2, (y / inverseScale) - 4);
	shadowTexture:Show();
end

-- Creates the model scene and adds the actors from a particular ID. 
function PartyPoseMixin:SetModelScene(sceneID)
	self.ModelScene:SetFromModelSceneID(sceneID, true); 
	self.ModelScene.shadowPool:ReleaseAll(); 
		
	local numPartyMembers = GetNumGroupMembers() - 1; 
	
	local playerActor = self.ModelScene:GetActorByTag("player");
	if (playerActor) then 
		if (playerActor:SetModelByUnit("player")) then 
			self:SetupShadow(playerActor); 
		end
	end
	
	for i=1, numPartyMembers do
		local partyActor = self.ModelScene:GetActorByTag("party"..i); 
		if (partyActor) then 
			partyActor:SetModelByUnit("party"..i)
			self:SetupShadow(partyActor);
		end
	end
	self.ModelScene:Show(); 
end

function PartyPoseMixin:OnLoad()
	self.ModelScene:EnableMouse(false);
	self.ModelScene:EnableMouseWheel(false);
	self.ModelScene.shadowPool = CreateTexturePool(self.ModelScene, "BORDER", 1, "PartyPoseModelShadowTextureTemplate");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
end

function PartyPoseMixin:OnEvent(event, ...)
	if (event == "UI_MODEL_SCENE_INFO_UPDATED") then
		self:SetModelScene(self.ModelScene:GetModelSceneID()); 
	end
end