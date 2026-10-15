PlayerChoiceTaleboundOptionButtonMixin = CreateFromMixins(PlayerChoiceBaseOptionButtonTemplateMixin);

function PlayerChoiceTaleboundOptionButtonMixin:SetPushed(pushed)
	self.pushed = pushed;
	self:SetEnabled(not pushed);
	ThreeSliceButtonMixin.UpdateButton(self, pushed and "PUSHED" or "NORMAL");
end

PlayerChoiceTaleboundOptionTemplateMixin = {};

function PlayerChoiceTaleboundOptionTemplateMixin:OnLoad()
	PlayerChoicePowerChoiceTemplateMixin.OnLoad(self);
	self.Artwork:SetSize(67, 67);
	self.CircleBorder.topPadding = 30;
	self.CircleBorder.bottomPadding = 30;
	self.selectedEffects = { {id = 188 } };
	self.GlowBG:SetAlpha(0.5);
	self.OptionButtonsContainer.buttonFrameTemplate = "PlayerChoiceTaleboundOptionButtonFrameTemplate";

	self.TypeIcon.topPadding = -40;
	self.Header.topPadding = -20;

	self.OptionButtonsContainer.ignoreInLayout = true;
	self.OptionButtonsContainer:ClearAllPoints();
	self.OptionButtonsContainer:SetPoint("TOP", self.WidgetContainer, "BOTTOM", 0, 10);

	-- Adjust the ArtworkCircleMask anchors
	self.ArtworkCircleMask:ClearAllPoints();
	self.ArtworkCircleMask:SetPoint("TOPLEFT", self.CircleBorder, "TOPLEFT", 3, -3);
	self.ArtworkCircleMask:SetPoint("BOTTOMRIGHT", self.CircleBorder, "BOTTOMRIGHT", -3, 3);
end

function PlayerChoiceTaleboundOptionTemplateMixin:OnShow()
	PlayerChoicePowerChoiceTemplateMixin.OnShow(self);
	EventRegistry:TriggerEvent("PlayerChoiceTaleboundOptionTemplate.OnShow", self);
end

function PlayerChoiceTaleboundOptionTemplateMixin:OnHide()
	PlayerChoicePowerChoiceTemplateMixin.OnHide(self);
	EventRegistry:TriggerEvent("PlayerChoiceTaleboundOptionTemplate.OnHide", self);
end

function PlayerChoiceTaleboundOptionTemplateMixin:GetTextureKitRegionTable()
	local useTextureRegions = PlayerChoicePowerChoiceTemplateMixin.GetTextureKitRegionTable(self);
	useTextureRegions.CircleBorder = "UI-Frame-TaleboundChoice-IconFrame";

	return useTextureRegions;
end
