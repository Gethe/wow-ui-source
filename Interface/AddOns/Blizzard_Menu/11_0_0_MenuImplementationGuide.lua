--[[
Blizzard_Menu implementation guide

Blizzard_Menu is a new framework for creating context menus and dropdown menus, and is a complete replacement for UIDropDownMenu.
All uses of UIDropDownMenu have been converted to use Blizzard_Menu, and UIDropDownMenu is now deprecated. Due to the
large fundamental differences between these two systems, shims have not been provided, and any public uses of UIDropDownMenu 
will also need to rewrite their implementation in terms of Blizzard_Menu to take advantage of the changes.

*** Menus ***
Menus are frames containing a collection of common controls like buttons, radios and checkboxes, but can also 
contain specialized frames. These menus can be opened at the cursor (context menus), or adjoined to dropdown buttons. 
The contents of these menus are defined by a generator function. Its arguments are a menu owner and a root description
that hold the menu contents.

Example:

local function GeneratorFunction(owner, rootDescription)
	rootDescription:CreateTitle("My Title");
	rootDescription:CreateButton("My Button", function(data)
    	-- Button handling here.
	end);
end);

*** Submenus ***
Elements added to a root description are called element descriptions and share most of the functions available in the 
root description. For example, element descriptions can have controls added to them in the same manner as they were added
to the root description. When an element description has elements added to it, it becomes and will display as a submenu.

Example:
local submenu = rootDescription:CreateButton("My Submenu");
submenu:CreateButton("Enable", SetEnabledFunction, true);
submenu:CreateButton("Disable", SetEnabledFunction, false);

*** Root Description and Element Description API ***
These functions are available to both description types:
SetTag
ClearQueuedDescription
AddQueuedDescription
Insert

These functions are available only to element descriptions:
SetRadio
IsSelected 
SetIsSelected
SetSelectionIgnored
SetSoundKit
SetOnEnter
SetOnLeave
SetEnabled
IsEnabled
SetData
SetResponder
SetResponse
SetTooltip
Pick

*** Adding Elements ***
To add element descriptions to another element description, it is recommended to use one of these Create functions that 
best represents your control type. Note that these functions are not made available on dividers and spacers, for practicality reasons:

CreateFrame(frameType)
CreateTemplate(frameTemplate)
CreateButton
CreateTitle
CreateCheckbox
CreateRadio
CreateDivider
CreateSpacer
CreateColorSwatch

You may want to insert a title, divider or spacer, but only if additional elements are going to be added:
QueueTitle
QueueDivider
QueueSpacer

*** Context Menus ***
While context menus can technically be opened atop empty space (as long as there a region to detect the mouse up/click), they are 
generally opened atop a region such as a button or list element. This region is called the owner region (or owner for short). 
If the owner becomes hidden while its menu is open, the menu will be automatically closed.

Example:
(See GeneratorFunction above)
MenuUtil.CreateContextMenu(owner, GeneratorFunction);

*** Dropdown Buttons ***
Dropdown buttons create menus adjoined to themselves on mouse down. Similarly to context menus, the implied owner here is the 
dropdown button. As with context menus, if the dropdown button becomes hidden while its menu is open, it will be automatically closed.

Example:
(See GeneratorFunction above)
dropdownButton:SetupMenu(GeneratorFunction);

In XML, these dropdown buttons should always be created using the DropdownButton intrinsic. Using this intrinsic absolves you from 
implementation steps related to menu behavior. For example, the menu will open on press, play an appropriate open/close sound, 
and display the selected text options (if appropriate) automatically.

Example:
<DropdownButton parentKey="FilterDropdown" inherits="WowStyle1FilterDropdownTemplate">
	<Anchors>
		<Anchor point="TOPRIGHT" x="-26" y="-64"/>
	</Anchors>
</DropdownButton>

In Lua, the dropdown button can be created like any other frame. For example, using CreateFrame:

Example:
local dropdown = CreateFrame("DropdownButton", nil, MyParentFrame, "WowStyle1DropdownTemplate");
dropdown:SetDefaultText("My Dropdown");
dropdown:SetPoint("CENTER", 0, -250);
dropdown:SetupMenu(GeneratorFunction);

*** Templates ***
Templates are provided in MenuTemplates.xml for the most common dropdown styles used throughout our UI. You'll find WowStyle1DropdownTemplate 
and WowStyle1FilterDropdownTemplate used most frequently in the code. WowStyle1DropdownTemplate is used for dropdowns where at least one 
selectable element is possible, and WowStyle1FilterDropdownTemplate is used for categorical filters where many selectable elements are possible.

Context menus do not depend on any templates whatsoever.

*** Selection State ***
By default, the text displayed on a selectable dropdown button (e.g. WowStyle1DropdownTemplate) is informed by the selected status of the element
descriptions inside the menu. For example, given the following menu description, the text displayed inside the dropdown button should be "Radio1".

Example:
g_selectedIndex = 1;

local function IsSelected(index) return index == g_selectedIndex; end
local function SetSelected(index) g_selectedIndex = index; end

local function GeneratorFunction(dropdown, rootDescription)
	for index = 1, 3 do
	    rootDescription:CreateRadio("My Radio "..index, IsSelected, SetSelected, index);
	end
end

dropdown:SetupMenu(GeneratorFunction);

When the dropdown button is shown, the generator function will be called (if it exists) to populate the description. Once finished, the dropdown 
button will iterate through all of the element descriptions accessible to the root description to find all of the selected elements, combining the 
result to form the selection text. If there are multiple selected elements, the text will become a comma delimited list.

*** Manipulating Selection Text ***
It is common for the selection text to require special behavior. Many times it won't be desirable for the same text that accompanies the element 
descriptions to be used as the selection text. In some cases, you may need to exclude specific selectable element descriptions from consideration 
altogether.

Here are some of the supported ways to change the results:

SetSelectionTranslator(func): This is a function called on each element description, allowing for a custom return. In the example, the selection.data 
is a number representing a rank (1, 2, 3, etc.), but the translator changes it to become "Rank 1", "Rank 2", "Rank 3", etc.

Example:
self:SetSelectionTranslator(function(selection)
	return TRADESKILL_RECIPE_LEVEL_DROPDOWN_BUTTON_FORMAT:format(selection.data);
end);

SetSelectionText(func): A function called once with all known selected element descriptions, returning the desired text. In the example, the 
selections are ignored completely, and instead some internal state is used instead to display the desired string, which could be "Any", "Multiple", 
or a formatted string combining class and spec. The implementation could have considered what was selected, if useful.

Example:
self:SetSelectionText(function(selections)
	if self.checkedCount > 1 then
		return CLUB_FINDER_MULTIPLE_ROLES;
	end

	if self.checkedCount == 1 then
		local specID, specInfo = next(self.checkedList);
		return TALENT_SPEC_AND_CLASS:format(specInfo.specName, specInfo.className);
	end

	return CLUB_FINDER_ANY_FLAG;
end);

OverrideText(text): Sets the text and ignores all selection state.

Example:
self.Dropdown:OverrideText("My Text");

SetDefaultText(text): Sets the text displayed when no selections are found.

Example:
self.TitleDropdown:SetDefaultText(PAPERDOLL_SELECT_TITLE);

SetSelectionIgnored(): Marks an element description to be ignored as a selection candidate.

Example:
local checkbox = rootDescription:CreateCheckbox(REPUTATION_CHECKBOX_SHOW_LEGACY_REPUTATIONS, IsLegacyRepSelected, SetLegacyRepSelected);
checkbox:SetSelectionIgnored();

*** Updating a Dropdown Button ***
As mentioned, the selection text is informed by the selected element descriptions, so if code external to the dropdown causes the logical 
state to change, the dropdown needs to be notified to update. This is most easily done by calling GenerateMenu() on the dropdown to cause a 
new root description to be created and then reevaluate the selected text. This is also commonly the most reliable. Note that this does not 
need to occur if the source of the change originated from selecting a menu element, as that will trigger a selection text automatically.

*** Configuring Element Description Frames ***
*** Changing Properties ***
Element descriptions inform the menu system what to create, but once the frames are created, most of the customization occurs through an initializer. 
The first argument of the initializer is a frame. Here is an example of an initializer that simply changes the font object on the font string that 
accompanies the Radio template.

Example:
local radio = rootDescription:CreateRadio(durationText, IsSelected, SetSelected, index);
radio:AddInitializer(function(button, description, menu)
	button.fontString:SetFontObject("Number12Font");
end);

*** Initializing a Template *** 

If you have a template that needs to be initialized with data that lives elsewhere (in this case, the dropdown button), you may need a slightly more 
involved initializer, but the approach is similar:

Example:
local levelRangeFrame = rootDescription:CreateTemplate("LevelRangeFrameTemplate");
levelRangeFrame:AddInitializer(function(frame, elementDescription, menu)
	frame:Reset();

	local minLevel = filterDropdown.minLevel;
	if minLevel > 0 then
		frame:SetMinLevel(minLevel);
	end

	local maxLevel = filterDropdown.maxLevel;
	if maxLevel > 0 then
		frame:SetMaxLevel(maxLevel);
	end

	frame:SetLevelRangeChangedCallback(function(minLevel, maxLevel)
		filterDropdown.minLevel, filterDropdown.maxLevel = minLevel, maxLevel;
		filterDropdown:ValidateResetState();
	end);
end);

*** Custom Buttons and Handling ***
If you want to use your own button template in the menu, you need to inform the menu description object when it has been
chosen (clicked, mouse down, or otherwise). This is done by calling Pick() on the description object:

local data = {...};
local buttonDescription = rootDescription:CreateTemplate("YourButtonTemplate", data);
buttonDescription:AddInitializer(function(button, description, menu)
	button:SetScript("OnClick", function(button, buttonName)
		local inputContext = MenuInputContext.MouseButton;
		description:Pick(inputContext, buttonName);
	end);
end);

You can additionally provide a responder function to take advantage of a custom response type depending on your use case.
buttonDescription:SetResponder(function(data, menuInputData, menu)
	-- Your handler here...

	return MenuResponse.Close;
end

The current response types are:
MenuResponse = 
{
	Open = 1, -- Menu remains open and unchanged
	Refresh = 2, -- All frames in the menu are reinitialized
	Close = 3, -- Parent menus remain open but this menu closes
	CloseAll = 4, -- All menus close
};

*** Compositor ***
Compositor facilitates restoring a region to its default state and enables composing a temporary hierarchy of regions that can be 
disposed on demand. In the case of Menu, this is most useful for specializing common control types without having to create additional templates.

If you wanted to use a radio template, but also need various other regions on the frame, you can follow this example from Currency Transfer. 
This attaches and initializes a texture, font string, and then reanchors everything as desired. Take note of each AttachTexture and AttachFontString 
call, functions that are added to the button via the compositor.

Example:
local radio = rootDescription:CreateRadio(currencyData.characterName, IsSelected, SetSelected, currencyData);
radio:AddInitializer(function(button, description, menu)
	local rightTexture = button:AttachTexture();
	rightTexture:SetSize(18, 18);
	rightTexture:SetPoint("RIGHT");
	rightTexture:SetTexture(currencyInfo.icon);

	local fontString = button.fontString;
	fontString:SetPoint("RIGHT", rightTexture, "LEFT");
	fontString:SetTextColor(NORMAL_FONT_COLOR:GetRGB());

	local fontString2 = button:AttachFontString();
	fontString2:SetHeight(20);
	fontString2:SetPoint("RIGHT", rightTexture, "LEFT", -5, 0);
	fontString2:SetJustifyH("RIGHT");
	fontString2:SetText(BreakUpLargeNumbers(currencyData.quantity));

	-- Manual calculation required to accomodate aligned text.
	local pad = 20;
	local width = pad + fontString:GetUnboundedStringWidth() + fontString2:GetUnboundedStringWidth() + rightTexture:GetWidth();

	local height = 20;
	return width, height;
end);

When this menu is closed, all of the regions will be stripped off of the radio, scripts will be cleared, and key changes reverted. It only exists for
the lifetime the control is shown.

*** Element Extents ***
The vast majority of the time you do not need to provide the extents of the frame. There are some scenarios like the example above where specific 
padding might be desired, notably on frames where content is both left and right anchored, leaving the width difficult to deduce.

The menu container will resize to enclose all of the menu elements. Each menu element is assigned a frame, and that the extent of each frame is 
acquired according to the following rules, in priority order:

1) The first size returned by a derived initializer. This return is optional, and omitted in 99% of the cases an initializer is provided.
2) The size of the bounding box of every region on the menu element frame. This only occurs if a compositor is assigned to the frame (default).
3) The size of the frame. This is the final case, because all frames have a size, even if it is the defaulted size of 1x1 in the compositor.

*** Tooltips ***

While you could manually setup the scripts to display a tooltip on a frame inside an element initializer, an easier approach is to call SetTooltip to 
delegate that setup to the menu system. If you passed data to your element description, you could access it using GetData().

Example:
local button = rootDescription:CreateButton("Button", OnClick);
button:SetTooltip(function(tooltip, elementDescription)
	GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
	GameTooltip_AddInstructionLine(tooltip, "Test Tooltip Instruction");
	GameTooltip_AddNormalLine(tooltip, "Test Tooltip Normal Line");
	GameTooltip_AddErrorLine(tooltip, "Test Tooltip Colored Line");
end);

*** Display Modes ***
By default, menus layout elements vertically. To enable a grid layout, use SetGridMode. If columns are not provided, then the column count will be 
selected automatically from AutoCalculateColumns (provided below):

Example:
local columns = 2;
rootDescription:SetGridMode(MenuConstants.VerticalGridDirection, columns);

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

*** Scrolling Menus ***
In rare circumstances with potentially large menu sets, you may need a scrolling menu. To enable this, use SetScrollMode.

Example:
local extent = 20;
local maxCharacters = 8;
local maxScrollExtent = extent * maxCharacters;
rootDescription:SetScrollMode(maxScrollExtent);

*** Positioning ***
Different rules apply to the positioning of a root menu:

Root context menus will always clamp to screen. 
Dropdown root menus never clamp to screen along the vertical axis. If the menu cannot fit, it will be reflected across the vertical axis, and then 
clamped to screen on the horizontal axis. This prevents the menu from overlapping the dropdown it is attached to.

Submenus never clamp to screen. Similarly to root menus, if the submenu cannot fit, it will be reflected across the horizontal axis of the element 
it is attached to. This rule applies to any depth of submenus, but menu elements will always try to create submenus in the left-to-right direction 
when possible.

*** Styles ***
The choice of menu background texture, interior extent padding, and child extent padding is determined by the menu style assigned to the context 
menu or dropdown button. When a context menu is opened, unless the owner region provides an override, the choice of menu style mixin is determined 
in MenuVariants.GetDefaultContextMenuMixin(). Similarly, unless a dropdown button provides an override, the choice of menu style mixin is determined
in MenuVariants.GetDefaultMenuMixin().

*** Helpers ***
If you are creating a dropdown button menu of common control types and you do not need to make adjustements to any of the elements, consider 
using one of these variadic utilities to simplify your definition:

MenuUtil.CreateButtonMenu
MenuUtil.CreateCheckboxMenu
MenuUtil.CreateRadioMenu
MenuUtil.CreateEnumRadioMenu
MenuUtil.CreateButtonContextMenu
MenuUtil.CreateCheckboxContextMenu
MenuUtil.CreateRadioContextMenu
MenuUtil.CreateEnumRadioContextMenu

Example 1:
MenuUtil.CreateButtonMenu(dropdown,
	{"My Button 1", OnClick, 1},
	{"My Button 2", OnClick, 2},
	{"My Button 3", OnClick, 3}
);

Example 2:
MenuUtil.CreateCheckboxContextMenu(ownerButton,
	CheckboxAPI.IsSelected, 
	CheckboxAPI.ToggleSelected,
	{"My Checkbox 1", 1},
	{"My Checkbox 2", 2},
	{"My Checkbox 3", 3},
	{"My Checkbox 4", 4},
	{"My Checkbox 5", 5}
);

*** Addon Menu Customization ***
Root menu descriptions are tagged with a string identifier that addon authors can use to register a function that appends elements to the menu.

A UnitPopup menu tag is in the format MENU_UNIT_<UNIT_TYPE>, where UNIT_TYPE is one of the unit types (SELF, RAID, PARTY1, etc.) and is accompanied 
by a contextData table that an addon can use to get more information about the menu.

To modify a menu:

Example:
Menu.ModifyMenu("MENU_MINIMAP_TRACKING", function(owner, rootDescription, contextData)
	rootDescription:CreateDivider();
	rootDescription:CreateTitle("My Addon");
	rootDescription:CreateButton("Button", function() print("Text here!" end);
end);

*** Taint ***
The menu system was designed with consideration to better support addon customization without taint consequences. Addons should always be able to 
insert elements at any position in a menu without imparting taint to any of the surrounding element handlers.

*** Event Trace Menu Discovery ***
When a tagged menu is opened, EventTrace will display a "Menu.OpenMenuTag" event with the tag to easily identify the menu. Alternatively, 
Menu.PrintOpenMenuTags() can be called to print all open tagged menus.
]]--