package com.velaplayer.app.playback

import android.content.Intent
import androidx.annotation.OptIn
import androidx.media3.common.util.UnstableApi
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.session.MediaSession
import androidx.media3.session.MediaSessionService

/**
 * Vela MediaSessionService — Official AndroidX Media3 1.11.0 implementation
 * Provides seamless background audio/video playback, notification controls,
 * lock screen media controls, and Bluetooth headset integration with foregroundServiceType="mediaPlayback".
 */
class VelaMediaSessionService : MediaSessionService() {

    companion object {
        var activePlayer: ExoPlayer? = null
        var activeSession: MediaSession? = null
    }

    private var fallbackSession: MediaSession? = null

    @OptIn(UnstableApi::class)
    override fun onCreate() {
        super.onCreate()
        if (activeSession == null) {
            val player = activePlayer ?: ExoPlayer.Builder(this)
                .setHandleAudioBecomingNoisy(true)
                .build()
            activePlayer = player
            fallbackSession = MediaSession.Builder(this, player).build()
            activeSession = fallbackSession
        }
    }

    override fun onGetSession(controllerInfo: MediaSession.ControllerInfo): MediaSession? {
        return activeSession ?: fallbackSession
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        val player = (activeSession ?: fallbackSession)?.player
        if (player == null || !player.playWhenReady || player.mediaItemCount == 0) {
            stopSelf()
        }
    }

    override fun onDestroy() {
        fallbackSession?.run {
            player.release()
            release()
            fallbackSession = null
        }
        if (activeSession == fallbackSession) {
            activeSession = null
            activePlayer = null
        }
        super.onDestroy()
    }
}
