{-# LANGUAGE OverloadedStrings #-}
module Main where

import Protolude hiding (link, on)
import Reflex.Dom hiding (WebSocket)

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
import GHCJS.DOM.WebSocket
import GHCJS.DOM.Navigator
import GHCJS.DOM
import Language.Javascript.JSaddle.Value
import Language.Javascript.JSaddle.Types
import JavaScript.Object

main = mainWidget $ do
  testWidget

testWidget = do
  text "hello"
  liftIO $ do
    wsConn <- newWebSocket ("ws://localhost:3000/" :: Protolude.Text) ([] :: [Protolude.Text])
    mediaStr <- audioSetup
    processor <- getScriptProcessorNode mediaStr
    _ <- liftIO $ on processor audioProcess (onAudioProcess wsConn)
    putStrLn ("MediaStream Setup Done" :: Protolude.Text)
    return ()

audioSetup :: MonadDOM m => m (MediaStream)
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
  GHCJS.DOM.MediaDevices.getUserMedia devices (Just constraints)

getScriptProcessorNode :: MonadDOM m => MediaStream -> m (ScriptProcessorNode)
getScriptProcessorNode mediaStream = do
  -- newAudioContext :: MonadDOM m => m AudioContext
  context <- newAudioContext

  strSrc <- createMediaStreamSource context mediaStream

  let bufferSize = 0
  processor <- createScriptProcessor context bufferSize (Just 1) (Just 1)

  connect strSrc processor Nothing Nothing
  return processor

onAudioProcess :: WebSocket -> EventM ScriptProcessorNode AudioProcessingEvent ()
onAudioProcess wsConn = do
  putStrLn ("Start Audio Process" :: Protolude.Text)
  aEv <- ask
  callBackListener aEv wsConn

callBackListener :: MonadDOM m => AudioProcessingEvent -> WebSocket -> m ()
callBackListener e wsConn = do
  -- getInputBuffer :: MonadDOM m => AudioProcessingEvent -> m AudioBuffer
  buf <- getInputBuffer e
  -- getChannelData :: MonadDOM m => AudioBuffer -> Word -> m Float32Array
  d <- getChannelData buf 0
  send wsConn (ArrayBuffer $ unFloat32Array d)
