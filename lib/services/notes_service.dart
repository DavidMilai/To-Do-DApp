import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

import '../models/note_model.dart';

class NotesService extends ChangeNotifier {
  List<Note> notes = [];
  bool isLoading = true;
  late Web3Client web3Client;
  late ContractAbi abiCode;
  late EthereumAddress contractAddress;
  late EthPrivateKey _creds;

  late DeployedContract _deployedContract;
  late ContractFunction _createNote;
  late ContractFunction _deleteNote;
  late ContractFunction _notes;
  late ContractFunction _noteCount;

  final String rpcURL = "http://127.0.0.1:7545"; //rpc remote procedure call
  final String wsURL = "ws://127.0.0.1:7545"; //ws web socket url
  final String _privatekey =
      "799b644888b1c83a26275e0ce84c18ea50a460386ea07388cd74f60cc467cefa";

  NotesService() {
    init();
  }

  Future<void> getCredentials() async {
    _creds = EthPrivateKey.fromHex(_privatekey);
  }

  Future<void> getABI() async {
    String abiFile =
        await rootBundle.loadString('build/contracts/NotesContract.json');
    var jsonABI = jsonDecode(abiFile);
    abiCode = ContractAbi.fromJson(jsonEncode(jsonABI['abi']), 'NotesContract');
    contractAddress =
        EthereumAddress.fromHex(jsonABI["networks"]["5777"]["address"]);
  }

  Future<void> getDeployedContract() async {
    _deployedContract = DeployedContract(abiCode, contractAddress);
    _createNote = _deployedContract.function('createNote');
    _deleteNote = _deployedContract.function('deleteNote');
    _notes = _deployedContract.function('notes');
    _noteCount = _deployedContract.function('noteCount');
    await fetchNotes();
  }

  Future<void> fetchNotes() async {
    List totalTaskList = await web3Client.call(
      contract: _deployedContract,
      function: _noteCount,
      params: [],
    );

    int totalTaskLen = totalTaskList[0].toInt();
    notes.clear();
    for (var i = 0; i < totalTaskLen; i++) {
      var temp = await web3Client.call(
          contract: _deployedContract,
          function: _noteCount,
          params: [BigInt.from(i)]);
      if (temp[1] != "") {
        notes.add(
          Note(
            id: (temp[0] as BigInt).toInt(),
            title: temp[1],
            description: temp[2],
          ),
        );
      }
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(String title, String description) async {
    await web3Client.sendTransaction(
      _creds,
      Transaction.callContract(
        contract: _deployedContract,
        function: _createNote,
        parameters: [title, description],
      ),
    );
    isLoading = true;
    fetchNotes();
  }

  Future<void> deleteNote(int id) async {
    await web3Client.sendTransaction(
      _creds,
      Transaction.callContract(
        contract: _deployedContract,
        function: _deleteNote,
        parameters: [BigInt.from(id)],
      ),
    );
    // isLoading = true;
    notifyListeners();
    fetchNotes();
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
