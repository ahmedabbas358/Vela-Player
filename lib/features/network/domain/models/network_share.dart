import 'package:flutter/material.dart';

enum NetworkProtocol {
  smb('SMB v2/v3 (Windows Share / NAS)', Icons.dns_rounded),
  webdav('WebDAV (Nextcloud / Cloud Storage)', Icons.cloud_queue_rounded),
  sftp('SFTP / SSH Secure Server', Icons.terminal_rounded),
  ftp('FTP Server', Icons.folder_shared_rounded),
  dlna('UPnP / DLNA Local Media Server', Icons.cast_connected_rounded),
  httpStream('HTTP / HTTPS Direct Stream', Icons.link_rounded),
  hlsStream('HLS / DASH Adaptive Stream (.m3u8 / .mpd)', Icons.live_tv_rounded);

  final String displayName;
  final IconData icon;
  const NetworkProtocol(this.displayName, this.icon);
}

/// Represents a remote network source configured by the user.
/// Passwords/tokens are never stored in plain text and are referenced via secureStorageKey.
class NetworkShare {
  final String id;
  final String name;
  final NetworkProtocol protocol;
  final String host;
  final int port;
  final String path;
  final String? username;
  final String secureStorageKey;
  final bool isConnected;
  final DateTime? lastConnectedAt;

  const NetworkShare({
    required this.id,
    required this.name,
    required this.protocol,
    required this.host,
    this.port = 445,
    this.path = '/',
    this.username,
    required this.secureStorageKey,
    this.isConnected = false,
    this.lastConnectedAt,
  });

  String get connectionUrl {
    switch (protocol) {
      case NetworkProtocol.smb:
        return 'smb://$host:$port$path';
      case NetworkProtocol.webdav:
        return 'https://$host:$port$path';
      case NetworkProtocol.sftp:
        return 'sftp://$host:$port$path';
      case NetworkProtocol.ftp:
        return 'ftp://$host:$port$path';
      case NetworkProtocol.dlna:
        return 'upnp://$host:$port$path';
      case NetworkProtocol.httpStream:
      case NetworkProtocol.hlsStream:
        return host;
    }
  }

  NetworkShare copyWith({
    String? id,
    String? name,
    NetworkProtocol? protocol,
    String? host,
    int? port,
    String? path,
    String? username,
    String? secureStorageKey,
    bool? isConnected,
    DateTime? lastConnectedAt,
  }) {
    return NetworkShare(
      id: id ?? this.id,
      name: name ?? this.name,
      protocol: protocol ?? this.protocol,
      host: host ?? this.host,
      port: port ?? this.port,
      path: path ?? this.path,
      username: username ?? this.username,
      secureStorageKey: secureStorageKey ?? this.secureStorageKey,
      isConnected: isConnected ?? this.isConnected,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
    );
  }
}
