var feedABI = [{
    "constant": false,
    "inputs": [],
    "name": "acceptOwnership",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [{
      "name": "authority_",
      "type": "address"
    }],
    "name": "setAuthority",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "owner",
    "outputs": [{
      "name": "",
      "type": "address"
    }],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "zzz",
    "outputs": [{
      "name": "",
      "type": "uint32"
    }],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "authority",
    "outputs": [{
      "name": "",
      "type": "address"
    }],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "newOwner",
    "outputs": [{
      "name": "",
      "type": "address"
    }],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [{
      "name": "newOwner_",
      "type": "address"
    }],
    "name": "transferOwnership",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "anonymous": true,
    "inputs": [{
        "indexed": true,
        "name": "sig",
        "type": "bytes4"
      },
      {
        "indexed": true,
        "name": "guy",
        "type": "address"
      },
      {
        "indexed": true,
        "name": "foo",
        "type": "bytes32"
      },
      {
        "indexed": true,
        "name": "bar",
        "type": "bytes32"
      },
      {
        "indexed": false,
        "name": "wad",
        "type": "uint256"
      },
      {
        "indexed": false,
        "name": "fax",
        "type": "bytes"
      }
    ],
    "name": "LogNote",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [{
      "indexed": true,
      "name": "authority",
      "type": "address"
    }],
    "name": "LogSetAuthority",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [{
      "indexed": true,
      "name": "owner",
      "type": "address"
    }],
    "name": "LogSetOwner",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [{
        "indexed": true,
        "name": "owner",
        "type": "address"
      },
      {
        "indexed": true,
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "OwnerUpdate",
    "type": "event"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "peek",
    "outputs": [{
        "name": "",
        "type": "bytes32"
      },
      {
        "name": "",
        "type": "bool"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": true,
    "inputs": [],
    "name": "read",
    "outputs": [{
      "name": "",
      "type": "bytes32"
    }],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [{
        "name": "val_",
        "type": "uint128"
      },
      {
        "name": "zzz_",
        "type": "uint32"
      }
    ],
    "name": "poke",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [{
        "name": "val_",
        "type": "uint128"
      },
      {
        "name": "zzz_",
        "type": "uint32"
      },
      {
        "name": "med_",
        "type": "address"
      }
    ],
    "name": "post",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [],
    "name": "void",
    "outputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  }
];