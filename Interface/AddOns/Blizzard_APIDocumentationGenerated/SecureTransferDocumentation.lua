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
			Name = "GetHousingVCPurchaseProductID",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "productID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetMailInfo",
			Type = "Function",
			HasRestrictions = true,

			Returns =
			{
				{ Name = "mailInfo", Type = "MailInfo", Nilable = false },
			},
		},
		{
			Name = "SendMail",
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
			Name = "MailInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "target", Type = "string", Nilable = false },
				{ Name = "sendMoney", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SecureTransfer);