{-# LANGUAGE CPP #-}
{-# LANGUAGE DoAndIfThenElse #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Plugins.DateZone
-- Copyright   :  (c) Martin Perner
-- License     :  BSD-style (see LICENSE)
--
-- Maintainer  :  Martin Perner <martin@perner.cc>
-- Stability   :  unstable
-- Portability :  unportable
--
-- A date plugin with localization and location support for Xmobar
--
-- Based on Plugins.Date
--
-- Usage example: in template put
--
-- > Run DateZone "%a %H:%M:%S" "de_DE.UTF-8" "UTC" "utcDate" 10
--
-----------------------------------------------------------------------------

module Xmobar.Plugins.DateZone (DateZone(..)) where

import Xmobar.Run.Exec

#ifdef DATEZONE
import Control.Concurrent.STM

import System.IO.Unsafe
import System.Environment (lookupEnv)

import Data.Maybe (fromMaybe)

import Data.Time.Format
import Data.Time.LocalTime
import Data.Time.LocalTime.TimeZone.Olson
import Data.Time.LocalTime.TimeZone.Series

import Xmobar.System.Localize

#if ! MIN_VERSION_time(1,5,0)
import System.Locale (TimeLocale)
#endif
#else
import System.IO
import Xmobar.Plugins.Date
#endif



data DateZone = DateZone String String String String Int
    deriving (Read, Show)

instance Exec DateZone where
    alias (DateZone _ _ _ a _) = a
#ifndef DATEZONE
    start (DateZone f _ _ a r) cb = do
      hPutStrLn stderr $ "Warning: DateZone plugin needs -fwith_datezone."++
                  " Using Date plugin instead."
      start (Date f a r) cb
#else
    start (DateZone f l z _ r) cb = do
      lock <- atomically $ takeTMVar localeLock
      setupTimeLocale l
      locale <- getTimeLocale
      atomically $ putTMVar localeLock lock
      if z /= "" then do
        tzdir <- lookupEnv "TZDIR"
        timeZone <- getTimeZoneSeriesFromOlsonFile ((fromMaybe "/usr/share/zoneinfo" tzdir) ++ "/" ++ z)
        go (dateZone f locale timeZone)
       else
        go (date f locale)

      where go func = doEveryTenthSeconds r $ func >>= cb

{-# NOINLINE localeLock #-}
-- ensures that only one plugin instance sets the locale
localeLock :: TMVar Bool
localeLock = unsafePerformIO (newTMVarIO False)

date :: String -> TimeLocale -> IO String
date format loc = getZonedTime >>= return . formatTime loc format

dateZone :: String -> TimeLocale -> TimeZoneSeries -> IO String
dateZone format loc timeZone = getZonedTime >>= return . formatTime loc format . utcToLocalTime' timeZone . zonedTimeToUTC
--   zonedTime <- getZonedTime
--   return $ formatTime loc format $ utcToLocalTime' timeZone $ zonedTimeToUTC zonedTime
#endif
