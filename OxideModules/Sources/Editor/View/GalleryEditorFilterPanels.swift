// Copyright (c) 2025 and Confidential to SoftFusion All rights reserved.

import SwiftUI
import UIComponents

struct GalleryEditorFilterPanels: View {
    @ObservedObject var presenter: EditorPresenter
    @Binding var expandedSectionID: String?

    var body: some View {
        VStack(spacing: 10) {
            if let expandedSection {
                FloatingControlPanel {
                    VStack(spacing: 8) {
                        if expandedSection.contains(filterID: presenter.draft.selectedFilterID) {
                            LabeledValueSlider(
                                title: "Intensity",
                                value: presenter.draft.filterIntensity,
                                range: 0...1,
                                valueText: "\(Int(presenter.draft.filterIntensity * 100))",
                                onChange: presenter.setFilterIntensity,
                                onChangeEnded: { Task { await presenter.commitFilterIntensity() } }
                            )
                            .padding(.horizontal, 16)
                        }

                        GalleryExpandedFilterRail(
                            section: expandedSection,
                            selectedFilterID: presenter.draft.selectedFilterID,
                            imageURL: presenter.draft.asset.imageURI,
                            onSelectFilter: { filter in Task { await presenter.selectFilter(filter.id) } }
                        )
                    }
                    .padding(.vertical, 8)
                }
            }

            FloatingControlPanel {
                GalleryFilterSectionBar(
                    catalog: presenter.filterCatalog,
                    selectedFilterID: presenter.draft.selectedFilterID,
                    expandedSectionID: expandedSectionID,
                    onSelectOriginal: selectOriginal,
                    onToggleSection: toggleSection
                )
//                .padding(.horizontal, 8)
            }
        }
        .onAppear(perform: revealSelectedSection)
    }

    private var expandedSection: GalleryFilterSection? {
        presenter.filterCatalog.sections.first { $0.id == expandedSectionID }
    }

    private func revealSelectedSection() {
        guard expandedSectionID == nil else { return }
        expandedSectionID = presenter.filterCatalog
            .section(containing: presenter.draft.selectedFilterID)?.id
            ?? presenter.filterCatalog.sections.first?.id
    }

    private func selectOriginal() {
        expandedSectionID = nil
        Task { await presenter.selectFilter(GalleryFilter.original.id) }
    }

    private func toggleSection(_ section: GalleryFilterSection) {
        withAnimation(.easeInOut(duration: 0.18)) {
            expandedSectionID = expandedSectionID == section.id ? nil : section.id
        }
    }
}
