# the diagrams paint their own background.

**2026-08-22**

A forge swaps
its mermaid theme with the page theme, so a diagram that inherits colours
is legible in one theme and not the other. Each diagram fixes its own
background, node fill, text and line colours, and therefore renders
identically in both. The surface is dark and the arrows are white, in that
order — white arrows alone would fix dark mode by making the diagram
vanish in light mode, but once the diagram owns its background that
objection disappears. Rejected: styling the arrows without setting a
background, which is the version of this fix that only works on the theme
its author happened to be using.
