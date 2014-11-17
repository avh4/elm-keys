module Keys (Key(..), KeyCombo(..), lastPressed) where

import Signal
import Native.Keys
import Either

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

fromCode : Int -> Maybe (Either.Either Key String)
fromCode code = case code of
  37 -> Just (Either.Left Left)
  38 -> Just (Either.Left Up)
  39 -> Just (Either.Left Right)
  40 -> Just (Either.Left Down)
  49 -> Just (Either.Right "1")
  50 -> Just (Either.Right "2")
  51 -> Just (Either.Right "3")
  52 -> Just (Either.Right "4")
  53 -> Just (Either.Right "5")
  54 -> Just (Either.Right "6")
  55 -> Just (Either.Right "7")
  65 -> Just (Either.Right "a")
  68 -> Just (Either.Right "d")
  77 -> Just (Either.Right "m")
  80 -> Just (Either.Right "p")
  _ -> Nothing

fromMeta : Int -> KeyCombo
fromMeta code = case fromCode code of
  Just (Either.Left key) -> Command key
  Just (Either.Right char) -> CommandCharacter char
  Nothing -> Unrecognized ("Meta-" ++ show code)

fromShift : Int -> KeyCombo
fromShift code = case fromCode code of
  Just (Either.Left key) -> Shift key
  Just (Either.Right char) -> Unrecognized ("Shift-" ++ show code ++ " shft-down event for a normal key?!") -- TODO: should never happen
  Nothing -> Unrecognized ("Shift-" ++ show code)

lastPressed : Signal KeyCombo
lastPressed = Signal.merges
  [ fromPresses <~ Native.Keys.pressesIn
  , fromDowns <~ Native.Keys.downsIn
  , fromMeta <~ Native.Keys.metaIn
  , fromShift <~ Native.Keys.shiftIn
  ]
