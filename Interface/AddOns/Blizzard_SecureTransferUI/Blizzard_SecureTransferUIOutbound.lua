-- Outbound loads under the global environment but needs to put the outbound table into the secure environment
local secureEnv = GetCurrentEnvironment();
SwapToGlobalEnvironment();
local SecureTransferOutbound = {};
secureEnv.SecureTransferOutbound = SecureTransferOutbound;
secureEnv = nil;	--This file shouldn't be calling back into secure code.

function SecureTransferOutbound.UpdateSendMailButton()
    securecall("SendMailFrame_EnableSendMailButton");
end

function SecureTransferOutbound.GetAppropriateTopLevelParent()
	return securecall("GetAppropriateTopLevelParent");
end

function SecureTransferOutbound.GetCatalogShopTopUpFrame()
	return securecallfunction(CatalogShopTopUpFrame_GetFrame);
end

local function GetHearthsteelCurrencyCode()
	return Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE;
end

function SecureTransferOutbound.GetHearthsteelVirtualCurrencyCode()
	return securecallfunction(GetHearthsteelCurrencyCode);
end

function SecureTransferOutbound.HideCatalogShopTopUpFrame()
	if CatalogShopTopUpFlowInboundInterface then
		CatalogShopTopUpFlowInboundInterface.SetShown(false);
	end
end

function SecureTransferOutbound.SetupGamepad(frame)
	if InputUtil.IsGamepadUIEnabled() then
		securecallfunction(function()
			local function Click(button)
				button:MouseDown();
				button:MouseUp();
			end

			frame.okayGamepadIcon = GamepadMode.AddGamepadIconToButton(frame.Button1, GAMEPAD_FACE_BOTTOM);
			frame.cancelGamepadIcon = GamepadMode.AddGamepadIconToButton(frame.Button2, GAMEPAD_FACE_RIGHT);
			GamepadMode.SetGamepadIconShown(frame.okayGamepadIcon, false);
			GamepadMode.SetGamepadIconShown(frame.cancelGamepadIcon, false);

			frame.bindings = GamepadMode.CreateBindingGroup("SeceureTransferDialog");
			frame.bindings:AddFunctionBinding(GAMEPAD_FACE_BOTTOM, GenerateClosure(Click, frame.Button1));
			frame.bindings:AddFunctionBinding(GAMEPAD_FACE_RIGHT, GenerateClosure(Click, frame.Button2));
		end);
	end
end

function SecureTransferOutbound.FrameShown(frame)
	if InputUtil.IsGamepadUIEnabled() then
		securecallfunction(function()
			local isPopup = true;
			GamepadMode.FrameControlsManager:FrameShown(frame, isPopup);
		end);
	end
end

function SecureTransferOutbound.FrameHidden(frame)
	if InputUtil.IsGamepadUIEnabled() then
		securecallfunction(function()
			GamepadMode.FrameControlsManager:FrameHidden(frame);
		end);
	end
end

function SecureTransferOutbound.FocusGamepad(frame)
	securecallfunction(function()
		GamepadMode.ActivateBindingGroup(frame.bindings);
		GamepadMode.SetGamepadIconShown(frame.okayGamepadIcon, true);
		GamepadMode.SetGamepadIconShown(frame.cancelGamepadIcon, true);
	end);
end

function SecureTransferOutbound.UnfocusGamepad(frame)
	securecallfunction(function()
		GamepadMode.DeactivateBindingGroup(frame.bindings);
		GamepadMode.SetGamepadIconShown(frame.okayGamepadIcon, false);
		GamepadMode.SetGamepadIconShown(frame.cancelGamepadIcon, false);
	end);
end
