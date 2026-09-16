PlayerChoiceTorghastOptionTemplateMixin = {};

function PlayerChoiceTorghastOptionTemplateMixin:OnLoad()
	PlayerChoicePowerChoiceTemplateMixin.OnLoad(self);
	self.selectedEffects = { {id = 97} };
end

function PlayerChoiceTorghastOptionTemplateMixin:GetTextureKitRegionTable()
	local useTextureRegions = PlayerChoicePowerChoiceTemplateMixin.GetTextureKitRegionTable(self);
	local atlasData = self:GetAtlasDataForRarity();

	self.SwirlBG:SetVertexColor(1, 1, 1);
	self.GlowBG:SetVertexColor(1, 1, 1);
	if atlasData then
		useTextureRegions.SwirlBG = "UI-Frame-%s-Portrait"..atlasData.postfixData.portraitBackgroundTorghast;
		useTextureRegions.GlowBG = useTextureRegions.SwirlBG;

		if atlasData.overrideColor then
			self.SwirlBG:SetVertexColor(atlasData.overrideColor.r, atlasData.overrideColor.g, atlasData.overrideColor.b);
			self.GlowBG:SetVertexColor(atlasData.overrideColor.r, atlasData.overrideColor.g, atlasData.overrideColor.b);
		end
	end

	return useTextureRegions;
end

local powerSwirlEffectID = 95;
local smokeEffectID = 89;

function PlayerChoiceTorghastOptionTemplateMixin:BeginEffects()
	if not self.powerSwirlEffectController then
		self.powerSwirlEffectController = PlayerChoiceFrame.BorderLayerModelScene:AddEffect(powerSwirlEffectID, self.Artwork);
	end

	if not self.smokeEffectController then
		self.smokeEffectController = GlobalFXBackgroundModelScene:AddEffect(smokeEffectID, self.Background);
	end
end

function PlayerChoiceTorghastOptionTemplateMixin:CancelEffects()
	PlayerChoicePowerChoiceTemplateMixin.CancelEffects(self);
	
	if self.powerSwirlEffectController then
		self.powerSwirlEffectController:CancelEffect();
		self.powerSwirlEffectController = nil;
	end

	if self.smokeEffectController then
		self.smokeEffectController:CancelEffect();
		self.smokeEffectController = nil;
	end
end
