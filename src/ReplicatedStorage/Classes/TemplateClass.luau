--< INFO >--

--< TYPES >--

--< SERVICES >--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--< FOLDERS >--
local Assets = ReplicatedStorage.Assets
local Packages = ReplicatedStorage.Packages

--< DEPENDENCIES >--
local Knit = require(ReplicatedStorage.Packages.Knit)

--< MAIN >--
local TemplateClass = {}
TemplateClass.__index = TemplateClass

TemplateClass.Internal = {}

function TemplateClass.New()
	local self = setmetatable({}, TemplateClass)
	
	table.insert(TemplateClass.Internal, self)
	return nil
end

function TemplateClass:Destroy()
	local index = table.find(TemplateClass.Internal, self)
	table.remove(TemplateClass.Internal, index)
	
	self = nil
end

return TemplateClass
