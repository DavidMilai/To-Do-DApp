import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

import '../models/note_model.dart';

class NotesService extends ChangeNotifier {
  List<Note> notes = [];

  final String rpcURL = "http://127.0.0.1:7545";
  //rpc remote procedure call

  final String wsURL = "ws://127.0.0.1:7545";
  //ws web socket url

  final String privateKey =
      "799b644888b1c83a26275e0ce84c18ea50a460386ea07388cd74f60cc467cefa";

  late Web3Client web3Client;

  NotesService() {
    init();
  }

  Future<void> init() async {
    web3Client = Web3Client(
      rpcURL: rpcURL,
    );
  }
}
