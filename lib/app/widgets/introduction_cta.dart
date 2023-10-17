import 'package:demux_app/app/pages/settings/cubit/app_settings_cubit.dart';
import 'package:demux_app/app/widgets/pages_drawer/cubit/pages_drawer_cubit.dart';
import 'package:demux_app/app/widgets/pages_drawer/cubit/pages_drawer_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IntrodutionCTAWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PagesDrawerCubit pagesDrawerCubit =
        BlocProvider.of<PagesDrawerCubit>(context);
    AppSettingsCubit appSettingsCubit =
        BlocProvider.of<AppSettingsCubit>(context);
    return Container(
      color: Colors.black54,
      child: Stack(
        children: [
          // Close button
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                appSettingsCubit.toggleShowIntroductionMessages(false);
              },
            ),
          ),
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome to Demux!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Add your API key in App Settings to start making requests.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    pagesDrawerCubit.navigateTo(PageRoutes.appSettings);
                  },
                  child: Text('App Settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
