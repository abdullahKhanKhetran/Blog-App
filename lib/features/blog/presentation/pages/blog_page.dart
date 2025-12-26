import 'package:blog_app/core/color_pallate.dart';
import 'package:blog_app/core/common/bloc/app_connection/bloc/connection_bloc.dart';
import 'package:blog_app/core/common/cubits/app_connection/app_connection_cubit.dart';
import 'package:blog_app/core/common/utils/show_dialog.dart';
import 'package:blog_app/core/common/widgets/loader.dart';
import 'package:blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_app/features/auth/presentation/pages/login_page.dart';
import 'package:blog_app/features/blog/presentation/pages/blog_screen.dart';
import 'package:blog_app/features/blog/presentation/pages/add_new_blog_page.dart';
import 'package:blog_app/features/blog/presentation/pages/my_blogs_screen.dart';
import 'package:blog_app/features/blog/presentation/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogPage extends StatefulWidget {
  static route() => MaterialPageRoute(builder: (context) => const BlogPage());
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _HomePageState();
}

class _HomePageState extends State<BlogPage> with WidgetsBindingObserver {
  final List<Widget> _screens = const [
    BlogScreen(),
    MyBlogsScreen(),
    AddNewBlogPage(),
    ProfilePage(),
  ];
  int _selectedScreenIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start periodic connection checks
    context.read<ConnectionBloc>().add(StartPeriodicCheck());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop periodic checks
    context.read<ConnectionBloc>().add(StopPeriodicCheck());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check connection when app resumes
      context.read<ConnectionBloc>().add(CheckConnection());
    }
  }

  void logout() {
    context.read<AuthBloc>().add(AuthSignOut());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          showSnackbar(context, state.message!);
        }
        if (state is AuthLogOutSuccess) {
          Navigator.of(context).pushAndRemoveUntil(
            SignInPage.route(),
            (route) => false,
          );
          showSnackbar(context, "Logged out successfully", "Success");
        }
      },
      builder: (context, authState) {
        if (authState is AuthLoading) {
          return const Scaffold(body: SafeArea(child: Loader()));
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            actions: [
              BlocBuilder<AppConnectionCubit, AppConnectionState>(
                builder: (context, connectionState) {
                  final isOnline = connectionState is AppConnectionSuccesful;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOnline ? Icons.wifi : Icons.wifi_off,
                        color: isOnline ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: isOnline ? Colors.green : Colors.red,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<ConnectionBloc>().add(CheckConnection());
                        },
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh connection',
                      ),
                    ],
                  );
                },
              ),
            ],
            title: Text(
              switch (_selectedScreenIndex) {
                0 => "Feed",
                1 => "My Blogs",
                2 => "Add New Blog",
                3 => "Profile",
                _ => "Blog App",
              },
            ),
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppPallete.gradient1, AppPallete.gradient2],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book, size: 64, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        'Blog App',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text("Log out", style: TextStyle(fontSize: 18)),
                  onTap: () {
                    Navigator.pop(context);
                    logout();
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedScreenIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppPallete.gradient3,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                label: "Feed",
                icon: Icon(Icons.home),
              ),
              BottomNavigationBarItem(
                label: "My Blogs",
                icon: Icon(Icons.table_rows),
              ),
              BottomNavigationBarItem(
                label: "Add",
                icon: Icon(Icons.add_circle),
              ),
              BottomNavigationBarItem(
                label: "Profile",
                icon: Icon(Icons.person),
              ),
            ],
            onTap: (value) {
              setState(() {
                _selectedScreenIndex = value;
              });
            },
          ),
          body: IndexedStack(
            index: _selectedScreenIndex,
            children: _screens,
          ),
        );
      },
    );
  }
}