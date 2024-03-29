
---------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
local _, tbl = ...;

if tbl then
	tbl.SecureCapsuleGet = SecureCapsuleGet;

	local function Import(name)
		tbl[name] = tbl.SecureCapsuleGet(name);
	end

	Import("IsOnGlueScreen");

	if ( tbl.IsOnGlueScreen() ) then
		tbl._G = _G;	--Allow us to explicitly access the global environment at the glue screens
	end

	setfenv(1, tbl);

	Import("C_XMLUtil");
	Import("pairs");
end
----------------

TemplateInfoCacheMixin = {};

function TemplateInfoCacheMixin:Init()
	self.templateInfos = {};
end

function TemplateInfoCacheMixin:SetInfoAddedCallback(callback)
	self.infoAddedCallback = callback;
end

function TemplateInfoCacheMixin:GetTemplateInfo(frameTemplate)
	local info = self.templateInfos[frameTemplate];
	if not info then
		info = C_XMLUtil.GetTemplateInfo(frameTemplate);
		self.templateInfos[frameTemplate] = info;
		
		if info and self.infoAddedCallback then
			self.infoAddedCallback(info);
		end
	end
	
	return info;
end

function TemplateInfoCacheMixin:GetTemplateInfos()
	return self.templateInfos;
end

function CreateTemplateInfoCache()
	local cache = CreateFromMixins(TemplateInfoCacheMixin);
	cache:Init();
	return cache;
end