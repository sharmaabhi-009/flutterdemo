// share accross all files
final Map<String, Map<String, Map<String, dynamic>>> stockDataByTopic = {};
  // topic -> {symbol -> stock info}
  /*
      {
        'Stock/#': {
          'RELIANCE': {symbol, name, price, change},
          'TCS': {symbol, name, price, change},
          ...
        },
        'Stock/BSE/#': {
          'SBI': {symbol, name, price, change},
          ...
        },
        'Stock/NSE/#': {  
          'INFY': {symbol, name, price, change},
          ...
        }
      }
  */


