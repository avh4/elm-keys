module Keys (Key(..), KeyCombo(..), lastPressed) where

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
  | Unrecognized String

fromPresses : String -> KeyCombo
fromPresses string = case string of
  "\r" -> Single Enter
  _ -> Character string

fromDowns : Int -> KeyCombo
fromDowns code = case code of
  8 ->  Single Backspace
  13 -> Single Enter
  37 -> Single Left
  38 -> Single Up
  39 -> Single Right
  40 -> Single Down
  _ -> Unrecognized (toString code)

keyFromCode : Int -> Maybe Key
keyFromCode code = case code of
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

fromShift : Int -> KeyCombo
fromShift code = case keyFromCode code of
  Just key -> Shift key
  Nothing -> case charFromCode code of
    Just _ -> Unrecognized ("Shift-" ++ toString code ++ " shft-down event for a normal key?!") -- TODO: should never happen
    Nothing -> Unrecognized ("Shift-" ++ toString code)

lastPressed : Signal KeyCombo
lastPressed = Signal.mergeMany
  [ Signal.map fromPresses Native.Keys.pressesIn
  , Signal.map fromDowns Native.Keys.downsIn
  , Signal.map fromMeta Native.Keys.metaIn
  , Signal.map fromShift Native.Keys.shiftIn
  ]
