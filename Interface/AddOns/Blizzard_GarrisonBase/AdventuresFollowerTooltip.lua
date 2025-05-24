
----------------------------------------
-- Adventures Level Portrait Mixin
---------------------------------------

AdventuresLevelPortraitMixin = {}

function AdventuresLevelPortraitMixin:SetupPortrait(info)
	self.info = info;

	self.PuckBorder:SetAtlas("Adventurers-Followers-Frame");
	self.Portrait:SetTexture(info.portraitIconID);
	self.LevelDisplayFrame.LevelText:SetText(info.level);
end
