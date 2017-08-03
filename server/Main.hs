module Main where

import Protolude
import Network.Wai
import Network.Wai.Handler.Warp
import Network.Wai.Handler.WebSockets
import Network.WebSockets
import Network.HTTP.Types.Status
import qualified Data.Map as Map


main :: IO ()
main =
  websocketsOr defaultConnectionOptions wsApp backupApp
  where
    -- wsApp :: ServerApp
    wsApp pending_conn = do
      conn <- acceptRequest pending_conn
      loop conn

    loop conn = do
      d <- receiveData conn
      print $ length d
      -- let
      --     rwst = handleRequest handler d

      -- hState <- readIORef handlerStateRef
      -- (resp, newState, _) <- runRWST rwst dbConn hState
      -- writeIORef handlerStateRef newState

      -- print resp
      -- sendBinaryData conn resp
      loop conn

    backupApp :: Application
    backupApp _ respond = respond $ responseLBS status400 [] "Not a WebSocket request"
