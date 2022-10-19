import { contractInstance } from "./main.js";
export default async function changeRole() {
  const AddAdmInp = document.querySelector(".AddNewAdmin");
  let AddAdmBtn = document.querySelector(".AddNewAdminBtn");
  let Acc = document.querySelector(".Account");
  let Balanse = document.querySelector(".Balanse");
  console.log(AddAdmInp);
  AddAdmBtn.addEventListener("click", async () => {
    let res = await contractInstance.methods
      .changeRole()
      .send({
        from: "0xcAB53AfD941EDE12eDDE8e0aCA0b577B3c8B3dF7",
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
  });
}
// export default changeRole();
