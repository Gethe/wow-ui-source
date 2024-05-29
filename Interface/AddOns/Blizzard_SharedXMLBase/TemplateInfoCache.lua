local Delegate = CreateFrame("FRAME");
Delegate:SetForbidden();

TemplateInfoCacheMixin = {};

function TemplateInfoCacheMixin:Init()
	self.templateInfos = {};
end

function TemplateInfoCacheMixin:SetInfoAddedCallback(callback)
	self.infoAddedCallback = callback;
end

function TemplateInfoCacheMixin:GetTemplateInfo(frameTemplate)
	local info = self.templateInfos[frameTemplate];
	if info then
		return info;
	end

	Delegate:SetAttribute("get-template-info-cache", self);
	Delegate:SetAttribute("get-template-info-template", frameTemplate);

	local newInfo = self.templateInfos[frameTemplate];

	if self.infoAddedCallback then
		self.infoAddedCallback(newInfo);
	end

	return newInfo;
end

function TemplateInfoCacheMixin:GetTemplateInfos()
	return self.templateInfos;
end

function CreateTemplateInfoCache()
	local cache = CreateFromMixins(TemplateInfoCacheMixin);
	cache:Init();
	return cache;
end

Delegate:SetScript("OnAttributeChanged", function(self, attribute, value)
	if attribute == "get-template-info-template" then
		local cache = self:GetAttribute("get-template-info-cache");
		local frameTemplate = value;
		cache.templateInfos[frameTemplate] = C_XMLUtil.GetTemplateInfo(frameTemplate);
	end
end);