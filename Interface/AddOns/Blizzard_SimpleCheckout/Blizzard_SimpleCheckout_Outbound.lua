-- Outbound loads under the global environment but needs to put the outbound table into the secure environment
local secureEnv = GetCurrentEnvironment();
SwapToGlobalEnvironment();
local SimpleCheckoutOutbound = {};
secureEnv.SimpleCheckoutOutbound = SimpleCheckoutOutbound;
secureEnv = nil;	--This file shouldn't be calling back into secure code.

function SimpleCheckoutOutbound.GetAppropriateTopLevelParent()
	return securecall("GetAppropriateTopLevelParent");
end

function SimpleCheckoutOutbound.HousingEditorFrameIsShown()
	return securecallfunction(HouseEditorFrame_IsShown);
end

function SimpleCheckoutOutbound.GetHousingEditorFrame()
	return securecallfunction(HouseEditorFrame_GetFrame);
end
