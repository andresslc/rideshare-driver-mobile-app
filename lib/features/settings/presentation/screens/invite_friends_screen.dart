import 'package:driver_app/core/core.dart';
import 'package:driver_app/shared/shared.dart';
import 'package:driver_app/shared/widgets/app_gradient_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../user_profile/presentation/providers/user_profile_provider.dart';
import '../../../user_profile/presentation/states/user_states.dart';

class InviteFriendsScreen extends ConsumerStatefulWidget {
  const InviteFriendsScreen({super.key});

  @override
  ConsumerState<InviteFriendsScreen> createState() =>
      _InviteFriendsScreenState();
}

class _InviteFriendsScreenState extends ConsumerState<InviteFriendsScreen> {
  static const _fallbackLink = 'example.com/invite';
  late final TextEditingController _controller;
  ProviderSubscription<UserProfileState>? _profileListener;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _fallbackLink);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = ref.read(userProfileProvider);
      _setReferralLink(profileState.profile?.user.referralLink);

      if (profileState.profile == null) {
        ref.read(userProfileProvider.notifier).fetchProfile(force: true);
      }
    });

    _profileListener = ref.listenManual(userProfileProvider, (previous, next) {
      if (!mounted) return;

      // Show new errors
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        context.showErrorToast(next.errorMessage!);
        ref.read(userProfileProvider.notifier).clearMessages();
      }

      _setReferralLink(next.profile?.user.referralLink);
    });
    
  }

  @override
  void dispose() {
    _profileListener?.close();
    _controller.dispose();
    super.dispose();
  }

  void copylinked() {
    Clipboard.setData(ClipboardData(text: _controller.text)).then((_) {
      // ignore: use_build_context_synchronously
      context.showToast(context.l10n.link_copied);
    });
  }

  void _setReferralLink(String? link) {
    final normalized = link?.trim();
    final text = (normalized?.isNotEmpty ?? false)
        ? normalized!
        : _fallbackLink;
    if (_controller.text != text) {
      if (!mounted) return;
      setState(() {
        _controller.text = text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.invite_drawer), centerTitle: true),
      // invite_friend
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(8.0).copyWith(bottom: kToolbarHeight),
          child: AppButton(text: l10n.copy_link, onPressed: () => copylinked()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // "Invitation Link" on right
          Text(l10n.invitation_link, style: context.textTheme.labelMedium),
          const SizedBox(height: 8),
          AppGradientBox(
            padding: EdgeInsets.all(8),
            cornerRadius: 12,
            child: Text(
              _controller.text,
              // overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
