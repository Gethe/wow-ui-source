
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