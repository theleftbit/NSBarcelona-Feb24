
import SwiftUI

#Preview {
  BookList_V1(dataModel: .init())
}

struct BookList_V1: View {
  
  @ObservedObject var dataModel: DataModel
  
  var body: some View {
    Group {
      if dataModel.isLoading {
        ProgressView()
      } else if let error = dataModel.error {
        AsyncStatePlainErrorView(error: error, onRetry: {})
      } else {
        List(dataModel.books, id: \.id) { book in
          VStack(alignment: .leading) {
            Text(book.title)
              .foregroundStyle(.primary)
            Text(ListFormatter.localizedString(byJoining: book.authors))
              .foregroundStyle(.secondary)
          }
        }
      }
    }
    .task {
      await dataModel.populateData()
    }
  }
  
  @MainActor
  class DataModel: ObservableObject {
    
    @Published var isLoading: Bool
    @Published var error: Swift.Error?
    @Published var books: [Book]
    
    init(isLoading: Bool = false, error: Error? = nil, books: [Book] = []) {
      self.isLoading = isLoading
      self.error = error
      self.books = books
    }

    func populateData() async {
      self.isLoading = true
      do {
        self.books = try await URLSession.shared.fetchBooks()
      } catch {
        self.error = error
      }
      self.isLoading = false
    }
  }
}
