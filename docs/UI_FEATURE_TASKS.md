# Oxide Editor UI Progress

Integration branch: `UI/main`

All UI feature branches are created from `UI/main` and merged back only after their implementation, tests, and self-review pass.

## Status legend

- `[ ]` Not started
- `[~]` In progress
- `[x]` Complete and merged into `UI/main`

## Feature tasks

### UI-01 — Violet semantic accent

- [ ] Add semantic violet accent tokens and accessible variants.
- [ ] Replace editor-specific orange selection and primary-action styling.
- [ ] Verify light, dark, monochrome, increased-contrast, and reduced-transparency states.
- [ ] Branch: `UI/violet-accent`

### UI-02 — Filter pack domain model

- [ ] Introduce non-overlapping thematic filter sections.
- [ ] Keep Original as a standalone option.
- [ ] Derive a section thumbnail from its selected filter or first filter fallback.
- [ ] Derive section selection and collapsed-state checkmark behavior.
- [ ] Cover empty packs, unknown filter IDs, Original, and selection changes with unit tests.
- [ ] Branch: `UI/filter-sections`

### UI-03 — Sectioned filter navigation

- [ ] Add the compact horizontal section rail.
- [ ] Expand only one section into a horizontal filter rail.
- [ ] Collapse the active section when tapped again.
- [ ] Preserve the expanded section while switching editing tools.
- [ ] Show selected filter and parent-section indicators independently.
- [ ] Show intensity only for non-Original filters.
- [ ] Branch: `UI/filter-navigation`

### UI-04 — Full-canvas editor foundation

- [ ] Extend the preview beneath floating editor controls.
- [ ] Keep navigation actions readable over bright and dark photographs.
- [ ] Preserve zoom, pan, crop, and spatial-effect coordinate behavior.
- [ ] Respect safe areas and all supported image aspect ratios.
- [ ] Add geometry and state-transition tests where applicable.
- [ ] Branch: `UI/editor-foundation`

### UI-05 — Floating tool controls

- [ ] Convert the tool picker and active tool content to compact floating materials.
- [ ] Keep a stable panel height while filters change.
- [ ] Provide Reduce Transparency and Increased Contrast fallbacks.
- [ ] Maintain 44-point minimum touch targets and VoiceOver labels.
- [ ] Branch: `UI/floating-controls`

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

