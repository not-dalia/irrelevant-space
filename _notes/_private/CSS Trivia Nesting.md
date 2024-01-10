---
created_at: 2024-01-06T03:45:46+0000
last_updated_at: 2024-01-06T03:45:46+0000
title: "CSS Nesting - The Good, the Bad and the Ugly"
type: note
topics:
  - Web development
  - CSS
---

good: no need for preprocessor, we can finally write CSS in CSS
bad: not supported by all browsers, and a preprocessor is better at support as it compiles to unnested CSS for now
ugly: the syntax can be weird, and nested elements starting with a letter aren't always supported because of the way the browser parses the CSS and to avoid slowing down the parsers, so you have to use the most pointless Pseudoclass selector [[CSS Trivia is|:is()]] to make it work
(okay maybe :is() isn't pointless, it's good for lists of selectors, but it's still ugly)

ideas:
- try to use with different browsers, see results
- try to inspect nested css in dev tools and see how it looks
- don't write detailed code examples, just assume knowledge of sass or so and give brief examples
- what happens if you use an unsupported browser? does it just ignore the nesting?
- what about document.styleSheets? does it show the nested selectors?
