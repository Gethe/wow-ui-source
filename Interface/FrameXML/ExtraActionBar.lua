

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
		if KeybindFrames_InQuickKeybindMode() then
			ExtraActionBar_ForceEmpty();
		else
			bar.intro:Stop();
			bar.outro:Play();
		end
	else
		ExtraAbilityContainer:RemoveFrame(self);
	end
end

function ExtraActionBar_ForceEmpty()
	local bar = ExtraActionBarFrame;
	bar.button.style:Hide();
	bar.button.icon:SetAlpha(0);
end

function ExtraActionBar_ForceShowIfNeeded()
	local bar = ExtraActionBarFrame;
	if not bar:IsShown() then
		ExtraActionBar_ForceEmpty();
		bar.button:Show();
		bar:Show();
		bar.button:UpdateUsable();
		ExtraAbilityContainer:AddFrame(bar, ExtraActionButtonPriority);
		bar.outro:Stop();
		bar.intro:Play();
	end
end

function ExtraActionBar_CancelForceShow()
	local bar = ExtraActionBarFrame;
	if not HasExtraActionBar() and bar:IsShown() then
		bar.button.style:Show();
		bar.button.icon:SetAlpha(1);
		bar:Hide();
		bar:SetAlpha(0.0);
		bar:Hide();
		ExtraAbilityContainer:RemoveFrame(bar);
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
