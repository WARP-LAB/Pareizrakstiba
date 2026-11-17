# 0004. Suggest completions use suggestGuessesForWord

I will use array that's returned by suggestGuessesForWord. However it is a suggestion list for the right spelling of the current partialy completed world, not a suggstion for competion! There's a difference!

```objc
  // reuse suggestGuessesForWord which returns an array of words
  return [self spellServer:sender suggestGuessesForWord:string inLanguage:language];
```

- Get the partial range
- Make string comparisons, to remove those words from `suggestGuessesForWord` returned array, which don't appear to be completions
- make completionsList to hold all suggestGuessesForWord array values
  - check all completionsList array
    - if a word in completionsList at index does not start with the same characters (and also that the characters are ordered the same) as the current range for inString, then this isn't going to be a completion, thus remove it from the array
    - accordingly to apple docs this should be faster than hasPrefix (`if (![[completionsList objectAtIndex:i] hasPrefix:rangeString])`)(quote: "can speed some operations dramatically"), but wee need extra range check. whatever.
