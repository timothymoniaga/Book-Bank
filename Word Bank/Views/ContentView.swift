//
//  ContentView.swift
//  Word Bank
//
//  Created by Timothy moniaga on 12/4/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var path = NavigationPath()
    @Query private var words: [Word]
    
    @StateObject private var wordBankViewModel = WordBankViewModel()

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(words) { word in
                    NavigationLink(destination: WordDetails(word: word)){
                        Text(word.word)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {

                ToolbarItem {
                    Button() {
                        path.append("add")
                    } label: {
                        Image(systemName: "plus")
                    }
                    .navigationDestination(for: String.self) { value in
                            AddWordView()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Word Bank").font(.headline)
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(words[index])
            }
        }
    }
}

struct WordDetails: View {
    var word: Word
    
    var body: some View {
        Text(word.mainDefinition)
            .navigationTitle(word.word)
    }
}

struct AddWordView: View {
    @StateObject private var viewModel = AddWordViewModel()
    @Environment(\.modelContext) private var context

    let colourTest = Color(red: 0.93, green: 0.89, blue: 0.78)

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                TextField("Search for definition", text: $viewModel.query)
                    .padding()
                    .submitLabel(.search)
                    .onSubmit {
                        viewModel.getMainDefinitions()
                    }

                Button {
                    viewModel.getMainDefinitions()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.black)
                }
                .padding()
            }
            .background(colourTest)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(viewModel.sortedPartsOfSpeech), id: \.self) { partOfSpeech in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(partOfSpeech.capitalized)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            ForEach(viewModel.mainDefinitions[partOfSpeech] ?? [], id: \.self) { definition in
                                Text(definition)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .background(
                                        viewModel.selectedDefinition == definition
                                        ? Color.gray.opacity(0.3)
                                        : Color.clear
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        viewModel.selectedDefinition = definition
                                    }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button("Add Word") {
                viewModel.addWord(context: context)
            }
            .disabled(viewModel.selectedDefinition == nil)
            .opacity(viewModel.selectedDefinition == nil ? 0.5 : 1)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Word.self, inMemory: true)
}
