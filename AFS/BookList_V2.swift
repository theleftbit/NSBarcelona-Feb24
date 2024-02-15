
import SwiftUI

#Preview {
  BookList_V2(urlSession: .shared)
}

struct BookList_V2: View {
  
  let urlSession: URLSession
  @State var loadingPhase = LoadingPhase.loading
  
  enum LoadingPhase {
    case loading
    case loaded(DataModel)
    case failed(Swift.Error)
  }
  
  var body: some View {
    contentView
    .task {
      self.loadingPhase = .loading
      do {
        let dataModel = try await DataModel(urlSession: urlSession)
        self.loadingPhase = .loaded(dataModel)
      } catch {
        self.loadingPhase = .failed(error)
      }
    }
  }
  
  @MainActor
  @ViewBuilder
  private var contentView: some View {
    switch loadingPhase {
    case .loading:
      ProgressView()
    case .failed(let error):
      AsyncStatePlainErrorView(error: error, onRetry: {})
    case .loaded(let dataModel):
      BookList(dataModel: dataModel)
    }
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
