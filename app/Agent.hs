{-# LANGUAGE TemplateHaskell, GADTs #-}

module Agent where

import Prelude

import Control.Monad (forM_)
import Data.Text (Text)
import qualified Data.Text.IO as TIO
import System.Directory (listDirectory, doesFileExist)
import System.FilePath ((</>))
import System.Process (callCommand)

fixGeneratedProjects :: IO ()
fixGeneratedProjects = do
    -- Get a list of all the directories in the current directory
    dirs <- listDirectory "."
    -- For each directory, check if it contains a `main.hs` file
    forM_ dirs $ \dir -> do
        let mainFile = dir </> "main.hs"
        mainFileExists <- doesFileExist mainFile
        -- If the `main.hs` file exists, run the fuse command to fix it
        when mainFileExists $ do
            let fuseCommand = "fuse fix " ++ mainFile
            callCommand fuseCommand
    -- Print a message to indicate that the process is complete
    TIO.putStrLn "Generated projects have been fixed."
