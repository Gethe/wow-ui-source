local SecureTransfer =
{
	Name = "SecureTransfer",
	Type = "System",
	Namespace = "C_SecureTransfer",

	Functions =
	{
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
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(SecureTransfer);