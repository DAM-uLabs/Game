// Web3 initialization and contract interaction code

const placeBetBtn = document.getElementById("place-bet");
const submitWinnerBtn = document.getElementById("submit-winner");
const winnerForm = document.getElementById("winner-form");

placeBetBtn.addEventListener("click", async function() {
  const player1 = document.getElementById("player1").value;
  const player2 = document.getElementById("player2").value;
  const gameId = document.getElementById("game-id").value;
  const betAmount = document.getElementById("bet-amount").value;
  
  // call the deposit function of the smart contract
  await contract.methods.deposit(gameId).send({ from: player1, value: betAmount });
  await contract.methods.deposit(gameId).send({ from: player2, value: betAmount });
  
  // call the add game function of the smart contract
  await contract.methods.addGame(gameId).send({ from: player1 });

  // hide the bet form and show the winner form
  document.getElementById("bet-form").style.display = "none";
  winnerForm.style.display = "block";

  // set a timer for a specified time
  setTimeout(async function() {
    const winner = document.getElementById("winner").value;
    // call the determineWinner function of the smart contract
    await contract.methods.determineWinner(gameId).send({ from: winner });
    // call the payout function of the smart contract
    await contract.methods.payout(gameId).send({ from: winner });
  }, 5000);
});
