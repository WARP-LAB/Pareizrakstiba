# 0003. Learn/Ignore Spelling — OS-level user dictionary, not hunspell's

When user chooses to "Learn Spelling" for a word OSX automatically adds it to user dictionary, located at `~/Library/Spelling/<langid>`.
It works and word isn't spelled any more.

When user chooses to "Ignore Spelling" no word is added to user dictionary, the word is kept in "memory" and only while document containing the word is loaded.

I see no need to use Hunspell method of adding word to the run-time dictionary, as it is managed in OS level and won't be passed here anyways
`myHS->add([word UTF8String]);`
