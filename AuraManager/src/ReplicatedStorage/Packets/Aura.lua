--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables
local Modules = ReplicatedStorage:WaitForChild("Modules")
local ByteNet = require(Modules:WaitForChild("ByteNet"))

--// Definte Packets
return ByteNet.defineNamespace("Aura", function()
	return {
		
		--// Server => Client
		
		--// Client => Server
		Equipped =ByteNet.definePacket{
			value = ByteNet.struct{
				Name=ByteNet.string;
				Character=ByteNet.inst;
				SourceContained=ByteNet.bool;
			}
		};
		
		Unequipped = ByteNet.definePacket{
			value = ByteNet.struct{
				Name=ByteNet.string;
				Character=ByteNet.inst;
			}
		};
	}
end)