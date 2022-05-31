FilterComponent = EnumUtil.MakeEnum(
	"TextButton", 			-- Simple button with white text 
	"Checkbox", 			-- Button with a small checkbox on the left and white description text on the right
	"Radio", 				-- Button with a small radio check icon on the left and white description text on the right
	"DynamicFilterSet", 	-- Generates a variable number of filter buttons (TextButton, Checkbox, or Radio) based on the numFilters function that is passed in. 
	"Space", 				-- Empty space (uninteractable)
	"Separator", 			-- Grey separator line (uninteractable)
	"Title", 				-- Yellow text (uninteractable)
	"Submenu", 				-- White text with a small arrow on the right, hovering over this will display the submenu. An optional "on click" function can be specified. 
	"CustomFunction" 		-- Calls the passed in function to initialize filters (for complex/special cases)
);

--[[
	Usage:

	UIDropDownMenu_Initialize(self, ExampleFilterDropDown_Initialize, "MENU");

	function ExampleFilterDropDown_Initialize(self, level)
		local filterSystem = {
			onUpdate = [Function] -- Optional function that is called when a button in the dropdown is clicked
			filters = {
				INSERT FILTERS HERE
				Examples:
				{ type = FilterComponent.TextButton, text = [String], set = [Function], },
				{ type = FilterComponent.Checkbox, text = [String], set = [Function], isSet = [Function], },
				{ type = FilterComponent.Radio, text = [String], set = [Function], isSet = [Function], },
				{ type = FilterComponent.DynamicFilterSet,
				  buttonType = [FilterComponent] -- Supports TextButton, Checkbox, Radio
				  set = [Function],
				  isSet = [Function],
				  numFilters = [Function],
				  filterValidation = [Function],
				  globalPrepend = [String],
				  globalPrependOffset = [Number] -- OPTIONAL 
				},
				{ type = FilterComponent.Space, },
				{ type = FilterComponent.Title, text = [String], },
				{ type = FilterComponent.Submenu, text = [String], value = [Number], childrenInfo = {
						filters = {
							INSERT SUBMENU FILTERS HERE
						},
					},
				},
				{ type = FilterComponent.CustomFunction, customFunc = [Function], },
			},
		};

		FilterDropDownSystem.Initialize(self, filterSystem, level);
	end
--]]

FilterDropDownSystem = {};

function FilterDropDownSystem.Initialize(dropdown, filterSystem, level)
	if level == 1 then
		FilterDropDownSystem.SetUpDropDownLevel(dropdown, filterSystem, level);
	else
		for filterIndex, filterInfo in ipairs(filterSystem.filters) do
			if filterInfo.value == UIDROPDOWNMENU_MENU_VALUE and level == 2 then
				local subMenuLayout = filterInfo.childrenInfo;
				subMenuLayout.onUpdate = filterSystem.onUpdate;
				FilterDropDownSystem.SetUpDropDownLevel(dropdown, subMenuLayout, level);
				return;
			elseif level == 3 then
				local secondLevelFilters = filterInfo.childrenInfo;
				if secondLevelFilters then
					for secondLevelFilterIndex, secondLevelFilterInfo in ipairs(secondLevelFilters.filters) do
						if secondLevelFilterInfo.value == UIDROPDOWNMENU_MENU_VALUE then
							local subMenuLayout = secondLevelFilterInfo.childrenInfo;
							subMenuLayout.onUpdate = filterSystem.onUpdate;
							FilterDropDownSystem.SetUpDropDownLevel(dropdown, subMenuLayout, level);
							return;
						end
					end
				end
			end
		end
	end
end

function FilterDropDownSystem.SetUpDropDownLevel(dropdown, filterSystem, level)
	for filterIndex, filterInfo in ipairs(filterSystem.filters) do
		if filterInfo.type == FilterComponent.TextButton then
			local set = function()
							filterInfo.set();
							if filterSystem.onUpdate then
								filterSystem.onUpdate();
							end
						end
			FilterDropDownSystem.AddTextButton(filterInfo.text, set, level);
		elseif filterInfo.type == FilterComponent.Checkbox then
			local set = function(_, _, _, value)
						filterInfo.set(value);
						if filterSystem.onUpdate then
							filterSystem.onUpdate();
						end
					end
			local isSet = filterInfo.isSet(filterInfo.filter);
			FilterDropDownSystem.AddCheckBoxButton(filterInfo.text, set, isSet, level);
		elseif filterInfo.type == FilterComponent.Radio then
			local set = function(_, _, _, value)
						filterInfo.set(value);
						if filterSystem.onUpdate then
							filterSystem.onUpdate();
						end
					end
			local isSet = filterInfo.isSet(filterInfo.filter);
			FilterDropDownSystem.AddRadioButton(filterInfo.text, set, isSet, level);
		elseif filterInfo.type == FilterComponent.DynamicFilterSet then
			-- Pass this function through since we may need it as well
			filterInfo.onUpdate = filterSystem.onUpdate;
			FilterDropDownSystem.AddDynamicFilterSet(filterInfo, level);
		elseif filterInfo.type == FilterComponent.Space then
			FilterDropDownSystem.AddSpace(level);
		elseif filterInfo.type == FilterComponent.Separator then
			FilterDropDownSystem.AddSeparator(level);
		elseif filterInfo.type == FilterComponent.Title then
			FilterDropDownSystem.AddTitle(filterInfo.text, level);
		elseif filterInfo.type == FilterComponent.Submenu and filterInfo.childrenInfo ~= nil then
			FilterDropDownSystem.AddSubMenuButton(filterInfo.text, filterInfo.value, filterInfo.set, level);
		elseif filterInfo.type == FilterComponent.CustomFunction then
			filterInfo.customFunc(level);
		end
	end
end

function FilterDropDownSystem.AddTextButton(text, set, level)
	local textButtonInfo = {
		keepShownOnClick = true,
		isNotRadio = true,
		notCheckable = true,
		func = set,
		text = text,
	};

	UIDropDownMenu_AddButton(textButtonInfo, level);
end

function FilterDropDownSystem.AddTextButtonToFilterSystem(filterSystem, text, set, level)
	local setWrapper = function(button, buttonName, down)
		set(button, buttonName, down);

		if filterSystem.onUpdate then
			filterSystem.onUpdate();
		end
	end

	FilterDropDownSystem.AddTextButton(text, setWrapper, level);
end

function FilterDropDownSystem.AddCheckBoxButton(text, setChecked, isChecked, level)
	local checkBoxInfo = {
		keepShownOnClick = true,
		isNotRadio = true,
		text = text,
		func = setChecked,
		checked = isChecked,
	};

	UIDropDownMenu_AddButton(checkBoxInfo, level);
end

function FilterDropDownSystem.AddCheckBoxButtonToFilterSystem(filterSystem, text, setChecked, isChecked, level)
	local setCheckedWrapper = function(button, arg1, arg2, value)
		setChecked(button, arg1, arg2, value);

		if filterSystem.onUpdate then
			filterSystem.onUpdate();
		end
	end
	
	FilterDropDownSystem.AddCheckBoxButton(text, setCheckedWrapper, isChecked, level);
end

function FilterDropDownSystem.AddRadioButton(text, setSelected, isSelected, level)
	local radioButtonInfo = {
		text = text,
		func = setSelected,
		checked = isSelected,
	};

	UIDropDownMenu_AddButton(radioButtonInfo, level);
end

function FilterDropDownSystem.AddRadioButtonToFilterSystem(filterSystem, text, setSelected, isSelected, level)
	local setSelectedWrapper = function()
		setSelected();

		if filterSystem.onUpdate then
			filterSystem.onUpdate();
		end
	end
	FilterDropDownSystem.AddRadioButton(text, setSelectedWrapper, isSelected, level);
end

function FilterDropDownSystem.AddDynamicFilterSet(filterSetInfo, level)
	local numFilters = filterSetInfo.numFilters();
	for i = 1, numFilters, 1 do
		local filterValidation = filterSetInfo.filterValidation;
		local isValidFilter = (filterValidation == nil) or filterValidation(i);
		if isValidFilter then
			local offset = filterSetInfo.globalPrependOffset;
			local globalPrepend = filterSetInfo.globalPrepend .. (offset and offset + i or i);
			if filterSetInfo.buttonType == FilterComponent.TextButton then
				local set =	function()
							filterSetInfo.set();
							if filterSetInfo.onUpdate then
								filterSetInfo.onUpdate();
							end
						end					
				FilterDropDownSystem.AddTextButton(_G[globalPrepend], set, level)
			else
				local set =	function(_, _, _, value)
							filterSetInfo.set(i, value);
							if filterSetInfo.onUpdate then
								filterSetInfo.onUpdate();
							end
						end
				local isSet = function() return filterSetInfo.isSet(i); end;
				if filterSetInfo.buttonType == FilterComponent.Checkbox then
					FilterDropDownSystem.AddCheckBoxButton(_G[globalPrepend], set, isSet, level);
				elseif filterSetInfo.buttonType == FilterComponent.Radio then
					FilterDropDownSystem.AddRadioButton(_G[globalPrepend], set, isSet, level);
				end
			end
		end
	end
end

function FilterDropDownSystem.AddSpace(level)
	UIDropDownMenu_AddSpace(level);
end

function FilterDropDownSystem.AddSeparator(level)
	UIDropDownMenu_AddSeparator(level);
end

function FilterDropDownSystem.AddTitle(text, level)
	local headerInfo = {
		isNotRadio = true,
		notCheckable = true,
		isTitle = true;
		text = text,
	};

	UIDropDownMenu_AddButton(headerInfo, level);
end

function FilterDropDownSystem.AddSubMenuButton(text, value, set, level)
	local subMenuInfo = {
		keepShownOnClick = true,
		hasArrow = true,
		notCheckable = true,
		func = set,
		text = text,
		value = value,
	};

	UIDropDownMenu_AddButton(subMenuInfo, level)
end