# Oxide Editor UI Progress

Integration branch: `UI/main`

All UI feature branches are created from `UI/main` and merged back only after their implementation, tests, and self-review pass.

## Status legend

- `[ ]` Not started
- `[~]` In progress
- `[x]` Complete and merged into `UI/main`

## Feature tasks

### UI-01 — Violet semantic accent

- [x] Add semantic violet accent tokens and accessible variants.
- [x] Replace the existing shared orange action and selection token.
- [x] Verify the palette compiles for the iOS Simulator target; broader photo-state visual QA remains in UI-07.
- [x] Branch: `UI/violet-accent`

### UI-02 — Filter pack domain model

- [x] Introduce non-overlapping thematic filter sections.
- [x] Keep Original as a standalone option.
- [x] Derive a section thumbnail from its selected filter or first filter fallback.
- [x] Derive section selection and collapsed-state checkmark behavior.
- [x] Cover empty packs, unknown filter IDs, Original, and selection changes with unit tests.
- [x] Branch: `UI/filter-sections`

### UI-03 — Sectioned filter navigation

- [x] Add the compact horizontal section rail.
- [x] Expand only one section into a horizontal filter rail.
- [x] Collapse the active section when tapped again.
- [x] Preserve the expanded section while switching editing tools.
- [x] Show selected filter and parent-section indicators independently.
- [x] Show intensity only for non-Original filters.
- [x] Branch: `UI/filter-navigation`

### UI-04 — Full-canvas editor foundation

- [x] Extend the preview beneath floating editor controls.
- [x] Keep navigation actions readable over bright and dark photographs.
- [x] Preserve zoom, pan, crop, and spatial-effect coordinate behavior.
- [x] Respect safe areas and all supported image aspect ratios.
- [x] Retain the existing viewport, crop geometry, and spatial-effect tests.
- [x] Branch: `UI/editor-foundation`

### UI-05 — Floating tool controls

- [x] Convert the tool picker and active tool content to compact floating materials.
- [x] Keep a stable panel height while filters change.
- [x] Provide Reduce Transparency and Increased Contrast fallbacks.
- [x] Maintain 44-point minimum touch targets and VoiceOver labels.
- [x] Branch: `UI/floating-controls`

### UI-06 — Press-to-compare

- [ ] Hide floating controls after approximately 0.2 seconds of continuous press.
- [ ] Restore controls on release with a short fade.
- [ ] Disable comparison while crop or spatial-effect positioning owns the gesture.
- [ ] Preserve pinch, pan, and double-tap zoom behavior.
- [ ] Add an accessible explicit show/hide-controls action.
- [ ] Cover gesture eligibility and visibility transitions with unit tests.
- [ ] Branch: `UI/press-to-compare`

### UI-07 — Integration, performance, and visual QA

- [ ] Profile thumbnail rendering, cancellation, allocations, and scrolling.
- [ ] Confirm only the expanded section renders filter thumbnails.
- [ ] Run the complete Swift test suite and iOS build.
- [ ] Verify representative portrait, landscape, bright, dark, and monochrome photos.
- [ ] Complete architecture, performance, memory, concurrency, Metal, StoreKit, and testing self-review.
- [ ] Update editor screenshots and merge final fixes into `UI/main`.
- [ ] Branch: `UI/editor-integration`

## Progress log

| Date | Task | Status | Notes |
| --- | --- | --- | --- |
| 2026-08-20 | UI workflow setup | Complete | Created the `UI/main` integration branch and this tracker. |
| 2026-08-20 | UI-01 Violet semantic accent | Complete | Added semantic violet tokens and passed the Oxide iOS Simulator build. |
| 2026-08-22 | UI-02 Filter pack model | Complete | Added thematic catalog and edge-case tests; Gallery iOS Simulator build passed. |
| 2026-08-22 | UI-03 Sectioned navigation | Complete | Added lazy category/filter rails with persistent selection indicators; app build passed. |
| 2026-08-22 | UI-04 Full-canvas foundation | Complete | Preview extends behind safe-area-aware editor chrome; app build passed. |
| 2026-08-22 | UI-05 Floating controls | Complete | Added stable floating panels with transparency/contrast fallbacks; app build passed. |
