--------------------------------------------------
-- DEFAULT MODEL FRAME MIXIN
DressUpModelFrameMixin = CreateFromMixins(ModelFrameMixin);

function DressUpModelFrameMixin:OnLoad()
	ModelFrameMixin.OnLoad(self, MODELFRAME_MAX_PLAYER_ZOOM);
end

function DressUpModelFrameMixin:OnHide()
	self:SetSheathed(false);
end

function DressUpModelFrameMixin:OnDressModel()
	self.gotDressed = true;
end

function DressUpModelFrameMixin:OnUpdate(elapsedTime)
	ModelFrameMixin.OnUpdate(self, elapsedTime);
	if (self.gotDressed) then
		DressUpFrameOutfitDropDown:UpdateSaveButton();
		self.gotDressed = nil;
	end
end

--------------------------------------------------
-- DRESS UP MODEL FRAME RESET BUTTON MIXIN
DressUpModelFrameResetButtonMixin = {};

function DressUpModelFrameResetButtonMixin:OnLoad()
	self.model = SideDressUpModel;
end

function DressUpModelFrameResetButtonMixin:OnClick()
	self.model:Dress();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end


--------------------------------------------------
-- DRESS UP MODEL FRAME CLOSE BUTTON MIXIN
DressUpModelFrameCloseButtonMixin = {};

function DressUpModelFrameCloseButtonMixin:OnClick()
	HideUIPanel(self:GetParent():GetParent());
end


--------------------------------------------------
-- DRESS UP MODEL FRAME CANCEL BUTTON MIXIN
DressUpModelFrameCancelButtonMixin = {};

function DressUpModelFrameCancelButtonMixin:OnClick()
	HideParentPanel(self);
end


--------------------------------------------------
-- DRESS UP MODEL FRAME MAX MIN MIXIN
DressUpModelFrameMaximizeMinimizeMixin = {};

function DressUpModelFrameMaximizeMinimizeMixin:OnLoad()
	local function OnMaximize(frame)
		frame:GetParent():SetSize(450, 545);
		UpdateUIPanelPositions(frame);
	end
						
	self:SetOnMaximizedCallback(OnMaximize);
						
	local function OnMinimize(frame)
		frame:GetParent():SetSize(334, 423);
		UpdateUIPanelPositions(frame);
	end
						
	self:SetOnMinimizedCallback(OnMinimize);
						
	self:SetMinimizedCVar("miniDressUpFrame");
end

--------------------------------------------------
-- DEFAULT MODEL FRAME FRAME MIXIN
DressUpModelFrameFrameMixin = {};

function DressUpModelFrameFrameMixin:OnLoad()
	self.TitleText:SetText(DRESSUP_FRAME);
end

function DressUpModelFrameFrameMixin:OnShow()
	SetPortraitTexture(DressUpFramePortrait, "player");
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function DressUpModelFrameFrameMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end


--------------------------------------------------
-- SIDE DRESS UP MODEL FRAME FRAME MIXIN
SideDressUpModelFrameFrameMixin = {};

function SideDressUpModelFrameFrameMixin:OnLoad()
	self.ResetButton = SideDressUpModel.ResetButton;
end

function SideDressUpModelFrameFrameMixin:OnShow()
	SetUIPanelAttribute(self.parentFrame, "width", self.openWidth);
	UpdateUIPanelPositions(self.parentFrame);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
end

function SideDressUpModelFrameFrameMixin:OnHide()
	SetUIPanelAttribute(self.parentFrame, "width", self.closedWidth);
	UpdateUIPanelPositions();
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end


--------------------------------------------------
-- SIDE DRESS UP MODEL FRAME RESET BUTTON MIXIN
SideDressUpModelFrameResetButtonMixin = CreateFromMixins(DressUpModelFrameResetButtonMixin);

function SideDressUpModelFrameResetButtonMixin:OnLoad()
	self.model = self:GetParent().DressUpModel;
end

