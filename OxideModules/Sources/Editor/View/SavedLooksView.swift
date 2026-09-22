import SwiftUI
import UIComponents

struct SavedLooksView: View {
    @ObservedObject var presenter: SavedLooksPresenter
    @FocusState private var isNameFocused: Bool

    private var isBusy: Bool { presenter.isBusy }
    private var galleryColumns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text(presenter.isNamingLook ? "Save look" : "My Looks")
                    .font(.title2.weight(.semibold))
                Spacer()
                Button(presenter.isNamingLook ? "Cancel" : "Done", action: presenter.close)
                    .frame(minHeight: 44)
                    .disabled(isBusy)
            }

            if presenter.isNamingLook {
                namingForm
            } else if presenter.loadState == .loading {
                Spacer()
                ProgressView("Loading looks…")
                Spacer()
            } else if presenter.loadState == .loaded {
                library
            } else {
                Spacer()
                Button("Try again") { Task { await presenter.load() } }
                Spacer()
            }

            if let error = presenter.errorMessage {
                Text(error)
                    .font(.callout)
                    .foregroundStyle(AppColours.appDestructiveColor)
                    .accessibilityAddTraits(.updatesFrequently)
            }
        }
        .padding(20)
        .foregroundStyle(AppColours.appForegroundColor)
        .tint(AppColours.accent)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColours.appColor.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .interactiveDismissDisabled(isBusy)
        .task { await presenter.load() }
    }

    private var namingForm: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Filter and intensity, adjustments, and effects. Crop and rotation are not included.")
                    .font(.callout)
                    .foregroundStyle(AppColours.appMutedForegroundColor)
                TextField("Look name", text: $presenter.name)
                    .textFieldStyle(.roundedBorder)
                    .focused($isNameFocused)
                    .submitLabel(.done)
                    .onSubmit(saveLook)
                    .disabled(isBusy)
                Button(action: saveLook) {
                    HStack {
                        if presenter.operation == .saving { ProgressView() }
                        Text(presenter.operation == .saving ? "Saving…" : "Save look")
                    }
                    .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!presenter.canSave)
            }
        }
    }

    private var library: some View {
        ScrollView {
            if presenter.looks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "square.stack").font(.largeTitle)
                    Text("No saved looks yet").font(.headline)
                    Text("Save this photo’s look to use it on your next edit.")
                        .foregroundStyle(AppColours.appMutedForegroundColor)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)

                LazyVGrid(columns: galleryColumns, spacing: 12) {
                    saveCurrentLookTile
                }
            } else {
                LazyVGrid(columns: galleryColumns, spacing: 12) {
                    ForEach(presenter.looks) { look in
                        lookTile(look)
                    }

                    saveCurrentLookTile
                }
            }
        }
    }

    private func lookTile(_ look: SavedLook) -> some View {
        let isSelected = look.applying(to: presenter.previewDraft) == presenter.previewDraft

        return Button {
            Task { await presenter.apply(look) }
        } label: {
            GeometryReader { geometry in
                ZStack(alignment: .bottomLeading) {
                    LUTPreviewImage(
                        imageURL: presenter.previewDraft.asset.imageURI,
                        presetID: look.filterID,
                        intensity: look.filterIntensity,
                        rotationDegrees: presenter.previewDraft.rotationDegrees,
                        crop: presenter.previewDraft.crop,
                        adjustments: look.adjustments,
                        effects: look.effects,
                        contentMode: .fill,
                        maxPixelSize: 320
                    )
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    .clipped()
                    .accessibilityHidden(true)

                    LinearGradient(
                        colors: [.clear, .black.opacity(0.72)],
                        startPoint: .center,
                        endPoint: .bottom
                    )

                    Text(look.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .padding(12)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 26)
                            .background(AppColours.accent, in: Circle())
                            .padding(10)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.width)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(isSelected ? AppColours.accent : Color.clear, lineWidth: 2)
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Apply look: \(look.name)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .disabled(isBusy)
    }

    private var saveCurrentLookTile: some View {
        Button {
            presenter.beginNaming()
            isNameFocused = true
        } label: {
            GeometryReader { geometry in
                VStack(spacing: 9) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .medium))
                    Text("Save current")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(AppColours.appMutedForegroundColor)
                .frame(width: geometry.size.width, height: geometry.size.width)
                .background(AppColours.appSurfaceColor.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            AppColours.appMutedForegroundColor.opacity(0.55),
                            style: StrokeStyle(lineWidth: 1, dash: [6, 5])
                        )
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Save current look")
        .disabled(isBusy)
    }

    private func saveLook() {
        Task { await presenter.save() }
    }
}
