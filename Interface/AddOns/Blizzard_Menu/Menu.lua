local CreateSecureMap = SecureTypes.CreateSecureMap;
local CreateSecureArray = SecureTypes.CreateSecureArray;
local CreateSecureFunction = SecureTypes.CreateSecureFunction;
local CreateProxy = ProxyUtil.CreateProxy;
local CreateProxyDirectory = ProxyUtil.CreateProxyDirectory;
local CreateProxyMixin = ProxyUtil.CreateProxyMixin;
local SetPrivateReference = ProxyUtil.SetPrivateReference;
local ReleasePrivateReference = ProxyUtil.ReleasePrivateReference;
local ProxyConvertablePrivateMixin = Mixin(ProxyConvertableMixin);
local CreateFromMixinsPrivate = CreateFromMixins;
local assert = assert;
local type = type;

local ModifyMenuRegistry = CreateFromMixinsPrivate(CallbackRegistryMixin);
ModifyMenuRegistry:SetUndefinedEventsAllowed(true);
ModifyMenuRegistry:OnLoad();

local MenuAttributeDelegate = CreateFrame("FRAME");
MenuAttributeDelegate:SetForbidden();

Menu = {};

local frameDummy = CreateFrame("Frame");
local mouseEventEnterData = nil;
local mouseEventLeaveData = nil;
local mouseEventTime = .33;
local mouseEventTimeRemaining = nil;

local isEditorShown = nil;
local isEditMenuShown = nil;

local function TryHideTooltip(frame)
	local tooltip = GetAppropriateTooltip();
	if tooltip:GetOwner() == frame then
		tooltip:Hide();
		tooltip:SetWindow(nil);
	end
end

--[[
For ease of debugging with internal tools, dropdowns are prevented from automatically
closing when clicked outside when either the edit menu or editor is shown.
]]--
EventRegistry:RegisterCallback("UIEditor.EditorVisibilityChanged", function(o, show)
	isEditorShown = show;
end);

do
	-- Handles closing dropdowns under the correct circumstances.
	local event = "GLOBAL_MOUSE_DOWN";
	
	local function HandlesGlobalMouseEvent(focus, buttonName)
		return focus and focus.HandlesGlobalMouseEvent and focus:HandlesGlobalMouseEvent(buttonName, event);
	end
	
	EventRegistry:RegisterFrameEventAndCallback(event, function(buttonID, buttonName)
		local manager = Menu.GetManager();
		if not manager then
			return;
		end
	
		-- Only interested in the top focus.
		local foci = GetMouseFoci();
		if not HandlesGlobalMouseEvent(foci[1], buttonName) then
			manager:HandleGlobalMouseEvent(buttonName, event);
		end
	end);
end

--[[
Menu descriptions, element descriptions, and menus objects are private and are
exposed externally using proxies. A menu object's proxy is a menu frame so that
external code can continue to pass the frame to required APIs like SetPoint().
--]]

local enableProxyReporting = false; -- For debugging purposes only.
local Proxies = CreateProxyDirectory("Menu.lua", enableProxyReporting);

MenuAttributeDelegate:SetScript("OnAttributeChanged", function(self, attribute, value)
	if attribute == "respond" then
		if value == true then
			local menu = self:GetAttribute("respond-menu");
			local description = self:GetAttribute("respond-description");
			local response = self:GetAttribute("respond-response");
			local menuManager = menu.menuManager;
			menuManager:AttributeRespond(menu, description, response);
			
			self:SetAttribute("respond-menu", nil);
			self:SetAttribute("respond-description", nil);
			self:SetAttribute("respond-response", nil);
			self:SetAttribute("respond", false);
		end
	elseif attribute == "get-open-menu-tags" then
		local menuManager = Proxies:ToPrivate(Menu.GetManager());
		local tags = menuManager:GetOpenMenuTags();
		self:SetAttribute("get-open-menu-tags-result", tags);
	end
end);

--[[
All descriptions in the menu hierarchy are assigned a single shared properties
table to store information shared across all menus, and to store callbacks for
menu structure changes.
--]]
local SharedMenuPropertiesMixin = {};
SharedMenuPropertiesMixin.__index = SharedMenuPropertiesMixin;

function SharedMenuPropertiesMixin:Init(menuMixin)
	self.menuMixin = menuMixin;
	self.menuResponseCallbacks = CreateSecureArray();
	self.menuChangedCallbacks = CreateSecureArray();
	self.menuAcquiredCallbacks = CreateSecureArray();
	self.menuReleasedCallbacks = CreateSecureArray();
end

function SharedMenuPropertiesMixin:DisableCompositor()
	self.disableCompositor = true;
end

function SharedMenuPropertiesMixin:IsCompositorEnabled()
	return not self.disableCompositor;
end

function SharedMenuPropertiesMixin:DisableReacquireFrames()
	self.disableRequireFrames = true;
end

function SharedMenuPropertiesMixin:CanReacquireFrames()
	return not self.disableRequireFrames;
end

do
	local function GetMenuMixin(smp)
		return smp.menuMixin;
	end
	
	function SharedMenuPropertiesMixin:GetMenuMixin()
		return securecall(GetMenuMixin, self);
	end
end

function SharedMenuPropertiesMixin:GetMenuResponseCallbacks()
	return self.menuResponseCallbacks;
end

function SharedMenuPropertiesMixin:AddMenuResponseCallback(callback)
	self.menuResponseCallbacks:Insert(callback);
end

function SharedMenuPropertiesMixin:GetMenuChangedCallbacks()
	return self.menuChangedCallbacks;
end

function SharedMenuPropertiesMixin:AddMenuChangedCallback(callback)
	self.menuChangedCallbacks:Insert(callback);
end

function SharedMenuPropertiesMixin:GetMenuAcquiredCallbacks()
	return self.menuAcquiredCallbacks;
end

function SharedMenuPropertiesMixin:AddMenuAcquiredCallback(callback)
	self.menuAcquiredCallbacks:Insert(callback);
end

function SharedMenuPropertiesMixin:GetMenuReleasedCallbacks()
	return self.menuReleasedCallbacks;
end

function SharedMenuPropertiesMixin:AddMenuReleasedCallback(callback)
	self.menuReleasedCallbacks:Insert(callback);
end

local function CreateSharedMenuProperties(menuMixin)
	local properties = {};
	setmetatable(properties, SharedMenuPropertiesMixin);
	properties:Init(menuMixin);
	return properties;
end

--[[
Base menu description contains the information to express layout rules and size constraints,
the collections to store child element descriptions, and the initializers used to populate
the description frame.the description frame. Child element description are also base menu descriptions.
]]

local BaseMenuDescriptionMixin = CreateFromMixinsPrivate(ProxyConvertablePrivateMixin);

local function IsValidGridDirection(direction)
	return (direction == MenuConstants.VerticalGridDirection) 
		or (direction == MenuConstants.HorizontalGridDirection);
end

function BaseMenuDescriptionMixin:Init(proxy)
	local tags = ProxyConvertablePrivateMixin.Init(self, proxy, Proxies);
	tags[proxy] = "BaseMenuDescriptionMixin";

	self.gridDirection = MenuConstants.VerticalLinearDirection;
	self.elementDescriptions = CreateSecureArray();
	self.initializers = CreateSecureArray();
	self.finalInitializer = CreateSecureFunction();
	self.resetters = CreateSecureArray();
end

function BaseMenuDescriptionMixin:GetMenuMixin()
	return self:GetSharedMenuProperties():GetMenuMixin();
end

function BaseMenuDescriptionMixin:SetScrollMode(maxScrollExtent)
	assert(type(maxScrollExtent) == "number");
	self.scrollable = true;
	self.maxScrollExtent = maxScrollExtent or 200;
end

function BaseMenuDescriptionMixin:SetGridMode(direction, columns, padding, compactionMargin)
	assert((columns == MenuConstants.AutoCalculateColumns) or (columns > 0));
	assert(IsValidGridDirection(direction));

	self.gridDirection = direction;
	self.gridColumns = columns;
	self.gridPadding = padding;
	self.compactionMargin = compactionMargin;
end

do
	local function HasGridLayout(menuDescription)
		return IsValidGridDirection(menuDescription.gridDirection);
	end
	
	function BaseMenuDescriptionMixin:HasGridLayout()
		return securecall(HasGridLayout, self);
	end
end

do
	local function IsScrollable(menuDescription)
		return menuDescription.scrollable;
	end
	
	function BaseMenuDescriptionMixin:IsScrollable()
		return securecall(IsScrollable, self);
	end
end

do
	local function GetMaxScrollExtent(menuDescription)
		return menuDescription.maxScrollExtent;
	end
	
	function BaseMenuDescriptionMixin:GetMaxScrollExtent()
		return securecall(GetMaxScrollExtent, self);
	end
end

do
	local function GetGridDirection(menuDescription)
		return menuDescription.gridDirection or 0;
	end

	function BaseMenuDescriptionMixin:GetGridDirection()
		return securecall(GetGridDirection, self);
	end
end

do
	local function GetGridColumns(menuDescription)
		return menuDescription.gridColumns or 0;
	end

	function BaseMenuDescriptionMixin:GetGridColumns()
		return securecall(GetGridColumns, self);
	end
end

do
	local function GetGridPadding(menuDescription)
		return menuDescription.gridPadding or 0;
	end

	function BaseMenuDescriptionMixin:GetGridPadding()
		return securecall(GetGridPadding, self);
	end
end

do
	local function GetCompactionMargin(menuDescription)
		return menuDescription.compactionMargin or 0;
	end

	function BaseMenuDescriptionMixin:GetCompactionMargin()
		return securecall(GetCompactionMargin, self);
	end
end

do
	local function GetPadding(menuDescription)
		return menuDescription.padding or 0;
	end

	function BaseMenuDescriptionMixin:GetPadding()
		return securecall(GetPadding, self);
	end
end

do
	local function GetMinimumWidth(menuDescription)
		return menuDescription.minimumWidth or 0;
	end

	function BaseMenuDescriptionMixin:GetMinimumWidth()
		return securecall(GetMinimumWidth, self);
	end
end

function BaseMenuDescriptionMixin:SetMinimumWidth(width)
	self.minimumWidth = width;
end

do
	local function GetMaximumWidth(menuDescription)
		return menuDescription.maximumWidth or 0;
	end

	function BaseMenuDescriptionMixin:GetMaximumWidth()
		return securecall(GetMaximumWidth, self);
	end
end

function BaseMenuDescriptionMixin:SetMaximumWidth(width)
	self.maximumWidth = width;
end

do
	local function IsSubmenuDeactivated(menuDescription)
		return menuDescription.deactivateSubmenu;
	end

	function BaseMenuDescriptionMixin:IsSubmenuDeactivated()
		return securecall(IsSubmenuDeactivated, self);
	end
end

function BaseMenuDescriptionMixin:DeactivateSubmenu()
	self.deactivateSubmenu = true;
end

function BaseMenuDescriptionMixin:SetSharedMenuProperties(sharedMenuProperties)
	self.sharedMenuProperties = sharedMenuProperties;
end

function BaseMenuDescriptionMixin:GetSharedMenuProperties()
	return self.sharedMenuProperties;
end

function BaseMenuDescriptionMixin:GetMenuResponseCallbacks()
	return self:GetSharedMenuProperties():GetMenuResponseCallbacks();
end

function BaseMenuDescriptionMixin:GetMenuChangedCallbacks()
	return self:GetSharedMenuProperties():GetMenuChangedCallbacks();
end

function BaseMenuDescriptionMixin:GetMenuAcquiredCallbacks()
	return self:GetSharedMenuProperties():GetMenuAcquiredCallbacks();
end

function BaseMenuDescriptionMixin:GetMenuReleasedCallbacks()
	return self:GetSharedMenuProperties():GetMenuReleasedCallbacks();
end

function BaseMenuDescriptionMixin:IsCompositorEnabled()
	return self:GetSharedMenuProperties():IsCompositorEnabled();
end

function BaseMenuDescriptionMixin:DisableCompositor()
	self:GetSharedMenuProperties():DisableCompositor();
end

function BaseMenuDescriptionMixin:CanReacquireFrames()
	return self:GetSharedMenuProperties():CanReacquireFrames();
end

function BaseMenuDescriptionMixin:DisableReacquireFrames()
	self:GetSharedMenuProperties():DisableReacquireFrames();
end

function BaseMenuDescriptionMixin:HasElements()
	return self.elementDescriptions:HasValues();
end

function BaseMenuDescriptionMixin:CanOpenSubmenu()
	return self:HasElements() and not self:IsSubmenuDeactivated();
end

do
	local function EnumerateElementDescriptions(menuDescription)
		return menuDescription.elementDescriptions:Enumerate();
	end
	
	function BaseMenuDescriptionMixin:EnumerateElementDescriptions()
		return securecall(EnumerateElementDescriptions, self);
	end
end

function BaseMenuDescriptionMixin:Insert(description, index)
	description:SetSharedMenuProperties(self:GetSharedMenuProperties());

	self.elementDescriptions:Insert(description, index);

	description:GetMenuChangedCallbacks():ExecuteRange(function(index, callback)
		callback();
	end);

	return description;
end

function BaseMenuDescriptionMixin:GetInitializers()
	return self.initializers;
end

function BaseMenuDescriptionMixin:AddInitializer(initializer, index)
	self.initializers:UniqueInsert(initializer, index);
end

function BaseMenuDescriptionMixin:SetFinalInitializer(finalInitializer)
	self.finalInitializer:SetFunction(finalInitializer);
end

function BaseMenuDescriptionMixin:GetFinalInitializer()
	return self.finalInitializer;
end

function BaseMenuDescriptionMixin:AddResetter(resetter)
	self.resetters:UniqueInsert(resetter);
end

function BaseMenuDescriptionMixin:GetResetters()
	return self.resetters;
end

--
--[[
The root menu description is the start of the menu hierarchy. Although all of the
child menu descriptions technically have access to the shared menu properties,
it is expected that any menu event registration occur on this root description.
]]--
local RootMenuDescriptionMixin = CreateFromMixinsPrivate(BaseMenuDescriptionMixin);
RootMenuDescriptionMixin.__index = RootMenuDescriptionMixin;

function RootMenuDescriptionMixin:Init(proxy, menuMixin)
	BaseMenuDescriptionMixin.Init(self, proxy);

	-- A single shared menu properties is created for the entire menu hierarchy.
	self.sharedMenuProperties = CreateSharedMenuProperties(menuMixin);
end

function RootMenuDescriptionMixin:AddMenuResponseCallback(callback)
	self:GetSharedMenuProperties():AddMenuResponseCallback(callback);
end

function RootMenuDescriptionMixin:AddMenuChangedCallback(callback)
	self:GetSharedMenuProperties():AddMenuChangedCallback(callback);
end

function RootMenuDescriptionMixin:AddMenuAcquiredCallback(callback)
	self:GetSharedMenuProperties():AddMenuAcquiredCallback(callback);
end

function RootMenuDescriptionMixin:AddMenuReleasedCallback(callback)
	self:GetSharedMenuProperties():AddMenuReleasedCallback(callback);
end

--[[
Menu element descriptions represent each individual menu element. Adding menu element
descriptions into an existing element description creates a submenu.
]]--
local MenuElementDescriptionMixin = CreateFromMixinsPrivate(BaseMenuDescriptionMixin);
MenuElementDescriptionMixin.__index = MenuElementDescriptionMixin;

function MenuElementDescriptionMixin:Init(proxy)
	BaseMenuDescriptionMixin.Init(self, proxy);

	self.elementFactory = CreateSecureFunction();
	self.finalizeGridLayout = CreateSecureFunction();
end

function MenuElementDescriptionMixin:CallFactory(factory)
	self.elementFactory:CallFunction(factory);
end

function MenuElementDescriptionMixin:SetElementFactory(elementFactory)
	self.elementFactory:SetFunction(elementFactory);
end

function MenuElementDescriptionMixin:SetFinalizeGridLayout(callback)
	self.finalizeGridLayout:SetFunction(callback);
end

function MenuElementDescriptionMixin:SendResponseToMenu(response)
	if self.menu then
		self.menu:SendResponse(self, response);
	end
end

function MenuElementDescriptionMixin:ForceOpenSubmenu()
	if self.menu then
		self.menu:ForceOpenSubmenu(self);
	end
end

local BaseMenuDescriptionAPI = 
{
	"HasElements",
	"AddInitializer",
	"SetFinalInitializer",
	"AddResetter",
	"SetMinimumWidth",
	"GetMinimumWidth",
	"SetMaximumWidth",
	"SetGridMode",
	"SetScrollMode",
};

local RootMenuDescriptionProxyMixin;
do
	local Funcs =
	{
		"AddMenuResponseCallback",
		"AddMenuChangedCallback",
		"AddMenuAcquiredCallback",
		"AddMenuReleasedCallback",
		"DisableCompositor",
		"DisableReacquireFrames",
	};
	tAppendAll(Funcs, BaseMenuDescriptionAPI);

	RootMenuDescriptionProxyMixin = CreateProxyMixin(Proxies, RootMenuDescriptionMixin, Funcs);
	RootMenuDescriptionProxyMixin.__index = RootMenuDescriptionProxyMixin;
end

local MenuElementDescriptionProxyMixin;
do
	local Funcs =
	{
		"SetOnEnter",
		"SetOnLeave",
		"SetElementFactory",
		"SetFinalizeGridLayout",
		"DeactivateSubmenu",
		"CanOpenSubmenu",
		"ForceOpenSubmenu",
	};
	tAppendAll(Funcs, BaseMenuDescriptionAPI);

	MenuElementDescriptionProxyMixin = CreateProxyMixin(Proxies, MenuElementDescriptionMixin, Funcs);
	MenuElementDescriptionProxyMixin.__index = MenuElementDescriptionProxyMixin;
end

do
	local function GetTag(descriptionProxy, tag, contextData)
		return descriptionProxy.tag, descriptionProxy.contextData;
	end

	RootMenuDescriptionProxyMixin.GetTag = GetTag;
	MenuElementDescriptionProxyMixin.GetTag = GetTag;

	local function SetTag(descriptionProxy, tag, contextData)
		descriptionProxy.tag = tag;
		descriptionProxy.contextData = contextData;
	end

	RootMenuDescriptionProxyMixin.SetTag = SetTag;
	MenuElementDescriptionProxyMixin.SetTag = SetTag;

	local function ClearQueuedDescriptions(descriptionProxy)
		descriptionProxy.queuedProxies = nil;
	end

	RootMenuDescriptionProxyMixin.ClearQueuedDescriptions = ClearQueuedDescriptions;
	MenuElementDescriptionProxyMixin.ClearQueuedDescriptions = ClearQueuedDescriptions;

	
	local function AddQueuedDescription(descriptionProxy, queuedDescriptionProxy)
		if not descriptionProxy.queuedProxies then
			descriptionProxy.queuedProxies = {};
		end
		table.insert(descriptionProxy.queuedProxies, queuedDescriptionProxy);
	end

	RootMenuDescriptionProxyMixin.AddQueuedDescription = AddQueuedDescription;
	MenuElementDescriptionProxyMixin.AddQueuedDescription = AddQueuedDescription;

	-- Proxy and description passed simply to avoid an extra ToProxy() call.
	local function InsertQueuedDescriptions(descriptionProxy, description)
		local queuedProxies = descriptionProxy.queuedProxies;
		descriptionProxy.queuedProxies = nil;
		if queuedProxies then
			for index, proxy in ipairs(queuedProxies) do
				description:Insert(Proxies:ToPrivate(proxy));
			end
		end
	end

	local function Insert(descriptionProxy, insertDescriptionProxy, index)
		local description = Proxies:ToPrivate(descriptionProxy);
		InsertQueuedDescriptions(descriptionProxy, description);
		local insertDescription = Proxies:ToPrivate(insertDescriptionProxy);
		return description:Insert(insertDescription, index):ToProxy();
	end

	RootMenuDescriptionProxyMixin.Insert = Insert;
	MenuElementDescriptionProxyMixin.Insert = Insert;

	--[[
	EnumerateElementDescriptions cannot be forwarded in CreateProxyMixin above because
	the function iterator will return the private objects instead of proxies.
	]]
	local function ipairs_proxy(tbl)
		local function Iterator(tbl, index)
			index = index + 1;
			local value = tbl[index];
			if value then
				return index, value:ToProxy();
			end
		end
	
		return Iterator, tbl, 0;
	end
	
	do
		local function EnumerateElementDescriptions(descriptionProxy)
			local description = Proxies:ToPrivate(descriptionProxy);
			return description.elementDescriptions:EnumerateIterator(ipairs_proxy);
		end

		RootMenuDescriptionProxyMixin.EnumerateElementDescriptions = EnumerateElementDescriptions;
		MenuElementDescriptionProxyMixin.EnumerateElementDescriptions = EnumerateElementDescriptions;
	end

	function MenuElementDescriptionProxyMixin:SetRadio(isRadio)
		self.isRadio = isRadio;
	end
	
	function MenuElementDescriptionProxyMixin:IsRadio()
		return self.isRadio;
	end

	function MenuElementDescriptionProxyMixin:SetIsSelected(isSelected)
		self.isSelected = isSelected;
	end
	
	function MenuElementDescriptionProxyMixin:IsSelected()
		if self.isSelected == nil then
			return false;
		end

		return self.isSelected(self:GetData());
	end
	
	function MenuElementDescriptionProxyMixin:SetCanSelect(canSelect)
		self.canSelect = canSelect;
	end
	
	function MenuElementDescriptionProxyMixin:CanSelect()
		if not self:IsEnabled() then
			return false;
		end

		if self.canSelect == nil then
			return true;
		end

		if type(self.canSelect) == "boolean" then
			return self.canSelect;
		end

		return self.canSelect(self:GetData());
	end
	
	function MenuElementDescriptionProxyMixin:SetSelectionIgnored()
		self.isSelectionIgnored = true;
	end
	
	function MenuElementDescriptionProxyMixin:IsSelectionIgnored()
		return self.isSelectionIgnored == true;
	end

	function MenuElementDescriptionProxyMixin:SetSoundKit(soundKit)
		self.soundKit = soundKit;
	end

	function MenuElementDescriptionProxyMixin:GetSoundKit()
		if type(self.soundKit) == "number" then
			return self.soundKit;
		end

		return self.soundKit(self);
	end
	
	function MenuElementDescriptionProxyMixin:SetShouldRespondIfSubmenu(canRespond)
		self.shouldRespondIfSubmenu = canRespond;
	end

	function MenuElementDescriptionProxyMixin:ShouldRespondIfSubmenu()
		return self.shouldRespondIfSubmenu;
	end

	function MenuElementDescriptionProxyMixin:SetShouldPlaySoundOnSubmenuClick(canPlay)
		self.playSoundOnSubmenuClick = canPlay;
	end
	
	function MenuElementDescriptionProxyMixin:ShouldPlaySoundOnSubmenuClick()
		return self.playSoundOnSubmenuClick;
	end

	function MenuElementDescriptionProxyMixin:SetOnEnter(onEnter)
		if onEnter == nil then
			self.onEnter = nil;
			return;
		end

		self.onEnter = function(...)
			onEnter(...);
		end
	end
	
	function MenuElementDescriptionProxyMixin:HookOnEnter(callback)
		if self.onEnter then
			hooksecurefunc(self, "onEnter", callback);
		else
			self:SetOnEnter(callback);
		end
	end

	function MenuElementDescriptionProxyMixin:GetOnEnter()
		return self.onEnter;
	end
	
	function MenuElementDescriptionProxyMixin:HandleOnEnter(frame)
		if frame.OnEnter then
			frame:OnEnter(self);
		end

		if self.onEnter then
			self.onEnter(frame, self);
		end
	end

	function MenuElementDescriptionProxyMixin:SetOnLeave(onLeave)
		if onLeave == nil then
			self.onLeave = nil;
			return;
		end

		self.onLeave = function(...)
			onLeave(...);
		end
	end
	
	function MenuElementDescriptionProxyMixin:HookOnLeave(callback)
		if self.onLeave then
			hooksecurefunc(self, "onLeave", callback);
		else
			self:SetOnLeave(callback);
		end
	end

	function MenuElementDescriptionProxyMixin:GetOnLeave()
		return self.onLeave;
	end

	function MenuElementDescriptionProxyMixin:HandleOnLeave(frame)
		if frame.OnLeave then
			frame:OnLeave(self);
		end
	
		if self.onLeave then
			self.onLeave(frame, self);
		end

		TryHideTooltip(frame);
	end

	function MenuElementDescriptionProxyMixin:SetEnabled(isEnabled)
		self.isEnabled = isEnabled;
	end
	
	function MenuElementDescriptionProxyMixin:IsEnabled()
		if self.isEnabled == nil then
			return true;
		end

		if type(self.isEnabled) == "boolean" then
			return self.isEnabled;
		end

		return self.isEnabled(self);
	end
	
	function MenuElementDescriptionProxyMixin:ShouldPollEnabled()
		return type(self.isEnabled) == "function";
	end

	function MenuElementDescriptionProxyMixin:SetData(data)
		self.data = data;
	end
	
	function MenuElementDescriptionProxyMixin:GetData()
		return self.data;
	end

	function MenuElementDescriptionProxyMixin:SetResponder(callback)
		self.responder = callback;
	end
	
	function MenuElementDescriptionProxyMixin:HookResponder(callback)
		if self.responder then
			hooksecurefunc(self, "responder", callback);
		else
			self:SetResponder(callback);
		end
	end

	function MenuElementDescriptionProxyMixin:SetResponse(response)
		self.defaultResponse = response;
	end
	
	function MenuElementDescriptionProxyMixin:GetDefaultResponse(menuInputContext, menuInputButtonName)
		if type(self.defaultResponse) == "function" then
			return securecallfunction(self.defaultResponse, menuInputContext, menuInputButtonName);
		end
		return self.defaultResponse;
	end

	local function SecureCallResponder(descriptionProxy, description, menuInputContext, menuInputButtonName)
		local menu = description.menu;
		local menuProxy = menu and menu:ToProxy() or nil;
		local menuInputData = {
			context = menuInputContext,
			buttonName = menuInputButtonName,
		};
		return descriptionProxy.responder(descriptionProxy:GetData(), menuInputData, menuProxy);
	end

	local function SecureGetDefaultResponse(descriptionProxy, menuInputContext, menuInputButtonName)
		return descriptionProxy:GetDefaultResponse(menuInputContext, menuInputButtonName);
	end

	local function SecureCanSelect(descriptionProxy)
		return descriptionProxy:CanSelect();
	end

	function MenuElementDescriptionProxyMixin:Pick(menuInputContext, menuInputButtonName)
		assert(menuInputContext, "MenuElementDescriptionProxyMixin:Pick() called without an input context.");

		--[[
		Pick() is not normally callable through a disabled button using the standard menu templates, however we need
		to account for the case where Pick is called through custom implementations.
		]]--
		local canSelect = securecallfunction(SecureCanSelect, self);
		if not canSelect then
			return false;
		end

		--[[
		If a responder callback is not set, then the menu will not change. Selecting a submenu root should 
		never cause the menu to close.
		]]--
		local response = nil;
		local willRespond = self.responder ~= nil;
		if willRespond then
			-- Use the default response if it exists. This is supplied by checkbox and radio descriptions.
			local descriptionResponse = securecallfunction(SecureGetDefaultResponse, self, menuInputContext, menuInputButtonName);
			if descriptionResponse then
				response = descriptionResponse;
			end

			--[[
			A reponse returned from the responder should always override a default response. This is intended
			so that a menu can be forced to close when it would otherwise remain open, which is common in cases
			where a checkbox or radio is changed.
			]]--
			local description = Proxies:ToPrivate(self);
			local overrideResponse = securecallfunction(SecureCallResponder, self, description, menuInputContext, menuInputButtonName);
			if overrideResponse then
				response = overrideResponse;
			end

			--[[
			There may not be a menu containing the description if the description was picked
			using a stepper or rotated via mouse wheel. If there is a menu, send it the
			response so it can refresh, reinitialize, or close as directed.
			]]
			description:SendResponseToMenu(response);
		end
		return willRespond, response;
	end
end

--[[
A single shared factory is used for all menu elements. ReleaseAll() is removed from this
factory to prevent accidentally flushing everything when only one submenu was intended to
be closed.
]]
local MenuElementFactory = CreateFrameFactory();
MenuElementFactory.ReleaseAll = nil;

MenuMixin = CreateFromMixinsPrivate(ProxyConvertablePrivateMixin);

function MenuMixin:Init(menuManager, proxy, permitOverwrite)
	local tags = ProxyConvertablePrivateMixin.Init(self, proxy, Proxies, permitOverwrite);
	tags[proxy] = "MenuMixin";

	self.level = 0;
	self.menuManager = menuManager;
	self.compositor = CreateCompositor(proxy);
	self.frames = CreateSecureArray();
	self.elementCompositors = CreateSecureMap();
end

do
	local function GetLevel(menu)
		return menu.level;
	end

	function MenuMixin:GetLevel()
		return securecall(GetLevel, self);
	end
end


function MenuMixin:SetClosedCallback(onCloseCallback)
	self.onCloseCallback = function(...)
		onCloseCallback(...);
	end
end

local function MeasureExtents(regions)
	local l, r, t, b = math.huge, 0, 0, math.huge;
	for index, region in ipairs(regions) do
		local left, bottom, width, height = region:GetRect();
		l = math.min(l, left);
		r = math.max(r, left + width);
		t = math.max(t, bottom + height);
		b = math.min(b, bottom);
	end
	return r - l, t - b;
end

--[[ 
Note that we don't expect frame extents to change when reinitializing a frame, otherwise we'll potentially
breach the screen bounds and create either the problem of a mispositioned menu, or flipping the menu across
it's parent menu. 

We still need to do another layout pass because initializing the frame may have overwritten the common
width we assigned.
]]--
local function CallInitializers(frame, menu, compositor)
	-- Always set a constant reference size so that measurements are not inconsistently affected by regions
	-- that use points to define their size.
	local templateInfo = MenuElementFactory:GetTemplateInfoCache():GetTemplateInfo(frame.frameTemplateOrFrameType);
	if templateInfo then
		frame:SetSize(templateInfo.width, templateInfo.height);
	else
		frame:SetSize(1, 1);
	end

	local width, height;
	local descriptionProxy = frame:GetElementDescription();
	local description = Proxies:ToPrivate(descriptionProxy);
	local menuProxy = menu:ToProxy();
	
	description:GetInitializers():ExecuteRange(function(index, initializer)
		-- Use the size returned from the initializer. This is intended to be overridable
		-- as each initializer in the list represents an extension of control.
		local w, h = initializer(frame, descriptionProxy, menuProxy);
		if w and h then
			width, height = w, h;
		end
	end);

	if (not width) or (not height) then
		-- Calculate the size based on all the regions created by the compositor.
		if not compositor then
			compositor = menu.elementCompositors:GetValue(frame);
		end

		if compositor and #compositor.attachments > 0 then
			local w, h = MeasureExtents(compositor.attachments);
			if w and h then
				width, height = w, h;
			end
		end
	end

	if width and height then
		width = Round(width);
		height = Round(height);
		frame:SetSize(width, height);
	else
		-- Assume the size was set in the initializer. It's current size will be it's desired size.
	end

	-- All of the initializers need to be called prior to calling the post initializer because
	-- each initializer can contribute to the regions available, and those regions need to be attached
	-- before attempting to traverse the entire hierarchy as is done in RecurseSetupFontString().
	description:GetFinalInitializer():CallFunctionIfSet(frame, descriptionProxy, menuProxy);
end

local function ResetMenuElement(pool, frame, new)
	if not new then
		TryHideTooltip(frame);

		--[[
		Clear scripts to ensure they cannot be called when the pool removes this frame's anchors.
		Any callback assigned to the menu description will be unavailable now that the
		compositor has flushed the state associated with the frame. However, by the time
		we reach this function, this frame should have already been explicitly hidden by the menu
		system during close, causing the OnLeave to be called if it were necessary.
		]]--
		frame:SetScript("OnEnter", nil);
		frame:SetScript("OnLeave", nil);
		frame:SetParent(frameDummy);
	end

	Pool_HideAndClearAnchors(pool, frame);
end

local function InitializeElementDescription(menu, elementDescription, factory, factoryArgs)
	elementDescription.menu = menu;

	-- Call the factory. 'childFrame' and 'initializer' in factoryArgs will be available on return.
	elementDescription.elementFactory:CallFunction(factory);

	-- 'childFrame' and 'initializer' are assigned before returning from the factory above.
	local childFrame = factoryArgs.childFrame;
	local initializer = factoryArgs.initializer;
	wipe(factoryArgs);

	elementDescription.frame = childFrame;

	-- 'childFrame' and 'initializer' are assigned before returning from the factory above.
	childFrame.GetElementDescription = function(frame)
		return elementDescription:ToProxy();
	end;

	--[[
	InitializationOrder - It is very important that we insert this initializer at the front of the 
	array because the element description object will frequently have had initializers added before
	the factory was invoked, and these initializers are intended to be called in least to
	most specialized order.
	]]--
	if initializer then
		local frontIndex = 1;
		elementDescription:AddInitializer(initializer, frontIndex);
	end
end

local function InitializeFrame(frame, menu)
	--[[
	All menu elements are expected to have an initial anchor to TOPLEFT. This is a contract
	also expected of custom templates that are used sas menu elements.
	]]--
	frame:ClearAllPoints();
	frame:SetPoint("TOPLEFT"); -- Workaround to force a valid rect prior to calling initializer.
	frame:GetHeight(); -- Workaround to force a valid rect prior to calling initializer.

	CallInitializers(frame, menu);

	frame:SetScript("OnMouseDown", menu.onElementMouseDown);
	frame:SetScript("OnEnter", menu.onElementEnter);
	frame:SetScript("OnLeave", menu.onElementLeave);
	frame:Show();
end

local function AcquireMenuElement(frameDummy, frameTemplateOrFrameType, ResetMenuElement)
	return MenuElementFactory:Create(frameDummy, frameTemplateOrFrameType, ResetMenuElement);
end

function MenuMixin:SetMenuDescription(menuDescription)
	self.menuDescription = menuDescription;
	
	-- In a secure context, the factoryArgs table can be passed to securecallfunction without tainting execution.
	local factoryArgs = {};
	if self.frames:IsEmpty() or menuDescription:CanReacquireFrames() then
		self.menuDescription = menuDescription;
		
		self:DiscardChildFrames();
		
		local isCompositorEnabled = menuDescription:IsCompositorEnabled();
		local function Factory(frameTemplateOrFrameType, initializer)
			local childFrame, new, templateInfo = securecallfunction(AcquireMenuElement, frameDummy, frameTemplateOrFrameType, ResetMenuElement)
			if not childFrame then
				error(string.format("MenuMixin:SetMenuDescription: Failed to create a frame from pool for frame template or frame type '%s'", frameTemplateOrFrameType));
			end
			
			if new then
				-- ID is for our test harness, it has no significance elsewhere.
				childFrame:SetID(1001);
			end

			factoryArgs.childFrame = childFrame;
			factoryArgs.initializer = initializer;

			local menuFrame = self:ToProxy();
			childFrame:SetParent(menuFrame);

			-- Used to acquire the template info cache for resizing during the initialization step.
			childFrame.frameTemplateOrFrameType = frameTemplateOrFrameType;

			--[[
			Menu frames have 'ignoreAllChildren' set to prevent any cosmetic regions 
			from being included in the layout calculation. We opt-in the frames that we
			expect to be included in the menu's layout list.
			]]--
			childFrame.includeInLayout = true;

			--[[
			Child frames can be RLF frames, and their Layout() call at initialization time informs the
			menu of their desired size. At the end of those initializations, the menu will reassign common
			widths to the frames that we do not want overwritten by a Layout() call when the frame is shown.
			It should be assumed that after a frame initializes, all resizing is on the responsibility of the
			menu. We also don't want the perf hit of an additional Layout() call if we've already done it
			(~3ms saved on human body 2 face options).
			]]--
			childFrame.skipLayoutOnShow = true;

			--[[
			Raise the frame level to ensure that the contents are always above the menu frame
			in case the menu's contents occupy some frame levels.
			]]--
			childFrame:SetFrameLevel(menuFrame:GetFrameLevel() + 20);

			self.frames:Insert(childFrame);

			if isCompositorEnabled then
				self.elementCompositors:SetValue(childFrame, CreateCompositor(childFrame));
			end
		end
		
		for index, elementDescription in menuDescription:EnumerateElementDescriptions() do
			securecallfunction(InitializeElementDescription, self, elementDescription, Factory, factoryArgs);
		end
	else
		--[[
		This is meant for a rare circumstances like character creation where it is too expensive
		to flush out and reacquire new frames for every element. Instead, every frame is reassigned
		new element description data and then reinitialized. If you need a breakpoint here,
		open a character creation customization dropdown, then mouse-wheel to change selections.
		]]--

		--[[
		This factory only captures the initializer because we're not interested in fetching a frame from the pool.
		]]--
		local function Factory(frameTemplateOrFrameType, initializer)
			factoryArgs.initializer = initializer;
		end;

		for index, elementDescription in menuDescription:EnumerateElementDescriptions() do
			factoryArgs.childFrame = self.frames:GetValue(index);

			securecallfunction(InitializeElementDescription, self, elementDescription, Factory, factoryArgs);
		end
	end
	
	for index, frame in self.frames:Enumerate() do
		securecallfunction(InitializeFrame, frame, self);
	end;
	
	--After all initializers have been called, continue with layout.
	self:PerformLayout();
end

function MenuMixin:Open(menuDescription, onElementMouseDown, onElementEnter, onElementLeave)
	-- Retain these wrappers in case the description is replaced.
	self.onElementMouseDown = onElementMouseDown;
	self.onElementEnter = onElementEnter;
	self.onElementLeave = onElementLeave;
	
	self:SetMenuDescription(menuDescription);
end

--Values were taken from character customization and are accepted default values.
local function AutoCalculateColumns(count)
	if count > 36 then
		return 4;
	elseif count > 24 then
		return 3;
	elseif count > 10 then
		return 2;
	end
	return 1;
end

local function AutoCalculateColumnsAndRows(count)
	local columns = AutoCalculateColumns(count);
	local rows = math.ceil(count / columns);
	return columns, rows;
end

local function TransformColumnsAndRows(count, columns, rows, maxRows)
	-- If there are too many rows, redistribute them across columns.
	if maxRows and rows > maxRows then
		columns = math.ceil(count / maxRows);
		rows = math.ceil(count / columns);
	end
	return columns, rows;
end

function MenuMixin:MeasureFrameExtents()
	local menuFrame = self:ToProxy();
	local width = menuFrame.minimumElementWidth;
	local height = 1;
	local totalHeight = 0;

	for index, frame in self.frames:Enumerate() do
		local w, h = frame:GetSize();
		width = math.max(width, w);
		height = math.max(height, h);
		totalHeight = totalHeight + height;
	end

	width = Round(width);
	height = Round(height);

	--assert(height > 1, "MenuMixin:MeasureFrameExtents(): Couldn't obtain a valid height for the frame. Set the size at the end of your initializer.");
	return width, height, totalHeight;
end

local function SecureGetInset(menuFrame)
	local inset = menuFrame:GetInset();
	return inset.left, inset.top, inset.right, inset.bottom;
end

local function SecureGetChildExtentPadding(menuFrame)
	local padding = menuFrame:GetChildExtentPadding();
	return padding.width, padding.height;
end

function MenuMixin:PerformLayout()
	--[[ 
	GetTop() is returning inconsistently between openings despite it's anchor being fixed in space. 
	Will need to create a simpler test case for us to understand this misbehavior, but in the meantime, 
	setting the size to 1,1 appears to force the GetTop() call to return accurately each time.
	]]--
	local menuFrame = self:ToProxy();
	menuFrame:SetSize(1, 1);

	--[[ 
	Obtaining the size of a frame is complicated by a case in character customization where
	the frame will compact itself if the menu requires multiple columns. We would normally know
	if a multiple columns are necessary from the number of frames alone, however in this case, 
	design wants the menu to compact instead of reposition if the menu would exceed the screen bounds.
	
	We cannot know if the menu would exceed the screen bounds unless we first measure the frame height,
	which implies we have to initialize the frame first.

	After we have the final extents of each frame, we apply the largest width of any frame to all frames
	so that the menu elements are easy to navigate. While this may not be desireable in some undiscovered
	cases in the future, this is desireable as the default case.

	So the required order is:
	1) Resize each frame inside their initializer (done prior to the PerformLayout() call).
	2) Measure frame extents.

	If a grid,
	3a) Calculate grid columns and rows.
	3b) If callbacks are provided, allow frames to do compaction, then measure frame extents again.
	
	4) Resize all frames to a common width.
	]]--
	
	local finalColumns = 1;
	local finalRows = nil;

	local childMaxWidth, childMaxHeight, childTotalHeight = self:MeasureFrameExtents();
	
	-- To avoid cramping, an additional amount of padding can be added.
	local childPadWidth, childPadHeight = securecallfunction(SecureGetChildExtentPadding, menuFrame);
	childMaxWidth = childMaxWidth + childPadWidth;

	if self.menuDescription:HasGridLayout() then
		local size = self.frames:GetSize();

		-- The # of columns will be auto calculated if it is not provided.
		local columns, rows;
		local gridColumns = self.menuDescription:GetGridColumns();
		if gridColumns > 0 then
			local maxGridColumns = math.min(size, gridColumns);
			columns, rows = maxGridColumns, math.ceil(size / maxGridColumns);
		else
			columns, rows = AutoCalculateColumnsAndRows(size);
		end

		--[[ 
		If a compaction margin is provided, then the menu will compact. This overrides any
		menu repositioning that could occur along the vertical axis.
		]]--
		local compactionMargin = self.menuDescription:GetCompactionMargin();
		if compactionMargin > 0 then
			local maxMenuHeight = math.max(0, menuFrame:GetTop() - compactionMargin);
			local maxRows = math.max(1, math.floor(maxMenuHeight / childMaxHeight));
			finalColumns, finalRows = TransformColumnsAndRows(size, columns, rows, maxRows);
		else
			finalColumns, finalRows = columns, rows;
		end

		--[[
		The final column and row count may be required by some frames to override their extents.
		If this occurs, we will have to recalculate the ideal frame size again.
		]]--
		local recalculateSize = false;

		for index, frame in self.frames:Enumerate() do
			local descriptionProxy = frame:GetElementDescription();
			local description = Proxies:ToPrivate(descriptionProxy);
			
			if description.finalizeGridLayout:IsSet() then
				description.finalizeGridLayout:CallFunction(frame, descriptionProxy, menuFrame, finalColumns, finalRows);
				recalculateSize = true;
			end
		end

		if recalculateSize then
			childMaxWidth = self:MeasureFrameExtents();
		end
	end

	-- Get the insets so that we can calculate fitting in the interior of the menu.
	local left, top, right, bottom = securecallfunction(SecureGetInset, menuFrame);

	--[[
	Children are assigned a uniform width for cursor hit tests. If either a minimum or maximum menu
	width is provided, then these children's widths may be modified as appropriate.
	]]--
	local childWidth = childMaxWidth;
	local minimumWidth = math.floor(self.menuDescription:GetMinimumWidth());
	local maximumWidth = math.floor(self.menuDescription:GetMaximumWidth());

	-- RLF
	--[[
	Also note that none of these keys will be cleared if the compositor is disabled, so ensure
	that all of these calls continue to be made unconditionally.
	]]
	menuFrame:SetMinimumWidth(((minimumWidth > 0) and minimumWidth) or nil);
	menuFrame:SetMaximumWidth(((maximumWidth > 0) and maximumWidth) or nil);
	menuFrame:SetWidthPadding(left + right);
	menuFrame:SetHeightPadding(top + bottom);

	if minimumWidth > 0 then
		assert(minimumWidth <= (((maximumWidth > 0) and maximumWidth) or math.huge), "Menu minimum width cannot be greater than maximum width.");
		-- Children are widened to fit.
		-- See Resolution in the settings menu for an example.
		local interior = minimumWidth - (left + right);
		if (childWidth * finalColumns) < interior then
			childWidth = math.max(interior / finalColumns, childMaxWidth);
		end
	end

	if maximumWidth > 0 then
		assert(maximumWidth >= minimumWidth, "Menu maximum width cannot be less than minimum width.");
		--[[
		Children as compacted to fit. The expectation with this mode is that the children
		are configured to truncate to account for not fitting. Make sure the only factor
		controlling the extent is not only the element's text.
		]]--
		local interior = maximumWidth - (left + right);
		if (childWidth * finalColumns) > interior then
			childWidth = (interior / finalColumns);
		else
			childWidth = math.min(childMaxWidth, interior);
		end
	end

	--[[
	The common width is applied to all frames. Also, anchor utilities below do not care if the 
	frame is an RLF, so we need to ensure the extents are set so that the grid size can be
	calculated correctly.
	]]--

	childWidth = Round(childWidth);
	for index, frame in self.frames:Enumerate() do
		frame:SetWidth(childWidth);
	end

	local useScroll = false;
	local maxScrollExtent;
	if self.menuDescription:IsScrollable() then
		maxScrollExtent = self.menuDescription:GetMaxScrollExtent();
		useScroll = childTotalHeight > maxScrollExtent;
	end

	if useScroll then
		menuFrame:InitScrollLayout(childWidth, maxScrollExtent);

		local scrollBox = menuFrame.ScrollBox;
		local onScrollBoxScroll = function(o, scrollPercentage, visibleExtentPercentage, panExtentPercentage)
			self.menuManager:CollapseMenusUntilLevel(self:GetLevel());
		end;  
		scrollBox:RegisterCallback(BaseScrollBoxEvents.OnScroll, onScrollBoxScroll, self);

		if not menuFrame.ScrollBox:HasDataProvider() then
			local dataProvider = CreateDataProvider();
			for index, frame in self.frames:Enumerate() do
				frame:ClearAllPoints();
				frame:SetPoint("TOPLEFT");
				frame:Hide();

				dataProvider:Insert(frame);
			end
			menuFrame.ScrollBox:SetDataProvider(dataProvider);
		end
	else
		local anchor = AnchorUtil.CreateAnchor("TOPLEFT", menuFrame, "TOPLEFT", left, -top);
		local useGrid = finalColumns > 1;
		if useGrid then
			local layout = nil;
			local gridPadding = self.menuDescription:GetGridPadding();
			local gridDirection = self.menuDescription:GetGridDirection();
			if gridDirection == MenuConstants.VerticalGridDirection then
				layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRightVertical, finalRows, gridPadding);
			elseif gridDirection == MenuConstants.HorizontalGridDirection then
				layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, finalColumns, gridPadding);
			end
			
			self.frames:ExecuteTable(function(frames)
				AnchorUtil.GridLayout(frames, anchor, layout);
			end);
		else
			local padding = self.menuDescription:GetPadding();
			self.frames:ExecuteTable(function(frames)
				AnchorUtil.VerticalLayout(frames, anchor, padding);
			end);
		end
	end

	--[[
	A layout frame is ideal for the menu because it will conform to all of the child contents, however because we
	have already directed children to do RLF calls, resize, or expicitly overwrite their size, we don't want the RLF
	behavior to call Layout() on all of the children again.
	
	This is avoided by having the menu template define 'skipChildLayout' = true, allowing the children to be included 
	in the extent calculations, but not make additional Layout() calls. 
	
	All of the elements have been resized, continue with the final menu Layout().
	]]--
	menuFrame:Layout();

	--[[
	After the layout is done, we can check if the menu overflowed any area of the screen and flip it along
	the appropriate axis if necessary. Note that if this was a grid menu with the compaction margin provided,
	this will have no effect along the vertical axis.
	]]--
	self:FlipPositionIfOffscreen();

	--[[
	After any menu position has been inverted, finish by clamping to screen. If this is a new menu, the menu
	will not be clamped to screen before this call. Note that if this was an existing menu being reinitialized,
	we would not expect the position to change as we don't want a menu changing size as children update.
	]]--
	menuFrame:SetClampedToScreen(true);
end

do
	local function ShouldFlipHorizontally(point, relativePoint)
		if point == "TOPLEFT" and relativePoint == "TOPRIGHT" then
			return true;
		elseif point == "BOTTOMLEFT" and relativePoint == "BOTTOMRIGHT" then
			return true;
		elseif point == "RIGHT" and relativePoint == "LEFT" then
			return true;
		elseif point == "TOPRIGHT" and relativePoint == "TOPLEFT" then
			return true;
		elseif point == "BOTTOMRIGHT" and relativePoint == "BOTTOMLEFT" then
			return true;
		elseif point == "LEFT" and relativePoint == "RIGHT" then
			return true;
		end
		return false;
	end

	local function ShouldFlipVertically(point, relativePoint)
		if point == "TOPRIGHT" and relativePoint == "BOTTOMRIGHT" then
			return true;
		elseif point == "TOPLEFT" and relativePoint == "BOTTOMLEFT" then
			return true;
		elseif point == "TOP" and relativePoint == "BOTTOM" then
			return true;
		elseif point == "BOTTOMRIGHT" and relativePoint == "TOPRIGHT" then
			return true;
		elseif point == "BOTTOMLEFT" and relativePoint == "TOPLEFT" then
			return true;
		elseif point == "BOTTOM" and relativePoint == "TOP" then
			return true;
		end
		return false;
	end

	local function GetContextMenuFlipVerticalPoint(point)
		if point == "TOPLEFT" then
			return "BOTTOMLEFT";
		elseif point == "TOPRIGHT" then
			return "BOTTOMRIGHT";
		elseif point == "BOTTOMLEFT" then
			return "TOPLEFT";
		elseif point == "BOTTOMRIGHT" then
			return "TOPRIGHT";
		elseif point == "TOP" then
			return "BOTTOM";
		elseif point == "BOTTOM" then
			return "TOP";
		end
	end

	local function FlipPoint(frame, point, relativeKey, relativePoint, x, y)
		frame:ClearPoint(point);
		frame:SetPoint(relativePoint, relativeKey, point, x, y);
	end

	function MenuMixin:FlipPositionIfOffscreen()
		local overflowHorizontal, overflowVertical = false, false;
		local menuFrame = self:ToProxy();
		
		local br, bt;
		local window = menuFrame:GetWindow();
		if window then
			br, bt = window:GetWindowSize();
		else
			local boundsParent = GetAppropriateTopLevelParent();
			br = boundsParent:GetRight();
			bt = boundsParent:GetTop();
		end

		local l = menuFrame:GetLeft();
		local r = menuFrame:GetRight();
		if (l < 0) or (r > br) then
			overflowHorizontal = true;
		end

		local t = menuFrame:GetTop();
		local b = menuFrame:GetBottom();
		if (b < 0) or (t > bt) then
			overflowVertical = true;
		end
	
		if overflowHorizontal or overflowVertical then
			for index = 1, menuFrame:GetNumPoints() do
				local flipped = false;
				local point, relativeKey, relativePoint, x, y = menuFrame:GetPoint(index);
				local asContextMenu = menuFrame.asContextMenu;
				-- Context menus can only ever be flipped vertically. They clamp horizontally.
				if (not asContextMenu) and overflowHorizontal then
					if ShouldFlipHorizontally(point, relativePoint) then
						FlipPoint(menuFrame, point, relativeKey, relativePoint, -x, y);
						flipped = true;
					end
				end
				
				if (not flipped) and overflowVertical then
					if asContextMenu then
						-- A context menu frame is always anchored to the UI origin, so to flip we
						-- replace the menu's point and retain it's relative point.
						menuFrame:ClearPoint(point);
						local flipPoint = GetContextMenuFlipVerticalPoint(point);
						menuFrame:SetPoint(flipPoint, relativeKey, relativePoint, x, y);
					else
						if ShouldFlipVertically(point, relativePoint) then
							FlipPoint(menuFrame, point, relativeKey, relativePoint, x, -y);
						end
					end
				end
			end
		end
	end
end

local function ReinitializeFrame(self, frame, isCompositorEnabled)
	local compositor;
	-- Compositor check avoids iterating over the secure map if we don't need to.
	if isCompositorEnabled then
		compositor = self.elementCompositors:GetValue(frame);
		if compositor then
			compositor:Clear();
		end

	end
	securecallfunction(CallInitializers, frame, self, compositor);
end

function MenuMixin:ReinitializeAll()
	local isCompositorEnabled = self.menuDescription:IsCompositorEnabled();
	for index, frame in self.frames:Enumerate() do
		securecallfunction(ReinitializeFrame, self, frame, isCompositorEnabled);
	end

	self:PerformLayout();
end

function MenuMixin:DiscardChildFrames()
	--[[
	Releasing the compositors will cause any keys assigned or changed to be discarded.
	All frame cleanup that is contingent on these keys must be finished prior to this
	release. 
	
	This will also restore any restricted APIs that were disallowed by the
	compositor like SetParent() which will be needed once the frame pool reset
	function is called.
	]]--

	local isCompositorEnabled = self.menuDescription:IsCompositorEnabled();
	for index, frame in self.frames:Enumerate() do
		local descriptionProxy = frame:GetElementDescription();
		local description = Proxies:ToPrivate(descriptionProxy);
		description:GetResetters():ExecuteRange(function(index, resetter)
			resetter(frame);
		end);

		-- Compositor check avoids iterating over the secure map if we don't need to.
		if isCompositorEnabled then
			local compositor = self.elementCompositors:GetValue(frame);
			if compositor then
				compositor:Detach();
			end
		end
		
		MenuElementFactory:Release(frame);
	end

	self.frames:Wipe();
end

function MenuMixin:Close()
	local menuFrame = self:ToProxy();
	menuFrame:SetScript("OnEnter", nil);
	menuFrame:SetScript("OnLeave", nil);
	menuFrame:SetScript("OnUpdate", nil);
	
	menuFrame.ScrollBox:RemoveDataProvider();
	
	-- All scripts must be finished before the compositor flushes our keys.

	if self.onCloseCallback then
		self.onCloseCallback(menuFrame);
	end

	-- Hide is necessary here to ensure any OnLeave scripts are fired on child frames before
	-- the compositor flushes our keys.
	menuFrame:Hide();

	-- Warning! All state on menu and its children will be flushed.
	self:DiscardChildFrames();

	self.compositor:Detach();

	for index, childMenuDescription in self.menuDescription:EnumerateElementDescriptions() do
		childMenuDescription.menu = nil;
	end
	self.menuDescription = nil;
end

function MenuMixin:SendResponse(description, response)
	self.menuManager:Respond(self, description, response);
end

function MenuMixin:ForceOpenSubmenu(description)
	self.menuManager:ForceOpenSubmenu(self, description);
end

do
	local Funcs =
	{
		"ReinitializeAll",
		"SetClosedCallback",
	};

	MenuProxyMixin = CreateProxyMixin(Proxies, MenuMixin, Funcs);
end

function MenuProxyMixin:OnLoad()
	self.ScrollBox = CreateFrame("Frame", nil, self, "WowScrollBoxList");

	self.ScrollBar = CreateFrame("EventFrame", nil, self, "MinimalScrollBar");
	self.ScrollBar:SetPoint("TOPLEFT", self.ScrollBox, "TOPRIGHT");
	self.ScrollBar:SetPoint("BOTTOMLEFT", self.ScrollBox, "BOTTOMRIGHT");

	local view = CreateScrollBoxListLinearView();

	view:SetFrameFactoryResetter(function(pool, frame, new)
		if not new then
			local elementData = frame:GetElementData();
			elementData:Hide();
		end
	end);

	view:SetElementExtentCalculator(function(dataIndex, elementData)
		return elementData:GetHeight();
	end);

	view:SetElementInitializer("Frame", function(frame, elementData)
		elementData:SetParent(frame);
		elementData:ClearAllPoints();
		elementData:SetPoint("TOPLEFT");
		elementData:Show();
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function MenuProxyMixin:ClearScrollLayout()
	self.ScrollBox:Hide();
	self.ScrollBar:Hide();
	self:ClearFixedSize();
end

function MenuProxyMixin:InitScrollLayout(childWidth, maxScrollExtent)
	local left, top, right, bottom = securecallfunction(SecureGetInset, self);
	local scrollBarWidth = self.ScrollBar:GetWidth();
	self.ScrollBox:SetPoint("TOPLEFT", left, -top);
	self.ScrollBox:SetPoint("BOTTOMRIGHT", -(right + scrollBarWidth), bottom);

	local scrollBarPad = 10;
	local insetWidth = left + right;
	local insetHeight = top + bottom;
	local width = childWidth + insetWidth + scrollBarWidth + scrollBarPad;
	local height = maxScrollExtent + insetHeight;
	self:SetFixedSize(width, height);

	self.ScrollBox:Show();
	self.ScrollBar:Show();
end

function MenuProxyMixin:SetMenuDescription(descriptionProxy)
	local menu = Proxies:ToPrivate(self);
	local description = Proxies:ToPrivate(descriptionProxy);
	menu:SetMenuDescription(description);
end

function MenuProxyMixin:SendResponse(descriptionProxy, response)
	local menu = Proxies:ToPrivate(self);
	local description = Proxies:ToPrivate(descriptionProxy);
	menu:SendResponse(description, response);
end

function MenuProxyMixin:Close()
	Menu.GetManager():CloseMenu(self);
end

function MenuProxyMixin:GetOwnerRegion()
	return self.ownerRegion;
end

local MenuManagerMixin = CreateFromMixinsPrivate(ProxyConvertablePrivateMixin);

function MenuManagerMixin:ProcessMouseEventLeaveData()
	if not mouseEventLeaveData then
		return;
	end
	mouseEventLeaveData = nil;

	if not self:ContainsCursor() then
		self:CollapseMenusUntilLevel(self:GetRetainMenuLevel());
	end
end

function MenuManagerMixin:ProcessMouseEventEnterData()
	if not mouseEventEnterData then
		return;
	end

	local frame = mouseEventEnterData.frame;
	local level = mouseEventEnterData.level;
	mouseEventEnterData = nil;

	if frame:IsMouseOver() then
		self:CheckForSubmenu(frame, level);
	end
end

function MenuManagerMixin:CancelMouseEventTimer()
	mouseEventTimeRemaining = nil;
	frameDummy:SetScript("OnUpdate", nil);
end

function MenuManagerMixin:Init(proxy)
	local tags = ProxyConvertablePrivateMixin.Init(self, proxy, Proxies);
	tags[proxy] = "MenuManagerMixin";

	self.menus = CreateSecureArray();
	self.frameFactory = CreateFrameFactory();
	
	self:SetRetainMenuLevel(0);

	self.mouseEventTimerCallback = function(frame, dt)
		if not (mouseEventEnterData or mouseEventLeaveData) then
			return;
		end

		mouseEventTimeRemaining = mouseEventTimeRemaining - dt;
		if mouseEventTimeRemaining > 0 then
			return;
		end

		self:ProcessMouseEventLeaveData();
		self:ProcessMouseEventEnterData();

		self:CancelMouseEventTimer();
	end
end

function MenuManagerMixin:RestartMouseEventTimer()
	if mouseEventTimeRemaining == nil then
		frameDummy:SetScript("OnUpdate", self.mouseEventTimerCallback);
	end
	mouseEventTimeRemaining = mouseEventTime;
end

function MenuManagerMixin:StopMouseEventTimer()
	mouseEventEnterData = nil;
	mouseEventLeaveData = nil;

	self:CancelMouseEventTimer();
end

local function GetMenuDescriptionTag(tags, menu)
	local description = menu.menuDescription;
	local proxy = description:ToProxy();
	local tag = proxy:GetTag();
	if tag then
		table.insert(tags, tag);
	end
end

function MenuManagerMixin:GetOpenMenuTags()
	local tags = {};
	for stackIndex, menu in self.menus:Enumerate() do
		securecallfunction(GetMenuDescriptionTag, tags, menu);
	end
	return tags;
end

function MenuManagerMixin:GetOpenMenu()
	return self.menus:GetValue(1);
end

function MenuManagerMixin:HandleESC()
	if self:IsAnyMenuOpen() then
		self:CloseMenus();
		return true;
	end
	return false;
end

function MenuManagerMixin:HandleGlobalMouseEvent(buttonName, event)
	if event == "GLOBAL_MOUSE_DOWN" and (buttonName == "LeftButton" or buttonName == "RightButton") then
		if isEditorShown or isEditMenuShown then
			return false;
		end

		if not self:ContainsCursor() then
			self:CloseMenus();
			return true;
		end
	end
	return false;
end

function MenuManagerMixin:ContainsCursor()
	for stackIndex, menu in self.menus:Enumerate() do
		if menu:ToProxy():IsMouseOver() then
			return true;
		end
	end
	return false;
end

function MenuManagerMixin:CloseMenu(menu)
	if not menu then
		return;
	end

	self:RemoveMenu(menu);
end

function MenuManagerMixin:CloseMenus()
	for stackIndex, menu in self.menus:EnumerateReverse() do
		self:CloseMenu(menu);
	end
end


function MenuManagerMixin:RemoveMenu(menu)
	if not menu then
		return;
	end

	if not self.menus:RemoveValue(menu) then
		return;
	end

	self:CollapseMenusUntilLevel(menu:GetLevel());

	local proxy = menu:ToProxy();

	-- All scripts must be finished before the compositor flushes our keys.
	-- Notify listeners that the menu is closing.
	menu.menuDescription:GetMenuReleasedCallbacks():ExecuteRange(function(index, onReleased)
		onReleased(proxy);
	end);

	--[[
	Close the menu. On return this needs to have finished executing all supported scripts and
	callbacks registered on the menu description object, as the compositor will have flushed our
	keys.
	]]--
	menu:Close();
	
	--[[
	The proxy for a menu must be manually removed because a pool frame is never
	dereferenced and will always persist.
	]]
	Proxies:RemoveProxy(proxy);

	-- Renable any scrolling we disabled when the menu was opened.
	local data = self.disabledScrollRegionData;
	if data and data.menu == menu then
		data.region:SetScrollAllowed(true);
		self.disabledScrollRegionData = nil;
	end

	self.frameFactory:Release(proxy);

	if self.menus:IsEmpty() then
		self:StopMouseEventTimer();
	end
end

function MenuManagerMixin:FindMenu(menuDescription)
	return self.menus:FindInTableIf(function(menu)
		return menu.menuDescription == menuDescription;
	end);
end

function MenuManagerMixin:IsAnyMenuOpen(menuDescription)
	return self.menus:HasValues();
end

function MenuManagerMixin:IsMenuDescriptionOpen(menuDescription)
	return self:FindMenu(menuDescription) ~= nil;
end

function MenuManagerMixin:IsMenuOpen(menu)
	return self.menus:Contains(menu);
end

function MenuManagerMixin:CollapseMenusUntilLevel(level)
	for stackIndex, menu in self.menus:EnumerateReverse() do
		if menu:GetLevel() > level then
			self:RemoveMenu(menu);
		end
	end
end

function MenuManagerMixin:GenerateSubmenu(menuDescription, level, relativeFrame)
	if self:IsMenuDescriptionOpen(menuDescription) then
		return;
	end

	self:CollapseMenusUntilLevel(level);

	self:GenerateSubmenuInternal(menuDescription, level + 1, relativeFrame);
end

function MenuManagerMixin:EvaluateMenuOverflow(menu)
	local overflowHorizontal, overflowVertical = false, false;
	local menuParent = menu:GetParent();
	if (menu:GetLeft() < 0) or (menu:GetRight() > menuParent:GetRight()) then
		overflowHorizontal = true;
	end

	if (menu:GetTop() > menuParent:GetTop()) or (menu:GetBottom() < 0) then
		overflowVertical = true;
	end

	return overflowHorizontal, overflowVertical;
end


function MenuManagerMixin:GenerateSubmenuInternal(menuDescription, level, relativeFrame)
	local function SetMenuPosition(menu)
		menu:SetPoint("TOPLEFT", relativeFrame, "TOPRIGHT");
	end

	local params = {};
	params.menuDescription = menuDescription;
	params.level = level;
	params.menuPositionFunc = SetMenuPosition;
	params.relativeFrame = relativeFrame;
	return self:GenerateMenuInternal(params);
end

local function ResetMenu(pool, frame, new)
	if not new then
		ReleasePrivateReference(frame);
	end

	frame:SetParent(nil);

	Pool_HideAndClearAnchors(pool, frame);
end

local function AcquireMenuFrame(menuManager)
	return menuManager.frameFactory:Create(nil, "MenuTemplateBase", ResetMenu);
end

local function SecureGenerate(proxy, menuDescription)
	Mixin(proxy, menuDescription:GetMenuMixin());
	proxy:Generate();
end

function MenuManagerMixin:AcquireMenu(params)
	local menuDescription = params.menuDescription;

	--[[
	Menus are parented to WorldFrame because UIParent is hidden in certain fullscreen UIs.
	We apply the scale of the appropriate parent to the menu to get the desired base scale.
	]]--
	local proxy, new = securecallfunction(AcquireMenuFrame, self);
	if new then
		-- ID is for our test harness, it has no significance elsewhere.
		proxy:SetID(1000);
	end
	--assert(select("#", proxy:GetRegions()) == 0);
	--assert(select("#", proxy:GetChildren()) == 0);

	proxy:ClearScrollLayout();

	local menu = CreateFromMixinsPrivate(MenuMixin);

	--[[
	Normally all proxies are tables with private references to the object. Since the frame 
	is the proxy, we'll need to set the private reference manually, and then remove it once 
	the frame is returned to the pool. Frames are never released from these pools so it is
	important we clear the private reference, else the menu object will never get gc'ed.
	--]]
	SetPrivateReference(proxy, menu);

	--[[
	A previous menu object may be in the proxy directory if it hasn't been gc'ed yet.
	We want that assert to ensure that we evaluate each case individually. 
	--]]
	local permitOverwrite = true;
	menu:Init(self, proxy, permitOverwrite);

	--[[
	Important! After this Init() call, all value changes to this frame will be 
	discarded once this frame is reclaimed.
	--]]
	securecallfunction(SecureGenerate, proxy, menuDescription);

	local parent = GetAppropriateTopLevelParent();

	--[[ Some tools exist on the Tooltip strata. Raise the menu strata to match if
	that case is encountered.
	--]]
	local strata = "FULLSCREEN_DIALOG";
	local ownerRegion = params.ownerRegion;
	if ownerRegion and ownerRegion.GetFrameStrata then
		if ownerRegion:GetFrameStrata() == "TOOLTIP" then
			strata = "TOOLTIP";
		end
	end
	proxy.ownerRegion = ownerRegion;
	proxy.asContextMenu = params.asContextMenu;
	proxy:SetFrameStrata(strata);

	local window = parent:GetWindow();
	local anchor = params.anchor;
	if anchor then
		local relativeTo = anchor:GetRelativeTo();
		window = relativeTo:GetWindow();
	end

	if not window then
		local relativeFrame = params.relativeFrame;
		if relativeFrame then
			window = relativeFrame:GetWindow();
		end
	end

	if (not window) and ownerRegion then
		window = ownerRegion:GetWindow();
	end

	proxy:SetWindow(window);
	proxy:SetScale(parent:GetScale());

	--[[
	Menu is initially unclamped until after we've calculated any overflow and performed
	any necessary anchor swapping.
	--]]
	proxy:SetClampedToScreen(false);

	return menu;
end

local function ExecuteMenuReponseCallbacks(menu, description)
	-- Menu response callbacks exist in the SharedMenuProperties, so descriptions on any menu level will cause
	-- the listeners to be notified.
	description:GetMenuResponseCallbacks():ExecuteRange(function(index, onMenuResponse)
		onMenuResponse(menu, description:ToProxy());
	end);
end

local function ReinitializeHierarchy(menu)
	while menu do
		menu:ReinitializeAll();
		menu = menu.parentMenu;
	end
end

local function SecureReinitializeAll(menu)
	menu:ReinitializeAll();
end

local function SecureReinitializeChildMenus(description)
	if description:HasElements() then
		for index, childElementDescription in description:EnumerateElementDescriptions() do
			local childMenu = childElementDescription.menu;
			if childMenu then
				childMenu:ReinitializeAll();
				break;
			end
		end
	end
end

local function CanSubmenuProxyRespond(description)
	local descriptionProxy = description:ToProxy();
	return descriptionProxy:ShouldRespondIfSubmenu();
end

function MenuManagerMixin:AttributeRespond(menu, description, response)
	--[[
	CloseAll and 'nil' are equivalent in behavior. For brevity, responders generally do not return
	anything, which causes the entire menu to close. While that is frequently desirable, checkboxes
	have a Refresh default behavior, so any of these controls that should cause the menu to close need
	to explicitly return CloseAll (or set the default response type).
	]]--

	-- Still on the fence about requiring an elect-in for this, but for now
	-- enable it by default. Known examples where this is used:
	-- Communities recruitment "Looking For" menu
	local canReinitializeHierarchy = true;
	local parentMenu = menu.parentMenu;

	if (response == nil) or (response == MenuResponse.CloseAll) then
		-- If the description has elements, but the submenu is omitted, treat it as
		-- if there are no elements.
		local canCloseMenus = not description:HasElements();
		if not canCloseMenus then
			canCloseMenus = description:IsSubmenuDeactivated() or securecallfunction(CanSubmenuProxyRespond, description);
		end

		if canCloseMenus then
			self:CloseMenus();
		end
		canReinitializeHierarchy = false;
	elseif response == MenuResponse.Close then
		self:CloseMenu(menu);
	elseif response == MenuResponse.Refresh then
		-- Reinitialize every option in the enclosing menu.
		securecallfunction(SecureReinitializeAll, menu);

		-- Reinitialize the child menu that is attached to this description, if one exists. This is to
		-- account for cases where a radio or checkbox is also a submenu and selecting an option influences
		-- the open submenu.
		securecallfunction(SecureReinitializeChildMenus, description);
	elseif response == MenuResponse.Open then
		-- No action
	end
	
	if canReinitializeHierarchy and parentMenu then
		securecallfunction(ReinitializeHierarchy, parentMenu);
		ReinitializeHierarchy(parentMenu);
	end

	-- The response callbacks are called last in case the menus needed to be regenerated to update their
	-- options and selected state. For example in Hierlooms, choosing a class requires the options in the root
	-- menu to be regenerated, which needs to be done prior to evaluating any new selected options.
	ExecuteMenuReponseCallbacks(menu, description);
end

function MenuManagerMixin:Respond(menu, description, response)
	MenuAttributeDelegate:SetAttribute("respond-menu", menu);
	MenuAttributeDelegate:SetAttribute("respond-description", description);
	MenuAttributeDelegate:SetAttribute("respond-response", response);
	MenuAttributeDelegate:SetAttribute("respond", true);
end

-- This is only intended to be called externally when DeactivateSubmenu() is used to prevent
-- automatic opening of the submenu on mouseover or click. This is for cases where design
-- wants the submenu to only open when a nested button is clicked.
function MenuManagerMixin:ForceOpenSubmenu(menu, description)
	if description:HasElements() then
		self:GenerateSubmenu(description, menu:GetLevel(), description.frame);
	end
end

function MenuManagerMixin:CheckForSubmenu(frame, level)
	local descriptionProxy = frame:GetElementDescription();
	local description = Proxies:ToPrivate(descriptionProxy);
	if not self:IsMenuDescriptionOpen(description) then
		self:CollapseMenusUntilLevel(level);
	end

	if (frame:GetObjectType() ~= "Button" or frame:IsEnabled()) and description:CanOpenSubmenu() then
		self:GenerateSubmenu(description, level, frame);
	end
end

do
	local function GetRetainMenuLevel(menuManager)
		return menuManager.retainMenuLevel;
	end

	function MenuManagerMixin:GetRetainMenuLevel()
		return securecall(GetRetainMenuLevel, self);
	end

	function MenuManagerMixin:SetRetainMenuLevel(level)
		self.retainMenuLevel = level;
	end
end

function MenuManagerMixin:SetEventLeaveData()
	mouseEventLeaveData = true;
	self:RestartMouseEventTimer();
end

function MenuManagerMixin:SetEventEnterData(frame, menu, level)
	mouseEventEnterData = {frame = frame, menu = menu, level = level};
	self:RestartMouseEventTimer();
end

function MenuManagerMixin:EnterFrame(frame, menu, level)
	self:SetEventEnterData(frame, menu, level);

	self:SetRetainMenuLevel(level);

	local descriptionProxy = frame:GetElementDescription();
	descriptionProxy:HandleOnEnter(frame);
end

function MenuManagerMixin:LeaveFrame(frame, menu)
	self:SetEventLeaveData();

	local descriptionProxy = frame:GetElementDescription();
	descriptionProxy:HandleOnLeave(frame);
end

function MenuManagerMixin:OnMenuEnter(level)
	self:SetRetainMenuLevel(level);
end

function MenuManagerMixin:OnMenuLeave()
	self:SetEventLeaveData();
end

local function SecureTaggedMenuOpened(menuDescription)
	local proxy = menuDescription:ToProxy();
	local tag, contextData = proxy:GetTag();
	if tag then
		EventRegistry:TriggerEvent("Menu.OpenMenuTag", tag, contextData);
	end
end

function MenuManagerMixin:GenerateMenuInternal(params)
	local menuDescription = params.menuDescription;
	-- If the menu has no entries, we don't bother even acquiring one. This can occur with context
	-- menus that are generated with conditional options.
	if not menuDescription:HasElements() then
		return nil;
	end

	local level = params.level;
	local menuPositionFunc = params.menuPositionFunc;

	local menu = self:AcquireMenu(params);
	menu.level = level;
	menu.parentDescription = menuDescription;
	menu.parentMenu = menuDescription.menu;

	--[[
	Menu scale should be the same scale of it's parent, but the character customization
	case downscales the controls and the menu scale needs to change to match. This shouldn't
	generally be needed.
	--]]

	-- Notify listeners that the description was added.
	menuDescription:GetMenuAcquiredCallbacks():ExecuteRange(function(index, onAcquired)
		onAcquired(menu:ToProxy());
	end);

	-- Anchors must be valid prior to opening the menu so that all point measurements are retrievable.
	menuPositionFunc(menu:ToProxy());	
	
	local function OnMouseDown(frame)
		-- The enter is discarded when we stop the timer, but we still need to process the leave.
		self:ProcessMouseEventLeaveData();
		self:StopMouseEventTimer();

		self:CheckForSubmenu(frame, menu:GetLevel());
	end

	local function OnEnter(frame)
		self:EnterFrame(frame, menu, menu:GetLevel());
	end

	local function OnLeave(frame)
		self:LeaveFrame(frame, menu);
	end
	
	securecallfunction(menu.Open, menu, menuDescription, OnMouseDown, OnEnter, OnLeave);
	
	local proxy = menu:ToProxy();

	-- The NineSlice utility creates a frame with frame level 500. To avoid interlacing with this frame
	-- we always need to add 500 to the menu's frame level. If there isn't an owner region, set the frame level
	-- arbitrarily high so it will hopefully be above everything, as there are some frames on the FULLSCREEN_DIALOG
	-- with questionably high frame levels.
	local frameLevel;
	local ownerRegion = params.ownerRegion;
	if ownerRegion and ownerRegion.GetFrameLevel then
		local nineSliceLevel = 500;
		frameLevel = ownerRegion:GetFrameLevel() + nineSliceLevel;
	else
		frameLevel = 9500;
	end

	proxy:SetFrameLevel(frameLevel + menu:GetLevel());
	proxy:Show();

	proxy:SetScript("OnEnter", function(menuFrame)
		self:OnMenuEnter(menu:GetLevel());
	end);

	proxy:SetScript("OnLeave", function(menuFrame)
		self:OnMenuLeave();
	end);
	
	--[[
	If an owner region becomes invisible, we generally want the root menu to close along with it. 
	In this instance this behavior is undesireable, the .ignoreOwner key should be set. Note that 
	this will require exposing a parameter to OpenMenu, OpenContextMenu, proxies, and utility file.
	]]--
	if ownerRegion and not params.ignoreOwner then
		proxy:SetScript("OnUpdate", function(dt)
			if not ownerRegion:IsVisible() then
				proxy:SetScript("OnUpdate", nil);
				self:CloseMenu(menu);
			end
		end);
	end

	self.menus:Insert(menu);
	
	--[[
	Any scroll controller or SMF under the mouse has scrolling disabled once a menu is opened above it.
	The region will be renabled once the menu is closed.
	]]
	if level == 1 then
		securecallfunction(self.DisableScrollableRegions, self, menu);
	end

	securecallfunction(SecureTaggedMenuOpened, menuDescription);

	return menu;
end

function MenuManagerMixin:DisableScrollableRegions(menu)
	for index, focus in ipairs(GetMouseFoci()) do
		if self.disabledScrollRegionData ~= nil then
			break;
		end

		local region = focus;
		while region do
			if IsScrollController(region) or IsScrollingMessageFrame(region) then
				region:SetScrollAllowed(false);
				
				self.disabledScrollRegionData = 
				{
					menu = menu, 
					region = region,
				};

				break;
			end

			region = region:GetParent();
		end
	end
end

function MenuManagerMixin:OpenMenuInternal(params)
	-- Ensure all other menus are closed first.
	self:CloseMenus();

	local RootMenuLevel = 1;
	params.level = RootMenuLevel;

	-- The level of retained menus when the cursor exits the menu bounds.
	self:SetRetainMenuLevel(RootMenuLevel);
	
	return self:GenerateMenuInternal(params);
end

function MenuManagerMixin:OpenMenu(ownerRegion, menuDescription, anchor)
	local function SetMenuPosition(menuFrame)
		local clearAllPoints = true;
		anchor:SetPoint(menuFrame, clearAllPoints);
	end

	local params = {};
	params.ownerRegion = ownerRegion;
	params.anchor = anchor;
	params.menuDescription = menuDescription;
	params.menuPositionFunc = SetMenuPosition;
	return self:OpenMenuInternal(params);
end

function MenuManagerMixin:OpenContextMenu(ownerRegion, menuDescription)
	--[[
	The region is required for closing the menu when the region becomes hidden,
	but otherwise the menu should open at the position of the cursor.
	]]--
	assert(ownerRegion, "MenuManagerMixin:OpenContextMenu(ownerRegion, menuDescription): ownerRegion was not provided.");

	local function SetMenuPosition(menuFrame)
		InputUtil.AnchorRegionToCursor(menuFrame, "TOPLEFT");
	end

	local params = {};
	params.asContextMenu = true;
	params.ownerRegion = ownerRegion;
	params.menuDescription = menuDescription;
	params.menuPositionFunc = SetMenuPosition;
	return self:OpenMenuInternal(params);
end

do
	local Funcs =
	{
		"HandleESC",
		"HandleGlobalMouseEvent",
	};

	local MenuManagerProxyMixin = CreateProxyMixin(Proxies, MenuManagerMixin, Funcs);
	MenuManagerProxyMixin.__index = MenuManagerProxyMixin;

	function MenuManagerProxyMixin:GetOpenMenu()
		local menuManager = Proxies:ToPrivate(self);
		local menu = menuManager:GetOpenMenu();
		return menu and menu:ToProxy() or nil;
	end

	function MenuManagerProxyMixin:CloseMenu(menuProxy)
		local menuManager = Proxies:ToPrivate(self);
		local menu = Proxies:ToPrivate(menuProxy);
		menuManager:CloseMenu(menu);
	end

	function MenuManagerProxyMixin:CloseMenus()
		local menuManager = Proxies:ToPrivate(self);
		menuManager:CloseMenus();
	end

	function MenuManagerProxyMixin:IsAnyMenuOpen()
		local menuManager = Proxies:ToPrivate(self);
		return menuManager:IsAnyMenuOpen();
	end

	function MenuManagerProxyMixin:OpenMenu(ownerRegion, menuDescriptionProxy, anchor)
		local menuManager = Proxies:ToPrivate(self);
		local menuDescription = Proxies:ToPrivate(menuDescriptionProxy);
		local menu = menuManager:OpenMenu(ownerRegion, menuDescription, anchor);
		return menu and menu:ToProxy();
	end

	function MenuManagerProxyMixin:OpenContextMenu(region, menuDescriptionProxy)
		local menuManager = Proxies:ToPrivate(self);
		local menuDescription = Proxies:ToPrivate(menuDescriptionProxy);
		local menu = menuManager:OpenContextMenu(region, menuDescription);
		return menu and menu:ToProxy();
	end

	local function CreateMenuManager()
		local menuManager = CreateFromMixinsPrivate(MenuManagerMixin);
		local menuManagerProxy = CreateProxy(menuManager, MenuManagerProxyMixin);
		menuManager:Init(menuManagerProxy);
		return menuManagerProxy;
	end

	local menuManagerProxy = CreateMenuManager();

	function Menu.GetManager()
		return menuManagerProxy;
	end

	local function SecureCreateRootMenuDescription(menuMixin)
		assert(menuMixin, "CreateRootMenuDescription argument 'menuMixin' is required.");
		local menuDescription = {};
		setmetatable(menuDescription, RootMenuDescriptionMixin);

		local proxy = CreateProxy(menuDescription, RootMenuDescriptionProxyMixin);
		menuDescription:Init(proxy, menuMixin);
		return menuDescription:ToProxy();
	end

	function Menu.CreateRootMenuDescription(menuMixin)
		return securecallfunction(SecureCreateRootMenuDescription, menuMixin);
	end
	
	local function SecureCreateMenuElementDescription()
		local elementDescription = {};
		setmetatable(elementDescription, MenuElementDescriptionMixin);

		local proxy = CreateProxy(elementDescription, MenuElementDescriptionProxyMixin);
		elementDescription:Init(proxy);
		return elementDescription:ToProxy();
	end

	function Menu.CreateMenuElementDescription()
		return securecallfunction(SecureCreateMenuElementDescription);
	end
	
	--[[
	Menu descriptions are always regenerated before the menu is displayed, so any additions 
	made by an addon should always appear regardless of the menu description having already 
	been created. However, if the addon wants to affect the dropdown's displayed selected 
	state, then we need to inform the dropdown to update after the changes are made.
	]]--
	local generatedDescriptions = {};

	local function SecureModifyMenu(ownerRegion, description, ...)
		local tag = description.tag;
		if not tag then
			return;
		end

		generatedDescriptions[tag] = {description, ownerRegion};

		ModifyMenuRegistry:TriggerEvent(tag, ownerRegion, description);
	end

	function Menu.PopulateDescription(menuGenerator, ownerRegion, description, ...)
		securecallfunction(menuGenerator, ownerRegion, description, ...);
		securecallfunction(SecureModifyMenu, ownerRegion, description, ...);
	end

	function Menu.ModifyMenu(tag, callback)
		assert(type(tag) == "string");

		local tbl = generatedDescriptions[tag];
		if tbl then
			local description = tbl[1];
			local ownerRegion = tbl[2];
			callback(ownerRegion, description, description.contextData);

			if IsDropdownButtonIntrinsic(ownerRegion) then
				ownerRegion:SignalUpdate();
			end
		end

		local function Callback(subscriber, ownerRegion, description)
			callback(ownerRegion, description, description.contextData);
		end
		
		-- Do not provide an owner context as we want one auto-generated to enable addons to use
		-- the same callback if they choose to do so.
		return ModifyMenuRegistry:RegisterCallbackWithHandle(tag, Callback);
	end

	function Menu.GetOpenMenuTags()
		MenuAttributeDelegate:SetAttribute("get-open-menu-tags");
		return MenuAttributeDelegate:GetAttribute("get-open-menu-tags-result");
	end

	function Menu.PrintOpenMenuTags()
		print(table.concat(Menu.GetOpenMenuTags(), LIST_DELIMITER));
	end
end