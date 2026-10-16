local SecureTransfer =
{
	Name = "SecureTransfer",
	Type = "System",
	Namespace = "C_SecureTransfer",
	Environment = "All",

	Functions =
	{
		{
			Name = "AcceptTrade",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "Cancel",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "CompleteHousingPurchase",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "CompleteHousingVCPurchase",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "GetHousingPurchaseCost",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "totalCost", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHousingPurchaseQuantity",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "quantity", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetHousingVCPurchaseProductID",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMailReceiveInfo",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "mailInfo", Type = "MailReceiveInfo", Nilable = false },
			},
		},
		{
			Name = "GetMailSendInfo",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "mailInfo", Type = "MailSendInfo", Nilable = false },
			},
		},
		{
			Name = "GetTradePartner",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "name", Type = "string", Nilable = true },
			},
		},
		{
			Name = "SendMail",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "ShouldShowTradeOfferWarning",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "shouldShow", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ShouldShowTradeRMTWarning",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "shouldShow", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "TakeMailMoney",
			Type = "Function",
			HasRestrictions = true,
		},
	},

	Events =
	{
		{
			Name = "SecureTransferCancel",
			Type = "Event",
			LiteralName = "SECURE_TRANSFER_CANCEL",
			SynchronousEvent = true,
		},
		{
			Name = "SecureTransferConfirmHousingPurchase",
			Type = "Event",
			LiteralName = "SECURE_TRANSFER_CONFIRM_HOUSING_PURCHASE",
			SynchronousEvent = true,
		},
		{
			Name = "SecureTransferConfirmSendMail",
			Type = "Event",
			LiteralName = "SECURE_TRANSFER_CONFIRM_SEND_MAIL",
			SynchronousEvent = true,
		},
		{
			Name = "SecureTransferConfirmTakeMailMoney",
			Type = "Event",
			LiteralName = "SECURE_TRANSFER_CONFIRM_TAKE_MAIL_MONEY",
			SynchronousEvent = true,
		},
		{
			Name = "SecureTransferConfirmTradeAccept",
			Type = "Event",
			LiteralName = "SECURE_TRANSFER_CONFIRM_TRADE_ACCEPT",
			SynchronousEvent = true,
		},
		{
			Name = "SecureTransferHousingCurrencyPurchaseConfirmation",
			Type = "Event",
			LiteralName = "SECURE_TRANSFER_HOUSING_CURRENCY_PURCHASE_CONFIRMATION",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
		{
			Name = "MailReceiveInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "sender", Type = "string", Nilable = false },
				{ Name = "money", Type = "number", Nilable = false },
			},
		},
		{
			Name = "MailSendInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "target", Type = "string", Nilable = false },
				{ Name = "sendMoney", Type = "number", Nilable = false },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(SecureTransfer);