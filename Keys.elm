module Keys (Key(..), KeyCombo(..), lastPressed, pastes) where

import Signal
import Native.Keys
import Result

type Key
  = Enter | Backspace
  | Left | Right | Up | Down

type KeyCombo
  = Single Key
  | Character String
  | Command Key
  | CommandCharacter String
  | Shift Key
  | CommandShift Key
  | Unrecognized String

fromPresses : String -> KeyCombo
fromPresses string = case string of
  "\r" -> Single Enter
  _ -> Character string

keyFromCode : Int -> Maybe Key
keyFromCode code = case code of
  8 -> Just Backspace
  13 -> Just Enter
  37 -> Just Left
  38 -> Just Up
  39 -> Just Right
  40 -> Just Down
  _ -> Nothing

charFromCode : Int -> Maybe String
charFromCode code = case code of
  49 -> Just "1"
  50 -> Just "2"
  51 -> Just "3"
  52 -> Just "4"
  53 -> Just "5"
  54 -> Just "6"
  55 -> Just "7"
  65 -> Just "a"
  68 -> Just "d"
  77 -> Just "m"
  80 -> Just "p"
  _ -> Nothing

fromMeta : Int -> KeyCombo
fromMeta code = case charFromCode code of
  Just char -> CommandCharacter char
  Nothing -> case keyFromCode code of
    Just key -> Command key
    Nothing -> Unrecognized ("Meta-" ++ toString code)

fromCombo : (Bool, Bool, Int) -> KeyCombo
fromCombo (meta, shift, code) = case keyFromCode code of
  Just key -> case (meta, shift) of
    (True, True) -> CommandShift key
    (True, False) -> Command key
    (False, True) -> Shift key
    (False, False) -> Single key
  Nothing -> case (meta, shift) of
    (True, True) -> Unrecognized ("Meta-Shift-" ++ toString code)
    (True, False) -> Unrecognized ("Meta-" ++ toString code)
    (False, True) -> Unrecognized ("Shift-" ++ toString code)
    (False, False) -> Unrecognized ("" ++ toString code)

lastPressed : Signal KeyCombo
lastPressed = Signal.mergeMany
  [ Signal.map fromPresses Native.Keys.pressesIn
  , Signal.map fromCombo Native.Keys.comboIn
  , Signal.map fromMeta Native.Keys.metaIn
  ]

pastes : Signal String
pastes = Native.Keys.pasteIn
