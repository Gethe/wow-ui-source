function SocialUIPersonalBattleTagDisplayMixin:ShouldShowHideBattleTagButton()
	return true;
end

function SocialUIBattleTagHiddenButtonMixin:OnLoad()
	self.HiddenIcon:SetAtlas(self:GetHiddenIconAtlas(), TextureKitConstants.UseAtlasSize);
	self.ShownIcon:SetAtlas(self:GetShownIconAtlas(), TextureKitConstants.UseAtlasSize);
	self.HighlightTexture:SetAtlas(self:GetShownIconAtlas(), TextureKitConstants.UseAtlasSize);
end

function SocialUIBattleTagHiddenButtonMixin:GetHiddenIconAtlas()
	return "friends-icon-battlenet-hide";
end

function SocialUIBattleTagHiddenButtonMixin:GetShownIconAtlas()
	return "friends-icon-battlenet-show";
end
