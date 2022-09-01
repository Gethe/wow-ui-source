
-- Utility for compressing and uncompressing data into strings for export and import.

ExportUtil = {};

local BitsPerChar = 6;

local function MakeBase64ConversionTable()
	local base64ConversionTable = {};
	base64ConversionTable[0] = 'A';
	for num = 1, 25 do
		table.insert(base64ConversionTable, string.char(65 + num));
	end

	for num = 0, 25 do
		table.insert(base64ConversionTable, string.char(97 + num));
	end

	for num = 0, 9 do
		table.insert(base64ConversionTable, tostring(num));
	end

	table.insert(base64ConversionTable, '+');
	table.insert(base64ConversionTable, '/');
	return base64ConversionTable;
end

local NumberToBase64CharConversionTable = MakeBase64ConversionTable();
local Base64CharToNumberConversionTable = tInvert(MakeBase64ConversionTable());

function ExportUtil.ConvertToBase64(dataEntries)
	local exportString = "";
	local currentValue = 0;
	local currentReservedBits = 0;
	local totalBits = 0;
	for i, dataEntry in ipairs(dataEntries) do
		local remainingValue = dataEntry.value;
		local remainingRequiredBits = dataEntry.bitWidth;
		-- TODO: bit.lshift doesnt work with > 32 bits.  Maybe use maxValue = 2^X instead?
		local maxValue = bit.lshift(1, remainingRequiredBits);
		if remainingValue >= maxValue then
			error(("Data entry has higher value than storable in bitWidth. (%d in %d bits)"):format(remainingValue, remainingRequiredBits));
			return "";
		end

		totalBits = totalBits + remainingRequiredBits;
		while remainingRequiredBits > 0 do
			local spaceInCurrentValue = (BitsPerChar - currentReservedBits);
			local maxStorableValue = bit.lshift(1, spaceInCurrentValue);
			local remainder = remainingValue % maxStorableValue;
			remainingValue = bit.rshift(remainingValue, spaceInCurrentValue);
			currentValue = currentValue + bit.lshift(remainder, currentReservedBits);

			if spaceInCurrentValue > remainingRequiredBits then
				currentReservedBits = (currentReservedBits + remainingRequiredBits) % BitsPerChar;
				remainingRequiredBits = 0;
			else
				exportString = exportString..NumberToBase64CharConversionTable[currentValue];
				currentValue = 0;
				currentReservedBits = 0;
				remainingRequiredBits = remainingRequiredBits - spaceInCurrentValue;
			end
		end
	end

	if currentReservedBits > 0 then
		exportString = exportString..NumberToBase64CharConversionTable[currentValue];
	end

	return exportString;
end

function ExportUtil.ConvertFromBase64(exportString)
	local dataValues = {};
	for i = 1, #exportString do
		table.insert(dataValues, Base64CharToNumberConversionTable[string.sub(exportString, i, i)]);
	end

	return dataValues;
end

function ExportUtil.MakeExportDataStream()
	return CreateAndInitFromMixin(ExportDataStreamMixin);
end

function ExportUtil.MakeImportDataStream(exportString)
	return CreateAndInitFromMixin(ImportDataStreamMixin, exportString);
end


ExportDataStreamMixin = {};

function ExportDataStreamMixin:Init()
	self.dataEntries = {};
end

function ExportDataStreamMixin:AddValue(bitWidth, value)
	table.insert(self.dataEntries, { bitWidth = bitWidth, value = value, });
end

function ExportDataStreamMixin:GetExportString()
	return ExportUtil.ConvertToBase64(self.dataEntries);
end

ImportDataStreamMixin = {};

function ImportDataStreamMixin:Init(exportString)
	self.dataValues = ExportUtil.ConvertFromBase64(exportString);
	self.currentIndex = 1;
	self.currentExtractedBits = 0;
	self.currentRemainingValue = self.dataValues[1];
end

function ImportDataStreamMixin:ExtractValue(bitWidth)
	if self.currentIndex > #self.dataValues then
		return nil;
	end

	local value = 0;
	local bitsNeeded = bitWidth;
	local extractedBits = 0;
	while bitsNeeded > 0 do
		local remainingBits = BitsPerChar - self.currentExtractedBits;
		local bitsToExtract = math.min(remainingBits, bitsNeeded);
		self.currentExtractedBits = self.currentExtractedBits + bitsToExtract;
		local maxStorableValue = bit.lshift(1, bitsToExtract);
		local remainder = self.currentRemainingValue % maxStorableValue;
		self.currentRemainingValue = bit.rshift(self.currentRemainingValue, bitsToExtract);
		value = value + bit.lshift(remainder, extractedBits);
		extractedBits = extractedBits + bitsToExtract;
		bitsNeeded = bitsNeeded - bitsToExtract;

		if bitsToExtract < remainingBits then
			break;
		elseif bitsToExtract >= remainingBits then
			self.currentIndex = self.currentIndex + 1;
			self.currentExtractedBits = 0;
			self.currentRemainingValue = self.dataValues[self.currentIndex];
		end
	end

	return value;
end

function ImportDataStreamMixin:GetNumberOfBits()
	return BitsPerChar * getn(self.dataValues);
end

