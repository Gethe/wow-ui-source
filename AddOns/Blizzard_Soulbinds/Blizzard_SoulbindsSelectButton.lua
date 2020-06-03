SoulbindsSelectButtonMixin = CreateFromMixins(SelectableButtonMixin);

local SoulbindsSelectButtonEvents =
{
	"UI_MODEL_SCENE_INFO_UPDATED",
};

function SoulbindsSelectButtonMixin:OnLoad()
	SelectableButtonMixin.OnLoad(self);
end

function SoulbindsSelectButtonMixin:OnEvent(event, ...)
	if event == "UI_MODEL_SCENE_INFO_UPDATED" then
		local soulbindID = self:GetSoulbindID();
		if soulbindID then
			self:Init(C_Soulbinds.GetSoulbindData(soulbindID));
		end
	end
end

function SoulbindsSelectButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, SoulbindsSelectButtonEvents);
end

function SoulbindsSelectButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, SoulbindsSelectButtonEvents);
end

function SoulbindsSelectButtonMixin:OnEnter()
	self.ModelScene.Highlight:Show();
end

function SoulbindsSelectButtonMixin:OnLeave()
	self.ModelScene.Highlight:Hide();
end

function SoulbindsSelectButtonMixin:Reset()
	SelectableButtonMixin.Reset(self);
	self:SetSoulbindID(nil);
	self.ModelScene.Active:Hide();
	self.ModelScene.Selected:Hide();
end

function SoulbindsSelectButtonMixin:GetSoulbindID()
	return self.soulbindID;
end

function SoulbindsSelectButtonMixin:SetSoulbindID(soulbindID)
	self.soulbindID = soulbindID;
end

function SoulbindsSelectButtonMixin:Init(soulbindData)
	self:SetSoulbindID(soulbindData.ID);

	local modelScene = self.ModelScene;
	modelScene:ClearScene();

	local forceEvenIfSame = false;
	local noAutoCreateActors = true;
	modelScene:SetFromModelSceneID(341, forceEvenIfSame, noAutoCreateActors);
	
	local modelSceneData = soulbindData.modelSceneData;
	if modelSceneData.modelSceneActorID > 0 then
		local actor = modelScene:CreateActorFromScene(modelSceneData.modelSceneActorID);
		if actor then
			actor:SetOnModelLoadedCallback(GenerateClosure(self.OnModelLoaded, self));
			actor:SetModelByCreatureDisplayID(modelSceneData.creatureDisplayInfoID, true);
		end
	end

	self.ModelScene:SetPaused(true);
end

function SoulbindsSelectButtonMixin:OnModelLoaded(model)
	self.ModelScene:SetPaused(not self:IsSelected());
end

function SoulbindsSelectButtonMixin:OnSelected(newSelected, isInitializing)
	if newSelected then
		self.ModelScene.Highlight:SetAtlas("Soulbinds_Portrait_Selected", true);
		self.ModelScene.Highlight:SetAlpha(.4);
		self.ModelScene.Highlight:SetBlendMode("ADD");
	else
		self.ModelScene.Highlight:SetAtlas("Soulbinds_Portrait_Border", true);
		self.ModelScene.Highlight:SetAlpha(.4);
		self.ModelScene.Highlight:SetBlendMode("ADD");
	end

	self.ModelScene.Selected:SetShown(newSelected);
	self.ModelScene:SetPaused(not newSelected);

	if not isInitializing then
		PlaySound(SOUNDKIT.SOULBINDS_SOULBIND_SELECTED);
	end
end

function SoulbindsSelectButtonMixin:SetActiveMarker(enabled)
	self.ModelScene.Active:SetShown(enabled);
end