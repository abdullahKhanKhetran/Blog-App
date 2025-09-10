import 'package:blog_app/core/color_pallate.dart';
import 'package:blog_app/core/common/bloc/bloc/connection_bloc.dart';
import 'package:blog_app/core/common/cubits/app_connection/app_connection_cubit.dart';
import 'package:blog_app/core/common/utils/show_dialog.dart';
import 'package:blog_app/core/common/widgets/loader.dart';
import 'package:blog_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_app/features/auth/presentation/pages/login_page.dart';
//import 'package:blog_app/features/auth/presentation/pages/login_page.dart';
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

class _HomePageState extends State<BlogPage> {
  bool isOnline = false;
  List<Widget> screens = [
    BlogScreen(),
    MyBlogsScreen(),
    AddNewBlogPage(),
    ProfilePage(),
  ];
  int _selectedScreenIndex = 0;
  void logout() {
    print("Logging out...");
    context.read<AuthBloc>().add(AuthSignOut());
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          showSnackbar(context, state.message!);
        }
        if (state is AuthLogOutSuccess) {
          print("logged out bitch");
          Navigator.of(
            context,
          ).pushAndRemoveUntil(SignInPage.route(), (route) => false);

          showSnackbar(context, "logged out", "Success");
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return Scaffold(body: SafeArea(child: const Loader()));
        }

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            actions: [
              Icon((isOnline) ? Icons.wifi : Icons.wifi_off),
              IconButton(
                onPressed: () {
                  context.read<ConnectionBloc>().add(CheckConnection());
                  setState(() {
                    isOnline =
                        (context.read<AppConnectionCubit>().state
                            is AppConnectionSuccesful);
                  });
                  print(isOnline);
                },
                icon: Icon(Icons.refresh),
              ),
            ],
            title: Text(switch (_selectedScreenIndex) {
              0 => "Feed",
              1 => "My Blogs",
              2 => "Add New Blog",
              3 => "Profile",
              _ => "unknown",
            }),
          ),
          drawer: Drawer(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.menu),
                  title: Text("MENU", style: TextStyle(fontSize: 20)),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.logout_rounded),
                  title: Text("Log out", style: TextStyle(fontSize: 20)),
                  onTap: logout,
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedScreenIndex,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppPallete.gradient3,
            items: [
              BottomNavigationBarItem(label: "home", icon: Icon(Icons.home)),
              BottomNavigationBarItem(
                label: "My blogs",
                icon: Icon(Icons.table_rows),
              ),
              BottomNavigationBarItem(label: "add", icon: Icon(Icons.add)),
              BottomNavigationBarItem(
                label: "profile",
                icon: Icon(Icons.person),
              ),
            ],
            onTap: (value) {
              setState(() {
                _selectedScreenIndex = value;
              });
            },
          ),
          body: screens[_selectedScreenIndex],
        );
      },
    );
  }
}
