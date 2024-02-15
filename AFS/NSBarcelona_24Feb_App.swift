
import SwiftUI

@main
struct NSBarcelona_24Feb_App: App {
  var body: some Scene {
    WindowGroup {
      BookList.Async(urlSession: .shared)
    }
  }
}

// MARK: Common code

struct Book: Identifiable, Decodable {
  
  let id: UUID
  let title: String
  let authors: [String]
  
  enum CodingKeys: String, CodingKey {
    case id
    case title
    case authors = "author_name"
  }
  
  init(from decoder: Decoder) throws {
    let container: KeyedDecodingContainer<Book.CodingKeys> = try decoder.container(keyedBy: Book.CodingKeys.self)
    self.id = UUID()
    self.title = try container.decode(String.self, forKey: Book.CodingKeys.title)
    self.authors = (try? container.decode([String].self, forKey: Book.CodingKeys.authors)) ?? []
  }
  
  init(id: UUID, title: String, authors: [String]) {
    self.id = id
    self.title = title
    self.authors = authors
  }
}

extension Array where Element == Book {
  static func mock() -> Self {
    [
      .init(id: UUID(), title: "El Quijote", authors: ["Miguel Cervantes"]),
      .init(id: UUID(), title: "La Divina Commedia", authors: ["Dante Alighieri"]),
      .init(id: UUID(), title: "Romeo and Juliette", authors: ["William Shakespeare"]),
      .init(id: UUID(), title: "The Odyssey", authors: ["Homer"]),
      .init(id: UUID(), title: "Confessions", authors: ["Agustine of Hippo"]),
      .init(id: UUID(), title: "The Prince", authors: ["Niccoló Macchiavelli"]),
    ]
  }
}

extension URLSession {
  
  struct Root: Decodable {
    let docs: [Book]
  }

  func fetchBooks() async throws -> [Book] {
    let request: URLRequest = {
      guard var URL = URL(string: "https://openlibrary.org/search.json") else { fatalError() }
      URL.append(queryItems: [
        .init(name: "q", value: "swiftui")
      ])
      var request = URLRequest(url: URL)
      request.httpMethod = "GET"
      return request
    }()
    let response = try await URLSession.shared.data(for: request).0
    let root = try JSONDecoder().decode(Root.self, from: response)
    return root.docs
  }
}
