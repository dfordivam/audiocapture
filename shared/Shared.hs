{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}

module Shared
  where

import Protolude
-- import GHC.Generics
import Data.Aeson
import Data.ByteString
import Data.Default
import Data.Time (UTCTime)
import Reflex.Dom.WebSocket.Message

-- Messages

type AppRequest = GetWavDataStats :<|> GetWavDataStats2


data GetWavDataStats = GetWavDataStats ByteString
  deriving (Generic, Show, FromJSON, ToJSON)

data WavDataStats = WavDataStats Int
  deriving (Generic, Show, FromJSON, ToJSON)

instance WebSocketMessage AppRequest GetWavDataStats where
  type ResponseT AppRequest GetWavDataStats = WavDataStats

data GetWavDataStats2 = GetWavDataStats2 ByteString
  deriving (Generic, Show, FromJSON, ToJSON)

instance WebSocketMessage AppRequest GetWavDataStats2 where
  type ResponseT AppRequest GetWavDataStats2 = WavDataStats
