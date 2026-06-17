#import "@preview/conch:0.1.0": system, terminal

#let _win-btn(content, f, fg, bg: none) = box(
  fill: bg,
  width: 32pt,
  height: 22pt,
  align(center + horizon, text(..f, fill: fg, size: 14pt)[#content]),
)

#let _tab-close-btn(content, f, fg, bg: none) = box(
  fill: bg,
  height: 1pt,
  align(bottom, text(..f, fill: fg, size: 14pt)[#content]),
)

#show: terminal.with(
  system: system(
    hostname: "andyleclair.dev",
    files: (
      "header.txt": "
<%= ascii_big_text %>

That's right, <%= url %>
",
    ),
  ),
  user: "andy",
  height: 630pt,
  width: 1200pt,
  font: (size: 14pt),
  chrome: (
    bar: (title, theme, font) => block(
      fill: theme.title-bg,
      width: 100%,
      {
        h(10pt)
        box(
          inset: (top: 5pt),
          {
            box(
              fill: theme.bg,
              radius: (top-left: 5pt, top-right: 5pt),
              inset: (x: 14pt, y: 8pt),
              {
                if title != "" {
                  text(..font, fill: theme.title-fg, size: 14pt)[#title]
                }
                h(10pt)
                _tab-close-btn([\u{2715}], font, white)
              },
            )
          },
        )
        h(1fr)
        box(
          baseline: -5pt,
          {
            _win-btn([\u{2500}], font, theme.title-fg)
            _win-btn([\u{2750}], font, theme.title-fg)
            _win-btn([\u{2715}], font, theme.title-fg)
          },
        )
      },
    ),
    radius: (top: 5pt, bottom: 5pt),
  ),
  theme: (
    bg: rgb("#000000"),
    fg: rgb("#FFFFFF"),
    prompt-user: rgb("#75507B"),
    prompt-path: rgb("#729FCF"),
    prompt-sym: rgb("#D3D7CF"),
    title-bg: rgb("#555753"),
    title-fg: rgb("#EEEEEC"),
    error: rgb("#CC0000"),
    cursor: rgb("#D3D7CF"),
    ansi: (
      red: rgb("#CC0000"),
      green: rgb("#4E9A06"),
      yellow: rgb("#C4A000"),
      blue: rgb("#3465A4"),
      magenta: rgb("#75507B"),
      cyan: rgb("#06989A"),
      white: rgb("#D3D7CF"),
      bright-red: rgb("#EF2929"),
      bright-green: rgb("#8AE234"),
      bright-yellow: rgb("#FCE94F"),
      bright-blue: rgb("#729FCF"),
      bright-magenta: rgb("#AD7FA8"),
      bright-cyan: rgb("#34E2E2"),
      bright-white: rgb("#EEEEEC"),
    ),
  ),
)

```
cat header.txt
```

