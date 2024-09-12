UnitPopupManager = { };
UnitPopupMenus = { };

local function GetNameAndClass(unit, name)
	local outName = name;
	if not outName and unit then
		outName = UnitNameUnmodified(unit) or UnitName(unit);
		end

	if not outName then
		outName = UNKNOWN;
	end

	local class;
	if unit and UnitIsPlayer(unit) then
		class = select(2, UnitClass(unit));
	end

	return outName, class;
end

function UnitPopupManager:OpenMenu(which, contextData)
	assertsafe(type(contextData) == "nil" or type(contextData) == "table", "extraContextData can only be a table if provided.");
	
	if contextData == nil then
		contextData = 
		{
			which = which,
		};
	else
		contextData.which = which;

		local name, server = nil, nil;
		local unit = contextData.unit;
		if unit then
			name, server = UnitNameUnmodified(unit);
			contextData.name = name;
			contextData.server = server;
		else
			name = contextData.name;
			if name then
				local name2, server2 = strmatch(name, "^([^-]+)-(.*)");
				if name2 then
					contextData.name = name2;
					contextData.server = server2;
				end
			end
		end
	end

	-- Remove this assert only if you've verified the intent for the inbound
	-- contextData to have it's player location overwritten.
	assert(contextData.playerLocation == nil);
	contextData.playerLocation = UnitPopupSharedUtil.TryCreatePlayerLocation(contextData);
	
	-- Remove this assert only if you've verified the intent for the inbound
	-- contextData to have it's account info overwritten.
	assert(contextData.accountInfo == nil);
	contextData.accountInfo = UnitPopupSharedUtil.GetBNetAccountInfo(contextData);

	if contextData.isMobile == nil then
		contextData.isMobile = UnitPopupSharedUtil.GetIsMobile(contextData);
	end

	local function CreateEntries(entry, description, sectionData, contextData)
		if not entry:CanShow(contextData) then
			return;
		end

		if entry:IsTitle() then
			description:QueueDivider(true);
			description:QueueTitle(entry:GetText());
		elseif entry:IsDivider() then
			description:QueueDivider(true);
		else
			local childDescription = entry:CreateMenuDescription(description, contextData);
			if not childDescription then
				assertsafe(false, string.format("Failed to create a menu description for entry %s"), entry:GetText());
				return;
			end

			childDescription:SetEnabled(function(description)
				return UnitPopupSharedUtil.IsEnabled(contextData, entry);
			end);

			local entries = entry:GetEntries();
			if entries then
				local childSectionData = {};
				for index, childEntry in ipairs(entries) do
					CreateEntries(childEntry, childDescription, childSectionData, contextData);
				end
			end
		end
	end

	local menuParent = nil;
	MenuUtil.CreateContextMenu(menuParent, function(owner, rootDescription)
		rootDescription:SetTag("MENU_UNIT_"..which, contextData);

		-- Create a class colored title atop every menu.
		local elementDescription = rootDescription:CreateTitle();
		elementDescription:AddInitializer(function(frame, description, menu)
			local title, class = GetNameAndClass(contextData.unit, contextData.name);
			frame.fontString:SetText(title);

			if class and not C_Glue.IsOnGlueScreen() then
				local colorCode = select(4, GetClassColor(class));
				local color = CreateColorFromHexString(colorCode);
				frame.fontString:SetTextColor(color:GetRGBA());
			end
		end);

		-- Section data for state relevant to each menu.
		local sectionData = {};
		local menu = self:GetMenu(which);
		for index, entry in ipairs(menu:AssembleMenuEntries(contextData)) do
			CreateEntries(entry, rootDescription, sectionData, contextData);
		end
	end);
end

function UnitPopupManager:GetMenu(which)
	return UnitPopupMenus[which];
end

function UnitPopupManager:RegisterMenu(which, menu)
	UnitPopupMenus[which] = menu;
end

function UnitPopup_OpenMenu(which, contextData)
	local anchor = nil;
	UnitPopupManager:OpenMenu(which, contextData, anchor);
end
