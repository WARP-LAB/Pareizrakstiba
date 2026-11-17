# 0001. Word charset: alphanumerics and dot

I'm currently rethinking my OG algo described below, as there might be a better way to manage abbreviation case. Anywys, currently it is as described below.

Word scanning uses a character set to decide what a "word" is, and two things pull in opposite directions:

- "-" is not set as part of word, although lv_LV.aff specifies "WORDCHARS -", only few in dic like those
- Latvian diacritics are typed via the `'` (apostrophe) dead key, so missing the key produces misspellings like `garumz;ime` — common in the wild.
- Words arrive glued to sentence punctuation: `garumz;ime...`

**Alphanumerics plus `.`**

Consequence: `garumz;ime` is two words, not one misspelled word. That's fine — it gets flagged (twice), is never suggested as correct, and flagging is correct behavior anyway. For user mby bit hard to fix.

The alternatives I considered:
- allow everything except whitespace, and at scan time strip trailing non-alphanumerics, so `garumz;ime...` → `garumz;ime` as one token and hunspell could suggest the joined form. Haven't tested it, but it seems expensive — every token gets per-token punctuation analysis on the spell-as-you-type hot path, which re-checks every word on each keystroke. Not worth it until proven otherwise.

`.` is included so abbreviations and decimals don't cut the word short (`u.tml.`). introduces undesired behaviour though if abbrevation itslef was mispelled.

If revisiting: the change is local to `wordCharSet` construction and the scanning loop in `spellServer:findMisspelledWordInString:...`. Benchmark on the per-keystroke path before accepting.
