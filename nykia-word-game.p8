pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
#include lib/keyboard.p8
buffer = ""

-- egrep '^[minnie]{4,}$' /usr/share/dict/words | pbcopy
levels =
  {{
      letters= "shane",
      words={
        "shane",
        "aenean",
        "ahsan",
        "anan",
        "anana",
        "ananas",
        "anes",
        "anna",
        "ansa",
        "asana",
        "ashen",
        "ashes",
        "asse",
        "assess",
        "assessee",
        "ease",
        "enaena",
        "ense",
        "esne",
        "hanna",
        "hansa",
        "hanse",
        "hasan",
        "hash",
        "henna",
        "nana",
        "nane",
        "nanes",
        "nash",
        "neese",
        "nese",
        "nesh",
        "neshness",
        "ness",
        "sahh",
        "sane",
        "saneness",
        "sans",
        "sasa",
        "sasan",
        "sash",
        "sass",
        "seah",
        "seen",
        "seesee",
        "senna",
        "sensa",
        "sense",
        "sess",
        "shah",
        "shan",
        "shanna",
        "shansa",
        "shea",
        "shee",
        "sheen",
        "snee",
        "sneesh",
      }
   }, {
      letters= "ryland",
      words={
        "ryland",
        "adad",
        "aday",
        "adda",
        "adlay",
        "adry",
        "alada",
        "alala",
        "alan",
        "aland",
        "alanyl",
        "alar",
        "alary",
        "allan",
        "allay",
        "ally",
        "allyl",
        "anal",
        "anally",
        "anan",
        "anana",
        "ananda",
        "anarya",
        "anay",
        "anda",
        "anna",
        "annal",
        "arad",
        "arar",
        "arara",
        "arna",
        "array",
        "arrayal",
        "aryl",
        "dada",
        "daddy",
        "dalar",
        "dally",
        "dand",
        "danda",
        "dandy",
        "darn",
        "darr",
        "dayal",
        "dray",
        "dryad",
        "dryly",
        "dyad",
        "lady",
        "ladyly",
        "lall",
        "land",
        "landlady",
        "lanyard",
        "lard",
        "lardy",
        "larry",
        "layland",
        "llyn",
        "lyard",
        "lyra",
        "nana",
        "nanny",
        "nard",
        "narr",
        "narra",
        "nary",
        "raad",
        "rada",
        "radar",
        "rally",
        "rana",
        "ranal",
        "rand",
        "randan",
        "randy",
        "rann",
        "ranny",
        "raya",
        "ryal",
        "rynd",
        "yalla",
        "yaray",
        "yard",
        "yardland",
        "yarl",
        "yarly",
        "yarn",
        "yarr",
        "yarran",
        "yaya",
        "yday",
      }
      },
   {
      letters= "elowyn",
      words={
        "ellowyn",
"eely",
"elle",
"enol",
"enow",
"eyen",
"eyey",
"eyne",
"lene",
"lennow",
"leno",
"llyn",
"loll",
"lolly",
"lone",
"lonely",
"loon",
"looney",
"loony",
"lowly",
"lown",
"lownly",
"lowy",
"neele",
"neon",
"newel",
"newly",
"noel",
"noll",
"nolle",
"nolo",
"none",
"nonene",
"nonly",
"nonyl",
"nonylene",
"noon",
"nowel",
"nowy",
"nylon",
"oleo",
"only",
"oolly",
"owly",
"weel",
"ween",
"weeny",
"weewow",
"well",
"welly",
"wene",
"wenny",
"wone",
"wool",
"woolen",
"woolly",
"woon",
"wyle",
"wyne",
"wynn",
"yeel",
"yell",
"yellow",
"yellowly",
"yellowy",
"yowl",
"yowley",
      }
   },
   {
     letters = "mine",
     words = {
"imine",
"immi",
"mein",
"meinie",
"mien",
"mime",
"mimine",
"mine",
"minim",
"minnie",
"mneme",
"neem",
"nine",
     }
   },
   {
     letters = "shadow",
     words = {
"adad",
"adaw",
"adda",
"awash",
"dada",
"dado",
"dash",
"dhaw",
"dhow",
"dodd",
"dodo",
"doodad",
"dosa",
"dosadh",
"doss",
"dowd",
"haddo",
"hash",
"hood",
"hoodoo",
"hoosh",
"howdah",
"howso",
"odds",
"odso",
"sadh",
"sado",
"sahh",
"sasa",
"sash",
"sass",
"sawah",
"shad",
"shadow",
"shah",
"shaw",
"shoad",
"shod",
"shoo",
"shood",
"show",
"soda",
"soho",
"sosh",
"soso",
"soss",
"swad",
"swash",
"swoosh",
"swosh",
"swow",
"wahoo",
"wash",
"wawa",
"wawah",
"whoa",
"whoo",
"whoosh",
"woad",
"wood",
"woohoo",
"woosh",
     }
   }
  }


function _init()
  keyboard:init()

  keyboard.coreader = function(key)
    buffer = ""
    while key ~= "\r" do
      if key == "\b" then
        -- backspace, overwrite space, backspace again
        -- to clear the previous character
        key=#buffer > 0 and "\b\^# \b" or ""
        buffer=sub(buffer,0,-2)
      else
        buffer..=key
      end
      -- end with \0 to not add newline
      if (keyboard.echo) print(key.."\0")
      key = yield()
      end
    return buffer
  end
  -- keyboard.echo = true

  game = cocreate(word_game(levels[3]))

end

function _update()
  coresume(game)

end

function word_game(level)
  local n = #level.letters
  local r = n * 7 -- radius
  local phase = 0
  local found = 0
  local total = #level.words
  -- local input = ""
  while true do
    cls()
    phase = -time() / 8

    print("words: "..found.."/"..total, 0,0)
    for i = 1, n do
      print("\^w\^t"..sub(level.letters, i, i), 64 + r * cos(phase + i/n), 64 + r * sin(phase + i/n))
    end
    local word = keyboard:poll()
    for dict_word in all(level.words) do
      if del(level.words, word) then
        found = found + 1
        break
      end
    end
    -- if char then
    --   -- if string.find(letters, char) then
    --     input = input..char
    --   -- else

    --   -- end
    -- end
    print(buffer, 64 - #buffer/2 * 4, 64)
    yield()
  end

end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
