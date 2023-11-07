module Main where

import Data.Aeson
import Data.Text
import qualified Data.Text.IO as TIO
import qualified Data.Text.Encoding as TE

main :: IO ()
main = do
    putStrLn "Hello, Haskell!"
    TIO.putStrLn "I want to create app for interacting with traccar api for devices and create monitoring system for it"
    TIO.putStrLn "Generated code from OpenAI:"
    TIO.putStrLn (TE.decodeUtf8 (encode generatedCode))
