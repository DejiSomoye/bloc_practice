import 'package:bloc_practice/apis/login_api.dart';
import 'package:bloc_practice/apis/notes_api.dart';
import 'package:bloc_practice/block/actions.dart';
import 'package:bloc_practice/block/app_bloc.dart';
import 'package:bloc_practice/block/app_state.dart';
import 'package:bloc_practice/dialogs/generic_dialog.dart';
import 'package:bloc_practice/dialogs/loading_screen.dart';
import 'package:bloc_practice/models.dart';
import 'package:bloc_practice/strings.dart';
import 'package:bloc_practice/views/iterable_list_view.dart';
import 'package:bloc_practice/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc(
        loginApi: LoginApi(),
        notesApi: NotesApi(),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text(homePage),
        ),
        body: BlocConsumer<AppBloc, AppState>(
          builder: (context, appState) {
            final notes = appState.fetchedNotes;
            if (notes == null) {
              return LoginView(
                onLoginTapped: (email, password) {
                  context.read<AppBloc>().add(
                        LoginAction(
                          email: email,
                          password: password,
                        ),
                      );
                },
              );
            } else {
              return notes.toListView();
            }
          },
          listener: (context, appState) {
            if (appState.isLoading) {
              LoadingScreen.instance().show(
                context: context,
                text: pleaseWait,
              );
            } else {
              LoadingScreen.instance().hide();
              final loginError = appState.loginError;
              if (loginError != null) {
                showGenericDialog(
                    context: context,
                    title: loginErrorDialogTitle,
                    content: loginErrorDialogContent,
                    optionsBuilder: () => {ok: true});
              }

              if (appState.isLoading == false &&
                  appState.loginError == null &&
                  appState.loginHandle == const LoginHandle.fooBar() &&
                  appState.fetchedNotes == null) {
                context.read<AppBloc>().add(
                      const LoadNotesAction(),
                    );
              }
            }
          },
        ),
      ),
    );
  }
}
