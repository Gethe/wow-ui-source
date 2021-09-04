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
	self.modelScene = self:GetParent().ModelScene;
end

function DressUpModelFrameResetButtonMixin:OnClick()
	self.modelScene:Reset();

	local playerActor = self.modelScene:GetPlayerActor();

	if (playerActor) then
		playerActor:SetSheathed(false);
		playerActor:Dress();
	end	
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end


--------------------------------------------------
-- DRESS UP MODEL FRAME CLOSE BUTTON MIXIN
DressUpModelFrameCloseButtonMixin = {};

function DressUpModelFrameCloseButtonMixin:OnClick()
	HideUIPanel(self:GetParent());
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

function DressUpModelFrameFrameMixin:OnDressModel()
	if self.OutfitDropDown then	
		if not self.gotDressed then
			self.gotDressed = true;
			C_Timer.After(0, function() self.gotDressed = nil; self.OutfitDropDown:UpdateSaveButton(); end);
		end
	end
end

--------------------------------------------------
-- SIDE DRESS UP MODEL FRAME FRAME MIXIN
SideDressUpModelFrameFrameMixin = {};

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

TransmogAndMountDressupFrameMixin = {};

function TransmogAndMountDressupFrameMixin:OnLoad()
	local checkButton = self.ShowMountCheckButton; 
	checkButton.text:SetFontObject("GameFontNormal");
	checkButton.text:ClearAllPoints(); 
	checkButton.text:SetPoint("RIGHT", checkButton, "LEFT"); 
	checkButton.text:SetText(TRANSMOG_AND_MOUNT_DRESSUP_FRAME_SHOW_MOUNT);
end 

function TransmogAndMountDressupFrameMixin:OnHide()
	self.mountID = nil; 
	self.transmogSetID = nil; 
	self.removeWeapons = nil; 
	self.ShowMountCheckButton:SetChecked(false);
end 

function TransmogAndMountDressupFrameMixin:RemoveWeapons()
	for actor in self.ModelScene:EnumerateActiveActors() do
		local mainHandSlotID = GetInventorySlotInfo("MAINHANDSLOT");
		local offHandSlotID = GetInventorySlotInfo("SECONDARYHANDSLOT");
		actor:UndressSlot(mainHandSlotID);
		actor:UndressSlot(offHandSlotID);
	end
end 

function TransmogAndMountDressupFrameMixin:CheckButtonOnClick()
	if(self.ShowMountCheckButton:GetChecked()) then
		DressUpMount(self.mountID, self);
	else
		local sources = C_TransmogSets.GetAllSourceIDs(self.transmogSetID);
		DressUpTransmogSet(sources, self);
	end

	if(self.removeWeapons) then 
		self:RemoveWeapons(); 
	end 
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end
