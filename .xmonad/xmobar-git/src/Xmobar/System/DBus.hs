-----------------------------------------------------------------------------
-- |
-- Module      :  DBus
-- Copyright   :  (c) Jochen Keil
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Jochen Keil <jochen dot keil at gmail dot com>
-- Stability   :  unstable
-- Portability :  unportable
--
-- DBus IPC module for Xmobar
--
-----------------------------------------------------------------------------

module Xmobar.System.DBus (runIPC) where

import DBus
import DBus.Client hiding (interfaceName)
import qualified DBus.Client as DC
import Data.Maybe (isNothing)
import Control.Concurrent.STM
import Control.Exception (handle)
import System.IO (stderr, hPutStrLn)
import Control.Monad.IO.Class (liftIO)

import Xmobar.System.Signal

busName :: BusName
busName = busName_ "org.Xmobar.Control"

objectPath :: ObjectPath
objectPath = objectPath_ "/org/Xmobar/Control"

interfaceName :: InterfaceName
interfaceName = interfaceName_ "org.Xmobar.Control"

runIPC :: TMVar SignalType -> IO ()
runIPC mvst = handle printException exportConnection
    where
    printException :: ClientError -> IO ()
    printException = hPutStrLn stderr . clientErrorMessage
    exportConnection = do
        client <- connectSession
        requestName client busName [ nameDoNotQueue ]
        export client objectPath defaultInterface
          { DC.interfaceName = interfaceName
          , DC.interfaceMethods = [ sendSignalMethod mvst ]
          }

sendSignalMethod :: TMVar SignalType -> Method
sendSignalMethod mvst = makeMethod sendSignalName
    (signature_ [variantType $ toVariant (undefined :: SignalType)])
    (signature_ [])
    sendSignalMethodCall
    where
    sendSignalName :: MemberName
    sendSignalName = memberName_ "SendSignal"

    sendSignalMethodCall :: MethodCall -> DBusR Reply
    sendSignalMethodCall mc = liftIO $
        if methodCallMember mc == sendSignalName
          then do
            let signals :: [Maybe SignalType]
                signals = map fromVariant (methodCallBody mc)
            mapM_ sendSignal signals
            if any isNothing signals
              then return ( ReplyError errorInvalidParameters [] )
              else return ( ReplyReturn [] )
          else
            return ( ReplyError errorUnknownMethod [] )

    sendSignal :: Maybe SignalType -> IO ()
    sendSignal = maybe (return ()) (atomically . putTMVar mvst)
