-- Inbound files need to load under the global environment
SwapToGlobalEnvironment();

--All of these functions should be safe to call by tainted code. They should only communicate with secure code via SetAttribute and GetAttribute.
SimpleCheckoutInboundInterface = {};

function SimpleCheckoutInboundInterface.IsShown()
	return SimpleCheckout:GetAttribute("isshown");
end

function SimpleCheckoutInboundInterface.EscapePressed()
	-- Escape Key Pressed can get close Housing, Shop, and other UIs that have brought up SimpleCheckout,
	-- from UIParent function ToggleGameMenu(), and we don't want Esc to close SimpleCheckout
	if SimpleCheckout:GetAttribute("isshown") then
		return true;
	end
	return false;
end
