//module.exports = {
//  networks: {
//    development: {
//      host: "127.0.0.1",
//      port: 7545,
//      network_id: "*",
//    },
//    advanced: {
//      websocket: true,
//    },
//  },
//  contract_build_directory: "./src/abis",
//  compilers: {
//    solc: {
//      version: "^0.8.0"
////      optimizer: {
////        enabled: true,
////      c  runs: 200,
////      },
//    },
//  },
//};

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
    },
  },
  contracts_directory: "./contracts",
  compilers: {
    solc: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },

  db: {
    enabled: false,
  },
};
