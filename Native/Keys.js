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
  var shiftIn = Signal.constant(0);
  var pasteIn = Signal.constant("");

  var specialKeys = {
    '8': 'backspace',
    '37': 'left',
    '38': 'up',
    '39': 'right',
    '40': 'down'
  };

  var modKeys = {
    '16': 'shift',
    '17': 'ctrl',
    '18': 'alt',
    '91': 'meta',
    '93': 'meta'
  };

  var downMods = {};
  var pasteCapture = document.createElement("textarea");

  // TODO: make this not visible; http://stackoverflow.com/a/13422563/308930
  pasteCapture.style.position = "absolute";

  function isPaste(e) {
    return downMods.meta && e.keyCode == 86;
  }

  function handlePaste() {
    // TODO: cancel old timeout if it exists (test with `echo -n | pbcopy`)
    var pasted = pasteCapture.value;
    if (pasted == '') {
      setTimeout(handlePaste, 10);
    } else {
      document.body.removeChild(pasteCapture);
      elm.notify(pasteIn.id, pasted);
    }
  }

  document.onkeydown = function(e) {
    var mod;
    if (isPaste(e)) {
      pasteCapture.value = "";
      document.body.appendChild(pasteCapture);
      pasteCapture.focus();
      handlePaste();
    } else if (mod = modKeys[e.keyCode.toString()]) {
      downMods[mod] = true;
      e.preventDefault();
    } else if (downMods.meta) {
      elm.notify(metaIn.id, e.keyCode);
      e.preventDefault();
    } else if (specialKeys[e.keyCode.toString()]) {
      if (downMods.shift) {
        elm.notify(shiftIn.id, e.keyCode);
        e.preventDefault();
      } else {
        elm.notify(downsIn.id, e.keyCode)
        e.preventDefault();
      }
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
    metaIn: metaIn,
    shiftIn: shiftIn,
    pasteIn: pasteIn
  };
};
