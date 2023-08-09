import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Library } from "../typechain-types";

describe("Library", function () {
    async function deployContract() {
        const [owner, otherAccount] = await ethers.getSigners();

        const Library = await ethers.getContractFactory("Library");
        const library: Library = await Library.deploy();

        return { library, owner, otherAccount };
    }

    async function deployContractWithBooks() {
        const [owner, otherAccount] = await ethers.getSigners();

        const Library = await ethers.getContractFactory("Library");
        const library: Library = await Library.deploy();

        await library.addBook(1000, 1);
        await library.addBook(2000, 2);
        await library.addBook(3000, 3);
        await library.connect(otherAccount).borrowBook(1000);
        await library.connect(otherAccount).borrowBook(3000);

        return { library, owner, otherAccount };
    }

    describe("Deployment", function () {
        it("Should set the right owner", async function () {
            const { library, owner } = await loadFixture(deployContract);

            expect(await library.owner()).to.equal(owner.address);
        });
    });

    describe("addBook", function () {
        it("Should add a book", async function () {
            const { library } = await loadFixture(deployContract);

            await expect(library.addBook(5000, 5)).to.not.be.reverted;

            const book = await library.getBook(5000);
            expect(book.isbn).to.equal(5000);
            expect(book.copies).to.equal(5);
        });

        it("Should emit event on adding a book", async function () {
            const { library } = await loadFixture(deployContract);

            await expect(library.addBook(10, 20))
                .to.emit(library, "BookAdded")
                .withArgs(10, 20);
        });

        it("Should revert if not called by the owner", async function () {
            const { library, otherAccount } = await loadFixture(deployContract);
            await expect(library.connect(otherAccount).addBook(10, 10)).to.be.revertedWith("Ownable: caller is not the owner");
        });

        it("Should revert if not enough copies are provided", async function () {
            const { library } = await loadFixture(deployContract);
            await expect(library.addBook(10, 0)).to.be.revertedWithCustomError(library, "NotEnoughCopies");
        });

        it("Should revert if book already exists", async function () {
            const { library } = await loadFixture(deployContractWithBooks);
            await expect(library.addBook(1000, 10)).to.be.revertedWithCustomError(library, "BookAlreadyExists");
        });
    });

    describe("borrowBook", function() {
        it("Should allow a user to borrow a book", async function () {
            const { library, otherAccount } = await loadFixture(deployContractWithBooks);

            await expect(library.connect(otherAccount).borrowBook(2000)).to.not.be.reverted;
        });

        it("Should emit event on borrowing a book", async function () {
            const { library, otherAccount } = await loadFixture(deployContractWithBooks);

            await expect(library.connect(otherAccount).borrowBook(2000))
                .to.emit(library, "BookBorrowed")
                .withArgs(2000, otherAccount.address);
        });

        it("Should revert if book is not found", async function () {
            const { library, otherAccount } = await loadFixture(deployContractWithBooks);
            await expect(library.connect(otherAccount).borrowBook(9000)).to.be.revertedWithCustomError(library, "BookNotFound");
        });

        it("Should revert if there are not enough copies to borrow", async function () {
            const { library } = await loadFixture(deployContractWithBooks);

            await expect(library.borrowBook(1000)).to.be.revertedWithCustomError(library, "NotEnoughCopies");
        });

        it("Should revert if the book is already borrowed by this user", async function () {
            const { library, otherAccount } = await loadFixture(deployContractWithBooks);

            await expect(library.connect(otherAccount).borrowBook(3000)).to.be.revertedWithCustomError(library, "BookAlreadyBorrowedByAddress");
        });
    });

    describe("returnBook", function() {
        it("Should allow a user to return a book", async function () {
            const { library, otherAccount } = await loadFixture(deployContractWithBooks);

            await expect(library.connect(otherAccount).returnBook(1000)).to.not.be.reverted;
        });

        it("Should emit event on returning a book", async function () {
            const { library, otherAccount } = await loadFixture(deployContractWithBooks);

            await expect(library.connect(otherAccount).returnBook(1000))
                .to.emit(library, "BookReturned")
                .withArgs(1000, otherAccount.address);
        });

        it("Should revert if the book is not borrowed by this user", async function () {
            const { library, otherAccount } = await loadFixture(deployContractWithBooks);

            await expect(library.connect(otherAccount).returnBook(2000)).to.be.revertedWithCustomError(library, "BookNotBorrowedByAddress");
        });
    });

    describe("getAvailableBooks", function() {
        it("Should allow a user to get available books", async function () {
            const { library, otherAccount } = await loadFixture(deployContractWithBooks);

            const availableBooks = await library.connect(otherAccount).getAvailableBooks();

            expect(availableBooks.length).to.equal(2);
            expect(availableBooks[0]).to.equal(2000);
            expect(availableBooks[1]).to.equal(3000);
        });

        it("Should revert if there are no books available", async function () {
            const { library, otherAccount } = await loadFixture(deployContract);

            await expect(library.getAvailableBooks()).to.be.revertedWithCustomError(library, "NoAvailableBooks");
        });
    });

    describe("getPersonsBorrowedABook", function() {
        it("Should allow any user to get all persons borrowed a book", async function () {
            const { library, otherAccount } = await loadFixture(deployContractWithBooks);

            const personList = await library.connect(otherAccount).getPersonsBorrowedABook(1000);

            expect(personList.length).to.equal(1);
            expect(personList[0]).to.equal(otherAccount.address);
        });

        it("Should revert if book is not found", async function () {
            const { library, otherAccount } = await loadFixture(deployContractWithBooks);
            await expect(library.connect(otherAccount).getPersonsBorrowedABook(9000)).to.be.revertedWithCustomError(library, "BookNotFound");
        });
    });
});