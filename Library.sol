// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.2 <0.9.0;

import "./Ownable.sol";

contract Library is Ownable {
    struct Book {
        uint isbn;
        uint copies;
        uint borrowed;
        address[] borrowers;
    }

    Book[] public books;

    mapping (address => mapping(uint => uint)) public personToBook;

    function addBook(uint _isbn, uint _copies) external onlyOwner {
        bool isbnExists = false;
        for (uint i = 0; i < books.length; i++) {
            if (books[i].isbn == _isbn) {
                isbnExists = true;
                break;
            }
        }
        require(isbnExists == false, "Book with this ISBN already exists");
        require(_copies > 0, "At least one copy of the books is required");

        Book memory book;
        book.isbn = _isbn;
        book.copies = _copies;
        book.borrowed = 0;

        books.push(book);
    }

    function borrowBook(uint _bookId) external {
        require(books[_bookId].borrowed < books[_bookId].copies, "Not enough copies");
        require(personToBook[msg.sender][_bookId] < 1, "The book is already borrowed by this address");

        books[_bookId].borrowed++;
        books[_bookId].borrowers.push(msg.sender);
        personToBook[msg.sender][_bookId] = 1;
    }

    function returnBook(uint _bookId) external {
        require(personToBook[msg.sender][_bookId] == 1, "The book is not borrowed by this address");

        books[_bookId].borrowed--;
        delete personToBook[msg.sender][_bookId];
    }

    function getAvailableBooks() external view returns (uint[] memory) {
        uint availableBooksCount = 0;
        for (uint i = 0; i < books.length; i++) {
            if (books[i].copies - books[i].borrowed > 0) {
                availableBooksCount++;
            }
        }

        require (availableBooksCount > 0, "There are no available books");

        uint[] memory bookIds = new uint[](availableBooksCount);
        uint counter = 0;
        for (uint i = 0; i < books.length; i++) {
            if (books[i].copies - books[i].borrowed > 0) {
                bookIds[counter] = i;
                counter++;
            }
        }

        return bookIds;
    }

    function getPersonsBorrowedABook(uint _bookId) external view returns (address[] memory){
        return books[_bookId].borrowers;
    }
}
