module Keys (Key(..), KeyCombo(..), lastPressed) where

import Signal
import Native.Keys

data Key
  = Enter | Backspace
  | Left | Right | Up | Down

data KeyCombo
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
  _ -> Unrecognized (show code)

fromMeta : Int -> KeyCombo
fromMeta code = case code of
  37 -> Command Left
  38 -> Command Up
  39 -> Command Right
  40 -> Command Down
  49 -> CommandCharacter "1"
  50 -> CommandCharacter "2"
  51 -> CommandCharacter "3"
  52 -> CommandCharacter "4"
  53 -> CommandCharacter "5"
  54 -> CommandCharacter "6"
  55 -> CommandCharacter "7"
  65 -> CommandCharacter "a"
  68 -> CommandCharacter "d"
  77 -> CommandCharacter "m"
  80 -> CommandCharacter "p"
  _ -> Unrecognized ("Meta-" ++ show code)

lastPressed : Signal KeyCombo
lastPressed = Signal.merges
  [ fromPresses <~ Native.Keys.pressesIn
  , fromDowns <~ Native.Keys.downsIn
  , fromMeta <~ Native.Keys.metaIn
  ]
