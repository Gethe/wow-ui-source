local LOADOUT_SERIALIZATION_VERSION = 1;

ClassTalentImportExportMixin = {};

ClassTalentImportExportMixin.bitWidthHeaderVersion = 8;
ClassTalentImportExportMixin.bitWidthSpecID = 16;
ClassTalentImportExportMixin.bitWidthRanksPurchased = 6;

StaticPopupDialogs["LOADOUT_IMPORT_ERROR_DIALOG"] = {
	text = "%s",
	button1 = OKAY,
	button2 = nil,
	timeout = 0,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
	whileDead = 1,
	hideOnEscape = 1,
};


function ClassTalentImportExportMixin:WriteLoadoutContent(exportStream, configID, treeID)
	local treeNodes = C_Traits.GetTreeNodes(treeID);
	for i, treeNodeID in ipairs(treeNodes) do
		local treeNode = C_Traits.GetNodeInfo(configID, treeNodeID);

		local isNodeSelected = treeNode.ranksPurchased > 0;
		local isPartiallyRanked = treeNode.ranksPurchased ~= treeNode.maxRanks;
		local isChoiceNode = treeNode.type == Enum.TraitNodeType.Selection;

		exportStream:AddValue(1, isNodeSelected and 1 or 0);
		if(isNodeSelected) then
			exportStream:AddValue(1, isPartiallyRanked and 1 or 0);
			if(isPartiallyRanked) then
				exportStream:AddValue(self.bitWidthRanksPurchased, treeNode.ranksPurchased);
			end

			exportStream:AddValue(1, isChoiceNode and 1 or 0);
			if(isChoiceNode) then
				local entryIndex = self:GetActiveEntryIndex(treeNode);
				if(entryIndex <= 0 or entryIndex > 4) then
					error("Error exporting tree node " .. treeNode.ID .. ". The active choice node entry index (" .. entryIndex .. ") is out of bounds. ");
				end
				
				-- store entry index as zero-index
				exportStream:AddValue(2, entryIndex - 1);
			end
		end
	end
end

function ClassTalentImportExportMixin:GetActiveEntryIndex(treeNode)
	for i, entryID in ipairs(treeNode.entryIDs) do
		if(entryID == treeNode.activeEntry.entryID) then
			return i;
		end
	end

	return 0;
end

function ClassTalentImportExportMixin:ReadLoadoutContent(importStream, treeID)
	local results = {};

	local treeNodes = C_Traits.GetTreeNodes(treeID);
	for i, _ in ipairs(treeNodes) do
		local nodeSelectedValue = importStream:ExtractValue(1)
		local isNodeSelected =  nodeSelectedValue == 1;
		local isPartiallyRanked = false;
		local partialRanksPurchased = 0;
		local isChoiceNode = false;
		local choiceNodeSelection = 0;

		if(isNodeSelected) then
			local isPartiallyRankedValue = importStream:ExtractValue(1);
			isPartiallyRanked = isPartiallyRankedValue == 1;
			if(isPartiallyRanked) then
				partialRanksPurchased = importStream:ExtractValue(self.bitWidthRanksPurchased);
			end
			local isChoiceNodeValue = importStream:ExtractValue(1);
			isChoiceNode = isChoiceNodeValue == 1;
			if(isChoiceNode) then
				choiceNodeSelection = importStream:ExtractValue(2);
			end
		end

		local result = {};
		result.isNodeSelected = isNodeSelected;
		result.isPartiallyRanked = isPartiallyRanked;
		result.partialRanksPurchased = partialRanksPurchased;
		result.isChoiceNode = isChoiceNode;
		-- entry index is stored as zero-index, so convert back to lua index
		result.choiceNodeSelection = choiceNodeSelection + 1;
		results[i] = result;

	end

	return results;
end


function ClassTalentImportExportMixin:GetLoadoutExportString()
	local exportStream = ExportUtil.MakeExportDataStream();
	local configID = self:GetConfigID();
	local currentSpecID = PlayerUtil.GetCurrentSpecID();
	local treeInfo = self:GetTreeInfo();
	local treeHash = C_Traits.GetTreeHash(configID, treeInfo.ID);


	self:WriteLoadoutHeader(exportStream, LOADOUT_SERIALIZATION_VERSION, currentSpecID, treeHash);
	self:WriteLoadoutContent(exportStream, configID, treeInfo.ID);

	return exportStream:GetExportString();
end

function ClassTalentImportExportMixin:ShowImportError(errorString)
	 StaticPopup_Show("LOADOUT_IMPORT_ERROR_DIALOG", errorString);
end

function ClassTalentImportExportMixin:ImportLoadout(importText)

	local importStream = ExportUtil.MakeImportDataStream(importText);

	local headerValid, serializationVersion, specID, treeHash = self:ReadLoadoutHeader(importStream);

	if(not headerValid) then
		self:ShowImportError(LOADOUT_ERROR_BAD_STRING);
		return;
	end

	if(serializationVersion ~= LOADOUT_SERIALIZATION_VERSION) then
		self:ShowImportError(LOADOUT_ERROR_SERIALIZATION_VERSION_MISMATCH);
		return;
	end

	if(specID ~= PlayerUtil.GetCurrentSpecID()) then
		self:ShowImportError(LOADOUT_ERROR_WRONG_SPEC);
		return;
	end

	local treeInfo = self:GetTreeInfo();
	local configID = self:GetConfigID();

	if not self:HashEquals(treeHash, C_Traits.GetTreeHash(configID, treeInfo.ID)) then
		self:ShowImportError(LOADOUT_ERROR_TREE_CHANGED);
		return;
	end


	local loadoutContent = self:ReadLoadoutContent(importStream, treeInfo.ID);
	local loadoutEntryInfo = self:ConvertToImportLoadoutEntryInfo(treeInfo.ID, loadoutContent);

	local configInfo = C_Traits.GetConfigInfo(configID);
	local success = C_ClassTalents.ImportLoadout(configID, loadoutEntryInfo);
	if(not success) then
		self:ShowImportError(LOADOUT_ERROR_IMPORT_FAILED);
	end
end

function ClassTalentImportExportMixin:HashEquals(a,b)
	if (table.getn(a) ~= table.getn(b))then
		return false;
	end

	for i, _ in ipairs(a) do
	 	if (a[i] ~= b[i]) then
	 		return false;
		end
	end

	return true;
end

function ClassTalentImportExportMixin:WriteLoadoutHeader(exportStream, serializationVersion, specID, treeHash)
	exportStream:AddValue(self.bitWidthHeaderVersion, serializationVersion);
	exportStream:AddValue(self.bitWidthSpecID, specID);
	-- treeHash is a 128bit hash, passed as an array of 16, 8-bit values
	for i, hashVal in ipairs(treeHash) do
		exportStream:AddValue(8, hashVal);
	end
end

function ClassTalentImportExportMixin:ReadLoadoutHeader(importStream)
	local headerBitWidth = self.bitWidthHeaderVersion + self.bitWidthSpecID + 128;
	local importStreamTotalBits = importStream:GetNumberOfBits();
	if( importStreamTotalBits < headerBitWidth) then
		return false, 0, 0, 0;
	end
	local serializationVersion = importStream:ExtractValue(self.bitWidthHeaderVersion);
	local specID = importStream:ExtractValue(self.bitWidthSpecID);
	-- treeHash is a 128bit hash, passed as an array of 16, 8-bit values
	local treeHash = {};
	for i=1,16,1 do
		treeHash[i] = importStream:ExtractValue(8);
	end
	return true, serializationVersion, specID, treeHash;
end

-- converts from compact bit-packing format to LoadoutEntryInfo format to pass to ImportLoadout API
function ClassTalentImportExportMixin:ConvertToImportLoadoutEntryInfo(treeID, loadoutContent)
	local results = {};
	local treeNodes = C_Traits.GetTreeNodes(treeID);
	local configID = self:GetConfigID();
	local count = 1;
	for i, treeNodeID in ipairs(treeNodes) do

		local indexInfo = loadoutContent[i];

		if (indexInfo.isNodeSelected) then
			local treeNode = C_Traits.GetNodeInfo(configID, treeNodeID);
			local result = {};
			result.nodeID = treeNode.ID;
			result.ranksPurchased = indexInfo.isPartiallyRanked and indexInfo.partialRanksPurchased or treeNode.maxRanks;
			result.selectionEntryID = indexInfo.isChoiceNode and treeNode.entryIDs[indexInfo.choiceNodeSelection] or treeNode.activeEntry.entryID;
			results[count] = result;
			count = count + 1;
		end

	end

	return results;
end