// registration;
import { contractInstance } from "/moduls/main.js";
let AddressReg = document.querySelector(".AddressReg");
let PasswordReg = document.querySelector(".PasswordReg");
let RegBtn = document.querySelector(".RegBtn");
console.log(RegBtn);
RegBtn.addEventListener("click", async () => {
  let res = await contractInstance.methods
    .registration(PasswordReg.value)
    .send({
      from: AddressReg.value,
      gas: 3000000,
    })
    .catch(function (error) {
      const data = error.data;
      // const adm = account;
      const txHash = Object.keys(data)[0];
      const reason = data[txHash].reason;
      // console.log(data);
      // stat.textContent = reason;
      alert(reason);
    });
  console.log(res);
  document.location.href = "http://127.0.0.1:5500/index.html";
});

let AddresssignIn = document.querySelector(".AddresssignIn");
let PasswordsignIn = document.querySelector(".PasswordsignIn");
let signInBtn = document.querySelector(".signInBtn");
signInBtn.addEventListener("click", async () => {
  let res = await contractInstance.methods
    .signIn(PasswordsignIn.value)
    .send({
      from: AddresssignIn.value,
      gas: 3000000,
    })
    .catch(function (error) {
      const data = error.data;
      const txHash = Object.keys(data)[0];
      const reason = data[txHash].reason;
      alert(reason);
    });
  console.log(res);
  document.location.href = "http://127.0.0.1:5500/index.html";
});
