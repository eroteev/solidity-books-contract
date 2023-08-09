// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Library is Ownable {
    struct Book {
        uint64 isbn;
        uint8 copies;
        uint8 borrowed;
        address[] borrowers;
    }

    mapping(uint64 => Book) private isbnToBook;
    uint64[] private isbnList;

    mapping(address => mapping(uint64 => bool)) public personToBookBorrowed;

    event BookAdded(uint64 isbn, uint8 copies);
    event BookBorrowed(uint64 isbn, address user);
    event BookReturned(uint64 isbn, address user);

    error BookNotFound();
    error BookAlreadyExists();
    error NotEnoughCopies();
    error BookAlreadyBorrowedByAddress();
    error BookNotBorrowedByAddress();
    error NoAvailableBooks();

    function addBook(uint64 _isbn, uint8 _copies) external onlyOwner {
        if (_copies == 0) {
            revert NotEnoughCopies();
        }
        Book storage book = isbnToBook[_isbn];
        if (book.isbn > 0) {
            revert BookAlreadyExists();
        }

        book.isbn = _isbn;
        book.copies = _copies;
        isbnList.push(_isbn);

        emit BookAdded(_isbn, _copies);
    }

    function getBook(uint64 _isbn) external view returns(Book memory book) {
        return isbnToBook[_isbn];
    }

    function borrowBook(uint64 _isbn) external {
        Book storage book = isbnToBook[_isbn];
        if (book.isbn == 0) {
            revert BookNotFound();
        }
        if (book.borrowed >= book.copies) {
            revert NotEnoughCopies();
        }

        if (personToBookBorrowed[msg.sender][_isbn] == true) {
            revert BookAlreadyBorrowedByAddress();
        }

        book.borrowed++;
        book.borrowers.push(msg.sender);
        personToBookBorrowed[msg.sender][_isbn] = true;

        emit BookBorrowed(_isbn, msg.sender);
    }

    function returnBook(uint64 _isbn) external {
        if (personToBookBorrowed[msg.sender][_isbn] == false) {
            revert BookNotBorrowedByAddress();
        }

        isbnToBook[_isbn].borrowed--;
        personToBookBorrowed[msg.sender][_isbn] = false;

        emit BookReturned(_isbn, msg.sender);
    }

    function getAvailableBooks() external view returns (uint64[] memory) {
        uint availableBooksCount = 0;
        uint isbnListLength = isbnList.length;

        for (uint i = 0; i < isbnListLength; i++) {
            Book memory currBook = isbnToBook[isbnList[i]];
            if (currBook.copies - currBook.borrowed > 0) {
                availableBooksCount++;
            }
        }

        if (availableBooksCount == 0) {
            revert NoAvailableBooks();
        }

        uint64[] memory books = new uint64[](availableBooksCount);
        uint counter = 0;
        for (uint i = 0; i < isbnListLength; i++) {
            Book memory currBook = isbnToBook[isbnList[i]];
            if (currBook.copies - currBook.borrowed > 0) {
                books[counter] = currBook.isbn;
                counter++;
            }
        }

        return books;
    }

    function getPersonsBorrowedABook(uint64 _isbn) external view returns (address[] memory){
        Book memory book = isbnToBook[_isbn];
        if (book.isbn == 0) {
            revert BookNotFound();
        }

        return book.borrowers;
    }
}
