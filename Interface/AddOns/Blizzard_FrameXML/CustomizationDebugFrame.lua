
CUSTOMIZATIONDEBUGFRAME_UPDATE_TIME = 0.5;

function ToggleCustomizationDebugInfo()
	if ( CustomizationDebugFrame:IsShown() ) then
		CustomizationDebugFrame:Hide();
	else
		CustomizationDebugFrame:Show();
	end
end

function CustomizationDebugFrame_OnLoad(self)
	self.updateTime = 0;
end

function CustomizationDebugFrame_OnUpdate(self, elapsed)
	local updateTime = self.updateTime - elapsed;
	if ( updateTime <= 0 ) then
		updateTime = CUSTOMIZATIONDEBUGFRAME_UPDATE_TIME;
		CustomizationDebugFrameText:SetText(GetDebugTargetCustomizationInfo());
	end
	self.updateTime = updateTime;
end
