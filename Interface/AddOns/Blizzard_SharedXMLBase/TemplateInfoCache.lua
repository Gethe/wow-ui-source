
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