
import SwiftUI

#Preview {
  BookList(dataModel: .init(books: .mock()))
}

struct BookList: View {
  
  @ObservedObject var dataModel: DataModel
  
  var body: some View {
    List(dataModel.books, id: \.id) { book in
      VStack(alignment: .leading) {
        Text(book.title)
          .foregroundStyle(.primary)
        Text(ListFormatter.localizedString(byJoining: book.authors))
          .foregroundStyle(.secondary)
      }
    }
  }
  
  struct Async: View {
    
    let urlSession: URLSession
    
    var body: some View {
      AsyncView(
        id: "book-list",
        dataGenerator: {
          try await DataModel(urlSession: urlSession)
        },
        hostedViewGenerator: {
          BookList(dataModel: $0)
        }, errorViewGenerator: {
          AsyncStatePlainErrorView(error: $0, onRetry: $1)
        }, loadingViewGenerator: {
            ProgressView()
        }
      )
    }
  }

  @MainActor
  class DataModel: ObservableObject {
    
    @Published var books: [Book]
    
    init(books: [Book]) {
      self.books = books
    }

    init(urlSession: URLSession) async throws {
      self.books = try await urlSession.fetchBooks()
    }
  }
}

extension BookList: PlaceholderDataProvider {
  static func generatePlaceholderData() -> DataModel {
    .init(books: .mock())
  }
}
