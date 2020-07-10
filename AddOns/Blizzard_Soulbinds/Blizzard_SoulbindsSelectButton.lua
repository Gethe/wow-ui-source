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

function SoulbindsSelectButtonMixin:OnUpdate(elapsed)
	if self.deferredFx then
		self.deferredFx();
		self.deferredFx = nil;
	end
end

function SoulbindsSelectButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, SoulbindsSelectButtonEvents);
end

function SoulbindsSelectButtonMixin:OnHide()
	self:Reset();

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
	self:SetHighlightUnselected();
	self:GetFxModelScene():ClearEffects();
	self.deferredFx = nil;
	self.activatedFxController = nil;
end

function SoulbindsSelectButtonMixin:GetFxModelScene()
	return self.FxModelScene;
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

function SoulbindsSelectButtonMixin:SetHighlightSelected()
	self.ModelScene.Highlight:SetAtlas("Soulbinds_Portrait_Selected", true);
	self.ModelScene.Highlight:SetAlpha(.8);
	self.ModelScene.Highlight:SetBlendMode("ADD");
end

function SoulbindsSelectButtonMixin:SetHighlightUnselected()
	self.ModelScene.Highlight:SetAtlas("Soulbinds_Portrait_Border", true);
	self.ModelScene.Highlight:SetAlpha(.7);
	self.ModelScene.Highlight:SetBlendMode("ADD");
end

function SoulbindsSelectButtonMixin:OnSelected(newSelected, isInitializing)
	if newSelected then
		self:SetHighlightSelected();
	else
		self:SetHighlightUnselected();
	end

	self.ModelScene.Selected:SetShown(newSelected);
	self.ModelScene:SetPaused(not newSelected);

	if not isInitializing then
		PlaySound(SOUNDKIT.SOULBINDS_SOULBIND_SELECTED);
	end
end

function SoulbindsSelectButtonMixin:SetActivated(activated)
	self.ModelScene.Active:SetShown(activated);
	if activated then
		self.ModelScene.Dark:SetAlpha(0);
		self.ModelScene:SetDesaturation(0);

		if not self.activatedFxController then
			self.deferredFx = GenerateClosure(self.PlayActivatedFx, self);
		end
	else
		if self.activatedFxController then
			self.activatedFxController:CancelEffect();
			self.activatedFxController = nil;
		end

		self.ModelScene.Dark:SetAlpha(.3);
		self.ModelScene:SetDesaturation(.5);
	end
end

function SoulbindsSelectButtonMixin:OnActivated()
	self:PlayActivatedFx();
end

function SoulbindsSelectButtonMixin:AddActiveEffect(effect)
	return self:GetFxModelScene():AddEffect(effect, self.ModelScene.Active);
end

function SoulbindsSelectButtonMixin:PlayActivatedFx()
	local ACTIVATED_FX = 41;
	self.activatedFxController = self:AddActiveEffect(ACTIVATED_FX);
end

function SoulbindsSelectButtonMixin:PlayActivationChangedFx()
	local ACTIVATE_CHANGED_FX = 46;
	self:AddActiveEffect(ACTIVATE_CHANGED_FX);
end