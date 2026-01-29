local HousingPhotoSharingUI =
{
	Name = "HousingPhotoSharingUI",
	Type = "System",
	Namespace = "C_HousingPhotoSharing",
	Environment = "All",

	Functions =
	{
		{
			Name = "BeginAuthorizationFlow",
			Type = "Function",
		},
		{
			Name = "ClearAuthorization",
			Type = "Function",
		},
		{
			Name = "CompleteAuthorizationFlow",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "callbackURL", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "GetCropRatio",
			Type = "Function",

			Returns =
			{
				{ Name = "cropRatio", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetPhotoSharingAuthURL",
			Type = "Function",

			Returns =
			{
				{ Name = "authUrl", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsAuthorized",
			Type = "Function",

			Returns =
			{
				{ Name = "authorized", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetScreenshotPreviewTexture",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "textureObject", Type = "SimpleTexture", Nilable = false },
			},
		},
		{
			Name = "TakePhoto",
			Type = "Function",
		},
		{
			Name = "UploadPhotoToService",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "optionalTitle", Type = "cstring", Nilable = false, Default = "" },
				{ Name = "optionalDescription", Type = "cstring", Nilable = false, Default = "" },
			},
		},
	},

	Events =
	{
		{
			Name = "PhotoSharingAuthorizationNeeded",
			Type = "Event",
			LiteralName = "PHOTO_SHARING_AUTHORIZATION_NEEDED",
			SynchronousEvent = true,
		},
		{
			Name = "PhotoSharingAuthorizationUpdated",
			Type = "Event",
			LiteralName = "PHOTO_SHARING_AUTHORIZATION_UPDATED",
			SynchronousEvent = true,
		},
		{
			Name = "PhotoSharingPhotoUploadStatus",
			Type = "Event",
			LiteralName = "PHOTO_SHARING_PHOTO_UPLOAD_STATUS",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "uploadStatus", Type = "PhotoSharingUploadStatus", Nilable = false },
			},
		},
		{
			Name = "PhotoSharingScreenshotReady",
			Type = "Event",
			LiteralName = "PHOTO_SHARING_SCREENSHOT_READY",
			SynchronousEvent = true,
		},
		{
			Name = "PhotoSharingThirdPartyAuthorizationNeeded",
			Type = "Event",
			LiteralName = "PHOTO_SHARING_THIRD_PARTY_AUTHORIZATION_NEEDED",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "authUrl", Type = "string", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(HousingPhotoSharingUI);