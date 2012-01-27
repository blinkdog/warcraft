--[[
NeedMonitorGameDB.lua
Copyright 2010 Patrick Meade

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--

local MAX_LEVEL=85

NeedMonitor_Game_DB = {
   ["Armor Switch"] = {
      ["Death Knight"] = false,
      ["Druid"] = false,
      ["Hunter"] = true,
      ["Mage"] = false,
      ["Paladin"] = true,
      ["Priest"] = false,
      ["Rogue"] = false,
      ["Shaman"] = true,
      ["Warlock"] = false,
      ["Warrior"] = true
   },
   ["Armor Level"] = {
      ["Hunter"] = {
         ["Cloth"] = {1,MAX_LEVEL},
         ["Leather"] = {1,MAX_LEVEL},
         ["Mail"] = {40,MAX_LEVEL},
         ["Plate"] = {-1,-1}
      },
      ["Paladin"] = {
         ["Cloth"] = {1,MAX_LEVEL},
         ["Leather"] = {1,MAX_LEVEL},
         ["Mail"] = {1,MAX_LEVEL},
         ["Plate"] = {40,MAX_LEVEL}
      },
      ["Shaman"] = {
         ["Cloth"] = {1,MAX_LEVEL},
         ["Leather"] = {1,MAX_LEVEL},
         ["Mail"] = {40,MAX_LEVEL},
         ["Plate"] = {-1,-1}
      },
      ["Warrior"] = {
         ["Cloth"] = {1,MAX_LEVEL},
         ["Leather"] = {1,MAX_LEVEL},
         ["Mail"] = {1,MAX_LEVEL},
         ["Plate"] = {40,MAX_LEVEL}
      }
   },
   ["Armor"] = {
      ["Death Knight"] = {
         ["Cloth"] = true,
         ["Leather"] = true,
         ["Mail"] = true,
         ["Plate"] = true,
         ["Shields"] = false
      },
      ["Druid"] = {
         ["Cloth"] = true,
         ["Leather"] = true,
         ["Mail"] = false,
         ["Plate"] = false,
         ["Shields"] = false
      },
      ["Hunter"] = {
         ["Cloth"] = true,
         ["Leather"] = true,
         ["Mail"] = true,
         ["Plate"] = false,
         ["Shields"] = false
      },
      ["Mage"] = {
         ["Cloth"] = true,
         ["Leather"] = false,
         ["Mail"] = false,
         ["Plate"] = false,
         ["Shields"] = false
      },
      ["Paladin"] = {
         ["Cloth"] = true,
         ["Leather"] = true,
         ["Mail"] = true,
         ["Plate"] = true,
         ["Shields"] = true
      },
      ["Priest"] = {
         ["Cloth"] = true,
         ["Leather"] = false,
         ["Mail"] = false,
         ["Plate"] = false,
         ["Shields"] = false
      },
      ["Rogue"] = {
         ["Cloth"] = true,
         ["Leather"] = true,
         ["Mail"] = false,
         ["Plate"] = false,
         ["Shields"] = false
      },
      ["Shaman"] = {
         ["Cloth"] = true,
         ["Leather"] = true,
         ["Mail"] = true,
         ["Plate"] = false,
         ["Shields"] = true
      },
      ["Warlock"] = {
         ["Cloth"] = true,
         ["Leather"] = false,
         ["Mail"] = false,
         ["Plate"] = false,
         ["Shields"] = false
      },
      ["Warrior"] = {
         ["Cloth"] = true,
         ["Leather"] = true,
         ["Mail"] = true,
         ["Plate"] = true,
         ["Shields"] = true
      },
   },
   ["Weapon"] = {
      ["Death Knight"] = {
         ["Bows"] = false,
         ["Crossbows"] = false,
         ["Daggers"] = false,
         ["Guns"] = false,
         ["Fishing Poles"] = true,
         ["Fist Weapons"] = false,
         ["Miscellaneous"] = false,
         ["One-Handed Axes"] = true,
         ["One-Handed Maces"] = true,
         ["One-Handed Swords"] = true,
         ["Polearms"] = true,
         ["Staves"] = false,
         ["Thrown"] = false,
         ["Two-Handed Axes"] = true,
         ["Two-Handed Maces"] = true,
         ["Two-Handed Swords"] = true,
         ["Wands"] = false
      },
      ["Druid"] = {
         ["Bows"] = false,
         ["Crossbows"] = false,
         ["Daggers"] = true,
         ["Guns"] = false,
         ["Fishing Poles"] = true,
         ["Fist Weapons"] = true,
         ["Miscellaneous"] = false,
         ["One-Handed Axes"] = false,
         ["One-Handed Maces"] = true,
         ["One-Handed Swords"] = false,
         ["Polearms"] = true,
         ["Staves"] = true,
         ["Thrown"] = false,
         ["Two-Handed Axes"] = false,
         ["Two-Handed Maces"] = true,
         ["Two-Handed Swords"] = false,
         ["Wands"] = false
      },
      ["Hunter"] = {
         ["Bows"] = true,
         ["Crossbows"] = true,
         ["Daggers"] = true,
         ["Guns"] = true,
         ["Fishing Poles"] = true,
         ["Fist Weapons"] = true,
         ["Miscellaneous"] = false,
         ["One-Handed Axes"] = true,
         ["One-Handed Maces"] = false,
         ["One-Handed Swords"] = true,
         ["Polearms"] = true,
         ["Staves"] = true,
         ["Thrown"] = true,
         ["Two-Handed Axes"] = true,
         ["Two-Handed Maces"] = false,
         ["Two-Handed Swords"] = true,
         ["Wands"] = false
      },
      ["Mage"] = {
         ["Bows"] = false,
         ["Crossbows"] = false,
         ["Daggers"] = true,
         ["Guns"] = false,
         ["Fishing Poles"] = true,
         ["Fist Weapons"] = false,
         ["Miscellaneous"] = false,
         ["One-Handed Axes"] = false,
         ["One-Handed Maces"] = false,
         ["One-Handed Swords"] = true,
         ["Polearms"] = false,
         ["Staves"] = true,
         ["Thrown"] = false,
         ["Two-Handed Axes"] = false,
         ["Two-Handed Maces"] = false,
         ["Two-Handed Swords"] = false,
         ["Wands"] = true
      },
      ["Paladin"] = {
         ["Bows"] = false,
         ["Crossbows"] = false,
         ["Daggers"] = false,
         ["Guns"] = false,
         ["Fishing Poles"] = true,
         ["Fist Weapons"] = false,
         ["Miscellaneous"] = false,
         ["One-Handed Axes"] = true,
         ["One-Handed Maces"] = true,
         ["One-Handed Swords"] = true,
         ["Polearms"] = true,
         ["Staves"] = false,
         ["Thrown"] = false,
         ["Two-Handed Axes"] = true,
         ["Two-Handed Maces"] = true,
         ["Two-Handed Swords"] = true,
         ["Wands"] = false
      },
      ["Priest"] = {
         ["Bows"] = false,
         ["Crossbows"] = false,
         ["Daggers"] = true,
         ["Guns"] = false,
         ["Fishing Poles"] = true,
         ["Fist Weapons"] = false,
         ["Miscellaneous"] = false,
         ["One-Handed Axes"] = false,
         ["One-Handed Maces"] = true,
         ["One-Handed Swords"] = false,
         ["Polearms"] = false,
         ["Staves"] = true,
         ["Thrown"] = false,
         ["Two-Handed Axes"] = false,
         ["Two-Handed Maces"] = false,
         ["Two-Handed Swords"] = false,
         ["Wands"] = true
      },
      ["Rogue"] = {
         ["Bows"] = true,
         ["Crossbows"] = true,
         ["Daggers"] = true,
         ["Guns"] = true,
         ["Fishing Poles"] = true,
         ["Fist Weapons"] = true,
         ["Miscellaneous"] = false,
         ["One-Handed Axes"] = true,
         ["One-Handed Maces"] = true,
         ["One-Handed Swords"] = true,
         ["Polearms"] = false,
         ["Staves"] = false,
         ["Thrown"] = true,
         ["Two-Handed Axes"] = false,
         ["Two-Handed Maces"] = false,
         ["Two-Handed Swords"] = false,
         ["Wands"] = false
      },
      ["Shaman"] = {
         ["Bows"] = false,
         ["Crossbows"] = false,
         ["Daggers"] = true,
         ["Guns"] = false,
         ["Fishing Poles"] = true,
         ["Fist Weapons"] = true,
         ["Miscellaneous"] = false,
         ["One-Handed Axes"] = true,
         ["One-Handed Maces"] = true,
         ["One-Handed Swords"] = false,
         ["Polearms"] = false,
         ["Staves"] = true,
         ["Thrown"] = false,
         ["Two-Handed Axes"] = true,
         ["Two-Handed Maces"] = true,
         ["Two-Handed Swords"] = false,
         ["Wands"] = false
      },
      ["Warlock"] = {
         ["Bows"] = false,
         ["Crossbows"] = false,
         ["Daggers"] = true,
         ["Guns"] = false,
         ["Fishing Poles"] = true,
         ["Fist Weapons"] = false,
         ["Miscellaneous"] = false,
         ["One-Handed Axes"] = false,
         ["One-Handed Maces"] = false,
         ["One-Handed Swords"] = true,
         ["Polearms"] = false,
         ["Staves"] = true,
         ["Thrown"] = false,
         ["Two-Handed Axes"] = false,
         ["Two-Handed Maces"] = false,
         ["Two-Handed Swords"] = false,
         ["Wands"] = true
      },
      ["Warrior"] = {
         ["Bows"] = true,
         ["Crossbows"] = true,
         ["Daggers"] = true,
         ["Guns"] = true,
         ["Fishing Poles"] = true,
         ["Fist Weapons"] = true,
         ["Miscellaneous"] = true,
         ["One-Handed Axes"] = true,
         ["One-Handed Maces"] = true,
         ["One-Handed Swords"] = true,
         ["Polearms"] = true,
         ["Staves"] = true,
         ["Thrown"] = true,
         ["Two-Handed Axes"] = true,
         ["Two-Handed Maces"] = true,
         ["Two-Handed Swords"] = true,
         ["Wands"] = false
      }
   },
   ["Talent Spec"] = {
      ["Death Knight"] = {
      },
      ["Druid"] = {
      },
      ["Hunter"] = {
      },
      ["Mage"] = {
         ["Arcane"] = {
         },
         ["Fire"] = {
         },
         ["Frost"] = {
         }
      },
      ["Paladin"] = {
         ["Holy"] = {
         },
         ["Protection"] = {
         },
         ["Retribution"] = {
         }
      },
      ["Priest"] = {
      },
      ["Rogue"] = {
      },
      ["Shaman"] = {
      },
      ["Warlock"] = {
      },
      ["Warrior"] = {
      }
   }
}

-- end of script

ChatFrame1:AddMessage("NeedMonitor_Game_DB has been loaded")

