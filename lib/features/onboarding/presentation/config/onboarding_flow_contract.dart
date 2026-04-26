import 'package:nurtur_app_wppl_agile/features/onboarding/domain/models/onboarding_form_contract.dart';
import 'package:nurtur_app_wppl_agile/features/onboarding/domain/models/onboarding_intro_slide.dart';

class OnboardingFlowContract {
  OnboardingFlowContract._();

  static const String appLabel = 'Nurtur';
  static const int introPageCount = 3;
  static const int totalPageCount = 4;

  static const String introPrimaryButtonLabel = 'Lanjutkan';
  static const String secondaryBackLabel = 'Kembali';
  static const String finalPrimaryButtonLabel = 'Mulai Sekarang';

  static const bool showTopBackActionOnFinalPage = true;
  static const bool showBottomBackActionOnIntroPage = false;
  static const bool showBottomBackActionOnMiddleIntroPages = true;
  static const bool showProgressIndicatorOnFinalPage = false;

  static const List<OnboardingIntroSlide> introSlides = [
    OnboardingIntroSlide(
      id: OnboardingIntroStepId.welcome,
      title: 'Selamat Datang, Ibu Hebat!',
      description:
          'Karena setiap ibu berharga. Mulailah perjalanan penuh perhatian, dukungan, dan ketenangan yang dirancang khusus untuk Anda.',
      primaryButtonLabel: introPrimaryButtonLabel,
      showSecondaryBackAction: false,
      imageAssetPath: 'assets/images/login_family_hero.png',
    ),
    OnboardingIntroSlide(
      id: OnboardingIntroStepId.community,
      title: 'Dukungan Komunitas yang Hangat',
      description:
          'Anda tidak sendirian. Terhubunglah dengan ribuan ibu lainnya yang siap berbagi cerita dan memberikan dukungan di setiap langkah perjalanan Anda.',
      primaryButtonLabel: introPrimaryButtonLabel,
      showSecondaryBackAction: true,
    ),
    OnboardingIntroSlide(
      id: OnboardingIntroStepId.mentalHealth,
      title: 'Kesehatan Mental Anda Prioritas Kami',
      description:
          'Dapatkan akses ke meditasi terbimbing, jurnal harian, dan sesi konsultasi dengan ahli untuk menjaga ketenangan pikiran Anda.',
      primaryButtonLabel: introPrimaryButtonLabel,
      showSecondaryBackAction: true,
    ),
  ];

  static const String finalPageTitle = 'Satu langkah lagi yuk!';
  static const String finalPageSubtitle = 'Lengkapi informasi berikut';
  static const String ageGroupFieldLabel = 'Kelompok Umur';
  static const String roleFieldLabel = 'Saya Seorang...';
  static const String moodFieldLabel = 'Bagaimana Perasaanmu Saat ini?';

  static const bool requiresAgeGroup = true;
  static const bool requiresRole = true;
  static const bool requiresMood = true;

  static const List<OnboardingSelectOption> ageGroupOptions = [
    OnboardingSelectOption(value: 'under_20', label: 'Di bawah 20 tahun'),
    OnboardingSelectOption(value: '20_24', label: '20 - 24 tahun'),
    OnboardingSelectOption(value: '25_29', label: '25 - 29 tahun'),
    OnboardingSelectOption(value: '30_34', label: '30 - 34 tahun'),
    OnboardingSelectOption(value: '35_plus', label: '35 tahun ke atas'),
  ];

  static const List<OnboardingSelectOption> roleOptions = [
    OnboardingSelectOption(value: 'pregnant_mother', label: 'Ibu Hamil'),
    OnboardingSelectOption(value: 'new_mother', label: 'Ibu Baru'),
    OnboardingSelectOption(value: 'toddler_mother', label: 'Ibu dengan Balita'),
    OnboardingSelectOption(value: 'caregiver', label: 'Pendamping Ibu'),
  ];

  static const List<OnboardingMoodOption> moodOptions = [
    OnboardingMoodOption(mood: OnboardingMood.sad, emoji: '😭', label: 'Sedih'),
    OnboardingMoodOption(
      mood: OnboardingMood.annoyed,
      emoji: '😖',
      label: 'Bete',
    ),
    OnboardingMoodOption(
      mood: OnboardingMood.neutral,
      emoji: '😐',
      label: 'Biasa',
    ),
    OnboardingMoodOption(
      mood: OnboardingMood.happy,
      emoji: '😊',
      label: 'Senang',
    ),
    OnboardingMoodOption(
      mood: OnboardingMood.awesome,
      emoji: '😍',
      label: 'Keren',
    ),
  ];
}
