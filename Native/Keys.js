Elm.Native.Keys = {};
Elm.Native.Keys.make = function(elm) {
  elm.Native = elm.Native || {};
  elm.Native.Keys = elm.Native.Keys || {};
  if (elm.Native.Keys.values) return elm.Native.Keys.values;

  // Imports
  var Signal = Elm.Native.Signal.make(elm);

  var pressesIn = Signal.constant("");
  var downsIn = Signal.constant(0);
  var metaIn = Signal.constant(0);

  var specialKeys = {
    '8': 'backspace',
    '37': 'left',
    '38': 'up',
    '39': 'right',
    '40': 'down'
  };

  var modKeys = {
    '91': 'meta',
    '93': 'meta'
  };

  var downMods = {};

  document.onkeydown = function(e) {
    var mod;
    if (mod = modKeys[e.keyCode.toString()]) {
      downMods[mod] = true;
      e.preventDefault();
    } else if (downMods.meta) {
      elm.notify(metaIn.id, e.keyCode);
      e.preventDefault();
    } else if (specialKeys[e.keyCode.toString()]) {
      elm.notify(downsIn.id, e.keyCode)
      e.preventDefault();
    }
  }

  document.onkeypress = function(e) {
    var evt = evt || window.event;
    var charCode = evt.which || evt.keyCode;
    var charTyped = String.fromCharCode(charCode);
    elm.notify(pressesIn.id, charTyped);
    e.preventDefault();
  }

  document.onkeyup = function(e) {
    var mod;
    if (mod = modKeys[e.keyCode.toString()]) {
      downMods[mod] = false;
      e.preventDefault();
    }
  }

  window.onblur = function() {
    downMods = {};
  };

  return elm.Native.Keys.values = {
    pressesIn: pressesIn,
    downsIn: downsIn,
    metaIn: metaIn
  };
};
