local ProfessionConstants =
{
	Tables =
	{
		{
			Name = "CraftingOrderDuration",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Short", Type = "CraftingOrderDuration", EnumValue = 0 },
				{ Name = "Medium", Type = "CraftingOrderDuration", EnumValue = 1 },
				{ Name = "Long", Type = "CraftingOrderDuration", EnumValue = 2 },
			},
		},
		{
			Name = "CraftingOrderFlags",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 1,
			MaxValue = 16,
			Fields =
			{
				{ Name = "IsRecraft", Type = "CraftingOrderFlags", EnumValue = 1 },
				{ Name = "HasNoneReagents", Type = "CraftingOrderFlags", EnumValue = 2 },
				{ Name = "HasSomeReagents", Type = "CraftingOrderFlags", EnumValue = 4 },
				{ Name = "HasAllReagents", Type = "CraftingOrderFlags", EnumValue = 8 },
				{ Name = "IsFulfillable", Type = "CraftingOrderFlags", EnumValue = 16 },
			},
		},
		{
			Name = "CraftingOrderItemType",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Reagent", Type = "CraftingOrderItemType", EnumValue = 0 },
				{ Name = "Recraft", Type = "CraftingOrderItemType", EnumValue = 1 },
				{ Name = "CraftedResult", Type = "CraftingOrderItemType", EnumValue = 2 },
				{ Name = "RemoveReagent", Type = "CraftingOrderItemType", EnumValue = 3 },
				{ Name = "NpcProvided", Type = "CraftingOrderItemType", EnumValue = 4 },
			},
		},
		{
			Name = "CraftingOrderReagentSource",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Any", Type = "CraftingOrderReagentSource", EnumValue = 0 },
				{ Name = "Customer", Type = "CraftingOrderReagentSource", EnumValue = 1 },
				{ Name = "Crafter", Type = "CraftingOrderReagentSource", EnumValue = 2 },
				{ Name = "None", Type = "CraftingOrderReagentSource", EnumValue = 3 },
			},
		},
		{
			Name = "CraftingOrderResult",
			Type = "Enumeration",
			NumValues = 47,
			MinValue = 0,
			MaxValue = 46,
			Fields =
			{
				{ Name = "Ok", Type = "CraftingOrderResult", EnumValue = 0 },
				{ Name = "Aborted", Type = "CraftingOrderResult", EnumValue = 1 },
				{ Name = "AlreadyClaimed", Type = "CraftingOrderResult", EnumValue = 2 },
				{ Name = "AlreadyCrafted", Type = "CraftingOrderResult", EnumValue = 3 },
				{ Name = "CannotBeOrdered", Type = "CraftingOrderResult", EnumValue = 4 },
				{ Name = "CannotCancel", Type = "CraftingOrderResult", EnumValue = 5 },
				{ Name = "CannotClaim", Type = "CraftingOrderResult", EnumValue = 6 },
				{ Name = "CannotClaimOwnOrder", Type = "CraftingOrderResult", EnumValue = 7 },
				{ Name = "CannotCraft", Type = "CraftingOrderResult", EnumValue = 8 },
				{ Name = "CannotCreate", Type = "CraftingOrderResult", EnumValue = 9 },
				{ Name = "CannotFulfill", Type = "CraftingOrderResult", EnumValue = 10 },
				{ Name = "CannotRecraft", Type = "CraftingOrderResult", EnumValue = 11 },
				{ Name = "CannotReject", Type = "CraftingOrderResult", EnumValue = 12 },
				{ Name = "CannotRelease", Type = "CraftingOrderResult", EnumValue = 13 },
				{ Name = "CrafterIsIgnored", Type = "CraftingOrderResult", EnumValue = 14 },
				{ Name = "DatabaseError", Type = "CraftingOrderResult", EnumValue = 15 },
				{ Name = "Expired", Type = "CraftingOrderResult", EnumValue = 16 },
				{ Name = "Locked", Type = "CraftingOrderResult", EnumValue = 17 },
				{ Name = "InvalidDuration", Type = "CraftingOrderResult", EnumValue = 18 },
				{ Name = "InvalidMinQuality", Type = "CraftingOrderResult", EnumValue = 19 },
				{ Name = "InvalidNotes", Type = "CraftingOrderResult", EnumValue = 20 },
				{ Name = "InvalidReagent", Type = "CraftingOrderResult", EnumValue = 21 },
				{ Name = "InvalidRealm", Type = "CraftingOrderResult", EnumValue = 22 },
				{ Name = "InvalidRecipe", Type = "CraftingOrderResult", EnumValue = 23 },
				{ Name = "InvalidRecraftItem", Type = "CraftingOrderResult", EnumValue = 24 },
				{ Name = "InvalidSort", Type = "CraftingOrderResult", EnumValue = 25 },
				{ Name = "InvalidTarget", Type = "CraftingOrderResult", EnumValue = 26 },
				{ Name = "InvalidType", Type = "CraftingOrderResult", EnumValue = 27 },
				{ Name = "MaxOrdersReached", Type = "CraftingOrderResult", EnumValue = 28 },
				{ Name = "MissingCraftingTable", Type = "CraftingOrderResult", EnumValue = 29 },
				{ Name = "MissingItem", Type = "CraftingOrderResult", EnumValue = 30 },
				{ Name = "MissingNpc", Type = "CraftingOrderResult", EnumValue = 31 },
				{ Name = "MissingOrder", Type = "CraftingOrderResult", EnumValue = 32 },
				{ Name = "MissingRecraftItem", Type = "CraftingOrderResult", EnumValue = 33 },
				{ Name = "NoAccountItems", Type = "CraftingOrderResult", EnumValue = 34 },
				{ Name = "NotClaimed", Type = "CraftingOrderResult", EnumValue = 35 },
				{ Name = "NotCrafted", Type = "CraftingOrderResult", EnumValue = 36 },
				{ Name = "NotInGuild", Type = "CraftingOrderResult", EnumValue = 37 },
				{ Name = "NotYetImplemented", Type = "CraftingOrderResult", EnumValue = 38 },
				{ Name = "OutOfPublicOrderCapacity", Type = "CraftingOrderResult", EnumValue = 39 },
				{ Name = "ServerIsNotAvailable", Type = "CraftingOrderResult", EnumValue = 40 },
				{ Name = "ThrottleViolation", Type = "CraftingOrderResult", EnumValue = 41 },
				{ Name = "TargetCannotCraft", Type = "CraftingOrderResult", EnumValue = 42 },
				{ Name = "TargetLocked", Type = "CraftingOrderResult", EnumValue = 43 },
				{ Name = "Timeout", Type = "CraftingOrderResult", EnumValue = 44 },
				{ Name = "TooManyItems", Type = "CraftingOrderResult", EnumValue = 45 },
				{ Name = "WrongVersion", Type = "CraftingOrderResult", EnumValue = 46 },
			},
		},
		{
			Name = "CraftingOrderState",
			Type = "Enumeration",
			NumValues = 16,
			MinValue = 0,
			MaxValue = 15,
			Fields =
			{
				{ Name = "None", Type = "CraftingOrderState", EnumValue = 0 },
				{ Name = "Creating", Type = "CraftingOrderState", EnumValue = 1 },
				{ Name = "Created", Type = "CraftingOrderState", EnumValue = 2 },
				{ Name = "Claiming", Type = "CraftingOrderState", EnumValue = 3 },
				{ Name = "Claimed", Type = "CraftingOrderState", EnumValue = 4 },
				{ Name = "Rejecting", Type = "CraftingOrderState", EnumValue = 5 },
				{ Name = "Rejected", Type = "CraftingOrderState", EnumValue = 6 },
				{ Name = "Releasing", Type = "CraftingOrderState", EnumValue = 7 },
				{ Name = "Crafting", Type = "CraftingOrderState", EnumValue = 8 },
				{ Name = "Recrafting", Type = "CraftingOrderState", EnumValue = 9 },
				{ Name = "Fulfilling", Type = "CraftingOrderState", EnumValue = 10 },
				{ Name = "Fulfilled", Type = "CraftingOrderState", EnumValue = 11 },
				{ Name = "Canceling", Type = "CraftingOrderState", EnumValue = 12 },
				{ Name = "Canceled", Type = "CraftingOrderState", EnumValue = 13 },
				{ Name = "Expiring", Type = "CraftingOrderState", EnumValue = 14 },
				{ Name = "Expired", Type = "CraftingOrderState", EnumValue = 15 },
			},
		},
		{
			Name = "CraftingOrderType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Public", Type = "CraftingOrderType", EnumValue = 0 },
				{ Name = "Guild", Type = "CraftingOrderType", EnumValue = 1 },
				{ Name = "Personal", Type = "CraftingOrderType", EnumValue = 2 },
				{ Name = "Npc", Type = "CraftingOrderType", EnumValue = 3 },
			},
		},
		{
			Name = "CraftingReagentType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Modifying", Type = "CraftingReagentType", EnumValue = 0 },
				{ Name = "Basic", Type = "CraftingReagentType", EnumValue = 1 },
				{ Name = "Finishing", Type = "CraftingReagentType", EnumValue = 2 },
				{ Name = "Automatic", Type = "CraftingReagentType", EnumValue = 3 },
			},
		},
		{
			Name = "ItemRecraftFlags",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 1,
			MaxValue = 1,
			Fields =
			{
				{ Name = "ItemRecraftFlagInvalid", Type = "ItemRecraftFlags", EnumValue = 1 },
			},
		},
		{
			Name = "NpcCraftingOrderSetFlags",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "CraftingOrderFlagAllowMultiple", Type = "NpcCraftingOrderSetFlags", EnumValue = 1 },
				{ Name = "CraftingOrderFlagAllowDuplicate", Type = "NpcCraftingOrderSetFlags", EnumValue = 2 },
			},
		},
		{
			Name = "Profession",
			Type = "Enumeration",
			NumValues = 15,
			MinValue = 0,
			MaxValue = 14,
			Fields =
			{
				{ Name = "FirstAid", Type = "Profession", EnumValue = 0 },
				{ Name = "Blacksmithing", Type = "Profession", EnumValue = 1 },
				{ Name = "Leatherworking", Type = "Profession", EnumValue = 2 },
				{ Name = "Alchemy", Type = "Profession", EnumValue = 3 },
				{ Name = "Herbalism", Type = "Profession", EnumValue = 4 },
				{ Name = "Cooking", Type = "Profession", EnumValue = 5 },
				{ Name = "Mining", Type = "Profession", EnumValue = 6 },
				{ Name = "Tailoring", Type = "Profession", EnumValue = 7 },
				{ Name = "Engineering", Type = "Profession", EnumValue = 8 },
				{ Name = "Enchanting", Type = "Profession", EnumValue = 9 },
				{ Name = "Fishing", Type = "Profession", EnumValue = 10 },
				{ Name = "Skinning", Type = "Profession", EnumValue = 11 },
				{ Name = "Jewelcrafting", Type = "Profession", EnumValue = 12 },
				{ Name = "Inscription", Type = "Profession", EnumValue = 13 },
				{ Name = "Archaeology", Type = "Profession", EnumValue = 14 },
			},
		},
		{
			Name = "ProfessionActionType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Craft", Type = "ProfessionActionType", EnumValue = 0 },
				{ Name = "Gather", Type = "ProfessionActionType", EnumValue = 1 },
			},
		},
		{
			Name = "ProfessionEffect",
			Type = "Enumeration",
			NumValues = 31,
			MinValue = 0,
			MaxValue = 30,
			Fields =
			{
				{ Name = "Skill", Type = "ProfessionEffect", EnumValue = 0 },
				{ Name = "StatInspiration", Type = "ProfessionEffect", EnumValue = 1 },
				{ Name = "StatResourcefulness", Type = "ProfessionEffect", EnumValue = 2 },
				{ Name = "StatFinesse", Type = "ProfessionEffect", EnumValue = 3 },
				{ Name = "StatDeftness", Type = "ProfessionEffect", EnumValue = 4 },
				{ Name = "StatPerception", Type = "ProfessionEffect", EnumValue = 5 },
				{ Name = "StatCraftingSpeed", Type = "ProfessionEffect", EnumValue = 6 },
				{ Name = "StatMulticraft", Type = "ProfessionEffect", EnumValue = 7 },
				{ Name = "UnlockReagentSlot", Type = "ProfessionEffect", EnumValue = 8 },
				{ Name = "ModInspiration", Type = "ProfessionEffect", EnumValue = 9 },
				{ Name = "ModResourcefulness", Type = "ProfessionEffect", EnumValue = 10 },
				{ Name = "ModFinesse", Type = "ProfessionEffect", EnumValue = 11 },
				{ Name = "ModDeftness", Type = "ProfessionEffect", EnumValue = 12 },
				{ Name = "ModPerception", Type = "ProfessionEffect", EnumValue = 13 },
				{ Name = "ModCraftingSpeed", Type = "ProfessionEffect", EnumValue = 14 },
				{ Name = "ModMulticraft", Type = "ProfessionEffect", EnumValue = 15 },
				{ Name = "ModUnused_1", Type = "ProfessionEffect", EnumValue = 16 },
				{ Name = "ModUnused_2", Type = "ProfessionEffect", EnumValue = 17 },
				{ Name = "ModCraftExtraQuantity", Type = "ProfessionEffect", EnumValue = 18 },
				{ Name = "ModGatherExtraQuantity", Type = "ProfessionEffect", EnumValue = 19 },
				{ Name = "ModCraftCritSize", Type = "ProfessionEffect", EnumValue = 20 },
				{ Name = "ModCraftReductionQuantity", Type = "ProfessionEffect", EnumValue = 21 },
				{ Name = "DecreaseDifficulty", Type = "ProfessionEffect", EnumValue = 22 },
				{ Name = "IncreaseDifficulty", Type = "ProfessionEffect", EnumValue = 23 },
				{ Name = "ModSkillGain", Type = "ProfessionEffect", EnumValue = 24 },
				{ Name = "AccumulateRanksByLabel", Type = "ProfessionEffect", EnumValue = 25 },
				{ Name = "StatIngenuity", Type = "ProfessionEffect", EnumValue = 26 },
				{ Name = "ModConcentration", Type = "ProfessionEffect", EnumValue = 27 },
				{ Name = "Tokenizer", Type = "ProfessionEffect", EnumValue = 28 },
				{ Name = "ModIngenuity", Type = "ProfessionEffect", EnumValue = 29 },
				{ Name = "ConcentrationRefund", Type = "ProfessionEffect", EnumValue = 30 },
			},
		},
		{
			Name = "ProfessionRating",
			Type = "Enumeration",
			NumValues = 9,
			MinValue = 0,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Inspiration", Type = "ProfessionRating", EnumValue = 0 },
				{ Name = "Resourcefulness", Type = "ProfessionRating", EnumValue = 1 },
				{ Name = "Finesse", Type = "ProfessionRating", EnumValue = 2 },
				{ Name = "Deftness", Type = "ProfessionRating", EnumValue = 3 },
				{ Name = "Perception", Type = "ProfessionRating", EnumValue = 4 },
				{ Name = "CraftingSpeed", Type = "ProfessionRating", EnumValue = 5 },
				{ Name = "Multicraft", Type = "ProfessionRating", EnumValue = 6 },
				{ Name = "Ingenuity", Type = "ProfessionRating", EnumValue = 7 },
				{ Name = "Unused_2", Type = "ProfessionRating", EnumValue = 8 },
			},
		},
		{
			Name = "ProfessionRatingType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Craft", Type = "ProfessionRatingType", EnumValue = 0 },
				{ Name = "Gather", Type = "ProfessionRatingType", EnumValue = 1 },
			},
		},
		{
			Name = "RcoCloseReason",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 0,
			MaxValue = 6,
			Fields =
			{
				{ Name = "RcoCloseFulfill", Type = "RcoCloseReason", EnumValue = 0 },
				{ Name = "RcoCloseExpire", Type = "RcoCloseReason", EnumValue = 1 },
				{ Name = "RcoCloseCancel", Type = "RcoCloseReason", EnumValue = 2 },
				{ Name = "RcoCloseReject", Type = "RcoCloseReason", EnumValue = 3 },
				{ Name = "RcoCloseGmCancel", Type = "RcoCloseReason", EnumValue = 4 },
				{ Name = "RcoCloseCrafterFulfill", Type = "RcoCloseReason", EnumValue = 5 },
				{ Name = "RcoCloseInvalid", Type = "RcoCloseReason", EnumValue = 6 },
			},
		},
		{
			Name = "ProfessionConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "NUM_PRIMARY_PROFESSIONS", Type = "number", Value = 2 },
				{ Name = "CLASSIC_PROFESSION_PARENT_TIER_INDEX", Type = "number", Value = 4 },
				{ Name = "RUNEFORGING_SKILL_LINE_ID", Type = "number", Value = 960 },
				{ Name = "RUNEFORGING_ROOT_CATEGORY_ID", Type = "number", Value = 210 },
				{ Name = "MAX_CRAFTING_REAGENT_SLOTS", Type = "number", Value = 12 },
				{ Name = "CRAFTING_ORDER_CLAIM_DURATION", Type = "number", Value = 0 },
				{ Name = "PUBLIC_CRAFTING_ORDER_STALE_THRESHOLD", Type = "number", Value = 0 },
				{ Name = "CRAFTING_ORDER_ITEM_RETENTION", Type = "number", Value = 30 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ProfessionConstants);