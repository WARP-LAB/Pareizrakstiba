# 0002. "Unlearn Spelling" adds a duplicate — can't delete from user dic

When user chooses to "Unlearn Spelling" for a word OSX does it, using the same user dictionary, located at `~/Library/Spelling/<languageid>`.
The way it's done, is adding the word one more time to the dic.
It works and word isn't spelled any more.

However, as user dictionary at `~/Library/Spelling/<languageid>` will be used to contribute/submit new words to HunSpell aff&dic developer, there's a problem to solve. In the situation described above user would contribute word list with an incorrect word repeated twice, instead of not sending it at all.
We have to change this OSX behavior, and on "Unlearn Spelling" actually delete the word from user dic.
BUT - this methods description is incorrect - it's not "didForgetWord", burt "WILL!ForgetWord".
"Notifies the delegate that the sender has removed the specified word from the user's list of acceptable words in the specified language."
actually is
"Notifies the delegate that the sender IS GOING TO REMOVE (add second copy) the specified word from the user's list of acceptable words in the specified language."
Thus I cannot delete a word, that hasn't been written to user's dic yet.

That means that on contribute process the code will have to check for any duplicate words (which accordingly are unlearned (incorrect) words).

Note: No need to use Hunspell method of removing word from Hunspell's run-time dictionary, as we do not use it, we use OS'es
`myHS->remove([word UTF8String]);`
