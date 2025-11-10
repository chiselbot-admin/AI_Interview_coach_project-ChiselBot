import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_notifier.dart';

class UserAvatar extends ConsumerWidget {
  final double radius;

  const UserAvatar({
    super.key,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (userName, _, profileImageUrl, _) =
        ref.watch(currentUserInfoProvider);
    final bool hasProfileImage =
        profileImageUrl != null && profileImageUrl.isNotEmpty;
    final Color avatarBackgroundColor = hasProfileImage
        ? Colors.transparent // 이미지가 있으면 투명
        : _getPastelColor(userName); // 이미지가 없으면 파스텔 색상 사용
    return CircleAvatar(
      radius: radius,
      backgroundColor: avatarBackgroundColor,
      backgroundImage: hasProfileImage ? NetworkImage(profileImageUrl!) : null,
      child: !hasProfileImage
          ? (userName != '개발자'
              ? Text(
                  userName[0].toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: radius * 0.8,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : Icon(Icons.person, color: Colors.white, size: radius * 1.2))
          : null,
    );
  }

  Color _getPastelColor(String text) {
    final hash = text.hashCode.abs();
    final pastelColors = [
      Color(0xFFD4A373), // 카라멜 브라운
      Color(0xFFB08968), // 따뜻한 베이지
      Color(0xFFE07A5F), // 테라코타
      Color(0xFF81B29A), // 세이지 그린
      Color(0xFFC4A77D), // 밀크 카페
      Color(0xFFBC8A5F), // 헤이즐넛
      Color(0xFF9C6644), // 시나몬
    ];
    return pastelColors[hash % pastelColors.length];
  }
}
