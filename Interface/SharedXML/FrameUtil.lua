
---------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
local _, tbl = ...;

if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	end

	setfenv(1, tbl);
end
----------------

FrameUtil = {};

function FrameUtil.RegisterUpdateFunction(frame, frequencySeconds, func)
	-- Prevents the OnUpdate handler from running the same frame it was
	-- removed.
	frame.canUpdate = true;

	local elapsed = frequencySeconds;
	frame:SetScript("OnUpdate", function(self, dt)
		if self.canUpdate then
			elapsed = elapsed - dt;
			if elapsed <= 0 then
				elapsed = frequencySeconds;
				func(frame, dt);
			end
		end
	end);
end

function FrameUtil.UnregisterUpdateFunction(frame)
	frame.canUpdate = false;
	frame:SetScript("OnUpdate", nil);
end

function FrameUtil.RegisterFrameForEvents(frame, events)
	for i, event in ipairs(events) do
		frame:RegisterEvent(event);
	end
end

function FrameUtil.UnregisterFrameForEvents(frame, events)
	for i, event in ipairs(events) do
		frame:UnregisterEvent(event);
	end
end

function FrameUtil.RegisterFrameForUnitEvents(frame, events, ...)
	for i, event in ipairs(events) do 
		frame:RegisterUnitEvent(event, ...);
	end
end

function FrameUtil.DialogStyleGlobalMouseDown(frame, buttonName, ...)
	local mouseFocus = GetMouseFocus();
	if DoesAncestryInclude(frame, mouseFocus) then
		return;
	end

	for i = 1, select("#", ...) do
		local alternateFrame = select(i, ...);
		if DoesAncestryInclude(alternateFrame, mouseFocus) then
			return;
		end
	end

	frame:Hide();
end

local StandardScriptHandlerSet = {
	OnLoad = true,
	OnShow = true,
	OnHide = true,
	OnEvent = true,
	OnEnter = true,
	OnLeave = true,
	OnClick = true,
	OnDragStart = true,
	OnReceiveDrag = true,

	-- Other scripts can/should be added here as needed.

	-- Many OnUpdates are set dynamically. Leave this off for now.
	-- OnUpdate = false,
};

-- ... is a list of tables to mixin.
function FrameUtil.SpecializeFrameWithMixins(frame, ...)
	Mixin(frame, ...);
	FrameUtil.ReflectStandardScriptHandlers(frame);
end

function FrameUtil.ReflectStandardScriptHandlers(frame)
	for scriptHandlerKey, shouldBeSet in pairs(StandardScriptHandlerSet) do
		local scriptHandler = frame[scriptHandlerKey];
		if scriptHandler ~= nil then
			frame:SetScript(scriptHandlerKey, scriptHandler);
		end
	end

	if frame.OnLoad then
		frame:OnLoad();
	end

	if frame.OnShow and frame:IsVisible() then
		frame:OnShow();
	end
end

-- This doesn't strictly speaking require a frame, but that's the likely usage of it so I'm leaving it here for now.
function FrameUtil.RegisterForVariablesLoaded(frame, loadMethod)
	if frame.savedVariablesEventRegistered then
		error("Cannot re-register for variables loaded.");
		return;
	end

	frame.savedVariablesEventRegistered = true;

	local function VariablesLoadedCallback(callbackSelf)
		loadMethod(frame);
	end

	EventUtil.ContinueOnVariablesLoaded(VariablesLoadedCallback);
end

-- Only expected to return differently in glues and in-game.
function FrameUtil.GetRootParent(frame)
	local parent = frame:GetParent();
	while parent do
		local nextParent = parent:GetParent();
		if not nextParent then
			break;
		end
		parent = nextParent;
	end
	return parent;
end

function DoesAncestryInclude(ancestry, frame)
	if ancestry then
		local currentFrame = frame;
		while currentFrame do
			if currentFrame == ancestry then
				return true;
			end
			currentFrame = currentFrame:GetParent();
		end
	end
	return false;
end

function GetUnscaledFrameRect(frame, scale)
	local frameLeft, frameBottom, frameWidth, frameHeight = frame:GetScaledRect();
	if frameLeft == nil then
		-- Defaulted returned for diagnosing invalid rects in layout frames.
		local defaulted = true;
		return 1, 1, 1, 1, defaulted;
	end

	return frameLeft / scale, frameBottom / scale, frameWidth / scale, frameHeight / scale;
end

function ApplyDefaultScale(frame, minScale, maxScale)
	local scale = GetDefaultScale();

	if minScale then
		scale = math.max(scale, minScale);
	end

	if maxScale then
		scale = math.min(scale, maxScale);
	end

	frame:SetScale(scale);
end

function FitToParent(parent, frame)
	local horizRatio = parent:GetWidth() / frame:GetWidth();
	local vertRatio = parent:GetHeight() / frame:GetHeight();

	if ( horizRatio < 1 or vertRatio < 1 ) then
		frame:SetScale(min(horizRatio, vertRatio));
		frame:SetPoint("CENTER", 0, 0);
	end

end

function UpdateScaleForFit(frame, extraWidth, extraHeight)
	frame:SetScale(1);

	local horizRatio = UIParent:GetWidth() / GetUIPanelWidth(frame, extraWidth);
	local vertRatio = UIParent:GetHeight() / GetUIPanelHeight(frame, extraHeight);

	if ( horizRatio < 1 or vertRatio < 1 ) then
		frame:SetScale(min(horizRatio, vertRatio));
	end
end