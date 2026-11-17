# 0006. No misspelling found — INT_MAX instead of NSNotFound

TODO: have to recheck this in year 2026

If no misspelling was found, signal it with the largest value that survives the 32-bit NSPortCoder trip to the spell-checking client app:
`NSNotFound` is `NSIntegerMax` (LONG_MAX) in 64-bit, but client apps receive this range over the wire as a 32-bit value and log a truncation warning, so INT_MAX is returned instead: `return NSMakeRange (INT_MAX, 0);`
