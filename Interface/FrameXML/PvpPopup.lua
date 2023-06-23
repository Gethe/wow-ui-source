PVPReadyPopupMixin = { };

local ROLE_BUTTON_BASE_XOFFSET = 22;
local ROLE_BUTTON_WIDTH = 55; 
local POPUP_EXPIRATION_TIME = 5;

function PVPReadyPopupMixin:OnLoad()
	self:RegisterEvent("PVP_ROLE_POPUP_SHOW");
	self:RegisterEvent("PVP_ROLE_POPUP_HIDE");
	self:RegisterEvent("PLAYER_JOINED_PVP_MATCH");
	self.RolePool = CreateFramePool("FRAME", self, "PvpRoleButtonWithCountTemplate");
end		

function PVPReadyPopupMixin:OnEvent(event, ...)
	if(event == "PVP_ROLE_POPUP_SHOW") then 
		self.startHide = false;	
		local readyCheckInfo = ...;
		self:Setup(readyCheckInfo); 
	elseif(event == "PLAYER_JOINED_PVP_MATCH") then 
		if(self:IsShown()) then 
			StaticPopupSpecial_Hide(PVPReadyPopup);
		end		
	elseif (event == "PVP_ROLE_POPUP_HIDE") then 
		if(self:IsShown()) then 
			local readyCheckInfo = ...;
			self.startHide = true; 
			self:Setup(readyCheckInfo); 
		end 
	end		
end

function PVPReadyPopupMixin:Reset()
	self.RolePool:ReleaseAll();
	self.lastRole = nil;
	
	self.RolelessButton:Hide();
end

function PVPReadyPopupMixin:GetCenterOffsetBasedOffNumRoles(roles)
	local countRoles = 0; 
	for _, roleInfo in ipairs(roles) do 
		if(roleInfo.totalRole > 0) then 
			countRoles = countRoles + 1;
		end 
	end

	local totalWidth = self:GetWidth(); 
	local widthOfRoles = ROLE_BUTTON_WIDTH * countRoles; 
	local usedRoleWidth = (ROLE_BUTTON_BASE_XOFFSET * (countRoles - 1)) + widthOfRoles; --The total used space of the roles buttons (Including paddng in between) 
	local centerOffset = (totalWidth - usedRoleWidth) / (2); --Trying to get the offset for just one side. 
	return centerOffset;
end		

function PVPReadyPopupMixin:SetupRoleButtons(roles)
	local centerOffset = self:GetCenterOffsetBasedOffNumRoles(roles);

	for _, roleInfo in ipairs(roles) do 
		if(roleInfo.totalRole > 0) then 
			self.lastRole = self:SetupRole(roleInfo, centerOffset);
		end 
	end	

	if(self.lastRole == nil) then 
		StaticPopupSpecial_Hide(PVPReadyPopup);
	end 
end

function PVPReadyPopupMixin:SetupRolelessButton(readyCheckInfo)
	if (readyCheckInfo.totalNumPlayers > 0) then
		self.RolelessButton:Setup(readyCheckInfo);
	end
end

function PVPReadyPopupMixin:Setup(readyCheckInfo)
	self:Reset();

	if (#readyCheckInfo.roles > 0) then
		self:SetupRoleButtons(readyCheckInfo.roles);
	else
		self:SetupRolelessButton(readyCheckInfo);
	end

	StaticPopupSpecial_Show(PVPReadyPopup);

	if(self.startHide) then 
		self.myExpirationTime = POPUP_EXPIRATION_TIME + GetTime();
		self:SetScript("OnUpdate", self.OnUpdate);
	else 
		self:SetScript("OnUpdate", nil);
	end
end

function PVPReadyPopupMixin:OnUpdate(elapsed)
	local timeRemaining = self.myExpirationTime - GetTime();
	if ( timeRemaining < 0 ) then
		StaticPopupSpecial_Hide(PVPReadyPopup);
		self.startHide = false; 
		self:SetScript("OnUpdate", nil);
	end
end 

function PVPReadyPopupMixin:SetupRole(roleInfo, centerOffset) 
	local roleButton = self.RolePool:Acquire(); 
	if (not self.lastRole) then 
		roleButton:SetPoint("LEFT", centerOffset, 40); 
	else 
		roleButton:SetPoint("LEFT", self.lastRole, "RIGHT", ROLE_BUTTON_BASE_XOFFSET, 0);
	end
	roleButton:Setup(roleInfo);
	return roleButton;
end		

PvpRoleButtonWithCountMixin = { };
function PvpRoleButtonWithCountMixin:Setup(roleInfo)
	local showDisabled = false;
	self.Texture:SetAtlas(GetIconForRole(roleInfo.role, showDisabled), TextureKitConstants.IgnoreAtlasSize);
	self.Count:SetFormattedText(PLAYERS_FOUND_OUT_OF_MAX, roleInfo.totalAccepted, roleInfo.totalRole);
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 1); 
	if(roleInfo.totalDeclined > 0) then 
		self.StatusIcon:SetAtlas(READY_CHECK_NOT_READY_TEXTURE, TextureKitConstants.IgnoreAtlasSize);
	elseif(roleInfo.totalAccepted == roleInfo.totalRole) then 
		self.StatusIcon:SetAtlas(READY_CHECK_READY_TEXTURE, TextureKitConstants.IgnoreAtlasSize);
	else 
		self.StatusIcon:SetAtlas(READY_CHECK_WAITING_TEXTURE, TextureKitConstants.IgnoreAtlasSize);
	end 
	self:Show(); 		
end

PvpRolelessButtonMixin = { };
function PvpRolelessButtonMixin:OnLoad()
	self.Texture:SetAtlas("UI-LFG-RoleIcon-Generic", TextureKitConstants.IgnoreAtlasSize);
	self.StatusIcon:SetAtlas(READY_CHECK_NOT_READY_TEXTURE, TextureKitConstants.IgnoreAtlasSize);
end

function PvpRolelessButtonMixin:Setup(readyCheckInfo)
	self.Count:SetFormattedText(PLAYERS_FOUND_OUT_OF_MAX, readyCheckInfo.numPlayersAccepted, readyCheckInfo.totalNumPlayers);
	self.StatusIcon:SetShown(readyCheckInfo.numPlayersDeclined > 0);
	self:Show();
end