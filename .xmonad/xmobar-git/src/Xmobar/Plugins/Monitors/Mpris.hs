{-# LANGUAGE OverloadedStrings #-}

----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.Monitors.Mpris
-- Copyright   :  (c) Artem Tarasov
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Artem Tarasov <lomereiter@gmail.com>
-- Stability   :  unstable
-- Portability :  unportable
--
--   MPRIS song info
--
----------------------------------------------------------------------------

module Xmobar.Plugins.Monitors.Mpris ( mprisConfig, runMPRIS1, runMPRIS2 ) where

-- TODO: listen to signals

import Xmobar.Plugins.Monitors.Common

import Text.Printf (printf)

import DBus
import qualified DBus.Client as DC

import Control.Arrow ((***))
import Data.Maybe ( fromJust )
import Data.Int ( Int32, Int64 )
import Data.Word ( Word32 )
import System.IO.Unsafe ( unsafePerformIO )

import Control.Exception (try)

class MprisVersion a where
    getMethodCall :: a -> String -> MethodCall
    getMetadataReply :: a -> DC.Client -> String -> IO [Variant]
    getMetadataReply mv c p = fmap methodReturnBody (DC.call_ c $ getMethodCall mv p)
    fieldsList :: a -> [String]

data MprisVersion1 = MprisVersion1
instance MprisVersion MprisVersion1 where
    getMethodCall MprisVersion1 p = (methodCall objectPath interfaceName memberName)
        { methodCallDestination = Just busName
        }
        where
        busName       = busName_     $ "org.mpris." ++ p
        objectPath    = objectPath_    "/Player"
        interfaceName = interfaceName_ "org.freedesktop.MediaPlayer"
        memberName    = memberName_    "GetMetadata"

    fieldsList MprisVersion1 = [ "album", "artist", "arturl", "mtime", "title"
                               , "tracknumber" ]

data MprisVersion2 = MprisVersion2
instance MprisVersion MprisVersion2 where
    getMethodCall MprisVersion2 p = (methodCall objectPath interfaceName memberName)
        { methodCallDestination = Just busName
        , methodCallBody = arguments
        }
        where
        busName       = busName_     $ "org.mpris.MediaPlayer2." ++ p
        objectPath    = objectPath_    "/org/mpris/MediaPlayer2"
        interfaceName = interfaceName_ "org.freedesktop.DBus.Properties"
        memberName    = memberName_    "Get"
        arguments     = map (toVariant::String -> Variant)
                            ["org.mpris.MediaPlayer2.Player", "Metadata"]

    fieldsList MprisVersion2 = [ "xesam:album", "xesam:artist", "mpris:artUrl"
                               , "mpris:length", "xesam:title",
                                 "xesam:trackNumber", "xesam:composer",
                                 "xesam:genre"
                               ]

mprisConfig :: IO MConfig
mprisConfig = mkMConfig "<artist> - <title>"
                [ "album", "artist", "arturl", "length"
                , "title", "tracknumber" , "composer", "genre"
                ]

{-# NOINLINE dbusClient #-}
dbusClient :: DC.Client
dbusClient = unsafePerformIO DC.connectSession

runMPRIS :: (MprisVersion a) => a -> String -> [String] -> Monitor String
runMPRIS version playerName _ = do
    metadata <- io $ getMetadata version dbusClient playerName
    if null metadata then
      getConfigValue naString
      else mapM showWithPadding (makeList version metadata) >>= parseTemplate

runMPRIS1 :: String -> [String] -> Monitor String
runMPRIS1 = runMPRIS MprisVersion1

runMPRIS2 :: String -> [String] -> Monitor String
runMPRIS2 = runMPRIS MprisVersion2

---------------------------------------------------------------------------

fromVar :: (IsVariant a) => Variant -> a
fromVar = fromJust . fromVariant

unpackMetadata :: [Variant] -> [(String, Variant)]
unpackMetadata [] = []
unpackMetadata xs =
  (map (fromVar *** fromVar) . unpack . head) xs where
    unpack v = case variantType v of
                 TypeDictionary _ _ -> dictionaryItems $ fromVar v
                 TypeVariant -> unpack $ fromVar v
                 TypeStructure _ ->
                   let x = structureItems (fromVar v) in
                     if null x then [] else unpack (head x)
                 _ -> []

getMetadata :: (MprisVersion a) => a -> DC.Client -> String -> IO [(String, Variant)]
getMetadata version client player = do
    reply <- try (getMetadataReply version client player) ::
                            IO (Either DC.ClientError [Variant])
    return $ case reply of
                  Right metadata -> unpackMetadata metadata;
                  Left _ -> []

makeList :: (MprisVersion a) => a -> [(String, Variant)] -> [String]
makeList version md = map getStr (fieldsList version) where
            formatTime n = (if hh == 0 then printf "%02d:%02d"
                                       else printf "%d:%02d:%02d" hh) mm ss
                           where hh = (n `div` 60) `div` 60
                                 mm = (n `div` 60) `mod` 60
                                 ss = n `mod` 60
            pInt str v = let num = fromVar v in
                           case str of
                             "mtime" -> formatTime (num `div` 1000)
                             "tracknumber" -> printf "%02d" num
                             "mpris:length" -> formatTime (num `div` 1000000)
                             "xesam:trackNumber" -> printf "%02d" num
                             _ -> (show::Int32 -> String) num
            pw32 v = printf "%02d" (fromVar v::Word32)
            plen str v = let num = fromVar v in
                           case str of
                             "mpris:length" -> formatTime (num `div` 1000000)
                             _ -> (show::Int64 -> String) num
            getStr str = case lookup str md of
                Nothing -> ""
                Just v -> case variantType v of
                            TypeString -> fromVar v
                            TypeInt32 -> pInt str v
                            TypeWord32 -> pw32 v
                            TypeInt64 -> plen str v
                            TypeArray TypeString ->
                              let x = arrayItems (fromVar v) in
                                if null x then "" else fromVar (head x)
                            _ -> ""
