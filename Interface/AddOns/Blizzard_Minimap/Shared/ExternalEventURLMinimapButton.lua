local SPELL_EFFECT_MODEL_SCENE_ID = 1695;
local SPELL_EFFECT_MODEL_FILE_ID = 166337;

ExternalEventURLMinimapButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function ExternalEventURLMinimapButtonMixin:SetEffectShown(shown)
	local actor = self.SpellEffectModelScene:GetActorByTag("target");
	if actor then
		if shown then
			actor:SetModelByFileID(SPELL_EFFECT_MODEL_FILE_ID);
			actor:SetAlpha(.6);
		else
			actor:ClearModel();
		end
	end

	self.SpellEffectModelScene:SetShown(shown);
end

function ExternalEventURLMinimapButtonMixin:ApplyBorderStyle()
	self.Border:SetAtlas(ExternalEventURLMinimapButtonStyle.borderAtlas);
	self.Border:SetSize(ExternalEventURLMinimapButtonStyle.borderWidth, ExternalEventURLMinimapButtonStyle.borderHeight);
	self.Border:ClearAllPoints();
	self.Border:SetPoint("CENTER");
end

function ExternalEventURLMinimapButtonMixin:ApplyEffectStyle()
	self.SpellEffectModelScene:SetSize(ExternalEventURLMinimapButtonStyle.spellEffectWidth, ExternalEventURLMinimapButtonStyle.spellEffectHeight);
end

function ExternalEventURLMinimapButtonMixin:OnLoad()
	ButtonStateBehaviorMixin.OnLoad(self);

	self:ApplyBorderStyle();
	self:ApplyEffectStyle();

	self.SpellEffectModelScene:TransitionToModelSceneID(SPELL_EFFECT_MODEL_SCENE_ID, CAMERA_TRANSITION_TYPE_IMMEDIATE, CAMERA_MODIFICATION_TYPE_MAINTAIN);

	self:Refresh();

	self:RegisterEvent("EXTERNAL_EVENT_URL_CHANGED");
end

function ExternalEventURLMinimapButtonMixin:OnShow()
	self:Refresh();
end

function ExternalEventURLMinimapButtonMixin:OnHide()
	self:SetEffectShown(false);
end

function ExternalEventURLMinimapButtonMixin:OnButtonStateChanged()
	local enabled = self:IsEnabled();
	local isPressed = self:IsDownOver() or self:IsDown();

	if enabled then
		self.Icon:SetDesaturated(false);
		self.Border:SetDesaturated(false);

		local x = isPressed and 1 or 0;
		local y = isPressed and -1 or 0;
		self.Icon:SetPoint("CENTER", x, y);
	else
		self.Icon:SetDesaturated(true);
		self.Border:SetDesaturated(false);
		self.Icon:SetPoint("CENTER", 0, 0);
	end
end

function ExternalEventURLMinimapButtonMixin:OnEvent(event)
	if event == "EXTERNAL_EVENT_URL_CHANGED" then
		self:Refresh();
	end
end

function ExternalEventURLMinimapButtonMixin:Refresh()
	local canShow = C_ExternalEventURL.CanShow();
	local hasURL = C_ExternalEventURL.HasURL();
	self:SetShown(canShow and hasURL);

	local isNew = hasURL and C_ExternalEventURL.IsNew();
	self:SetEffectShown(canShow and hasURL and isNew);
end

function ExternalEventURLMinimapButtonMixin:OnClick()
	if self:IsEnabled() then
		C_ExternalEventURL.LaunchURL();

		self:Refresh();
	end
end

function ExternalEventURLMinimapButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(GAMEMENU_EXTERNALEVENT);
	GameTooltip:Show();
end

function ExternalEventURLMinimapButtonMixin:OnLeave()
	GameTooltip_Hide();
end
