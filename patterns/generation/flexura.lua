-- output error message for an invalid field
function invalidField(field)
   error('Invalid field "'..field..'" in line '..linecount)
end

-- output error message for an invalid line
function invalidLine()
   error('Input line '..linecount..' is invalid: "'..wholeLine..'"')
end

function utf8substring(s,i,j)
   if j then
      if j == -1 then
         return string.sub(s,utf8.offset(s,i))
      else
         return string.sub(s,utf8.offset(s,i),utf8.offset(s,j+1)-1)
      end
   else
      return string.sub(s,utf8.offset(s,i))
   end
end

function createSet(list)
   local set = {}
   for _,l in ipairs(list) do
      set[l] = true
   end
   return set
end

-- list of all generated forms
outputlist = {}

-- digraphs with macrons are not needed, as diphthongs are always long
vowels = createSet{"A","a","Ā","ā","E","e","Ē","ē","I","i","Ī","ī","O","o","Ō",
   "ō","U","u","Ū","ū","Y","y","Ȳ","ȳ","Æ","æ","Œ","œ"}

-- possible diphthongs are "au" and "eu", macrons are not used
firstVowelsOfDiphthongs = createSet{"A", "a", "E", "e"}

-- q is intentionally left out here
consonants = createSet{"B","b","C","c","D","d","F","f","G","g","H","h","J","j",
   "K","k","L","l","M","m","N","n","P","p","R","r","S","s","T","t","V","v","W",
   "w","X","x","Z","z"}

-- stop consonants, called "(litterae) mutae" in Latin
mutae = createSet{"B", "b", "P", "p", "D", "d", "T", "t", "G", "g", "C", "c",
   "K", "k"}

-- liquid consonants, called "(litterae) liquidae" in Latin
liquidae = createSet{"L", "l", "R", "r"}


function endsInTwoConsonants(word)
   if consonants[utf8substring(word,-1,-1)]
   and consonants[utf8substring(word,-2,-2)]
   and (consonants[utf8substring(word,-3,-3)]
   or not mutae[utf8substring(word,-2,-2)]
   or not liquidae[utf8substring(word,-1,-1)]) then
      return true
   else
      return false
   end
end

function endsIn(word,ending)
   if string.len(word) > string.len(ending)
   and string.sub(word,-string.len(ending)) == ending then
      return true
   else
      return false
   end
end

function beginWithSameLetter(wordA,wordB)
   if utf8substring(wordA,1,1) == utf8substring(wordB,1,1) then
      return true
   else
      return false
   end
end

-- adjectives with consonantal declension
adjectivesConsonantalDeclension = createSet{"compos","com-pos","dīves",
   "particeps","parti-ceps","pauper","prīnceps","prīn-ceps","sōspes",
   "super-stes","vetus"}

-- adjectives with superlative ending in "-limus"
adjectivesSuperlative_limus = createSet{"difficilis","dif-ficilis","dissimilis",
   "dis-similis","facilis","gracilis","humilis","similis"}

-- adjectives using declensed forms as adverb instead of a regular adverb
adjectivesWithDeclensedFormAdverb = createSet{"cēterus","crēber","malus",
   "meritus","multus","necessārius","nimius","paullus","paulus","perpetuus",
   "per-petuus","plērus","plērusque","plērus-que","plūrimus","plūrumus",
   "postrēmus","potissimus","rārus","sēcrētus","sērus","sōlus","subitus",
   "sub-itus","tantus","tūtus"}
   -- the adverb of "malus" is "male" with short e (= vocative)


function attachEndings(root,endings)
   for _,ending in pairs(endings) do
      if firstVowelsOfDiphthongs[string.sub(root,-1)]
      and string.sub(ending,1,1) == "u" then
         table.insert(outputlist,root.."|"..ending)
      else
         table.insert(outputlist,root..ending)
      end
   end
end

-- endings of the nouns of the first declension
nounEndings1 = { "a","æ","am","ā","ārum","īs","ās" }
nounEndings1_ae_arum = { "æ","ārum","īs","ās" }

-- endings of the nouns of the second declension
nounEndings2_us = { "us","ī","ō","um","e","ōrum","īs","ōs" }
nounEndings2_ius = { "ius","iī","ī","iō","ium","iōrum","iīs","iōs" }
nounEndings2_jus = { "jus","jī","ī","jō","jum","jōrum","jīs","jōs" }
nounEndings2_us_neuter = { "us","ī","ō","a","ōrum","īs" }
nounEndings2_um = { "um","ī","ō","a","ōrum","īs" }
nounEndings2_ium = { "ium","iī","ī","iō","ia","iōrum","iīs" }
nounEndings2_jum = { "jum","jī","ī","jō","ja","jōrum","jīs" }
nounEndings2_r_ri = { "r","rī","rō","rum","rōrum","rīs","rōs" }
nounEndings2_er_ri = { "er","rī","rō","rum","rōrum","rīs","rōs" }
nounEndings2_i_orum = { "ī","ōrum","īs","ōs" }
nounEndings2_a_orum = { "a","ōrum","īs" }

-- endings of the nouns of the third declension
nounEndings3_i = { -- e.g. "turris"
   "is","ī","im","ēs","ium","ibus","īs"}
nounEndings3_i_neuter = { -- e.g. "mare", nom./acc. sing. is left out
   "is","ī","ia","ium","ibus"}
nounEndings3_i_plural = { -- e.g. "penātēs"
   "ēs","ium","ibus","īs"}
nounEndings3_i_neuter_plural = { -- e.g. "mœnia"
   "ia","ium","ibus"}
nounEndings3_mixed = { -- e.g. "pars", nom. sing. is left out
   "is","ī","em","e","ēs","ium","ibus","īs"}
nounEndings3_mixed_neuter = { -- e.g. "os", nom./acc. sing. is left out
   "is","ī","e","a","ium","ibus"}
nounEndings3_consonantal = { -- e.g. "cōnsul", nom. sing. is left out
   "is","ī","em","e","ēs","um","ibus"}
nounEndings3_consonantal_neuter = { -- e.g. "mūnus", nom./acc. sing. is left out
   "is","ī","e","a","um","ibus"}
nounEndings3_consonantal_plural = { -- e.g. "majōrēs"
   "ēs","um","ibus"}
nounEndings3_mixedAndConsonantal = { -- e.g. "parēns", nom. sing. is left out
   "is","ī","em","e","ēs","ium","um","ibus","īs"}

-- endings of the nouns of the fourth declension
nounEndings4_us = { -- e.g. "currus"
   "us","ūs","uī","um","ū","ūs","uum","ibus"}
nounEndings4_us_ubus = { -- e.g. "arcus"
   "us","ūs","uī","um","ū","ūs","uum","ubus"}
nounEndings4_us_plural = { -- e.g. "Īdūs"
   "ūs","uum","ibus"}
nounEndings4_u = { -- e.g. "cornū"
   "ū","ūs","ua","uum","ibus"}

-- endings of the nouns of the fifth declension
nounEndings5 = { -- e.g. "rēs"
   "ēs","eī","em","ē","ērum","ēbus"}
nounEndings5_afterVowel = { -- e.g. "diēs"
   "ēs","ēī","em","ē","ērum","ēbus"} -- long e in the genitive/dative sg.

-- endings of the adjectives of the first and second declension
adjectiveEndings_us_a_um = { -- e.g. "bonus"
   "us","a","um","ī","æ","ō","am","ā","e","ōrum","ārum","īs","ōs","ās"}

adjectiveEndings_i_ae_a = { -- plural
   "ī","æ","a","ōrum","ārum","īs","ōs","ās"}

adjectiveEndings_r_ra_rum = { -- e.g. "liber", "satur"
   "r","ra","rum","rī","ræ","rō","ram","rā","rōrum","rārum","rīs","rōs","rās"}

adjectiveEndings_er_ra_rum = { -- e.g. "pulcher"
   "er","ra","rum","rī","ræ","rō","ram","rā","rōrum","rārum","rīs","rōs","rās"}

pronominalAdjectiveEndings = { -- e.g. "sōlus"
   "us","a","um","īus","ī","am","ō","ā","e","æ","ōrum","ārum","īs","ōs","ās"}

pronominalAdjectiveEndingsSingular = {
   "us","a","um","īus","ī","am","ō","ā","e"}

endings_o_ae = { -- "duo" and "ambō", nominative ending in "o"/"ō" is left out
   "æ","ōrum","ārum","ōbus","ābus","ōs","ās"}

-- endings of the adjectives of the third declension
adjectiveEndings_er_ris_re = { -- e.g. "acer"
   "er","ris","re","rī","rem","rēs","ria","rium","ribus","rīs"}
   -- "rīs" is a variant of "rēs" for the accusative plural

adjectiveEndings_r_ris_re = { -- "celer"
   "r","ris","re","rī","rem","rēs","ria","rum","ribus","rīs"}
   -- "rīs" is a variant of "rēs" for the accusative plural

adjectiveEndings_is_e = { -- e.g. "brevis"
   "is","e","ī","em","ēs","ia","ium","ibus","īs"}
   -- "īs" is a variant of "ēs" for the accusative plural

adjectiveEndings_ior_ius = { -- e.g. "altior"
   "ior","ius","iōris","iōrī","iōrem","iōre","iōrēs","iōra","iōrum","iōribus"}

adjectiveEndings_jor_jus = { -- e.g. "pējor"
   "jor","jus","jōris","jōrī","jōrem","jōre","jōrēs","jōra","jōrum","jōribus"}

adjectiveEndings_ans_antis = { -- e.g. "cōnstāns"
   "āns","antis","antī","antem","antēs","antia","antium","antibus","antīs"}
   -- "antīs" is a variant of "antēs" for the accusative plural

adjectiveEndings_ens_entis = { -- e.g. "vehemēns"
   "ēns","entis","entī","entem","entēs","entia","entium","entibus","entīs"}
   -- "entīs" is a variant of "entēs" for the accusative plural

adjectiveEndings_i_ium = { -- e.g. "atrōx", nom. sing. is left out
   "is","ī","em","ēs","ia","ium","ibus","īs"}
   -- "īs" is a variant of "ēs" for the accusative plural

adjectiveEndings_es_ium = { -- plural only, e.g. "trēs"
   "ēs","ia","ium","ibus","īs"}
   -- "īs" is a variant of "ēs" for the accusative plural

adjectiveEndings_i_um = { -- e.g. "memor", nom. sing. is left out
   "is","ī","em","ēs","um","ibus"}
   -- nominative and accusative neuter plural are not in use

adjectiveEndings_e_um = { -- e.g. "vetus", nom. sing. is left out
   "is","ī","em","e","ēs","a","um","ibus"}

-- the participles present active follow the mixed declension
participlePresentActiveEndingsA = { -- e.g. "laudāns" < "laudāre"
   "āns","antis","antī","antem","ante",
   "antēs","antia","antium","antibus","antīs"}
   -- "antīs" is a variant of "antēs" for the accusative plural

participlePresentActiveEndingsE = { -- e.g. "mittēns" < "mittere"
   "ēns","entis","entī","entem","ente",
   "entēs","entia","entium","entibus","entīs"}
   -- "entīs" is a variant of "entēs" for the accusative plural

-- endings of the first conjugation
presentStemEndingsActive1 = {
   "ō","ās","at","āmus","ātis","ant", -- indicative present
   "ābam","ābās","ābat","ābāmus","ābātis","ābant", -- indicative imperfect
   "ābō","ābis","ābit","ābimus","ābitis","ābunt", -- future
   "em","ēs","et","ēmus","ētis","ent", -- subjunctive present
   "ārem","ārēs","āret","ārēmus","ārētis","ārent", -- subjunctive imperfect
   "ā","āte","ātō","ātōte","antō" -- imperative
   }

presentStemEndingsPassive1 = {
   "or","āris","ātur","āmur","āminī","antur", -- indicative present
   "ābar","ābāris","ābātur","ābāmur","ābāminī","ābantur", -- indicative imperfect
   "ābor","āberis","ābitur","ābimur","ābiminī","ābuntur", -- future
   "er","ēris","ētur","ēmur","ēminī","entur", -- subjunctive present
   "ārer","ārēris","ārētur","ārēmur","ārēminī","ārentur", -- subjunctive imperfect
   "āre","ātor","antor", -- imperative
   "ārī" --infinitive
   }

-- special forms for "dare" (the "a" is short except in "dās" and "dā")
presentStemEndingsDare = {
   "ō","ās","at","amus","atis","ant", -- indicative present active
   "abam","abās","abat","abāmus","abātis","abant", -- indicative imperfect active
   "abō","abis","abit","abimus","abitis","abunt", -- future active
   "em","ēs","et","ēmus","ētis","ent", -- subjunctive present active
   "arem","arēs","aret","arēmus","arētis","arent", -- subjunctive imperfect active
   "ā","ate","atō","atōte","antō", -- imperative active
   "or","aris","atur","amur","aminī","antur", -- indicative present passive
   "abar","abāris","abātur","abāmur","abāminī","abantur", -- indicative imperfect passive
   "abor","aberis","abitur","abimur","abiminī","abuntur", -- future passive
   "er","ēris","ētur","ēmur","ēminī","entur", -- subjunctive present passive
   "arer","arēris","arētur","arēmur","arēminī","arentur", -- subjunctive imperfect passive
   "are","ator","antor", -- imperative passive
   "arī" --infinitive passive
   }

-- endings of the second conjugation
presentStemEndingsActive2 = {
   "eō","ēs","et","ēmus","ētis","ent", -- indicative present
   "ēbam","ēbās","ēbat","ēbāmus","ēbātis","ēbant", -- indicative imperfect
   "ēbō","ēbis","ēbit","ēbimus","ēbitis","ēbunt", -- future
   "eam","eās","eat","eāmus","eātis","eant", -- subjunctive present
   "ērem","ērēs","ēret","ērēmus","ērētis","ērent", -- subjunctive imperfect
   "ē","ēte","ētō","ētōte","entō" -- imperative
   }

presentStemEndingsPassive2 = {
   "eor","ēris","ētur","ēmur","ēminī","entur", -- indicative present
   "ēbar","ēbāris","ēbātur","ēbāmur","ēbāminī","ēbantur", -- indicative imperfect
   "ēbor","ēberis","ēbitur","ēbimur","ēbiminī","ēbuntur", -- future
   "ear","eāris","eātur","eāmur","eāminī","eantur", -- subjunctive present
   "ērer","ērēris","ērētur","ērēmur","ērēminī","ērentur", -- subjunctive imperfect
   "ēre","ētor","entor", -- imperative
   "ērī" --infinitive
   }

-- endings of the third conjugation
presentStemEndingsActive3 = {
   "ō","is","it","imus","itis","unt", -- indicative present
   "ēbam","ēbās","ēbat","ēbāmus","ēbātis","ēbant", -- indicative imperfect
   "am","ēs","et","ēmus","ētis","ent", -- future
   "ās","at","āmus","ātis","ant", -- subjunctive present
   "erem","erēs","eret","erēmus","erētis","erent", -- subjunctive imperfect
   "ite","itō","itōte","untō" -- imperative
   }
--[[ the ending "e" of the second person singular of the imperative present is
not taken into account here as there are irregular forms for "dīcere" and
"dūcere" ]]

presentStemEndingsPassive3 = {
   "or","eris","itur","imur","iminī","untur", -- indicative present
   "ēbar","ēbāris","ēbātur","ēbāmur","ēbāminī","ēbantur", -- indicative imperfect
   "ar","ēris","ētur","ēmur","ēminī","entur", -- future
   "āris","ātur","āmur","āminī","antur", -- subjunctive present
   "erer","erēris","erētur","erēmur","erēminī","erentur", -- subjunctive imperfect
   "ere","itor","untor", -- imperative
   "ī" --infinitive
   }

-- endings of the mixed third conjugation
presentStemEndingsActive3M = {
   "iō","is","it","imus","itis","iunt", -- indicative present
   "iēbam","iēbās","iēbat","iēbāmus","iēbātis","iēbant", -- indicative imperfect
   "iam","iēs","iet","iēmus","iētis","ient", -- future
   "iās","iat","iāmus","iātis","iant", -- subjunctive present
   "erem","erēs","eret","erēmus","erētis","erent", -- subjunctive imperfect
   "ite","itō","itōte","iuntō" -- imperative
--[[ the ending "e" of the second person singular of the imperative present is
not taken into account here as there are irregular forms for "facere" and
"calefacere" ]]
   }

presentStemEndingsPassive3M = {
   "ior","eris","itur","imur","iminī","iuntur", -- indicative present
   "iēbar","iēbāris","iēbātur","iēbāmur","iēbāminī","iēbantur", -- indicative imperfect
   "iar","iēris","iētur","iēmur","iēminī","ientur", -- future
   "iāris","iātur","iāmur","iāminī","iantur", -- subjunctive present
   "erer","erēris","erētur","erēmur","erēminī","erentur", -- subjunctive imperfect
   "ere","itor","iuntor", -- imperative
   "ī" --infinitive
   }

-- endings of the fourth conjugation
presentStemEndingsActive4 = {
   "iō","īs","it","īmus","ītis","iunt", -- indicative present
   "iēbam","iēbās","iēbat","iēbāmus","iēbātis","iēbant", -- indicative imperfect
   "iam","iēs","iet","iēmus","iētis","ient", -- future
   "iās","iat","iāmus","iātis","iant", -- subjunctive present
   "īrem","īrēs","īret","īrēmus","īrētis","īrent", -- subjunctive imperfect
   "ī","īte","īto","ītōte","iuntō" -- imperative
   }

presentStemEndingsPassive4 = {
   "ior","īris","ītur","īmur","īminī","iuntur", -- indicative present
   "iēbar","iēbāris","iēbātur","iēbāmur","iēbāminī","iēbantur", -- indicative imperfect
   "iar","iēris","iētur","iēmur","iēminī","ientur", -- future
   "iāris","iātur","iāmur","iāminī","iantur", -- subjunctive present
   "īrer","īrēris","īrētur","īrēmur","īrēminī","īrentur", -- subjunctive imperfect
   "īre","ītor","iuntor", -- imperative
   "īrī" --infinitive
   }


-- generate positive forms of adjectives with three endings
function generatePositiveForms3(masculine,feminine)
   -- adjectives of the first and second declension ending in "us/a/um"
   if endsIn(masculine,"us") and feminine == nil then
      root = string.sub(masculine,1,-3)
      if masculine == "sōlus" then -- pronominal declension
         attachEndings(root,pronominalAdjectiveEndings)
      else
         attachEndings(root,adjectiveEndings_us_a_um)
      end

   -- plērusque
   elseif (masculine == "plērusque" or masculine == "plērus-que")
   and feminine == nil then
      for _,ending in pairs(adjectiveEndings_us_a_um) do
         table.insert(outputlist,"plēr"..ending.."que")
      end

   -- adjectives of the first and second declension ending in "r/ra/rum"
   elseif string.len(masculine) > 1 and endsIn(masculine,"r")
   and feminine and string.len(feminine) == string.len(masculine) + 1
   and string.sub(feminine,1,-3) == string.sub(masculine,1,-2)
   and endsIn(feminine,"ra") then
      root = string.sub(masculine,1,-2)
      attachEndings(root,adjectiveEndings_r_ra_rum)

   -- adjectives of the first and second declension ending in "er/ra/rum"
   elseif string.len(masculine) > 2 and endsIn(masculine,"er")
   and feminine and string.len(feminine) == string.len(masculine)
   and string.sub(feminine,1,-3) == string.sub(masculine,1,-3)
   and endsIn(feminine,"ra") then
      root = string.sub(masculine,1,-3)
      attachEndings(root,adjectiveEndings_er_ra_rum)

   -- adjectives of the third declension ending in "er/ris/re"
   elseif string.len(masculine) > 2 and endsIn(masculine,"er")
   and feminine and string.len(feminine) == string.len(masculine) + 1
   and string.sub(feminine,1,-4) == string.sub(masculine,1,-3)
   and endsIn(feminine,"ris") then
      root = string.sub(masculine,1,-3)
      attachEndings(root,adjectiveEndings_er_ris_re)

   -- adjectives of the third declension ending in "r/ris/re" ("celer")
   elseif string.len(masculine) > 1 and endsIn(masculine,"r")
   and feminine and string.len(feminine) == string.len(masculine) + 2
   and string.sub(feminine,1,-4) == string.sub(masculine,1,-2)
   and endsIn(feminine,"ris") then
      root = string.sub(masculine,1,-2)
      attachEndings(root,adjectiveEndings_r_ris_re)

   else
      invalidLine()
   end
end

-- generate comparative and superlative forms of adjectives with three endings
function generateComparativeAndSuperlative3(masculine,feminine)
   if masculine == "bonus" then
      attachEndings("mel",adjectiveEndings_ior_ius) -- comparative (melior)
      attachEndings("optim",adjectiveEndings_us_a_um) -- superlative (optimus)
      generateAdverb3("optimus") -- adverb of superlative

   elseif masculine == "citer" then
      attachEndings("citer",adjectiveEndings_ior_ius) -- comparative
      attachEndings("citim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3("citimus") -- adverb of superlative

   elseif masculine == "māgnus" then
      attachEndings("mā",adjectiveEndings_jor_jus) -- comparative (mājor)
      attachEndings("maxim",adjectiveEndings_us_a_um) -- superlative (maximus)
      generateAdverb3("maximus") -- adverb of superlative

   elseif masculine == "malus" then
      attachEndings("pē",adjectiveEndings_jor_jus) -- comparative (pējor)
      attachEndings("pessim",adjectiveEndings_us_a_um) -- superlative (pessimus)
      generateAdverb3("pessimus") -- adverb of superlative

   elseif masculine == "multus" then
      generatePositiveForms1("plūs","plūris")
      attachEndings("plūrim",adjectiveEndings_us_a_um) -- superlative
      attachEndings("plūrum",adjectiveEndings_us_a_um) -- superlative
      -- adverb is "plūrimum" (= accusative)

   elseif endsIn(masculine,"dicus") then
      root = string.sub(masculine,1,-5).."īcent"
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(root.."issimus") -- adverb of superlative

   elseif endsIn(masculine,"ficus") or endsIn(masculine,"volus") then
      root = string.sub(masculine,1,-3).."ent"
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(root.."issimus") -- adverb of superlative

   -- adjectives of the first and second declension ending in "us/a/um"
   elseif endsIn(masculine,"us") then
      if string.len(masculine) > 3 and vowels[utf8substring(masculine,-3,-3)]
      and string.sub(masculine,-4) ~= "quus" then
         -- adjectives ending in vowel+"us" are not comparable
      else
         root = string.sub(masculine,1,-3)
         attachEndings(root,adjectiveEndings_ior_ius) -- comparative

         if masculine == "exterus" then
            attachEndings("extrēm",adjectiveEndings_us_a_um) -- superlative
            generateAdverb3("extrēmus") -- adverb of superlative
         elseif masculine == "īnferus" then
            attachEndings("īnfim",adjectiveEndings_us_a_um) -- first superlative
            attachEndings("īm",adjectiveEndings_us_a_um) -- second superlative
            generateAdverb3("īnfimus") -- adverb of first superlative
            generateAdverb3("īmus") -- adverb of second superlative
         elseif masculine == "posterus" then
            attachEndings("postrēm",adjectiveEndings_us_a_um) -- first superlative
            attachEndings("postum",adjectiveEndings_us_a_um) -- second superlative
            generateAdverb3("postrēmus") -- adverb of first superlative
            generateAdverb3("postumus") -- adverb of second superlative
         elseif masculine == "superus" then
            attachEndings("suprēm",adjectiveEndings_us_a_um) -- superlative
            generateAdverb3("suprēmus") -- adverb of superlative
         else
            attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
              generateAdverb3(root.."issimus") -- adverb of superlative
         end
      end

   -- plērusque
   elseif (masculine == "plērusque" or masculine == "plērus-que") then
      for _,ending in pairs(adjectiveEndings_ior_ius) do
         table.insert(outputlist,"plēr"..ending.."que") -- comparative
      end
      for _,ending in pairs(adjectiveEndings_us_a_um) do
         table.insert(outputlist,"plērissim"..ending.."que") -- superlative
      end
      generateAdverb3("plērissimusque") -- adverb of superlative

   -- adjectives of the first and second declension ending in "r/ra/rum"
   elseif string.len(masculine) > 1 and endsIn(masculine,"r")
   and feminine and string.len(feminine) == string.len(masculine) + 1
   and string.sub(feminine,1,-3) == string.sub(masculine,1,-2)
   and endsIn(feminine,"ra") then
      attachEndings(masculine,adjectiveEndings_ior_ius) -- comparative
      if masculine == "exter" then
         attachEndings("extrēm",adjectiveEndings_us_a_um) -- superlative
         generateAdverb3("extrēmus") -- adverb of superlative
      else
         attachEndings(masculine.."rim",adjectiveEndings_us_a_um) -- superlative
         generateAdverb3(masculine.."rimus") -- adverb of superlative
      end

   -- adjectives of the first and second declension ending in "er/ra/rum"
   elseif string.len(masculine) > 2 and endsIn(masculine,"er")
   and feminine and string.len(feminine) == string.len(masculine)
   and string.sub(feminine,1,-3) == string.sub(masculine,1,-3)
   and endsIn(feminine,"ra") then
      root = string.sub(feminine,1,-2)
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      attachEndings(masculine.."rim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(masculine.."rimus") -- adverb of superlative

   -- adjectives of the third declension ending in "er/ris/re"
   elseif string.len(masculine) > 2 and endsIn(masculine,"er")
   and feminine and string.len(feminine) == string.len(masculine) + 1
   and string.sub(feminine,1,-4) == string.sub(masculine,1,-3)
   and endsIn(feminine,"ris") then
      root = string.sub(feminine,1,-3)
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      attachEndings(masculine.."rim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(masculine.."rimus") -- adverb of superlative

   -- adjectives of the third declension ending in "r/ris/re" ("celer")
   elseif string.len(masculine) > 1 and endsIn(masculine,"r")
   and feminine and string.len(feminine) == string.len(masculine) + 2
   and string.sub(feminine,1,-4) == string.sub(masculine,1,-2)
   and endsIn(feminine,"ris") then
      attachEndings(masculine,adjectiveEndings_ior_ius) -- comparative
      attachEndings(masculine.."rim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(masculine.."rimus") -- adverb of superlative
   end
end

-- generate adverb of adjectives with three endings
function generateAdverb3(masculine,feminine)
   if masculine == "bonus" then
      table.insert(outputlist,"bene")
   elseif masculine == "citus" then
      table.insert(outputlist,"cito") -- short o
   elseif masculine == "māgnus" then
      table.insert(outputlist,"magis")
      table.insert(outputlist,"mage")
   elseif masculine == "parvus" then
      table.insert(outputlist,"parum")
   elseif masculine == "plērissimusque" or masculine == "plērissimus-que" then
      table.insert(outputlist,"plērissimēque")
   elseif masculine == "rārus" then
      -- adverbs are "rārō" (= ablative) and "rārenter"
      table.insert(outputlist,"rārenter")
   elseif adjectivesWithDeclensedFormAdverb[masculine] then
      -- no additional form required
   elseif endsIn(masculine,"r") then
      if endsIn(feminine,"ra") then
         table.insert(outputlist,string.sub(feminine,1,-2).."ē")
         -- e.g. "miserē"/"pulchrē"
      else
         table.insert(outputlist,string.sub(feminine,1,-3).."iter")
         -- e.g. "ācriter"/"celeriter"
      end
   else
      table.insert(outputlist,string.sub(masculine,1,-3).."ē")
   end
end

-- generate positive forms of adjectives with two endings
function generatePositiveForms2(adjective)
   if adjective == "complūrēs" or adjective == "com-plūrēs" then
      table.insert(outputlist,"complūrēs") -- nominative/accusative
      table.insert(outputlist,"complūra") -- neuter
      table.insert(outputlist,"complūrium") -- genitive
      table.insert(outputlist,"complūribus") -- dative/ablative
      table.insert(outputlist,"complūrīs") -- alternative accusative

   -- adjectives of the third declension ending in "is/e"
   elseif string.len(adjective) > 2 and endsIn(adjective,"is") then
      root = string.sub(adjective,1,-3)
      attachEndings(root,adjectiveEndings_is_e)

   -- adjectives of the third declension ending in "ior/ius"
   elseif string.len(adjective) > 3 and endsIn(adjective,"ior") then
      root = string.sub(adjective,1,-4)
      attachEndings(root,adjectiveEndings_ior_ius)

   else
      invalidField(adjective)
   end
end

-- generate comparative and superlative forms of adjectives with two endings
function generateComparativeAndSuperlative2(adjective)
   -- adjectives of the third declension ending in "is/e"
   if string.len(adjective) > 2 and endsIn(adjective,"is") then
      root = string.sub(adjective,1,-3)
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      if adjectivesSuperlative_limus[adjective] then
         attachEndings(root.."lim",adjectiveEndings_us_a_um) -- superlative
         generateAdverb3(root.."limus") -- adverb of superlative
      else
         attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
         generateAdverb3(root.."issimus") -- adverb of superlative
      end

   -- comparatives of the third declension ending in "ior/ius"
   elseif string.len(adjective) > 3 and endsIn(adjective,"ior") then
      if adjective == "dēterior" then
         attachEndings("dēterrim",adjectiveEndings_us_a_um) -- superlative
         generateAdverb3("dēterrimus") -- adverb of superlative
      elseif adjective == "propior" then
         attachEndings("proxim",adjectiveEndings_us_a_um) -- first superlative
         attachEndings("proxum",adjectiveEndings_us_a_um) -- second superlative
         generateAdverb3("proximus") -- adverb of first superlative
         generateAdverb3("proxumus") -- adverb of second superlative
      else
         root = string.sub(adjective,1,-4)
         attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
         generateAdverb3(root.."issimus") -- adverb of superlative
      end
   end
end

-- generate adverb of adjectives with two endings
function generateAdverb2(adjective)
   if adjective == "difficilis" or adjective == "dif-ficilis" then
      table.insert(outputlist,"difficulter")
   elseif adjective == "facilis" then
      -- adverb is "facile" (= neuter)
   elseif endsIn(adjective,"ior") then
      -- adverb ends in "-ius" (= neuter)
   elseif endsIn(adjective,"is") then
      table.insert(outputlist,string.sub(adjective,1,-2).."ter")
   end
end

-- generate positive forms of adjectives with one ending
function generatePositiveForms1(nominative,genitive)
   -- adjectives of the third declension ending in "āns"
   if endsIn(nominative,"āns") then
      if genitive == nil then
         root = utf8substring(nominative,1,-4)
         attachEndings(root,adjectiveEndings_ans_antis)
      else
         invalidLine()
      end

   -- adjectives of the third declension ending in "ēns"
   elseif endsIn(nominative,"ēns") then
      if genitive == nil then
         root = utf8substring(nominative,1,-4)
         attachEndings(root,adjectiveEndings_ens_entis)
      else
         invalidLine()
      end

   -- adjectives with consonantal declension
   elseif adjectivesConsonantalDeclension[nominative] == true then
      if genitive and beginWithSameLetter(nominative,genitive)
         and endsIn(genitive,"is") then
         table.insert(outputlist,nominative)
         root = string.sub(genitive,1,-3)
         attachEndings(root,adjectiveEndings_e_um)
      else
         invalidLine()
      end

   -- plūs
   elseif nominative == "plūs" and genitive == "plūris" then
      table.insert(outputlist,"plūs") -- nominative/accusative
      table.insert(outputlist,"plūris") -- genitive
      table.insert(outputlist,"plūre") -- ablative (dative is missing)
      attachEndings("plūr",adjectiveEndings_es_ium) -- plural forms
      table.insert(outputlist,"plūra") -- alternative neuter plural

   -- adjectives with abl. sing. ending in "-ī", but gen. pl. ending in "-um"
   elseif (nominative == "in-ops" and genitive == "in-opis") or
   (nominative == "memor" and genitive == "memoris") or
   (nominative == "vigil" and genitive == "vigilis") then
      table.insert(outputlist,nominative)
      root = string.sub(genitive,1,-3)
      attachEndings(root,adjectiveEndings_i_um)

   -- adjectives with ī declension
   else
      if genitive and utf8.len(genitive) >= utf8.len(nominative)
      and beginWithSameLetter(nominative,genitive)
      and endsIn(genitive,"is") then
         table.insert(outputlist,nominative)
         root = string.sub(genitive,1,-3)
         attachEndings(root,adjectiveEndings_i_ium)
      else
         invalidLine()
      end
   end
end

-- generate comparative and superlative forms of adjectives with one ending
function generateComparativeAndSuperlative1(nominative,genitive)
   if nominative == "vetus" and genitive == "veteris" then
      attachEndings("vetust",adjectiveEndings_ior_ius) -- comparative
      attachEndings("veterrim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3("veterrimus") -- adverb of superlative

   -- adjectives of the third declension ending in "āns"
   elseif utf8.len(nominative) > 3 and endsIn(nominative,"āns") then
      root = utf8substring(nominative,1,-4).."ant"
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(root.."issimus") -- adverb of superlative

   -- adjectives of the third declension ending in "ēns"
   elseif utf8.len(nominative) > 3 and endsIn(nominative,"ēns") then
      root = utf8substring(nominative,1,-4).."ent"
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(root.."issimus") -- adverb of superlative

   -- plūs
   elseif nominative == "plūs" and genitive == "plūris" then
      attachEndings("plūrim",adjectiveEndings_us_a_um) -- superlative
      attachEndings("plūrum",adjectiveEndings_us_a_um) -- superlative
      -- adverb is "plūrimum" (= accusative)

   -- regular adjectives with genitive ending in "is"
   else
      root = string.sub(genitive,1,-3)
      attachEndings(root,adjectiveEndings_ior_ius) -- comparative
      attachEndings(root.."issim",adjectiveEndings_us_a_um) -- superlative
      generateAdverb3(root.."issimus") -- adverb of superlative
      if nominative == "juvenis" and genitive == nominative then
         attachEndings("jūn",adjectiveEndings_ior_ius) -- second comparative
      end
   end
end


-- generate adverb of adjectives with one ending
function generateAdverb1(nominative,genitive)
   if nominative == "audāx" then
      table.insert(outputlist,"audāciter")
      table.insert(outputlist,"audācter")
   elseif nominative == "sollers" then
      table.insert(outputlist,"sollerter")
   elseif utf8.len(nominative) > 3 and endsIn(nominative,"āns") then
      table.insert(outputlist,utf8substring(nominative,1,-4).."anter")
   elseif utf8.len(nominative) > 3 and endsIn(nominative,"ēns") then
      table.insert(outputlist,utf8substring(nominative,1,-4).."enter")
   else
      table.insert(outputlist,string.sub(genitive,1,-2).."ter")
   end
end


-- read input line by line
linecount = 0
for line in io.lines() do
   linecount = linecount + 1
   wholeLine = line
   i = string.find(line,",")

   if i == nil then
      firstField = line
      secondField = nil
      thirdField = nil
      fourthField = nil
   else
      firstField = string.sub(line,1,i-1)
      line = string.sub(line,i+1,-1)
      i = string.find(line,",")

      if i == nil then
         secondField = line
         thirdField = nil
         fourthField = nil
      else
         secondField = string.sub(line,1,i-1)
         line = string.sub(line,i+1,-1)
         i = string.find(line,",")

         if i == nil then
            thirdField = line
            fourthField = nil
         else
            thirdField = string.sub(line,1,i-1)
            fourthField = string.sub(line,i+1,-1)
         end
      end
   end

   -- uninflectable word
   if secondField == nil and thirdField == nil and fourthField == nil then
      table.insert(outputlist,firstField)

   -- verb of the first conjugation
   elseif secondField == "1" then
      if utf8.len(firstField) < 2 then
         invalidField(firstField)
      elseif firstField == "dō" or utf8.len(firstField) > 3
         and utf8substring(firstField,-3) == "-dō" then
         root = utf8substring(firstField,1,-2)
         attachEndings(root,presentStemEndingsDare)
         attachEndings(root,participlePresentActiveEndingsA)
         attachEndings(root.."and",adjectiveEndings_us_a_um) -- gerundivum
      elseif utf8substring(firstField,-1) == "ō" then
         root = utf8substring(firstField,1,-2)
         attachEndings(root,presentStemEndingsActive1)
         attachEndings(root,presentStemEndingsPassive1)
         attachEndings(root,participlePresentActiveEndingsA)
         attachEndings(root.."and",adjectiveEndings_us_a_um) -- gerundivum
      elseif string.sub(firstField,-2) == "or" then
         root = string.sub(firstField,1,-3)
         attachEndings(root,presentStemEndingsPassive1)
         attachEndings(root,participlePresentActiveEndingsA)
         attachEndings(root.."and",adjectiveEndings_us_a_um) -- gerundivum
      else
         invalidField(firstField)
      end

   -- verb of the second conjugation
   elseif secondField == "2" then
      if utf8.len(firstField) < 3 then
         invalidField(firstField)
      elseif utf8substring(firstField,-2) == "eō" then
         root = utf8substring(firstField,1,-3)
         attachEndings(root,presentStemEndingsActive2)
         attachEndings(root,presentStemEndingsPassive2)
         attachEndings(root,participlePresentActiveEndingsE)
         attachEndings(root.."end",adjectiveEndings_us_a_um) -- gerundivum
      elseif string.sub(firstField,-3) == "eor" then
         root = string.sub(firstField,1,-4)
         attachEndings(root,presentStemEndingsPassive2)
         attachEndings(root,participlePresentActiveEndingsE)
         attachEndings(root.."end",adjectiveEndings_us_a_um) -- gerundivum
      else
         invalidField(firstField)
      end

   -- verb of the third conjugation
   elseif secondField == "3" then
      if utf8.len(firstField) < 3 then
         invalidField(firstField)
      elseif utf8substring(firstField,-1) == "ō" then
         local c = utf8substring(firstField,-2,-2)
         if not consonants[c] and c ~= "u" then
            invalidLine()
         else
            root = utf8substring(firstField,1,-2)
            -- active forms
            attachEndings(root,presentStemEndingsActive3)
            -- second person singular of the imperative present
            if firstField == "dīcō" or firstField == "dūcō" or
               utf8.len(firstField) > 5 and
                  (utf8substring(firstField,-5) == "-dīcō"
                     or utf8substring(firstField,-5) == "-dūcō")
               then
               table.insert(outputlist,root) -- "dīc"/"dūc"
            else
               table.insert(outputlist,root.."e") -- e.g. "mitte"
            end
            -- passive forms
            attachEndings(root,presentStemEndingsPassive3)
            attachEndings(root,participlePresentActiveEndingsE)
            attachEndings(root.."end",adjectiveEndings_us_a_um) -- gerundivum
         end
      elseif string.sub(firstField,-2) == "or" then
         local c = utf8substring(firstField,-3,-3)
         if not consonants[c] and c ~= "u" then
            invalidLine()
         else
            root = string.sub(firstField,1,-3)
            attachEndings(root,presentStemEndingsPassive3)
            attachEndings(root,participlePresentActiveEndingsE)
            attachEndings(root.."end",adjectiveEndings_us_a_um) -- gerundivum
         end
      else
         invalidField(firstField)
      end

   -- verb of the mixed third conjugation
   elseif secondField == "3M" then
      if utf8.len(firstField) < 3 then
         invalidField(firstField)
      elseif utf8substring(firstField,-2) == "iō" then
         root = utf8substring(firstField,1,-3)
         -- active forms
         attachEndings(root,presentStemEndingsActive3M)
         -- second person singular of the imperative present
         if firstField == "cale-faciō" then
            table.insert(outputlist,"cal-face")
         elseif firstField == "faciō" or utf8.len(firstField) > 6 and
            utf8substring(firstField,-6) == "-faciō" then
            table.insert(outputlist,root) -- "fac"
         else
            table.insert(outputlist,root.."e") -- e.g. "cape"
         end
         attachEndings(root,presentStemEndingsPassive3M)
         attachEndings(root.."i",participlePresentActiveEndingsE)
         attachEndings(root.."iend",adjectiveEndings_us_a_um) -- gerundivum
      elseif string.sub(firstField,-3) == "ior" then
         root = string.sub(firstField,1,-4)
         attachEndings(root,presentStemEndingsPassive3M)
         attachEndings(root.."i",participlePresentActiveEndingsE)
         attachEndings(root.."iend",adjectiveEndings_us_a_um) -- gerundivum
      else
         invalidField(firstField)
      end

   -- verb of the fourth conjugation
   elseif secondField == "4" then
      if utf8.len(firstField) < 3 then
         invalidField(firstField)
      elseif utf8substring(firstField,-2) == "iō" then
         root = utf8substring(firstField,1,-3)
         attachEndings(root,presentStemEndingsActive4)
         attachEndings(root,presentStemEndingsPassive4)
         attachEndings(root.."i",participlePresentActiveEndingsE)
         attachEndings(root.."iend",adjectiveEndings_us_a_um) -- gerundivum
      elseif string.sub(firstField,-3) == "ior" then
         root = string.sub(firstField,1,-4)
         attachEndings(root,presentStemEndingsPassive4)
         attachEndings(root.."i",participlePresentActiveEndingsE)
         attachEndings(root.."iend",adjectiveEndings_us_a_um) -- gerundivum
      else
         invalidField(firstField)
      end

   -- noun of the first declension
   elseif secondField == "D1" then
      if thirdField or fourthField then
         invalidLine()
      elseif endsIn(firstField,"a") then
         root = string.sub(firstField,1,-2)
         attachEndings(root,nounEndings1)
         if firstField == "dea" then
            table.insert(outputlist,"deābus") -- alternative genitive plural
         elseif firstField == "fīlia" then
            table.insert(outputlist,"fīliābus") -- alternative genitive plural
         end
      elseif endsIn(firstField,"æ") then -- plurale tantum
         if thirdField then
            invalidLine()
         else
            root = utf8substring(firstField,1,-2)
            attachEndings(root,nounEndings1_ae_arum)
         end
      else
         invalidField(firstField)
      end

   -- masculine/feminine noun of the second declension
   elseif secondField == "D2" then
      if fourthField then
         invalidLine()
      elseif endsIn(firstField,"us") then
         if thirdField then
            invalidLine()
         elseif firstField == "deus" then
            table.insert(outputlist,"de|us") -- nominative/vocative sg.
            table.insert(outputlist,"deī") -- genitive sg./nominative pl.
            table.insert(outputlist,"deō") -- dative/ablative sg.
            table.insert(outputlist,"de|um") -- accusative sg.
            table.insert(outputlist,"diī") -- nominative pl.
            table.insert(outputlist,"dī") -- nominative pl.
            table.insert(outputlist,"deōrum") -- genitive pl.
            table.insert(outputlist,"deīs") -- dative/ablative pl.
            table.insert(outputlist,"diīs") -- dative/ablative pl.
            table.insert(outputlist,"dīs") -- dative/ablative pl.
            table.insert(outputlist,"deōs") -- accusative pl.
         elseif endsIn(firstField,"ius") then
            root = string.sub(firstField,1,-4)
            attachEndings(root,nounEndings2_ius)
         elseif endsIn(firstField,"jus") then
            root = string.sub(firstField,1,-4)
            attachEndings(root,nounEndings2_jus)
         else
            root = string.sub(firstField,1,-3)
            attachEndings(root,nounEndings2_us)
            if firstField == "locus" then
               table.insert(outputlist,"loca") -- alternative nom./acc. pl.
            end
         end
      elseif endsIn(firstField,"r") then
         if thirdField and utf8substring(thirdField,1,-2) == firstField
         and endsIn(thirdField,"ī") then -- e.g. "puer"
            root = string.sub(firstField,1,-2)
            attachEndings(root,nounEndings2_r_ri)
            if firstField == "vesper" then
               table.insert(outputlist,"vespere") -- alternative abl. sg.
            end
         elseif thirdField
         and utf8substring(thirdField,1,-3) == utf8substring(firstField,1,-3)
         and endsIn(thirdField,"rī") then -- e.g. "ager"
            root = string.sub(firstField,1,-3)
            attachEndings(root,nounEndings2_er_ri)
         else
            invalidLine()
         end
      elseif endsIn(firstField,"ī") then -- plurale tantum
         if thirdField then
            invalidLine()
         else
            root = utf8substring(firstField,1,-2)
            attachEndings(root,nounEndings2_i_orum)
         end
      else
         invalidField(firstField)
      end

   -- neuter noun of the second declension
   elseif secondField == "D2N" then
      if thirdField or fourthField then
         invalidLine()
      elseif endsIn(firstField,"um") then
         if endsIn(firstField,"ium") then
            root = string.sub(firstField,1,-4)
            attachEndings(root,nounEndings2_ium)
         elseif endsIn(firstField,"jum") then
            root = string.sub(firstField,1,-4)
            attachEndings(root,nounEndings2_jum)
         else
            root = string.sub(firstField,1,-3)
            attachEndings(root,nounEndings2_um)
         end
      elseif endsIn(firstField,"us") then
         root = string.sub(firstField,1,-3)
         attachEndings(root,nounEndings2_us_neuter)
         if firstField == "vulgus" then
            table.insert(outputlist,"vulgum") -- alternative accusative sg.
         elseif firstField == "volgus" then
            table.insert(outputlist,"volgum") -- alternative accusative sg.
         end
      elseif endsIn(firstField,"a") then -- plurale tantum (neuter)
         root = string.sub(firstField,1,-2)
         attachEndings(root,nounEndings2_a_orum)
      end

   -- masculine/feminine noun of the third declension
   elseif secondField == "D3" then
      if string.len(firstField) < 2 or fourthField then
         invalidLine()
      -- noun ending in "-is" (with short i)
      elseif endsIn(firstField,"is") then
         if thirdField then
            -- i declension
            if string.sub(thirdField,1,-2) == string.sub(firstField,1,-2)
            and endsIn(thirdField,"im") then
               root = string.sub(firstField,1,-3)
               attachEndings(root,nounEndings3_i)
            -- consonantal declension
            elseif beginWithSameLetter(firstField,thirdField)
            and endsIn(thirdField,"is") then
               root = string.sub(thirdField,1,-3)
               attachEndings(root,nounEndings3_consonantal)
            else
               invalidField(thirdField)
            end
         -- consonantal declension
         elseif firstField == "canis" or firstField == "juvenis" then
            root = string.sub(firstField,1,-3)
            attachEndings(root,nounEndings3_consonantal)
         -- mixed or consonantal declension
         elseif firstField == "mēnsis" then
            root = string.sub(firstField,1,-3)
            attachEndings(root,nounEndings3_mixedAndConsonantal)
         -- mixed declension
         else
            root = string.sub(firstField,1,-3)
            attachEndings(root,nounEndings3_mixed)
         end
      -- noun ending in "-īs" (with long i)
      elseif endsIn(firstField,"īs") then
         -- vīs/vim/vī/vīrēs
         if firstField == "vīs" and thirdField == "vim" then
            table.insert(outputlist,"vīs") -- nominative sg.
            table.insert(outputlist,"vim") -- genitive sg.
            table.insert(outputlist,"vī") -- ablative sg.
            root = "vīr"
            attachEndings(root,nounEndings3_i_plural)
         elseif not thirdField or utf8.len(thirdField) < 5 then
            invalidLine()
         -- "-īs/-ītis": mixed declension
         elseif utf8substring(thirdField,1,-5) == utf8substring(firstField,1,-3)
         and endsIn(thirdField,"ītis") then -- e.g. "Samnīs"
            root = utf8substring(thirdField,1,-3)
            table.insert(outputlist,firstField) -- nominative sg.
            attachEndings(root,nounEndings3_mixed)
         else
            invalidField(thirdField)
         end
      -- noun ending in "-ēs"
      elseif endsIn(firstField,"ēs") then
         if not thirdField or utf8.len(thirdField) < 3 then
            invalidLine()
         -- singular
         elseif utf8substring(thirdField,1,-3) == utf8substring(firstField,1,-3)
         and endsIn(thirdField,"is") then
            -- consonantal declension
            if firstField == "sēdēs" then
               root = utf8substring(firstField,1,-3)
               attachEndings(root,nounEndings3_consonantal)
            -- mixed or consonantal declension
            elseif firstField == "vātēs" then
               root = utf8substring(firstField,1,-3)
               attachEndings(root,nounEndings3_mixedAndConsonantal)
            -- mixed declension
            else
               root = utf8substring(firstField,1,-3)
               attachEndings(root,nounEndings3_mixed)
            end
         -- plural ending in "-ium" (i declension)
         elseif utf8substring(thirdField,1,-4) == utf8substring(firstField,1,-3)
         and endsIn(thirdField,"ium") then
            root = utf8substring(firstField,1,-3)
            attachEndings(root,nounEndings3_i_plural)
         -- plural ending in "-um" (consonantal declension)
         elseif utf8substring(thirdField,1,-3) == utf8substring(firstField,1,-3)
         and endsIn(thirdField,"um") then
            root = utf8substring(firstField,1,-3)
            attachEndings(root,nounEndings3_consonantal_plural)
         else
            invalidField(thirdField)
         end
      -- noun ending in "-dō" or "-gō"
      elseif endsIn(firstField,"dō") or endsIn(firstField,"gō") then
         if thirdField then
            invalidLine()
         else
            root = utf8substring(firstField,1,-2).."in"
            table.insert(outputlist,firstField) -- nominative sg.
            attachEndings(root,nounEndings3_consonantal)
         end
      -- noun ending in "-ēns"
      elseif endsIn(firstField,"ēns") then
         if thirdField then
            invalidLine()
         elseif firstField == "parēns" then -- mixed or consonantal declension
            root = "parent"
            table.insert(outputlist,firstField) -- nominative sg.
            attachEndings(root,nounEndings3_mixedAndConsonantal)
         else -- mixed declension
            root = utf8substring(firstField,1,-4).."ent"
            table.insert(outputlist,firstField) -- nominative sg.
            attachEndings(root,nounEndings3_mixed)
         end
      -- noun ending in "-iō"
      elseif endsIn(firstField,"iō") then
         if thirdField then
            invalidLine()
         else
            root = firstField.."n"
            table.insert(outputlist,firstField) -- nominative sg.
            attachEndings(root,nounEndings3_consonantal)
         end
      -- noun ending in "-or"
      elseif endsIn(firstField,"or") then
         if thirdField then
            invalidLine()
         else
            root = string.sub(firstField,1,-3).."ōr"
            table.insert(outputlist,firstField) -- nominative sg.
            attachEndings(root,nounEndings3_consonantal)
         end
      -- noun ending in "-tās"
      elseif endsIn(firstField,"tās") then
         if thirdField then
            invalidLine()
         else
            root = utf8substring(firstField,1,-2).."t"
            table.insert(outputlist,firstField) -- nominative sg.
            attachEndings(root,nounEndings3_consonantal)
         end
      elseif not thirdField or utf8.len(thirdField) < 4 then
         invalidLine()
      -- singular
      elseif endsIn(thirdField,"is") then
         root = string.sub(thirdField,1,-3)
         if firstField == "bōs" and thirdField == "bovis" then
            table.insert(outputlist,"bōs") -- nominative sg.
            table.insert(outputlist,"bovis") -- genitive sg.
            table.insert(outputlist,"bovī") -- dative sg.
            table.insert(outputlist,"bovem") -- accusative sg.
            table.insert(outputlist,"bove") -- ablative sg.
            table.insert(outputlist,"bovēs") -- nominative/accusative pl.
            table.insert(outputlist,"bovum") -- genitive pl.
            table.insert(outputlist,"boum") -- genitive pl.
            table.insert(outputlist,"bōbus") -- dative/ablative pl.
            table.insert(outputlist,"būbus") -- dative/ablative pl.
         -- mixed declension
         elseif (firstField == "faux" and thirdField == "faucis")
         or (firstField == "līs" and thirdField == "lītis")
         or (firstField == "nix" and thirdField == "nivis")
         or endsInTwoConsonants(root) then
            table.insert(outputlist,firstField) -- nominative sg.
            attachEndings(root,nounEndings3_mixed)
         -- mixed or consonantal declension
         elseif (firstField == "fraus" and thirdField == "fraudis")
         or (firstField == "mūs" and thirdField == "mūris")
         or (firstField == "optimās" and thirdField == "optimātis") then
            table.insert(outputlist,firstField) -- nominative sg.
            attachEndings(root,nounEndings3_mixedAndConsonantal)
         -- consonantal declension
         else
            table.insert(outputlist,firstField) -- nominative sg.
            attachEndings(root,nounEndings3_consonantal)
         end
      else
         invalidLine()
      end

   -- neuter noun of the third declension
   elseif secondField == "D3N" then
      if string.len(firstField) < 2 or fourthField then
         invalidLine()
      -- pār
      elseif firstField == "pār" and thirdField == "paris" then
         root = "par"
         table.insert(outputlist,firstField) -- nominative/accusative sg.
         attachEndings(root,nounEndings3_i_neuter)
      -- neuter noun ending in "-e"
      elseif endsIn(firstField,"e") and thirdField
      and utf8.len(thirdField) == utf8.len(firstField) + 1
      and string.sub(thirdField,1,-3) == string.sub(firstField,1,-2)
      and endsIn(thirdField,"is") then
         root = string.sub(firstField,1,-2)
         table.insert(outputlist,firstField) -- nominative/accusative
         attachEndings(root,nounEndings3_i_neuter)
      -- neuter noun ending in "-al"
      elseif endsIn(firstField,"al") and thirdField
      and utf8.len(thirdField) == utf8.len(firstField) + 2
      and utf8substring(thirdField,1,-5) == string.sub(firstField,1,-3)
      and endsIn(thirdField,"ālis") then
         root = string.sub(thirdField,1,-3)
         table.insert(outputlist,firstField) -- nominative/accusative
         attachEndings(root,nounEndings3_i_neuter)
      -- neuter noun ending in "-ar"
      elseif endsIn(firstField,"ar") and thirdField
      and utf8.len(thirdField) == utf8.len(firstField) + 2
      and utf8substring(thirdField,1,-5) == string.sub(firstField,1,-3)
      and endsIn(thirdField,"āris") then
         root = string.sub(thirdField,1,-3)
         table.insert(outputlist,firstField) -- nominative/accusative
         attachEndings(root,nounEndings3_i_neuter)
      -- plurale tantum ending in "-ia"
      elseif endsIn(firstField,"ia") and thirdField
      and utf8.len(thirdField) == utf8.len(firstField) + 1
      and utf8substring(thirdField,1,-4) == string.sub(firstField,1,-3)
      and endsIn(thirdField,"ium") then
         root = string.sub(firstField,1,-3)
         attachEndings(root,nounEndings3_i_neuter_plural)
      -- neuter noun ending in "-men"
      elseif endsIn(firstField,"men") then
         if thirdField then
            invalidLine()
         else
            root = utf8substring(firstField,1,-3).."in"
            table.insert(outputlist,firstField) -- nominative sg.
            attachEndings(root,nounEndings3_consonantal)
         end
      elseif not thirdField or utf8.len(thirdField) < 5 then
         invalidLine()
      -- singular
      elseif endsIn(thirdField,"is") then
         root = string.sub(thirdField,1,-3)
         if firstField == "vās" and thirdField == "vāsis" then
            table.insert(outputlist,"vās") -- nominative/accusative sg.
            table.insert(outputlist,"vāsis") -- genitive sg.
            table.insert(outputlist,"vāsī") -- dative sg.
            table.insert(outputlist,"vāse") -- ablative sg.
            table.insert(outputlist,"vāsa") -- nominative/accusative pl.
            table.insert(outputlist,"vāsōrum") -- genitive pl.
            table.insert(outputlist,"vāsīs") -- dative/ablative pl.
         -- root ending in two or more consonants: mixed declension
         elseif endsInTwoConsonants(root) then
            table.insert(outputlist,firstField) -- nominative/accusative sg.
            attachEndings(root,nounEndings3_mixed_neuter)
         -- consonantal declension
         else
            table.insert(outputlist,firstField) -- nominative/accusative sg.
            attachEndings(root,nounEndings3_consonantal_neuter)
         end
      else
         invalidLine()
      end

   -- masculine/feminine noun of the fourth declension
   elseif secondField == "D4" then
      if thirdField or fourthField then
         invalidLine()
      elseif endsIn(firstField,"us") then
         root = string.sub(firstField,1,-3)
         if firstField == "domus" then
            table.insert(outputlist,"domus") -- nominative sg.
            table.insert(outputlist,"domūs") -- gen. sg./nom. pl./acc. pl.
            table.insert(outputlist,"domuī") -- dative sg.
            table.insert(outputlist,"domum") -- accusative sg.
            table.insert(outputlist,"domō") -- ablative sg.
            table.insert(outputlist,"domī") -- locative sg.
            table.insert(outputlist,"domōrum") -- genitive pl.
            table.insert(outputlist,"domuum") -- genitive pl.
            table.insert(outputlist,"domibus") -- dative/ablative pl.
            table.insert(outputlist,"domōs") -- accusative pl.
         elseif firstField == "arcus" or firstField == "artus"
         or firstField == "tribus" then
            attachEndings(root,nounEndings4_us_ubus)
         else
            attachEndings(root,nounEndings4_us)
         end
      elseif endsIn(firstField,"ūs") then -- plurale tantum
         root = utf8substring(firstField,1,-3)
         attachEndings(root,nounEndings4_us_plural)
      else
         invalidField(firstField)
      end

   -- neuter noun of the fourth declension
   elseif secondField == "D4N" then
      if thirdField or fourthField then
         invalidLine()
      elseif endsIn(firstField,"ū") then
         root = string.sub(firstField,1,-3)
         attachEndings(root,nounEndings4_u)
      else
         invalidField(firstField)
      end

   -- masculine/feminine noun of the fifth declension
   elseif secondField == "D5" then
      if utf8.len(firstField) < 3 or thirdField or fourthField then
         invalidLine()
      elseif endsIn(firstField,"ēs") then
         root = utf8substring(firstField,1,-3)
         if vowels[utf8substring(firstField,-3,-3)] then
            attachEndings(root,nounEndings5_afterVowel)
         else
            attachEndings(root,nounEndings5)
         end
      else
         invalidField(firstField)
      end

   -- adjective with three endings with comparison
   elseif secondField == "AC3" then
      if fourthField then
         invalidLine()
      else
         generatePositiveForms3(firstField,thirdField)
         generateAdverb3(firstField,thirdField)
         generateComparativeAndSuperlative3(firstField,thirdField)
      end

   -- adjective with two endings with comparison
   elseif secondField == "AC2" then
      if thirdField or fourthField then
         invalidLine()
      else
         generatePositiveForms2(firstField)
         generateAdverb2(firstField)
         generateComparativeAndSuperlative2(firstField)
      end

   -- adjective with one ending with comparison
   elseif secondField == "AC1" then
      if fourthField then
         invalidLine()
      else
         generatePositiveForms1(firstField,thirdField)
         generateAdverb1(firstField,thirdField)
         generateComparativeAndSuperlative1(firstField,thirdField)
      end

   -- adjective with three endings without comparison
   elseif secondField == "AI3" then
      if fourthField then
         invalidLine()
      else
         generatePositiveForms3(firstField,thirdField)
         generateAdverb3(firstField,thirdField)
      end

   -- adjective with two endings without comparison
   elseif secondField == "AI2" then
      if thirdField or fourthField then
         invalidLine()
      else
         generatePositiveForms2(firstField)
         generateAdverb2(firstField)
      end

   -- adjective with one ending without comparison
   elseif secondField == "AI1" then
      if fourthField then
         invalidLine()
      else
         generatePositiveForms1(firstField,thirdField)
         generateAdverb1(firstField,thirdField)
      end

   -- numeral
   elseif secondField == "N" then
      if thirdField or fourthField then
         invalidLine()
      elseif firstField == "ūnus" then
         attachEndings("ūn",pronominalAdjectiveEndings)
         -- the plural forms are used for some pluralia tantum
      elseif firstField == "duo" then
         table.insert(outputlist,"duo") -- nominative masc./neuter
         attachEndings("du",endings_o_ae)
      elseif firstField == "trēs" then
         attachEndings("tr",adjectiveEndings_es_ium)
      elseif firstField == "mīlle" then
         table.insert(outputlist,"mīlle") -- singular
         table.insert(outputlist,"mīlia") -- nom./acc. plural
         table.insert(outputlist,"mīlium") -- gen. plural
         table.insert(outputlist,"mīlibus") -- dat/abl. plural
      elseif endsIn(firstField,"us") then
         root = utf8substring(firstField,1,-3)
         attachEndings(root,adjectiveEndings_us_a_um)
      elseif endsIn(firstField,"ī") then
         root = utf8substring(firstField,1,-2)
         attachEndings(root,adjectiveEndings_i_ae_a)
      else
         invalidField(firstField)
      end

   -- invalid line
   else
      invalidLine()
   end
end

for _,word in pairs(outputlist) do
   print(word)
end
