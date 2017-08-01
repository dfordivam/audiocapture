{-# LANGUAGE OverloadedStrings #-}
module Main where

import Protolude hiding (link, on)
import Reflex.Dom

import Reflex.Dom.WebSocket.Monad
import Reflex.Dom.WebSocket.Message
import Reflex.Dom.SemanticUI
import Control.Monad.Primitive
import qualified Data.Map as Map
import Control.Lens
import Control.Monad.Fix

import GHCJS.DOM.AudioBuffer hiding (getGain)
import GHCJS.DOM.ScriptProcessorNode
import GHCJS.DOM.AudioProcessingEvent
import GHCJS.DOM.AudioNode
import GHCJS.DOM.Types
import GHCJS.DOM.EventM
import GHCJS.DOM.AudioContext
import GHCJS.DOM.AudioContext
import GHCJS.DOM.Window
import GHCJS.DOM.MediaDevices
import GHCJS.DOM.Navigator
import GHCJS.DOM
import Data.Aeson
import Data.Aeson.Types
import Language.Javascript.JSaddle.Value
import Language.Javascript.JSaddle.Types
import JavaScript.Object

main = mainWidget $ do
  testWidget

testWidget = do
  text "hello"
  liftIO audioSetup

audioSetup :: MonadDOM m => m ()
audioSetup = do
  win <- currentWindowUnchecked
  nav <- getNavigator win

  devices <- getMediaDevices nav

  v <- liftIO $ do
    o <- create
    t <- toJSVal True
    setProp "audio" t o
    toJSVal (ValObject o)

  let constraints = MediaStreamConstraints v
  media <- GHCJS.DOM.MediaDevices.getUserMedia devices (Just constraints)
  myGetUserMedia media

myGetUserMedia :: MonadDOM m => MediaStream -> m ()
myGetUserMedia mediaStream = do
  -- newAudioContext :: MonadDOM m => m AudioContext
  context <- newAudioContext

  strSrc <- createMediaStreamSource context mediaStream

  let bufferSize = 0
  processor <- createScriptProcessor context bufferSize (Just 1) (Just 1)

  connect strSrc processor Nothing Nothing

  _ <- liftIO $ on processor audioProcess onAudioProcess
  putStrLn ("Setup Done" :: Protolude.Text)
  return ()

onAudioProcess :: EventM ScriptProcessorNode AudioProcessingEvent ()
onAudioProcess = do
  putStrLn ("Start Audio Process" :: Protolude.Text)
  aEv <- ask
  callBackListener aEv

callBackListener :: MonadDOM m => AudioProcessingEvent -> m ()
callBackListener e = do
  -- getInputBuffer :: MonadDOM m => AudioProcessingEvent -> m AudioBuffer
  buf <- getInputBuffer e
  -- getChannelData :: MonadDOM m => AudioBuffer -> Word -> m Float32Array
  d <- getChannelData buf 0
  putStrLn ("Got Channel Data" :: Protolude.Text)
