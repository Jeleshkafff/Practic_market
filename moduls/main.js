import ABI from "../abi.js";
export let web3, current_account, contractInstance;
import changeRole from "/moduls/addAdm.js";
const abi = ABI;
export let accountContract = "0xBA82d355c85941dd0B5C8b3dec843ab529E64faB";

function network() {
  web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));
  contractInstance = new web3.eth.Contract(abi, accountContract);
}
network();
changeRole();
let accounts = await web3.eth.getAccounts();

console.log(accounts);
