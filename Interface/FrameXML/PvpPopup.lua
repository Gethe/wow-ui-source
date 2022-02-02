PVPReadyPopupMixin = { };

local ROLE_BUTTON_BASE_XOFFSET = 22;
local ROLE_BUTTON_WIDTH = 55; 
local POPUP_EXPIRATION_TIME = 5;

function PVPReadyPopupMixin:OnLoad()
	self:RegisterEvent("PVP_ROLE_POPUP_SHOW");
	self:RegisterEvent("PVP_ROLE_POPUP_HIDE");
	self:RegisterEvent("PVP_ROLE_POPUP_JOINED_MATCH");
	self.RolePool = CreateFramePool("FRAME", self, "PvpRoleButtonWithCountTemplate");
end		

function PVPReadyPopupMixin:OnEvent(event, ...)
	if(event == "PVP_ROLE_POPUP_SHOW") then 
		self.startHide = false;	
		local roles = ...; 
		self:Setup(roles); 
	elseif(event == "PVP_ROLE_POPUP_JOINED_MATCH") then 
		if(self:IsShown()) then 
			StaticPopupSpecial_Hide(PVPReadyPopup);
		end		
	elseif (event == "PVP_ROLE_POPUP_HIDE") then 
		if(self:IsShown()) then 
			local roles = ...;
			self.startHide = true; 
			self:Setup(roles); 
		end 
	end		
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

function PVPReadyPopupMixin:Setup(roles)
	self.RolePool:ReleaseAll();
	self.lastRole = nil; 
	local centerOffset = self:GetCenterOffsetBasedOffNumRoles(roles);

	for _, roleInfo in ipairs(roles) do 
		if(roleInfo.totalRole > 0) then 
			self.lastRole = self:SetupRole(roleInfo, centerOffset);
		end 
	end	

	if(self.lastRole == nil) then 
		StaticPopupSpecial_Hide(PVPReadyPopup);
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
	self.Texture:SetTexCoord(GetTexCoordsForRole(roleInfo.role));
	self.Count:SetFormattedText(PLAYERS_FOUND_OUT_OF_MAX, roleInfo.totalAccepted, roleInfo.totalRole);
	self:SetFrameLevel(self:GetParent():GetFrameLevel() + 1); 
	if(roleInfo.totalDeclined > 0) then 
		self.StatusIcon:SetTexture(READY_CHECK_NOT_READY_TEXTURE);
	elseif(roleInfo.totalAccepted == roleInfo.totalRole) then 
		self.StatusIcon:SetTexture(READY_CHECK_READY_TEXTURE);
	else 
		self.StatusIcon:SetTexture(READY_CHECK_WAITING_TEXTURE);
	end 
	self:Show(); 		
end