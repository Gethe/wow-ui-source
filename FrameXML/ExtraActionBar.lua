

local DefaultExtraActionStyle = "Interface\\ExtraButton\\Default";

function ExtraActionBar_OnLoad (self)
	self:SetFrameLevel(self:GetFrameLevel() + 2);
	self:SetAlpha(0.0)
end

function ExtraActionBar_Update()
	if ( HasExtraActionBar() ) then
		ExtraActionBarFrame:Show();
		ActionButton_UpdateUsable(self.button);
	end
end


function ExtraActionBar_OnShow (self)
	local texture = GetOverrideBarSkin() or DefaultExtraActionStyle;
	self.button.style:SetTexture(texture);
	ActionButton_UpdateUsable(self.button);
	UIParent_ManageFramePositions();
end


function ExtraActionBar_OnHide (self)
	UIParent_ManageFramePositions();
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
