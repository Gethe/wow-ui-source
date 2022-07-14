

local DefaultExtraActionStyle = "Interface\\ExtraButton\\Default";

function ExtraActionBar_OnLoad (self)
	self:SetFrameLevel(self:GetFrameLevel() + 2);
	self:SetAlpha(0.0)
end

function ExtraActionBar_Update()
	local bar = ExtraActionBarFrame;
	if ( HasExtraActionBar() ) then
		bar:Show();
		local texture = GetOverrideBarSkin() or DefaultExtraActionStyle;
		bar.button.style:SetTexture(texture);
		bar.button:UpdateUsable();
		ExtraAbilityContainer:AddFrame(bar, ExtraActionButtonPriority);
		bar.outro:Stop();
		bar.intro:Play();
	elseif( bar:IsShown() ) then
		bar.intro:Stop();
		bar.outro:Play();
	else
		ExtraAbilityContainer:RemoveFrame(self);
	end
end


function ExtraActionButtonKey(id, isDown)
	if not HasExtraActionBar() then
		return;
	end

	local button = _G["ExtraActionButton"..id];
	
	if isDown then
		if ( button:GetButtonState() == "NORMAL" ) then
			button:SetButtonState("PUSHED");
		end
		if (GetCVarBool("ActionButtonUseKeyDown")) then
			SecureActionButton_OnClick(button, "LeftButton");
			button:UpdateState();
		end
	else
		if ( button:GetButtonState() == "PUSHED" ) then
			button:SetButtonState("NORMAL");
			if (not GetCVarBool("ActionButtonUseKeyDown")) then
				SecureActionButton_OnClick(button, "LeftButton");
				button:UpdateState();
			end
		end
	end
end
