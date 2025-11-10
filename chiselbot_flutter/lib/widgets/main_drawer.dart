import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_router.dart';
import '../providers/auth_notifier.dart';
import '../providers/storage_providers.dart';
import 'user_avatar.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (userName, userEmail, _, isLoggedIn) =
        ref.watch(currentUserInfoProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final state = ref.watch(storageListProvider);
    return Drawer(
      backgroundColor: Colors.grey[900],
      width: screenWidth * .85,
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const UserAvatar(radius: 24),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: isLoggedIn
                          ? null
                          : () {
                              Navigator.pop(context);
                              Navigator.of(context).pushNamed(RoutePaths.login);
                            },
                      child: Text(
                        userEmail,
                        style: TextStyle(
                          color: isLoggedIn ? Colors.white70 : Colors.blue,
                          fontSize: 14,
                          decoration:
                              isLoggedIn ? null : TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade800, indent: 16, endIndent: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '면접 보관함',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: Builder(
              builder: (_) {
                if (state.loading && state.items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null && state.items.isEmpty) {
                  return Center(
                    child: Text('목록 오류: ${state.error}',
                        style: const TextStyle(color: Colors.white)),
                  );
                }
                if (state.items.isEmpty) {
                  return const Center(
                    child: Text('보관된 항목이 없습니다.',
                        style: TextStyle(color: Colors.white70)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (_, i) {
                    final it = state.items[i];
                    return TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.of(context).pushNamed(
                          RoutePaths.storageDetail,
                          arguments: it.storageId,
                        );
                      },
                      style:
                          TextButton.styleFrom(alignment: Alignment.centerLeft),
                      child: Text(
                        "[${it.categoryName}/${it.interviewLevel}] ${it.questionText}",
                        style: const TextStyle(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(color: Colors.grey.shade800, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed('/settings');
                },
                child: const Icon(Icons.settings, color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
