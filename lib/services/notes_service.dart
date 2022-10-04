import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

import '../models/note_model.dart';

class NotesService extends ChangeNotifier {
  List<Note> allNotes = [];
  late Web3Client web3Client;
  late ContractAbi abiCode;
  late EthereumAddress contractAddress;
  late EthPrivateKey credentials;
  late DeployedContract deployedContract;
  late ContractFunction createNote;
  late ContractFunction deleteNote;
  late ContractFunction notes;
  late ContractFunction noteCount;

  final String rpcURL = "http://127.0.0.1:7545"; //rpc remote procedure call
  final String wsURL = "ws://127.0.0.1:7545"; //ws web socket url
  final String privateKey =
      "799b644888b1c83a26275e0ce84c18ea50a460386ea07388cd74f60cc467cefa";

  NotesService() {
    init();
  }

  Future<void> getABI() async {
    String abiFile =
        await rootBundle.loadString('build/contracts/NotesContract.json');
    var jsonABI = jsonDecode(abiFile);
    abiCode = ContractAbi.fromJson(jsonEncode(jsonABI['abi']), 'NotesContract');
    contractAddress =
        EthereumAddress.fromHex(jsonABI["networks"]["5777"]["address"]);
  }

  Future<void> getCredentials() async {
    credentials = EthPrivateKey.fromHex(privateKey);
  }

  Future<void> getDeployedContract() async {
    deployedContract = DeployedContract(abiCode, contractAddress);
    createNote = deployedContract.function('createNote');
    deleteNote = deployedContract.function('deleteNote');
    notes = deployedContract.function('notes');
    noteCount = deployedContract.function('noteCount');
    await fetchNotes();
  }

  Future<void> fetchNotes() async {
    List totalTaskList = await web3Client.call(
      contract: deployedContract,
      function: noteCount,
      params: [],
    );

    int totalTaskLen = totalTaskList[0].toInt();
    allNotes.clear();
    for (var i = 0; i < totalTaskLen; i++) {
      var temp = await web3Client.call(
          contract: deployedContract,
          function: notes,
          params: [BigInt.from(i)]);
      if (temp[1] != "") {
        allNotes.add(
          Note(
            id: (temp[0] as BigInt).toInt(),
            title: temp[1],
            description: temp[2],
          ),
        );
      }
    }
    notifyListeners();
  }

  Future<void> init() async {
    web3Client = Web3Client(rpcURL, http.Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsURL).cast<String>();
    });
    await getABI();
    await getCredentials();
    await getDeployedContract();
  }
}
