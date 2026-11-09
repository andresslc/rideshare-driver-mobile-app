import 'package:driver_app/core/params/auth_params.dart'
    show SendOtpParams;
import 'package:driver_app/features/auth/presentation/states/auth_state.dart';
import 'package:driver_app/shared/widgets/loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/constants_data.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/extensions/strings_extensions.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../core/navigation/routes.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/shared.dart';
import '../../../../shared/widgets/custom_dialogue.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({
    super.key,
    this.warningId,
    this.sessionExpiredId,
    this.sessionExpiredMessage,
  });

  final String? warningId;
  final String? sessionExpiredId;
  final String? sessionExpiredMessage;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final CustomLoader loader = CustomLoader();

  Widget _buildDriverOnboardingInfo(
    AppLocalizations l10n,
    BuildContext context,
  ) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.driver_onboarding_title,
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.driver_onboarding_message,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                l10n.driver_onboarding_visit_label,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: () async {
                  final url = remoteConfigModel.websiteURL;
                  final uri = Uri.tryParse(url);
                  if (uri != null) {
                    final launched = await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                    if (!launched && context.mounted) {
                      context.showToast('Unable to open link.');
                    }
                  } else {
                    if (context.mounted) {
                      context.showToast('Invalid URL.');
                    }
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.click_here,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: colors.link,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      // _phoneController.text = '3020329435';
      // _phoneController.text = '3001234569';
      _phoneController.text = '334 333 2975';
      // _phoneController.text = '1000000077';
      // _phoneController.text = '3001234569';
      //  '11234567899'
    }
    _scheduleEntryDialog();
  }

  @override
  void didUpdateWidget(covariant LoginScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final warningChanged =
        widget.warningId != null && widget.warningId != oldWidget.warningId;
    final sessionChanged =
        widget.sessionExpiredId != null &&
        widget.sessionExpiredId != oldWidget.sessionExpiredId;

    if (warningChanged || sessionChanged) {
      _scheduleEntryDialog();
    }
  }

  void _scheduleEntryDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      if (widget.sessionExpiredId != null) {
        _showSessionExpiredDialog();
        return;
      }

      if (widget.warningId != null) {
        _showAccountWarningDialog();
      }
    });
  }

  void _showAccountWarningDialog() {
    showDialog(
      context: context,
      builder: (_) => CustomDialogue(
        title: context.l10n.driverAccountNotFound,
        subtitle: context.l10n.driverAccountNotCreatedWeb,
        icon: Icons.info_outline_rounded,
      ),
    );
  }

  void _showSessionExpiredDialog() {
    final backendMessage = widget.sessionExpiredMessage?.trim();
    final message = backendMessage != null && backendMessage.isNotEmpty
        ? backendMessage
        : context.l10n.session_expired;

    showDialog(
      context: context,
      builder: (_) => CustomDialogue(
        title: context.l10n.session_expired,
        subtitle: message,
        icon: Icons.lock_outline_rounded,
        buttons: [
          AppButton(
            text: context.l10n.ok,
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: context.appColors.brand,
            fontColor: Colors.white,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void onLogin() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final String rawNumber = _phoneController.text.trim();

    String digitsOnly = rawNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // if (digitsOnly.startsWith('1')) {
    //   digitsOnly = digitsOnly.substring(1);
    // }

    // final formattedNumber = digitsOnly;

    ref
        .read(authProvider.notifier)
        .sendOtp(
          // SendOtpParams(phone: formattedNumber),
          SendOtpParams(phone: digitsOnly, countryCode: kDebugMode ? '1' : '1'),
          // onError: (msg) {
          //   context.hideLoader();
          //   context.showToast(msg);
          // },
          // onSuccess: (user) {
          //   context.hideLoader();
          //   context.goNamed(Routes.verification.name, extra: formattedNumber);
          // },
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;
    ref.listen<AuthState>(authProvider, (previous, next) {
      switch (next) {
        case AuthLoading():
          loader.showLoader(context);
          break;
        case AuthError(:final message):
          loader.hideLoader();
          context.showToast(message);
          break;

        case OtpSent():
          final String rawNumber = _phoneController.text.trim();
          String digitsOnly = rawNumber.replaceAll(RegExp(r'[^0-9]'), '');
          loader.hideLoader();
          context.pushNamed(
            Routes.verification.name,
            extra: digitsOnly,
            // _phoneController.text.trim(),
          );
          break;

        default:
          loader.hideLoader();
          break;
      }
    });

    return AppScaffold(
      padding: const EdgeInsets.all(0),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      safeArea: false,
      child: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppSizes.p64),
                          Image.asset(AppImages.logo, height: 144, width: 144)
                              .animate()
                              .fadeIn(duration: 1500.ms)
                              .scale(begin: const Offset(0.8, 0.8)),
                          const SizedBox(height: AppSizes.p24),
                          AuthHeader(
                                title: l10n.welcome_back,
                                subtitle: l10n.login_subtitle,
                              )
                              .animate()
                              .fadeIn(duration: 1500.ms)
                              .scale(begin: const Offset(0.8, 0.8)),
                          const SizedBox(height: AppSizes.p24),
                          PhoneNumberField(
                            controller: _phoneController,
                            hintText: l10n.add_phone_number,
                          ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),

                          const SizedBox(height: AppSizes.p24),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _phoneController,
                            builder: (context, value, child) {
                              final digitsOnly = value.text.replaceAll(
                                RegExp(r'[^0-9]'),
                                '',
                              );

                              return AppButton(
                                    text: l10n.continue_with_phone,
                                    isDisable:
                                        isLoading || digitsOnly.length < 10,
                                    onPressed: isLoading ? null : onLogin,
                                  )
                                  .animate()
                                  .fadeIn(delay: 300.ms)
                                  .slideY(begin: 0.1);
                            },
                          ),
                          const SizedBox(height: AppSizes.p32),
                          const Spacer(),
                          _buildDriverOnboardingInfo(l10n, context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
