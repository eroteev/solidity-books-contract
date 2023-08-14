import { ethers, isError } from "ethers";
import Library from "../artifacts/contracts/Library.sol/Library.json";

const NETWORK_URL = 'http://127.0.0.1:8545';
const OWNER_PK = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'; // Account #0
const USER_PK = '0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d'; // Account #1
const CONTRACT_ADDRESS = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
const BOOK_ISBN = 1000;
const BOOK_COPIES = 10;

const run = async function () {
    const provider = new ethers.JsonRpcProvider(NETWORK_URL)

    const ownerWallet = new ethers.Wallet(OWNER_PK, provider);
    const ownerContract = new ethers.Contract(CONTRACT_ADDRESS, Library.abi, ownerWallet);

    const userWallet = new ethers.Wallet(USER_PK, provider);
    const userContract = new ethers.Contract(CONTRACT_ADDRESS, Library.abi, userWallet);

    await addBook();
    await rentBook();
    await checkBookIsRented();
    await checkBookAvailability();
    await returnBook();
    await checkBookAvailability();


    async function addBook() {
        try {
            const tx = await ownerContract.addBook(BOOK_ISBN, BOOK_COPIES);
            const receipt = await tx.wait();
            if (receipt.status != 1) {
                console.log("Adding book transaction failed");
                return;
            }
            console.log("Book added successfully");
        } catch (e) {
            if (isError(e, "CALL_EXCEPTION") && e?.info?.error?.message.includes('BookAlreadyExists')) {
                console.log("The book already exists");
                return;
            }
            throw e;
        }
    }

    async function rentBook() {
        try {
            const tx = await userContract.borrowBook(BOOK_ISBN);
            const receipt = await tx.wait();
            if (receipt.status != 1) {
                console.log("Book borrow transaction failed");
                return;
            }
            console.log("Book borrowed successfully");
        } catch (e) {
            if (isError(e, "CALL_EXCEPTION") && e?.info?.error?.message.includes('BookAlreadyBorrowedByAddress')) {
                console.log('You have already rented this book');
                return;
            }
            throw e;
        }
    }

    async function checkBookIsRented() {
        const book = await userContract.getBook(BOOK_ISBN);
        if (book.borrowers.includes(await userWallet.getAddress())) {
            console.log("The user address has been recorded to the borrowers list for this book on the blockchain");
            return;
        }
        console.log("The user's address is not found in the borrowers list for this book on the blockchain");
    }

    async function returnBook() {
        const tx = await userContract.returnBook(BOOK_ISBN);
        const receipt = await tx.wait();
        if (receipt.status != 1) {
            console.log("Book return transaction failed");
            return;
        }
        console.log("Book returned successfully");
    }

    async function checkBookAvailability() {
        const book = await ownerContract.getBook(BOOK_ISBN);
        console.log("There are %s available copies of the book", (book.copies - book.borrowed).toString());
    }
}();
