local frameDummy = CreateFrame("Frame");
local frameFactory = CreateFrameFactory();

local function PoolReset(pool, region, new)
	Pool_HideAndClearAnchors(pool, region);

	if not new then
		-- The region requires a parent to avoid being leaked on client shutdown.
		region:SetParent(frameDummy);
	end
end

local texturePool = CreateTexturePool(frameDummy, "ARTWORK", 7, nil, PoolReset);
local fontStringPool = CreateFontStringPool(frameDummy, "ARTWORK", 7, nil, PoolReset);

local function FrameFactoryCreate(compositor, parent, frameType)
	local frame, new = frameFactory:Create(parent, frameType, PoolReset);
	table.insert(compositor.attachments, frame);

	frame:SetParent(parent);
	frame:Show();

	return frame, new;
end

--[[
Note that these default functions are going to be deleted and replaced with a single
reset/default function once it's available.
]]
local function SetRegionToDefaults(region)
	region:SetSize(1,1);
	region:SetAlpha(1);

	region:SetScript("OnMouseDown", nil);
	region:SetScript("OnMouseUp", nil);
	region:SetScript("OnMouseWheel", nil);
	region:SetScript("OnEnter", nil);
	region:SetScript("OnLeave", nil);
end

local function SetTextureToDefaults(texture)
	SetRegionToDefaults(texture);

	texture:SetTexture(nil);
	texture:SetHorizTile(false);
	texture:SetVertTile(false);
	texture:SetTexCoord(0,1,0,1);
	texture:SetVertexColor(1,1,1,1);

	for index = 1, 4 do
		texture:SetVertexOffset(index,0,0);
	end

	texture:SetAtlas(nil);
	texture:SetBlendMode("BLEND");
	texture:SetDrawLayer("ARTWORK");
	texture:SetDesaturation(0);
	texture:ClearTextureSlice();
end

local function SetFontStringToDefaults(fontString)
	SetRegionToDefaults(fontString);

	fontString:SetFontObject("GameFontHighlight");
	fontString:SetTextColor(1,1,1,1);
	fontString:SetWidth(150);
	fontString:SetMaxLines(1);
	fontString:SetJustifyH("LEFT");
	fontString:SetJustifyV("MIDDLE");
end

local function SetFrameToDefaults(frame)
	SetRegionToDefaults(frame);

	frame:SetPropagateKeyboardInput(false);

	frame:SetScript("OnLoad", nil);
	frame:SetScript("OnShow", nil);
	frame:SetScript("OnHide", nil);
	frame:SetScript("OnUpdate", nil);
	frame:SetScript("OnEvent", nil);
	frame:SetScript("OnSizeChanged", nil);
	frame:SetScript("OnDragStart", nil);
	frame:SetScript("OnDragStop", nil);
	frame:SetScript("OnReceiveDrag", nil);
end

local function SetButtonToDefaults(button)
	SetFrameToDefaults(button);

	button:RegisterForClicks("LeftButtonUp");

	button:SetScript("OnClick", nil);
	button:SetScript("OnDoubleClick", nil);
	button:SetScript("OnEnable", nil);
	button:SetScript("OnDisable", nil);
end

local function SetCheckButtonToDefaults(checkButton)
	SetButtonToDefaults(checkButton);

	local force = true;
	checkButton:SetChecked(false, force);
end

local function SetStatusBarToDefaults(statusBar)
	SetFrameToDefaults(statusBar);

	statusBar:SetFillStyle("STANDARD");
	statusBar:SetOrientation("HORIZONTAL");
	statusBar:SetReverseFill(false);
	statusBar:SetRotatesTexture(false);
	statusBar:SetColorFill(1,1,1,1);
	statusBar:SetStatusBarColor(1,1,1,1);
	statusBar:SetStatusBarDesaturation(0);
	statusBar:SetStatusBarDesaturated(false);
	statusBar:SetStatusBarTexture("");
	statusBar:SetMinMaxValues(0,0);
	statusBar:SetValue(0);
end

local function SetEditBoxToDefaults(editBox)
	SetFrameToDefaults(editBox);

	editBox:SetFontObject("GameFontHighlight");
	editBox:SetTextColor(1,1,1,1);
	editBox:SetWidth(150);
	editBox:SetJustifyH("LEFT");
	editBox:SetJustifyV("MIDDLE");
	editBox:SetText("");
	editBox:SetAutoFocus(false);
	editBox:ClearFocus();
end

local originalMetatables = {};

local function SetOriginalMetatable(region)
	local objType = region:GetObjectType();
	originalMetatables[objType] = getmetatable(region);
	region:Hide();
end

local configurationTbls = {};
local defaultConfigurationTbl = nil;

do
	local function CreateConfigurationTbl(defaultFunc, factory, disallowedFunctions, redirectFunctions)
		return {
			defaultFunc = defaultFunc, 
			factory = factory,
			disallowedFunctions = disallowedFunctions,
			redirectFunctions = redirectFunctions,
		};
	end

	local function SetupConfigurationTbl(objType, defaultFunc, factory, disallowedFunctions, redirectFunctions)
		configurationTbls[objType] = CreateConfigurationTbl(defaultFunc, factory, disallowedFunctions, redirectFunctions);
	end

	local function NewTicker(compositor, parent, timeSeconds, callback)
		return compositor:NewTicker(parent, timeSeconds, callback);
	end

	local function AttachTexture(compositor, parent)
		return compositor:AttachTexture(parent);
	end
	
	local function AttachFontString(compositor, parent)
		return compositor:AttachFontString(parent);
	end
	
	local function AttachFrame(compositor, parent, frameType)
		return compositor:AttachFrame(parent, frameType);
	end
	
	local function AttachTemplate(compositor, parent, template)
		return compositor:AttachTemplate(parent, template);
	end

	local regionRedirectFunctions = 
	{
	};

	-- Functions added to compositor created frames.
	local frameRedirectFunctions = 
	{
		["NewTicker"] = NewTicker,
		["AttachTexture"] = AttachTexture,
		["AttachFontString"] = AttachFontString,
		["AttachFrame"] = AttachFrame,
		["AttachTemplate"] = AttachTemplate,
	};

	local regionDisallowedFunctions = tInvert(
	{
	});
	
	local fontStringDisallowedFunctions = tInvert(
	{
		"SetFont",
	});

	--[[
	Disallow these functions from being called so that they don't create child regions
	the compositor won't be aware of.
	AttachTexture and AttachFontString should be used instead of CreateTexture and CreateFontString.
	]]--
	local frameDisallowedFunctions = tInvert(
	{
		"SetForbidden",
		"CreateTexture",
		"CreateMaskTexture",
		"CreateFontString",
		"CreateAnimationGroup",
		"CreateLine",
	});
	
	SetOriginalMetatable(frameDummy:CreateTexture());
	SetOriginalMetatable(frameDummy:CreateFontString());
	SetOriginalMetatable(frameDummy);
	SetOriginalMetatable(CreateFrame("Button"));
	SetOriginalMetatable(CreateFrame("CheckButton"));
	SetOriginalMetatable(CreateFrame("StatusBar"));
	SetOriginalMetatable(CreateFrame("EditBox"));

	defaultConfigurationTbl = CreateConfigurationTbl(SetFrameToDefaults, frameFactory, frameDisallowedFunctions, frameRedirectFunctions);
	
	--[[
	Configuration tables are optional here, and will eventually be replaced once a Reinitialize() method is added for every
	native frame type. Expect the 'defaultFunction' to disappear in a future patch.
	]]
	SetupConfigurationTbl("Texture", SetTextureToDefaults, texturePool, regionDisallowedFunctions, regionRedirectFunctions);
	SetupConfigurationTbl("FontString", SetFontStringToDefaults, fontStringPool, fontStringDisallowedFunctions, regionRedirectFunctions);
	SetupConfigurationTbl("Frame", SetFrameToDefaults, frameFactory, frameDisallowedFunctions, frameRedirectFunctions);
	SetupConfigurationTbl("Button", SetButtonToDefaults, frameFactory, frameDisallowedFunctions, frameRedirectFunctions);
	SetupConfigurationTbl("CheckButton", SetCheckButtonToDefaults, frameFactory, frameDisallowedFunctions, frameRedirectFunctions);
	SetupConfigurationTbl("StatusBar", SetStatusBarToDefaults, frameFactory, frameDisallowedFunctions, frameRedirectFunctions);
	SetupConfigurationTbl("EditBox", SetEditBoxToDefaults, frameFactory, frameDisallowedFunctions, frameRedirectFunctions);
end

local function GetConfigurationTbl(region)
	local objType = region:GetObjectType();
	return configurationTbls[objType] or defaultConfigurationTbl;
end

local function GetDefaultFunc(region)
	return GetConfigurationTbl(region).defaultFunc;
end

local function GetConfigFunc(region)
	return GetConfigurationTbl(region).configFunc;
end

local function GetFactory(region)
	return GetConfigurationTbl(region).factory;
end

local function GetOriginalMetatable(region)	
	local objType = region:GetObjectType();
	if not originalMetatables[objType] then
		SetOriginalMetatable(region);
	end

	return originalMetatables[objType];
end

local function RestoreOriginalMetatable(region)
	setmetatable(region, GetOriginalMetatable(region));
end

local function ConfigureMetatable(compositor, region)
	local configTbl = GetConfigurationTbl(region);
	local originalMetatable = GetOriginalMetatable(region);
	local disallowedFunctions = configTbl.disallowedFunctions;
	local redirectFunctions = configTbl.redirectFunctions;

	--[[
	This table is where all new insertions occur. The region should not have any keys at risk
	of being modified after the compositor is initialized. The intention here is to restore the 
	region to it's pristine "as first created" state.
	]]--
	local values = {};

	local metatable = 
	{
		__index = function(tbl, key)
			if disallowedFunctions[key] then
				assertsafe(false, string.format("Use of function '%s' is disallowed. (Index)", key));
				return function()
					assertsafe(false, string.format("Use of function '%s' is disallowed (Call).", key));
				end
			end

			--[[
			Always return the value if it exists in the discard table first. Note that this value may have been
			obtained from the original region, and shadow the original value.
			]]--
			local value = values[key];
			if value ~= nil then
				return value;
			end
			
			--[[
			If the value exists on the original region, we write the value to the discard table, preserving
			the original value. This ensures that a value that was assigned in a template's OnLoad or XML 
			is retained when the template is reacquired.
			]]--
			local originalValue = rawget(region, key);
			if originalValue ~= nil then
				rawset(values, key, originalValue);
				return originalValue;
			end

			-- Finally return the original metatable value, which will generally be C_API script functions.
			return originalMetatable.__index[key];
		end,

		__newindex = values,
	};

	-- Assign the redirect functions to the discard table, forwarding the compositor as their first argument.
	for key, func in pairs(redirectFunctions) do
		values[key] = function(...)
			--assert(select(1, ...) == region);
			-- ... expands to (parent, arg1, arg2, argn, ...) and are appended after the compositor.
			return func(compositor, ...);
		end;
	end

	--assert(region ~= frameDummy);
	setmetatable(region, metatable);

	table.insert(compositor.replacedMetatables, region);

	return region;
end

CompositorMixin = {};

do 
	--[[
	local function ReplaceRegionMetatables(compositor, ...)
		for i = 1, select("#", ...) do
			local region = select(i, ...);
			ConfigureMetatable(compositor, region);
		end
	end
	
	local function RecursiveConfigureMetatables(compositor, ...)
		for i = 1, select("#", ...) do
			local frame = select(i, ...);
			ConfigureMetatable(compositor, frame);
	
			--ReplaceRegionMetatables(compositor, frame:GetRegions());
			--RecursiveConfigureMetatables(compositor, frame:GetChildren());
		end
	end
	]]--
	
	function CompositorMixin:Init(target)
		self.replacedMetatables = {};
		self.attachments = {};
		self.target = target;
	
		ConfigureMetatable(self, target);

		--[[
		Stopped restricting modifications to children. It was too expensive for complex
		template types, and there still isn't a good way to restore templates to their original
		state if they were modified via C_APIs. Will revisit this another time.
		]]--
		--RecursiveConfigureMetatables(self, target);
	end
end

function CompositorMixin:GetBase()
	return self.target;
end

function CompositorMixin:ClearTicker()
	if self.ticker then
		self.ticker:Cancel();
		self.ticker = nil;
	end
end

function CompositorMixin:NewTicker(parent, timeSeconds, callback)
	self:ClearTicker();
	self.ticker = C_Timer.NewTicker(timeSeconds, callback);
end

local function Configure(compositor, region, parent)
	local defaultFunc = GetDefaultFunc(region);
	defaultFunc(region);

	ConfigureMetatable(compositor, region);
end

function CompositorMixin:CreateWithPool(parent, pool, defaultFunc, configFunc)
	local region = pool:Acquire();
	table.insert(self.attachments, region);

	region:SetParent(parent);

	--[[
	Configure the region before showing, so that any scripts that were assigned to the region
	previously are removed.
	]]
	Configure(self, region, parent);

	region:Show();

	return region;
end

function CompositorMixin:AttachTexture(parent)
	return self:CreateWithPool(parent, texturePool);
end

function CompositorMixin:AttachFontString(parent)
	return self:CreateWithPool(parent, fontStringPool);
end

function CompositorMixin:AttachFrame(parent, frameType)
	local frame = FrameFactoryCreate(self, parent, frameType);
	Configure(self, frame, parent);
	return frame;
end

--[[
Attaching a template will not be accompanied by any default configuration and metatable
changes. It's the callsite's responsibility to fully initialize the returned frame with 
the assumption that is has been changed by it's previous user.
]]--
function CompositorMixin:AttachTemplate(parent, template)
	local frame = FrameFactoryCreate(self, parent, template);
	return frame;
end

local function ReleaseAttachments(compositor)
	for index, region in ipairs(compositor.attachments) do
		local factory = GetFactory(region);
		factory:Release(region);
	end

	compositor.attachments = {};
end

function CompositorMixin:Clear()
	self:ClearTicker();

	for index, region in ipairs(self.replacedMetatables) do
		if region ~= self.target then
			RestoreOriginalMetatable(region);
		end
	end

	ReleaseAttachments(self);

	self.attachments = {};
	self.replacedMetatables = {self.target};
end

function CompositorMixin:Detach()
	self:ClearTicker();
	
	for index, region in ipairs(self.replacedMetatables) do
		RestoreOriginalMetatable(region);
	end
	self.replacedMetatables = {};

	ReleaseAttachments(self);
end

CompositorMixin.__index = CompositorMixin;

function CreateCompositor(target)
	local tbl = {};
	setmetatable(tbl, CompositorMixin);
	tbl:Init(target);
	return tbl;
end
