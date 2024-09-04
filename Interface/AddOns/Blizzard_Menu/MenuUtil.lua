local MenuUtilPrivate = {};
local CreateDropdownMenuUsingInserter = nil;
local CreateContextMenuUsingInserter = nil;

do
	local function VariadicInsert(elementDescription, inserter, ...)
		local arg = ...;
		if arg == nil then
			return;
		end

		elementDescription:Insert(inserter(unpack(arg)));
		VariadicInsert(elementDescription, inserter, select(2, ...));
	end

	CreateDropdownMenuUsingInserter = function(dropdown, inserter, ...)
		local tbl = {...};

		dropdown:SetupMenu(function(dropdown, rootDescription)
			VariadicInsert(rootDescription, inserter, unpack(tbl));
		end);
	end

	CreateContextMenuUsingInserter = function(ownerRegion, inserter, ...)
		local tbl = {...};

		return MenuUtil.CreateContextMenu(ownerRegion, function(ownerRegion, rootDescription)
			VariadicInsert(rootDescription, inserter, unpack(tbl));
		end);
	end
end


MenuUtil = {};

local function TraverseMenu(elementDescription, op, condition)
	if (condition == nil) or condition(elementDescription) then
		local handled = op(elementDescription);
		if handled then
			return true;
		end
	end

	for index, desc in elementDescription:EnumerateElementDescriptions() do
		local handled = TraverseMenu(desc, op, condition);
		if handled then
			return true;
		end
	end

	return false;
end

function MenuUtil.TraverseMenu(elementDescription, op, condition)
	for index, desc in elementDescription:EnumerateElementDescriptions() do
		local handled = TraverseMenu(desc, op, condition);
		if handled then
			return true;
		end
	end
	return false;
end

local function TraverseSelections(elementDescription, selections, condition)
	if ((condition == nil) or condition(elementDescription)) and (elementDescription:IsSelected()) then
		table.insert(selections, elementDescription);
	end
	
	for index, desc in elementDescription:EnumerateElementDescriptions() do
		TraverseSelections(desc, selections, condition);
	end

	return false;
end

function MenuUtil.GetSelections(elementDescription, condition)
	local selections = {};
	for index, desc in elementDescription:EnumerateElementDescriptions() do
		TraverseSelections(desc, selections, condition);
	end
	return selections;
end

local function MergeFunctions(elementDescription)
	for key, inserter in pairs(MenuUtilPrivate.GetInserters()) do
		elementDescription[key] = function(self, ...)
			return self:Insert(inserter(...));
		end;
	end

	for key, func in pairs(MenuUtilPrivate.GetUtilities()) do
		elementDescription[key] = func;
	end

	return elementDescription;
end

function MenuUtil.ShowTooltip(owner, func, ...)
	local tooltip = GetAppropriateTooltip();
	tooltip:SetOwner(owner, "ANCHOR_RIGHT");
	func(tooltip, ...);
	tooltip:Show();
end

function MenuUtil.HideTooltip(owner)
	local tooltip = GetAppropriateTooltip();
	if tooltip:GetOwner() == owner then
		tooltip:Hide();
	end
end

function MenuUtil.HookTooltipScripts(owner, func)
	local tooltip = GetAppropriateTooltip();
	
	local oldOnEnter = owner:GetScript("OnEnter") or nop;
	owner:SetScript("OnEnter", function(...)
		tooltip:SetOwner(owner, "ANCHOR_RIGHT");
		oldOnEnter(...)
		func(tooltip);
		tooltip:Show();
	end);

	local oldOnLeave = owner:GetScript("OnLeave") or nop;
	owner:SetScript("OnLeave", function(...)
		oldOnLeave(...)
		func(tooltip);
		tooltip:Hide();
	end);
end

function MenuUtil.CreateRootMenuDescription(menuMixin)
	local elementDescription = Menu.CreateRootMenuDescription(menuMixin);
	MergeFunctions(elementDescription);
	return elementDescription;
end

--[[
Creates a context menu at the cursor. The region provided will inform the menu to close if it
becomes hidden. If no region is provided, then an explicit mouse press or ESC press will
be required to close it.
]]

local function SecureGetMenuMixin(ownerRegion)
	-- An addon may choose to override GetDefaultContextMenuMixin, though the implications that has on
	-- forbidden frames aren't clear yet.
	return ownerRegion.menuMixin or MenuVariants.GetDefaultContextMenuMixin();
end

function MenuUtil.CreateContextMenu(ownerRegion, generator, ...)
	if not ownerRegion then
		ownerRegion = GetAppropriateTopLevelParent();
	end

	local menuMixin = securecallfunction(SecureGetMenuMixin, ownerRegion);
	local elementDescription = MenuUtil.CreateRootMenuDescription(menuMixin);

	Menu.PopulateDescription(generator, ownerRegion, elementDescription, ...);

	local menu = Menu.GetManager():OpenContextMenu(ownerRegion, elementDescription);
	if menu then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end

	return menu;
end

--[[ Accessors so the implementation can change. Avoid grabbing .text off a description unless you're
prepared to fixup broken references when it moves or changes.
]]--
function MenuUtil.SetElementText(elementDescription, text)
	elementDescription.text = text;
end

function MenuUtil.GetElementText(elementDescription)
	return elementDescription.text;
end

function MenuUtil.CreateFrame()
	local elementDescription = MenuTemplates.CreateFrame();
	MergeFunctions(elementDescription);
	return elementDescription;
end

function MenuUtil.CreateTemplate(template)
	local elementDescription = MenuTemplates.CreateTemplate(template);
	MergeFunctions(elementDescription);
	return elementDescription;
end

local function ConfigureTextButton(text, elementDescription)
	MergeFunctions(elementDescription);
	MenuUtil.SetElementText(elementDescription, text);
	return elementDescription;
end

function MenuUtil.CreateTitle(text, color)
	local elementDescription = MenuTemplates.CreateTitle(text);
	ConfigureTextButton(text, elementDescription);

	local useColor = color or NORMAL_FONT_COLOR;
	elementDescription:AddInitializer(function(frame, description, menu)
		frame.fontString:SetTextColor(useColor:GetRGBA());
	end);
	return elementDescription;
end

function MenuUtil.CreateButton(text, callback, data)
	--assert(type(text) == "string");
	--assert((callback == nil) or type(callback) == "function");
	local elementDescription = MenuTemplates.CreateButton(text, callback, data);
	return ConfigureTextButton(text, elementDescription);
end

function MenuUtil.CreateCheckbox(text, isSelected, setSelected, data)
	--assert(type(text) == "string");
	--assert(type(isSelected) == "function");
	--assert(type(setSelected) == "function");
	local elementDescription = MenuTemplates.CreateCheckbox(text, isSelected, setSelected, data);
	return ConfigureTextButton(text, elementDescription);
end

function MenuUtil.CreateRadio(text, isSelected, setSelected, data)
	--assert(type(text) == "string");
	--assert(type(isSelected) == "function");
	--assert(type(setSelected) == "function");
	local elementDescription = MenuTemplates.CreateRadio(text, isSelected, setSelected, data);
	return ConfigureTextButton(text, elementDescription);
end

function MenuUtil.CreateColorSwatch(text, callback, colorInfo)
	--assert(type(text) == "string");
	--assert(type(callback) == "function");
	--assert(type(colorInfo) == "table");
	local elementDescription = MenuTemplates.CreateColorSwatch(text, callback, colorInfo);
	return ConfigureTextButton(text, elementDescription);
end

--[[
Wrappers for convenience since all other create functions are in MenuUtil. Note that these
are not accompanied by any additional utilities or inserters.
]]--
MenuUtil.CreateDivider = MenuTemplates.CreateDivider;
MenuUtil.CreateSpacer = MenuTemplates.CreateSpacer;

MenuUtilPrivate.Inserters =
{
	CreateFrame = MenuUtil.CreateFrame,
	CreateTemplate = MenuUtil.CreateTemplate,
	CreateButton = MenuUtil.CreateButton,
	CreateTitle = MenuUtil.CreateTitle,
	CreateCheckbox = MenuUtil.CreateCheckbox,
	CreateRadio = MenuUtil.CreateRadio,
	CreateDivider = MenuUtil.CreateDivider,
	CreateSpacer = MenuUtil.CreateSpacer,
	CreateColorSwatch = MenuUtil.CreateColorSwatch,
};

function MenuUtilPrivate.GetInserters()
	return MenuUtilPrivate.Inserters;
end

local function DefaultTooltipInitializer(tooltip, elementDescription)
	local titleText = MenuUtil.GetElementText(elementDescription);
	GameTooltip_SetTitle(tooltip, titleText);
end

local function SetTooltip(elementDescription, initializer)
	elementDescription:SetOnEnter(function(frame)
		MenuUtil.ShowTooltip(frame, initializer or DefaultTooltipInitializer, elementDescription);
	end);
end

local function TitleAndTextTooltipInitializer(tooltip, tooltipTitle, tooltipText)
	GameTooltip_SetTitle(tooltip, tooltipTitle);
	GameTooltip_AddNormalLine(tooltip, tooltipText, true);
end

local function SetTitleAndTextTooltip(elementDescription, tooltipTitle, tooltipText)
	elementDescription:SetOnEnter(function(frame)
		MenuUtil.ShowTooltip(frame, TitleAndTextTooltipInitializer, tooltipTitle, tooltipText);
	end);
end

local function QueueDescription(description, queueDescription, clearQueue)
	if clearQueue then
		description:ClearQueuedDescriptions();
	end
	description:AddQueuedDescription(queueDescription);
end

local function QueueTitle(description, text, color, clearQueue)
	QueueDescription(description, MenuUtil.CreateTitle(text, color), clearQueue);
end

local function QueueDivider(description, clearQueue)
	QueueDescription(description, MenuUtil.CreateDivider(), clearQueue);
end

local function QueueSpacer(description, extent, clearQueue)
	QueueDescription(description, MenuUtil.CreateSpacer(extent), clearQueue);
end

MenuUtilPrivate.Utilities =
{
	SetTooltip = SetTooltip,
	SetTitleAndTextTooltip = SetTitleAndTextTooltip,
	QueueTitle = QueueTitle,
	QueueDivider = QueueDivider,
	QueueSpacer = QueueSpacer,
};

function MenuUtilPrivate.GetUtilities()
	return MenuUtilPrivate.Utilities;
end

--Variadic menu functions

--[[
... is a variadic array of non-associative tables, whose values match the Inserter function below.
The 'data' argument is optional.
]]
function MenuUtil.CreateButtonMenu(dropdown, ...)
	local function Inserter(text, onClick, data)
		return MenuUtil.CreateButton(text, onClick, data);
	end

	return CreateDropdownMenuUsingInserter(dropdown, Inserter, ...);
end

function MenuUtil.CreateButtonContextMenu(ownerRegion, ...)
	local function Inserter(text, onClick, data)
		return MenuUtil.CreateButton(text, onClick, data);
	end
	return CreateContextMenuUsingInserter(ownerRegion, Inserter, ...);
end

--[[
... is a variadic array of non-associative tables, whose values match the Inserter function below.
The 'data' argument is optional.
]]
function MenuUtil.CreateCheckboxMenu(dropdown, isSelected, setSelected, ...)
	local function Inserter(text, data)
		return MenuUtil.CreateCheckbox(text, isSelected, setSelected, data);
	end

	return CreateDropdownMenuUsingInserter(dropdown, Inserter, ...);
end

function MenuUtil.CreateCheckboxContextMenu(ownerRegion, isSelected, setSelected, ...)
	local function Inserter(text, data)
		return MenuUtil.CreateCheckbox(text, isSelected, setSelected, data);
	end
	return CreateContextMenuUsingInserter(ownerRegion, Inserter, ...);
end

--[[
... is a variadic array of non-associative tables, whose values match the Inserter function below.
The 'data' argument is optional.
]]
function MenuUtil.CreateRadioMenu(dropdown, isSelected, setSelected, ...)
	local function Inserter(text, data)
		return MenuUtil.CreateRadio(text, isSelected, setSelected, data);
	end
	return CreateDropdownMenuUsingInserter(dropdown, Inserter, ...);
end

function MenuUtil.CreateRadioContextMenu(ownerRegion, isSelected, setSelected, ...)
	local function Inserter(text, data)
		return MenuUtil.CreateRadio(text, isSelected, setSelected, data);
	end
	return CreateContextMenuUsingInserter(ownerRegion, Inserter, ...);
end

local function CreateEnumTables(enum, enumTranslator, orderTbl)
	local enumTbls = {};

	for enumKey, enumValue in pairs(enum) do
		table.insert(enumTbls, { enumTranslator(enumValue), enumValue });
	end

	if orderTbl then
		table.sort(enumTbls, function(lhs, rhs)
			return orderTbl[lhs[2]] < orderTbl[rhs[2]];
		end);
	else
		table.sort(enumTbls, function(lhs, rhs)
			return lhs[2] < rhs[2];
		end);
	end

	return enumTbls;
end

function MenuUtil.CreateEnumRadioMenu(dropdown, enum, enumTranslator, isSelected, setSelected, orderTbl)
	local enumTbls = CreateEnumTables(enum, enumTranslator, orderTbl);
	return MenuUtil.CreateRadioMenu(dropdown, isSelected, setSelected, unpack(enumTbls));
end

function MenuUtil.CreateEnumRadioContextMenu(dropdown, enum, enumTranslator, isSelected, setSelected, orderTbl)
	local enumTbls = CreateEnumTables(enum, enumTranslator, orderTbl);
	return MenuUtil.CreateRadioContextMenu(dropdown, isSelected, setSelected, unpack(enumTbls));
end