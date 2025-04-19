PlayerChoiceTorghastOptionTemplateMixin = {};

local rarityToSwirlPostfix =
{
	[Enum.PlayerChoiceRarity.Common] = "",
	[Enum.PlayerChoiceRarity.Uncommon] = "-QualityUncommon",
	[Enum.PlayerChoiceRarity.Rare] = "-QualityRare",
	[Enum.PlayerChoiceRarity.Epic] = "-QualityEpic",
};

function PlayerChoiceTorghastOptionTemplateMixin:OnLoad()
	PlayerChoicePowerChoiceTemplateMixin.OnLoad(self);
	self.selectedEffects = { {id = 97} };
end

function PlayerChoiceTorghastOptionTemplateMixin:GetTextureKitRegionTable()
	local useTextureRegions = PlayerChoicePowerChoiceTemplateMixin.GetTextureKitRegionTable(self);

	useTextureRegions.SwirlBG = "UI-Frame-%s-Portrait"..rarityToSwirlPostfix[self.optionInfo.rarity];
	useTextureRegions.GlowBG = useTextureRegions.SwirlBG;

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
