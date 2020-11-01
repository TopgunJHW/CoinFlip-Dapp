var web3 = new Web3(Web3.givenProvider);
// var contractInstance;

$(document).ready(function() {

    window.ethereum.enable().then(function(accounts){// Ask user for permission for webpage to access MetaMask.
      //contractInstance = new web3.eth.Contract(abi, address)
      // abi = template of the specification of the contract. What are the functions, what are the inputs and the outputs. javascript can than know what type of data to sent and to receive.
      contractInstance = new web3.eth.Contract(abi, "0xEbB9aA610b760b9582e30Ce1b68Be84AF8ca22fd", {from: accounts[0]});
      console.log(contractInstance);

      $("#bet_button").click(bet)
    });

    function bet(){
      var choice = document.getElementById("choice").textContent;
      var choiceNB = 1;
      var betAmount = $("#betAmount").val();

      if(choice == "Head"){
        choiceNB = 0;
      };

      var config = {value: web3.utils.toWei(betAmount, "ether")}

      contractInstance.methods.bet(choiceNB).send(config)
      .on("transactionHash", function(hash){     //.on is an event listener listening to specific event
        console.log(hash);
      })
      .on("confirmation", function(confirmationNr){
        console.log(confirmationNr);
      })
      .on("receipt", function(receipt){
        console.log(receipt);
        var result = receipt["events"]["betResult"]["returnValues"]["_result"];
        var amount = receipt["events"]["betResult"]["returnValues"]["_value"];

        var textResult = "You won ";
        if(result == "You lose")(
          textResult = "You lost "
        );

        $("#result").text(result);
        $("#amount").text(textResult +  web3.utils.fromWei(amount, "ether") + " ether");

        alert("Is mined");
      });
    };
  });
