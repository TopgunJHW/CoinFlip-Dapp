var web3 = new Web3(Web3.givenProvider);
var contractInstance;
var from;

$(document).ready(function() {

    window.ethereum.enable().then(function(accounts){// Ask user for permission for webpage to access MetaMask.
      //contractInstance = new web3.eth.Contract(abi, address)
      // abi = template of the specification of the contract. What are the functions, what are the inputs and the outputs. javascript can than know what type of data to sent and to receive.
      from = accounts[0];
      contractInstance = new web3.eth.Contract(abi, "0x8cEE73d45e6B00D1fB472532E168588c546D0E27", {from: from});
      console.log(contractInstance);

      // var queryIDs_events = [];
      // contractInstance.events.betResult({filter: {queryID: queryIDs_events}}, function(error, event){
      //   var queryID_event = event.returnValues.queryID;
      //   console.log("STEPSuccess");
      //   console.log(queryIDs_events);
      //   console.log(event);
      //   console.log(queryID_event);
      //   console.log(queryIDs_events.includes(queryID_event));
      //
      //   contractInstance.methods.getBetInfo(queryID_event).call().then(function(betResult){
      //       // console.log("Success")
      //       // console.log(queryID);
      //       // console.log(event);
      //       insertRow(betResult, queryID_event, true);
      //   });
      // });

      $("#bet_button").click(bet)
      // $("#bet_button").on("click", function(){
      //   bet(queryIDs_events);
      // })
      $("#btn_history").click(getAllBets)
      $("#btn_fund").click(fundContract)
      $("#btn_witdrawAll").click(witdrawAll)
      $("#btn_selfDestruct").click(selfDestruct)
    });

    // function bet(queryIDs_events){
    function bet(){
      var choice = document.getElementById("choice").textContent;
      var choiceNB = headOrTail(choice);
      var betAmount = $("#betAmount").val();
      var config = {value: web3.utils.toWei(betAmount, "ether")};

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

        var queryID = receipt.events.logNewProvableQuery.returnValues.queryID;
        // queryIDs_events.push(queryID);
        var blockNumber = receipt.blockNumber;
        insertTableRow('table_bets_body', queryID, [blockNumber, choice, 'pending', 'pending']);

        contractInstance.once('betResult', {filter: {queryID: queryID}}, function(err, event){
          console.log("Event trigger Success");
          console.log("QueryID event equal to queryID input: ", queryID == event.returnValues.queryID);
          console.log(queryID);
          console.log(event);
          contractInstance.methods.getBetInfo(queryID).call().then(function(betResult){
              insertRow(betResult, queryID, true);
            });
          });

      })
      // .then(function(receipt){
      //   console.log(receipt);
      // });
    };

    function getAllBets(){

      // Clear all table rows
      var new_tbody = document.createElement('tbody');
      new_tbody.setAttribute("id", "table_bets_body");
      var old_tbody = document.getElementById('table_bets_body');
      old_tbody.parentNode.replaceChild(new_tbody, old_tbody);

      contractInstance.methods.getQueryIDs(from).call().then(function(queryIDs){
        insertRowLoop(0, queryIDs)
        });
      };

    function insertRowLoop(i, queryIDs){

      if (i < queryIDs.length) {
        var queryID = queryIDs[i];
        contractInstance.methods.getBetInfo(queryID).call().then(function(betResult){
          insertRow(betResult, queryID);
          i++;
          insertRowLoop(i, queryIDs);
        });
      };
    };

    function insertRow(betResult, queryID, replace = false){
      var blockNumber = betResult.blockNumber;
      var choice = headOrTail(betResult.guessNumber);
      var amount = betResult.betAmount;
      var bool = betResult.setRandomNumber;
      var answer;
      var result;

      if (!bool){
        answer = "Pending";
        result = "Pending";
      }else {
        var textResult = "You lost ";

        if(betResult.guessNumber == betResult.randomNumber){
          textResult = "You won ";
          amount = String(parseInt(amount) * 2);
        }

        answer = headOrTail(betResult.randomNumber);
        result = textResult + web3.utils.fromWei(amount, "ether") + " ether";
      }

      if (replace) {
        replaceTableRow(queryID, [blockNumber, choice, answer, result]);
      }else {
        // insertTableRow(blockNumber, choice, answer, result);
        insertTableRow('table_bets_body', queryID, [blockNumber, choice, answer, result]);
      }
    };

    function insertTableRow(tableID, newrowID, cells){
      var table = document.getElementById(tableID);
      var row = table.insertRow(0);
      row.setAttribute('id', newrowID);

      cells.forEach((cell, i) => {
        insertTableCell(row, i, cell);
      });
    }

    function insertTableCell(row, index, input){
      var cell = row.insertCell(index);
      cell.innerHTML = input;
    }

    function replaceTableRow(rowID, cells) {
      var row = document.getElementById(rowID);

      cells.forEach((cell, i) => {
        row.deleteCell(i)
        insertTableCell(row, i, cell);
      });
    }

    function deleteRow(rowID){
      var row = document.getElementById(rowID);
      row.parentNode.removeChild(row);
    }

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

    function fundContract(){
      var fundAmount = $("#fundAmount").val();
      var config = {value: web3.utils.toWei(fundAmount, "ether")};

      contractInstance.methods.fundContract().send(config)
      .on("transactionHash", function(hash){     //.on is an event listener listening to specific event
        console.log(hash);
      })
      .on("receipt", function(receipt){
        console.log(receipt);
        alert("Contract funded");
      });
    }

    function witdrawAll(){
      contractInstance.methods.withdrawAll().send()
      .on("transactionHash", function(hash){     //.on is an event listener listening to specific event
        console.log(hash);
      })
      .on("receipt", function(receipt){
        console.log(receipt);
        alert("Contract fund withdrawn");
      });
    };

    function selfDestruct(){
      contractInstance.methods.close().send()
      .on("transactionHash", function(hash){     //.on is an event listener listening to specific event
        console.log(hash);
      })
      .on("receipt", function(receipt){
        console.log(receipt);
        alert("Contract destroyed");
      });
    };
  });
