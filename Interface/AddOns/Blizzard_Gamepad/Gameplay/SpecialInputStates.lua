--[[
	Handles gamepad configuration for special cases
]]

-- Allow left stick movement input to cancel farsight-like abilities
local function SetupFarsightControls()
	local inputButton = CreateFrame("BUTTON", nil, UIParent);
	inputButton:EnableGamePadStick(true);
	inputButton:HookScript("OnGamePadStick", function(self, button)
		if (button == "Left") then
			SpellStopCasting();
			self:Hide();
		end
		return true;
	end)
	inputButton:Hide();

	EventRegistry:RegisterFrameEventAndCallback("PLAYER_FARSIGHT_FOCUS_CHANGED", function()
		-- Only enable move-to-cancel for relevant abilities, this event is also used for any forced camera reposition such as Eye of Acherus control
		if C_UnitAuras.GetPlayerAuraBySpellID(6196) or C_UnitAuras.GetPlayerAuraBySpellID(6197) then -- 6196 = Shaman Far Sight, 6197 = Hunter Eagle Eye
			inputButton:Show();
		end
	end)
end

SetupFarsightControls();
