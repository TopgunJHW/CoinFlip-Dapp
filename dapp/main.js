var web3 = new Web3(Web3.givenProvider);
var contractInstance;

$(document).ready(function() {

    window.ethereum.enable().then(function(accounts){// Ask user for permission for webpage to access MetaMask.
      //contractInstance = new web3.eth.Contract(abi, address)
      // abi = template of the specification of the contract. What are the functions, what are the inputs and the outputs. javascript can than know what type of data to sent and to receive.
      contractInstance = new web3.eth.Contract(abi, "0x8135FAA772a58202AB50E34689B4CCe922904591", {from: accounts[0]});
      console.log(contractInstance);

      $("#bet_button").click(bet)
      $("#get_allBets").click(getAllBets)
    });


    function bet(){
      var choice = document.getElementById("choice").textContent;
      var choiceNB = headOrTail(choice);
      var betAmount = $("#betAmount").val();
      var config = {value: web3.utils.toWei(betAmount, "ether")}

      contractInstance.methods.makeBet(choiceNB).send(config)
      .on("transactionHash", function(hash){     //.on is an event listener listening to specific event
        console.log(hash);
      })
      .on("confirmation", function(confirmationNr){
        console.log(confirmationNr);
      })
      .on("receipt", function(receipt){
        console.log(receipt);
        // alert("Is mined");
      })
      .then(function(){
        var from = contractInstance.options.from;
        console.log(from);

        contractInstance.methods.getQueryIDs(from).call().then(function(queryIDs){
          console.log(queryIDs);
          var queryID = queryIDs[queryIDs.length-1];
          console.log(queryID);

          // contractInstance.once('betResult', {filter: {queryId: queryID}}, function (err, events){
          //   console.log(events);

          contractInstance.methods.getBetInfo(queryID).call().then(function(betResult){
            console.log(betResult);

            var blockNumber = betResult.blockNumber;
            var text2 = "You lost ";
            var amount = betResult.betAmount;
            if(betResult.guessNumber == betResult.randomNumber){
              text2 = "You won ";
              amount = String(parseInt(amount) * 2);
            };

            var choice = headOrTail(betResult.guessNumber);
            var answer = headOrTail(betResult.randomNumber);

            // $("#block_tbl").text("#1");
            // $("#choice_tbl").text(choice);
            // $("#answer_tbl").text(answer);
            // $("#result_tbl").text(text2 + web3.utils.fromWei(amount, "ether") + " ether");
            insert_Row("LOL", choice, answer, text2 + web3.utils.fromWei(amount, "ether") + " ether");

          });
        });
      });
    };

    function getAllBets(){

      // Clear all table rows
      var new_tbody = document.createElement('tbody');
      new_tbody.setAttribute("id", "table_result_body");
      var old_tbody = document.getElementById('table_result_body');
      old_tbody.parentNode.replaceChild(new_tbody, old_tbody);

    };

    function insert_Row(inputC0, inputC1, inputC2, inputC3){
      var x = document.getElementById('table_result_body').insertRow(-1);
      var c0 = x.insertCell(0);
      var c1 = x.insertCell(1);
      var c2 = x.insertCell(2);
      var c3 = x.insertCell(3);
      c0.innerHTML = inputC0;
      c1.innerHTML = inputC1;
      c2.innerHTML = inputC2;
      c3.innerHTML = inputC3;
    };
    function headOrTail(inputString){
      if (inputString == "0") {
        txt = "Head";
      }else if (inputString == "1"){
        txt = "Tail";
      }else if (inputString == "Head") {
        txt = "0";
      }else {
        txt = "1";
      };
      return txt;
    };
  });
