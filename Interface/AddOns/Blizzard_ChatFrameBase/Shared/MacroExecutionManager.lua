local _, addonTbl = ...;

if C_Glue.IsOnGlueScreen() then
	return;
end

-- Set up a private editbox to handle macro execution.

local function GetDefaultChatEditBox(field)
	return DEFAULT_CHAT_FRAME.editBox;
end

addonTbl.MacroEditBox = Mixin(CreateFrame("EditBox"), ChatFrameEditBoxBaseMixin);
addonTbl.MacroEditBox:Hide();

local setMacroExecutionCallback = C_Macro.SetMacroExecuteLineCallback;
C_Macro.SetMacroExecuteLineCallback = nil; -- explicitly only set this once per ui-instance

EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function()
	setMacroExecutionCallback(function(line)
		local defaultEditBox = securecall(GetDefaultChatEditBox);
		local macroEditBox = addonTbl.MacroEditBox;
		macroEditBox:SetAttribute("chatType", defaultEditBox:GetAttribute("chatType"));
		macroEditBox:SetAttribute("tellTarget", defaultEditBox:GetAttribute("tellTarget"));
		macroEditBox:SetAttribute("channelTarget", defaultEditBox:GetChannelTarget());
		macroEditBox:SetText(line);
		macroEditBox:SendText();
	end);
end);
