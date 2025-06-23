local Stick = {
	Name = "Stick",
	Type = "Tool",
	Model = game.ReplicatedStorage.Assets.Items.Tools.Stick,
	IdleAnimation = "",
	ActiveAnimation = "http://www.roblox.com/asset/?id=182393478",
	Sound = "rbxassetid://182393478",

	Meta = {
		Nickname = "Stick",
		Damage = 9,
		AttackRange = 1.5,
		AttackCooldown = -0.25,
		Speed = 0,
		Knockback = 2,
		
		HumanZombieWinRatio = 3/2,
		Power = 1,
	},
}

return Stick