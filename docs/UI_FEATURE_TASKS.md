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

- [x] Hide floating controls after approximately 0.2 seconds of continuous press.
- [x] Restore controls on release with a short fade.
- [x] Disable comparison while crop or spatial-effect positioning owns the gesture.
- [x] Preserve pinch, pan, and double-tap zoom behavior.
- [x] Add an accessible explicit show/hide-controls action.
- [x] Cover gesture eligibility and visibility transitions with unit tests.
- [x] Branch: `UI/press-to-compare`

### UI-07 — Integration, performance, and visual QA

- [~] Profile thumbnail rendering, cancellation, allocations, and scrolling. Static review and cancellation are complete; Instruments needs a manual photo session.
- [x] Confirm only the expanded section renders filter thumbnails.
- [~] Run the complete Swift test suite and iOS build. Build/analyze pass; checked-in test configuration exposes no runnable bundle.
- [~] Verify representative portrait, landscape, bright, dark, and monochrome photos. Concept review is complete; runtime editor review needs manual navigation.
- [x] Complete architecture, performance, memory, concurrency, Metal, StoreKit, and testing self-review.
- [~] Update editor screenshots and merge final fixes into `UI/main`. Installed-app smoke test passed; editor screenshot awaits manual editor access.
- [x] Branch: `UI/editor-integration`

### UI-08 — Adaptive tool-panel sizing

- [x] Remove the global fixed panel height that leaves empty space around compact tools.
- [x] Size Filters to its collapsed, selected, and expanded content states.
- [x] Let Adjust, Crop, and Rotate wrap their intrinsic content with compact padding.
- [x] Preserve the Effects panel height required by its carousel and advanced scrolling.
- [x] Branch: `UI/adaptive-tool-panels`

### UI-09 — Filter panel intrinsic height

- [x] Bound the horizontal category rail to its compact content height.
- [x] Bound the expanded filter rail independently from the parent panel.
- [x] Let the filter card equal the sum of only its visible rows.
- [x] Branch: `UI/filter-panel-intrinsic-height`

### UI-10 — Filter concept alignment and contrast

- [x] Use dark charcoal floating materials so labels remain readable over bright photos.
- [x] Separate filter previews and filter categories into distinct floating panels.
- [x] Replace category thumbnails with the approved compact text strip.
- [x] Preserve violet parent-category and selected-filter indicators.
- [x] Reveal the applied section, or Cinematic by default, when entering Filters.
- [x] Branch: `UI/filter-concept-alignment`

### UI-11 — Liquid Glass controls

- [x] Apply native interactive Liquid Glass to floating editor surfaces on iOS 26.
- [x] Tint glass dark enough to preserve the approved text contrast.
- [x] Retain dark material on iOS 16–25 and an opaque Reduce Transparency fallback.
- [x] Preserve Increased Contrast borders and existing touch targets.
- [x] Branch: `UI/liquid-glass-controls`

### UI-12 — Liquid Glass surface consistency

- [x] Give photo-backed panels the same dark base as panels floating over the editor background.
- [x] Preserve native Liquid Glass response without allowing bright photos to wash out the surface.
- [x] Verify existing material and accessibility fallbacks remain unchanged.
- [x] Branch: `UI/liquid-glass-surface-consistency`

## Progress log

| Date | Task | Status | Notes |
| --- | --- | --- | --- |
| 2026-08-20 | UI workflow setup | Complete | Created the `UI/main` integration branch and this tracker. |
| 2026-08-20 | UI-01 Violet semantic accent | Complete | Added semantic violet tokens and passed the Oxide iOS Simulator build. |
| 2026-08-22 | UI-02 Filter pack model | Complete | Added thematic catalog and edge-case tests; Gallery iOS Simulator build passed. |
| 2026-08-22 | UI-03 Sectioned navigation | Complete | Added lazy category/filter rails with persistent selection indicators; app build passed. |
| 2026-08-22 | UI-04 Full-canvas foundation | Complete | Preview extends behind safe-area-aware editor chrome; app build passed. |
| 2026-08-22 | UI-05 Floating controls | Complete | Added stable floating panels with transparency/contrast fallbacks; app build passed. |
| 2026-08-22 | UI-06 Press-to-compare | Complete | Added 0.2-second comparison, conflict gating, accessibility action, and tests; build passed. |
| 2026-08-22 | UI-07 Integration QA | Partial | Implementation is ready to merge; manual editor profiling/screenshots and test-scheme repair remain recorded. |
| 2026-08-22 | UI-08 Adaptive panels | Complete | Compact tools use intrinsic sizing; Effects retains its bounded height; app build passed. |
| 2026-08-22 | UI-09 Filter height | Complete | Category and expanded rails have independent compact heights; app build passed. |
| 2026-08-22 | UI-10 Concept alignment | Complete | Dark panels, preview/category hierarchy, and high-contrast labels now match the approved concept; build passed. |
| 2026-08-22 | UI-11 Liquid Glass | Complete | Native interactive glass, compatibility fallback, and accessibility surfaces added; build passed. |
| 2026-08-24 | UI-12 Glass consistency | Complete | Added a shared dark glass base so photo-backed and background-backed panels match; build passed. |
