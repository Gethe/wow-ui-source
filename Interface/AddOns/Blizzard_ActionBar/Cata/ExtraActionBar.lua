local DefaultExtraActionStyle = "Interface\\ExtraButton\\Default";

function ExtraActionBar_OnLoad (self)
	self:RegisterEvent("UPDATE_EXTRA_ACTIONBAR");
	self:SetFrameLevel(self:GetFrameLevel() + 2);
	if ( HasExtraActionBar() ) then
		self:Show();
	end
	self:SetAlpha(0.0)
end


function ExtraActionBar_OnShow (self)
	local _, spellID = GetActionInfo(self.button.action);
	local texture = GetOverrideBarSkin() or DefaultExtraActionStyle;
	self.button.style:SetTexture(texture);
	UIParent_ManageFramePositions();
end


function ExtraActionBar_OnHide (self)
	UIParent_ManageFramePositions();
end

function ExtraActionBar_OnEvent (self, event, ...)
	if ( event == "UPDATE_EXTRA_ACTIONBAR" ) then
		if ( HasExtraActionBar() ) then
			self:Show();
			self.outro:Stop();
			self.intro:Play();
		elseif( self:IsShown() ) then
			self.intro:Stop();
			self.outro:Play();
		end
	end
end

function ExtraActionButtonKey(id, isDown)
	local button = _G["ExtraActionButton"..id];
	
	if isDown then
		if ( button:GetButtonState() == "NORMAL" ) then
			button:SetButtonState("PUSHED");
		end
		if (GetCVarBool("ActionButtonUseKeyDown")) then
			SecureActionButton_OnClick(button, "LeftButton");
			ActionButton_UpdateState(button);
		end
	else
		if ( button:GetButtonState() == "PUSHED" ) then
			button:SetButtonState("NORMAL");
			if (not GetCVarBool("ActionButtonUseKeyDown")) then
				SecureActionButton_OnClick(button, "LeftButton");
				ActionButton_UpdateState(button);
			end
		end
	end
end

