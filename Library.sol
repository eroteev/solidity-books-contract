// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Ownable.sol";

contract Library is Ownable {
    struct Book {
        uint64 isbn;
        uint8 copies;
        uint8 borrowed;
        address[] borrowers;
    }

    mapping(uint64 => Book) private isbnToBook;
    mapping(uint64 => bool) private isbnInserted;
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
        if (isbnInserted[_isbn] == true) {
            revert BookAlreadyExists();
        }

        isbnToBook[_isbn] = Book(_isbn, _copies, 0, new address[](0));
        isbnInserted[_isbn] = true;
        isbnList.push(_isbn);

        emit BookAdded(_isbn, _copies);
    }

    function borrowBook(uint64 _isbn) external {
        if (isbnInserted[_isbn] == false) {
            revert BookNotFound();
        }
        if (isbnToBook[_isbn].borrowed >= isbnToBook[_isbn].copies) {
            revert NotEnoughCopies();
        }

        if (personToBookBorrowed[msg.sender][_isbn] == true) {
            revert BookAlreadyBorrowedByAddress();
        }

        isbnToBook[_isbn].borrowed++;
        isbnToBook[_isbn].borrowers.push(msg.sender);
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
        for (uint i = 0; i < isbnList.length; i++) {
            if (isbnToBook[isbnList[i]].copies - isbnToBook[isbnList[i]].borrowed > 0) {
                availableBooksCount++;
            }
        }

        if (availableBooksCount == 0) {
            revert NoAvailableBooks();
        }

        uint64[] memory books = new uint64[](availableBooksCount);
        uint counter = 0;
        for (uint i = 0; i < isbnList.length; i++) {
            if (isbnToBook[isbnList[i]].copies - isbnToBook[isbnList[i]].borrowed > 0) {
                books[counter] = isbnList[i];
                counter++;
            }
        }

        return books;
    }

    function getPersonsBorrowedABook(uint64 _isbn) external view returns (address[] memory){
        if (isbnInserted[_isbn] == false) {
            revert BookNotFound();
        }

        return isbnToBook[_isbn].borrowers;
    }
}
