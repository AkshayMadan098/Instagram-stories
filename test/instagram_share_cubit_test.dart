import 'package:flutter_test/flutter_test.dart';
import 'package:instagram_stories/core/platform/instagram_story_channel.dart';
import 'package:instagram_stories/features/instagram_share/domain/repositories/instagram_share_repository.dart';
import 'package:instagram_stories/features/instagram_share/presentation/cubit/instagram_share_cubit.dart';
import 'package:instagram_stories/features/instagram_share/presentation/cubit/instagram_share_state.dart';

class MockInstagramShareRepository implements InstagramShareRepository {
  InstagramShareResult stubResult = InstagramShareResult.success;
  bool stubIsInstalled = true;

  @override
  Future<bool> isInstagramInstalled() async => stubIsInstalled;

  @override
  Future<InstagramShareResult> shareToStory({
    required String imagePath,
    String? caption,
  }) async {
    return stubResult;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InstagramShareCubit', () {
    late MockInstagramShareRepository repository;
    late InstagramShareCubit cubit;

    setUp(() {
      repository = MockInstagramShareRepository();
      cubit = InstagramShareCubit(repository: repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is InstagramShareInitial', () {
      expect(cubit.state, isA<InstagramShareInitial>());
    });

    test('emits [Loading, Success] when share succeeds', () async {
      repository.stubResult = InstagramShareResult.success;

      final expectedStates = [
        isA<InstagramShareLoading>(),
        isA<InstagramShareSuccess>(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.shareToInstagramStory(
        imagePath: '/test/story.png',
        caption: 'Look at my project status!',
      );
    });

    test('emits [Loading, InstagramShareNotInstalled] when app is missing', () async {
      repository.stubResult = InstagramShareResult.notInstalled;

      final expectedStates = [
        isA<InstagramShareLoading>(),
        isA<InstagramShareNotInstalled>(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.shareToInstagramStory(
        imagePath: '/test/story.png',
      );
    });

    test('emits [Loading, InstagramShareSimulated] on desktop / simulator', () async {
      repository.stubResult = InstagramShareResult.simulated;

      final expectedStates = [
        isA<InstagramShareLoading>(),
        isA<InstagramShareSimulated>(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));

      await cubit.shareToInstagramStory(
        imagePath: '/test/story.png',
      );
    });
  });
}
