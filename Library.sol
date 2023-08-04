// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./Ownable.sol";

contract Library is Ownable {
    struct Book {
        uint isbn;
        uint copies;
        uint borrowed;
        address[] borrowers;
    }

    mapping(uint => Book) private isbnToBook;
    mapping(uint => bool) private isbnInserted;
    uint[] private isbnList;

    mapping(address => mapping(uint => bool)) public personToBookBorrowed;

    error BookNotFound();
    error BookAlreadyExists();
    error NotEnoughCopies();
    error BookAlreadyBorrowedByAddress();
    error BookNotBorrowedByAddress();
    error NoAvailableBooks();

    function addBook(uint _isbn, uint _copies) external onlyOwner {
        if (_copies == 0) {
            revert NotEnoughCopies();
        }
        if (isbnInserted[_isbn] == true) {
            revert BookAlreadyExists();
        }

        isbnToBook[_isbn] = Book(_isbn, _copies, 0, new address[](0));
        isbnInserted[_isbn] = true;
        isbnList.push(_isbn);
    }

    function borrowBook(uint _isbn) external {
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
    }

    function returnBook(uint _isbn) external {
        if (personToBookBorrowed[msg.sender][_isbn] == false) {
            revert BookNotBorrowedByAddress();
        }

        isbnToBook[_isbn].borrowed--;
        personToBookBorrowed[msg.sender][_isbn] = false;
    }

    function getAvailableBooks() external view returns (uint[] memory) {
        uint availableBooksCount = 0;
        for (uint i = 0; i < isbnList.length; i++) {
            if (isbnToBook[isbnList[i]].copies - isbnToBook[isbnList[i]].borrowed > 0) {
                availableBooksCount++;
            }
        }

        if (availableBooksCount == 0) {
            revert NoAvailableBooks();
        }

        uint[] memory books = new uint[](availableBooksCount);
        uint counter = 0;
        for (uint i = 0; i < isbnList.length; i++) {
            if (isbnToBook[isbnList[i]].copies - isbnToBook[isbnList[i]].borrowed > 0) {
                books[counter] = isbnList[i];
                counter++;
            }
        }

        return books;
    }

    function getPersonsBorrowedABook(uint _isbn) external view returns (address[] memory){
        if (isbnInserted[_isbn] == false) {
            revert BookNotFound();
        }

        return isbnToBook[_isbn].borrowers;
    }
}
