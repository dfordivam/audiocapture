{-# LANGUAGE OverloadedStrings #-}
module Main where

import Protolude
import Network.Wai
import Network.Wai.Handler.Warp
import Network.Wai.Handler.WebSockets
import Network.WebSockets
import Network.HTTP.Types.Status
import qualified Data.Map as Map
import Data.ByteString

main :: IO ()
main = do
  runEnv 3000 app
app =
  websocketsOr defaultConnectionOptions wsApp backupApp
  where
    -- wsApp :: ServerApp
    wsApp pending_conn = do
      conn <- acceptRequest pending_conn
      loop conn

    loop conn = do
      d <- receiveData conn
      let
        h :: ByteString -> IO ()
        h d = print $ Data.ByteString.length d
      h d
      loop conn

    backupApp :: Application
    backupApp _ respond = respond $ responseLBS status400 [] "Not a WebSocket request"
