local SAVE_FIELD_ID_VERSION = 1;
local SAVE_FIELD_ID_ACTIVE_LAYOUT_NAMES = 2;
local SAVE_FIELD_ID_LAYOUTS = 3;

local SAVE_FIELD_ID_COOLDOWN_ORDER = 1;
local SAVE_FIELD_ID_CATEGORY_OVERRIDES = 2;
local SAVE_FIELD_ID_SOUND_OVERRIDES = 3;

local ENCODING_VERSION_PAYLOAD_DELIMITER = "|";

local function MakeClassAndSpecTag(class, spec)
	assertsafe(spec < 10, "MakeClassAndSpecTag can only use one digit for encoding spec");
	return class * 10 + spec;
end

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
	if self.persistenceObject then
		return self.persistenceObject:GetSerializedData();
	end

	return GetCVar("cooldownViewerLayouts");
end

function CooldownViewerDataStoreSerializationMixin:SetSerializedData(serializedData)
	if self.persistenceObject then
		self.persistenceObject:SetSerializedData(serializedData);
	else
		SetCVar("cooldownViewerLayouts", serializedData);
	end
end

function CooldownViewerDataStoreSerializationMixin:ClearSerializedData()
	if self.persistenceObject then
		self.persistenceObject:ClearSerializedData();
	else
		self:SetSerializedData("");
	end
end

function CooldownViewerDataStoreSerializationMixin:GetCurrentClassAndSpec()
	local classID = select(3, UnitClass("player"));
	local specialization = C_SpecializationInfo.GetSpecialization();

	return classID, specialization;
end

function CooldownViewerDataStoreSerializationMixin:GetCurrentClassAndSpecTag()
	local classID, specialization = self:GetCurrentClassAndSpec();

	if classID and specialization then
		return MakeClassAndSpecTag(classID, specialization);
	end

	return nil;
end

local function ValidateReaderVersion(dataTable, expectedVersion)
	assertsafe(dataTable[SAVE_FIELD_ID_VERSION] == expectedVersion, "Attempting to read incorrect data version, expected %s, was: %s", tostring(expectedVersion), tostring(dataTable[SAVE_FIELD_ID_VERSION]));
end

local function ReadDataVersion1(dataTable, layoutManager)
	ValidateReaderVersion(dataTable, 1);

	local layouts = dataTable[SAVE_FIELD_ID_LAYOUTS];
	if layouts then
		for classAndSpecTag, classAndSpecLayouts in pairs(layouts) do
			for layoutName, layout in pairs(classAndSpecLayouts) do
				local layoutObject = layoutManager:AddLayout(layoutName, classAndSpecTag);
				layoutManager:WriteCooldownOrderToLayout(layoutObject, layout[SAVE_FIELD_ID_COOLDOWN_ORDER]);

				local categoryOverrides = layout[SAVE_FIELD_ID_CATEGORY_OVERRIDES];
				if categoryOverrides then
					for cooldownCategory, cooldownIDs in pairs(categoryOverrides) do
						layoutManager:WriteCooldownCategoryToLayout(layoutObject, cooldownCategory, cooldownIDs);
					end
				end

				local soundOverrides = layout[SAVE_FIELD_ID_SOUND_OVERRIDES];
				if soundOverrides then
					-- No sounds notifications for now
				end

				layoutManager:SetPreviouslyActiveLayoutNameForSpec(classAndSpecTag, layoutName);
			end
		end
	end
end

local function ReadDataVersion2(dataTable, layoutManager)
	ValidateReaderVersion(dataTable, 2);

	local layouts = dataTable[SAVE_FIELD_ID_LAYOUTS];
	if layouts then
		for classAndSpecTag, classAndSpecLayouts in pairs(layouts) do
			for layoutName, layout in pairs(classAndSpecLayouts) do
				local layoutObject = layoutManager:AddLayout(layoutName, classAndSpecTag);
				layoutManager:WriteCooldownOrderToLayout(layoutObject, layout[SAVE_FIELD_ID_COOLDOWN_ORDER]);

				local categoryOverrides = layout[SAVE_FIELD_ID_CATEGORY_OVERRIDES];
				if categoryOverrides then
					for cooldownCategory, cooldownIDs in pairs(categoryOverrides) do
						layoutManager:WriteCooldownCategoryToLayout(layoutObject, cooldownCategory, cooldownIDs);
					end
				end

				local soundOverrides = layout[SAVE_FIELD_ID_SOUND_OVERRIDES];
				if soundOverrides then
					-- No sounds notifications for now
				end
			end
		end
	end

	local activeLayoutNames = dataTable[SAVE_FIELD_ID_ACTIVE_LAYOUT_NAMES];
	if activeLayoutNames then
		for specTag, layoutName in pairs(activeLayoutNames) do
			layoutManager:SetPreviouslyActiveLayoutNameForSpec(specTag, layoutName);
		end
	end
end

local versionedDataReaders =
{
	[1] = ReadDataVersion1,
	[2] = ReadDataVersion2,
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
	return 2;
end

function CooldownViewerDataStoreSerializationMixin:GetCurrentEncodingVersion()
	return 1;
end

function CooldownViewerDataStoreSerializationMixin:ReadData()
	local layoutManager = self:GetLayoutManager();

	local serializedData = self:GetSerializedData();
	assertsafe(type(serializedData) == "string", "Incorrect serialized data format");

	if #serializedData == 0 then
		return;
	end

	-- Format: <version string><pipe delimiter><encoded data, custom format depending on version>
	local delimiterIndex = string.find(serializedData, ENCODING_VERSION_PAYLOAD_DELIMITER, 1, true);
	assert(delimiterIndex ~= nil, "Unable to find version for serialized data")

	local versionString = string.sub(serializedData, 1, delimiterIndex - 1);
	assert(versionString ~= nil, "Unable to find version for serialized data")
	local dataVersion = tonumber(versionString);

	local dataPayload = string.sub(serializedData, delimiterIndex + 1);
	assertsafe(dataPayload ~= nil, "Serialized data missing payload");

	local decoder = versionedEncoders[dataVersion];
	assertsafe(decoder ~= nil, "Decoder missing for data version %s", tostring(dataVersion));

	local deserializedTable = decoder.Read(dataPayload);
	assertsafe(type(deserializedTable) == "table", "Serialized data didn't decode to a table");

	local settingsDataVersion = deserializedTable[SAVE_FIELD_ID_VERSION];
	assertsafe(type(settingsDataVersion) == "number", "Deserialized table did not contain version in expected location, or there was no reader for version %s", tostring(settingsDataVersion));

	local reader = versionedDataReaders[settingsDataVersion];
	assertsafe(type(reader) == "function", "Reader missing for data version %s", tostring(dataVersion));

	reader(deserializedTable, layoutManager);
end

function CooldownViewerDataStoreSerializationMixin:WriteData()
	local layoutManager = self:GetLayoutManager();
	local output = {};
	output[SAVE_FIELD_ID_VERSION] = self:GetCurrentSaveFormatVersion();

	local activeLayoutNames = {};
	output[SAVE_FIELD_ID_ACTIVE_LAYOUT_NAMES] = activeLayoutNames;
	for specTag, layoutName in layoutManager:EnumeratePreviouslyActiveLayoutNames() do
		activeLayoutNames[specTag] = layoutName;
	end

	local layouts;
	local function AddClassSpecTagToContainer(layout)
		if not layouts then
			layouts = {};
		end

		if not layouts[layout.classAndSpecTag] then
			layouts[layout.classAndSpecTag] = {};
		end

		return layouts[layout.classAndSpecTag];
	end

	local function AddCooldownOverrideToLayout(layoutContainer, containerStorageIndex, cooldownID, cooldownValue)
		if cooldownValue then
			if not layoutContainer[containerStorageIndex] then
				layoutContainer[containerStorageIndex] = {};
			end

			if not layoutContainer[containerStorageIndex][cooldownValue] then
				layoutContainer[containerStorageIndex][cooldownValue] = {};
			end

			table.insert(layoutContainer[containerStorageIndex][cooldownValue], cooldownID);
		end
	end

	local function AddLayoutToContainer(layoutName, layout)
		local classAndSpecContainer = AddClassSpecTagToContainer(layout);

		-- TODO: I don't think that layout names need to be completely unique, but maybe they should be? Leaving this here for PR thoughts.
		assertsafe(classAndSpecContainer[layoutName] == nil, "Layout names must be unique within class and spec");

		local layoutContainer = {};

		if layout.orderedCooldownIDs then
			layoutContainer[SAVE_FIELD_ID_COOLDOWN_ORDER] = layout.orderedCooldownIDs;
		end

		if layout.cooldownInfo then
			for cooldownID, cooldownInfo in pairs(layout.cooldownInfo) do
				AddCooldownOverrideToLayout(layoutContainer, SAVE_FIELD_ID_CATEGORY_OVERRIDES, cooldownID, cooldownInfo.category);
			end
		end

		if next(layoutContainer) then
			classAndSpecContainer[layoutName] = layoutContainer;
		end
	end

	for layoutName, layout in layoutManager:EnumerateLayouts() do
		AddLayoutToContainer(layoutName, layout);
	end

	if layouts then
		output[SAVE_FIELD_ID_LAYOUTS] = layouts;
	end

	local encodingVersion = self:GetCurrentEncodingVersion();
	local encoder = versionedEncoders[encodingVersion];
	assertsafe(encoder ~= nil, "Encoder missing for data version %s", tostring(encodingVersion));

	local encodedOutput = encoder.Write(output);
	assertsafe(type(encodedOutput) == "string", "Unable to serialize output");

	self:SetSerializedData(tostring(encodingVersion)..ENCODING_VERSION_PAYLOAD_DELIMITER..encodedOutput);
end
