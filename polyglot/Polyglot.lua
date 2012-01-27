--[[
Polyglot.lua
Copyright 2009 Patrick Meade

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

Polyglot = CreateFrame("frame", nil, UIParent)

Polyglot_Languages = {
   Alliance_Common = "Common",
   Horde_Common = "Orcish",
   Alliance = {
      "Common",
      "Darnassian",
      "Draenei",
      "Dwarvish",
      "Gnomish"
   },
   Horde = {
      "Gutterspeak",
      "Orcish",
      "Taurahe",
      "Thalassian",
      "Troll"
   },
   Other = {
      "Demonic",   -- language of demons
      "Draconic",  -- language of dragons
      "Kalimag",   -- language of elementals
      "Titan"      -- language of giants
   }
}

Polyglot_Channel_Colors = {
   CHAT_MSG_BATTLEGROUND = "|cFFFF7F00",
   CHAT_MSG_BATTLEGROUND_LEADER = "|cFFFFDBB7",
   CHAT_MSG_GUILD = "|cFF40FF40",
   CHAT_MSG_OFFICER = "|cFF40C040",
   CHAT_MSG_PARTY = "|cFFAAAAFF",
   CHAT_MSG_RAID = "|cFFFF7F00",
   CHAT_MSG_RAID_LEADER = "|cFFFF4809",
   CHAT_MSG_RAID_WARNING = "|cFFFF4800"
}

Polyglot_Channel_Tags = {
   CHAT_MSG_BATTLEGROUND = "[Battleground]",
   CHAT_MSG_BATTLEGROUND_LEADER = "[Battleground Leader]",
   CHAT_MSG_GUILD = "[Guild]",
   CHAT_MSG_OFFICER = "[Officer]",
   CHAT_MSG_PARTY = "[Party]",
   CHAT_MSG_RAID = "[Raid]",
   CHAT_MSG_RAID_LEADER = "[Raid Leader]",
   CHAT_MSG_RAID_WARNING = "[Raid Warning]"
}

Polyglot_Translation_Channel = {
   CHAT_MSG_BATTLEGROUND = "BATTLEGROUND",
   CHAT_MSG_BATTLEGROUND_LEADER = "BATTLEGROUND",
   CHAT_MSG_GUILD = "GUILD",
   CHAT_MSG_OFFICER = "GUILD",
   CHAT_MSG_PARTY = "PARTY",
   CHAT_MSG_RAID = "RAID",
   CHAT_MSG_RAID_LEADER = "RAID",
   CHAT_MSG_RAID_WARNING = "RAID"
}

function Polyglot:initialize()
   -- initalize the last message to nothing
   self.lastMessage = ""
   -- determine some information about the player
   local ignore
   self.faction, ignore = UnitFactionGroup("player")
   self.numLanguages = GetNumLanguages()
   self.languages = {}
   for i=1, self.numLanguages do
      table.insert(self.languages, GetLanguageByIndex(i))
   end
   self.race, ignore = UnitRace("player")
   -- build the languages of fluency for this player
   local factionCommon
   if self.faction == "Alliance" then
      factionCommon = Polyglot_Languages.Alliance_Common
   else
      factionCommon = Polyglot_Languages.Horde_Common
   end
   self.languageFluent = {}
   for i=1, #self.languages do
      if self.languages[i] ~= factionCommon then
         table.insert(self.languageFluent, self.languages[i])
      end
   end
   -- build the languages of interest for this player
   local factionLanguages
   if self.faction == "Alliance" then
      factionLanguages = Polyglot_Languages.Alliance
   else
      factionLanguages = Polyglot_Languages.Horde
   end
   self.languageInterest = {}
   for i=1, #factionLanguages do
      table.insert(self.languageInterest, factionLanguages[i])
      for j=1, #self.languages do
         if factionLanguages[i] == self.languages[j] then
            table.remove(self.languageInterest)
         end
      end
   end
   for i=1, #Polyglot_Languages.Other do
      table.insert(self.languageInterest, Polyglot_Languages.Other[i])
   end
end

function Polyglot:onEvent(event, ...)
   -- on load, initialize the add-on
   if event == "PLAYER_ENTERING_WORLD" then
      Polyglot:initialize()
   end
   -- on incoming messages, handle them
   local prefix, message, sender, language, channel
   if event == "CHAT_MSG_ADDON" then
      prefix, message, channel, sender = ...
   end
   if ((event ~= "PLAYER_ENTERING_WORLD") and (event ~= "CHAT_MSG_ADDON")) then
      message, sender, language, channel = ...
   end
   -- cook raw messages
   if prefix == nil then
      prefix = ""
   end
   if message == nil then
      message = ""
   end
   if sender == nil then
      sender = ""
   end
   if language == nil then
      language = ""
   end
   if channel == nil then
      channel = ""
   end
   -- if a chat message came in, may need to translate it
   if language ~= "" then
      self:sendTranslation(event, message, sender, language, channel)
   end
   -- if an addon message came in, may need to show the translation
   if prefix == "POLYGLOT" then
      self:recieveTranslation(event, prefix, message, channel, sender)
   end
end

function Polyglot:sendTranslation(event, message, sender, language, channel)
   local sendIt = false
   for i=1, #self.languageFluent do
      if language == self.languageFluent[i] then
         sendIt = true
      end
   end
   if sendIt then
      local color = Polyglot_Channel_Colors[event]
      local tag = Polyglot_Channel_Tags[event]
      local translate = Polyglot_Translation_Channel[event]
      SendAddonMessage("POLYGLOT", language..color..tag.." {"..sender.."}: \a"..message, translate)
   end
end

function Polyglot:recieveTranslation(event, prefix, message, channel, sender)
   -- parse the message into coherent parts
   local startPos, endPos, language, restOfString = string.find(message,"([^|]*)")
   local startPos, endPos, displayMessage, restOfString = string.find(message,"(|.*)$")
   -- cook raw messages
   if language == nil then
      language = ""
   end
   if displayMessage == nil then
      displayMessage = ""
   end
   -- check to see if the translation is desired
   local showIt = false
   for i=1, #self.languageInterest do
      if self.languageInterest[i] == language then
         showIt = true
      end
   end
   -- DEBUG: For testing
   --showIt = true
   -- if a translation is desired, then show it
   if showIt then
      if self.lastMessage ~= message then
         self.lastMessage = message
         self:showTranslation(language, displayMessage)
      end
   end
end

function Polyglot:showTranslation(language, displayMessage)
   local msgStart, msgWords = strsplit("\a", displayMessage)
   local words = { strsplit(" ", msgWords) }
   local finalMessage = ""..msgStart
   for i=1, #words do
      if words[i] ~= "" then
         finalMessage = finalMessage..self:mungeWord(language, words[i]).." "
      end
   end
   ChatFrame1:AddMessage(finalMessage)
end

function Polyglot:mungeWord(language, word)
   -- if necessary, create an empty dictionary
   if Polyglot_Dictionary == nil then
      Polyglot_Dictionary = {}
   end
   -- if necessary, create an empty language
   if Polyglot_Dictionary[language] == nil then
      Polyglot_Dictionary[language] = {}
   end
   -- if necessary, create a new word
   if Polyglot_Dictionary[language][word] == nil then
      Polyglot_Dictionary[language][word] = 0
   end
   -- load up the word count
   local wordCount = Polyglot_Dictionary[language][word]
   -- save back the new word count
   Polyglot_Dictionary[language][word] = math.min((wordCount + 1), 11)
   -- roll the dice to see if the word will be munged
   local mungeRoll = math.random(1,10)
   -- if we roll low enough, return the real word
   if mungeRoll < wordCount then
      return word
   end
   -- otherwise, we need to munge it
   return self:mungeIt(word)
end

function Polyglot:mungeIt(realWord)
   local LOWER_VOWEL = "aeiou"
   local UPPER_VOWEL = "AEIOU"
   local LOWER_CONST = "bcdfghjklmnpqrstvwxyz"
   local UPPER_CONST = "BCDFGHJKLMNPQRSTVWXYZ"
   
   local mungedWord = ""
   for i=1, string.len(realWord) do
      local letter = string.sub(realWord, i, i)
      local subFrom = nil
      for j=1, string.len(LOWER_VOWEL) do
         if letter == string.sub(LOWER_VOWEL, j, j) then
            subFrom = LOWER_VOWEL
         end
      end
      for j=1, string.len(UPPER_VOWEL) do
         if letter == string.sub(UPPER_VOWEL, j, j) then
            subFrom = UPPER_VOWEL
         end
      end
      for j=1, string.len(LOWER_CONST) do
         if letter == string.sub(LOWER_CONST, j, j) then
            subFrom = LOWER_CONST
         end
      end
      for j=1, string.len(UPPER_CONST) do
         if letter == string.sub(UPPER_CONST, j, j) then
            subFrom = UPPER_CONST
         end
      end
      -- did it belong to any of those?
      if subFrom ~= nil then
         local subIndex = math.random(1, string.len(subFrom))
         mungedWord = mungedWord..string.sub(subFrom, subIndex, subIndex)
      else
         mungedWord = mungedWord..letter
      end
   end
   
   return mungedWord
end

-- DEBUG: For testing
--[[
function Polyglot:printSelfInfo()
   ChatFrame1:AddMessage("I am a " .. self.race .. " (" .. self.faction .. ") and I speak " .. self.numLanguages .. " languages.")
   for i=1, #self.languages do
      ChatFrame1:AddMessage("Language " .. i .. ": " .. self.languages[i])
   end
   ChatFrame1:AddMessage("I will translate the following languages:")
   for i=1, #self.languageFluent do
      ChatFrame1:AddMessage("Language " .. i .. ": " .. self.languageFluent[i])
   end
   ChatFrame1:AddMessage("I am interested in translations of the following languages.")
   for i=1, #self.languageInterest do
      ChatFrame1:AddMessage("Language " .. i .. ": " .. self.languageInterest[i])
   end
end

function Polyglot:printDictionary()
   ChatFrame1:AddMessage("Polyglot Dictionary")
   for index,value in pairs(Polyglot_Dictionary) do
      ChatFrame1:AddMessage("Language "..index..":")
      for word,count in pairs(Polyglot_Dictionary[index]) do
         ChatFrame1:AddMessage(""..word..": "..count)
      end
   end
end
]]--

Polyglot:SetScript("OnEvent", Polyglot.onEvent)
Polyglot:RegisterEvent("PLAYER_ENTERING_WORLD")
Polyglot:RegisterEvent("CHAT_MSG_ADDON")
Polyglot:RegisterEvent("CHAT_MSG_BATTLEGROUND")
Polyglot:RegisterEvent("CHAT_MSG_BATTLEGROUND_LEADER")
Polyglot:RegisterEvent("CHAT_MSG_GUILD")
--Polyglot:RegisterEvent("CHAT_MSG_OFFICER") -- Not ready yet; sends to everybody in guild
Polyglot:RegisterEvent("CHAT_MSG_PARTY")
Polyglot:RegisterEvent("CHAT_MSG_RAID")
Polyglot:RegisterEvent("CHAT_MSG_RAID_LEADER")
Polyglot:RegisterEvent("CHAT_MSG_RAID_WARNING")

-- DEBUG: For testing
--[[
SLASH_POLYGLOT1 = "/polyglot"

SlashCmdList["POLYGLOT"] = function(msg)
   Polyglot:printSelfInfo()
end

SLASH_DICTIONARY1 = "/dictionary"

SlashCmdList["DICTIONARY"] = function(msg)
   Polyglot:printDictionary()
end

Polyglot:initialize()
ChatFrame1:AddMessage("Polyglot complete.")
]]--

-- End of file
