---
title: Features I need to support
image: /assets/hypocycle.svg
draft: true
topics:
  - test
type: endeavor
---

A lot of what's mentioned in the [docs](https://help.obsidian.md/How+to/Format+your+notes)
also check [[Todo]] for more

```jekyll
test
```

Internal links can have three different formats:
-  `[[internal link]]`
-  `[internal link](internal_link.html)` - This one needs to be ==encoded== - Example: [A short poem](/A%20short%20poem.md)
-  `<a href="/internal_link.html">internal link</a>` - this one also needs to be ==encoded==

>[!Note] but now what
>Looks like obsidian doesn't support the `<a>` tags for internal links.

```
what about links inside codeblocks? [[Todo]]
```

![[This is a note#Questions]]

[internal link](internal-links.html)

hello
```
test
```

>[!test]
>this is a test
>what happens if there's a code `block` inline. Should be fine, right?
>what if it's a ``` triple block
>```
>looks like I can have nested code blocks here?
>```


```
>[!test]
>this is a test
```

> ```
> this is a test
> ```

<span style="color:red">
test [test](#test)
</span>

`````jekyll
```
```
test
`````

~~~~~~~~~~~~
test
~~~~~~~~~~~~

# hola

hola
==

[[Regular Expression Named Captures]]

![[32544547.jpg|100]]
