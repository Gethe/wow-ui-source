GlueAnnouncementDialogMixin = {}

function GlueAnnouncementDialogMixin:OnShow()
	self:SetParent(GetAppropriateTopLevelParent());

	BaseNineSliceDialogMixin.OnShow(self);
end

function GlueAnnouncementDialogMixin:OnCloseClick()
	BaseNineSliceDialogMixin.OnCloseClick(self);
	CharacterSelect_CheckDialogStates();
end
