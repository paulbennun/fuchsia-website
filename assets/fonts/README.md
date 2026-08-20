# Typefaces

Both families are served from this origin. Nothing here is fetched from a third party.

| file | family | style | axes kept | bytes |
|---|---|---|---|---|
| `newsreader.woff2` | Newsreader | upright | `opsz` 14–72, `wght` 400–700 | 84,536 |
| `newsreader-italic.woff2` | Newsreader | italic | `wght` 400–700 (`opsz` pinned 30) | 41,940 |
| `inter.woff2` | Inter | upright | `wght` 400–700 (`opsz` pinned 14) | 31,004 |
| `inter-italic.woff2` | Inter | italic | `wght` 400–700 (`opsz` pinned 14) | 33,064 |

Newsreader keeps its optical-size axis because the serif runs from 15 px body copy to
76 px display heads. Its italic is pinned at `opsz` 30 — the only sizes it is set at are
a 22–32 px blockquote and one decorative glyph — which is worth 53 KB.

## Character coverage

Included:

```
U+0000-00FF                                   Basic Latin + Latin-1 Supplement
U+0131, U+0152-0153, U+02BB-02BC,
U+02C6, U+02DA, U+02DC                        the standard "latin" tail
U+2000-206F                                   General Punctuation, in full
U+20AC, U+2122, U+2212, U+2215                currency, trade mark, minus, division slash
U+FEFF, U+FFFD
U+2190-2193, U+2318, U+25BA                   Inter only: arrows, the command mark, the play pointer
```

General Punctuation is carried whole because the copy leans on it: the em dash appears
233 times, the right single quotation mark 99, and the CSS `content` for an open FAQ row
is `\2013`.

Deliberately dropped: Latin Extended (`U+0100-02BA` and the rest of the Google
"latin-ext" set), and every non-Latin script. No page uses a codepoint between U+00B7 and
U+2013.

`U+25B8` ▸ is absent from both families at source, so it cannot be subset in; it resolves
through the fallback stack, exactly as it did before.

## Sources and licence

Built from the variable originals vendored in Paul's own repositories:

- `fuchsia-llc-platform/assets/fonts/Newsreader[opsz,wght].ttf`
- `fuchsia-llc-platform/assets/fonts/Newsreader-Italic[opsz,wght].ttf`
- `fuchsia-llc-platform/assets/fonts/Inter[opsz,wght].ttf`
- `Integrity/IntegrityApp/Resources/Fonts/Inter-Italic-VariableFont.ttf`

Both are SIL Open Font License 1.1 — see `OFL-Newsreader.txt` and `OFL-Inter.txt`, which
travel with the files as the licence requires.

To rebuild, with `fonttools[woff]` and `brotli` installed:

```
UNI="U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,U+02DA,U+02DC,\
U+2000-206F,U+20AC,U+2122,U+2212,U+2215,U+FEFF,U+FFFD"
UI="$UNI,U+2190-2193,U+2318,U+25BA"

fonttools varLib.instancer -o tmp.ttf "Newsreader[opsz,wght].ttf" opsz=14:72 wght=400:700
pyftsubset tmp.ttf --unicodes="$UNI" --flavor=woff2 --output-file=newsreader.woff2
```

…and the same shape for the other three, with the axis pins from the table above.
