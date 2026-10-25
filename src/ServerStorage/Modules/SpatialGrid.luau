--!strict

const SpatialGrid = {}
SpatialGrid.__index = SpatialGrid

type Cell = {
	Items: {any},
	Positions: {Vector3},
}

export type SpatialGrid = typeof(setmetatable({} :: {
	CellSize: number,
	Cells: {[number]: Cell},
}, SpatialGrid))

local function cellKey(x: number, z: number): number
	return x * 65536 + z
end

function SpatialGrid.new(cellSize: number): SpatialGrid
	return setmetatable({
		CellSize = cellSize,
		Cells = {},
	}, SpatialGrid)
end

function SpatialGrid.Clear(self: SpatialGrid)
	for _, cell in self.Cells do
		table.clear(cell.Items)
		table.clear(cell.Positions)
	end
end

function SpatialGrid.Insert(self: SpatialGrid, item: any, position: Vector3)
	const key = cellKey(position.X // self.CellSize, position.Z // self.CellSize)
	local cell = self.Cells[key]
	if not cell then
		cell = {Items = {}, Positions = {}}
		self.Cells[key] = cell
	end
	table.insert(cell.Items, item)
	table.insert(cell.Positions, position)
end

function SpatialGrid.Query(self: SpatialGrid, position: Vector3, radius: number): {any}
	const results = {}
	const size = self.CellSize
	const radiusSquared = radius * radius
	for x = (position.X - radius) // size, (position.X + radius) // size do
		for z = (position.Z - radius) // size, (position.Z + radius) // size do
			const cell = self.Cells[cellKey(x, z)]
			if not cell then continue end

			for index, itemPosition in cell.Positions do
				const offset = itemPosition - position
				if offset:Dot(offset) <= radiusSquared then
					table.insert(results, cell.Items[index])
				end
			end
		end
	end
	return results
end

return SpatialGrid
