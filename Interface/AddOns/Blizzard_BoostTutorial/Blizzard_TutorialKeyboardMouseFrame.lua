NPE_TutorialKeyboardMouseFrame = {};

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:Initialize()
	self.Dimmed = false;
	self.PointerFrameID = nil;
	self.ActionBarCalloutFrame = nil;
	self.ActionBarPointerFrameID = nil;
	self.IsLocalized = false;
	self.Frame = NPE_TutorialKeyboardMouseFrame_Frame;
	self.HelpFrame = NPE_TutorialInterfaceHelp;

	Dispatcher:RegisterEvent("UI_SCALE_CHANGED", self);
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:LocalizeMovementKeyText()
	if (self.IsLocalized) then return; end

	local binds = {
		"MOVEFORWARD",
		"TURNLEFT",
		"MOVEBACKWARD",
		"TURNRIGHT",
	}

	for i, v in pairs(binds) do
		local fontString = self.Frame["txtKey_" .. v];
		local text = GetBindingKey(v);
		if (text and (text ~= "")) then
			fontString:SetText(text);
		end
	end

	self.IsLocalized = true;
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:Show()
	self:LocalizeMovementKeyText();

	self.Frame:Show();
	NPE_TutorialPointerFrame:Hide(self.PointerFrameID);

	-- Set scale
	self:UpdateScale();
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:Hide()
	self.Frame:Hide();
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:UI_SCALE_CHANGED()
	if (NewPlayerExperience:GetIsActive()) then
		self:UpdateScale();
	end
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:UpdateScale()
	local ratio = self.Frame:GetHeight() / UIParent:GetHeight();
	if (ratio > 0.3) then
		self.Frame:SetScale(0.3 / ratio);
	else
		self.Frame:SetScale(1);
	end
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:_Dim()
	self.Frame.Anim_UnDim:Stop();
	self.Frame.Anim_Dim:Play();
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:_UnDim()
	self.Frame.Anim_Dim:Stop();
	self.Frame.Anim_UnDim:Play();
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:Dim()
	self.Dimmed = true;
	self:_Dim();
	NPE_TutorialPointerFrame:Hide(self.PointerFrameID);
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:UnDim()
	self.Dimmed = false;
	self:_UnDim();
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:HideHelpFrame()
	if (self.HelpFrame:IsVisible()) then
		self.HelpFrame:Hide();
		return true;
	end

	return false;
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:ShowHelpFrame()
	if (not NewPlayerExperience:GetIsActive()) then
		return false;
	end

	if (not self.HelpFrame:IsVisible()) then
		self.HelpFrame:Show();
		self.HelpFrame.Anim_In:Play();
		return true;
	end

	return false;
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:MainFrame_OnHide()
	local wasShown = self:ShowHelpFrame();

	if (wasShown) then
		self.PointerFrameID = NPE_TutorialPointerFrame:Show(NPE_SHOWINTERFACEHELP, "DOWN", self.HelpFrame.btnOpen, 0, -10);
		C_Timer.After(5, function() NPE_TutorialPointerFrame:Hide(self.PointerFrameID) end);
	end
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:BtnShow_OnClick()
	if (self.Frame:IsVisible()) then
		self:Hide();
	else
		self:Show();
	end
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:ActionBarHitFrame_OnEnter(frame)
	self.ActionBarCalloutFrame = NPE_TutorialCallout:Show();
	self.ActionBarCalloutFrame:SetPoint("TOPLEFT", ActionButton1, -10, 10);
	self.ActionBarCalloutFrame:SetPoint("BOTTOMRIGHT", ActionButton4, 10, -10);

	if (not Tutorials.ActionBarCallout.IsActive) then
		self.ActionBarPointerFrameID = NPE_TutorialPointerFrame:Show(NPE_ACTIONBARCALLOUT, "DOWN", self.ActionBarCalloutFrame);
	end
end

-- ------------------------------------------------------------------------------------------------------------
function NPE_TutorialKeyboardMouseFrame:ActionBarHitFrame_OnExit(frame)
	if (self.ActionBarCalloutFrame) then
		NPE_TutorialCallout:Hide(self.ActionBarCalloutFrame);
	end

	NPE_TutorialPointerFrame:Hide(self.ActionBarPointerFrameID);
end