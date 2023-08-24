local gio = require("gameio")

local gameInfo = {}

gameInfo.worldColors = {
  ["earth"] = gio.rgb("023B22"),
  ["watalu"] = gio.rgb("3A0E03"),
  ["epsillion"] = gio.rgb("02394A"),
  ["xenova"] = gio.rgb("473249"),
  ["mastered"] = gio.rgb("403304")
}

gameInfo.levelNames = {
  earth = {
    ["H"] = "Extra Lives Shack",
    [1] = "Beginner's Path",
    [2] = "Amature Shrubs",
    [3] = "Gravel Pass",
    [4] = "Deep Charcoal Woods",
    [5] = "Coin Reserve"
    },
  watalu = {
    ["H"] = "Watalu Coin Bank",
    [1] = "Granite Groves",
    [2] = "Rocky Ravine",
    [3] = "Ancient Ruins",
    [4] = "Hell's Inferno",
    [5] = "Gold Rush"
    },
  epsillion = {
    ["H"] = "Mystic Mastery Isle",
    [1] = "Starlight Soil",
    [2] = "Refined Minerals",
    [3] = "Quartz Zone",
    [4] = "The Void",
    [5] = "Diamond Cluster"
    },
  xenova = {
    ["H"] = "Anti-matter Lives",
    [1] = "Void's Crumble",
    [2] = "Purple Overgrowth",
    [3] = "Grand Purple Hall",
    [4] = "Obsidian Caverns",
    [5] = "Nova Artifact"
    }
}

gameInfo.difficultyNames = {
  ["H"] = "Shop",
  [1] = "Easy",
  [2] = "Medium",
  [3] = "Hard",
  [4] = "Extreme",
  [5] = "Special" 
}

gameInfo.difficultyColors = {
  ["H"] = gio.rgb("9fa0a9"),
  [1] = gio.rgb("03C03C"),
  [2] = gio.rgb("FFBF00"),
  [3] = gio.rgb("C46210"),
  [4] = gio.rgb("58111A"),
  [5] = gio.rgb("00B9E8") 
}

gameInfo.splashTexts = {
  "Hockney was here",
  "It's not Minecraft!",
  "Better than Music Player",
  "forgot the ==",
  "90% Bug free",
  "10/7 on IGN",
  "The Final Frontier",
  "As seen on TV!",
  "100% pure!",
  "May contain nuts!",
  "More polygons!",
  "Moderately attractive!",
  "Limited edition!",
  "It's finished!",
  "More than 500 sold!",
  "One of a kind!",
  "It's a game!",
  "Made in Canada!",
  "Singleplayer!",
  "Keyboard compatible!",
  "Closed source!",
  "Classy!",
  "Now with difficulty!",
  "12 herbs and spices!",
  "Fat free!",
  "Cloud computing!",
  "Technically good!",
  "Lua > Python",
  "une title screen!",
  "Euclidian!",
  "Now in 3D!",
  "Four times the detail!",
  "Solar2D!",
  "Thousands of colors!",
  "Macroscopic!",
  "Bring it on!",
  "Random splash!",
  "Loved by millions!",
  "Ultimate edition!",
  "Water proof!",
  "Uninflammable!",
  "Whoa, dude!",
  "Tell your friends!",
  "Haunted!",
  "Polynomial!",
  "Terrestrial!",
  "Scientific!",
  "Not as cool as Flemino!",
  "Take frequent breaks!",
  "Not linear!",
  "Larger than Earth!",
  "sqrt(-1) love math!",
  "1% sugar!",
  "150% hyperbole!",
  "Peter Griffin!",
  "48151342 lines of code!",
  "The sum of its parts!",
  "umop-apisdn!",
  "Who is here 2023?"
}

return gameInfo