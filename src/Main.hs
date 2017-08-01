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
-- import GHCJS.Marshal (toJSVal_aeson)
import GHCJS.DOM
import Data.Aeson
import Data.Aeson.Types
import Language.Javascript.JSaddle.Value
import Language.Javascript.JSaddle.Types
import JavaScript.Object
main = mainWidget $ do
  testWidget
  -- let url = "ws://localhost:3000/"
  -- withWSConnection
  --   url
  --   never -- close event
  --   True -- reconnect
  --   topWidget
  -- return ()

-- topWidget
--   :: (MonadWidget t m, DomBuilderSpace m ~ GhcjsDomSpace, PrimMonad m)
--   => WithWebSocketT Message.AppRequest t m ()
-- topWidget = divClass "ui container" $ do
--   text "Welcome"
--   -- navigation with visibility control

testWidget = do
  text "hello"
  liftIO audioSetup

-- getUserMedia :: MonadDOM m => MediaDevices -> Maybe MediaStreamConstraints -> m MediaStream

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
-- $("#start-rec-btn").click(function () {
--         close();
--         client = new BinaryClient('wss://'+location.host);
--         client.on('open', function () {
--             bStream = client.createStream({sampleRate: resampleRate});
--         });

--         if (context) {
--             recorder.connect(context.destination);
--             return;
--         }

--         var session = {
--             audio: true,
--             video: false
--         };


--         navigator.getUserMedia(session, function (stream) {
--             context = new AudioContext();
--             var audioInput = context.createMediaStreamSource(stream);
--             var bufferSize = 0; // let implementation decide

--             recorder = context.createScriptProcessor(bufferSize, 1, 1);

--             recorder.onaudioprocess = onAudio;

--             audioInput.connect(recorder);

--             recorder.connect(context.destination);

--         }, function (e) {

--         });
-- });

myGetUserMedia :: MonadDOM m => MediaStream -> m ()
myGetUserMedia mediaStream = do
  -- newAudioContext :: MonadDOM m => m AudioContext
  context <- newAudioContext

  -- createMediaStreamSource :: (MonadDOM m, IsAudioContext self) => self -> MediaStream -> m MediaStreamAudioSourceNode
  strSrc <- createMediaStreamSource context mediaStream

  -- This example creates an oscillator, then links it to a gain node, so that the gain node controls the volume of the oscillator node.
  -- createOscillator :: (MonadDOM m, IsAudioContext self) => self -> m OscillatorNode
  -- createGain :: (MonadDOM m, IsAudioContext self) => self -> m GainNode
  -- oscNode <- createOscillator context
  -- gainNode <- createGain context
  -- connect strSrc oscNode Nothing Nothing
  -- connect oscNode gainNode Nothing Nothing


  -- createScriptProcessor :: (MonadDOM m, IsAudioContext self) => self -> Word -> Maybe Word -> Maybe Word -> m ScriptProcessorNode
  -- The buffer size in units of sample-frames. If specified, the bufferSize must be one of the following values: 256, 512, 1024, 2048, 4096, 8192, 16384. If it's not passed in, or if the value is 0, then the implementation will choose the best buffer size for the given environment, which will be a constant power of 2 throughout the lifetime of the node.
  -- Number on Input and output channel = 1

  let bufferSize = 0
  processor <- createScriptProcessor context bufferSize (Just 1) (Just 1)

  connect strSrc processor Nothing Nothing

  _ <- liftIO $ on processor audioProcess onAudioProcess
  return ()

  -- createMediaStreamDestination :: (MonadDOM m, IsAudioContext self) => self -> m MediaStreamAudioDestinationNode
  -- destination <- createMediaStreamDestination context
  -- getStream destination
  -- -- https://developer.mozilla.org/en-US/docs/Web/API/AudioNode/connect
  -- connect :: (MonadDOM m, IsAudioNode self, IsAudioNode destination) => self -> destination -> Maybe Word -> Maybe Word -> m ()

  -- connect strSrc destination Nothing Nothing

onAudioProcess :: EventM ScriptProcessorNode AudioProcessingEvent ()
onAudioProcess = do
  aEv <- ask
  callBackListener aEv


callBackListener :: MonadDOM m => AudioProcessingEvent -> m ()
callBackListener e = do
  -- getInputBuffer :: MonadDOM m => AudioProcessingEvent -> m AudioBuffer
  buf <- getInputBuffer e
  -- getChannelData :: MonadDOM m => AudioBuffer -> Word -> m Float32Array
  d <- getChannelData buf 0
  Protolude.print ("Got Channel Data")


  -- createScriptProcessor :: (MonadDOM m, IsAudioContext self) => self -> Word -> Maybe Word -> Maybe Word -> m ScriptProcessorNode

-- audioProcess :: EventName ScriptProcessorNode AudioProcessingEvent
-- audioProcess = unsafeEventName (toJSString "audioprocess")

-- type EventM t e = ReaderT e IO

-- on :: (IsEventTarget t, IsEvent e)
--    => t             -- ^ target
--    -> EventName t e -- ^ event
--    -> EventM t e () -- ^ action
--    -> IO (IO ())    -- ^ @IO@ action that removes the listener from the element
