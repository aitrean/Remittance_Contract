/*
* Utility function for testing that events were emitted
* based on solution in a response by mkaj on stackoverflow
* https://ethereum.stackexchange.com/questions/15353/how-to-listen-for-contract-events-in-javascript-tests
*/

var _ = require('lodash');
var Promise = require('bluebird');

module.exports = {
  assertEvent: function(contract, filter, errorMessage) {
    return new Promise((resolve, reject) => {
      try {
        var event = contract[filter.event]();
        event.watch();
        event.get((error, logs) => {
          var log = _.filter(logs, filter);
          if (log[0]) {
            resolve(log);
          } else {
            reject();
          }
        });
        event.stopWatching();
      } catch (e) {
        throw Error('Failed to find filtered event for ' + filter.event);
      }
    });
  }
};
