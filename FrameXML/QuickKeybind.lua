-- All funcions here need a fully qualified name for event handler inheritance to work properly.
QuickKeybindButtonTemplateMixin = {};

function QuickKeybindButtonTemplateMixin:QuickKeybindButtonOnClick(button, down)
	if ( KeybindFrames_InQuickKeybindMode() and button ~= "LeftButton" and button ~= "RightButton") then
		QuickKeybindFrame:OnKeyDown(button);
	end
end

function QuickKeybindButtonTemplateMixin:QuickKeybindButtonOnEnter()
	if ( KeybindFrames_InQuickKeybindMode() ) then
		QuickKeybindFrame:SetSelected(self.commandName, self);
		self:QuickKeybindButtonSetTooltip();
		self.oldUpdateScript = self:GetScript("OnUpdate");
		self:SetScript("OnUpdate", self.QuickKeybindButtonOnUpdate);
		self.changedUpdateScript = true;
		self.QuickKeybindHighlightTexture:SetAlpha(1);
	end
end

function QuickKeybindButtonTemplateMixin:QuickKeybindButtonOnLeave()
	if ( KeybindFrames_InQuickKeybindMode() ) then
		QuickKeybindFrame:SetSelected(nil, nil);
		local idleAlpha = 0.5;
		self.QuickKeybindHighlightTexture:SetAlpha(idleAlpha);
	end
	QuickKeybindTooltip:Hide();
	if ( self.changedUpdateScript ) then
		self:SetScript("OnUpdate", self.oldUpdateScript);
		self.changedUpdateScript = nil;
	end
end

function QuickKeybindButtonTemplateMixin:QuickKeybindButtonOnMouseWheel(delta)
	if ( KeybindFrames_InQuickKeybindMode() ) then
		QuickKeybindFrame:OnMouseWheel(delta);
	end
end

function QuickKeybindButtonTemplateMixin:QuickKeybindButtonSetTooltip(anchorToGameTooltip)
	if ( self.commandName and KeybindFrames_InQuickKeybindMode() ) then
		local parent = self:GetParent();
		if ( anchorToGameTooltip ) then
			QuickKeybindTooltip:SetOwner(GameTooltip, "ANCHOR_TOP", 0, 10);
		elseif ( parent == MultiBarBottomRight or parent == MultiBarRight or parent == MultiBarLeft ) then
			QuickKeybindTooltip:SetOwner(self, "ANCHOR_LEFT");
		else
			QuickKeybindTooltip:SetOwner(self, "ANCHOR_RIGHT");
		end
		GameTooltip_AddHighlightLine(QuickKeybindTooltip, GetBindingName(self.commandName));
		local key1, key2 = GetBindingKey(self.commandName);
		if ( key1 ) then
			GameTooltip_AddInstructionLine(QuickKeybindTooltip, key1);
			GameTooltip_AddNormalLine(QuickKeybindTooltip, ESCAPE_TO_UNBIND);
		else
			GameTooltip_AddErrorLine(QuickKeybindTooltip, NOT_BOUND);
			GameTooltip_AddNormalLine(QuickKeybindTooltip, PRESS_KEY_TO_BIND);
		end
		QuickKeybindTooltip:Show();
	end
end

function QuickKeybindButtonTemplateMixin:QuickKeybindButtonOnUpdate(elapsed)
	local parent = self:GetParent();
	local tooltipBuffer = 10;
	if ( parent == MultiBarRight or parent == MultiBarLeft ) then
		if ( QuickKeybindTooltip:IsShown() and GameTooltip:IsShown() and QuickKeybindTooltip:GetBottom() < GameTooltip:GetTop() + tooltipBuffer ) then
			local anchorToGameTooltip = true;
			self:QuickKeybindButtonSetTooltip(anchorToGameTooltip);
		end
	end
end