README

Polyglot is an user interface add-on for World of Warcraft. It provides an
approximation of characters being able to learn the languages of other races.
This document is organized from general to specific; when you feel you have
enough information about Polyglot, stop reading.

INSTALLING POLYGLOT

To install Polyglot, simply unpack the ZIP archive so that the Polyglot folder
appears in the directory where all World of Warcraft add-ons are stored. On
Windows, this directory is usually:

C:\Program Files\World of Warcraft\Interface\AddOns\

After unpacking, you should have the following folder:

C:\Program Files\World of Warcraft\Interface\AddOns\Polyglot

With the following files in that folder:

C:\Program Files\World of Warcraft\Interface\AddOns\Polyglot\LICENSE.txt
C:\Program Files\World of Warcraft\Interface\AddOns\Polyglot\Polyglot.lua
C:\Program Files\World of Warcraft\Interface\AddOns\Polyglot\Polyglot.toc
C:\Program Files\World of Warcraft\Interface\AddOns\Polyglot\README.txt

ENABLING/DISABLING POLYGLOT

Polyglot is enabled by default. If you don't want a particular character to
make use of Polyglot, click the "AddOns" button in the lower left hand corner
of the screen where your character is shown. Find "Polyglot" on the list and
check/uncheck the box as appropriate.

USING POLYGLOT

There are no commands or windows associated with Polyglot. If Polyglot is
enabled for a character, then the character will automatically make use of it.
When translations are available, they will be displayed in your chat window.

CAPABILITIES AND LIMITATIONS

Not everything spoken in another language will recieve a translation. Here are
some of the limitations:

- Cross-faction language will not be translated.
  -- Alliance do not get translations for Horde languages.
  -- Horde do not get translations for Alliance languages.

- Guild Officer chat will not be translated.

- Things spoken with Whisper, Say, or Yell will not be translated.

- Things spoken on General, Trade, etc. chats will not be translated.
  
- Some things spoken in Party, Guild, Battleground, and Raid will be
  translated.

LEARNING THE LANGUAGE

At first, any provided translations will seem garbled. This represents your
character attempting to learn the new language. As your character is exposed
to more and more of the target language, more words (and less garbled text)
will appear. Each language is independent and must be learned individually.

TRANSLATION APPEARANCE

When a translation appears in the chat window, the speaker's name will have
curly braces { } around their name instead of square braces [ ]. This
indicates that the text given is a translation:

Normal guild chat:
[Guild] [JoeBob]: Hey guys, what's up?

Translated guild chat:
[Guild] {JoeBob}: Xuq guys, qpiz'l ab?

UNDER THE HOOD (Translations)

The translations appear in your chat window because they are provided by other
players who speak the language in question. When running Polyglot you are not
only receiving translations, but you are also providing them when your
character understands the language being spoken.

The more people who are running the Polyglot add-on, the more common it will
be to recieve translations for things spoken in other languages. So, encourage
your friends to download and make use of Polyglot.

UNDER THE HOOD (Garbled Text)

The translations provided by other players are actually 100% accurate, it is
Polyglot itself that garbles the translation, according to how much of the
language your character has had a chance to hear. This is a flavor feature,
meant to make the other languages more interesting.

At the moment, "instant total fluency" is not available. If you want this
feature, you are welcome to dig around in the Lua code for the add-on and
add this for yourself. You may also e-mail the author to ask for it.

GRITTY DETAILS (Translations)

The following chat events are checked for language. If your character speaks
the language being used in the message, then they will send a translation:

CHAT_MSG_BATTLEGROUND
CHAT_MSG_BATTLEGROUND_LEADER
CHAT_MSG_GUILD
CHAT_MSG_PARTY
CHAT_MSG_RAID
CHAT_MSG_RAID_LEADER
CHAT_MSG_RAID_WARNING

The translation is sent via the SendAddonMessage() function provided by
Blizzard, and translations are recieved as CHAT_MSG_ADDON events.

This should shed some light on the limitations given earlier. You do not
recieve cross-faction language translations, because cross-faction characters
cannot communicate with you directly (this is intentional on Blizzard's part)

The SendAddonMessage() function is limited to sending a message to certain
channels; Battleground, Guild, Party, and Raid. Thus Whisper, Say, or Yell
messages are not translated, because it's not trivial to determine exactly
who heard a say or yell command. Whispers and general chat channels never
need translation.

The odd duck out is Guild Officer Chat. Although this could be translated,
the author hadn't yet written the routines to determine who in the Guild
was an officer and thus who should recieve the translations. Not limiting
translations to officers would mean anybody in the guild using Polyglot
would be able to see officer chat; quite a surprise for an unsuspecting
guild leader and her officers. The author believes that users should not
be exposed to surprises. Thus Guild Officer chat is not translated.

GRITTY DETAILS (Garbled Text)

As mentioned before, the translation provided from other clients is a
pure translation of the original message. Polyglot checks each word to
see how many times the character has been exposed to the word (yes, it
keeps a count for each and every word!).

It then "rolls the dice" to see if your character remembers the word
well enough to provide a direct translation. If the roll came out badly,
then the word is garbled. Each exposure (successful or not) adds 10%
to the chance that your character will remember the word. Once a word
reaches a 100% chance to remember, the word will always be translated
directly without garbling it.

Each language has an independent count; so seeing the word "spiders" in
Gnomish does not help for seeing the word "spiders" in Darnassian. Even
more complicated, the garbling routines are not very intelligent. Thus
"spider", "spiders", "Spiders", "SPIDERS", "SPIDERS!", "SPIDERS!!!",
"spiders.", and "spiders," are all considered to be different words.
There will probably be some enhancement along this line in the future.

The garbling process is pretty simple; a vowel is replaced by a vowel,
a consonant is replaced by a consonant. So the word "apple" could be
garbled into "ufhpo", "iccqa", or any number of other things. It is
possible (although VERY RARE) that a garbling could actually produce
a real word, "dog" for example could be garbled into "cat" and vice
versa.

Note that slang words, curse words, or offensive words may also be generated
by the garbling routines. Fortunately, the garbling is always local to your
own computer, so nobody else will see offense words accidentally created
by the garbling routine.

SECURITY CONCERN

An unmodified version of Polyglot will provide true translations. However,
the translations are provided by other players who are also using add-ons.
There is no security mechanism in place to prevent against creating false
translations. If somebody does create such a translation spoofing add-on,
then you are suggested to disable Polyglot until the fad of translation
spoofing blows over. (Or, kick spoofers from your party, guild, or raid.)

AUTHOR CONTACT

Name:  Patrick Meade
Email: meade@cs.wisc.edu
