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

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -14, -14);

	if not self.soulbindData.unlocked then
		GameTooltip_AddNormalLine(GameTooltip, self.soulbindData.playerConditionReason);
	else
		GameTooltip_AddHighlightLine(GameTooltip, self.soulbindData.name);

		local specIDs = C_Soulbinds.GetSpecsAssignedToSoulbind(self.soulbindData.ID);
		if #specIDs > 0 then
			local specNames = {};
			for index, specID in ipairs(specIDs) do
				local name = select(2, GetSpecializationInfoForSpecID(specID));
				table.insert(specNames, name);
			end
			local specList = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(table.concat(specNames, LIST_DELIMITER));
			GameTooltip_AddNormalLine(GameTooltip, SOULBINDS_ACTIVATED_FOR_SPEC:format(specList));
		end
		
	end
	GameTooltip:Show();
end

function SoulbindsSelectButtonMixin:OnLeave()
	self.ModelScene.Highlight:Hide();
	GameTooltip_Hide();
end

function SoulbindsSelectButtonMixin:Reset()
	SelectableButtonMixin.Reset(self);
	self:SetSoulbind(nil);
	self.ModelScene.Active:Hide();
	self.ModelScene.Selected:Hide();
	self.inTutorial = false;
	self:SetHighlightUnselected();
	self:GetFxModelScene():ClearEffects();
	self.deferredFx = nil;
	self.activatedFxController = nil;
	self.ModelScene.Highlight2.Pulse:Stop();
	self.ModelScene.Highlight3.Pulse:Stop();
	self.ModelScene.Dark.Pulse:Stop();
end

function SoulbindsSelectButtonMixin:GetFxModelScene()
	return self.FxModelScene;
end

function SoulbindsSelectButtonMixin:GetSoulbindID()
	return self.soulbindData and self.soulbindData.ID or nil;
end

function SoulbindsSelectButtonMixin:SetSoulbind(soulbindData)
	self.soulbindData = soulbindData;
end

function SoulbindsSelectButtonMixin:ShouldShowTutorial()
	return Soulbinds.HasNewSoulbindTutorial(self.soulbindData.ID) and self.soulbindData.unlocked and not GetCVarBitfield("soulbindsViewedTutorial", self.soulbindData.cvarIndex);
end

function SoulbindsSelectButtonMixin:Init(soulbindData)
	self:SetSoulbind(soulbindData);

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

	local showTutorial = self:ShouldShowTutorial();
	self.ModelScene.Highlight2.Pulse:SetPlaying(showTutorial);
	self.ModelScene.Highlight3.Pulse:SetPlaying(showTutorial);
	self.ModelScene.NewAlert:SetShown(showTutorial);

	self.ModelScene.Lock:SetShown(not soulbindData.unlocked);

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

function SoulbindsSelectButtonMixin:OnSelected(newSelected)
	self.ModelScene.NewAlert:Hide();
	self.ModelScene.Highlight2.Pulse:Stop();
	self.ModelScene.Highlight3.Pulse:Stop();
	self.ModelScene.Dark.Pulse:Stop();

	if newSelected then
		SetCVarBitfield("soulbindsViewedTutorial", self.soulbindData.cvarIndex, true);
		self:SetHighlightSelected();
	else
		self:SetHighlightUnselected();
		
		if self.inTutorial then
			self.ModelScene.Dark:SetAlpha(.5);
			self.ModelScene.Dark.Pulse:Stop();
			self.ModelScene:SetDesaturation(.8);
			self.inTutorial = false;
		end
	end

	self.ModelScene.Selected:SetShown(newSelected);
	self.ModelScene:SetPaused(not newSelected);
end

function SoulbindsSelectButtonMixin:SetActivated(activated)
	self.ModelScene.Active:SetShown(activated);
	if activated then
		self.ModelScene.Dark:SetAlpha(0);
		self.ModelScene.Dark.Pulse:Stop();
		self.ModelScene:SetDesaturation(0);

		if not self.activatedFxController then
			self.deferredFx = GenerateClosure(self.PlayActivatedFx, self);
		end
	else
		if self.activatedFxController then
			self.activatedFxController:CancelEffect();
			self.activatedFxController = nil;
		end

		if self:ShouldShowTutorial() then
			self.inTutorial = true;
			self.ModelScene.Dark:SetAlpha(0);
			self.ModelScene.Dark.Pulse:Play();
			self.ModelScene:SetDesaturation(0);
		else
			self.ModelScene.Dark:SetAlpha(.5);
			self.ModelScene.Dark.Pulse:Stop();
			self.ModelScene:SetDesaturation(.8);
		end
	end
end

function SoulbindsSelectButtonMixin:OnActivated()
	self:PlayActivationChangedFx();
end

function SoulbindsSelectButtonMixin:AddActiveEffect(effect)
	return self:GetFxModelScene():AddEffect(effect, self.ModelScene.Active);
end

function SoulbindsSelectButtonMixin:PlayActivatedFx()
	local ACTIVATED_FX = 41;
	self.activatedFxController = self:AddActiveEffect(ACTIVATED_FX);
end

function SoulbindsSelectButtonMixin:PlayActivationChangedFx()
	local ACTIVATE_CHANGED_FX = 72;
	self:AddActiveEffect(ACTIVATE_CHANGED_FX);
end