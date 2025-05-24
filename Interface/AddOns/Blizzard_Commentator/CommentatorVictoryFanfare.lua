
local COMMENTATOR_VICTORY_FANFARE_MODEL_SCENE_ID = 59;
local COMMENTATOR_VICTORY_FANFARE_EFFECT_MODEL_ID = 382335;--"SPELLS\\EASTERN_PLAGUELANDS_BEAM_EFFECT.M2";

CommentatorVictoryFanfareFrameMixin = {};

function CommentatorVictoryFanfareFrameMixin:OnLoad()
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.BackgroundModelScene:SetFromModelSceneID(COMMENTATOR_VICTORY_FANFARE_MODEL_SCENE_ID, true);
	
	local effect = self.BackgroundModelScene:GetActorByTag("effect");
	if effect then
		effect:SetModelByFileID(COMMENTATOR_VICTORY_FANFARE_EFFECT_MODEL_ID);
		effect:SetAlpha(0.0);
		self.BackgroundModelScene.effect = effect;
	end
	
	local effect2 = self.BackgroundModelScene:GetActorByTag("effect2");
	if effect2 then
		effect2:SetModelByFileID(COMMENTATOR_VICTORY_FANFARE_EFFECT_MODEL_ID);
		effect2:SetAlpha(0.0);
		self.BackgroundModelScene.effect2 = effect2;
	end
	
	self.BG1:SetWidth(GetScreenWidth() * 0.8);
	self.BG1:SetHeight(2);
	
	self.BG2:SetWidth(GetScreenWidth() * 0.8);
	self.BG2:SetHeight(2);

end

function CommentatorVictoryFanfareFrameMixin:OnEvent(event)
	if event == "PLAYER_ENTERING_WORLD" then
		self:Reset();
		self:Hide();
	end
end

function CommentatorVictoryFanfareFrameMixin:PlayVictoryFanfare(text, team)
	self.Title:SetText(text);
	self.TitleFlash:SetText(text);
	self.TeamName:SetText(team);
	self.TeamNameFlash:SetText(team);

	self:Reset();
	self.Anim:Play();
	
	C_Timer.After(1.5, function()
		self.BackgroundModelScene.EffectAnimIn:Play();
		self.BackgroundModelScene:Show();
	end);
	
	C_Timer.After(5.0, function()
		self.ExitArenaButton:Show();
	end);
end

function CommentatorVictoryFanfareFrameMixin:Reset()
	self.Icon:SetAlpha(0);
	self.Icon2:SetAlpha(0);
	self.Icon3:SetAlpha(0);
	self.BackgroundModelScene:Hide();
	self.Anim:Stop();
	self.ExitArenaButton:Hide();
end
