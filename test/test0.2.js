// type:'deposit', 'destroy', 'withdraw', 'updateSection', 'claim'
// tokenAddress 1~4
// accountAddress 1~20
// total true: all false: invalid parameter
// times The number of executions. If there is no such parameter, it will be executed once according to the data configuration type.
// data Specific implementation, if you need to insert random mode, add {}
// If the configuration is not filled in, the measurement is performed in random mode.
// ------------------------run test case
// The terminal starts the ETH node.
// ganache-cli --port=7545 --gasLimit=8000000 --accounts=10 --defaultBalanceEther=10000
// Compile contract
// npm run build
// Run command
// truffle test .\test\test0.2.js > test0.2.log
collateralNames = new Array('DAI', 'PAX', 'TUSD', 'USDC');
weightTest = new Array(1, 3, 3, 3);
runConfig = [
// deposit-pool-claim-withdraw
    {
        'data':[
    //deposit-pool
        {
            'type':'oneClickMinting',
            'data':[
                {
                    'accountAddress':1,
                    'amount':11,
                }
            ]
        },
        {
            'type':'deposit',
            // 'times':100,
            'data':[
                {
                    'tokenAddress':1,
                    'accountAddress':1,
                    'amount':1,
                },
                {
                    'tokenAddress':2,
                    'accountAddress':2,
                    'amount':3,
                },
                {
                    'tokenAddress':3,
                    'accountAddress':3,
                    'amount':3,
                },
                {
                    'tokenAddress':4,
                    'accountAddress':4,
                    'amount':2,
                },
            ]
        },
        {
            'type':'oneClickMinting',
            'data':[
                {
                    'accountAddress':1,
                    'amount':10,
                }
            ]
        },
    //deposit-claim 
        {
            'type':'claim',
            'data':[
                {
                'accountAddress':1
                },
                {
                'accountAddress':2
                },
                {
                'accountAddress':3
                },
                {
                'accountAddress':4
                },
            ]
        },
        {
            'type':'oneClickMinting',
            'data':[
                {
                    'accountAddress':1,
                    'amount':20,
                }
            ]
        },
    //deposit-withdraw               
        {
            'type':'withdraw',
            'data':[
                {
                    'tokenAddress':1,
                    'accountAddress':1,
                    'amount':1,
                }
            ]
        }
    ],
    },
//deposit-convert-destroy2-withdraw4-deposit-withdraw8-claim  
//user4 mint 24USDx
//user5 mint 6USDx          
    {   
        'data':[
            {
                'type':'deposit',
                // 'times':100,
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':1,
                        'amount':12,
                    },
                    {
                        'tokenAddress':2,
                        'accountAddress':2,
                        'amount':24,
                    },
                    {
                        'tokenAddress':3,
                        'accountAddress':3,
                        'amount':36,
                    },
                    {
                        'tokenAddress':4,
                        'accountAddress':4,
                        'amount':48,
                    },
                ]
            }, 
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':10,
                    }
                ]
            },
            {
                'type':'destroy',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':1,
                    }
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':12,
                    }
                ]
            },
            {
                'type':'destroy',
                'data':[
                    {
                        'accountAddress':2,
                        'amount':1,
                    }
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':50,
                    }
                ]
            },
            {
                'type':'destroy',
                'data':[
                    {
                        'accountAddress':3,
                        'amount':1,
                    }
                ]
            },
            {
                'type':'destroy',
                'data':[
                    {
                        'accountAddress':4,
                        'amount':1,
                    }
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':1000,
                    }
                ]
            },
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':2,
                        'amount':1,
                    }
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':1000,
                    }
                ]
            },
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':3,
                        'accountAddress':3,
                        'amount':13,
                    }
                ]
            }, 
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':201,
                    }
                ]
            },
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':3,
                        'accountAddress':3,
                        'amount':1,
                    }
                ]
            }, 
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':3,
                        'accountAddress':3,
                        'amount':11,
                    }
                ]
            }, 
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':1000,
                    }
                ]
            },                   
            {
                'type':'deposit',
                // 'times':100,
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':5,
                        'amount':6,
                    },
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':11,
                    }
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':20,
                    }
                ]
            },
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':5,
                        'amount':11,
                    }
                ]
            }, 
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':5,
                        'amount':10,
                    }
                ]
            }, 
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':1000,
                    }
                ]
            },
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':5,
                        'amount':6,
                    }
                ]
            }, 
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':5,
                        'amount':1,
                    }
                ]
            },              
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':1,
                        'amount':11,
                    }
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':1000,
                    }
                ]
            },
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':1,
                        'amount':1,
                    }
                ]
            },
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':1,
                        'amount':10,
                    }
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':300,
                    }
                ]
            }, 
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':1,
                        'amount':9,
                    }
                ]
            }, 
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':1000,
                    }
                ]
            },                    
            {
                'type':'claim',
                'data':[
                    {
                    'accountAddress':1
                    },
                    {
                    'accountAddress':2
                    },
                    {
                    'accountAddress':3
                    },
                    {
                    'accountAddress':4
                    },
                    {
                    'accountAddress':5
                    },
                ]
            },
        ],  
    },
//deposit-convert-section[1]-deposit-withdraw3-destroy2-claim-deposit-claim-withdraw6-destroy3
//section[0]:user4 calim 24USDx;user1 claim 2USDx;user2 claim 24USDx;user3 claim 24USDx
//section[1]:user2 claim 18USDx;user1 claim 6USDx;              
    {   
        'data':[
            {
                'type':'deposit',
                // 'times':100,
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':1,
                        'amount':12,
                    },
                    {
                        'tokenAddress':2,
                        'accountAddress':2,
                        'amount':24,
                    },
                    {
                        'tokenAddress':3,
                        'accountAddress':3,
                        'amount':36,
                    },
                    {
                        'tokenAddress':4,
                        'accountAddress':4,
                        'amount':48,
                    },
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':1000,
                    }
                ]
            },
        //section[1]                
            {
                'type':'updateSection',
                // 'times':100,
                'data':[
                    {
                        'tokens':[1, 2],
                        'weight':[1, 3],
                    },
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':40,
                    }
                ]
            },                
            {
                'type':'deposit',
                // 'times':100,
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':5,
                        'amount':6,
                    }
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':7,
                    }
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':8,
                    }
                ]
            },
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':3,
                        'accountAddress':3,
                        'amount':13,
                    }
                ]
            }, 
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':3,
                        'accountAddress':3,
                        'amount':1,
                    }
                ]
            }, 
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':3,
                        'accountAddress':3,
                        'amount':11,
                    }
                ]
            }, 
            {
                'type':'destroy',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':1,
                    }
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':500,
                    }
                ]
            },
            {
                'type':'destroy',
                'data':[
                    {
                        'accountAddress':2,
                        'amount':1,
                    }
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':30,
                    }
                ]
            },
            {
                'type':'claim',
                'data':[
                    {
                    'accountAddress':1   //提取2 USDx
                    },
                    {
                    'accountAddress':2   //提取24 USDx
                    },
                    {
                    'accountAddress':3   //提取24 USDx
                    },
                    {
                    'accountAddress':4   //return 空或0
                    },
                    {
                    'accountAddress':5   //return 空或0
                    },
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':40,
                    }
                ]
            },
            {
                'type':'deposit',
                // 'times':100,
                'data':[
                    {
                        'tokenAddress':2,
                        'accountAddress':2,
                        'amount':19,
                    }
                ]
            },               
            {
                'type':'claim',
                'data':[
                    {
                    'accountAddress':1   //提取6 USDx
                    },
                    {
                    'accountAddress':2   //return 空或0
                    },
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':24,
                    }
                ]
            },
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':1,
                        'amount':5,
                    }
                ]
            }, 
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':1,
                        'amount':1,
                    }
                ]
            }, 
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':1,
                        'accountAddress':1,
                        'amount':4,
                    }
                ]
            }, 
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':60,
                    }
                ]
            },
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':2,
                        'accountAddress':2,
                        'amount':2,
                    }
                ]
            }, 
            {
                'type':'withdraw',
                'data':[
                    {
                        'tokenAddress':2,
                        'accountAddress':2,
                        'amount':1,
                    }
                ]
            }, 
            {
                'type':'destroy',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':7,
                    }
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':1000,
                    }
                ]
            },
            {
                'type':'destroy',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':1,
                    }
                ]
            },
            {
                'type':'oneClickMinting',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':1000,
                    }
                ]
            },
            {
                'type':'destroy',
                'data':[
                    {
                        'accountAddress':1,
                        'amount':6,
                    }
                ]
            },
        ],          
    }
];

require('./migrate.js');