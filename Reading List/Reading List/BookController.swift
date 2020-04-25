//
//  BookController.swift
//  Reading List
//
//  Created by Dawn Jones on 4/24/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class BookController {
    init() {
        self.loadFromPersistentStore()
    }
    
    private(set) var books: [Book] = []
    
    private var readingListURL: URL? {
        let fm = FileManager.default
        guard let directory = fm.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return directory.appendingPathComponent("ReadingList.plist")
    }
    
    var readBooks: [Book] {
        var bookArray: [Book] = []
        for book in books {
            if book.hasBeenRead {
                bookArray.append(book)
            }
        }
        return bookArray
    }
    
    var unreadBooks: [Book] {
        var bookArray: [Book] = []
        for book in books {
            if !book.hasBeenRead {
                bookArray.append(book)
            }
        }
        return bookArray
    }
    
    private func saveToPersistentStore() {
        guard let url = readingListURL else { return }
        
        do {
            let encoder = PropertyListEncoder()
            let booksData = try encoder.encode(books)
            try booksData.write(to: url)
        } catch {
            NSLog("Error saving books data: \(error)")
        }
    }
    
    private func loadFromPersistentStore() {
        let fm = FileManager.default
        guard let url = readingListURL,
            fm.fileExists(atPath: url.path) else { return }
        
        // Plist file -> Data -> Stars
        
        do {
            let booksData = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            let decodedBooks = try decoder.decode([Book].self, from: booksData)
            books = decodedBooks
        } catch {
            NSLog("Error loading books data: \(error)")
        }
    }
    
    @discardableResult func createBook(title: String, reasonToRead: String) -> Book {
        let book = Book(title: title, reasonToRead: reasonToRead)
        books.append(book)
        self.saveToPersistentStore()
        return book
    }
    
    func deleteBook(book: Book) {
        guard let bookIndex = books.index(of: book) else { return }
        books.remove(at: bookIndex)
        self.saveToPersistentStore()
    }
    
    func updateHasBeenRead(for book: Book) {
        guard let bookIndex = books.index(of: book) else { return }
        books[bookIndex].hasBeenRead = !books[bookIndex].hasBeenRead
        self.saveToPersistentStore()
    }
    
    func updateBookData(for book: Book, title: String, reasonToRead: String) {
        guard let bookIndex = books.index(of: book) else { return }
        books[bookIndex].title = title
        books[bookIndex].reasonToRead = reasonToRead
        self.saveToPersistentStore()
    }
}