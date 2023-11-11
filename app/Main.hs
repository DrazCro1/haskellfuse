{-# LANGUAGE OverloadedStrings #-}

module Main where

import Network.HTTP.Simple
import Data.Aeson
import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import qualified Data.Text.Encoding as TE  -- Import Data.Text.Encoding
import System.Directory (createDirectory)
import System.IO (stdout, hSetBuffering, BufferMode (LineBuffering))
import System.Process (callProcess)
import System.Random (randomRIO)
import Control.Monad (replicateM)

-- Function to generate a random string
randomString :: Int -> IO String
randomString len = replicateM len $ randomRIO ('a', 'z')

-- OpenAI API key
apiKey :: Text
apiKey = "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"

-- GPT-3 endpoint
endpoint :: String
endpoint = "https://api.openai.com/v1/engines/gpt-3.5-turbo/completions"

main :: IO ()
main = do 
    hSetBuffering stdout LineBuffering

    TIO.putStrLn "Welcome to Haskell Project Generator!"
    TIO.putStrLn "Please provide a prompt to generate Haskell code:"
    userPrompt <- TIO.getLine

    -- Create a Haskell project based on the user's input
    createHaskellProject userPrompt

-- Define the data you want
createHaskellProject :: Text -> IO ()
createHaskellProject userPrompt = do
    let requestData = object
            [ "prompt" .= userPrompt
            , "max_tokens" .= (100 :: Int)
            ]

    -- Send a request to the GPT-3 API
    request <- parseRequest endpoint
    let request' = setRequestMethod "POST"
            $ setRequestHeader "Authorization" ["Bearer " <> TE.encodeUtf8 apiKey]
            $ setRequestBodyJSON requestData
            $ request

    response <- httpJSON request'
    let generatedCode = getResponseBody response :: Value

    TIO.putStrLn "Received response:"
    TIO.putStrLn (generateMainCode userPrompt generatedCode)

       -- Generate a random string to use as the directory name
    dirName <- randomString 10

    -- Create a Haskell project directory
    TIO.putStrLn "Creating Haskell project directory:"
    createDirectory dirName

    -- Create Haskell files and write generated code
    let mainPath = dirName ++ "/Main.hs"
    let readmePath = dirName ++ "/README.md"
    TIO.writeFile mainPath $ generateMainCode userPrompt generatedCode
    TIO.writeFile readmePath "Welcome to My Haskell Project!"

    TIO.putStrLn "Haskell project files created successfully:"

    -- Build the Haskell project (You can customize this part based on your build process)
    TIO.putStrLn "Building Haskell project:"
    let appPath = dirName ++ "/my_haskell_app3"
    callProcess "ghc" ["-o", appPath, mainPath]
    TIO.putStrLn "Haskell project built successfully:"


-- Helper function to generate Main.hs code with the user's prompt and the generated code
generateMainCode :: Text -> Value -> Text
generateMainCode userPrompt generatedCode = T.unlines
    [ "module Main where"
    , ""
    , "import Data.Aeson"
    , "import Data.Text"
    , "import qualified Data.Text.IO as TIO"
    , "import qualified Data.Text.Encoding as TE"
    , ""
    , "main :: IO ()"
    , "main = do"
    , "    putStrLn \"Hello, Haskell!\""
    , "    TIO.putStrLn \"" <> userPrompt <> "\""
    , "    TIO.putStrLn \"Generated code from OpenAI:\""
    , "    TIO.putStrLn (TE.decodeUtf8 (encode generatedCode))"
    ]
