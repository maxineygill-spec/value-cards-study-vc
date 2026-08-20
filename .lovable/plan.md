# Values-Only Study

Remove the two-condition randomization so every participant always plays the value cards pathway. Nothing else about the game flow, trading logic, or data collection changes.

## What changes for the player

- Starting the study always deals from the 18-card values deck — no more 50/50 random assignment to the scenario/issue cards.
- Glossary screen always shows "The Values at Play" with the values intro text.
- Prioritize screen always shows the values wording ("Now, choose your top 3").
- The issue/scenario deck is no longer reachable anywhere in the app.

## Technical notes

- `useGameState.ts`: drop the random assignment in `startStudy` and lock the deck pool to `ALL_VALUES.slice(0, 18)`; keep `condition` fixed at `"values"` and `deck_version` at `"values-18"` so saved sessions and JSON exports keep the same shape.
- `Glossary.tsx` / `Sort.tsx`: remove the conditional copy branches and the `condition` prop, keeping the values text.
- `Index.tsx`: stop passing `condition` to those screens.
- `ResearcherView.tsx`: drop the issues-count stat and per-row condition split (all rows are now `values`); leave `condition` in the CSV export for compatibility with previously collected data.
- Leave `src/data/issues.ts` in place but unused so the deck can be reintroduced later; no database or schema changes.
