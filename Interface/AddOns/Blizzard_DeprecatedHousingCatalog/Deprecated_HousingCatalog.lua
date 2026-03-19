-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

--[[
	== Summary of 12.0.5 Changes ==
	
	Previously, there was just Housing Catalog Entry, which represented one "stack" of stuff in the Catalog, with a "Subtype" to denote what kind of stack it was.
	For example, for a "Sturdy Chair" there might be both an "OwnedModifiedStack" entry for a stack of dyed chairs, and a "OwnedUnmodifiedStack" entry for undyed chairs.
	This had multiple problems, primarily around the idea of "Owned" because "Owned" here really only meant "has any in storage."
	Decor that you own but have placed all instances of were technically "Unowned" which just caused a lot of confusion and fragility,
	and it wasn't clear or consistent which "totals" or "quantities" referred to all instances of the decor versus only instances of a stack, etc.

	Now, Catalog Entries are split into 2 separate concepts.

	HousingCatalogEntry is now the top-level base information about a single thing that can be in the Catalog, whether you own it or not.
	This includes static information, like name and icon, as well as top-level general info like "total num stored" which is agnostic of separated stacks.
	HousingCatalogEntryVariants is a sublevel, that represent a specific "variant" of the entry that the player does own.

	Example: Player has 2 red-dyed, 1 blue-dyed, and 2 undyed Sturdy Chairs in storage, and 1 Sturdy Chair placed in a house
	Before:
		[Sturdy Chair HousingCatalogEntryInfo (OwnedUnmodified, quantity: 2, numPlaced: 1)]
		[Sturdy Chair HousingCatalogEntryInfo (OwnedModified, dyes: red, quantity: 2, numPlaced: 1)]
		[Sturdy Chair HousingCatalogEntryInfo (OwnedModified, dyes: blue, quantity: 1, numPlaced: 1)]
	Now:
		[Sturdy Chair HousingCatalogEntryInfo (totalNumStored: 5, totalNumPlaced: 1)]
			[HousingCatalogEntryVariantInfo (dyes: none, numStored: 2)]
			[HousingCatalogEntryVariantInfo (dyes: red, numStored: 2)]
			[HousingCatalogEntryVariantInfo (dyes: blue, numStored: 1)]

	Example: Player has 6 Sturday Chairs, all of them have been placed in a house
	Before:
		[Sturdy Chair HousingCatalogEntryInfo (Unowned, quantity: 0, numPlaced: 6)]
	Now:
		[Sturdy Chair HousingCatalogEntryInfo (totalNumStored: 0, totalNumPlaced: 6)]
]]--

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	-- Old enum: Enum.HousingCatalogEntrySubtype (removed in new API)
	if not Enum.HousingCatalogEntrySubtype then
		Enum.HousingCatalogEntrySubtype = {
			Invalid = 0,
			Unowned = 1,
			OwnedModifiedStack = 2,
			OwnedUnmodifiedStack = 3,
		};
	end

	-- Helper to convert old HousingCatalogEntryID (compound) to new HousingCatalogEntryVariantID.
	-- Old: { recordID, entryType, entrySubtype, subtypeIdentifier }
	-- New: { recordID, entryType, variantIdentifier }
	local function ConvertEntryIDToVariantID(entryID)
		return {
			recordID = entryID.recordID,
			entryType = entryID.entryType,
			variantIdentifier = entryID.subtypeIdentifier or 0,
		};
	end

	-- Helper to augment a single HousingCatalogEntryVariantID with old HousingCatalogEntryID fields.
	-- Creates a super-ID containing both old and new fields.
	local function ConvertVariantIDToSuperID(variantID)
		if variantID then
			variantID.subtypeIdentifier = variantID.variantIdentifier;
			variantID.entrySubtype = Enum.HousingCatalogEntrySubtype.Unowned;
		end
		return variantID;
	end

	-- Helper to add backward-compatible fields to HousingCatalogEntryInfo results.
	-- Old fields: entryID (compound with entrySubtype/subtypeIdentifier), quantity, numPlaced, showQuantity, customizations, marketInfo
	-- New fields: recordID, entryType, totalNumStored, totalNumPlaced
	local function AddBackwardCompatEntryInfoFields(info)
		if info then
			info.entryID = {
				recordID = info.recordID,
				entryType = info.entryType,
				entrySubtype = Enum.HousingCatalogEntrySubtype.Unowned,
				subtypeIdentifier = 0,
				variantIdentifier = 0,
			};
			info.quantity = info.totalNumStored;
			info.numPlaced = info.totalNumPlaced;
			info.showQuantity = (info.remainingRedeemable + (info.totalNumStored or 0)) > 0;
			info.dyeSlots = {};
		end
		return info;
	end

	-- Helper to add backward-compatible fields to HousingCatalogCategoryInfo results.
	-- Old field: anyOwnedEntries
	-- New field: anyStoredEntries
	local function AddBackwardCompatCategoryInfoFields(info)
		if info then
			info.anyOwnedEntries = info.anyStoredEntries;
		end
		return info;
	end

	-- Helper to add backward-compatible fields to HousingCatalogSubcategoryInfo results.
	-- Old field: anyOwnedEntries
	-- New field: anyStoredEntries
	local function AddBackwardCompatSubcategoryInfoFields(info)
		if info then
			info.anyOwnedEntries = info.anyStoredEntries;
		end
		return info;
	end

	-- Helper to convert old HousingCategorySearchInfo field names.
	-- Old field: withOwnedEntriesOnly
	-- New field: withStoredEntriesOnly
	local function ConvertSearchParams(searchParams)
		if searchParams and searchParams.withOwnedEntriesOnly ~= nil and searchParams.withStoredEntriesOnly == nil then
			searchParams.withStoredEntriesOnly = searchParams.withOwnedEntriesOnly;
		end
		return searchParams;
	end

	---------------------------------------------------------------------------
	-- C_HousingCatalog Function Bridges
	---------------------------------------------------------------------------

	-- Old: C_HousingCatalog.GetCatalogEntryInfoByRecordID(entryType, recordID, tryGetOwnedInfo)
	-- New: C_HousingCatalog.GetCatalogEntryInfoByRecordID(entryType, recordID)
	local originalGetCatalogEntryInfoByRecordID = C_HousingCatalog.GetCatalogEntryInfoByRecordID;
	C_HousingCatalog.GetCatalogEntryInfoByRecordID = function(entryType, recordID, _tryGetOwnedInfo)
		local info = originalGetCatalogEntryInfoByRecordID(entryType, recordID);
		return AddBackwardCompatEntryInfoFields(info);
	end

	-- Old: C_HousingCatalog.GetCatalogEntryInfoByItem(itemInfo, tryGetOwnedInfo)
	-- New: C_HousingCatalog.GetCatalogEntryInfoByItem(itemInfo)
	local originalGetCatalogEntryInfoByItem = C_HousingCatalog.GetCatalogEntryInfoByItem;
	C_HousingCatalog.GetCatalogEntryInfoByItem = function(itemInfo, _tryGetOwnedInfo)
		local info = originalGetCatalogEntryInfoByItem(itemInfo);
		return AddBackwardCompatEntryInfoFields(info);
	end

	-- Old: C_HousingCatalog.GetCatalogEntryInfo(entryID)
	-- entryID was compound { recordID, entryType, entrySubtype, subtypeIdentifier }
	-- New entryID is simpler { recordID, entryType }; variant info is separate via GetCatalogEntryVariantInfo
	local originalGetCatalogEntryInfo = C_HousingCatalog.GetCatalogEntryInfo;
	C_HousingCatalog.GetCatalogEntryInfo = function(entryID)
		local info = originalGetCatalogEntryInfo(entryID);
		return AddBackwardCompatEntryInfoFields(info);
	end

	-- Old: C_HousingCatalog.CanDestroyEntry(entryID) where entryID had entrySubtype/subtypeIdentifier
	-- New: C_HousingCatalog.CanDestroyEntry(entryVariantID) where entryVariantID has variantIdentifier
	local originalCanDestroyEntry = C_HousingCatalog.CanDestroyEntry;
	C_HousingCatalog.CanDestroyEntry = function(entryIDOrVariantID)
		if entryIDOrVariantID.subtypeIdentifier then
			entryIDOrVariantID = ConvertEntryIDToVariantID(entryIDOrVariantID);
		end
		return originalCanDestroyEntry(entryIDOrVariantID);
	end

	-- Old: C_HousingCatalog.DestroyEntry(entryID, destroyAll) where entryID had entrySubtype/subtypeIdentifier
	-- New: C_HousingCatalog.DestroyEntry(entryVariantID, destroyAll) where entryVariantID has variantIdentifier
	local originalDestroyEntry = C_HousingCatalog.DestroyEntry;
	C_HousingCatalog.DestroyEntry = function(entryIDOrVariantID, destroyAll)
		if entryIDOrVariantID.subtypeIdentifier then
			entryIDOrVariantID = ConvertEntryIDToVariantID(entryIDOrVariantID);
		end
		return originalDestroyEntry(entryIDOrVariantID, destroyAll);
	end

	-- Old: C_HousingCatalog.GetFeaturedDecor() -> table of HousingFeaturedDecorEntry { entryID, productID, price, originalPrice, canPreview }
	-- New: C_HousingCatalog.GetFeaturedSmallProducts() -> table of HousingFeaturedSmallProductInfo { entryVariantID, productID, price, originalPrice, canPreview }
	C_HousingCatalog.GetFeaturedDecor = function()
		local results = C_HousingCatalog.GetFeaturedSmallProducts();
		for _, info in ipairs(results) do
			info.entryID = ConvertVariantIDToSuperID(info.entryVariantID);
		end
		return results;
	end

	-- Return struct field renamed: anyOwnedEntries (old) -> anyStoredEntries (new)
	local originalGetCatalogCategoryInfo = C_HousingCatalog.GetCatalogCategoryInfo;
	C_HousingCatalog.GetCatalogCategoryInfo = function(categoryID)
		local info = originalGetCatalogCategoryInfo(categoryID);
		return AddBackwardCompatCategoryInfoFields(info);
	end

	-- Return struct field renamed: anyOwnedEntries (old) -> anyStoredEntries (new)
	local originalGetCatalogSubcategoryInfo = C_HousingCatalog.GetCatalogSubcategoryInfo;
	C_HousingCatalog.GetCatalogSubcategoryInfo = function(subcategoryID)
		local info = originalGetCatalogSubcategoryInfo(subcategoryID);
		return AddBackwardCompatSubcategoryInfoFields(info);
	end

	-- Input struct field renamed: withOwnedEntriesOnly (old) -> withStoredEntriesOnly (new)
	local originalSearchCatalogCategories = C_HousingCatalog.SearchCatalogCategories;
	C_HousingCatalog.SearchCatalogCategories = function(searchParams)
		return originalSearchCatalogCategories(ConvertSearchParams(searchParams));
	end

	-- Input struct field renamed: withOwnedEntriesOnly (old) -> withStoredEntriesOnly (new)
	local originalSearchCatalogSubcategories = C_HousingCatalog.SearchCatalogSubcategories;
	C_HousingCatalog.SearchCatalogSubcategories = function(searchParams)
		return originalSearchCatalogSubcategories(ConvertSearchParams(searchParams));
	end

	---------------------------------------------------------------------------
	-- C_HousingBasicMode Function Bridges
	---------------------------------------------------------------------------

	-- Old: C_HousingBasicMode.StartPlacingNewDecor(catalogEntryID) where catalogEntryID had entrySubtype/subtypeIdentifier
	-- New: C_HousingBasicMode.StartPlacingNewDecor(catalogEntryVariantID) where catalogEntryVariantID has variantIdentifier
	local originalStartPlacingNewDecor = C_HousingBasicMode.StartPlacingNewDecor;
	C_HousingBasicMode.StartPlacingNewDecor = function(catalogEntryIDOrVariantID)
		if catalogEntryIDOrVariantID.subtypeIdentifier then
			catalogEntryIDOrVariantID = ConvertEntryIDToVariantID(catalogEntryIDOrVariantID);
		end
		return originalStartPlacingNewDecor(catalogEntryIDOrVariantID);
	end

	---------------------------------------------------------------------------
	-- HousingCatalogSearcher ScriptObject Method Bridges
	---------------------------------------------------------------------------

	-- Helper to augment new HousingCatalogEntryVariantID results with old HousingCatalogEntryID fields.
	-- Creates a super-ID containing both old and new fields.
	-- New: { recordID, entryType, variantIdentifier }
	-- Old: { recordID, entryType, entrySubtype, subtypeIdentifier }
	local function ConvertVariantIDsToEntryIDs(variantIDs)
		for _, variantID in ipairs(variantIDs) do
			ConvertVariantIDToSuperID(variantID);
		end
		return variantIDs;
	end

	-- Hook CreateCatalogSearcher to apply deprecated method aliases to the searcher metatable.
	-- Old: IsOwnedOnlyActive, SetOwnedOnly, ToggleOwnedOnly
	-- New: IsStoredOnlyActive, SetStoredOnly, ToggleStoredOnly

	-- These functions are read-only parts of the metatable so they can't have a fully compatible
	-- deprecation layer. Please update to the new APIs but for old behavior you can use
	-- OldGetAllSearchItems or OldGetCatalogSearchResults for now.
	-- Old: GetAllSearchItems/GetCatalogSearchResults return HousingCatalogEntryID
	-- New: GetAllSearchItems/GetCatalogSearchResults return HousingCatalogEntryVariantID
	local originalCreateCatalogSearcher = C_HousingCatalog.CreateCatalogSearcher;
	C_HousingCatalog.CreateCatalogSearcher = function()
		local searcher = originalCreateCatalogSearcher();
		-- Method renames: old names -> new implementations
		searcher.IsOwnedOnlyActive = searcher.IsStoredOnlyActive;
		searcher.SetOwnedOnly = searcher.SetStoredOnly;
		searcher.ToggleOwnedOnly = searcher.ToggleStoredOnly;

		-- Return type bridges: add old fields to returned variant IDs
		local originalGetAllSearchItems = searcher.GetAllSearchItems;
		searcher.OldGetAllSearchItems = function(self)
			local results = originalGetAllSearchItems(self);
			return ConvertVariantIDsToEntryIDs(results);
		end

		local originalGetCatalogSearchResults = searcher.GetCatalogSearchResults;
		searcher.OldGetCatalogSearchResults = function(self)
			local results = originalGetCatalogSearchResults(self);
			return ConvertVariantIDsToEntryIDs(results);
		end

		return searcher;
	end
end
