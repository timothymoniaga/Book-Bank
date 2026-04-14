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
                    NavigationLink(destination: WordDetails(word: word)) {
                        HStack(alignment: .bottom) {
                            Text(word.word + ": ")
                                .font(.system(size: 16, weight: .bold))
                            Text(word.mainDefinition)
                                .font(.system(size: 13, weight: .light))
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .onDelete(perform: deleteItems)
            }
            .scrollContentBackground(.hidden)
            .background(Color.bookBackground.ignoresSafeArea())
            .navigationDestination(for: String.self) { value in
                AddWordView(path: $path)
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        path.append("add")
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Word Bank")
                        .font(.headline)
                        .foregroundStyle(Color.bookText)
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
        VStack {
            Text(word.mainDefinition)
        
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(word.word)
                    .font(.headline)
                    .foregroundStyle(Color.bookText)
            }
        }
        .background(Color.bookBackground).ignoresSafeArea()


    }
}

struct AddWordView: View {
    @StateObject private var viewModel = AddWordViewModel()
    @Binding var path: NavigationPath
    @Environment(\.modelContext) private var context

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                TextField("Search for definition", text: $viewModel.query)
                    .padding()
                    .submitLabel(.search)
                    .onSubmit {
                        viewModel.getMainDefinitions()
                    }
                    .foregroundStyle(Color.bookText)

                Button {
                    viewModel.getMainDefinitions()
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.bookAccent)
                }
                .padding()
            }
            .background(Color.bookPaper)
            .cornerRadius(8)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(viewModel.sortedPartsOfSpeech), id: \.self) { partOfSpeech in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(partOfSpeech.capitalized)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(Color.bookAccent)

                            let definitions = viewModel.mainDefinitions[partOfSpeech] ?? []

                            ForEach(definitions.indices, id: \.self) { index in
                                let definition = definitions[index]

                                Text(definition)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .foregroundStyle(Color.bookText)
                                    .background(
                                        viewModel.selectedDefinition == definition
                                        ? Color.bookPaper
                                        : Color.clear
                                    )
                                    .contentShape(Rectangle())
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        viewModel.selectedDefinition = definition
                                    }

                                if index < definitions.count - 1 {
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding(4)
                    .background(Color.bookCard)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

            }

            Button("Add Word") {
                viewModel.addWord(context: context)
                path.removeLast()
            }
            .disabled(viewModel.selectedDefinition == nil)
            .opacity(viewModel.selectedDefinition == nil ? 0.5 : 1)
            .foregroundStyle(Color.bookButton)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.bookBackground)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Word.self, inMemory: true)
}
