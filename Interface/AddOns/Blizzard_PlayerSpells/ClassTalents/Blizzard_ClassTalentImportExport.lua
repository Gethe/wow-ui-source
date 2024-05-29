-- WoW 10.0 Class Talent Tree Import/Export 
-- File Format Specifications

-- The import/export string for Class Talent is created in two steps:
-- 1. Create a variable sized byte arry using a bit stream to represent the state of the tree
-- 2. Convert the binary data to a base64 string

-- HEADER (fixed-size)

-- 	Serialization Version, 8 bits. 
-- 	The version of the serialization method.  If the client updates the export algorithm, the version will be incremented, and loadouts exported with older serialization version will fail to import and need to be re-exported. The current version is defined by C_Traits.GetLoadoutSerializationVersion.

-- 	Specialization ID, 16 bits.  
-- 	The class specialization for this loadout.  Uses the player's currently assigned specialization.  Attempting to import a loadout for a different class specialization will result in a failure.

-- 	Tree Hash, 128 bits, optional.  
-- 	A hash of the content of the tree to compare against the current tree when importing a loadout.  For third-party sites that want to generate loadout strings, this can be ommitted and zero-filled, which will ignore the extra validation on import.  If the tree has changed and treehash is zero-filled, it will attempt to import the loadout but may result in incomplete or incorrect nodes getting selected.

-- FILE CONTENT (variable-size)

-- 	Is Node Selected (either purchased or granted), 1 bit
--		Is Node Purchased 1 bit
--			Is Partially Ranked, 1 bit
-- 				Ranks Purchased, 6 bits
-- 			Is Choice Node, 1 bit
-- 				Choice Entry Index, 2 bits

-- The content section uses single bits for boolean values for various node states (0=false, 1=true).  If the boolean is true, additional information is written to the file.

-- The order of the nodes is determined by C_Traits.GetTreeNodes API.  It returns all nodes for a class tree, including nodes from all class specializations, ordered in ascending order by the nodeID.  Only nodes from the specID defined in the header should be marked as selected for this loadout.

-- Is Node Selected, 1 bit.
-- Specifies if the node is purchased or granted in the loadout. If it is unselected, the 0 bit is the only information written for that node, and the next bit in the stream will contain the selected value for the next node in the tree. 

-- Is Node Purchased, 1 bit.
-- Specifies if the node is purchased rather than automatically granted. If the node is selected but not purchased it is assumed to be granted at rank 1.

-- Is Partially Ranked, 1 bit.
-- (Only written if isNodeSelected is true). Indicates if the node is partially ranked.  For example, if a node has 3 ranks, and the player only puts 2 ranks into that node, it is marked as partially ranked and the number of ranks is written to the stream.  If it is not partially ranked, the max number of ranks is assumed.

-- Ranks Purchased, 6 bits.
-- (Only written if IsPartiallyRanked is true). The number of ranks a player put into this node, between 1 (inclusive) and max ranks for that node (exclusive). 

-- Is Choice Node, 1 bit
-- (Only written if isNodeSelected is true). Specifies if this node is a choice node, where a player must choose one out of the available options. 

-- Choice Entry Index, 2 bits.
-- (Only written if isChoiceNode is true). The index of selected entry for the choice node. Zero-based index (first entry is index 0).

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

		local isNodeGranted = treeNode.activeRank - treeNode.ranksPurchased > 0;
		local isNodePurchased = treeNode.ranksPurchased > 0;
		local isNodeSelected = isNodeGranted or isNodePurchased;
		local isPartiallyRanked = treeNode.ranksPurchased ~= treeNode.maxRanks;
		local isChoiceNode = treeNode.type == Enum.TraitNodeType.Selection or treeNode.type == Enum.TraitNodeType.SubTreeSelection;

		exportStream:AddValue(1, isNodeSelected and 1 or 0);
		if(isNodeSelected) then
			exportStream:AddValue(1, isNodePurchased and 1 or 0);

			if isNodePurchased then
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
		local nodeSelectedValue = importStream:ExtractValue(1);
		local isNodeSelected =  nodeSelectedValue == 1;
		local isNodePurchased = false;
		local isPartiallyRanked = false;
		local partialRanksPurchased = 0;
		local isChoiceNode = false;
		local choiceNodeSelection = 0;

		if(isNodeSelected) then
			local nodePurchasedValue = importStream:ExtractValue(1);

			isNodePurchased = nodePurchasedValue == 1;
			if(isNodePurchased) then
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
		end

		local result = {};
		result.isNodeSelected = isNodeSelected;
		result.isNodeGranted = isNodeSelected and not isNodePurchased;
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
	local treeHash = C_Traits.GetTreeHash(treeInfo.ID);
	local serializationVersion = C_Traits.GetLoadoutSerializationVersion()

	self:WriteLoadoutHeader(exportStream, serializationVersion, currentSpecID, treeHash);
	self:WriteLoadoutContent(exportStream, configID, treeInfo.ID);

	return exportStream:GetExportString();
end

function ClassTalentImportExportMixin:ShowImportError(errorString)
	 StaticPopup_Show("LOADOUT_IMPORT_ERROR_DIALOG", ERROR_COLOR:WrapTextInColorCode(errorString));
end

function ClassTalentImportExportMixin:ImportLoadout(importText, loadoutName)
	if(self:IsInspecting()) then
		self:ShowImportError(LOADOUT_ERROR_IMPORT_FAILED);
		return false;
	end

	if(not loadoutName or loadoutName == "") then
		self:ShowImportError(LOADOUT_ERROR_IMPORT_FAILED);
		return false;
	end

	local importStream = ExportUtil.MakeImportDataStream(importText);

	local headerValid, serializationVersion, specID, treeHash = self:ReadLoadoutHeader(importStream);
	local currentSerializationVersion = C_Traits.GetLoadoutSerializationVersion();

	if(not headerValid) then
		self:ShowImportError(LOADOUT_ERROR_BAD_STRING);
		return false;
	end

	if(serializationVersion ~= currentSerializationVersion) then
		self:ShowImportError(LOADOUT_ERROR_SERIALIZATION_VERSION_MISMATCH);
		return false;
	end

	if(specID ~= PlayerUtil.GetCurrentSpecID()) then
		self:ShowImportError(LOADOUT_ERROR_WRONG_SPEC);
		return false;
	end

	local treeInfo = self:GetTreeInfo();
	local configID = self:GetConfigID();

	if not self:IsHashEmpty(treeHash) then
		-- allow third-party sites to generate loadout strings with an empty tree hash, which bypasses hash validation
		if not self:HashEquals(treeHash, C_Traits.GetTreeHash(treeInfo.ID)) then
			self:ShowImportError(LOADOUT_ERROR_TREE_CHANGED);
			return false;
		end
	end

	local loadoutContent = self:ReadLoadoutContent(importStream, treeInfo.ID);
	local loadoutEntryInfo = self:ConvertToImportLoadoutEntryInfo(configID, treeInfo.ID, loadoutContent);

	local newConfigHasPurchasedRanks = #loadoutEntryInfo > 0;
	local configInfo = C_Traits.GetConfigInfo(configID);
	local success, errorString = C_ClassTalents.ImportLoadout(configID, loadoutEntryInfo, loadoutName);
	if(not success) then
		self:ShowImportError(errorString or LOADOUT_ERROR_IMPORT_FAILED);
		return false;
	end

	self:OnTraitConfigCreateStarted(newConfigHasPurchasedRanks);

	return true;
end

function ClassTalentImportExportMixin:ViewLoadout(importText, level)
	local importStream = ExportUtil.MakeImportDataStream(importText);

	local headerValid, serializationVersion, specID = self:ReadLoadoutHeader(importStream);
	local currentSerializationVersion = C_Traits.GetLoadoutSerializationVersion();

	if (not headerValid) then
		self:ShowImportError(LOADOUT_ERROR_BAD_STRING);
		return false;
	end

	if (serializationVersion ~= currentSerializationVersion) then
		self:ShowImportError(LOADOUT_ERROR_SERIALIZATION_VERSION_MISMATCH);
		return false;
	end

	C_ClassTalents.InitializeViewLoadout(specID, level);

	local configID = Constants.TraitConsts.VIEW_TRAIT_CONFIG_ID;
	local treeID = C_ClassTalents.GetTraitTreeForSpec(specID);

	local loadoutContent = self:ReadLoadoutContent(importStream, treeID);
	local loadoutEntryInfo = self:ConvertToImportLoadoutEntryInfo(configID, treeID, loadoutContent);
	return C_ClassTalents.ViewLoadout(loadoutEntryInfo), specID;
end

-- Returns true if all elements in the treehash are zero
function ClassTalentImportExportMixin:IsHashEmpty(treeHash)
	for i, value in ipairs(treeHash) do
		if (value ~= 0) then
			return false;
	   end
   end

   return true;
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
function ClassTalentImportExportMixin:ConvertToImportLoadoutEntryInfo(configID, treeID, loadoutContent)
	local results = {};
	local treeNodes = C_Traits.GetTreeNodes(treeID);
	local count = 1;
	for i, treeNodeID in ipairs(treeNodes) do

		local indexInfo = loadoutContent[i];

		if (indexInfo.isNodeSelected) then
			local treeNode = C_Traits.GetNodeInfo(configID, treeNodeID);
			if (treeNode) then
				local result = {};
				result.nodeID = treeNode.ID;

				 -- For now this assumes there is only ever one granted rank. If this changes it will need to be stored in the loadout string/stream.
				result.ranksGranted = indexInfo.isNodeGranted and 1 or 0;

				if (indexInfo.isNodeSelected and not indexInfo.isNodeGranted) then
					result.ranksPurchased = indexInfo.isPartiallyRanked and indexInfo.partialRanksPurchased or treeNode.maxRanks;
				else
					result.ranksPurchased = 0;
				end

					result.selectionEntryID = nil;

					if (indexInfo.isChoiceNode and indexInfo.choiceNodeSelection) then
						result.selectionEntryID = treeNode.entryIDs[indexInfo.choiceNodeSelection];
					elseif (treeNode.activeEntry) then
						result.selectionEntryID = treeNode.activeEntry.entryID;
					end

					if (not result.selectionEntryID) then
						result.selectionEntryID = treeNode.entryIDs[1];
					end

					-- There's something wrong with this loadout string if we still don't have an entry ID.
					if (result.selectionEntryID ~= nil) then
						results[count] = result;
						count = count + 1;
					end

			end
		end

	end

	return results;
end
