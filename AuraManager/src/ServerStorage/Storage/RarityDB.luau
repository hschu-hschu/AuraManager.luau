export type AuraInfo = {
	HipHeight: number?;
	AudioInfo: {Name: string, Author: string}?;
	CreatorId: (number | {number})?;
	ConceptId: (number | {number})?;
}

--// Sol's RNG doesn't actually use this format
local Settings : {[string]: AuraInfo} = {
	--Example
	["Savior"] = {
		CreatorId = 419860256;
		Rarity = 3200000;

		AudioInfo = {
			Name = "Fight Fight Fight C";
			Author = "Rockshop";
		}
	};
}

return Settings :: {[string]: AuraInfo}