import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/camera/data/repositories/camera_repository_impl.dart';
import 'features/camera/presentation/cubit/camera_cubit.dart';
import 'features/camera/presentation/pages/camera_page.dart';
import 'features/canvas/presentation/cubit/canvas_cubit.dart';
import 'features/instagram_share/data/repositories/instagram_share_repository_impl.dart';
import 'features/instagram_share/presentation/cubit/instagram_share_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive dark UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const InstagramStoriesApp());
}

class InstagramStoriesApp extends StatelessWidget {
  const InstagramStoriesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final cameraRepository = CameraRepositoryImpl();
    final instagramShareRepository = InstagramShareRepositoryImpl();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: cameraRepository),
        RepositoryProvider.value(value: instagramShareRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<CameraCubit>(
            create: (context) => CameraCubit(repository: cameraRepository),
          ),
          BlocProvider<InstagramShareCubit>(
            create: (context) =>
                InstagramShareCubit(repository: instagramShareRepository),
          ),
          BlocProvider<CanvasCubit>(
            create: (context) => CanvasCubit(imagePath: ''),
          ),
        ],
        child: MaterialApp(
          title: 'Instagram Stories',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const CameraPage(),
        ),
      ),
    );
  }
}
