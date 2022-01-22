local emotesList = {
	wave = {
		animationId = "rbxassetid://3344650532",
		triggerWords = {
			"hell+o+",
			"h+i+o*",
			"wa+[sz]+u+p+",
			"y+o+",
			"greetings*",
			"salutations*",
			"goo+d+%smorning+",
			"he+y+o*",
			"howdy+",
			"what'?s*%s*up+", -- %s matches a whitespace
		},
	},
	applaud = {
		animationId = "rbxassetid://5911729486",
		triggerWords = {
			"ya+y+",
			"h[ou]+r+a+y+",
			"woo+t*",
			"woo+h+oo+",
			"bravo+",
			"congratulations+",
			"congrats+",
			"gg",
			"pog+",
			"poggers+",
		},
	},
	agree = {
		animationId = "rbxassetid://4841397952",
		requiresOwnershipOf = 4849487550,
		triggerWords = {
			"ye+s*",
			"ye+a+h*",
			"y[eu]+p+",
			"o+k+",
			"o+k+a+y+",
		},
	},
	disagree = {
		animationId = "rbxassetid://4841401869",
		requiresOwnershipOf = 4849495710,
		triggerWords = {
			"no+",
			"no+pe+",
			"yi+ke+s+",
		},
	},
	shrug = {
		animationId = "rbxassetid://3334392772",
		triggerWords = {
			"not+%s+sure+",
			"idk+",
			"don't%s+know+",
			"I%s+don't%s+know+",
			"who+%s+knows+",
		},
	},
	laugh = {
		animationId = "rbxassetid://3337966527",
		requiresOwnershipOf = 4102315500,
		triggerWords = {
			"lo+l+",
			"rof+l+",
			"ha[ha]*",
			"he[he]+",
		},
	},
	sleep = {
		animationId = "rbxassetid://4686925579",
		requiresOwnershipOf = 4689362868,
		triggerWords = {
			"zzz+",
			"yawn+",
		},
	},
}

return emotesList
