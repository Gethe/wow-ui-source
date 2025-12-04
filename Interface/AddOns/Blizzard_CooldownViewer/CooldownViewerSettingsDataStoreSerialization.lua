local SAVE_FIELD_ID_VERSION = 1;

-- NOTE: SAVE_FIELD_ID_ACTIVE_LAYOUT_NAMES
-- In v3 and below: This is specTag (number) -> layout name (string)
-- In v4 (and likely above) this is spec (number) -> layoutID (number)
local SAVE_FIELD_ID_ACTIVE_LAYOUT_NAMES = 2;
local SAVE_FIELD_ID_LAYOUTS = 3;
local SAVE_FIELD_ID_LAYOUT_ID_DATA = 4;

local SAVE_FIELD_ID_COOLDOWN_ORDER = 1;
local SAVE_FIELD_ID_CATEGORY_OVERRIDES = 2;
local SAVE_FIELD_ID_ALERT_OVERRIDES = 3;

local ENCODING_VERSION_PAYLOAD_DELIMITER = "|";

CooldownViewerDataStoreSerializationMixin = {};

function CooldownViewerDataStoreSerializationMixin:Init(layoutManager, persistenceObject)
	self:SetSerializationPersistenceObject(persistenceObject);
	self.layoutManager = layoutManager;
	self:ReadData();
end

function CooldownViewerDataStoreSerializationMixin:IsLoaded()
	return self:GetSerializedData() ~= nil;
end

function CooldownViewerDataStoreSerializationMixin:ResetToDefaults()
	self:ClearSerializedData();
end

function CooldownViewerDataStoreSerializationMixin:GetLayoutManager()
	return self.layoutManager;
end

function CooldownViewerDataStoreSerializationMixin:SetSerializationPersistenceObject(persistenceObject)
	--[[
		The persistenceObject must implement this API:
			obj:SetSerializedData(...)	: Accepts a string, typically stores it to a storage container
			obj:GetSerializedData() 	: Returns a string, represents something that CooldownViewerDataStoreSerializationMixin can deserialize.
			obj:ClearSerializedData() 	: Resets internal state so that the serialized data is no longer stored anywhere.

		If a persistenceObject isn't set on the serializer, a default storage mechanism will be used.

		Asserting here to capture the issue at the callsite, rather than erroring when the call occurs.
	--]]

	assertsafe(not persistenceObject or persistenceObject.SetSerializedData ~= nil, "SetSerializationPersistenceObject: needs SetSerializedData API");
	assertsafe(not persistenceObject or persistenceObject.GetSerializedData ~= nil, "SetSerializationPersistenceObject: needs GetSerializedData API");
	assertsafe(not persistenceObject or persistenceObject.ClearSerializedData ~= nil, "SetSerializationPersistenceObject: needs ClearSerializedData API");

	self.persistenceObject = persistenceObject;
end

function CooldownViewerDataStoreSerializationMixin:GetSerializedData()
	if self.cachedSerializedData then
		return self.cachedSerializedData;
	end

	if self.persistenceObject then
		self.cachedSerializedData = self.persistenceObject:GetSerializedData();
	else
		self.cachedSerializedData = C_CooldownViewer.GetLayoutData();
	end

	return self.cachedSerializedData;
end

function CooldownViewerDataStoreSerializationMixin:SetSerializedData(serializedData)
	self.cachedSerializedData = nil;

	if self.persistenceObject then
		self.persistenceObject:SetSerializedData(serializedData);
	else
		C_CooldownViewer.SetLayoutData(serializedData);
	end
end

function CooldownViewerDataStoreSerializationMixin:ClearSerializedData()
	self.cachedSerializedData = nil;

	if self.persistenceObject then
		self.persistenceObject:ClearSerializedData();
	else
		self:SetSerializedData("");
	end
end

local function CheckWriteCooldownOrderToLayout_v1(layoutManager, layoutObject, orderedCooldownIDs)
	if orderedCooldownIDs then
		layoutManager:WriteCooldownOrderToLayout(layoutObject, orderedCooldownIDs);
	end
end

local function CheckWriteCategoryOverridesToLayout_v1(layoutManager, layoutObject, categoryOverrides)
	if categoryOverrides then
		for cooldownCategory, cooldownIDs in pairs(categoryOverrides) do
			layoutManager:WriteCooldownCategoryToLayout(layoutObject, cooldownCategory, cooldownIDs);
		end
	end
end

local function CheckWriteAlertsToLayout_v3(layoutManager, layoutObject, alerts)
	if alerts then
		layoutManager:WriteCooldownAlertsToLayout(layoutObject, alerts);
	end
end

local function ReadDataVersion1(dataTable, layoutManager, serializer)
	local layouts = dataTable[SAVE_FIELD_ID_LAYOUTS];
	if layouts then
		for classAndSpecTag, classAndSpecLayouts in pairs(layouts) do
			for layoutName, layout in pairs(classAndSpecLayouts) do
				local layoutObject = serializer:AddLayout(layoutManager, layoutName, classAndSpecTag);
				CheckWriteCooldownOrderToLayout_v1(layoutManager, layoutObject, layout[SAVE_FIELD_ID_COOLDOWN_ORDER]);
				CheckWriteCategoryOverridesToLayout_v1(layoutManager, layoutObject, layout[SAVE_FIELD_ID_CATEGORY_OVERRIDES]);

				layoutManager:SetPreviouslyActiveLayout(layoutObject);
			end
		end
	end
end

local function ReadDataVersion2(dataTable, layoutManager, serializer)
	local layouts = dataTable[SAVE_FIELD_ID_LAYOUTS];
	if layouts then
		for classAndSpecTag, classAndSpecLayouts in pairs(layouts) do
			for layoutName, layout in pairs(classAndSpecLayouts) do
				local layoutObject = serializer:AddLayout(layoutManager, layoutName, classAndSpecTag);
				CheckWriteCooldownOrderToLayout_v1(layoutManager, layoutObject, layout[SAVE_FIELD_ID_COOLDOWN_ORDER]);
				CheckWriteCategoryOverridesToLayout_v1(layoutManager, layoutObject, layout[SAVE_FIELD_ID_CATEGORY_OVERRIDES]);
			end
		end
	end

	local activeLayoutNames = dataTable[SAVE_FIELD_ID_ACTIVE_LAYOUT_NAMES];
	if activeLayoutNames then
		for specTag, layoutName in pairs(activeLayoutNames) do
			layoutManager:SetPreviouslyActiveLayoutByName(layoutName, specTag);
		end
	end
end

local function ReadDataVersion3(dataTable, layoutManager, serializer)
	ReadDataVersion2(dataTable, layoutManager, serializer);

	local layouts = dataTable[SAVE_FIELD_ID_LAYOUTS];
	if layouts then
		for classAndSpecTag, classAndSpecLayouts in pairs(layouts) do
			for layoutName, layout in pairs(classAndSpecLayouts) do
				local layoutObject = layoutManager:GetLayoutByName(layoutName, classAndSpecTag);
				assertsafe(layoutObject ~= nil, "Unable to find layout that should have been added");
				if layoutObject then
					CheckWriteAlertsToLayout_v3(layoutManager, layoutObject, layout[SAVE_FIELD_ID_ALERT_OVERRIDES]);
				end
			end
		end
	end
end

local function ReadDataVersion4(dataTable, layoutManager, serializer)
	--[[
	For importing...the imported layoutID will likely be different from what's in the saved data
	because when we import it, we might need to make a new id, so there now needs to be a temp map
	maintained so that the saved data layout id can be mapped to the actually created layout id

	Prepopulate the lookup with a default layout mapping because that layout will never be stored.
	This is mostly to avoid some extra checks when processing previously active layouts.
	--]]
	local defaultLayoutID = layoutManager:GetDefaultLayoutID();
	local layoutIDLookup = { [defaultLayoutID] = defaultLayoutID };

	local layouts = dataTable[SAVE_FIELD_ID_LAYOUTS];
	local layoutIDToName = dataTable[SAVE_FIELD_ID_LAYOUT_ID_DATA];
	if layouts then
		for classAndSpecTag, classAndSpecLayouts in pairs(layouts) do
			for layoutID, layout in pairs(classAndSpecLayouts) do
				local layoutName = layoutIDToName[layoutID];
				local layoutObject = serializer:AddLayout(layoutManager, layoutName, classAndSpecTag, layoutID);
				local newLayoutID = CooldownManagerLayout_GetID(layoutObject);
				layoutIDLookup[layoutID] = newLayoutID;

				CheckWriteCooldownOrderToLayout_v1(layoutManager, layoutObject, layout[SAVE_FIELD_ID_COOLDOWN_ORDER]);
				CheckWriteCategoryOverridesToLayout_v1(layoutManager, layoutObject, layout[SAVE_FIELD_ID_CATEGORY_OVERRIDES]);
			end
		end
	end

	local activeLayouts = dataTable[SAVE_FIELD_ID_ACTIVE_LAYOUT_NAMES];
	if activeLayouts then
		for specTag, layoutID in pairs(activeLayouts) do
			local layout = layoutManager:GetLayout(layoutIDLookup[layoutID]);
			local isDefaultLayoutID = layoutManager:IsDefaultLayoutID(layoutIDLookup[layoutID]);
			assertsafe(isDefaultLayoutID or layout ~= nil, "Cannot update previously active layout[%s]: didn't exist", tostring(layoutIDLookup[layoutID]));
			if layout then
				local layoutSpecTag = CooldownManagerLayout_GetClassAndSpecTag(layout);
				assertsafe(layoutSpecTag == specTag, "Cannot update previously active layout[%s], specTag[%s] didn't match layoutSpec[%s]", tostring(specTag), tostring(layoutSpecTag));
				if layoutSpecTag == specTag then
					layoutManager:SetPreviouslyActiveLayout(layout);
				end
			elseif isDefaultLayoutID then
				layoutManager:SetPreviouslyActiveLayoutForSpecToDefault(specTag);
			end
		end
	end

	if layouts then
		for classAndSpecTag, classAndSpecLayouts in pairs(layouts) do
			for layoutID, layout in pairs(classAndSpecLayouts) do
				local layoutObject = layoutManager:GetLayout(layoutIDLookup[layoutID]);
				assertsafe(layoutObject ~= nil, "Unable to find layout[%s] that should have been added", tostring(layoutIDLookup[layoutID]));
				if layoutObject then
					CheckWriteAlertsToLayout_v3(layoutManager, layoutObject, layout[SAVE_FIELD_ID_ALERT_OVERRIDES]);
				end
			end
		end
	end
end

local versionedDataReaders =
{
	[1] = ReadDataVersion1,
	[2] = ReadDataVersion2,
	[3] = ReadDataVersion3,
	[4] = ReadDataVersion4,
};

local versionedEncoders =
{
	[1] = {
		Read = function(dataPayload)
			local decoded = C_EncodingUtil.DecodeBase64(dataPayload);
			assertsafe(decoded ~= nil, "Unable to decode serialized data");

			local inflated = C_EncodingUtil.DecompressString(decoded, Enum.CompressionMethod.Deflate);
			return C_EncodingUtil.DeserializeCBOR(inflated);
		end,

		Write = function(data)
			local serialized = C_EncodingUtil.SerializeCBOR(data);
			assertsafe(serialized ~= nil, "Unable to serialize data");

			local compressed = C_EncodingUtil.CompressString(serialized, Enum.CompressionMethod.Deflate);
			local encoded = C_EncodingUtil.EncodeBase64(compressed);
			assertsafe(encoded ~= nil, "Unable to encode cooldowns");

			return encoded;
		end,
	},
};

function CooldownViewerDataStoreSerializationMixin:GetCurrentSaveFormatVersion()
	return 4;
end

function CooldownViewerDataStoreSerializationMixin:GetCurrentEncodingVersion()
	return 1;
end

function CooldownViewerDataStoreSerializationMixin:ReadData()
	self:DeserializeLayouts(self:GetSerializedData());
end

function CooldownViewerDataStoreSerializationMixin:AddLayout(layoutManager, ...)
	local layoutObject = layoutManager:AddLayout(...);
	if layoutObject then
		local layoutID = CooldownManagerLayout_GetID(layoutObject);
		table.insert(GetOrCreateTableEntry(self, "newLayoutIDs"), layoutID);
	end

	return layoutObject;
end

local function IsFailCondition(isUserInput, condition, ...)
	-- NOTE: If this is user input, errors should be handled gracefully, if it's from saved data, then assert.
	if not isUserInput then
		assertsafe(condition, ...);
	end

	return not condition;
end

function CooldownViewerDataStoreSerializationMixin:DeserializeLayouts(serializedData, isUserInput)
	local layoutManager = self:GetLayoutManager();

	if IsFailCondition(isUserInput, type(serializedData) == "string", "Incorrect serialized data format") then return; end

	if #serializedData == 0 then
		return nil;
	end

	-- Format: <version string><pipe delimiter><encoded data, custom format depending on version>
	local delimiterIndex = string.find(serializedData, ENCODING_VERSION_PAYLOAD_DELIMITER, 1, true);
	if IsFailCondition(isUserInput, delimiterIndex ~= nil, "Unable to find version for serialized data") then return; end

	local versionString = string.sub(serializedData, 1, delimiterIndex - 1);
	if IsFailCondition(isUserInput, versionString ~= nil, "Unable to find version for serialized data") then return; end

	local dataVersion = tonumber(versionString);

	local dataPayload = string.sub(serializedData, delimiterIndex + 1);
	if IsFailCondition(isUserInput, dataPayload ~= nil, "Serialized data missing payload") then return; end

	local decoder = versionedEncoders[dataVersion];
	if IsFailCondition(isUserInput, decoder ~= nil, "Decoder missing for data version %s", tostring(dataVersion)) then return; end

	local deserializedTable = decoder.Read(dataPayload);
	if IsFailCondition(isUserInput, type(deserializedTable) == "table", "Serialized data didn't decode to a table") then return; end

	local settingsDataVersion = deserializedTable[SAVE_FIELD_ID_VERSION];
	if IsFailCondition(isUserInput, type(settingsDataVersion) == "number", "Deserialized table did not contain version in expected location, or there was no reader for version %s", tostring(settingsDataVersion)) then return; end

	local reader = versionedDataReaders[settingsDataVersion];
	if IsFailCondition(isUserInput, type(reader) == "function", "Reader missing for data version %s", tostring(settingsDataVersion)) then return; end

	layoutManager:LockNotifications();
	layoutManager:SetShouldCheckAddLayoutStatus(false);
	reader(deserializedTable, layoutManager, self);
	layoutManager:SetShouldCheckAddLayoutStatus(true);
	layoutManager:UnlockNotifications();

	local newLayoutIDs = self.newLayoutIDs;
	self.newLayoutIDs = nil;
	return newLayoutIDs;
end

function CooldownViewerDataStoreSerializationMixin:CreateEncodeOutput(output)
	local encodingVersion = self:GetCurrentEncodingVersion();
	local encoder = versionedEncoders[encodingVersion];
	assertsafe(encoder ~= nil, "Encoder missing for data version %s", tostring(encodingVersion));

	local encodedOutput = encoder.Write(output);
	assertsafe(type(encodedOutput) == "string", "Unable to serialize output");

	return tostring(encodingVersion)..ENCODING_VERSION_PAYLOAD_DELIMITER..encodedOutput;
end

function CooldownViewerDataStoreSerializationMixin:SerializeLayouts(singleLayoutID)
	local needsPreviouslyActiveLayouts = singleLayoutID == nil;

	local layoutManager = self:GetLayoutManager();
	local output = {};
	output[SAVE_FIELD_ID_VERSION] = self:GetCurrentSaveFormatVersion();

	local activeLayouts = {};
	output[SAVE_FIELD_ID_ACTIVE_LAYOUT_NAMES] = activeLayouts;

	if needsPreviouslyActiveLayouts then
		for specTag, layoutID in layoutManager:EnumeratePreviouslyActiveLayoutIDs() do
			activeLayouts[specTag] = layoutID;
		end
	end

	local layouts;
	local function AddClassSpecTagToContainer(layout)
		if not layouts then
			layouts = {};
		end

		local tag = CooldownManagerLayout_GetClassAndSpecTag(layout);
		if not layouts[tag] then
			layouts[tag] = {};
		end

		return layouts[tag];
	end

	local function AddCooldownOverrideToLayout(layoutContainer, ...)
		local argCount = select("#", ...);
		local lastKeyIndex = argCount - 1;

		-- First pass to validate all keys
		for key = 1, lastKeyIndex do
			local currentKey = select(key, ...);
			if currentKey == nil then
				return; -- nil is totally fine, it just means we don't need to write anything to layoutContainer.
			end

			local currentKeyType = type(currentKey);
			if currentKeyType ~= "number" then
				assertsafe(false, "AddCooldownOverrideToLayout: All keys must be numbers (found %s)", currentKeyType);
			end
		end

		for key = 1, lastKeyIndex do
			local currentKey = select(key, ...);
			layoutContainer = GetOrCreateTableEntry(layoutContainer, currentKey);
		end

		local value = select(argCount, ...);
		table.insert(layoutContainer, value);
	end

	local layoutIDToName = {};
	local function AddLayoutToContainer(layoutID, layout)
		assertsafe(CooldownManagerLayout_GetID(layout) == layoutID, "LayoutID %s doesn't match actual layoutID of %s", tostring(layoutID), tostring(CooldownManagerLayout_GetID(layout)));
		assertsafe(layoutIDToName[layoutID] == nil, "layoutID must be unique");

		layoutIDToName[layoutID] = CooldownManagerLayout_GetName(layout); -- This could be getting the default/generated name, that's ok.
		local classAndSpecContainer = AddClassSpecTagToContainer(layout);
		local outputLayoutContainer = {};

		local orderedCooldownIDs = CooldownManagerLayout_GetOrderedCooldownIDs(layout);

		if orderedCooldownIDs then
			outputLayoutContainer[SAVE_FIELD_ID_COOLDOWN_ORDER] = orderedCooldownIDs;
		end

		local layoutCooldownInfo = CooldownManagerLayout_GetCooldownInfo(layout);
		if layoutCooldownInfo then
			for cooldownID, cooldownInfo in pairs(layoutCooldownInfo) do
				AddCooldownOverrideToLayout(outputLayoutContainer, SAVE_FIELD_ID_CATEGORY_OVERRIDES, cooldownInfo.category, cooldownID);

				if cooldownInfo.alerts then
					for alertIndex, alert in ipairs(cooldownInfo.alerts) do
						AddCooldownOverrideToLayout(outputLayoutContainer, SAVE_FIELD_ID_ALERT_OVERRIDES, cooldownID, alert);
					end
				end
			end
		end

		-- Always add the layout to the container, newly created layouts still need to be saved and will not contain any customizations yet, just a name, id, and spec tag.
		classAndSpecContainer[layoutID] = outputLayoutContainer;
	end

	for layoutID, layout in layoutManager:EnumerateLayouts() do
		local addLayout = not singleLayoutID or layoutID == singleLayoutID;
		if addLayout then
			AddLayoutToContainer(layoutID, layout);
		end
	end

	if layouts then
		output[SAVE_FIELD_ID_LAYOUTS] = layouts;
		output[SAVE_FIELD_ID_LAYOUT_ID_DATA] = layoutIDToName;
	end

	return self:CreateEncodeOutput(output);
end

function CooldownViewerDataStoreSerializationMixin:WriteData()
	self:SetSerializedData(self:SerializeLayouts());
end
