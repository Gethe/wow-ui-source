function ObjectCache_Create(mixin)
	return {
		objects = {},

		Get = function(self, key)
			local object = self.objects[key];
			if object then
				return object;
			end

			object = CreateFromMixins(mixin);
			object:Init(key);
			self.objects[key] = object;
			return object;
		end,
	}
end