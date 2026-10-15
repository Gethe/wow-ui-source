function InputUtil.ShowInspectCursor()
	SetCursor("INSPECT_CURSOR");
end

function ShowInspectCursor()
	InputUtil.ShowInspectCursor();
end

function InputUtil.GetCursorPosition(parent)
	local x, y = GetCursorPosition();
	local scale = parent:GetEffectiveScale();
	return x / scale, y / scale;
end

function InputUtil.GetAnchorPositionAtCursor()
	local x, y = InputUtil.GetCursorPosition(GetAppropriateTopLevelParent());
	-- Cursor is relative to BL while frame coordinates are relative to TL.
	return x, (-GetScreenHeight() + y);
end

-- Interface Style

local secureexecuterange = secureexecuterange;

do
	local interfaceTransitionCallbacks = {};
	local interfaceTransitionCallbacksHighPrio = {};
	local interfaceTransistionListener = CreateFrame("FRAME");
	interfaceTransistionListener:SetForbidden();
	interfaceTransistionListener:RegisterEvent("INPUT_DEVICE_INTERFACE_TRANSITION");


	local function HandleTransition(subscriber, transitionScheme, newInterfaceType, oldInterfaceType)
		local transitioned = false;

		local oldInterfaceScheme = nil;
		if (oldInterfaceType ~= nil) then
			oldInterfaceScheme = transitionScheme[oldInterfaceType];
		end
		local newInterfaceScheme = nil;
		if (newInterfaceType ~= nil) then
			newInterfaceScheme = transitionScheme[newInterfaceType];
		end

		-- transition out of the existing interface style
		if (oldInterfaceScheme ~= nil and oldInterfaceScheme.Uninit) then
			oldInterfaceScheme.Uninit();
			transitioned = true;
		end

		-- if transitioning into a valid interface style
		if (newInterfaceScheme ~= nil) then
			-- set up the transitioner for the new style if that has not yet happened
			if (newInterfaceScheme.isSetup == false) then

				if newInterfaceScheme.Setup then
					newInterfaceScheme.Setup();
					newInterfaceScheme.isSetup = true; -- ensure transitioner will not be set up twice
				end
			end

			-- transition to the new interface style
			if (newInterfaceScheme.Init) then
				newInterfaceScheme.Init(newInterfaceScheme);
				transitioned = true;
			end
		end

		-- actually handle the default transition style, if it exists
		if not transitioned and transitionScheme.Default then
			transitionScheme.Default(newInterfaceType, oldInterfaceType);
		end
	end

	interfaceTransistionListener:SetScript("OnEvent", function(self, event, ...)
		if (event == "INPUT_DEVICE_INTERFACE_TRANSITION") then
			local newInterfaceType, oldInterfaceType  = ...;
			secureexecuterange(interfaceTransitionCallbacksHighPrio, HandleTransition, newInterfaceType, oldInterfaceType);
			secureexecuterange(interfaceTransitionCallbacks, HandleTransition, newInterfaceType, oldInterfaceType);
		end
	end);

	local function GetCallbackTable(subscriber)
		if interfaceTransitionCallbacksHighPrio[subscriber] ~= nil then
			return interfaceTransitionCallbacksHighPrio;
		end
		return interfaceTransitionCallbacks;
	end

	local function ConstructTransitionStyle(cbTbl, subscriber, transitionStyle)
		if (cbTbl[subscriber][transitionStyle] == nil) then
			cbTbl[subscriber][transitionStyle] = {
				isSetup = false,
				Setup = nil,
				Init = nil,
				Uninit = nil,
			};
		end
	end
	local function RegisterInit(subscriber, transitionStyle, callback)
		local cbTbl = GetCallbackTable(subscriber);
		ConstructTransitionStyle(cbTbl, subscriber, transitionStyle);
		cbTbl[subscriber][transitionStyle].Init = callback;

		-- Work around to handle the case that the subscriber is registering an init for the current interface mode
		if (transitionStyle == InputUtil.GetCurrentInterfaceStyle()) then
			callback();
		end
	end
	local function RegisterUninit(subscriber, transitionStyle, callback)
		local cbTbl = GetCallbackTable(subscriber);
		ConstructTransitionStyle(cbTbl, subscriber, transitionStyle);
		cbTbl[subscriber][transitionStyle].Uninit = callback;
	end
	local function RegisterSetup(subscriber, transitionStyle, callback)
		local cbTbl = GetCallbackTable(subscriber);
		ConstructTransitionStyle(cbTbl, subscriber, transitionStyle);
		cbTbl[subscriber][transitionStyle].Setup = callback;

		-- Work around to handle the case that the subscriber is registering a setup for the current interface mode
		if (transitionStyle == InputUtil.GetCurrentInterfaceStyle()) then
			callback();
			cbTbl[subscriber][transitionStyle].isSetup = true;
		end
	end

	-- Register for transitioners
	function InputUtil.RegisterForInterfaceTransitions(subscriber, defaultCallbackHandler)
		if interfaceTransitionCallbacks[subscriber] == nil then
			interfaceTransitionCallbacks[subscriber] = {};
			interfaceTransitionCallbacks[subscriber].Default = defaultCallbackHandler;
		else
			assert(interfaceTransitionCallbacks[subscriber].Default == defaultCallbackHandler);
		end
	end

	function InputUtil.RegisterForHighPrioInterfaceTransitions(subscriber, defaultCallbackHandler)
		if interfaceTransitionCallbacksHighPrio[subscriber] == nil then
			interfaceTransitionCallbacksHighPrio[subscriber] = {};
			interfaceTransitionCallbacksHighPrio[subscriber].Default = defaultCallbackHandler;
		else
			assert(interfaceTransitionCallbacksHighPrio[subscriber].Default == defaultCallbackHandler);
		end
	end

	-- MKB transitions
	function InputUtil.RegisterMKBInit(subscriber, callback)
		RegisterInit(subscriber, Enum.InputDeviceInterfaceType.Mkb, callback);
	end
	function InputUtil.RegisterMKBUninit(subscriber, callback)
		RegisterUninit(subscriber, Enum.InputDeviceInterfaceType.Mkb, callback);
	end
	function InputUtil.RegisterMKBSetup(subscriber, callback)
		RegisterSetup(subscriber, Enum.InputDeviceInterfaceType.Mkb, callback);
	end

	-- Gamepad transitions
	function InputUtil.RegisterGamepadInit(subscriber, callback)
		RegisterInit(subscriber, Enum.InputDeviceInterfaceType.Gamepad, callback);
	end
	function InputUtil.RegisterGamepadUninit(subscriber, callback)
		RegisterUninit(subscriber, Enum.InputDeviceInterfaceType.Gamepad, callback);
	end
	function InputUtil.RegisterGamepadSetup(subscriber, callback)
		RegisterSetup(subscriber, Enum.InputDeviceInterfaceType.Gamepad, callback);
	end

	-- Register to just get sent the event
	function InputUtil.RegisterInterfaceTransitionCallback(callback)
		-- handle legacy case of there being no key submitted
		table.insert(interfaceTransitionCallbacks, { Default = callback });
	end

end

do
	local gamepadDeviceConnectedCallbacks = {};
	local gamepadDeviceConnectedListener = CreateFrame("FRAME");
	gamepadDeviceConnectedListener:SetForbidden();
	gamepadDeviceConnectedListener:RegisterEvent("GAME_PAD_CONNECTED");

	local function CallGamepadDeviceConnectedCallback(index, callback)
		callback();
	end

	gamepadDeviceConnectedListener:SetScript("OnEvent", function(self, event, ...)
		if (event == "GAME_PAD_CONNECTED") then
			secureexecuterange(gamepadDeviceConnectedCallbacks, CallGamepadDeviceConnectedCallback);
		end
	end);

	function InputUtil.RegisterGamepadDeviceConnectedCallback(callback)
		table.insert(gamepadDeviceConnectedCallbacks, callback);
	end
end

function InputUtil:Transition(transitionScheme, newInterfaceType, oldInterfaceType)
	if (oldInterfaceType and transitionScheme[oldInterfaceType] and transitionScheme[oldInterfaceType].Uninit) then
		transitionScheme[oldInterfaceType].Uninit(transitionScheme[oldInterfaceType]);
	end

	if (newInterfaceType and transitionScheme[newInterfaceType] and transitionScheme[newInterfaceType].Init) then
		transitionScheme[newInterfaceType].Init(transitionScheme[newInterfaceType]);
	end
end

function InputUtil.GetCursorDelta(parent)
	local x, y = GetCursorDelta();
	local scale = parent:GetEffectiveScale();
	return x / scale, y / scale;
end

function InputUtil.IsMouseOver(region, topOffset, bottomOffset, leftOffset, rightOffset)
	return region:IsMouseOver(topOffset, bottomOffset, leftOffset, rightOffset);
end

function InputUtil.CursorUpdate(region)
	if ( IsModifiedClick("DRESSUP") and region.hasItem ) then
		InputUtil.ShowInspectCursor();
	else
		ResetCursor();
	end
end

function CursorUpdate(region)
	InputUtil.CursorUpdate(region);
end

function InputUtil.CursorOnUpdate(region)
	if ( GameTooltip:IsOwned(region) ) then
		InputUtil.CursorUpdate(region);
	end
end

function CursorOnUpdate(region)
	InputUtil.CursorOnUpdate(region);
end

function InputUtil.AnchorRegionToCursor(region, point)
	local parent = GetAppropriateTopLevelParent();
	local x, y = InputUtil.GetCursorPosition(parent);

	-- Accounts for the letterboxing that causes the UI origin to be shifted
	-- closer to the position of the cursor.
	local _, _, _, pointX, _ = parent:GetPointByName("TOPLEFT");
	if pointX then
		x = x - pointX;
	end

	region:ClearAllPoints();
	region:SetPoint(point, parent, "BOTTOMLEFT", x, y);
end
